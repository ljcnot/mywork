<%@ WebHandler Language="C#" Class="delOrganization" %>

using System;
using System.Web;
using WebReference;
using System.Web.SessionState;
using System.Data;

/// <summary>
/// 功    能：删除指定的机构
/// 作    者：邹子杭
/// 修订日期：2015-11-30
/// </summary>

public class delOrganization : IHttpHandler ,IRequiresSessionState{
    
    public void ProcessRequest (HttpContext context) {

        //获取页面传过来的参数：
        string orgID = context.Request.Form["orgID"];
        
        //添加验证：
        organizationManager om = new organizationManager();
        om.pageHeaderValue = initWeb.InitWebServiceProxy();

        string result = om.delOrganization(orgID);
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