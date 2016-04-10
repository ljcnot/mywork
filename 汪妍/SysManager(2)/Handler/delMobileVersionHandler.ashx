<%@ WebHandler Language="C#" Class="delMobileVersionHandler" %>

using System;
using System.Web;
using WebReference;
using System.Web.SessionState;

/// <summary>
/// 功能：删除app版本信息
/// </summary>
public class delMobileVersionHandler : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        string AppVersion = context.Request.Form["AppVersion"];
        int AppVersion2 = Convert.ToInt16(AppVersion);
            
        systemInfo dm = new systemInfo();
        dm.pageHeaderValue = initWeb.InitWebServiceProxy(); 
        
        string result = dm.delApp(AppVersion2);

        dm.Dispose();

        context.Response.ContentType = "text/plain";
        context.Response.Write(result);
    }

    public bool IsReusable { get { return false; } }
}