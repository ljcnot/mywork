<%@ WebHandler Language="C#" Class="getCodeDic" %>

using System;
using System.Web;
using localhost;
using System.Web.SessionState;
using System.Data;

public class getCodeDic : IHttpHandler, IRequiresSessionState
{
    
    public void ProcessRequest (HttpContext context) {

        //获取ajax传入的参数：
        string classCode = context.Request.QueryString["classCode"];    //代码字典的编号
        string textField = context.Request.Form["textFieldName"].ToString(); //文本字段名
        string valueField = context.Request.Form["valueFieldName"].ToString();//值字段名
        
         //初始化服务：
        cdManager cd = new cdManager();
        cd.pageHeaderValue = initWeb.InitWebServiceProxy();

        DataSet result = cd.codeDictionaryItem(classCode,"1");
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
 
    public bool IsReusable {
        get {
            return false;
        }
    }

}