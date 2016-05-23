<%@ WebHandler Language="C#" Class="getProjectByID" %>

using System;
using System.Web;
using localhost;
using System.Web.SessionState;
using System.Data;


/// <summary>
/// 功能：根据版块ID获取版块信息
/// </summary>
public class getProjectByID : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {

        string projectID = context.Request.Form["projectID"];
       
        projectManager dm = new projectManager();
        dm.pageHeaderValue = initWeb.InitWebServiceProxy();
        //DataSet result = new DataSet();
        clsProject dc = dm.getProjectByID(projectID);
        string strJson = toJson.ObjectToJson<clsProject>(dc);
      
        //string result = dc.sectionDesc;
        //string strJson = "{'sectionName':" + dc.sectionName + ",\"sectionManagerID\":" + dc.sectionManagerID + ",\"sectionLogo\":" + dc.sectionLogo + ",\"sectionDesc\":" + dc.sectionDesc + "}";
        

        dm.Dispose();

        context.Response.ContentType = "text/plain";
        context.Response.Write(strJson);
    }

    public bool IsReusable { get { return false; } }
}