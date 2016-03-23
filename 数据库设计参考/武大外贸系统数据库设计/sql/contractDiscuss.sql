use fTradeDB2
/*
	武大外贸合同管理信息系统-合同讨论管理
	根据设备管理系统公告改编
	author:		卢苇
	CreateDate:	2012-4-26
	UpdateDate: 
*/
--1.合同讨论意见一览表（discussInfo）：
select contractID, discussID, discussTitle, discussHTML, discussTime, authorID, authorName 
from discussInfo
order by discussID desc

drop TABLE discussInfo
CREATE TABLE discussInfo
(
	contractID varchar(12) not null,	--外键：档案号（合同编号）
	discussID varchar(12) not null,		--主键：讨论意见编号，使用第 2 号号码发生器产生
	discussTitle nvarchar(100) null,	--标题：暂时未使用
	discussHTML nvarchar(4000) null,	--内容

	discussTime datetime default(getdate()),--发表时间
	authorID varchar(10) null,			--发表人ID
	authorName varchar(30) null,		--发表人姓名:冗余设计
CONSTRAINT [PK_discussInfo] PRIMARY KEY CLUSTERED 
(
	[discussID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[discussInfo] WITH CHECK ADD CONSTRAINT [FK_discussInfo_contractInfo] FOREIGN KEY([contractID])
REFERENCES [dbo].[contractInfo] ([contractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[discussInfo] CHECK CONSTRAINT [FK_discussInfo_contractInfo] 
GO

CREATE NONCLUSTERED INDEX [IX_discussInfo] ON [dbo].[discussInfo] 
(
	[discussTime] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

--2.讨论意见阅读记录
drop TABLE discussReadInfo
CREATE TABLE discussReadInfo
(
	contractID varchar(12) not null,	--外键：档案号（合同编号）
	readerID varchar(10) not null,		--阅读人ID
	readerTime datetime null,			--阅读时间
CONSTRAINT [PK_discussReadInfo] PRIMARY KEY CLUSTERED 
(
	[contractID] ASC,
	[readerID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[discussReadInfo] WITH CHECK ADD CONSTRAINT [FK_discussReadInfo_contractInfo] FOREIGN KEY([contractID])
REFERENCES [dbo].[contractInfo] ([contractID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[discussReadInfo] CHECK CONSTRAINT [FK_discussReadInfo_contractInfo]
GO

select * from discussReadInfo


drop PROCEDURE addDiscussInfo
/*
	name:		addDiscussInfo
	function:	1.添加指定合同的讨论意见
				注意：该存储过程不锁定单据
	input: 
				@contractID varchar(12),	--外键：档案号（合同编号）
				@discussTitle nvarchar(100),--标题：暂时未使用
				@discussHTML nvarchar(4000),--内容
				@authorID varchar(10),		--发表人ID
	output: 
				@Ret		int output		--操作成功标识
											0:成功，9:未知错误
				@discussID varchar(12) output--讨论意见编号，使用第 2 号号码发生器产生
	author:		卢苇
	CreateDate:	2012-4-26
	UpdateDate: 

*/
create PROCEDURE addDiscussInfo
	@contractID varchar(12),	--外键：档案号（合同编号）
	@discussTitle nvarchar(100),--标题：暂时未使用
	@discussHTML nvarchar(4000),--内容

	@authorID varchar(10),		--发表人ID

	@Ret int output,			--操作成功标识
	@discussID varchar(12) output--讨论意见编号，使用第 2 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 2, 1, @curNumber output
	set @discussID = @curNumber

	--取发表人的姓名：
	declare @authorName varchar(30)
	set @authorName = isnull((select cName from sysUserInfo where userID = @authorID),'')

	declare @createTime smalldatetime --发表时间
	set @createTime = getdate()
	insert discussInfo(contractID, discussID, discussTitle, discussHTML, discussTime, authorID, authorName)
	values (@contractID, @discussID, @discussTitle, @discussHTML, @createTime, @authorID, @authorName)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	--将本人设置为已经阅读：
	exec dbo.discussInfoReaded @contractID, @authorID,@Ret output
	
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@authorID, @authorName, @createTime, '讨论合同', '用户[' + @authorName + 
					']对合同['+@contractID+']发表了编号为['+@discussID+']的意见。')
GO

select * from discussReadInfo

drop PROCEDURE delDiscussInfo
/*
	name:		delDiscussInfo
	function:	2.删除指定的讨论意见
	input: 
				@discussID varchar(12),			--讨论意见编号
				@delManID varchar(10),			--删除人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：该意见不存在，9：未知错误
	author:		卢苇
	CreateDate:	2012-4-26
	UpdateDate:
*/
create PROCEDURE delDiscussInfo
	@discussID varchar(12),			--讨论意见编号
	@delManID varchar(10),			--删除人
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的意见是否存在
	declare @count as int
	set @count=(select count(*) from discussInfo where discussID = @discussID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	delete discussInfo where discussID = @discussID
	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除公告', '用户' + @delManName
												+ '删除了讨论意见['+ @discussID +']。')

GO
--测试：


drop PROCEDURE discussInfoReaded
/*
	name:		discussInfoReaded
	function:	3.登记指定合同讨论意见已经阅读
				注意：本存储过程不登记工作日志
	input: 
				@contractID varchar(12),	--档案号（合同编号）
				@readerID varchar(10),		--阅读人
	output: 
				@Ret		int output			--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2012-5-9
	UpdateDate:
*/
create PROCEDURE discussInfoReaded
	@contractID varchar(12),	--档案号（合同编号）
	@readerID varchar(10),		--阅读人
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断阅读人是否存在
	declare @count as int
	set @count=(select count(*) from discussReadInfo where contractID = @contractID and readerID = @readerID)	
	if (@count = 0)	--不存在
		insert discussReadInfo(contractID,readerID,readerTime)
		values(@contractID,@readerID,GETDATE())
	else
		update discussReadInfo
		set readerTime = GETDATE()
		where contractID = @contractID and readerID = @readerID

	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0
GO

drop TABLE discussReadInfo
CREATE TABLE discussReadInfo
(
	contractID varchar(12) not null,	--外键：档案号（合同编号）
	readerID varchar(10) not null,		--阅读人ID
	readerTime smalldatetime null,		--阅读时间
CONSTRAINT [PK_discussReadInfo] PRIMARY KEY CLUSTERED 
(
	[contractID] ASC,
	[readerID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

