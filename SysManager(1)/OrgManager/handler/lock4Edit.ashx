<%@ WebHandler Language="C#" Class="lock4Edit" %>

using System;
using System.Web;
using WebReference;
using System.Web.SessionState;
using System.Data;

/// <summary>
/// 功    能：锁定指定机构编辑，避免编辑冲突
/// 作    者：邹子杭
/// 修订日期：2015-12-02
/// </summary>

public class lock4Edit : IHttpHandler,IRequiresSessionState {
    
    public void ProcessRequest (HttpContext context) {

        string orgID = context.Request.Form["orgID"];

        organizationManager om = new organizationManager();
        om.pageHeaderValue = initWeb.InitWebServiceProxy();

        string result = om.lock4Edit(orgID);
        om.Dispose();
        
        context.Response.ContentType = "text/plain";
        context.Response.Write(result);
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}