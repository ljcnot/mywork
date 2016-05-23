using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using localhost;
using System.Data;
using System.Web.SessionState;


public partial class userManagement_organizationManager_orgManagerList : System.Web.UI.Page,IRequiresSessionState,IHttpHandler
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            
            bindTreeview();
           
        }
    }
    #region  “组织机构”树初始化函数
    /// <summary>
    /// 模块编号：UI-201
    /// 作    用：将结果集绑定到“组织机构”树。
    /// 作    者：邹子杭
    /// 编写日期：2015-11-23
    /// </summary>
    public void bindTreeview()
    {
        //添加验证：
        organizationManager om = new organizationManager();
        om.pageHeaderValue = initWeb.InitWebServiceProxy();    
        DataSet ds = om.queryOrgList();
        om.Dispose();
        
        //默认添加公司的节点：
        TreeNode node = new TreeNode();
        node.SelectAction = TreeNodeSelectAction.Select;
        node.Target = "_self";
        node.Text = "组织机构";//节点名  
        node.NavigateUrl = "javascript:selectChange('0')";
        tvQueryObject.Nodes.Add(node);

        if (ds.Tables[0].Rows.Count < 1)
            return;
        
        //逐记录绑定树：
        foreach (DataRow Row in ds.Tables[0].Rows)
        {
            
            string newOrgID = Row["orgID"].ToString();
            string newOrgName = Row["orgName"].ToString();
            
            if (!AddNode(newOrgID, newOrgName))
                AddNode(newOrgID, newOrgName);
        }
        
    }
    /// <summary>
    /// 作用：添加节点
    /// 作者：邹子杭
    /// 入口参数：DataRow Row 行数据 
    /// 出口参数：
    /// 编写日期：2015-11-24
    /// </summary>
    /// <param name="newOrgID"></param>
    /// <param name="newOrgName"></param>
    /// <returns></returns>
    public bool AddNode(string newOrgID, string newOrgName)
    {       
        TreeNode node = new TreeNode();
        node.SelectAction = TreeNodeSelectAction.Select;
        node.Target = "_self";
        node.Value = newOrgID;      //组织机构代码
        //遍历树，查找父节点：
        foreach (TreeNode treeNode in tvQueryObject.Nodes[0].ChildNodes)
        {
            string orgID = treeNode.Value;
            if (newOrgID == orgID)
            {
                node.Text = newOrgName;
                node.NavigateUrl = "javascript:selectChange('" + newOrgID + "','" + newOrgName +"')";
                treeNode.ChildNodes.Add(node);
                return true;
            }            
        }
        node.Text = newOrgName;          //节点名
        node.NavigateUrl = "javascript:selectChange('" + newOrgID + "','" + newOrgName +"')";
        tvQueryObject.Nodes[0].ChildNodes.Add(node);

        return false;
        
    }
    #endregion
    protected void tvQueryObject_SelectedNodeChanged(object sender, EventArgs e)
    {
       
    }
    
}