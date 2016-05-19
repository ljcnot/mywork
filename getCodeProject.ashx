<%@ WebHandler Language="C#" Class="getCodeDictionary " %>

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

public class getCodeDictionary : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        //获取ajax传入的参数：
        string projectID = context.Request.QueryString["projectID"];    //项目ID
        string inputCode = context.Request.Form["inputCode"].ToString(); //文本字段名
        string maxItem = context.Request.Form["valueFieldName"].ToString();//值字段名

        //初始化服务：
        FinancialSystem cd = new FinancialSystem();
        cd.pageHeaderValue = initWeb.InitWebServiceProxy();


        DataSet result = cd.getProjectListByInputCode(projectID, inputCode,maxItem);
        DataTable dt = result.Tables[0];
        cd.Dispose();
        //装配成combobox控件指定的格式指定的
        string Json = "";
        Json += "[";
        if (dt.Rows.Count > 0)
        {
            for (int i = 0; i < dt.Rows.Count; i++)
            {
                Json += "{";
                Json += textField + ": \"" + dt.Rows[i][textField].ToString() + "\",";
                Json += valueField + ": \"" + dt.Rows[i][valueField].ToString() + "\"";
                Json += "}";
                if (i < dt.Rows.Count - 1)
                {
                    Json += ",";
                }
            }
        }
        Json += "]";

        context.Response.ContentType = "text/plain";
        context.Response.Write(Json);
    }

    public bool IsReusable { get { return false; } }
}