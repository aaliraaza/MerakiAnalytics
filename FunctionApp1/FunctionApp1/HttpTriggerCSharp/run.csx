#r "Newtonsoft.Json"


using System.Net;
using System;
using Newtonsoft.Json;

public static object Run(HttpRequestMessage req, ICollector<string> outputEventHubMessage, TraceWriter log)
{
    string SECRET = "MerakiPOC";
    string VALIDATOR = "ValidCode";

    log.Info("C# HTTP trigger function processed a request.");

    string methodVal = req.Method.ToString();
    string methodType = "GET";
    if (methodVal == methodType)
    {
        return req.CreateResponse(HttpStatusCode.OK, VALIDATOR);
    }
    else
    {

        // Get request body
        string jsonContent = req.Content.ReadAsStringAsync().Result;
        dynamic data = JsonConvert.DeserializeObject(jsonContent);

        string name = data["secret"].ToString();

        log.Info(string.Format(" The secret is: {0}", name));

        if (name == SECRET)
        {
            outputEventHubMessage.Add("1 " + data);
            return req.CreateResponse(HttpStatusCode.OK, "Success");
        }
        else
        {

            log.Info(string.Format(" The method {0} is not supported ", "Invalid secret"));
            return req.CreateResponse(HttpStatusCode.BadRequest, "Invalid Secret");
        }

    }

}