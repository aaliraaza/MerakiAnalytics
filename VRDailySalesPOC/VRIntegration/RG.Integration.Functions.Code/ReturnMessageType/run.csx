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
    string operationName = data["operation"];
    string topicName = "";
    string wrapperName = "";
   
    switch (operationName)
    {
        case "DeleteStudentInformation":
            switch (messageType)
            {
                case "SMO":
                    topicName = "DELETECOURSEENROLLMENT";
                    break; 

                case "MAV":
                    topicName = "DELETECOURSE";
                    break;   

                case "SCE":
                    topicName = "DELETEGROUPMEMBERSHIP";
                    break;  

                case "CRS":
                    topicName = "DELETEGROUP";
                    break;               

                default:
                    break;
            }
            break;


        case "PostStudentInformation":
            switch (messageType)
            {
                case "MAV":
                    wrapperName = "CreateCourse";
                    topicName = "CREATECOURSE";
                    mapName = "Sits.CreateCourseToCanonical.Course";
                    break;

                case "SMO":
                    wrapperName = "EnrolUserCourse";
                    topicName = "ENROLUSERCOURSE";
                    mapName = "Sits.EnrolUserCourseToCanonical.Course";
                    break;

                case "CRS":
                    wrapperName = "CreateGroup";
                    topicName = "CREATEGROUP";
                    mapName = "Sits.CreateGroupToCanonical.Group";
                    break;

                case "YPS":
                    wrapperName = "CreateTerm";
                    topicName = "CREATETERM";
                    mapName = "Sits.CreateTermToCanonical.Term";
                    break;

                case "SCE":
                    wrapperName = "CreateUser";
                    topicName = "CREATEUSER";
                    mapName = "Sits.CreateUserToCanonical.User";
                    break;

                default:
                    break;
            }
            break;

        case "PostStaffInformation":
            switch (messageType)
            {
                case "PRS":
                    wrapperName = "CreateStaff";
                    topicName = "CREATESTAFF";
                    mapName = "Sits.CreateStaffToCanonical.User";
                    break;

                default:
                    break;
            }
            break;
            
        case "PutStudentInformation":
            switch (messageType)
            {
                case "STU":
                    wrapperName = "EditUser";
                    topicName = "EDITUSER";
                    mapName = "Sits.EditUserToCanonical.User";
                    break;
                
                case "MAV":
                    wrapperName = "CreateCourse";
                    topicName = "EDITCOURSE";
                    mapName = "Sits.CreateCourseToCanonical.Course";
                    break;

                case "YPS":
                    wrapperName = "CreateTerm";
                    topicName = "EDITTERM";
                    mapName = "Sits.CreateTermToCanonical.Term";
                    break;
                
                case "CRS":
                    wrapperName = "CreateGroup";
                    topicName = "CREATEGROUP";
                    mapName = "Sits.CreateGroupToCanonical.Group";
                    break;

                case "SCE":
                    wrapperName = "CreateUser";
                    topicName = "EDITCOURSEENROLLMENT";
                    mapName = "Sits.CreateUserToCanonical.User";	
                    break;

                default:
                    break;
            }
            break;

        default:
            break;
    }
    
    return req.CreateResponse(HttpStatusCode.OK, new 
    {
        wrapper = $"{wrapperName}",
        topic = $"{topicName}",
        map = $"{mapName}"
    });
}