<%@ WebHandler Language="C#" Class="getOrgInfo" %>

using System;
using System.Web;
using localhost;
using System.Web.SessionState;
using System.Data;

/// <summary>
/// 功    能： 查询指定代码的机构基本信息(返回对象) 
/// 作    者：邹子杭
/// 修订日期：2015-11-30
/// </summary>

public class getOrgInfo : IHttpHandler ,IRequiresSessionState{
    
    public void ProcessRequest (HttpContext context) {

        //获取页面传过来的参数：
        string orgID = context.Request.Form["orgID"].ToString();//机构代码

        //添加验证：
        organizationManager om = new organizationManager();
        om.pageHeaderValue = initWeb.InitWebServiceProxy();

        clsOrganization co = om.getOrgInfo(orgID);
        string strJson = toJson.ObjectToJson<clsOrganization>(co);
        
        context.Response.ContentType = "text/plain";
        context.Response.Write(strJson);
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}