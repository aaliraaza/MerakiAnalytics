using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace MerakiApp
{
    public partial class _Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {



        }

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

            var ehClient = EventHubClient.CreateFromConnectionString("Event hub connection string");

            var jsonString = String.Empty;

            try
            {

                context.Request.InputStream.Position = 0;
                using (var inputStream = new StreamReader(context.Request.InputStream))
                {
                    jsonString = inputStream.ReadToEnd();
                    EventData data = new EventData(Encoding.UTF8.GetBytes(jsonString));
                    ehClient.Send(data);
                    ehClient.Close();
                }

            }

    }
    }