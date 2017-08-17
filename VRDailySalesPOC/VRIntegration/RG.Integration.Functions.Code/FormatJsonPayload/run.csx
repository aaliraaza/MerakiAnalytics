#r "Newtonsoft.Json"

using System;
using System.Net;
using Newtonsoft.Json;
using System.Xml;
using System.Net.Http.Headers;
public static async Task<object> Run(HttpRequestMessage req, TraceWriter log)
{
    log.Info($"Webhook was triggered!");
    var requestContent = req.Content.ReadAsStringAsync().Result;                
    var xmlNode = JsonConvert.DeserializeXmlNode(requestContent);
    var doc = new XmlDocument();
    doc.LoadXml(xmlNode.OuterXml);    

 var response = new HttpResponseMessage(HttpStatusCode.OK);
 response.Content = new StringContent(JsonConvert.SerializeXmlNode(doc.DocumentElement, Newtonsoft.Json.Formatting.Indented, false));
    response.Content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

 return response;

}
