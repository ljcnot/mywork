use hustOA
/*
	OA������Ϣϵͳ-���������
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

--1.������һ����
drop TABLE discussGroup
CREATE TABLE discussGroup(
	discussID char(12) not null,		--������������ID,�ɵ�20000�ź��뷢��������
										--8λ���ڴ���+4λ��ˮ��

	discussName nvarchar(30) not null,	--����������,
	notes nvarchar(300) null,			--����������

	--ע�⣺�ر��˵������齫���������Ʋ��أ���ϵͳ���ṩ�������ù��ܣ�
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
 CONSTRAINT [PK_discussGroup] PRIMARY KEY CLUSTERED 
(
	[discussID] DESC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--������
--����������������
CREATE NONCLUSTERED INDEX [IX_discussGroup] ON [dbo].[discussGroup] 
(
	[discussName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.��������Ա������
drop table discussGroupMember
CREATE TABLE discussGroupMember(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL,
	discussID char(12) not null,		--�����������ID
	discussName nvarchar(30) not null,	--������ƣ�����������,
	userID varchar(10) not null,		--��Ա����
	userName nvarchar(30) not null,		--������ƣ���Ա����
	
	--�ٴν�����Ƿ�Ӧ�ü���Ƿ����ٴν��룺
	isOff char(1) default('0') null,	--�Ƿ��˳�:��0������δ�˳�����1�������˳�
	offDate smalldatetime null,			--�˳�����
	
	createTime smalldatetime null,		--����ʱ��
CONSTRAINT [PK_discussGroupMember] PRIMARY KEY CLUSTERED 
(
	[discussID]ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[discussGroupMember] WITH CHECK ADD CONSTRAINT [FK_discussGroupMember_discussGroup] FOREIGN KEY([discussID])
REFERENCES [dbo].[discussGroup] ([discussID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[discussGroupMember] CHECK CONSTRAINT [FK_discussGroupMember_discussGroup]
GO

--������
--��Ա����������
CREATE NONCLUSTERED INDEX [IX_discussGroupMember] ON [dbo].[discussGroupMember] 
(
	[userID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



drop PROCEDURE checkDiscussGroupName
/*
	name:		checkDiscussGroupName
	function:	0.1.���ָ�����������Ƿ��Ѿ�����
	input: 
				@discussName nvarchar(30),	--����������
				@discussID varchar(12),		--������ID:���½����ʱ�����ֶ�����Ϊ""
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE checkDiscussGroupName
	@discussName nvarchar(30),	--����������
	@discussID varchar(12),		--������ID:���½����ʱ�����ֶ�����Ϊ""
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--��������������Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from discussGroup where discussName = @discussName and isOff='0' and discussID<>@discussID)
	set @Ret = @count
GO

drop PROCEDURE createDiscussGroup
/*
	name:		createDiscussGroup
	function:	1.����������
				ע�⣺���洢���̲������༭��
	input: 
				@discussName nvarchar(30),	--����������,
				@notes nvarchar(300),		--����������
				@members xml,				--ʹ��xml�洢����Ա������N'<root>
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
							0:�ɹ���1�������������Ѿ���ռ�ã�9��δ֪����
				@createTime smalldatetime output,
				@discussID varchar(12) output--������������ID,�ɵ�20000�ź��뷢��������
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE createDiscussGroup
	@discussName nvarchar(30),	--����������,
	@notes nvarchar(300),		--����������
	@members xml,				--ʹ��xml�洢����Ա������N'<root>
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
	@discussID varchar(12) output--������������ID,�ɵ�20000�ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--��������Ƿ�Ψһ��
	declare @count int
	set @count = ISNULL((select count(*) from discussGroup where discussName = @discussName and isOff='0'),0)
	if (@count>0)
	begin
		set @Ret =1
		return
	end
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 20000, 1, @curNumber output
	set @discussID = @curNumber

	--ȡά���˵�������
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
		--���봴���˵���Ա��
		insert discussGroupMember(discussID, discussName, userID, userName, createTime)
		values(@discussID, @discussName, @createManID, @createManName, @createTime)
		--������Ա��
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
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '���������', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ�������������[' + @discussName + '('+@discussID+')]��')
GO
--���ԣ�
declare	@Ret		int
declare	@createTime smalldatetime 
declare	@discussID varchar(12)
exec dbo.createDiscussGroup '����������', '����һ��������������',
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
	'00000009',@Ret	output,@createTime output,@discussID output
select @Ret, @discussID, @Ret
select * from discussGroup
select * from discussGroupMember

drop PROCEDURE queryDiscussGroupLocMan
/*
	name:		queryDiscussGroupLocMan
	function:	2.��ѯָ���������Ƿ��������ڱ༭
	input: 
				@discussID varchar(12),		--������ID
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���������鲻����
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE queryDiscussGroupLocMan
	@discussID varchar(12),		--������ID
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from discussGroup where discussID = @discussID),'')
	set @Ret = 0
GO


drop PROCEDURE lockDiscussGroup4Edit
/*
	name:		lockDiscussGroup4Edit
	function:	3.����������༭������༭��ͻ
	input: 
				@discussID varchar(12),			--������ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����������鲻���ڣ�2:Ҫ���������������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE lockDiscussGroup4Edit
	@discussID varchar(12),			--������ID
	@lockManID varchar(10) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������������Ƿ����
	declare @count as int
	set @count=(select count(*) from discussGroup where discussID = @discussID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ��������������['+ @discussID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockDiscussGroupEditor
/*
	name:		unlockDiscussGroupEditor
	function:	4.�ͷ�������༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@discussID varchar(12),			--������ID
				@lockManID varchar(10) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE unlockDiscussGroupEditor
	@discussID varchar(12),			--������ID
	@lockManID varchar(10) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
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

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷ�������༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ���������['+ @discussID +']�ı༭����')
GO

drop PROCEDURE addDiscussGroupMember
/*
	name:		addDiscussGroupMember
	function:	5.�����Ա�����һ����Ա��
	input: 
				@discussID varchar(12),		--������ID
				@userID varchar(10),		--Ҫ��ӵ���Ա����
				@addManID varchar(10),		--�����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���������鲻���ڣ�2.���û��Ѿ��Ǹ�������ĳ�Ա��9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE addDiscussGroupMember
	@discussID varchar(12),		--������ID
	@userID varchar(10),		--Ҫ��ӵ���Ա����
	@addManID varchar(10),		--�����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������������Ƿ����
	declare @count as int
	set @count=(select count(*) from discussGroup where discussID = @discussID and isOff='0')	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	--�жϸ��û��Ƿ��Ǹ���ĳ�Ա
	declare @status char(1)
	set @status = '0'
	set @count=(select count(*) from discussGroupMember where discussID = @discussID and userID=@userID)	
	if (@count > 0)	--����
	begin
		select  @status = isOff
		from discussGroupMember 
		where discussID = @discussID and userID=@userID
		--���״̬��
		if (@status = '0')
		begin
			set @Ret = 2
			return
		end
	end

	--ȡ���������ƣ�
	declare @discussName nvarchar(30)
	set @discussName = ISNULL((select discussName from discussGroup where discussID = @discussID),'')
	
	--ȡ��Ա��������
	declare @userName nvarchar(30)
	set @userName = isnull((select cName from userInfo where jobNumber = @userID),'')
	--ȡ����˵�������
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
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@addManID, @addManName, @createTime, '����������', '�û�' + @addManName
												+ '���û�['+@userName+']������������['+ @discussName + '('+@discussID +')]��')
GO
--���ԣ�
declare @Ret int
exec dbo.addDiscussGroupMember '201304130003', 'G201300001', @Ret output
select @Ret
select * from discussGroupMember

select * from userInfo

drop PROCEDURE offDiscussGroupMember
/*
	name:		offDiscussGroupMember
	function:	6.��Ա�˳�
				ע�⣺�����̵�ȫ����Ա���˳���ʱ���Զ��ر�������
	input: 
				@discussID varchar(12),		--������ID
				@userID varchar(10),		--Ҫ�˳�����Ա����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���������鲻���ڣ�2.���û����Ǹ�������ĳ�Ա��9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE offDiscussGroupMember
	@discussID varchar(12),		--������ID
	@userID varchar(10),		--Ҫ�˳�����Ա����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�˳����������Ƿ����
	declare @count as int
	set @count=(select count(*) from discussGroup where discussID = @discussID and isOff='0')	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--�жϸ��û��Ƿ��Ǹ���ĳ�Ա
	declare @status char(1)
	set @status = '0'
	set @count=(select count(*) from discussGroupMember where discussID = @discussID and userID=@userID and isOff='0')	
	if (@count = 0)	--������
	begin
		set @Ret = 2
		return
	end

	--ȡ���������ƣ�
	declare @discussName nvarchar(30)
	set @discussName = ISNULL((select discussName from discussGroup where discussID = @discussID),'')
	
	--ȡ��Ա��������
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
	
		--����Ƿ������г�Ա���˳�����������Զ��ر������飺
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
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@userID, @userName, @exitTime, '�˳�������', '�û�' + @userName
												+ '�˳���������['+ @discussName + '('+@discussID +')]��')
GO

drop PROCEDURE updateDiscussGroup
/*
	name:		updateDiscussGroup
	function:	7.����������
	input: 
				@discussID varchar(12),		--������ID
				@discussName nvarchar(30),	--����������,
				@notes nvarchar(300),		--����������

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���������鲻���ڣ�2��Ҫ���µ���������������������3:Ҫ���µ������Ѿ���ռ�ã�
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 
*/
create PROCEDURE updateDiscussGroup
	@discussID varchar(12),		--������ID
	@discussName nvarchar(30),	--����������,
	@notes nvarchar(300),		--����������

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from discussGroup where discussID = @discussID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from discussGroup where discussID = @discussID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��������Ƿ�Ψһ�������رյ�������
	set @count = ISNULL((select count(*) from discussGroup 
							where discussID<>@discussID and discussName = @discussName and isOff='0'),0)
	if (@count>0)
	begin
		set @Ret =1
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		--��������
		update discussGroup
		set discussName= @discussName,
			notes = @notes,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where discussID = @discussID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--������Ա��
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

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '����������', '�û�' + @modiManName 
												+ '������������['+ @discussID +']�����ƺͣ���������')
GO


drop PROCEDURE delDiscussGroup
/*
	name:		delDiscussGroup
	function:	8.ɾ��ָ����������
				ע�⣺Ϊ�˱�����ʷ��¼����ò�Ҫʹ�ñ����ܣ�Ӧ��ʹ�ùرչ��ܣ�
	input: 
				@discussID varchar(12),			--������ID
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���������鲻���ڣ�2��Ҫɾ������������������������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 

*/
create PROCEDURE delDiscussGroup
	@discussID varchar(12),			--������ID
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from discussGroup where discussID = @discussID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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

	--ȡ���������ƣ�
	declare @discussName nvarchar(30)
	set @discussName = ISNULL((select discussName from discussGroup where discussID = @discussID),'')
	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��������', '�û�' + @delManName
												+ 'ɾ����������['+ @discussName+ '(' + @discussID +')]��')

GO

drop PROCEDURE closeDiscussGroup
/*
	name:		closeDiscussGroup
	function:	9.�ر�������
	input: 
				@discussID varchar(12),			--������ID
				@stopManID varchar(10) output,	--�ر��ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���������鲻���ڣ�2��Ҫ�رյ���������������������3���������鱾���ǹر�״̬��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-4-13
	UpdateDate: 

*/
create PROCEDURE closeDiscussGroup
	@discussID varchar(12),			--������ID
	@stopManID varchar(10) output,	--�ر��ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from discussGroup where discussID = @discussID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
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
	
	--���״̬��
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

	--ȡ���������ƣ�
	declare @discussName nvarchar(30)
	set @discussName = ISNULL((select discussName from discussGroup where discussID = @discussID),'')
	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '�ر�������', '�û�' + @stopManName
												+ '�ر���������[' + @discussName + '(' + @discussID + ')]��')
GO

--��ѯ��䣺
select d.discussID,d.discussName, d.notes,
d.isOff, case d.isOff when '0' then '' when '1' then convert(varchar(10),d.offDate,120) end offDate,
d.createManID,d.createManName
from discussGroup d

--��ϸ���ѯ��䣺
select m.discussID,m.discussName, m.userID,m.userName,
m.isOff, case m.isOff when '0' then '' when '1' then convert(varchar(10),m.offDate,120) end offDate,
convert(varchar(10),m.createTime,120) createTime
from discussGroupMember m


select discussID from discussGroupMember where isOff='0' and userID = '00000008'

select * from userInfo
delete  from userInfo where cName = 'abc' and jobNumber<='G201300226'
