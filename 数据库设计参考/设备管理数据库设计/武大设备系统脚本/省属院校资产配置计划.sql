alter TABLE [dbo].[plan] add othermana numeric(18,2) NULL			--纳入预算管理的非税收入拨款 
drop TABLE [dbo].[plan]
CREATE TABLE [dbo].[plan](
	OrganCode varchar(15) default('42000186-X'),	--组织代码
	serialNum int NULL,						--序号
	purchseApplicationID varchar(18) null,	--单号
	[depart] [nvarchar](255) NULL,			--部门
	projectName [nvarchar](100) NULL,		--项目名称
	AssetClassCode varchar(10) NULL,		--财政部分类代码
	AssetClassName nvarchar(100) NULL,		--财政部分类名称
	Unitage nvarchar(50) null,				--计量单位
	AssetName nvarchar(100) NULL,			--资产名称
	Amount numeric(18,2) NULL,				--数量
	[Sum] numeric(18,2) NULL,				--金额
	Finance numeric(18,2) NULL,				--财政拨款（小计）
	othermana numeric(18,2) NULL,			--纳入预算管理的非税收入拨款 


) ON [PRIMARY]

GO

select * from [plan]
order by serialNum
--赋单号：
update [plan]
set purchseApplicationID='201211020001'

update [plan]
set othermana=Finance
update [plan]
set Finance=null

--生成计量单位：
update [plan]
set AssetClassName = a.aTypeName, Unitage = a.Unitage
from [plan] p inner join aTypeCodeList a on p.AssetClassCode= a.aTypeCode



create table aTypeCodeList
(
	aTypeCode varchar(7) null,	--代码
	aTypeName nvarchar(100) null,--名称
	Unitage nvarchar(50) null,	--计量单位
	notes nvarchar(300) null,	--说 明
)

select * from aTypeCodeList
where aTypeCode is null

update aTypeCodeList
set aTypeName = LTRIM(rtrim(aTypeName))




exec sp_addlinkedserver
     @server = MPS,--Linkedserver的名称
     @provider = 'Microsoft.ACE.OLEDB.12.0',--使用JET 4.0不能用，必须用这个
     @srvproduct = 'ACCESS 2000',
     @datasrc = 'F:\lw\软件项目\开发中\武大设备管理信息系统\省属院校关联系统\湖北省行政事业单位资产管理软件\data\hbgydx\hbgydx_V7.mdb'  --对应的数据库全路径GO
go

EXEC sp_addlinkedsrvlogin 
     @rmtsrvname = N'MPS',
     @useself = N'FALSE',
     @locallogin = NULL, 
     @rmtuser = N'Admin', --如果Access中没有建用户则默认为Admin,密码为空
     @rmtpassword = NULL
GO


--导入数据：
select OrganCode, SerialNumber, purchseApplicationID, projectName, AssetClassCode, AssetClassName,
	Unitage, AssetName, Amount, [Sum],othermanagementuntaxation
from   OPENDATASOURCE( 'Microsoft.ACE.OLEDB.12.0',   
'Data Source=F:\lw\软件项目\开发中\武大设备管理信息系统\省属院校关联系统\湖北省行政事业单位资产管理软件\data\hbgydx\hbgydx_V7.mdb;User ID=Admin;Password=')...PurchaseApplicationDetail


insert OPENDATASOURCE( 'Microsoft.ACE.OLEDB.12.0',   
'Data Source=F:\lw\软件项目\开发中\武大设备管理信息系统\省属院校关联系统\湖北省行政事业单位资产管理软件\data\hbgydx\hbgydx_V7.mdb;User ID=Admin;Password=')...PurchaseApplicationDetail
(OrganCode, SerialNumber, purchseApplicationID, projectName, AssetClassCode, AssetClassName,
	Unitage, AssetName, Amount, [Sum],othermanagementuntaxation)
select OrganCode, serialNum, purchseApplicationID, projectName, AssetClassCode, AssetClassName,
	Unitage, AssetName, Amount, [Sum], othermana
from [plan]


delete from OPENDATASOURCE( 'Microsoft.ACE.OLEDB.12.0',   
'Data Source=F:\lw\软件项目\开发中\武大设备管理信息系统\省属院校关联系统\湖北省行政事业单位资产管理软件\data\hbgydx\hbgydx_V7.mdb;User ID=Admin;Password=')...PurchaseApplicationDetail
