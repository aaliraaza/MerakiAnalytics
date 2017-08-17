#r "Newtonsoft.Json"
#r "System.Xml.Linq"
#r "System.Runtime.Caching"

#load "XsltHelper.csx"
#load "HttpRequestMessageExtensions.csx"
#load "IntegrationXsltException.csx"

using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Linq;
using System.Xml.Xsl;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, TraceWriter log, CancellationToken token)
{
    var clientRequestId = string.Empty;

    try
    {
        clientRequestId = HttpRequestMessageExtensions.GetClientRequestId(request: req);
        log.Info(string.Format("Executing transform operation. client request id: '{0}'", clientRequestId));
        return await XsltHelper.Transform(req, token).ConfigureAwait(continueOnCapturedContext: false);
    }
    catch (IntegrationXsltException ex)
    {
        log.Info(string.Format("An exception occurred while performing transform. client request id: '{0}' and exception: '{1}'", clientRequestId, ex.ToString()));
        return req.CreateErrorResponse(ex.StatusCode, ex.Message);
    }
    catch (Exception ex)
    {
        log.Info(string.Format("An exception occurred while performing transform. client request id: '{0}' and exception: '{1}'", clientRequestId, ex.ToString()));
        throw;
    }
}
