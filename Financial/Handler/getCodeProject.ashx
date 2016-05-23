<%@ WebHandler Language="C#" Class="getCodeProject " %>

using System;
using System.Web;
using localhost;
using System.Web.SessionState;
using System.Data;

/// <summary>
/// getCodeDictionary 摘要说明
/// 功    能：获取指定的代码字典
/// 作    者：卢嘉诚
/// 编写日期：2015-11-06
/// </summary>

public class getCodeProject : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        //获取ajax传入的参数：

        string inputCode = context.Request.Form["term"].ToString(); //文本字段名

        //初始化服务：
        FinancialSystem cd = new FinancialSystem();
        cd.pageHeaderValue = initWeb.InitWebServiceProxy();


        DataSet result = cd.getProjectListByInputCode( inputCode, "5");
        DataTable dt = result.Tables[0];
        cd.Dispose();
        //装配成combobox控件指定的格式指定的
        string Json = toJson.DataTableToJson("", dt, "projectID,projectName");
        

        context.Response.ContentType = "text/plain";
        context.Response.Write(Json);
    }

    public bool IsReusable { get { return false; } }
}