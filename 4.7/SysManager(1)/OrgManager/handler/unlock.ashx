<%@ WebHandler Language="C#" Class="unlock" %>

using System;
using System.Web;
using WebReference;
using System.Web.SessionState;
using System.Data;

/// <summary>
/// 功    能： 释放编辑锁 
/// 作    者：邹子杭
/// 修订日期：2015-12-02
/// </summary>

public class unlock : IHttpHandler ,IRequiresSessionState{
    
    public void ProcessRequest (HttpContext context) {

        string orgID = context.Request.Form["orgID"];

        organizationManager om = new organizationManager();
        om.pageHeaderValue = initWeb.InitWebServiceProxy();

        string result = om.unlock(orgID);
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