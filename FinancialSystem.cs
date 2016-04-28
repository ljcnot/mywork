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
    /// <param name="flowProgress">流转进度</param>
    /// <returns>成功：借支单编号，采用401号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "添加借支单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
     public string addBorrowSingle(string borrowManID, string borrowMan, string position, string departmentID, string department, string borrowDate, string projectID,
        string projectName, string borrowReason, decimal borrowSum, int flowProgress)
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
			            @borrowSingleID varchar(15) ,  --借支单号,主键 由401号号码发生器生成
			            @borrowManID varchar(13)	,	--借支人ID
			            @borrowMan varchar(20)	,		--借支人（姓名）
			            @position	varchar(10)	,	--职务
			            @departmentID	varchar(13)	,	--部门ID
			            @department	varchar(16)	,	--部门
			            @borrowDate	varchar(19)	,	--借支时间
			            @projectID	varchar(14),	--所在项目ID
			            @projectName	varchar(200),	--所在项目（名称）
			            @borrowReason	varchar(200),	--借支事由
			            @borrowSum	money,	--借支金额
			            @flowProgress varchar(10),		--流转进度：0：待审核，1：审批中，2：已审结

			            @createManID varchar(10),		--创建人工号
	            output: 
				            @Ret		int output		--操作成功标识
							            0:成功，1：该国别名称或代码已存在，9：未知错误
				            @rowNum		int output,		--序号
				            @createTime smalldatetime output
	            author:		卢嘉诚
	            CreateDate:	2016-3-23
	            UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
        */
        SqlCommand cmd = new SqlCommand("addborrowSingle", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@borrowManID", SqlDbType.VarChar, 13);
        cmd.Parameters["@borrowManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowManID"].Value = borrowManID;

        cmd.Parameters.Add("@borrowMan", SqlDbType.VarChar, 20);
        cmd.Parameters["@borrowMan"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowMan"].Value = borrowMan;

        cmd.Parameters.Add("@position", SqlDbType.VarChar, 10);
        cmd.Parameters["@position"].Direction = ParameterDirection.Input;
        cmd.Parameters["@position"].Value = position;

        cmd.Parameters.Add("@departmentID", SqlDbType.VarChar, 13);
        cmd.Parameters["@departmentID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@departmentID"].Value = departmentID;

        cmd.Parameters.Add("@department", SqlDbType.VarChar, 16);
        cmd.Parameters["@department"].Direction = ParameterDirection.Input;
        cmd.Parameters["@department"].Value = department;

        cmd.Parameters.Add("@borrowDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@borrowDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowDate"].Value = borrowDate;

        cmd.Parameters.Add("@projectID", SqlDbType.VarChar, 14);
        cmd.Parameters["@projectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectID"].Value = projectID;

        cmd.Parameters.Add("@projectName", SqlDbType.VarChar, 200);
        cmd.Parameters["@projectName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectName"].Value = projectName;

        cmd.Parameters.Add("@borrowReason", SqlDbType.VarChar, 200);
        cmd.Parameters["@borrowReason"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowReason"].Value = borrowReason;

        cmd.Parameters.Add("@borrowSum", SqlDbType.Decimal, 12);
        cmd.Parameters["@borrowSum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowSum"].Value = borrowSum;

        cmd.Parameters.Add("@flowProgress", SqlDbType.Int);
        cmd.Parameters["@flowProgress"].Direction = ParameterDirection.Input;
        cmd.Parameters["@flowProgress"].Value = flowProgress;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = "user100";

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@borrowSingleID", SqlDbType.VarChar, 15);
        cmd.Parameters["@borrowSingleID"].Direction = ParameterDirection.Output;
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
    /// <param name="flowProgress">流转进度</param>
    /// <returns>成功：返回@Ret表示；失败："Error：..."</returns>
    [WebMethod(Description = "编辑借支单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string editBorrowSingle(string borrowSingleID,string borrowManID, string borrowMan, string position, string departmentID, string department, string borrowDate, string projectID,
        string projectName, string borrowReason, decimal borrowSum, int flowProgress)
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
                        @borrowSingleID varchar(15), 	--主键：借支单号，使用第 3 号号码发生器产生
			            @borrowManID varchar(13)	,	--借支人ID
			            @borrowMan varchar(20)	,		--借支人（姓名）
			            @position	varchar(10)	,	--职务
			            @departmentID	varchar(13)	,	--部门ID
			            @department	varchar(16)	,	--部门
			            @borrowDate	smalldatetime	,	--借支时间
			            @projectID	varchar(14),	--所在项目ID
			            @projectName	varchar(200),	--所在项目（名称）
			            @borrowReason	varchar(200),	--借支事由
			            @borrowSum	Decimal(12),	--借支金额
			            @flowProgress smallint,		--流转进度

			            @modiManID varchar(10),		--维护人工号
	            output: 
				            @Ret		int output		--操作成功标识
							            --操作表示，0：成功，1：该单据被其他人编辑占用，2：该单据为审核状态不允许编辑
	            author:		卢嘉诚
	            CreateDate:	2016-3-23
	            UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
        */
        SqlCommand cmd = new SqlCommand("editBorrowSingle", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@borrowSingleID", SqlDbType.VarChar, 15);
        cmd.Parameters["@borrowSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowSingleID"].Value = borrowSingleID;

        cmd.Parameters.Add("@borrowManID", SqlDbType.VarChar, 13);
        cmd.Parameters["@borrowManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowManID"].Value = borrowManID;

        cmd.Parameters.Add("@borrowMan", SqlDbType.VarChar, 20);
        cmd.Parameters["@borrowMan"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowMan"].Value = borrowMan;

        cmd.Parameters.Add("@position", SqlDbType.VarChar, 10);
        cmd.Parameters["@position"].Direction = ParameterDirection.Input;
        cmd.Parameters["@position"].Value = position;

        cmd.Parameters.Add("@departmentID", SqlDbType.VarChar, 13);
        cmd.Parameters["@departmentID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@departmentID"].Value = departmentID;

        cmd.Parameters.Add("@department", SqlDbType.VarChar, 16);
        cmd.Parameters["@department"].Direction = ParameterDirection.Input;
        cmd.Parameters["@department"].Value = department;

        cmd.Parameters.Add("@borrowDate", SqlDbType.SmallDateTime);
        cmd.Parameters["@borrowDate"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowDate"].Value = borrowDate;

        cmd.Parameters.Add("@projectID", SqlDbType.VarChar, 14);
        cmd.Parameters["@projectID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectID"].Value = projectID;

        cmd.Parameters.Add("@projectName", SqlDbType.VarChar, 200);
        cmd.Parameters["@projectName"].Direction = ParameterDirection.Input;
        cmd.Parameters["@projectName"].Value = projectName;

        cmd.Parameters.Add("@borrowReason", SqlDbType.VarChar, 200);
        cmd.Parameters["@borrowReason"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowReason"].Value = borrowReason;

        cmd.Parameters.Add("@borrowSum", SqlDbType.Decimal, 12);
        cmd.Parameters["@borrowSum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@borrowSum"].Value = borrowSum;

        cmd.Parameters.Add("@flowProgress", SqlDbType.Int);
        cmd.Parameters["@flowProgress"].Direction = ParameterDirection.Input;
        cmd.Parameters["@flowProgress"].Value = flowProgress;

        cmd.Parameters.Add("@modiManID", SqlDbType.VarChar, 10);
        cmd.Parameters["@modiManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@modiManID"].Value = "user100";
         
        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return "编辑成功！";
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
    /// <returns>成功：返回@Ret表示；失败："Error：..."</returns>
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
				@borrwSingleID varchar(15),			--借支单ID
				@lockManID varchar(13) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
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
                return "锁定成功！";
            else if (ret == 1)
                return "借支单" + borrowSingleID + "不存在！";
            else if (ret == 2)
                return "该单据已被用户" + lockManID + "锁定！";
            else
                return "未知错误！";
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
    /// <returns>成功：返回@Ret表示；失败："Error：..."</returns>
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
				@borrwSingleID varchar(15),			--借支单ID
				@lockManID varchar(13) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该借支单不存在，2：锁定该单据的人不是自己，8:该单据未被锁定,9：未知错误
	            author:		卢嘉诚
	            CreateDate:	2016-3-23
	            UpdateDate: 2016-3-23 by lw 根据编辑要求增加rowNum返回参数
        */
        SqlCommand cmd = new SqlCommand("unlockborrowSingleEdit", sqlCon);
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
                return "释放编辑锁成功！";
            else if (ret == 1)
                return "借支单" + borrowSingleID + "不存在！";
            else if (ret == 2)
                return "该单据已被用户" + lockManID + "锁定！";
            else if (ret == 8)
                return "该单据未被任何人锁定";
            else
                return "未知错误！";
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
    /// <returns>成功：返回@Ret表示；失败："Error：..."</returns>
    [WebMethod(Description = "删除指定借支单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string delborrowSingle(string borrowSingleID, string lockManID)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
	            name:		delborrowSingle
	            function:	删除指定借支单
	            input: 
				            @borrowSingleID varchar(15),			--借支单ID
				            @lockManID varchar(13) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
	            output: 
				            @Ret		int output		--操作成功标识
							            0:成功，
							            1：指定的借支单不存在，
							            2:要删除的借支单正被别人锁定，
							            3:该单据已经批复，不能删除，
							            9：未知错误
	            author:		卢嘉诚
	            CreateDate:	2016-4-16
	            UpdateDate: 
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
                return "借支单" + borrowSingleID + "不存在！";
            else if (ret == 2)
                return "该单据已被用户" + lockManID + "锁定！";
            else if (ret == 3)
                return "该单据处于审核状态无法删除";
            else
                return "未知错误！";
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
    /// <param name="approvalProgress">审批进度</param>
    /// <returns>成功：借支单编号，采用401号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "添加费用报销单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string addExpRemSingle(string departmentID, string ExpRemDepartment, string ExpRemDate, string projectID,
        string projectName, int ExpRemSingleNum, string note, int expRemSingleType, decimal amount, string borrowSingleID,
        decimal originalloan, decimal replenishment, decimal shouldRefund, string ExpRemPersonID, string ExpRemPerson,
        string businessPeopleID, string businessPeople, string businessReason, int approvalProgress)
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
				        @ExpRemSingleID varchar(15) not null,  --报销单编号
				        @departmentID varchar(13) not null,	--部门ID
				        @ExpRemDepartment varchar(20)	not null,	--报销部门
				        @ExpRemDate smalldatetime not null,	--报销日期
				        @projectID varchar(13) not null,	--项目ID
				        @projectName varchar(50) not null,	--项目名称
				        @ExpRemSingleNum smallint ,	--报销单据及附件
				        @note varchar(200),	--备注
				        @expRemSingleType smallint default,	--报销单类型，0：费用报销单，1：差旅费报销单
				        @amount money not null,	--合计金额
				        @borrowSingleID varchar(15) ,	--原借支单ID
				        @originalloan money not null,	--原借款
				        @replenishment money not null,	--应补款
				        @shouldRefund money not null,	--应退款
				        @ExpRemPersonID varchar(14) not null,	--报销人编号
				        @ExpRemPerson varchar(10)	not	null,	--报销人姓名
				        @businessPeopleID	varchar(14) not null,	--出差人编号
				        @businessPeople	varchar(10) not null,	--出差人
				        @businessReason varchar(200)	not null,	--出差事由
				        @approvalProgress smallint default(0) not null,	--审批进度

			        @createManID varchar(10),		--创建人工号
	        output: 
				        @Ret		int output		--操作成功标识
							        0:成功，1：该国别名称或代码已存在，9：未知错误
				        @rowNum		int output,		--序号
				        @createTime smalldatetime output
	        author:		卢嘉诚
        */
        SqlCommand cmd = new SqlCommand("addExpRemSingle", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@departmentID", SqlDbType.VarChar, 13);
        cmd.Parameters["@departmentID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@departmentID"].Value = departmentID;

        cmd.Parameters.Add("@ExpRemDepartment", SqlDbType.VarChar, 20);
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

        cmd.Parameters.Add("@borrowSingleID", SqlDbType.VarChar,15);
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

        cmd.Parameters.Add("@ExpRemPersonID", SqlDbType.VarChar,13);
        cmd.Parameters["@ExpRemPersonID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemPersonID"].Value = ExpRemPersonID;

        cmd.Parameters.Add("@ExpRemPerson", SqlDbType.VarChar,10);
        cmd.Parameters["@ExpRemPerson"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemPerson"].Value = ExpRemPerson;

        cmd.Parameters.Add("@businessPeopleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@businessPeopleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessPeopleID"].Value = businessPeopleID;

        cmd.Parameters.Add("@businessPeople", SqlDbType.VarChar, 10);
        cmd.Parameters["@businessPeople"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessPeople"].Value = businessPeople;

        cmd.Parameters.Add("@businessReason", SqlDbType.VarChar, 200);
        cmd.Parameters["@businessReason"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessReason"].Value = businessReason;

        cmd.Parameters.Add("@approvalProgress", SqlDbType.SmallInt);
        cmd.Parameters["@approvalProgress"].Direction = ParameterDirection.Input;
        cmd.Parameters["@approvalProgress"].Value = approvalProgress;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar,13);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = "user100";

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@createTime", SqlDbType.SmallDateTime);
        cmd.Parameters["@createTime"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 15);
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
    public string addExpenseReimbursementDetails(string ExpRemSingleID, string ExpRemAbstract, string supplementaryExplanation, string financialAccountID, string financialAccount, decimal expSum )
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
				                ExpRemDetailsID	varchar(17)	not null,	--报销详情ID
				                ExpRemSingleID	varchar(16)	not null,	--报销单ID
				                abstract	varchar(100)	not null,	--摘要
				                supplementaryExplanation	varchar(100)	not null,	--补充说明
				                financialAccountID	varchar(13)	not null,	--报销科目ID
				                financialAccount	varchar(200)	not null,	--报销科目
				                expSum	float	not null,	--金额

				                @createManID varchar(10),		--创建人工号
	                output: 
				                @Ret		int output		--操作成功标识
							                0:成功，1：该国别名称或代码已存在，9：未知错误
				                @rowNum		int output,		--序号
				                @createTime smalldatetime output
	                author:		卢嘉诚
        */
        SqlCommand cmd = new SqlCommand("addExpenseReimbursementDetails", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 15);
        cmd.Parameters["@ExpRemSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleID"].Value = ExpRemSingleID;

        cmd.Parameters.Add("@abstract", SqlDbType.VarChar, 100);
        cmd.Parameters["@abstract"].Direction = ParameterDirection.Input;
        cmd.Parameters["@abstract"].Value = ExpRemAbstract;

        cmd.Parameters.Add("@supplementaryExplanation", SqlDbType.VarChar,100);
        cmd.Parameters["@supplementaryExplanation"].Direction = ParameterDirection.Input;
        cmd.Parameters["@supplementaryExplanation"].Value = supplementaryExplanation;

        cmd.Parameters.Add("@financialAccountID", SqlDbType.VarChar, 13);
        cmd.Parameters["@financialAccountID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@financialAccountID"].Value = financialAccountID;

        cmd.Parameters.Add("@financialAccount", SqlDbType.VarChar, 200);
        cmd.Parameters["@financialAccount"].Direction = ParameterDirection.Input;
        cmd.Parameters["@financialAccount"].Value = financialAccount;

        cmd.Parameters.Add("@expSum", SqlDbType.Money);
        cmd.Parameters["@expSum"].Direction = ParameterDirection.Input;
        cmd.Parameters["@expSum"].Value = expSum;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 13);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = "user100";

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@createTime", SqlDbType.SmallDateTime);
        cmd.Parameters["@createTime"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@ExpRemDetailsID", SqlDbType.VarChar, 17);
        cmd.Parameters["@ExpRemDetailsID"].Direction = ParameterDirection.Output;
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
        string otherExpenses, decimal otherExpensesSum)
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
				            TravelExpensesDetailsID varchar(18) not null,	--差旅费报销详情ID
				            ExpRemSingleID varchar(15) not null,	--报销单编号
				            StartDate smalldatetime	not null,	--起始时间
				            endDate smalldatetime not null,	--结束日期
				            startingPoint varchar(12) not null,	--起点
				            destination varchar(12) not null,	--终点
				            vehicle		varchar(12)	not null,	--交通工具
				            documentsNum	int	not null,	--单据张数
				            vehicleSum	money not null,	--交通费金额
				            financialAccountID	varchar(13)	not null,	--科目ID
				            financialAccount	varchar(20) not null,	--科目名称
				            peopleNum	int not null,	--人数
				            travelDays float ,	-- 出差天数
				            TravelAllowanceStandard	money,	--出差补贴标准
				            travelAllowancesum	money	not null,	--补贴金额
				            otherExpenses	varchar(20) null,	--其他费用
				            otherExpensesSum	money	null,	--其他费用金额
        */
        SqlCommand cmd = new SqlCommand("addTravelExpensesDetails", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 15);
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

        cmd.Parameters.Add("@financialAccountID", SqlDbType.VarChar,13);
        cmd.Parameters["@financialAccountID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@financialAccountID"].Value = financialAccountID;

        cmd.Parameters.Add("@financialAccount", SqlDbType.VarChar,20);
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

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 13);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = "user100";

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@createTime", SqlDbType.SmallDateTime);
        cmd.Parameters["@createTime"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@TravelExpensesDetailsID", SqlDbType.VarChar, 17);
        cmd.Parameters["@TravelExpensesDetailsID"].Direction = ParameterDirection.Output;
        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@TravelExpensesDetailsID"].Value;
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
				        @ExpRemSingleID varchar(15),			--报销单ID
				        @approvalProgress smallint ,	--审批进度
				        @lockManID varchar(13) output,	--锁定人，如果当前报销单正在被人占用编辑则返回该人的工号
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

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 15);
        cmd.Parameters["@ExpRemSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleID"].Value = ExpRemSingleID;


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
                return "删除报销单成功！";
            else if (ret == 1)
                return "报销单" + ExpRemSingleID + "不存在！";
            else if (ret == 2)
                return "该单据已被用户" + lockManID + "锁定！";
            else if (ret == 3)
                return "该单据处于审核状态无法删除";
            else
                return "未知错误！";
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
				        @ExpRemSingleID varchar(15),			--报销单ID
				        @lockManID varchar(13) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
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

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 15);
        cmd.Parameters["@ExpRemSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleID"].Value = ExpRemSingleID;


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
                return "锁定成功！";
            else if (ret == 1)
                return "报销单" + ExpRemSingleID + "不存在！";
            else if (ret == 2)
                return "该单据已被用户" + lockManID + "锁定！";
            else
                return "未知错误！";
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
				        @ExpRemSingleID varchar(15),			--报销单ID
				        @lockManID varchar(13) output,	--锁定人，如果当前设备借用申请单正在被人占用编辑则返回该人的工号
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

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 15);
        cmd.Parameters["@ExpRemSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleID"].Value = ExpRemSingleID;


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
                return "释放编辑锁成功！";
            else if (ret == 1)
                return "报销单" + ExpRemSingleID + "不存在！";
            else if (ret == 2)
                return "该单据已被用户" + lockManID + "锁定！";
            else if (ret == 8)
                return "该单据未被任何人锁定";
            else
                return "未知错误！";
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
    /// <param name="approvalProgress">审批进度</param>
    /// <returns>成功：编辑成功！；失败："Error：..."</returns>
    [WebMethod(Description = "编辑费用报销单<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string editExpRemSingle(string ExpRemSingleID, string departmentID, string ExpRemDepartment, string ExpRemDate, string projectID,
        string projectName, int ExpRemSingleNum, string note, int expRemSingleType, decimal amount, string borrowSingleID,
        decimal originalloan, decimal replenishment, decimal shouldRefund, string ExpRemPersonID, string ExpRemPerson,
        string businessPeopleID, string businessPeople, string businessReason, int approvalProgress, string lockManID)
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
				            注意：本存储过程不锁定编辑！
	            input: 
				            @ExpRemSingleID varchar(15),  --报销单ID			
				            @departmentID varchar(13) ,	--部门ID
				            @ExpRemDepartment varchar(20)	,	--报销部门
				            @ExpRemDate smalldatetime ,	--报销日期
				            @projectID varchar(13) ,	--项目ID
				            @projectName varchar(50) ,	--项目名称
				            @ExpRemSingleNum smallint ,	--报销单据及附件
				            @note varchar(200),	--备注
				            @expRemSingleType smallint ,	--报销单类型，0：费用报销单，1：差旅费报销单
				            @amount money ,	--合计金额
				            @borrowSingleID varchar(15) ,	--原借支单ID
				            @originalloan money ,	--原借款
				            @replenishment money ,	--应补款
				            @shouldRefund money ,	--应退款
				            @ExpRemPersonID varchar(14) ,	--报销人编号
				            @ExpRemPerson varchar(10),	--报销人姓名
				            @businessPeopleID	varchar ,	--出差人编号
				            @businessPeople	varchar(10) ,	--出差人
				            @businessReason varchar(200)	,	--出差事由
				            @approvalProgress smallint ,	--审批进度:0：新建，1：待审批，2：审批中,3:已审结

			                @lockManID varchar(10),		--创建人工号
	            output: 
				            @Ret		int output		--操作成功标识
							            0:成功，1：该借支单已被锁定，2：该借支单为审核状态9：未知错误
	            author:		卢嘉诚
	            CreateDate:	2016-3-23
	            UpdateDate: 2016-3-23 by 
        */
        SqlCommand cmd = new SqlCommand("editExpRemSingle", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@ExpRemSingleID", SqlDbType.VarChar, 15);
        cmd.Parameters["@ExpRemSingleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemSingleID"].Value = ExpRemSingleID;

        cmd.Parameters.Add("@departmentID", SqlDbType.VarChar, 13);
        cmd.Parameters["@departmentID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@departmentID"].Value = departmentID;

        cmd.Parameters.Add("@ExpRemDepartment", SqlDbType.VarChar, 20);
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

        cmd.Parameters.Add("@borrowSingleID", SqlDbType.VarChar, 15);
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

        cmd.Parameters.Add("@ExpRemPersonID", SqlDbType.VarChar, 13);
        cmd.Parameters["@ExpRemPersonID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemPersonID"].Value = ExpRemPersonID;

        cmd.Parameters.Add("@ExpRemPerson", SqlDbType.VarChar, 10);
        cmd.Parameters["@ExpRemPerson"].Direction = ParameterDirection.Input;
        cmd.Parameters["@ExpRemPerson"].Value = ExpRemPerson;

        cmd.Parameters.Add("@businessPeopleID", SqlDbType.VarChar, 13);
        cmd.Parameters["@businessPeopleID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessPeopleID"].Value = businessPeopleID;

        cmd.Parameters.Add("@businessPeople", SqlDbType.VarChar, 10);
        cmd.Parameters["@businessPeople"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessPeople"].Value = businessPeople;

        cmd.Parameters.Add("@businessReason", SqlDbType.VarChar, 200);
        cmd.Parameters["@businessReason"].Direction = ParameterDirection.Input;
        cmd.Parameters["@businessReason"].Value = businessReason;

        cmd.Parameters.Add("@approvalProgress", SqlDbType.SmallInt);
        cmd.Parameters["@approvalProgress"].Direction = ParameterDirection.Input;
        cmd.Parameters["@approvalProgress"].Value = approvalProgress;

        cmd.Parameters.Add("@lockManID", SqlDbType.VarChar, 13);
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
                return "该单据已被用户" + lockManID + "锁定！";
            else if (ret == 2)
                return "该单据处于审核状态无法编辑";
            else if (ret == 3)
                return "报销单" + ExpRemSingleID + "不存在";
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
    /// <param name="enclosureID">附件ID</param>
    /// <param name="billType">票据类型</param>
    /// <param name="billID">票据ID</param>
    /// <param name="enclosureAddress">附件地址</param>
    /// <param name="enclosureType">附件类型</param>
    /// <returns>成功：借支单编号，采用406号号码发生器发生；失败："Error：..."</returns>
    [WebMethod(Description = "添加附件<br />"
                           + "<a href='../../SDK/PM/Interface.html#projectManager.addProject'>SDK说明</a>", EnableSession = false)]
    //[SoapHeader("PageHeader")]
    public string addEnclosure(int billType, string billID, string enclosureAddress, int enclosureType)
    {
        //verifyPageHeader(this);
        int ret = 9;
        //从web.config获取连接字符串
        string conStr = WebConfigurationManager.ConnectionStrings["conStr"].ToString();
        SqlConnection sqlCon = new SqlConnection(conStr);
        sqlCon.Open();
        /*
          	name:		addEnclosure
	        function:	1.添加附件
				        注意：本存储过程不锁定编辑！
	        input: 
				        enclosureID	varchar(15)	not	null,	--主键：附件ID，使用第406号号码发生器产生
				        billType	 smallint default(0)	not	null,	--票据类型：0，借支单，1：报销单
				        billID	varchar(15)	not	null,	--票据编号
				        enclosureAddress	varchar(200)	not	null,	--附件地址
				        enclosureType	 smallint default(0)	not	null,	--附件类型

				        @createManID varchar(10),		--创建人工号
	        output: 
				        @Ret		int output		--操作成功标识
							        0:成功，1：该国别名称或代码已存在，9：未知错误
				        @createTime smalldatetime output
	        author:		卢嘉诚
	CreateDate:	2016-3-23
        */
        SqlCommand cmd = new SqlCommand("addEnclosure", sqlCon);
        cmd.CommandType = CommandType.StoredProcedure;

        cmd.Parameters.Add("@enclosureID", SqlDbType.VarChar, 15);
        cmd.Parameters["@enclosureID"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@billType", SqlDbType.SmallInt);
        cmd.Parameters["@billType"].Direction = ParameterDirection.Input;
        cmd.Parameters["@billType"].Value = billType;

        cmd.Parameters.Add("@billID", SqlDbType.VarChar,15);
        cmd.Parameters["@billID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@billID"].Value = billID;

        cmd.Parameters.Add("@enclosureAddress", SqlDbType.VarChar, 200);
        cmd.Parameters["@enclosureAddress"].Direction = ParameterDirection.Input;
        cmd.Parameters["@enclosureAddress"].Value = enclosureAddress;

        cmd.Parameters.Add("@enclosureType", SqlDbType.SmallInt);
        cmd.Parameters["@enclosureType"].Direction = ParameterDirection.Input;
        cmd.Parameters["@enclosureType"].Value = enclosureType;

        cmd.Parameters.Add("@createManID", SqlDbType.VarChar, 13);
        cmd.Parameters["@createManID"].Direction = ParameterDirection.Input;
        cmd.Parameters["@createManID"].Value = "user0001";

        cmd.Parameters.Add("@Ret", SqlDbType.Int);
        cmd.Parameters["@Ret"].Direction = ParameterDirection.Output;

        cmd.Parameters.Add("@createTime", SqlDbType.SmallDateTime);
        cmd.Parameters["@createTime"].Direction = ParameterDirection.Output;


        try
        {
            cmd.ExecuteNonQuery();
            ret = (int)cmd.Parameters["@Ret"].Value;
            if (ret == 0)
                return (string)cmd.Parameters["@enclosureID"].Value;
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
}
