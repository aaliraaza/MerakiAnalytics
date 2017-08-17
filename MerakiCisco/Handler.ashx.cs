using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using System.Text;

//adding in the parts for using Azure
using Microsoft.Azure; // Namespace for CloudConfigurationManager
using Microsoft.WindowsAzure.Storage; // Namespace for CloudStorageAccount
using Microsoft.WindowsAzure.Storage.Blob;
using Microsoft.WindowsAzure.Storage.Auth;
using System.Configuration; // Namespace for Blob storage types

//trying out event hub
using Microsoft.ServiceBus.Messaging;


namespace MerakiCisco
{
    /// <summary>
    /// Summary description for Handler
    /// </summary>
    public class Handler : IHttpHandler
    {

        //These must be changed with the values that are in the Meraki dashboard 
        private const string VALIDATOR = "MerakiPOC";
        private const string SECRET = "ValidCode";


        public void ProcessRequest(HttpContext context)
        {
            switch (context.Request.HttpMethod)
            {
                case "GET":
                    GetFile(context);
                    break;
                case "POST":
                    PostFile(context);
                    break;
                default:
                    throw new NotSupportedException(string.Format(" The method {0} is not supported ", context.Request.HttpMethod));
            }

        }

        private void GetFile(HttpContext context)
        {
            context.Response.ContentType = " text / plain ";
            context.Response.Write(VALIDATOR);
        }

        private void PostFile(HttpContext context)
        {
            string dt = string.Format("text-{0:yyyy-MM-dd_hh-mm-ss-tt}", DateTime.Now);
            var ehClient = EventHubClient.CreateFromConnectionString("Endpoint=sb://merakinstest1.servicebus.windows.net/;SharedAccessKeyName=ManagePolicy;SharedAccessKey=StnDcVm4L0rQjiDb/txGNzo6FF/Nt1ZT7PJIi6A4ens=;EntityPath=meraki");
            var jsonString = String.Empty;
            try
            {

                context.Request.InputStream.Position = 0;
                using (var inputStream = new StreamReader(context.Request.InputStream))
                {
                    jsonString = inputStream.ReadToEnd();
                }

                ehClient.Send(new EventData(Encoding.UTF8.GetBytes(jsonString)));
                ehClient.Close();
            }
            catch
            {

            }

        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}