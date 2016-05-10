use PM100
/*
	��Ŀ����ϵͳ--��Ŀ�Ǽ�
	author:		¬έ
	CreateDate:	2015-10-20
	UpdateDate: 
*/
--1.��Ŀ�ǼǱ�
drop TABLE project
CREATE TABLE project
(
	projectID varchar(13) not null,		--��������Ŀ��ţ�����1100�ź��뷢��������,��ʽ��P+8λ������+4λ��ˮ��
	projectName	nvarchar(30) not null,	--��Ŀ����
	inputCode varchar(5) null,			--������
	customerID varchar(13) not null,	--ί�е�λID���ɿͻ�����ϵͳά��
	customerName nvarchar(30) not null,	--ί�е�λ���ƣ��������
	contractAmount numeric(12,2) null,	--��ͬ���
	amountType smallint default(1),		--��ͬ�������:0->�����1->��ʽ��ͬ���
	netAmount numeric(12,2) null,		--����ͬ���
	signDate smalldatetime null,		--��ͬǩ������
	signerID varchar(10) null,			--ǩ����ID�������¹���ϵͳά��
	signer nvarchar(30) null,			--ǩ���ˣ��������
	startDate smalldatetime null,		--�������ڣ��н��ȹ���ϵͳ���ݹ���
	expectedDuration int null,			--Ԥ�㹤�ڣ���λ����
	completeDate smalldatetime null,	--ʵ���깤����
	managerID varchar(10) null,			--������ID�������¹���ϵͳά��
	manager nvarchar(30) null,			--�����ˣ��������
	progress numeric(6,2) default(0),	--���ȣ��н��ȹ���ϵͳ���ܹ���
	pStatus	nvarchar(10) null,			--״̬˵��:�ɵ�2000�Ŵ����ֵ䶨��,�������ֹ����룬���Ա���״̬����
	collectedAmount numeric(12,2) default(0),	--���տ�ɲ����տ�ϵͳ���ܹ���
	--uncollectedAmount numeric(12,2),	--β������ֶ�
	remarks	nvarchar(60) null,			--��ע
	--collectedDetail xml,				--�ؿ����
	projectDesc	nvarchar(1000) null,	--��Ŀ����

	--����ά�����:
	createDate smalldatetime default(getdate()),	--��������
	createrID varchar(10) null,			--������ID
	creater nvarchar(30) null,			--����������
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���

 CONSTRAINT [PK_project] PRIMARY KEY CLUSTERED 
(
	[projectID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
CREATE NONCLUSTERED INDEX [IX_project] ON [dbo].[project] 
(
	[projectName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_project_1] ON [dbo].[project] 
(
	[customerID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_project_2] ON [dbo].[project] 
(
	[signerID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_project_3] ON [dbo].[project] 
(
	[managerID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select * from project
select case amountType when 0 then '����' when 1 then '' end from project
drop PROCEDURE addProject
/*
	name:		addProject
	function:	1.�����Ŀ
	input: 
				@projectName nvarchar(30),		--��Ŀ����
				@customerID varchar(13),		--ί�е�λID���ɿͻ�����ϵͳά��
				@contractAmount numeric(12,2),	--��ͬ���
				@amountType smallint,			--��ͬ�������:0->�����1->��ʽ��ͬ���
				@netAmount numeric(12,2),		--����ͬ��Ϊ�ջ�'0'��ʾ����ͬ��ͬ���
				@strSignDate varchar(19),		--��ͬǩ������:����YYYY-MM-DD hh:mm:ss��ʽ����
				@signerID varchar(10),			--ǩ����ID�������¹���ϵͳά��
				@managerID varchar(10),			--������ID�������¹���ϵͳά��
				@pStatus nvarchar(10),			--״̬˵��:�ɵ�2000�Ŵ����ֵ䶨��,�������ֹ����룬���Ա���״̬����
				@remarks nvarchar(60),			--��ע
				@projectDesc nvarchar(1000),	--��Ŀ����

				--����ά�����:
				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output,			--�ɹ���ʶ
												0:�ɹ���1:����Ŀ�Ѿ���ע����ˣ�2:û������ί�е�λ��3:��ί�е�λ�����ڣ�9:δ֪����
				@projectID varchar(13) output	--��Ŀ��ţ�����1100�ź��뷢��������
	author:		¬έ
	CreateDate:	2015-10-21
	UpdateDate:
*/
create PROCEDURE addProject
	@projectName nvarchar(30),		--��Ŀ����
	@customerID varchar(13),		--ί�е�λID���ɿͻ�����ϵͳά��
	@contractAmount numeric(12,2),	--��ͬ���
	@amountType smallint,			--��ͬ�������:0->�����1->��ʽ��ͬ���
	@netAmount numeric(12,2),		--����ͬ��Ϊ�ջ�'0'��ʾ����ͬ��ͬ���
	@strSignDate varchar(19),		--��ͬǩ������:����YYYY-MM-DD hh:mm:ss��ʽ����
	@signerID varchar(10),			--ǩ����ID�������¹���ϵͳά��
	@managerID varchar(10),			--������ID�������¹���ϵͳά��
	@pStatus nvarchar(10),			--״̬˵��:�ɵ�2000�Ŵ����ֵ䶨��,�������ֹ����룬���Ա���״̬����
	@remarks nvarchar(60),			--��ע
	@projectDesc nvarchar(1000),	--��Ŀ����

	--����ά�����:
	@createManID varchar(10),		--�����˹���
	@Ret int output,				--�ɹ���ʶ
	@projectID varchar(13) output	--��Ŀ��ţ�����1100�ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���������
	declare @count as int
	set @count = (select count(*) from project where projectName = @projectName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end
	
	--��ȡ�����룺
	declare @inputCode varchar(5)	--����������
	set @inputCode = dbo.getChinaPYCode(@projectName)
	--��ȡί�е�λ���ƣ�
	if (@customerID is null or @customerID='')
	begin
		set @Ret = 2
		return
	end
	declare @customerName nvarchar(30)
	set @customerName = isnull((select customerName from customerInfo where customerID = @customerID),'')
	if (@customerName is null)
	begin
		set @Ret = 3
		return
	end
	
	--ʹ�ú��뷢����������Ŀ��ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 1100, 1, @curNumber output
	set @projectID = @curNumber

	--��ʽ��ǩ���ˣ�
	if (@signerID is null or @signerID='')
		set @signerID = @createManID
	--ȡ��Ա��������
	declare @signer nvarchar(30),@manager nvarchar(30),@createManName nvarchar(30)	--ǩ����/������/������
	set @signer = isnull((select cName from userInfo where userID = @signerID),'')
	set @manager = isnull((select cName from userInfo where userID = @managerID),'')
	set @createManName = isnull((select cName from userInfo where userID = @createManID),'')

	--��ʽ��״̬˵����
	if (@pStatus is null or @pStatus='')
		set @pStatus = (select objDesc from codeDictionary where classCode=2000 and objCode=1)
	declare @createTime smalldatetime
	set @createTime = getdate()
	--��ʽ��ǩ�����ڣ�
	declare @signDate smalldatetime
	if (@strSignDate is null or @strSignDate='')
		set @signDate = @createTime
	else
		set @signDate = convert(smalldatetime, @strSignDate, 120)
	--��ʽ����ͬ��ֵ��
	if (@netAmount is null or @netAmount=0)
		set @netAmount = @contractAmount
	insert project(projectID, projectName, inputCode, customerID, customerName,
			contractAmount, amountType, netAmount,
			signDate, signerID, signer,
			managerID, manager,
			pStatus, remarks, projectDesc,
			--����ά�����:
			createDate, createrID, creater, modiManID, modiManName, modiTime)
	values(@projectID, @projectName, @inputCode, @customerID, @customerName,
			@contractAmount, @amountType, @netAmount,
			@signDate, @signerID, @signer,
			@managerID, @manager,
			@pStatus, @remarks, @projectDesc,
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
								'�����Ŀ','ϵͳ����' + @createManName + 
								'��Ҫ���������Ŀ[' + @projectName + ']����Ϣ��')
GO
--���ԣ�
declare	@Ret int, @projectID varchar(13)
exec dbo.addProject '����������ղ���Ŀ','C201510200005',400,0,0,'','','','�ƻ���','','','U201510003',@Ret output, @projectID output
select @Ret, @projectID


drop PROCEDURE checkProjectName
/*
	name:		checkProjectName
	function:	2.���ָ������Ŀ�Ƿ��Ѿ��Ǽ�
	input: 
				@projectName nvarchar(30),		--��Ŀ����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2015-10-22
	UpdateDate: 
*/
create PROCEDURE checkProjectName
	@projectName nvarchar(30),		--��Ŀ����
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--������Ŀ�����Ƿ���ڣ�
	declare @count int
	set @count = (select count(*) from project where projectName = @projectName)
	set @Ret = @count
GO
--���ԣ�
declare	@Ret int
exec dbo.checkProjectName '����������ղ���Ŀ',@Ret output
select @Ret

drop PROCEDURE queryProjectLocMan
/*
	name:		queryProjectLocMan
	function:	3.��ѯָ����Ŀ�Ƿ��������ڱ༭
	input: 
				@projectID varchar(13),		--��Ŀ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ������Ŀ������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2015-10-22
	UpdateDate: 
*/
create PROCEDURE queryProjectLocMan
	@projectID varchar(13),		--��Ŀ���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from project where projectID = @projectID),'')
	set @Ret = 0
GO


drop PROCEDURE lockProject4Edit
/*
	name:		lockProject4Edit
	function:	4.������Ŀ�༭������༭��ͻ
	input: 
				@projectID varchar(13),			--��Ŀ���
				@lockManID varchar(10) output,	--�����ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���1��Ҫ��������Ŀ�����ڣ�2:Ҫ��������Ŀ���ڱ����˱༭��
												9��δ֪����
	author:		¬έ
	CreateDate:	2015-10-22
	UpdateDate: 
*/
create PROCEDURE lockProject4Edit
	@projectID varchar(13),			--��Ŀ���
	@lockManID varchar(10) output,	--�����ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ��������Ŀ�Ƿ����
	declare @count as int
	set @count=(select count(*) from project where projectID = @projectID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from project where projectID = @projectID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update project
	set lockManID = @lockManID 
	where projectID = @projectID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '������Ŀ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������Ϊ��[' + @projectID + ']����ĿΪ��ռʽ�༭��')
GO

drop PROCEDURE unlockProjectEditor
/*
	name:		unlockProjectEditor
	function:	5.�ͷ���Ŀ�༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@projectID varchar(13),			--��Ŀ���
				@lockManID varchar(10) output,	--�����ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2015-10-22
	UpdateDate: 
*/
create PROCEDURE unlockProjectEditor
	@projectID varchar(13),			--��Ŀ���
	@lockManID varchar(10) output,	--�����ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from project where projectID = @projectID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update project set lockManID = '' where projectID = @projectID
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
	values(@lockManID, @lockManName, getdate(), '�ͷ���Ŀ�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˱��Ϊ��[' + @projectID + ']����Ŀ�ı༭����')
GO

drop PROCEDURE delProject
/*
	name:		delProject
	function:	6.ɾ��ָ������Ŀ
	input: 
				@projectID varchar(13),			--��Ŀ���
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
												0:�ɹ���1��ָ������Ŀ�����ڣ�2��Ҫɾ������Ŀ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2015-10-22
	UpdateDate: 

*/
create PROCEDURE delProject
	@projectID varchar(13),			--��Ŀ���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ������Ŀ�Ƿ����
	declare @count as int
	set @count=(select count(*) from project where projectID = @projectID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from project where projectID = @projectID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete project where projectID = @projectID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ����Ŀ', '�û�' + @delManName
												+ 'ɾ���˱��Ϊ��[' + @projectID + ']����Ŀ��')
GO



--------------------------��Ϊ��������Ҫ��ÿһ�����¶���Ҫ��ˣ����²�����Ƭ��---------------------------
drop PROCEDURE updateProjectName
/*
	name:		updateProjectName
	function:	7.������Ŀ����
	input: 
				@projectID varchar(13),			--��Ŀ���
				@projectName nvarchar(30),		--��Ŀ����

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µ���Ŀ��������������2:�µ����Ʊ�ռ�ã�9��δ֪����
	author:		¬έ
	CreateDate:	2015-10-23
	UpdateDate: 
*/
create PROCEDURE updateProjectName
	@projectID varchar(13),			--��Ŀ���
	@projectName nvarchar(30),		--��Ŀ����

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ��Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from project where projectID = @projectID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--����Ƿ�����������
	declare @count int
	set @count = (select count(*) from project where projectName = @projectName)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update project
	set projectName = @projectName,
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where projectID = @projectID
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '������Ŀ����', '�û�' + @modiManName 
												+ '�����˱��Ϊ��[' + @projectID + ']����Ŀ�����ơ�')
GO




select projectID, projectName, inputCode, customerID, customerName, isnull(contractAmount,0) contractAmount,
amountType, case amountType when 0 then '����' when 1 then '' end amountTypeDesc, isnull(netAmount,0) netAmount,
isnull(convert(varchar(19),signDate,120),'') signDate, signerID, signer,
isnull(convert(varchar(19),startDate,120),'') startDate, isnull(expectedDuration,0) expectedDuration,
isnull(convert(varchar(19),completeDate,120),'') completeDate,
isnull(managerID,'') managerID, isnull(manager,'') manager, isnull(progress,0) progress, pStatus,
collectedAmount, isnull(contractAmount,0) - isnull(collectedAmount,0) uncollectedAmount,
isnull(remarks,'') remarks, isnull(projectDesc,'') projectDesc
from project

select * from project

select projectID, projectName, inputCode, customerID, customerName, contractAmount, amountType,
	convert(varchar(19),signDate,120) signDate, signerID, signer,
	convert(varchar(19),startDate,120) startDate, expectedDuration,
	convert(varchar(19),completeDate,120) completeDate,
	managerID, manager, isnull(progress,0), pStatus,
	collectedAmount, contractAmount - collectedAmount uncollectedAmount,
	remarks, projectDesc
from project

select * from customerInfo
select * from userInfo