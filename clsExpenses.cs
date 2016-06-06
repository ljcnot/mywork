using System;
using System.Data;
using System.Data.SqlClient;
using System.Collections.Generic;
using System.Web;
using System.Web.Security;
using System.Web.Configuration;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;

/// <summary>
/// clsExpenses的摘要说明:支出明细基本信息
/// 作    者：卢苇
/// 编写日期：2016-6-6
/// </summary>
[DataContract]  //指明是进行反序列化Json对象
public class clsExpenses
{
    public string expensesID { get; set; }   //支出明细ID
    [DataMember]
    public string projectID { get; set; }  //项目ID
    [DataMember]
	public string projectName{ get; set; }  //项目名称

    [DataMember]
    public string customerID{ get; set; }   //委托单位ID，由客户管理系统维护
	public string customerName{ get; set; }   //委托单位名称：冗余设计
    [DataMember]
    public string ExpensesAbstract { get; set; }   //摘要
    [DataMember]
    public decimal expensesSum { get; set; }   //支出金额
    [DataMember]
    public string remarks { get; set; }   //备注
    [DataMember]
    public string collectionModeID { get; set; }   //付款账户ID
    [DataMember]
    public string collectionMode { get; set; }   //付款账户
    public string startDate { get; set; }   //申请日期

    public string paymentApplicantID { get; set; }   //付款申请人ID
    [DataMember]
    public string paymentApplicant { get; set; }   //付款申请人
    public int confirmationStatus { get; set; }   //确认状态，0：未确认，1：已确认
    [DataMember]
    public string paymentDate { get; set; }   //支付日期
    public string confirmationDate { get; set; }   //确认日期

    public string confirmationPersonID { get; set; }   //确认人ID
    [DataMember]
    public string confirmationPerson { get; set; }   //确认人



    public clsExpenses()
	{
		//
		//TODO: 在此处添加构造函数逻辑
		//
	}
    ~clsExpenses()
    {
    }

    /// <summary>
    /// 功   能：根据编号从数据库中加载数据构造支出明细对象
    /// 作    者：卢嘉诚
    /// 编写日期：2016-6-6
    /// </summary>
    /// <param name="expensesID">支出明细编号</param>
    public clsExpenses(string expensesID)
    {
        string strCmd = "select expensesID,projectID, project, customerID, customerName, abstract,";
        strCmd += "expensesSum,isnull(remarks,'')remarks, isnull(collectionModeID,'') collectionModeID,isnull(collectionMode,'') collectionMode,";
        strCmd += "isnull(convert(varchar(19),startDate,120),'') startDate, paymentApplicantID, paymentApplicant,";
        strCmd += "confirmationStatus,isnull(convert(varchar(19),paymentDate,120),'') paymentDate,";
        strCmd += "isnull(convert(varchar(19),confirmationDate,120),'') confirmationDate,";
        strCmd += "isnull(confirmationPersonID,'') confirmationPersonID, isnull(confirmationPerson,'') confirmationPerson";
        strCmd += " from expensesList";
        strCmd += " where expensesID='" + expensesID + "'";

        //从web.config获取连接字符串
        string constr = WebConfigurationManager.ConnectionStrings["constr"].ToString();
        using (SqlConnection sqlcon = new SqlConnection(constr))
        {
            try
            {
                sqlcon.Open();
                using (DataTable dt = new DataTable())
                using (SqlCommand sqlCmd = new SqlCommand(strCmd, sqlcon))
                using (SqlDataAdapter da = new SqlDataAdapter(sqlCmd))
                {
                    da.Fill(dt);
                    if (dt.Rows.Count == 1)
                    {
                        DataRow dr = dt.Rows[0];
                        this.expensesID = expensesID;
                        projectID = dr["projectID"].ToString();
                        projectName = dr["project"].ToString();
                        customerID = dr["customerID"].ToString();
                        customerName = dr["customerName"].ToString();
                        ExpensesAbstract = dr["abstract"].ToString();
                        expensesSum = decimal.Parse(dr["expensesSum"].ToString());
                        remarks = dr["remarks"].ToString();
                        collectionModeID = dr["collectionModeID"].ToString();
                        collectionMode = dr["collectionMode"].ToString();
                        startDate = dr["startDate"].ToString();
                        paymentApplicantID = dr["paymentApplicantID"].ToString();
                        paymentApplicant = dr["paymentApplicant"].ToString();
                        confirmationStatus = int.Parse(dr["confirmationStatus"].ToString());
                        paymentDate = dr["paymentDate"].ToString();
                        confirmationDate = dr["confirmationDate"].ToString();
                        confirmationPersonID = dr["confirmationPersonID"].ToString();
                        confirmationPerson = dr["confirmationPerson"].ToString();

                    }
                }
            }
            catch (Exception e)
            {
            }
        }
    }
}

