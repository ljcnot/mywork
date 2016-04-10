<%@ WebHandler Language="C#" Class="addMobileVersionHandler" %>

using System;
using System.Web;
using WebReference;
using System.Web.SessionState;

/// <summary>
/// 功能：添加app版本信息
/// </summary>
public class addMobileVersionHandler : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        string AppVersion = context.Request.Form["AppVersion"];
        int AppVersion2 = Convert.ToInt16(AppVersion);
        string AppExplain = context.Request.Form["AppExplain"];
        string logoUrl = context.Request.Form["logoUrl"];
        systemInfo dm = new systemInfo();
        dm.pageHeaderValue = initWeb.InitWebServiceProxy(); 
        string result = dm.addApp(AppVersion2, logoUrl, AppExplain);

        dm.Dispose();

        context.Response.ContentType = "text/plain";
        context.Response.Write(result);
    }

    public bool IsReusable { get { return false; } }
}