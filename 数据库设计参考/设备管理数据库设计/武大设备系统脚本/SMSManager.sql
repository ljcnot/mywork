use epdc211
/*
	����豸������Ϣϵͳ-���Ź�������
	author:		¬έ
	CreateDate:	2012-8-18
	UpdateDate:
				
*/
select SMSInfoID, receiverID, receiver, mobile, convert(varchar(19),sendPlanTime,120) sendPlanTime, 
		convert(varchar(19),sendTime,120) sendTime, case SMSType when 1 then 'ϵͳ��������' when 2 then '�ֹ�����' end SMSType, 
		case SMSStatus when 0 then '' when 1 then '?' when 2 then '��' when -1 then '�w' end SMSStatus, SMSContent, senderID, sender
from SMSInfo
select * from SMSInfo
update SMSInfo set lockManID=''

alter TABLE SMSInfo add	feeTimes int default(1) null,		--�ƷѴ�������OAϵͳһ�»� by lw 2013-10-31
update SMSInfo
set feetimes=1

drop TABLE SMSInfo
CREATE TABLE SMSInfo
(
	SMSInfoID char(12) not null,		--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	senderID varchar(10) not null,		--�����˹���
	sender nvarchar(30) not null,		--������
	receiverID varchar(110) not null,	--�����˹��ţ����������ʹ�á�,���ָ�
	receiver nvarchar(310) not null,	--�����ˣ����������ʹ�á�,���ָ�
	mobile varchar(300) not null,		--�ֻ�������ֻ�ʹ�á�,���ָ�
	sendPlanTime datetime null,			--�ƻ�����ʱ��:Ϊnull��ʱ��Ϊ���̷���
	sendTime datetime null,				--����ʱ��
	SMSType smallint default(2),		--�������ͣ�1->ϵͳ�������͡�2->�ֹ�����
	SMSStatus smallint default(0),		--����״̬��0->�½���δ���巢�ͣ���1->�����͡�9->�ѷ��͡�-1->����ʧ��
	SMSContent nvarchar(300) null,		--��������

	feeTimes int default(1) null,		--�ƷѴ�������OAϵͳһ�»� by lw 2013-10-31

	--�����ˣ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_SMSInfo] PRIMARY KEY CLUSTERED 
(
	[SMSInfoID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
CREATE NONCLUSTERED INDEX [IX_SMSInfo] ON [dbo].[SMSInfo] 
(
	[sender] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SMSInfo_1] ON [dbo].[SMSInfo] 
(
	[receiver] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SMSInfo_2] ON [dbo].[SMSInfo] 
(
	[sendTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SMSInfo_3] ON [dbo].[SMSInfo] 
(
	[SMSStatus] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_SMSInfo_4] ON [dbo].[SMSInfo] 
(
	[SMSType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--2.����ģ��⣺�������ʱʹ���ֹ�ά��
drop table SMSTemplate
CREATE TABLE SMSTemplate(
	templateID varchar(12) not null,	--��������Ϣģ����,��ϵͳʹ�õ�11001�ź��뷢����������8λ���ڴ���+4λ��ˮ�ţ�
	templateType nvarchar(30) null,		--��Ϣģ������
	templateBody nvarchar(4000) null,	--��Ϣģ������
 CONSTRAINT [PK_SMSTemplate] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--3.���żƷѱ�
select convert(varchar(10),a.accountTime,120) accountTime, a.summary, a.invoice, a.feeTimes, 
	a.income, a.outlay, a.overage
from SMSFeeAccount a
order by rowNum desc
select * from smsfeeaccount
drop TABLE SMSFeeAccount
CREATE TABLE SMSFeeAccount
(
	rowNum int IDENTITY(1,1) NOT NULL,	--���������
	accountTime datetime null,			--����ʱ��
	summary nvarchar(30) null,			--ժҪ
	invoice varchar(30) null,			--Ʊ�ݺ�:����ķ�Ʊ�ţ�֧���Ķ��ź�
	feeTimes int default(0),			--�ƷѴ���
	income numeric(12,2) default(0),	--����
	outlay numeric(12,2) default(0),	--֧��
	overage numeric(12,2) null,			--���
 CONSTRAINT [PK_SMSFeeAccount] PRIMARY KEY CLUSTERED 
(
	[rowNum] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

drop PROCEDURE addSMSInfo
/*
	name:		addSMSInfo
	function:	1.��Ӷ���
				ע�⣺�ô洢���̲���������
	input: 
				@senderID varchar(10),		--�����˹���
				@receiverID varchar(110),	--�����˹��ţ����������ʹ�á�,���ָ�
				@mobile varchar(300),		--�ֻ�������ֻ�ʹ�á�,���ָ�
				@sendPlanTime varchar(19),	--�ƻ�����ʱ��
				@SMSType smallint,			--�������ͣ�1->ϵͳ�������͡�2->�ֹ����͡�9->ϵͳ���������
				@SMSContent nvarchar(300),	--��������

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output	--����ʱ��
				@SMSInfoID char(12) output	--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	author:		¬έ
	CreateDate:	2012-8-19
	UpdateDate: modi by lw 2012-12-29�޸������˽�������������շѴ���ͳ��
*/
create PROCEDURE addSMSInfo
	@senderID varchar(10),		--�����˹���
	@receiverID varchar(110),	--�����˹��ţ����������ʹ�á�,���ָ�
	@mobile varchar(300),		--�ֻ�������ֻ�ʹ�á�,���ָ�
	@sendPlanTime varchar(19),	--�ƻ�����ʱ��
	@SMSType smallint,			--�������ͣ�1->ϵͳ�������͡�2->�ֹ�����
	@SMSContent nvarchar(300),	--��������

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,	--����ʱ��
	@SMSInfoID char(12) output	--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢�����������ű�ʶ���룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10020, 1, @curNumber output
	set @SMSInfoID = @curNumber

	--ȡ�����ˡ������˵�������ͳ���շѴ�����
	declare @id varchar(10), @sender nvarchar(30),@receiver nvarchar(310)
	declare @feeTimes int
	set @receiver = '';set @feeTimes = 0;
	declare tar cursor for
	SELECT convert(varchar(10),T.x.query('data(.)')) FROM 
	(SELECT CONVERT(XML,'<x>'+REPLACE(@receiverID,',','</x><x>')+'</x>',1) Col1) A
	OUTER APPLY A.Col1.nodes('/x') AS T(x)
	OPEN tar
	FETCH NEXT FROM tar INTO @id
	WHILE @@FETCH_STATUS = 0
	begin
		declare @name nvarchar(30)
		set @name = isnull((select cName from userInfo where jobNumber = @id),'')
		set @receiver = @receiver + @name
		set @feeTimes = @feeTimes + 1
		FETCH NEXT FROM tar INTO @id
	end
	CLOSE tar
	DEALLOCATE tar
	set @sender = isnull((select cName from userInfo where jobNumber = @senderID),'')

	--ȡ�����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--���ƻ�����ʱ�䣺
	declare @sPTime datetime
	if (@sendPlanTime='')
		set @sPTime = null
	else
		set @sPTime = CONVERT(datetime,@sendPlanTime,120)
	
	set @createTime = getdate()
	insert SMSInfo(SMSInfoID, senderID, sender, receiverID, receiver, mobile,
					sendPlanTime, SMSType, SMSContent, feeTimes,
					lockManID, modiManID, modiManName, modiTime,
					createManID, createManName, createTime)
	values (@SMSInfoID, @senderID, @sender, @receiverID, @receiver, @mobile,
					@sPTime, @SMSType, @SMSContent, @feeTimes,
					'', @createManID, @createManName, @createTime,
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��Ӷ���', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˶���[' + @SMSInfoID + ']��')
GO
--���ԣ�
declare @Ret		int
declare @createTime smalldatetime 
declare @SMSInfoID char(12)
exec addSMSInfo '00200977','00200977','18602702392','',2,'Hello world!','00200977',@Ret output, @createTime output, @SMSInfoID output
select @Ret,@SMSInfoID

select * from SMSInfo

drop PROCEDURE querySMSInfoLocMan
/*
	name:		querySMSInfoLocMan
	function:	2.��ѯָ�������Ƿ��������ڱ༭
	input: 
				@SMSInfoID char(12),	--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ķ��Ų�����
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-8-19
	UpdateDate: 
*/
create PROCEDURE querySMSInfoLocMan
	@SMSInfoID char(12),	--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	@Ret int output,		--�����ɹ���ʶ
	@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from SMSInfo where SMSInfoID = @SMSInfoID),'')
	set @Ret = 0
GO


drop PROCEDURE lockSMSInfo4Edit
/*
	name:		lockSMSInfo4Edit
	function:	3.�������ű༭������༭��ͻ
	input: 
				@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0���ɹ���1��Ҫ�����Ķ��Ų����ڣ�
							2��Ҫ�����Ķ������ڱ����˱༭��
							3���ö����ѷ��ͻ����ڷ���
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-8-19
	UpdateDate: modi by lw 2012-12-29 ���������͡�״̬��Ϊ���ɱ༭
*/
create PROCEDURE lockSMSInfo4Edit
	@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ķ����Ƿ����
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @SMSStatus int
	select @thisLockMan = isnull(lockManID,''), @SMSStatus = SMSStatus
	from SMSInfo 
	where SMSInfoID = @SMSInfoID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--������״̬:
	if (@SMSStatus = 9 or @SMSStatus = 1)
	begin
		set @Ret = 3
		return
	end

	update SMSInfo 
	set lockManID = @lockManID 
	where SMSInfoID = @SMSInfoID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�������ű༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˶���['+ @SMSInfoID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockSMSInfoEditor
/*
	name:		unlockSMSInfoEditor
	function:	4.�ͷŶ��ű༭��
				ע�⣺�����̲��������Ƿ���ڣ�
	input: 
				@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-8-19
	UpdateDate: 
*/
create PROCEDURE unlockSMSInfoEditor
	@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from SMSInfo where SMSInfoID = @SMSInfoID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update SMSInfo set lockManID = '' where SMSInfoID = @SMSInfoID
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
	values(@lockManID, @lockManName, getdate(), '�ͷŶ��ű༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˶���['+ @SMSInfoID +']�ı༭����')
GO


drop PROCEDURE updateSMSInfo
/*
	name:		updateSMSInfo
	function:	5.���¶���
	input: 
				@SMSInfoID char(12),		--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
				@senderID varchar(10),		--�����˹���
				@receiverID varchar(110),	--�����˹��ţ����������ʹ�á�,���ָ�
				@mobile varchar(300),		--�ֻ�������ֻ�ʹ�á�,���ָ�
				@sendPlanTime varchar(19),	--�ƻ�����ʱ��
				@SMSType smallint,			--�������ͣ�1->ϵͳ�������͡�2->�ֹ����͡�9->ϵͳ���������
				@SMSContent nvarchar(300),	--��������

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ķ��Ų����ڣ�2��Ҫ���µĶ�����������������
							3���ö����ѷ��ͻ����ڷ��ͣ��������޸ģ�
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-8-19
	UpdateDate: modi by lw 2012-12-29 ���������͡�״̬��Ϊ���ɱ༭
*/
create PROCEDURE updateSMSInfo
	@SMSInfoID char(12),		--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	@senderID varchar(10),		--�����˹���
	@receiverID varchar(110),	--�����˹��ţ����������ʹ�á�,���ָ�
	@mobile varchar(300),		--�ֻ�������ֻ�ʹ�á�,���ָ�
	@sendPlanTime varchar(19),	--�ƻ�����ʱ��
	@SMSType smallint,			--�������ͣ�1->ϵͳ�������͡�2->�ֹ�����
	@SMSContent nvarchar(300),	--��������

	--ά����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @SMSStatus int
	select @thisLockMan = isnull(lockManID,''), @SMSStatus = SMSStatus
	from SMSInfo 
	where SMSInfoID = @SMSInfoID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--������״̬:
	if (@SMSStatus = 9 or @SMSStatus = 1)
	begin
		set @Ret = 3
		return
	end
	
	--ȡ�����ˡ������˵�������ͳ���շѴ�����
	declare @id varchar(10), @sender nvarchar(30),@receiver nvarchar(310)
	declare @feeTimes int
	set @receiver = '';set @feeTimes = 0;
	declare tar cursor for
	SELECT convert(varchar(10),T.x.query('data(.)')) FROM 
	(SELECT CONVERT(XML,'<x>'+REPLACE(@receiverID,',','</x><x>')+'</x>',1) Col1) A
	OUTER APPLY A.Col1.nodes('/x') AS T(x)
	OPEN tar
	FETCH NEXT FROM tar INTO @id
	WHILE @@FETCH_STATUS = 0
	begin
		declare @name nvarchar(30)
		set @name = isnull((select cName from userInfo where jobNumber = @id),'')
		set @receiver = @receiver + @name
		set @feeTimes = @feeTimes + 1
		FETCH NEXT FROM tar INTO @id
	end
	CLOSE tar
	DEALLOCATE tar
	set @sender = isnull((select cName from userInfo where jobNumber = @senderID),'')

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--���ƻ�����ʱ�䣺
	declare @sPTime datetime
	if (@sendPlanTime='')
		set @sPTime = null
	else
		set @sPTime = CONVERT(datetime,@sendPlanTime,120)

	set @updateTime = getdate()
	update SMSInfo 
	set SMSInfoID = @SMSInfoID, senderID = @senderID, sender = @sender, 
		receiverID = @receiverID, receiver = @receiver, mobile = @mobile,
		sendPlanTime = @sPTime, SMSType = @SMSType, SMSContent = @SMSContent,
		feeTimes = @feeTimes,
		SMSStatus = 0,	--��״̬��λ
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where SMSInfoID = @SMSInfoID
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���¶���', '�û�' + @modiManName 
												+ '�����˶���['+ @SMSInfoID +']��')
GO

select * from SMSFeeAccount
drop PROCEDURE delSMSInfo
/*
	name:		delSMSInfo
	function:	6.ɾ��ָ���Ķ���
	input: 
				@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ķ��Ų����ڣ�
							2��Ҫɾ���Ķ�����������������
							3���ö����ѷ��ͻ����ڷ��ͣ�������ɾ����
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-8-19
	UpdateDate: modi by lw 2012-12-29����ɾ�����ܣ����͵Ķ��Ų�����ɾ����
*/
create PROCEDURE delSMSInfo
	@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���Ķ����Ƿ����
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @SMSStatus int
	select @thisLockMan = isnull(lockManID,''), @SMSStatus = SMSStatus
	from SMSInfo 
	where SMSInfoID = @SMSInfoID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	--������״̬:
	if (@SMSStatus = 9 or @SMSStatus = 1)
	begin
		set @Ret = 3
		return
	end

	delete SMSInfo where SMSInfoID = @SMSInfoID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ���˶���['+ @SMSInfoID +']��')

GO

drop PROCEDURE clearSMSInfo
/*
	name:		clearSMSInfo
	function:	7.�������
				ע��:�ù��̲�������״̬���Ǹ߼�������Աʹ�õĹ��̡��ù��̲��������������µĶ��ţ�
	input: 
				@startTime varchar(19),			--���ʱ�䷶Χ����ʼʱ��
				@endTime varchar(19),			--���ʱ�䷶Χ������ʱ��
				@clearManID varchar(10) output,	--�����
	output: 
				@Ret		int output			--�����ɹ���ʶ��0:�ɹ���1:����������90������ݣ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-29
	UpdateDate: 

*/
create PROCEDURE clearSMSInfo
	@startTime varchar(19),			--���ʱ�䷶Χ����ʼʱ��
	@endTime varchar(19),			--���ʱ�䷶Χ������ʱ��
	@clearManID varchar(10) output,	--�����
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--������ڸ�ʽ��
	declare @sTime smalldatetime, @eTime smalldatetime
	set @sTime = CONVERT(datetime,@startTime,120)
	set @eTime = CONVERT(datetime,@endTime,120)
	if (@sTime > @eTime)
	begin
		declare @temp smalldatetime
		set @temp = @sTime
		set @sTime = @eTime
		set @eTime = @temp
	end
	if (datediff(day,@eTime, GETDATE()) < 90)
	begin
		set @Ret = 1
		return
	end

	delete SMSInfo where modiTime>=@sTime and modiTime <= @eTime
	set @Ret = 0

	--ȡά���˵�������
	declare @clearManName nvarchar(30)
	set @clearManName = isnull((select userCName from activeUsers where userID = @clearManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@clearManID, @clearManName, getdate(), '�������', '�û�' + @clearManName
			+ '����˶���['+ convert(varchar(19),@sTime,120) + '��' + CONVERT(varchar(19),@eTime,120)  +']��Χ�ڵĶ��š�')

GO
--���ԣ�
declare @Ret int
exec dbo.clearSMSInfo '2012-09-1','2012-06-01','0000000000', @ret output
select @Ret
select * from SMSInfo
select * from workNote order by actionTime desc

drop PROCEDURE changeSMSStatus
drop PROCEDURE sendSMS
/*
	name:		sendSMS
	function:	8.���Ͷ���
				ע���ù���ֻ������״̬�궨Ϊ������״̬���ɵ��ȳ����Զ����ȷ��ͣ�
	input: 
				@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
				@sendTime varchar(19),			--����ʱ��

				--ά����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0���ɹ���1��ָ���Ķ��Ų����ڣ�
							2��Ҫ���͵Ķ�����������������
							3���ö����Ѿ����ͻ����ڷ��ͣ�
							4���˺����㣬
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-29
	UpdateDate: 
*/
create PROCEDURE sendSMS
	@SMSInfoID char(12),			--���������ű�ʶ��ʹ�õ� 10020 �ź��뷢��������
	@sendTime varchar(19),			--����ʱ��

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���Ķ����Ƿ����
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @SMSStatus int, @oldSendPlanTime smalldatetime
	select @thisLockMan = isnull(lockManID,''), @SMSStatus = SMSStatus, @oldSendPlanTime = sendPlanTime
	from SMSInfo 
	where SMSInfoID = @SMSInfoID
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--������״̬:
	if (@SMSStatus = 9 or @SMSStatus = 1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--���ƻ�����ʱ�䣺
	declare @sTime datetime
	if (@sendTime='')
	begin
		if (@oldSendPlanTime is null)
			set @sTime = GETDATE()
		else 
			set @sTime = null
	end
	else
		set @sTime = CONVERT(datetime,@sendTime,120)
		
	--���Ʒ��˺������ˣ�
	declare @feeTimes int		--���ζ��ŷ��ͼƷѴ���
	declare @fee numeric(12,2)	--���μƷ�
	set @feeTimes = isnull((select feeTimes from SMSInfo where SMSInfoID = @SMSInfoID),1)
	declare @price numeric(12,2) --���ŵ���
	set @price = isnull(cast((select objDesc from codeDictionary where classCode=1 and objCode=6) as numeric(12,2)),0.1)
	set @fee = @feeTimes * @price
	
	declare @feeMode varchar(10)	--ϵͳ�շ�ģʽ
	set @feeMode = isnull((select objDesc from codeDictionary where classCode=1 and objCode=5),2)
	declare @overage numeric(12,2)
	set @overage = isnull((select top 1 overage from SMSFeeAccount order by rowNum desc),0)
	if (@feeMode=2) --Ԥ����ģʽ
	begin
		if (@overage < @fee)
		begin
			set @Ret = 4
			return 
		end
	end
	
	set @updateTime = getdate()
	begin tran
		insert SMSFeeAccount(accountTime, summary, invoice, feeTimes, income, outlay, overage)
		values(@updateTime,'���Ͷ���',@SMSInfoID,@feeTimes,0,@fee,@overage - @fee)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end

		update SMSInfo
		set SMSStatus = 1,	--����״̬��0->�½���δ���巢�ͣ���1->�����͡�9->�ѷ��͡�-1->����ʧ��
			sendPlanTime = @sTime,
			--ά���ˣ�
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where SMSInfoID = @SMSInfoID
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
	values(@modiManID, @modiManName, @updateTime, '���Ͷ���', '�û�' + @modiManName 
												+ '�����˶���['+ @SMSInfoID +']��')
GO
--����:
declare	@updateTime smalldatetime --����ʱ��
declare	@Ret		int				--�����ɹ���ʶ
exec dbo.sendSMS '201212300002', '2012-12-30 00:50:00', '00001', @updateTime output, @Ret output
select @Ret

update SMSInfo
set SMSStatus = 0

select * from SMSInfo
select * from SMSFeeAccount
select * from workNote

drop PROCEDURE sendingInfo
/*
	name:		sendingInfo
	function:	9.��������Ǽ�
				ע�����ǹ������Ǽǵ�ר�й���
	input: 
				@SMSInfoID char(12),		--���ű�ʶ
				@isSended smallint,			--�Ƿ��ͳɹ���9->���ͳɹ���-1->����ʧ��
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0���ɹ���1��ָ���Ķ��Ų����ڣ�
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-29
	UpdateDate: 
*/
create PROCEDURE sendingInfo
	@SMSInfoID char(12),		--���ű�ʶ
	@isSended smallint,			--�Ƿ��ͳɹ���9->���ͳɹ���-1->����ʧ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���Ķ����Ƿ����
	declare @count as int
	set @count=(select count(*) from SMSInfo where SMSInfoID = @SMSInfoID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	begin tran	
		if (@isSended = -1)	--����ʧ�ܽ����õ���
		begin
			declare @overage numeric(12,2)
			set @overage = isnull((select top 1 overage from SMSFeeAccount order by rowNum desc),0)

			insert SMSFeeAccount(accountTime, summary, invoice, feeTimes, income, outlay, overage)
			select top 1 getdate(),'����ʧ��',@SMSInfoID,feeTimes,0,-outlay,@overage + outlay
			from SMSFeeAccount 
			where invoice = @SMSInfoID
			order by rowNum desc
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
		end

		update SMSInfo	
		set sendTime=GETDATE(),
			SMSStatus=@isSended
		where SMSInfoID = @SMSInfoID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
	commit tran	
	set @Ret = 0
GO
--���ԣ�
declare @Ret		int		--�����ɹ���ʶ
exec dbo.sendingInfo '201212300002', -1, @Ret output
select @Ret
