#r "Newtonsoft.Json"

using System;
using System.Net;
using System.Threading.Tasks;
using Newtonsoft.Json;

public static async Task<object> Run(HttpRequestMessage req, TraceWriter log)
{
    log.Info($"C# HTTP trigger function processed a request. RequestUri={req.RequestUri}");

    // Get request body
    string jsonContent = await req.Content.ReadAsStringAsync();
    dynamic data = JsonConvert.DeserializeObject(jsonContent);
    string mapName = "";
    string messageType = data["messagetype"];
    string keyid = data["keyid"];
    
    string studentCode = "";
    string moduleCode = "";
    string moduleOccurence = "";
    string periodSlotCode = "";
    string academicYearCode = "";
    string courseCode = "";
    string sis_course_id = "";
    string departmentCode = "";
    string sectionCreateFlag = "";
    string[] msgParts = null;
    switch (messageType)
            {
                case "SMO":
                    //    "keyid": "SMO_1560589_ME7761_D_SPAN1_2016/7_O"
                    msgParts = keyid.Split('_'); 
                    //TODO - Try Parse, for index out of bounds                       
                    messageType = msgParts[0];
                    studentCode = msgParts[1];
                    moduleCode = msgParts[2];
                    moduleOccurence = msgParts[3];
                    periodSlotCode = msgParts[4];
                    academicYearCode = msgParts[5];
                    sectionCreateFlag = msgParts[6];
                    sis_course_id = "undefined";
                    if(sectionCreateFlag == "A")
                    {
                        sis_course_id = moduleCode +'_' + "ALL" + '_' + periodSlotCode +'_' + academicYearCode.Substring(2,2);
                    }
                    if(sectionCreateFlag == "O")
                    {
                        sis_course_id = moduleCode +'_' + moduleOccurence + '_' + periodSlotCode +'_' + academicYearCode.Substring(2,2);
                    }
                    break; 

                case "MAV":
                    //    "keyid": "MAV_ME7761_D_SPAN1_2016/7"
                    msgParts = keyid.Split('_');                        
                    messageType = msgParts[0];
                    moduleCode = msgParts[1];
                    moduleOccurence = msgParts[2];
                    periodSlotCode = msgParts[3];
                    academicYearCode = msgParts[4];
                    sis_course_id = moduleCode +'_' + moduleOccurence + '_' + periodSlotCode +'_' + academicYearCode.Substring(2,2);
                    break;

                case "CRS":
                    //    "keyid": "CRS_ME7761"
                    msgParts = keyid.Split('_');                        
                    messageType = msgParts[0];
                    courseCode = msgParts[1];
                    break;    

                case "SCE":
                    //    "keyid": "SCE_1560589_ME7761"
                    msgParts = keyid.Split('_');                        
                    messageType = msgParts[0];
                    studentCode = msgParts[1];
                    courseCode = msgParts[2];
                    departmentCode = msgParts[3];
                    break;         

                default:
                    break;
            }
   
    
    return req.CreateResponse(HttpStatusCode.OK, new 
    {
        messageType = $"{messageType}",
        studentCode = $"{studentCode}",
        moduleCode = $"{moduleCode}",
        moduleOccurence = $"{moduleOccurence}",
        periodSlotCode = $"{periodSlotCode}",
        academicYearCode = $"{academicYearCode}",
        courseCode = $"{courseCode}",
        sis_course_id = $"{sis_course_id}",
        departmentCode = $"{departmentCode}"
    });
}