#r "Newtonsoft.Json"

using System;
using System.Net;
using Newtonsoft.Json;
using System.Xml;

public static async Task<object> Run(HttpRequestMessage req, TraceWriter log)
{
    log.Info($"C# HTTP trigger function processed a request. RequestUri={req.RequestUri}");

        var requestContent = req.Content.ReadAsStringAsync().Result;                
                var xmlNode = JsonConvert.DeserializeXmlNode(requestContent);
                var doc = new XmlDocument();
                doc.LoadXml(xmlNode.OuterXml);
                return new HttpResponseMessage(HttpStatusCode.OK) { Content = new StringContent(doc.OuterXml) };

}