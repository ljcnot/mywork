use PM100
/*
	��Ŀ����ϵͳ--��֯��������
	author:		¬έ
	CreateDate:	2015-10-20
	UpdateDate: 
*/
--1.��֯������
alter TABLE organization add	orgType smallint default(9)		--ʹ�õ�λ���ͣ��ɵ�10�Ŵ����ֵ䶨�塣�����ࣺ1����ѧ��2�����У�3��������4�����ڣ�9������
drop TABLE organization
CREATE TABLE organization
(
	orgID varchar(13) not null,			--�������������룬����1000�ź��뷢������������ʽ��O+8λ������+4λ��ˮ��
	orgType smallint default(9),		--ʹ�õ�λ���ͣ��ɵ�10�Ŵ����ֵ䶨�塣�����ࣺ1����ѧ��2�����У�3��������4�����ڣ�9������
	orgName nvarchar(30) null,			--��������
	abbOrgName nvarchar(6) null,		--�������
	inputCode varchar(5) null,			--����������
	superiorOrgID varchar(13) default(''),--�ϼ��������룺���û���ϼ�������''
	orgLevel smallint default(0),		--������������֯�������Ĳ㼶

	managerID varchar(10) null,			--�����˹���
	managerName nvarchar(30) null,		--����������

	e_mail varchar(30) null,			--E_mail��ַ
	tel varchar(30) null,				--��ϵ�绰
	tAddress nvarchar(100) null,		--��ַ
	web varchar(36) null,				--��ַ
	
	isOff int default(0),				--�Ƿ�ע����0->δע����1->��ע��
	setOffDate smalldatetime,			--ע������

	--����ά�����:
	createDate smalldatetime default(getdate()),	--��������
	createrID varchar(10) null,			--������ID
	creater nvarchar(30) null,			--����������
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���

 CONSTRAINT [PK_organization] PRIMARY KEY CLUSTERED 
(
	[orgID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
CREATE NONCLUSTERED INDEX [IX_organization] ON [dbo].[organization] 
(
	[orgName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_organization_1] ON [dbo].[organization] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_organization_2] ON [dbo].[organization] 
(
	[superiorOrgID] ASC,
	[orgID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_organization_3] ON [dbo].[organization] 
(
	[superiorOrgID] ASC,
	[orgName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_organization_4] ON [dbo].[organization] 
(
	[orgLevel] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select * from organization



drop PROCEDURE fastAddOrganization
/*
	name:		fastAddOrganization
	function:	1.������ӻ�����Ҫ��Ϣ
	input: 
				@orgName nvarchar(30),		--��������
				--������Ϣ��
				@superiorOrgID varchar(13),	--�ϼ��������룺���û���ϼ�������''
				--����ά�����:
				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output,		--�����ɹ���ʶ��
							0:�ɹ���1:ͬ����������������2:�ϼ����������ڣ�9:δ֪����
				@orgID varchar(13)output	--�������룬����1000�ź��뷢��������
	author:		¬έ
	CreateDate:	2015-10-21
	UpdateDate:
*/
create PROCEDURE fastAddOrganization
	@orgName nvarchar(30),		--��������
	--������Ϣ��
	@superiorOrgID varchar(13),	--�ϼ��������룺���û���ϼ�������''
	--����ά�����:
	@createManID varchar(10),	--�����˹���
	@Ret int output,			--�����ɹ���ʶ
	@orgID varchar(13)output	--�������룬����1000�ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���������
	declare @count as int
	set @count = (select count(*) from organization where superiorOrgID = @superiorOrgID and orgName = @orgName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end
	
	--��ȡ�����룺
	declare @inputCode varchar(5)	--����������
	set @inputCode = dbo.getChinaPYCode(@orgName)
	--��ȡ�����Ĳ㼶��
	declare @orgLevel smallint		--������������֯�������Ĳ㼶
	if (@superiorOrgID='')
		set @orgLevel = 0
	else
	begin
		set @orgLevel = (select orgLevel from organization where orgID = @superiorOrgID)
		if (@orgLevel is null)
		begin 
			set @Ret = 2
			return
		end
		set @orgLevel = @orgLevel + 1
	end
	--ʹ�ú��뷢���������������룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 1000, 1, @curNumber output
	set @orgID = @curNumber

	--ȡ����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select cName from userInfo where userID = @createManID),'')

	declare @createTime smalldatetime
	set @createTime = getdate()
	insert organization (orgID, orgName,inputCode,
				--������Ϣ��
				superiorOrgID, orgLevel,
				--����ά�����:
				createDate, createrID, creater,modiManID, modiManName, modiTime)
	values(@orgID, @orgName, @inputCode,
				--������Ϣ��
				@superiorOrgID, @orgLevel,
				--����ά�����:
				@createTime, @createManID, @createManName, @createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 
								'��Ҫע�����','ϵͳ����' + @createManName + 
								'��Ҫ������˻���[' + @orgName + ']�ļ�Ҫ��Ϣ��')
GO
--���ԣ�
declare	@Ret int, @orgID varchar(13)
exec dbo.fastAddOrganization '������̲�','O201510001', 'U201510003',@Ret output, @orgID output
select @Ret, @orgID
select * from organization
select * from workNote

drop PROCEDURE addOrganization
/*
	name:		addOrganization
	function:	1.1��ӻ���������Ϣ
	input: 
				--������Ϣ��
				@superiorOrgID varchar(13),	--�ϼ��������룺���û���ϼ�������''

				@orgType smallint,			--�������ͣ��ɵ�10�Ŵ����ֵ䶨�塣�����ࣺ1����ѧ��2�����У�3��������4�����ڣ�9������
				@orgName nvarchar(30),		--��������
				@abbOrgName nvarchar(6),	--�������
				@inputCode varchar(5),		--���������룬Ϊ''���Զ����塣�Զ�����ԭ�򣺼�Ʋ�Ϊ�գ���ȡ��Ƶ�ƴ���룻����ȡ���Ƶ�ƴ����
				@e_mail varchar(30),		--E_mail��ַ
				@tel varchar(30),			--��ϵ�绰
				@tAddress nvarchar(100),	--��ַ
				@web varchar(36),			--��ַ

				--ά����:
				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output,		--�����ɹ���ʶ��
											0:�ɹ���1:ͬ����������������2:�ϼ����������ڣ�9:δ֪����
				@orgID varchar(13)output	--�������룬����1000�ź��뷢��������
	author:		¬έ
	CreateDate:	2015-11-22
	UpdateDate:
*/
create PROCEDURE addOrganization
	--������Ϣ��
	@superiorOrgID varchar(13),	--�ϼ��������룺���û���ϼ�������''
	
	@orgType smallint,			--ʹ�õ�λ���ͣ��ɵ�10�Ŵ����ֵ䶨�塣�����ࣺ1����ѧ��2�����У�3��������4�����ڣ�9������
	@orgName nvarchar(30),		--��������
	@abbOrgName nvarchar(6),	--�������
	@inputCode varchar(5),		--���������룬Ϊ''���Զ����塣�Զ�����ԭ�򣺼�Ʋ�Ϊ�գ���ȡ��Ƶ�ƴ���룻����ȡ���Ƶ�ƴ����
	@e_mail varchar(30),		--E_mail��ַ
	@tel varchar(30),			--��ϵ�绰
	@tAddress nvarchar(100),	--��ַ
	@web varchar(36),			--��ַ

	--ά����:
	@createManID varchar(10),	--�����˹���
	@Ret		int output,		--�����ɹ���ʶ
	@orgID varchar(13)output	--�������룬����1000�ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�����ͬ���������Ƿ���������
	declare @count int
	set @count = (select count(*) from organization where superiorOrgID = @superiorOrgID and orgName = @orgName and orgID <> @orgID)
	if @count > 0
	begin
		set @Ret = 1
		return
	end
	
	--��ȡ�����Ĳ㼶��
	declare @orgLevel smallint		--������������֯�������Ĳ㼶
	if (@superiorOrgID='')
		set @orgLevel = 0
	else
	begin
		set @orgLevel = (select orgLevel from organization where orgID = @superiorOrgID)
		if (@orgLevel is null)
		begin 
			set @Ret = 2
			return
		end
		set @orgLevel = @orgLevel + 1
	end

	--���������Ϊ�գ�����������
	if (@inputCode is null or @inputCode='')
	begin
		if (@abbOrgName is not null and @abbOrgName<>'')
			set @inputCode = dbo.getChinaPYCode(@abbOrgName)
		else
			set @inputCode = dbo.getChinaPYCode(@orgName)
	end
	
	--ʹ�ú��뷢���������������룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 1000, 1, @curNumber output
	set @orgID = @curNumber

	--ȡ����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select cName from userInfo where userID = @createManID),'')

	declare @createTime smalldatetime
	set @createTime = getdate()
	insert organization (orgID, orgType, orgName, abbOrgName, inputCode,
				--������Ϣ��
				superiorOrgID, orgLevel,
				--��ϵ��ʽ��
				e_mail, tel, tAddress, web,
				--����ά�����:
				createDate, createrID, creater,modiManID, modiManName, modiTime)
	values(@orgID, @orgType, @orgName, @abbOrgName, @inputCode,
				--������Ϣ��
				@superiorOrgID, @orgLevel,
				--��ϵ��ʽ��
				@e_mail, @tel, @tAddress, @web,
				--����ά�����:
				@createTime, @createManID, @createManName, @createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, 
								'ע�����','ϵͳ����' + @createManName + 
								'��Ҫ������˻���[' + @orgName + ']�Ļ�����Ϣ��')
GO

drop PROCEDURE queryOrganizationLocMan
/*
	name:		queryOrganizationLocMan
	function:	2.��ѯָ�������Ƿ��������ڱ༭
	input: 
				@orgID varchar(13),			--��������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ļ���������
				@lockManID varchar(10) output--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2015-11-22
	UpdateDate: 
*/
create PROCEDURE queryOrganizationLocMan
	@orgID varchar(13),			--��������
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from Organization where orgID = @orgID),'')
	set @Ret = 0
GO


drop PROCEDURE lockOrganization4Edit
/*
	name:		lockOrganization4Edit
	function:	3.���������༭������༭��ͻ
	input: 
				@orgID varchar(13),				--��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�����Ļ��������ڣ�2:Ҫ�����Ļ������ڱ����˱༭��
												9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-22
	UpdateDate: 
*/
create PROCEDURE lockOrganization4Edit
	@orgID varchar(13),				--��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from Organization where orgID = @orgID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from Organization where orgID = @orgID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update Organization
	set lockManID = @lockManID 
	where orgID = @orgID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '���������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������Ϊ��[' + @orgID + ']�Ļ���Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockOrganizationEditor
/*
	name:		unlockOrganizationEditor
	function:	4.�ͷŻ����༭��
				ע�⣺�����̲��������Ƿ���ڣ�
	input: 
				@orgID varchar(13),				--��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-22
	UpdateDate: 
*/
create PROCEDURE unlockOrganizationEditor
	@orgID varchar(13),				--��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from Organization where orgID = @orgID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update Organization set lockManID = '' where orgID = @orgID
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
	values(@lockManID, @lockManName, getdate(), '�ͷŻ����༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˱��Ϊ��[' + @orgID + ']�Ļ����ı༭����')
GO


drop PROCEDURE checkOrgCode
/*
	name:		checkOrgCode
	function:	5.���ָ���Ļ��������Ƿ��Ѿ�����
				˵��������һ������Ľӿڣ�Ӧ������Ҫ���ж������Ļ���
	input: 
				@superiorOrgID varchar(13),	--�ϼ��������룬Ϊ�մ���Ϊ��������
				@orgID varchar(13),			--��������
	output: 
				@Ret		int output		--�����ɹ���ʶ
											0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-22
	UpdateDate: 
*/
create PROCEDURE checkOrgCode
	@superiorOrgID varchar(13),	--�ϼ���������
	@orgID varchar(13),			--��������
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�����ͬ���������Ƿ����ظ����룺
	declare @count int
	set @count = (select count(*) from organization where superiorOrgID = @superiorOrgID and orgID = @orgID)
	set @Ret = @count
GO

drop PROCEDURE checkOrgName
/*
	name:		checkOrgName
	function:	6.���ָ���Ļ��������Ƿ��Ѿ�����
	input: 
				@superiorOrgID varchar(13),	--�ϼ��������룬Ϊ�մ���Ϊ��������
				@orgName nvarchar(30),		--��������	
				@excludedOrgID varchar(13),	--����Ļ������룬''��ʾû�г���Ļ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
											0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-22
	UpdateDate: 
*/
create PROCEDURE checkOrgName
	@superiorOrgID varchar(13),	--�ϼ��������룬Ϊ�մ���Ϊ��������
	@orgName nvarchar(30),		--��������	
	@excludedOrgID varchar(13),	--����Ļ������룬''��ʾû�г���Ļ���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���������Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from Organization 
					where superiorOrgID = @superiorOrgID and orgName = @orgName and orgID<>@excludedOrgID)
	set @Ret = @count
GO

drop PROCEDURE checkOrgAbbName
/*
	name:		checkOrgAbbName
	function:	7.���ָ���Ļ�������Ƿ��Ѿ�����
	input: 
				@superiorOrgID varchar(13),	--�ϼ��������룬Ϊ�մ���Ϊ��������
				@abbOrgName nvarchar(6),	--�������
				@excludedOrgID varchar(13),	--����Ļ������룬''��ʾû�г���Ļ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-22
	UpdateDate: 
*/
create PROCEDURE checkOrgAbbName
	@superiorOrgID varchar(13),	--�ϼ��������룬Ϊ�մ���Ϊ��������
	@abbOrgName nvarchar(6),	--�������
	@excludedOrgID varchar(13),	--����Ļ������룬''��ʾû�г���Ļ���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���������Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from organization 
						where superiorOrgID = @superiorOrgID and abbOrgName = @abbOrgName and orgID<>@excludedOrgID)
	set @Ret = @count
GO

drop PROCEDURE delOrganization
/*
	name:		delOrganization
	function:	8.ɾ��ָ���Ļ���
	input: 
				@orgID varchar(13),				--��������
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���1��ָ���Ļ��������ڣ�2��Ҫɾ���Ļ�����������������
												3�������¼�������9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-22
	UpdateDate: 

*/
create PROCEDURE delOrganization
	@orgID varchar(13),				--��������
	@delManID varchar(10) output,	--ɾ���ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from organization where orgID = @orgID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from organization where orgID = @orgID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--����Ƿ����¼�������
	set @count=(select count(*) from organization where superiorOrgID = @orgID)
	if (@count > 0)
	begin
		set @Ret = 3
		return
	end
	
	delete organization where orgID = @orgID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ���˴���Ϊ��[' + @orgID + ']�Ļ�����')
GO
--���ԣ�
select * from organization

declare	@Ret int, @orgID varchar(13)
exec dbo.fastAddOrganization '�����û���','O201511004', 'U201510003',@Ret output, @orgID output
select @Ret, @orgID

declare	@Ret int, @delManID varchar(10)
set @delManID ='U201510003'
exec dbo.delOrganization 'O201511005',@delManID output, @Ret output
select @Ret, @delManID

select * from organization
select * from workNote
	
drop PROCEDURE updateOrganization
/*
	name:		updateOrganization
	function:	9.���»���������Ϣ
	input: 
				@orgID varchar(13),			--�������루��λ�ֶΣ��Ǹ����ֶΣ�
				@orgType smallint,			--ʹ�õ�λ���ͣ��ɵ�10�Ŵ����ֵ䶨�塣�����ࣺ1����ѧ��2�����У�3��������4�����ڣ�9������
				@orgName nvarchar(30),		--��������
				@abbOrgName nvarchar(6),	--�������
				@inputCode varchar(5),		--���������룬Ϊ''���Զ����塣�Զ�����ԭ�򣺼�Ʋ�Ϊ�գ���ȡ��Ƶ�ƴ���룻����ȡ���Ƶ�ƴ����
				@e_mail varchar(30),		--E_mail��ַ
				@tel varchar(30),			--��ϵ�绰
				@tAddress nvarchar(100),	--��ַ
				@web varchar(36),			--��ַ

				--ά����:
				@modiManID varchar(10) output,--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
											0:�ɹ���1��Ҫ���µĻ�����������������
											2:��ͬ�����������ظ������ƣ�
											3:��ͬ�����������ظ��ļ�ƣ�9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-22
	UpdateDate:
*/
create PROCEDURE updateOrganization
	@orgID varchar(13),			--�������루��λ�ֶΣ��Ǹ����ֶΣ�
	@orgType smallint,			--ʹ�õ�λ���ͣ��ɵ�10�Ŵ����ֵ䶨�塣�����ࣺ1����ѧ��2�����У�3��������4�����ڣ�9������
	@orgName nvarchar(30),		--��������
	@abbOrgName nvarchar(6),	--�������
	@inputCode varchar(5),		--���������룬Ϊ''���Զ����塣�Զ�����ԭ�򣺼�Ʋ�Ϊ�գ���ȡ��Ƶ�ƴ���룻����ȡ���Ƶ�ƴ����
	@e_mail varchar(30),		--E_mail��ַ
	@tel varchar(30),			--��ϵ�绰
	@tAddress nvarchar(100),	--��ַ
	@web varchar(36),			--��ַ

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from organization where orgID = @orgID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--�����ͬ���������Ƿ���������
	declare @count int, @superiorOrgID varchar(13) --�ϼ���������
	set @superiorOrgID =(select superiorOrgID from organization where orgID = @orgID)
	set @count = (select count(*) from organization where superiorOrgID = @superiorOrgID and orgName = @orgName and orgID <> @orgID)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--�����ͬ���������Ƿ����ظ��ļ�ƣ�
	set @count = (select count(*) from organization where superiorOrgID = @superiorOrgID and abbOrgName = @abbOrgName and orgID <> @orgID)
	if @count > 0
	begin
		set @Ret = 3
		return
	end

	--���������Ϊ�գ�����������
	if (@inputCode is null or @inputCode='')
	begin
		if (@abbOrgName is not null and @abbOrgName<>'')
			set @inputCode = dbo.getChinaPYCode(@abbOrgName)
		else
			set @inputCode = dbo.getChinaPYCode(@orgName)
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @updateTime smalldatetime
	set @updateTime = getdate()
	update organization
	set orgType = @orgType,orgName =@orgName ,abbOrgName = @abbOrgName,inputCode = @inputCode,
		e_mail = @e_mail,tel = @tel,tAddress = @tAddress,@web = @web,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where orgID = @orgID
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���»���������Ϣ', '�û�' + @modiManName 
												+ '�����˴���Ϊ��[' + @orgID + ']�Ļ����Ļ�����Ϣ��')
GO


drop PROCEDURE updateOrgID
/*
	name:		updateOrgID
	function:	10.���»�������
				˵��������һ������Ľӿڣ�Ӧ������Ҫ���ж������Ļ���
	input: 
				@orgID varchar(13),			--�������루��λ�ֶΣ��Ǹ����ֶΣ�
				@newOrgID varchar(13),		--�µĻ�������

				--ά����:
				@modiManID varchar(10) output,--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
											0:�ɹ���1��Ҫ���µĻ�����������������
											2:��ͬ�����������ظ��Ĵ��룬9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-22
	UpdateDate:
*/
create PROCEDURE updateOrgID
	@orgID varchar(13),			--�������루��λ�ֶΣ��Ǹ����ֶΣ�
	@newOrgID varchar(13),		--�µĻ�������

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from organization where orgID = @orgID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--�����ͬ���������Ƿ����ظ����룺
	declare @count int, @superiorOrgID varchar(13) --�ϼ���������
	set @superiorOrgID =(select superiorOrgID from organization where orgID = @orgID)
	set @count = (select count(*) from organization where superiorOrgID = @superiorOrgID and orgID = @newOrgID and orgID <> @orgID)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @updateTime smalldatetime
	set @updateTime = getdate()
	update organization
	set orgID = @newOrgID,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where orgID = @orgID
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���Ļ�������', '�û�' + @modiManName 
												+ '�����˴���Ϊ��[' + @orgID + ']�Ļ������룬�ĳ���['+@newOrgID+']��')
GO


drop PROCEDURE updateOrgManager
/*
	name:		updateOrgManager
	function:	11.���»���������
	input: 
				@orgID varchar(13),			--�������루��λ�ֶΣ��Ǹ����ֶΣ�
				@managerID varchar(10),		--�����˹���

				--ά����:
				@modiManID varchar(10) output,--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
											0:�ɹ���1��Ҫ���µĻ�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-22
	UpdateDate:
*/
create PROCEDURE updateOrgManager
	@orgID varchar(13),			--�������루��λ�ֶΣ��Ǹ����ֶΣ�
	@managerID varchar(10),		--�����˹���

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from organization where orgID = @orgID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--ȡ�����ˡ�ά���˵�������
	declare @managerName nvarchar(30),@modiManName nvarchar(30)
	set @managerName = isnull((select cName from userInfo where userID = @managerID),'')
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	declare @updateTime smalldatetime
	set @updateTime = getdate()
	update organization
	set managerID = @managerID, managerName = @managerName,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where orgID = @orgID
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���Ļ���������', '�û�' + @modiManName 
					+ '�����˴���Ϊ��[' + @orgID + ']�Ļ��������ˣ��¸�����Ϊ['+@managerName+'��'+@managerID+'��]��')
GO

drop PROCEDURE setOrganizationOff
/*
	name:		setOrganizationOff
	function:	12.ͣ��ָ���Ļ���
	input: 
				@orgID varchar(13),				--��������
				@stopManID varchar(10) output,	--ͣ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ��������ڣ�2��Ҫͣ�õĻ�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-22
	UpdateDate: 

*/
create PROCEDURE setOrganizationOff
	@orgID varchar(13),				--��������
	@stopManID varchar(10) output,	--ͣ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from organization where orgID = @orgID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from organization where orgID = @orgID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update organization
	set isOff = '1', setOffDate = @stopTime
	where orgID = @orgID
	set @Ret = 0

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, 'ͣ�û���', '�û�' + @stopManName
												+ 'ͣ���˴���Ϊ��[' + @orgID + ']�ĵ�λ��')
GO

drop PROCEDURE setOrganizationActive
/*
	name:		setOrganizationActive
	function:	13.����ָ���Ļ���
	input: 
				@orgID varchar(13),				--��������
				@activeManID varchar(10) output,--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
											0:�ɹ���1��ָ���Ļ��������ڣ�2��Ҫ���õĻ�����������������
											3���û��������Ǽ���״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2015-11-22
	UpdateDate: 

*/
create PROCEDURE setOrganizationActive
	@orgID varchar(13),				--��������
	@activeManID varchar(10) output,--�����ˣ������ǰʹ�õ�λ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ļ����Ƿ����
	declare @count as int
	set @count=(select count(*) from organization where orgID = @orgID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10),@status int
	select @thisLockMan = isnull(lockManID,''), @status = isOff  
	from organization 
	where orgID = @orgID
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--���״̬��
	if (@status = 0)
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update organization
	set isOff = '0', setOffDate = null
	where orgID = @orgID
	set @Ret = 0

	--ȡά���˵�������
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '�������û���', '�û�' + @activeManName
												+ '���������˴���Ϊ��[' + @orgID + ']�Ļ�����')
GO
