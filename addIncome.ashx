<%@ WebHandler Language="C#" Class="addProject " %>

using System;
using System.Web;
using localhost;
using System.Web.SessionState;

/// <summary>
/// addProject 摘要说明
/// 功    能：添加项目。
/// 作    者：卢嘉诚
/// 编写日期：2015-11-05
/// </summary>

public class addProject : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        //获取页面传过来的参数：
        string projectName = context.Request.Form["projectName"];
        string customerName = context.Request.Form["customerName"];
        string payee = context.Request.Form["payee"];
        string Incomeabstract = context.Request.Form["abstract"];
        decimal incomeSum = decimal.Parse(context.Request.Form["incomeSum"].ToString());
        string startDate = context.Request.Form["startDate"];
        string remarks = context.Request.Form["remarks"];

        string paymentApplicantID = "";
        if (HttpContext.Current.Session["curUser"] != null)
        {
            clsUser curUser = (clsUser)HttpContext.Current.Session["curUser"];
            paymentApplicantID = curUser.userID;
        }
        //添加验证：
        FinancialSystem pm = new FinancialSystem();
        pm.pageHeaderValue = initWeb.InitWebServiceProxy();

        string result = pm.addIncome("P201510240001", projectName, "0001", customerName, Incomeabstract, incomeSum,
                                        remarks,"ZH20160518", "工商银行", startDate, paymentApplicantID, payee, paymentApplicantID);
        pm.Dispose();

        context.Response.ContentType = "text/xml";
        context.Response.Write(result);
    }

    public bool IsReusable { get { return false; } }
}