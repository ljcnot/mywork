<%@ WebHandler Language="C#" Class="queryOrgInfo" %>

using System;
using System.Web;
using WebReference;
using System.Web.SessionState;
using System.Data;

public class queryOrgInfo : IHttpHandler ,IRequiresSessionState{
    
    public void ProcessRequest (HttpContext context) {

        //获取页面传过来的参数：
        string orgID = context.Request.Form["orgID"].ToString();//机构代码

        //添加验证：
        organizationManager om = new organizationManager();
        om.pageHeaderValue = initWeb.InitWebServiceProxy();

        //DataSet ds = new DataSet();
        //ds = om.queryOrgInfo(orgID);
        string strJson = toJson.ToJson(om.queryOrgInfo(orgID).Tables[0],0);
        
        context.Response.ContentType = "text/plain";
        context.Response.Write(strJson);
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}