use epdc211
/*
	武大设备管理信息系统-公告板管理
	author:		卢苇
	CreateDate:	2011-11-23
	UpdateDate: 
*/
--1.站内公告一览表（bulletinInfo）：
select bulletinID a,* from bulletinInfo where isActive =1 order by isActive desc, orderNum, a desc
update bulletinInfo
set lockManID = ''

drop TABLE bulletinInfo
CREATE TABLE bulletinInfo
(
	bulletinID char(12) not null,			--主键：公告编号，使用第 10010 号号码发生器产生
	bulletinTime datetime null,				--公告时间
	bulletinTitle nvarchar(100) null,		--公告标题
	bulletinHTML nvarchar(max) null,		--公告内容

	isActive int default(0),				--是否显示（激活）：0->未激活，1->已激活
	activeDate smalldatetime null,			--激活日期
	orderNum smallint default(-1),			--显示排序号
	autoCloseDate smalldatetime null,		--自动关闭日期

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
CONSTRAINT [PK_bulletinInfo] PRIMARY KEY CLUSTERED 
(
	[bulletinID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_bulletinInfo] ON [dbo].[bulletinInfo] 
(
	[bulletinTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_bulletinInfo_0] ON [dbo].[bulletinInfo] 
(
	[isActive] ASC,
	[orderNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


--1.2公告板多媒体资源管理表
--多媒体文件放在bulletin\media中
drop TABLE bulletinResouce
CREATE TABLE bulletinResouce(
	resouceName nvarchar(30) not null,	--资源名称
	resouceType smallint not null,		--资源类型：1->图片，2->影音文件
	fileGUID36 varchar(36) not NULL,	--资源文件对应的36位全球唯一编码文件名
	oldFilename varchar(128) not null,	--资源文件原始文件名
	extFileName varchar(8) not NULL,	--资源文件文件扩展名
	notes nvarchar(100) null,			--说明
	ownerID varchar(10) null,			--所有人工号
	ownerName varchar(30) null,			--所有人姓名
	isShare char(1) default('N')		--是否共享
 CONSTRAINT [PK_bulletinResouce] PRIMARY KEY CLUSTERED 
(
	[resouceType] ASC,
	[fileGUID36] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--资源名索引：
CREATE NONCLUSTERED INDEX [IX_bulletinResouce] ON [dbo].[bulletinResouce]
(
	[resouceName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE addBulletinInfo
/*
	name:		addBulletinInfo
	function:	1.添加公告信息
				注意：该存储过程自动锁定单据
	input: 
				@bulletinTitle nvarchar(100),	--公告标题
				@bulletinTime varchar(10),		--公告日期
				@autoCloseDate varchar(10),		--公告自动关闭日期
				@bulletinHTML nvarchar(max),	--公告内容

				@createManID varchar(10),		--创建人工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output,
				@bulletinID char(12) output		--主键：公告编号，使用第 10010 号号码发生器产生
	author:		卢苇
	CreateDate:	2011-11-23
	UpdateDate: modi by lw 2011-12-4增加公告日期和自动关闭日期参数

*/
create PROCEDURE addBulletinInfo
	@bulletinTitle nvarchar(100),		--公告标题
	@bulletinTime varchar(10),		--公告日期
	@autoCloseDate varchar(10),		--公告自动关闭日期
	@bulletinHTML nvarchar(max),		--公告内容

	@createManID varchar(10),			--创建人工号

	@Ret		int output,
	@createTime smalldatetime output,
	@bulletinID char(12) output			--主键：公告编号，使用第 10010 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10010, 1, @curNumber output
	set @bulletinID = @curNumber

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	
	set @createTime = getdate()
	if (@bulletinTime='')
		set @bulletinTime = CONVERT(varchar(10), @createTime, 120)

	insert bulletinInfo(bulletinID, bulletinTime, autoCloseDate, bulletinTitle, bulletinHTML,
							lockManID, modiManID, modiManName, modiTime) 
	values (@bulletinID, @bulletinTime, @autoCloseDate, @bulletinTitle, @bulletinHTML,
							@createManID, @createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加公告', '系统根据用户' + @createManName + 
					'的要求添加了公告[' + @bulletinID + ']。')
GO


DROP PROCEDURE activeBulletinInfo
/*
	name:		activeBulletinInfo
	function:	2.激活指定的公告，并自动排序在最后
	input: 
				@bulletinID char(12),			--公告编号
				@autoCloseDate varchar(10),		--自动关闭日期
				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要激活的公告不存在，2:要激活的公告正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-23
	UpdateDate: 
*/
create PROCEDURE activeBulletinInfo
	@bulletinID char(12),			--公告编号
	@autoCloseDate varchar(10),		--自动关闭日期

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--检查默认关闭时间：
	if (@autoCloseDate ='')
		set @autoCloseDate = convert(varchar(10), dateadd(day, 7, getdate()), 120)
	
	set @updateTime = getdate()
	declare @curMaxOrderNum int
	set @curMaxOrderNum = isnull((select max(orderNum) from bulletinInfo where isActive = 1),0)
	update bulletinInfo
	set isActive = 1, activeDate = @updateTime,
		autoCloseDate = @autoCloseDate,
		
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID

	--将该公告置顶：
	declare @execRet int
	exec dbo.setBulletinToTop @bulletinID, @modiManID output, @execRet output

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '激活公告', '用户' + @modiManName 
												+ '激活了公告['+ @bulletinID +']。')
GO

DROP PROCEDURE setOffBulletinInfo
/*
	name:		setOffBulletinInfo
	function:	3.休眠指定的公告
	input: 
				@bulletinID char(12),			--公告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要休眠的公告不存在，2:要休眠的公告正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-23
	UpdateDate: 
*/
create PROCEDURE setOffBulletinInfo
	@bulletinID char(12),			--公告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
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
	update bulletinInfo
	set isActive = 0, activeDate = null, autoCloseDate = null,
		orderNum = -1,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '关闭公告', '用户' + @modiManName 
												+ '关闭了公告['+ @bulletinID +']。')
GO

drop PROCEDURE delBulletinInfo
/*
	name:		delBulletinInfo
	function:	3.删除指定的公告
	input: 
				@bulletinID char(12),			--公告编号
				@delManID varchar(10) output,	--删除人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：该公告不存在，2:要删除的公告信息正被别人锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-24
	UpdateDate:
*/
create PROCEDURE delBulletinInfo
	@bulletinID char(12),			--公告编号
	@delManID varchar(10) output,	--删除人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete bulletinInfo where bulletinID = @bulletinID
	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除公告', '用户' + @delManName
												+ '删除了公告['+ @bulletinID +']。')

GO
--测试：


DROP PROCEDURE updateBulletinInfo
/*
	name:		updateBulletinInfo
	function:	4.更新指定的公告内容或标题
	input: 
				@bulletinID char(12),			--公告编号
				@bulletinTitle nvarchar(100),	--公告标题
				@bulletinTime varchar(10),		--公告日期
				@autoCloseDate varchar(10),		--公告自动关闭日期
				@bulletinHTML nvarchar(max),	--公告内容

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要修改的公告不存在，2:要修改的公告正在被别人编辑，3.该公告已激活，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-24
	UpdateDate: modi by lw 2011-12-4增加公告日期和自动关闭日期参数

*/
create PROCEDURE updateBulletinInfo
	@bulletinID char(12),			--公告编号
	@bulletinTitle nvarchar(100),	--公告标题
	@bulletinTime varchar(10),		--公告日期
	@autoCloseDate varchar(10),		--公告自动关闭日期
	@bulletinHTML nvarchar(max),	--公告内容

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查公告状态:
	declare @isActive int
	set @isActive = (select isActive from bulletinInfo where bulletinID = @bulletinID)
	if (@isActive <> 0)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	if (@bulletinTime='')
		set @bulletinTime=CONVERT(varchar(10),@updateTime, 120)

	update bulletinInfo
	set bulletinTitle = @bulletinTitle, bulletinHTML = @bulletinHTML,
		bulletinTime = @bulletinTime, autoCloseDate = @autoCloseDate,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where bulletinID = @bulletinID

	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '修改公告', '用户' + @modiManName 
												+ '修改了公告['+ @bulletinID +']。')
GO


drop PROCEDURE closeDieingBulletinInfo
/*
	name:		closeDieingBulletinInfo
	function:	5.自动关闭到期的公告（这个过程是给维护计划调度用，用户不用包装）
	input: 
	output: 
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate:
*/
create PROCEDURE closeDieingBulletinInfo
	WITH ENCRYPTION 
AS
	declare @count as int
	set @count=(select count(*) from bulletinInfo where isActive =1 and convert(varchar(10),autoCloseDate,120) <= convert(varchar(10),getdate(),120))	
	if (@count = 0)	--不存在
	begin
		return
	end

	update bulletinInfo
	set isActive = 0, activeDate = null, autoCloseDate = null,
		orderNum = 0
	where isActive =1 and convert(varchar(10),autoCloseDate,120) <= convert(varchar(10),getdate(),120)

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values('', 'System', getdate(), '自动关闭到期公告', '系统执行了自动关闭到期公告的计划关闭了'+cast(@count as varchar(10))+'个到期的公告。')
GO
--测试：
exec dbo.closeDieingBulletinInfo
select * from bulletinInfo where isActive =1
update bulletinInfo
set autoCloseDate = getdate()
where bulletinID='201111260001'


DROP PROCEDURE setBulletinToTop
/*
	name:		setBulletinToTop
	function:	6.将指定的可显示公告置顶
	input: 
				@bulletinID char(12),			--公告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要置顶的公告不存在，2:要置顶的公告正在被别人编辑，3.该公告未激活，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE setBulletinToTop
	@bulletinID char(12),			--公告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int
	select @thisLockMan = isnull(lockManID,''), @isActive = isActive from bulletinInfo where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查公告状态:
	if (@isActive <> 1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--将已发布的公告重新排序：
	declare @tab table
					(
						bulletinID char(12) not null,			--主键：公告编号，使用第 10010 号号码发生器产生
						orderNum smallint default(-1)			--显示排序号
					)
	insert @tab
	select bulletinID, orderNum from bulletinInfo 
	where isActive =1 and bulletinID <> @bulletinID
	order by orderNum
	begin tran
		declare @bID char(12), @i int
		set @i = 1
		declare tar cursor for
		select bulletinID from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @bID
		WHILE @@FETCH_STATUS = 0
		begin
			update bulletinInfo
			set orderNum = @i
			where bulletinID = @bID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			set @i = @i + 1
			FETCH NEXT FROM tar INTO @bID
		end
		CLOSE tar
		DEALLOCATE tar
		--将指定的公告置顶：	
		update bulletinInfo
		set orderNum = 0
		where bulletinID = @bulletinID
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
	values(@modiManID, @modiManName, getdate(), '公告置顶', '用户' + @modiManName 
												+ '将公告['+ @bulletinID +']置顶。')
GO
--测试：
select * from bulletinInfo
declare @Ret int 
exec dbo.setBulletinToTop '201111260001', '00200977', @Ret output

DROP PROCEDURE setBulletinToLast
/*
	name:		setBulletinToLast
	function:	7.将指定的可显示公告上移一行
	input: 
				@bulletinID char(12),			--公告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要移动的公告不存在，2:要移动的公告正在被别人编辑，3.该公告未激活，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE setBulletinToLast
	@bulletinID char(12),			--公告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int
	declare @myOrderNum smallint --本公告的排序号
	select @thisLockMan = isnull(lockManID,''), @isActive = isActive, @myOrderNum = orderNum from bulletinInfo where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查公告状态:
	if (@isActive <> 1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--将已发布的位置在本公告前面的公告重新排序：
	declare @tab table
					(
						bulletinID char(12) not null,			--主键：公告编号，使用第 10010 号号码发生器产生
						orderNum smallint default(-1)			--显示排序号
					)
	insert @tab
	select bulletinID, orderNum from bulletinInfo 
	where isActive =1 and orderNum < @myOrderNum
	order by orderNum
	
	begin tran
		declare @bID char(12), @i int
		set @i = 1
		declare tar cursor for
		select bulletinID from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @bID
		WHILE @@FETCH_STATUS = 0
		begin
			update bulletinInfo
			set orderNum = @i
			where bulletinID = @bID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			set @i = @i + 1
			FETCH NEXT FROM tar INTO @bID
		end
		CLOSE tar
		DEALLOCATE tar
		--将指定的公告上移一行：	
		update bulletinInfo
		set orderNum = @i
		where bulletinID = @bID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		update bulletinInfo
		set orderNum = @i - 1
		where bulletinID = @bulletinID
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
	values(@modiManID, @modiManName, getdate(), '公告上移一行', '用户' + @modiManName 
												+ '将公告['+ @bulletinID +']上移了一行。')
GO
--测试：
select * from bulletinInfo 
where isActive =1 
order by orderNum

declare @updateTime smalldatetime 
declare @Ret int 
exec dbo.setBulletinToLast '201111270001', '00200977', @Ret output

DROP PROCEDURE setBulletinToNext
/*
	name:		setBulletinToNext
	function:	8.将指定的可显示公告下移一行
	input: 
				@bulletinID char(12),			--公告编号

				--维护情况:
				@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要移动的公告不存在，2:要移动的公告正在被别人编辑，3.该公告未激活，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE setBulletinToNext
	@bulletinID char(12),			--公告编号

	--维护情况:
	@modiManID varchar(10) output,	--维护人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	declare @isActive int
	declare @myOrderNum smallint --本公告的排序号
	select @thisLockMan = isnull(lockManID,''), @isActive = isActive, @myOrderNum = orderNum from bulletinInfo where bulletinID = @bulletinID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查公告状态:
	if (@isActive <> 1)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--将本公告与下一个公告交换位置：
	declare @nextBulletinID char(12), @nextOrderNum smallint
	select top 1 @nextBulletinID = bulletinID, @nextOrderNum = orderNum 
	from bulletinInfo 
	where isActive =1 and orderNum > @myOrderNum
	order by orderNum
	
	if (@nextBulletinID is not null)
	begin
		begin tran
			update bulletinInfo 
			set orderNum = @nextOrderNum
			where bulletinID = @bulletinID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			update bulletinInfo 
			set orderNum = @myOrderNum
			where bulletinID = @nextBulletinID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		commit tran
	end
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), '公告下移一行', '用户' + @modiManName 
												+ '将公告['+ @bulletinID +']下移了一行。')
GO
--测试：
select * from bulletinInfo 
where isActive =1 
order by orderNum

declare @updateTime smalldatetime 
declare @Ret int 
exec dbo.setBulletinToNext '201111270001', '00200977', @Ret output

drop PROCEDURE queryBulletinLocMan
/*
	name:		queryBulletinLocMan
	function:	9.查询指定公告是否有人正在编辑
	input: 
				@bulletinID char(12),			--公告号,使用10010号号码发生器产生
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的公告不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE queryBulletinLocMan
	@bulletinID char(12),			--公告号,使用10010号号码发生器产生
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	set @Ret = 0
GO


drop PROCEDURE lockBulletin4Edit
/*
	name:		lockBulletin4Edit
	function:	10.锁定公告开始编辑，避免编辑冲突
	input: 
				@bulletinID char(12),			--公告号,使用10010号号码发生器产生
				@lockManID varchar(10) output,	--锁定人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的公告不存在，2:要锁定的公告正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE lockBulletin4Edit
	@bulletinID char(12),			--公告号,使用10010号号码发生器产生
	@lockManID varchar(10) output,	--锁定人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的公告是否存在
	declare @count as int
	set @count=(select count(*) from bulletinInfo where bulletinID = @bulletinID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	update bulletinInfo
	set lockManID = @lockManID 
	where bulletinID = @bulletinID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定公告编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了公告['+ @bulletinID +']为独占式编辑。')
GO

drop PROCEDURE unlockBulletinEditor
/*
	name:		unlockBulletinEditor
	function:	11.释放公告编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@bulletinID char(12),			--公告号,使用10010号号码发生器产生
				@lockManID varchar(10) output,	--锁定人，如果当前公告正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE unlockBulletinEditor
	@bulletinID char(12),			--公告号,使用10010号号码发生器产生
	@lockManID varchar(10) output,	--锁定人，如果当前公告正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from bulletinInfo where bulletinID = @bulletinID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update bulletinInfo set lockManID = '' where bulletinID = @bulletinID
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
	values(@lockManID, @lockManName, getdate(), '释放公告编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了公告['+ @bulletinID +']的编辑锁。')
GO

drop PROCEDURE addResource
/*
	name:		12.addResource
	function:	添加资源文件
				注意：该存储过程不登记工作日志
	input: 
				@resouceName nvarchar(30),	--资源名称
				@resouceType smallint,		--资源类型：1->图片，2->影音文件
				@oldFilename varchar(128),	--资源文件原始文件名
				@extFileName varchar(8),	--资源文件文件扩展名
				@notes nvarchar(100),		--说明
				@ownerID varchar(10),		--所有人工号
				@isShare char(1),			--是否共享
	output: 
				@Ret		int output,	--操作成功标识
							0:成功，9：未知错误
				@fileGUID36 varchar(36) output	--系统分配的资源文件36位全球唯一编码文件名
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 
*/
create PROCEDURE addResource
	@resouceName nvarchar(30),	--资源名称
	@resouceType smallint,		--资源类型：1->图片，2->影音文件
	@oldFilename varchar(128),	--资源文件原始文件名
	@extFileName varchar(8),	--资源文件文件扩展名
	@notes nvarchar(100),		--说明
	@ownerID varchar(10),		--所有人工号
	@isShare char(1),			--是否共享

	@Ret int output,			--操作成功标识
	@fileGUID36 varchar(36) output	--系统分配的资源文件36位全球唯一编码文件名
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--取所有人姓名：
	declare @ownerName varchar(30)		--所有人姓名
	set @ownerName = isnull((select userCName from activeUsers where userID = @ownerID),'')

	--生成唯一的文件名：
	set @fileGUID36 = (select newid())

	--登记资源信息：
	insert bulletinResouce(resouceName, resouceType, fileGUID36, oldFilename, extFileName,
							notes, ownerID, ownerName, isShare)
	values(@resouceName, @resouceType, @fileGUID36, @oldFilename, @extFileName,
							@notes, @ownerID, @ownerName, @isShare)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end   

	set @Ret = 0
GO


drop PROCEDURE delResource
/*
	name:		delResource
	function:	13.删除指定的资源文件
				注意：该存储过程不登记工作日志，也不删除文件！
	input: 
				@fileGUID36 varchar(36),	--资源文件名称
				@delManID varchar(10),		--删除人
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2011-11-27
	UpdateDate: 

*/
create PROCEDURE delResource
	@fileGUID36 varchar(36),	--资源文件名称
	@delManID varchar(10),		--删除人
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	delete bulletinResouce where fileGUID36 = @fileGUID36
	set @Ret = 0
GO
