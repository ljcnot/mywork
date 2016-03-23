use epdc211
/*
	武大设备管理信息系统-设备盘点管理
	注意：设备盘点只指明设备现在的状态，并不改变设备的任何状态，可以通过盘点表生成设备变更的相应调拨单和报废单。
	author:		卢苇
	CreateDate:	2011-11-20
	UpdateDate: 
*/

--1.设备盘点信息：
--1.1设备盘点表：
select * from eqpCheckInfo2
drop TABLE eqpCheckInfo2
CREATE TABLE eqpCheckInfo2(
	checkNum char(12) not null,			--主键：设备盘点号,使用4号号码发生器产生
											--8位日期代码+4位流水号
	applyDate smalldatetime not null,	--盘点开始时间
	expCompleteDate smalldatetime not null,	--预计完成时间 add by lw 2012-7-27
	applyState int default(0),			--设备清查（盘点）单状态：0->新建，1->已生效，2->已作废
	
	--清查（盘点）范围：
	clgCode char(3) not null,			--学院代码
	clgName nvarchar(30) not null,		--学院名称：冗余字段，但是可以解释历史数据	add by lw 2012-5-4
	uCode varchar(8) null,				--使用单位代码
	uName nvarchar(30) null,			--使用单位名称:冗余字段，但是可以保留历史名称add by lw 2012-5-4
	
	checkerID varchar(10) not null,		--盘点负责人工号
	checker nvarchar(30) not null,		--盘点负责人

	verifyManID varchar(10) null,		--审核（生效）人工号
	verifyMan nvarchar(30) null,		--审核人
	verifyDate smalldatetime null,		--审核生效时间

	notes nvarchar(100) null,			--备注
	
	--统计信息：
	staffNumOfLocation int null,		--清查时的院部（或使用单位）的中人数 add by lw 2012-7-27
	eqpNumber int null,					--清查（盘点）总设备数量
	eqpCheckedNumber int null,			--已经确认过的设备数量
	eqpWaitCheckNumber int null,		--待确认设备数量
	eqpNoKeeperNumber int null,			--没有保管人的设备数量
	eqpUploadedPhotoNumber int null,	--已上传照片的设备数量
	eqpNotExistNumber int null,			--明确为“有帐无物、无帐无物”状态的设备
	eqpNeedMaintainNumber int null,		--明确为“待修”状态的设备
	eqpNeedScrapNumber int null,		--明确为“待报废”状态的设备
	eqpNormalNumber int null,			--明确为“正常”状态的设备
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_eqpCheckInfo2] PRIMARY KEY CLUSTERED 
(
	[checkNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--盘点开始日期索引：
CREATE NONCLUSTERED INDEX [IX_eqpCheckInfo2] ON [dbo].[eqpCheckInfo2] 
(
	[applyDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--盘点生效日期索引：
CREATE NONCLUSTERED INDEX [IX_eqpCheckInfo2_1] ON [dbo].[eqpCheckInfo2] 
(
	[verifyDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--盘点人索引：
CREATE NONCLUSTERED INDEX [IX_eqpCheckInfo2_2] ON [dbo].[eqpCheckInfo2] 
(
	[checkerID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--审核人索引：
CREATE NONCLUSTERED INDEX [IX_eqpCheckInfo2_3] ON [dbo].[eqpCheckInfo2] 
(
	[verifyManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--1.2设备盘点明细表：
select * from eqpCheckDetailInfo2
drop TABLE eqpCheckDetailInfo2
CREATE TABLE eqpCheckDetailInfo2(
	checkNum char(12) not null,			--外键：设备清查单号
	eCode char(8) not null,				--设备编号，不设计成外键，以免设备表中删除设备后被动删除了历史信息！
	eName nvarchar(30) not null,		--设备名称:冗余设计
	lockKeeper smallint default(0),		--是否锁定保管人：
													--0->未锁定，
													--1->前期有保管人、或设备管理员指定了保管人(已经指定了保管人)
													--2->系统使用姓名自动匹配到唯一的保管人，
													--9—>本人已确认
	keeperID varchar(10) null,			--保管人工号
	keeper nvarchar(30) null,			--保管人
	eqpLocate nvarchar(100) null,		--设备所在地址
	checkDate smalldatetime null,		--确认日期
	checkStatus char(1) not null,		--清查时的设备状态：
										--0：状态不明
										--1：正常；
										--3：待修；
										--4：待报废；
										--5：有帐无物；
										--6：无帐无物；--这种状态应该无法确定！
										--9：其他。
	statusNotes nvarchar(100) null,		--设备现状说明
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_eqpCheckDetailInfo2] PRIMARY KEY CLUSTERED 
(
	[checkNum] ASC,
	[eCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[eqpCheckDetailInfo2] WITH CHECK ADD CONSTRAINT [FK_eqpCheckDetailInfo2_eqpCheckInfo2] FOREIGN KEY([checkNum])
REFERENCES [dbo].[eqpCheckInfo2] ([checkNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpCheckDetailInfo2] CHECK CONSTRAINT [FK_eqpCheckDetailInfo2_eqpCheckInfo2]
GO
--索引：
--盘点日期索引：
CREATE NONCLUSTERED INDEX [IX_eqpCheckDetailInfo2_1] ON [dbo].[eqpCheckDetailInfo2]
(
	[checkDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--保管人索引：
CREATE NONCLUSTERED INDEX [IX_eqpCheckDetailInfo2_2] ON [dbo].[eqpCheckDetailInfo2]
(
	[keeperID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

delete eqpCheckPhoto
select * from eqpCheckPhoto
--1.3设备现状照片表：这是清查明细表的一个附表！
--图片文件放在eqpCheckPhoto/201111,子目录为上传的日期的年月
drop TABLE eqpCheckPhoto
CREATE TABLE eqpCheckPhoto(
	checkNum char(12) not null,			--外键：设备清查单号
	eCode char(8) not null,				--外键:设备编号
	eName nvarchar(30) not null,		--设备名称:冗余设计
	rowNum bigint IDENTITY(1,1) NOT NULL,--主键:序号
	photoDate smalldatetime not null,	--拍摄日期
	aFilename varchar(128) not NULL,	--主键：图片文件对应的36位全球唯一编码文件名
	notes nvarchar(100) null,			--说明
 CONSTRAINT [PK_eqpCheckPhoto] PRIMARY KEY CLUSTERED 
(
	[checkNum] ASC,
	[eCode] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[eqpCheckPhoto]  WITH CHECK ADD  CONSTRAINT [FK_eqpCheckPhoto_eqpCheckDetailInfo] FOREIGN KEY([checkNum], [eCode])
REFERENCES [dbo].[eqpCheckDetailInfo2] ([checkNum], [eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpCheckPhoto] CHECK CONSTRAINT [FK_eqpCheckPhoto_eqpCheckDetailInfo]
GO
--索引：
--图片名索引：
CREATE NONCLUSTERED INDEX [IX_eqpCheckPhoto] ON [dbo].[eqpCheckPhoto]
(
	[aFilename] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE buildCheckApply
/*
	name:		buildCheckApply
	function:	1.生成设备清查（盘点）表
				注意：该存储过程不锁定单据
	input: 
				@applyDate varchar(10),		--盘点开始时间
				@expCompleteDate varchar(10),--预计完成时间 add by lw 2012-7-27
				@clgCode char(3),			--学院代码
				@uCode varchar(8),			--使用单位代码
				@checkerID varchar(10),		--清查负责人（盘点人）工号 add by lw 2012-7-27
				@notes nvarchar(100),		--备注

				@createManID varchar(10),	--创建人(操作员)工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的清查设备正在被别人编辑或被长事务锁定，9:未知错误
				@createTime smalldatetime output	--添加时间
				@checkNum char(12) output			--生成的设备盘点号,使用4号号码发生器产生
	author:		卢苇
	CreateDate:	2011-11-22
	UpdateDate: 增加使用单位名称 modi by lw 2012-5-4
				增加清查范围所在单位（或院部）的人数统计，将清查负责人和操作员分离 modi by lw 2012-7-27
				增加检查清查设备的编辑锁和长事务锁 modi by lw 2012-7-28

*/
create PROCEDURE buildCheckApply
	@applyDate varchar(10),		--盘点开始时间
	@expCompleteDate varchar(10),--预计完成时间 add by lw 2012-7-27
	@clgCode char(3),			--学院代码
	@uCode varchar(8),			--使用单位代码
	@checkerID varchar(10),		--清查负责人（盘点人）工号 add by lw 2012-7-27
	@notes nvarchar(100),		--备注

	@createManID varchar(10),	--创建人(操作员)工号

	@Ret		int output,
	@createTime smalldatetime output,
	@checkNum char(12) output	--生成的设备盘点号,使用4号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 4, 1, @curNumber output
	set @checkNum = @curNumber

	--取使用单位名称：
	declare @clgName nvarchar(30)	--学院名称
	declare @uName nvarchar(30)		--使用单位名称
	set @clgName = (select clgName from college where clgCode = @clgCode)
	if (@uCode <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	else
		set @uName = ''

	--检查清查锁定的设备是否有编辑锁或长事务锁：
	declare @count int
	set @count = (select COUNT(*) from equipmentList
					where clgCode = @clgCode and (@uCode='' or uCode = @uCode) and curEqpStatus not in('6','7')
						  and (isnull(lockManID,'') <> '' or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 1
		return
	end
	
	--统计清查单位的人数：
	declare @staffNumOfLocation int		--清查时的院部（或使用单位）的中人数 add by lw 2012-7-27
	if (@uCode <> '')
		set @staffNumOfLocation = (select COUNT(*) from userInfo where clgCode = @clgCode and uCode = @uCode)
	else
		set @staffNumOfLocation = (select COUNT(*) from userInfo where clgCode = @clgCode)
		
	--取清查负责人姓名：
	declare @checker nvarchar(30)
	set @checker = isnull((select userCName from activeUsers where userID = @checkerID),'')
	--取维护人姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	if (@applyDate='')
		set @applyDate = convert(varchar(10), getdate(), 120)
		
	set @createTime = getdate()
	begin tran
		insert eqpCheckInfo2(checkNum, applyDate, expCompleteDate, clgCode, clgName, uCode, uName, checkerID, checker, 
							staffNumOfLocation, notes,
							lockManID, modiManID, modiManName, modiTime) 
		values (@checkNum, @applyDate, @expCompleteDate, @clgCode, @clgName, @uCode, @uName, @checkerID, @checker, 
							@staffNumOfLocation, @notes,
							'', @createManID, @createManName, @createTime)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--插入盘点表设备明细：
		insert eqpCheckDetailInfo2(checkNum, eCode, eName, checkStatus, keeperID, keeper)
		select @checkNum, eCode, eName, 0, keeperID, keeper
		from equipmentList
		where clgCode = @clgCode and (@uCode='' or uCode = @uCode) and curEqpStatus not in('6','7')
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--锁定设备列表，防止在清查过程中添加附件、调拨、报废等设备变动：
		update equipmentList
		set lock4LongTime = '1', lInvoiceNum = @checkNum
		where clgCode = @clgCode and (@uCode='' or uCode = @uCode) and curEqpStatus not in('6','7')
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
	commit tran
	set @Ret = 0

	--计算清查设备的保管人状态：
	--根据毕处要求，如果有保管人ID的直接引用保管人ID，如果有唯一保管人姓名匹配给出自动匹配状态，其他给出可能匹配状态
	declare @execRet int
	exec dbo.calcLockKeeperStatus @checkNum, @execRet output

	--更新统计信息； 
	exec dbo.updateCheckTotalInfo @checkNum, @execRet output

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '生成清查单', '系统根据用户' + @createManName + 
					'的要求生成了设备清查单[' + @checkNum + ']。')
GO
--测试：
declare @Ret int,@createTime smalldatetime, @checkNum char(12)
exec dbo.buildCheckApply '2012-07-28','2012-08-27','000','','00200977','测试存储过程','00200977', @Ret output, @createTime output, @checkNum output
select @Ret, @createTime, @checkNum

select * from eqpCheckInfo2 where checkNum='201207280006'
select * from eqpCheckDetailInfo2 where checkNum='201207280006'
select * from equipmentList where eCode = '11003199'

drop PROCEDURE calcLockKeeperStatus
/*
	name:		calcLockKeeperStatus
	function:	1.1.计算清查设备的保管人锁定状态:
					如果没有保管人ID，系统使用姓名匹配，如果有唯一的教职工（在清查范围内的）姓名匹配，则自动填入保管人ID
				注意：该存储过程不检查编辑锁，也不登记工作日志！该存储过程目前为内部过程，不提供C#接口！
	input: 
				@checkNum char(12),			--设备清查单号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的清查单不存在，9：未知错误
	author:		卢苇
	CreateDate:	2012-7-27
	UpdateDate: 

*/
create PROCEDURE calcLockKeeperStatus
	@checkNum char(12),			--设备清查单号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的清查单是否存在
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--获取清查单的清查范围（院部或有使用单位代码）：
	declare @clgCode char(3), @uCode varchar(8)	--学院代码/使用单位代码
	select @clgCode= clgCode, @uCode = uCode from eqpCheckInfo2 where checkNum = @checkNum
	
	--计算保管人锁定状态：
	--逐个扫描清查设备，如果没有保管人ID，则使用姓名自动匹配保管人
	declare @eCode char(8), @keeperID varchar(10), @keeper nvarchar(30)	--设备编号，保管人工号，保管人
	declare tar cursor for
	select eCode, keeperID, keeper from eqpCheckDetailInfo2
	where checkNum = @checkNum
	OPEN tar
	FETCH NEXT FROM tar INTO @eCode, @keeperID, @keeper
	WHILE @@FETCH_STATUS = 0
	begin
		if (@keeperID<> '')	--有明确的保管人
			update eqpCheckDetailInfo2
			set lockKeeper = 1
			where checkNum = @checkNum and eCode = @eCode
		else if (rtrim(ltrim(@keeper))='')	--没有保管人
			update eqpCheckDetailInfo2
			set lockKeeper = 0, keeperID = '', keeper = ''
			where checkNum = @checkNum and eCode = @eCode
		else --使用姓名匹配保管人
		begin
			declare @sName nvarchar(30) --标准名称：不含空格（中英文）
			set @sName = replace(replace(@keeper,' ',''),'　','')
			declare @pNum int	--姓名匹配的记录数
			if (@uCode <> '')
				set @pNum = (select count(*) from userInfo 
				where isOff=0 and clgCode=@clgCode and (uCode is null or uCode = @uCode) and replace(replace(cName,' ',''),'　','') =@sName)
			else 
				set @pNum = (select count(*) from userInfo 
				where isOff=0 and clgCode=@clgCode and replace(replace(cName,' ',''),'　','') =@sName)
			
			if (@pNum = 1)	--有明确的唯一匹配的保管人
			begin
				if (@uCode <> '')
					select @keeperID = jobNumber, @keeper = cName from userInfo 
					where isOff=0 and clgCode=@clgCode and (uCode is null or uCode = @uCode) and replace(replace(cName,' ',''),'　','') =@sName
				else 
					select @keeperID = jobNumber, @keeper = cName from userInfo 
					where isOff=0 and clgCode=@clgCode and replace(replace(cName,' ',''),'　','') =@sName
				update eqpCheckDetailInfo2
				set lockKeeper = 2, keeperID = @keeperID, keeper = @keeper
				where checkNum = @checkNum and eCode = @eCode
			end
			else	--没有匹配的保管人或不止一个匹配的保管人
				update eqpCheckDetailInfo2
				set lockKeeper = 0, keeperID = ''
				where checkNum = @checkNum and eCode = @eCode
		end
		FETCH NEXT FROM tar INTO @eCode, @keeperID, @keeper
	end
	CLOSE tar
	DEALLOCATE tar
	
	set @Ret = 0
GO
--测试：
select * from eqpCheckInfo2
update eqpCheckDetailInfo2
set keeperID='', keeper='毕 卫 民'
where checkNum='201207270001' and eCode = '12000048'

declare @execRet int
exec dbo.calcLockKeeperStatus '201207270001', @execRet output
select @execRet

select * from eqpCheckDetailInfo2 where checkNum = '201207270001'

drop PROCEDURE updateCheckTotalInfo
/*
	name:		updateCheckTotalInfo
	function:	1.2.更新指定的清查（盘点）单统计信息
				注意：该存储过程不检查编辑锁，也不登记工作日志！
	input: 
				@checkNum char(12),			--设备清查（盘点）单号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的清查（盘点）单不存在，9：未知错误
	author:		卢苇
	CreateDate:	2011-11-22
	UpdateDate: 

*/
create PROCEDURE updateCheckTotalInfo
	@checkNum char(12),			--设备清查（盘点）单号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的清查（盘点）单是否存在
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--统计信息：
	declare @eqpNumber int				--清查（盘点）总设备数量
	set @eqpNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum)
	declare @eqpCheckedNumber int, @eqpWaitCheckNumber int, @eqpNoKeeperNumber int
	set @eqpCheckedNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and lockKeeper = 9)		--已经确认过的设备数量
	set @eqpWaitCheckNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and lockKeeper in(1,2))	--待确认设备数量
	set @eqpNoKeeperNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and lockKeeper = 0)	--没有保管人的设备数量
	
	declare @eqpUploadedPhotoNumber int	--已上传照片的设备数量
	set @eqpUploadedPhotoNumber = (select count(*) from eqpCheckDetailInfo2 
							where checkNum = @checkNum and eCode in (select eCode from eqpCheckPhoto where checkNum = @checkNum))

	--checkStatus char(1) not null,		--盘点时的设备状态：
										--0：状态不明
										--1：完好；
										--3：待修；
										--4：待报废；
										--5：有帐无物；
										--6：无帐无物；
										--9：其他。
	declare @eqpNormalNumber int		--明确为“正常”状态的设备
	set @eqpNormalNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and checkStatus = '1')
	declare @eqpNeedMaintainNumber int	--明确为“待修”状态的设备
	set @eqpNeedMaintainNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and checkStatus = '3')
	declare @eqpNeedScrapNumber int		--明确为“待报废”状态的设备
	set @eqpNeedScrapNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and checkStatus = '4')
	declare @eqpNotExistNumber int		--明确为“有帐无物、无帐无物”状态的设备
	set @eqpNeedScrapNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and checkStatus in('5','6'))

	update eqpCheckInfo2
	set eqpNumber = @eqpNumber, eqpCheckedNumber = @eqpCheckedNumber, eqpWaitCheckNumber = @eqpWaitCheckNumber, eqpNoKeeperNumber = @eqpNoKeeperNumber,
		eqpUploadedPhotoNumber =@eqpUploadedPhotoNumber,
		eqpNormalNumber = @eqpNormalNumber, eqpNeedMaintainNumber = @eqpNeedMaintainNumber, eqpNeedScrapNumber = @eqpNeedScrapNumber,
		eqpNotExistNumber = @eqpNotExistNumber
	where checkNum = @checkNum
	set @Ret = 0
GO


drop PROCEDURE queryCheckApplyLocMan
/*
	name:		queryCheckApplyLocMan
	function:	2.查询指定设备清查（盘点）单是否有人正在编辑
	input: 
				@checkNum char(12),			--设备清查（盘点）单号,使用4号号码发生器产生
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的清查（盘点）单不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2011-11-22
	UpdateDate: 
*/
create PROCEDURE queryCheckApplyLocMan
	@checkNum char(12),			--设备清查（盘点）单号,使用4号号码发生器产生
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output		--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from eqpCheckInfo2 where checkNum = @checkNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockCheckInfo4Edit
/*
	name:		lockCheckInfo4Edit
	function:	3.锁定清查（盘点）单开始清查（盘点），避免编辑冲突
	input: 
				@checkNum char(12),			--设备清查（盘点）单号,使用4号号码发生器产生
				@lockManID varchar(10) output,	--锁定人，如果当前清查（盘点）单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的清查（盘点）单不存在，2:要锁定的清查（盘点）单正在被别人编辑，3:该单据已审核（生效）
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-22
	UpdateDate: 
*/
create PROCEDURE lockCheckInfo4Edit
	@checkNum char(12),				--设备清查（盘点）单号,使用4号号码发生器产生
	@lockManID varchar(10) output,	--锁定人，如果当前清查（盘点）单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的盘点单是否存在
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpCheckInfo2 where checkNum = @checkNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	declare @applyState int
	set @applyState = (select applyState from eqpCheckInfo2 where checkNum = @checkNum)
	if (@applyState <> 0)
	begin
		set @Ret = 3
		return
	end

	update eqpCheckInfo2
	set lockManID = @lockManID 
	where checkNum = @checkNum
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定清查单编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了清查单['+ @checkNum +']为独占式编辑。')
GO

drop PROCEDURE unlockCheckInfoEditor
/*
	name:		unlockCheckInfoEditor
	function:	4.释放清查（盘点）单编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@checkNum char(12),				--设备清查（盘点）单号,使用4号号码发生器产生
				@lockManID varchar(10) output,	--锁定人，如果当前清查（盘点）单正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2011-11-22
	UpdateDate: 
*/
create PROCEDURE unlockCheckInfoEditor
	@checkNum char(12),				--设备清查（盘点）单号,使用4号号码发生器产生
	@lockManID varchar(10) output,	--锁定人，如果当前清查（盘点）单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpCheckInfo2 where checkNum = @checkNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update eqpCheckInfo2 set lockManID = '' where checkNum = @checkNum
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
	values(@lockManID, @lockManName, getdate(), '释放清查单编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了清查单['+ @checkNum +']的编辑锁。')
GO

drop PROCEDURE queryCheckEqpLocMan
/*
	name:		queryCheckEqpLocMan
	function:	5.查询指定清查设备是否有人正在编辑
	input: 
				@checkNum char(12),			--设备清查单号
				@eCode char(8),				--设备编号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的清查设备不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2012-7-27
	UpdateDate: 
*/
create PROCEDURE queryCheckEqpLocMan
	@checkNum char(12),			--设备清查单号
	@eCode char(8),				--设备编号
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output		--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode = @eCode),'')
	set @Ret = 0
GO


drop PROCEDURE lockCheckEqp4Edit
/*
	name:		lockCheckEqp4Edit
	function:	6.锁定清查单中指定设备，避免编辑冲突
	input: 
				@checkNum char(12),				--设备清查单号
				@eCode char(8),					--设备编号
				@lockManID varchar(10) output,	--锁定人，如果当前清查单中的指定设备正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的清查设备不存在，2:要锁定的清查设备正在被别人编辑，3:该单据已审核（生效）
							9：未知错误
	author:		卢苇
	CreateDate:	2012-7-27
	UpdateDate: 
*/
create PROCEDURE lockCheckEqp4Edit
	@checkNum char(12),				--设备清查单号
	@eCode char(8),					--设备编号
	@lockManID varchar(10) output,	--锁定人，如果当前清查单中的指定设备正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的清查设备是否存在
	declare @count as int
	set @count=(select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode = @eCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode = @eCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	declare @applyState int
	set @applyState = (select applyState from eqpCheckInfo2 where checkNum = @checkNum)
	if (@applyState <> 0)
	begin
		set @Ret = 3
		return
	end

	update eqpCheckDetailInfo2
	set lockManID = @lockManID 
	where checkNum = @checkNum and eCode = @eCode
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定清查设备编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了清查单['+ @checkNum +']中设备['+@eCode+']为独占式编辑。')
GO

drop PROCEDURE unlockCheckEqpEditor
/*
	name:		unlockCheckEqpEditor
	function:	7.释放清查设备编辑锁
				注意：本过程不检查设备是否存在！
	input: 
				@checkNum char(12),				--设备清查单号
				@eCode char(8),					--设备编号
				@lockManID varchar(10) output,	--锁定人，如果当前清查设备正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2012-7-27
	UpdateDate: 
*/
create PROCEDURE unlockCheckEqpEditor
	@checkNum char(12),				--设备清查单号
	@eCode char(8),					--设备编号
	@lockManID varchar(10) output,	--锁定人，如果当前清查设备正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode = @eCode),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update eqpCheckDetailInfo2 set lockManID = '' where checkNum = @checkNum and eCode = @eCode
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
	values(@lockManID, @lockManName, getdate(), '释放清查设备编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了清查单['+ @checkNum +']中设备['+@eCode+']的编辑锁。')
GO

drop PROCEDURE changeKeeping
/*
	name:		changeKeeping
	function:	8.指定设备保管
				注意：清查（盘点）单生效前设备的信息不会更改！
				当保管人的工号和维护人的工号是同一个人的时候，该功能自动生成确认状态。
				当保管人的工号为空的时候，该功能为撤销指定保管人。
	input: 
				@checkNum char(12),				--设备清查单号
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
	CreateDate:	2012-6-27
	UpdateDate: 
*/
create PROCEDURE changeKeeping
	@checkNum char(12),				--设备清查单号
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
	set @count=(select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode= @eCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode= @eCode),'')
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
	if (@keeperID<>'')
	begin
		--获取保管人姓名：
		declare @keeper nvarchar(30)
		set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
		declare @status smallint
		if (@keeperID = @modiManID)	--确认
			set @status = 9
		else
			set @status = 1			--指定保管人
		update eqpCheckDetailInfo2
		set keeperID = @keeperID, keeper = @keeper, eqpLocate = @eqpLocate, 
			checkDate = @updateTime, lockKeeper = @status,	--0->未锁定，
															--1->前期有保管人、或设备管理员指定了保管人
															--2->系统使用姓名自动匹配到唯一的保管人，
															--9—>本人已确认
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where eCode= @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
		--登记工作日志：
		if (@keeperID = @modiManID)	--确认
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@modiManID, @modiManName, @updateTime, '设备保管确认', '用户[' + @keeper + ']' 
														+ '认领了设备['+ @eCode +']。')
		else	--指派保管人
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@modiManID, @modiManName, @updateTime, '指定设备保管', '用户' + @modiManName 
														+ '将设备['+ @eCode +']保管人指派为['+@keeper+']。')
	end
	else	--撤销保管人
	begin
		update eqpCheckDetailInfo2
		set keeperID = '', keeper = '', eqpLocate = @eqpLocate, 
			checkDate = @updateTime, lockKeeper = 0,--0->未锁定
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where eCode= @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
		--登记工作日志：
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@modiManID, @modiManName, @updateTime, '撤销设备保管', '用户' + @modiManName 
													+ '撤销了设备['+ @eCode +']的保管人。')
	end
	
	--更新统计信息：
	exec dbo.updateCheckTotalInfo @checkNum, @Ret output
	
	set @Ret = 0

GO


drop PROCEDURE updateEqpCheckStatus
/*
	name:		updateEqpCheckStatus
	function:	9.更新清查设备的状态（含设备现状和设备现状图）
				注意：本过程检查编辑锁
	input: 
				@checkNum char(12),			--设备清查单号
				@eCode char(8),				--设备编号
				@checkStatus char(1),		--清查时的设备状态：
													--0：状态不明
													--1：正常；
													--3：待修；
													--4：待报废；
													--5：有帐无物；
													--6：无帐无物；--这种状态应该无法确定！
													--9：其他。
				@statusNotes nvarchar(100),	--设备现状说明
				@photos xml,				--照片信息，采用如下方式存放:
									N'<root>
									  <photo aFileName="90b2bd1c-8789-4223-9f05-2c38f6f000a7.png" photoDate="2012-06-11" notes="设备正面照"/>
									  <photo aFileName="bc1a3c47-00c1-4c7c-93de-f75149db7a9d.png" photoDate="2012-06-11" notes="设备侧面"/>
									</root>'				
				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前清查设备正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的清查设备不存在，
							2:该单据已经生效或作废，不允许修改，3：要更新的清查设备正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-11-22
	UpdateDate: 增加设备现状说明字段，删除确认日期字段 modi by lw 2012-7-27
*/
create PROCEDURE updateEqpCheckStatus
	@checkNum char(12),			--设备清查单号
	@eCode char(8),				--设备编号
	@checkStatus char(1),		--清查时的设备状态：
										--0：状态不明
										--1：正常；
										--3：待修；
										--4：待报废；
										--5：有帐无物；
										--6：无帐无物；--这种状态应该无法确定！
										--9：其他。
	@statusNotes nvarchar(100),	--设备现状说明
	@photos xml,				--照片信息，采用如下方式存放:
						/*	N'<root>
								<photo aFileName="90b2bd1c-8789-4223-9f05-2c38f6f000a7.png" photoDate="2012-06-11" notes="设备正面照"/>
								<photo aFileName="bc1a3c47-00c1-4c7c-93de-f75149db7a9d.png" photoDate="2012-06-11" notes="设备侧面"/>
							</root>'
						*/				
	--维护人:
	@modiManID varchar(10) output,		--维护人，如果当前清查设备正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的清查设备是否存在
	declare @count as int
	set @count=(select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode = @eCode)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode = @eCode
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @applyState int
	select @applyState = applyState from eqpCheckInfo2 where checkNum = @checkNum
	--检查单据状态:
	if (@applyState <> 0)
	begin
		set @Ret = 3
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')


	--取设备名称：
	declare @eName nvarchar(30)	
	set @eName = isnull((select eName from equipmentList where eCode = @eCode),'')

	set @updateTime = getdate()
	begin tran
		--更新清查设备现状:
		update eqpCheckDetailInfo2
		set checkStatus = @checkStatus, statusNotes = @statusNotes,
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime 
		where checkNum = @checkNum and eCode = @eCode
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
		
		--删除设备现状图：
		delete eqpCheckPhoto where checkNum = @checkNum and eCode = @eCode
		--添加设备现状图：
		if (cast(@photos as nvarchar(max))<>N'<root/>')
		begin
			--登记图片：
			insert eqpCheckPhoto(checkNum, eCode, eName, aFileName, photoDate, notes)
			select @checkNum, @eCode, @eName, 
					cast(T.x.query('data(./@aFileName)') as varchar(128)) aFileName,
					cast(T.x.query('data(./@photoDate)') as nvarchar(19)) photoDate,
					cast(T.x.query('data(./@notes)') as nvarchar(500)) notes
			from (select @photos.query('/root/photo') Col1) A OUTER APPLY A.Col1.nodes('/photo') AS T(x)
			if @@ERROR <> 0 
			begin
				rollback tran
				set @Ret = 9
				return
			end    
		end
	commit tran

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新清查设备现状', '用户' + @modiManName 
												+ '更新了清查单['+ @checkNum +']中设备['+ @eCode +']的状态。')
GO
--测试：
declare	@Ret	int
exec dbo.updateEqpCheckStatus '201206110009', '11003199', '1', '设备正常使用，维护情况良好', 
						'<root>
						  <photo aFileName="90b2bd1c-8789-4223-9f05-2c38f6f000a7.png" photoDate="2012-06-11" notes="设备正面照"/>
						  <photo aFileName="bc1a3c47-00c1-4c7c-93de-f75149db7a9d.png" photoDate="2012-06-11" notes="设备侧面"/>
						</root>','00011275',@Ret output
select @Ret
select * from eqpCheckInfo2
select * from eqpCheckPhoto



drop PROCEDURE delCheckInfo
/*
	name:		delCheckInfo
	function:	10.删除指定的设备清查单
	input: 
				@checkNum char(12),				--设备清查单号
				@delManID varchar(10) output,	--删除人，如果当前清查单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的清查单不存在，2：要删除的清查单正被别人锁定，3:该单据已经生效，不能删除，9：未知错误
	author:		卢苇
	CreateDate:	2011-11-22
	UpdateDate: modi by lw 2012-7-28 增加长事务锁处理

*/
create PROCEDURE delCheckInfo
	@checkNum char(12),				--设备清查单号
	@delManID varchar(10) output,	--删除人，如果当前清查单正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的清查单是否存在
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @applyState int
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState
	from eqpCheckInfo2 
	where checkNum = @checkNum
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	if (@applyState = 1)
	begin
		set @Ret = 3
		return
	end
	
	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	begin tran
		--撤销设备的长事务锁：
		update equipmentList
		set lock4LongTime = '0', lInvoiceNum = ''
		where eCode in (select eCode from eqpCheckDetailInfo2 where checkNum = @checkNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--删除清查表：
		delete eqpCheckInfo2 where checkNum = @checkNum
	commit tran
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除设备清查单', '用户' + @delManName
												+ '删除了设备清查单['+ @checkNum +']。')

GO

drop PROCEDURE verifyCheckApply
/*
	name:		verifyCheckApply
	function:	11.生效清查单
	input: 
				@checkNum char(12),					--设备清查单号

				--维护人:
				@verifyManID varchar(10) output,	--生效人（审核人），如果当前清查单正在被人占用编辑则返回该人的工号
	output: 
				@verifyDate smalldatetime output,	--清查生效日期日期
				@Ret		int output				--操作成功标识
													0:成功，1：指定的清查单不存在，2：要生效的清查单正被别人锁定，
													3:要生效的清查单中的设备还有编辑锁未释放，
													5：该清查单已经生效或作废，9：未知错误
	author:		卢苇
	CreateDate:	2011-11-22
	UpdateDate: modi by lw 2012-7-28
				1.增加清查设备的编辑锁判断，将清查的确认信息和现状信息写入设备列表
				2.将作废与生效分离
*/
create PROCEDURE verifyCheckApply
	@checkNum char(12),					--设备清查单号

	@verifyManID varchar(10) output,	--生效人，如果当前清查单正在被人占用编辑则返回该人的工号
	@verifyDate smalldatetime output,	--生效日期
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的盘点单是否存在
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @applyState int
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState
	from eqpCheckInfo2 
	where checkNum = @checkNum
	--检查单据编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @verifyManID)
	begin
		set @verifyManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	if (@applyState <> 0)
	begin
		set @Ret = 5
		return
	end
	
	--检查清查设备编辑锁：
	select @count = (select COUNT(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and isnull(lockManID,'') <> '')
	if (@count > 0)
	begin
		set @Ret = 3
		return
	end
	

	--取维护人的姓名：
	declare @verifyMan nvarchar(30)
	set @verifyMan = isnull((select userCName from activeUsers where userID = @verifyManID),'')

	--更新统计信息：
	declare @execRet int
	exec dbo.updateCheckTotalInfo @checkNum, @execRet output

	set @verifyDate = getdate()
	
	begin tran
		--逐个扫描清查设备，更新设备列表和设备现状表：
		declare @eCode char(8)	--设备清查单号/设备编号
		declare @lockKeeper smallint	--是否锁定保管人：
										--0->未锁定，
										--1->前期有保管人、或设备管理员指定了保管人
										--2->系统使用姓名自动匹配到唯一的保管人，
										--9—>本人已确认
		declare @keeperID varchar(10), @keeper nvarchar(30), @eqpLocate nvarchar(100)	--保管人工号/保管人/设备所在地址
		declare tar cursor for
		select eCode, lockKeeper, keeperID, keeper, eqpLocate
		from eqpCheckDetailInfo2
		where checkNum = @checkNum
		OPEN tar
		FETCH NEXT FROM tar INTO @eCode, @lockKeeper, @keeperID, @keeper, @eqpLocate
		WHILE @@FETCH_STATUS = 0
		begin
			--将现状写入设备现状表：
			--计算设备现状批次号：
			declare @sNumber int	--现状批次号
			set @sNumber = ISNULL((select MAX(sNumber) from eqpStatusInfo where eCode = @eCode),0)
			set @sNumber = @sNumber + 1
			if (@lockKeeper<>9)
			begin
				set @keeperID = ''
				set @keeper = ''
			end
			insert into eqpStatusInfo(eCode, eName, sNumber, checkDate, keeperID, keeper, eqpLocate, 
								checkStatus, statusNotes, invoiceType, invoiceNum)
			select @eCode, eName, @sNumber, checkDate, @keeperID, @keeper, @eqpLocate, 
								case checkStatus when '0' then '1' else checkStatus end, statusNotes, '5', @checkNum
								--自动将状态不明转化为正常状态
			from eqpCheckDetailInfo2
			where checkNum = @checkNum and eCode = @eCode
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			--将现状图写入设备现状图表：
			insert into eqpStatusPhoto(eCode, eName, sNumber, photoDate, aFilename, notes)
			select @eCode, eName, @sNumber, photoDate, aFilename, notes
			from eqpCheckPhoto
			where checkNum = @checkNum and eCode = @eCode
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			if (@lockKeeper=9) --有设备确认信息
			begin
				--获取设备保管人的隶属院部和使用单位信息：
				declare @clgCode char(3), @uCode varchar(8)		--学院代码/使用单位代码
				select @clgCode = clgCode, @uCode = uCode
				from userInfo
				where jobNumber = @keeperID
				
				--获取原设备隶属信息：
				declare @oldClgCode char(3), @oldUCode varchar(8)		--原学院代码/原使用单位代码
				declare @oldKeeperID varchar(10), @oldEqpLocate nvarchar(100)	--原保管人工号/设备所在地址
				select @oldClgCode = clgCode, @oldUCode = uCode, @oldKeeperID = keeperID, @oldEqpLocate = eqpLocate
				from equipmentList
				where eCode = @eCode
				
				if (@clgCode is null)
				begin
					set @clgCode = @oldClgCode
					set @uCode = @oldUCode
				end
				else if (@uCode is null)
				begin
					set @uCode = @oldUCode
				end
				--如果变动了保管信息：
				if ((@clgCode is not null and @clgCode <> @oldClgCode)
					or (@uCode is not null and @uCode <> @oldUCode)
					or @keeperID <> @oldKeeperID or @eqpLocate <> @oldEqpLocate)
				begin
					--登记设备生命周期表:
					insert eqpLifeCycle(eCode,eName, eModel, eFormat, clgCode, clgName, uCode, uName, 
						keeperID, keeper, eqpLocate,
						annexAmount, price, totalAmount,
						changeDate, changeDesc,changeType,changeInvoiceID) 
					select @eCode, e.eName, e.eModel, e.eFormat, @clgCode, clg.clgName, @uCode, u.uName, 
						@keeperID, @keeper, @eqpLocate,
						e.annexAmount, e.price, e.totalAmount,
						c.checkDate, '清查设备时变更了该设备的保管信息',
						'清查',@checkNum
					from equipmentList e inner join eqpCheckDetailInfo2 c on e.eCode = c.eCode
						left join college clg on clg.clgCode = @clgCode
						left join useUnit u on u.clgCode = @clgCode and u.uCode = @uCode
					where c.checkNum = @checkNum and c.eCode = @eCode
					
					--更新设备保管信息：
					update equipmentList
					set clgCode = @clgCode, uCode = @uCode, keeperID = @keeperID, keeper = @keeper, eqpLocate = @eqpLocate
					where eCode = @eCode
					if @@ERROR <> 0 
					begin
						set @Ret = 9
						rollback tran
						return
					end    
				end
			end

			FETCH NEXT FROM tar INTO @eCode, @lockKeeper, @keeperID, @keeper, @eqpLocate
		end
		CLOSE tar
		DEALLOCATE tar
		
		--将设备清查表标记为生效状态：
		update eqpCheckInfo2
		set applyState = 1,	--设备盘点单状态：0->新建，1->已生效，2->已作废
			verifyManID = @verifyManID, verifyMan = @verifyMan, verifyDate = @verifyDate
		where checkNum = @checkNum 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--释放设备长事务锁：
		update equipmentList
		set lock4LongTime = '0', lInvoiceNum = ''
		where eCode in (select eCode from eqpCheckDetailInfo2 where checkNum = @checkNum)
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
	values(@verifyManID, @verifyMan, @verifyDate, '清查单生效', '用户' + @verifyMan
												+ '审核生效了设备清查单['+ @checkNum +']。')
GO
--测试：


drop PROCEDURE cancelVerifyCheck
/*
	name:		cancelVerifyCheck
	function:	12.撤销清查单的生效
				注意：该功能不能撤销设备被更新的状态！也有可能无法撤销设备生命周期表中添加的记录！
	input: 
				@checkNum char(12),					--设备清查单号

				--维护人:
				@cancelManID varchar(10) output,	--取消人，如果当前清查单正在被人占用编辑则返回该人的工号
	output: 
				@cancelDate smalldatetime output,	--取消日期
				@Ret		int output				--操作成功标识
													0:成功，1：指定的清查单不存在,2：要撤销生效的清查单正被别人锁定，
													3：该单据不是已生效状态，
													4：要撤销生效的清查单中的设备正被别人编辑锁定，9：未知错误
	author:		卢苇
	CreateDate:	2011-11-22
	UpdateDate: modi by lw 2012-7-28
				1.增加删除生效清查单所添加的设备现状记录和设备生命周期记录
				2.增加设备的长事务锁
*/
create PROCEDURE cancelVerifyCheck
	@checkNum char(12),					--设备清查单号
	@cancelManID varchar(10) output,	--取消人，如果当前清查单正在被人占用编辑则返回该人的工号
	@cancelDate smalldatetime output,	--取消日期
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的清查单是否存在
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @applyState int
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState
	from eqpCheckInfo2 
	where checkNum = @checkNum
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @cancelManID)
	begin
		set @cancelManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查清查状态:
	if (@applyState <> 1)
	begin
		set @Ret = 3
		return
	end

	--检查清查锁定的设备是否有编辑锁或长事务锁：
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from eqpCheckDetailInfo2 where checkNum = @checkNum)
						  and (isnull(lockManID,'') <> '' or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 4
		return
	end

	--取维护人的姓名\时间：
	declare @cancelMan nvarchar(30)
	set @cancelMan = isnull((select userCName from activeUsers where userID = @cancelManID),'')
	set @cancelDate = getdate()

	begin tran
		--删除该清查单生成的设备现状表记录：
		delete eqpStatusInfo
		where invoiceType = '5' and invoiceNum = @checkNum

		--逐设备删除可能的清查单生成的设备生命周期表记录:必须是最后一条
		declare @eCode char(8)	--设备清查单号/设备编号
		declare tar cursor for
		select eCode from eqpCheckDetailInfo2 where checkNum = @checkNum
		OPEN tar
		FETCH NEXT FROM tar INTO @eCode
		WHILE @@FETCH_STATUS = 0
		begin
			declare @changeType varchar(10), @changeInvoiceID varchar(30)	--变动类型/变动凭证号
			select top 1 @changeType = changeType, @changeInvoiceID = changeInvoiceID 
			from eqpLifeCycle
			where eCode = @eCode
			order by rowNum desc
			
			if (@changeType='清查' and @changeInvoiceID = @checkNum)
			begin
				delete eqpLifeCycle
				where eCode = @eCode and changeType='清查' and changeInvoiceID = @checkNum
			end
			
			FETCH NEXT FROM tar INTO @eCode
		end
		CLOSE tar
		DEALLOCATE tar
		
		--将设备清查表标记为活动状态：
		update eqpCheckInfo2
		set applyState = 0,	--设备清查单状态：0->新建，1->已生效，2->已作废
			verifyManID = '', verifyMan = '', verifyDate = null
		where checkNum = @checkNum 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--重新锁定设备长事务锁：
		update equipmentList
		set lock4LongTime = '1', lInvoiceNum = @checkNum
		where eCode in (select eCode from eqpCheckDetailInfo2 where checkNum = @checkNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	
	commit tran
	
	set @Ret = 0
	--更新统计信息：
	declare @execRet int
	exec dbo.updateCheckTotalInfo @checkNum, @execRet output

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@cancelManID, @cancelMan, @cancelDate, '撤销清查单生效', '用户' + @cancelMan
												+ '撤销了清查单['+ @checkNum +']的生效。')

GO

drop PROCEDURE revokeCheckApply
/*
	name:		revokeCheckApply
	function:	13.废除清查单
	input: 
				@checkNum char(12),					--设备清查单号

				--维护人:
				@revokeManID varchar(10) output,	--废除人，如果当前清查单正在被人占用编辑则返回该人的工号
	output: 
				@revokeDate smalldatetime output,	--废除日期
				@Ret		int output				--操作成功标识
													0:成功，1：指定的清查单不存在，2：要废除的清查单正被别人锁定，
													3:要废除的清查单中的设备还有编辑锁未释放，
													5：该清查单已经生效或废除，9：未知错误
	author:		卢苇
	CreateDate:	2012-7-28
	UpdateDate: 
*/
create PROCEDURE revokeCheckApply
	@checkNum char(12),					--设备清查单号

	@revokeManID varchar(10) output,	--废除人，如果当前清查单正在被人占用编辑则返回该人的工号
	@revokeDate smalldatetime output,	--废除日期
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的盘点单是否存在
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @applyState int
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState
	from eqpCheckInfo2 
	where checkNum = @checkNum
	--检查单据编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @revokeManID)
	begin
		set @revokeManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	if (@applyState <> 0)
	begin
		set @Ret = 5
		return
	end
	
	--检查清查设备编辑锁：
	select @count = (select COUNT(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and isnull(lockManID,'') <> '')
	if (@count > 0)
	begin
		set @Ret = 3
		return
	end
	

	--取维护人的姓名：
	declare @revokeMan nvarchar(30)
	set @revokeMan = isnull((select userCName from activeUsers where userID = @revokeManID),'')

	set @revokeDate = getdate()
	
	begin tran
		--将设备清查表标记为生效状态：
		update eqpCheckInfo2
		set applyState = 2,	--设备盘点单状态：0->新建，1->已生效，2->已作废
			verifyManID = @revokeManID, verifyMan = @revokeMan, verifyDate = @revokeDate
		where checkNum = @checkNum 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--释放设备长事务锁：
		update equipmentList
		set lock4LongTime = '0', lInvoiceNum = ''
		where eCode in (select eCode from eqpCheckDetailInfo2 where checkNum = @checkNum)
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
	values(@revokeManID, @revokeMan, @revokeDate, '清查单作废', '用户' + @revokeMan
												+ '将设备清查单['+ @checkNum +']作废。')
GO




select 
checkNum, convert(varchar(10),applyDate,120) applyDate, case applyState when 0 then '‥' when 1 then '√' when 2 then '╳' end applyState,
clgCode, clgName, uCode, uName, checkerID, checker, verifyManID, verifyMan, isnull(convert(varchar(10),verifyDate,120),'') verifyDate,
eqpNumber, eqpCheckedNumber, eqpNotExistNumber, 
eqpNeedMaintainNumber, eqpNeedScrapNumber, eqpNormalNumber, notes, eqpUploadedPhotoNumber
from
eqpCheckInfo2
select * 
	
	
	
use epdc2	
select ch.lockKeeper,e.eCode,convert(varchar(10),e.acceptDate,120) as acceptDate,case e.curEqpStatus when '1' then '在用' when '2' then '多余' when '3' then '待修' when '4' then '待报废'when '5' then '丢失' when '6' then '报废' when '7' then '调出' when '8' then '降档' when '9' then '其他' else '未知' end curEqpStatus,e.eName,e.eModel,e.eFormat,clg.clgName,u.uName,e.keeper,ch.keeper,c.cName,e.factory,e.serialNumber,convert(varchar(10),e.makeDate,120) as makeDate,e.business,e.annexCode,e.annexName,e.annexAmount,e.eTypeCode,e.aTypeCode,f.fName,a.aName,convert(varchar(10),e.buyDate,120) as buyDate,e.price,e.totalAmount,e.oprMan, e.acceptMan, e.notes,case e.curEqpStatus when '6' then convert(char(10), e.scrapDate, 120) else '' end scrapDate,e.cCode,e.fCode,e.aCode,e.clgCode,e.uCode
from 
 eqpCheckDetailInfo2 ch left join equipmentList e on ch.eCode = e.eCode 
	left join country c on e.cCode = c.cCode 
	left join fundSrc f on e.fCode = f.fCode 
	left join appDir a on e.aCode = a.aCode 
	left join college clg on e.clgCode = clg.clgCode 
	left join useUnit u on e.uCode = u.uCode 
