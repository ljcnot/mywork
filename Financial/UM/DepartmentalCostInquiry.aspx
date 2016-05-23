<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DepartmentalCostInquiry.aspx.cs" Inherits="ShareDoc_Catalogue_shareSet" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>类目设置</title>
    <link href="../../SysManager/css/userCss.css" rel="stylesheet" type="text/css"/>
    <link href="../../css/style.css" rel="stylesheet" />
    <link href="../../jquery/css/popmenu.css" rel="stylesheet" />
    <link href="../../css/lhgdialog/idialog.css" rel="stylesheet"type="text/css" />
    <link href="../../css/flexigrid/flexigrid.css" rel="stylesheet" type="text/css" />
    <link href="../../css/listTools.css" rel="stylesheet" type="text/css" />
    <!--JQuery主函数库-->
    <script src="../../jquery/jquery-1.10.2.js" type="text/javascript"></script>
    <script src="../../jquery/flexigrid.js" type="text/javascript"></script>
    <script src="../../jquery/popmenu.js" type="text/javascript"></script>
    <script src="../../js/cookie.js" type="text/javascript"></script>
    <!--系统参数库-->
    <script src="../../js/sysTools.js" type="text/javascript"></script>
    <script src="../../js/formats.js" type="text/javascript"></script>
    <!--HELP ID预定义常量-->
    <script src="../../js/helpID.js" type="text/javascript"></script>
    <script src="../../js/filter.js" type="text/javascript"></script>
    <!--权限函数库-->
    <script src="../../js/right.js" type="text/javascript"></script>
    <script src="../../js/UIcomm.js" type="text/javascript"></script>
    <!--新对话合类库-->
    <script src="../../jquery/lhgdialog/lhgdialog.js" type="text/javascript"></script>
    <link href="../../SysManager/css/style.css" rel="stylesheet" />
    <link href="../../jquery/css/tip.css" type="text/css" rel="stylesheet" />
    <link href="../../css/comboboxDefault.css" type="text/css" rel="stylesheet" />
    
    <script src="../../js/combo_2.0/combo.js" type="text/javascript"></script>
    
    <script src="../../jquery/jquery.bgiframe.js" type="text/javascript"></script>
    
    <script type="text/javascript">
        getMyTopWindow = function () {
            return parent.getMyTopWindow();
        }
        //自动检测容器尺寸：
        var _pIframe = window.frameElement; //容器对象
        var _w = 800; var _h = 500;
        if (_pIframe) {
            _w = $(_pIframe).width();
            _h = $(_pIframe).height();
        }
        //重新定义列表的尺寸：这是一个供主页面调用的函数
        //rewrt by lw 2012-1-4
        function resize(w, h) {
            if (!w || !h || w == 0 || h == 0) {
                var p = window.frameElement; //容器对象
                if (p) {
                    w = $(p).width();
                    h = $(p).height();
                }
            }
            _w = w; _h = h;
            thisGrid.flexResize(w, h - 87);
        }
        var lockResult = ""
        var categoryID = "";
        var strWhere = "";
        var curTools = [];
        curTools[curTools.length] = { name: 'cmdAddCategory', displayname: "添加", bclass: 'cmdNew', title: "添加类目", onpress: toolbarItem_onclick };
        curTools[curTools.length] = { name: 'cmdDelCategory', displayname: "删除", bclass: 'cmdDel', title: "删除类目", onpress: toolbarItem_onclick };
        curTools[curTools.length] = { name: 'cmdUpdateCategory', displayname: "编辑", bclass: 'cmdUpdate', title: "编辑类目", onpress: toolbarItem_onclick };
        curTools[curTools.length] = { name: 'cmdStart', displayname: "启用", bclass: 'cmdActive', title: "添加类目", onpress: toolbarItem_onclick };
        curTools[curTools.length] = { name: 'cmdStop', displayname: "停用", bclass: 'cmdSetOff', title: "删除类目", onpress: toolbarItem_onclick };
        curTools[curTools.length] = { name: 'cmdDAllStart', displayname: "全部启用", bclass: 'cmdAudit', title: "删除类目", onpress: toolbarItem_onclick };

        var thisGrid = null;
        function orgList() {
            //modi by lw 2014-4-4改写了UIcomm.js中的disableBackSapce函数，区分浏览器判断
            if ($.browser.mozilla || $.browser.opera) document.onkeypress = disableBackSapce;
            else document.onkeydown = disableBackSapce; //禁止后退键  作用于IE、Chrome

            document.getElementById("user").style.height = getArg("resultWinHeight") + "px";

            thisGrid = $("#flex1").flexigrid({
                url: "",
                params: [{ name: "where", value: strWhere }],
                dataType: "xml",
                data: null,
               

                buttons: curTools,
                searchitems: [
                    { display: '项目名称', name: 'projectName', isdefault: true, operater: "Like" }
                ],
                buttons: curTools,
                sortname: "categoryID",
                sortorder: "desc",
                title: "",
                usepager: true,
                useRp: true,
                rp: 20,
                showTableToggleBtn: true,
                width: _w,
                height: _h - 87,   //这是表格体的高度，要减去标题、工具条、表头和状态栏的高度
                singleSelect: true,  //只能单选

                showcheckbox: true, //显示checkbox
                onrowchecked: function (row) {  //checkbox事件处理函数
                    projectID = row[0].cells[2].innerText;
                },
                rowhandler: false,  //双击行
                //rowClickHandler: setButton, //根据数据设置按钮的状态
                //onError: errorReport,  //获取数据出错处理！！

                //rowMouseRightHandler: contextmenu, //行上鼠标右键
                resizable: false //是否允许重定义尺寸
            })
        }
        //重新加载grid：
        $(function () {
            orgList();
        });
        //右键菜单：
        var menuType = 0;   //0：一般列表中的右键菜单；1：显示选择列表中的右键菜单
        function contextmenu(row) {
            $(row).unbind("contextmenu");   //add by lw 2011-12-25
            var menu = { width: 150, items: clone(contextMenuItem) };
            $(row).contextmenu(menu);
        }
        function toolbarItem_onclick(cmd, grid) {
            var orgID = "";
            if ($(".trSelected").length > 0) {
                orgID = $($(".trSelected")[0].cells[2]).text();
            }
            switch (cmd) {
                case "cmdNew":     //添加机构：
                    var opener = $.dialog({
                        id: "addCategory", title: "添加类目", width: "700px", height: "360px", lock: true,
                        content: "url:Query/addCategory.html",
                        close: function (cw, w) { return cw.beforeClose(w); },
                        afterClose: function (status) {
                            if (status == "success")
                                thisGrid.flexReload();
                        },
                        min: false,
                        max: false,
                        help: true,
                        helpID: 150
                    });
                    break;
                case "cmdDel":     //删除机构：
                    f(fondsID == "")
                    $.dialog.warning("请选择您要删除的类目！");
                    delCategory(categoryID);
                    break;
                case "cmdEdit":    //修改
                    if (projectID == "")
                        $.dialog.warning("请选择您要修改的项目！");
                    else {
                        var opener = $.dialog({
                            id: "editCategory", title: "编辑类目页面", width: "920px", height: "480px", lock: true,
                            content: "url:editCategory.html?categoryID=" + categoryID,
                            close: function (cw, w) { return cw.beforeClose(w); },
                            afterClose: function (status) {
                                if (status == "success") {


                                }
                            },
                            min: true,
                            max: true,
                            resize: true,
                            help: true,
                            helpID: 150
                        });
                    }
                    break;
            }
        }
    </script>
</head>
<body onscroll="none">
    <form id="form1" runat="server">
    <div id="user">
        <asp:TreeView
            ID="tvQueryObject"
            runat="server"
            EnableTheming="True"
            ExpandDepth="0"
            Height="180px"
            ImageSet="Arrows"
            MaxDataBindDepth="2"
            Width="16px"
            OnSelectedNodeChanged="tvQueryObject_SelectedNodeChanged">
            <ParentNodeStyle Font-Bold="False" />
            <HoverNodeStyle 
                Font-Underline="True" 
                ForeColor="#5555DD" />
            <SelectedNodeStyle 
                Font-Underline="True" 
                ForeColor="#5555DD" 
                HorizontalPadding="0px"
                VerticalPadding="0px" />
            <NodeStyle 
                Font-Names="Tahoma" 
                Font-Size="14px" 
                ForeColor="Black" 
                HorizontalPadding="0px"
                NodeSpacing="0px" 
                VerticalPadding="0px" />
            <Nodes>
                <asp:TreeNode  NavigateUrl="#" Text="武汉东之友道信息技术有限公司" Expanded="True">
                    <asp:TreeNode NavigateUrl="#" Text="软工部"></asp:TreeNode>
                    <asp:TreeNode NavigateUrl="#" Text="总工办"></asp:TreeNode>
                    <asp:TreeNode NavigateUrl="#" Text="美工部"></asp:TreeNode>
                </asp:TreeNode>
            </Nodes>
        </asp:TreeView>
    </div>    
    <div id="dataWin" >
        <div id="frame">
        <table id="flex1" style="display:none;" summary="详细信息">
            <caption ><a style="float:left;margin-left:200px;font-size:20px">类目信息</a></caption>
            <tr>
                <td style="color:#000000">类目号:</td>
                <td ><input class="hei" id="categoryID" type="text" title="请输入类目号" /></td>
                <td style="color:#000000">类目名称：</td>
                <td><input class="hei" id="categoryName" type="text" title="请输入类目名称" /></td>
            </tr>

            <tr>
                <td style="color:#000000">描述</td>
                <td><input class="hei" id="describe" type="text" title="请描述"style="height:60px"/></td>
                <td style="color:#000000">标识</td>
                <td><input class="hei" id="logo" type="text" title="标识"style="height:60px"/></td>
            </tr>
            <tr>
                <td style="color:#000000">提交部门:</td>
                <td><input class="hei" id="submitDepartment" type="text" title="请输入全宗名称" /></td>
                <td style="color:#000000">提交人员：</td>
                <td><input class="hei" id="submitSigner" type="text" title="请输入归属部门" /></td> 
            </tr>
            <tr>
                <td style="color:#000000">提交时间:</td>
                <td><input class="hei" id="submitTime" type="text" title="请输入提交人员" /></td>
                <td >停用时间:</td>
                <td><input class="hei" id="stopTime" type="text" title="请输入提交时间" /></td>
            </tr>

            
        </table>
       </div>
    </div>    
    </form>
</body>
</html>
