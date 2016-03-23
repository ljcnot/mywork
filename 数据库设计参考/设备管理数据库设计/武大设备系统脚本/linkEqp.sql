use HGDepdc211
/*
	设备管理信息系统-连接的省厅系统设备表
	author:		卢苇
	CreateDate:	2012-12-24
	UpdateDate: 
*/
--1.linkEqpInfo（连接的设备表）：
drop table [dbo].[linkEqpInfo]
CREATE TABLE [dbo].[linkEqpInfo](
	isUploaded nvarchar(4) null,	--是否上报
	ZCBH varchar(20) not null,		--主键：资产编号
	StdName nvarchar(30) null,		--资产名称
	CatalogID varchar(7) null,		--资产分类代码
	QTY	int null,					--数量:正整数，不可拆分的资产数量必须是1
	OrgnValue numeric(19,2)	null,	--价值:价值类型不是"无价值"时必填,与"财政性拨款"、"事业收入"与"其他资金"合计相等
	SrcName	nvarchar(10) null,		--取得方式:购置,调拨,捐赠,划拨,置换,其他
	fundSrc nvarchar(10) null,		--资金来源
	barCode varchar(30) null,		--一维条码：add by lw 2012-11-18
	curEqpStatus nvarchar(10) null,	--根据报表的规定重新定义设备的现状代码含义：本字段由第2号代码字典定义 modi by lw 2011-1-26
									--1：在用，指正在使用的仪器设备；
									--2：多余，指具有使用价值而未使用的仪器设备；
									--3：待修，指待修或正在修理的仪器设备；
									--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
									--5：丢失，
									--6：报废，
									--7：调出，
									--8：降档，指经学校批准允许降档次使用、管理的仪器设备；
									--9：其他，现状不详的仪器设备。
	keeper nvarchar(30) null,		--保管人
	eqpLocate nvarchar(100) null,	--设备所在地址:设备所在地add by lw 2012-5-22增加设备认领功能
	invoiceNum varchar(30) null,	--会计凭证号
	acceptYear varchar(10) null,	--入账年度
	acceptDate varchar(20) null,	--入账日期
	loginDate varchar(20) null,		--录入日期
	acceptMan nvarchar(30) null,	--录入人
	remark nvarchar(300) null,		--备注

 CONSTRAINT [PK_linkEqpInfo] PRIMARY KEY CLUSTERED 
(
	[ZCBH] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

select totalAmount, * from equipmentList

insert linkEqpInfo(isUploaded, ZCBH, StdName, CatalogID, QTY, OrgnValue, SrcName, fundSrc, barCode, curEqpStatus, 
		keeper, eqpLocate, invoiceNum, acceptYear, acceptDate, loginDate, acceptMan,remark)
select
已上报,资产编号,资产名称,分类代码,数量,账面原值,增加方式,资金来源,条形码,
使用状况,责任人,管理机构,会计凭证号,入账年度,入账日期,录入日期,录入人,备注
from l

select distinct 资产编号 from l

select * from linkEqpInfo where ZCBH in(
select l.ZCBH--, e.eCode, l.StdName, e.eName, l.OrgnValue, e.totalAmount, l.QTY, l.acceptYear, e.acceptDate, l.eqpLocate, clg.clgName, e.* , l.*
from equipmentList e left join college clg on e.clgCode = clg.clgCode
left join linkEqpInfo l on  e.eName = l.StdName
and e.totalAmount = l.OrgnValue
--and convert(char(4),YEAR(e.acceptDate)) = l.acceptYear
--and clg.clgName = l.eqpLocate
where l.ZCBH is not null)

select * from equipmentList where eName = '微机' and totalAmount=4100 and eModel='方正'

select * from linkEqpInfo

--上报资产与在库设备连接后的表：
select l.ZCBH, e.eCode, l.StdName, e.eName, l.OrgnValue, e.totalAmount, l.QTY, l.acceptYear, e.acceptDate, l.eqpLocate, clg.clgName, e.* , l.*
from equipmentList e left join college clg on e.clgCode = clg.clgCode
left join linkEqpInfo l on  e.eName = l.StdName
and e.totalAmount = l.OrgnValue
--and convert(char(4),YEAR(e.acceptDate)) = l.acceptYear
--and clg.clgName = l.eqpLocate
where l.ZCBH is not null

--匹配好的报废单表中的设备：
select '=trim("'+l.ZCBH+'")', '=trim("'+e.eCode+'")', l.StdName, e.eName, l.OrgnValue, e.totalAmount, l.QTY, l.acceptYear, e.acceptDate, l.eqpLocate, clg.clgName, e.* , l.*
from equipmentList e left join college clg on e.clgCode = clg.clgCode
left join linkEqpInfo l on  e.eName = l.StdName
and e.totalAmount = l.OrgnValue
--and convert(char(4),YEAR(e.acceptDate)) = l.acceptYear
--and clg.clgName = l.eqpLocate
where e.eCode in (select 设备编号 from info) and l.ZCBH is not null


--省厅系统数据分析：
--PurchaseApplicationDetail 配置计划明细表
--PurchaseApplicationMaster 配置计划主表

--AssetTreamentMaster 报废申请主表
--AssetTreamentDetail 报废申请明细表

--BasAssetStock 上报数据暂存表
--BasAssetSourcesOfFunding 经费来源表
--ModalTable 输入模板自定义字段描述表
--ModalTable_REP_ORDER 模板编号表
--AccountItemTable 卡片编号表

--BasClassCode GBT14885-1994
--Basdatatable 代码字典
--BasDeptCode 学校部门代码表
--BasLocationCode 学校地点表
--BASOrganInfo 学校基本信息表
--BASOrganLevel 财政分级标准
--BASPersonLevel 行政级别表
--BASProfession 职业分类表
--BasAdminCode 区域代码表

--ValidTable 验证信息表
--MONAUDITFORMULA 报表验证表达式表

--syxmdmb 使用项目代码表（房屋的使用方式）
--fundstypeCode 资产科目代码表
--BJREPZCSYJINYMQKBCODE	资产负债表资产项目

