use hustOA
/*
	ǿ�ų����İ칫ϵͳ-ѧ���������
	author:		¬έ
	CreateDate:	2012-12-23
	UpdateDate: 
*/
--1.ѧ����������
select * from academicReports
select * from AReportEnterMans
update AReportEnterMans
set isLate = 0
drop table academicReports
CREATE TABLE academicReports(
	aReportID varchar(10) not null,		--������ѧ��������,��ϵͳʹ�õ�200�ź��뷢����������'BG'+4λ��ݴ���+4λ��ˮ�ţ�
	topic  nvarchar(40) null,			--����
	reportManID varchar(100) not null,	--�����˹��ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
	reportMan nvarchar(300) not null,	--������������֧�ֶ���ˣ�����"XXX,XXX"��ʽ��š��������
	reportStartTime smalldatetime null,	--���濪ʼʱ��
	reportEndTime smalldatetime null,	--�������ʱ��
	summary nvarchar(300) null,			--����ժҪ
	
	reportPlaceID varchar(10) null,		--����ص�ı�ʶ�ţ�����ID��
	reportPlace nvarchar(60) null,		--����ص�
	placeIsReady smallint default(0),	--������Ҫ�ĳ����Ƿ�׼���ã�0->δ׼���ã�1->׼������
	
	needEqpCodes varchar(80) null,		--������Ҫ���豸��ţ�֧�ֶ���豸������"XXXXXXXX,XXXXXXXX"��ʽ���
	needEqpNames nvarchar(300) null,	--������Ҫ���豸���ƣ�֧�ֶ���豸������"�豸1,�豸2"��ʽ��ţ�������ơ�
	eqpIsReady smallint default(0),		--������Ҫ���豸�Ƿ�׼���ã�0->δ׼���ã�1->׼������
	
	--��Զ�����Ҫ֪ͨ�����ѣ�����ѧ������Ҫ�ܹ��޶����ķ�Χ����Щ���ܶ�û������
	--���������ֶ���Ԥ��������չ��Щ���ܵģ�
	--add by lw 2013-1-3
	needSMSInvitation smallint default(0),--�Ƿ���Ҫ����֪ͨ��0->����Ҫ, 1->��Ҫ
	needSMSRemind smallint default(0),	--�Ƿ���Ҫ�������ѣ�����ǰ1Сʱ���ѣ���0->����Ҫ��1->��Ҫ

	isPublish smallint default(0),		--(ԭisSendMsg�ֶ�)�Ƿ�ѧ�����棺0->δ����ѧ�����棨��ѧ�����泷�أ���1->�ѷ���ѧ������ modi by lw 2013-1-3
	publishTime smalldatetime null,		--��������add by lw 2013-1-3
	isOver smallint default(0),			--�Ƿ񱨸������0->δ������1->���� ע�⣺����ǲ��ܳ����� add by lw 2013-1-3

	orderNum smallint default(-1),		--��ʾ����� add by lw 2013-3-20
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_academicReports] PRIMARY KEY CLUSTERED 
(
	[aReportID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--����ʱ��������
CREATE NONCLUSTERED INDEX [IX_academicReports] ON [dbo].[academicReports] 
(
	[reportStartTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--��������������
CREATE NONCLUSTERED INDEX [IX_academicReports_1] ON [dbo].[academicReports] 
(
	[orderNum] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


select * from academicReports
select * from AReportEnterMans

--2.ѧ�����汨����
select * from AReportEnterMans
drop table AReportEnterMans
CREATE TABLE AReportEnterMans(
	aReportID varchar(10) not null,		--�����ѧ��������
	topic  nvarchar(40) null,			--���⣺�������
	applyManID varchar(10) not null,	--�����˹���
	applyMan nvarchar(30) null,			--����������
	applyTime smalldatetime null,		--����ʱ��
	checkManID varchar(10) null,		--�����˹���
	checkMan nvarchar(30) null,			--����������
	arriveTime smalldatetime null,		--����ʱ��
	isLate smallint default(0),			--�Ƿ�ٵ���0->δ���1->�������-1->�ٵ�
 CONSTRAINT [PK_AReportEnterMans] PRIMARY KEY CLUSTERED 
(
	[aReportID] ASC,
	[applyManID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[AReportEnterMans] WITH CHECK ADD CONSTRAINT [FK_AReportEnterMans_academicReports] FOREIGN KEY([aReportID])
REFERENCES [dbo].[academicReports] ([aReportID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AReportEnterMans] CHECK CONSTRAINT [FK_AReportEnterMans_academicReports]
GO


drop PROCEDURE queryAcademicReportLocMan
/*
	name:		queryAcademicReportLocMan
	function:	1.��ѯָ��ѧ�������Ƿ��������ڱ༭
	input: 
				@aReportID varchar(10),		--ѧ��������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����ѧ�����治����
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-12-23
	UpdateDate: 
*/
create PROCEDURE queryAcademicReportLocMan
	@aReportID varchar(10),		--ѧ��������
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	set @Ret = 0
GO


drop PROCEDURE lockAcademicReport4Edit
/*
	name:		lockAcademicReport4Edit
	function:	2.����ѧ������༭������༭��ͻ
	input: 
				@aReportID varchar(10),			--ѧ��������
				@lockManID varchar(10) output,	--�����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������ѧ�����治���ڣ�2:Ҫ������ѧ���������ڱ����˱༭��
							3����ѧ�������ѷ�����������༭������
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-23
	UpdateDate: 
*/
create PROCEDURE lockAcademicReport4Edit
	@aReportID varchar(10),		--ѧ��������
	@lockManID varchar(10) output,	--�����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @isPublish smallint
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish from academicReports where aReportID= @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���״̬��
	if (@isPublish=1)
	begin
		set @Ret = 3
		return
	end

	update academicReports
	set lockManID = @lockManID 
	where aReportID= @aReportID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����ѧ������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ��������ѧ������['+ @aReportID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockAcademicReportEditor
/*
	name:		unlockAcademicReportEditor
	function:	3.�ͷ�ѧ������༭��
				ע�⣺�����̲����ѧ�������Ƿ���ڣ�
	input: 
				@aReportID varchar(10),			--ѧ��������
				@lockManID varchar(10) output,	--�����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-23
	UpdateDate: 
*/
create PROCEDURE unlockAcademicReportEditor
	@aReportID varchar(10),			--ѧ��������
	@lockManID varchar(10) output,	--�����ˣ������ǰѧ�����������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update academicReports set lockManID = '' where aReportID= @aReportID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�ѧ������༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ���ѧ������['+ @aReportID +']�ı༭����')
GO

drop PROCEDURE addAcademicReport
/*
	name:		addAcademicReport
	function:	4.���ѧ��������Ϣ
	input: 
				@topic  nvarchar(40),		--����
				@reportManID varchar(100),	--�����˹��ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
				@reportMan nvarchar(300),	--������������֧�ֶ���ˣ�����"XXX,XXX"��ʽ��š��������
				@reportStartTime varchar(19),--���濪ʼʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
				@reportEndTime varchar(19),	--�������ʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
				@summary nvarchar(300),		--����ժҪ
				
				@reportPlaceID varchar(10),	--����ص�ı�ʶ�ţ�����ID��
				@reportPlace nvarchar(60),	--����ص�
				
				@needEqpCodes varchar(80),	--������Ҫ���豸��ţ�֧�ֶ���豸������"XXXXXXXX,XXXXXXXX"��ʽ���
				@needEqpNames nvarchar(300),--������Ҫ���豸���ƣ�֧�ֶ���豸������"�豸1,�豸2"��ʽ��ţ�������ơ�

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@aReportID varchar(10) output--ѧ��������
	author:		¬έ
	CreateDate:	2012-12-23
	UpdateDate: 
*/
create PROCEDURE addAcademicReport
	@topic  nvarchar(40),		--����
	@reportManID varchar(100),	--�����˹��ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
	@reportMan nvarchar(300),	--������������֧�ֶ���ˣ�����"XXX,XXX"��ʽ��š��������
	@reportStartTime varchar(19),--���濪ʼʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
	@reportEndTime varchar(19),	--�������ʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
	@summary nvarchar(300),		--����ժҪ
	
	@reportPlaceID varchar(10),	--����ص�ı�ʶ�ţ�����ID��
	@reportPlace nvarchar(60),	--����ص�
	
	@needEqpCodes varchar(80),	--������Ҫ���豸��ţ�֧�ֶ���豸������"XXXXXXXX,XXXXXXXX"��ʽ���
	@needEqpNames nvarchar(300),--������Ҫ���豸���ƣ�֧�ֶ���豸������"�豸1,�豸2"��ʽ��ţ�������ơ�

	@createManID varchar(10),	--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@aReportID varchar(10) output--ѧ��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢��������ѧ�������ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 200, 1, @curNumber output
	set @aReportID = @curNumber

	--ȡ�����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert academicReports(aReportID, topic, reportManID, reportMan, reportStartTime, reportEndTime, summary,
					reportPlaceID, reportPlace, needEqpCodes, needEqpNames,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@aReportID, @topic, @reportManID, @reportMan, @reportStartTime, @reportEndTime, @summary,
					@reportPlaceID, @reportPlace, @needEqpCodes, @needEqpNames,
					--����ά�����:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�Ǽ�ѧ������', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ���ѧ�����桰' + @topic + '['+@aReportID+']����')
GO

drop PROCEDURE updateAcademicReport
/*
	name:		updateAcademicReport
	function:	5.�޸�ѧ��������Ϣ
	input: 
				@aReportID varchar(10),		--ѧ��������
				@topic  nvarchar(40),		--����
				@reportManID varchar(100),	--�����˹��ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
				@reportMan nvarchar(300),	--������������֧�ֶ���ˣ�����"XXX,XXX"��ʽ��š��������
				@reportStartTime varchar(19),--���濪ʼʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
				@reportEndTime varchar(19),	--�������ʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
				@summary nvarchar(300),		--����ժҪ
				
				@reportPlaceID varchar(10),	--����ص�ı�ʶ�ţ�����ID��
				@reportPlace nvarchar(60),	--����ص�
				
				@needEqpCodes varchar(80),	--������Ҫ���豸��ţ�֧�ֶ���豸������"XXXXXXXX,XXXXXXXX"��ʽ���
				@needEqpNames nvarchar(300),--������Ҫ���豸���ƣ�֧�ֶ���豸������"�豸1,�豸2"��ʽ��ţ�������ơ�

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ�ѧ�����治���ڣ�
							2:Ҫ�޸ĵ�ѧ�������������������༭��
							3����ѧ�������ѷ������������޸ģ�
							9:δ֪����
				@modiTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-23
	UpdateDate: 
*/
create PROCEDURE updateAcademicReport
	@aReportID varchar(10),		--ѧ��������
	@topic  nvarchar(40),		--����
	@reportManID varchar(100),	--�����˹��ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
	@reportMan nvarchar(300),	--������������֧�ֶ���ˣ�����"XXX,XXX"��ʽ��š��������
	@reportStartTime varchar(19),--���濪ʼʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
	@reportEndTime varchar(19),	--�������ʱ�䣺����"yyyy-MM-dd hh:MM:ss"��ʽ���
	@summary nvarchar(300),		--����ժҪ
	
	@reportPlaceID varchar(10),	--����ص�ı�ʶ�ţ�����ID��
	@reportPlace nvarchar(60),	--����ص�
	
	@needEqpCodes varchar(80),	--������Ҫ���豸��ţ�֧�ֶ���豸������"XXXXXXXX,XXXXXXXX"��ʽ���
	@needEqpNames nvarchar(300),--������Ҫ���豸���ƣ�֧�ֶ���豸������"�豸1,�豸2"��ʽ��ţ�������ơ�

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @isPublish smallint
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish from academicReports where aReportID= @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���״̬��
	if (@isPublish=1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--����Ƿ���ʱ��仯:
	--����Ƿ��г��ر仯��
	--����Ƿ����豸�仯:
	
	set @modiTime = getdate()
	update academicReports
	set aReportID = @aReportID, topic = @topic, 
		reportManID = @reportManID, reportMan = @reportMan, 
		reportStartTime = @reportStartTime, reportEndTime = @reportEndTime, summary = @summary,
		reportPlaceID = @reportPlaceID, reportPlace = @reportPlace, needEqpCodes = @needEqpCodes, needEqpNames = @needEqpNames,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where aReportID= @aReportID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸�ѧ������', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸���ѧ�����桰' + @topic + '['+@aReportID+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delAcademicReport
/*
	name:		delAcademicReport
	function:	6.ɾ��ָ����ѧ������
	input: 
				@aReportID varchar(10),			--ѧ��������
				@delManID varchar(10) output,	--ɾ���ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ѧ�����治���ڣ�2��Ҫɾ����ѧ��������������������3����ѧ�������ѷ�����9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-23
	UpdateDate: 

*/
create PROCEDURE delAcademicReport
	@aReportID varchar(10),			--ѧ��������
	@delManID varchar(10) output,	--ɾ���ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @isPublish smallint
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish from academicReports where aReportID= @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���״̬��
	if (@isPublish=1)
	begin
		set @Ret = 3
		return
	end

	delete academicReports where aReportID= @aReportID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��ѧ������', '�û�' + @delManName
												+ 'ɾ����ѧ������['+@aReportID+']��')

GO


drop PROCEDURE placeIsReady4AReport
/*
	name:		placeIsReady4AReport
	function:	7.ָ֪ͨ����ѧ�����泡���Ѿ�׼����
	input: 
				@aReportID varchar(10),			--ѧ��������
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ѧ�����治���ڣ�2��ָ����ѧ��������������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-23
	UpdateDate: 

*/
create PROCEDURE placeIsReady4AReport
	@aReportID varchar(10),			--ѧ��������
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end

	update academicReports
	set placeIsReady = 1
	where aReportID= @aReportID
	
	set @Ret = 0
	--����Ƿ��豸Ҳ׼���ã����Ҳ׼�����˾Ϳ�ʼ����֪ͨ
GO

drop PROCEDURE eqpIsReady4AReport
/*
	name:		eqpIsReady4AReport
	function:	8.ָ֪ͨ����ѧ�������豸�Ѿ�׼����
	input: 
				@aReportID varchar(10),			--ѧ��������
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ѧ�����治���ڣ�2��ָ����ѧ��������������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-23
	UpdateDate: 

*/
create PROCEDURE eqpIsReady4AReport
	@aReportID varchar(10),			--ѧ��������
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @Ret = 2
		return
	end

	update academicReports
	set eqpIsReady = 1
	where aReportID= @aReportID
	
	set @Ret = 0
	--����Ƿ񳡵�Ҳ׼���ã����Ҳ׼�����˾Ϳ�ʼ����ѧ������
	
GO


drop PROCEDURE publishAReport
/*
	name:		publishAReport
	function:	9.����ѧ������ѧ������
	input: 
				@aReportID varchar(10),			--ѧ��������
				@publishManID varchar(10) output,	--�����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ѧ�����治���ڣ�2��ָ����ѧ��������������������3����ѧ�������Ѿ��Ƿ���״̬��9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-3
	UpdateDate: 

*/
create PROCEDURE publishAReport
	@aReportID varchar(10),			--ѧ��������
	@publishManID varchar(10) output,	--�����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @isPublish smallint
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish from academicReports where aReportID= @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @publishManID)
	begin
		set @publishManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���״̬��
	if (@isPublish=1)
	begin
		set @Ret = 3
		return
	end
	
	--ȡ�����˵�������
	declare @publishMan nvarchar(30)
	set @publishMan = isnull((select userCName from activeUsers where userID = @publishManID),'')

	--���ɷ�����ţ�
	declare @curMaxOrderNum int
	set @curMaxOrderNum = isnull((select max(orderNum) from academicReports  where isPublish = 1),0) + 1
	
	declare @publishTime smalldatetime --��������
	set @publishTime = GETDATE()
	update academicReports 
	set isPublish = 1, publishTime = @publishTime, orderNum = @curMaxOrderNum,
		--����ά�����:
		modiManID = @publishManID, modiManName = @publishMan, modiTime = @publishTime
	where aReportID= @aReportID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--����ѧ�������ö���
	declare @execRet int
	exec dbo.setAReportToTop @publishManID, @publishManID output, @execRet output

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@publishManID, @publishMan, @publishTime, '����ѧ������', '�û�' + @publishMan
												+ '������ѧ������['+@aReportID+']��')

GO

drop PROCEDURE cancelPublishAReport
/*
	name:		cancelPublishAReport
	function:	9.1.��������ѧ������ѧ������
	input: 
				@aReportID varchar(10),			--ѧ��������
				@cancelManID varchar(10) output,--�����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ѧ�����治���ڣ�2��ָ����ѧ��������������������3����ѧ�����滹δ������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-3
	UpdateDate: 

*/
create PROCEDURE cancelPublishAReport
	@aReportID varchar(10),			--ѧ��������
	@cancelManID varchar(10) output,--�����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ����������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @isPublish smallint
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish from academicReports where aReportID= @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @cancelManID)
	begin
		set @cancelManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���״̬��
	if (@isPublish=0)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @cancelMan nvarchar(30)
	set @cancelMan = isnull((select userCName from activeUsers where userID = @cancelManID),'')

	declare @cancelTime smalldatetime --��������
	set @cancelTime = GETDATE()
	update academicReports 
	set isPublish = 0, publishTime = null, 
		orderNum = -1,
		--����ά�����:
		modiManID = @cancelManID, modiManName = @cancelMan, modiTime = @cancelTime
	where aReportID= @aReportID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@cancelManID, @cancelMan, @cancelTime, '����ѧ������', '�û�' + @cancelMan
												+ '������ѧ������['+@aReportID+']��')

GO



drop PROCEDURE applyEnterAReport
/*
	name:		applyEnterAReport
	function:	10.����μ�ָ����ѧ������
	input: 
				@aReportID varchar(10),			--ѧ��������
				@applyManID varchar(10) output,	--�����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ѧ�����治���ڣ�2��Ҫ����μӵ�ѧ��������������������3�����Ѿ�����μ��ˣ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-23
	UpdateDate: 

*/
create PROCEDURE applyEnterAReport
	@aReportID varchar(10),			--ѧ��������
	@applyManID varchar(10) output,	--�����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @applyManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--����Ƿ��ظ����룺
	set @count =(select count(*) from AReportEnterMans where aReportID = @aReportID and applyManID = @applyManID)
	if (@count > 0)	--������
	begin
		set @Ret = 3
		return
	end

	--ȡ�����˵�������
	declare @applyMan nvarchar(30)
	set @applyMan = isnull((select userCName from activeUsers where userID = @applyManID),'')

	declare @applyTime smalldatetime	--����ʱ��
	set @applyTime = GETDATE()
	
	insert AReportEnterMans(aReportID, topic, applyManID, applyMan, applyTime)
	select aReportID, topic, @applyManID, @applyMan, @applyTime
	from academicReports 
	where aReportID= @aReportID
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@applyManID, @applyMan, @applyTime, 'ѧ�����汨��', '�û�' + @applyMan
												+ '�����μ���ѧ������['+@aReportID+']��')
GO
--���ԣ�
declare @Ret int
exec dbo.applyEnterAReport 'BG20120019','00001', @Ret output
select @Ret


select * from AReportEnterMans
select * from academicReports
select * from userInfo

drop PROCEDURE cancelEnterAReport
/*
	name:		cancelEnterAReport
	function:	11.ȡ���μ�ָ����ѧ������
	input: 
				@aReportID varchar(10),			--ѧ��������
				@cancelManID varchar(10) output,--ȡ���ˣ�ԭ�����ˣ��������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ѧ�����治���ڣ�2��Ҫ����μӵ�ѧ��������������������3����û������μӸ�ѧ�����棬9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-23
	UpdateDate: 

*/
create PROCEDURE cancelEnterAReport
	@aReportID varchar(10),			--ѧ��������
	@cancelManID varchar(10) output,--ȡ���ˣ�ԭ�����ˣ��������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @cancelManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--����Ƿ������룺
	set @count =(select count(*) from AReportEnterMans where aReportID = @aReportID and applyManID = @cancelManID)
	if (@count = 0)	--δ����
	begin
		set @Ret = 3
		return
	end

	--ȡ�����˵�������
	declare @cancelMan nvarchar(30)
	set @cancelMan = isnull((select userCName from activeUsers where userID = @cancelManID),'')

	delete AReportEnterMans
	where aReportID = @aReportID and applyManID = @cancelManID

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@cancelManID, @cancelMan, getdate(), 'ȡ��ѧ�����汨��', '�û�' + @cancelMan
												+ 'ȡ���˲μ�ѧ������['+@aReportID+']��')
GO
--���ԣ�
declare	@Ret		int	--�����ɹ���ʶ
exec dbo.cancelEnterAReport 'BG20120032', '0005', @Ret output
select @Ret

select * from academicReports
select * from AReportEnterMans

drop PROCEDURE checkEnterAReport
/*
	name:		checkEnterAReport
	function:	12.����ָ����ѧ�����棨���ڣ�
	input: 
				@aReportID varchar(10),			--ѧ��������
				@enterManID varchar(10),		--�����ˣ�ԭ�����ˣ�
				@checkManID varchar(10) output,	--����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output,			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ѧ�����治���ڣ�2��Ҫ����μӵ�ѧ��������������������9��δ֪����
				@isLate smallint output			--ϵͳ���صĵ���״̬��1:�������-1���ٵ�
	author:		¬έ
	CreateDate:	2012-12-23
	UpdateDate: 

*/
create PROCEDURE checkEnterAReport
	@aReportID varchar(10),			--ѧ��������
	@enterManID varchar(10),		--�����ˣ�ԭ�����ˣ�
	@checkManID varchar(10) output,	--����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output,			--�����ɹ���ʶ
	@isLate smallint output			--ϵͳ���صĵ���״̬��1:�������-1���ٵ�, 0��δ֪
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @isLate = 0

	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @checkManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--ȡ�����˺Ϳ����˵�������
	declare @enterMan nvarchar(30), @checkMan nvarchar(30)
	set @enterMan = isnull((select cName from userInfo where jobNumber = @enterManID),'')
	set @checkMan = isnull((select userCName from activeUsers where userID = @checkManID),'')

	--ȡѧ������ʱ��͵���ʱ�䣺
	declare @reportTime smalldatetime, @arriveTime smalldatetime
	set @reportTime = (select reportStartTime from academicReports where aReportID=@aReportID)
	set @arriveTime = GETDATE()
	if (@reportTime > @arriveTime)
		set @isLate = 1
	else
		set @isLate = -1
	
	--����Ƿ����ֱ���
	set @count =(select count(*) from AReportEnterMans where aReportID = @aReportID and applyManID = @enterManID)
	if (@count = 0)	--δ����
	begin
		insert AReportEnterMans(aReportID, topic, applyManID, applyMan, applyTime, checkManID, checkMan, arriveTime, isLate)
		select aReportID, topic, @enterManID, @enterMan, @arriveTime, @checkManID, @checkMan, @arriveTime, @isLate
		from academicReports 
		where aReportID= @aReportID
	end
	else
	begin
		update AReportEnterMans
		set checkManID = @checkManID, checkMan = @checkMan, arriveTime = @arriveTime, isLate = @isLate
		where aReportID= @aReportID and applyManID = @enterManID
	end

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@checkManID, @checkMan, @arriveTime, 'ѧ���������', '�û�' + @checkMan
												+ '��['+@enterMan+']����Ϊ����ѧ������['+@aReportID+']��')
GO


drop PROCEDURE checkEnterAReportByFlag
/*
	name:		checkEnterAReportByFlag
	function:	13.ʹ�ñ�־״̬����
	input: 
				@aReportID varchar(10),			--ѧ��������
				@enterManID varchar(10),		--�����ˣ�ԭ�����ˣ�
				@isLate smallint,				--����״̬��1:������� -1:�ٵ�����
				@checkManID varchar(10) output,	--����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ѧ�����治���ڣ�2��Ҫ����μӵ�ѧ��������������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-1
	UpdateDate: 

*/
create PROCEDURE checkEnterAReportByFlag
	@aReportID varchar(10),			--ѧ��������
	@enterManID varchar(10),		--�����ˣ�ԭ�����ˣ�
	@isLate smallint,				--����״̬��1:������� -1:�ٵ�����
	@checkManID varchar(10) output,	--����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @checkManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--ȡ�����˺Ϳ����˵�������
	declare @enterMan nvarchar(30), @checkMan nvarchar(30)
	set @enterMan = isnull((select cName from userInfo where jobNumber = @enterManID),'')
	set @checkMan = isnull((select userCName from activeUsers where userID = @checkManID),'')

	--ȡѧ������ʱ��͵���ʱ�䣺
	declare @reportTime smalldatetime, @arriveTime smalldatetime
	set @reportTime = (select reportStartTime from academicReports where aReportID=@aReportID)

	--���ݵ���״̬���õ���ʱ�䣺������������Ϊ���鿪ʼʱ�䣬�ٵ���������Ϊ���鿪ʼ��15����
	if (@isLate=1)
		set @arriveTime = @reportTime
	else
		set @arriveTime = DATEADD(minute, 15, @reportTime)
	
	--����Ƿ����ֱ���
	set @count =(select count(*) from AReportEnterMans where aReportID = @aReportID and applyManID = @enterManID)
	if (@count = 0)	--δ����
	begin
		insert AReportEnterMans(aReportID, topic, applyManID, applyMan, applyTime, checkManID, checkMan, arriveTime, isLate)
		select aReportID, topic, @enterManID, @enterMan, @arriveTime, @checkManID, @checkMan, @arriveTime, @isLate
		from academicReports 
		where aReportID= @aReportID
	end
	else
	begin
		update AReportEnterMans
		set checkManID = @checkManID, checkMan = @checkMan, arriveTime = @arriveTime, isLate = @isLate
		where aReportID= @aReportID and applyManID = @enterManID
	end

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@checkManID, @checkMan, @arriveTime, 'ѧ���������', '�û�' + @checkMan
												+ '��['+@enterMan+']����Ϊ����ѧ������['+@aReportID+']��')
GO

drop PROCEDURE cancelCheckEnterAReport
/*
	name:		cancelCheckEnterAReport
	function:	14.ȡ�������������ȡ�����ܣ�
	input: 
				@aReportID varchar(10),			--ѧ��������
				@enterManID varchar(10),		--�����ˣ�ԭ�����ˣ�
				@checkManID varchar(10) output,	--����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ѧ�����治���ڣ�2��Ҫ����μӵ�ѧ��������������������3:û�и������˻�δ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-1
	UpdateDate: 

*/
create PROCEDURE cancelCheckEnterAReport
	@aReportID varchar(10),			--ѧ��������
	@enterManID varchar(10),		--�����ˣ�ԭ�����ˣ�
	@checkManID varchar(10) output,	--����ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from academicReports where aReportID= @aReportID),'')
	if (@thisLockMan <> '')
	begin
		set @checkManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--���μ����Ƿ���ڲ����
	set @count =(select count(*) from AReportEnterMans where aReportID = @aReportID and applyManID = @enterManID and isLate<>0)
	if (@count=0)
	begin
		set @Ret =3
		return
	end

	--ȡ�����˺Ϳ����˵�������
	declare @enterMan nvarchar(30), @checkMan nvarchar(30)
	set @enterMan = isnull((select cName from userInfo where jobNumber = @enterManID),'')
	set @checkMan = isnull((select userCName from activeUsers where userID = @checkManID),'')

	update AReportEnterMans
	set checkManID = @checkManID, checkMan = @checkMan, arriveTime = null, isLate = 0
	where aReportID = @aReportID and applyManID = @enterManID

	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@checkManID, @checkMan, GETDATE(), 'ȡ��ѧ�����浽��', '�û�' + @checkMan
												+ '��['+@enterMan+']����Ϊδ����ѧ������['+@aReportID+']��')
GO
--���ԣ�
declare @checkManID varchar(10) 
set @checkManID='0000000000'
declare @Ret		int 
exec dbo.cancelCheckEnterAReport 'BG20120038','0005',@checkManID output, @Ret output
select @Ret

select * from AReportEnterMans


drop PROCEDURE aReportIsOver
/*
	name:		aReportIsOver
	function:	15.��ָ����ѧ����������Ϊ���״̬
	input: 
				@aReportID varchar(10),			--ѧ��������
				@overManID varchar(10) output,	--����趨�ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ѧ�����治���ڣ�2��ָ����ѧ��������������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-3
	UpdateDate: 

*/
create PROCEDURE aReportIsOver
	@aReportID varchar(10),			--ѧ��������
	@overManID varchar(10) output,	--����趨�ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ��ɵ�ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID= @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from academicReports where aReportID= @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @overManID)
	begin
		set @overManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @overMan nvarchar(30)
	set @overMan = isnull((select userCName from activeUsers where userID = @overManID),'')

	declare @overTime smalldatetime
	set @overTime = GETDATE()
	update academicReports 
	set isOver = 1,
		--����ά�����:
		modiManID = @overManID, modiManName = @overMan, modiTime = @overTime
	where aReportID= @aReportID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@overManID, @overMan, @overTime, '��ɷ���ѧ������', '�û�' + @overMan
												+ '��ѧ������['+@aReportID+']����Ϊ���״̬��')

GO


DROP PROCEDURE setAReportToTop
/*
	name:		setAReportToTop
	function:	20.��ָ�����ѷ�����ѧ�������ö�
	input: 
				@aReportID varchar(10),			--ѧ��������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ö���ѧ�����治���ڣ�2:Ҫ�ö���ѧ���������ڱ����˱༭��3.��ѧ������δ���
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-3-20
	UpdateDate: 
*/
create PROCEDURE setAReportToTop
	@aReportID varchar(10),			--ѧ��������

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID = @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isPublish int
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish from academicReports where aReportID = @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--���ѧ������״̬:
	if (@isPublish <> 1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--���ѷ�����ѧ��������������
	declare @tab table
					(
						aReportID varchar(10) not null,			--ѧ��������
						orderNum smallint default(-1)			--��ʾ�����
					)
	insert @tab
	select aReportID, orderNum from academicReports 
	where isPublish =1 and aReportID <> @aReportID
	order by orderNum
	begin tran
		declare @bID char(12), @i int
		set @i = 1
		declare tar cursor for
		select aReportID from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @bID
		WHILE @@FETCH_STATUS = 0
		begin
			update academicReports
			set orderNum = @i
			where aReportID = @bID
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
		--��ָ����ѧ�������ö���	
		update academicReports
		set orderNum = 0
		where aReportID = @aReportID
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
	values(@modiManID, @modiManName, getdate(), 'ѧ�������ö�', '�û�' + @modiManName 
												+ '��ѧ������['+ @aReportID +']�ö���')
GO
--���ԣ�
select * from academicReports
declare @Ret int 
exec dbo.setAReportToTop '201111260001', '00200977', @Ret output

DROP PROCEDURE setAReportToLast
/*
	name:		setAReportToLast
	function:	21.��ָ�����ѷ�����ѧ����������һ��
	input: 
				@aReportID varchar(10),			--ѧ��������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ƶ���ѧ�����治���ڣ�2:Ҫ�ƶ���ѧ���������ڱ����˱༭��3.��ѧ������δ���
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-3-20
	UpdateDate: 
*/
create PROCEDURE setAReportToLast
	@aReportID varchar(10),			--ѧ��������

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID = @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isPublish int
	declare @myOrderNum smallint --��ѧ������������
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish, @myOrderNum = orderNum from academicReports where aReportID = @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--���ѧ������״̬:
	if (@isPublish <> 1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--���ѷ�����λ���ڱ�ѧ������ǰ���ѧ��������������
	declare @tab table
					(
						aReportID char(12) not null,			--ѧ��������
						orderNum smallint default(-1)			--��ʾ�����
					)
	insert @tab
	select aReportID, orderNum from academicReports 
	where isPublish =1 and orderNum < @myOrderNum
	order by orderNum
	
	begin tran
		declare @bID char(12), @i int
		set @i = 1
		declare tar cursor for
		select aReportID from @tab
		order by orderNum
		OPEN tar
		FETCH NEXT FROM tar INTO @bID
		WHILE @@FETCH_STATUS = 0
		begin
			update academicReports
			set orderNum = @i
			where aReportID = @bID
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
		--��ָ����ѧ����������һ�У�	
		update academicReports
		set orderNum = @i
		where aReportID = @bID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		update academicReports
		set orderNum = @i - 1
		where aReportID = @aReportID
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
	values(@modiManID, @modiManName, getdate(), 'ѧ����������һ��', '�û�' + @modiManName 
												+ '��ѧ������['+ @aReportID +']������һ�С�')
GO
--���ԣ�
select * from academicReports 
where isPublish =1 
order by orderNum

declare @updateTime smalldatetime 
declare @Ret int 
exec dbo.setAReportToLast '201111270001', '00200977', @Ret output

DROP PROCEDURE setAReportToNext
/*
	name:		setAReportToNext
	function:	22.��ָ�����ѷ�����ѧ����������һ��
	input: 
				@aReportID varchar(10),			--ѧ��������

				--ά�����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�ƶ���ѧ�����治���ڣ�2:Ҫ�ƶ���ѧ���������ڱ����˱༭��3.��ѧ������δ���
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-3-20
	UpdateDate: 
*/
create PROCEDURE setAReportToNext
	@aReportID varchar(10),			--ѧ��������

	--ά�����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰѧ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������ѧ�������Ƿ����
	declare @count as int
	set @count=(select count(*) from academicReports where aReportID = @aReportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	declare @isPublish int
	declare @myOrderNum smallint --��ѧ������������
	select @thisLockMan = isnull(lockManID,''), @isPublish = isPublish, @myOrderNum = orderNum from academicReports where aReportID = @aReportID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--���ѧ������״̬:
	if (@isPublish <> 1)
	begin
		set @Ret = 3
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--����ѧ����������һ��ѧ�����潻��λ�ã�
	declare @nextBulletinID char(12), @nextOrderNum smallint
	select top 1 @nextBulletinID = aReportID, @nextOrderNum = orderNum 
	from academicReports 
	where isPublish =1 and orderNum > @myOrderNum
	order by orderNum
	
	if (@nextBulletinID is not null)
	begin
		begin tran
			update academicReports 
			set orderNum = @nextOrderNum
			where aReportID = @aReportID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			update academicReports 
			set orderNum = @myOrderNum
			where aReportID = @nextBulletinID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		commit tran
	end
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, getdate(), 'ѧ����������һ��', '�û�' + @modiManName 
												+ '��ѧ������['+ @aReportID +']������һ�С�')
GO
--���ԣ�
select * from academicReports 
where isPublish =1 
order by orderNum

declare @updateTime smalldatetime 
declare @Ret int 
exec dbo.setBulletinToNext '201111270001', '00200977', @Ret output


drop PROCEDURE closeTimeOutAcademicReports
/*
	name:		closeTimeOutAcademicReports
	function:	23.�Զ��رյ��ڵ�ѧ�����棨��������Ǹ�ά���ƻ������ã��û����ð�װ��
	input: 
	output: 
	author:		¬έ
	CreateDate:	2013-07-14
	UpdateDate:
*/
create PROCEDURE closeTimeOutAcademicReports
	WITH ENCRYPTION 
AS
	declare @count as int
	set @count=(select count(*) from academicReports where isPublish =1 and isOver=0 and convert(varchar(10),reportStartTime,120) <= convert(varchar(10),getdate(),120))	
	if (@count = 0)	--������
	begin
		return
	end

	update academicReports
	set isOver = 1
	where isPublish =1 and isOver=0 and convert(varchar(10),reportStartTime,120) <= convert(varchar(10),getdate(),120)

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values('', 'System', getdate(), '�Զ��رյ���ѧ������', 'ϵͳִ�����Զ��رյ���ѧ������ļƻ��ر���'+cast(@count as varchar(10))+'�����ڵ�ѧ�����档')
GO




--ѧ�������ѯ��䣺
select a.aReportID, a.topic, a.reportManID, a.reportMan, 
	convert(varchar(19),a.reportStartTime,120) reportStartTime, 
	convert(varchar(19),a.reportEndTime,120) reportEndTime, a.summary,
	a.reportPlaceID, a.reportPlace, a.placeIsReady,
	a.needEqpCodes, a.needEqpNames, a.eqpIsReady
from academicReports a


--������Ա��ѯ��䣺
select m.aReportID, a.topic, convert(varchar(19),a.reportStartTime,120) reportStartTime, 
	convert(varchar(19),a.reportEndTime,120) reportEndTime, 
	m.applyManID, m.applyMan, convert(varchar(10),applyTime,120) applyTime, 
	checkManID, checkMan, convert(varchar(19),m.arriveTime,120) arriveTime, isLate
from AReportEnterMans m
left join academicReports a on m.aReportID = a.aReportID
