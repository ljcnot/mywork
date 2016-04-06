<%@ WebHandler Language="C#" Class="userListHandler" %>

using System;
using System.Web;
using WebReference;
using System.Web.SessionState;
using System.Data;


/// <summary>
/// 功能：根据版块ID获取版块信息
/// </summary>
public class userListHandler : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {

        //获取flexigrid控件传过来的查询参数：
        string page = context.Request.Form["page"];             //当前页
        string rp = context.Request.Form["rp"];                 //每页行数
        string strWhere = context.Request.Form["where"] == null ? "" : context.Request.Form["where"];        //传入的筛选条件
        string sortname = context.Request.Form["sortname"];     //排序字段名称
        string sortorder = context.Request.Form["sortorder"];   //排序方式
        string query = context.Request.Form["query"];           //搜索值
        string qtype = context.Request.Form["qtype"];           //搜索字段名

        //添加验证：
        userManager list = new userManager();
        list.pageHeaderValue = initWeb.InitWebServiceProxy();

        //装配查询参数：
        pageSet myPageSet = new pageSet();
        myPageSet.curPage = int.Parse(page) - 1;
        myPageSet.pageSize = int.Parse(rp);
        pageDataSet result;

        string strOrderBy = "order by " + sortname + " " + sortorder;
        result = list.generalPageQuery("", strWhere, strOrderBy, myPageSet);    //一般查询
        list.Dispose();

        context.Response.ContentType = "text/xml";
        context.Response.Write(toXML.ToXML(result));
    }

    public bool IsReusable { get { return false; } }
}