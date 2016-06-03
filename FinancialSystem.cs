using System;
using System.Web;
using System.Collections;
using System.Collections.Generic;
using System.Web.Services;
using System.Web.Services.Protocols;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;
using System.Web.Configuration;

/// <summary>
/// FinancialSystem 的摘要说明
/// </summary>
[WebService(Namespace = "http://tempuri.org/")]
[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
// 若要允许使用 ASP.NET AJAX 从脚本中调用此 Web 服务，请取消注释以下行。 
// [System.Web.Script.Services.ScriptService]
public class FinancialSystem : virtualWebService
{

    public FinancialSystem () {

        //如果使用设计的组件，请取消注释以下行 
        //InitializeComponent(); 
    }

     [WebMethod]
    public string HelloWorld()
    {
        return "Hello World";
    }




     #region 查询
     /// <summary>
     /// 功    能：借支单，分页查询语句，根据前台传入的查询条件、排序方式和要检索的字段、分页设置参数，采用分页技术检索项目列表结果集
     /// 作    者：卢苇
     /// 编写日期：2016-5-16
     /// </summary>
     /// <param name="colList">列名,“*” or “”代表全部字段</param>
     /// <param name="strWhere">范围约束</param>
     /// <param name="strOrder">排序要求</param>
     /// <param name="myPageSet">分页参数</param>
     /// <returns>项目列表结果集：数据的列为输入的列名前加一个行号</returns>
     [WebMethod(Description = "分页查询语句，根据前台传入的查询条件、排序方式和要检索的字段、分页设置参数，采用分页技术检索项目列表结果集<br />"
                             + "<a href='../../SDK/PM/Interface.html#projectManager.PageQueryProjectList'>SDK说明</a>", EnableSession = false)]
     [SoapHeader("PageHeader")]
     public pageDataSet PageQueryBorrowSingleList(string colList, string strWhere, string strOrder, pageSet myPageSet)
     {
         verifyPageHeader(this);
         if (colList.Trim() == "" || colList.Trim() == "*")
         {
             colList = "borrowSingleID,borrowMan, position, department,";
             colList += "borrowDate, projectName,borrowReason,isnull(borrowSum,0)borrowSum";
         }
         if (strOrder.Trim() == "")
         {
             strOrder = "order by borrowSingleID desc";
         }
         string tabName = "borrowSingle ";
         if (strWhere != "")
             strWhere = strWhere.Replace("|", "%");

         return sysTools.pageSelect(tabName, colList, strWhere, strOrder, myPageSet);
     }

     /// <summary>
     /// 功   能：获取借支单列表           
     /// 作    者：卢苇
     /// 编写日期：2015-10-21
     /// </summary>
     /// <param name="colList">列名,“*” or “”代表全部字段</param>
     /// <param name="strWhere">范围约束</param>
     /// <param name="strOrder">排序要求</param>
     /// <returns>项目列表结果集</returns>
     [WebMethod(Description = "一般查询语句，根据前台传入的查询条件、排序方式和要检索的字段，检索项目列表结果集<br />"
                             + "<a href='../../SDK/PM/Interface.html#projectManager.getProjectList'>SDK说明</a>", EnableSession = false)]
     [SoapHeader("PageHeader")]
     public DataSet getProjectList(string colList, string strWhere, string strOrder)
     {
         verifyPageHeader(this);
         if (colList.Trim() == "" || colList.Trim() == "*")
         {
             colList = "borrowSingleID,borrowMan, position, department,";
             colList += "borrowDate, projectName,borrowReason,isnull(borrowSum,0)borrowSum";
         }
         if (strWhere != "")
             strWhere = strWhere.Replace("|", "%");
         if (strOrder.Trim() == "")
             strOrder = "order by borrowSingleID desc";
         string tabName = "borrowSingle ";

         string strCmd = "select " + colList + " from " + tabName + " " + strWhere + " " + strOrder;
         //从web.config获取连接字符串
         string constr = WebConfigurationManager.ConnectionStrings["constr"].ToString();
         using (SqlConnection sqlcon = new SqlConnection(constr))
         {
             try
             {
                 sqlcon.Open();
                 DataSet ds = new DataSet();
                 using (SqlCommand sqlCmd = new SqlCommand(strCmd, sqlcon))
                 using (SqlDataAdapter da = new SqlDataAdapter(sqlCmd))
                 {
                     da.Fill(ds);
                 }
                 return ds;
             }
             catch (Exception e)
             {
                 return null;
             }
         }
     }


     /// <summary>
     /// 功    能：根据编号查找项目（返回结果集）
     /// 作    者：卢苇
     /// 编写日期：2015-10-21
     /// </summary>
     /// <param name="projectID">项目编号</param>
     /// <returns>项目（结果集方式）</returns>
     [WebMethod(Description = "根据编号查找项目（返回结果集）<br />"
                             + "<a href='../../SDK/PM/Interface.html#projectManager.queryProjectByID'>SDK说明</a>", EnableSession = false)]
     [SoapHeader("PageHeader")]
     public DataSet queryBorrowSingleByID(string borrowSingleID)
     {
         verifyPageHeader(this);
         string strCmd = "select borrowSingleID,borrowMan, position, department,";
         strCmd += "borrowDate, projectName,borrowReason,isnull(borrowSum,0)borrowSum";
         strCmd += " from borrowSingle";
         strCmd += " where borrowSingleID='" + borrowSingleID + "'";

         //从web.config获取连接字符串
         string constr = WebConfigurationManager.ConnectionStrings["constr"].ToString();
         using (SqlConnection sqlcon = new SqlConnection(constr))
         {
             try
             {
                 sqlcon.Open();
                 DataSet ds = new DataSet();
                 using (SqlCommand sqlCmd = new SqlCommand(strCmd, sqlcon))
                 using (SqlDataAdapter da = new SqlDataAdapter(sqlCmd))
                 {
                     da.Fill(ds);
                 }
                 return ds;
             }
             catch (Exception e)
             {
                 return null;
             }
         }
     }

     /// <summary>
     /// 功    能：根据编号查找项目（返回对象）
     /// 作    者：卢苇
     /// 编写日期：2015-10-21
     /// </summary>
     /// <param name="projectID">项目编号</param>
     /// <returns>项目（对象方式）</returns>
     [WebMethod(Description = "根据编号查找项目（返回对象）<br />"
                             + "<a href='../../SDK/PM/Interface.html#projectManager.getProjectByID'>SDK说明</a>", EnableSession = false)]
     [SoapHeader("PageHeader")]
     public clsProject getProjectByID(string projectID)
     {
         verifyPageHeader(this);
         return new clsProject(projectID);
     }

     /// <summary>
     /// 功    能：收入明细，分页查询语句，根据前台传入的查询条件、排序方式和要检索的字段、分页设置参数，采用分页技术检索项目列表结果集
     /// 作    者：卢苇
     /// 编写日期：2016-5-16
     /// </summary>
     /// <param name="colList">列名,“*” or “”代表全部字段</param>
     /// <param name="strWhere">范围约束</param>
     /// <param name="strOrder">排序要求</param>
     /// <param name="myPageSet">分页参数</param>
     /// <returns>项目列表结果集：数据的列为输入的列名前加一个行号</returns>
     [WebMethod(Description = "分页查询语句，根据前台传入的查询条件、排序方式和要检索的字段、分页设置参数，采用分页技术检索项目列表结果集<br />"
                             + "<a href='../../SDK/PM/Interface.html#projectManager.PageQueryProjectList'>SDK说明</a>", EnableSession = false)]
     [SoapHeader("PageHeader")]
     public pageDataSet PageQueryIncomeList(string colList, string strWhere, string strOrder, pageSet myPageSet)
     {
         verifyPageHeader(this);
         if (colList.Trim() == "" || colList.Trim() == "*")
         {
             colList = "incomeInformationID,isnull(convert(varchar(19),startDate,120),'') startDate, abstract, isnull(incomeSum,0) incomeSum,";
             colList += "remarks";
         }
         if (strOrder.Trim() == "")
         {
             strOrder = "order by incomeInformationID desc";
         }
         string tabName = "incomeList ";
         if (strWhere != "")
             strWhere = strWhere.Replace("|", "%");

         return sysTools.pageSelect(tabName, colList, strWhere, strOrder, myPageSet);
     }


     /// <summary>
     /// 功   能：获取收入明细列表           
     /// 作    者：卢苇
     /// 编写日期：2015-10-21
     /// </summary>
     /// <param name="colList">列名,“*” or “”代表全部字段</param>
     /// <param name="strWhere">范围约束</param>
     /// <param name="strOrder">排序要求</param>
     /// <returns>项目列表结果集</returns>
     [WebMethod(Description = "一般查询语句，根据前台传入的查询条件、排序方式和要检索的字段，检索项目列表结果集<br />"
                             + "<a href='../../SDK/PM/Interface.html#projectManager.getProjectList'>SDK说明</a>", EnableSession = false)]
     [SoapHeader("PageHeader")]
     public DataSet getIncomeList(string colList, string strWhere, string strOrder)
     {
         verifyPageHeader(this);
         if (colList.Trim() == "" || colList.Trim() == "*")
         {
             colList = "incomeInformationID,isnull(convert(varchar(19),startDate,120),'') startDate, abstract, isnull(incomeSum,0) incomeSum,";
             colList += "remarks";
         }
         if (strWhere != "")
             strWhere = strWhere.Replace("|", "%");
         if (strOrder.Trim() == "")
             strOrder = "order by incomeInformationID desc";
         string tabName = "incomeList ";

         string strCmd = "select " + colList + " from " + tabName + " " + strWhere + " " + strOrder;
         //从web.config获取连接字符串
         string constr = WebConfigurationManager.ConnectionStrings["constr"].ToString();
         using (SqlConnection sqlcon = new SqlConnection(constr))
         {
             try
             {
                 sqlcon.Open();
                 DataSet ds = new DataSet();
                 using (SqlCommand sqlCmd = new SqlCommand(strCmd, sqlcon))
                 using (SqlDataAdapter da = new SqlDataAdapter(sqlCmd))
                 {
                     da.Fill(ds);
                 }
                 return ds;
             }
             catch (Exception e)
             {
                 return null;
             }
         }
     }

     #endregion


     #region 借支单的增删改及锁定

     /// <summary>
    /// 功    能：添加借支单
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-21
    /// </summary>
    /// <param name="borrowManID">借支人ID</param>
    /// <param name="borrowMan">借支人姓名</param>
    /// <param name="position">借支人职务</param>
    /// <param name="departmentID">部门ID</param>
    /// <param name="department">部门</param>
    /// <param name="borrowDate">借支时间</param>
    /// <param name="projectID">所在项目ID</param>
    /// <param name="projectName">所在项目（名称）</param>
    /// <param name="borrowReason">借支事由</param>
    /// <param name="borrowSum">借支金额</param>
     /// <param name="createManID">创建人ID</param>
    /// <returns>成功：借支单编号，采用401号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "添加借支单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
     public string addBorrowSingle(string borrowManID, string borrowMan, string position, string departmentID, string department, string borrowDate, string projectID,
        string projectName, string borrowReason, decimal borrowSum, string createManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	            name:		addborrowSingle
	            function:	1.添加借支单
				            注意：本存储过程不锁定编辑！
	            input: 
			            @borrowManID varchar(10),		--借支人ID
			            @borrowMan varchar(30),		    --借支人（姓名）
			            @position	varchar(20),		--职务
			            @departmentID	varchar(13),	--部门ID
			            @department	varchar(30),		--部门
			            @borrowDate	smalldatetime,  	--借支时间
			            @projectID	 varchar(13),		--所在项目ID
			            @projectName	varchar(30),	--所在项目（名称）
			            @borrowReason	varchar(200),	--借支事由
			            @borrowSum		numeric(15,2),  --借支金额

			            @createManID varchar(10),		--创建人工号
	            output: 
				            @borrowSingleID varchar(13),	--借支单号,主键 由401号号码发生器生成
				            @Ret		int output		--操作成功标识
							            0:成功，9：未知错误
	            author:		卢嘉诚
	            CreateDate:	2016-3-23
        */
        SqlCommand cmd = new SqlCommand("addborrowSingle", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@borrowSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@borrowSingleID"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@borrowManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@borrowManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowManID"].Value = borrowManID;

        cmd.Parameters.Add("@borrowMan", SqlDbType.VarChar, 30);
        cmd.Parameters["@borrowMan"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowMan"].Value = borrowMan;

        cmd.Parameters.Add("@position", SqlDbType.VarChar, 20);
        cmd.Parameters["@position"].Direction = ParameterDirection.Input;
        cmd.Parameters["@position"].Value = position;

        cmd.Parameters.Add("@departmentID", SqlDbType.VarChar, 13);
        cmd.Parameters["@departmentID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@departmentID"].Value = departmentID;

        cmd.Parameters.Add("@department", SqlDbType.VarChar, 30);
        cmd.Parameters["@department"].Direction = ParameterDirection.Input;
        cmd.Parameters["@department"].Value = department;

        cmd.Parameters.Add("@borrowDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@borrowDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowDate"].Value = borrowDate;

        cmd.Parameters.Add("@projectID", SqlDbType.VarChar, 13);
        cmd.Parameters["@projectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectID"].Value = projectID;

        cmd.Parameters.Add("@projectName", SqlDbType.VarChar, 30);
        cmd.Parameters["@projectName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectName"].Value = projectName;

        cmd.Parameters.Add("@borrowReason", SqlDbType.VarChar, 200);
        cmd.Parameters["@borrowReason"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowReason"].Value = borrowReason;

        cmd.Parameters.Add("@borrowSum", SqlDbType.Money);
        cmd.Parameters["@borrowSum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowSum"].Value = borrowSum;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = createManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@borrowSingleID"].Value;
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }



    /// <summary>
    /// 功    能：编辑借支单
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-21
    /// </summary>
    /// <param name="borrowSingleID">借支单号ID</param>
    /// <param name="borrowManID">借支人ID</param>
    /// <param name="borrowMan">借支人姓名</param>
    /// <param name="position">借支人职务</param>
    /// <param name="departmentID">部门ID</param>
    /// <param name="department">部门</param>
    /// <param name="borrowDate">借支时间</param>
    /// <param name="projectID">所在项目ID</param>
    /// <param name="projectName">所在项目（名称）</param>
    /// <param name="borrowReason">借支事由</param>
    /// <param name="borrowSum">借支金额</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：编辑成功！；失败："Error：..."</returns>
    [WebMethod(Description = "编辑借支单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string editBorrowSingle(string borrowSingleID,string borrowManID, string borrowMan, string position, string departmentID, string department, string borrowDate, string projectID,
        string projectName, string borrowReason, decimal borrowSum, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		editborrowSingle
	        function:	1.编辑借支单
				        注意：本存储过程锁定编辑！
	        input: 
			        @borrowSingleID varchar(13),	--借支单号,主键
			        @borrowManID varchar(10),		--借支人ID
			        @borrowMan varchar(30),		--借支人（姓名）
			        @position	varchar(20),			--职务
			        @departmentID	varchar(13),		--部门ID
			        @department	varchar(30),		--部门
			        @borrowDate	smalldatetime,	--借支时间
			        @projectID	 varchar(13),		--所在项目ID
			        @projectName	varchar(30),		--所在项目（名称）
			        @borrowReason	varchar(200),		--借支事由
			        @borrowSum		numeric(15,2),--借支金额

	        output: 
				        @lockManID varchar(10) output,		--锁定人工号
				        @Ret		int output		--操作表示，0：成功，1：该借支单不存在，2：该单据为审核状态不允许编辑，3：该单据被其他人编辑占用,4:请先锁定该单据再编辑,避免冲突

	        author:		卢嘉诚
	        CreateDate:	2016-3-23
        */
        SqlCommand cmd = new SqlCommand("editBorrowSingle", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@borrowSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@borrowSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowSingleID"].Value = borrowSingleID;

        cmd.Parameters.Add("@borrowManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@borrowManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowManID"].Value = borrowManID;

        cmd.Parameters.Add("@borrowMan", SqlDbType.VarChar, 30);
        cmd.Parameters["@borrowMan"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowMan"].Value = borrowMan;

        cmd.Parameters.Add("@position", SqlDbType.VarChar, 20);
        cmd.Parameters["@position"].Direction = ParameterDirection.Input;
        cmd.Parameters["@position"].Value = position;

        cmd.Parameters.Add("@departmentID", SqlDbType.VarChar, 13);
        cmd.Parameters["@departmentID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@departmentID"].Value = departmentID;

        cmd.Parameters.Add("@department", SqlDbType.VarChar, 30);
        cmd.Parameters["@department"].Direction = ParameterDirection.Input;
        cmd.Parameters["@department"].Value = department;

        cmd.Parameters.Add("@borrowDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@borrowDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowDate"].Value = borrowDate;

        cmd.Parameters.Add("@projectID", SqlDbType.VarChar, 13);
        cmd.Parameters["@projectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectID"].Value = projectID;

        cmd.Parameters.Add("@projectName", SqlDbType.VarChar, 30);
        cmd.Parameters["@projectName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectName"].Value = projectName;

        cmd.Parameters.Add("@borrowReason", SqlDbType.VarChar, 200);
        cmd.Parameters["@borrowReason"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowReason"].Value = borrowReason;

        cmd.Parameters.Add("@borrowSum", SqlDbType.Money);
        cmd.Parameters["@borrowSum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowSum"].Value = borrowSum;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar,10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

         
        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "编辑成功！";
            if (ret == 1)
                return "Error:借支单" + borrowSingleID + "不存在！";
            if (ret == 2)
                return "Error:借支单" + borrowSingleID + "为审核状态不允许编辑！";
            if (ret == 3)
                return "Error:该单据已被用户" + lockManID + "锁定，无法编辑";
            if (ret == 4)
                return "Error:请先锁定该借支单再编辑，避免冲突";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }



    /// <summary>
    /// 功    能：锁定指定借支单
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-21
    /// </summary>
    /// <param name="borrowSingleID">借支单号ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：锁定成功！；失败："Error：..."</returns>
    [WebMethod(Description = "锁定指定借支单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string lockBorrowSingleEdit(string borrowSingleID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
           	     name:		addborrowSingle
	            function:	1.锁定借支单
				            锁定借支单编辑，避免编辑冲突
	input: 
				@borrwSingleID varchar(13),			--借支单ID
				@lockManID varchar(10) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的借支单不存在，2:要锁定的借支单正在被别人编辑，
							3:该单据已经批复，不能编辑锁定，
							9：未知错误
	            author:		卢嘉诚
	            CreateDate:	2016-3-23
	            UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
        */
        SqlCommand cmd = new SqlCommand("lockBorrowSingleEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@borrowSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@borrowSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowSingleID"].Value = borrowSingleID;


        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "锁定成功！";
            else if (ret == 1)
                return "Error:借支单" + borrowSingleID + "不存在！";
            else if (ret == 2)
                return "Error:该单据已被用户" + lockManID + "锁定！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }



    /// <summary>
    /// 功    能：释放指定借支单编辑锁
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-21
    /// </summary>
    /// <param name="borrowSingleID">借支单号ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：释放编辑锁成功！；失败："Error：..."</returns>
    [WebMethod(Description = "释放指定借支单编辑锁<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string unlockborrowSingleEdit(string borrowSingleID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
           	     name:		addborrowSingle
	            function:	1.释放锁定借支单编辑，避免编辑冲突
				           
	input: 
				@borrwSingleID varchar(13),			--借支单ID
				@lockManID varchar(10) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该借支单不存在，2：锁定该单据的人不是自己，8:该单据未被锁定,9：未知错误
	            author:		卢嘉诚
	            CreateDate:	2016-3-23
        */
        SqlCommand cmd = new SqlCommand("unlockborrowSingleEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@borrowSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@borrowSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowSingleID"].Value = borrowSingleID;


        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "释放编辑锁成功！";
            else if (ret == 1)
                return "Error:借支单" + borrowSingleID + "不存在！";
            else if (ret == 2)
                return "Error:该单据已被用户" + lockManID + "锁定！";
            else if (ret == 8)
                return "Error:该单据未被任何人锁定";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }



    /// <summary>
    /// 功    能：删除指定借支单
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-26
    /// </summary>
    /// <param name="borrowSingleID">借支单号ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：删除借支单成功！；失败："Error：..."</returns>
    [WebMethod(Description = "删除指定借支单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    [SoapHeader("PageHeader")]
    public string delborrowSingle(string borrowSingleID, string lockManID)
    {
        verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		delborrowSingle
	        function:	删除指定借支单
	        input: 
				        @borrowSingleID varchar(13),			--借支单ID
				        @lockManID varchar(10) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	        output: 
				        @Ret		int output		--操作成功标识
							        0:成功，
							        1：指定的借支单不存在，
							        2:要删除的借支单正被别人锁定，
							        3:该单据已经批复，不能删除，
							        4:请先锁定该借支单，再删除，避免冲突
							        9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-4-16

        */
        SqlCommand cmd = new SqlCommand("delborrowSingle", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@borrowSingleID", SqlDbType.VarChar, 15);
        cmd.Parameters["@borrowSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowSingleID"].Value = borrowSingleID;


        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 13);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "删除借支单成功！";
            else if (ret == 1)
                return "Error:借支单" + borrowSingleID + "不存在！";
            else if (ret == 2)
                return "Error:该单据已被用户" + lockManID + "锁定！";
            else if (ret == 3)
                return "Error:该单据处于审核状态无法删除";
            else if (ret == 4)
                return "Error:请先锁定该借支单，再删除，避免冲突";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }




    /// <summary>
    /// 功    能：审核指定借支单
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-21
    /// </summary>
    /// <param name="billID">借支单ID</param>
    /// <param name="approvalStatus">审批情况</param>
    /// <param name="approvalOpinions">审批意见</param>
    /// <param name="examinationPeoplePost">审批人职务</param>
    /// <param name="examinationPeopleID">审批人ID</param>
    /// <param name="examinationPeopleName">审批人名称</param>
    /// <param name="createManID">创建人ID</param>
    /// <returns>成功：返回@Ret表示；失败："Error：..."</returns>
    [WebMethod(Description = "审核指定借支单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string AuditBorrowSingle(string billID, int approvalStatus, string approvalOpinions, string examinationPeoplePost, string examinationPeopleID, string examinationPeopleName, string createManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		AuditBorrowSingle
	        function:	1.审核借支单
				        注意：本存储过程不锁定编辑！
	        input: 
			        @billID	varchar(13),				--借支单ID
			        @approvalStatus smallint,			--审批情况（0：同意/1“不同意）
			        @approvalOpinions	varchar(200),		--审批意见
			        @examinationPeoplePost varchar(20),	--审批人职务
			        @examinationPeopleID	varchar(10),	--审批人ID
			        @examinationPeopleName	varchar(30),	--审批人名称

			        @createManID varchar(10) output,			--创建人ID
	        output: 
			        @Ret		int output           --操作成功标识,0:成功，1：要审核的借支单不存在，2：该借支单正在被其他用户锁定，3：该借支单为处于审核状态，4:请先锁定该借支单再审核避免冲突，9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-5-7

        */
        SqlCommand cmd = new SqlCommand("AuditBorrowSingle", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;


        cmd.Parameters.Add("@billID", SqlDbType.VarChar,13);
        cmd.Parameters["@billID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@billID"].Value = billID;

        cmd.Parameters.Add("@approvalStatus", SqlDbType.SmallInt);
        cmd.Parameters["@approvalStatus"].Direction = ParameterDirection.Input;
        cmd.Parameters["@approvalStatus"].Value = approvalStatus;

        cmd.Parameters.Add("@approvalOpinions", SqlDbType.VarChar, 200);
        cmd.Parameters["@approvalOpinions"].Direction = ParameterDirection.Input;
        cmd.Parameters["@approvalOpinions"].Value = approvalOpinions;

        cmd.Parameters.Add("@examinationPeoplePost", SqlDbType.VarChar,20);
        cmd.Parameters["@examinationPeoplePost"].Direction = ParameterDirection.Input;
        cmd.Parameters["@examinationPeoplePost"].Value = examinationPeoplePost;

        cmd.Parameters.Add("@examinationPeopleID", SqlDbType.VarChar,10);
        cmd.Parameters["@examinationPeopleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@examinationPeopleID"].Value = examinationPeopleID;

        cmd.Parameters.Add("@examinationPeopleName", SqlDbType.VarChar,30);
        cmd.Parameters["@examinationPeopleName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@examinationPeopleName"].Value = examinationPeopleName;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar,10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@createManID"].Value = createManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            createManID = (string)cmd.Parameters["@createManID"].Value;
            if (ret == 0)
                return "审核成功！";
            else if (ret == 1)
                return "Error:要审核的借支单" + billID + "不存在！";
            else if (ret == 2)
                return "Error:该借支单已被用户" + createManID + "锁定！";
            else if (ret == 3)
                return "Error:该借支单处未处于审核状态！";
            else if (ret == 4)
                return "Error:请先锁定该借支单避免冲突！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }



    #endregion


    #region 报销单的增删改及锁定
    /// <summary>
    /// 功    能：添加费用报销单
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-21
    /// </summary>
    /// <param name="departmentID">部门ID</param>
    /// <param name="ExpRemDepartment">报销部门</param>
    /// <param name="ExpRemDate">报销日期</param>
    /// <param name="projectID">项目ID</param>
    /// <param name="projectName">项目名称</param>
    /// <param name="ExpRemSingleNum">报销单据及附件数</param>
    /// <param name="note">备注</param>
    /// <param name="expRemSingleType">报销单类型</param>
    /// <param name="amount">合计金额</param>
    /// <param name="borrowSingleID">原借支单ID</param>
    /// <param name="originalloan">原借款</param>
    /// <param name="replenishment">应补款</param>
    /// <param name="shouldRefund">应退款</param>
    /// <param name="originalloan">原借款</param>
    /// <param name="ExpRemPersonID">报销人ID</param>
    /// <param name="ExpRemPerson">报销人姓名</param>
    /// <param name="businessPeopleID">出差人ID</param>
    /// <param name="businessPeople">出差人姓名</param>
    /// <param name="businessReason">出差事由</param>
    /// <param name="approvalStatus">审批进度</param>
    /// <returns>成功：借支单编号，采用401号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "添加费用报销单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string addExpRemSingle(string departmentID, string ExpRemDepartment, string ExpRemDate, string projectID,
        string projectName, int ExpRemSingleNum, string note, int expRemSingleType, decimal amount, string borrowSingleID,
        decimal originalloan, decimal replenishment, decimal shouldRefund, string ExpRemPersonID, string ExpRemPerson,
        string businessPeopleID, string businessPeople, string businessReason, int approvalStatus, string createManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		addExpRemSingle
	        function:	1.添加费用报销单
				        注意：本存储过程不锁定编辑！
	        input: 
				        @departmentID varchar(13) ,	--部门ID
				        @ExpRemDepartment varchar(30)	,	--报销部门
				        @ExpRemDate smalldatetime ,	--报销日期
				        @projectID varchar(13) ,	--项目ID
				        @projectName varchar(50) ,	--项目名称
				        @ExpRemSingleNum smallint ,	--报销单据及附件
				        @note varchar(200),	--备注
				        @expRemSingleType smallint ,	--报销单类型，0：费用报销单，1：差旅费报销单
				        @amount numeric(15,2) ,	--合计金额
				        @borrowSingleID varchar(13) ,	--原借支单ID
				        @originalloan numeric(15,2) ,	--原借款
				        @replenishment numeric(15,2) ,	--应补款
				        @shouldRefund numeric(15,2) ,	--应退款
				        @ExpRemPersonID varchar(10) ,	--报销人编号
				        @ExpRemPerson varchar(30),	--报销人姓名
				        @businessPeopleID	varchar(10),	--出差人编号
				        @businessPeople	varchar(30) ,	--出差人
				        @businessReason varchar(200)	,	--出差事由
				        @approvalStatus smallint ,		--审批状态，0：未发起，1：审核中，2：审批完成

				        @createManID varchar(10),		--创建人工号
	        output: 
				        @Ret		int output		--操作成功标识
							        0:成功，1：该国别名称或代码已存在，9：未知错误
				        @ExpRemSingleID varchar(13) output	--主键：报销单编号，使用第403号号码发生器产生
				        @createTime smalldatetime output
	        author:		卢嘉诚
	        CreateDate:	2016-3-23
        */
        SqlCommand cmd = new SqlCommand("addExpRemSingle", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@departmentID", SqlDbType.VarChar, 13);
        cmd.Parameters["@departmentID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@departmentID"].Value = departmentID;

        cmd.Parameters.Add("@ExpRemDepartment", SqlDbType.VarChar, 30);
        cmd.Parameters["@ExpRemDepartment"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemDepartment"].Value = ExpRemDepartment;

        cmd.Parameters.Add("@ExpRemDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@ExpRemDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemDate"].Value = ExpRemDate;

        cmd.Parameters.Add("@projectID", SqlDbType.VarChar, 13);
        cmd.Parameters["@projectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectID"].Value = projectID;

        cmd.Parameters.Add("@projectName", SqlDbType.VarChar, 50);
        cmd.Parameters["@projectName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectName"].Value = projectName;

        cmd.Parameters.Add("@ExpRemSingleNum", SqlDbType.SmallInt);
        cmd.Parameters["@ExpRemSingleNum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleNum"].Value = ExpRemSingleNum;

        cmd.Parameters.Add("@note", SqlDbType.VarChar, 200);
        cmd.Parameters["@note"].Direction = ParameterDirection.Input;
        cmd.Parameters["@note"].Value = note;

        cmd.Parameters.Add("@expRemSingleType", SqlDbType.SmallInt);
        cmd.Parameters["@expRemSingleType"].Direction = ParameterDirection.Input;
        cmd.Parameters["@expRemSingleType"].Value = expRemSingleType;

        cmd.Parameters.Add("@amount", SqlDbType.Money);
        cmd.Parameters["@amount"].Direction = ParameterDirection.Input;
        cmd.Parameters["@amount"].Value = amount;

        cmd.Parameters.Add("@borrowSingleID", SqlDbType.VarChar,13);
        cmd.Parameters["@borrowSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowSingleID"].Value = borrowSingleID;

        cmd.Parameters.Add("@originalloan", SqlDbType.Money);
        cmd.Parameters["@originalloan"].Direction = ParameterDirection.Input;
        cmd.Parameters["@originalloan"].Value = originalloan;

        cmd.Parameters.Add("@replenishment", SqlDbType.Money);
        cmd.Parameters["@replenishment"].Direction = ParameterDirection.Input;
        cmd.Parameters["@replenishment"].Value = replenishment;

        cmd.Parameters.Add("@shouldRefund", SqlDbType.Money);
        cmd.Parameters["@shouldRefund"].Direction = ParameterDirection.Input;
        cmd.Parameters["@shouldRefund"].Value = shouldRefund;

        cmd.Parameters.Add("@ExpRemPersonID", SqlDbType.VarChar,10);
        cmd.Parameters["@ExpRemPersonID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemPersonID"].Value = ExpRemPersonID;

        cmd.Parameters.Add("@ExpRemPerson", SqlDbType.VarChar,30);
        cmd.Parameters["@ExpRemPerson"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemPerson"].Value = ExpRemPerson;

        cmd.Parameters.Add("@businessPeopleID", SqlDbType.VarChar, 10);
        cmd.Parameters["@businessPeopleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessPeopleID"].Value = businessPeopleID;

        cmd.Parameters.Add("@businessPeople", SqlDbType.VarChar, 30);
        cmd.Parameters["@businessPeople"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessPeople"].Value = businessPeople;

        cmd.Parameters.Add("@businessReason", SqlDbType.VarChar, 200);
        cmd.Parameters["@businessReason"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessReason"].Value = businessReason;

        cmd.Parameters.Add("@approvalStatus", SqlDbType.SmallInt);
        cmd.Parameters["@approvalStatus"].Direction = ParameterDirection.Input;
        cmd.Parameters["@approvalStatus"].Value = approvalStatus;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar,10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = createManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@ExpRemSingleID"].Direction = ParameterDirection.Output;
        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@ExpRemSingleID"].Value;
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }






    /// <summary>
    /// 功    能：添加费用报销详情
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-26
    /// </summary>
    /// <param name="ExpRemSingleID">报销单ID</param>
    /// <param name="abstract">摘要</param>
    /// <param name="supplementaryExplanation">补充说明</param>
    /// <param name="financialAccountID">报销科目ID</param>
    /// <param name="financialAccount">报销科目</param>
    /// <param name="expSum">金额</param>
    /// <returns>成功：报销详情编号，采用404号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "添加费用报销详情<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string addExpenseReimbursementDetails(string ExpRemSingleID, string ExpRemAbstract, string supplementaryExplanation, string financialAccountID, string financialAccount, decimal expSum ,string createManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	            name:		addExpenseReimbursementDetails
	            function:	1.添加费用报销单详情
				            注意：本存储过程不锁定编辑！
	            input: 
				            @ExpRemSingleID	varchar(13),	--报销单ID
				            @abstract	varchar(100),	--摘要
				            @supplementaryExplanation	varchar(100),	--补充说明
				            @financialAccountID	varchar(8),	--报销科目ID
				            @financialAccount	varchar(30),	--报销科目
				            @expSum	numeric(15,2),	--金额

				            @createManID varchar(10),		--创建人工号
	            output: 
				            @Ret		int output,      --操作成功标识，0：成功，9：未知错误
				            @rowNum		int output,		--序号
				            @createTime smalldatetime output
	            author:		卢嘉诚
	            CreateDate:	2016-3-23
        */
        SqlCommand cmd = new SqlCommand("addExpenseReimbursementDetails", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@ExpRemSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleID"].Value = ExpRemSingleID;

        cmd.Parameters.Add("@abstract", SqlDbType.VarChar, 100);
        cmd.Parameters["@abstract"].Direction = ParameterDirection.Input;
        cmd.Parameters["@abstract"].Value = ExpRemAbstract;

        cmd.Parameters.Add("@supplementaryExplanation", SqlDbType.VarChar,100);
        cmd.Parameters["@supplementaryExplanation"].Direction = ParameterDirection.Input;
        cmd.Parameters["@supplementaryExplanation"].Value = supplementaryExplanation;

        cmd.Parameters.Add("@financialAccountID", SqlDbType.VarChar, 8);
        cmd.Parameters["@financialAccountID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@financialAccountID"].Value = financialAccountID;

        cmd.Parameters.Add("@financialAccount", SqlDbType.VarChar, 30);
        cmd.Parameters["@financialAccount"].Direction = ParameterDirection.Input;
        cmd.Parameters["@financialAccount"].Value = financialAccount;

        cmd.Parameters.Add("@expSum", SqlDbType.Money);
        cmd.Parameters["@expSum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@expSum"].Value = expSum;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = createManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@createTime", SqlDbType.SmallDateTime);
        cmd.Parameters["@createTime"].Direction = ParameterDirection.Output;

        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@ExpRemDetailsID"].Value;
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    /// <summary>
    /// 功    能：添加差旅费报销详情
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-26
    /// </summary>
    /// <param name="ExpRemSingleID">报销单ID</param>
    /// <param name="StartDate">起始时间</param>
    /// <param name="endDate">结束日期</param>
    /// <param name="startingPoint">起点</param>
    /// <param name="destination">终点</param>
    /// <param name="vehicle">交通工具</param>
    ///  <param name="documentsNum">单据张数</param>
    /// <param name="vehicleSum">交通费金额</param>
    /// <param name="financialAccountID">科目ID</param>
    /// <param name="financialAccount">科目名称</param>
    /// <param name="peopleNum">人数</param>
    /// <param name="travelDays">出差天数</param>
    ///  <param name="TravelAllowanceStandard">出差补贴标准</param>
    /// <param name="travelAllowancesum">补贴金额</param>
    /// <param name="otherExpenses">其他费用</param>
    /// <param name="otherExpensesSum">其他费用金额</param>
    /// <returns>成功：报销详情编号，采用404号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "添加差旅费报销详情<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string addTravelExpensesDetails(string ExpRemSingleID, string StartDate, string endDate, string startingPoint, string destination, string vehicle, string documentsNum,
        string vehicleSum, string financialAccountID, string financialAccount, int peopleNum, float travelDays, decimal TravelAllowanceStandard, decimal travelAllowancesum,
        string otherExpenses, decimal otherExpensesSum, string createManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	       	name:		addTravelExpensesDetails
	        function:	1.添加差旅费报销详情
				        注意：本存储过程不锁定编辑！
	        input: 
				        @ExpRemSingleID varchar(13),	--报销单编号
				        @StartDate smalldatetime,	--起始时间
				        @endDate smalldatetime,	--结束日期
				        @startingPoint varchar(12),	--起点
				        @destination varchar(12),	--终点
				        @vehicle		varchar(12),	--交通工具
				        @documentsNum	int,	--单据张数
				        @vehicleSum	numeric(15,2),	--交通费金额
				        @financialAccountID	varchar(8),	--科目ID
				        @financialAccount	varchar(30),	--科目名称
				        @peopleNum	int,	--人数
				        @travelDays float,	-- 出差天数
				        @TravelAllowanceStandard numeric(15,2),	--出差补贴标准
				        @travelAllowancesum	numeric(15,2),	--补贴金额
				        @otherExpenses	varchar(20),	--其他费用
				        @otherExpensesSum	numeric(15,2),	--其他费用金额

				        @createManID varchar(10),		--创建人工号

				        @Ret		int output,
				        @createTime smalldatetime output
	        output: 
				        @Ret		int output		--操作成功标识，0：成功，9：未知错误
				        @createTime smalldatetime output
	        author:		卢嘉诚
	        CreateDate:	2016-3-23
        */
        SqlCommand cmd = new SqlCommand("addTravelExpensesDetails", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@ExpRemSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleID"].Value = ExpRemSingleID;

        cmd.Parameters.Add("@StartDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@StartDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@StartDate"].Value = StartDate;

        cmd.Parameters.Add("@endDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@endDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@endDate"].Value = endDate;

        cmd.Parameters.Add("@startingPoint", SqlDbType.VarChar, 12);
        cmd.Parameters["@startingPoint"].Direction = ParameterDirection.Input;
        cmd.Parameters["@startingPoint"].Value = startingPoint;

        cmd.Parameters.Add("@destination", SqlDbType.VarChar, 12);
        cmd.Parameters["@destination"].Direction = ParameterDirection.Input;
        cmd.Parameters["@destination"].Value = destination;

        cmd.Parameters.Add("@vehicle", SqlDbType.VarChar,12);
        cmd.Parameters["@vehicle"].Direction = ParameterDirection.Input;
        cmd.Parameters["@vehicle"].Value = vehicle;

        cmd.Parameters.Add("@documentsNum", SqlDbType.Int);
        cmd.Parameters["@documentsNum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@documentsNum"].Value = documentsNum;

        cmd.Parameters.Add("@vehicleSum", SqlDbType.Money);
        cmd.Parameters["@vehicleSum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@vehicleSum"].Value = vehicleSum;

        cmd.Parameters.Add("@financialAccountID", SqlDbType.VarChar,8);
        cmd.Parameters["@financialAccountID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@financialAccountID"].Value = financialAccountID;

        cmd.Parameters.Add("@financialAccount", SqlDbType.VarChar,30);
        cmd.Parameters["@financialAccount"].Direction = ParameterDirection.Input;
        cmd.Parameters["@financialAccount"].Value = financialAccount;

        cmd.Parameters.Add("@peopleNum", SqlDbType.Int);
        cmd.Parameters["@peopleNum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@peopleNum"].Value = peopleNum;

        cmd.Parameters.Add("@travelDays", SqlDbType.Float);
        cmd.Parameters["@travelDays"].Direction = ParameterDirection.Input;
        cmd.Parameters["@travelDays"].Value = travelDays;

        cmd.Parameters.Add("@TravelAllowanceStandard", SqlDbType.Money);
        cmd.Parameters["@TravelAllowanceStandard"].Direction = ParameterDirection.Input;
        cmd.Parameters["@TravelAllowanceStandard"].Value = TravelAllowanceStandard;

        cmd.Parameters.Add("@travelAllowancesum", SqlDbType.Money);
        cmd.Parameters["@travelAllowancesum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@travelAllowancesum"].Value = travelAllowancesum;

        cmd.Parameters.Add("@otherExpenses", SqlDbType.VarChar,20);
        cmd.Parameters["@otherExpenses"].Direction = ParameterDirection.Input;
        cmd.Parameters["@otherExpenses"].Value = otherExpenses;

        cmd.Parameters.Add("@otherExpensesSum", SqlDbType.Money);
        cmd.Parameters["@otherExpensesSum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@otherExpensesSum"].Value = otherExpensesSum;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = createManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@createTime", SqlDbType.SmallDateTime);
        cmd.Parameters["@createTime"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return "添加成功！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }



    /// <summary>
    /// 功    能：删除指定报销单
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-26
    /// </summary>
    /// <param name="ExpRemSingleID">报销单ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：返回@Ret表示；失败："Error：..."</returns>
    [WebMethod(Description = "删除指定报销单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string delExpRemSingle(string ExpRemSingleID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		delExpRemSingle
	        function:	删除报销单
	        input: 
				        @ExpRemSingleID varchar(13),			--报销单ID
				        @lockManID varchar(10) output,	--锁定人，如果当前报销单正在被人占用编辑则返回该人的工号
	        output: 
				        @Ret		int output		--操作成功标识
							        0:成功，1：指定的借支单不存在，
							        2:要删除的借支单正被别人锁定，
							        3:该单据已经批复，不能编辑锁定，
							        9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-4-16
	        UpdateDate: 
        */
        SqlCommand cmd = new SqlCommand("delExpRemSingle", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@ExpRemSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleID"].Value = ExpRemSingleID;


        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "删除报销单成功！";
            else if (ret == 1)
                return "Error:报销单" + ExpRemSingleID + "不存在！";
            else if (ret == 2)
                return "Error:该单据已被用户" + lockManID + "锁定！";
            else if (ret == 3)
                return "Error:该单据处于审核状态无法删除";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }



    /// <summary>
    /// 功    能：锁定指定报销单
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-21
    /// </summary>
    /// <param name="ExpRemSingleID">报销单号ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：返回@Ret表示；失败："Error：..."</returns>
    [WebMethod(Description = "锁定指定报销单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string lockExpRemSingleEdit(string ExpRemSingleID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
            name:		lockExpRemSingleEdit
	        function:	锁定报销单编辑，避免编辑冲突
	        input: 
				        @ExpRemSingleID varchar(13),			--报销单ID
				        @lockManID varchar(10) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	        output: 
				        @Ret		int output		--操作成功标识
							        0:成功，1：要锁定的借支单不存在，2:要锁定的借支单正在被别人编辑，
							        3:该单据已经批复，不能编辑锁定，
							        9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-4-16
	        UpdateDate: 
        */
        SqlCommand cmd = new SqlCommand("lockExpRemSingleEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@ExpRemSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleID"].Value = ExpRemSingleID;


        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "锁定成功！";
            else if (ret == 1)
                return "Error:报销单" + ExpRemSingleID + "不存在！";
            else if (ret == 2)
                return "Error:该单据已被用户" + lockManID + "锁定！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }



    /// <summary>
    /// 功    能：释放指定报销单编辑锁
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-21
    /// </summary>
    /// <param name="borrowSingleID">借支单号ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：返回@Ret表示；失败："Error：..."</returns>
    [WebMethod(Description = "释放指定报销单编辑锁<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string unlockExpRemSingleEdit(string ExpRemSingleID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
            name:		unlockExpRemSingleEdit
	        function:	释放锁定报销单编辑，避免编辑冲突
	        input: 
				        @ExpRemSingleID varchar(13),			--报销单ID
				        @lockManID varchar(10) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	        output: 
				        @Ret		int output		--操作成功标识
							        0:成功，1：要锁定的借支单不存在，2:要锁定的借支单正在被别人编辑，
							        3:该单据已经批复，不能编辑锁定，
							        9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-4-16
	        UpdateDate: 
        */
        SqlCommand cmd = new SqlCommand("unlockExpRemSingleEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@ExpRemSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleID"].Value = ExpRemSingleID;


        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "释放编辑锁成功！";
            else if (ret == 1)
                return "Error:报销单" + ExpRemSingleID + "不存在！";
            else if (ret == 2)
                return "Error:该单据已被用户" + lockManID + "锁定！";
            else if (ret == 8)
                return "Error:该单据未被任何人锁定";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }



    /// <summary>
    /// 功    能：编辑费用报销单
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-21
    /// </summary>
    /// <param name="ExpRemSingleID">部门ID</param>
    /// <param name="departmentID">部门ID</param>
    /// <param name="ExpRemDepartment">报销部门</param>
    /// <param name="ExpRemDate">报销日期</param>
    /// <param name="projectID">项目ID</param>
    /// <param name="projectName">项目名称</param>
    /// <param name="ExpRemSingleNum">报销单据及附件数</param>
    /// <param name="note">备注</param>
    /// <param name="expRemSingleType">报销单类型</param>
    /// <param name="amount">合计金额</param>
    /// <param name="borrowSingleID">原借支单ID</param>
    /// <param name="originalloan">原借款</param>
    /// <param name="replenishment">应补款</param>
    /// <param name="shouldRefund">应退款</param>
    /// <param name="originalloan">原借款</param>
    /// <param name="ExpRemPersonID">报销人ID</param>
    /// <param name="ExpRemPerson">报销人姓名</param>
    /// <param name="businessPeopleID">出差人ID</param>
    /// <param name="businessPeople">出差人姓名</param>
    /// <param name="businessReason">出差事由</param>
    /// <param name="approvalStatus">审批进度</param>
    /// <returns>成功：编辑成功！；失败："Error：..."</returns>
    [WebMethod(Description = "编辑费用报销单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string editExpRemSingle(string ExpRemSingleID, string departmentID, string ExpRemDepartment, string ExpRemDate, string projectID,
        string projectName, int ExpRemSingleNum, string note, int expRemSingleType, decimal amount, string borrowSingleID,
        decimal originalloan, decimal replenishment, decimal shouldRefund, string ExpRemPersonID, string ExpRemPerson,
        string businessPeopleID, string businessPeople, string businessReason, int approvalStatus, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	            name:		editExpRemSingle
	            function:	1.编辑报销单
				            注意：本存储过程锁定编辑！
	            input: 
				            @ExpRemSingleID varchar(13),  --报销单ID			
				            @departmentID varchar(13) ,	--部门ID
				            @ExpRemDepartment varchar(30)	,	--报销部门
				            @ExpRemDate smalldatetime ,	--报销日期
				            @projectID varchar(13) ,	--项目ID
				            @projectName varchar(50) ,	--项目名称
				            @ExpRemSingleNum smallint ,	--报销单据及附件
				            @note varchar(200),	--备注
				            @expRemSingleType smallint ,	--报销单类型，0：费用报销单，1：差旅费报销单
				            @amount numeric(15,2) ,	--合计金额
				            @borrowSingleID varchar(13) ,	--原借支单ID
				            @originalloan numeric(15,2) ,	--原借款
				            @replenishment numeric(15,2) ,	--应补款
				            @shouldRefund numeric(15,2) ,	--应退款
				            @ExpRemPersonID varchar(10) ,	--报销人编号
				            @ExpRemPerson varchar(30),	--报销人姓名
				            @businessPeopleID	varchar(10) ,	--出差人编号
				            @businessPeople	varchar(30) ,	--出差人
				            @businessReason varchar(200)	,	--出差事由
				            @approvalStatus smallint ,	--审批进度:0：新建，1：待审批，2：审批中,3:已审结

				            @lockManID  varchar(10),		--锁定人ID
	            output: 
				            @Ret		int output			--成功表示，0：成功，1：该单据已被其他用户锁定，2：该单据处于审核状态无法编辑，3：该单据不存在

	            author:		卢嘉诚
	            CreateDate:	2016-3-23

        */
        SqlCommand cmd = new SqlCommand("editExpRemSingle", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@ExpRemSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleID"].Value = ExpRemSingleID;

        cmd.Parameters.Add("@departmentID", SqlDbType.VarChar, 13);
        cmd.Parameters["@departmentID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@departmentID"].Value = departmentID;

        cmd.Parameters.Add("@ExpRemDepartment", SqlDbType.VarChar, 30);
        cmd.Parameters["@ExpRemDepartment"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemDepartment"].Value = ExpRemDepartment;

        cmd.Parameters.Add("@ExpRemDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@ExpRemDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemDate"].Value = ExpRemDate;

        cmd.Parameters.Add("@projectID", SqlDbType.VarChar, 13);
        cmd.Parameters["@projectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectID"].Value = projectID;

        cmd.Parameters.Add("@projectName", SqlDbType.VarChar, 50);
        cmd.Parameters["@projectName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectName"].Value = projectName;

        cmd.Parameters.Add("@ExpRemSingleNum", SqlDbType.SmallInt);
        cmd.Parameters["@ExpRemSingleNum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleNum"].Value = ExpRemSingleNum;

        cmd.Parameters.Add("@note", SqlDbType.VarChar, 200);
        cmd.Parameters["@note"].Direction = ParameterDirection.Input;
        cmd.Parameters["@note"].Value = note;

        cmd.Parameters.Add("@expRemSingleType", SqlDbType.SmallInt);
        cmd.Parameters["@expRemSingleType"].Direction = ParameterDirection.Input;
        cmd.Parameters["@expRemSingleType"].Value = expRemSingleType;

        cmd.Parameters.Add("@amount", SqlDbType.Money);
        cmd.Parameters["@amount"].Direction = ParameterDirection.Input;
        cmd.Parameters["@amount"].Value = amount;

        cmd.Parameters.Add("@borrowSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@borrowSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowSingleID"].Value = borrowSingleID;

        cmd.Parameters.Add("@originalloan", SqlDbType.Money);
        cmd.Parameters["@originalloan"].Direction = ParameterDirection.Input;
        cmd.Parameters["@originalloan"].Value = originalloan;

        cmd.Parameters.Add("@replenishment", SqlDbType.Money);
        cmd.Parameters["@replenishment"].Direction = ParameterDirection.Input;
        cmd.Parameters["@replenishment"].Value = replenishment;

        cmd.Parameters.Add("@shouldRefund", SqlDbType.Money);
        cmd.Parameters["@shouldRefund"].Direction = ParameterDirection.Input;
        cmd.Parameters["@shouldRefund"].Value = shouldRefund;

        cmd.Parameters.Add("@ExpRemPersonID", SqlDbType.VarChar, 10);
        cmd.Parameters["@ExpRemPersonID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemPersonID"].Value = ExpRemPersonID;

        cmd.Parameters.Add("@ExpRemPerson", SqlDbType.VarChar, 30);
        cmd.Parameters["@ExpRemPerson"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemPerson"].Value = ExpRemPerson;

        cmd.Parameters.Add("@businessPeopleID", SqlDbType.VarChar, 10);
        cmd.Parameters["@businessPeopleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessPeopleID"].Value = businessPeopleID;

        cmd.Parameters.Add("@businessPeople", SqlDbType.VarChar, 30);
        cmd.Parameters["@businessPeople"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessPeople"].Value = businessPeople;

        cmd.Parameters.Add("@businessReason", SqlDbType.VarChar, 200);
        cmd.Parameters["@businessReason"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessReason"].Value = businessReason;

        cmd.Parameters.Add("@approvalStatus", SqlDbType.SmallInt);
        cmd.Parameters["@approvalStatus"].Direction = ParameterDirection.Input;
        cmd.Parameters["@approvalStatus"].Value = approvalStatus;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;



        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "编辑报销单成功";
            else if (ret == 1)
                return "Error:该单据已被用户" + lockManID + "锁定！";
            else if (ret == 2)
                return "Error:该单据处于审核状态无法编辑";
            else if (ret == 3)
                return "Error:报销单" + ExpRemSingleID + "不存在";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    /// <summary>
    /// 功    能：审核指定报销单
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-21
    /// </summary>
    /// <param name="billID">借支单ID</param>
    /// <param name="approvalStatus">审批情况</param>
    /// <param name="approvalOpinions">审批意见</param>
    /// <param name="examinationPeoplePost">审批人职务</param>
    /// <param name="examinationPeopleID">审批人ID</param>
    /// <param name="examinationPeopleName">审批人名称</param>
    /// <param name="createManID">创建人ID</param>
    /// <returns>成功：返回@Ret表示；失败："Error：..."</returns>
    [WebMethod(Description = "审核指定报销单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string AudiExpRemSingle(string billID, int approvalStatus, string approvalOpinions, string examinationPeoplePost, string examinationPeopleID, string examinationPeopleName, string createManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		AudiExpRemSingle
	        function:	1.审核报销单
				        注意：本存储过程不锁定编辑！
	        input: 
			        @billID	varchar(13),	--报销单ID
			        @approvalStatus smallint,	--审批情况（同意/不同意）
			        @approvalOpinions	varchar(200),	--审批意见
			        @examinationPeoplePost varchar(50),	--审批人职务
			        @examinationPeopleID	varchar(10),	--审批人ID
			        @examinationPeopleName	varchar(30),	--审批人名称

			        @createManID varchar(10) output,			--创建人ID

	        output: 
			        @Ret		int output           --操作成功标识,0:成功，1：要审核的报销单不存在，2：该报销单正在被其他用户锁定，3：该报销单为处于审核状态，9：未知错误
			        @createManID varchar(13) output,			--创建人ID
	        author:		卢嘉诚
	        CreateDate:	2016-5-7
        */
        SqlCommand cmd = new SqlCommand("AudiExpRemSingle", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;


        cmd.Parameters.Add("@billID", SqlDbType.VarChar, 13);
        cmd.Parameters["@billID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@billID"].Value = billID;

        cmd.Parameters.Add("@approvalStatus", SqlDbType.SmallInt);
        cmd.Parameters["@approvalStatus"].Direction = ParameterDirection.Input;
        cmd.Parameters["@approvalStatus"].Value = approvalStatus;

        cmd.Parameters.Add("@approvalOpinions", SqlDbType.VarChar, 200);
        cmd.Parameters["@approvalOpinions"].Direction = ParameterDirection.Input;
        cmd.Parameters["@approvalOpinions"].Value = approvalOpinions;

        cmd.Parameters.Add("@examinationPeoplePost", SqlDbType.VarChar, 50);
        cmd.Parameters["@examinationPeoplePost"].Direction = ParameterDirection.Input;
        cmd.Parameters["@examinationPeoplePost"].Value = examinationPeoplePost;

        cmd.Parameters.Add("@examinationPeopleID", SqlDbType.VarChar, 10);
        cmd.Parameters["@examinationPeopleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@examinationPeopleID"].Value = examinationPeopleID;

        cmd.Parameters.Add("@examinationPeopleName", SqlDbType.VarChar, 30);
        cmd.Parameters["@examinationPeopleName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@examinationPeopleName"].Value = examinationPeopleName;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = createManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            createManID = (string)cmd.Parameters["@createManID"].Value;
            if (ret == 0)
                return "审核成功！";
            else if (ret == 1)
                return "Error:要审核的报销单" + billID + "不存在！";
            else if (ret == 2)
                return "Error:该报销单已被用户" + createManID + "锁定！";
            else if (ret == 3)
                return "Error:该报销单处未处于审核状态！";
            else if (ret == 4)
                return "Error:请先锁定该报销单避免冲突！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    /// <summary>
    /// 功    能：添加费用报销单(XML)
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-21
    /// </summary>
    /// <param name="departmentID">部门ID</param>
    /// <param name="ExpRemDepartment">报销部门</param>
    /// <param name="ExpRemDate">报销日期</param>
    /// <param name="projectID">项目ID</param>
    /// <param name="projectName">项目名称</param>
    /// <param name="ExpRemSingleNum">报销单据及附件数</param>
    /// <param name="note">备注</param>
    /// <param name="expRemSingleType">报销单类型</param>
    /// <param name="amount">合计金额</param>
    /// <param name="borrowSingleID">原借支单ID</param>
    /// <param name="originalloan">原借款</param>
    /// <param name="replenishment">应补款</param>
    /// <param name="shouldRefund">应退款</param>
    /// <param name="originalloan">原借款</param>
    /// <param name="ExpRemPersonID">报销人ID</param>
    /// <param name="ExpRemPerson">报销人姓名</param>
    /// <param name="businessPeopleID">出差人ID</param>
    /// <param name="businessPeople">出差人姓名</param>
    /// <param name="businessReason">出差事由</param>
    /// <param name="approvalStatus">审批进度</param>
    /// <param name="xVar">详情XML</param>
    /// <returns>成功：借支单编号，采用401号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "添加费用报销单(XML)<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string addExpRemSingleForXML(string departmentID, string ExpRemDepartment, string ExpRemDate, string projectID,
        string projectName, int ExpRemSingleNum, string note, int expRemSingleType, decimal amount, string borrowSingleID,
        decimal originalloan, decimal replenishment, decimal shouldRefund, string ExpRemPersonID, string ExpRemPerson,
        string businessPeopleID, string businessPeople, string businessReason, int approvalStatus, string createManID, string xVar)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
            name:		addExpRemSingle
	        function:	1.添加费用报销单
				        注意：本存储过程不锁定编辑！
	        input: 
				    @departmentID varchar(13) ,	--部门ID
				    @ExpRemDepartment varchar(20)	,	--报销部门
				    @ExpRemDate smalldatetime ,	--报销日期
				    @projectID varchar(13) ,	--项目ID
				    @projectName varchar(50) ,	--项目名称
				    @ExpRemSingleNum smallint ,	--报销单据及附件
				    @note varchar(200),	--备注
				    @expRemSingleType smallint ,	--报销单类型，0：费用报销单，1：差旅费报销单
				    @amount numeric(15,2) ,	--合计金额
				    @borrowSingleID varchar(15) ,	--原借支单ID
				    @originalloan numeric(15,2) ,	--原借款
				    @replenishment numeric(15,2) ,	--应补款
				    @shouldRefund numeric(15,2) ,	--应退款
				    @ExpRemPersonID varchar(10) ,	--报销人编号
				    @ExpRemPerson varchar(30),	--报销人姓名
				    @businessPeopleID	varchar(10) ,	--出差人编号
				    @businessPeople	varchar(30) ,	--出差人
				    @businessReason varchar(200)	,	--出差事由
				    @approvalStatus smallint ,		--审批状态，0：未发起，1：审核中，2：审批完成
				    @xVar XML,					--XML格式的详情

			        @createManID varchar(10),		--创建人工号
	        output: 
				        @Ret		int output		--操作成功标识
							        0:成功，1：该国别名称或代码已存在，9：未知错误
				        @createTime smalldatetime output
	        author:		卢嘉诚
        */
        SqlCommand cmd = new SqlCommand("addExpRemSingleForXML", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@departmentID", SqlDbType.VarChar, 13);
        cmd.Parameters["@departmentID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@departmentID"].Value = departmentID;

        cmd.Parameters.Add("@ExpRemDepartment", SqlDbType.VarChar, 30);
        cmd.Parameters["@ExpRemDepartment"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemDepartment"].Value = ExpRemDepartment;

        cmd.Parameters.Add("@ExpRemDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@ExpRemDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemDate"].Value = ExpRemDate;

        cmd.Parameters.Add("@projectID", SqlDbType.VarChar, 13);
        cmd.Parameters["@projectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectID"].Value = projectID;

        cmd.Parameters.Add("@projectName", SqlDbType.VarChar, 50);
        cmd.Parameters["@projectName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectName"].Value = projectName;

        cmd.Parameters.Add("@ExpRemSingleNum", SqlDbType.SmallInt);
        cmd.Parameters["@ExpRemSingleNum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleNum"].Value = ExpRemSingleNum;

        cmd.Parameters.Add("@note", SqlDbType.VarChar, 200);
        cmd.Parameters["@note"].Direction = ParameterDirection.Input;
        cmd.Parameters["@note"].Value = note;

        cmd.Parameters.Add("@expRemSingleType", SqlDbType.SmallInt);
        cmd.Parameters["@expRemSingleType"].Direction = ParameterDirection.Input;
        cmd.Parameters["@expRemSingleType"].Value = expRemSingleType;

        cmd.Parameters.Add("@amount", SqlDbType.Money);
        cmd.Parameters["@amount"].Direction = ParameterDirection.Input;
        cmd.Parameters["@amount"].Value = amount;

        cmd.Parameters.Add("@borrowSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@borrowSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowSingleID"].Value = borrowSingleID;

        cmd.Parameters.Add("@originalloan", SqlDbType.Money);
        cmd.Parameters["@originalloan"].Direction = ParameterDirection.Input;
        cmd.Parameters["@originalloan"].Value = originalloan;

        cmd.Parameters.Add("@replenishment", SqlDbType.Money);
        cmd.Parameters["@replenishment"].Direction = ParameterDirection.Input;
        cmd.Parameters["@replenishment"].Value = replenishment;

        cmd.Parameters.Add("@shouldRefund", SqlDbType.Money);
        cmd.Parameters["@shouldRefund"].Direction = ParameterDirection.Input;
        cmd.Parameters["@shouldRefund"].Value = shouldRefund;

        cmd.Parameters.Add("@ExpRemPersonID", SqlDbType.VarChar, 10);
        cmd.Parameters["@ExpRemPersonID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemPersonID"].Value = ExpRemPersonID;

        cmd.Parameters.Add("@ExpRemPerson", SqlDbType.VarChar, 30);
        cmd.Parameters["@ExpRemPerson"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemPerson"].Value = ExpRemPerson;

        cmd.Parameters.Add("@businessPeopleID", SqlDbType.VarChar, 10);
        cmd.Parameters["@businessPeopleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessPeopleID"].Value = businessPeopleID;

        cmd.Parameters.Add("@businessPeople", SqlDbType.VarChar, 30);
        cmd.Parameters["@businessPeople"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessPeople"].Value = businessPeople;

        cmd.Parameters.Add("@businessReason", SqlDbType.VarChar, 200);
        cmd.Parameters["@businessReason"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessReason"].Value = businessReason;

        cmd.Parameters.Add("@approvalStatus", SqlDbType.SmallInt);
        cmd.Parameters["@approvalStatus"].Direction = ParameterDirection.Input;
        cmd.Parameters["@approvalStatus"].Value = approvalStatus;

        cmd.Parameters.Add("@xVar", SqlDbType.Xml);
        cmd.Parameters["@xVar"].Direction = ParameterDirection.Input;
        cmd.Parameters["@xVar"].Value = xVar;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = createManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@createTime", SqlDbType.SmallDateTime);
        cmd.Parameters["@createTime"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@ExpRemSingleID"].Direction = ParameterDirection.Output;
        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@ExpRemSingleID"].Value;
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    #endregion

    #region 附件的增删改
    /// <summary>
    /// 功    能：添加附件
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="uidFilename">UID文件名</param>
    /// <param name="billType">票据类型</param>
    /// <param name="billID">票据ID</param>
    /// <param name="aFilename">原始文件名</param>
    /// <param name="fileSize">文件尺寸</param>
    /// <param name="fileType">文件类型</param>
    /// <param name="fileLog">文件log</param>
    /// <returns>成功：借支单编号，采用406号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "添加附件<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    [SoapHeader("PageHeader")]
    public string addAttachment(string uidFilename, int billType, string billID, string aFilename, int fileSize, string fileType, string fileLog, string createManID)
    {
        verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		addAttachment
	        function:	1.添加附件
				        注意：本存储过程不锁定编辑！
	        input: 
				        @uidFilename varchar(128),	--UID文件名
				        @billType	 smallint,		--票据类型：0，借支单，1：报销单
				        @billID	varchar(13),		--票据编号
				        @aFilename varchar(128),	--原始文件名
				        @fileSize bigint,			--文件尺寸
				        @fileType varchar(10),		--文件类型
				        @fileLog varchar(128),		--文件log：如果没有没有定义，则使用默认的文件类型LOG

				        @createManID varchar(10),		--创建人工号

	        output: 
				        @Ret		int output,     --成功标识,0:成功,9:未知错误
				        @createTime smalldatetime output
	        author:		卢嘉诚
	        CreateDate:	2016-5-13
        */
        SqlCommand cmd = new SqlCommand("addAttachment", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@uidFilename", SqlDbType.VarChar, 128);
        cmd.Parameters["@uidFilename"].Direction = ParameterDirection.Input;
        cmd.Parameters["@uidFilename"].Value = uidFilename;

        cmd.Parameters.Add("@billType", SqlDbType.SmallInt);
        cmd.Parameters["@billType"].Direction = ParameterDirection.Input;
        cmd.Parameters["@billType"].Value = billType;

        cmd.Parameters.Add("@billID", SqlDbType.VarChar, 13);
        cmd.Parameters["@billID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@billID"].Value = billID;

        cmd.Parameters.Add("@aFilename", SqlDbType.VarChar, 128);
        cmd.Parameters["@aFilename"].Direction = ParameterDirection.Input;
        cmd.Parameters["@aFilename"].Value = aFilename;

        cmd.Parameters.Add("@fileSize", SqlDbType.BigInt);
        cmd.Parameters["@fileSize"].Direction = ParameterDirection.Input;
        cmd.Parameters["@fileSize"].Value = fileSize;

        cmd.Parameters.Add("@fileType", SqlDbType.VarChar,10);
        cmd.Parameters["@fileType"].Direction = ParameterDirection.Input;
        cmd.Parameters["@fileType"].Value = fileType;

        cmd.Parameters.Add("@fileLog", SqlDbType.VarChar, 128);
        cmd.Parameters["@fileLog"].Direction = ParameterDirection.Input;
        cmd.Parameters["@fileLog"].Value = fileLog;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = createManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@createTime", SqlDbType.SmallDateTime);
        cmd.Parameters["@createTime"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@uidFilename"].Value;
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    /// <summary>
    /// 功    能：删除附件
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="uidFilename">UID文件名</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：借支单编号，采用406号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "添加附件<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    [SoapHeader("PageHeader")]
    public string delEnclosure(string uidFilename, string lockManID)
    {
        verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		delAttachment
	        function:	1.删除附件
				        注意：本存储过程不锁定编辑！
	        input: 
				        @uidFilename varchar(128),		--UID文件名
				        @lockManID varchar(10),		--锁定人工号
	        output: 
				        @Ret		int output		  --成功标示，0：成功，1：该附件不存在,9:未知错误
				        @createTime smalldatetime output
	        author:		卢嘉诚
	        CreateDate:	2016-5-13
        */
        SqlCommand cmd = new SqlCommand("delEnclosure", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@uidFilename", SqlDbType.VarChar, 128);
        cmd.Parameters["@uidFilename"].Direction = ParameterDirection.Input;
        cmd.Parameters["@uidFilename"].Value = uidFilename;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@createTime", SqlDbType.SmallDateTime);
        cmd.Parameters["@createTime"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return "删除附件成功";
            else if (ret == 1)
                return "Error:要删除的附件" + uidFilename + "不存在！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    #endregion





    #region 科目的增删改
    /// <summary>
    /// 功    能：添加科目
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="FinancialSubjectID">科目ID</param>
    /// <param name="superiorSubjectsID">上级科目ID</param>
    /// <param name="superiorSubjects">上级科目名称</param>
    /// <param name="subjectName">科目名称</param>
    /// <param name="AccountNumber">科目层数</param>
    /// <param name="establishTime">设立时间</param>
    /// <param name="explain">说明</param>
    /// <returns>成功：借支单编号，采用406号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "添加科目<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    [SoapHeader("PageHeader")]
    public string addSubject(string FinancialSubjectID, string superiorSubjectsID, string superiorSubjects, string subjectName, int AccountNumber, string establishTime, string explain, string createManID)
    {
        verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		addSubject
	        function:	1.添加科目
				        注意：本存储过程不锁定编辑！
	        input: 
				        @FinancialSubjectID	varchar(8),	--科目ID,主键
				        @superiorSubjectsID	varchar(8),	--上级科目ID
				        @superiorSubjects varchar(30),		--上级科目名称
				        @subjectName	varchar(30),			--科目名称
				        @AccountNumber int ,				--科目层数
				        @establishTime smalldatetime,		--设立时间
				        @explain	varchar(200),				--说明

				        @createManID varchar(10),			--创建人工号
	        output: 
				        @Ret		int output		--操作成功标识
							        0:成功，1：该国别名称或代码已存在，9：未知错误
				        @createTime smalldatetime output
	        author:		卢嘉诚
	        CreateDate:	2016-3-23

        */
        SqlCommand cmd = new SqlCommand("addSubject", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;


        cmd.Parameters.Add("@FinancialSubjectID", SqlDbType.VarChar,8);
        cmd.Parameters["@FinancialSubjectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@FinancialSubjectID"].Value = FinancialSubjectID;

        cmd.Parameters.Add("@superiorSubjectsID", SqlDbType.VarChar, 8);
        cmd.Parameters["@superiorSubjectsID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@superiorSubjectsID"].Value = superiorSubjectsID;

        cmd.Parameters.Add("@superiorSubjects", SqlDbType.VarChar, 30);
        cmd.Parameters["@superiorSubjects"].Direction = ParameterDirection.Input;
        cmd.Parameters["@superiorSubjects"].Value = superiorSubjects;

        cmd.Parameters.Add("@subjectName", SqlDbType.VarChar,30);
        cmd.Parameters["@subjectName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@subjectName"].Value = subjectName;

        cmd.Parameters.Add("@AccountNumber", SqlDbType.Int);
        cmd.Parameters["@AccountNumber"].Direction = ParameterDirection.Input;
        cmd.Parameters["@AccountNumber"].Value = AccountNumber;

        cmd.Parameters.Add("@establishTime", SqlDbType.SmallDateTime);
        cmd.Parameters["@establishTime"].Direction = ParameterDirection.Input;
        cmd.Parameters["@establishTime"].Value = establishTime;

        cmd.Parameters.Add("@explain", SqlDbType.VarChar,200);
        cmd.Parameters["@explain"].Direction = ParameterDirection.Input;
        cmd.Parameters["@explain"].Value = explain;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar,10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = createManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@createTime", SqlDbType.SmallDateTime);
        cmd.Parameters["@createTime"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@FinancialSubjectID"].Value;
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    /// <summary>
    /// 功    能：编辑科目
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="FinancialSubjectID">科目ID</param>
    /// <param name="subjectName">科目名称</param>
    /// <param name="explain">说明</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：借支单编号，采用406号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "编辑科目<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string editSubject(string FinancialSubjectID, string subjectName, string explain, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
             name:		editSubject
             function:	1.编辑科目
                         注意：本存储过程锁定编辑！
             input: 
                         @FinancialSubjectID	varchar(8),	--科目ID
                         @subjectName	varchar(30),		--科目名称
                         @explain varchar(200),				--说明


             output: 
                         @lockManID varchar(10) output,		--锁定人工号
                         @Ret		int output,			--操作成功标识,0:成功，1：该科目已被其他人用户锁定，3：该科目不存在，9：未知错误
                         @createTime smalldatetime output
             author:		卢嘉诚
             CreateDate:	2016-3-23
         */
        SqlCommand cmd = new SqlCommand("editSubject", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@FinancialSubjectID", SqlDbType.VarChar, 8);
        cmd.Parameters["@FinancialSubjectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@FinancialSubjectID"].Value = FinancialSubjectID;

        cmd.Parameters.Add("@subjectName", SqlDbType.VarChar,30);
        cmd.Parameters["@subjectName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@subjectName"].Value = subjectName;

        cmd.Parameters.Add("@explain", SqlDbType.VarChar, 200);
        cmd.Parameters["@explain"].Direction = ParameterDirection.Input;
        cmd.Parameters["@explain"].Value = explain;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

     

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@createTime", SqlDbType.SmallDateTime);
        cmd.Parameters["@createTime"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "编辑成功！";
            else if (ret == 1)
                return "Error:该科目已被用户" + lockManID + "锁定无法编辑";
            else if (ret == 3)
                return "Error:该科目不存在";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    /// <summary>
    /// 功    能：锁定指定科目
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="FinancialSubjectID">科目ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：借支单编号，采用406号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "锁定指定科目<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string lockSubjectEdit(string FinancialSubjectID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	    name:		lockSubjectEdit
	    function:	锁定科目编辑，避免编辑冲突
	    input: 
				    @FinancialSubjectID varchar(8),			--科目ID
				    @lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				
	    output: 
				    @Ret int output					--操作成功标识	0:成功，1：要锁定的科目不存在，2:要锁定的科目正在被别人编辑，9：未知错误
							    0:成功，
							    1：要锁定的科目不存在，
							    2:要锁定的科目正在被别人编辑，
							    9：未知错误
	    author:		卢嘉诚
	    CreateDate:	2016-4-16
         */
        SqlCommand cmd = new SqlCommand("lockSubjectEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@FinancialSubjectID", SqlDbType.VarChar, 8);
        cmd.Parameters["@FinancialSubjectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@FinancialSubjectID"].Value = FinancialSubjectID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;



        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "锁定成功！";
            else if (ret == 1)
                return "Error:该科目不存在！";
            else if (ret == 2)
                return "Error:要锁定的科目正在被用户" + lockManID + "锁定编辑";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    /// <summary>
    /// 功    能：释放指定科目锁定
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="FinancialSubjectID">科目ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：借支单编号，采用406号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "释放指定科目锁定<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string unlockSubjectEdit(string FinancialSubjectID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		unlockSubjectEdit
	        function:	释放科目编辑锁定，避免编辑冲突
	        input: 
				        @FinancialSubjectID varchar(8),			--科目ID
				        @lockManID varchar(10) output,	--锁定人，如果当前科目正在被人占用编辑则返回该人的工号
	        output: 
				        @Ret		int output		--操作成功标识0:成功，1：要释放锁定的科目不存在，2:要释放锁定的科目正在被别人编辑，8：该科目未被任何人锁定，9：未知错误
							
	        author:		卢嘉诚
	        CreateDate:	2016-4-16
	        UpdateDate: 

         */
        SqlCommand cmd = new SqlCommand("unlockSubjectEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@FinancialSubjectID", SqlDbType.VarChar, 8);
        cmd.Parameters["@FinancialSubjectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@FinancialSubjectID"].Value = FinancialSubjectID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "释放锁定成功！";
            else if (ret == 1)
                return "Error:科目" + FinancialSubjectID + "不存在！";
            else if (ret == 2)
                return "Error:该科目已被用户" + lockManID + "锁定无法编辑";
            else if (ret == 8)
                return "Error:该科目未被任何人锁定！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }
    #endregion








    #region 账户的增删改
    /// <summary>
    /// 功    能：增加账户
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="accountName">账户名称</param>
    /// <param name="bankAccount">开户行</param>
    /// <param name="accountCompany">开户名</param>
    /// <param name="accountOpening">开户账号</param>
    /// <param name="bankAccountNum">开户行号</param>
    /// <param name="accountDate">开户时间</param>
    /// <param name="administratorID">管理人ID</param>
    /// <param name="administrator">管理人姓名</param>
    /// <param name="branchAddress">支行地址</param>
    /// <param name="remarks">备注</param>
    /// <param name="Obsolete">是否作废</param>
    /// <param name="enabledeate">启用日期</param>
    /// <param name="createManID">创建人工号</param>
    /// <returns>成功：账户编号，采用409号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "增加账户<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string addAccountList(string accountName, string bankAccount, string accountCompany, string accountOpening, string bankAccountNum, string accountDate, string administratorID, string administrator, string branchAddress,
        string remarks, int Obsolete, string enabledeate, string createManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		addAccountList
	        function:	1.添加账户
				        注意：本存储过程不锁定编辑！
	        input: 
				        @accountName	varchar(50),		--账户名称
				        @bankAccount	varchar(100),		--开户行
				        @accountCompany	varchar(100),	--开户名
				        @accountOpening	varchar(50),	--开户账号
				        @bankAccountNum	varchar(50),	--开户行号
				        @accountDate	smalldatetime,	--开户时间
				        @administratorID	varchar(10),	--管理人ID
				        @administrator	varchar(30),	--管理人(姓名）
				        @branchAddress	varchar(100),	--支行地址
				        @remarks varchar(200),			--备注
				        @Obsolete		smallint ,		--是否作废,0:在用，1：作废
				        @enabledeate	smalldatetime,	--启用日期

				        @createManID varchar(10),		--创建人工号
	        output: 
				        @accountID 	varchar(10) output,		--账户ID,主键,使用409号号码发生器生成
				        @Ret		int output		--操作成功标识
							        0:成功，1：该账户已存在，9：未知错误
				
	        author:		卢嘉诚
	        CreateDate:	2016-3-23

         */
        SqlCommand cmd = new SqlCommand("addAccountList", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@accountID", SqlDbType.VarChar, 10);
        cmd.Parameters["@accountID"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@accountName", SqlDbType.VarChar, 50);
        cmd.Parameters["@accountName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountName"].Value = accountName;

        cmd.Parameters.Add("@bankAccount", SqlDbType.VarChar, 100);
        cmd.Parameters["@bankAccount"].Direction = ParameterDirection.Input;
        cmd.Parameters["@bankAccount"].Value = bankAccount;

        cmd.Parameters.Add("@accountCompany", SqlDbType.VarChar, 100);
        cmd.Parameters["@accountCompany"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountCompany"].Value = accountCompany;

        cmd.Parameters.Add("@accountOpening", SqlDbType.VarChar, 50);
        cmd.Parameters["@accountOpening"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountOpening"].Value = accountOpening;

        cmd.Parameters.Add("@bankAccountNum", SqlDbType.VarChar, 50);
        cmd.Parameters["@bankAccountNum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@bankAccountNum"].Value = bankAccountNum;

        cmd.Parameters.Add("@accountDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@accountDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountDate"].Value = accountDate;

        cmd.Parameters.Add("@administratorID", SqlDbType.VarChar,10);
        cmd.Parameters["@administratorID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@administratorID"].Value = administratorID;

        cmd.Parameters.Add("@administrator", SqlDbType.VarChar, 30);
        cmd.Parameters["@administrator"].Direction = ParameterDirection.Input;
        cmd.Parameters["@administrator"].Value = administrator;

        cmd.Parameters.Add("@branchAddress", SqlDbType.VarChar, 100);
        cmd.Parameters["@branchAddress"].Direction = ParameterDirection.Input;
        cmd.Parameters["@branchAddress"].Value = branchAddress;

        cmd.Parameters.Add("@remarks", SqlDbType.VarChar, 200);
        cmd.Parameters["@remarks"].Direction = ParameterDirection.Input;
        cmd.Parameters["@remarks"].Value = remarks;

        cmd.Parameters.Add("@Obsolete", SqlDbType.SmallInt);
        cmd.Parameters["@Obsolete"].Direction = ParameterDirection.Input;
        cmd.Parameters["@Obsolete"].Value = Obsolete;

        cmd.Parameters.Add("@enabledeate", SqlDbType.SmallDateTime);
        cmd.Parameters["@enabledeate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@enabledeate"].Value = enabledeate;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = createManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@accountID"].Value;
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    /// <summary>
    /// 功    能：删除账户
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="FinancialSubjectID">科目ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：删除成功；失败："Error：..."</returns>
    [WebMethod(Description = "删除账户<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string delAccountList(string accountID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		delAccountList
	        function:		1.删除账户
				        注意：本存储过程锁定编辑！
	        input: 
				        @accountID 	varchar(10) output,		--账户ID,主键,使用409号号码发生器生成
				        @lockManID varchar(10),		--锁定人ID
	        output: 
				        @Ret		int output		--操作成功标示；0:成功，1：该账户不存在，2：该账户被其他用户锁定，3:请先锁定该账户在删除避免冲突，9：未知错误

	        author:		卢嘉诚
	        CreateDate:	2016-5-13
         */
        SqlCommand cmd = new SqlCommand("delAccountList", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@accountID", SqlDbType.VarChar, 10);
        cmd.Parameters["@accountID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountID"].Value = accountID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "删除账户成功！";
            else if (ret == 1)
                return "Error:账户" + accountID + "不存在！";
            else if (ret == 2)
                return "Error:该账户被用户" + lockManID + "锁定";
            else if (ret == 3)
                return "Error:请先锁定该账户再删除，避免冲突！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    /// <summary>
    /// 功    能：编辑账户
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="accountID">账户ID</param>
    /// <param name="accountName">账户名称</param>
    /// <param name="bankAccount">开户行</param>
    /// <param name="accountCompany">开户名</param>
    /// <param name="accountOpening">开户账号</param>
    /// <param name="bankAccountNum">开户行号</param>
    /// <param name="accountDate">开户时间</param>
    /// <param name="administratorID">管理人ID</param>
    /// <param name="administrator">管理人姓名</param>
    /// <param name="branchAddress">支行地址</param>
    /// <param name="remarks">备注</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：账户编号，采用409号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "编辑账户<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string editAccountList(string accountID, string accountName, string bankAccount, string accountCompany, string accountOpening, string bankAccountNum, string accountDate, string administratorID, string administrator, string branchAddress,
        string remarks, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		editAccountList
	        function:	1.编辑账户
				        注意：本存储过程锁定编辑！
	        input: 
				        @accountID 	varchar(10),		--账户ID,主键,使用409号号码发生器生成
				        @accountName	varchar(50),		--账户名称
				        @bankAccount	varchar(100),		--开户行
				        @accountCompany	varchar(100),	--开户名
				        @accountOpening	varchar(50),	--开户账号
				        @bankAccountNum	varchar(50),	--开户行号
				        @accountDate	smalldatetime,	--开户时间
				        @administratorID	varchar(10),	--管理人ID
				        @administrator	varchar(30),	--管理人(姓名）
				        @branchAddress	varchar(100),	--支行地址
				        @remarks varchar(200),			--备注

	        output: 
				        @lockManID varchar(10)output,		--锁定人ID
				        @Ret		int output		--操作成功标示；0:成功，1：该账户不存在，2：该账户已被其他用户锁定，9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-3-23
	
         */
        SqlCommand cmd = new SqlCommand("addAccountList", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@accountID", SqlDbType.VarChar, 10);
        cmd.Parameters["@accountID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountID"].Value = accountID;

        cmd.Parameters.Add("@accountName", SqlDbType.VarChar, 50);
        cmd.Parameters["@accountName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountName"].Value = accountName;

        cmd.Parameters.Add("@bankAccount", SqlDbType.VarChar, 100);
        cmd.Parameters["@bankAccount"].Direction = ParameterDirection.Input;
        cmd.Parameters["@bankAccount"].Value = bankAccount;

        cmd.Parameters.Add("@accountCompany", SqlDbType.VarChar, 100);
        cmd.Parameters["@accountCompany"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountCompany"].Value = accountCompany;

        cmd.Parameters.Add("@accountOpening", SqlDbType.VarChar, 50);
        cmd.Parameters["@accountOpening"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountOpening"].Value = accountOpening;

        cmd.Parameters.Add("@bankAccountNum", SqlDbType.VarChar, 50);
        cmd.Parameters["@bankAccountNum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@bankAccountNum"].Value = bankAccountNum;

        cmd.Parameters.Add("@accountDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@accountDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountDate"].Value = accountDate;

        cmd.Parameters.Add("@administratorID", SqlDbType.VarChar, 10);
        cmd.Parameters["@administratorID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@administratorID"].Value = administratorID;

        cmd.Parameters.Add("@administrator", SqlDbType.VarChar, 30);
        cmd.Parameters["@administrator"].Direction = ParameterDirection.Input;
        cmd.Parameters["@administrator"].Value = administrator;

        cmd.Parameters.Add("@branchAddress", SqlDbType.VarChar, 100);
        cmd.Parameters["@branchAddress"].Direction = ParameterDirection.Input;
        cmd.Parameters["@branchAddress"].Value = branchAddress;

        cmd.Parameters.Add("@remarks", SqlDbType.VarChar, 200);
        cmd.Parameters["@remarks"].Direction = ParameterDirection.Input;
        cmd.Parameters["@remarks"].Value = remarks;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "编辑成功！";
            else if (ret == 1)
                return "Error:账户" + accountID + "不存在";
            else if (ret == 2)
                return "Error:该账户已被用户" + lockManID + "锁定";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    /// <summary>
    /// 功    能：锁定指定账户
    /// 作    者：卢嘉诚
    /// 编写日期：2016-5-4
    /// </summary>
    /// <param name="accountID">账户ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：借支单编号，采用406号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "锁定指定账户<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string lockAccountEdit(string accountID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		lockAccountEdit
	        function: 	锁定账户编辑，避免编辑冲突
	        input: 
				        @accountID varchar(10),		--账户ID

	        output: 
				        @lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				        @Ret		int output		--操作成功标识0:成功，1：要锁定的账户不存在，2:要锁定的账户正在被别人编辑，9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-4-16
	        UpdateDate: 
         */
        SqlCommand cmd = new SqlCommand("lockAccountEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@accountID", SqlDbType.VarChar, 10);
        cmd.Parameters["@accountID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountID"].Value = accountID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;



        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "Error:锁定成功！";
            else if (ret == 1)
                return "Error:账户" + accountID + "不存在！";
            else if (ret == 2)
                return "Error:要锁定的账户正在被用户" + lockManID + "锁定编辑";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    /// <summary>
    /// 功    能：释放指定账户锁定
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="accountID">账户ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：释放锁定成功！；失败："Error：..."</returns>
    [WebMethod(Description = "释放指定账户锁定<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string unlockAccountEdit(string accountID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	            name:		unlockAccountEdit
	            function: 	释放锁定账户编辑，避免编辑冲突
	            input: 
				            @accountID varchar(10),			--账户ID
				
	            output: 
				            @lockManID varchar(10) output,	--锁定人ID，如果当前账户正在被人占用编辑则返回该人的工号
				            @Ret		int output		--操作成功标识0:成功，1：要释放锁定的账户不存在，2:要释放锁定的账户正在被别人编辑，8：该账户未被任何人锁定9：未知错误
	            author:		卢嘉诚
	            CreateDate:	2016-4-16
         */
        SqlCommand cmd = new SqlCommand("unlockAccountEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@accountID", SqlDbType.VarChar, 10);
        cmd.Parameters["@accountID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountID"].Value = accountID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "释放锁定成功！";
            else if (ret == 1)
                return "Error:账户" + accountID + "不存在！";
            else if (ret == 2)
                return "Error:该账户已被用户" + lockManID + "锁定无法编辑！";
            else if (ret == 8)
                return "Error:该账户未被任何人锁定！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    /// <summary>
    /// 功    能：账户移交
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="handoverDate">移交时间</param>
    /// <param name="transferAccountID">移交账户ID</param>
    /// <param name="transferAccount">移交账户</param>
    /// <param name="transferPersonID">移交人ID</param>
    /// <param name="transferPerson">移交人</param>
    /// <param name="handoverPersonID">交接人ID</param>
    /// <param name="handoverPerson">交接人</param>
    /// <param name="transferMatters">移交事项</param>
    /// <param name="remarks">备注</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <param name="TransferConfirmation">移交确认</param>
    /// <returns>成功：返回账户移交ID！；失败："Error：..."</returns>
    [WebMethod(Description = "账户移交<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string accountTransfer(string handoverDate, string transferAccountID, string transferAccount, string transferPersonID, string transferPerson, string handoverPersonID, string handoverPerson, string transferMatters,
        string remarks, string TransferConfirmation,string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		accountTransfer
	        function: 	该存储过程锁定账户编辑，避免编辑冲突
	        input: 

				        @handoverDate	smalldatetime,	--移交日期
				        @transferAccountID	varchar(10),	--移交账户ID
				        @transferAccount	varchar(50),	--移交账户
				        @transferPersonID	varchar(10),	--移交人ID
				        @transferPerson	varchar(30),	--移交人
				        @handoverPersonID	varchar(10),	--交接人ID
				        @handoverPerson	varchar(30),	--交接人
				        @transferMatters	varchar(200),	--移交事项
				        @remarks		varchar(200),	--备注
				        @TransferConfirmation smallint ,	--移交确认，0：未确认，1：确认
				
	        output: 
				        @accountTransferID varchar(15) output,	--账户移交ID,主键，使用410号号码发生器生成
				        @lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				        @Ret int output				--操作成功标识0:成功，1：要移交的的账户不存在，2:要移交的的账户正在被别人锁定，3:该账户未锁定，请先锁定账户9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-4-16

         */
        SqlCommand cmd = new SqlCommand("accountTransfer", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@accountTransferID", SqlDbType.VarChar, 15);
        cmd.Parameters["@accountTransferID"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@handoverDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@handoverDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@handoverDate"].Value = handoverDate;

        cmd.Parameters.Add("@transferAccountID", SqlDbType.VarChar,10);
        cmd.Parameters["@transferAccountID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@transferAccountID"].Value = transferAccountID;

        cmd.Parameters.Add("@transferAccount", SqlDbType.VarChar,50);
        cmd.Parameters["@transferAccount"].Direction = ParameterDirection.Input;
        cmd.Parameters["@transferAccount"].Value = transferAccount;

        cmd.Parameters.Add("@transferPersonID", SqlDbType.VarChar,10);
        cmd.Parameters["@transferPersonID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@transferPersonID"].Value = transferPersonID;

        cmd.Parameters.Add("@transferPerson", SqlDbType.VarChar, 30);
        cmd.Parameters["@transferPerson"].Direction = ParameterDirection.Input;
        cmd.Parameters["@transferPerson"].Value = transferPerson;

        cmd.Parameters.Add("@handoverPersonID", SqlDbType.VarChar, 10);
        cmd.Parameters["@handoverPersonID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@handoverPersonID"].Value = handoverPersonID;

        cmd.Parameters.Add("@handoverPerson", SqlDbType.VarChar, 30);
        cmd.Parameters["@handoverPerson"].Direction = ParameterDirection.Input;
        cmd.Parameters["@handoverPerson"].Value = handoverPerson;

        cmd.Parameters.Add("@transferMatters", SqlDbType.VarChar, 200);
        cmd.Parameters["@transferMatters"].Direction = ParameterDirection.Input;
        cmd.Parameters["@transferMatters"].Value = transferMatters;

        cmd.Parameters.Add("@remarks", SqlDbType.VarChar, 200);
        cmd.Parameters["@remarks"].Direction = ParameterDirection.Input;
        cmd.Parameters["@remarks"].Value = remarks;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@accountTransferID"].Value;
            else if (ret == 1)
                return "Error:账户" + transferAccountID + "不存在！";
            else if (ret == 2)
                return "Error:该账户已被用户" + lockManID + "锁定无法编辑！";
            else if (ret == 3)
                return "Error：该账户未锁定，请先锁定该账户再移交";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    /// <summary>
    /// 功    能：账户移交确认
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="accountTransferID">账户移交ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：确认账户移交成功！；失败："Error：..."</returns>
    [WebMethod(Description = "账户移交确认<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string TransferAccountConfirmation(string accountTransferID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		TransferAccountConfirmation
	        function: 	该存储过程锁定账户编辑，避免编辑冲突
	        input: 
				        @accountTransferID		--账户移交ID

				
	        output: 
				        @lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				        @Ret int output				--操作成功标识0:成功，1：该次账户移交不存在，2:确认人并非交接人9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-4-16

         */
        SqlCommand cmd = new SqlCommand("TransferAccountConfirmation", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@accountTransferID", SqlDbType.VarChar, 15);
        cmd.Parameters["@accountTransferID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountTransferID"].Value = accountTransferID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@accountTransferID"].Value;
            else if (ret == 1)
                return "Error:本次账户移交" + accountTransferID + "不存在！";
            else if (ret == 2)
                return "Error：确认人并非该移账户移交的交接人！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    #endregion










    #region 账户明细的增删改
    /// <summary>
    /// 功    能：增加账户明细
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="accountID">账户ID</param>
    /// <param name="account">账户名称</param>
    /// <param name="detailDate">日期</param>
    /// <param name="abstract">摘要</param>
    /// <param name="borrow">借</param>
    /// <param name="loan">贷</param>
    /// <param name="balance">余额</param>
    /// <param name="departmentID">部门ID</param>
    /// <param name="department">部门</param>
    /// <param name="projectID">项目ID</param>
    /// <param name="project">项目</param>
    /// <param name="clerkID">经手人ID</param>
    /// <param name="clerk">经手人</param>
    /// <param name="remarks">备注</param>
    /// <param name="createManID">创建人ID</param>
    /// <returns>成功：账户编号，采用409号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "增加账户明细<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string addAccountDetails(string accountID, string account, string detailDate, string Detailsabstract, decimal borrow, decimal loan, decimal balance, string departmentID, string department,
        string projectID, string project, string clerkID, string clerk, string remarks, string createManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	            name:		addAccountDetails
	            function:	1.添加账户明细
				            注意：本存储过程不锁定编辑！
	            input: 
				            @accountID 	varchar(10)	not null,	--账户ID
				            @account		varchar(50)	not	null,	--账户名称
				            @detailDate	smalldatetime	not null,	--日期
				            @abstract	varchar(200),	--摘要
				            @borrow		numeric(15,2),		--借
				            @loan		numeric(15,2),		--贷
				            @balance		numeric(15,2),		--余额
				            @departmentID	varchar(13),	--部门ID
				            @department		varchar(30),	--部门
				            @projectID		varchar(13),	--项目ID
				            @project			varchar(50),	--项目
				            @clerkID		varchar(10),		--经手人ID
				            @clerk		varchar(30),		--经手人
				            @remarks		varchar(200),		--备注

				            @createManID varchar(10),		--创建人工号
	            output: 
				            @AccountDetailsID	varchar(14) output,	--交易ID，主键，使用408号号码发生器生成
				            @Ret		int output		--操作成功标示；0:成功，1：该账户已存在，9：未知错误
	            author:		卢嘉诚
	            CreateDate:	2016-3-23
         */
        SqlCommand cmd = new SqlCommand("addAccountDetails", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@AccountDetailsID", SqlDbType.VarChar, 14);
        cmd.Parameters["@AccountDetailsID"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@accountID", SqlDbType.VarChar, 10);
        cmd.Parameters["@accountID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountID"].Value = accountID;

        cmd.Parameters.Add("@account", SqlDbType.VarChar, 50);
        cmd.Parameters["@account"].Direction = ParameterDirection.Input;
        cmd.Parameters["@account"].Value = account;

        cmd.Parameters.Add("@detailDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@detailDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@detailDate"].Value = detailDate;

        cmd.Parameters.Add("@abstract", SqlDbType.VarChar, 200);
        cmd.Parameters["@abstract"].Direction = ParameterDirection.Input;
        cmd.Parameters["@abstract"].Value = Detailsabstract;

        cmd.Parameters.Add("@borrow", SqlDbType.Money);
        cmd.Parameters["@borrow"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrow"].Value = borrow;

        cmd.Parameters.Add("@loan", SqlDbType.Money);
        cmd.Parameters["@loan"].Direction = ParameterDirection.Input;
        cmd.Parameters["@loan"].Value = loan;

        cmd.Parameters.Add("@balance", SqlDbType.Money);
        cmd.Parameters["@balance"].Direction = ParameterDirection.Input;
        cmd.Parameters["@balance"].Value = balance;

        cmd.Parameters.Add("@departmentID", SqlDbType.VarChar, 13);
        cmd.Parameters["@departmentID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@departmentID"].Value = departmentID;

        cmd.Parameters.Add("@department", SqlDbType.VarChar, 30);
        cmd.Parameters["@department"].Direction = ParameterDirection.Input;
        cmd.Parameters["@department"].Value = department;

        cmd.Parameters.Add("@projectID", SqlDbType.VarChar, 13);
        cmd.Parameters["@projectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectID"].Value = projectID;

        cmd.Parameters.Add("@project", SqlDbType.VarChar, 50);
        cmd.Parameters["@project"].Direction = ParameterDirection.Input;
        cmd.Parameters["@project"].Value = project;

        cmd.Parameters.Add("@clerkID", SqlDbType.VarChar, 10);
        cmd.Parameters["@clerkID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@clerkID"].Value = clerkID;

        cmd.Parameters.Add("@clerk", SqlDbType.VarChar, 30);
        cmd.Parameters["@clerk"].Direction = ParameterDirection.Input;
        cmd.Parameters["@clerk"].Value = clerk;

        cmd.Parameters.Add("@remarks", SqlDbType.VarChar, 200);
        cmd.Parameters["@remarks"].Direction = ParameterDirection.Input;
        cmd.Parameters["@remarks"].Value = remarks;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = createManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@AccountDetailsID"].Value;
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    /// <summary>
    /// 功    能：删除账户明细
    /// 作    者：卢嘉诚
    /// 编写日期：2016-5-5
    /// </summary>
    /// <param name="FinancialSubjectID">科目ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：删除成功；失败："Error：..."</returns>
    [WebMethod(Description = "删除账户明细<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string delAccountDetails(string AccountDetailsID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		delAccountList
	        function:		1.删除账户明细
				        注意：本存储过程锁定编辑！
	        input: 
				        @AccountDetailsID	varchar(14) output,	--账户明细ID，主键，使用408号号码发生器生成
				        @lockManID varchar(10),		--锁定人ID
	        output: 
				        @Ret		int output		--操作成功标识;--操作成功标示；0:成功，1：该账户明细不存在，2：该账户明细被其他用户锁定，9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-3-23
	        UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
         */
        SqlCommand cmd = new SqlCommand("delAccountDetails", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@AccountDetailsID", SqlDbType.VarChar, 14);
        cmd.Parameters["@AccountDetailsID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@AccountDetailsID"].Value = AccountDetailsID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "删除账户明细成功！";
            else if (ret == 1)
                return "Error:账户" + AccountDetailsID + "不存在！";
            else if (ret == 2)
                return "Error:该账户被用户" + lockManID + "锁定";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }



    /// <summary>
    /// 功    能：编辑账户明细
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="AccountDetailsID">账户明细ID</param>
    /// <param name="accountID">账户ID</param>
    /// <param name="account">账户名称</param>
    /// <param name="detailDate">日期</param>
    /// <param name="abstract">摘要</param>
    /// <param name="borrow">借</param>
    /// <param name="loan">贷</param>
    /// <param name="balance">余额</param>
    /// <param name="departmentID">部门ID</param>
    /// <param name="department">部门</param>
    /// <param name="projectID">项目ID</param>
    /// <param name="project">项目</param>
    /// <param name="clerkID">经手人ID</param>
    /// <param name="clerk">经手人</param>
    /// <param name="remarks">备注</param>
    /// <param name="lockManID">锁定人</param>
    /// <returns>成功：编辑成功！；失败："Error：..."</returns>
    [WebMethod(Description = "增加账户明细<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string editAccountDetails(string AccountDetailsID,string accountID, string account, string detailDate, string Detailsabstract, decimal borrow, decimal loan, decimal balance, string departmentID, string department,
        string projectID, string project, string clerkID, string clerk, string remarks,string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		editAccountDetails	
	        function:	1.编辑账户明细
				        注意：本存储过程锁定编辑！
	        input: 
				        @AccountDetailsID	varchar(14) output,	--交易ID，主键，使用408号号码发生器生成
				        @accountID 	varchar(10),	--账户ID
				        @account		varchar(50),--账户名称
				        @detailDate	smalldatetime,	--日期
				        @abstract	varchar(200),	--摘要
				        @borrow		numeric(15,2),			--借
				        @loan		numeric(15,2),			--贷
				        @balance	numeric(15,2),			--余额
				        @departmentID	varchar(13),--部门ID
				        @department	varchar(30),	--部门
				        @projectID	varchar(13),	--项目ID
				        @project	varchar(50),	--项目
				        @clerkID	varchar(10),	--经手人ID
				        @clerk		varchar(30),	--经手人
				        @remarks	varchar(200),	--备注

				        @lockManID varchar(10)output,		--锁定人ID
	        output: 
				        @Ret		int output		--操作成功标示；0:成功，1：该账户明细不存在，2：该账户明细已被其他用户锁定，9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-3-23

         */
        SqlCommand cmd = new SqlCommand("editAccountDetails", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@AccountDetailsID", SqlDbType.VarChar, 14);
        cmd.Parameters["@AccountDetailsID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@AccountDetailsID"].Value = AccountDetailsID;

        cmd.Parameters.Add("@accountID", SqlDbType.VarChar, 10);
        cmd.Parameters["@accountID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@accountID"].Value = accountID;

        cmd.Parameters.Add("@account", SqlDbType.VarChar, 50);
        cmd.Parameters["@account"].Direction = ParameterDirection.Input;
        cmd.Parameters["@account"].Value = account;

        cmd.Parameters.Add("@detailDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@detailDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@detailDate"].Value = detailDate;

        cmd.Parameters.Add("@abstract", SqlDbType.VarChar, 200);
        cmd.Parameters["@abstract"].Direction = ParameterDirection.Input;
        cmd.Parameters["@abstract"].Value = Detailsabstract;

        cmd.Parameters.Add("@borrow", SqlDbType.Money);
        cmd.Parameters["@borrow"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrow"].Value = borrow;

        cmd.Parameters.Add("@loan", SqlDbType.Money);
        cmd.Parameters["@loan"].Direction = ParameterDirection.Input;
        cmd.Parameters["@loan"].Value = loan;

        cmd.Parameters.Add("@balance", SqlDbType.Money);
        cmd.Parameters["@balance"].Direction = ParameterDirection.Input;
        cmd.Parameters["@balance"].Value = balance;

        cmd.Parameters.Add("@departmentID", SqlDbType.VarChar, 13);
        cmd.Parameters["@departmentID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@departmentID"].Value = departmentID;

        cmd.Parameters.Add("@department", SqlDbType.VarChar, 30);
        cmd.Parameters["@department"].Direction = ParameterDirection.Input;
        cmd.Parameters["@department"].Value = department;

        cmd.Parameters.Add("@projectID", SqlDbType.VarChar, 13);
        cmd.Parameters["@projectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectID"].Value = projectID;

        cmd.Parameters.Add("@project", SqlDbType.VarChar, 50);
        cmd.Parameters["@project"].Direction = ParameterDirection.Input;
        cmd.Parameters["@project"].Value = project;

        cmd.Parameters.Add("@clerkID", SqlDbType.VarChar, 10);
        cmd.Parameters["@clerkID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@clerkID"].Value = clerkID;

        cmd.Parameters.Add("@clerk", SqlDbType.VarChar, 30);
        cmd.Parameters["@clerk"].Direction = ParameterDirection.Input;
        cmd.Parameters["@clerk"].Value = clerk;

        cmd.Parameters.Add("@remarks", SqlDbType.VarChar, 200);
        cmd.Parameters["@remarks"].Direction = ParameterDirection.Input;
        cmd.Parameters["@remarks"].Value = remarks;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "编辑成功！";
            else if (ret == 1)
                return "Error:账户明细" + AccountDetailsID + "不存在!";
            else if (ret == 2)
                return "Error:该账户明细已经被用户" + lockManID + "锁定！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    /// <summary>
    /// 功    能：锁定指定账户明细
    /// 作    者：卢嘉诚
    /// 编写日期：2016-5-4
    /// </summary>
    /// <param name="AccountDetailsID">账户明细ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：锁定成功；失败："Error：..."</returns>
    [WebMethod(Description = "锁定指定账户明细<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string lockAccountDetailsEdit(string AccountDetailsID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		lockAccountDetailsEdit
	        function: 	锁定账户明细编辑，避免编辑冲突
	        input: 
				        @AccountDetailsID varchar(14),		--账户ID
				        @lockManID varchar(10) output,	--锁定人，如果当前科目正在被人占用编辑则返回该人的工号
	        output: 
				        @Ret		int output		--操作成功标识0:成功，1：要锁定的账户明细不存在，2:要锁定的账户明细正在被别人编辑，9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-4-16
	        UpdateDate: 
         */
        SqlCommand cmd = new SqlCommand("lockAccountDetailsEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@AccountDetailsID", SqlDbType.VarChar, 14);
        cmd.Parameters["@AccountDetailsID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@AccountDetailsID"].Value = AccountDetailsID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;



        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "锁定成功！";
            else if (ret == 1)
                return "Error:账户明细" + AccountDetailsID + "不存在！";
            else if (ret == 2)
                return "Error:要锁定的账户明细正在被用户" + lockManID + "锁定编辑";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    /// <summary>
    /// 功    能：释放指定账户明细锁定
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="AccountDetailsID">账户明细ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：释放锁定成功！；失败："Error：..."</returns>
    [WebMethod(Description = "释放指定账户明细锁定<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string unlockAccountDetailsEdit(string AccountDetailsID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	            name:		lockAccountDetailsEdit
	            function: 	释放锁定账户明细编辑，避免编辑冲突
	            input: 
				            @AccountDetailsID varchar(14),		--交易ID
				            @lockManID varchar(10) output,	--锁定人，如果当前科目正在被人占用编辑则返回该人的工号
	            output: 
				            @Ret		int output		--操作成功标识0:成功，1：要释放锁定的账户明细不存在，2:要释放锁定的账户明细正在被别人编辑，8：该账户明细未被任何人锁定9：未知错误
	            author:		卢嘉诚
	            CreateDate:	2016-4-16
	            UpdateDate: 
         */
        SqlCommand cmd = new SqlCommand("unlockAccountDetailsEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@AccountDetailsID", SqlDbType.VarChar, 14);
        cmd.Parameters["@AccountDetailsID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@AccountDetailsID"].Value = AccountDetailsID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "释放锁定成功！";
            else if (ret == 1)
                return "Error:账户" + AccountDetailsID + "不存在！";
            else if (ret == 2)
                return "Error:该账户明细已被用户" + lockManID + "锁定无法编辑！";
            else if (ret == 8)
                return "Error:该账户明细未被任何人锁定！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    #endregion

    #region 收支明细的增删改
    /// <summary>
    /// 功    能：增加收入明细
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="projectID">项目ID</param>
    /// <param name="project">项目名称</param>
    /// <param name="customerID">客户ID</param>
    /// <param name="customerName">客户名称</param>
    /// <param name="abstract">摘要</param>
    /// <param name="incomeSum">收入金额</param>
    /// <param name="remarks">备注</param>
    /// <param name="startDate">收款日期</param>
    /// <param name="paymentApplicantID">收款申请人ID</param>
    /// <param name="payee">收款人</param>
    /// <param name="createManID">创建人ID</param>
    /// <returns>成功：收入明细编号，采用411号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "增加收入明细<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string addIncome(string projectID, string project, string customerID, string customerName, string Incomeabstract, decimal incomeSum,  string remarks,
         string startDate, string paymentApplicantID, string payee, string createManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	            name:		addIncome
	            function: 	该存储过程不锁定编辑
	            input: 

				            @projectID	varchar(13),	--项目ID
				            @project		varchar(50),		--项目名称
				            @customerID	varchar(10),			--客户ID
				            @customerName	varchar(30),		--客户名称
				            @abstract	varchar(200),			--摘要
				            @incomeSum	numeric(15,2),			--收入金额
				            @remarks	varchar(200),			--备注
				            @startDate	smalldatetime,			--收款日期
				            @paymentApplicantID	varchar(10),	--收款申请人ID
				            @payee	varchar(30),				--收款人
				            @createManID varchar(10),	--创建人

				
	            output: 
				            @incomeInformationID varchar(16)	output,	--收入记录号，主键，使用411号号码发生器生成
				            @Ret int output				--操作成功标识0:成功，9：未知错误
	            author:		卢嘉诚
	            CreateDate:	2016-4-16
	
         */
        SqlCommand cmd = new SqlCommand("addIncome", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@incomeInformationID", SqlDbType.VarChar, 16);
        cmd.Parameters["@incomeInformationID"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@projectID", SqlDbType.VarChar, 13);
        cmd.Parameters["@projectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectID"].Value = projectID;

        cmd.Parameters.Add("@project", SqlDbType.VarChar, 50);
        cmd.Parameters["@project"].Direction = ParameterDirection.Input;
        cmd.Parameters["@project"].Value = project;

        cmd.Parameters.Add("@customerID", SqlDbType.VarChar,13);
        cmd.Parameters["@customerID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@customerID"].Value = customerID;

        cmd.Parameters.Add("@customerName", SqlDbType.VarChar, 30);
        cmd.Parameters["@customerName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@customerName"].Value = customerName;

        cmd.Parameters.Add("@abstract", SqlDbType.VarChar,200);
        cmd.Parameters["@abstract"].Direction = ParameterDirection.Input;
        cmd.Parameters["@abstract"].Value = Incomeabstract;

        cmd.Parameters.Add("@incomeSum", SqlDbType.Money);
        cmd.Parameters["@incomeSum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@incomeSum"].Value = incomeSum;

        cmd.Parameters.Add("@remarks", SqlDbType.VarChar, 200);
        cmd.Parameters["@remarks"].Direction = ParameterDirection.Input;
        cmd.Parameters["@remarks"].Value = remarks;

        cmd.Parameters.Add("@startDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@startDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@startDate"].Value = startDate;

        cmd.Parameters.Add("@paymentApplicantID", SqlDbType.VarChar, 10);
        cmd.Parameters["@paymentApplicantID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@paymentApplicantID"].Value = paymentApplicantID;

        cmd.Parameters.Add("@payee", SqlDbType.VarChar, 30);
        cmd.Parameters["@payee"].Direction = ParameterDirection.Input;
        cmd.Parameters["@payee"].Value = payee;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = createManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@incomeInformationID"].Value;
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    /// <summary>
    /// 功    能：删除收入明细
    /// 作    者：卢嘉诚
    /// 编写日期：2016-5-5
    /// </summary>
    /// <param name="incomeInformationID">科目ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：删除成功；失败："Error：..."</returns>
    [WebMethod(Description = "删除收入明细<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string delIncome(string incomeInformationID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	            name:		delIncome
	            function:		1.删除收入明细
				            注意：本存储过程锁定编辑！
	            input: 
				            @incomeInformationID	varchar(16) output,	--收入信息ID，主键
				            @lockManID varchar(10),		--锁定人ID
	            output: 
				            @Ret		int output		--操作成功标识;--操作成功标示；0:成功，1：该收入明细不存在，2：该收入明细被其他用户锁定，3：请先锁定该收入明细再删除避免冲突，9：未知错误
	            author:		卢嘉诚
	            CreateDate:	2016-5-6
         */
        SqlCommand cmd = new SqlCommand("delIncome", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@incomeInformationID", SqlDbType.VarChar, 16);
        cmd.Parameters["@incomeInformationID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@incomeInformationID"].Value = incomeInformationID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "删除收入明细成功！";
            else if (ret == 1)
                return "Error:收入明细" + incomeInformationID + "不存在！";
            else if (ret == 2)
                return "Error:该收入明细被用户" + lockManID + "锁定";
            else if (ret == 3)
                return "Error:请先锁定该收入明细再删除避免冲突！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    /// <summary>
    /// 功    能：编辑收入明细
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="incomeInformationID">收入明细ID</param>
    /// <param name="projectID">项目ID</param>
    /// <param name="project">项目</param>
    /// <param name="customerID">客户ID</param>
    /// <param name="customerName">客户名称</param>
    /// <param name="Incomeabstract">摘要</param>
    /// <param name="incomeSum">收入金额</param>
    /// <param name="remarks">备注</param>
    /// <param name="startDate">收款日期</param>
    /// <param name="paymentApplicantID">收款申请人ID</param>
    /// <param name="payee">收款人</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：编辑成功！；失败："Error：..."</returns>
    [WebMethod(Description = "编辑收入明细<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string editIncome(string incomeInformationID, string projectID, string project, string customerID, string customerName,string Incomeabstract, decimal incomeSum,  string remarks,  string startDate, string paymentApplicantID, string payee, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		editIncome
	        function:	1.编辑收入明细
				        注意：本存储过程锁定编辑！
	        input: 
				        @incomeInformationID varchar(16),		--收入记录号，主键
				        @projectID	varchar(13),	--项目ID
				        @project		varchar(50),		--项目名称
				        @customerID	varchar(13),			--客户ID
				        @customerName	varchar(30),		--客户名称
				        @abstract		varchar(200),			--摘要
				        @incomeSum	numeric(15,2),			--收入金额
				        @remarks		varchar(200),			--备注
				        @startDate		smalldatetime,			--收款日期
				        @paymentApplicantID	varchar(10),	--收款申请人ID
				        @payee			varchar(30),				--收款人

				

	        output: 
				        @lockManID varchar(10) output,		--锁定人ID
				        @Ret		int output		--操作成功标示；0:成功，1：该账户明细不存在，2：该账户明细已被其他用户锁定，9：未知错误

	        author:		卢嘉诚
	        CreateDate:	2016-3-23

         */
        SqlCommand cmd = new SqlCommand("editIncome", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@incomeInformationID", SqlDbType.VarChar, 16);
        cmd.Parameters["@incomeInformationID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@incomeInformationID"].Value = incomeInformationID;

        cmd.Parameters.Add("@projectID", SqlDbType.VarChar, 13);
        cmd.Parameters["@projectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectID"].Value = projectID;

        cmd.Parameters.Add("@project", SqlDbType.VarChar, 50);
        cmd.Parameters["@project"].Direction = ParameterDirection.Input;
        cmd.Parameters["@project"].Value = project;

        cmd.Parameters.Add("@customerID", SqlDbType.VarChar,13);
        cmd.Parameters["@customerID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@customerID"].Value = customerID;

        cmd.Parameters.Add("@customerName", SqlDbType.VarChar, 30);
        cmd.Parameters["@customerName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@customerName"].Value = customerName;

        cmd.Parameters.Add("@abstract", SqlDbType.VarChar,200);
        cmd.Parameters["@abstract"].Direction = ParameterDirection.Input;
        cmd.Parameters["@abstract"].Value = Incomeabstract;

        cmd.Parameters.Add("@incomeSum", SqlDbType.Money);
        cmd.Parameters["@incomeSum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@incomeSum"].Value = incomeSum;

        cmd.Parameters.Add("@remarks", SqlDbType.VarChar, 200);
        cmd.Parameters["@remarks"].Direction = ParameterDirection.Input;
        cmd.Parameters["@remarks"].Value = remarks;

        cmd.Parameters.Add("@startDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@startDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@startDate"].Value = startDate;

        cmd.Parameters.Add("@paymentApplicantID", SqlDbType.VarChar, 10);
        cmd.Parameters["@paymentApplicantID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@paymentApplicantID"].Value = paymentApplicantID;

        cmd.Parameters.Add("@payee", SqlDbType.VarChar, 30);
        cmd.Parameters["@payee"].Direction = ParameterDirection.Input;
        cmd.Parameters["@payee"].Value = payee;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "编辑成功！";
            else if (ret == 1)
                return "Error:收入明细" + incomeInformationID + "不存在!";
            else if (ret == 2)
                return "Error:该收入明细已经被用户" + lockManID + "锁定！";
            else if (ret == 3)
                return "Error:请先锁定该收入明细再编辑，避免冲突！";
            else if (ret == 4)
                return "Error:该收入明细已确认，无法编辑！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }




    /// <summary>
    /// 功    能：添加支出记录
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="projectID">项目ID</param>
    /// <param name="project">项目名称</param>
    /// <param name="customerID">客户ID</param>
    /// <param name="customerName">客户名称</param>
    /// <param name="abstract">摘要</param>
    /// <param name="expensesSum">支出金额</param>
    /// <param name="remarks">备注</param>
    /// <param name="startDate">申请日期</param>
    /// <param name="paymentApplicantID">付款申请人ID</param>
    /// <param name="paymentApplicant">付款人申请人</param>
    /// <param name="createManID">创建人ID</param>
    /// <returns>成功：支出记录ID，采用412号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "添加支出记录<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    [SoapHeader("PageHeader")]
    public string addExpenses(string projectID, string project, string customerID, string customerName, string Expensesabstract, decimal expensesSum,string remarks,
         string startDate, string paymentApplicantID, string paymentApplicant, string createManID)
    {
        verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		addExpenses
	        function:	1.添加支出记录
				        注意：本存储过程不锁定编辑！
	        input: 
				        @projectID	varchar(13),	--项目ID
				        @project		varchar(50),	--项目名称
				        @customerID	varchar(13),	--客户ID
				        @customerName	varchar(30),	--客户名称
				        @abstract	varchar(200),		--摘要
				        @expensesSum	numeric(15,2),--支出金额
				        @remarks	varchar(200),		--备注
				        @startDate	smalldatetime,	--申请日期
				        @paymentApplicantID	varchar(10),	--付款申请人ID
				        @paymentApplicant		varchar(30),	--付款申请人

				        @createManID varchar(10),		--创建人工号
	        output: 
				        @expensesID	varchar(16) output,	--支出记录ID，主键，使用412号号码发生器生成
				        @Ret		int output		--操作成功标识
							        0:成功，9：未知错误
				
	        author:		卢嘉诚
	        CreateDate:	2016-3-23

         */
        SqlCommand cmd = new SqlCommand("addExpenses", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@expensesID", SqlDbType.VarChar, 16);
        cmd.Parameters["@expensesID"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@projectID", SqlDbType.VarChar, 13);
        cmd.Parameters["@projectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectID"].Value = projectID;

        cmd.Parameters.Add("@project", SqlDbType.VarChar, 50);
        cmd.Parameters["@project"].Direction = ParameterDirection.Input;
        cmd.Parameters["@project"].Value = project;

        cmd.Parameters.Add("@customerID", SqlDbType.VarChar, 13);
        cmd.Parameters["@customerID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@customerID"].Value = customerID;

        cmd.Parameters.Add("@customerName", SqlDbType.VarChar, 30);
        cmd.Parameters["@customerName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@customerName"].Value = customerName;

        cmd.Parameters.Add("@abstract", SqlDbType.VarChar, 200);
        cmd.Parameters["@abstract"].Direction = ParameterDirection.Input;
        cmd.Parameters["@abstract"].Value = Expensesabstract;

        cmd.Parameters.Add("@expensesSum", SqlDbType.Money);
        cmd.Parameters["@expensesSum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@expensesSum"].Value = expensesSum;

        cmd.Parameters.Add("@remarks", SqlDbType.VarChar, 200);
        cmd.Parameters["@remarks"].Direction = ParameterDirection.Input;
        cmd.Parameters["@remarks"].Value = remarks;

        cmd.Parameters.Add("@startDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@startDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@startDate"].Value = startDate;

        cmd.Parameters.Add("@paymentApplicantID", SqlDbType.VarChar, 10);
        cmd.Parameters["@paymentApplicantID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@paymentApplicantID"].Value = paymentApplicantID;

        cmd.Parameters.Add("@paymentApplicant", SqlDbType.VarChar, 30);
        cmd.Parameters["@paymentApplicant"].Direction = ParameterDirection.Input;
        cmd.Parameters["@paymentApplicant"].Value = paymentApplicant;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = createManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@expensesID"].Value;
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    /// <summary>
    /// 功    能：删除支出记录
    /// 作    者：卢嘉诚
    /// 编写日期：2016-5-5
    /// </summary>
    /// <param name="expensesID">支出记录ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：删除成功；失败："Error：..."</returns>
    [WebMethod(Description = "删除支出记录<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string delExpenses(string expensesID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	            name:		delExpenses
	            function:		1.删除支出记录
				            注意：本存储过程锁定编辑！
	            input: 
				            @expensesID	varchar(16) output,		--支出信息ID，主键
				            @lockManID varchar(10),		--锁定人ID
	            output: 
				            @Ret		int output		--操作成功标识;--操作成功标示；0:成功，1：该支出记录不存在，2：该支出记录被其他用户锁定，3：请先锁定该支出记录再删除避免冲突，9：未知错误
	            author:		卢嘉诚
	            CreateDate:	2016-5-6
         */
        SqlCommand cmd = new SqlCommand("delExpenses", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@expensesID", SqlDbType.VarChar, 16);
        cmd.Parameters["@expensesID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@expensesID"].Value = expensesID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "删除支出记录成功！";
            else if (ret == 1)
                return "Error:支出记录" + expensesID + "不存在！";
            else if (ret == 2)
                return "Error:该支出记录被用户" + lockManID + "锁定";
            else if (ret == 3)
                return "Error:请先锁定该支出记录再删除避免冲突！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    /// <summary>
    /// 功    能：编辑支出记录
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="expensesID">支出记录ID</param>
    /// <param name="projectID">项目ID</param>
    /// <param name="project">项目</param>
    /// <param name="customerID">客户ID</param>
    /// <param name="customerName">客户名称</param>
    /// <param name="Expensesabstract">摘要</param>
    /// <param name="expensesSum">支出金额</param>
    /// <param name="remarks">备注</param>
    /// <param name="startDate">申请日期</param>
    /// <param name="paymentApplicantID">付款申请人ID</param>
    /// <param name="paymentApplicant">付款人申请人</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：编辑成功！；失败："Error：..."</returns>
    [WebMethod(Description = "编辑支出记录<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string editExpenses(string expensesID, string projectID, string project, string customerID, string customerName, string Expensesabstract, decimal expensesSum,  string remarks, string startDate, string paymentApplicantID, string paymentApplicant, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	            name:		editExpenses
	            function:	1.编辑支出记录
				            注意：本存储过程锁定编辑！
	            input: 
				            @expensesID	varchar(16),	    --支出记录ID，主键
				            @projectID	varchar(13),	    --项目ID
				            @project		varchar(50),	--项目名称
				            @customerID 	varchar(13),	 --客户ID
				            @customerName	varchar(30),	--客户名称
				            @abstract	    varchar(200),		--摘要
				            @expensesSum	numeric(15,2) , --支出金额
				            @remarks	varchar(200),		--备注
				            @startDate	smalldatetime,	    --申请日期
				            @paymentApplicantID	varchar(10),	--付款申请人ID
				            @paymentApplicant		varchar(30),	--付款申请人

	            output: 
				            @lockManID varchar(10)output,		--锁定人ID
				            @Ret		int output			--操作成功标示；0:成功，1：该支出记录不存在，2：该支出记录已被其他用户锁定，3:请先锁定该支出记录避免编辑冲突4：该支出记录已确认无法编辑9：未知错误

	            author:		卢嘉诚
	            CreateDate:	2016-3-23

         */
        SqlCommand cmd = new SqlCommand("editExpenses", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@expensesID", SqlDbType.VarChar, 16);
        cmd.Parameters["@expensesID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@expensesID"].Value = expensesID;

        cmd.Parameters.Add("@projectID", SqlDbType.VarChar, 13);
        cmd.Parameters["@projectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectID"].Value = projectID;

        cmd.Parameters.Add("@project", SqlDbType.VarChar, 50);
        cmd.Parameters["@project"].Direction = ParameterDirection.Input;
        cmd.Parameters["@project"].Value = project;

        cmd.Parameters.Add("@customerID", SqlDbType.VarChar, 13);
        cmd.Parameters["@customerID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@customerID"].Value = customerID;

        cmd.Parameters.Add("@customerName", SqlDbType.VarChar, 30);
        cmd.Parameters["@customerName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@customerName"].Value = customerName;

        cmd.Parameters.Add("@abstract", SqlDbType.VarChar, 200);
        cmd.Parameters["@abstract"].Direction = ParameterDirection.Input;
        cmd.Parameters["@abstract"].Value = Expensesabstract;

        cmd.Parameters.Add("@expensesSum", SqlDbType.Money);
        cmd.Parameters["@expensesSum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@expensesSum"].Value = expensesSum;

        cmd.Parameters.Add("@remarks", SqlDbType.VarChar, 200);
        cmd.Parameters["@remarks"].Direction = ParameterDirection.Input;
        cmd.Parameters["@remarks"].Value = remarks;

        cmd.Parameters.Add("@startDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@startDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@startDate"].Value = startDate;

        cmd.Parameters.Add("@paymentApplicantID", SqlDbType.VarChar, 10);
        cmd.Parameters["@paymentApplicantID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@paymentApplicantID"].Value = paymentApplicantID;

        cmd.Parameters.Add("@paymentApplicant", SqlDbType.VarChar, 30);
        cmd.Parameters["@paymentApplicant"].Direction = ParameterDirection.Input;
        cmd.Parameters["@paymentApplicant"].Value = paymentApplicant;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "编辑成功！";
            else if (ret == 1)
                return "Error:支出记录" + expensesID + "不存在!";
            else if (ret == 2)
                return "Error:该支出记录已经被用户" + lockManID + "锁定！";
            else if (ret == 3)
                return "Error:请先锁定该支出记录再编辑，避免冲突！";
            else if (ret == 4)
                return "Error:该支出记录已确认，无法编辑！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    /// <summary>
    /// 功    能：锁定指定收入明细
    /// 作    者：卢嘉诚
    /// 编写日期：2016-5-4
    /// </summary>
    /// <param name="incomeInformationID">收入明细ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：锁定成功；失败："Error：..."</returns>
    [WebMethod(Description = "锁定指定收入明细<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string lockIncomeEdit(string incomeInformationID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		lockAccountDetailsEdit
	        function: 	锁定收入明细编辑，避免编辑冲突
	        input: 
				        @incomeInformationID varchar(16),		--收入信息ID
				        @lockManID varchar(10) output,	--锁定人，如果当前收入明细正在被人占用编辑则返回该人的工号
	        output: 
				        @Ret		int output		--操作成功标识0:成功，1：要锁定的收入明细不存在，2:要锁定的收入明细正在被别人编辑，9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-4-16
	        UpdateDate: 
         */
        SqlCommand cmd = new SqlCommand("lockIncomeEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@incomeInformationID", SqlDbType.VarChar, 16);
        cmd.Parameters["@incomeInformationID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@incomeInformationID"].Value = incomeInformationID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;



        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "锁定成功！";
            else if (ret == 1)
                return "Error:收入记录" + incomeInformationID + "不存在！";
            else if (ret == 2)
                return "Error:要锁定的收入记录正在被用户" + lockManID + "锁定编辑";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    /// <summary>
    /// 功    能：释放指定收入明细锁定
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="incomeInformationID">收入明细ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：释放锁定成功！；失败："Error：..."</returns>
    [WebMethod(Description = "释放指定收入明细锁定<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string unlockIncomeEdit(string incomeInformationID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		unlockIncomeEdit
	        function: 	释放锁定收入明细编辑，避免编辑冲突
	        input: 
				        @incomeInformationID varchar(16),		--收入明细ID
				        @lockManID varchar(10) output,			--锁定人，如果当前收入正在被人占用编辑则返回该人的工号
	        output: 
				        @Ret		int output		--操作成功标识0:成功，1：要释放锁定的收入明细不存在，2:要释放锁定的收入明细正在被别人编辑，8：该收入明细未被任何人锁定9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-4-16
	        UpdateDate: 
         */
        SqlCommand cmd = new SqlCommand("unlockIncomeEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@incomeInformationID", SqlDbType.VarChar, 16);
        cmd.Parameters["@incomeInformationID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@incomeInformationID"].Value = incomeInformationID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "释放锁定成功！";
            else if (ret == 1)
                return "Error:收入明细" + incomeInformationID + "不存在！";
            else if (ret == 2)
                return "Error:该收入明细已被用户" + lockManID + "锁定无法编辑！";
            else if (ret == 8)
                return "Error:该收入明细未被任何人锁定！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }



    /// <summary>
    /// 功    能：锁定指定支出记录
    /// 作    者：卢嘉诚
    /// 编写日期：2016-5-4
    /// </summary>
    /// <param name="expensesID">支出记录ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：锁定成功；失败："Error：..."</returns>
    [WebMethod(Description = "锁定指定支出记录<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string lockExpensesEdit(string expensesID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		lockAccountDetailsEdit
	        function: 	锁定支出记录编辑，避免编辑冲突
	        input: 
				        @expensesID varchar(16),		--支出信息ID
				        @lockManID varchar(10) output,	--锁定人，如果当前支出记录正在被人占用编辑则返回该人的工号
	        output: 
				        @Ret		int output		--操作成功标识0:成功，1：要锁定的支出记录不存在，2:要锁定的支出记录正在被别人编辑，9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-4-16
	        UpdateDate: 
         */
        SqlCommand cmd = new SqlCommand("lockExpensesEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@expensesID", SqlDbType.VarChar, 16);
        cmd.Parameters["@expensesID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@expensesID"].Value = expensesID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;



        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "锁定成功！";
            else if (ret == 1)
                return "Error:支出记录" + expensesID + "不存在！";
            else if (ret == 2)
                return "Error:要锁定的支出记录正在被用户" + lockManID + "锁定编辑";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    /// <summary>
    /// 功    能：释放指定支出记录锁定
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="expensesID">支出记录ID</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：释放锁定成功！；失败："Error：..."</returns>
    [WebMethod(Description = "释放指定支出记录锁定<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string unlockExpensesEdit(string expensesID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	 	    name:		unlockExpensesEdit
	        function: 	释放锁定支出记录编辑，避免编辑冲突
	        input: 
				        @expensesID varchar(16),		--支出记录ID
				        @lockManID varchar(10) output,			--锁定人，如果当前支出正在被人占用编辑则返回该人的工号
	        output: 
				        @Ret		int output		--操作成功标识0:成功，1：要释放锁定的支出记录不存在，2:要释放锁定的支出记录正在被别人编辑，8：该支出记录未被任何人锁定9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-4-16
	        UpdateDate: 
         */
        SqlCommand cmd = new SqlCommand("unlockExpensesEdit", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@expensesID", SqlDbType.VarChar, 16);
        cmd.Parameters["@expensesID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@expensesID"].Value = expensesID;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "释放锁定成功！";
            else if (ret == 1)
                return "Error:支出记录" + expensesID + "不存在！";
            else if (ret == 2)
                return "Error:该支出记录已被用户" + lockManID + "锁定无法编辑！";
            else if (ret == 8)
                return "Error:该支出记录未被任何人锁定！";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }




    /// <summary>
    /// 功    能：确认指定收入明细
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="incomeInformationID">收入明细ID</param>
    /// <param name="ActualArrivalTime">实际到账时间</param>
    /// <param name="confirmationDate">确认日期</param>
    /// <param name="confirmationPersonID">确认人ID</param>
    /// <param name="confirmationPerson">确认人</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：释放锁定成功！；失败："Error：..."</returns>
    [WebMethod(Description = "确认指定收入明细<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string confirmIncome(string incomeInformationID, string ActualArrivalTime,string confirmationDate, string confirmationPersonID, string confirmationPerson,  string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	        name:		confirmIncome
	        function: 	该存储过程锁定账户编辑，避免编辑冲突
	        input: 
				        @incomeInformationID varchar(16)	,	--收入信息ID，主键
				        @ActualArrivalTime   smalldatetime  ,	--实际到账时间
				        @confirmationDate	smalldatetime	,	--确认日期
				        @confirmationPersonID	varchar(10),	--确认人ID
				        @confirmationPerson		varchar(30),	--确认人

				
	        output: 
				        @lockManID varchar(10) output,	--锁定人，如果当前借支单正在被人占用编辑则返回该人的工号
				        @Ret		int output		--操作成功标识0:成功，1：要确认的收入明细不存在，2:要确认的收入明细正在被别人锁定，3:该收入明细未锁定，请先锁定9：未知错误
	        author:		卢嘉诚
	        CreateDate:	2016-4-16
	
         */
        SqlCommand cmd = new SqlCommand("confirmIncome", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@incomeInformationID", SqlDbType.VarChar, 16);
        cmd.Parameters["@incomeInformationID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@incomeInformationID"].Value = incomeInformationID;

        cmd.Parameters.Add("@ActualArrivalTime", SqlDbType.SmallDateTime);
        cmd.Parameters["@ActualArrivalTime"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ActualArrivalTime"].Value = ActualArrivalTime;

        cmd.Parameters.Add("@confirmationDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@confirmationDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@confirmationDate"].Value = confirmationDate;

        cmd.Parameters.Add("@confirmationPersonID", SqlDbType.VarChar, 10);
        cmd.Parameters["@confirmationPersonID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@confirmationPersonID"].Value = confirmationPersonID;

        cmd.Parameters.Add("@confirmationPerson", SqlDbType.VarChar, 30);
        cmd.Parameters["@confirmationPerson"].Direction = ParameterDirection.Input;
        cmd.Parameters["@confirmationPerson"].Value = confirmationPerson;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "收入确认成功！";
            else if (ret == 1)
                return "Error:收入明细" + incomeInformationID + "不存在！";
            else if (ret == 2)
                return "Error:该收入明细已被用户" + lockManID + "锁定无法编辑！";
            else if (ret == 3)
                return "Error:该收入明细未锁定，请先锁定再确认，避免冲突";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }


    /// <summary>
    /// 功    能：确认指定支出记录
    /// 作    者：卢嘉诚
    /// 编写日期：2016-4-28
    /// </summary>
    /// <param name="expensesID">支出记录ID</param>
    /// <param name="collectionModeID">付款账户ID</param>
    /// <param name="collectionMode">付款账户</param>
    /// <param name="paymentDate">支付日期</param>
    /// <param name="confirmationDate">确认日期</param>
    /// <param name="confirmationPersonID">确认人ID</param>
    /// <param name="confirmationPerson">确认人</param>
    /// <param name="lockManID">锁定人ID</param>
    /// <returns>成功：释放锁定成功！；失败："Error：..."</returns>
    [WebMethod(Description = "确认指定支出记录<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string confirmexpenses(string expensesID,string collectionModeID,string collectionMode, string paymentDate,string confirmationDate, string confirmationPersonID, string confirmationPerson,string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	            name:		confirmexpenses
	            function: 	该存储过程锁定账户编辑，避免编辑冲突
	            input: 
				            @expensesID varchar(16),			--支出记录ID，主键
				            @collectionModeID	varchar(10),	--付款账户ID
				            @collectionMode	varchar(50),	--付款账户
				            @paymentDate		smalldatetime,	--支付日期
				            @confirmationDate	smalldatetime	,	--确认日期
				            @confirmationPersonID	varchar(10),	--确认人ID
				            @confirmationPerson	varchar(30),	--确认人
				
	            output: 
				            @lockManID varchar(10) output,	--锁定人，如果当前借支出记录正在被人占用编辑则返回该人的工号
				            @Ret		int output		--操作成功标识0:成功，1：要确认的支出记录不存在，2:要确认的支出记录正在被别人锁定，3:该支出记录未锁定，请先锁定9：未知错误
	            author:		卢嘉诚
	            CreateDate:	2016-4-16
	
          */
        SqlCommand cmd = new SqlCommand("confirmexpenses", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@expensesID", SqlDbType.VarChar, 16);
        cmd.Parameters["@expensesID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@expensesID"].Value = expensesID;

        cmd.Parameters.Add("@collectionModeID", SqlDbType.VarChar, 10);
        cmd.Parameters["@collectionModeID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@collectionModeID"].Value = collectionModeID;

        cmd.Parameters.Add("@collectionMode", SqlDbType.VarChar, 50);
        cmd.Parameters["@collectionMode"].Direction = ParameterDirection.Input;
        cmd.Parameters["@collectionMode"].Value = collectionMode;

        cmd.Parameters.Add("@paymentDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@paymentDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@paymentDate"].Value = paymentDate;

        cmd.Parameters.Add("@confirmationDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@confirmationDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@confirmationDate"].Value = confirmationDate;

        cmd.Parameters.Add("@confirmationPersonID", SqlDbType.VarChar, 13);
        cmd.Parameters["@confirmationPersonID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@confirmationPersonID"].Value = confirmationPersonID;

        cmd.Parameters.Add("@confirmationPerson", SqlDbType.VarChar, 10);
        cmd.Parameters["@confirmationPerson"].Direction = ParameterDirection.Input;
        cmd.Parameters["@confirmationPerson"].Value = confirmationPerson;


        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 13);
        cmd.Parameters["@lockManID"].Direction = ParameterDirection.InputOutput;
        cmd.Parameters["@lockManID"].Value = lockManID;

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            lockManID = (string)cmd.Parameters["@lockManID"].Value;
            if (ret == 0)
                return "支出确认成功！";
            else if (ret == 1)
                return "Error:支出记录" + expensesID + "不存在！";
            else if (ret == 2)
                return "Error:该支出记录已被用户" + lockManID + "锁定无法编辑！";
            else if (ret == 3)
                return "Error:该支出记录未锁定，请先锁定再确认，避免冲突";
            else
                return "Error:未知错误！";
        }
        catch (Exception e)
        {
            return "Error:" + e.Message;
        }
        finally
        {
            cmd.Dispose();
            sqlCon.Close();
            sqlCon.Dispose();
        }
    }

    #endregion


    /// <summary>
    /// 模块编号：
    /// 作    用：根据输入码获取项目列表。这是渐进增强控件使用的获取列表服务
    /// 作    者：
    /// 入口参数：
    ///             string inputCode    //输入的字符
    ///             string  maxItem     //最大行数
    /// 出口参数：
    ///             可用的项目结果集
    /// 编写日期：2016-03-28
    /// </summary>
    /// <param name="InputCode"></param>
    /// <param name="maxItem"></param>
    /// <returns></returns>
    [WebMethod(Description = "根据输入码获取项目列表。这是渐进增强控件使用的获取列表服务",
        EnableSession = false)]
    public DataSet getProjectListByInputCode( string InputCode, string maxItem)
    {
        //verifyPageHeader(this);

        string strCmd = "select distinct top " + maxItem +
                " projectID,projectName,customerName,contractAmount,collectedAmount" +
                " from project where  projectName like '%%" +
                InputCode + "%%' order by projectName";
        //从web.config获取连接字符串
        string constr = WebConfigurationManager.ConnectionStrings["constr"].ToString();
        using (SqlConnection sqlcon = new SqlConnection(constr))
        {
            try
            {
                sqlcon.Open();
                DataSet ds = new DataSet();
                using (SqlCommand sqlCmd = new SqlCommand(strCmd, sqlcon))
                using (SqlDataAdapter da = new SqlDataAdapter(sqlCmd))
                {
                    da.Fill(ds);
                }
                return ds;
            }
            catch (Exception e)
            {
                return null;
            }
        }
    }



}
