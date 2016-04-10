using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using WebReference;
using System.Web.SessionState;
using System.Data;

public partial class projectManagement_ManagenmentList : System.Web.UI.Page,IHttpHandler, IRequiresSessionState
{
    protected void Page_Load(object sender, EventArgs e)
    {
        organizationManager dm = new organizationManager();
        dm.pageHeaderValue = initWeb.InitWebServiceProxy();
        DataSet cm = dm.queryTopOrg();
        dm.Dispose();
        TreeNode node = new TreeNode();
    }
    protected void tvQueryObject_SelectedNodeChanged(object sender, EventArgs e)
    {

    }
}