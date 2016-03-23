use hustOA
/*
	武大设备管理信息系统-统计
	author:		卢苇
	CreateDate:	2011-2-8
	UpdateDate: 
*/
select * from statisticTemplate
select * from wd.dbo.statisticTemplate
--1.统计模板表
select * from statisticTemplate
drop table statisticTemplate
CREATE TABLE [dbo].[statisticTemplate](
	templateID smallint IDENTITY(1,1) NOT NULL,	--模板ID
	templateType smallint default(0),	--模板类别：0->设备分类汇总，1->金额分段汇总，2->单位分组汇总,3->使用方向，4->经费来源
	templateName nvarchar(30) not null,	--统计模板名称
	templateDesc nvarchar(300) null,	--统计模板的描述
	
	--统计的参数：
	--del by lw 2011-2-19因为在统计的时候可以方便地设定这两个参数，所以删除！
	--statisticUnitType int not null,		--统计范围:0->全校，1->院部
	--particleSize int not null,			--分组（统计单位或颗粒度）:0->全校，1->院部，2->使用单位，当模板类型为：2->单位分组时只能选择1、2
	
	--维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间
	--编辑锁定人：
	lockManID varchar(18) null,			--当前正在锁定编辑的人身份号码
 CONSTRAINT [PK_statisticTemplate] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

insert statisticTemplate(templateType, templateName, templateDesc)
values(0, '信息化资产分类统计模板','')
insert statisticTemplate(templateType, templateName, templateDesc)
values(0, '存量资产（车辆）分类统计模板','')

select * from wd.dbo.subTotalTemplateQuota
--2.分类汇总统计模板的指标：
drop table subTotalTemplateQuota
CREATE TABLE [dbo].[subTotalTemplateQuota](
	templateID smallint not null,	--模板ID
	rowNum smallint NOT NULL,		--序号
	eTypeCode char(8) not null,		--分类编号（教）
	eTypeName nvarchar(30) not null,--分类名称：注意这里的分类名称可能与分类编码中的名称不一致！！
 CONSTRAINT [PK_subTotalTemplateQuota] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--外键：
ALTER TABLE [dbo].[subTotalTemplateQuota] WITH CHECK ADD CONSTRAINT [FK_subTotalTemplateQuota_statisticTemplate] FOREIGN KEY([templateID])
REFERENCES [dbo].[statisticTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[subTotalTemplateQuota] CHECK CONSTRAINT [FK_subTotalTemplateQuota_statisticTemplate] 
GO

--注意：当分类编码可能是类别码！最后两位为0时是小类，最后4位为0时是中类，最后6位为0时是大类。
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,1, '05010105', 'PC机') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,2, '05010104', '服务器') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,3, '05010904', '交换机') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,4, '05010710', '测金系统（软件）') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,5, '05010508', '硬磁盘驱动（存储）') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,6, '05010535', '磁盘存储')
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,7, '03040310', '投影仪') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,8, '03160602', '投影机') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,9, '05010501', '针式、彩色喷墨打印机') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,10, '05010549', '激光打印机') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,11, '05010550', '扫描仪') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,12, '05010902', '路由器') 


--------车辆统计
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,1, '04130301', '小轿车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,2, '04130201', '轻型越野汽车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,3, '04130202', '中型越野汽车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,4, '04130300', '客车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,5, '04130302', '大轿车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,6, '04130303', '旅行车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,7, '04130103', '货车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,8, '04130104', '微型汽车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,9, '04130105', '自卸载重汽车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,10, '04130400', '特种车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,11, '04130401', '轻便干粉消防车/消防车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,12, '04130402', '救护车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,13, '04130404', '洒水车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,14, '04130407', '工具车（保修工作车）/双排专用车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,15, '04130408', '高空作业车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,16, '04130412', '垃圾车/垃圾自上车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,17, '04130500', '摩托车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,18, '04130501', '三轮摩托车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,19, '04130503', '两轮摩托车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,20, '04130601', '轻型摩托车') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,21, '04130602', '动力翻斗车/翻斗车') 

--3.金额分段统计模板的指标：
drop table moneySectionQuota
CREATE TABLE [dbo].[moneySectionQuota](
	templateID smallint not null,	--模板ID
	rowNum smallint NOT NULL,		--序号
	startMoney money null,			--起点金额
	endMoney money null,			--结束金额：-1表示无穷大
 CONSTRAINT [PK_moneySectionQuota] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--外键：
ALTER TABLE [dbo].[moneySectionQuota] WITH CHECK ADD CONSTRAINT [FK_moneySectionQuota_statisticTemplate] FOREIGN KEY([templateID])
REFERENCES [dbo].[statisticTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[moneySectionQuota] CHECK CONSTRAINT [FK_moneySectionQuota_statisticTemplate]
GO

--4.使用方向统计模板的指标：
drop table appDirQuota
CREATE TABLE [dbo].[appDirQuota](
	templateID smallint not null,	--模板ID
	rowNum smallint NOT NULL,		--序号
	aCode char(2) not null,			--使用方向代码
	aName nvarchar(20) not null,	--使用方向名称	
 CONSTRAINT [PK_appDirQuota] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--外键：
ALTER TABLE [dbo].[appDirQuota] WITH CHECK ADD CONSTRAINT [FK_appDirQuota_statisticTemplate] FOREIGN KEY([templateID])
REFERENCES [dbo].[statisticTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[appDirQuota] CHECK CONSTRAINT [FK_appDirQuota_statisticTemplate]
GO

--5.经费来源统计模板的指标：
drop table fundSrcQuota
CREATE TABLE [dbo].[fundSrcQuota](
	templateID smallint not null,	--模板ID
	rowNum smallint NOT NULL,		--序号
	fCode char(2) not null,			--经费来源代码
	fName nvarchar(20) not null,	--经费来源名称	
 CONSTRAINT [PK_fundSrcQuota] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--外键：
ALTER TABLE [dbo].[fundSrcQuota] WITH CHECK ADD CONSTRAINT [FK_fundSrcQuota_statisticTemplate] FOREIGN KEY([templateID])
REFERENCES [dbo].[statisticTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[fundSrcQuota] CHECK CONSTRAINT [FK_fundSrcQuota_statisticTemplate]
GO

--统计模板编辑存储过程：
drop PROCEDURE checkStatisticTemplate
/*
	name:		checkStatisticTemplate
	function:	0.检查指定的统计模板是否已经存在
	input: 
				@templateName nvarchar(30),	--统计模板名称
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2011-2-9
	UpdateDate: 
*/
create PROCEDURE checkStatisticTemplate
	@templateName nvarchar(30),		--统计模板名称
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该统计模板名称是否重名：
	declare @count int
	set @count = (select count(*) from statisticTemplate where templateName = @templateName)
	set @Ret = @count
GO

drop PROCEDURE addStatisticTemplate
/*
	name:		addStatisticTemplate
	function:	1.添加统计模板
				注意：本存储过程锁定编辑！
	input: 
				@templateType smallint,		--模板类别：0->设备分类汇总，1->金额分段汇总，2->单位分组,3->使用方向，4->经费来源
				@templateName nvarchar(30),	--统计模板名称
				@templateDesc nvarchar(300),--统计模板的描述
				
				----统计的参数：
				--@statisticUnitType int,		--统计范围:0->全校，1->院部
				--@particleSize int,			--统计单位（颗粒度）:0->全校，1->院部，2->使用单位
				
				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该模板已经登记过，9：未知错误
				@templateID smallint output,	--模板ID
				@createTime smalldatetime output
	author:		卢苇
	CreateDate:	2011-2-9
	UpdateDate:modi by lw 2011-2-19删除统计范围和分组依据两个条件
			   modi by lw 2011-3-10根据毕处要求增加“使用方向、经费来源”两种模板
*/
create PROCEDURE addStatisticTemplate
	@templateType smallint,		--模板类别：0->设备分类汇总，1->金额分段汇总，2->单位分组,3->使用方向，4->经费来源
	@templateName nvarchar(30),	--统计模板名称
	@templateDesc nvarchar(300),--统计模板的描述
	
	--统计的参数：
	--@statisticUnitType int,		--统计范围:0->全校，1->院部
	--@particleSize int,			--统计单位（颗粒度）:0->全校，1->院部，2->使用单位
	
	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@templateID smallint output,	--模板ID
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该模板是否重名：
	declare @count int
	set @count = (select count(*) from statisticTemplate where templateName = @templateName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert statisticTemplate(templateType, templateName, templateDesc, 
						lockManID, modiManID, modiManName, modiTime) 
	values (@templateType, @templateName, @templateDesc, 
			@createManID, @createManID, @createManName, @createTime)
	set @templateID =(select templateID from statisticTemplate where templateName = @templateName)
	
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加统计模板', '系统根据用户' + @createManName + 
					'的要求添加了统计模板[' + @templateName + ']。')
GO

drop PROCEDURE queryStatisticTemplateLocMan
/*
	name:		queryStatisticTemplateLocMan
	function:	2.查询指定统计模板是否有人正在编辑
	input: 
				@templateID smallint,		--模板ID
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的统计模板不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2011-2-9
	UpdateDate: 
*/
create PROCEDURE queryStatisticTemplateLocMan
	@templateID smallint,		--模板ID
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	set @Ret = 0
GO


drop PROCEDURE lockStatisticTemplate4Edit
/*
	name:		lockStatisticTemplate4Edit
	function:	3.锁定统计模板编辑，避免编辑冲突
	input: 
				@templateID smallint,		--模板ID
				@lockManID varchar(10) output,	--锁定人，如果当前模板正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的统计模板不存在，2:要锁定的统计模板正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-2-9
	UpdateDate: 
*/
create PROCEDURE lockStatisticTemplate4Edit
	@templateID smallint,		--模板ID
	@lockManID varchar(10) output,	--锁定人，如果当前模板正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的统计模板是否存在
	declare @count as int
	set @count=(select count(*) from statisticTemplate where templateID = @templateID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update statisticTemplate
	set lockManID = @lockManID 
	where templateID = @templateID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定统计模板编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了第[' + str(@templateID,6) + ']号统计模板为独占式编辑。')
GO

drop PROCEDURE unlockStatisticTemplateEditor
/*
	name:		unlockStatisticTemplateEditor
	function:	4.释放统计模板编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@templateID smallint,		--模板ID
				@lockManID varchar(10) output,	--锁定人，如果当前统计模板正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2011-2-9
	UpdateDate: 
*/
create PROCEDURE unlockStatisticTemplateEditor
	@templateID smallint,		--模板ID
	@lockManID varchar(10) output,	--锁定人，如果当前统计模板正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update statisticTemplate set lockManID = '' where templateID = @templateID
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
	values(@lockManID, @lockManName, getdate(), '释放统计模板编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了第[' + str(@templateID,6) + ']号统计模板的编辑锁。')
GO

drop PROCEDURE addSubTotalTemplateQuota
/*
	name:		addSubTotalTemplateQuota
	function:	5.添加设备分类汇总统计指标
				注意：这个存储过程先删除全部的明细数据，然后再添加。
				另使用设备分类约束条件的模板都要调用该存储过程保存数据！
	input: 
				@templateID smallint,	--模板ID
				@quotaDetail xml,		--使用xml存储的指标：N'<root>
																	--	<row id="1">
																	--		<eTypeCode>05010549</eTypeCode>
																	--		<eTypeName>激光打印机</eTypeName>
																	--	</row>
																	--	<row id="2">
																	--		<eTypeCode>05010550</eTypeCode>
																	--		<eTypeName>扫描仪</eTypeName>
																	--	</row>
																	--	...
																	--</root>'
				--维护人:
				@modiManID varchar(10) output,	--维护人，如果当前统计模板正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的统计模板正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-2-9
	UpdateDate: 
*/
create PROCEDURE addSubTotalTemplateQuota
	@templateID smallint,	--模板ID
	@quotaDetail xml,		--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<eTypeCode>05010549</eTypeCode>
														--		<eTypeName>激光打印机</eTypeName>
														--	</row>
														--	<row id="2">
														--		<eTypeCode>05010550</eTypeCode>
														--		<eTypeName>扫描仪</eTypeName>
														--	</row>
														--	...
														--</root>'
	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前统计模板正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
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

	--更新插入设备分类汇总指标：
	begin tran
		delete subTotalTemplateQuota where templateID = @templateID

		insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
		select @templateID, cast(cast(T.x.query('data(./@id)') as varchar(8)) as smallint) rowNum, 
				cast(T.x.query('data(./eTypeCode)') as char(8)) eTypeCode, 
				cast(T.x.query('data(./eTypeName)') as nvarchar(30)) eTypeName
		from(select @quotaDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
		
		update statisticTemplate
		set modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where templateID = @templateID
		set @Ret = 0
	commit tran
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新插入分类汇总指标', '用户' + @modiManName 
												+ '更新插入了第['+ str(@templateID,6) +']号统计模板的设备分类汇总指标。')
GO
--测试：
declare	@quotaDetail xml
set @quotaDetail = N'<root>
						<row id="1">
							<eTypeCode>05010549</eTypeCode>
							<eTypeName>激光打印机</eTypeName>
						</row>
						<row id="2">
							<eTypeCode>05010550</eTypeCode>
							<eTypeName>扫描仪</eTypeName>
						</row>
					</root>'
declare @updateTime smalldatetime
declare @Ret int
exec dbo.addSubTotalTemplateQuota 1, @quotaDetail, '2010112301', @updateTime output, @Ret output
select @Ret

select * from subTotalTemplateQuota

drop PROCEDURE addMoneySectionQuota
/*
	name:		addMoneySectionQuota
	function:	6.添加金额分段汇总统计指标
				注意：这个存储过程先删除全部的明细数据，然后再添加。本存储过程维护两个从表！
	input: 
				@templateID smallint,	--模板ID
				@quotaDetail xml,		--使用xml存储的分类约束条件：N'<root>
																	--	<row id="1">
																	--		<eTypeCode>05010549</eTypeCode>
																	--		<eTypeName>激光打印机</eTypeName>
																	--	</row>
																	--	<row id="2">
																	--		<eTypeCode>05010550</eTypeCode>
																	--		<eTypeName>扫描仪</eTypeName>
																	--	</row>
																	--	...
																	--</root>'
				@moneySectionDetail xml,--使用xml存储的金额分段条件指标：N'<root>
																	--	<row id="1">
																	--		<startMoney>0</startMoney>
																	--		<endMoney>10000</endMoney>
																	--	</row>
																	--	<row id="2">
																	--		<startMoney>10000</startMoney>
																	--		<endMoney>20000</endMoney>
																	--	</row>
																	--	<row id="3">
																	--		<startMoney>20000</startMoney>
																	--		<endMoney>-1</endMoney>
																	--	</row>
																	--	...
																	--</root>'
				--维护人:
				@modiManID varchar(10) output,	--维护人，如果当前统计模板正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的统计模板正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-2-9
	UpdateDate: 
*/
create PROCEDURE addMoneySectionQuota
	@templateID smallint,	--模板ID
	@quotaDetail xml,		--使用xml存储的分类约束条件：N'<root>
														--	<row id="1">
														--		<eTypeCode>05010549</eTypeCode>
														--		<eTypeName>激光打印机</eTypeName>
														--	</row>
														--	<row id="2">
														--		<eTypeCode>05010550</eTypeCode>
														--		<eTypeName>扫描仪</eTypeName>
														--	</row>
														--	...
														--</root>'
	@moneySectionDetail xml,--使用xml存储的金额分段条件指标：N'<root>
														--	<row id="1">
														--		<startMoney>0</startMoney>
														--		<endMoney>10000</endMoney>
														--	</row>
														--	<row id="2">
														--		<startMoney>10000</startMoney>
														--		<endMoney>20000</endMoney>
														--	</row>
														--	<row id="3">
														--		<startMoney>20000</startMoney>
														--		<endMoney>-1</endMoney>
														--	</row>
														--	...
														--</root>'
	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前统计模板正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
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

	--更新插入金额分段汇总指标：
	begin tran
		delete subTotalTemplateQuota where templateID = @templateID
		delete moneySectionQuota where templateID = @templateID
		--更新插入设备分类汇总指标：
		if (cast(@quotaDetail as varchar(max))<>'' and cast(@quotaDetail as varchar(max))<>'<root></root>')
			insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
			select @templateID, cast(cast(T.x.query('data(./@id)') as varchar(8)) as smallint) rowNum, 
					cast(T.x.query('data(./eTypeCode)') as char(8)) eTypeCode, 
					cast(T.x.query('data(./eTypeName)') as nvarchar(30)) eTypeName
			from(select @quotaDetail.query('/root/row') Col1) A
					OUTER APPLY A.Col1.nodes('/row') AS T(x)
		--更新插入金额分段汇总指标：
		insert moneySectionQuota(templateID, rowNum, startMoney, endMoney)
		select @templateID, cast(cast(T.x.query('data(./@id)') as varchar(8)) as smallint) rowNum, 
				cast(cast(T.x.query('data(./startMoney)') as varchar(14)) as money) startMoney, 
				cast(cast(T.x.query('data(./endMoney)') as varchar(14)) as money) endMoney
		from(select @moneySectionDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)

		update statisticTemplate
		set modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where templateID = @templateID
		set @Ret = 0
	commit tran
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新插入分类汇总指标', '用户' + @modiManName 
												+ '更新插入了第['+ str(@templateID,6) +']号统计模板的金额分段汇总指标。')
GO
--测试：
declare	@quotaDetail xml
set @quotaDetail = N''
declare	@moneySectionDetail xml
set @moneySectionDetail =N'<root>
						<row id="1">
							<startMoney>0</startMoney>
							<endMoney>10000</endMoney>
						</row>
						<row id="2">
							<startMoney>10000</startMoney>
							<endMoney>20000</endMoney>
						</row>
						<row id="3">
							<startMoney>20000</startMoney>
							<endMoney>-1</endMoney>
						</row>
						...
					</root>'
declare @updateTime smalldatetime
declare @Ret int
exec dbo.addMoneySectionQuota 1, @quotaDetail, @moneySectionDetail, '2010112301', @updateTime output, @Ret output
select @Ret

select * from subTotalTemplateQuota
select * from moneySectionQuota

drop PROCEDURE addAppDirQuota
/*
	name:		addAppDirQuota
	function:	7.添加使用方向统计指标
				注意：这个存储过程先删除全部的明细数据，然后再添加。
	input: 
				@templateID smallint,	--模板ID
				@appDirDetail xml,		--使用xml存储的指标：N'<root>
																	--	<row id="1">
																	--		<aCode>1</aCode>
																	--		<aName>教学</aName>
																	--	</row>
																	--	<row id="2">
																	--		<aCode>2</aCode>
																	--		<aName>科研</aName>
																	--	</row>
																	--	...
																	--</root>'
				--维护人:
				@modiManID varchar(10) output,	--维护人，如果当前统计模板正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的统计模板正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-3-10
	UpdateDate: 
*/
create PROCEDURE addAppDirQuota
	@templateID smallint,	--模板ID
	@appDirDetail xml,		--使用xml存储的指标：N'<root>
													--	<row id="1">
													--		<aCode>1</aCode>
													--		<aName>教学</aName>
													--	</row>
													--	<row id="2">
													--		<aCode>2</aCode>
													--		<aName>科研</aName>
													--	</row>
													--	...
													--</root>'
	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前统计模板正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
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

	--更新插入使用方向指标：
	begin tran
		delete appDirQuota where templateID = @templateID

		insert appDirQuota(templateID, rowNum, aCode, aName)
		select @templateID, cast(cast(T.x.query('data(./@id)') as varchar(8)) as smallint) rowNum, 
				cast(T.x.query('data(./aCode)') as char(8)) eTypeCode, 
				cast(T.x.query('data(./aName)') as nvarchar(30)) eTypeName
		from(select @appDirDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
		
		update statisticTemplate
		set modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where templateID = @templateID
		set @Ret = 0
	commit tran
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新插入使用方向指标', '用户' + @modiManName 
												+ '更新插入了第['+ str(@templateID,6) +']号统计模板的使用方向指标。')
GO
--测试：
declare	@quotaDetail xml
set @quotaDetail = N'<root>
						<row id="1">
							<aCode>1</aCode>
							<aName>教学</aName>
						</row>
						<row id="2">
							<aCode>2</aCode>
							<aName>科研</aName>
						</row>
					</root>'
declare @updateTime smalldatetime
declare @Ret int
exec dbo.addAppDirQuota 3, @quotaDetail, '2010112301', @updateTime output, @Ret output
select @Ret

select * from appDirQuota

drop PROCEDURE addFundSrcQuota
/*
	name:		addFundSrcQuota
	function:	8.添加经费来源统计指标
				注意：这个存储过程先删除全部的明细数据，然后再添加。
	input: 
				@templateID smallint,	--模板ID
				@fundSrcDetail xml,		--使用xml存储的指标：N'<root>
																	--	<row id="1">
																	--		<fCode>1</fCode>
																	--		<fName>教育事业费</fName>
																	--	</row>
																	--	<row id="2">
																	--		<fCode>2</fCode>
																	--		<fName>科研专款或基金</fName>
																	--	</row>
																	--	...
																	--</root>'
				--维护人:
				@modiManID varchar(10) output,	--维护人，如果当前统计模板正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的统计模板正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-3-10
	UpdateDate: 
*/
create PROCEDURE addFundSrcQuota
	@templateID smallint,	--模板ID
	@fundSrcDetail xml,		--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<fCode>1</fCode>
														--		<fName>教育事业费</fName>
														--	</row>
														--	<row id="2">
														--		<fCode>2</fCode>
														--		<fName>科研专款或基金</fName>
														--	</row>
														--	...
														--</root>'
	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前统计模板正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
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

	--更新插入使用方向指标：
	begin tran
		delete fundSrcQuota where templateID = @templateID

		insert fundSrcQuota(templateID, rowNum, fCode, fName)
		select @templateID, cast(cast(T.x.query('data(./@id)') as varchar(8)) as smallint) rowNum, 
				cast(T.x.query('data(./fCode)') as char(8)) eTypeCode, 
				cast(T.x.query('data(./fName)') as nvarchar(30)) eTypeName
		from(select @fundSrcDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
		
		update statisticTemplate
		set modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where templateID = @templateID
		set @Ret = 0
	commit tran
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新插入经费来源指标', '用户' + @modiManName 
												+ '更新插入了第['+ str(@templateID,6) +']号统计模板的经费来源指标。')
GO
--测试：
declare	@quotaDetail xml
set @quotaDetail = N'<root>
						<row id="1">
							<fCode>1</fCode>
							<fName>教育事业费</fName>
						</row>
						<row id="2">
							<fCode>2</fCode>
							<fName>科研专款或基金</fName>
						</row>
					</root>'
declare @updateTime smalldatetime
declare @Ret int
exec dbo.addFundSrcQuota 4, @quotaDetail, '2010112301', @updateTime output, @Ret output
select @Ret

select * from fundSrcQuota

drop PROCEDURE updateStatisticTemplate
/*
	name:		updateStatisticTemplate
	function:	9.更新统计模板
	input: 
				@templateID smallint,		--模板ID
				@templateType smallint,		--模板类别：0->设备分类汇总，1->金额分段汇总，2->单位分组,3->使用方向，4->经费来源
				@templateName nvarchar(30),	--统计模板名称
				@templateDesc nvarchar(300),--统计模板的描述
				
				--统计的参数：
				--@statisticUnitType int,		--统计范围:0->全校，1->院部
				--@particleSize int,			--统计单位（颗粒度）:0->全校，1->院部，2->使用单位

				--维护人:
				@modiManID varchar(10) output,	--维护人，如果当前统计模板正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的统计模板正被别人锁定，2:有重复的模板名称，9：未知错误
	author:		卢苇
	CreateDate:	2011-2-9
	UpdateDate: modi by lw 2011-2-19删除统计范围和分组依据两个条件
*/
create PROCEDURE updateStatisticTemplate
	@templateID smallint,		--模板ID
	@templateType smallint,		--模板类别：0->设备分类汇总，1->金额分段汇总，2->单位分组,3->使用方向，4->经费来源
	@templateName nvarchar(30),	--统计模板名称
	@templateDesc nvarchar(300),--统计模板的描述
	
	--统计的参数：
	--@statisticUnitType int,		--统计范围:0->全校，1->院部
	--@particleSize int,			--统计单位（颗粒度）:0->全校，1->院部，2->使用单位

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前统计模板正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--检查是否重码重名：
	declare @count int
	set @count = (select count(*) from statisticTemplate where templateName = @templateName and templateID <> @templateID)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update statisticTemplate
	set templateType = @templateType, templateName = @templateName, templateDesc = @templateDesc, 
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where templateID = @templateID
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新统计模板', '用户' + @modiManName 
												+ '更新了第[' + str(@templateID,6) + ']号统计模板。')
GO
--测试：
select * from statisticTemplate
update statisticTemplate
set lockManID=''
select lockManID from statisticTemplate where templateID = 16
select count(*) from statisticTemplate where templateName = 'Hello'

declare @modiManID varchar(10), @updateTime smalldatetime, @Ret	int
set @modiManID='201100001'
exec dbo.updateStatisticTemplate 16,0,'Hello world!','这是一个测试模板',0, 0, @modiManID output, @updateTime output, @Ret output
select @modiManID, @updateTime, @Ret

drop PROCEDURE delStatisticTemplate
/*
	name:		delStatisticTemplate
	function:	10.删除指定的统计模板
	input: 
				@templateID smallint,			--模板ID
				@delManID varchar(10) output,	--删除人，如果当前统计模板正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的分类编码不存在，2：要删除的分类编码正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-2-9
	UpdateDate: 

*/
create PROCEDURE delStatisticTemplate
	@templateID smallint,			--模板ID
	@delManID varchar(10) output,	--删除人，如果当前统计模板正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的统计模板是否存在
	declare @count as int
	set @count=(select count(*) from statisticTemplate where templateID = @templateID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete statisticTemplate where templateID = @templateID
	--这里没有删除关联的统计数据，如果用户要求增加删除关联的统计数据在下面增加！
	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除统计模板', '用户' + @delManName
												+ '删除了第[' + str(@templateID,6) + ']号统计模板。')
GO

select * from wd.dbo.totalcenter
--10.统计中心管理表：这个表里面存放的是指定统计模板统计的数据！
drop table [totalCenter]
CREATE TABLE [dbo].[totalCenter](
	totalTabNum varchar(20) not null,	--主键：统计表编号，使用第1000号号码发生器生成
	theTitle nvarchar(100) null,		--统计表标题
	templateID smallint NOT NULL,		--模板ID
	templateType smallint,				--模板类别：0->设备分类汇总，1->金额分段汇总，2->单位分组,3->使用方向，4->经费来源
	
	--统计时间限制参数：
	startAcceptDate varchar(10) not null,	--验收开始日期
	endAcceptDate varchar(10) not null,		--验收结束日期
	startScrapDate varchar(10) not null,	--报废开始日期
	endScrapDate varchar(10) not null,		--报废结束日期

	--统计空间限制参数：
	statisticUnitType int not null,		--统计范围:0->全校，1->院部
				--这是为了支持用户动态定义统计范围而做的设计：
	statisticUnitCode xml null,			--xml格式存放的统计范围定义：N'<root>
														--	<row id="1">
														--		<clgCode>027</clgCode>
														--		<clgName>财务部</clgName>
														--	</row>
														--	<row id="2">
														--		<clgCode>029</clgCode>
														--		<clgName>招生就业工作处</clgName>
														--	</row>
														--	...
														--</root>'
	particleSize int not null,			--分组（统计单位或颗粒度）:0->全校，1->院部，2->使用单位。为0时不使用统计单位分组。
				--这个设计是为了保证历史数据的正确性而做的冗余设计：
	--因为明细数据中已经保存了单位的详细信息，所以废除particleDesc字段
	--particleDesc xml null,				--xml格式存放的统计单位描述：N'<root>
														--	<row id="1">
														--		<clgCode>027</clgCode>
														--		<clgName>财务部</clgName>
														--		<useUnit id="1">
														--			<uCode>02700</uCode>
														--			<uName>财务部</uName>
														--		</useUnit>
														--		<useUnit id="2">
														--			<uCode>02701</uCode>
														--			<uName>国资办</uName>
														--		</useUnit>
														--		<useUnit id="3">
														--			<uCode>02702</uCode>
														--			<uName>外资贷款办</uName>
														--		</useUnit>
														--		<useUnit id="4">
														--			<uCode>02703</uCode>
														--			<uName>学生贷款管理中心</uName>
														--		</useUnit>
														--	</row>
														--	<row id="2">
														--		<clgCode>029</clgCode>
														--		<clgName>招生就业工作处</clgName>
														--		<useUnit id="1">
														--			<uCode>02900</uCode>
														--			<uName>招生就业工作处</uName>
														--		</useUnit>
														--	</row>
														--	...
														--</root>'

	--统计指标：这是为了支持用户动态修改统计指标而做的设计!
	quotaDetail xml null,		--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<eTypeCode>05010549</eTypeCode>
														--		<eTypeName>激光打印机</eTypeName>
														--	</row>
														--	<row id="2">
														--		<eTypeCode>05010550</eTypeCode>
														--		<eTypeName>扫描仪</eTypeName>
														--	</row>
														--	...
														--</root>'
	moneySectionDetail xml null,--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<startMoney>0</startMoney>
														--		<endMoney>10000</endMoney>
														--	</row>
														--	<row id="2">
														--		<startMoney>10000</startMoney>
														--		<endMoney>20000</endMoney>
														--	</row>
														--	<row id="3">
														--		<startMoney>20000</startMoney>
														--		<endMoney>-1</endMoney>
														--	</row>
														--	...
														--</root>'
	--根据毕处的要求增加使用方向和经费来源两个模板：
	appDirDetail xml null,		--使用xml存储的指标：N'<root>
													--	<row id="1">
													--		<aCode>1</aCode>
													--		<aName>教学</aName>
													--	</row>
													--	<row id="2">
													--		<aCode>2</aCode>
													--		<aName>科研</aName>
													--	</row>
													--	...
													--</root>'
	fundSrcDetail xml null,		--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<fCode>1</fCode>
														--		<fName>教育事业费</fName>
														--	</row>
														--	<row id="2">
														--		<fCode>2</fCode>
														--		<fName>科研专款或基金</fName>
														--	</row>
														--	...
														--</root>'
	
	makeDate smalldatetime null,		--统计日期
	makerID varchar(10) null,			--统计人工号
	maker varchar(30) null,				--统计人
 CONSTRAINT [PK_totalCenter] PRIMARY KEY CLUSTERED 
(
	[totalTabNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


--11.分类汇总统计表：
drop table subTotal
CREATE TABLE [dbo].[subTotal](
	totalTabNum varchar(20) not null,	--主键/外键：统计表编号，使用第1000号号码发生器生成
	ID4Row int not null,				--主键：行号 modi by lw 2011-12-20 为了支持列排序，更改列名，原列名为：RowID
	clgCode char(3) default(''),	--学院代码
	clgName nvarchar(30) default(''),--院部名称	
	uCode varchar(8) default(''),	--使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！
	uName nvarchar(30) default(''),	--使用单位名称	
	rowNum int,						--指标号：设备分类编号
	eTypeCode char(8) not null,		--分类编号（教）
	eTypeName nvarchar(30) not null,--分类名称：注意这里的分类名称可能与分类编码中的名称不一致！！
	totalNum int not null,			--数量：单位：台套
	totalMoney numeric(18,2) not null,		--金额：单位：元
 CONSTRAINT [PK_subTotal] PRIMARY KEY CLUSTERED 
(
	[totalTabNum] ASC,
	[ID4Row] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--外键：
ALTER TABLE [dbo].[subTotal] WITH CHECK ADD CONSTRAINT [FK_subTotal_totalCenter] FOREIGN KEY([totalTabNum])
REFERENCES [dbo].[totalCenter] ([totalTabNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[subTotal] CHECK CONSTRAINT [FK_subTotal_totalCenter] 
GO


--12.金额分段统计表：
drop table moneySectionTotal
CREATE TABLE [dbo].[moneySectionTotal](
	totalTabNum varchar(20) not null,	--主键/外键：统计表编号，使用第1000号号码发生器生成
	ID4Row int not null,				--主键：行号 modi by lw 2011-12-20 为了支持列排序，更改列名，原列名为：RowID
	clgCode char(3) default(''),	--学院代码
	clgName nvarchar(30) default(''),--院部名称	
	uCode varchar(8) default(''),	--使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！
	uName nvarchar(30) default(''),	--使用单位名称	
	rowNum int,						--指标号：金额分段编号
	startMoney money null,			--起点金额
	endMoney money null,			--结束金额：-1表示无穷大
	totalNum int not null,			--数量：单位：台套
	totalMoney numeric(18,2) not null,		--金额：单位：元
 CONSTRAINT [PK_moneySectionTotal] PRIMARY KEY CLUSTERED 
(
	[totalTabNum] ASC,
	[ID4Row] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--外键：
ALTER TABLE [dbo].[moneySectionTotal] WITH CHECK ADD CONSTRAINT [FK_moneySectionTotal_totalCenter] FOREIGN KEY([totalTabNum])
REFERENCES [dbo].[totalCenter] ([totalTabNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[moneySectionTotal] CHECK CONSTRAINT [FK_moneySectionTotal_totalCenter]
GO

--13.单位分组统计表：
drop table unitGroupTotal
CREATE TABLE [dbo].[unitGroupTotal](
	totalTabNum varchar(20) not null,	--主键/外键：统计表编号，使用第1000号号码发生器生成
	ID4Row int not null,				--主键：行号 modi by lw 2011-12-20 为了支持列排序，更改列名，原列名为：RowID
	clgCode char(3) default(''),	--学院代码
	clgName nvarchar(30) default(''),--院部名称	
	uCode varchar(8) default(''),	--使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！
	uName nvarchar(30) default(''),	--使用单位名称	
	totalNum int not null,			--数量：单位：台套
	totalMoney numeric(18,2) not null,		--金额：单位：元
 CONSTRAINT [PK_unitGroupTotal] PRIMARY KEY CLUSTERED 
(
	[totalTabNum] ASC,
	[ID4Row] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--外键：
ALTER TABLE [dbo].[unitGroupTotal] WITH CHECK ADD CONSTRAINT [FK_unitGroupTotal_totalCenter] FOREIGN KEY([totalTabNum])
REFERENCES [dbo].[totalCenter] ([totalTabNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[unitGroupTotal] CHECK CONSTRAINT [FK_unitGroupTotal_totalCenter] 
GO

--14.使用方向汇总统计表：
drop table appDirTotal
CREATE TABLE [dbo].[appDirTotal](
	totalTabNum varchar(20) not null,	--主键/外键：统计表编号，使用第1000号号码发生器生成
	ID4Row int not null,				--主键：行号 modi by lw 2011-12-20 为了支持列排序，更改列名，原列名为：RowID
	clgCode char(3) default(''),	--学院代码
	clgName nvarchar(30) default(''),--院部名称	
	uCode varchar(8) default(''),	--使用单位代码
	uName nvarchar(30) default(''),	--使用单位名称	
	rowNum int,						--指标号：设备分类编号
	aCode char(2) not null,			--使用方向代码
	aName nvarchar(20) not null,	--使用方向名称	
	totalNum int not null,			--数量：单位：台套
	totalMoney numeric(18,2) not null,		--金额：单位：元
 CONSTRAINT [PK_appDirTotal] PRIMARY KEY CLUSTERED 
(
	[totalTabNum] ASC,
	[ID4Row] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--外键：
ALTER TABLE [dbo].[appDirTotal] WITH CHECK ADD CONSTRAINT [FK_appDirTotal_totalCenter] FOREIGN KEY([totalTabNum])
REFERENCES [dbo].[totalCenter] ([totalTabNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[appDirTotal] CHECK CONSTRAINT [FK_appDirTotal_totalCenter] 
GO

--15.经费来源汇总统计表：
drop table fundSrcTotal
CREATE TABLE [dbo].[fundSrcTotal](
	totalTabNum varchar(20) not null,	--主键/外键：统计表编号，使用第1000号号码发生器生成
	ID4Row int not null,				--主键：行号 modi by lw 2011-12-20 为了支持列排序，更改列名，原列名为：RowID
	clgCode char(3) default(''),	--学院代码
	clgName nvarchar(30) default(''),--院部名称	
	uCode varchar(8) default(''),	--使用单位代码
	uName nvarchar(30) default(''),	--使用单位名称	
	rowNum int,						--指标号：设备分类编号
	fCode char(2) not null,			--经费来源代码
	fName nvarchar(20) not null,	--经费来源名称	
	totalNum int not null,			--数量：单位：台套
	totalMoney numeric(18,2) not null,		--金额：单位：元
 CONSTRAINT [PK_fundSrcTotal] PRIMARY KEY CLUSTERED 
(
	[totalTabNum] ASC,
	[ID4Row] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--外键：
ALTER TABLE [dbo].[fundSrcTotal] WITH CHECK ADD CONSTRAINT [FK_fundSrcTotal_totalCenter] FOREIGN KEY([totalTabNum])
REFERENCES [dbo].[totalCenter] ([totalTabNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[fundSrcTotal] CHECK CONSTRAINT [FK_fundSrcTotal_totalCenter] 
GO

drop PROCEDURE statisticPro
/*
	name:		statisticPro
	function:	11.按模板统计
				注意：该存储过程并不使用统计模板表中的数据，而使用用户动态传入的指标值，这是为了支持用户动态修改统计指标！
	input: 
				@templateID smallint,		--统计模板ID
				@templateType smallint,		--模板类别：0->设备分类汇总，1->金额分段汇总，2->单位分组,3->使用方向，4->经费来源
				
				--统计时间限制参数：
				@startAcceptDate smalldatetime,	--验收开始日期
				@endAcceptDate smalldatetime,	--验收结束日期
				@startScrapDate smalldatetime,	--报废开始日期
				@endScrapDate smalldatetime,	--报废结束日期

				--统计空间限制参数：
				@statisticUnitType int,			--统计范围:0->全校，1->院部
				@statisticUnitCode xml,			--xml格式存放的统计范围定义：N'<root>
																	--	<row id="1">
																	--		<clgCode>027</clgCode>
																	--		<clgName>财务部</clgName>
																	--	</row>
																	--	<row id="2">
																	--		<clgCode>029</clgCode>
																	--		<clgName>招生就业工作处</clgName>
																	--	</row>
																	--	...
																	--</root>'
				@particleSize int,				--统计单位（颗粒度）:0->全校，1->院部，2->使用单位。为0时不使用统计单位分组。

				--统计指标：这是为了支持用户动态修改统计指标而做的设计!
				@quotaDetail xml,		--使用xml存储的指标：N'<root>
																	--	<row id="1">
																	--		<eTypeCode>05010549</eTypeCode>
																	--		<eTypeName>激光打印机</eTypeName>
																	--	</row>
																	--	<row id="2">
																	--		<eTypeCode>05010550</eTypeCode>
																	--		<eTypeName>扫描仪</eTypeName>
																	--	</row>
																	--	...
																	--</root>'
				@moneySectionDetail xml,--使用xml存储的指标：N'<root>
																	--	<row id="1">
																	--		<startMoney>0</startMoney>
																	--		<endMoney>10000</endMoney>
																	--	</row>
																	--	<row id="2">
																	--		<startMoney>10000</startMoney>
																	--		<endMoney>20000</endMoney>
																	--	</row>
																	--	<row id="3">
																	--		<startMoney>20000</startMoney>
																	--		<endMoney>-1</endMoney>
																	--	</row>
																	--	...
																	--</root>'
				@appDirDetail xml,		--使用xml存储的指标：N'<root>
																--	<row id="1">
																--		<aCode>1</aCode>
																--		<aName>教学</aName>
																--	</row>
																--	<row id="2">
																--		<aCode>2</aCode>
																--		<aName>科研</aName>
																--	</row>
																--	...
																--</root>'
				@fundSrcDetail xml,		--使用xml存储的指标：N'<root>
																	--	<row id="1">
																	--		<fCode>1</fCode>
																	--		<fName>教育事业费</fName>
																	--	</row>
																	--	<row id="2">
																	--		<fCode>2</fCode>
																	--		<fName>科研专款或基金</fName>
																	--	</row>
																	--	...
																	--</root>'
				--结果集分页参数：
				@pageSize int,      --每页行数   
				@page     int,		--指定页   
	output:		
				@rows  int OUTPUT,	--总行数
				@pages int OUTPUT	--总页数   
				--del by lw 2011-2-15,新的统计表不需要该参数！
				--统计单位（颗粒度）描述，注意：这是一个传出参数，主要是保证历史数据的正确性！
				--@particleDesc xml output				--xml格式存放的统计单位描述：N'<root>
																	--	<row id="1">
																	--		<clgCode>027</clgCode>
																	--		<clgName>财务部</clgName>
																	--		<useUnit id="1">
																	--			<uCode>02700</uCode>
																	--			<uName>财务部</uName>
																	--		</useUnit>
																	--		<useUnit id="2">
																	--			<uCode>02701</uCode>
																	--			<uName>国资办</uName>
																	--		</useUnit>
																	--		<useUnit id="3">
																	--			<uCode>02702</uCode>
																	--			<uName>外资贷款办</uName>
																	--		</useUnit>
																	--		<useUnit id="4">
																	--			<uCode>02703</uCode>
																	--			<uName>学生贷款管理中心</uName>
																	--		</useUnit>
																	--	</row>
																	--	<row id="2">
																	--		<clgCode>029</clgCode>
																	--		<clgName>招生就业工作处</clgName>
																	--		<useUnit id="1">
																	--			<uCode>02900</uCode>
																	--			<uName>招生就业工作处</uName>
																	--		</useUnit>
																	--	</row>
																	--	...
																	--</root>'
				使用结果集传出统计指标和指标值
	author:		卢苇
	CreateDate:	2011-2-10
	UpdateDate: modi by lw 2011-2-14根据毕处的意见增加一个单位分组统计模板！增加结果集使用单位名称支持，支持空数据分组显示。
				modi by lw 2011-2-15增加分页参数，修改为分页查询的方式
				modi by lw 2011-2-15为了保证保存结果集中避免分页，将本存储过程分拆出一个完整结果集的子存储过程，
									同时新的统计表设计中不再使用@particleDesc参数，废止该传出参数！
				modi by lw 2011-3-10根据毕处要求增加使用方向和经费来源两个模板的统计
*/
create PROCEDURE statisticPro
	@templateID smallint,		--统计模板ID
	@templateType smallint,		--模板类别：0->设备分类汇总，1->金额分段汇总，2->单位分组,3->使用方向，4->经费来源
	
	--统计时间限制参数：
	@startAcceptDate varchar(10),--验收开始日期:按ODBC格式存放的日期"YYYY-MM-DD"
	@endAcceptDate varchar(10),	--验收结束日期:按ODBC格式存放的日期"YYYY-MM-DD"
	@startScrapDate varchar(10),--报废开始日期:按ODBC格式存放的日期"YYYY-MM-DD"
	@endScrapDate varchar(10),	--报废结束日期:按ODBC格式存放的日期"YYYY-MM-DD"

	--统计空间限制参数：
	@statisticUnitType int,			--统计范围:0->全校，1->院部
	@statisticUnitCode xml,			--xml格式存放的统计范围定义：N'<root>
														--	<row id="1">
														--		<clgCode>027</clgCode>
														--		<clgName>财务部</clgName>
														--	</row>
														--	<row id="2">
														--		<clgCode>029</clgCode>
														--		<clgName>招生就业工作处</clgName>
														--	</row>
														--	...
														--</root>'
	@particleSize int,				--统计单位（颗粒度）:0->全校，1->院部，2->使用单位。为0时不使用统计单位分组。

	--统计指标：这是为了支持用户动态修改统计指标而做的设计!
	@quotaDetail xml,		--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<eTypeCode>05010549</eTypeCode>
														--		<eTypeName>激光打印机</eTypeName>
														--	</row>
														--	<row id="2">
														--		<eTypeCode>05010550</eTypeCode>
														--		<eTypeName>扫描仪</eTypeName>
														--	</row>
														--	...
														--</root>'
	@moneySectionDetail xml,--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<startMoney>0</startMoney>
														--		<endMoney>10000</endMoney>
														--	</row>
														--	<row id="2">
														--		<startMoney>10000</startMoney>
														--		<endMoney>20000</endMoney>
														--	</row>
														--	<row id="3">
														--		<startMoney>20000</startMoney>
														--		<endMoney>-1</endMoney>
														--	</row>
														--	...
														--</root>'
	@appDirDetail xml,		--使用xml存储的指标：N'<root>
													--	<row id="1">
													--		<aCode>1</aCode>
													--		<aName>教学</aName>
													--	</row>
													--	<row id="2">
													--		<aCode>2</aCode>
													--		<aName>科研</aName>
													--	</row>
													--	...
													--</root>'
	@fundSrcDetail xml,		--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<fCode>1</fCode>
														--		<fName>教育事业费</fName>
														--	</row>
														--	<row id="2">
														--		<fCode>2</fCode>
														--		<fName>科研专款或基金</fName>
														--	</row>
														--	...
														--</root>'
	--结果集分页参数：
    @pageSize int,      --每页行数   
    @page     int,		--指定页   
    @rows  int OUTPUT,	--总行数
    @pages int OUTPUT	--总页数   
    
    --del by lw 2011-2-15,新的统计表不需要该参数！
	--统计单位（颗粒度）描述，注意：这是一个传出参数，主要是保证历史数据的正确性！
	--@particleDesc xml output				--xml格式存放的统计单位描述：N'<root>
														--	<row id="1">
														--		<clgCode>027</clgCode>
														--		<clgName>财务部</clgName>
														--		<useUnit id="1">
														--			<uCode>02700</uCode>
														--			<uName>财务部</uName>
														--		</useUnit>
														--		<useUnit id="2">
														--			<uCode>02701</uCode>
														--			<uName>国资办</uName>
														--		</useUnit>
														--		<useUnit id="3">
														--			<uCode>02702</uCode>
														--			<uName>外资贷款办</uName>
														--		</useUnit>
														--		<useUnit id="4">
														--			<uCode>02703</uCode>
														--			<uName>学生贷款管理中心</uName>
														--		</useUnit>
														--	</row>
														--	<row id="2">
														--		<clgCode>029</clgCode>
														--		<clgName>招生就业工作处</clgName>
														--		<useUnit id="1">
														--			<uCode>02900</uCode>
														--			<uName>招生就业工作处</uName>
														--		</useUnit>
														--	</row>
														--	...
														--</root>'
	WITH ENCRYPTION 
AS
	if not (select object_id('Tempdb..#totalResult')) is null 
		drop table #totalResult
	create table #totalResult(RowID int not null)
	ALTER TABLE [dbo].[#totalResult] ADD  CONSTRAINT [PK_totalResult] PRIMARY KEY CLUSTERED 
	(
		[RowID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	
	--根据模板类别构造不同的临时表，接收makeTotal的结果集！
	if @templateType = 0	--0->设备分类汇总
	begin
		if @particleSize = 0	--不分组
			alter table #totalResult add eTypeCode char(8), eTypeName nvarchar(30), totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
										rowNum int, eTypeCode char(8), eTypeName nvarchar(30), totalNum int, totalMoney  numeric(18,2)
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
										rowNum int, eTypeCode char(8), eTypeName nvarchar(30), totalNum int, totalMoney  numeric(18,2)
	end
	else if @templateType = 1	--1->金额分段汇总
	begin
		if @particleSize = 0	--不分组
			alter table #totalResult add startMoney money, endMoney money, totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
										rowNum int, startMoney money, endMoney money, totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
										rowNum int, startMoney money, endMoney money, totalNum int, totalMoney numeric(18,2)
	end
	else if @templateType = 2	--2->单位分组
	begin
		if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
										totalNum int, totalMoney  numeric(18,2)
	end
	else if @templateType = 3	--3->使用方向汇总
	begin
		if @particleSize = 0	--不分组
			alter table #totalResult add aCode char(2), aName nvarchar(20), totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
										rowNum int, aCode char(2), aName nvarchar(20), totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
										rowNum int, aCode char(2), aName nvarchar(20), totalNum int, totalMoney numeric(18,2)
	end
	else if @templateType = 4	--4->经费来源汇总
	begin
		if @particleSize = 0	--不分组
			alter table #totalResult add fCode char(2), fName nvarchar(20), totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
										rowNum int, fCode char(2), fName nvarchar(20), totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
										rowNum int, fCode char(2), fName nvarchar(20), totalNum int, totalMoney numeric(18,2)
	end

	insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
									@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
									@appDirDetail, @fundSrcDetail

	--准备分页：
	declare @topRows as varchar(10)
	set @topRows = ltrim(str((@page+1) * @pageSize, 10))
	declare @sql as nvarchar(max)
	set @sql = N'select ' + 'top '+ @topRows + ' *'
		+ ' from #totalResult'
		+ ' where RowID BETWEEN ' + str(@page * @pageSize + 1 ,10) + ' AND ' + @topRows
		+ ' order by RowID'
	
	set @rows = (select count(*) from #totalResult)	--总行数
	set @pages = (@rows + @pageSize -1) / @pageSize	--总页数

--print @sql
	EXEC(@sql)   
	drop table #totalResult
GO
--测试：
declare @quotaDetail xml
set @quotaDetail = N'<root>
				</root>'
declare @moneySectionDetail xml
set @moneySectionDetail = N'<root>
					<row id="1">
						<startMoney>0</startMoney>
						<endMoney>10000</endMoney>
					</row>
					<row id="2">
						<startMoney>10000</startMoney>
						<endMoney>20000</endMoney>
					</row>
					<row id="3">
						<startMoney>20000</startMoney>
						<endMoney>-1</endMoney>
					</row>
				</root>'
declare @appDirDetail xml
set @appDirDetail =N'<root>
						<row id="1">
							<aCode>2</aCode>
							<aName>科研</aName>
						</row>
						<row id="2">
							<aCode>1</aCode>
							<aName>教学</aName>
						</row>
					</root>'
declare @fundSrcDetail xml
set @fundSrcDetail =N'<root>
						<row id="1">
							<fCode>1</fCode>
							<fName>教育事业费</fName>
						</row>
						<row id="2">
							<fCode>2</fCode>
							<fName>科研专款或基金</fName>
						</row>
					</root>'
declare @particleDesc xml
declare @rows int, @pages int
exec dbo.statisticPro 31, 4, '2009-01-01', '', '2011-01-01', '', 0, null, 2, @quotaDetail, @moneySectionDetail, 
		@appDirDetail, @fundSrcDetail, 20, 0, @rows output, @pages output
select @rows, @pages

drop PROCEDURE makeTotal
/*
	name:		makeTotal
	function:	12.根据统计条件，生成统计结果集
				本存储过程由statisticPro存储过程分拆而出。
				注意：该存储过程并不使用统计模板表中的数据，而使用用户动态传入的指标值，这是为了支持用户动态修改统计指标！
					这是一个内部存储过程，不需要包装到服务中！
	input: 
				@templateType smallint,		--模板类别：0->设备分类汇总，1->金额分段汇总，2->单位分组,3->使用方向，4->经费来源
				
				--统计时间限制参数：
				@startAcceptDate smalldatetime,	--验收开始日期
				@endAcceptDate smalldatetime,	--验收结束日期
				@startScrapDate smalldatetime,	--报废开始日期
				@endScrapDate smalldatetime,	--报废结束日期

				--统计空间限制参数：
				@statisticUnitType int,			--统计范围:0->全校，1->院部
				@statisticUnitCode xml,			--xml格式存放的统计范围定义：N'<root>
																	--	<row id="1">
																	--		<clgCode>027</clgCode>
																	--		<clgName>财务部</clgName>
																	--	</row>
																	--	<row id="2">
																	--		<clgCode>029</clgCode>
																	--		<clgName>招生就业工作处</clgName>
																	--	</row>
																	--	...
																	--</root>'
				@particleSize int,				--统计单位（颗粒度）:0->全校，1->院部，2->使用单位。为0时不使用统计单位分组。

				--统计指标：这是为了支持用户动态修改统计指标而做的设计!
				@quotaDetail xml,		--使用xml存储的指标：N'<root>
																	--	<row id="1">
																	--		<eTypeCode>05010549</eTypeCode>
																	--		<eTypeName>激光打印机</eTypeName>
																	--	</row>
																	--	<row id="2">
																	--		<eTypeCode>05010550</eTypeCode>
																	--		<eTypeName>扫描仪</eTypeName>
																	--	</row>
																	--	...
																	--</root>'
				@moneySectionDetail xml,--使用xml存储的指标：N'<root>
																	--	<row id="1">
																	--		<startMoney>0</startMoney>
																	--		<endMoney>10000</endMoney>
																	--	</row>
																	--	<row id="2">
																	--		<startMoney>10000</startMoney>
																	--		<endMoney>20000</endMoney>
																	--	</row>
																	--	<row id="3">
																	--		<startMoney>20000</startMoney>
																	--		<endMoney>-1</endMoney>
																	--	</row>
																	--	...
																	--</root>'
				@appDirDetail xml,		--使用xml存储的指标：N'<root>
																--	<row id="1">
																--		<aCode>1</aCode>
																--		<aName>教学</aName>
																--	</row>
																--	<row id="2">
																--		<aCode>2</aCode>
																--		<aName>科研</aName>
																--	</row>
																--	...
																--</root>'
				@fundSrcDetail xml		--使用xml存储的指标：N'<root>
																	--	<row id="1">
																	--		<fCode>1</fCode>
																	--		<fName>教育事业费</fName>
																	--	</row>
																	--	<row id="2">
																	--		<fCode>2</fCode>
																	--		<fName>科研专款或基金</fName>
																	--	</row>
																	--	...
																	--</root>'
	output:		
				使用结果集传出统计指标和指标值
	author:		卢苇
	CreateDate:	2011-2-15
	UpdateDate:modi by lw 2011-3-10根据毕处要求增加使用方向和经费来源两个模板的统计
*/
create PROCEDURE makeTotal
	@templateType smallint,		--模板类别：0->设备分类汇总，1->金额分段汇总，2->单位分组,3->使用方向，4->经费来源
	
	--统计时间限制参数：
	@startAcceptDate varchar(10),--验收开始日期:按ODBC格式存放的日期"YYYY-MM-DD"
	@endAcceptDate varchar(10),	--验收结束日期:按ODBC格式存放的日期"YYYY-MM-DD"
	@startScrapDate varchar(10),--报废开始日期:按ODBC格式存放的日期"YYYY-MM-DD"
	@endScrapDate varchar(10),	--报废结束日期:按ODBC格式存放的日期"YYYY-MM-DD"

	--统计空间限制参数：
	@statisticUnitType int,			--统计范围:0->全校，1->院部
	@statisticUnitCode xml,			--xml格式存放的统计范围定义：N'<root>
														--	<row id="1">
														--		<clgCode>027</clgCode>
														--		<clgName>财务部</clgName>
														--	</row>
														--	<row id="2">
														--		<clgCode>029</clgCode>
														--		<clgName>招生就业工作处</clgName>
														--	</row>
														--	...
														--</root>'
	@particleSize int,				--统计单位（颗粒度）:0->全校，1->院部，2->使用单位。为0时不使用统计单位分组。

	--统计指标：这是为了支持用户动态修改统计指标而做的设计!
	@quotaDetail xml,		--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<eTypeCode>05010549</eTypeCode>
														--		<eTypeName>激光打印机</eTypeName>
														--	</row>
														--	<row id="2">
														--		<eTypeCode>05010550</eTypeCode>
														--		<eTypeName>扫描仪</eTypeName>
														--	</row>
														--	...
														--</root>'
	@moneySectionDetail xml,--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<startMoney>0</startMoney>
														--		<endMoney>10000</endMoney>
														--	</row>
														--	<row id="2">
														--		<startMoney>10000</startMoney>
														--		<endMoney>20000</endMoney>
														--	</row>
														--	<row id="3">
														--		<startMoney>20000</startMoney>
														--		<endMoney>-1</endMoney>
														--	</row>
														--	...
														--</root>'
	@appDirDetail xml,		--使用xml存储的指标：N'<root>
													--	<row id="1">
													--		<aCode>1</aCode>
													--		<aName>教学</aName>
													--	</row>
													--	<row id="2">
													--		<aCode>2</aCode>
													--		<aName>科研</aName>
													--	</row>
													--	...
													--</root>'
	@fundSrcDetail xml		--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<fCode>1</fCode>
														--		<fName>教育事业费</fName>
														--	</row>
														--	<row id="2">
														--		<fCode>2</fCode>
														--		<fName>科研专款或基金</fName>
														--	</row>
														--	...
														--</root>'
	WITH ENCRYPTION 
AS
	declare @strWhere nvarchar(1000), @groupCol nvarchar(max)
	set @strWhere = N''
	set @groupCol = N''
	--构造时间约束条件：
	if @startAcceptDate <> ''
		set @strWhere = @strWhere + ' and e.acceptDate >=' + char(39) + @startAcceptDate + char(39)
	if @endAcceptDate = ''
		set @endAcceptDate = convert(varchar(10),dateadd(day,1,getdate()),120)
	set @strWhere = @strWhere + ' and e.acceptDate <' + char(39) + @endAcceptDate + char(39)

	if @startScrapDate = ''
		set @startScrapDate = convert(varchar(10), dateadd(day,1,getdate()), 120)	--为了保证历史数据重建的正确性，必须加上的条件！
	set @strWhere = @strWhere + ' and (e.scrapDate is null or e.scrapDate >=' + char(39) + @startScrapDate + char(39) + ')'

	if @endScrapDate <> ''
	begin
		set @strWhere = @strWhere + ' and e.scrapDate <' + char(39) + @endScrapDate + char(39)
	end

	--构造空间限制约束条件：
	if @statisticUnitType = 1	--统计范围:0->全校，1->院部
	begin
		if not (select object_id('Tempdb..#tempUnit')) is null 
			drop table #tempUnit
		create table #tempUnit(clgCode char(3))

		insert #tempUnit(clgCode)
		select cast(T.x.query('data(./clgCode)') as char(3)) 
		from(select @statisticUnitCode.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
		
		set @strWhere = @strWhere + ' and e.clgCode in (select clgCode from #tempUnit)'
	end

	if @strWhere <> N''
		set @strWhere = substring(@strWhere, 5, len(@strWhere) - 4)
		
	--构造分组条件：
	if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
		set @groupCol = N' clgCode,'
	if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
		set @groupCol = N' clgCode, uCode, '

	--构造设备分类列表：
	if not (select object_id('Tempdb..#tempSubTotal')) is null 
		drop table #tempSubTotal
	create table #tempSubTotal(rowNum int, eTypeCode char(8), eTypeName nvarchar(30))

	declare @strQuotaDetail as varchar(max)
	set @strQuotaDetail = cast(@quotaDetail as varchar(max))
	if @quotaDetail is not null and @strQuotaDetail <> '' and @strQuotaDetail <> '<root></root>' and @strQuotaDetail <> '<root/>'
	begin
		insert #tempSubTotal(rowNum, eTypeCode, eTypeName)
		select cast(cast(T.x.query('data(./@id)') as char(8)) as int), cast(T.x.query('data(./eTypeCode)') as char(8)), cast(T.x.query('data(./eTypeName)') as nvarchar(30)) 
		from(select @quotaDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
	end
	
	--根据统计的指标类型，开始统计：
	declare @sql as nvarchar(max)
	if @templateType = 0	--0->设备分类汇总
	begin
		set @sql = N'
			--指定明确分类统计：
			select ' + @groupCol + ' eTypeCode, count(*) totalNum, sum(totalAmount) totalMoney
			from equipmentList e
			where '+ @strWhere +' and eTypeCode in (select eTypeCode from #tempSubTotal where right(eTypeCode,2)<>' + char(39) + '00' + char(39) + ')
			group by ' + @groupCol + ' eTypeCode
			union all
			--类别统计：小类
			select ' + @groupCol + ' left(eTypeCode,6) + ' + char(39) + '00' + char(39) + ', count(*), sum(totalAmount)
			from equipmentList e
			where '+ @strWhere +' and left(eTypeCode,6) in (select left(eTypeCode,6) from #tempSubTotal where right(eTypeCode,4)<>' + char(39) + '0000' + char(39) + ' and right(eTypeCode,2)=' + char(39) + '00' + char(39) + ')
			group by ' + @groupCol + ' left(eTypeCode,6) + ' + char(39) + '00' + char(39) + '
			union all
			--类别统计：中类
			select ' + @groupCol + ' left(eTypeCode,4) + ' + char(39) + '0000' + char(39) + ', count(*), sum(totalAmount)
			from equipmentList e
			where '+ @strWhere +' and left(eTypeCode,4) in (select left(eTypeCode,4) from #tempSubTotal where right(eTypeCode,6)<>' + char(39) + '000000' + char(39) + ' and right(eTypeCode,4)=' + char(39) + '0000' + char(39) + ')
			group by ' + @groupCol + ' left(eTypeCode,4) + ' + char(39) + '0000' + char(39) + '
			union all
			--类别统计：大类
			select ' + @groupCol + ' left(eTypeCode,2) + ' + char(39) + '000000' + char(39) + ', count(*), sum(totalAmount)
			from equipmentList e
			where '+ @strWhere +' and left(eTypeCode,2) in (select left(eTypeCode,2) from #tempSubTotal where right(eTypeCode,6)=' + char(39) + '000000' + char(39) + ')
			group by ' + @groupCol + ' left(eTypeCode,2) + ' + char(39) + '000000' + char(39)
		if @particleSize = 0	--不分组
			set @sql = N'select ROW_NUMBER() OVER(order by s.rowNum) as RowID, s.eTypeCode, s.eTypeName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from #tempSubTotal s left outer join (' + @sql + ') t on s.eTypeCode = t.eTypeCode'
		else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.rowNum, s.eTypeCode, s.eTypeName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select clgCode, clgName, temp.rowNum, eTypeCode, eTypeName from college , #tempSubTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.eTypeCode = t.eTypeCode'
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.uCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.uCode, s.uName, s.rowNum, s.eTypeCode, s.eTypeName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select c.clgCode, c.clgName, u.uCode, u.uName, temp.rowNum, eTypeCode, eTypeName from college c left join useUnit u on c.clgCode = u.clgCode , #tempSubTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.uCode = t.uCode and s.eTypeCode = t.eTypeCode'
	end
	else if @templateType = 1	--1->金额分段汇总
	begin
		--构造金额分组表：
		if not (select object_id('Tempdb..#tempMoneySectionTotal')) is null 
			drop table #tempMoneySectionTotal
		create table #tempMoneySectionTotal(rowNum int, startMoney money, endMoney money)

		insert #tempMoneySectionTotal(rowNum, startMoney, endMoney)
		select cast(cast(T.x.query('data(./@id)') as char(8)) as int), cast(cast(T.x.query('data(./startMoney)') as char(14)) as money), cast(cast(T.x.query('data(./endMoney)') as varchar(14)) as money)
		from (select @moneySectionDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)

		set @groupCol = @groupCol + N' case '
		declare @i int
		declare @startMoney money, @endMoney money
		declare OB cursor for
		select rowNum, startMoney, endMoney from #tempMoneySectionTotal
		OPEN OB
		FETCH NEXT FROM OB INTO @i, @startMoney, @endMoney
		WHILE @@FETCH_STATUS = 0
		begin
			set @groupCol = @groupCol + ' when totalAmount>=' + str(@startMoney, 14, 2)
			if @endMoney > 0
				set @groupCol = @groupCol + ' and totalAmount < ' + str(@endMoney, 14, 2) 
			set @groupCol = @groupCol + ' then ' + str(@i, 8)
			FETCH NEXT FROM OB INTO @i, @startMoney, @endMoney
		end
		CLOSE OB
		DEALLOCATE OB
		set @groupCol = @groupCol + N' end '

		set @sql = N'select ' + @groupCol + ' moneyLevel, count(*) totalNum, sum(cast(totalAmount as numeric(18,2))) totalMoney'
					+ ' from equipmentList e'
					+ ' where '+ @strWhere 
		if (select count(*) from #tempSubTotal) > 0	--指定设备类型的统计
		begin
			set @sql = @sql 
				--指定明确分类统计：
				+' and (eTypeCode in (select eTypeCode from #tempSubTotal where right(eTypeCode,2)<>' + char(39) + '00' + char(39) + ')'
				--指定类别统计：小类
				+ ' or left(eTypeCode,6) in (select left(eTypeCode,6) from #tempSubTotal where right(eTypeCode,4)<>' + char(39) + '0000' + char(39) + ' and right(eTypeCode,2)=' + char(39) + '00' + char(39) + ')'
				--指定类别统计：中类
				+ ' or left(eTypeCode,4) in (select left(eTypeCode,4) from #tempSubTotal where right(eTypeCode,6)<>' + char(39) + '000000' + char(39) + ' and right(eTypeCode,4)=' + char(39) + '0000' + char(39) + ')'
				--指定类别统计：大类
				+ ' or left(eTypeCode,2) in (select left(eTypeCode,2) from #tempSubTotal where right(eTypeCode,6)=' + char(39) + '000000' + char(39) + '))'
		end
		set @sql = @sql + ' group by ' + @groupCol 
		if @particleSize = 0	--不分组
			set @sql = N'select ROW_NUMBER() OVER(order by s.rowNum) as RowID, s.startMoney, s.endMoney, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+' from #tempMoneySectionTotal s left join (' + @sql + ') t on s.rowNum = t.moneyLevel'
		else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.rowNum, s.startMoney, s.endMoney, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select clgCode, clgName, temp.rowNum, temp.startMoney, temp.endMoney from college, #tempMoneySectionTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.rowNum = t.moneyLevel'
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.uCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.uCode, s.uName, s.rowNum, s.startMoney, s.endMoney, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select c.clgCode, c.clgName, u.uCode, u.uName, temp.rowNum, temp.startMoney, temp.endMoney from college c left join useUnit u on c.clgCode = u.clgCode, #tempMoneySectionTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.uCode = t.uCode and s.rowNum = t.moneyLevel'
	end
	else if @templateType = 2	--2->单位分组
	begin
		set @sql = N'select ' + @groupCol + ' count(*) totalNum, sum(totalAmount) totalMoney
		from equipmentList e
		where '+ @strWhere 
		if (select count(*) from #tempSubTotal) > 0	--指定设备类型的统计
			--指定明确分类统计：
			set @sql = @sql +' and (eTypeCode in (select eTypeCode from #tempSubTotal where right(eTypeCode,2)<>' + char(39) + '00' + char(39) + ')'
				--指定类别统计：小类
				+ ' or left(eTypeCode,6) in (select left(eTypeCode,6) from #tempSubTotal where right(eTypeCode,4)<>' + char(39) + '0000' + char(39) + ' and right(eTypeCode,2)=' + char(39) + '00' + char(39) + ')'
				--指定类别统计：中类
				+ ' or left(eTypeCode,4) in (select left(eTypeCode,4) from #tempSubTotal where right(eTypeCode,6)<>' + char(39) + '000000' + char(39) + ' and right(eTypeCode,4)=' + char(39) + '0000' + char(39) + ')'
				--指定类别统计：大类
				+ ' or left(eTypeCode,2) in (select left(eTypeCode,2) from #tempSubTotal where right(eTypeCode,6)=' + char(39) + '000000' + char(39) + '))'
		set @sql = @sql +' group by ' + left(@groupCol, len(@groupCol) -1)

		if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			set @sql = N'select ROW_NUMBER() OVER(order by c.clgCode) as RowID, c.clgCode, c.clgName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from college c left join (' + @sql + ') t on c.clgCode = t.clgCode'
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			set @sql = N'select ROW_NUMBER() OVER(order by c.clgCode, u.uCode) as RowID, c.clgCode, c.clgName, u.uCode, u.uName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from college c left join useUnit u on c.clgCode = u.clgCode '
				+ ' left join (' + @sql + ') t on c.clgCode = t.clgCode and u.uCode = t.uCode'
	end
	else if @templateType = 3	--3->使用方向汇总
	begin
		--构造使用方向分组表：
		if not (select object_id('Tempdb..#tempAppDirTotal')) is null 
			drop table #tempAppDirTotal
		create table #tempAppDirTotal(rowNum int, aCode char(2), aName nvarchar(20))

		insert #tempAppDirTotal(rowNum, aCode, aName)
		select cast(cast(T.x.query('data(./@id)') as char(8)) as int), cast(T.x.query('data(./aCode)') as char(2)), cast(T.x.query('data(./aName)') as nvarchar(20))
		from (select @appDirDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)

		set @groupCol = @groupCol + N' aCode '

		set @sql = N'select ' + @groupCol + ' , count(*) totalNum, sum(cast(totalAmount as numeric(18,2))) totalMoney'
					+ ' from equipmentList e'
					+ ' where '+ @strWhere + ' and aCode in (select aCode from #tempAppDirTotal)'
		if (select count(*) from #tempSubTotal) > 0	--指定设备类型的统计
		begin
			set @sql = @sql 
				--指定明确分类统计：
				+' and (eTypeCode in (select eTypeCode from #tempSubTotal where right(eTypeCode,2)<>' + char(39) + '00' + char(39) + ')'
				--指定类别统计：小类
				+ ' or left(eTypeCode,6) in (select left(eTypeCode,6) from #tempSubTotal where right(eTypeCode,4)<>' + char(39) + '0000' + char(39) + ' and right(eTypeCode,2)=' + char(39) + '00' + char(39) + ')'
				--指定类别统计：中类
				+ ' or left(eTypeCode,4) in (select left(eTypeCode,4) from #tempSubTotal where right(eTypeCode,6)<>' + char(39) + '000000' + char(39) + ' and right(eTypeCode,4)=' + char(39) + '0000' + char(39) + ')'
				--指定类别统计：大类
				+ ' or left(eTypeCode,2) in (select left(eTypeCode,2) from #tempSubTotal where right(eTypeCode,6)=' + char(39) + '000000' + char(39) + '))'
		end
		set @sql = @sql + ' group by ' + @groupCol 
		if @particleSize = 0	--不分组
			set @sql = N'select ROW_NUMBER() OVER(order by s.rowNum) as RowID, s.aCode, s.aName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+' from #tempAppDirTotal s left join (' + @sql + ') t on s.aCode = t.aCode'
		else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.rowNum, s.aCode, s.aName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select clgCode, clgName, temp.rowNum, temp.aCode, temp.aName from college, #tempAppDirTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.aCode = t.aCode'
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.uCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.uCode, s.uName, s.rowNum, s.aCode, s.aName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select c.clgCode, c.clgName, u.uCode, u.uName, temp.rowNum, temp.aCode, temp.aName from college c left join useUnit u on c.clgCode = u.clgCode, #tempAppDirTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.uCode = t.uCode and s.aCode = t.aCode'
	end
	else if @templateType = 4	--4->经费来源汇总
	begin
		--构造使用方向分组表：
		if not (select object_id('Tempdb..#tempFundSrcTotal')) is null 
			drop table #tempFundSrcTotal
		create table #tempFundSrcTotal(rowNum int, fCode char(2), fName nvarchar(20))

		insert #tempFundSrcTotal(rowNum, fCode, fName)
		select cast(cast(T.x.query('data(./@id)') as char(8)) as int), cast(T.x.query('data(./fCode)') as char(2)), cast(T.x.query('data(./fName)') as nvarchar(20))
		from (select @fundSrcDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)

		set @groupCol = @groupCol + N' fCode '

		set @sql = N'select ' + @groupCol + ' , count(*) totalNum, sum(cast(totalAmount as numeric(18,2))) totalMoney'
					+ ' from equipmentList e'
					+ ' where '+ @strWhere + ' and fCode in (select fCode from #tempFundSrcTotal)'
		if (select count(*) from #tempSubTotal) > 0	--指定设备类型的统计
		begin
			set @sql = @sql 
				--指定明确分类统计：
				+' and (eTypeCode in (select eTypeCode from #tempSubTotal where right(eTypeCode,2)<>' + char(39) + '00' + char(39) + ')'
				--指定类别统计：小类
				+ ' or left(eTypeCode,6) in (select left(eTypeCode,6) from #tempSubTotal where right(eTypeCode,4)<>' + char(39) + '0000' + char(39) + ' and right(eTypeCode,2)=' + char(39) + '00' + char(39) + ')'
				--指定类别统计：中类
				+ ' or left(eTypeCode,4) in (select left(eTypeCode,4) from #tempSubTotal where right(eTypeCode,6)<>' + char(39) + '000000' + char(39) + ' and right(eTypeCode,4)=' + char(39) + '0000' + char(39) + ')'
				--指定类别统计：大类
				+ ' or left(eTypeCode,2) in (select left(eTypeCode,2) from #tempSubTotal where right(eTypeCode,6)=' + char(39) + '000000' + char(39) + '))'
		end
		set @sql = @sql + ' group by ' + @groupCol 
		if @particleSize = 0	--不分组
			set @sql = N'select ROW_NUMBER() OVER(order by s.rowNum) as RowID, s.fCode, s.fName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+' from #tempFundSrcTotal s left join (' + @sql + ') t on s.fCode = t.fCode'
		else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.rowNum, s.fCode, s.fName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select clgCode, clgName, temp.rowNum, temp.fCode, temp.fName from college, #tempFundSrcTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.fCode = t.fCode'
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.uCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.uCode, s.uName, s.rowNum, s.fCode, s.fName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select c.clgCode, c.clgName, u.uCode, u.uName, temp.rowNum, temp.fCode, temp.fName from college c left join useUnit u on c.clgCode = u.clgCode, #tempFundSrcTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.uCode = t.uCode and s.fCode = t.fCode'
	end

--print @sql
	EXEC(@sql)   
GO
--测试：
declare @quotaDetail xml
set @quotaDetail = N'<root></root>'
declare @moneySectionDetail xml
set @moneySectionDetail = N'<root>
					<row id="1">
						<startMoney>0</startMoney>
						<endMoney>10000</endMoney>
					</row>
					<row id="2">
						<startMoney>10000</startMoney>
						<endMoney>20000</endMoney>
					</row>
					<row id="3">
						<startMoney>20000</startMoney>
						<endMoney>-1</endMoney>
					</row>
				</root>'
declare @appDirDetail xml
set @appDirDetail =N'<root>
						<row id="1">
							<aCode>2</aCode>
							<aName>科研</aName>
						</row>
						<row id="2">
							<aCode>1</aCode>
							<aName>教学</aName>
						</row>
					</root>'
declare @fundSrcDetail xml
set @fundSrcDetail =N'<root>
						<row id="1">
							<fCode>1</fCode>
							<fName>教育事业费</fName>
						</row>
						<row id="2">
							<fCode>2</fCode>
							<fName>科研专款或基金</fName>
						</row>
					</root>'
declare @particleDesc xml
declare @rows int, @pages int
exec dbo.makeTotal  3, '2009-01-01', '', '2011-01-01', '', 0, null, 1, @quotaDetail, @moneySectionDetail, @appDirDetail, @fundSrcDetail



drop PROCEDURE saveTotalResult
/*
	name:		saveTotalResult
	function:	13.保存统计数据
				注意：本存储过程同时保存主从表的数据！
	input: 
				@theTitle nvarchar(100),	--统计表标题
				@templateID smallint,		--统计模板ID
				@templateType smallint,		--模板类别：0->设备分类汇总，1->金额分段汇总，2->单位分组,3->使用方向，4->经费来源
				
				--统计时间限制参数：
				@startAcceptDate varchar(10),--验收开始日期:按ODBC格式存放的日期"YYYY-MM-DD"
				@endAcceptDate varchar(10),	--验收结束日期:按ODBC格式存放的日期"YYYY-MM-DD"
				@startScrapDate varchar(10),--报废开始日期:按ODBC格式存放的日期"YYYY-MM-DD"
				@endScrapDate varchar(10),	--报废结束日期:按ODBC格式存放的日期"YYYY-MM-DD"

				--统计空间限制参数：
				@statisticUnitType int,			--统计范围:0->全校，1->院部
				@statisticUnitCode xml,			--xml格式存放的统计范围定义：N'<root>
																	--	<row id="1">
																	--		<clgCode>027</clgCode>
																	--		<clgName>财务部</clgName>
																	--	</row>
																	--	<row id="2">
																	--		<clgCode>029</clgCode>
																	--		<clgName>招生就业工作处</clgName>
																	--	</row>
																	--	...
																	--</root>'
				@particleSize int,				--统计单位（颗粒度）:0->全校，1->院部，2->使用单位。为0时不使用统计单位分组。

				--统计指标：这是为了支持用户动态修改统计指标而做的设计!
				@quotaDetail xml,		--使用xml存储的指标：N'<root>
																	--	<row id="1">
																	--		<eTypeCode>05010549</eTypeCode>
																	--		<eTypeName>激光打印机</eTypeName>
																	--	</row>
																	--	<row id="2">
																	--		<eTypeCode>05010550</eTypeCode>
																	--		<eTypeName>扫描仪</eTypeName>
																	--	</row>
																	--	...
																	--</root>'
				@moneySectionDetail xml,--使用xml存储的指标：N'<root>
																	--	<row id="1">
																	--		<startMoney>0</startMoney>
																	--		<endMoney>10000</endMoney>
																	--	</row>
																	--	<row id="2">
																	--		<startMoney>10000</startMoney>
																	--		<endMoney>20000</endMoney>
																	--	</row>
																	--	<row id="3">
																	--		<startMoney>20000</startMoney>
																	--		<endMoney>-1</endMoney>
																	--	</row>
																	--	...
																	--</root>'
				
				@appDirDetail xml,		--使用xml存储的指标：N'<root>
																--	<row id="1">
																--		<aCode>1</aCode>
																--		<aName>教学</aName>
																--	</row>
																--	<row id="2">
																--		<aCode>2</aCode>
																--		<aName>科研</aName>
																--	</row>
																--	...
																--</root>'
				@fundSrcDetail xml,		--使用xml存储的指标：N'<root>
																	--	<row id="1">
																	--		<fCode>1</fCode>
																	--		<fName>教育事业费</fName>
																	--	</row>
																	--	<row id="2">
																	--		<fCode>2</fCode>
																	--		<fName>科研专款或基金</fName>
																	--	</row>
																	--	...
																	--</root>'
				@makerID varchar(10),		--统计人工号
	output:		
				@Ret		int output,		--操作成功标识
							0:成功，9：未知错误
				@makeDate smalldatetime output,	--统计表存档日期
				@totalTabNum varchar(20) output	--统计表编号
	author:		卢苇
	CreateDate:	2011-2-15
	UpdateDate: modi by lw 2011-3-11 根据毕处要求增加使用方向和经费来源两个模板
*/
create PROCEDURE saveTotalResult
	@theTitle nvarchar(100),	--统计表标题
	@templateID smallint,		--统计模板ID
	@templateType smallint,		--模板类别：0->设备分类汇总，1->金额分段汇总，2->单位分组,3->使用方向，4->经费来源
	
	--统计时间限制参数：
	@startAcceptDate varchar(10),--验收开始日期:按ODBC格式存放的日期"YYYY-MM-DD"
	@endAcceptDate varchar(10),	--验收结束日期:按ODBC格式存放的日期"YYYY-MM-DD"
	@startScrapDate varchar(10),--报废开始日期:按ODBC格式存放的日期"YYYY-MM-DD"
	@endScrapDate varchar(10),	--报废结束日期:按ODBC格式存放的日期"YYYY-MM-DD"

	--统计空间限制参数：
	@statisticUnitType int,			--统计范围:0->全校，1->院部
	@statisticUnitCode xml,			--xml格式存放的统计范围定义：N'<root>
														--	<row id="1">
														--		<clgCode>027</clgCode>
														--		<clgName>财务部</clgName>
														--	</row>
														--	<row id="2">
														--		<clgCode>029</clgCode>
														--		<clgName>招生就业工作处</clgName>
														--	</row>
														--	...
														--</root>'
	@particleSize int,				--统计单位（颗粒度）:0->全校，1->院部，2->使用单位。为0时不使用统计单位分组。

	--统计指标：这是为了支持用户动态修改统计指标而做的设计!
	@quotaDetail xml,		--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<eTypeCode>05010549</eTypeCode>
														--		<eTypeName>激光打印机</eTypeName>
														--	</row>
														--	<row id="2">
														--		<eTypeCode>05010550</eTypeCode>
														--		<eTypeName>扫描仪</eTypeName>
														--	</row>
														--	...
														--</root>'
	@moneySectionDetail xml,--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<startMoney>0</startMoney>
														--		<endMoney>10000</endMoney>
														--	</row>
														--	<row id="2">
														--		<startMoney>10000</startMoney>
														--		<endMoney>20000</endMoney>
														--	</row>
														--	<row id="3">
														--		<startMoney>20000</startMoney>
														--		<endMoney>-1</endMoney>
														--	</row>
														--	...
														--</root>'
	
	@appDirDetail xml,		--使用xml存储的指标：N'<root>
													--	<row id="1">
													--		<aCode>1</aCode>
													--		<aName>教学</aName>
													--	</row>
													--	<row id="2">
													--		<aCode>2</aCode>
													--		<aName>科研</aName>
													--	</row>
													--	...
													--</root>'
	@fundSrcDetail xml,		--使用xml存储的指标：N'<root>
														--	<row id="1">
														--		<fCode>1</fCode>
														--		<fName>教育事业费</fName>
														--	</row>
														--	<row id="2">
														--		<fCode>2</fCode>
														--		<fName>科研专款或基金</fName>
														--	</row>
														--	...
														--</root>'
	@makerID varchar(10),		--统计人工号
	@Ret		int output,		--操作成功标识
	@makeDate smalldatetime output,	--统计表存档日期
	@totalTabNum varchar(20) output	--统计表编号
	
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 1000, 1, @curNumber output
	set @totalTabNum = @curNumber

	--获取统计人姓名：
	declare @maker varchar(30)
	set @maker = isnull((select userCName from activeUsers where userID = @makerID),'')
	
	set @makeDate = getdate()
	--为保证历史数据的正确性（查看明细），对时间限制条件做的特殊处理：
	if @endAcceptDate = ''
		set @endAcceptDate = convert(varchar(10),dateadd(day,1,getdate()),120)
	if @startScrapDate = ''
		set @startScrapDate = convert(varchar(10), dateadd(day,1,getdate()), 120)
	
	begin tran
		--保存主表：
		insert totalCenter(totalTabNum, theTitle, templateID, templateType,
							startAcceptDate, endAcceptDate, startScrapDate, endScrapDate,
							statisticUnitType, statisticUnitCode, particleSize,
							quotaDetail, moneySectionDetail, 
							appDirDetail, fundSrcDetail,
							makeDate, makerID, maker)
		values(@totalTabNum, @theTitle, @templateID, @templateType,
							@startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
							@statisticUnitType, @statisticUnitCode, @particleSize,
							@quotaDetail, @moneySectionDetail, 
							@appDirDetail, @fundSrcDetail,
							@makeDate, @makerID, @maker)
		

		if not (select object_id('Tempdb..#totalResult')) is null 
			drop table #totalResult
		create table #totalResult(RowID int not null)
	
		--根据模板类别构造不同的临时表，接收makeTotal的结果集,以不同方式插入明细数据：
		if @templateType = 0	--0->设备分类汇总
		begin
			if @particleSize = 0	--不分组
			begin
				alter table #totalResult add eTypeCode char(8), eTypeName nvarchar(30), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into subTotal(totalTabNum, ID4Row, eTypeCode, eTypeName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
											rowNum int, eTypeCode char(8), eTypeName nvarchar(30), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into subTotal(totalTabNum, ID4Row, clgCode, clgName, rowNum, eTypeCode, eTypeName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
											rowNum int, eTypeCode char(8), eTypeName nvarchar(30), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into subTotal(totalTabNum, ID4Row, clgCode, clgName, uCode, uName, rowNum, eTypeCode, eTypeName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
		end
		else if @templateType = 1	--1->金额分段汇总
		begin
			if @particleSize = 0	--不分组
			begin
				alter table #totalResult add startMoney money, endMoney money, totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into moneySectionTotal(totalTabNum, ID4Row, startMoney, endMoney, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
											rowNum int, startMoney money, endMoney money, totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into moneySectionTotal(totalTabNum, ID4Row, clgCode, clgName, rowNum, startMoney, endMoney, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
											rowNum int, startMoney money, endMoney money, totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into moneySectionTotal(totalTabNum, ID4Row, clgCode, clgName, uCode, uName, rowNum, startMoney, endMoney, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
		end
		else if @templateType = 2 --2->单位分组
		begin
			if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into unitGroupTotal(totalTabNum, ID4Row, clgCode, clgName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
											totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into unitGroupTotal(totalTabNum, ID4Row, clgCode, clgName, uCode, uName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
		end
		else if @templateType = 3	--3->使用方向汇总
		begin
			if @particleSize = 0	--不分组
			begin
				alter table #totalResult add aCode char(2), aName nvarchar(20), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into appDirTotal(totalTabNum, ID4Row, aCode, aName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
											rowNum int, aCode char(2), aName nvarchar(20), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into appDirTotal(totalTabNum, ID4Row, clgCode, clgName, rowNum, aCode, aName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
											rowNum int, aCode char(2), aName nvarchar(20), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into appDirTotal(totalTabNum, ID4Row, clgCode, clgName, uCode, uName, rowNum, aCode, aName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
		end
		else if @templateType = 4	--4->经费来源汇总
		begin
			if @particleSize = 0	--不分组
			begin
				alter table #totalResult add fCode char(2), fName nvarchar(20), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into fundSrcTotal(totalTabNum, ID4Row, fCode, fName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
											rowNum int, fCode char(2), fName nvarchar(20), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into fundSrcTotal(totalTabNum, ID4Row, clgCode, clgName, rowNum, fCode, fName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
											rowNum int, fCode char(2), fName nvarchar(20), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into fundSrcTotal(totalTabNum, ID4Row, clgCode, clgName, uCode, uName, rowNum, fCode, fName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
		end
		drop table #totalResult
		
	commit tran
	set @Ret = 0
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makerID, @maker, @makeDate, '添加统计表', '系统根据用户' + @maker + 
					'的要求添加了统计表[' + @totalTabNum + ']。')
GO
--测试：
declare @quotaDetail xml
set @quotaDetail = N'<root>
					<row id="1">
						<eTypeCode>05010549</eTypeCode>
						<eTypeName>激光打印机</eTypeName>
					</row>
					<row id="2">
						<eTypeCode>05010550</eTypeCode>
						<eTypeName>扫描仪</eTypeName>
					</row>
					<row id="3">
						<eTypeCode>05011549</eTypeCode>
						<eTypeName>空指标</eTypeName>
					</row>
				</root>'
declare @moneySectionDetail xml
set @moneySectionDetail = N'<root>
					<row id="1">
						<startMoney>0</startMoney>
						<endMoney>10000</endMoney>
					</row>
					<row id="2">
						<startMoney>10000</startMoney>
						<endMoney>20000</endMoney>
					</row>
					<row id="3">
						<startMoney>20000</startMoney>
						<endMoney>-1</endMoney>
					</row>
				</root>'
declare @appDirDetail xml
set @appDirDetail =N'<root>
						<row id="1">
							<aCode>2</aCode>
							<aName>科研</aName>
						</row>
						<row id="2">
							<aCode>1</aCode>
							<aName>教学</aName>
						</row>
					</root>'
declare @fundSrcDetail xml
set @fundSrcDetail =N'<root>
						<row id="1">
							<fCode>1</fCode>
							<fName>教育事业费</fName>
						</row>
						<row id="2">
							<fCode>2</fCode>
							<fName>科研专款或基金</fName>
						</row>
					</root>'
declare @Ret int	--操作成功标识
declare @makeDate smalldatetime	--统计表存档日期
declare @totalTabNum varchar(20)--统计表编号
exec dbo.saveTotalResult '测试统计表1', 5, 2, '2009-01-01', '', '2011-01-01', '', 0, null, 1, @quotaDetail, @moneySectionDetail, 
			@appDirDetail, @fundSrcDetail, 
			'00001', @Ret output, @makeDate output, @totalTabNum output

select @Ret, @totalTabNum

select * from totalCenter
select * from subTotal

drop PROCEDURE getTotalResult
/*
	name:		getTotalResult
	function:	14.采用分页方式获取指定的统计表的数据
	input: 
				@totalTabNum varchar(20),	--统计表编号
				@strOrder nvarchar(200),	--排序条件	add by lw 2011-12-20
				--结果集分页参数：
				@pageSize int,      --每页行数   
				@page     int,		--指定页   
	output:		
				@rows  int OUTPUT,	--总行数
				@pages int OUTPUT	--总页数   
				使用结果集传出统计指标和指标值
	author:		卢苇
	CreateDate:	2011-2-15
	UpdateDate: modi by lw 2011-2-17修改获取结果集没有加报表编号限制的错误，改为传参动态执行语句。
				modi by lw 2011-3-11 根据毕处要求增加使用方向和经费来源两个模板
				modi by lw 2011-12-20增加排序条件
*/
create PROCEDURE getTotalResult
	@totalTabNum varchar(20),	--统计表编号
	@strOrder nvarchar(200),	--排序条件	add by lw 2011-12-20
	--结果集分页参数：
    @pageSize int,      --每页行数   
    @page     int,		--指定页   
    @rows  int OUTPUT,	--总行数
    @pages int OUTPUT	--总页数   
	WITH ENCRYPTION 
AS
	--修正order子句：
	if (@strOrder = '')
		set @strOrder = ' order by ID4Row'

	--获取报表类型：
	declare @templateType smallint		--模板类别：0->设备分类汇总，1->金额分段汇总，2->单位分组,3->使用方向，4->经费来源
	declare @particleSize int			--统计单位（颗粒度）:0->全校，1->院部，2->使用单位。为0时不使用统计单位分组。
	select @templateType = templateType, @particleSize = particleSize from totalCenter where totalTabNum = @totalTabNum
	if @templateType is null
	begin
		set @rows = 0
		set @pages = 0
		return
	end
	
	--准备分页：
	declare @topRows as varchar(10)
	set @topRows = ltrim(str((@page+1) * @pageSize, 10))
	declare @sql as nvarchar(max)
	
	--根据模板类别构造不同的临时表，接收makeTotal的结果集！
	if @templateType = 0	--0->设备分类汇总
	begin
		if @particleSize = 0	--不分组
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, eTypeCode, eTypeName, totalNum, totalMoney'
				+ ' from subTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, rowNum, eTypeCode, eTypeName, totalNum, totalMoney'
				+ ' from subTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, uCode, uName, rowNum, eTypeCode, eTypeName, totalNum, totalMoney'
				+ ' from subTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		set @rows = (select count(*) from subTotal where totalTabNum = @totalTabNum)	--总行数
	end
	else if @templateType = 1	--1->金额分段汇总
	begin
		if @particleSize = 0	--不分组
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, startMoney, endMoney, totalNum, totalMoney'
				+ ' from moneySectionTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, rowNum, startMoney, endMoney, totalNum, totalMoney'
				+ ' from moneySectionTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, uCode, uName, rowNum, startMoney, endMoney, totalNum, totalMoney'
				+ ' from moneySectionTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		set @rows = (select count(*) from moneySectionTotal where totalTabNum = @totalTabNum)	--总行数
	end
	else if @templateType = 2	--2->单位分组
	begin
		if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, totalNum, totalMoney'
				+ ' from unitGroupTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, uCode, uName, totalNum, totalMoney'
				+ ' from unitGroupTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		set @rows = (select count(*) from unitGroupTotal where totalTabNum = @totalTabNum)	--总行数
	end
	else if @templateType = 3	--3->使用方向汇总
	begin
		if @particleSize = 0	--不分组
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, aCode, aName, totalNum, totalMoney'
				+ ' from appDirTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, rowNum, aCode, aName, totalNum, totalMoney'
				+ ' from appDirTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, uCode, uName, rowNum, aCode, aName, totalNum, totalMoney'
				+ ' from appDirTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		set @rows = (select count(*) from appDirTotal where totalTabNum = @totalTabNum)	--总行数
	end
	else if @templateType = 4	--3->经费来源汇总
	begin
		if @particleSize = 0	--不分组
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, fCode, fName, totalNum, totalMoney'
				+ ' from fundSrcTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 1	--分组（统计单位或颗粒度）:1->院部
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, rowNum, fCode, fName, totalNum, totalMoney'
				+ ' from fundSrcTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 2	--统计单位（颗粒度）:2->使用单位
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, uCode, uName, rowNum, fCode, fName, totalNum, totalMoney'
				+ ' from fundSrcTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		set @rows = (select count(*) from fundSrcTotal where totalTabNum = @totalTabNum)	--总行数
	end
	set @pages = (@rows + @pageSize -1) / @pageSize	--总页数
	set @sql = N'select * from (' + @sql + ') tab1'
	if @pageSize > 0
		set @sql = @sql + N' where RowID BETWEEN ' + str(@page * @pageSize + 1 ,10) + ' AND ' + @topRows

--print @sql
	EXEC(@sql)   
GO
--测试：
use epdc2
select * from totalCenter
select * from subTotal
select * from unitGroupTotal

declare @rows int, @pages int
exec dbo.getTotalResult '201103120001', 'order by eTypeCode', 10, 0, @rows output, @pages output
select @rows, @pages


--删除统计表
drop PROCEDURE delTotalResult
/*
	name:		delTotalResult
	function:	15.删除指定的编号的统计表
	input: 
				@totalTabNum varchar(20),	--统计表编号
				@delManID varchar(10) output,	--删除人，如果当前统计表正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的统计表不存在，9：未知错误
	author:		卢苇
	CreateDate:	2011-2-15
	UpdateDate: 

*/
create PROCEDURE delTotalResult
	@totalTabNum varchar(20),		--统计表编号
	@delManID varchar(10) output,	--删除人，如果当前统计模板正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的统计表是否存在
	declare @count as int
	set @count=(select count(*) from totalCenter where totalTabNum = @totalTabNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	delete totalCenter where totalTabNum = @totalTabNum
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除统计表', '用户' + @delManName
												+ '删除了编号为[' + @totalTabNum + ']的统计表。')
GO

