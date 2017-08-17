using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Http;
using Newtonsoft.Json;
using System.Threading;
namespace ConsoleApplication1
{
    class Program
    {
        static void Main(string[] args)
        {

            for (int i = 0; i <= 50; i++)
            {
                //putting few seconds of delay
      
                Thread.Sleep(TimeSpan.FromMilliseconds(200));

                //Console.WriteLine("Value" + i);
                //RAP Sandpit Environment Functions endpoint
                //GetRequest("https://merakifuncapp.azurewebsites.net/api/HttpTriggerCSharp1?code=Qk25r7/aDvKV2BtHjvvCIVf/mLNd6gJVKvqrgLq104QXu/w3ecJq3g==");
                GetRequest("https://vrsalesforce.azurewebsites.net/api/HttpTriggerCSharp1?code=f19ltibk7rjbaudc2t568t1emiblmwvx312ebpezztp8sjlwhfrytm5nqgp6phmkqbcb5mz33di");
                
            }
            //var values = new Dictionary<string, string>
            //    {
            //       { "thing1", "hello" },
            //       { "thing2", "world" }
            //    };

           
            Console.ReadKey();
        }

        async static void GetRequest(string URL)
        {
            

            using (HttpClient client = new HttpClient())
            {
                string postBody = JsonConvert.SerializeObject(Sensor.Generate());
                client.DefaultRequestHeaders.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));

                using (HttpResponseMessage response = await client.PostAsync(URL, new StringContent(postBody, Encoding.UTF8, "application/json")))
                { 
                   
                    //   HttpResponseMessage wcfResponse = await httpClient.PostAsync(resourceAddress, new StringContent(postBody, Encoding.UTF8, "application/json"));
                    using (HttpContent content = response.Content)
                    {

                        string myContent = await content.ReadAsStringAsync();
                        Console.WriteLine(myContent);
                    }

                }
                
            }


        }
    }
}
