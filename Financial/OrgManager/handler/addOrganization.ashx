<%@ WebHandler Language="C#" Class="addOrganization" %>

using System;
using System.Web;
using localhost;
using System.Web.SessionState;
using System.Data;

/// <summary>
/// 功    能：添加机构基本信息
/// 作    者：邹子杭
/// 修订日期：2015-11-30
/// </summary>

public class addOrganization : IHttpHandler ,IRequiresSessionState{
    
    public void ProcessRequest (HttpContext context) {

        //获取页面传过来的参数：        
        int orgType = int.Parse(context.Request.Form["orgType"].ToString());
        //int orgType = 1;
        string orgName = context.Request.Form["orgName"];
        string abbOrgName = context.Request.Form["abbOrgName"];
        string inputCode = context.Request.Form["inputCode"];
        string e_mail = context.Request.Form["e_mail"];
        string tel = context.Request.Form["tel"];
        string tAddress = context.Request.Form["tAddress"];
        string web = context.Request.Form["web"];

        string superiorOrgID = context.Request.Form["superiorOrgID"];
      
        
        //添加验证：
        organizationManager om = new organizationManager();
        om.pageHeaderValue = initWeb.InitWebServiceProxy();

        string result = om.addOrganization(superiorOrgID, orgType, orgName, abbOrgName, 
                                            inputCode, e_mail, tel, tAddress, web);
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