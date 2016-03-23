use hustOA
/*
	强磁场中心办公系统-资料管理
	根据武大外贸合同管理信息系统资料管理改编
	author:		卢苇
	CreateDate:	2013-1-14
	UpdateDate: 
*/
--1多媒体资料管理表
--多媒体文件放在~\upload\resouce\目录中，按类别存放，分别为：picture（图片）、media（影音文件）、doc（文档）、template（模板）
select * from resourceInfo
update resourceInfo
set isPublish='Y'

drop TABLE resourceInfo
CREATE TABLE resourceInfo(
	resourceTheme nvarchar(30) not null,--主题分类
	resourceName nvarchar(30) not null,	--资料名称
	resourceType varchar(30) not null,	--资料类型：picture（图片）、media（影音文件）、doc（文档）、template（模板）
	rFilename varchar(128) not NULL,	--资料文件唯一文件名：这是上传控件创建的文件名（含路径）
	notes nvarchar(100) null,			--说明
	uploadDate smalldatetime default(getdate()), --上传日期
	isPublish char(1) default('N'),		--是否发布
	orderNum smallint default(-1),		--显示排序号
	usedTimes bigint default(0),		--使用次数：这是做热度统计使用的
	createrID varchar(10) null,			--创建人工号
	createrName varchar(30) null,		--所有人
 CONSTRAINT [PK_resourceInfo] PRIMARY KEY CLUSTERED 
(
	[resourceType] ASC,
	[rFilename] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
--作者索引：
CREATE NONCLUSTERED INDEX [IX_resourceInfo] ON [dbo].[resourceInfo]
(
	[createrID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--显示排序索引：
CREATE NONCLUSTERED INDEX [IX_resourceInfo_01] ON [dbo].[resourceInfo]
(
	[orderNum] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--主题分类索引：
CREATE NONCLUSTERED INDEX [IX_resourceInfo_0] ON [dbo].[resourceInfo]
(
	[resourceTheme] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--是否发布索引：
CREATE NONCLUSTERED INDEX [IX_resourceInfo_1] ON [dbo].[resourceInfo]
(
	[isPublish] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--使用频率索引：
CREATE NONCLUSTERED INDEX [IX_resourceInfo_2] ON [dbo].[resourceInfo]
(
	[usedTimes] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--资料名称索引：
CREATE NONCLUSTERED INDEX [IX_resourceInfo_4] ON [dbo].[resourceInfo]
(
	[resourceName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--资料类别名称索引：
CREATE NONCLUSTERED INDEX [IX_resourceInfo_5] ON [dbo].[resourceInfo]
(
	[resourceType] ASC,
	[resourceName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--2.资料回收站：用户删除的资料并不真实删除，而是放在一个RecycleBin的目录，同样按类别存放
drop TABLE resourceRecycle
CREATE TABLE resourceRecycle(
	resourceTheme nvarchar(30) not null,--主题
	resourceName nvarchar(30) not null,	--资料名称
	resourceType varchar(30) not null,	--资料类型：picture（图片）、media（影音文件）、doc（文档）、template（模板）
	rFilename varchar(128) not NULL,	--资料文件唯一文件名
	notes nvarchar(100) null,			--说明
	uploadDate smalldatetime default(getdate()), --上传日期
	usedTimes bigint default(0),			--使用次数：这是做热度统计使用的
	delDate smalldatetime default(getdate()),--删除日期
	createrID varchar(10) null,			--所有人
	createrName varchar(30) null,		--所有人姓名
 CONSTRAINT [PK_resourceRecycle] PRIMARY KEY CLUSTERED 
(
	[resourceType] ASC,
	[rFilename] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_resourceRecycle] ON [dbo].[resourceRecycle]
(
	[createrID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--删除日期索引：
CREATE NONCLUSTERED INDEX [IX_resourceRecycle_1] ON [dbo].[resourceRecycle]
(
	[delDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--使用频率索引：
CREATE NONCLUSTERED INDEX [IX_resourceRecycle_2] ON [dbo].[resourceRecycle]
(
	[usedTimes] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--资料名称索引：
CREATE NONCLUSTERED INDEX [IX_resourceRecycle_3] ON [dbo].[resourceRecycle]
(
	[resourceName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--资料类别名称索引：
CREATE NONCLUSTERED INDEX [IX_resourceRecycle_4] ON [dbo].[resourceRecycle]
(
	[resourceType] ASC,
	[resourceName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE addResource
/*
	name:		1.addResource
	function:	添加资料
				@resourceTheme nvarchar(30),--主题
				@resourceName nvarchar(30),	--资料名称
				@resourceType varchar(30),	--资料类型：picture（图片）、media（影音文件）、doc（文档）、template（模板）
				@rFilename varchar(128),	--资料文件唯一文件名
				@notes nvarchar(100),		--说明
				@createrID varchar(10),		--创建人
	output: 
				@Ret		int output		--操作成功标识
										0:成功，1：资料文件名不唯一，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-26
	UpdateDate: 
*/
create PROCEDURE addResource
	@resourceTheme nvarchar(30),--主题
	@resourceName nvarchar(30),	--资料名称
	@resourceType varchar(30),	--资料类型：picture（图片）、media（影音文件）、doc（文档）、template（模板）
	@rFilename varchar(128),	--资料文件唯一文件名
	@notes nvarchar(100),		--说明
	@createrID varchar(10),		--创建人
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断资料文件名是否唯一
	declare @count as int
	set @count=(select count(*) from resourceInfo where resourceType = @resourceType and resourceName = @resourceName)	
	if (@count > 0)	--名称冲突
	begin
		set @Ret = 1
		return
	end

	
	--取创建人的姓名：
	declare @createrName nvarchar(30)
	set @createrName = isnull((select userCName from activeUsers where userID = @createrID),'')

	declare @updateTime smalldatetime
	set @updateTime = getdate()
	insert resourceInfo(resourceTheme, resourceName, resourceType, rFilename, notes, createrID, createrName,uploadDate)
	values(@resourceTheme, @resourceName, @resourceType, @rFilename, @notes, @createrID, @createrName, @updateTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--登记工作日志：
	declare @attachmentName varchar(100)
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createrID, @createrName, @updateTime, '添加资料', '用户' + @createrName
												+ '添加了一个类别为['+@resourceType+']名称为['+ @resourceName +']的资料。')
GO

drop PROCEDURE delResource
/*
	name:		delResource
	function:	2.删除指定的文件名的资料
				注意：系统并没有真实删除，而是将资料移入回收站
	input: 
				@rFilename varchar(128),	--资料文件唯一文件名

				@delManID varchar(10) output,--删除人
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的资料不存在，2：与回收站内文件名冲突，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-26
	UpdateDate: 

*/
create PROCEDURE delResource
	@rFilename varchar(128),	--资料文件唯一文件名

	@delManID varchar(10) output,--删除人
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--判断指定的资料是否存在
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--判断是否与回收站内文件名冲突
	set @count=(select count(*) from resourceRecycle where rFilename = @rFilename)	
	if (@count > 0)	--冲突
	begin
		set @Ret = 2
		return
	end

	declare @delDate smalldatetime
	set @delDate = GETDATE()
	insert resourceRecycle(resourceTheme,resourceName, resourceType, rFilename, notes, createrID, createrName, uploadDate, usedTimes, delDate)
	select resourceTheme,resourceName, resourceType, rFilename, notes, createrID, createrName, uploadDate, usedTimes, @delDate
	from resourceInfo
	where rFilename = @rFilename
	
	delete resourceInfo where rFilename = @rFilename
	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')
	--取资料名称\类别：
	declare @resourceName nvarchar(30),@resourceType varchar(30)
	select @resourceName = resourceName, @resourceType =resourceType  
	from resourceInfo
	where rFilename = @rFilename

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @delDate, '删除资料', '用户' + @delManName
												+ '删除了类别为['+ @resourceType +']的资料['+@resourceName+']。')
GO


drop PROCEDURE publishResource
/*
	name:		3.publishResource
	function:	发布资料
	input: 
				@rFilename varchar(128),	--资料文件唯一文件名

				@publishManID varchar(10) output,--发布人
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的资料不存在，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-26
	UpdateDate: 
*/
create PROCEDURE publishResource
	@rFilename varchar(128),	--资料文件唯一文件名

	@publishManID varchar(10) output,--发布人
	@Ret int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--判断指定的资料是否存在
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @curMaxOrderNum int
	set @curMaxOrderNum = isnull((select max(orderNum) from resourceInfo where isPublish='Y'),0) + 1
	update resourceInfo
	set isPublish = 'Y', orderNum=@curMaxOrderNum
	where rFilename = @rFilename
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end   

	set @Ret = 0

	--取发布人姓名：
	declare @shareName varchar(30)
	set @shareName = isnull((select userCName from activeUsers where userID = @publishManID),'')
	--取资料名称\类别：
	declare @resourceName nvarchar(30),@resourceType varchar(30)
	select @resourceName = resourceName, @resourceType =resourceType  
	from resourceInfo
	where rFilename = @rFilename

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@publishManID, @shareName, GETDATE(), '发布资料', '用户' + @shareName
												+ '发布了类别为['+ @resourceType +']的资料['+@resourceName+']。')
GO

drop PROCEDURE closeResource
/*
	name:		4.closeResource
	function:	撤销发布资料
	input: 
				@rFilename varchar(128),	--资料文件唯一文件名

				@closeManID varchar(10) output,--撤销人
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的资料不存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-1-19
	UpdateDate: 
*/
create PROCEDURE closeResource
	@rFilename varchar(128),	--资料文件唯一文件名

	@closeManID varchar(10) output,--撤销人
	@Ret int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--判断指定的资料是否存在
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	update resourceInfo
	set isPublish = 'N'
	where rFilename = @rFilename
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end   

	set @Ret = 0

	--取发布人姓名：
	declare @shareName varchar(30)
	set @shareName = isnull((select userCName from activeUsers where userID = @closeManID),'')
	--取资料名称\类别：
	declare @resourceName nvarchar(30),@resourceType varchar(30)
	select @resourceName = resourceName, @resourceType =resourceType  
	from resourceInfo
	where rFilename = @rFilename

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@closeManID, @shareName, GETDATE(), '撤销资料发布', '用户' + @shareName
												+ '撤销了类别为['+ @resourceType +']的资料['+@resourceName+']的发布。')
GO

drop PROCEDURE addUsedTimes
/*
	name:		4.addUsedTimes
	function:	增加资料使用次数
	input: 
				@rFilename varchar(128),	--资料文件唯一文件名

				@useManID varchar(10) output,--使用人
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的资料不存在，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-26
	UpdateDate: 
*/
create PROCEDURE addUsedTimes
	@rFilename varchar(128),	--资料文件唯一文件名

	@useManID varchar(10) output,--使用人
	@Ret int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--判断指定的资料是否存在
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	update resourceInfo
	set usedTimes = usedTimes+1
	where rFilename = @rFilename
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end   

	set @Ret = 0
/*
	--取使用人姓名：
	declare @useManName varchar(30)
	set @useManName = isnull((select userCName from activeUsers where userID = @useManID),'')
	--取资料名称\类别：
	declare @resourceName nvarchar(30),@resourceType varchar(30)
	select @resourceName = resourceName, @resourceType =resourceType  
	from resourceInfo
	where rFilename = @rFilename

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@useManID, @useManName, GETDATE(), '发布资料', '用户' + @useManName
												+ '使用了类别为['+ @resourceType +']的资料['+@resourceName+']。')
*/
GO

DROP PROCEDURE setResourceToTop
/*
	name:		setResourceToTop
	function:	10.将指定的已发布的资料置顶
	input: 
				@rFilename varchar(128),	--资料文件唯一文件名

				--维护情况:
				@modiManID varchar(10),		--维护人
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要置顶的资料不存在，3.该资料未发布，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-07-08
	UpdateDate: 
*/
create PROCEDURE setResourceToTop
	@rFilename varchar(128),	--资料文件唯一文件名

	--维护情况:
	@modiManID varchar(10),		--维护人
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的资料是否存在
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查资料状态:
	declare @resourceName nvarchar(30)	--资料名称
	declare @isPublish char(1)	--是否发布
	select @isPublish = isPublish, @resourceName=resourceName from resourceInfo where rFilename = @rFilename
	if (@isPublish <> 'Y')
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--将已发布的资料重新排序：
	declare @tab table
					(
						rFilename varchar(128) not null,		--资料文件唯一文件名
						orderNum smallint default(-1)			--显示排序号
					)
	insert @tab
	select rFilename, orderNum from resourceInfo 
	where isPublish ='Y' and rFilename <> @rFilename
	order by orderNum
	begin tran
		declare @rf varchar(128), @i int
		set @i = 2
		declare tar cursor for
		select rFilename from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @rf
		WHILE @@FETCH_STATUS = 0
		begin
			update resourceInfo
			set orderNum = @i
			where rFilename = @rf
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			set @i = @i + 1
			FETCH NEXT FROM tar INTO @rf
		end
		CLOSE tar
		DEALLOCATE tar
		--将指定的资料置顶：	
		update resourceInfo
		set orderNum = 1
		where rFilename = @rFilename
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
	values(@modiManID, @modiManName, getdate(), '资料置顶', '用户' + @modiManName 
												+ '将资料['+ @resourceName +']置顶。')
GO
--测试：
select * from resourceInfo 
where isPublish ='Y'
order by orderNum

declare @Ret int 
exec dbo.setResourceToTop '/hustoa/upload/resouce/201304/0514211b-76c9-42ac-a1f0-d17fd84f95c2.jpg', '00200977', @Ret output

DROP PROCEDURE setResourceToLast
/*
	name:		setResourceToLast
	function:	11.将指定的已发布的资料上移一行
	input: 
				@rFilename varchar(128),	--资料文件唯一文件名

				--维护情况:
				@modiManID varchar(10),		--维护人
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要移动的资料不存在，3.该资料未发布，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-07-08
	UpdateDate: 
*/
create PROCEDURE setResourceToLast
	@rFilename varchar(128),	--资料文件唯一文件名

	--维护情况:
	@modiManID varchar(10),		--维护人
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的资料是否存在
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查资料状态:
	declare @resourceName nvarchar(30)	--资料名称
	declare @isPublish char(1)			--是否发布
	declare @myOrderNum smallint		--本资料的排序号
	select @isPublish = isPublish, @resourceName=resourceName, @myOrderNum=orderNum from resourceInfo where rFilename = @rFilename
	if (@isPublish <> 'Y')
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--将已发布的位置在本资料前面的资料重新排序：
	declare @tab table
					(
						rFilename varchar(128) not null,		--资料文件唯一文件名
						orderNum smallint default(-1)			--显示排序号
					)
	insert @tab
	select rFilename, orderNum from resourceInfo 
	where isPublish ='Y' and orderNum < @myOrderNum
	order by orderNum
	begin tran
		declare @rf varchar(128), @i int
		set @i = 1
		declare tar cursor for
		select rFilename from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @rf
		WHILE @@FETCH_STATUS = 0
		begin
			update resourceInfo
			set orderNum = @i
			where rFilename = @rf
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			set @i = @i + 1
			FETCH NEXT FROM tar INTO @rf
		end
		CLOSE tar
		DEALLOCATE tar
		--将指定的资料上移一行：	
		update resourceInfo
		set orderNum = @i
		where rFilename = @rf
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		update resourceInfo
		set orderNum = @i - 1
		where rFilename = @rFilename
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
	values(@modiManID, @modiManName, getdate(), '资料上移一行', '用户' + @modiManName 
												+ '将资料['+ @resourceName +']上移了一行。')
GO
--测试：
select * from resourceInfo 
where isPublish ='Y'
order by orderNum

declare @Ret int 
exec dbo.setResourceToLast '/hustoa/upload/resouce/201306/3948954f-cd5c-49ce-a1e5-9819e3e1ec7b.jpg', '00200977', @Ret output

DROP PROCEDURE setResourceToNext
/*
	name:		setResourceToNext
	function:	12.将指定的已发布的资料下移一行
	input: 
				@rFilename varchar(128),	--资料文件唯一文件名

				--维护情况:
				@modiManID varchar(10),		--维护人
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要移动的资料不存在，3.该资料未发布，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-07-08
	UpdateDate: 
*/
create PROCEDURE setResourceToNext
	@rFilename varchar(128),	--资料文件唯一文件名

	--维护情况:
	@modiManID varchar(10),		--维护人
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的资料是否存在
	declare @count as int
	set @count=(select count(*) from resourceInfo where rFilename = @rFilename)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查资料状态:
	declare @resourceName nvarchar(30)	--资料名称
	declare @isPublish char(1)			--是否发布
	declare @myOrderNum smallint		--本资料的排序号
	select @isPublish = isPublish, @resourceName=resourceName, @myOrderNum=orderNum from resourceInfo where rFilename = @rFilename
	if (@isPublish <> 'Y')
	begin
		set @Ret = 3
		return
	end


	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--将本资料与下一个资料交换位置：
	declare @nextRFilename varchar(128), @nextOrderNum smallint
	select top 1 @nextRFilename = rFilename, @nextOrderNum = orderNum 
	from resourceInfo 
	where isPublish ='Y' and orderNum > @myOrderNum
	order by orderNum
	
	if (@nextRFilename is not null)
	begin
		begin tran
			update resourceInfo
			set orderNum = @nextOrderNum
			where rFilename = @rFilename
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			update resourceInfo
			set orderNum = @myOrderNum
			where rFilename = @nextRFilename
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
	values(@modiManID, @modiManName, getdate(), '资料下移一行', '用户' + @modiManName 
												+ '将资料['+ @resourceName +']下移了一行。')
GO
--测试：
select * from resourceInfo 
where isPublish ='Y'
order by orderNum

declare @Ret int 
exec dbo.setResourceToNext '/hustoa/upload/resouce/201306/3948954f-cd5c-49ce-a1e5-9819e3e1ec7b.jpg', '00200977', @Ret output


--查询语句：
select resourceTheme, resourceName, resourceType, rFilename, notes, createrID, createrName, convert(varchar(10),uploadDate,120) uploadDate, 
isPublish, usedTimes, 
case  when datediff(day,uploadDate,getdate())<8 then datediff(day,uploadDate,getdate()) else 8 end recently
from resourceInfo
order by uploadDate desc    --默认排序：是否共享、最近上传、使用频率
