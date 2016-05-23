<%@ WebHandler Language="C#" Class="getClassNumber" %>

using System;
using System.Web;
using System;
using System.Web;
using localhost;
using System.Web.SessionState;
using System.Data;

public class getClassNumber : IHttpHandler,IRequiresSessionState {
    
    public void ProcessRequest (HttpContext context) {

        //获取调用者传过来的执行参数：
        string Type = context.Request.Form["type"];       //单据类型

        //添加验证：
        sysEncoder se = new sysEncoder();
        se.pageHeaderValue = initWeb.InitWebServiceProxy();

        string result = "";
        result = se.getClassNumber(numberClass.orgCode, 0);
        se.Dispose();
            
        context.Response.ContentType = "text/plain";
        context.Response.Write(result);
    }
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}