use newfTradeDB2
/*
	武大外贸合同管理信息系统-运维类表和存储过程设计：包括权限管理和工作日志
	根据警用地理信息系统、设备管理系统改编
	author:		卢苇
	CreateDate:	2010-11-22
	UpdateDate: 2011-9-12重新设计权限表，
				1.原sysRight表描述：修改为只描述系统功能模块和数据对象，用来生成导航树，指定用户可以使用的功能模块和数据资源；
				2.增加sysDataOpr(数据操作集）表：描述系统数据资源可支持的操作，分为4类操作：查询、编辑、导出、审计，由第99号代码字典描述；
				3.相应修改角色权限和增加角色权限操作表；
				4.将原用户权限表去除，改为用户角色表，用户的权限改为动态计算。
				5.增加工作日志备份管理
				2012-8-4修改设计权限表：
				1.将系统权限表与访问颗粒度分离
*/
--1.0权限表：
select * from sysRight
where rightKind=1 and rightClass=3

select * from sysrole
select * from sysUserRole where sysUserName='fjc'
select * from sysuserInfo where sysUserName='fjc'
update sysuserInfo 
set sysPassword='2FAEB9A4B18B6E8D52ABE95664D0BBBD'
where sysUserName='fjc'

select * from epdc211.dbo.userInfo where sysUserName='bwm'

update sysRight
set rightType='D'
where rightKind=1 and rightClass=3

--modi by lw 2013-10-06
drop table sysRight
CREATE TABLE [dbo].[sysRight]
(
	rightID varchar(8) not null,		--权限的ID值：由于主页面增加ID值识别而增加的字段add by lw 2013-07-17
	rightName nvarchar(30) not null,	--权限名称
	rightEName varchar(30) not null,	--权限的英文名称名称
	Url varchar(200) null,				--权限功能对应的Url add by lw 2011-6-5
	rightType char(1) not null,			--权限类别：F->功能模块，D->数据对象
	rightKind smallint not null,		--主键：分类
	rightClass smallint default(0),		--主键：子类
	rightItem smallint default(0),		--主键：小类
	canUse char(1) not null,			--能够作为“使用”分配：Y->能，N->不不能
	rightDesc nvarchar(100) null,		--权限描述
 CONSTRAINT [PK_sysRight] PRIMARY KEY CLUSTERED 
(
	[rightKind] ASC,
	[rightClass] ASC,
	[rightItem] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--修订权限：by lw 2013-10-06
select * from sysRight
where rightKind=1 and rightClass=3
select * from sysRoleRight where rightKind=1 and rightClass=3
delete sysRight
where rightKind=3 and rightClass=3

insert sysRight(rightID,rightName, rightEName,Url, rightType, rightKind, rightClass,rightItem,canUse,rightDesc )
values('330','外贸服务评价','serviceEvaluate','trader/serviceEvaluate.html','D',3,3,0,'Y','查看外贸服务公司的评价情况的权利。')

insert sysRight(rightID,rightName, rightEName,Url, rightType, rightKind, rightClass,rightItem,canUse,rightDesc )
values('340','货物使用情况','eqpStatus','contractManager/eqpStatus.html','D',3,4,0,'Y','查看进口货物使用情况的权利。')

select * from sysRight where rightID=720
update sysRoleRight 
set Url ='realExchangeRate/realExchangeRateList.html'
where rightKind=7 and rightClass=2
update sysRight 
set Url ='realExchangeRate/realExchangeRateList.html'
where rightID=720


update sysRight
set rightid=CAST(rightkind as varchar(3)) +CAST(rightclass as varchar(2))+CAST(rightitem as varchar(2))

select * from sysRight where rightEName in ('defineSystem','FlowOption','SysInterface','OnlineUser','myResourceList','pulbicResourceList')
select * from sysRoleRight where rightEName in ('defineSystem','FlowOption','SysInterface','OnlineUser','myResourceList','pulbicResourceList')
delete sysRight where rightEName in ('defineSystem','FlowOption','SysInterface','OnlineUser','myResourceList','pulbicResourceList')

--1.1权限（系统资源）粒度表：
DROP TABLE [dbo].[sysRightPartSize]
CREATE TABLE [dbo].[sysRightPartSize]
(
	rightKind smallint not null,		--主键：分类
	rightClass smallint default(0),		--主键：子类
	rightItem smallint default(0),		--主键：小类
	partSize int not null,				--系统权限（资源）的可用粒度：由第98号代码字典定义
 CONSTRAINT [PK_sysRightPartSize] PRIMARY KEY CLUSTERED 
(
	[rightKind] ASC,
	[rightClass] ASC,
	[rightItem] ASC,
	[partSize] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
--定义外键：
ALTER TABLE [dbo].[sysRightPartSize]  WITH CHECK ADD  CONSTRAINT [FK_sysRightPartSize_sysRight] FOREIGN KEY([rightKind],[rightClass],[rightItem])
REFERENCES [dbo].[sysRight] ([rightKind],[rightClass],[rightItem])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysRightPartSize] CHECK CONSTRAINT [FK_sysRightPartSize_sysRight] 
go

select * from sysRightPartSize

--修订权限：2013-10-06
select p.rightKind,p.rightClass ,p.rightItem, rightName, p.partSize
from sysRight r left join sysRightPartSize p on r.rightKind = p.rightKind and r.rightClass=p.rightClass and r.rightItem=p.rightItem
where r.rightKind=3

insert sysRightPartSize(rightKind, rightClass, rightItem, partSize)
values(3,3,0,8)
insert sysRightPartSize(rightKind, rightClass, rightItem, partSize)
values(3,4,0,8)

select p.rightKind,p.rightClass ,p.rightItem, rightName, p.partSize
from sysRight r left join sysRightPartSize p on r.rightKind = p.rightKind and r.rightClass=p.rightClass and r.rightItem=p.rightItem
where r.rightKind=5



--1.2数据操作集（由于这个数据表为静态数据，所以并没有将操作集单独设计成一个表）：
alter table [dbo].[sysDataOpr] add sortNum smallint default(0)				--排序号码
drop table sysDataOpr
CREATE TABLE [dbo].[sysDataOpr]
(
	sortNum smallint null,				--排序号码
	rightKind smallint not null,		--外键：对应的数据对象分类
	rightClass smallint default(0),		--外键：对应的数据对象子类
	rightItem smallint default(0),		--外键：对应的数据对象小类
	oprType smallint not null,			--操作的类别：由第99号代码字典定义
	oprName varchar(20) not null,		--操作的名称
	oprEName varchar(20) not null,		--操作的英文名称
	oprDesc varchar(100) null			--操作的描述
 CONSTRAINT [PK_sysDataOpr] PRIMARY KEY CLUSTERED 
(
	[rightKind] ASC,
	[rightClass] ASC,
	[rightItem] ASC,
	[oprName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
--定义外键：
ALTER TABLE [dbo].[sysDataOpr]  WITH CHECK ADD  CONSTRAINT [FK_sysDataOpr_sysRight] FOREIGN KEY([rightKind],[rightClass],[rightItem])
REFERENCES [dbo].[sysRight] ([rightKind],[rightClass],[rightItem])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysDataOpr] CHECK CONSTRAINT [FK_sysDataOpr_sysRight] 
go


--修订权限：2013-10-06
select r.rightKind,r.rightClass ,r.rightItem, r.rightName, sortNum, oprType, oprName,oprEName, oprDesc
from sysRight r left join sysDataOpr o on r.rightKind = o.rightKind and r.rightClass=o.rightClass and r.rightItem=o.rightItem
where r.rightKind=1
order by rightKind,rightClass,rightItem,sortNum

update sysDataOpr
set sortNum=sortNum+1
where rightKind=1 and rightClass=1 and sortNum>12

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(13,1,1,0,1,'查阅变更表','cmdChangeList','查阅指定的合同的变更情况')

update sysDataOpr
set sortNum=sortNum+2
where rightKind=1 and rightClass=1 and sortNum>14

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(15,1,1,0,5,'评价','cmdEvaluate','对外贸公司服务质量进行评价')
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(16,1,1,0,1,'查阅评价表','cmdEvalList','查阅指定的合同的评价表')

delete sysDataOpr where rightKind=1 and rightClass=4
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
select sortNum, r.rightKind,4 ,r.rightItem, oprType, oprName,oprEName, oprDesc
from sysRight r left join sysDataOpr o on r.rightKind = o.rightKind and r.rightClass=o.rightClass and r.rightItem=o.rightItem
where r.rightKind=1 and r.rightClass=1

delete sysDataOpr where rightKind=1 and rightClass=3
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
select sortNum, r.rightKind,3 ,r.rightItem, oprType, oprName,oprEName, oprDesc
from sysRight r left join sysDataOpr o on r.rightKind = o.rightKind and r.rightClass=o.rightClass and r.rightItem=o.rightItem
where r.rightKind=1 and r.rightClass=1

update sysDataOpr
set oprName='打印列表'
where rightKind=1 and oprName='列表'

select r.rightKind,r.rightClass ,r.rightItem, r.rightName, sortNum, oprType, oprName,oprEName, oprDesc
from sysRight r left join sysDataOpr o on r.rightKind = o.rightKind and r.rightClass=o.rightClass and r.rightItem=o.rightItem
where r.rightKind=3
order by rightKind,rightClass,rightItem,sortNum
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(1,3,3,0,1,'默认列表','cmdDefaultList','数据对象默认列表功能')

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(2,3,3,0,2,'重建','cmdUpdate','重新构造指定年度的外贸服务评价')

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(3,3,3,0,1,'查阅','cmdShowCard','查看指定供应商的服务评价表')

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(4,3,3,0,3,'打印列表','cmdPrintList','打印列表')

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(5,3,3,0,3,'导出','cmdOutput','导出当前数据窗口中的列表')

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(6,3,3,0,1,'查阅评价表','cmdShowEvaluateCard','查看指定的服务评价表')

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(7,3,3,0,1,'查阅关联合同','cmdShowLinkContract','查看指定的服务评价表关联的合同')

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(8,3,3,0,2,'修改','cmdUpdateEvalCard','修改指定的服务评价表')

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(9,3,3,0,3,'打印评价表列表','cmdPrintEvalList','打印服务评价表列表')

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(10,3,3,0,3,'打印卡片','cmdPrintEvalCard','打印指定的服务评价表')

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(11,3,3,0,3,'导出评价表列表','cmdOutputEvalList','导出当前数据窗口中的列表')

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(1,3,4,0,1,'默认列表','cmdDefaultList','数据对象默认列表功能')

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(2,3,4,0,1,'筛选','cmdFilter','设定查询条件，约束设备列表的显示范围')


insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(3,3,4,0,3,'打印列表','cmdPrintList','打印列表')

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(4,3,4,0,3,'导出','cmdOutput','导出当前数据窗口中的列表')

--公告管理工具：
select sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc 
from sysDataOpr
where rightKind = 5 and rightClass=1
order by sortNum

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
select sortNum+1, 5, rightClass, rightItem, oprType, oprName, oprEName, oprDesc from hustOA.dbo.sysDataOpr
where rightKind = 1 and rightClass=1
order by sortNum

insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(3,	5,	1,	0,	2,	'克隆',	'cmdClone',	'将指定公告克隆一个副本并设置为等待发布状态')

update sysDataOpr
set sortNum =1
where rightKind = 5 and rightClass=1 and oprEName='cmdDefaultList'

update sysDataOpr
set sortNum =2
where rightKind = 5 and rightClass=1 and oprEName='cmdNew'

update sysDataOpr
set sortNum =sortNum+1
where rightKind = 5 and rightClass=1 and sortNum>=7

insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(3,	5,	1,	0,	3,	'撤销',	'cmdSetOff',	'撤销指定的公告（关闭发布，设置为等待发布状态）')


select sortNum,rightKind,2,rightItem,oprType, oprName, oprEName,oprDesc
from sysDataOpr
where rightKind=5 and rightClass=2
order by sortNum

update sysDataOpr
set sortNum =13
where rightKind=5 and rightClass=2 and oprName='导出'

insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(3,	5,	2,	0,	2,	'克隆',	'cmdClone',	'将指定公告克隆一个副本并设置为等待发布状态')

delete sysDataOpr where rightKind=5 and rightClass=2 and oprName in ('打印卡片','打印（列表）')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(7,	5,	2,	0,	3,	'撤销',	'cmdSetOff',	'撤销指定的公告（关闭发布，设置为等待发布状态）')

10	5	2	0	1	置顶	cmdToTop	将指定公告置顶特殊显示		3
11	5	2	0	1	撤销置顶	cmdCloseOnTop	撤销指定公告的置顶特殊显示		3
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(10,	5,	2,	0,	1,	'置顶',	'cmdToTop',	'将指定公告置顶特殊显示')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(11,	5,	2,	0,	1,	'撤销置顶',	'cmdCloseOnTop',	'撤销指定公告的置顶特殊显示')

insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(14,	5,	2,	0,	1,	'不约束到可见范围',	'cmdNotLimit2ICanSee',	'不约束到本人可以阅读的公告')

update sysDataOpr
set sortNum =12
where rightKind=5 and rightClass=2 and oprName='筛选'

--历史公告：
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(1,	5,	3,	0,	1,	'默认列表',	'cmdDefaultList',	'历史公告默认列表功能')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(2,	5,	3,	0,	2,	'克隆',	'cmdClone',	'将指定公告克隆一个副本并设置为等待发布状态')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(3,	5,	3,	0,	3,	'重新启用',	'cmdRecall',	'重新将指定公告设置为等待发布状态')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(4,	5,	3,	0,	1,	'查阅',	'cmdShowCard', '查阅指定公告')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(5,	5,	3,	0,	1,	'筛选',	'cmdFilter', '设定查询条件，约束公告列表的显示范围')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(6,	5,	3,	0,	4,	'导出',	'cmdOutput',	'导出当前数据窗口中的公告列表')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(7,	5,	3,	0,	1,	'不约束到可见范围',	'cmdNotLimit2ICanSee',	'不约束到本人可以阅读的公告')

--常用资料:
select sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc 
from sysDataOpr
where rightKind = 5 and rightClass=4
order by sortNum

insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(1,	5,	4,	0,	1,	'默认列表',	'cmdDefaultList',	'上传资料默认列表功能')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(2,	5,	4,	0,	2,	'上传',	'cmdUpload','上传资料文件')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(3,	5,	4,	0,	2,	'删除',	'cmdDel','删除上传的资料')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(4,	5,	4,	0,	3,	'发布',	'cmdPublish','发布上传的资料')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(5,	5,	4,	0,	3,	'关闭',	'cmdClose','关闭发布指定的上传资料')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(6,	5,	4,	0,	1,	'查阅',	'cmdShowCard','查看上传资料的详细信息')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(7,	5,	4,	0,	1,	'筛选',	'cmdFilter','设定查询条件，约束上传资料列表的显示范围')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(8,	5,	4,	0,	4,	'导出',	'cmdOutput','导出当前数据窗口中的上传资料列表')


--用户管理：
select sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc 
from sysDataOpr
where rightKind = 6
order by rightKind, rightClass,sortNum

--代码字典：
select sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc 
from sysDataOpr
where rightKind = 7 and rightClass=1
order by rightKind, rightClass, rightItem,sortNum
--汇率表：
select sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc 
from sysDataOpr
where rightKind = 7 and rightClass=2
order by rightKind, rightClass, rightItem,sortNum

insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(1,	7,	2,	0,	1,	'默认列表',	'cmdDefaultList','数据对象默认列表功能')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(2,	7,	2,	0,	2,	'获取',	'cmdDownload','获取当天的汇率')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(3,	7,	2,	0,	2,	'更新',	'cmdUpdate','更新指定的汇率')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(4,	7,	2,	0,	1,	'汇率换算',	'rateCalc','使用当前汇率计算兑换货币')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(5,	7,	2,	0,	1,	'查阅卡片',	'cmdShowCard','查看指定行的汇率的详细信息')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(6,	7,	2,	0,	4,	'打印列表',	'cmdPrint','打印列表')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(7,	7,	2,	0,	4,	'导出',	'cmdOutput','导出当前数据窗口中的列表')

select * from sysRight where rightKind = 7 and rightClass=2

--运行维护：
--在线用户管理：
select * from sysRight
select sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc 
from sysDataOpr
where rightKind = 9 and rightClass=7
order by rightKind, rightClass, rightItem,sortNum
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(1,	9,	7,	0,	1,	'默认列表',	'cmdDefaultList','在线用户默认列表功能')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(2,	9,	7,	0,	1,	'筛选',	'cmdFilter','设定查询条件，约束在线用户列表的显示范围')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(3,	9,	7,	0,	1,	'查阅卡片',	'cmdShowCard','查看指定在线用户的详细信息')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(4,	9,	7,	0,	2,	'清除',	'cmdDelAll','清除指定的在线用户')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(5,	9,	7,	0,	3,	'打印列表',	'cmdPrint','打印列表')
insert sysDataOpr(sortNum,rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
values(6,	9,	7,	0,	3,	'导出',	'cmdOutput','导出当前数据窗口中的在线用户列表')

--短信管理：
select sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc 
from sysDataOpr
where rightKind = 9 and rightClass=8
order by rightKind, rightClass, rightItem,sortNum
update sysDataOpr
set sortNum=6
where rightKind = 9 and rightClass=8 and oprName='查阅'
--短信账单：
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
select sortNum, 9, 9, rightItem, oprType, oprName, oprEName, oprDesc from hustOA.dbo.sysDataOpr
where rightKind = 10 and rightClass=5
order by sortNum


--获取系统所有的操作：
select distinct oprType, oprName, oprEName, oprDesc 
from sysDataOpr

select sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc
from sysDataOpr
where rightKind=1 and rightClass=3
order by sortNum

select *
from sysDataOpr
where rightKind=1 and rightClass=3
order by sortNum

/*
权限规划表：													
		F表示为管理功能，D表示为数据列表											
功能模块或数据对象	英文名称			URL								权限类别	分类	子类	小类	可以使用	数据对象查询范围可设置约束		查询操作集		...		权限描述
																														全校	本院部	本单位			筛选	查阅卡片...		
设备采购			planApplyForm										F			1		0		0		√																	可以操作设备采购管理功能的权利。
	采购申请单		eqpPlanApplyList	planApply/eqpPlanApplyList.html	D			1		1		0		√			√		√		√				√		√		...		可以操作“采购申请单”的权限，包括对采购申请单的查询、编辑、导出和审计（执行）的权利。
	购置计划		eqpPlanList			planApply/eqpPlanList.html		D			1		2		0		√			√		√		√				√		√		...		可以操作“购置计划”的权限，包括对购置计划的查询、导出和撤销权利。
...
详细定义请参见《武汉大学设备管理信息系统权限规划表》
*/


--2.0.角色表：
--角色程序计划提供的功能：
--1.根据角色ID获取角色的基本信息
--2.根据角色ID获取角色的权限信息
--3.添加角色基本信息
--4.修改角色基本信息
--5.删除全部角色的权限
--6.添加角色的权限（逐条）
--7.基本的锁操作
--8.删除角色
--9.根据获取用户的权限获取角色的权限
use epdc2
alter TABLE [dbo].[sysRole] add	sysRoleTypeName varchar(100) default('通用的校级角色')	--角色级别的名称：冗余设计 add by lw 2012-8-3
alter TABLE [dbo].[sysRole] add	clgName nvarchar(30) null				--学院名称：冗余字段，但是可以解释历史数据	add by lw 2012-8-3
alter TABLE [dbo].[sysRole] add	uName nvarchar(30) null					--使用单位名称:冗余字段，但是可以保留历史名称add by lw 2012-8-3

select * from sysRole
truncate table sysRole
drop TABLE [dbo].[sysRole]
CREATE TABLE [dbo].[sysRole] 
(
	sysRoleID smallint IDENTITY(1,1) NOT NULL,	--角色ID
	sysRoleName varchar(50) null,				--角色中文名
	sysRoleDesc nvarchar(100) null,				--角色描述
	sysRoleType smallint default(1),			--角色级别：由第100号代码字典定义：1—>通用的校级角色，2->通用的院部级角色，3->通用的单位角色，4->隶属于特定院部的角色,5->隶属于特定单位的角色
	sysRoleTypeName varchar(100) default('通用的校级角色'),	--角色级别的名称：冗余设计 add by lw 2012-8-3

	--特定区域的角色所在院部或单位
	unitID varchar(12) null,		--所属单位编码
	unitName nvarchar(30) null,		--所属单位名称:冗余设计。学校员工登记隶属学院名称,公司员工登记公司名称
	
	isOff int default(0),				--是否注销：0->未注销，1->已注销
	setOffDate smalldatetime,			--注销日期

	--最新维护情况:
	modiManID varchar(10) not null,		--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10) null,			--当前正在锁定编辑人工号

 CONSTRAINT [PK_sysRole] PRIMARY KEY CLUSTERED 
(
	[sysRoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


SET IDENTITY_INSERT dbo.sysRole ON

select * from sysRole

--预定义的角色：
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType, modiManID)
values('超级用户', '系统预设的拥有全部权限的用户', 1, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('校级系统管理员', '系统预设的拥有全部权限的用户', 1, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('院部系统管理员', '系统预设的隶属于院部的系统管理员，拥有本院部特定角色定义权限', 2, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('单位系统管理员', '系统预设的隶属于单位的系统管理员，拥有本单位特定角色定义权限', 3, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('一般用户', '系统预设的普通用户，系统默认分配该角色给每一个新建用户，该用户只拥有本单位的单据查询权限', 3, '0000000000')

select * from codeDictionary where classCode = 100
select * from sysRole

--2.1.角色权限表：
DROP TABLE [dbo].[sysRoleRight] 
CREATE TABLE [dbo].[sysRoleRight] 
(
	sysRoleID smallint not null,		--外键:角色ID
	rightName nvarchar(30) not null,	--权限名称:冗余字段
	rightEName varchar(30) not null,	--权限的英文名称名称 add by lw 2011-6-5
	Url varchar(200) null,				--权限功能对应的Url add by lw 2011-6-5
	rightType char(1) not null,			--权限类别：F->管理功能，D->数据列表；
	rightKind smallint not null,		--主键:分类
	rightClass smallint not null,		--主键:子类
	rightItem smallint not null,		--主键:小类
	rightDesc nvarchar(100) null,		--权限描述:冗余字段
 CONSTRAINT [PK_sysRoleRight] PRIMARY KEY CLUSTERED 
(
	[sysRoleID] ASC,
	[rightKind] ASC,
	[rightClass] ASC,
	[rightItem] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--定义外键：与系统角色表关联的外键
ALTER TABLE [dbo].[sysRoleRight]  WITH CHECK ADD  CONSTRAINT [FK_sysRoleRight_sysRole] FOREIGN KEY([sysRoleID])
REFERENCES [dbo].[sysRole] ([sysRoleID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysRoleRight] CHECK CONSTRAINT [FK_sysRoleRight_sysRole]
go

--定义外键：与系统权限表关联的外键
ALTER TABLE [dbo].[sysRoleRight]  WITH CHECK ADD  CONSTRAINT [FK_sysRoleRight_sysRight] FOREIGN KEY([rightKind],[rightClass],[rightItem])
REFERENCES [dbo].[sysRight] ([rightKind],[rightClass],[rightItem])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysRoleRight] CHECK CONSTRAINT [FK_sysRoleRight_sysRight]
go

--预定义的角色：超级用户，拥有全部权限：
insert sysRoleRight(sysRoleID,
	rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, rightDesc)
select 1, rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, rightDesc 
from sysRight
where canUse='Y' and rightKind*100+rightClass*10+rightItem not in (select rightKind*100+rightClass*10+rightItem from sysRoleRight where sysRoleID=1)

select * from sysRoleRight
select * from sysRole
--2.2.角色权限操作表：
select * from sysRoleDataOpr
DROP TABLE [dbo].[sysRoleDataOpr] 
CREATE TABLE [dbo].[sysRoleDataOpr] 
(
	sysRoleID smallint not null,		--外键:角色ID
	sortNum smallint null,				--排序号码
	rightKind smallint not null,		--主键:分类
	rightClass smallint not null,		--主键:子类
	rightItem smallint not null,		--主键:小类
	oprType smallint not null,			--操作的类别：由第99号代码字典定义
	oprName varchar(20) not null,		--操作的名称
	oprEName varchar(20) not null,		--操作的英文名称
	oprDesc varchar(100) null,			--操作的描述
	oprPartSize int not null,			--系统权限（资源）的操作粒度：由第98号代码字典定义
 CONSTRAINT [PK_sysRoleDataOpr] PRIMARY KEY CLUSTERED 
(
	[sysRoleID] ASC,
	[rightKind] ASC,
	[rightClass] ASC,
	[rightItem] ASC,
	[oprType] ASC,
	[oprName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--定义外键：与系统角色表关联的外键
ALTER TABLE [dbo].[sysRoleDataOpr]  WITH CHECK ADD  CONSTRAINT [FK_sysRoleDataOpr_sysRole] FOREIGN KEY([sysRoleID])
REFERENCES [dbo].[sysRole] ([sysRoleID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysRoleDataOpr] CHECK CONSTRAINT [FK_sysRoleDataOpr_sysRole]
go

--定义外键：与数据操作集表关联的外键
ALTER TABLE [dbo].[sysRoleDataOpr]  WITH CHECK ADD  CONSTRAINT [FK_sysRoleDataOpr_sysDataOpr] FOREIGN KEY([rightKind],[rightClass],[rightItem],[oprName])
REFERENCES [dbo].[sysDataOpr] ([rightKind],[rightClass],[rightItem],[oprName])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysRoleDataOpr] CHECK CONSTRAINT [FK_sysRoleDataOpr_sysDataOpr]
go

--定义外键：与角色权限表关联的外键:这个定义会导致多重路径，所以要手工维护与角色权限表的级联！！！
ALTER TABLE [dbo].[sysRoleDataOpr]  WITH CHECK ADD  CONSTRAINT [FK_sysRoleDataOpr_sysRoleRight] FOREIGN KEY([sysRoleID],[rightKind],[rightClass],[rightItem])
REFERENCES [dbo].[sysRoleRight] ([sysRoleID],[rightKind],[rightClass],[rightItem])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysRoleDataOpr] CHECK CONSTRAINT [FK_sysRoleDataOpr_sysRoleRight]
go

--给超级用户角色赋予全部的操作集：
insert sysRoleDataOpr
select 1,sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc, 8
from sysDataOpr

select * from sysRoleDataOpr where sysRoleID = 1 order by rightKind, rightClass, rightItem
select * from sysRole where sysRoleID = 1
select * from sysRoleRight where sysRoleID = 1


select * from userInfo
select * from sysRight

--3.用户角色表：
drop table sysUserRole
CREATE TABLE [dbo].[sysUserRole] 
(
	userID varchar(10) not null,		--外键:工号
	sysUserName varchar(30) not null,	--用户名:冗余字段
	sysRoleID smallint not null,		--外键:角色ID
	sysRoleName varchar(50) null,		--角色中文名:冗余字段
	sysRoleType smallint not null		--角色级别:冗余字段,由第100号代码字典定义：1—>通用的校级角色，2->通用的院部级角色，3->通用的单位角色，4->隶属于特定院部的角色,5->隶属于特定单位的角色
 CONSTRAINT [PK_sysUserRole] PRIMARY KEY CLUSTERED 
(
	[userID] ASC,
	[sysRoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--定义外键：与用户表关联的外键
ALTER TABLE [dbo].[sysUserRole]  WITH CHECK ADD  CONSTRAINT [FK_sysUserRole_sysUserInfo] FOREIGN KEY([userID])
REFERENCES [dbo].[sysUserInfo] ([userID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysUserRole] CHECK CONSTRAINT [FK_sysUserRole_sysUserInfo] 
go

--定义外键：与系统角色表关联的外键
ALTER TABLE [dbo].[sysUserRole]  WITH CHECK ADD  CONSTRAINT [FK_sysUserRole_sysRole] FOREIGN KEY([sysRoleID])
REFERENCES [dbo].[sysRole] ([sysRoleID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysUserRole] CHECK CONSTRAINT [FK_sysUserRole_sysRole]
go

drop PROCEDURE addSysRole
/*
	name:		addSysRole
	function:	3.1.添加角色
				注意：这个存储过程角色名的唯一性！并锁定为独占式编辑！
	input: 
				@sysRoleName varchar(50),		--角色中文名
				@sysRoleDesc nvarchar(100),		--角色描述
				@sysRoleType smallint,			--角色级别：由第100号代码字典定义：1—>通用的校级角色，2->通用的院部级角色，3->通用的单位角色，4->隶属于特定院部的角色,5->隶属于特定单位的角色
				@unitID varchar(12),			--所属单位编码
				@unitName nvarchar(30),			--所属单位名称:冗余设计。学校员工登记隶属学院名称,公司员工登记公司名称
	

				--最新维护情况:
				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output,
							0:成功，1:该角色名已经登记过，9:未知错误
				@createTime smalldatetime output,
				@sysRoleID int output		--角色ID
	author:		卢苇
	CreateDate:	2011-9-5
	UpdateDate: modi by lw 2012-8-3增加角色级别类型名称、院部名称和使用单位名称
*/
create PROCEDURE addSysRole
	@sysRoleName varchar(50),		--角色中文名
	@sysRoleDesc nvarchar(100),		--角色描述
	@sysRoleType smallint,			--角色级别：由第100号代码字典定义：1—>通用的校级角色，2->通用的院部级角色，3->通用的单位角色，4->隶属于特定院部的角色,5->隶属于特定单位的角色
	@unitID varchar(12),			--所属单位编码
	@unitName nvarchar(30),			--所属单位名称:冗余设计。学校员工登记隶属学院名称,公司员工登记公司名称
	@createManID varchar(10),		--创建人工号

	@Ret		int output,			--0:成功，1:该角色名已经登记过，9:未知错误
	@createTime smalldatetime output,
	@sysRoleID int output		--角色ID
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查角色名是否唯一：
	declare @count as int
	set @count = (select count(*) from sysRole where sysRoleName = @sysRoleName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end
	--获取角色级别的名称/学院名称/使用单位名称:
	declare @sysRoleTypeName varchar(100),@clgName nvarchar(30), @uName nvarchar(30)
	set @sysRoleTypeName = isnull((select objDesc from codeDictionary where classCode = 100 and objCode = @sysRoleType),'')

	--取添加人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert sysRole(sysRoleName, sysRoleDesc, sysRoleType, sysRoleTypeName, unitID, unitName,
				--最新维护情况:
				modiManID, modiManName, modiTime, lockManID)
	values(@sysRoleName, @sysRoleDesc, @sysRoleType, @sysRoleTypeName, @unitID, @unitName,
				--最新维护情况:
				@createManID, @createManName, @createTime, @createManID)
	--获取ID:
	set @sysRoleID = (select sysRoleID from sysRole where sysRoleName = @sysRoleName)
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 
								'添加角色','系统根据' + @createManName + 
								'的要求添加了角色[' + @sysRoleName +']。')
GO

drop PROCEDURE checkSysRoleName
/*
	name:		checkSysRoleName
	function:	3.2.检查角色名是否唯一
	input: 
				@sysRoleName varchar(50),		--角色中文名
	output: 
				@Ret		int output
							0:唯一，>1：不唯一，-1：未知错误
	author:		卢苇
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE checkSysRoleName
	@sysRoleName varchar(50),		--角色中文名
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = -1
	set @Ret = (select count(*) from sysRole where sysRoleName = @sysRoleName)
GO


drop PROCEDURE querySysRoleLockMan
/*
	name:		querySysRoleLockMan
	function:	3.3.查询指定角色是否有人正在编辑
	input: 
				@sysRoleID smallint,	--角色ID
	output: 
				@Ret		int output	--操作成功标识
							0:成功，1：查询出错，可能是该ID的角色不存在
				@lockManID varchar(10) output		--当前正在编辑的人工号
	author:		卢苇
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE querySysRoleLockMan
	@sysRoleID smallint,		--角色ID
	@Ret		int output,		--操作成功标识
	@lockManID varchar(10) output--当前正在编辑的人工号
	WITH ENCRYPTION 
AS
	set @Ret = 1
	set @lockManID = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	set @Ret = 0
GO

drop PROCEDURE lockSysRole4Edit
/*
	name:		lockSysRole4Edit
	function:	3.4.锁定角色编辑，避免编辑冲突
	input: 
				@sysRoleID smallint,		--角色ID
				@lockManID varchar(10) output,	--锁定人，如果当前角色正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的角色不存在，2:要锁定的角色正在被别人编辑，9：未知错误
	author:		卢苇
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE lockSysRole4Edit
	@sysRoleID smallint,		--角色ID
	@lockManID varchar(10) output,--锁定人，如果当前角色正在被人占用编辑则返回该人的工号
	@Ret		int output	--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的会员是否存在
	declare @count as int
	set @count = (select count(*) from sysRole where sysRoleID = @sysRoleID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update sysRole
	set lockManID = @lockManID 
	where sysRoleID = @sysRoleID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName varchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')
	
	--取角色名：
	declare @sysRoleName varchar(50)
	set @sysRoleName = isnull((select sysRoleName from sysRole where sysRoleID = @sysRoleID),'')
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定角色编辑', '系统根据' + @lockManName
												+ '的要求锁定了角色['+ @sysRoleName +']为独占式编辑。')
GO

drop PROCEDURE unlockSysRoleEditor
/*
	name:		unlockSysRoleEditor
	function:	3.5.释放角色编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@sysRoleID smallint,		--角色ID
				@lockManID varchar(10) output,	--锁定人，如果当前角色正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE unlockSysRoleEditor
	@sysRoleID smallint,		--角色ID
	@lockManID varchar(10) output,	--锁定人，如果当前角色正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin 
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update sysRole set lockManID = '' where sysRoleID = @sysRoleID
	end
	else
	begin
		set @Ret = 0
		return
	end
	
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--取角色名：
	declare @sysRoleName varchar(50)
	set @sysRoleName = isnull((select sysRoleName from sysRole where sysRoleID = @sysRoleID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放角色编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了角色['+ @sysRoleName +']的编辑锁。')
GO

drop PROCEDURE updateSysRoleInfo
/*
	name:		updateSysRoleInfo
	function:	3.6.更新指定的角色的基本信息
	input: 
				@sysRoleID smallint,			--角色ID
				@sysRoleName varchar(50),		--角色中文名
				@sysRoleDesc nvarchar(100),		--角色描述
				@sysRoleType smallint,			--角色级别：由第100号代码字典定义：1—>通用的校级角色，2->通用的院部级角色，3->通用的单位角色，4->隶属于特定院部的角色,5->隶属于特定单位的角色
				@unitID varchar(12),			--所属单位编码
				@unitName nvarchar(30),			--所属单位名称:冗余设计。学校员工登记隶属学院名称,公司员工登记公司名称

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前角色正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的角色信息正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-9-5
	UpdateDate: modi by lw 2012-8-3增加角色级别类型名称、院部名称和使用单位名称
*/
create PROCEDURE updateSysRoleInfo
	@sysRoleID smallint,			--角色ID
	@sysRoleName varchar(50),		--角色中文名
	@sysRoleDesc nvarchar(100),		--角色描述
	@sysRoleType smallint,			--角色级别：由第100号代码字典定义：1—>通用的校级角色，2->通用的院部级角色，3->通用的单位角色，4->隶属于特定院部的角色,5->隶属于特定单位的角色
	@unitID varchar(12),			--所属单位编码
	@unitName nvarchar(30),			--所属单位名称:冗余设计。学校员工登记隶属学院名称,公司员工登记公司名称

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前角色正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--获取角色级别的名称/学院名称/使用单位名称:
	declare @sysRoleTypeName varchar(100)
	set @sysRoleTypeName = isnull((select objDesc from codeDictionary where classCode = 100 and objCode = @sysRoleType),'')

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--获取原角色名：
	declare @oldSysRoleName varchar(50)
	set @oldSysRoleName = ISNULL((select sysRoleName from sysRole where sysRoleID = @sysRoleID), '');

	set @updateTime = getdate()

	update sysRole
	set sysRoleName = @sysRoleName, sysRoleDesc = @sysRoleDesc, 
		sysRoleType = @sysRoleType, sysRoleTypeName = @sysRoleTypeName,
		unitID = @unitID, unitName = @unitName,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where sysRoleID = @sysRoleID
	set @Ret = 0

	--检查用户是否修改了角色名：
	declare @notes varchar(100)
	set @notes = '用户' + @modiManName + '更新了角色['+ @oldSysRoleName +']的基本信息。'
	if @oldSysRoleName <> @sysRoleName
	begin
		set @notes = @notes + '注意：角色名改为了：' + @oldSysRoleName + '。'
	end
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新角色的基本信息', @notes)
GO


drop PROCEDURE clearSysRoleRights
/*
	name:		clearSysRoleRights
	function:	3.7.清除角色的权限表
	input: 
				@sysRoleID smallint,			--角色ID

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前角色正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的角色信息正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE clearSysRoleRights
	@sysRoleID smallint,			--角色ID

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前角色正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	begin tran
		delete sysRoleRight
		where sysRoleID = @sysRoleID

		update sysRole
		set --维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where sysRoleID = @sysRoleID
	commit tran	
		
	set @Ret = 0

	--获取角色名：
	declare @sysRoleName varchar(50)
	set @sysRoleName = ISNULL((select sysRoleName from sysRole where sysRoleID = @sysRoleID), '');

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '清除角色的权限', '用户' + @modiManName + '清除了角色['+ @sysRoleName +']的权限。')
GO

drop PROCEDURE clearSysRoleDataOprs
/*
	name:		clearSysRoleDataOprs
	function:	3.7.1.清除角色的数据操作
	input: 
				@sysRoleID smallint,			--角色ID

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前角色正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的角色信息正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-9-24
	UpdateDate: 
*/
create PROCEDURE clearSysRoleDataOprs
	@sysRoleID smallint,			--角色ID

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前角色正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		delete sysRoleDataOpr
		where sysRoleID = @sysRoleID

		update sysRole
		set --维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where sysRoleID = @sysRoleID
	commit tran	
	
	set @Ret = 0

	--获取角色名：
	declare @sysRoleName varchar(50)
	set @sysRoleName = ISNULL((select sysRoleName from sysRole where sysRoleID = @sysRoleID), '');

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '清除角色的数据操作集', '用户' + @modiManName + '清除了角色['+ @sysRoleName +']的数据操作集。')
GO

drop PROCEDURE addSysRoleRight
/*
	name:		addSysRoleRight
	function:	3.8.添加角色的权限
				注意：这个过程没有维护主表的维护记录和登记工作日志
	input: 
				@sysRoleID smallint,		--角色ID
				@rightKind smallint,		--主键:分类
				@rightClass smallint,		--主键:子类
				@rightItem smallint,		--主键:小类

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前角色正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的角色信息正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-9-5
	UpdateDate: modi by lw 2012-8-4 根据表设计的变化修改接口
*/
create PROCEDURE addSysRoleRight
	@sysRoleID smallint,		--角色ID
	@rightKind smallint,		--主键:分类
	@rightClass smallint,		--主键:子类
	@rightItem smallint,		--主键:小类

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前角色正在被人占用编辑则返回该人的工号

	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--获取权限的描述性字段：
	declare @rightName nvarchar(30)	--权限名称:冗余字段
	declare @rightEName varchar(30)	--权限的英文名称名称 add by lw 2011-6-5
	declare @Url varchar(200)		--权限功能对应的Url add by lw 2011-6-5
	declare @rightType char(1)		--权限类别：F->管理功能，D->数据列表；
	declare @rightDesc nvarchar(100)--权限描述:冗余字段
	select @rightName = rightName, @rightEName = rightEName, @Url = Url, @rightType = rightType, @rightDesc = rightDesc
	from sysRight
	where rightKind = @rightKind and rightClass = @rightClass and rightItem = @rightItem

	insert sysRoleRight(sysRoleID, rightName, rightEName, Url, rightType,
						rightKind, rightClass, rightItem,
						rightDesc)
	values(@sysRoleID, @rightName, @rightEName, @Url, @rightType,
						@rightKind, @rightClass, @rightItem,
						@rightDesc)
	
	set @Ret = 0
GO
--测试：
select * from sysRoleRight where sysRoleID = 2
select * from sysRoleDataOpr where sysRoleID = 2

delete sysRoleRight where sysRoleID = 2

drop PROCEDURE addSysRoleDataOpr
/*
	name:		addSysRoleDataOpr
	function:	3.8.1.添加角色的数据操作
				注意：这个过程没有维护主表的维护记录和登记工作日志
	input: 
				@sysRoleID smallint,		--角色ID
				@rightKind smallint,		--主键:分类
				@rightClass smallint,		--主键:子类
				@rightItem smallint,		--主键:小类
				@oprType smallint,			--操作的类别：由第99号代码字典定义
				@oprName varchar(20),		--操作的名称
				@oprEName varchar(20),		--操作的英文名称
				@oprDesc varchar(100),		--操作的描述
				@oprPartSize int,			--系统权限（资源）的操作粒度：由第98号代码字典定义

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前角色正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的角色信息正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-9-24
	UpdateDate: modi by lw 2012-8-4 根据表设计的变化修改接口
				modi by lw 2012-8-8 增加操作排序字段处理
*/
create PROCEDURE addSysRoleDataOpr
	@sysRoleID smallint,		--角色ID
	@rightKind smallint,		--主键:分类
	@rightClass smallint,		--主键:子类
	@rightItem smallint,		--主键:小类
	@oprType smallint,			--操作的类别：由第99号代码字典定义
	@oprName varchar(20),		--操作的名称
	@oprEName varchar(20),		--操作的英文名称
	@oprDesc varchar(100),		--操作的描述
	@oprPartSize int,			--系统权限（资源）的操作粒度：由第98号代码字典定义

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前角色正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	insert sysRoleDataOpr(sysRoleID, sortNum, rightKind, rightClass, rightItem, 
						oprType, oprName, oprEName, oprDesc, oprPartSize)
	select @sysRoleID, sortNum, @rightKind, @rightClass, @rightItem, 
						@oprType, @oprName, @oprEName, @oprDesc, @oprPartSize
	from sysDataOpr
	where rightKind = @rightKind and rightClass = @rightClass and rightItem = @rightItem 
			and oprEName = @oprEName
	
	set @Ret = 0
GO


DROP PROCEDURE sysRoleSetOff
/*
	name:		sysRoleSetOff
	function:	3.9.注销指定的角色
	input: 
				@sysRoleID smallint,				--角色ID
				@setOffDate smalldatetime,			--注销日期

				--维护情况:
				@modiManID varchar(10) output,		--维护人，如果当前角色正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output				--操作成功标识
							0:成功，1：要更新的角色信息正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE sysRoleSetOff
	@sysRoleID smallint,				--角色ID
	@setOffDate smalldatetime,			--注销日期

	--维护情况:
	@modiManID varchar(10) output,		--维护人，如果当前角色正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update sysRole
	set isOff = 1, setOffDate = @setOffDate,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where sysRoleID = @sysRoleID
	set @Ret = 0

	--获取角色名：
	declare @sysRoleName varchar(50)
	set @sysRoleName = ISNULL((select sysRoleName from sysRole where sysRoleID = @sysRoleID), '');

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '注销角色', '用户' + @modiManName 
												+ '注销了角色['+ @sysRoleName +']。')
GO

drop PROCEDURE delSysRoleInfo
/*
	name:		delSysRoleInfo
	function:	3.10.删除指定的角色
	input: 
				@sysRoleID smallint,			--角色ID
				@delManID varchar(10) output,	--删除人，如果当前角色正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：该角色不存在，2:要删除的角色信息正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-9-5
	UpdateDate:
*/
create PROCEDURE delSysRoleInfo
	@sysRoleID smallint,			--角色ID
	@delManID varchar(10) output,	--删除人，如果当前角色正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的角色是否存在
	declare @count as int
	set @count=(select count(*) from sysRole where sysRoleID = @sysRoleID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--获取角色名：
	declare @sysRoleName varchar(50)
	set @sysRoleName = ISNULL((select sysRoleName from sysRole where sysRoleID = @sysRoleID), '');

	delete sysRole where sysRoleID = @sysRoleID
	--权限表自动跟随删除！
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除角色', '用户' + @delManName
												+ '删除了角色['+ @sysRoleName +']的信息。')

GO
--测试：

DROP PROCEDURE sysRoleSetActive
/*
	name:		sysRoleSetActive
	function:	3.11.激活指定的角色
	input: 
				@sysRoleID smallint,			--角色ID

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前角色正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要激活的角色不存在，2：要激活的角色正被别人锁定编辑，9：未知错误
	author:		卢苇
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE sysRoleSetActive
	@sysRoleID smallint,				--角色ID

	--维护情况:
	@modiManID varchar(10) output,		--维护人，如果当前角色正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的角色是否存在
	declare @count as int
	set @count=(select count(*) from sysRole where sysRoleID = @sysRoleID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from sysRole where sysRoleID = @sysRoleID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update sysRole
	set isOff = 0, setOffDate = null,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where sysRoleID = @sysRoleID
	set @Ret = 0

	--获取角色名：
	declare @sysRoleName varchar(50)
	set @sysRoleName = ISNULL((select sysRoleName from sysRole where sysRoleID = @sysRoleID), '');

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '激活角色', '用户' + @modiManName 
												+ '激活了角色['+ @sysRoleName +']。')
GO

use epdc2
select distinct actions from workNote
--4.工作日志表
truncate TABLE [dbo].[workNote]
drop TABLE [dbo].[workNote]
alter TABLE [dbo].[workNote] alter column workNoteID bigint
CREATE TABLE [dbo].[workNote] (
	userID varchar(10) not null,								--用户身份ID（工号）
	userName nvarchar(30) NOT NULL ,							--用户名
	actionTime smalldatetime NOT NULL ,							--活动时间
	actions nvarchar(10) COLLATE Chinese_PRC_CI_AS NOT NULL ,	--活动分类
	actionObject nvarchar(500) COLLATE Chinese_PRC_CI_AS NULL ,	--活动对象描述
	workNoteID bigint IDENTITY (1, 1) NOT NULL 
CONSTRAINT [PK_workNote] PRIMARY KEY CLUSTERED 
(
	[workNoteID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_workNote] ON [dbo].[workNote] 
(
	[userID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_workNote_1] ON [dbo].[workNote] 
(
	[actions] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_workNote_2] ON [dbo].[workNote] 
(
	[actionTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

drop TABLE [dbo].[workNoteBak]
alter TABLE [dbo].[workNoteBak] alter column workNoteID bigint
CREATE TABLE [dbo].[workNoteBak] (
	userID varchar(10) not null,								--用户身份ID（工号）
	userName nvarchar(30) NOT NULL ,							--用户名
	actionTime smalldatetime NOT NULL ,							--活动时间
	actions nvarchar(10) COLLATE Chinese_PRC_CI_AS NOT NULL ,	--活动分类
	actionObject nvarchar(500) COLLATE Chinese_PRC_CI_AS NULL ,	--活动对象描述
	workNoteID bigint NOT NULL 
CONSTRAINT [PK_workNoteBak] PRIMARY KEY CLUSTERED 
(
	[workNoteID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_workNoteBak] ON [dbo].[workNoteBak] 
(
	[userID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_workNoteBak_1] ON [dbo].[workNoteBak] 
(
	[actions] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_workNoteBak_2] ON [dbo].[workNoteBak] 
(
	[actionTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


select * from workNote
--获取活动分类的语句：
select * from workNote


select * from sysUserRight

drop PROCEDURE addWorkNote
/*
	name:		addWorkNote
	function:	4.1.登记工作日志
				注：这是一个提供给上层代码成批操作数据库的时候最后登记日志的函数
	input: 
				@modiManID varchar(10),			--维护人(登记人)
				@actions nvarchar(10),			--活动分类
				@actionObject nvarchar(500),	--活动对象描述
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2011-9-5
	UpdateDate: 
*/
create PROCEDURE addWorkNote
	--维护情况:
	@modiManID varchar(10),			--维护人(登记人)
	@actions nvarchar(10),			--活动分类
	@actionObject nvarchar(500),	--活动对象描述

	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	--登记时间
	declare @updateTime smalldatetime
	set @updateTime = getdate()
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, @actions, @actionObject)
	set @Ret = 0
GO

drop PROCEDURE delWorkNote
/*
	name:		delWorkNote
	function:	4.2.删除指定范围的工作日志
	input: 
				@where varchar(460),			--指定的范围
				@modiManID varchar(10),			--维护人(登记人)
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2011-10-15
	UpdateDate: 
*/
create PROCEDURE delWorkNote
	--维护情况:
	@where varchar(460),			--指定的范围
	@modiManID varchar(10),			--维护人(登记人)
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	--登记时间
	declare @updateTime smalldatetime
	set @updateTime = getdate()
	
	begin tran
		--删除前强制备份工作日志：
		insert workNoteBak
		select * from workNote where workNoteID not in (select workNoteID from workNoteBak)
		if @@ERROR <> 0 
		begin
			rollback tran
			return
		end    
		
		--删除日志：
		exec(N'delete workNote ' + @where)
		if @@ERROR <> 0 
		begin
			rollback tran
			return
		end    
	commit tran
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '删除工作日志', '用户' + @modiManName
												+ '删除了范围为['+ @where +']的工作日志。')
	set @Ret = 0
GO
--测试：
declare @Ret int
declare @where varchar(460)
set @where = 'where actions=' + char(39) + '删除工作日志' + char(39)
exec dbo.delWorkNote @where, '0000000000', @ret output
select @Ret
select * from workNoteBak
select * from workNote


use epdc2
select * from sysUserRole

insert sysUserRole
select jobNumber, sysUserName, 1, '超级用户', 1 from userInfo



