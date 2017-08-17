#r "Newtonsoft.Json"

using System;
using System.Net;
using Newtonsoft.Json;
using System.Xml;
using System.Net.Http.Headers;

public static async Task<object> Run(HttpRequestMessage req, TraceWriter log)
{
    log.Info($"C# HTTP trigger function processed a request. RequestUri={req.RequestUri}");

        var requestContent = req.Content.ReadAsStringAsync().Result;    
        var doc = new XmlDocument();
        doc.LoadXml(requestContent);            
        var json = JsonConvert.SerializeXmlNode(doc.DocumentElement,Newtonsoft.Json.Formatting.Indented, false );
        //return new HttpResponseMessage(HttpStatusCode.OK) { Content = new StringContent(json)};


         var response = new HttpResponseMessage(HttpStatusCode.OK);
 response.Content = new StringContent(json);
    response.Content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

 return response;
}