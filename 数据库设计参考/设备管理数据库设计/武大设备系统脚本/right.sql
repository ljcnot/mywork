use epdc211
/*
	武大设备管理系统-运维类表和存储过程设计：包括权限管理和工作日志
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
drop table sysRight
CREATE TABLE [dbo].[sysRight]
(
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
--添加权限：by lw 2012-10-13
insert sysRight(rightName, rightEName,Url, rightType, rightKind, rightClass,rightItem,canUse,rightDesc )
select '闲置设备','overageEqpList','overView/overageEqpList.html', rightType, rightKind, 5,rightItem,canUse,'可以查询、导出闲置设备情况的权利。'
from sysRight
where rightKind = 4 and rightClass = 2

insert sysRight(rightName, rightEName,Url, rightType, rightKind, rightClass,rightItem,canUse,rightDesc )
select '我的设备','myEqpList','overView/myEqpList.html', rightType, rightKind, 6,rightItem,canUse,'查询我的全部设备的权利。'
from sysRight
where rightKind = 4 and rightClass = 2


use epdc211
select partSize, objDesc partSizeName, * from sysRightPartSize s left join codeDictionary cd on s.partSize = cd.objCode and cd.classCode = 98


select * from sysRightPartSize
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
--添加权限：by lw 2012-10-13
--闲置设备：
insert sysRightPartSize(rightKind,rightClass,rightItem,partSize)
select rightKind,5,rightItem,partSize from sysRightPartSize where rightKind = 4 and rightClass = 2

insert sysDataOpr(sortNum, rightKind,rightClass,rightItem,oprType,oprName,oprEName,oprDesc)
select sortNum, rightKind,5,rightItem,oprType,oprName,oprEName,oprDesc from sysDataOpr where rightKind = 4 and rightClass = 2
--我的设备：
insert sysRightPartSize(rightKind,rightClass,rightItem,partSize)
values(4,6,0,1)
select * from sysRightPartSize where rightKind = 4 and rightClass = 6
insert sysDataOpr(sortNum, rightKind,rightClass,rightItem,oprType,oprName,oprEName,oprDesc)
select sortNum, rightKind,6,rightItem,oprType,oprName,oprEName,oprDesc from sysDataOpr where rightKind = 4 and rightClass = 2
select * from sysDataOpr where rightKind = 4 and rightClass = 6


--报废申请单和报废单没有使用单位这个颗粒度：add by lw 2012-10-19
select rightKind,rightClass,rightItem, partSize from [sysRightPartSize] where rightKind = 3 and rightClass = 2 and rightItem=0 and partSize=2
delete from [sysRightPartSize] where rightKind = 3 and rightClass = 2 and rightItem=0 and partSize=2

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


--增加系统权限：add by lw 2013-10-30
select * from sysDataOpr where rightKind=3 and rightClass=6 order by sortNum
update sysDataOpr 
set sortNum = sortNum+1
where rightKind=3 and rightClass=6 and sortNum>6

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(7,3,6,0,2,'展期','cmdExceeding','重新定义指定设备清查单的预计结束日期')

update sysDataOpr 
set sortNum = sortNum+1
where rightKind=3 and rightClass=6 and sortNum>4

insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(5,3,6,0,1,'认领设备','cmdCheckMyEqps','显示设备清查单中需要我认领的设备')

update sysDataOpr 
set oprName='查看设备'
where rightKind=3 and rightClass=6 and oprEName='cmdCheckEqps'
update sysDataOpr 
set oprName='认领设备'
where rightKind=3 and rightClass=6 and oprEName='cmdCheckMyEqps'



--添加权限：by lw 2012-10-13
insert sysDataOpr(rightKind,rightClass,rightItem,oprType, oprName, oprEName,oprDesc)
select rightKind,5,rightItem,oprType, oprName, oprEName,oprDesc from [sysDataOpr] where rightKind = 4 and rightClass = 2

--增加系统权限：add by lw 2012-10-13
delete sysDataOpr
where sortNum=13 and rightKind =3 and  rightClass = 1 and rightItem=0
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(13,3,1,0,4,'更正','cmdChange','更正设备的一般情况，金额与保管单位不能更正')
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(14,3,1,0,4,'审核','cmdAudit','审核生效设备一般情况更正的信息')
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(15,3,1,0,2,'状态','cmdStatus','设定设备的状态')
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(16,3,1,0,1,'被锁设备','cmdLockList','查询全部被锁定的设备')
insert sysDataOpr(sortNum, rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc)
values(17,3,1,0,1,'更正历史','cmdChangeHistory','查询设备的更正历史情况')

select * from sysDataOpr where rightKind=3 order by rightKind, rightclass,sortNum

insert sysDataOpr(sortNum, rightKind,rightClass,rightItem,oprType,oprName,oprEName,oprDesc)
select sortNum, rightKind,5,rightItem,oprType,oprName,oprEName,oprDesc from sysDataOpr where rightKind = 4 and rightClass = 2

--报废申请单和报废单没有使用单位这个颗粒度：add by lw 2012-10-19
select rightKind,rightClass,rightItem, partSize from [sysRightPartSize] where rightKind = 3 and rightClass = 2 and rightItem=0 and partSize=2
delete from [sysRightPartSize] where rightKind = 3 and rightClass = 2 and rightItem=0 and partSize=2

--发现一个错误的操作，应删除：by lw 2012-10-13
select * from sysDataOpr
where rightKind = 2 and rightClass = 1 and oprEName='cmdCancelVerify'
delete sysDataOpr
where rightKind = 2 and rightClass = 1 and oprEName='cmdCancelVerify'

--获取系统所有的操作：
select distinct oprType, oprName, oprEName, oprDesc 
from sysDataOpr

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
drop TABLE [dbo].[sysRole]
CREATE TABLE [dbo].[sysRole] 
(
	sysRoleID smallint IDENTITY(1,1) NOT NULL,	--角色ID
	sysRoleName varchar(50) null,				--角色中文名
	sysRoleDesc nvarchar(100) null,				--角色描述
	--add by lw 2011-9-4增加角色分级：
	sysRoleType smallint default(1),			--角色级别：由第100号代码字典定义：1—>通用的校级角色，2->通用的院部级角色，3->通用的单位角色，4->隶属于特定院部的角色,5->隶属于特定单位的角色
	sysRoleTypeName varchar(100) default('通用的校级角色'),	--角色级别的名称：冗余设计 add by lw 2012-8-3
	--特定区域的角色所在院部或单位
	clgCode char(3) null,						--学院代码
	clgName nvarchar(30) null,					--学院名称：冗余字段，但是可以解释历史数据	add by lw 2012-8-3
	uCode varchar(8) null,						--使用单位代码
	uName nvarchar(30) null,					--使用单位名称:冗余字段，但是可以保留历史名称add by lw 2012-8-3
	
	isOff int default(0),				--是否注销：0->未注销，1->已注销
	setOffDate smalldatetime,			--注销日期

	--创建人：add by lw 2012-10-29为了保持操作的范围——个人的一致性增加的字段
	createManID varchar(10) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号:modi by lw 2012-11-06放开非空验证
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


--获取指定用户的权限：
select rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, 
canUse, max(canQuery) canQuery, max(canEdit) canEdit, max(canOutput) canOutput, max(canCheck) canCheck, rightDesc 
from sysRoleRight
where sysRoleID in (select sysRoleID from sysUserRole where jobNumber = '0000000000')
group by rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse, rightDesc 
order by rightKind, rightClass, rightItem

--获取指定用户的权限操作：
select rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc, max(oprLocal) oprLocal
from sysRoleDataOpr
where sysRoleID in (select sysRoleID from sysUserRole where jobNumber = '0000000000')
group by rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc

select * from [sysRoleDataOpr]
where rightKind = 3 and rightClass = 2
--2.2.角色权限操作表：
alter TABLE [dbo].[sysRoleDataOpr] add oprPartSize int	--系统权限（资源）的操作粒度：由第98号代码字典定义
update [dbo].[sysRoleDataOpr]
set oprPartSize = oprLocal

alter TABLE [dbo].[sysRoleDataOpr] add	sortNum smallint null				--排序号码
update [dbo].[sysRoleDataOpr]
set sortNum = 0

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

--更新数据：2011-10-16
select * from sysRoleDataOpr where sysRoleID = 1

delete sysRoleDataOpr  where sysRoleID = 1 and rightKind = 3 and rightClass = 3 and oprName='取消复核'

insert sysRoleDataOpr(sysRoleID, rightKind, rightClass, rightItem, 
		oprType, oprName, oprEName, oprDesc, oprLocal)
values(1, 3,3,0,4,'取消复核','cmdCancelCheck','取消单据的复核执行', 9)

insert sysRoleDataOpr(sysRoleID, rightKind, rightClass, rightItem, 
		oprType, oprName, oprEName, oprDesc, oprLocal)
values(7,6,0,2,'回复','cmdAnswer','回复指定的用户意见',9)

select * from sysRoleDataOpr where sysRoleID = 1
select * from sysRole where sysRoleID = 1
select * from sysRoleRight where sysRoleID = 1

select * from sysRole
select * from wd.dbo.sysRole
use epdc211
select * from userInfo where sysUserName='axs'
select * from sysUserRole where jobNumber = '00011680'
select * from sysRoleDataOpr where rightKind= '3' and rightClass='1' and sysRoleID in (4,5)
select rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc, max(oprPartSize) oprPartSize
from sysRoleDataOpr
where rightKind= '3' and rightClass='1' and sysRoleID in (4,5)
group by rightKind, rightClass, rightItem, sortNum, oprType, oprName, oprEName, oprDesc


select rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, rightDesc  
from sysRoleRight 
where sysRoleID in (select sysRoleID from sysUserRole where jobNumber = '00200977') 
group by rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, rightDesc 
order by rightKind, rightClass, rightItem; 
select rightKind, rightClass, rightItem, oprType, oprName, oprEName, oprDesc, max(oprPartSize) oprPartSize 
from sysRoleDataOpr 
where sysRoleID in (select sysRoleID from sysUserRole where jobNumber = '00200977') 
group by rightKind, rightClass, rightItem, sortNum, oprType, oprName, oprEName, oprDesc 
order by rightKind, rightClass, rightItem, sortNum, oprType


select * from sysRolePartSize where rightKind= '3' and rightClass='1' and sysRoleID in (4,5)
select * from sysRoleRight
--3.用户角色表：
drop table sysUserRole
CREATE TABLE [dbo].[sysUserRole] 
(
	jobNumber varchar(10) not null,		--外键:工号
	sysUserName varchar(30) not null,	--用户名:冗余字段
	sysRoleID smallint not null,		--外键:角色ID
	sysRoleName varchar(50) null,		--角色中文名:冗余字段
	sysRoleType smallint not null		--角色级别:冗余字段,由第100号代码字典定义：1—>通用的校级角色，2->通用的院部级角色，3->通用的单位角色，4->隶属于特定院部的角色,5->隶属于特定单位的角色
 CONSTRAINT [PK_sysUserRole] PRIMARY KEY CLUSTERED 
(
	[jobNumber] ASC,
	[sysRoleID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

--定义外键：与用户表关联的外键
ALTER TABLE [dbo].[sysUserRole]  WITH CHECK ADD  CONSTRAINT [FK_sysUserRole_userInfo] FOREIGN KEY([jobNumber])
REFERENCES [dbo].[userInfo] ([jobNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysUserRole] CHECK CONSTRAINT [FK_sysUserRole_userInfo]
go

--定义外键：与系统角色表关联的外键
ALTER TABLE [dbo].[sysUserRole]  WITH CHECK ADD  CONSTRAINT [FK_sysUserRole_sysRole] FOREIGN KEY([sysRoleID])
REFERENCES [dbo].[sysRole] ([sysRoleID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysUserRole] CHECK CONSTRAINT [FK_sysUserRole_sysRole]
go

select * from sysRole
drop PROCEDURE addSysRole
/*
	name:		addSysRole
	function:	3.1.添加角色
				注意：这个存储过程角色名的唯一性！并锁定为独占式编辑！
	input: 
				@sysRoleName varchar(50),		--角色中文名
				@sysRoleDesc nvarchar(100),		--角色描述
				@sysRoleType smallint,			--角色级别：由第100号代码字典定义：1—>通用的校级角色，2->通用的院部级角色，3->通用的单位角色，4->隶属于特定院部的角色,5->隶属于特定单位的角色
				@clgCode char(3),				--学院代码
				@uCode varchar(8),				--使用单位代码：老数据中有空值，需要用户确认是否允许空值！！！不允许.modi by lw 2011-2-11根据设备处要求延长编码长度！
	

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
				modi by lw 2012-10-29增加创建人处理
*/
create PROCEDURE addSysRole
	@sysRoleName varchar(50),		--角色中文名
	@sysRoleDesc nvarchar(100),		--角色描述
	@sysRoleType smallint,			--角色级别：由第100号代码字典定义：1—>通用的校级角色，2->通用的院部级角色，3->通用的单位角色，4->隶属于特定院部的角色,5->隶属于特定单位的角色
	@clgCode char(3),				--学院代码
	@uCode varchar(8),				--使用单位代码
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
	if (@clgCode <> '')
		set @clgName = (select clgName from college where clgCode = @clgCode)
	else
		set @clgName = ''
	if (@uCode <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	else
		set @uName = ''

	--取添加人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert sysRole(sysRoleName, sysRoleDesc, sysRoleType, sysRoleTypeName, clgCode, clgName, uCode, uName,
				--创建情况:
				createManID, createManName, createTime, lockManID)
	values(@sysRoleName, @sysRoleDesc, @sysRoleType, @sysRoleTypeName, @clgCode, @clgName, @uCode, @uName,
				--创建情况:
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
				@clgCode char(3),				--学院代码
				@uCode varchar(8),				--使用单位代码：老数据中有空值，需要用户确认是否允许空值！！！不允许.modi by lw 2011-2-11根据设备处要求延长编码长度！

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
	@clgCode char(3),				--学院代码
	@uCode varchar(8),				--使用单位代码：老数据中有空值，需要用户确认是否允许空值！！！不允许.modi by lw 2011-2-11根据设备处要求延长编码长度！

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
	declare @sysRoleTypeName varchar(100),@clgName nvarchar(30), @uName nvarchar(30)
	set @sysRoleTypeName = isnull((select objDesc from codeDictionary where classCode = 100 and objCode = @sysRoleType),'')
	if (@clgCode <> '')
		set @clgName = (select clgName from college where clgCode = @clgCode)
	else
		set @clgName = ''
	if (@uCode <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	else
		set @uName = ''

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
		clgCode = @clgCode, clgName = @clgName, uCode = @uCode, uName = @uName,
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

use epdc2
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
--set @where = 'where actions=' + char(39) + '删除工作日志' + char(39)
exec dbo.delWorkNote @where, '0000000000', @ret output
select @Ret
select * from workNoteBak
select * from workNote


use epdc2
select * from sysUserRole

insert sysUserRole
select jobNumber, sysUserName, 1, '超级用户', 1 from userInfo



