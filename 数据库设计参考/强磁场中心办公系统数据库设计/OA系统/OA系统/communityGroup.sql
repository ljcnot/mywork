use hustOA
/*
	OA管理信息系统-群组管理
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

--1.群组一览表：
select * from communityGroup
drop TABLE communityGroup
CREATE TABLE communityGroup(
	groupID char(12) not null,			--主键：群组ID,由第20001号号码发生器产生
										--8位日期代码+4位流水号
	
	groupClass nvarchar(30) not null,	--群组类别
	groupName nvarchar(30) not null,	--群组名称
	notes nvarchar(300) null,			--群组描述
	
	managerID varchar(10) not null,		--群主工号
	manager nvarchar(30) not null,		--冗余设计：群主姓名

	--注意：关闭了的群组将不参与名称查重，现系统不提供重新启用功能，
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
 CONSTRAINT [PK_communityGroup] PRIMARY KEY CLUSTERED 
(
	[groupID] DESC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--索引：
--群组名称索引：
CREATE NONCLUSTERED INDEX [IX_communityGroup] ON [dbo].[communityGroup] 
(
	[groupName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.群组人员名单：
select * from communityGroupMember where groupID='201304180017'
drop table communityGroupMember
CREATE TABLE communityGroupMember(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	groupID char(12) not null,			--外键：群组ID
	groupName nvarchar(30) not null,	--冗余设计：群组名称,
	userType smallint default(0),		--用户类型：0->普通组员，99->群主
	userID varchar(10) not null,		--组员工号
	userName nvarchar(30) not null,		--冗余设计：组员姓名
	
	--再次进入的是否应该检查是否是再次进入：
	isOff char(1) default('0') null,	--是否退出:“0”代表未退出，“1”代表退出
	offDate smalldatetime null,			--退出日期
	
	createTime smalldatetime null,		--创建时间
CONSTRAINT [PK_communityGroupMember] PRIMARY KEY CLUSTERED 
(
	[groupID]ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[communityGroupMember] WITH CHECK ADD CONSTRAINT [FK_communityGroupMember_communityGroup] FOREIGN KEY([groupID])
REFERENCES [dbo].[communityGroup] ([groupID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[communityGroupMember] CHECK CONSTRAINT [FK_communityGroupMember_communityGroup]
GO

--索引：
--组员工号索引：
CREATE NONCLUSTERED INDEX [IX_communityGroupMember] ON [dbo].[communityGroupMember] 
(
	[userID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--3.邀请（或申请）参加人员表（不采用主从表设计，一人一单）：
select * from communityGroupApply where groupID='201304180017'
drop table communityGroupApply
CREATE TABLE communityGroupApply(
	applyID char(12) not null,			--主键：邀请（或申请）单号，由第20002号号码发生器产生
	applyType smallint default(0),		--单据类型：0->邀请单，1->申请单
	applyStatus smallint default(0),	--单据状态：0->等待同意，1->已同意，-1->不同意
	groupID char(12) not null,			--外键：群组ID
	groupName nvarchar(30) not null,	--冗余设计：群组名称,
	
	userID varchar(10) not null,		--邀请人员（或申请人员）工号
	userName nvarchar(30) not null,		--冗余设计：邀请人员（或申请人员）姓名
	applyMsg nvarchar(300) null,		--留言
	
CONSTRAINT [PK_communityGroupApply] PRIMARY KEY CLUSTERED 
(
	[applyID]ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[communityGroupApply] WITH CHECK ADD CONSTRAINT [FK_communityGroupApply_communityGroup] FOREIGN KEY([groupID])
REFERENCES [dbo].[communityGroup] ([groupID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[communityGroupApply] CHECK CONSTRAINT [FK_communityGroupApply_communityGroup]
GO

--索引：
--被邀请人（申请人）工号索引：
CREATE NONCLUSTERED INDEX [IX_communityGroupApply] ON [dbo].[communityGroupApply] 
(
	[userID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE checkCommunityGroupName
/*
	name:		checkCommunityGroupName
	function:	0.1.检查指定的群组是否已经存在
	input: 
				@groupName nvarchar(30),	--群组名称
				@groupID varchar(12),		--群组ID:当新建检查时将该字段设置为""
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE checkCommunityGroupName
	@groupName nvarchar(30),	--群组名称
	@groupID varchar(12),		--群组ID:当新建检查时将该字段设置为""
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查群组名称是否存在：
	declare @count int
	set @count = (select count(*) from communityGroup where groupName = @groupName and isOff='0' and groupID<>@groupID)
	set @Ret = @count
GO

drop PROCEDURE createCommunityGroup
/*
	name:		createCommunityGroup
	function:	1.创建群组
				注意：本存储过程不锁定编辑！创建人就是群主。
				本过程自动生成邀请函消息，并发送到消息队列。
	input: 
				@groupClass nvarchar(30),	--群组类别
				@groupName nvarchar(30),	--群组名称,
				@notes nvarchar(300),		--群组描述
				@applyMsg nvarchar(300),	--留言
				@members xml,				--使用xml存储的邀请参加人名单：N'<root>
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
							0:成功，1：群组名称已经被占用，9：未知错误
				@createTime smalldatetime output,
				@groupID varchar(12) output	--主键：群组ID,由第20001号号码发生器产生
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE createCommunityGroup
	@groupClass nvarchar(30),	--群组类别
	@groupName nvarchar(30),	--群组名称,
	@notes nvarchar(300),		--群组描述
	@applyMsg nvarchar(300),	--留言
	@members xml,				--使用xml存储的邀请参加人名单：N'<root>
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
	@groupID varchar(12) output	--主键：群组ID,由第20001号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--检查名称是否唯一：
	declare @count int
	set @count = ISNULL((select count(*) from communityGroup where groupName = @groupName and isOff='0'),0)
	if (@count>0)
	begin
		set @Ret =1
		return
	end
	--使用号码发生器产生群的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 20001, 1, @curNumber output
	set @groupID = @curNumber

	--取创建人（群主）姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--邀请函：
	declare @InviteForm nvarchar(4000)
	set @InviteForm = 
	N'<root>
		<groupID>'+@groupID+'</groupID>
		<groupName>'+@groupName+'</groupName>
		<cmdType>Invite</cmdType>
		<applyID>{#applyID}</applyID>
		<applyMsg>'+@applyMsg+'</applyMsg>
	</root>'
	set @createTime = getdate()
	begin tran
		insert communityGroup(groupID, groupClass, groupName, notes, managerID, manager,
							createManID, createManName, createTime,
							modiManID, modiManName, modiTime,lockManID)
		values (@groupID, @groupClass, @groupName, @notes, @createManID, @createManName, 
				@createManID, @createManName, @createTime,
				@createManID, @createManName, @createTime,'') 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--将群主作为默认的组员：
		insert communityGroupMember(groupID, groupName, userType, userID, userName, createTime)
		values(@groupID, @groupName, 99, @createManID, @createManName, @createTime)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--插入邀请人员表：
		declare @userID varchar(10), @userName nvarchar(30)		--被邀请人（申请人）工号、姓名
		declare tar cursor for
		select cast(T.x.query('data(./userID)') as varchar(10)) userID,
				cast(T.x.query('data(./userName)') as nvarchar(30)) userName
		from(select @members.query('/root/row') Col1) A
			OUTER APPLY A.Col1.nodes('/row') AS T(x)
		OPEN tar
		FETCH NEXT FROM tar INTO @userID, @userName
		WHILE @@FETCH_STATUS = 0
		begin
			--使用号码发生器产生单据的号码：
			declare @applyID varchar(12)
			exec dbo.getClassNumber 20002, 1, @curNumber output
			set @applyID = @curNumber

			insert communityGroupApply(applyID, groupID, groupName, userID, userName, applyMsg)
			values(@applyID, @groupID, @groupName, @userID,@userName, @applyMsg)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				CLOSE tar
				DEALLOCATE tar
				return
			end
			--生成消息：
			declare @execRet int, @messageID varchar(12)
			declare @rInviteForm nvarchar(4000)
			set @rInviteForm = replace(@InviteForm,'{#applyID}',@applyID)
			exec dbo.addMessageInfo 9,'群邀请函', 9, @createManID, 1, @userID, @rInviteForm,
				@execRet output, @messageID output
			
			FETCH NEXT FROM tar INTO @userID, @userName
		end
		CLOSE tar
		DEALLOCATE tar
	commit tran
	set @Ret = 0
	--登记工作日志：
	declare @worknote nvarchar(100)
	
	if (@execRet=0)
		set @worknote = '系统根据用户' + @createManName + '的要求添加了群组[' + @groupName + '('+@groupID+')]。'
	else
		set @worknote = '系统根据用户' + @createManName + '的要求添加了群组[' + @groupName + '('+@groupID+')],但在发送邀请函的时候出错。'
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加群组', @worknote)
GO
select * from communityGroup
--测试：
declare	@Ret		int
declare	@createTime smalldatetime 
declare	@groupID varchar(12)
exec dbo.createCommunityGroup '生活休闲','测试群组', '这是一个测试用群组','这是给邀请人的留言',
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
	'00000009',@Ret	output,@createTime output,@groupID output
select @Ret, @groupID, @Ret
select * from communityGroup
select * from communityGroupMember
select * from communityGroupApply
select * from messageInfo
select * from workNote order by actionTime desc
delete communityGroup
delete messageInfo

declare @x xml
set @x = N'<root>
			<row id="1">
				<userID>00000008</userID>
				<userName>余  玮</userName>
			</row>
			<row id="2">
				<userID>00000009</userID>
				<userName>卢苇</userName>
			</row>
		</root>'
select @x.query('//userName/text()')

drop PROCEDURE inviteGroupMember
/*
	name:		inviteGroupMember
	function:	2.邀请加入群组
				注意：本过程是群主的操作功能。
				本过程自动生成邀请函消息，并发送到消息队列。
	input: 
				@groupID varchar(12),			--群组ID
				@applyMsg nvarchar(300),	--留言
				@members xml,				--使用xml存储的邀请参加人名单：N'<root>
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

				@inviteManID varchar(10),	--邀请人（群主）工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的群组不存在，2：没有邀请组员的权力，9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE inviteGroupMember
	@groupID varchar(12),		--群组ID
	@applyMsg nvarchar(300),	--留言
	@members xml,				--使用xml存储的邀请参加人名单：N'<root>
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

	@inviteManID varchar(10),		--群主工号

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的群组是否存在
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID and isOff='0')
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--取群组信息：
	declare @groupName nvarchar(30)	--群组名称
	declare @managerID varchar(10)	--群主工号
	select @groupName = groupName, @managerID=managerID
	from communityGroup
	where groupID = @groupID
	--检查权限：
	if(@inviteManID<>@managerID)
	begin
		set @Ret = 2
		return
	end

	--取群主姓名：
	declare @managerName nvarchar(30)
	set @managerName = isnull((select userCName from activeUsers where userID = @managerID),'')

	--邀请函：
	declare @InviteForm nvarchar(4000)
	set @InviteForm = 
	N'<root>
		<groupID>'+@groupID+'</groupID>
		<groupName>'+@groupName+'</groupName>
		<cmdType>Invite</cmdType>
		<applyID>{#applyID}</applyID>
		<applyMsg>'+@applyMsg+'</applyMsg>
	</root>'
	declare @createTime smalldatetime
	set @createTime = getdate()
	begin tran
		--插入邀请人员表：
		declare @userID varchar(10), @userName nvarchar(30)		--被邀请人（申请人）工号、姓名
		declare tar cursor for
		select cast(T.x.query('data(./userID)') as varchar(10)) userID,
				cast(T.x.query('data(./userName)') as nvarchar(30)) userName
		from(select @members.query('/root/row') Col1) A
			OUTER APPLY A.Col1.nodes('/row') AS T(x)
		OPEN tar
		FETCH NEXT FROM tar INTO @userID, @userName
		WHILE @@FETCH_STATUS = 0
		begin
			--判断该用户是否是该组的活动成员,如果是则忽略！
			set @count=(select count(*) from communityGroupMember where groupID = @groupID and userID=@userID and isOff='0')	
			if (@count > 0)	--存在
				continue

			--使用号码发生器产生单据的号码：
			declare @curNumber varchar(50)
			declare @applyID varchar(12)
			exec dbo.getClassNumber 20002, 1, @curNumber output
			set @applyID = @curNumber

			insert communityGroupApply(applyID, groupID, groupName, userID, userName, applyMsg)
			values(@applyID, @groupID, @groupName, @userID,@userName, @applyMsg)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				CLOSE tar
				DEALLOCATE tar
				return
			end
			--生成消息：
			declare @execRet int, @messageID varchar(12)
			declare @rInviteForm nvarchar(4000)
			set @rInviteForm = replace(@InviteForm,'{#applyID}',@applyID)
			exec dbo.addMessageInfo 9,'群邀请函', 9, @inviteManID, 1, @userID, @rInviteForm,
				@execRet output, @messageID output
			
			FETCH NEXT FROM tar INTO @userID, @userName
		end
		CLOSE tar
		DEALLOCATE tar
	commit tran
	set @Ret = 0
	--登记工作日志：
	declare @worknote nvarchar(100)
	
	if (@execRet=0)
		set @worknote = '用户' + @managerName + '邀请'
			+ cast(@members.query('//userName/text()') as nvarchar(100)) +'等人参加群组[' + @groupName + '('+@groupID+')]。'
	else
		set @worknote = '用户' + @managerName + '邀请'
			+ cast(@members.query('//userName/text()') as nvarchar(100)) +'等人参加群组[' + @groupName + '('+@groupID+')],但在发送邀请函的时候出错。'
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@inviteManID, @managerName, @createTime, '邀请群组员', @worknote)
GO
declare	@Ret		int
declare	@createTime smalldatetime 
declare	@groupID varchar(12)
exec dbo.inviteGroupMember '201304190006', '这是给邀请人的留言',
		N'<root>
			<row id="1">
				<userID>00000008</userID>
				<userName>余  玮</userName>
			</row>
			<row id="2">
				<userID>G201300004</userID>
				<userName>卢苇</userName>
			</row>
		</root>',
	'G201300040',@Ret	output
select @Ret
select * from communityGroup
select * from communityGroupApply
select * from messageInfo
select * from workNote order by actionTime desc

drop PROCEDURE applyGroupMember
/*
	name:		applyGroupMember
	function:	3.申请加入群组
				注意：本过程是一般用户的操作功能。
				本过程自动生成申请函消息，并发送到消息队列。
	input: 
				@groupID varchar(12),		--群组ID
				@applyMsg nvarchar(300),	--留言
				@userID varchar(10),		--申请人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的群组不存在，2：该用户已经是该群组的成员，9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE applyGroupMember
	@groupID varchar(12),		--群组ID
	@applyMsg nvarchar(300),	--留言
	@userID varchar(10),		--申请人工号

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断要锁定的群组是否存在
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID and isOff='0')
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--判断该用户是否是该组的活动成员,如果是则忽略！
	set @count=(select count(*) from communityGroupMember where groupID = @groupID and userID=@userID and isOff='0')	
	if (@count > 0)	--存在
	begin
		set @Ret = 2
		return
	end

	--取群组信息：
	declare @groupName nvarchar(30)	--群组名称
	declare @managerID varchar(10),@managerName nvarchar(30)--群主工号和姓名
	select @groupName = groupName, @managerID=managerID, @managerName = manager 
	from communityGroup
	where groupID = @groupID

	--取申请人姓名：
	declare @userName nvarchar(30)
	set @userName = isnull((select userCName from activeUsers where userID = @managerID),'')

	--邀请函：
	declare @InviteForm nvarchar(4000)
	set @InviteForm = 
	N'<root>
		<groupID>'+@groupID+'</groupID>
		<groupName>'+@groupName+'</groupName>
		<cmdType>Invite</cmdType>
		<applyID>{#applyID}</applyID>
		<applyMsg>'+@applyMsg+'</applyMsg>
	</root>'
	
	declare @createTime smalldatetime
	set @createTime = getdate()
	--使用号码发生器产生单据的号码：
	declare @curNumber varchar(50)
	declare @applyID varchar(12)
	exec dbo.getClassNumber 20002, 1, @curNumber output
	set @applyID = @curNumber

	insert communityGroupApply(applyID,	applyType, groupID, groupName, userID, userName, applyMsg)
	values(@applyID, 1, @groupID, @groupName, @userID,@userName, @applyMsg)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	--生成消息：
	declare @execRet int, @messageID varchar(12)
	set @InviteForm = replace(@InviteForm,'{#applyID}',@applyID)
	exec dbo.addMessageInfo 10,'群申请函', 9, @userID, 1, @managerID, @InviteForm,
		@execRet output, @messageID output

	set @Ret = 0
	--登记工作日志：
	declare @worknote nvarchar(100)
	
	if (@execRet=0)
		set @worknote = '用户' + @userName + '申请加入群组[' + @groupName + '('+@groupID+')]。'
	else
		set @worknote = '用户' + @userName + '申请加入群组[' + @groupName + '('+@groupID+')],但在发送邀请函的时候出错。'
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@userID, @userName, @createTime, '申请加入群组', @worknote)
GO

drop PROCEDURE answerGroupMemberApply
/*
	name:		answerGroupMemberApply
	function:	4.回复申请（或邀请）
				注意：本过程是消息的处理函数调用过程
	input: 
				@applyID char(12),			--邀请（或申请）单号
				@answerID varchar(10),		--回复人工号
				@result char(1),			--是否同意："Y"同意，"N"不同意
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的群组不存在，2：该用户已经是该群组的成员，3：没有权力处理该单据，4:该单据已经回复，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE answerGroupMemberApply
	@applyID char(12),			--邀请（或申请）单号
	@answerID varchar(10),		--回复人工号
	@result char(1),			--是否同意："Y"同意，"N"不同意
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--获取单据的信息：
	declare @applyType smallint		--单据类型：0->邀请单，1->申请单
	declare @applyStatus smallint	--单据状态：0->等待同意，1->已同意，-1->不同意
	declare @groupID varchar(12)		--群组ID
	declare @groupName nvarchar(30)	--群组名称,
	declare @userID varchar(10)		--邀请人员（或申请人员）工号
	declare @userName nvarchar(30)	--邀请人员（或申请人员）姓名
	declare @applyMsg nvarchar(300)	--留言
	declare @managerID varchar(10)	--群主工号
	declare @manager nvarchar(30)	--群主姓名
	
	select @applyType=a.applyType, @applyStatus=a.applyStatus, 
			@groupID=a.groupID, @groupName=c.groupName, @managerID =c.managerID, @manager = manager,
			@userID=a.userID, @userName=a.userName, @applyMsg=a.applyMsg
	from communityGroupApply a left join communityGroup c on a.groupID = c.groupID
	where applyID=@applyID
	--判断要锁定的群组是否存在
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID and isOff='0')
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	--检查单据状态：
	if (@applyStatus<>0)
	begin
		set @Ret = 4
		return
	end
	--检查单据类型和处理人是否匹配：
	if (@applyType=0 and @answerID <>@userID) or (@applyType=1 and @answerID <>@managerID)
	begin
		set @Ret = 3
		return
	end

	--取回复人姓名：
	declare @answer nvarchar(30)
	set @answer = isnull((select userCName from activeUsers where userID = @managerID),'')

	declare @createTime smalldatetime
	set @createTime = getdate()
	if (@result='Y')	--同意
	begin
		--判断该用户是否是该组的活动成员,如果是则忽略！
		set @count=(select count(*) from communityGroupMember where groupID = @groupID and userID=@userID and isOff='0')	
		if (@count > 0)	--存在
		begin
			set @Ret = 2
			return
		end
		begin tran
			update communityGroupApply
			set applyStatus = 1
			where applyID = @applyID
			if @@ERROR <> 0 
			begin
				rollback tran
				set @Ret = 9
				return
			end
			insert communityGroupMember(groupID, groupName, userID, userName, createTime)
			values(@groupID, @groupName, @userID, @userName, @createTime)
			if @@ERROR <> 0 
			begin
				rollback tran
				set @Ret = 9
				return
			end
		commit tran
		set @Ret = 0
		--登记工作日志：
		if (@applyType=0)
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@answerID, @answer, @createTime, '同意邀请加入群', '用户' + @answer + '同意了加入群组[' + @groupName + '('+@groupID+')]。')
		else
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@answerID, @answer, @createTime, '同意申请加入群', '群主' + @answer + '同意了用户['+@userName+']加入群组[' + @groupName + '('+@groupID+')]的申请。')
	end
	else	--不同意
	begin
		update communityGroupApply
		set applyStatus = -1
		where applyID = @applyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end
		set @Ret = 0
		--登记工作日志：
		if (@applyType=0)
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@answerID, @answer, @createTime, '拒绝邀请加入群', '用户' + @answer + '拒绝了加入群组[' + @groupName + '('+@groupID+')]。')
		else
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@answerID, @answer, @createTime, '拒绝申请加入群', '群主' + @answer + '拒绝了用户['+@userName+']加入群组[' + @groupName + '('+@groupID+')]的申请。')
	end
GO
--测试：
declare @Ret int
exec dbo.answerGroupMemberApply '201304190011','G201300105','Y',@Ret output
select @Ret

select * from communityGroupApply where applyID='201304190011'
select * from communityGroupApply where groupID ='201304190004'
select * from messageInfo
1	G201300005	胡颖	<root>   <groupID>201304190006</groupID>   <groupName>lw123</groupName>   <cmdType>Invite</cmdType>   <applyID>201304190017</applyID>   <applyMsg>卢苇 邀请您加入 lw123 群</applyMsg>   </root>
1	G201300105	卢芳	<root>   <groupID>201304190006</groupID>   <groupName>lw123</groupName>   <cmdType>Invite</cmdType>   <applyID>201304190017</applyID>   <applyMsg>卢苇 邀请您加入 lw123 群</applyMsg>   </root>

delete communityGroup
delete messageInfo

drop PROCEDURE queryCommunityGroupLocMan
/*
	name:		queryCommunityGroupLocMan
	function:	5.查询指定群组是否有人正在编辑
	input: 
				@groupID varchar(12),		--群组ID
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的群组不存在
				@lockManID varchar(10) output	--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE queryCommunityGroupLocMan
	@groupID varchar(12),		--群组ID
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from communityGroup where groupID = @groupID),'')
	set @Ret = 0
GO


drop PROCEDURE lockCommunityGroup4Edit
/*
	name:		lockCommunityGroup4Edit
	function:	6.锁定群组编辑，避免编辑冲突
	input: 
				@groupID varchar(12),			--群组ID
				@lockManID varchar(10) output,	--锁定人，如果当前群组正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的群组不存在，2:要锁定的群组正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE lockCommunityGroup4Edit
	@groupID varchar(12),			--群组ID
	@lockManID varchar(10) output,	--锁定人，如果当前群组正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的群组是否存在
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from communityGroup where groupID = @groupID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update communityGroup
	set lockManID = @lockManID 
	where groupID = @groupID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定群组编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了群组['+ @groupID +']为独占式编辑。')
GO

drop PROCEDURE unlockCommunityGroupEditor
/*
	name:		unlockCommunityGroupEditor
	function:	7.释放群组编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@groupID varchar(12),			--群组ID
				@lockManID varchar(10) output,	--锁定人，如果当前群组正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE unlockCommunityGroupEditor
	@groupID varchar(12),			--群组ID
	@lockManID varchar(10) output,	--锁定人，如果当前群组正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from communityGroup where groupID = @groupID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update communityGroup set lockManID = '' where groupID = @groupID
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
	values(@lockManID, @lockManName, getdate(), '释放群组编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了群组['+ @groupID +']的编辑锁。')
GO

drop PROCEDURE offCommunityGroupMember
/*
	name:		offCommunityGroupMember
	function:	8.组员退出
				注意：本过程当全部组员都退出的时候自动关闭群组
	input: 
				@groupID varchar(12),		--群组ID
				@userID varchar(10),		--要退出的组员工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的群组不存在，2.该用户不是该群组的成员，9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE offCommunityGroupMember
	@groupID varchar(12),		--群组ID
	@userID varchar(10),		--要退出的组员工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要退出的群组是否存在
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID and isOff='0')	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--判断该用户是否是该组的成员
	declare @status char(1)
	set @status = '0'
	set @count=(select count(*) from communityGroupMember where groupID = @groupID and userID=@userID and isOff='0')	
	if (@count = 0)	--不存在
	begin
		set @Ret = 2
		return
	end

	--取群组名称：
	declare @groupName nvarchar(30)
	set @groupName = ISNULL((select groupName from communityGroup where groupID = @groupID),'')
	
	--取组员的姓名：
	declare @userName nvarchar(30)
	set @userName = isnull((select userCName from activeUsers where userID = @userID),'')

	declare @existTime smalldatetime
	set @existTime = getdate()
	begin tran
		update communityGroupMember
		set isOff = '1', offDate = @existTime
		where groupID = @groupID and userID=@userID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	
		--检查是否是所有成员都退出，如果是则自动关闭群组：
		set @count=(select count(*) from communityGroupMember where groupID = @groupID and isOff='0')	
		if (@count = 0)
		begin
			update communityGroup
			set isOff='1', offDate=GETDATE()
			where groupID = @groupID
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
	values(@userID, @userName, @existTime, '退出群组', '用户' + @userName
												+ '退出了群组['+ @groupName + '('+@groupID +')]。')
GO

drop PROCEDURE outCommunityGroupMember
/*
	name:		outCommunityGroupMember
	function:	9.将组员踢出群组
				注意：这是群主的操作，本过程检查权限
	input: 
				@groupID varchar(12),		--群组ID
				@userID varchar(10),		--要踢出的组员工号
				@delManID varchar(10),		--操作人（群主）工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：指定的群组不存在，2：该用户不是该群组的成员，3：你没有踢出组员的权利，9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE outCommunityGroupMember
	@groupID varchar(12),		--群组ID
	@userID varchar(10),		--要踢出的组员工号
	@delManID varchar(10),		--操作人（群主）工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要退出的群组是否存在
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID and isOff='0')	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--取群组信息：
	declare @managerID varchar(10)	--群主工号
	declare @manager nvarchar(30)	--群主姓名
	declare @groupName nvarchar(30)	--群组名称
	select @groupName = groupName, @managerID= managerID, @manager= manager 
	from communityGroup 
	where groupID = @groupID
	
	if (@delManID<>@managerID)
	begin
		set @Ret = 3
		return
	end
	
	--判断该用户是否是该群的成员
	declare @status char(1)
	set @status = '0'
	set @count=(select count(*) from communityGroupMember where groupID = @groupID and userID=@userID and isOff='0')	
	if (@count = 0)	--不存在
	begin
		set @Ret = 2
		return
	end

	--取组员的姓名：
	declare @userName nvarchar(30)
	set @userName = isnull((select cName from userInfo where jobNumber = @userID),'')

	--取操作人（群主）的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	declare @exitTime smalldatetime
	set @exitTime = getdate()
	begin tran
		update communityGroupMember
		set isOff = '1', offDate = @exitTime
		where groupID = @groupID and userID=@userID
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end
	
		--检查是否是所有成员都退出，如果是则自动关闭群组：
		set @count=(select count(*) from communityGroupMember where groupID = @groupID and isOff='0')	
		if (@count = 0)
		begin
			update communityGroup
			set isOff='1', offDate=GETDATE()
			where groupID = @groupID
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
	values(@delManID, @delManName, @exitTime, '踢出群组员', '群主' + @delManName
												+ '将组员['+@userName+']踢出了群组['+ @groupName + '('+@groupID +')]。')
GO

drop PROCEDURE updateCommunityGroup
/*
	name:		updateCommunityGroup
	function:	10.更新群组
	input: 
				@groupID varchar(12),		--群组ID
				@groupClass nvarchar(30),	--群组类别
				@groupName nvarchar(30),	--群组名称,
				@notes nvarchar(300),		--群组描述
				@managerID varchar(10),		--群主工号

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前群组正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的群组不存在，2：要更新的群组正被别人锁定，3:要更新的名称已经被占用，
							4:维护人没有更新权力，5:要设定的新群主还不是组员，
							9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE updateCommunityGroup
	@groupID varchar(12),		--群组ID
	@groupClass nvarchar(30),	--群组类别
	@groupName nvarchar(30),	--群组名称,
	@notes nvarchar(300),		--群组描述
	@managerID varchar(10),		--群主工号

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前群组正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的群组是否存在
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--取群组信息：
	declare @oldManagerID varchar(10)	--群主工号
	declare @oldManager nvarchar(30)	--群主姓名
	declare @thisLockMan varchar(10)	--锁定人
	select @oldManagerID= managerID, @oldManager= manager, @thisLockMan = isnull(lockManID,'')
	from communityGroup 
	where groupID = @groupID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查权限：
	if (@modiManID <> @oldManagerID)
	begin
		set @Ret =4
		return
	end
	
	--检查名称是否唯一：不检查关闭的群组
	set @count = ISNULL((select count(*) from communityGroup 
							where groupID<>@groupID and groupName = @groupName and isOff='0'),0)
	if (@count>0)
	begin
		set @Ret =1
		return
	end
	

	--判断新群主是否是该群的成员
	set @count=(select count(*) from communityGroupMember where groupID = @groupID and userID=@managerID and isOff='0')	
	if (@count = 0)	--不存在
	begin
		set @Ret = 5
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--取新群主的姓名：
	declare @manager nvarchar(30)
	set @manager = isnull((select cName from userInfo where jobNumber = @managerID),'')
	
	set @updateTime = getdate()
	begin tran
		--更新主表：
		update communityGroup
		set groupClass=@groupClass, groupName= @groupName,notes = @notes,
			managerid = @managerID, manager = @manager,
			--维护情况:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where groupID = @groupID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--更新组员表中的群主信息：
		if (@oldManagerID <> @managerID)
		begin
			update communityGroupMember
			set userType = 0
			where groupID = @groupID and userID = @oldManagerID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			update communityGroupMember
			set userType = 99
			where groupID = @groupID and userID = @ManagerID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		end
		
		--更新组员表：
		update communityGroupMember
		set groupName = @groupName
		where groupID = @groupID
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
	values(@modiManID, @modiManName, @updateTime, '更新群组', '用户' + @modiManName 
												+ '更新了群组['+ @groupID +']的名称、描述和（或）群主。')
GO


drop PROCEDURE delCommunityGroup
/*
	name:		delCommunityGroup
	function:	11.删除指定的群组
				注意：为了保持历史记录，最好不要使用本功能，应该使用关闭功能！
	input: 
				@groupID varchar(12),			--群组ID
				@delManID varchar(10) output,	--删除人，如果当前群组正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的群组不存在，2：要删除的群组正被别人锁定，
							3:没有删除群的权力
							9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 

*/
create PROCEDURE delCommunityGroup
	@groupID varchar(12),			--群组ID
	@delManID varchar(10) output,	--删除人，如果当前群组正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的群组是否存在
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--取群组信息：
	declare @groupName nvarchar(30)	--群名称
	declare @managerID varchar(10)	--群主工号
	declare @thisLockMan varchar(10)--锁定人
	select @groupName=groupName, @thisLockMan= isnull(lockManID,''), @managerID = managerID 
	from communityGroup 
	where groupID = @groupID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查权限：
	if (@delManID <> @managerID)
	begin
		set @Ret =3
		return
	end

	delete communityGroup where groupID = @groupID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除群组', '用户' + @delManName
												+ '删除了群组['+ @groupName+ '(' + @groupID +')]。')

GO

drop PROCEDURE closeCommunityGroup
/*
	name:		closeCommunityGroup
	function:	12.关闭群组
	input: 
				@groupID varchar(12),			--群组ID
				@stopManID varchar(10) output,	--关闭人，如果当前群组正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的群组不存在，2：要关闭的群组正被别人锁定，3：该群组本就是关闭状态，
							4:没有关闭群的权力
							9：未知错误
	author:		卢苇
	CreateDate:	2013-4-13
	UpdateDate: 

*/
create PROCEDURE closeCommunityGroup
	@groupID varchar(12),			--群组ID
	@stopManID varchar(10) output,	--关闭人，如果当前群组正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的群组是否存在
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--取群组信息：
	declare @groupName nvarchar(30)	--群名称
	declare @managerID varchar(10)	--群主工号
	declare @thisLockMan varchar(10), @status char(1)	--锁定人与群状态
	select  @groupName = groupName, @thisLockMan = isnull(lockManID,'') , @status = isOff, @managerID = managerID 
	from communityGroup where groupID = @groupID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查权限：
	if (@stopManID <> @managerID)
	begin
		set @Ret =4
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
	update communityGroup
	set isOff = '1', offDate = @stopTime
	where groupID = @groupID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '关闭群组', '用户' + @stopManName
												+ '关闭了群组[' + @groupName + '(' + @groupID + ')]。')
GO

--查询语句：
select c.groupID,c.groupName, c.notes,
c.managerID, c.manager,
c.isOff, case c.isOff when '0' then '' when '1' then convert(varchar(10),c.offDate,120) end offDate,
c.createManID,c.createManName
from communityGroup c

--明细表查询语句：
select m.groupID,m.groupName, m.userType, m.userID,m.userName,
m.isOff, case m.isOff when '0' then '' when '1' then convert(varchar(10),m.offDate,120) end offDate,
convert(varchar(10),m.createTime,120) createTime
from communityGroupMember m


select groupID from communityGroupMember where isOff='0' and userID = '00000008'