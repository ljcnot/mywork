<%@ WebHandler Language="C#" Class="UploadHandler" %>
using System;
using System.Collections.Generic;

using System.IO;   
using System.Net;
using System.Web;
using System.Web.Services;
using System.Web.SessionState;

/// <summary>
/// UploadHandler:上传的处理函数。注意：现在这个函数是把文件写入了上传目录，但是没有登记到数据库中！
/// 作    者：卢苇
/// 编写日期：2012-3-31
/// </summary>
public class UploadHandler : IHttpHandler, IRequiresSessionState
{
    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/plain";   
        context.Response.Charset = "utf-8";

        HttpPostedFile file = context.Request.Files["Filedata"];

        string dir = DateTime.Now.ToString("yyyyMM");
        string uploadPath = HttpContext.Current.Server.MapPath("../"+@context.Request["folder"]) + "/" + dir + "/"; //存放路径：按月份分开存放

        //获取文件的全球唯一名：
        string filename = System.Guid.NewGuid().ToString();
        string extFilename = file.FileName.Substring(file.FileName.LastIndexOf("."));
        if (file != null)  
        {  
            //检查上传目录：
            if (!Directory.Exists(uploadPath))  
            {  
                Directory.CreateDirectory(uploadPath);  
            }
            file.SaveAs(uploadPath + filename + extFilename);  
            //将保存的文件名传送回去：
            context.Response.Write(@context.Request["folder"] + "/" + dir + "/" + filename + extFilename);  
        }   
        else  
        {   
            context.Response.Write("0");   
        }  
    }

    public bool IsReusable
    {
        get { return false; }
    }
}
