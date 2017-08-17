//-----------------------------------------------------------------------
// <copyright file="XsltHelper.csx" company="Microsoft">
//      All rights reserved.
// </copyright>
//-----------------------------------------------------------------------

#load "ContentEnvelope.csx"
#load "ContentHash.csx"
#load "ContentLinkDefinition.csx"
#load "HttpRequestMessageExtensions.csx"
#load "IntegrationXsltException.csx"
#load "Validation.csx"
#load "XsltInput.csx"

using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Runtime.Caching;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Linq;
using System.Xml.Xsl;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public static class XsltHelper
{
	private static readonly MemoryCache CompiledTransformCache = new MemoryCache("CompiledTransformCache");

	private static readonly CacheItemPolicy CachePolicy = new CacheItemPolicy()
	{
		SlidingExpiration = new TimeSpan(0, 20, 0)
	};

	public static async Task<HttpResponseMessage> Transform(HttpRequestMessage request, CancellationToken cancellationToken)
	{
		var transformRequest = await XsltHelper.GetXsltInput(request, cancellationToken).ConfigureAwait(continueOnCapturedContext: false);

		Validation.XslTransformRequest(transformRequest);

		try
		{
			using (var mapContent = await XsltHelper.GetMapContent(transformRequest.MapContentLink.Uri, cancellationToken).ConfigureAwait(continueOnCapturedContext: false))
			using (var seekableMapContent = new MemoryStream())
			{
				await mapContent.CopyToAsync(seekableMapContent).ConfigureAwait(continueOnCapturedContext: false);

				seekableMapContent.Position = 0;

				// NOTE(rarayudu): Using stream readers to take care of encoding issues.
				// In logic apps RP, we are always storing the schema/map contents using UTF8 encdoing. This will create problems for XMLs which have encoding of type other than UTF8.
				// Another possibility is to read the content as string and use the StringReader. - Not following that as don't want to load the entire string incase if the schema is large.
				using (var transformStreamReader = new StreamReader(stream: seekableMapContent, detectEncodingFromByteOrderMarks: true))
				{
					var arguments = XsltHelper.GetXsltArguments(
						xsltParameters: transformRequest.XsltParameters,
						transformStreamReader: transformStreamReader);

					var inputXmlContent = transformRequest.Content.Type == JTokenType.String
						? Encoding.UTF8.GetBytes(transformRequest.Content.ToObject<string>())
						: transformRequest.Content.ToObject<ContentEnvelope>().DecodeAsBytes();

					var settings = new XsltSettings(enableDocumentFunction: true, enableScript: true);

					// NOTE(rarayudu): Set the transform stream reader stream postion to start for the XslCompiledTransform.
					transformStreamReader.BaseStream.Position = 0;

					using (var inputXmlStream = new MemoryStream(inputXmlContent))
					using (var inputXmlStreamReader = new StreamReader(stream: inputXmlStream, detectEncodingFromByteOrderMarks: true))
					using (var inputXmlReader = XmlReader.Create(inputXmlStreamReader))
					{
						var xsltCompiler = GetCompiledTransformFromCache(mapAbsolutePath: transformRequest.MapContentLink.Uri.AbsolutePath, mapVersion: transformRequest.MapContentLink.ContentVersion);

						if (xsltCompiler == null)
						{
							using (var transformXmlReader = XmlReader.Create(transformStreamReader))
							{
								xsltCompiler = new XslCompiledTransform();
								xsltCompiler.Load(transformXmlReader, settings, new XmlUrlResolver());

								XsltHelper.CompiledTransformCache.Set(
									key: transformRequest.MapContentLink.Uri.AbsolutePath,
									value: new TransformCachedItem(mapVersion: transformRequest.MapContentLink.ContentVersion, compiledTransform: xsltCompiler),
									policy: CachePolicy);
							}
						}

						using (var outputStream = new MemoryStream())
						using (var outputXmlWriter = XmlWriter.Create(outputStream))
						{
							xsltCompiler.Transform(inputXmlReader, arguments, outputXmlWriter);

							return HttpRequestMessageExtensions.CreateXmlResponse(
								request: request,
								statusCode: HttpStatusCode.OK,
								content: new ByteArrayContent(outputStream.ToArray()));
						}
					}
				}
			}
		}
		catch (XmlException ex)
		{
			throw new IntegrationXsltException(
				statusCode: HttpStatusCode.BadRequest,
				message: string.Format(CultureInfo.InvariantCulture, "An error occurred while processing input xml. '{0}'", ex.Message),
				innerException: ex);
		}
		catch (XsltException ex)
		{
			throw new IntegrationXsltException(
				statusCode: HttpStatusCode.BadRequest,
				message: string.Format(CultureInfo.InvariantCulture, "An error occurred while processing map. '{0}'", ex.Message),
				innerException: ex);
		}
		catch (IntegrationXsltException)
		{
			XsltHelper.CompiledTransformCache.Remove(key: transformRequest.MapContentLink.Uri.AbsolutePath);

			throw;
		}
	}

	private static async Task<XsltInput> GetXsltInput(HttpRequestMessage request, CancellationToken cancellationToken)
	{
		try
		{
			return await request.Content.ReadAsAsync<XsltInput>(cancellationToken).ConfigureAwait(continueOnCapturedContext: false);
		}
		catch (Exception ex)
		{
			if (ex is FormatException || ex is ArgumentException || ex is JsonException)
			{
				throw new IntegrationXsltException(
					statusCode: HttpStatusCode.BadRequest,
					message: string.Format(CultureInfo.InvariantCulture, "The request content is not valid and could not be deserialized: '{0}'", ex.Message),
					innerException: ex);
			}

			throw;
		}
	}

	private static async Task<Stream> GetMapContent(Uri mapContentLink, CancellationToken cancellationToken)
	{
		var httpClient = new HttpClient();
		var response = await httpClient.GetAsync(mapContentLink, cancellationToken).ConfigureAwait(continueOnCapturedContext: false);

		if (response.StatusCode != HttpStatusCode.OK)
		{
			var responseContent = response.Content != null
				? await response.Content.ReadAsStringAsync().ConfigureAwait(continueOnCapturedContext: false)
				: string.Empty;

			throw new IntegrationXsltException(
				statusCode: response.StatusCode,
				message: string.Format(CultureInfo.InvariantCulture, "An error occurred while fetching the map content using the content link: '{0}'. Error: '{1}'", mapContentLink, responseContent));
		}

		return await response.Content.ReadAsStreamAsync().ConfigureAwait(continueOnCapturedContext: false);
	}

	private static XsltArgumentList GetXsltArguments(IDictionary<string, string> xsltParameters, TextReader transformStreamReader)
	{
		var arguments = new XsltArgumentList();
		if (xsltParameters != null)
		{
			foreach (KeyValuePair<string, string> parameter in xsltParameters)
			{
				if (parameter.Key.Contains(':'))
				{
					var splitArgument = parameter.Key.Split(':');
					if (splitArgument.Length == 2)
					{
						arguments.AddParam(splitArgument[1], GetParameterNamespace(splitArgument[0], transformStreamReader), parameter.Value ?? string.Empty);
					}
					else
					{
						arguments.AddParam(parameter.Key, string.Empty, parameter.Value ?? string.Empty);
					}
				}
				else
				{
					arguments.AddParam(parameter.Key, string.Empty, parameter.Value ?? string.Empty);
				}
			}
		}

		return arguments;
	}

	private static string GetParameterNamespace(string namespacePrefix, TextReader transformStreamReader)
	{
		var xsltDocument = XDocument.Load(transformStreamReader);
		if (xsltDocument.Root != null)
		{
			var namespaceOfPrefix = xsltDocument.Root.GetNamespaceOfPrefix(namespacePrefix);
			return namespaceOfPrefix != null ? namespaceOfPrefix.NamespaceName : string.Empty;
		}
		else
		{
			throw new IntegrationXsltException(HttpStatusCode.BadRequest, "The provided map is not valid.");
		}
	}

	private static XslCompiledTransform GetCompiledTransformFromCache(string mapAbsolutePath, string mapVersion)
	{
		if (CompiledTransformCache.Contains(mapAbsolutePath))
		{
			var cachedData = (TransformCachedItem)CompiledTransformCache.Get(key: mapAbsolutePath);

			if (cachedData.MapVersion == mapVersion)
			{
				return cachedData.CompiledTransform;
			}
		}

		return null;
	}

	private class TransformCachedItem
	{
		public TransformCachedItem(string mapVersion, XslCompiledTransform compiledTransform)
		{
			this.MapVersion = mapVersion;
			this.CompiledTransform = compiledTransform;
		}

		public string MapVersion { get; set; }

		public XslCompiledTransform CompiledTransform { get; set; }
	}
}