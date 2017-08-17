//-----------------------------------------------------------------------
// <copyright file="HttpRequestMessageExtensions.csx" company="Microsoft">
//      All rights reserved.
// </copyright>
//-----------------------------------------------------------------------

using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;

public static class HttpRequestMessageExtensions
{
    public static readonly string HeaderClientRequestId = "x-ms-client-request-id";

    [SuppressMessage("Microsoft.Design", "CA1062:Validate arguments of public methods", Justification = "By design. As this is a extension method caller has to take care of it.")]
    public static string GetClientRequestId(HttpRequestMessage request)
    {
        return HttpRequestMessageExtensions.GetFirstOrDefaultHeader(request: request, name: HttpRequestMessageExtensions.HeaderClientRequestId, defaultValue: string.Empty);
    }

    [SuppressMessage("Microsoft.Design", "CA1026:DefaultParametersShouldNotBeUsed", Justification = "By design")]
    [SuppressMessage("Microsoft.Design", "CA1062:Validate arguments of public methods", Justification = "By design. As this is a extension method caller has to take care of it.")]
    public static string GetFirstOrDefaultHeader(HttpRequestMessage request, string name, string defaultValue = null)
    {
        IEnumerable<string> values = (IEnumerable<string>)null;

        if (request.Headers.TryGetValues(name, out values) && values.Any<string>())
        {
            return values.First<string>();
        }

        return defaultValue;
    }

    [SuppressMessage("Microsoft.Design", "CA1062:Validate arguments of public methods", Justification = "By design. As this is a extension method caller has to take care of it.")]
    public static HttpResponseMessage CreateXmlResponse(HttpRequestMessage request, HttpStatusCode statusCode, HttpContent content)
    {
        var response = request.CreateResponse(statusCode);

        try
        {
            if (content != null)
            {
                response.Content = content;
                response.Content.Headers.ContentType = new MediaTypeHeaderValue("application/xml");
            }
        }
        catch
        {
            response.Dispose();
            response = null;
            throw;
        }

        return response;
    }
}
