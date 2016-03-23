use hustOA
/*
	强磁场中心办公系统-设备管理
	author:		卢苇
	CreateDate:	2012-11-20
	UpdateDate: 
*/
--1.equipmentList（设备表）：
--特殊设备要增加字段，做成派生结构
--查询锁定编辑或有长事务的设备
select * from equipmentList where eCode='20131436'
select * from equipmentAnnex where eCode='20131436'
select e.eCode, e.eName, e.lockManID, u.cName lockMan, u.telNum, u.mobileNum,
	case e.lock4LongTime when '0' then '' when '1' then '设备清查单' 
	when '2' then '设备调拨单' when '3' then '设备报废单' end invoiceType, e.lInvoiceNum
from equipmentList e left join userInfo u on e.lockManID = u.jobNumber 
where isnull(e.lockManID,'')<>'' or e.lock4LongTime <> 0

update equipmentList
set unit = g.unit
from eqpAcceptInfo e left join GBT14885 g on e.aTypeCode = g.aTypeCode

update equipmentList
set obtainMode = 1,purchaseMode=2
select eCode,'自制' as status 
use hustOA

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
alter table equipmentList add	barCode varchar(14) null		--一维条码：add by lw 2012-11-18


alter TABLE equipmentList add currency smallint null		--本系统特有字段：币种,由第3号代码字典定义
alter TABLE equipmentList add cPrice numeric(12, 2) null	--本系统特有字段：外币计价
alter TABLE equipmentList add cTotalAmount numeric(12, 2) null--本系统特有字段：外币总价, >0（单价+附件价格）修改类型，约束小数点
alter TABLE equipmentList add isShare smallint default(0)	--本系统特有字段：是否共享，0->不共享，1->共享
alter TABLE equipmentList alter column aTypeCode varchar(7) null,		--本系统不适用：分类编号（财）分类编号（财）=f（分类编号（数））使用映射表

select * from equipmentList where lock4LongTime='0'
--注意：本系统中附件不能随主件录入！
select * from equipmentList
drop table equipmentList
CREATE TABLE equipmentList(
	eCode char(8) not null,			--主键：设备编号,本系统使用第6号号码发生器产生（4位年份代码+4位流水号）
	acceptApplyID char(12) null,	--本系统不适用：对应的验收单号
	eName nvarchar(30) not null,	--设备名称（仪器名称）:
	eModel nvarchar(20) not null,	--设备型号
	eFormat nvarchar(30) not null,	--设备规格
	unit nvarchar(10) null,			--计量单位：该单位从GBT14885表中获取
	cCode char(3) not null,			--国家代码：
	factory	nvarchar(20) null,		--生产厂家
	makeDate smalldatetime null,	--出厂日期，不允许空值，在界面上拦截
	serialNumber nvarchar(20) null,	--出厂编号
	business nvarchar(20) null,		--销售单位
	buyDate smalldatetime null,		--购置日期，不允许空值，在界面上拦截
	annexName nvarchar(20) null,	--附件名称
	annexCode nvarchar(20) null,	--随机附件编号
	annexAmount	numeric(12, 2) null,--附件金额（就是附件单价）修改类型，约束小数点

	eTypeCode char(8) not null,		--分类编号（教）：这里只填门类码
	eTypeName nvarchar(30) not null,--教育部分类名称
	aTypeCode varchar(7) null,		--本系统不适用：分类编号（财）分类编号（财）=f（分类编号（数））使用映射表
									--根据GB/T 14885-2010规定将编码延长到7位

	fCode char(2) not null,			--经费来源代码
	aCode char(2) null,				--本系统不适用：使用方向代码：老数据中有空值，需要用户确认是否允许空值！！！不允许！
	price numeric(12, 2) null,		--单价，>0 修改类型，约束小数点
	totalAmount numeric(12, 2) null,--总价, >0（单价+附件价格）修改类型，约束小数点
	
	currency smallint null,			--本系统特有字段：币种,由第3号代码字典定义
	cPrice numeric(12, 2) null,		--本系统特有字段：外币计价
	cTotalAmount numeric(12, 2) null,--本系统特有字段：外币总价, >0（单价+附件价格）修改类型，约束小数点
	
	clgCode char(3) not null,		--学院代码:本系统中使用固定值
	uCode varchar(8) not null,		--使用单位代码
	keeperID varchar(10) null,		--保管人工号（设备管理员）,add by lw 2011-10-12计划增加设备的派生信息，如果管理员登记了，派生信息只能由管理员填写
	keeper nvarchar(30) null,		--保管人
	eqpLocate nvarchar(100) null,	--设备所在地址:设备所在地add by lw 2012-5-22增加设备认领功能
	
	isShare smallint default(0),	--本系统特有字段：是否共享，0->不共享，1->共享

	notes nvarchar(50) null,		--备注
	acceptDate smalldatetime null,	--本系统不适用：验收日期
	oprManID varchar(10) null,		--经办人工号
	oprMan nvarchar(30) null,		--经办人
	acceptManID varchar(10) null,	--本系统不适用：验收人工号
	acceptMan nvarchar(30) null,	--本系统不适用：验收人
	
	barCode varchar(30) null,		--本系统不适用：一维条码
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

	lock4LongTime char(1) default('0'),	--长事务锁：add by lw 2012-7-28
										--主要是为清查等功能锁定设备，防止在锁定期间内设备的添加附件、调拨或报废
											--'0'->未锁定
											--'1'->清查锁定
											--'2'->调拨锁定
											--'3'->报废锁定
											--'4'->验收单锁定（添加附件验收单锁定）：
													--因为添加附件允许取消审核并修改生成的验收单，所以要锁定
											--'5'->设备信息更正申请锁定 add by lw 2012-19-13
	lInvoiceNum varchar(30) null,		--长事务锁锁定的票据号
	
	obtainMode int null,				--本系统不适用：取得方式：由第11号代码字典定义，add by lw 2012-10-1
	purchaseMode int null,				--本系统不适用：采购组织形式：由第18号代码字典定义，add by lw 2012-10-1

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
--2.equipmentAnnex（设备附件）：设备附件可以与设备分开购置
drop table equipmentAnnex
CREATE TABLE equipmentAnnex(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号
	acceptApplyID char(12) null,		--本系统不适用：对应的验收单号	--因为附件可以独立验收，所以增加如下字段：add by lw 2011-4-5
	eCode char(8) not null,				--外键：设备编号
	annexName nvarchar(20) not null,	--附件名称
	annexModel nvarchar(20) null,		--本系统特有字段：型号
	annexFormat nvarchar(30) null,		--规格

	unit nvarchar(10) null,				--本系统特有字段：计量单位：该单位从GBT14885表中获取
	serialNumber nvarchar(2100) null,	--本系统特有字段：出厂编号

	
	--因为附件可以独立验收，所以增加如下字段：add by lw 2011-4-5
	cCode char(3) not null,				--国家代码：add by lw 2011-10-26
	fCode char(2) not null,				--经费来源代码：可以与主设备的经费来源不同！如果以设备的经费来源统计，则忽略附件的经费来源。
	factory	nvarchar(20) null,			--生产厂家
	makeDate smalldatetime null,		--出厂日期
	business nvarchar(20) null,			--销售单位
	buyDate smalldatetime null,			--购置日期
	-----------------------------------------------
	
	quantity int null,					--数量
	price numeric(12, 2) null,			--单价
	totalAmount numeric(12, 2) null,	--总价
	currency smallint null,				--本系统特有字段：币种,由第3号代码字典定义
	cPrice numeric(12, 2) null,			--本系统特有字段：外币计价
	cTotalAmount numeric(12, 2) null,	--外币总价

	oprManID varchar(10) null,			--经办人工号 add by lw 2012-8-12
	oprMan nvarchar(30) null,			--经办人
	acceptMan nvarchar(30) null,		--本系统不适用：验收人
	acceptManID varchar(10) null,		--本系统不适用：验收人工号:add by lw 2011-10-26
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
	eFormat nvarchar(30) not null,	--设备规格
	
	--现隶属信息：
	clgCode char(3) not null,		--本系统不适用：学院代码
	clgName nvarchar(30) null,		--本系统不适用：学院名称
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
use hustOA
alter TABLE eqpStatusInfo alter column invoiceType char(1) null		--对应生成状态的票据类型：'1':验收单号，'5':设备清查单号
alter TABLE eqpStatusInfo alter column invoiceNum varchar(30) null		--对应生成状态的票据号，可能是验收单号或设备清查单号等
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
	invoiceType char(1) null,		--对应生成状态的票据类型：'1':验收单号，'5':设备清查单号
	invoiceNum varchar(30) null,		--对应生成状态的票据号，可能是验收单号或设备清查单号等
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


drop PROCEDURE queryEqpLocMan
/*
	name:		queryEqpLocMan
	function:	1.查询指定设备是否有人正在编辑
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
	function:	2.锁定设备编辑，避免编辑冲突
	input: 
				@eCode char(8),					--设备编号
				@lockManID varchar(10) output,	--锁定人，如果当前设备正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的设备不存在，2:要锁定的设备正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2012-5-22
	UpdateDate: 
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
	function:	3.释放设备编辑锁
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

delete equipmentList where isnull(uCode,'')=''
delete shareEqpStatus where eCode not in (select ecode from equipmentList)
drop PROCEDURE addEqpInfo
/*
	name:		addEqpInfo
	function:	4.添加设备信息
				本过程根据设备管理系统审核验收单单修改而来
				注意：该存储过程自动锁定单据
	input: 
				@eTypeCode char(8),			--分类编号（教）
				@eTypeName nvarchar(30),	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
				@eName nvarchar(30),		--设备名称
				@eModel nvarchar(20),		--设备型号
				@eFormat nvarchar(30),		--设备规格
				@cCode char(3),				--国家代码
				@factory nvarchar(20),		--出厂厂家
				@makeDate smalldatetime,	--出厂日期，在界面上拦截
				@serialNumber nvarchar(2100),--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
				@buyDate smalldatetime,		--购置日期
				@business nvarchar(20),		--销售单位
				@fCode char(2),				--经费来源代码
				@uCode varchar(8),			--使用单位代码
				@keeperID varchar(10),		--保管人工号,add by lw 2012-8-10
				@price numeric(12,2),		--单价，>0
				@sumNumber int,				--数量

				@currency smallint,			--本系统特有字段：币种,由第3号代码字典定义
				@cPrice numeric(12, 2),		--本系统特有字段：外币计价
				
				@oprManID varchar(10),		--经办人工号,add by lw 2012-8-10
				@notes nvarchar(50),		--备注
				@photoXml xml,				--设备照片：add by lw 2012-10-25
				@eqpLocate nvarchar(100),	--设备所在地址:设备所在地add by lw 2012-12-19
				@isShare smallint,			--本系统特有字段：是否共享，0->不共享，1->共享

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output	--添加时间
	author:		卢苇
	CreateDate:	2012-12-20
	UpdateDate: 
*/
create PROCEDURE addEqpInfo
	@eTypeCode char(8),			--分类编号（教）
	@eTypeName nvarchar(30),	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
	@eName nvarchar(30),		--设备名称
	@eModel nvarchar(20),		--设备型号
	@eFormat nvarchar(30),		--设备规格
	@cCode char(3),				--国家代码
	@factory nvarchar(20),		--出厂厂家
	@makeDate smalldatetime,	--出厂日期，在界面上拦截
	@serialNumber nvarchar(2100),--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
	@buyDate smalldatetime,		--购置日期
	@business nvarchar(20),		--销售单位
	@fCode char(2),				--经费来源代码
	@uCode varchar(8),			--使用单位代码
	@keeperID varchar(10),		--保管人工号,add by lw 2012-8-10
	@price numeric(12,2),		--单价，>0
	@sumNumber int,				--数量

	@currency smallint,			--本系统特有字段：币种,由第3号代码字典定义
	@cPrice numeric(12, 2),		--本系统特有字段：外币计价
	
	@oprManID varchar(10),		--经办人工号,add by lw 2012-8-10
	@notes nvarchar(50),		--备注
	@photoXml xml,				--设备照片：add by lw 2012-10-25
	@eqpLocate nvarchar(100),	--设备所在地址:设备所在地add by lw 2012-12-19
	@isShare smallint,			--本系统特有字段：是否共享，0->不共享，1->共享

	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @clgCode char(3),@clgName nvarchar(30)	--学院代码
	set @clgCode = '001'	--这是暂时设定的代码，需要根据学校分配的代码改写！
	set @clgName = '脉冲强磁场科学中心'

	--取计量单位：
	declare @unit nvarchar(10)
	set @unit = '台/套'
	
	--获取部门名称：
	declare @uName nvarchar(30)	--学院名称/使用单位名称
	set @uName = (select uName from useUnit where uCode = @uCode)

	--取保管人、经办人、创建人的姓名：
	declare @keeper nvarchar(30),@oprMan nvarchar(30),@createManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @oprMan = isnull((select cName from userInfo where jobNumber = @oprManID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	--构造出厂编号：
	declare @xmlSerialNumber xml
	set @xmlSerialNumber = '<s>'+REPLACE(@serialNumber,'|','</s><s>')+'</s>'

	set @createTime = getdate()
	--生成设备清单：
	begin tran
		declare @rowID int --行号，用来取设备出厂编号和附件编号的序列号
		set @rowID = 1
		declare @length int
		set @length = @sumNumber
		
		declare @eCode char(8)
		--逐个生成设备清单：
		while (@sumNumber>0)
		begin
			--使用号码发生器产生设备号码：
			declare @curNumber varchar(50)
			exec dbo.getClassNumber 6, 1, @curNumber output
			set @eCode = @curNumber

			declare @curSerialNumber nvarchar(20)	--当前设备的出厂编号
			set @curSerialNumber = (select cast(@xmlSerialNumber.query('(/s)[sql:variable("@rowID")]/text()') as nvarchar(20)))
			--生成设备清单：
			insert equipmentList(eCode, eName, eModel, eFormat, unit, cCode, factory, business,
				eTypeCode, eTypeName, 
				fCode, makeDate, buyDate, price, totalAmount, currency, cPrice, cTotalAmount,
				clgCode, uCode, keeperID, keeper, eqpLocate, notes,
				acceptDate, oprManID, oprMan, curEqpStatus,
				serialNumber, isShare,
				--最新维护情况:
				modiManID, modiManName, modiTime)
			values(@eCode, @eName, @eModel, @eFormat, @unit, @cCode, @factory, @business,
				@eTypeCode,@eTypeName,
				@fCode, @makeDate, @buyDate, @price, @price, @currency, @cPrice, @cPrice,
				@clgCode, @uCode, @keeperID, @keeper, @eqpLocate, @notes,
				@buyDate, @oprManID, @oprMan, '1',
				@curSerialNumber, @isShare,
				--最新维护情况:
				@createManID, @createManName, @createTime)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			--登记设备的生命周期：
			insert eqpLifeCycle(eCode,eName, eModel, eFormat,
				clgCode, clgName, uCode, uName, keeper,
				price, totalAmount,
				changeDate, changeDesc,changeType,changeInvoiceID) 
			values(@eCode, @eName, @eModel, @eFormat, 
				@clgCode, @clgName, @uCode, @uName, @keeper,
				@price, @price,
				@createTime, '登记设备['+@eCode+']','登记',null)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
			
			--生成设备现状库：add by lw 2012-10-27
			--只有数量为1的验收单允许输入设备照片，这需要在UI上做限制
			if (@length = 1)
			begin
				insert eqpStatusInfo(eCode, eName, sNumber, checkDate, keeperID, keeper, 
							eqpLocate, checkStatus,		--设备状态：
											--0：状态不明 --这种状态自动变更为正常
											--1：正常；
											--3：待修；
											--4：待报废；
											--5：有帐无物；
											--6：无帐无物；--这种状态应该无法确定！
											--9：其他。
							statusNotes, invoiceType, invoiceNum)
				values(@eCode, @eName, 1, @createTime, @keeperID, @keeper, @eqpLocate, 1,
						'设备入库状态', '1', null)

				insert eqpStatusPhoto(eCode, eName, sNumber, photoDate, aFilename, notes)
				select @eCode, @eName, 1, cast(T.photo.query('data(./@photoDate)') as varchar(10)), 
					cast(T.photo.query('data(./@aFileName)') as varchar(128)), 
					cast(T.photo.query('data(./@notes)') as nvarchar(100))
				from @photoXml.nodes('/root/photo') as T(photo)
			end
			set @rowID = @rowID + 1
			set @sumNumber = @sumNumber -1
		end
	commit tran	
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '登记设备', '系统根据用户' + @createManName + 
					'的要求登记了' + str(@sumNumber) + '台/套设备。')
GO

drop PROCEDURE delEqpInfo
/*
	name:		delEqpInfo
	function:	5.删除指定的设备
	input: 
				@eCode char(8)					--设备编号
				@delManID varchar(10) output,	--删除人，如果当前验收申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的设备不存在，2：要删除的设备正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2012-12-20
	UpdateDate: 

*/
create PROCEDURE delEqpInfo
	@eCode char(8),					--设备编号
	@delManID varchar(10) output,	--删除人，如果当前验收申请单正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
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
	if ((@locker<>'' and @locker<>@delManID) or @lock4LongTime<>'0')
	begin
		set @Ret = 2
		return
	end

	delete equipmentList where eCode = @eCode
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除设备', '用户' + @delManName
												+ '删除了设备['+ @eCode +']。')

GO


drop PROCEDURE addAnnex
/*
	name:		addAnnex
	function:	6.添加附件
				根据设备管理系统中的添加附件修改而成.
				注意：本存储过程使用主设备的锁
	input: 
				@eCode char(8),				--主设备编号
				@annexName nvarchar(20),	--附件名称
				@annexModel nvarchar(20),	--本系统特有字段：型号
				@annexFormat nvarchar(30),	--规格

				@serialNumber nvarchar(2100),--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
				
				@cCode char(3),				--国家代码：add by lw 2011-10-26
				@fCode char(2),				--经费来源代码：可以与主设备的经费来源不同！如果以设备的经费来源统计，则忽略附件的经费来源。
				@factory	nvarchar(20),	--生产厂家
				@makeDate smalldatetime,	--出厂日期
				@business nvarchar(20),		--销售单位
				@buyDate smalldatetime,		--购置日期
				-----------------------------------------------
				
				@quantity int,				--数量
				@price numeric(12, 2),		--单价
				@currency smallint,			--本系统特有字段：币种,由第3号代码字典定义
				@cPrice numeric(12, 2),		--本系统特有字段：外币计价

				@oprManID varchar(10),		--经办人工号 add by lw 2012-8-12

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
	author:		卢苇
	CreateDate:	2012-12-20
	UpdateDate: 
*/
create PROCEDURE addAnnex
	@eCode char(8),				--主设备编号
	@annexName nvarchar(20),	--附件名称
	@annexModel nvarchar(20),	--本系统特有字段：型号
	@annexFormat nvarchar(30),	--规格

	@serialNumber nvarchar(2100),--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
	
	@cCode char(3),				--国家代码：add by lw 2011-10-26
	@fCode char(2),				--经费来源代码：可以与主设备的经费来源不同！如果以设备的经费来源统计，则忽略附件的经费来源。
	@factory	nvarchar(20),	--生产厂家
	@makeDate smalldatetime,	--出厂日期
	@business nvarchar(20),		--销售单位
	@buyDate smalldatetime,		--购置日期
	-----------------------------------------------
	
	@quantity int,				--数量
	@price numeric(12, 2),		--单价
	@currency smallint,			--本系统特有字段：币种,由第3号代码字典定义
	@cPrice numeric(12, 2),		--本系统特有字段：外币计价

	@oprManID varchar(10),		--经办人工号 add by lw 2012-8-12

	@createManID varchar(10) output,	--创建人工号：就是添加附件人（验收人）
	@Ret		int output,
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--取计量单位：
	declare @unit nvarchar(10)
	set @unit = '台/套'

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
													or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 4
		return
	end
	
	--取经办人/维护人的姓名：
	declare @oprMan nvarchar(30),@createManName nvarchar(30)
	set @oprMan = isnull((select cName from userInfo where jobNumber = @oprManID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--计算金额：
	declare @sumAmount numeric(12,2)			--合计金额
	set @sumAmount = @price * @quantity

	set @createTime = getdate()
	begin tran
		insert equipmentAnnex(eCode, annexName, annexModel, annexFormat, unit, 
						fCode, cCode, factory, makeDate, business, buyDate, 
						quantity, price, totalAmount, currency, cPrice, cTotalAmount,
						oprManID, oprMan)
		values(@eCode, @annexName, @annexModel, @annexFormat, @unit, 
						@fCode, @cCode, @factory, @makeDate, @business, @buyDate, 
						@quantity, @price, @sumAmount, @currency, @cPrice, @quantity*@cPrice,
						@oprManID, @oprMan)
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
			totalAmount = isnull(totalAmount,0) + @sumAmount,
			cTotalAmount = ISNULL(cTotalAmount,0) + @quantity*@cPrice
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
			@createTime, '添加附件：' + @annexName, '添加附件',null
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
	values(@createManID, @createManName, @createTime, '添加附件', '系统根据用户' + @createManName + 
					'的要求给设备['+ @eCode +']添加了附件'+str(@quantity)+'台/套['+ @annexName +']。')
GO
--测试:
use hustOA
declare @Ret		int
declare @createTime smalldatetime 
exec dbo.addAnnex 'A5000725','ceshi','*','*','123456','156','1 ','IBM','2012-12-01','lan','2012-12-12',
			5,7500,'502',200,'0000000000','0000000000', @Ret  output, @createTime output
select @Ret

drop PROCEDURE updateAnnex
/*
	name:		updateAnnex
	function:	7.修改设备附件
				根据设备管理系统中的修改附件修改而成.
				注意：本存储过程使用主设备的锁
	input: 
				@eCode char(8),				--主设备编号
				@rowNum int,				--附件行号
				@annexName nvarchar(20),	--附件名称
				@annexModel nvarchar(20),	--本系统特有字段：型号
				@annexFormat nvarchar(30),	--规格

				--@serialNumber nvarchar(2100),--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
				
				@cCode char(3),				--国家代码：add by lw 2011-10-26
				@fCode char(2),				--经费来源代码：可以与主设备的经费来源不同！如果以设备的经费来源统计，则忽略附件的经费来源。
				@factory	nvarchar(20),	--生产厂家
				@makeDate smalldatetime,	--出厂日期
				@business nvarchar(20),		--销售单位
				@buyDate smalldatetime,		--购置日期
				-----------------------------------------------
				
				@quantity int,				--数量
				@price numeric(12, 2),		--单价
				@currency smallint,			--本系统特有字段：币种,由第3号代码字典定义
				@cPrice numeric(12, 2),		--本系统特有字段：外币计价

				@oprManID varchar(10),		--经办人工号 add by lw 2012-8-12

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
							4:指定的附件不存在，
							5:要添加附件的主设备有长事务锁，不允许修改
							9:未知错误
				@modiTime smalldatetime output	--修改时间
	author:		卢苇
	CreateDate:	2012-12-20
	UpdateDate: 
*/
create PROCEDURE updateAnnex
	@eCode char(8),				--主设备编号
	@rowNum int,				--附件行号
	@annexName nvarchar(20),	--附件名称
	@annexModel nvarchar(20),	--本系统特有字段：型号
	@annexFormat nvarchar(30),	--规格

	--@serialNumber nvarchar(2100),--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
	
	@cCode char(3),				--国家代码：add by lw 2011-10-26
	@fCode char(2),				--经费来源代码：可以与主设备的经费来源不同！如果以设备的经费来源统计，则忽略附件的经费来源。
	@factory	nvarchar(20),	--生产厂家
	@makeDate smalldatetime,	--出厂日期
	@business nvarchar(20),		--销售单位
	@buyDate smalldatetime,		--购置日期
	-----------------------------------------------
	
	@quantity int,				--数量
	@price numeric(12, 2),		--单价
	@currency smallint,			--本系统特有字段：币种,由第3号代码字典定义
	@cPrice numeric(12, 2),		--本系统特有字段：外币计价

	@oprManID varchar(10),		--经办人工号 add by lw 2012-8-12

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
													or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end
	
	--判断指定的附件是否存在
	set @count=(select count(*) from equipmentAnnex where eCode = @eCode and rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 4
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
	set @sumAmount = @price * @quantity
	
	--获取原附件金额：
	declare @oldSumAmount numeric(12,2), @oldCTotalAmount numeric(12,2)			--合计金额/外币金额
	select @oldSumAmount = totalAmount, @oldCTotalAmount = cTotalAmount 
	from equipmentAnnex 
	where eCode = @eCode and rowNum = @rowNum
	
	set @modiTime = getdate()
	begin tran
		--修改附件表：
		update equipmentAnnex
		set annexName = @annexName, annexModel = @annexModel, annexFormat = @annexFormat,
			--serialNumber = @serialNumber, 
			cCode = @cCode, fCode = @fCode, 
			factory = @factory, makeDate = @makeDate, business = @business, buyDate = @buyDate,
			quantity = @quantity, price = @price, totalAmount = @sumAmount, currency = @currency, cPrice = @cPrice, cTotalAmount = @quantity * @cPrice,
			oprManID = @oprManID
		where eCode = @eCode and rowNum = @rowNum
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
			annexAmount	= isnull(annexAmount,0) - @oldSumAmount + @sumAmount,
			totalAmount = isnull(totalAmount,0) - @oldSumAmount + @sumAmount,
			cTotalAmount = isnull(cTotalAmount,0) - @oldCTotalAmount + @quantity * @cPrice
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
			'添加附件',null
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
	values(@modiManID, @modiManName, @modiTime, '修改附件', '系统根据用户' + @modiManName + 
					'的要求修改了设备['+ @eCode +']的附件['+ @annexName +']。')
GO

drop PROCEDURE delAnnex
/*
	name:		delAnnex
	function:	7.1.删除设备附件
				注意：本存储过程使用主设备的锁，这个存储过程是设备系统没有的！
	input: 
				@eCode char(8),				--主设备编号
				@rowNum int,				--附件行号
				@delManID varchar(10) output,	--删除人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:主设备不存在，
							2:主设备正别别人锁定编辑，
							3:主设备的状态不对，只有以下设备状态允许删除附件：
									--1：在用，指正在使用的仪器设备；
									--3：待修，指待修或正在修理的仪器设备；
									--8：降档，指经学校批准允许降档次使用、管理的仪器设备；
							4:指定的附件不存在，
							5:主设备有长事务锁，不允许修改
							9:未知错误
	author:		卢苇
	CreateDate:	2013-07-08
	UpdateDate: 
*/
create PROCEDURE delAnnex
	@eCode char(8),				--主设备编号
	@rowNum int,				--附件行号
	@delManID varchar(10) output,	--删除人工号
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

	declare @thisLockMan varchar(10), @curEqpStatus char(1)
	select @thisLockMan = isnull(lockManID,''), @curEqpStatus = curEqpStatus
	from equipmentList where eCode = @eCode
	--检查设备编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
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
					where eCode = @eCode and ((isnull(lockManID,'') <> '' and isnull(lockManID,'') <> @delManID) 
													or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end
	
	--判断指定的附件是否存在
	set @count=(select count(*) from equipmentAnnex where eCode = @eCode and rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 4
		return
	end

	--取删除人的姓名：
	declare @delMan nvarchar(30)
	set @delMan = isnull((select cName from userInfo where jobNumber = @delManID),'')

	--获取原附件名称和金额：
	declare @annexName nvarchar(20)	--附件名称
	declare @oldSumAmount numeric(12,2), @oldCTotalAmount numeric(12,2)			--合计金额/外币金额
	select @annexName = annexName, @oldSumAmount = totalAmount, @oldCTotalAmount = cTotalAmount 
	from equipmentAnnex 
	where eCode = @eCode and rowNum = @rowNum

	declare	@modiTime smalldatetime
	set @modiTime = getdate()
	begin tran
		--删除附件表：
		delete equipmentAnnex where eCode = @eCode and rowNum = @rowNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--更新设备表：
		declare @curAnnexName nvarchar(20)
		set @curAnnexName = isnull((select annexName from equipmentList where eCode = @eCode),'')
		if @curAnnexName = @annexName
			set @curAnnexName = ''
		update equipmentList
		set annexName = @curAnnexName,
			annexAmount	= isnull(annexAmount,0) - @oldSumAmount,
			totalAmount = isnull(totalAmount,0) - @oldSumAmount,
			cTotalAmount = isnull(cTotalAmount,0) - @oldCTotalAmount
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
			@modiTime, '删除附件：' + @annexName,
			'删除附件',null
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
	values(@delManID, @delMan, @modiTime, '删除附件', '系统根据用户' + @delMan + 
					'的要求删除了设备['+ @eCode +']的附件['+ @annexName +']。')
GO

select * from eqpCodeList where isUsed='Y' order by eCode
select top 100 eCode from eqpCodeList where isUsed='N'


drop PROCEDURE setEqpStatus
/*
	name:		setEqpStatus
	function:	8.设置设备状态
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
													or lock4LongTime <> '0'))
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


drop PROCEDURE shareEqp
/*
	name:		shareEqp
	function:	9.共享设备
				注意：该存储过程检测编辑锁，但不一定需要锁定，也不释放编辑锁
	input: 
				@eCode char(8),					--设备编号
				@isShare smallint,				--是否共享：0->不共享，1->共享

				@modiManID varchar(10) output,	--修改人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，
							1:该设备不存在，
							2:该设备正别别人锁定编辑，
							3:该设备有编辑锁或长事务锁
							9:未知错误
	author:		卢苇
	CreateDate:	2012-12-20
	UpdateDate: modi by lw 2013-1-22将该存储过程与共享设备状态表关联
*/
create PROCEDURE shareEqp
	@eCode char(8),					--设备编号
	@isShare smallint,				--是否共享：0->不共享，1->共享
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
													or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 3
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	declare @modiTime smalldatetime
	set @modiTime = getdate()
	begin tran
		update equipmentList
		set isShare = @isShare,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @modiTime
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--登记共享设备状态表：
		set @count = isnull((select count(*) from shareEqpStatus where eCode = @eCode),0)
		if (@count = 0 and @isShare=1)
		begin
			insert shareEqpStatus(eCode, isShare, modiManID, modiManName, modiTime)
			values(@eCode, @isShare, @modiManID, @modiManName, @modiTime)
		end
		else if (@count >0 and @isShare=1)
		begin
			update shareEqpStatus
			set isShare = 1, setoffDate=null
			where eCode = @eCode
		end
		else if (@count >0 and @isShare=0)
		begin
			update shareEqpStatus
			set isShare = 0, setoffDate=@modiTime
			where eCode = @eCode
		end
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	
				
		--登记设备的生命周期：
		declare @changeDesc nvarchar(200),	@changeType nvarchar(10)--变动描述/变动类型
		if (@isShare = 1)
		begin
			set @changeDesc = @modiManName +'将设备设为共享。'
			set @changeType = '共享'
		end
		else
		begin
			set @changeDesc = @modiManName +'将设备设为不共享。'
			set @changeType = '不共享'
		end
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,changeType,changeInvoiceID) 
		select eCode, eName, eModel, eFormat, 
			e.clgCode, c.clgName, e.uCode, u.uName, keeper,
			annexAmount, price, totalAmount,
			@modiTime, @changeDesc,@changeType,''
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
	if (@isShare = 1)
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@modiManID, @modiManName, @modiTime, '共享设备', '用户' + @modiManName + 
						'将设备['+ @eCode +']设置为共享')
	else
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@modiManID, @modiManName, @modiTime, '独占设备', '用户' + @modiManName + 
						'将设备['+ @eCode +']设置为不共享')
GO


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
	
	acceptApplyID char(12) null,	--本系统不适用：对应的验收单号:不允许更正！
	eName nvarchar(30) not null,	--设备名称
	eModel nvarchar(20) null,		--设备型号
	eFormat nvarchar(30) null,		--设备规格
	unit nvarchar(10) null,			--计量单位：不允许更正！
	cCode char(3) not null,			--国家代码
	factory	nvarchar(20) null,		--生产厂家
	makeDate smalldatetime null,	--出厂日期
	serialNumber nvarchar(20) null,	--出厂编号
	business nvarchar(20) null,		--销售单位
	buyDate smalldatetime null,		--购置日期
	annexName nvarchar(20) null,	--不适用本系统：附件名称：不允许更正
	annexCode nvarchar(20) null,	--不适用本系统：随机附件编号:不允许更正！
	annexAmount	numeric(12, 2) null,--不适用本系统：附件金额（就是附件单价）不允许更正

	eTypeCode char(8) not null,		--分类编号（教）最后4位不允许同时为“0”
	eTypeName nvarchar(30) not null,--教育部分类名称
	aTypeCode varchar(7) null,		--不适用本系统：分类编号（财）分类编号（财）=f（分类编号（数））使用映射表
									--根据GB/T 14885-2010规定将编码延长到7位modi by lw 2012-2-23

	fCode char(2) not null,			--经费来源代码
	aCode char(2) null,				--不适用本系统：使用方向代码
	price numeric(12, 2) null,		--单价：不允许更正！
	totalAmount numeric(12, 2) null,--总价：不允许更正！

	currency smallint null,			--本系统特有字段：币种,由第3号代码字典定义；不允许更正！
	cPrice numeric(12, 2) null,		--本系统特有字段：外币计价
	cTotalAmount numeric(12, 2) null,--本系统特有字段：外币总价, >0（单价+附件价格）修改类型，约束小数点；不允许更正！
	
	clgCode char(3) not null,		--学院代码:本系统中使用固定值；不允许更正！
	uCode varchar(8) not null,		--使用单位代码；不允许更正！
	keeperID varchar(10) null,		--保管人工号（设备管理员）,add by lw 2011-10-12计划增加设备的派生信息，如果管理员登记了，派生信息只能由管理员填写；不允许更正！
	keeper nvarchar(30) null,		--保管人：不允许更正！
	eqpLocate nvarchar(100) null,	--设备所在地址
	isShare smallint null,			--本系统特有字段：是否共享，0->不共享，1->共享；不允许更正

	notes nvarchar(50) null,		--备注
	acceptDate smalldatetime null,	--本系统不适用：验收日期：不允许更正！
	oprManID varchar(10) null,		--经办人工号：不允许更正！
	oprMan nvarchar(30) null,		--经办人：不允许更正！
	acceptManID varchar(10) null,	--不适用本系统：验收人工号：不允许更正！
	acceptMan nvarchar(30) null,	--不适用本系统：验收人：不允许更正！
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

	obtainMode int null,			--取得方式
	purchaseMode int null,			--采购组织形式
	barCode varchar(30) null,		--本系统不适用：一维条码
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
				@eFormat nvarchar(30),		--设备规格
				@cCode char(3),				--国家代码
				@factory nvarchar(20),		--出厂厂家
				@makeDate varchar(10),		--出厂日期:采用“yyyy-MM-dd”格式
				@serialNumber nvarchar(20),	--出厂编号
				@business nvarchar(20),		--销售单位
				@buyDate varchar(10),		--购置日期:采用“yyyy-MM-dd”格式

				@eTypeCode char(8),			--分类编号（教）
				@eTypeName nvarchar(30),	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30

				@fCode char(2),				--经费来源代码
				--@aCode char(2),				--使用方向代码

				@eqpLocate nvarchar(100),	--设备所在地址

				@notes nvarchar(50),		--备注
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1:该设备不存在，2:该设备有没有结束的事务（长事务锁或编辑锁）
							3:没有修改任何信息，9:未知错误
				@changeApplyID varchar(12)	--主键：更正申请单号，使用第 5 号号码发生器产生
	author:		卢苇
	CreateDate:	2012-12-20
	UpdateDate: 
*/
create PROCEDURE addChangeEqpInfoApply
	@eCode char(8),				--设备编号
	@changeDesc nvarchar(50),	--更正主要事项描述，如果为空，系统自动扫描修改的字段，生成主项描述
	@applyManID varchar(10),	--申请人工号
	
	@eName nvarchar(30),		--设备名称
	@eModel nvarchar(20),		--设备型号
	@eFormat nvarchar(30),		--设备规格
	@cCode char(3),				--国家代码
	@factory nvarchar(20),		--出厂厂家
	@makeDate varchar(10),		--出厂日期:采用“yyyy-MM-dd”格式
	@serialNumber nvarchar(20),	--出厂编号
	@business nvarchar(20),		--销售单位
	@buyDate varchar(10),		--购置日期:采用“yyyy-MM-dd”格式

	@eTypeCode char(8),			--分类编号（教）
	@eTypeName nvarchar(30),	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30

	@fCode char(2),				--经费来源代码
	--@aCode char(2),				--使用方向代码

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
	if ((@locker<>'' and @locker<>@applyManID) or @lock4LongTime<>'0')
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

	--取计量单位：
	declare @unit nvarchar(10)
	set @unit = '台套'
	
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
	--set @desc = @desc + (select case aCode when @aCode then '' else '、使用方向' end from equipmentList where eCode=@eCode)
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
			business, buyDate, annexName, annexCode, annexAmount, eTypeCode, eTypeName, 
			fCode, price, totalAmount, clgCode, uCode, keeperID, keeper, eqpLocate, notes,
			acceptDate, oprManID, oprMan, acceptManID, acceptMan, curEqpStatus, scrapDate, scrapNum, 
			obtainMode, purchaseMode)
		select @changeApplyID, eCode, @changeDesc, @applyManID, @applyManName, @createTime,
			acceptApplyID, @eName, @eModel, @eFormat, @unit, @cCode, @factory, @makeDate, @serialNumber, 
			@business, @buyDate, annexName, annexCode, annexAmount, @eTypeCode, @eTypeName, 
			@fCode, price, totalAmount, clgCode, uCode, keeperID, keeper, @eqpLocate, @notes,
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
		set lock4LongTime = '5', lInvoiceNum=@changeApplyID
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
					'创建了设备['+@eCode+']信息更正申请单[' + @changeApplyID + ']。')
GO
--测试:
select top 10 * from equipmentList
select * from activeUsers
declare @Ret		int
declare @changeApplyID varchar(12)
exec dbo.addChangeEqpInfoApply '00000001','','00200977','超级显示器','*','19"','156','三星中国','2008-12-10','234234','洪山区创兴电脑',
	'2008-10-10','05010502','彩色终端','1','武汉','测试数据', @Ret output, @changeApplyID output
select @Ret, @changeApplyID


select * from changeEqpInfoApply
select top 10 * from workNote order by actionTime desc
select * from equipmentList where eCode ='00000174'
use hustOA
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
							0:成功，1：指定的设备信息更正单不存在，2：单据已审核生效，不能删除，9：未知错误
	author:		卢苇
	CreateDate:	2012-10-13
	UpdateDate: 

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

	begin tran
		--释放长事务锁：
		update equipmentList
		set lock4LongTime = '0', lInvoiceNum=''
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
							0:成功，1：指定的设备信息更正单不存在，2：单据已审核生效，9：未知错误
	author:		卢苇
	CreateDate:	2012-10-13
	UpdateDate: 

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
				lock4LongTime = '0', lInvoiceNum='',	--释放长事务锁
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
			set lock4LongTime = '0', lInvoiceNum=''
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
							0:成功，1：该设备不存在，2：该设备正被别人锁定编辑，9：未知错误
	author:		卢苇
	CreateDate:	2012-5-22
	UpdateDate: 
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



--附件查询语句：
select a.rowNum,a.annexName, annexModel, annexFormat, a.cCode, c.cName, a.fCode, f.fName,
a.factory, convert(varchar(10),a.makeDate,120) as makeDate, a.business, convert(varchar(10),a.buyDate,120) as buyDate,
a.price, a.quantity, a.totalAmount, a.currency,cd.objDesc currencyName, a.cTotalAmount, a.oprMan
from equipmentAnnex a left join country c on a.cCode = c.cCode 
left join fundSrc f on a.fCode = f.fCode 
left join codeDictionary cd on a.currency = cd.objCode and cd.classCode = 3 
order by a.rowNum


--获取设备生产厂家：
USE hustOA
select distinct top 10 tab.factory
from 
((select distinct factory from equipmentList)
union 
(select distinct factory from equipmentAnnex)) as tab
where tab.factory like '%IBM%' 
order by tab.factory


select * from equipmentList
where eCode='20130073'

update equipmentList
set notes = '测试回车'+CHAR(9)+'测试'
where eCode='20130073'

select '测试回车'+CHAR(9)+'测试'

