/*
*  权限函数库：
*  权限内存对象构造函数及查询权限是否拥有、操作的范围的公共函数库
*
*  从userInfo/addRoler.html中抽取的公共权限操作函数，如果要修改请一致化！
*  by lw 2011-9-24
*  修订说明：
*  modi by lw 2012-8-4
*  1.修改操作访问数据范围字段名称；
*  2.增加本人数据访问颗粒度；
*  modi by lw 2012-11-08
*  3.将用户权限中的权限内存对象构造函数移入；
*/

//系统权限(资源)构造函数：
//wrt by lw 2012-8-7
function sysRight(rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem) {
    this.rightName = rightName; //权限名称:冗余字段
    this.rightEName = rightEName;   //权限的英文名称名称
    this.Url = Url; //权限功能对应的Url
    this.rightType = rightType;    //权限类别：F->管理功能，D->数据列表；
    this.rightKind = rightKind; //权限分类
    this.rightClass = rightClass;   //权限子类
    this.rightItem = rightItem; //权限小类
    this.id = rightKind + "_" + rightClass + "_" + rightItem;   //ID：快速查询的ID值
    this.checked = false;   //是否选择
    this.partSizes = [];    //权限可选的颗粒度
    this.oprs = [];         //权限的操作集：存放dataOpr对象
}

//资源操作对象构造函数：
//wrt by lw 2012-8-7
function dataOpr(oprType, oprName, oprEName, oprDesc, selectedPartSize) {
    this.id = oprEName;         //ID：快速查询的ID值
    this.oprType = oprType;     //操作的类别：由第99号代码字典定义
    this.oprName = oprName;     //操作的中文名称
    this.oprEName = oprEName;   //操作的英文名称
    this.oprDesc = oprDesc;     //操作的描述 
    this.checked = false;       //是否选择
    this.selectedPartSize = selectedPartSize;  //可选择的颗粒度
    this.canSelPartSizes = [];  //操作可选的颗粒度:存放oprCanSelPartSize对象
}

//操作的颗粒度构造函数：
//wrt by lw 2012-8-7
function oprCanSelPartSize(partSize, partSizeName) {
    this.partSize = partSize;
    this.partSizeName = partSizeName;
    this.enable = true;
}

//初始化一个树状结构的权限数组：
//入口参数：
//          var sysUserRight    //系统可用资源数组
//          var sysUserDataOpr  //系统可用操作集
//出口参数：
//          var rightsOption    //将操作集签入到系统可用资源中的数组
//wrt by lw 2012-11-08
function initSysRightTree(sysUserRight, sysUserDataOpr) {
    var rightsOption = [];
    //构造权限对象：
    for (var i = 0; i < sysUserRight.length; i++) {
        var r = sysUserRight[i];
        var p = rightsOption[rightsOption.length]
                  = new sysRight(r.rightName, r.rightEName, r.Url, r.rightType, r.rightKind, r.rightClass, r.rightItem);
        for (var j = 0; j < sysUserDataOpr.length; j++) {
            var opr = sysUserDataOpr[j];
            if (opr.rightKind == r.rightKind && opr.rightClass == r.rightClass && opr.rightItem == r.rightItem) {
                p.oprs[p.oprs.length] = new dataOpr(opr.oprType, opr.oprName, opr.oprEName, opr.oprDesc, opr.oprPartSize);
            }
        }
    }
    return rightsOption;
}

//根据ID查询权限（系统资源）的操作集：
//注意：本函数必须指定一个使用initSysRightTree构造的名称为rightsOption的权限树形数组
//wrt by lw 2012-8-7
function getOprsByID(id) {
    for (var i = 0; i < rightsOption.length; i++) {
        if (rightsOption[i].id == id) {
            return rightsOption[i].oprs;
        }
    }
    return false;
}

//获取指定类别的操作集：
//wrt by lw 2011-9-23
//注意：参数oprType 可以缺省，缺省时表示获取全部的指定类别数据的全部操作集
function getDataOprs(dataOprs, rightKind, rightClass, rightItem, oprType) {
    var oprs = [];
    for (var i = 0; i < dataOprs.length; i++) {
        if (dataOprs[i].rightKind == rightKind && dataOprs[i].rightClass == rightClass
                    && dataOprs[i].rightItem == rightItem
                    && (oprType == undefined || dataOprs[i].oprType == oprType)) {
            oprs[oprs.length] = dataOprs[i];
        }
    }
    return oprs;
}

//检查允许的操作集中是否有指定名称的操作：
//wrt by lw 2011-9-24
function haveAllowOpr(allowOprs, searchOprName) {
    for (var i = 0; i < allowOprs.length; i++) {
        if (allowOprs[i].oprEName == searchOprName || allowOprs[i].oprName == searchOprName)
            return true;
    }
    return false;
}

//获取指定操作的范围：
//wrt by lw 2011-9-24
function getOprLocate(allowOprs, searchOprName) {
    for (var i = 0; i < allowOprs.length; i++) {
        if (allowOprs[i].oprEName == searchOprName || allowOprs[i].oprName == searchOprName)
            return allowOprs[i].oprPartSize;
    }
    return '0';
}

//根据分类号和操作名称获取指定操作的范围：
//wrt by lw 2012-8-8
function getOprLocateByClassCode(dataOprs, rightKind, rightClass, rightItem, oprName) {
    for (var i = 0; i < dataOprs.length; i++) {
        if (dataOprs[i].rightKind == rightKind && dataOprs[i].rightClass == rightClass
                    && dataOprs[i].rightItem == rightItem
                    && (dataOprs[i].oprEName == oprName || dataOprs[i].oprName == oprName)) {
            return dataOprs[i].oprPartSize;
        }
    }
    return '0';
}

//根据用户权限的可操作范围和数据的管理信息设置按钮的状态：
//wrt by lw 2011-9-28
//参数：row,        数据行
//      clgColID,   院部所在列序号
//      uColID,     单位所在列序号
//      userColID,  单据的修改人工号所在列序号
//      allowOprs,  允许的操作集
//      buttonName  按钮的名称
//返回值：按钮对象
function setAButton(row, uColID, userColID, allowOprs, buttonName) {
    if (haveAllowOpr(allowOprs, buttonName)) {
        switch (getOprLocate(allowOprs, buttonName)) { //1->可在本人的数据中使用，2->可在本单位范围内数据使用，4->可在本院部范围内数据使用，8->可在全校使用
            case '1':
                if (row.cells[userColID].innerText != curUser.curUserInfo.userID)
                    thisGrid[0].grid.disableButton(buttonName);
                break;
            case '2':
                if (uColID == null) {   //处理报废单没有使用单位的颗粒度问题
                    if (row.cells[userColID].innerText != curUser.curUserInfo.userID)
                        thisGrid[0].grid.disableButton(buttonName);
                }
                else {
                    if (row.cells[clgColID].innerText != curUser.curUserInfo.clgCode
                    || (curUser.curUserInfo.uCode != "" && row.cells[uColID].innerText != curUser.curUserInfo.uCode)
                    || (curUser.curUserInfo.uCode == "" && row.cells[userColID].innerText != curUser.curUserInfo.userID)) //当资料不完整的时候降级 add by lw 2012-8-8
                        thisGrid[0].grid.disableButton(buttonName);
                }
                break;
            case '4':
                break;
            case '8':
                break;
        }
    }
}

//根据数据的范围获取命令是否允许：
//wrt by lw 2011-9-28
//参数：row,        数据行
//      clgColID,   院部所在列序号
//      uColID,     单位所在列序号
//      userColID,  单据的修改人工号所在列序号
//      allowOprs,  允许的操作集
//      cmdName     命令的名称
function getCmdEnable(row, clgColID, uColID, userColID, allowOprs, cmdName) {
    if (haveAllowOpr(allowOprs, cmdName)) {
        switch (getOprLocate(allowOprs, cmdName)) { //1->可在本人的数据中使用，2->可在本单位范围内数据使用，4->可在本院部范围内数据使用，8->可在全校使用
            case '1':
                if (row.cells[userColID].innerText == curUser.curUserInfo.userID)
                    return true;
                else
                    return false;
            case '2':
                if (uColID == null && row.cells[userColID].innerText == curUser.curUserInfo.userID)      //处理报废单没有使用单位的颗粒度问题
                    return true;
                else if (row.cells[clgColID].innerText == curUser.curUserInfo.clgCode && (curUser.curUserInfo.uName == ""
                                    || row.cells[uColID].innerText == curUser.curUserInfo.uCode))
                    return true;
                return false;
            case '4':
                if (row.cells[clgColID].innerText == curUser.curUserInfo.clgCode)
                    return true;
                else
                    return false;
            case '8':
                return true;
        }
    }
    else
        return false;
}
