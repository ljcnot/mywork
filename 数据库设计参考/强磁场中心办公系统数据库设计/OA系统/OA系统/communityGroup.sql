use hustOA
/*
	OA������Ϣϵͳ-Ⱥ�����
	ע�⣺��������Ⱥ�������
	�����飺����ԱȨ��ƽ�ȣ��κ�һ����Ա������������˲μ������飬����Ҫͬ�⼴�ɼ��������飬ϵͳ��֧���г�ȫ��������Ĺ��ܣ�
	��֧���߳����˵�Ȩ����ֻ֧�������˳���ȫ����Ա�˳���ϵͳ�Զ���ɢ�����顣
	Ⱥ�飺��һ����Ȩ�����û���������Ⱥ����ϵͳ֧���г�ȫ��Ⱥ��Ĺ��ܣ��κ��˶�������������ض���Ⱥ�飬ֻҪȺ��ͬ��Ϳ����ˣ�
	Ⱥ����������һ���˲μ�Ⱥ��ֻҪ��������ͬ�⼴�ɣ�
	Ⱥ�������߳�һ����Ա�����Խ�ɢһ��Ⱥ�顣����Ⱥ��ƻ���չ��һЩ������Դ�������������ȡ�
	�������Ⱥ�Ĳ���ֻ�и��¹�����Ҫ������
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/

--1.Ⱥ��һ����
select * from communityGroup
drop TABLE communityGroup
CREATE TABLE communityGroup(
	groupID char(12) not null,			--������Ⱥ��ID,�ɵ�20001�ź��뷢��������
										--8λ���ڴ���+4λ��ˮ��
	
	groupClass nvarchar(30) not null,	--Ⱥ�����
	groupName nvarchar(30) not null,	--Ⱥ������
	notes nvarchar(300) null,			--Ⱥ������
	
	managerID varchar(10) not null,		--Ⱥ������
	manager nvarchar(30) not null,		--������ƣ�Ⱥ������

	--ע�⣺�ر��˵�Ⱥ�齫���������Ʋ��أ���ϵͳ���ṩ�������ù��ܣ�
	--��������ṩ�ù��������õ�ʱ��Ҫ��������Ƿ��ظ���
	isOff char(1) default('0') null,	--�Ƿ�ر�:��0���������ã���1������ر�
	offDate smalldatetime null,			--�ر�����

	--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_communityGroup] PRIMARY KEY CLUSTERED 
(
	[groupID] DESC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--������
--Ⱥ������������
CREATE NONCLUSTERED INDEX [IX_communityGroup] ON [dbo].[communityGroup] 
(
	[groupName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.Ⱥ����Ա������
select * from communityGroupMember where groupID='201304180017'
drop table communityGroupMember
CREATE TABLE communityGroupMember(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	groupID char(12) not null,			--�����Ⱥ��ID
	groupName nvarchar(30) not null,	--������ƣ�Ⱥ������,
	userType smallint default(0),		--�û����ͣ�0->��ͨ��Ա��99->Ⱥ��
	userID varchar(10) not null,		--��Ա����
	userName nvarchar(30) not null,		--������ƣ���Ա����
	
	--�ٴν�����Ƿ�Ӧ�ü���Ƿ����ٴν��룺
	isOff char(1) default('0') null,	--�Ƿ��˳�:��0������δ�˳�����1�������˳�
	offDate smalldatetime null,			--�˳�����
	
	createTime smalldatetime null,		--����ʱ��
CONSTRAINT [PK_communityGroupMember] PRIMARY KEY CLUSTERED 
(
	[groupID]ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[communityGroupMember] WITH CHECK ADD CONSTRAINT [FK_communityGroupMember_communityGroup] FOREIGN KEY([groupID])
REFERENCES [dbo].[communityGroup] ([groupID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[communityGroupMember] CHECK CONSTRAINT [FK_communityGroupMember_communityGroup]
GO

--������
--��Ա����������
CREATE NONCLUSTERED INDEX [IX_communityGroupMember] ON [dbo].[communityGroupMember] 
(
	[userID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--3.���루�����룩�μ���Ա�����������ӱ���ƣ�һ��һ������
select * from communityGroupApply where groupID='201304180017'
drop table communityGroupApply
CREATE TABLE communityGroupApply(
	applyID char(12) not null,			--���������루�����룩���ţ��ɵ�20002�ź��뷢��������
	applyType smallint default(0),		--�������ͣ�0->���뵥��1->���뵥
	applyStatus smallint default(0),	--����״̬��0->�ȴ�ͬ�⣬1->��ͬ�⣬-1->��ͬ��
	groupID char(12) not null,			--�����Ⱥ��ID
	groupName nvarchar(30) not null,	--������ƣ�Ⱥ������,
	
	userID varchar(10) not null,		--������Ա����������Ա������
	userName nvarchar(30) not null,		--������ƣ�������Ա����������Ա������
	applyMsg nvarchar(300) null,		--����
	
CONSTRAINT [PK_communityGroupApply] PRIMARY KEY CLUSTERED 
(
	[applyID]ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[communityGroupApply] WITH CHECK ADD CONSTRAINT [FK_communityGroupApply_communityGroup] FOREIGN KEY([groupID])
REFERENCES [dbo].[communityGroup] ([groupID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[communityGroupApply] CHECK CONSTRAINT [FK_communityGroupApply_communityGroup]
GO

--������
--�������ˣ������ˣ�����������
CREATE NONCLUSTERED INDEX [IX_communityGroupApply] ON [dbo].[communityGroupApply] 
(
	[userID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE checkCommunityGroupName
/*
	name:		checkCommunityGroupName
	function:	0.1.���ָ����Ⱥ���Ƿ��Ѿ�����
	input: 
				@groupName nvarchar(30),	--Ⱥ������
				@groupID varchar(12),		--Ⱥ��ID:���½����ʱ�����ֶ�����Ϊ""
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE checkCommunityGroupName
	@groupName nvarchar(30),	--Ⱥ������
	@groupID varchar(12),		--Ⱥ��ID:���½����ʱ�����ֶ�����Ϊ""
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���Ⱥ�������Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from communityGroup where groupName = @groupName and isOff='0' and groupID<>@groupID)
	set @Ret = @count
GO

drop PROCEDURE createCommunityGroup
/*
	name:		createCommunityGroup
	function:	1.����Ⱥ��
				ע�⣺���洢���̲������༭�������˾���Ⱥ����
				�������Զ��������뺯��Ϣ�������͵���Ϣ���С�
	input: 
				@groupClass nvarchar(30),	--Ⱥ�����
				@groupName nvarchar(30),	--Ⱥ������,
				@notes nvarchar(300),		--Ⱥ������
				@applyMsg nvarchar(300),	--����
				@members xml,				--ʹ��xml�洢������μ���������N'<root>
																	--	<row id="1">
																	--		<userID>00000008</userID>
																	--		<userName>��  ��</userName>
																	--	</row>
																	--	<row id="2">
																	--		<userID>00000009</userID>
																	--		<userName>¬έ</userName>
																	--	</row>
																	--	...
																	--</root>'

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ⱥ�������Ѿ���ռ�ã�9��δ֪����
				@createTime smalldatetime output,
				@groupID varchar(12) output	--������Ⱥ��ID,�ɵ�20001�ź��뷢��������
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE createCommunityGroup
	@groupClass nvarchar(30),	--Ⱥ�����
	@groupName nvarchar(30),	--Ⱥ������,
	@notes nvarchar(300),		--Ⱥ������
	@applyMsg nvarchar(300),	--����
	@members xml,				--ʹ��xml�洢������μ���������N'<root>
														--	<row id="1">
														--		<userID>00000008</userID>
														--		<userName>��  ��</userName>
														--	</row>
														--	<row id="2">
														--		<userID>00000009</userID>
														--		<userName>¬έ</userName>
														--	</row>
														--	...
														--</root>'

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,
	@groupID varchar(12) output	--������Ⱥ��ID,�ɵ�20001�ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--��������Ƿ�Ψһ��
	declare @count int
	set @count = ISNULL((select count(*) from communityGroup where groupName = @groupName and isOff='0'),0)
	if (@count>0)
	begin
		set @Ret =1
		return
	end
	--ʹ�ú��뷢��������Ⱥ�ĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 20001, 1, @curNumber output
	set @groupID = @curNumber

	--ȡ�����ˣ�Ⱥ����������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--���뺯��
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
		--��Ⱥ����ΪĬ�ϵ���Ա��
		insert communityGroupMember(groupID, groupName, userType, userID, userName, createTime)
		values(@groupID, @groupName, 99, @createManID, @createManName, @createTime)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--����������Ա��
		declare @userID varchar(10), @userName nvarchar(30)		--�������ˣ������ˣ����š�����
		declare tar cursor for
		select cast(T.x.query('data(./userID)') as varchar(10)) userID,
				cast(T.x.query('data(./userName)') as nvarchar(30)) userName
		from(select @members.query('/root/row') Col1) A
			OUTER APPLY A.Col1.nodes('/row') AS T(x)
		OPEN tar
		FETCH NEXT FROM tar INTO @userID, @userName
		WHILE @@FETCH_STATUS = 0
		begin
			--ʹ�ú��뷢�����������ݵĺ��룺
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
			--������Ϣ��
			declare @execRet int, @messageID varchar(12)
			declare @rInviteForm nvarchar(4000)
			set @rInviteForm = replace(@InviteForm,'{#applyID}',@applyID)
			exec dbo.addMessageInfo 9,'Ⱥ���뺯', 9, @createManID, 1, @userID, @rInviteForm,
				@execRet output, @messageID output
			
			FETCH NEXT FROM tar INTO @userID, @userName
		end
		CLOSE tar
		DEALLOCATE tar
	commit tran
	set @Ret = 0
	--�Ǽǹ�����־��
	declare @worknote nvarchar(100)
	
	if (@execRet=0)
		set @worknote = 'ϵͳ�����û�' + @createManName + '��Ҫ�������Ⱥ��[' + @groupName + '('+@groupID+')]��'
	else
		set @worknote = 'ϵͳ�����û�' + @createManName + '��Ҫ�������Ⱥ��[' + @groupName + '('+@groupID+')],���ڷ������뺯��ʱ�����'
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '���Ⱥ��', @worknote)
GO
select * from communityGroup
--���ԣ�
declare	@Ret		int
declare	@createTime smalldatetime 
declare	@groupID varchar(12)
exec dbo.createCommunityGroup '��������','����Ⱥ��', '����һ��������Ⱥ��','���Ǹ������˵�����',
		N'<root>
			<row id="1">
				<userID>00000008</userID>
				<userName>��  ��</userName>
			</row>
			<row id="2">
				<userID>00000009</userID>
				<userName>¬έ</userName>
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
				<userName>��  ��</userName>
			</row>
			<row id="2">
				<userID>00000009</userID>
				<userName>¬έ</userName>
			</row>
		</root>'
select @x.query('//userName/text()')

drop PROCEDURE inviteGroupMember
/*
	name:		inviteGroupMember
	function:	2.�������Ⱥ��
				ע�⣺��������Ⱥ���Ĳ������ܡ�
				�������Զ��������뺯��Ϣ�������͵���Ϣ���С�
	input: 
				@groupID varchar(12),			--Ⱥ��ID
				@applyMsg nvarchar(300),	--����
				@members xml,				--ʹ��xml�洢������μ���������N'<root>
																	--	<row id="1">
																	--		<userID>00000008</userID>
																	--		<userName>��  ��</userName>
																	--	</row>
																	--	<row id="2">
																	--		<userID>00000009</userID>
																	--		<userName>¬έ</userName>
																	--	</row>
																	--	...
																	--</root>'

				@inviteManID varchar(10),	--�����ˣ�Ⱥ��������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ⱥ�鲻���ڣ�2��û��������Ա��Ȩ����9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE inviteGroupMember
	@groupID varchar(12),		--Ⱥ��ID
	@applyMsg nvarchar(300),	--����
	@members xml,				--ʹ��xml�洢������μ���������N'<root>
														--	<row id="1">
														--		<userID>00000008</userID>
														--		<userName>��  ��</userName>
														--	</row>
														--	<row id="2">
														--		<userID>00000009</userID>
														--		<userName>¬έ</userName>
														--	</row>
														--	...
														--</root>'

	@inviteManID varchar(10),		--Ⱥ������

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������Ⱥ���Ƿ����
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID and isOff='0')
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--ȡȺ����Ϣ��
	declare @groupName nvarchar(30)	--Ⱥ������
	declare @managerID varchar(10)	--Ⱥ������
	select @groupName = groupName, @managerID=managerID
	from communityGroup
	where groupID = @groupID
	--���Ȩ�ޣ�
	if(@inviteManID<>@managerID)
	begin
		set @Ret = 2
		return
	end

	--ȡȺ��������
	declare @managerName nvarchar(30)
	set @managerName = isnull((select userCName from activeUsers where userID = @managerID),'')

	--���뺯��
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
		--����������Ա��
		declare @userID varchar(10), @userName nvarchar(30)		--�������ˣ������ˣ����š�����
		declare tar cursor for
		select cast(T.x.query('data(./userID)') as varchar(10)) userID,
				cast(T.x.query('data(./userName)') as nvarchar(30)) userName
		from(select @members.query('/root/row') Col1) A
			OUTER APPLY A.Col1.nodes('/row') AS T(x)
		OPEN tar
		FETCH NEXT FROM tar INTO @userID, @userName
		WHILE @@FETCH_STATUS = 0
		begin
			--�жϸ��û��Ƿ��Ǹ���Ļ��Ա,���������ԣ�
			set @count=(select count(*) from communityGroupMember where groupID = @groupID and userID=@userID and isOff='0')	
			if (@count > 0)	--����
				continue

			--ʹ�ú��뷢�����������ݵĺ��룺
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
			--������Ϣ��
			declare @execRet int, @messageID varchar(12)
			declare @rInviteForm nvarchar(4000)
			set @rInviteForm = replace(@InviteForm,'{#applyID}',@applyID)
			exec dbo.addMessageInfo 9,'Ⱥ���뺯', 9, @inviteManID, 1, @userID, @rInviteForm,
				@execRet output, @messageID output
			
			FETCH NEXT FROM tar INTO @userID, @userName
		end
		CLOSE tar
		DEALLOCATE tar
	commit tran
	set @Ret = 0
	--�Ǽǹ�����־��
	declare @worknote nvarchar(100)
	
	if (@execRet=0)
		set @worknote = '�û�' + @managerName + '����'
			+ cast(@members.query('//userName/text()') as nvarchar(100)) +'���˲μ�Ⱥ��[' + @groupName + '('+@groupID+')]��'
	else
		set @worknote = '�û�' + @managerName + '����'
			+ cast(@members.query('//userName/text()') as nvarchar(100)) +'���˲μ�Ⱥ��[' + @groupName + '('+@groupID+')],���ڷ������뺯��ʱ�����'
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@inviteManID, @managerName, @createTime, '����Ⱥ��Ա', @worknote)
GO
declare	@Ret		int
declare	@createTime smalldatetime 
declare	@groupID varchar(12)
exec dbo.inviteGroupMember '201304190006', '���Ǹ������˵�����',
		N'<root>
			<row id="1">
				<userID>00000008</userID>
				<userName>��  ��</userName>
			</row>
			<row id="2">
				<userID>G201300004</userID>
				<userName>¬έ</userName>
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
	function:	3.�������Ⱥ��
				ע�⣺��������һ���û��Ĳ������ܡ�
				�������Զ��������뺯��Ϣ�������͵���Ϣ���С�
	input: 
				@groupID varchar(12),		--Ⱥ��ID
				@applyMsg nvarchar(300),	--����
				@userID varchar(10),		--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ⱥ�鲻���ڣ�2�����û��Ѿ��Ǹ�Ⱥ��ĳ�Ա��9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE applyGroupMember
	@groupID varchar(12),		--Ⱥ��ID
	@applyMsg nvarchar(300),	--����
	@userID varchar(10),		--�����˹���

	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������Ⱥ���Ƿ����
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID and isOff='0')
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--�жϸ��û��Ƿ��Ǹ���Ļ��Ա,���������ԣ�
	set @count=(select count(*) from communityGroupMember where groupID = @groupID and userID=@userID and isOff='0')	
	if (@count > 0)	--����
	begin
		set @Ret = 2
		return
	end

	--ȡȺ����Ϣ��
	declare @groupName nvarchar(30)	--Ⱥ������
	declare @managerID varchar(10),@managerName nvarchar(30)--Ⱥ�����ź�����
	select @groupName = groupName, @managerID=managerID, @managerName = manager 
	from communityGroup
	where groupID = @groupID

	--ȡ������������
	declare @userName nvarchar(30)
	set @userName = isnull((select userCName from activeUsers where userID = @managerID),'')

	--���뺯��
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
	--ʹ�ú��뷢�����������ݵĺ��룺
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

	--������Ϣ��
	declare @execRet int, @messageID varchar(12)
	set @InviteForm = replace(@InviteForm,'{#applyID}',@applyID)
	exec dbo.addMessageInfo 10,'Ⱥ���뺯', 9, @userID, 1, @managerID, @InviteForm,
		@execRet output, @messageID output

	set @Ret = 0
	--�Ǽǹ�����־��
	declare @worknote nvarchar(100)
	
	if (@execRet=0)
		set @worknote = '�û�' + @userName + '�������Ⱥ��[' + @groupName + '('+@groupID+')]��'
	else
		set @worknote = '�û�' + @userName + '�������Ⱥ��[' + @groupName + '('+@groupID+')],���ڷ������뺯��ʱ�����'
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@userID, @userName, @createTime, '�������Ⱥ��', @worknote)
GO

drop PROCEDURE answerGroupMemberApply
/*
	name:		answerGroupMemberApply
	function:	4.�ظ����루�����룩
				ע�⣺����������Ϣ�Ĵ��������ù���
	input: 
				@applyID char(12),			--���루�����룩����
				@answerID varchar(10),		--�ظ��˹���
				@result char(1),			--�Ƿ�ͬ�⣺"Y"ͬ�⣬"N"��ͬ��
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ⱥ�鲻���ڣ�2�����û��Ѿ��Ǹ�Ⱥ��ĳ�Ա��3��û��Ȩ������õ��ݣ�4:�õ����Ѿ��ظ���
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE answerGroupMemberApply
	@applyID char(12),			--���루�����룩����
	@answerID varchar(10),		--�ظ��˹���
	@result char(1),			--�Ƿ�ͬ�⣺"Y"ͬ�⣬"N"��ͬ��
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--��ȡ���ݵ���Ϣ��
	declare @applyType smallint		--�������ͣ�0->���뵥��1->���뵥
	declare @applyStatus smallint	--����״̬��0->�ȴ�ͬ�⣬1->��ͬ�⣬-1->��ͬ��
	declare @groupID varchar(12)		--Ⱥ��ID
	declare @groupName nvarchar(30)	--Ⱥ������,
	declare @userID varchar(10)		--������Ա����������Ա������
	declare @userName nvarchar(30)	--������Ա����������Ա������
	declare @applyMsg nvarchar(300)	--����
	declare @managerID varchar(10)	--Ⱥ������
	declare @manager nvarchar(30)	--Ⱥ������
	
	select @applyType=a.applyType, @applyStatus=a.applyStatus, 
			@groupID=a.groupID, @groupName=c.groupName, @managerID =c.managerID, @manager = manager,
			@userID=a.userID, @userName=a.userName, @applyMsg=a.applyMsg
	from communityGroupApply a left join communityGroup c on a.groupID = c.groupID
	where applyID=@applyID
	--�ж�Ҫ������Ⱥ���Ƿ����
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID and isOff='0')
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	--��鵥��״̬��
	if (@applyStatus<>0)
	begin
		set @Ret = 4
		return
	end
	--��鵥�����ͺʹ������Ƿ�ƥ�䣺
	if (@applyType=0 and @answerID <>@userID) or (@applyType=1 and @answerID <>@managerID)
	begin
		set @Ret = 3
		return
	end

	--ȡ�ظ���������
	declare @answer nvarchar(30)
	set @answer = isnull((select userCName from activeUsers where userID = @managerID),'')

	declare @createTime smalldatetime
	set @createTime = getdate()
	if (@result='Y')	--ͬ��
	begin
		--�жϸ��û��Ƿ��Ǹ���Ļ��Ա,���������ԣ�
		set @count=(select count(*) from communityGroupMember where groupID = @groupID and userID=@userID and isOff='0')	
		if (@count > 0)	--����
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
		--�Ǽǹ�����־��
		if (@applyType=0)
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@answerID, @answer, @createTime, 'ͬ���������Ⱥ', '�û�' + @answer + 'ͬ���˼���Ⱥ��[' + @groupName + '('+@groupID+')]��')
		else
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@answerID, @answer, @createTime, 'ͬ���������Ⱥ', 'Ⱥ��' + @answer + 'ͬ�����û�['+@userName+']����Ⱥ��[' + @groupName + '('+@groupID+')]�����롣')
	end
	else	--��ͬ��
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
		--�Ǽǹ�����־��
		if (@applyType=0)
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@answerID, @answer, @createTime, '�ܾ��������Ⱥ', '�û�' + @answer + '�ܾ��˼���Ⱥ��[' + @groupName + '('+@groupID+')]��')
		else
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@answerID, @answer, @createTime, '�ܾ��������Ⱥ', 'Ⱥ��' + @answer + '�ܾ����û�['+@userName+']����Ⱥ��[' + @groupName + '('+@groupID+')]�����롣')
	end
GO
--���ԣ�
declare @Ret int
exec dbo.answerGroupMemberApply '201304190011','G201300105','Y',@Ret output
select @Ret

select * from communityGroupApply where applyID='201304190011'
select * from communityGroupApply where groupID ='201304190004'
select * from messageInfo
1	G201300005	��ӱ	<root>   <groupID>201304190006</groupID>   <groupName>lw123</groupName>   <cmdType>Invite</cmdType>   <applyID>201304190017</applyID>   <applyMsg>¬έ ���������� lw123 Ⱥ</applyMsg>   </root>
1	G201300105	¬��	<root>   <groupID>201304190006</groupID>   <groupName>lw123</groupName>   <cmdType>Invite</cmdType>   <applyID>201304190017</applyID>   <applyMsg>¬έ ���������� lw123 Ⱥ</applyMsg>   </root>

delete communityGroup
delete messageInfo

drop PROCEDURE queryCommunityGroupLocMan
/*
	name:		queryCommunityGroupLocMan
	function:	5.��ѯָ��Ⱥ���Ƿ��������ڱ༭
	input: 
				@groupID varchar(12),		--Ⱥ��ID
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����Ⱥ�鲻����
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE queryCommunityGroupLocMan
	@groupID varchar(12),		--Ⱥ��ID
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from communityGroup where groupID = @groupID),'')
	set @Ret = 0
GO


drop PROCEDURE lockCommunityGroup4Edit
/*
	name:		lockCommunityGroup4Edit
	function:	6.����Ⱥ��༭������༭��ͻ
	input: 
				@groupID varchar(12),			--Ⱥ��ID
				@lockManID varchar(10) output,	--�����ˣ������ǰȺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������Ⱥ�鲻���ڣ�2:Ҫ������Ⱥ�����ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE lockCommunityGroup4Edit
	@groupID varchar(12),			--Ⱥ��ID
	@lockManID varchar(10) output,	--�����ˣ������ǰȺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������Ⱥ���Ƿ����
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����Ⱥ��༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ��������Ⱥ��['+ @groupID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockCommunityGroupEditor
/*
	name:		unlockCommunityGroupEditor
	function:	7.�ͷ�Ⱥ��༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@groupID varchar(12),			--Ⱥ��ID
				@lockManID varchar(10) output,	--�����ˣ������ǰȺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE unlockCommunityGroupEditor
	@groupID varchar(12),			--Ⱥ��ID
	@lockManID varchar(10) output,	--�����ˣ������ǰȺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
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

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷ�Ⱥ��༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ���Ⱥ��['+ @groupID +']�ı༭����')
GO

drop PROCEDURE offCommunityGroupMember
/*
	name:		offCommunityGroupMember
	function:	8.��Ա�˳�
				ע�⣺�����̵�ȫ����Ա���˳���ʱ���Զ��ر�Ⱥ��
	input: 
				@groupID varchar(12),		--Ⱥ��ID
				@userID varchar(10),		--Ҫ�˳�����Ա����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ⱥ�鲻���ڣ�2.���û����Ǹ�Ⱥ��ĳ�Ա��9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE offCommunityGroupMember
	@groupID varchar(12),		--Ⱥ��ID
	@userID varchar(10),		--Ҫ�˳�����Ա����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�˳���Ⱥ���Ƿ����
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID and isOff='0')	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--�жϸ��û��Ƿ��Ǹ���ĳ�Ա
	declare @status char(1)
	set @status = '0'
	set @count=(select count(*) from communityGroupMember where groupID = @groupID and userID=@userID and isOff='0')	
	if (@count = 0)	--������
	begin
		set @Ret = 2
		return
	end

	--ȡȺ�����ƣ�
	declare @groupName nvarchar(30)
	set @groupName = ISNULL((select groupName from communityGroup where groupID = @groupID),'')
	
	--ȡ��Ա��������
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
	
		--����Ƿ������г�Ա���˳�����������Զ��ر�Ⱥ�飺
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
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@userID, @userName, @existTime, '�˳�Ⱥ��', '�û�' + @userName
												+ '�˳���Ⱥ��['+ @groupName + '('+@groupID +')]��')
GO

drop PROCEDURE outCommunityGroupMember
/*
	name:		outCommunityGroupMember
	function:	9.����Ա�߳�Ⱥ��
				ע�⣺����Ⱥ���Ĳ����������̼��Ȩ��
	input: 
				@groupID varchar(12),		--Ⱥ��ID
				@userID varchar(10),		--Ҫ�߳�����Ա����
				@delManID varchar(10),		--�����ˣ�Ⱥ��������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ⱥ�鲻���ڣ�2�����û����Ǹ�Ⱥ��ĳ�Ա��3����û���߳���Ա��Ȩ����9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE outCommunityGroupMember
	@groupID varchar(12),		--Ⱥ��ID
	@userID varchar(10),		--Ҫ�߳�����Ա����
	@delManID varchar(10),		--�����ˣ�Ⱥ��������
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�˳���Ⱥ���Ƿ����
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID and isOff='0')	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--ȡȺ����Ϣ��
	declare @managerID varchar(10)	--Ⱥ������
	declare @manager nvarchar(30)	--Ⱥ������
	declare @groupName nvarchar(30)	--Ⱥ������
	select @groupName = groupName, @managerID= managerID, @manager= manager 
	from communityGroup 
	where groupID = @groupID
	
	if (@delManID<>@managerID)
	begin
		set @Ret = 3
		return
	end
	
	--�жϸ��û��Ƿ��Ǹ�Ⱥ�ĳ�Ա
	declare @status char(1)
	set @status = '0'
	set @count=(select count(*) from communityGroupMember where groupID = @groupID and userID=@userID and isOff='0')	
	if (@count = 0)	--������
	begin
		set @Ret = 2
		return
	end

	--ȡ��Ա��������
	declare @userName nvarchar(30)
	set @userName = isnull((select cName from userInfo where jobNumber = @userID),'')

	--ȡ�����ˣ�Ⱥ������������
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
	
		--����Ƿ������г�Ա���˳�����������Զ��ر�Ⱥ�飺
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
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, @exitTime, '�߳�Ⱥ��Ա', 'Ⱥ��' + @delManName
												+ '����Ա['+@userName+']�߳���Ⱥ��['+ @groupName + '('+@groupID +')]��')
GO

drop PROCEDURE updateCommunityGroup
/*
	name:		updateCommunityGroup
	function:	10.����Ⱥ��
	input: 
				@groupID varchar(12),		--Ⱥ��ID
				@groupClass nvarchar(30),	--Ⱥ�����
				@groupName nvarchar(30),	--Ⱥ������,
				@notes nvarchar(300),		--Ⱥ������
				@managerID varchar(10),		--Ⱥ������

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰȺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ⱥ�鲻���ڣ�2��Ҫ���µ�Ⱥ����������������3:Ҫ���µ������Ѿ���ռ�ã�
							4:ά����û�и���Ȩ����5:Ҫ�趨����Ⱥ����������Ա��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE updateCommunityGroup
	@groupID varchar(12),		--Ⱥ��ID
	@groupClass nvarchar(30),	--Ⱥ�����
	@groupName nvarchar(30),	--Ⱥ������,
	@notes nvarchar(300),		--Ⱥ������
	@managerID varchar(10),		--Ⱥ������

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰȺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ����Ⱥ���Ƿ����
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--ȡȺ����Ϣ��
	declare @oldManagerID varchar(10)	--Ⱥ������
	declare @oldManager nvarchar(30)	--Ⱥ������
	declare @thisLockMan varchar(10)	--������
	select @oldManagerID= managerID, @oldManager= manager, @thisLockMan = isnull(lockManID,'')
	from communityGroup 
	where groupID = @groupID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���Ȩ�ޣ�
	if (@modiManID <> @oldManagerID)
	begin
		set @Ret =4
		return
	end
	
	--��������Ƿ�Ψһ�������رյ�Ⱥ��
	set @count = ISNULL((select count(*) from communityGroup 
							where groupID<>@groupID and groupName = @groupName and isOff='0'),0)
	if (@count>0)
	begin
		set @Ret =1
		return
	end
	

	--�ж���Ⱥ���Ƿ��Ǹ�Ⱥ�ĳ�Ա
	set @count=(select count(*) from communityGroupMember where groupID = @groupID and userID=@managerID and isOff='0')	
	if (@count = 0)	--������
	begin
		set @Ret = 5
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--ȡ��Ⱥ����������
	declare @manager nvarchar(30)
	set @manager = isnull((select cName from userInfo where jobNumber = @managerID),'')
	
	set @updateTime = getdate()
	begin tran
		--��������
		update communityGroup
		set groupClass=@groupClass, groupName= @groupName,notes = @notes,
			managerid = @managerID, manager = @manager,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where groupID = @groupID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--������Ա���е�Ⱥ����Ϣ��
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
		
		--������Ա��
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

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '����Ⱥ��', '�û�' + @modiManName 
												+ '������Ⱥ��['+ @groupID +']�����ơ������ͣ���Ⱥ����')
GO


drop PROCEDURE delCommunityGroup
/*
	name:		delCommunityGroup
	function:	11.ɾ��ָ����Ⱥ��
				ע�⣺Ϊ�˱�����ʷ��¼����ò�Ҫʹ�ñ����ܣ�Ӧ��ʹ�ùرչ��ܣ�
	input: 
				@groupID varchar(12),			--Ⱥ��ID
				@delManID varchar(10) output,	--ɾ���ˣ������ǰȺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ⱥ�鲻���ڣ�2��Ҫɾ����Ⱥ����������������
							3:û��ɾ��Ⱥ��Ȩ��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 

*/
create PROCEDURE delCommunityGroup
	@groupID varchar(12),			--Ⱥ��ID
	@delManID varchar(10) output,	--ɾ���ˣ������ǰȺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ����Ⱥ���Ƿ����
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--ȡȺ����Ϣ��
	declare @groupName nvarchar(30)	--Ⱥ����
	declare @managerID varchar(10)	--Ⱥ������
	declare @thisLockMan varchar(10)--������
	select @groupName=groupName, @thisLockMan= isnull(lockManID,''), @managerID = managerID 
	from communityGroup 
	where groupID = @groupID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���Ȩ�ޣ�
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

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��Ⱥ��', '�û�' + @delManName
												+ 'ɾ����Ⱥ��['+ @groupName+ '(' + @groupID +')]��')

GO

drop PROCEDURE closeCommunityGroup
/*
	name:		closeCommunityGroup
	function:	12.�ر�Ⱥ��
	input: 
				@groupID varchar(12),			--Ⱥ��ID
				@stopManID varchar(10) output,	--�ر��ˣ������ǰȺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����Ⱥ�鲻���ڣ�2��Ҫ�رյ�Ⱥ����������������3����Ⱥ�鱾���ǹر�״̬��
							4:û�йر�Ⱥ��Ȩ��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 

*/
create PROCEDURE closeCommunityGroup
	@groupID varchar(12),			--Ⱥ��ID
	@stopManID varchar(10) output,	--�ر��ˣ������ǰȺ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ����Ⱥ���Ƿ����
	declare @count as int
	set @count=(select count(*) from communityGroup where groupID = @groupID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--ȡȺ����Ϣ��
	declare @groupName nvarchar(30)	--Ⱥ����
	declare @managerID varchar(10)	--Ⱥ������
	declare @thisLockMan varchar(10), @status char(1)	--��������Ⱥ״̬
	select  @groupName = groupName, @thisLockMan = isnull(lockManID,'') , @status = isOff, @managerID = managerID 
	from communityGroup where groupID = @groupID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���Ȩ�ޣ�
	if (@stopManID <> @managerID)
	begin
		set @Ret =4
		return
	end
	--���״̬��
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

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '�ر�Ⱥ��', '�û�' + @stopManName
												+ '�ر���Ⱥ��[' + @groupName + '(' + @groupID + ')]��')
GO

--��ѯ��䣺
select c.groupID,c.groupName, c.notes,
c.managerID, c.manager,
c.isOff, case c.isOff when '0' then '' when '1' then convert(varchar(10),c.offDate,120) end offDate,
c.createManID,c.createManName
from communityGroup c

--��ϸ���ѯ��䣺
select m.groupID,m.groupName, m.userType, m.userID,m.userName,
m.isOff, case m.isOff when '0' then '' when '1' then convert(varchar(10),m.offDate,120) end offDate,
convert(varchar(10),m.createTime,120) createTime
from communityGroupMember m


select groupID from communityGroupMember where isOff='0' and userID = '00000008'