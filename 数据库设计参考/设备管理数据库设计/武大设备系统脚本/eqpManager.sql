use epdc211
/*
	武大设备管理信息系统-设备管理
	author:		卢苇
	CreateDate:	2010-11-24
	UpdateDate: 
*/
--1.equipmentList（设备表）：
--特殊设备要增加字段，做成派生结构
--查询锁定编辑或有长事务的设备
select e.eCode, e.eName, e.lockManID, u.cName lockMan, u.telNum, u.mobileNum, e.lock4LongTime,
	case e.lock4LongTime when 0 then '' 
	when 2 then '设备调拨单' when 3 then '设备报废单' 
	else '设备清查单' 
	end invoiceType, e.lInvoiceNum
from equipmentList e left join userInfo u on e.lockManID = u.jobNumber 
where isnull(e.lockManID,'')<>'' or e.lock4LongTime <> 0

update equipmentList
set unit = g.unit
from eqpAcceptInfo e left join GBT14885 g on e.aTypeCode = g.aTypeCode

update equipmentList
set obtainMode = 1,purchaseMode=2
select eCode,'自制' as status 
use epdc211

--自制设备：
update equipmentList
set obtainMode = 7
where notes like '%自制%'
		or factory like '%武汉大学%'
		or eModel like '%自制%'
		or eFormat like '%自制%'
--捐赠设备：
update equipmentList
set obtainMode = 4
where fCode = '6'

select * from equipmentList

alter table equipmentList add lock4LongTime smallint	--长事务锁：add by lw 2012-7-28，因为设备清查时需要叠加锁，所以改成整形！modi by lw 2013-5-27
ALTER TABLE [dbo].[equipmentList] ADD  DEFAULT (0) FOR [lock4LongTime]
update equipmentList
set lock4LongTime=0
where lock4LongTime is null

alter table equipmentList add bakLInvoiceNum varchar(30) null	--备份的长事务锁锁定的票据号：因为设备清查是叠加事务锁，所以要备份 add by lw 2013-5-27

drop table equipmentList
CREATE TABLE equipmentList(
	eCode char(8) not null,			--主键：设备编号,使用特殊的号码发生器产生
											--2位年份代码+6位流水号，号码预先生成
											--使用手工输入号码，自动检测号码是否重号
	acceptApplyID char(12) null,	--对应的验收单号
	eName nvarchar(30) not null,	--设备名称:需要用户确认是否允许空值！！！不允许！！
	eModel nvarchar(20) not null,	--设备型号
	eFormat nvarchar(30) not null,	--设备规格：根据教育部要求延长字段长度为20位 modi by lw 2011-1-26
	unit nvarchar(10) null,			--计量单位：add by lw 2012-10-5该单位从GBT14885表中获取
	cCode char(3) not null,			--国家代码：需要用户确认是否允许空值！！！不允许！！
	factory	nvarchar(20) null,		--生产厂家
	makeDate smalldatetime null,	--出厂日期，在界面上拦截
	serialNumber nvarchar(20) null,	--出厂编号
	business nvarchar(20) null,		--销售单位
	buyDate smalldatetime null,		--购置日期，不允许空值
	annexName nvarchar(20) null,	--附件名称	add by lw 2010-12-4与验收单一致化
	annexCode nvarchar(20) null,	--随机附件编号
	annexAmount	numeric(12, 2) null,--附件金额（就是附件单价）修改类型，约束小数点 modi by lw 2012-10-9

	eTypeCode char(8) not null,		--分类编号（教）最后4位不允许同时为“0”
	eTypeName nvarchar(30) not null,--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
	aTypeCode varchar(7) not null,	--分类编号（财）分类编号（财）=f（分类编号（数））使用映射表
									--根据GB/T 14885-2010规定将编码延长到7位modi by lw 2012-2-23

	fCode char(2) not null,			--经费来源代码
	aCode char(2) null,				--使用方向代码：老数据中有空值，需要用户确认是否允许空值！！！不允许！
	price numeric(12, 2) null,		--单价，>0 修改类型，约束小数点 modi by lw 2012-10-9
	totalAmount numeric(12, 2) null,--总价, >0（单价+附件价格）修改类型，约束小数点 modi by lw 2012-10-9
	clgCode char(3) not null,		--学院代码
	uCode varchar(8) null,			--使用单位代码：老数据中有空值，需要用户确认是否允许空值！！！不允许.modi by lw 2011-2-11根据设备处要求延长编码长度！
	keeperID varchar(10) null,		--保管人工号（设备管理员）,add by lw 2011-10-12计划增加设备的派生信息，如果管理员登记了，派生信息只能由管理员填写
	keeper nvarchar(30) null,		--保管人
	eqpLocate nvarchar(100) null,	--设备所在地址:设备所在地add by lw 2012-5-22增加设备认领功能

	notes nvarchar(50) null,		--备注
	acceptDate smalldatetime null,	--验收日期
	oprManID varchar(10) null,		--经办人工号 add by lw 2012-8-9
	oprMan nvarchar(30) null,		--经办人
	acceptManID varchar(10) null,	--验收人工号,add by lw 2011-2-19
	acceptMan nvarchar(30) null,	--验收人
	
	barCode varchar(30) null,		--一维条码：add by lw 2012-11-18
	--计划废止：
	--scrapFlag int default(0),		--是否报废:0->否，1->是；这是申请报废字段，
									--本字段改成现状码：0-在用，1-待修，2-待报废，3-已申请报废 4-已报废，
									--前2种状态院系设备保管员可以直接修改，状态2由申请报废单设置，状态4由复核设置，状态3预留扩展
	curEqpStatus char(1) not null,	--根据报表的规定重新定义设备的现状代码含义：本字段由第2号代码字典定义 modi by lw 2011-1-26
									--1：在用，指正在使用的仪器设备；
									--2：多余，指具有使用价值而未使用的仪器设备；
									--3：待修，指待修或正在修理的仪器设备；
									--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
									--5：丢失，
									--6：报废，
									--7：调出，
									--8：降档，指经学校批准允许降档次使用、管理的仪器设备；
									--9：其他，现状不详的仪器设备。
	scrapDate smalldatetime null,	--报废日期，原[ISDORE] [bit] NOT NULL,是已经确认报废，现改为使用报废日期
	--add by lw 2011-05-16,因为筛选中的条件构造比较麻烦，所以增加该字段
	--注意：相应修改了报废的存储过程，在处理原始数据的时候需要处理
	scrapNum char(12) null,		--对应的设备报废单号

	lock4LongTime smallint default(0),	--长事务锁：add by lw 2012-7-28，因为设备清查时需要叠加锁，所以改成整形！modi by lw 2013-5-27
										--主要是为清查等功能锁定设备，防止在锁定期间内设备的添加附件、调拨或报废
											--'0'->未锁定
											--'1'->清查锁定,修改成叠加锁"10"
											--'2'->调拨锁定
											--'3'->报废锁定
											--'4'->验收单锁定（添加附件验收单锁定）：
													--因为添加附件允许取消审核并修改生成的验收单，所以要锁定
											--'5'->设备信息更正申请锁定 add by lw 2012-19-13
	lInvoiceNum varchar(30) null,		--长事务锁锁定的票据号
	bakLInvoiceNum varchar(30) null,	--备份的长事务锁锁定的票据号：因为设备清查是叠加事务锁，所以要备份 add by lw 2013-5-27
	
	obtainMode int null,				--取得方式：由第11号代码字典定义，add by lw 2012-10-1
	purchaseMode int null,				--采购组织形式：由第18号代码字典定义，add by lw 2012-10-1
	
	ZCBH varchar(20) null,			--资产编号:与资产管理系统连接的编号。这是与省厅系统连接的编号！add by lw 2012-12-25

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_equipmentList] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--院部索引：
CREATE NONCLUSTERED INDEX [IX_equipmentList] ON [dbo].[equipmentList] 
(
	[clgCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--院部、使用单位索引：
CREATE NONCLUSTERED INDEX [IX_equipmentList0] ON [dbo].[equipmentList] 
(
	[clgCode] ASC,
	[uCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--教育部分类代码索引：
CREATE NONCLUSTERED INDEX [IX_equipmentList1] ON [dbo].[equipmentList] 
(
	[eTypeCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--财政部分类代码索引：
CREATE NONCLUSTERED INDEX [IX_equipmentList2] ON [dbo].[equipmentList] 
(
	[aTypeCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--经费来源索引：
CREATE NONCLUSTERED INDEX [IX_equipmentList3] ON [dbo].[equipmentList] 
(
	[fCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--使用方向索引：
CREATE NONCLUSTERED INDEX [IX_equipmentList4] ON [dbo].[equipmentList] 
(
	[aCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--销售单位索引：
CREATE NONCLUSTERED INDEX [IX_equipmentList5] ON [dbo].[equipmentList] 
(
	[business] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
--生产厂家索引：
CREATE NONCLUSTERED INDEX [IX_equipmentList6] ON [dbo].[equipmentList] 
(
	[factory] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


select * from equipmentAnnex order by buyDate desc
--2.equipmentAnnex（设备附件）：需要用户确认设备附件是否可以与设备分开购置！！！
drop table equipmentAnnex
CREATE TABLE equipmentAnnex(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号
	acceptApplyID char(12) null,		--对应的验收单号	--因为附件可以独立验收，所以增加如下字段：add by lw 2011-4-5
	eCode char(8) not null,				--外键：设备编号
	annexName nvarchar(20) null,		--附件名称
	annexFormat nvarchar(20) null,		--型号规格

	--因为附件可以独立验收，所以增加如下字段：add by lw 2011-4-5
	cCode char(3) not null,				--国家代码：add by lw 2011-10-26
	fCode char(2) not null,				--经费来源代码：可以与主设备的经费来源不同！如果以设备的经费来源统计，则忽略附件的经费来源。
	factory	nvarchar(20) null,			--生产厂家
	makeDate smalldatetime null,		--出厂日期
	business nvarchar(20) null,			--销售单位
	buyDate smalldatetime null,			--购置日期
	-----------------------------------------------
	
	quantity int null,					--数量：好像这个字段没有存在的必要！
	price numeric(12, 2) null,			--单价：好像这个字段也没有存在的必要 修改类型，约束小数点 modi by lw 2012-10-9
	totalAmount numeric(12, 2) null,	--总价：修改类型，约束小数点 modi by lw 2012-10-9

	oprManID varchar(10) null,			--经办人工号 add by lw 2012-8-12
	oprMan nvarchar(30) null,			--经办人
	acceptMan nvarchar(30) null,		--验收人
	acceptManID varchar(10) null,		--验收人工号:add by lw 2011-10-26
/*	以下字段作废，因为附件编辑的时候使用的是主设备的锁 del by lw 2012-10-5
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
*/	
 CONSTRAINT [PK_equipmentAnnex] PRIMARY KEY CLUSTERED 
(
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--外键：
ALTER TABLE [dbo].[equipmentAnnex] WITH CHECK ADD CONSTRAINT [FK_equipmentAnnex_equipmentList] FOREIGN KEY([eCode])
REFERENCES [dbo].[equipmentList] ([eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[equipmentAnnex] CHECK CONSTRAINT [FK_equipmentAnnex_equipmentList]
GO

CREATE NONCLUSTERED INDEX [IX_equipmentList] ON [dbo].[equipmentAnnex]
(
	[business] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--导入数据：
insert equipmentAnnex(acceptApplyID, eCode, annexName, annexFormat,
	cCode, fCode, factory, makeDate, business, buyDate,
	quantity, price, totalAmount,
	oprMan, acceptMan, acceptManID)
select acceptApplyID, eCode, annexName, annexFormat,
	isnull(cCode,''), fCode, factory, makeDate, business, buyDate,
	quantity, price, totalAmount,
	oprMan, acceptMan, acceptManID
from equipmentAnnex2

select * from equipmentAnnex

--3.eqpLifeCycle（设备生命周期表）：
--设备的生命周期：
--验收审核：设备生命周期的开始
--取消验收审核：设备生命周期的终止
--设备维修：设备生命周期：变动，可能涉及现值变动
--设备调拨：设备生命周期：变动，隶属关系变动
--增加附件：设备生命周期：变动，涉及现值变动
--设备报废：设备生命周期终止
select * from eqpLifeCycle

alter table eqpLifeCycle alter column changeType nvarchar(10) null		--变动类型 modi by lw 2012-10-18
drop table eqpLifeCycle
CREATE TABLE eqpLifeCycle(
	eCode char(8) not null,			--主键/外键：设备编号,使用特殊的号码发生器产生
											--2位年份代码+6位流水号，号码预先生成
											--使用手工输入号码，自动检测号码是否重号
	rowNum int IDENTITY(1,1) NOT NULL,	--主键:序号
	
	--冗余设计：
	eName nvarchar(30) not null,	--设备名称
	eModel nvarchar(20) not null,	--设备型号
	eFormat nvarchar(20) not null,	--设备规格
	
	--现隶属信息：
	clgCode char(3) not null,		--学院代码
	clgName nvarchar(30) null,		--学院名称
	uCode varchar(8) null,			--使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！
	uName nvarchar(30) null,		--使用单位名称
	keeper nvarchar(30) null,		--保管人
	keeperID varchar(10) null,		--保管人工号:add by lw 2012-5-22为设备认领一致化改造
	eqpLocate nvarchar(100) null,	--设备所在地址:add by lw 2012-5-22为设备认领一致化改造
	
	--现值：	
	annexAmount	numeric(12, 2) null,--附件金额 修改类型，约束小数点 modi by lw 2012-10-9
	price numeric(12, 2)  null,		--单价，>0 修改类型，约束小数点 modi by lw 2012-10-9
	totalAmount numeric(12, 2) null,--总价, >0（单价+附件价格）修改类型，约束小数点 modi by lw 2012-10-9

	--变动事项：
	changeDate smalldatetime default(getdate()), --变动日期
	changeDesc nvarchar(200) not null,	--变动描述
	--add by lw 2011-10-15：
	changeType nvarchar(10) null,		--变动类型 modi by lw 2012-10-18
	changeInvoiceID varchar(30) null,	--变动凭证号
	
 CONSTRAINT [PK_eqpLifeCycle] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[eqpLifeCycle] WITH CHECK ADD CONSTRAINT [FK_eqpLifeCycle_equipmentList] FOREIGN KEY([eCode])
REFERENCES [dbo].[equipmentList] ([eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpLifeCycle] CHECK CONSTRAINT [FK_eqpLifeCycle_equipmentList]
GO

--4.设备现状表：因为这个信息的来源可能不止设备清查一个功能，也可能是验收功能等，
			  --所以要将它同设备清查现状表分离设计，并且设备清查表可能在数据年切的时候被删除，而这个表不会被删除！
select * from eqpStatusInfo
drop TABLE eqpStatusInfo
CREATE TABLE eqpStatusInfo(
	eCode char(8) not null,				--主键/外键：设备编号
	eName nvarchar(30) not null,		--设备名称：冗余设计
	sNumber int not null,				--主键：现状批次号
	checkDate smalldatetime null,		--确认日期
	keeperID varchar(10) null,			--保管人工号
	keeper nvarchar(30) null,			--保管人
	eqpLocate nvarchar(100) null,		--设备所在地址
	checkStatus char(1) not null,		--设备状态：
										--0：状态不明 --这种状态自动变更为正常
										--1：正常；
										--3：待修；
										--4：待报废；
										--5：有帐无物；
										--6：无帐无物；--这种状态应该无法确定！
										--9：其他。
	statusNotes nvarchar(100) null,		--设备现状说明
	invoiceType char(1) not null,		--对应生成状态的票据类型：'1':验收单号，'5':设备清查单号
	invoiceNum varchar(30) not null,	--对应生成状态的票据号，可能是验收单号或设备清查单号等
 CONSTRAINT [PK_eqpStatusInfo] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC,
	[sNumber] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[eqpStatusInfo] WITH CHECK ADD CONSTRAINT [FK_eqpStatusInfo_equipmentList] FOREIGN KEY([eCode])
REFERENCES [dbo].[equipmentList] ([eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpStatusInfo] CHECK CONSTRAINT [FK_eqpStatusInfo_equipmentList]
GO

--索引：
--确认日期索引：
CREATE NONCLUSTERED INDEX [IX_eqpStatusInfo_1] ON [dbo].[eqpStatusInfo]
(
	[checkDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select * from eqpStatusPhoto
--4.1设备现状照片表：这是设备现状表的一个附表！
--图片文件放在eqpCheckPhoto/201111,子目录为上传的日期的年月
drop TABLE eqpStatusPhoto
CREATE TABLE eqpStatusPhoto(
	eCode char(8) not null,				--外键/主键:设备编号
	eName nvarchar(30) not null,		--设备名称:冗余设计
	sNumber int not null,				--外键/主键:现状批次号
	rowNum bigint IDENTITY(1,1) NOT NULL,--主键:序号
	photoDate smalldatetime not null,	--拍摄日期
	aFilename varchar(128) not NULL,	--主键：图片文件对应的36位全球唯一编码文件名
	notes nvarchar(100) null,			--说明
 CONSTRAINT [PK_eqpStatusPhoto] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC,
	[sNumber] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[eqpStatusPhoto]  WITH CHECK ADD  CONSTRAINT [FK_eqpStatusPhoto_eqpStatusInfo] FOREIGN KEY([eCode],[sNumber])
REFERENCES [dbo].[eqpStatusInfo] ([eCode],[sNumber])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpStatusPhoto] CHECK CONSTRAINT [FK_eqpStatusPhoto_eqpStatusInfo]
GO
--索引：
--图片名索引：
CREATE NONCLUSTERED INDEX [IX_eqpStatusPhoto] ON [dbo].[eqpStatusPhoto]
(
	[aFilename] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE addAnnex
/*
	name:		addAnnex
	function:	0.添加附件并生成相应的验收单
				注意：本存储过程自动完成验收的审核过程，不生成设备清单，不锁定单据
					  本存储过程没有做附件金额、设备总价的金额检查，请再UI中检查！
	input: 
				@applyDate smalldatetime,	--申请日期
				@eCode char(8),				--设备编号
				@annexName nvarchar(20),	--附件名称
				@annexFormat nvarchar(20),	--型号规格
				@cCode char(3),				--国家代码
				@fCode char(2),				--经费来源代码
				@factory nvarchar(20),		--出厂厂家
				@makeDate smalldatetime,	--出厂日期，在界面上拦截
				@business nvarchar(20),		--销售单位
				@buyDate smalldatetime,		--购置日期
				@sumNumber int,				--数量
				@annexAmount numeric(12,2),	--附件金额（单价）
				@oprManID varchar(10),		--经办人工号,add by lw 2012-8-10

				@createManID varchar(10) output,	--创建人工号：就是添加附件人（验收人），如果主设备被别人锁定编辑返回锁定人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要添加附件的主设备不存在，
							2:要添加附件的主设备正别别人锁定编辑，
							3:要添加附件的主设备的状态不对，只有以下设备状态允许添加附件：
									--1：在用，指正在使用的仪器设备；
									--3：待修，指待修或正在修理的仪器设备；
									--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
							4:该设备有编辑锁或长事务锁
							9:未知错误
				@createTime smalldatetime output	--添加时间
				@acceptID char(12) output	--生成的验收单号，使用第 1 号号码发生器产生
	author:		卢苇
	CreateDate:	2011-10-26
	UpdateDate: modi by lw 2012-8-12将经办人改成工号，增加长事务锁检查，增加创建人字段
				modi by lw 2012-10-27修正附件单价的字段类型
*/
create PROCEDURE addAnnex
	@applyDate smalldatetime,	--申请日期
	@eCode char(8),				--设备编号
	@annexName nvarchar(20),	--附件名称
	@annexFormat nvarchar(20),	--型号规格
	@cCode char(3),				--国家代码
	@fCode char(2),				--经费来源代码
	@factory nvarchar(20),		--出厂厂家
	@makeDate smalldatetime,	--出厂日期，在界面上拦截
	@business nvarchar(20),		--销售单位
	@buyDate smalldatetime,		--购置日期
	@sumNumber int,				--数量
	@annexAmount numeric(12,2),	--附件金额（单价）
	@oprManID varchar(10),		--经办人工号,add by lw 2012-8-10
	@createManID varchar(10) output,	--创建人工号：就是添加附件人（验收人）
	@Ret		int output,
	@createTime smalldatetime output,
	@acceptID char(12) output	--验收单号，使用第 1 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查指定的设备是否存在
	declare @count as int
	set @count=(select count(*) from equipmentList where eCode = @eCode)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @curEqpStatus char(1)
	select @thisLockMan = isnull(lockManID,''), @curEqpStatus = curEqpStatus
	from equipmentList where eCode = @eCode
	--检查设备编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @createManID)
	begin
		set @createManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查设备状态:
	if (@curEqpStatus not in ('1','3','8'))
	begin
		set @Ret = 3
		return
	end
	
	--检查设备是否有编辑锁或长事务锁：
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode and ((isnull(lockManID,'') <> '' and isnull(lockManID,'') <> @createManID) 
													or lock4LongTime <> 0))
	if (@count>0)
	begin
		set @Ret = 4
		return
	end
	
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 1, 1, @curNumber output
	set @acceptID = @curNumber

	--取经办人的姓名：
	declare @oprMan nvarchar(30)
	set @oprMan = isnull((select cName from userInfo where jobNumber = @oprManID),'')

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--计算金额：
	declare @sumAmount numeric(12,2)			--合计金额
	set @sumAmount = @annexAmount * @sumNumber
	
	--取主设备对应的验收单中得会计科目：
	declare @accountCode varchar(9)	--会计科目代码
	set @accountCode = isnull((select accountCode from eqpAcceptInfo 
								where acceptApplyID in(select acceptApplyID from equipmentList where eCode = @eCode)
								), '');
	
	set @createTime = getdate()
	begin tran
		--添加附件表：
		insert equipmentAnnex(acceptApplyID, eCode, annexName, annexFormat, fCode,
						cCode, factory, makeDate, business, buyDate, 
						quantity, price, totalAmount,
						oprManID, oprMan, acceptMan, acceptManID)
		values(@acceptID, @eCode, @annexName, @annexFormat, @fCode,
						@cCode, @factory, @makeDate, @business, @buyDate, 
						@sumNumber, @annexAmount, @sumAmount,
						@oprManID, @oprMan, @createManName, @createManID)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--添加验收单：
		insert eqpAcceptInfo(acceptApplyType, acceptApplyID, acceptApplyStatus, applyDate, acceptDate,
								eTypeCode, eTypeName, aTypeCode, eName,
								eModel, eFormat, cCode, factory, makeDate, serialNumber, buyDate, business, fCode, aCode, 
								clgCode, clgName, uCode, uName, 
								keeperID, keeper, annexName, annexAmount, price, totalAmount, sumNumber, sumAmount,
								oprManID, oprMan, notes, acceptMan, acceptManID,
								startECode, endECode, accountCode,
								lockManID, modiManID, modiManName, modiTime,
								createManID, createManName, createTime) 
 		select 1, @acceptID, 2, @applyDate, @createTime,
								eTypeCode, eTypeName, aTypeCode, @annexName,
								@annexFormat, '*', @cCode, @factory, @makeDate, '', @buyDate, @business, @fCode, aCode, 
								e.clgCode, c.clgName, e.uCode, u.uName, 
								keeperID, keeper, '', 0, @annexAmount, @annexAmount, @sumNumber, @sumAmount,
								@oprManID, @oprMan, '这是设备['+ e.eName +'('+ @eCode +')]的附件。', @createManName, @createManID,
								@eCode, @eCode, @accountCode,
								@createManID, @createManID, @createManName, @createTime,
								@createManID, @createManName, @createTime
		from equipmentList e left join college c on e.clgCode = c.clgCode
				left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
		where e.eCode = @eCode

		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--更新设备表：
		declare @curAnnexName nvarchar(20)
		set @curAnnexName = isnull((select annexName from equipmentList where eCode = @eCode),'')
		if @curAnnexName = ''
			set @curAnnexName = @annexName
		update equipmentList
		set annexName = @curAnnexName,
			annexAmount	= isnull(annexAmount,0) + @sumAmount,
			totalAmount = isnull(totalAmount,0) + @sumAmount
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--登记设备的生命周期：
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,changeType,changeInvoiceID) 
		select eCode, eName, eModel, eFormat, 
			e.clgCode, c.clgName, e.uCode, u.uName, keeper,
			annexAmount, price, totalAmount,
			@createTime, '添加附件：' + @annexName,
			'添加附件',@acceptID
		from equipmentList e left join college c on e.clgCode = c.clgCode
				left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
		where e.eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
	commit tran
	
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加附件验收单', '系统根据用户' + @createManName + 
					'的要求给设备['+ @eCode +']添加了附件['+ @annexName +']，并生成了相应的验收单[' + @acceptID + ']。')
GO

drop PROCEDURE updateAnnexApply
/*
	name:		updateAnnexApply
	function:	1.修改设备附件验收单并生成相应的设备附件
				注意：该存储过程自动完成验收的审核过程，不生成设备清单，不锁定单据
					  本存储过程没有做附件金额、设备总价的金额检查，请再UI中检查！
	input: 
				@acceptID char(12),			--验收单号
				@applyDate smalldatetime,	--申请日期
				@eCode char(8),				--设备编号
				@annexName nvarchar(20),	--附件名称
				@annexFormat nvarchar(20),	--型号规格
				@cCode char(3),				--国家代码
				@fCode char(2),				--经费来源代码
				@factory nvarchar(20),		--出厂厂家
				@makeDate smalldatetime,	--出厂日期，在界面上拦截
				@business nvarchar(20),		--销售单位
				@buyDate smalldatetime,		--购置日期
				@sumNumber int,				--数量
				@annexAmount numeric(12,2),	--附件金额（单价）
				@oprManID varchar(10),		--经办人工号,add by lw 2012-8-10

				@modiManID varchar(10) output,	--修改人工号：就是添加附件人（验收人）
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:要添加附件的主设备不存在，
							2:要添加附件的主设备正别别人锁定编辑，
							3:要添加附件的主设备的状态不对，只有以下设备状态允许添加附件：
									--1：在用，指正在使用的仪器设备；
									--3：待修，指待修或正在修理的仪器设备；
									--8：降档，指经学校批准允许降档次使用、管理的仪器设备；
							4:指定的验收申请单不存在，
							5:要更新的验收单息正被别人锁定，
							6:该单据已经通过审核，不允许修改，
							7:该附件验收单的主设备有编辑锁或长事务锁
							9:未知错误
				@modiTime smalldatetime output	--修改时间
	author:		卢苇
	CreateDate:	2011-11-3
	UpdateDate: modi by lw 2012-8-12将经办人改成工号，增加长事务锁检查
				modi by lw 2012-10-27修正附件单价的字段类型
*/
create PROCEDURE updateAnnexApply
	@acceptID char(12),			--验收单号
	@applyDate smalldatetime,	--申请日期
	@eCode char(8),				--设备编号
	@annexName nvarchar(20),	--附件名称
	@annexFormat nvarchar(20),	--型号规格
	@cCode char(3),				--国家代码
	@fCode char(2),				--经费来源代码
	@factory nvarchar(20),		--出厂厂家
	@makeDate smalldatetime,	--出厂日期，在界面上拦截
	@business nvarchar(20),		--销售单位
	@buyDate smalldatetime,		--购置日期
	@sumNumber int,				--数量
	@annexAmount numeric(12,2),	--附件金额（单价）
	@oprManID varchar(10),		--经办人工号,add by lw 2012-8-10
	@modiManID varchar(10) output,	--修改人工号：就是添加附件人（验收人）
	@Ret		int output,
	@modiTime smalldatetime output	--修改时间
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查指定的设备是否存在
	declare @count as int
	set @count=(select count(*) from equipmentList where eCode = @eCode)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @curEqpStatus char(1)
	select @thisLockMan = isnull(lockManID,''), @curEqpStatus = curEqpStatus
	from equipmentList where eCode = @eCode
	--检查设备编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查设备状态:
	if (@curEqpStatus not in ('1','3','8'))
	begin
		set @Ret = 3
		return
	end
	--检查设备是否有编辑锁或长事务锁：
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode and ((isnull(lockManID,'') <> '' and isnull(lockManID,'') <> @modiManID) 
													or lock4LongTime <> 0))
	if (@count>0)
	begin
		set @Ret = 7
		return
	end
	
	--判断指定的验收申请单是否存在
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 4
		return
	end

	declare @acceptApplyStatus int
	select @thisLockMan = isnull(lockManID,''), @acceptApplyStatus = acceptApplyStatus
	from eqpAcceptInfo 
	where acceptApplyID = @acceptID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 5
		return
	end
	
	--检查单据状态:
	if (@acceptApplyStatus <> 0)
	begin
		set @Ret = 6
		return
	end

	--取经办人的姓名：
	declare @oprMan nvarchar(30)
	set @oprMan = isnull((select cName from userInfo where jobNumber = @oprManID),'')

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--计算金额：
	declare @sumAmount numeric(12,2)			--合计金额
	set @sumAmount = @annexAmount * @sumNumber
	
	--取主设备对应的验收单中得会计科目：
	declare @accountCode varchar(9)	--会计科目代码
	set @accountCode = isnull((select accountCode from eqpAcceptInfo 
								where acceptApplyID in(select acceptApplyID from equipmentList where eCode = @eCode)
								), '');
	
	set @modiTime = getdate()
	begin tran
		--添加附件表：
		insert equipmentAnnex(acceptApplyID, eCode, annexName, annexFormat, fCode,
						cCode, factory, makeDate, business, buyDate, 
						quantity, price, totalAmount,
						oprManID, oprMan, acceptMan, acceptManID)
		values(@acceptID, @eCode, @annexName, @annexFormat, @fCode,
						@cCode, @factory, @makeDate, @business, @buyDate, 
						@sumNumber, @annexAmount, @sumAmount,
						@oprManID, @oprMan, @modiManName, @modiManID)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--添加验收单：
		update eqpAcceptInfo
		set acceptApplyType = 1,
			acceptApplyStatus = 2, 
			applyDate = @applyDate,
			acceptDate = @modiTime,
			eTypeCode = e.eTypeCode, eTypeName = e.eTypeName, aTypeCode = e.aTypeCode, 
			eName = @annexName, eModel = @annexFormat,  eFormat = '*', 
			cCode = @cCode, 
			factory = @factory, makeDate = @makeDate, 
			serialNumber = '', 
			buyDate = @buyDate, business = @business, 
			fCode = @fCode, aCode = e.aCode, 
			clgCode = e.clgCode, clgName = c.clgName, 
			uCode = e.uCode, uName = u.uName, 
			keeperID = e.keeperID, keeper = e.keeper, 
			annexName = '', annexAmount = 0, price = @annexAmount, totalAmount = @annexAmount, sumNumber = @sumNumber, sumAmount = @sumAmount,
			oprManID = @oprManID, oprMan = @oprMan, notes = '这是设备['+ e.eName +'('+ @eCode +')]的附件。', 
			acceptMan = @modiManName, acceptManID = @modiManID,
			startECode = @eCode, endECode = @eCode, accountCode = @accountCode,
			lockManID = @modiManID, modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
		from (select * from equipmentList where eCode = @eCode) e left join college c on e.clgCode = c.clgCode
				left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
		where eqpAcceptInfo.acceptApplyID = @acceptID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--更新设备表：
		declare @curAnnexName nvarchar(20)
		set @curAnnexName = isnull((select annexName from equipmentList where eCode = @eCode),'')
		if @curAnnexName = ''
			set @curAnnexName = @annexName
		update equipmentList
		set annexName = @curAnnexName,
			annexAmount	= isnull(annexAmount,0) + @sumAmount,
			totalAmount = isnull(totalAmount,0) + @sumAmount
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--登记设备的生命周期：
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,changeType,changeInvoiceID) 
		select eCode, eName, eModel, eFormat, 
			e.clgCode, c.clgName, e.uCode, u.uName, keeper,
			annexAmount, price, totalAmount,
			@modiTime, '添加附件：' + @annexName,
			'添加附件',@acceptID
		from equipmentList e left join college c on e.clgCode = c.clgCode
				left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
		where e.eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
	commit tran
	
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改附件验收单', '系统根据用户' + @modiManName + 
					'的要求给设备['+ @eCode +']添加了附件['+ @annexName +']，并生成了相应的验收单[' + @acceptID + ']。')
GO


select * from eqpCodeList where isUsed='Y' order by eCode
select top 100 eCode from eqpCodeList where isUsed='N'


drop PROCEDURE setEqpStatus
/*
	name:		setEqpStatus
	function:	2.设置设备状态
				注意：该存储过程检测编辑锁，但不一定需要锁定，也不释放编辑锁
	input: 
				@eCode char(8),				--设备编号
				@curEqpStatus char(1),		--设备状态码

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:该设备不存在，
							2:该设备正别别人锁定编辑，
							3:该设备有编辑锁或长事务锁
							9:未知错误
	author:		卢苇
	CreateDate:	2012-10-13
	UpdateDate: 
*/
create PROCEDURE setEqpStatus
	@eCode char(8),					--设备编号
	@curEqpStatus char(1),			--设备状态码
	@modiManID varchar(10) output,	--修改人工号
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查指定的设备是否存在
	declare @count as int
	set @count=(select count(*) from equipmentList where eCode = @eCode)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from equipmentList where eCode = @eCode
	--检查设备编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查设备是否有编辑锁或长事务锁：
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode and ((isnull(lockManID,'') <> '' and isnull(lockManID,'') <> @modiManID) 
													or lock4LongTime <> 0))
	if (@count>0)
	begin
		set @Ret = 3
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--取状态码对应的名称：
	declare @statusName nvarchar(10)
	set @statusName = (select objDesc from codeDictionary where classCode=2 and objCode=@curEqpStatus)

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	begin tran
		update equipmentList
		set curEqpStatus = @curEqpStatus,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @modiTime
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--登记设备的生命周期：
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,changeType,changeInvoiceID) 
		select eCode, eName, eModel, eFormat, 
			e.clgCode, c.clgName, e.uCode, u.uName, keeper,
			annexAmount, price, totalAmount,
			@modiTime, @modiManName +'将设备状态设为为：' + @statusName,
			'修改状态',''
		from equipmentList e left join college c on e.clgCode = c.clgCode
				left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
		where e.eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
	commit tran
	
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '修改设备状态', '用户' + @modiManName + 
					'将设备['+ @eCode +']的状态修改为['+ @statusName +']。')
GO
--测试：
select * from equipmentList
declare @Ret int
exec dbo.setEqpStatus '00000104', '3', '00000001', @Ret output
select @Ret
select * from eqpLifeCycle where eCode='00000104'
select * from userInfo

--3.可用设备编号表：这是设备编号的特殊号码发生器使用的表！
drop TABLE eqpCodeList
CREATE TABLE eqpCodeList(
	eCode char(8) not null,			--设备编号
	isUsed char(1) default('N')		--是否已经使用
 CONSTRAINT [PK_eqpCodeList] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_eqpCodeList] ON [dbo].[eqpCodeList]
(
	[isUsed] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select * from eqpCodeList
drop PROCEDURE makeEqpCodes
/*
	name:		makeEqpCodes
	function:	1.生成可用设备编号表
	input: 
				@year char(4),				--年度
				@startNum varchar(6),		--起始编号
				@length smallint,			--长度
				@makeManID varchar(10),		--生成设备编号的人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：当前正有用户再使用验收单，2：没有足够的号码生成，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-24
	UpdateDate: 
*/
create PROCEDURE makeEqpCodes
	@year char(4),				--年度
	@startNum varchar(6),		--起始编号
	@length smallint,			--长度
	@makeManID varchar(10),		--生成设备编号的人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--释放不正常退出的用户锁定的验收单：
	update eqpAcceptInfo
	set lockManID = ''
	where lockManID not in (select userID from activeUsers)
	
	--检查验收单是否有人在编辑
	declare @count int
	set @count = (select count(*) from eqpAcceptInfo where isnull(lockManID,'') <> '')
	if (@count > 0)
	begin
		set @Ret = 1
		return
	end
	declare @oldLength int
	set @oldLength = @length
	declare @shortYear varchar(2)
	set @shortYear = right(@year,2)
	--为加快算法，生成已占用号码表：
	declare @usedCodes table(eCode char(8))
	insert @usedCodes(eCode)
	select eCode from equipmentList where left(eCode,2) = @shortYear
	
	begin tran
		--清空号码表：
		truncate table eqpCodeList
		--锁定全部验收单
		update eqpAcceptInfo
		set lockManID = @makeManID

		--生成号码
		if (@startNum is null)
			set @startNum = '1'
		declare @intStartNum int
		set @intStartNum = cast(@startNum as int)
		declare @curCode as varchar(8)
		WHILE @length > 0
		begin
			set @curCode = @shortYear + right('00000' + ltrim(convert(varchar(6),@intStartNum)), 6) 
--print @curCode
			--检查该号码是否使用过：
			set @count = (select count(*) from @usedCodes where eCode = @curCode)
			if (@count = 0)
			begin
				set @length = @length - 1
				insert eqpCodeList(eCode) values(@curCode)
			end
			set @intStartNum = @intStartNum + 1
			if (@intStartNum > 999999)	--号码溢出
			begin
				set @Ret = 2
				update eqpAcceptInfo set lockManID = ''
				commit tran
				return
			end
		end
		update eqpAcceptInfo set lockManID = ''
	commit tran
	set @Ret = 0
	
	--取创建人的姓名：
	declare @makeManName nvarchar(30)
	set @makeManName = isnull((select userCName from activeUsers where userID = @makeManID),'')
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makeManID, @makeManName, getdate(), '创建设备编号', '系统根据用户' + @makeManName
												+ '的要求创建了['+ @year+'年]的设备编号['+ cast(@oldLength as varchar(6)) +']个。')
	
GO

--测试：
select * from eqpAcceptInfo where isnull(lockManID,'') <> ''
update eqpAcceptInfo 
set lockManID = ''
where isnull(lockManID,'') <> ''

truncate table eqpCodeList
declare @ret int
exec dbo.makeEqpCodes '2015', null, 1000, '0000000000', @ret output
select @ret
select * from eqpCodeList
select * from workNote order by actionTime desc

delete worknote

drop PROCEDURE checkEqpCodes
/*
	name:		checkEqpCodes
	function:	2.检查号码段是否可用
	input: 
				@startNum varchar(8),		--起始编号
				@length smallint,			--长度
	output: 
				@Ret		int output		--操作成功标识
							0:可用，-1：不能使用，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-24
	UpdateDate: 
*/
create PROCEDURE checkEqpCodes
	@startNum varchar(8),		--起始编号
	@length smallint,			--长度
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--生成结束号码
	declare @intEndNum int
	set @intEndNum = cast(right(@startNum,6) as int) + @length - 1
	declare @endCode as varchar(8)
	set @endCode = left(@startNum,2) + right('00000' + ltrim(convert(varchar(6),@intEndNum)), 6)
	
	--检查该号码段中的可用号码是否足够：
	declare @count int
	set @count = (select count(*) from eqpCodeList where eCode >= @startNum and eCode <= @endCode and isUsed = 'N')
	if (@count = @length)
		set @Ret = 0
	else
		set @Ret = -1
GO
--测试：
select * from eqpCodeList
declare @ret int
exec dbo.checkEqpCodes '12000189', 10, @ret output
select @ret



drop PROCEDURE autoGetCodes
/*
	name:		autoGetCodes
	function:	3.自动获取合适的号码段
	input: 
				@length smallint,			--长度
	output: 
				@Ret		int output,		--操作成功标识
							0:可用，1：没有合适的号码段，9：未知错误
				@startNum varchar(8) output,--起始编号
				@endNum varchar(8) output	--结束编号
	author:		卢苇
	CreateDate:	2010-11-24
	UpdateDate: 2011-1-23 modi by lw 传出结束号码
*/
create PROCEDURE autoGetCodes
	@length smallint,			--长度
	@Ret	int output,			--操作成功标识
	@startNum varchar(8) output,--起始编号
	@endNum varchar(8) output	--结束编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @startNum = ''
	
	declare @eCode char(8), @execRet int
	declare tar cursor for
	select eCode from eqpCodeList where isUsed = 'N'	
	OPEN tar
	FETCH NEXT FROM tar INTO @eCode
	WHILE @@FETCH_STATUS = 0
	begin
		exec dbo.checkEqpCodes @eCode, @length, @execRet output
		if (@execRet = 0)
		begin
			set @startNum = @eCode
			break
		end
		FETCH NEXT FROM tar INTO @eCode
	end
	CLOSE tar
	DEALLOCATE tar
	
	if (@startNum <> '')
	begin
		--生成结束号码
		declare @intEndNum int
		set @intEndNum = cast(right(@startNum,6) as int) + @length - 1
		set @endNum = left(@startNum,2) + right('00000' + ltrim(convert(varchar(6),@intEndNum)), 6)
		
		set @Ret = 0
	end
	else
		set @Ret = 1
GO
--测试：
select * from eqpCodeList
declare @ret int, @startNum varchar(8), @endNum varchar(8)
exec dbo.autoGetCodes 20, @ret output, @startNum output, @endNum output
select @ret, @startNum, @endNum


drop PROCEDURE checkECodesEnable
/*
	name:		checkECodesEnable
	function:	4.检查从指定的号码开始是否有指定长度的连续的可用号码段
	input: 
				@startNum varchar(8),		--起始编号
				@length smallint,			--长度
	output: 
				@Ret		int output,		--操作成功标识
							0:可用，1：没有合适的号码段，9：未知错误
				@endNum varchar(8) output	--结束编号
	author:		卢苇
	CreateDate:	2011-1-23
	UpdateDate: 
*/
create PROCEDURE checkECodesEnable
	@startNum varchar(8),		--起始编号
	@length smallint,			--长度
	@Ret	int output,			--操作成功标识
	@endNum varchar(8) output	--结束编号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @execRet int
	exec dbo.checkEqpCodes @startNum, @length, @execRet output
	if (@execRet = 0)
	begin
		--生成结束号码
		declare @intEndNum int
		set @intEndNum = cast(right(@startNum,6) as int) + @length - 1
		set @endNum = left(@startNum,2) + right('00000' + ltrim(convert(varchar(6),@intEndNum)), 6)
		
		set @Ret = 0
	end
	else
		set @Ret = 1
GO
--测试：
select * from eqpCodeList
declare @ret int, @startNum varchar(8), @endNum varchar(8)
exec dbo.checkECodesEnable '10000674', 3, @ret output, @endNum output
select @ret, @endNum



--5.设备的派生信息：
--5.1车辆的派生信息：
--5.2大型精密设备的派生信息：
--5.3放射源设备的派生信息：

select changeApplyID, eCode, changeDesc, applyManID, applyManName, CONVERT(varchar(10),e.applyTime,120) applyTime, 
	isAgree, checkManID,checkManName, convert(varchar(10),e.checkTime,120) checkTime,
	acceptApplyID, eName, eModel, eFormat, unit, cCode, factory, convert(varchar(10),e.makeDate,120) makeDate,
	serialNumber, business, convert(varchar(10),buyDate,120) buyDate,
	annexName, annexCode, annexAmount,
	eTypeCode, eTypeName, aTypeCode,
	fCode, aCode, price, totalAmount, clgCode, uCode, keeperID, keeper, eqpLocate, notes,
	convert(varchar(10),e.acceptDate,120) acceptDate, oprManID, oprMan, acceptManID, acceptMan, 
	curEqpStatus, convert(varchar(10),e.scrapDate,120) scrapDate, scrapNum,
	obtainMode, purchaseMode
from changeEqpInfoApply e

select changeApplyID, eCode, changeDesc, applyManID, applyManName, CONVERT(varchar(10),e.applyTime,120) applyTime, isAgree, checkManID,checkManName, convert(varchar(10),e.checkTime,120) checkTime
from changeEqpInfoApply e
where eCode='12015242'
--6.设备信息更正申请表：
drop TABLE changeEqpInfoApply
CREATE TABLE changeEqpInfoApply(
	changeApplyID varchar(12) not null,	--主键：更正申请单号，使用第 5 号号码发生器产生
	eCode char(8) not null,				--设备编号

	changeDesc nvarchar(50) null,		--更正主要事项描述，如果为空，系统自动扫描修改的字段，生成主项描述
	applyManID varchar(10) null,		--申请人工号
	applyManName nvarchar(30) null,		--申请人姓名
	applyTime smalldatetime default(getdate()),		--申请时间

	isAgree smallint not null default(0),	--是否同意变更：0->申请状态；1->同意变更；->2不同意变更
	checkManID varchar(10) null,		--审核人工号
	checkManName nvarchar(30) null,		--审核人姓名
	checkTime smalldatetime null,		--审核时间
	
	acceptApplyID char(12) null,	--对应的验收单号:不允许更正！
	eName nvarchar(30) not null,	--设备名称
	eModel nvarchar(20) not null,	--设备型号
	eFormat nvarchar(30) not null,	--设备规格
	unit nvarchar(10) null,			--计量单位：不允许更正！
	cCode char(3) not null,			--国家代码
	factory	nvarchar(20) null,		--生产厂家
	makeDate smalldatetime null,	--出厂日期
	serialNumber nvarchar(20) null,	--出厂编号
	business nvarchar(20) null,		--销售单位
	buyDate smalldatetime null,		--购置日期
	annexName nvarchar(20) null,	--附件名称：不允许更正
	annexCode nvarchar(20) null,	--随机附件编号:不允许更正！
	annexAmount	numeric(12, 2) null,--附件金额（就是附件单价）不允许更正

	eTypeCode char(8) not null,		--分类编号（教）最后4位不允许同时为“0”
	eTypeName nvarchar(30) not null,--教育部分类名称
	aTypeCode varchar(7) not null,	--分类编号（财）分类编号（财）=f（分类编号（数））使用映射表
									--根据GB/T 14885-2010规定将编码延长到7位modi by lw 2012-2-23

	fCode char(2) not null,			--经费来源代码
	aCode char(2) null,				--使用方向代码
	price numeric(12, 2) null,		--单价：不允许更正！
	totalAmount numeric(12, 2) null,--总价：不允许更正！
	clgCode char(3) not null,		--学院代码：不允许更正！
	uCode varchar(8) null,			--使用单位代码：不允许更正！
	keeperID varchar(10) null,		--保管人工号（设备管理员）：不允许更正！
	keeper nvarchar(30) null,		--保管人：不允许更正！
	eqpLocate nvarchar(100) null,	--设备所在地址

	notes nvarchar(50) null,		--备注
	acceptDate smalldatetime null,	--验收日期：不允许更正！
	oprManID varchar(10) null,		--经办人工号：不允许更正！
	oprMan nvarchar(30) null,		--经办人：不允许更正！
	acceptManID varchar(10) null,	--验收人工号：不允许更正！
	acceptMan nvarchar(30) null,	--验收人：不允许更正！
	curEqpStatus char(1) not null,	--根据报表的规定重新定义设备的现状代码含义：本字段由第2号代码字典定义 modi by lw 2011-1-26
									--1：在用，指正在使用的仪器设备；
									--2：多余，指具有使用价值而未使用的仪器设备；
									--3：待修，指待修或正在修理的仪器设备；
									--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
									--5：丢失，
									--6：报废，
									--7：调出，
									--8：降档，指经学校批准允许降档次使用、管理的仪器设备；
									--9：其他，现状不详的仪器设备。
	scrapDate smalldatetime null,	--报废日期：不允许更正！
	--add by lw 2011-05-16,因为筛选中的条件构造比较麻烦，所以增加该字段
	--注意：相应修改了报废的存储过程，在处理原始数据的时候需要处理
	scrapNum char(12) null,		--对应的设备报废单号：不允许更正！

	obtainMode int null,				--取得方式
	purchaseMode int null,				--采购组织形式
 CONSTRAINT [PK_changeEqpInfoApply] PRIMARY KEY CLUSTERED 
(
	[changeApplyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--索引：
CREATE NONCLUSTERED INDEX [IX_changeEqpInfoApply] ON [dbo].[changeEqpInfoApply] 
(
	[eCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[changeEqpInfoApply] WITH CHECK ADD CONSTRAINT [FK_changeEqpInfoApply_equipmentList] FOREIGN KEY([eCode])
REFERENCES [dbo].[equipmentList] ([eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[changeEqpInfoApply] CHECK CONSTRAINT [FK_changeEqpInfoApply_equipmentList]
GO

select * from equipmentList where isnull(lockManID,'') <> '' or lock4LongTime<>0
drop PROCEDURE addChangeEqpInfoApply
/*
	name:		addChangeEqpInfoApply
	function:	10.添加设备信息更正申请单
	input: 
				@eCode char(8),				--设备编号
				@changeDesc nvarchar(50),	--更正主要事项描述，如果为空，系统自动扫描修改的字段，生成主项描述
				@applyManID varchar(10),	--申请人工号
				
				@eName nvarchar(30),		--设备名称
				@eModel nvarchar(20),		--设备型号
				@eFormat nvarchar(20),		--设备规格
				@cCode char(3),				--国家代码
				@factory nvarchar(20),		--出厂厂家
				@makeDate varchar(10),		--出厂日期:采用“yyyy-MM-dd”格式
				@serialNumber nvarchar(20),	--出厂编号
				@business nvarchar(20),		--销售单位
				@buyDate varchar(10),		--购置日期:采用“yyyy-MM-dd”格式

				@eTypeCode char(8),			--分类编号（教）
				@eTypeName nvarchar(30),	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30

				@fCode char(2),				--经费来源代码
				@aCode char(2),				--使用方向代码

				@eqpLocate nvarchar(100),	--设备所在地址

				@notes nvarchar(50),		--备注
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1:该设备不存在，2:该设备正被别人编辑锁定或有未完成的长事务
							3:没有修改任何信息，9:未知错误
				@changeApplyID varchar(12)	--主键：更正申请单号，使用第 5 号号码发生器产生
	author:		卢苇
	CreateDate:	2012-10-13
	UpdateDate: 
*/
create PROCEDURE addChangeEqpInfoApply
	@eCode char(8),				--设备编号
	@changeDesc nvarchar(50),	--更正主要事项描述，如果为空，系统自动扫描修改的字段，生成主项描述
	@applyManID varchar(10),	--申请人工号
	
	@eName nvarchar(30),		--设备名称
	@eModel nvarchar(20),		--设备型号
	@eFormat nvarchar(20),		--设备规格
	@cCode char(3),				--国家代码
	@factory nvarchar(20),		--出厂厂家
	@makeDate varchar(10),		--出厂日期:采用“yyyy-MM-dd”格式
	@serialNumber nvarchar(20),	--出厂编号
	@business nvarchar(20),		--销售单位
	@buyDate varchar(10),		--购置日期:采用“yyyy-MM-dd”格式

	@eTypeCode char(8),			--分类编号（教）
	@eTypeName nvarchar(30),	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30

	@fCode char(2),				--经费来源代码
	@aCode char(2),				--使用方向代码

	@eqpLocate nvarchar(100),	--设备所在地址

	@notes nvarchar(50),		--备注

	@Ret		int output,
	@changeApplyID varchar(12) output	--主键：更正申请单号，使用第 5 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该设备是否存在：
	declare @count int
	set @count = (select COUNT(*) from equipmentList where eCode = @eCode)
	if (@count=0)
	begin
		set @Ret = 1
		return
	end

	--检查设备的长事务锁和编辑锁：
	declare @locker varchar(10), @lock4LongTime char(1)
	select @locker=isnull(lockManID,''), @lock4LongTime=lock4LongTime from equipmentList where eCode =@eCode
	if ((@locker<>'' and @locker<>@applyManID) or @lock4LongTime<>0)
	begin
		set @Ret = 2
		return
	end

	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 5, 1, @curNumber output
	set @changeApplyID = @curNumber

	--申请人的姓名：
	declare @applyManName nvarchar(30)	--申请人姓名
	set @applyManName = isnull((select userCName from activeUsers where userID = @applyManID),'')

	--取财政部编码：
	declare @aTypeCode varchar(7)		--分类编号（财）
	set @aTypeCode = (select aTypeCode from typeCodes where eTypeCode=@eTypeCode and eTypeName=@eTypeName)

	--取计量单位：
	declare @unit nvarchar(10)
	set @unit = ISNULL((select unit from GBT14885 where aTypeCode = @aTypeCode),'')
	
	--检查主项描述：
	declare @desc nvarchar(50)
	set @desc = ''
	set @desc = @desc + (select case eName when @eName then '' else '、设备名称' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case eModel when @eModel then '' else '、型号' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case eFormat when @eFormat then '' else '、规格' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case cCode when @cCode then '' else '、国别' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case factory when @factory then '' else '、生产厂家' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case makeDate when @makeDate then '' else '、出厂日期' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case serialNumber when @serialNumber then '' else '、出厂编号' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case business when @business then '' else '、销售单位' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case buyDate when @buyDate then '' else '、购置日期' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case eTypeCode + eTypeName when @eTypeCode+@eTypeName then '' else '、分类编码' end 
							from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case fCode when @fCode then '' else '、经费来源' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case aCode when @aCode then '' else '、使用方向' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case eqpLocate when @eqpLocate then '' else '、存放地点' end from equipmentList where eCode=@eCode)
	set @desc = @desc + (select case notes when @notes then '' else '、备注' end from equipmentList where eCode=@eCode)
	if (@desc='')
	begin
		set @Ret = 3
		return
	end
	if (isnull(@changeDesc,'')='')
	begin
		set @changeDesc = N'申请修改'+RIGHT(@desc, LEN(@desc)-1)
	end

	declare @createTime smalldatetime
	set @createTime = getdate()
	begin tran
		insert changeEqpInfoApply(changeApplyID, eCode, changeDesc, applyManID, applyManName, applyTime,
			acceptApplyID, eName, eModel, eFormat, unit, cCode, factory, makeDate, serialNumber, 
			business, buyDate, annexName, annexCode, annexAmount, eTypeCode, eTypeName, aTypeCode,
			fCode, aCode, price, totalAmount, clgCode, uCode, keeperID, keeper, eqpLocate, notes,
			acceptDate, oprManID, oprMan, acceptManID, acceptMan, curEqpStatus, scrapDate, scrapNum, 
			obtainMode, purchaseMode)
		select @changeApplyID, eCode, @changeDesc, @applyManID, @applyManName, @createTime,
			acceptApplyID, @eName, @eModel, @eFormat, @unit, @cCode, @factory, @makeDate, @serialNumber, 
			@business, @buyDate, annexName, annexCode, annexAmount, @eTypeCode, @eTypeName, @aTypeCode,
			@fCode, @aCode, price, totalAmount, clgCode, uCode, keeperID, keeper, @eqpLocate, @notes,
			acceptDate, oprManID, oprMan, acceptManID, acceptMan, curEqpStatus, scrapDate, scrapNum, 
			obtainMode, purchaseMode
		from equipmentList
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--添加设备长事务锁：
		update equipmentList
		set lock4LongTime = 5, lInvoiceNum=@changeApplyID
		where eCode =@eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	commit tran
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@applyManID, @applyManName, @createTime, '更正申请', '用户' + @applyManName + 
					'创建了设备信息更正申请单[' + @changeApplyID + ']。')
GO
--测试:
select top 10 * from equipmentList
select * from activeUsers
declare @Ret		int
declare @changeApplyID varchar(12)
exec dbo.addChangeEqpInfoApply '00000174','','00200977','超级显示器','*','19"','156','三星中国','2008-12-10','234234','洪山区创兴电脑',
	'2008-10-10','05010502','彩色终端','1','3','武汉','测试数据', @Ret output, @changeApplyID output
select @Ret, @changeApplyID

select * from changeEqpInfoApply
select top 10 * from workNote order by actionTime desc
select * from equipmentList where eCode ='00000174'
use epdc211
declare @Ret int
exec dbo.delChangeEqpInfoApply '201210140005','00200977', @Ret output


select changeApplyID, eCode, changeDesc, applyManID, applyManName, 
	CONVERT(varchar(10),e.applyTime,120) applyTime, isAgree, checkManID,checkManName, 
	convert(varchar(10),e.checkTime,120) checkTime,acceptApplyID, eName, eModel, eFormat, 
	unit, cCode, factory, convert(varchar(10),e.makeDate,120) makeDate,serialNumber, business, 
	convert(varchar(10),buyDate,120) buyDate,annexName, annexCode, annexAmount,eTypeCode, eTypeName, 
	aTypeCode,fCode, aCode, price, totalAmount, clgCode, uCode, keeperID, keeper, eqpLocate, notes,
	convert(varchar(10),e.acceptDate,120) acceptDate, oprManID, oprMan, acceptManID, acceptMan, curEqpStatus, 
	convert(varchar(10),e.scrapDate,120) scrapDate, scrapNum,obtainMode, purchaseMode 
	from changeEqpInfoApply e where e.changeApplyID ='201210140001'

drop PROCEDURE delChangeEqpInfoApply
/*
	name:		delChangeEqpInfoApply
	function:	11.删除指定的设备信息更正申请
	input: 
				@changeApplyID varchar(12),		--更正申请单号
				@delManID varchar(10),			--删除人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的设备信息更正单不存在，2：单据已审核生效，不能删除，
							5：该更正申请的设备正在清查，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-10-13
	UpdateDate: modi by lw 2013-5-27增加长事务锁处理
*/
create PROCEDURE delChangeEqpInfoApply
	@changeApplyID varchar(12),		--更正申请单号
	@delManID varchar(10) output,	--删除人
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的申请单是否存在
	declare @count as int
	set @count=(select count(*) from changeEqpInfoApply where changeApplyID = @changeApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--获取设备编号：
	declare @eCode char(8)
	set @eCode = (select eCode from changeEqpInfoApply where changeApplyID = @changeApplyID)
	
	declare @isAgree smallint
	select @isAgree = isAgree
	from changeEqpInfoApply 
	where changeApplyID = @changeApplyID
	--检查单据状态:
	if (@isAgree <> 0)
	begin
		set @Ret = 2
		return
	end

	--检查该单据涉及的设备是否有编辑锁或长事务锁：
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from changeEqpInfoApply where changeApplyID = @changeApplyID)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 5 and lInvoiceNum=@changeApplyID))))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end

	begin tran
		--释放长事务锁：
		update equipmentList
		set lock4LongTime = 0, lInvoiceNum=''
		where eCode =@eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end

		delete changeEqpInfoApply where changeApplyID = @changeApplyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	commit tran	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除更正申请单', '用户' + @delManName
												+ '删除了设备['+@eCode+']信息更正单['+ @changeApplyID +']。')

GO


drop PROCEDURE activeChangeEqpInfoApply
/*
	name:		activeChangeEqpInfoApply
	function:	12.生效或作废指定的设备信息更正申请
	input: 
				@changeApplyID varchar(12),		--更正申请单号
				@isActive char(1),				--是否生效："Y":生效，"N"：作废
				@activeManID varchar(10),		--审核人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的设备信息更正单不存在，2：单据已审核生效，
							5：该更正申请的设备正在清查，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-10-13
	UpdateDate: modi by lw 2013-5-27增加长事务锁处理
*/
create PROCEDURE activeChangeEqpInfoApply
	@changeApplyID varchar(12),		--更正申请单号
	@isActive char(1),				--是否生效："Y":生效，"N"：作废
	@activeManID varchar(10),		--审核人
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的申请单是否存在
	declare @count as int
	set @count=(select count(*) from changeEqpInfoApply where changeApplyID = @changeApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @isAgree smallint
	select @isAgree = isAgree
	from changeEqpInfoApply 
	where changeApplyID = @changeApplyID
	--检查单据状态:
	if (@isAgree <> 0)
	begin
		set @Ret = 2
		return
	end

	--检查该单据涉及的设备是否有编辑锁或长事务锁：
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from changeEqpInfoApply where changeApplyID = @changeApplyID)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 5 and lInvoiceNum=@changeApplyID))))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end

	--获取设备编号：
	declare @eCode char(8)
	set @eCode = (select eCode from changeEqpInfoApply where changeApplyID = @changeApplyID)

	--取维护人的姓名：
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')
	
	declare @modiTime smalldatetime
	set @modiTime = GETDATE()
	begin tran
		if (@isActive = 'Y')
		begin
			--更正设备库，并释放长事务锁：
			update equipmentList
			set eName = c.eName, eModel = c.eModel, eFormat = c.eFormat,
				cCode = c.cCode, factory = c.factory, makeDate = c.makeDate,
				serialNumber = c.serialNumber, business = c.business, buyDate = c.buyDate,
				eTypeCode = c.eTypeCode, eTypeName = c.eTypeName, aTypeCode = c.aTypeCode,
				fCode = c.fCode, aCode = c.aCode,
				eqpLocate = c.eqpLocate, notes = c.notes,
				lock4LongTime = 0, lInvoiceNum='',	--释放长事务锁
				--维护情况:
				modiManID = @activeManID, modiManName = @activeManName,	modiTime = @modiTime
			from equipmentList e inner join changeEqpInfoApply c on e.eCode=c.eCode
			where c.changeApplyID = @changeApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
			--登记设备的生命周期：
			insert eqpLifeCycle(eCode,eName, eModel, eFormat,
				clgCode, clgName, uCode, uName, keeper,
				annexAmount, price, totalAmount,
				changeDate, changeDesc,changeType,changeInvoiceID) 
			select e.eCode, e.eName, e.eModel, e.eFormat, 
				e.clgCode, c.clgName, e.uCode, u.uName, e.keeper,
				e.annexAmount, e.price, e.totalAmount,
				@modiTime, @activeManName +'将' + a.applyManName 
					+ '"' +a.changeDesc + '"的更正申请生效。',
				'修改设备信息',@changeApplyID
			from equipmentList e left join changeEqpInfoApply a on e.eCode = a.eCode and a.changeApplyID = @changeApplyID
					left join college c on e.clgCode = c.clgCode
					left join useUnit u on e.uCode = u.uCode and e.clgCode = u.clgCode
			where e.eCode = @eCode
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			--修改单据状态：
			update changeEqpInfoApply 
			set isAgree = 1, checkManID = @activeManID, checkManName = @activeManName,
				checkTime = @modiTime
			where changeApplyID = @changeApplyID
		end
		else
		begin
			--修改单据状态：
			update changeEqpInfoApply 
			set isAgree = 2
			where changeApplyID = @changeApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end

			--释放长事务锁：
			update equipmentList
			set lock4LongTime = 0, lInvoiceNum=''
			where eCode =@eCode
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
		end
	commit tran

	set @Ret = 0
	
	--登记工作日志：
	if (@isActive = 'Y')
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@activeManID, @activeManName, @modiTime, '生效更正申请单', '用户' + @activeManName
													+ '生效了设备信息更正单['+ @changeApplyID +']。')
	else
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@activeManID, @activeManName, @modiTime, '作废更正申请单', '用户' + @activeManName
													+ '作废了设备信息更正单['+ @changeApplyID +']。')

GO
--测试：
select * from activeUsers
declare @Ret		int
exec dbo.activeChangeEqpInfoApply '201210190003', 'Y', '00200977', @Ret output
select @Ret

select * from changeEqpInfoApply
select * from workNote order by actionTime desc

--设备现状：
select e.eTypeCode, e.eTypeName, e.aTypeCode,
	e.eCode, e.eName, e.eModel, e.eFormat,
	e.annexAmount,
	e.fCode, f.fName, e.aCode, a.aName, e.makeDate, e.buyDate, e.price, e.totalAmount, 
	e.clgCode, clg.clgName, e.uCode, u.uName, e.keeper, e.acceptDate, 
	curEqpStatus char(1) not null,	--根据报表的规定重新定义设备的现状代码含义：本字段由第2号代码字典定义 modi by lw 2011-1-26
									--1：在用，指正在使用的仪器设备；
									--2：多余，指具有使用价值而未使用的仪器设备；
									--3：待修，指待修或正在修理的仪器设备；
									--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
									--5：丢失，
									--6：报废，
									--7：调出，
									--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
									--9：其他，现状不详的仪器设备。
	case curEqpStatus when '1' then '在用' when '2' then '多余' when '3' then '待修' when '4' then '待报废'
	when '5' then '丢失' when '6' then '报废' when '7' then '调出' when '8' then '降档' when '9' then '其他' else '未知' end eqpStatus,
	case curEqpStatus when '6' then convert(char(10), e.scrapDate, 120) else '' end scrapDate
from equipmentList e 
left join fundSrc f on e.fCode = f.fCode
left join appDir a on e.aCode = a.aCode
left join college clg on e.clgCode = clg.clgCode
left join useUnit u on e.uCode = u.uCode

--变动日期, 变动描述, 隶属院部代码, 隶属院部, 隶属使用单位代码, 隶属使用单位, 保管人, 附件金额, 单价, 总价
select 	changeDate,changeDesc,
	clgCode, clgName, uCode, uName, keeper,
	annexAmount, price, totalAmount
from eqpLifeCycle
order by rowNum

--测试数据：
insert eqpLifeCycle(eCode,
	eName, eModel, eFormat,
	clgCode, clgName, uCode, uName, keeper,
	annexAmount, price, totalAmount,
	changeDesc) 
select '01010102',
	eName, eModel, eFormat,
	e.clgCode, clg.clgName, e.uCode, u.uName, keeper,
	annexAmount, price, totalAmount,
	'测试设备生命周期表！'
from equipmentList e left join college clg on e.clgCode = clg.clgCode
left join useUnit u on e.uCode = u.uName
where eCode = '01010102'

select * from eqpLifeCycle



drop PROCEDURE queryEqpLocMan
/*
	name:		queryEqpLocMan
	function:	11.查询指定设备是否有人正在编辑
	input: 
				@eCode char(8),				--设备编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的设备不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-5-22
	UpdateDate: 
*/
create PROCEDURE queryEqpLocMan
	@eCode char(8),				--设备编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from equipmentList where eCode= @eCode),'')
	set @Ret = 0
GO


drop PROCEDURE lockEqp4Edit
/*
	name:		lockEqp4Edit
	function:	12.锁定设备编辑，避免编辑冲突
	input: 
				@eCode char(8),					--设备编号
				@lockManID varchar(10) output,	--锁定人，如果当前设备正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的设备不存在，2:要锁定的设备正在被别人编辑，
							5：该锁定编辑的设备有长事务锁，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-5-22
	UpdateDate: modi by lw 2013-5-27增加长事务锁处理
*/
create PROCEDURE lockEqp4Edit
	@eCode char(8),					--设备编号
	@lockManID varchar(10) output,	--锁定人，如果当前设备正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的设备是否存在
	declare @count as int
	set @count=(select count(*) from equipmentList where eCode= @eCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentList where eCode= @eCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查该设备是否有编辑锁或长事务锁：
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode and lock4LongTime <> 0)
	if (@count>0)
	begin
		set @Ret = 5
		return
	end

	update equipmentList
	set lockManID = @lockManID 
	where eCode= @eCode
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定设备编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了设备['+ @eCode +']为独占式编辑。')
GO

drop PROCEDURE unlockEqpEditor
/*
	name:		unlockEqpEditor
	function:	13.释放设备编辑锁
				注意：本过程不检查设备是否存在！
	input: 
				@eCode char(8),					--设备编号
				@lockManID varchar(10) output,	--锁定人，如果当前设备正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-5-22
	UpdateDate: 
*/
create PROCEDURE unlockEqpEditor
	@eCode char(8),					--设备编号
	@lockManID varchar(10) output,	--锁定人，如果当前设备正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentList where eCode= @eCode),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update equipmentList set lockManID = '' where eCode= @eCode
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

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放设备编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了设备['+ @eCode +']的编辑锁。')
GO

drop PROCEDURE changeEqpKeeping
/*
	name:		changeEqpKeeping
	function:	14.更改设备保管
	input: 
				@eCode char(8),					--设备编号
				@keeperID varchar(10),			--新保管人工号
				@eqpLocate nvarchar(100),		--新设备所在地址

				--维护人:
				@modiManID varchar(10) output,	--维护人，如果当前设备正被人占用编辑则返回该人的工号
	output: 

				@updateTime smalldatetime output,--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：该设备不存在，2：该设备正被别人锁定编辑，
							5：该设备有长事务锁，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-5-22
	UpdateDate: modi by lw 2013-5-27增加长事务锁处理
*/
create PROCEDURE changeEqpKeeping
	@eCode char(8),					--设备编号
	@keeperID varchar(10),			--新保管人工号
	@eqpLocate nvarchar(100),		--新设备所在地址

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前设备正被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的设备是否存在
	declare @count as int
	set @count=(select count(*) from equipmentList where eCode= @eCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentList where eCode= @eCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查该设备是否有编辑锁或长事务锁：
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode and lock4LongTime <> 0)
	if (@count>0)
	begin
		set @Ret = 5
		return
	end

	--获取保管人姓名：
	declare @keeper nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	update equipmentList
	set keeperID = @keeperID, keeper = @keeper, eqpLocate = @eqpLocate,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where eCode= @eCode
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新设备保管', '用户' + @modiManName 
												+ '更新了设备['+ @eCode +']的保管人为：'+ @keeper +'。')
GO




select ROW_NUMBER() OVER(order by eCode asc) AS RowID, eCode,eName, totalAmount,oldKeeper,newKeeperID,newKeeper,'' 
from equipmentAllocationDetail d left join equipmentAllocation e on d.alcNum=e.alcNum  
where d.alcNum in('762') 
order by d.alcNum


select * from equipmentAnnex



