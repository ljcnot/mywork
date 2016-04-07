<%@ Page Language="C#" AutoEventWireup="true" CodeFile="orgList.aspx.cs" Inherits="userManagement_organizationManager_orgManagerList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>组织机构管理</title>
    <link href="../css/userCss.css" rel="stylesheet" type="text/css" />
    <link href="../../css/style.css" rel="stylesheet" />
    <link href="../../jquery/css/popmenu.css" rel="stylesheet" type="text/css" />
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
        var curOrgID = '0';
        var strWhere = "";
        //定义button集：
        var curTools = [];
        curTools[curTools.length] = { name: 'cmdNew', displayname: "添加", bclass: 'cmdNew', title: "添加组织机构", onpress: toolbarItem_onclick };
        curTools[curTools.length] = { name: 'cmdDel', displayname: "删除", bclass: 'cmdDel', title: "删除组织机构", onpress: toolbarItem_onclick };
        curTools[curTools.length] = { name: 'cmdChange', displayname: "修改", bclass: 'cmdChange', title: "修改组织机构", onpress: toolbarItem_onclick };
        curTools[curTools.length] = { name: 'cmdShowCard', displayname: "查看", bclass: 'cmdShowCard', title: "查看组织机构", onpress: toolbarItem_onclick };
        curTools[curTools.length] = { name: 'cmdFilter', displayname: "筛选", bclass: 'cmdFilter', title: "筛选", onpress: toolbarItem_onclick };
        curTools[curTools.length] = { name: 'cmdRightSet', displayname: "权限设置", bclass: 'cmdRightSet', title: "机构权限设置", onpress: toolbarItem_onclick };
        curTools[curTools.length] = {
            name: 'cmdSetOff', type: "switchButton",
            buttons: [                
                { name: 'cmdSetOff', displayname: "注销", bclass: 'cmdSetOff', title: "" },
                { name: 'cmdActive', displayname: "启用", bclass: 'cmdActive', title: "" },
            ], onpress: toolbarItem_onclick
        };
        curTools[curTools.length] = {
            name: 'cmdSwitchPrint', type: "switchButton",
            buttons: [
                    { name: 'cmdPrintCard', displayname: "打印卡片", bclass: 'cmdPrintCard', title: "打印各机构详情卡片" },
                    { name: 'cmdPrint', displayname: "打印列表", bclass: 'cmdPrint', title: "打印各机构列表" }
            ], onpress: toolbarItem_onclick
        };
        curTools[curTools.length] = {
            name: 'cmdSwitchOutput', type: "switchButton",
            buttons: [{ name: 'cmdOutput', displayname: "导出", bclass: 'cmdOutput', title: "导出各机构列表", onpress: toolbarItem_onclick },
                    { name: 'cmdOutputTask', displayname: "任务", bclass: 'cmdShowCard', title: "查看我的导出任务", onpress: toolbarItem_onclick }
            ], onpress: toolbarItem_onclick
        };
        curTools[curTools.length] = { name: 'cmdSetMaster', displayname: "部门负责人", bclass: 'cmdSetMaster', title: "设定部门负责人", onpress: toolbarItem_onclick };
        //根据数据的范围设置按钮的状态：
        //wrt by lw 2011-9-28
        function setButton(row) {
            //恢复所有按钮状态到激活状态：
            $(".fbutton").each(function () { this.disabled = false; });
        }
        //右键菜单的处理：
        //允许的全部操作集：
        var contextMenuItem = [{ text: "查看", icon: "../../images/showCard.png", alias: "cmdShowCard", action: contextMenuItem_click },
                            { type: "splitLine" },
                            { text: "新建", icon: "../../images/cmdNew.png", alias: "contextmenu-add", action: contextMenuItem_click },
                            { text: "清空", icon: "../../images/clear.png", alias: "contextmenu-clear", action: contextMenuItem_click },
                            { text: "显示", icon: "../../images/Browse.png", alias: "contextmenu-view", action: contextMenuItem_click },
                            { type: "splitLine" },
                            { text: "导出", icon: "../../images/cmdOutput.png", alias: "contextmenu-output", action: contextMenuItem_click },
                            { type: "splitLine" },
                            { text: "刷新", icon: "../../images/cmdRefresh.png", alias: "contextmenu-reflash", action: contextMenuItem_click }];
        //---------------------------------------------------------------
        var selectedList = [];//选择列表
        var thisGrid = null;
        function orgList() {
            //modi by lw 2014-4-4改写了UIcomm.js中的disableBackSapce函数，区分浏览器判断
            if ($.browser.mozilla || $.browser.opera) document.onkeypress = disableBackSapce;
            else document.onkeydown = disableBackSapce; //禁止后退键  作用于IE、Chrome

            document.getElementById("user").style.height = getArg("resultWinHeight") + "px";

            thisGrid = $("#flex1").flexigrid({
                url: "handler/PageQueryOrgList.ashx",
                params: [{ name: "where", value: strWhere }],
                dataType: "xml",
                data: null,
                colModel: [
                { display: '序号', name: 'RowID', width: 55, sortable: false, align: 'center' },
                { display: '机构代码', name: 'orgID', width: 85, sortable: true, align: 'left' },
                { display: '机构类型', name: 'orgType', width: 55, sortable: true, align: 'left' },
                /*--由第10号代码字典定义--1:教学--2:科研--3:行政--4:后勤--9:其他*/
                { display: '机构名称', name: 'orgName', width: 210, sortable: true, align: 'left' },
                { display: '机构简称', name: 'abbOrgName', width: 55, sortable: true, align: 'left' },
                { display: '输入码', name: 'inputCode', width: 55, sortable: true, align: 'left' },
                { display: 'E_mail地址', name: 'e_mail', width: 210, sortable: true, align: 'left' },
                { display: '联系电话', name: 'tel', width: 85, sortable: true, align: 'left' },
                { display: '地址', name: 'tAddress', width: 210, sortable: true, align: 'left' },
                { display: '网址', name: 'web', width: 150, sortable: true, align: 'left' }],
                buttons:curTools,                    
                searchitems: [
                    { display: '机构名称', name: 'orgName', operater: "Like" }],
                sortname: "orgID",
                sortorder: "desc",
                usepager: true,
                //title: '组织机构管理',
                useRp: true, 
                rp: 20,
                rpOptions: [10, 15, 20, 30, 40, 100], //可选择设定的每页结果数 
                showTableToggleBtn: false,
                width: _w -240,
                height: _h - 87,
                singleSelect: true,//只能单选
                showcheckbox: true,//显示checkbox
                onrowchecked: function (row) {//checkbox事件处理函数
                    //alert($row[0].cells[2].text());
                },
                rowhandler: function (row) {
                    showOrg($(row.cells[2]).text());
                },//双击行
                rowClickHandler: setButton,//根据数据设置按钮的状态
                onError: errorReport,//获取数据出错处理

                rowMouseRightHandler: contextmenu,//行上鼠标右键
                resizable:false//是否允许重新定义尺寸
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
        //菜单条处理函数：
        function contextMenuItem_click(target) {
            var id = $(target.cells[2]).text();
            var cmd = this.data.alias;
            switch (cmd) {
                case "cmdShowCard": //查看
                    showOrg(id);
                    break;
                case "contextmenu-add":     //加入选择列表
                    for (var i = 0; i < selectedList.length; i++) {
                        if (selectedList[i] == id)
                            return;
                    }
                    selectedList[selectedList.length] = id;
                    break;
                case "contextmenu-clear":   //清空列表
                    selectedList = [];
                    break;
                case "contextmenu-view":    //显示选择列表
                    menuType = 1;
                    contextMenuItems = [];
                    contextMenuItems = [{ text: "查看", icon: "../../images/showCard.png", alias: "cmdShowCard", action: contextMenuItem_click },
                                { type: "splitLine" },
                                { text: "导出", icon: "../../images/cmdOutput.png", alias: "contextmenu-output", action: contextMenuItem_click },
                                { type: "splitLine" },
                                { text: "刷新", icon: "../../images/cmdRefresh.png", alias: "contextmenu-reflash", action: contextMenuItem_click },
                                { type: "splitLine" },
                                { text: "返回", icon: "../../images/cmdBack.png", alias: "contextmenu-return", action: contextMenuItem_click }];
                    showSelList();
                    break;
                case "contextmenu-output":  //导出选择列表
                    export2File("N");
                    break;
                case "contextmenu-reflash":  //刷新列表
                    thisGrid.flexReload();
                    break;
                case "contextmenu-return":  //从选择列表中返回
                    menuType = 0;
                    contextMenuItems = [];
                    contextMenuItems = [{ text: "查看", icon: "../../images/showCard.png", alias: "cmdShowCard", action: contextMenuItem_click },
                                { type: "splitLine" },
                                { text: "新建", icon: "../../images/cmdNew.png", alias: "contextmenu-add", action: contextMenuItem_click },
                                { text: "清空", icon: "../../images/clear.png", alias: "contextmenu-clear", action: contextMenuItem_click },
                                { text: "显示", icon: "../../images/Browse.png", alias: "contextmenu-view", action: contextMenuItem_click },
                                { type: "splitLine" },
                                { text: "导出", icon: "../../images/cmdOutput.png", alias: "contextmenu-output", action: contextMenuItem_click },
                                { type: "splitLine" },
                                { text: "刷新", icon: "../../images/cmdRefresh.png", alias: "contextmenu-reflash", action: contextMenuItem_click }];
                    thisGrid.flexOptions({ params: [{ name: "where", value: strWhere }] });
                    thisGrid.flexReload();
                    break;
            }
        }
        //工具条函数：
        function toolbarItem_onclick(cmd,grid)
        {
            var orgID = "";
            if ($(".trSelected").length > 0) {
                orgID = $($(".trSelected")[0].cells[2]).text();
            }
            switch (cmd) {
                case "cmdNew":     //添加机构：
                    var opener = $.dialog({
                        id: "addOrganization", title: "添加机构", width: "700px", height: "360px", lock: true,
                        content: "url:OrgManager/addOrganization.html",
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
                    delOrg(orgID);
                    break;
                case "cmdChange":  //修改机构：
                    if (orgID == "")
                        $.dialog.warning("请选择您要修改的机构！");
                    else
                        editOrg(orgID);
                    break;
                case "cmdShowCard":  //查询机构：
                    if (orgID == "")
                        $.dialog.warning("请选择您要查询的机构！");
                    else
                        showOrg(orgID);
                    break;
                case "cmdFilter"://筛选
                    var opener = $.dialog({
                        id: "orgFilter", title: "筛选", width: "700px", height: "360px", lock: true,
                        content: "url:OrgManager/orgFilter.html",
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
                case "cmdActive":
                    openOrg(orgID);
                    break;
                case "cmdSetOff":
                    stopOrg(orgID);
                    break;
                case "cmdRightSet":
                    rightSet();
                    break
                case "cmdSetMaster":
                    setDeptMaster();
                default:
            }
        }
        //设定部门负责人：
        function setDeptMaster() {
            $.dialog({
                id: "setDeptMaster", title: "部门负责人", width: "700px", height: "360px", lock: true,
                content: "url:OrgManager/deptMaster.html",
                close: function (cw, w) { return cw.beforeClose(w); },
                afterClose: function (status) {
                    if (status == "success")
                        thisGrid.flexReload();
                },
                min: false,
                max: false,
                help: true,
                helpID: 151
            });
        }
        //启用机构：
        function openOrg(orgID) {
            $.ajax({
                type: "POST",
                url: "handler/setOrganizationActive.ashx",
                data: { "orgID": orgID },
                dataType: "text",
                success: function (result) {
                    if (result == "") {
                        //刷新页面：
                        thisGrid.flexReload();
                    }
                    else if (result.substring(0, 6) == "Error:") {
                        $.dialog.errorTips(result.substring(6));
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.dialog.errorTips("ajax执行返回错误：" + textStatus);
                }
            });
        }
        //停用机构：
        function stopOrg(orgID) {
            $.ajax({
                type: "POST",
                url: "handler/setOrganizationOff.ashx",
                data: { "orgID": orgID },
                dataType: "text",
                success: function (result) {
                    if (result == "") {
                        //刷新页面：
                        thisGrid.flexReload();
                    }
                    else if (result.substring(0, 6) == "Error:") {
                        $.dialog.errorTips(result.substring(6));
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    $.dialog.errorTips("ajax执行返回错误：" + textStatus);
                }
            });
        }
        //锁定指定机构编辑:
        function lock4Edit(orgID) {
            $.ajax({
                async: false,   //调用方式：同步
                type: "POST",
                url: "handler/lock4Edit.ashx",
                data: { "orgID": orgID },
                dataType: "text",
                success: function (result) {
                    if (result == "") {
                        lockResult = result;
                    }
                    else if (result.substring(0, 6) == "Error:") {
                        $.dialog.errorTips(result.substring(6));
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) { alert(textStatus); }
            });
        }
        //修改组织机构信息：
        function editOrg(orgID)
        {
            lock4Edit(orgID);
            $.dialog({
                id: "updateOrganization", title: "修改机构", width: "700px", height: "360px", lock: true,
                content: "url:OrgManager/editOrgInfo.html?orgID=" + orgID,
                close: function (cw, w) { return cw.beforeClose(w); },
                afterClose: function (status) {
                    if (status == "success")
                        thisGrid.flexReload();
                },
                min: false,
                max: false,
                help: true,
                helpID: 151
            });
        }
        //查询机构：
        function showOrg(orgID) {
            $.dialog({
                id: "showOrganizaton", title: "详细信息", width: "700px", height: "360px", lock: true,
                content: "url:OrgManager/orgDetails.html?orgID=" + orgID,
                afterClose: function (status) {
                    if (status == "success")
                        thisGrid.flexReload();
                },
                min: false,
                max: false,
                help: true,
                helpID: 152
            });
        }
        //删除机构：
        function delOrg(orgID) {
            $.dialog.confirm('删除该组织机构会清除该组织机构的所有的信息。<br />您真的要删除这个机构吗？',
            function () {
                $.ajax({
                    type: "POST",
                    url: "handler/delOrganization.ashx",
                    data: { "orgID": orgID },
                    dataType: "text",
                    success: function (result) {
                        if (result == "") {
                            //刷新页面：
                            thisGrid.flexReload();
                        }
                        else if (result.substring(0, 6) == "Error:") {
                            $.dialog.errorTips(result.substring(6));
                        }
                    },
                    error: function (XMLHttpRequest, textStatus, errorThrown) {
                        $.dialog.errorTips("ajax执行返回错误：" + textStatus);
                    }
                });
            });
            return true;
        }
        //显示选择列表：
        function showSelList()
        {
            var strCodes = "";
            for ( i = 0; i < selectedList.length; i++) {
                strCodes += "'" + selectedList[i] + "',";
            }
            if (strCodes.length > 0) {
                strCodes = strCodes.substring(0, strCodes.length - 1);
            }
        }

        //显示指定的机构：
        function selectChange(orgID, orgName) {
            curOrgID = orgID;
            if (thisGrid != null) {
                var strWhere = "";
                thisGrid.flexOptions({ params: [{ name: "where", value: strWhere }] });
                thisGrid.flexReload();
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
            Height="122px"
            ImageSet="Arrows"
            MaxDataBindDepth="2"
            Width="94px"
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
                HorizontalPadding="5px"
                NodeSpacing="0px" 
                VerticalPadding="0px" />
        </asp:TreeView>
    </div>    
    <div id="dataWin" >
        <table id="flex1" style="display:none"></table>
    </div>    
    </form>
</body>
</html>
