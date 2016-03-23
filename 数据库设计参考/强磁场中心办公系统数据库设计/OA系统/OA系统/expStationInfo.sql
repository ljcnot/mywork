use hustOA
/*
	ǿ�ų����İ칫ϵͳ-����վ����
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 
*/
--1.����վһ����
select * from expStationInfo
drop table expStationInfo
CREATE TABLE expStationInfo(
	expStationID varchar(10) not null,		--����������վ���,��ϵͳʹ�õ�55�ź��뷢����������'SY'+4λ��ݴ���+4λ��ˮ�ţ�
	expStationName nvarchar(30) null,		--����վ����
	expStationMapFile varchar(128) null,	--����վ����ͼ�ļ�·��
	buildDate smalldatetime null,			--����վ��������
	scrappedDate smalldatetime null,		--����վ��ֹ����
	keeperID varchar(10) null,				--�����˹���
	keeper nvarchar(30) null,				--������:�������
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_expStationInfo] PRIMARY KEY CLUSTERED 
(
	[expStationID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--2.����վʹ�������
drop table expStationApplyInfo
CREATE TABLE expStationApplyInfo(
	applyID varchar(10) not null,		--����������վʹ�����뵥��,��ϵͳʹ�õ�51�ź��뷢����������'CA'+4λ��ݴ���+4λ��ˮ�ţ�
	expStationID varchar(10) not null,	--����վ��ţ���ʹ�������������ʷ����
	expStationName nvarchar(30) null,	--����վ���ƣ������ֶ�
	applyManID varchar(10) not null,	--�����˹���
	applerMan nvarchar(30) not null,	--����������
	applyTime smalldatetime null,		--��������
	usedTime smalldatetime null,		--����ʹ������
	timeBlock xml null,					--����ʹ��ʱ�Σ�����--<root>
															--	<timeBlock>A</timeBlock>
															--	<timeBlock>B</timeBlock>
															--</root>
										--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��A->���磬B->���磬C->����
	applyReason nvarchar(300) null,		--��������
	applyStatus smallint default(0),	--��������״̬��0->δ����1->����׼��-1������׼
	
	approveTime smalldatetime null,		--��׼ʱ��
	approveManID varchar(10) null,		--��׼�˹���
	approveMan nvarchar(30) null,		--��׼���������������
	approveOpinion nvarchar(300) null,	--�������

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_expStationApplyInfo] PRIMARY KEY CLUSTERED 
(
	[applyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--����վID������
CREATE NONCLUSTERED INDEX [IX_expStationApplyInfo] ON [dbo].[expStationApplyInfo] 
(
	[expStationID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--����վ����ʹ������״̬������
CREATE NONCLUSTERED INDEX [IX_expStationApplyInfo_1] ON [dbo].[expStationApplyInfo] 
(
	[expStationID] ASC,
	[usedTime] ASC,
	[applyStatus] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



drop PROCEDURE queryExpStationLocMan
/*
	name:		queryExpStationLocMan
	function:	1.��ѯָ������վ�Ƿ��������ڱ༭
	input: 
				@expStationID varchar(10),		--����վ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ��������վ������
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE queryExpStationLocMan
	@expStationID varchar(10),		--����վ���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from expStationInfo where expStationID= @expStationID),'')
	set @Ret = 0
GO


drop PROCEDURE lockExpStation4Edit
/*
	name:		lockExpStation4Edit
	function:	2.��������վ�༭������༭��ͻ
	input: 
				@expStationID varchar(10),		--����վ���
				@lockManID varchar(10) output,	--�����ˣ������ǰ����վ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��Ҫ����������վ�����ڣ�2:Ҫ����������վ���ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE lockExpStation4Edit
	@expStationID varchar(10),		--����վ���
	@lockManID varchar(10) output,	--�����ˣ������ǰ����վ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ����������վ�Ƿ����
	declare @count as int
	set @count=(select count(*) from expStationInfo where expStationID= @expStationID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from expStationInfo where expStationID= @expStationID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update expStationInfo
	set lockManID = @lockManID 
	where expStationID= @expStationID
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
	values(@lockManID, @lockManName, getdate(), '��������վ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ������������վ['+ @expStationID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockExpStationEditor
/*
	name:		unlockExpStationEditor
	function:	3.�ͷ�����վ�༭��
				ע�⣺�����̲��������վ�Ƿ���ڣ�
	input: 
				@expStationID varchar(10),		--����վ���
				@lockManID varchar(10) output,	--�����ˣ������ǰ����վ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE unlockExpStationEditor
	@expStationID varchar(10),		--����վ���
	@lockManID varchar(10) output,	--�����ˣ������ǰ����վ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from expStationInfo where expStationID= @expStationID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update expStationInfo set lockManID = '' where expStationID= @expStationID
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�����վ�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ�������վ['+ @expStationID +']�ı༭����')
GO

drop PROCEDURE addExpStation
/*
	name:		addExpStation
	function:	4.�������վ��Ϣ
	input: 
				@expStationName nvarchar(30),	--����վ����
				@expStationMapFile varchar(128),--����վ����ͼ�ļ�·��
				@buildDate varchar(10),				--����վ��������:���á�yyyy-MM-dd����ʽ����
				@keeperID varchar(10),			--�����˹���

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@expStationID varchar(10) output--����վ��ţ���ϵͳʹ�õ�55�ź��뷢����������'SY'+4λ��ݴ���+4λ��ˮ�ţ�
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE addExpStation
	@expStationName nvarchar(30),		--����վ����
	@expStationMapFile varchar(128),	--����վ����ͼ�ļ�·��
	@buildDate varchar(10),				--����վ��������:���á�yyyy-MM-dd����ʽ����
	@keeperID varchar(10),				--�����˹���

	@createManID varchar(10),			--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@expStationID varchar(10) output	--����վ��ţ���ϵͳʹ�õ�55�ź��뷢����������'SY'+4λ��ݴ���+4λ��ˮ�ţ�
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢������������վ��ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 55, 1, @curNumber output
	set @expStationID = @curNumber

	--ȡ������/�����˵�������
	declare @keeper nvarchar(30), @createManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert expStationInfo(expStationID, expStationName, expStationMapFile, buildDate, keeperID, keeper,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@expStationID, @expStationName, @expStationMapFile, @buildDate, @keeperID, @keeper,
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
	values(@createManID, @createManName, @createTime, '�Ǽ�����վ', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ�������վ��' + @expStationName + '['+@expStationID+']����')
GO
--���ԣ�
declare	@Ret		int
declare	@createTime smalldatetime
declare	@expStationID varchar(10)
exec dbo.addExpStation '����վ3', '', '2013-1-13','G201300001','00002', @Ret output, @createTime output, @expStationID output
select @Ret, @expStationID
select * from expStationInfo

drop PROCEDURE updateExpStation
/*
	name:		updateExpStation
	function:	5.�޸�����վ��Ϣ
	input: 
				@expStationID varchar(10),			--����վ���
				@expStationName nvarchar(30),		--����վ����
				@expStationMapFile varchar(128),	--����վ����ͼ�ļ�·��
				@buildDate varchar(10),				--����վ��������:���á�yyyy-MM-dd����ʽ����
				@keeperID varchar(10),				--�����˹���

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ�����վ�����ڣ�
							2:Ҫ�޸ĵ�����վ�������������༭��
							9:δ֪����
				@modiTime smalldatetime output	--�޸�ʱ��
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE updateExpStation
	@expStationID varchar(10),		--����վ���
	@expStationName nvarchar(30),	--����վ����
	@expStationMapFile varchar(128),--����վ����ͼ�ļ�·��
	@buildDate varchar(10),			--����վ��������:���á�yyyy-MM-dd����ʽ����
	@keeperID varchar(10),			--�����˹���

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ����������վ�Ƿ����
	declare @count as int
	set @count=(select count(*) from expStationInfo where expStationID= @expStationID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from expStationInfo where expStationID= @expStationID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡ������/ά���˵�������
	declare @keeper nvarchar(30), @modiManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')


	set @modiTime = getdate()
	update expStationInfo
	set expStationName = @expStationName, expStationMapFile = @expStationMapFile,
		buildDate=@buildDate, keeperID = @keeperID, keeper = @keeper,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where expStationID= @expStationID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸�����վ', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸�������վ��' + @expStationName + '['+@expStationID+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delExpStation
/*
	name:		delExpStation
	function:	6.ɾ��ָ��������վ
	input: 
				@expStationID varchar(10),		--����վ���
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ����վ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ��������վ�����ڣ�2��Ҫɾ��������վ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 

*/
create PROCEDURE delExpStation
	@expStationID varchar(10),			--����վ���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ����վ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ����������վ�Ƿ����
	declare @count as int
	set @count=(select count(*) from expStationInfo where expStationID= @expStationID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from expStationInfo where expStationID= @expStationID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete expStationInfo where expStationID= @expStationID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������վ', '�û�' + @delManName
												+ 'ɾ��������վ['+@expStationID+']��')

GO

drop PROCEDURE stopExpStation
/*
	name:		stopExpStation
	function:	7.ͣ��ָ��������վ
	input: 
				@expStationID varchar(10),		--����վ���
				@stopManID varchar(10) output,	--ͣ���ˣ������ǰ����վ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ��������վ�����ڣ�2��Ҫͣ�õ�����վ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 

*/
create PROCEDURE stopExpStation
	@expStationID varchar(10),		--����վ���
	@stopManID varchar(10) output,	--ͣ���ˣ������ǰ����վ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫͣ�õ�����վ�Ƿ����
	declare @count as int
	set @count=(select count(*) from expStationInfo where expStationID= @expStationID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from expStationInfo where expStationID= @expStationID
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete expStationInfo where expStationID= @expStationID
	set @Ret = 0

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, getdate(), 'ͣ������վ', '�û�' + @stopManName
												+ 'ͣ��������վ['+@expStationID+']��')

GO
----------------------------------------------����վ��������------------------------------------------------------
drop PROCEDURE queryExpStationApplyLocMan
/*
	name:		queryExpStationApplyLocMan
	function:	11.��ѯָ������վ���뵥�Ƿ��������ڱ༭
	input: 
				@applyID varchar(10),		--����վ���뵥���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ��������վ���뵥������
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE queryExpStationApplyLocMan
	@applyID varchar(10),		--����վ���뵥���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from expStationApplyInfo where applyID= @applyID),'')
	set @Ret = 0
GO


drop PROCEDURE lockExpStationApply4Edit
/*
	name:		lockExpStationApply4Edit
	function:	12.��������վ���뵥�༭������༭��ͻ
	input: 
				@applyID varchar(10),			--����վ���뵥���
				@lockManID varchar(10) output,	--�����ˣ������ǰ����վ���뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ����������վ���뵥�����ڣ�2:Ҫ����������վ���뵥���ڱ����˱༭��
							3:�õ����Ѿ����������ܱ༭������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE lockExpStationApply4Edit
	@applyID varchar(10),		--����վ���뵥���
	@lockManID varchar(10) output,	--�����ˣ������ǰ����վ���뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ����������վ���뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from expStationApply where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from expStationApplyInfo 
	where applyID= @applyID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬��
	if (@applyStatus<>0)
	begin
		set @Ret = 3
		return
	end

	update expStationApplyInfo
	set lockManID = @lockManID 
	where applyID= @applyID
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
	values(@lockManID, @lockManName, getdate(), '��������վ����༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ������������վ����['+ @applyID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockExpStationApplyEditor
/*
	name:		unlockExpStationApplyEditor
	function:	13.�ͷ�����վ���뵥�༭��
				ע�⣺�����̲��������վ���뵥�Ƿ���ڣ�
	input: 
				@applyID varchar(10),			--����վ���뵥���
				@lockManID varchar(10) output,	--�����ˣ������ǰ����վ���뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE unlockExpStationApplyEditor
	@applyID varchar(10),			--����վ���뵥���
	@lockManID varchar(10) output,	--�����ˣ������ǰ����վ���뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from expStationApplyInfo where applyID= @applyID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update expStationApplyInfo set lockManID = '' where applyID= @applyID
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�����վ����༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ�������վ���뵥['+ @applyID +']�ı༭����')
GO

drop PROCEDURE addExpStationApply
/*
	name:		addExpStationApply
	function:	14.�������վ���뵥
	input: 
				@expStationID varchar(10),		--����վ��ţ���ʹ�������������ʷ����
				@applyManID varchar(10),	--�����˹���
				@applyTime varchar(10),		--�������ڣ�����"yyyy-MM-dd"��ʽ����
				@usedTime varchar(10),		--����ʹ�����ڣ�����"yyyy-MM-dd"��ʽ����
				@timeBlock xml,				--����ʹ��ʱ�Σ�����--<root>
																--	<timeBlock>A</timeBlock>
																--	<timeBlock>B</timeBlock>
																--</root>
											--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��A->���磬B->���磬C->����
				@applyReason nvarchar(300),	--��������

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@applyID varchar(10) output	--����վ���뵥�ţ���ϵͳʹ�õ�56�ź��뷢����������'SA'+4λ��ݴ���+4λ��ˮ�ţ�
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE addExpStationApply
	@expStationID varchar(10),		--����վ��ţ���ʹ�������������ʷ����
	@applyManID varchar(10),	--�����˹���
	@applyTime varchar(10),		--�������ڣ�����"yyyy-MM-dd"��ʽ����
	@usedTime varchar(10),		--����ʹ�����ڣ�����"yyyy-MM-dd"��ʽ����
	@timeBlock xml,				--����ʹ��ʱ�Σ�����--<root>
													--	<timeBlock>A</timeBlock>
													--	<timeBlock>B</timeBlock>
													--</root>
								--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��A->���磬B->���磬C->����
	@applyReason nvarchar(300),	--��������
	
	@createManID varchar(10),	--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@applyID varchar(10) output	--����վ���뵥�ţ���ϵͳʹ�õ�56�ź��뷢����������'SA'+4λ��ݴ���+4λ��ˮ�ţ�
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢������������վ��ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 56, 1, @curNumber output
	set @applyID = @curNumber
	
	--ȡ����վ���ƣ�
	declare @expStationName nvarchar(30)		--����վ����
	set @expStationName = isnull((select expStationName from expStationInfo where expStationID = @expStationID),'')
	--ȡ�����˵�������
	declare @createManName nvarchar(30), @applerMan nvarchar(30)	--����������
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @applerMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	
	set @createTime = getdate()
	insert expStationApplyInfo(applyID, expStationID, expStationName, applyManID, applerMan, 
						applyTime, usedTime, timeBlock, applyReason, 
						--����ά�����:
						modiManID, modiManName, modiTime)
	values(@applyID, @expStationID, @expStationName, @applyManID, @applerMan, 
			@applyTime, @usedTime, @timeBlock, @applyReason,
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
	values(@createManID, @createManName, @createTime, '�Ǽ�����վ����', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ�������վ��' + @expStationName + '�������뵥['+@applyID+']����')
GO
--���ԣ�
declare	@Ret		int
declare	@createTime smalldatetime
declare	@applyID varchar(10)
exec dbo.addExpStationApply 'SY20130001', '00002', '2013-01-08', '2013-01-9',
	N'<root>
		<timeBlock>B</timeBlock>
	</root>',
	'1.ʵ�飻2.ʵ��','00002',
	 @Ret output, @createTime output, @applyID output
select @Ret, @applyID
select * from expStationApplyInfo

drop PROCEDURE updateExpStationApply
/*
	name:		updateExpStationApply
	function:	15.�޸�����վ���뵥��Ϣ
	input: 
				@applyID varchar(10),		--����վ���뵥���
				@expStationID varchar(10),	--����վ��ţ���ʹ�������������ʷ����
				@applyManID varchar(10),	--�����˹���
				@applyTime varchar(10),		--�������ڣ�����"yyyy-MM-dd"��ʽ����
				@usedTime varchar(10),		--����ʹ�����ڣ�����"yyyy-MM-dd"��ʽ����
				@timeBlock xml,				--����ʹ��ʱ�Σ�����--<root>
																--	<timeBlock>A</timeBlock>
																--	<timeBlock>B</timeBlock>
																--</root>
											--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��A->���磬B->���磬C->����
				@applyReason nvarchar(300),	--��������

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵĵ��ݲ����ڣ�
							2:Ҫ�޸ĵĵ����������������༭��
							3:�õ����Ѿ������������޸�
							9:δ֪����
				@modiTime smalldatetime output	--�޸�ʱ��
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 
*/
create PROCEDURE updateExpStationApply
	@applyID varchar(10),		--����վ���뵥���
	@expStationID varchar(10),	--����վ��ţ���ʹ�������������ʷ����
	@applyManID varchar(10),	--�����˹���
	@applyTime varchar(10),		--�������ڣ�����"yyyy-MM-dd"��ʽ����
	@usedTime varchar(10),		--����ʹ�����ڣ�����"yyyy-MM-dd"��ʽ����
	@timeBlock xml,				--����ʹ��ʱ�Σ�����--<root>
													--	<timeBlock>A</timeBlock>
													--	<timeBlock>B</timeBlock>
													--</root>
								--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��A->���磬B->���磬C->����
	@applyReason nvarchar(300),	--��������

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--ע�⣺����û��������վ�Ƿ���ڵ��жϣ�

	--�ж�Ҫ����������վ���뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from expStationApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from expStationApplyInfo 
	where applyID= @applyID
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬��
	if (@applyStatus<>0)
	begin
		set @Ret = 3
		return
	end

	--ȡ����վ���ƣ�
	declare @expStationName nvarchar(30)		--����վ����
	set @expStationName = isnull((select expStationName from expStationInfo where expStationID = @expStationID),'')
	--ȡά����/�����˵�������
	declare @modiManName nvarchar(30), @applerMan nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	set @applerMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')

	set @modiTime = getdate()
	update expStationApplyInfo
	set expStationID = @expStationID, expStationName = @expStationName,
		applyManID = @applyManID, applerMan = @applerMan, 
		applyTime = @applyTime, usedTime = @usedTime, timeBlock = @timeBlock,
		applyReason = @applyReason, 
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where applyID= @applyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸�����վ����', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸�������վ��' + @expStationName + '�������뵥['+@applyID+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delExpStationApply
/*
	name:		delExpStationApply
	function:	16.ɾ��ָ��������վ���뵥
	input: 
				@applyID varchar(10),			--����վ���뵥���
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ����վ���뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ��������վ���뵥�����ڣ�2��Ҫɾ��������վ���뵥��������������
							3���õ����Ѿ�����������ɾ����
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 

*/
create PROCEDURE delExpStationApply
	@applyID varchar(10),			--����վ���뵥���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ����վ���뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ����������վ���뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from expStationApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from expStationApplyInfo 
	where applyID= @applyID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬��
	if (@applyStatus<>0)
	begin
		set @Ret = 3
		return
	end

	delete expStationApplyInfo where applyID= @applyID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������վ����', '�û�' + @delManName
												+ 'ɾ��������վ���뵥['+@applyID+']��')

GO

drop PROCEDURE approveExpStationApply
/*
	name:		approveExpStationApply
	function:	17.����ָ��������վ���뵥
	input: 
				@applyID varchar(10),				--����վ���뵥���
				@isAgree smallint,					--�Ƿ�ͬ�⣺1->ͬ��,-1����ͬ��
				@approveOpinion nvarchar(300),		--�������
				@approveManID varchar(10) output,	--�����ˣ������ǰ����վ���뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output				--�����ɹ���ʶ
							0:�ɹ���1��ָ��������վ���뵥�����ڣ�2��Ҫ����������վ���뵥��������������
							3��������վ���뵥�Ѿ�������4:��ִ�й������ݵĲ���ʱ����
							5���õ��������ʱ����Ѿ���ռ�ã�
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 

*/
create PROCEDURE approveExpStationApply
	@applyID varchar(10),				--����վ���뵥���
	@isAgree smallint,					--�Ƿ�ͬ�⣺1->ͬ��,-1����ͬ��
	@approveOpinion nvarchar(300),		--�������
	@approveManID varchar(10) output,	--�����ˣ������ǰ����վ���뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ����������վ���뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from expStationApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	declare @usedTime smalldatetime
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus, @usedTime = usedTime
	from expStationApplyInfo 
	where applyID= @applyID
	if (@thisLockMan <> '' and @thisLockMan <> @approveManID)
	begin
		set @approveManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬��
	if (@applyStatus<>0)
	begin
		set @Ret = 3
		return
	end
	--���ʱ����Ƿ��г�ͻ��
	declare @usedBlock table(expStationID varchar(10), block varchar(4))
	insert @usedBlock(expStationID, block)
	select p.expStationID, cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
	from expStationApplyInfo p 
	CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
	where convert(varchar(10),p.usedTime,120)=convert(varchar(10),@usedTime,120) and p.applyStatus = 1
	order by timeB;
	WITH CTE
	AS ( 
		select p.expStationID, cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
		from expStationApplyInfo p 
		CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
		where p.applyID = @applyID
	)
	select @count = count(*) from CTE where timeB in (select block from @usedBlock)
	if (@count > 0)	--��ͻ
	begin
		set @Ret = 5
		return
	end

	--ȡ�����˵�������
	declare @approveMan nvarchar(30)
	set @approveMan = isnull((select userCName from activeUsers where userID = @approveManID),'')
	
	declare @approveTime smalldatetime
	set @approveTime = GETDATE()
	update expStationApplyInfo
	set applyStatus = @isAgree,approveTime = @approveTime,
		approveManID = @approveManID, approveMan = @approveMan, approveOpinion = @approveOpinion
	where applyID= @applyID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@approveManID, @approveMan, @approveTime, '��������վ����', '�û�' + @approveMan
												+ '����������վ���뵥['+@applyID+']��')
GO
--���ԣ�
declare @Ret int	--�����ɹ���ʶ
exec dbo.approveExpStationApply 'SA20130003', 1, 'ͬ��', 'G20130001', @Ret output
select @Ret

select * from expStationApplyInfo



--����վ�Ĳ�ѯ��䣺
select expStationID, expStationName, expStationMapFile
from expStationInfo

use hustOA
--����վʹ��������ѯ��䣺��xml��ʾʱ���
select applyID, expStationID, expStationName, applyManID, applerMan, applyTime, 
	usedTime, timeBlock,					--����ʹ��ʱ�Σ�����--<root>
											--	<timeBlock>A</timeBlock>
											--	<timeBlock>B</timeBlock>
											--</root>
										--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��A->���磬B->����,C->����
	applyReason, applyStatus, approveTime, approveManID, approveMan, approveOpinion
from expStationApplyInfo


--����վʹ��������ѯ��䣺ʱ���ת��Ϊ�м�
select a.expStationID, a.expStationName, p.applyID, p.expStationID, p.expStationName, p.applyManID, p.applerMan, p.applyTime, p.usedTime, 
	p.applyReason, p.applyStatus, p.approveTime, p.approveManID, p.approveMan, p.approveOpinion,
	cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
from expStationInfo a left join (expStationApplyInfo p 
CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)) on a.expStationID = p.expStationID 
order by a.expStationID, timeB

--����վʱ��״̬��ѯ��䣺
select p.applyID, p.expStationID, p.expStationName, p.applyManID, p.applerMan, p.applyTime, p.usedTime,
p.applyReason, p.applyStatus,
cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
from expStationApplyInfo p 
CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
where convert(varchar(10),p.usedTime,120)='2013-1-13' and p.applyStatus <> -1
order by timeB, p.applyStatus


select applyID, expStationID, expStationName, applyManID, applerMan, applyTime, 
	usedTime, timeBlock,					--����ʹ��ʱ�Σ�����--<root>
											--	<timeBlock>8</timeBlock>
											--	<timeBlock>9</timeBlock>
											--</root>
										--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��0~23
	applyReason, applyStatus, approveTime, approveManID, approveMan, approveOpinion
from expStationApplyInfo
order by applyID desc





select expStationID, expStationName, expStationMapFile, buildDate, keeperID, keeper
from expStationInfo
order by expStationID
