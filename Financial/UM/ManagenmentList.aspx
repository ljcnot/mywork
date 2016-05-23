<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ManagenmentList.aspx.cs" Inherits="projectManagement_ManagenmentList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    <asp:TreeView ID="tvQueryObject" runat="server" EnableTheming="True" ExpandDepth="0"
            Height="122px" ImageSet="Arrows" MaxDataBindDepth="2"
            Width="94px" OnSelectedNodeChanged="tvQueryObject_SelectedNodeChanged">
            <ParentNodeStyle Font-Bold="False" />
            <HoverNodeStyle Font-Underline="True" ForeColor="#5555DD" />
            <SelectedNodeStyle Font-Underline="True" ForeColor="#5555DD" HorizontalPadding="0px"
                VerticalPadding="0px" />
            <NodeStyle Font-Names="Tahoma" Font-Size="14px" ForeColor="Black" HorizontalPadding="5px"
                NodeSpacing="0px" VerticalPadding="0px" />
        </asp:TreeView>
    </div>
    </form>
</body>
</html>
