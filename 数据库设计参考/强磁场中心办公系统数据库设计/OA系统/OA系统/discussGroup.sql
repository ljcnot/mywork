use hustOA
/*
	OA管理信息系统-讨论组管理
	注意：讨论组与群组的区别
	讨论组：各组员权利平等，任何一个组员都可以邀请别人参加讨论组，不需要同意即可加入讨论组，系统不支持列出全部讨论组的功能，
	不支持踢出别人的权利，只支持自行退出，全部组员退出后系统自动解散讨论组。
	群组：有一个特权管理用户————群主，系统支持列出全部群组的功能，任何人都可以申请加入特定的群组，只要群主同意就可以了，
	群主可以邀请一个人参加群，只要被邀请人同意即可，
	群主可以踢出一个组员，可以解散一个群组。将来群组计划扩展到一些共享资源————如相册等。
	讨论组和群的操作只有更新过程需要上锁！
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/

--1.讨论组一览表：
drop TABLE discussGroup
CREATE TABLE discussGroup(
	discussID char(12) not null,		--主键：讨论组ID,由第20000号号码发生器产生
										--8位日期代码+4位流水号

	discussName nvarchar(30) not null,	--讨论组名称,
	notes nvarchar(300) null,			--讨论组描述

	--注意：关闭了的讨论组将不参与名称查重，现系统不提供重新启用功能，
	--如果将来提供该功能则启用的时候要检查名称是否重复！
	isOff char(1) default('0') null,	--是否关闭:“0”代表在用，“1”代表关闭
	offDate smalldatetime null,			--关闭日期

	--创建人：add by lw 2012-8-9为了保持操作的范围——个人的一致性增加的字段
	createManID varchar(10) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_discussGroup] PRIMARY KEY CLUSTERED 
(
	[discussID] DESC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--索引：
--讨论组名称索引：
CREATE NONCLUSTERED INDEX [IX_discussGroup] ON [dbo].[discussGroup] 
(
	[discussName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.讨论组人员名单：
drop table discussGroupMember
CREATE TABLE discussGroupMember(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	discussID char(12) not null,		--外键：讨论组ID
	discussName nvarchar(30) not null,	--冗余设计：讨论组名称,
	userID varchar(10) not null,		--组员工号
	userName nvarchar(30) not null,		--冗余设计：组员姓名
	
	--再次进入的是否应该检查是否是再次进入：
	isOff char(1) default('0') null,	--是否退出:“0”代表未退出，“1”代表退出
	offDate smalldatetime null,			--退出日期
	
	createTime smalldatetime null,		--创建时间
CONSTRAINT [PK_discussGroupMember] PRIMARY KEY CLUSTERED 
(
	[discussID]ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[discussGroupMember] WITH CHECK ADD CONSTRAINT [FK_discussGroupMember_discussGroup] FOREIGN KEY([discussID])
REFERENCES [dbo].[discussGroup] ([discussID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[discussGroupMember] CHECK CONSTRAINT [FK_discussGroupMember_discussGroup]
GO

--索引：
--组员工号索引：
CREATE NONCLUSTERED INDEX [IX_discussGroupMember] ON [dbo].[discussGroupMember] 
(
	[userID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



drop PROCEDURE checkDiscussGroupName
/*
	name:		checkDiscussGroupName
	function:	0.1.检查指定的讨论组是否已经存在
	input: 
				@discussName nvarchar(30),	--讨论组名称
				@discussID varchar(12),		--讨论组ID:当新建检查时将该字段设置为""
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE checkDiscussGroupName
	@discussName nvarchar(30),	--讨论组名称
	@discussID varchar(12),		--讨论组ID:当新建检查时将该字段设置为""
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查讨论组名称是否存在：
	declare @count int
	set @count = (select count(*) from discussGroup where discussName = @discussName and isOff='0' and discussID<>@discussID)
	set @Ret = @count
GO

drop PROCEDURE createDiscussGroup
/*
	name:		createDiscussGroup
	function:	1.创建讨论组
				注意：本存储过程不锁定编辑！
	input: 
				@discussName nvarchar(30),	--讨论组名称,
				@notes nvarchar(300),		--讨论组描述
				@members xml,				--使用xml存储的组员名单：N'<root>
																	--	<row id="1">
																	--		<userID>00000008</userID>
																	--		<userName>余  玮</userName>
																	--	</row>
																	--	<row id="2">
																	--		<userID>00000009</userID>
																	--		<userName>卢苇</userName>
																	--	</row>
																	--	...
																	--</root>'

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：讨论组名称已经被占用，9：未知错误
				@createTime smalldatetime output,
				@discussID varchar(12) output--主键：讨论组ID,由第20000号号码发生器产生
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE createDiscussGroup
	@discussName nvarchar(30),	--讨论组名称,
	@notes nvarchar(300),		--讨论组描述
	@members xml,				--使用xml存储的组员名单：N'<root>
														--	<row id="1">
														--		<userID>00000008</userID>
														--		<userName>余  玮</userName>
														--	</row>
														--	<row id="2">
														--		<userID>00000009</userID>
														--		<userName>卢苇</userName>
														--	</row>
														--	...
														--</root>'

	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@createTime smalldatetime output,
	@discussID varchar(12) output--主键：讨论组ID,由第20000号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--检查名称是否唯一：
	declare @count int
	set @count = ISNULL((select count(*) from discussGroup where discussName = @discussName and isOff='0'),0)
	if (@count>0)
	begin
		set @Ret =1
		return
	end
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 20000, 1, @curNumber output
	set @discussID = @curNumber

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	begin tran
		insert discussGroup(discussID, discussName, notes, 
							createManID, createManName, createTime,
							modiManID, modiManName, modiTime,lockManID)
		values (@discussID, @discussName, @notes, 
				@createManID, @createManName, @createTime,
				@createManID, @createManName, @createTime,'') 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--插入创建人到组员表：
		insert discussGroupMember(discussID, discussName, userID, userName, createTime)
		values(@discussID, @discussName, @createManID, @createManName, @createTime)
		--插入组员表：
		insert discussGroupMember(discussID, discussName, userID, userName, createTime)
		select @discussID, @discussName, 
				cast(T.x.query('data(./userID)') as varchar(10)) userID,
				cast(T.x.query('data(./userName)') as nvarchar(30)) userName,
				@createTime
		from(select @members.query('/root/row') Col1) A
			OUTER APPLY A.Col1.nodes('/row') AS T(x)
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
	values(@createManID, @createManName, @createTime, '添加讨论组', '系统根据用户' + @createManName + 
					'的要求添加了讨论组[' + @discussName + '('+@discussID+')]。')
GO
--测试：
declare	@Ret		int
declare	@createTime smalldatetime 
declare	@discussID varchar(12)
exec dbo.createDiscussGroup '测试讨论组', '这是一个测试用讨论组',
		N'<root>
			<row id="1">
				<userID>00000008</userID>
				<userName>余  玮</userName>
			</row>
			<row id="2">
				<userID>00000009</userID>
				<userName>卢苇</userName>
			</row>
		</root>',
	'00000009',@Ret	output,@createTime output,@discussID output
select @Ret, @discussID, @Ret
select * from discussGroup
select * from discussGroupMember

drop PROCEDURE queryDiscussGroupLocMan
/*
	name:		queryDiscussGroupLocMan
	function:	2.查询指定讨论组是否有人正在编辑
	input: 
				@discussID varchar(12),		--讨论组ID
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的讨论组不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE queryDiscussGroupLocMan
	@discussID varchar(12),		--讨论组ID
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from discussGroup where discussID = @discussID),'')
	set @Ret = 0
GO


drop PROCEDURE lockDiscussGroup4Edit
/*
	name:		lockDiscussGroup4Edit
	function:	3.锁定讨论组编辑，避免编辑冲突
	input: 
				@discussID varchar(12),			--讨论组ID
				@lockManID varchar(10) output,	--锁定人，如果当前讨论组正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的讨论组不存在，2:要锁定的讨论组正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE lockDiscussGroup4Edit
	@discussID varchar(12),			--讨论组ID
	@lockManID varchar(10) output,	--锁定人，如果当前讨论组正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的讨论组是否存在
	declare @count as int
	set @count=(select count(*) from discussGroup where discussID = @discussID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussGroup where discussID = @discussID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update discussGroup
	set lockManID = @lockManID 
	where discussID = @discussID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定讨论组编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了讨论组['+ @discussID +']为独占式编辑。')
GO

drop PROCEDURE unlockDiscussGroupEditor
/*
	name:		unlockDiscussGroupEditor
	function:	4.释放讨论组编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@discussID varchar(12),			--讨论组ID
				@lockManID varchar(10) output,	--锁定人，如果当前讨论组正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE unlockDiscussGroupEditor
	@discussID varchar(12),			--讨论组ID
	@lockManID varchar(10) output,	--锁定人，如果当前讨论组正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussGroup where discussID = @discussID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update discussGroup set lockManID = '' where discussID = @discussID
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
	values(@lockManID, @lockManName, getdate(), '释放讨论组编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了讨论组['+ @discussID +']的编辑锁。')
GO

drop PROCEDURE addDiscussGroupMember
/*
	name:		addDiscussGroupMember
	function:	5.添加组员（添加一个组员）
	input: 
				@discussID varchar(12),		--讨论组ID
				@userID varchar(10),		--要添加的组员工号
				@addManID varchar(10),		--添加人
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的讨论组不存在，2.该用户已经是该讨论组的成员，9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE addDiscussGroupMember
	@discussID varchar(12),		--讨论组ID
	@userID varchar(10),		--要添加的组员工号
	@addManID varchar(10),		--添加人
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的讨论组是否存在
	declare @count as int
	set @count=(select count(*) from discussGroup where discussID = @discussID and isOff='0')	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	--判断该用户是否是该组的成员
	declare @status char(1)
	set @status = '0'
	set @count=(select count(*) from discussGroupMember where discussID = @discussID and userID=@userID)	
	if (@count > 0)	--存在
	begin
		select  @status = isOff
		from discussGroupMember 
		where discussID = @discussID and userID=@userID
		--检查状态：
		if (@status = '0')
		begin
			set @Ret = 2
			return
		end
	end

	--取讨论组名称：
	declare @discussName nvarchar(30)
	set @discussName = ISNULL((select discussName from discussGroup where discussID = @discussID),'')
	
	--取组员的姓名：
	declare @userName nvarchar(30)
	set @userName = isnull((select cName from userInfo where jobNumber = @userID),'')
	--取添加人的姓名：
	declare @addManName nvarchar(30)
	set @addManName = isnull((select userCName from activeUsers where userID = @addManID),'')

	declare @createTime smalldatetime
	set @createTime = getdate()
	if (@status = '0')
		insert discussGroupMember(discussID, discussName, userID, userName, createTime)
		values(@discussID, @discussName, @userID, @userName,@createTime)
	else
		update discussGroupMember
		set isOff = '0', offDate = null, discussName = @discussName, userName = @userName
		where discussID = @discussID and userID=@userID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@addManID, @addManName, @createTime, '加入讨论组', '用户' + @addManName
												+ '将用户['+@userName+']加入了讨论组['+ @discussName + '('+@discussID +')]。')
GO
--测试：
declare @Ret int
exec dbo.addDiscussGroupMember '201304130003', 'G201300001', @Ret output
select @Ret
select * from discussGroupMember

select * from userInfo

drop PROCEDURE offDiscussGroupMember
/*
	name:		offDiscussGroupMember
	function:	6.组员退出
				注意：本过程当全部组员都退出的时候自动关闭讨论组
	input: 
				@discussID varchar(12),		--讨论组ID
				@userID varchar(10),		--要退出的组员工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的讨论组不存在，2.该用户不是该讨论组的成员，9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE offDiscussGroupMember
	@discussID varchar(12),		--讨论组ID
	@userID varchar(10),		--要退出的组员工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要退出的讨论组是否存在
	declare @count as int
	set @count=(select count(*) from discussGroup where discussID = @discussID and isOff='0')	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--判断该用户是否是该组的成员
	declare @status char(1)
	set @status = '0'
	set @count=(select count(*) from discussGroupMember where discussID = @discussID and userID=@userID and isOff='0')	
	if (@count = 0)	--不存在
	begin
		set @Ret = 2
		return
	end

	--取讨论组名称：
	declare @discussName nvarchar(30)
	set @discussName = ISNULL((select discussName from discussGroup where discussID = @discussID),'')
	
	--取组员的姓名：
	declare @userName nvarchar(30)
	set @userName = isnull((select userCName from activeUsers where userID = @userID),'')

	declare @exitTime smalldatetime
	set @exitTime = getdate()
	begin tran
		update discussGroupMember
		set isOff = '1', offDate = @exitTime
		where discussID = @discussID and userID=@userID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	
		--检查是否是所有成员都退出，如果是则自动关闭讨论组：
		set @count=(select count(*) from discussGroupMember where discussID = @discussID and isOff='0')	
		if (@count = 0)
		begin
			update discussGroup
			set isOff='1', offDate=GETDATE()
			where discussID = @discussID
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
	values(@userID, @userName, @exitTime, '退出讨论组', '用户' + @userName
												+ '退出了讨论组['+ @discussName + '('+@discussID +')]。')
GO

drop PROCEDURE updateDiscussGroup
/*
	name:		updateDiscussGroup
	function:	7.更新讨论组
	input: 
				@discussID varchar(12),		--讨论组ID
				@discussName nvarchar(30),	--讨论组名称,
				@notes nvarchar(300),		--讨论组描述

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前讨论组正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的讨论组不存在，2：要更新的讨论组正被别人锁定，3:要更新的名称已经被占用，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE updateDiscussGroup
	@discussID varchar(12),		--讨论组ID
	@discussName nvarchar(30),	--讨论组名称,
	@notes nvarchar(300),		--讨论组描述

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前讨论组正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的讨论组是否存在
	declare @count as int
	set @count=(select count(*) from discussGroup where discussID = @discussID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussGroup where discussID = @discussID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查名称是否唯一：不检查关闭的讨论组
	set @count = ISNULL((select count(*) from discussGroup 
							where discussID<>@discussID and discussName = @discussName and isOff='0'),0)
	if (@count>0)
	begin
		set @Ret =1
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		--更新主表：
		update discussGroup
		set discussName= @discussName,
			notes = @notes,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where discussID = @discussID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--更新组员表：
		update discussGroupMember
		set discussName = @discussName
		where discussID = @discussID
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
	values(@modiManID, @modiManName, @updateTime, '更新讨论组', '用户' + @modiManName 
												+ '更新了讨论组['+ @discussID +']的名称和（或）描述。')
GO


drop PROCEDURE delDiscussGroup
/*
	name:		delDiscussGroup
	function:	8.删除指定的讨论组
				注意：为了保持历史记录，最好不要使用本功能，应该使用关闭功能！
	input: 
				@discussID varchar(12),			--讨论组ID
				@delManID varchar(10) output,	--删除人，如果当前讨论组正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的讨论组不存在，2：要删除的讨论组正被别人锁定，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 

*/
create PROCEDURE delDiscussGroup
	@discussID varchar(12),			--讨论组ID
	@delManID varchar(10) output,	--删除人，如果当前讨论组正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的讨论组是否存在
	declare @count as int
	set @count=(select count(*) from discussGroup where discussID = @discussID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussGroup where discussID = @discussID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete discussGroup where discussID = @discussID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	set @Ret = 0

	--取讨论组名称：
	declare @discussName nvarchar(30)
	set @discussName = ISNULL((select discussName from discussGroup where discussID = @discussID),'')
	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除讨论组', '用户' + @delManName
												+ '删除了讨论组['+ @discussName+ '(' + @discussID +')]。')

GO

drop PROCEDURE closeDiscussGroup
/*
	name:		closeDiscussGroup
	function:	9.关闭讨论组
	input: 
				@discussID varchar(12),			--讨论组ID
				@stopManID varchar(10) output,	--关闭人，如果当前讨论组正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的讨论组不存在，2：要关闭的讨论组正被别人锁定，3：该讨论组本就是关闭状态，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 

*/
create PROCEDURE closeDiscussGroup
	@discussID varchar(12),			--讨论组ID
	@stopManID varchar(10) output,	--关闭人，如果当前讨论组正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的讨论组是否存在
	declare @count as int
	set @count=(select count(*) from discussGroup where discussID = @discussID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10), @status char(1)
	select  @thisLockMan = isnull(lockManID,'') , @status = isOff
	from discussGroup
	where discussID = @discussID
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查状态：
	if (@status = '1')
	begin
		set @Ret = 3
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update discussGroup
	set isOff = '1', offDate = @stopTime
	where discussID = @discussID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--取讨论组名称：
	declare @discussName nvarchar(30)
	set @discussName = ISNULL((select discussName from discussGroup where discussID = @discussID),'')
	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '关闭讨论组', '用户' + @stopManName
												+ '关闭了讨论组[' + @discussName + '(' + @discussID + ')]。')
GO

--查询语句：
select d.discussID,d.discussName, d.notes,
d.isOff, case d.isOff when '0' then '' when '1' then convert(varchar(10),d.offDate,120) end offDate,
d.createManID,d.createManName
from discussGroup d

--明细表查询语句：
select m.discussID,m.discussName, m.userID,m.userName,
m.isOff, case m.isOff when '0' then '' when '1' then convert(varchar(10),m.offDate,120) end offDate,
convert(varchar(10),m.createTime,120) createTime
from discussGroupMember m


select discussID from discussGroupMember where isOff='0' and userID = '00000008'

select * from userInfo
delete  from userInfo where cName = 'abc' and jobNumber<='G201300226'
