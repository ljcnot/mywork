use hustOA
/*
	ǿ�ų����İ칫ϵͳ-���ع���
	author:		¬έ
	CreateDate:	2013-1-7
	UpdateDate: 
*/
--1.����һ����
select * from placeInfo
drop table placeInfo
CREATE TABLE placeInfo(
	placeID varchar(10) not null,		--���������ر��,��ϵͳʹ�õ�50�ź��뷢����������'CD'+4λ��ݴ���+4λ��ˮ�ţ�
	placeName nvarchar(30) null,		--��������
	placeMapFile varchar(128) null,		--��������ͼ�ļ�·��
	buildDate smalldatetime null,		--���ؽ�������
	scrappedDate smalldatetime null,	--���ط�ֹ����
	keeperID varchar(10) null,			--�����˹���
	keeper nvarchar(30) null,			--������:�������
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_placeInfo] PRIMARY KEY CLUSTERED 
(
	[placeID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--2.����ʹ�������
drop table placeApplyInfo
CREATE TABLE placeApplyInfo(
	applyID varchar(10) not null,		--����������ʹ�����뵥��,��ϵͳʹ�õ�51�ź��뷢����������'CA'+4λ��ݴ���+4λ��ˮ�ţ�
	placeID varchar(10) not null,		--���ر�ţ���ʹ�������������ʷ����
	placeName nvarchar(30) null,		--�������ƣ������ֶ�
	applyManID varchar(10) not null,	--�����˹���
	applerMan nvarchar(30) not null,	--����������
	applyTime smalldatetime null,		--��������
	usedTime smalldatetime null,		--����ʹ������
	timeBlock xml null,					--����ʹ��ʱ�Σ�����--<root>
															--	<timeBlock>8</timeBlock>
															--	<timeBlock>9</timeBlock>
															--</root>
										--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��0~23
	applyReason nvarchar(300) null,		--��������
	applyStatus smallint default(0),	--��������״̬��0->δ����1->����׼��-1������׼
	linkInvoiceType smallint default(0),--�������ݣ�0->δ֪��1->ѧ�����棬2->���飬9->���� 
	linkInvoice varchar(12) null,		--�������ݺ�
	
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
 CONSTRAINT [PK_placeApplyInfo] PRIMARY KEY CLUSTERED 
(
	[applyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--����ID������
CREATE NONCLUSTERED INDEX [IX_placeApplyInfo] ON [dbo].[placeApplyInfo] 
(
	[placeID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--��������ʹ������״̬������
CREATE NONCLUSTERED INDEX [IX_placeApplyInfo_1] ON [dbo].[placeApplyInfo] 
(
	[placeID] ASC,
	[usedTime] ASC,
	[applyStatus] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



drop PROCEDURE queryPlaceInfoLocMan
/*
	name:		queryPlaceInfoLocMan
	function:	1.��ѯָ�������Ƿ��������ڱ༭
	input: 
				@placeID varchar(10),		--���ر��
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���ĳ��ز�����
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-1-7
	UpdateDate: 
*/
create PROCEDURE queryPlaceInfoLocMan
	@placeID varchar(10),		--���ر��
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from placeInfo where placeID= @placeID),'')
	set @Ret = 0
GO


drop PROCEDURE lockPlaceInfo4Edit
/*
	name:		lockPlaceInfo4Edit
	function:	2.�������ر༭������༭��ͻ
	input: 
				@placeID varchar(10),			--���ر��
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����ĳ��ز����ڣ�2:Ҫ�����ĳ������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-7
	UpdateDate: 
*/
create PROCEDURE lockPlaceInfo4Edit
	@placeID varchar(10),		--���ر��
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ĳ����Ƿ����
	declare @count as int
	set @count=(select count(*) from placeInfo where placeID= @placeID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from placeInfo where placeID= @placeID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update placeInfo
	set lockManID = @lockManID 
	where placeID= @placeID
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
	values(@lockManID, @lockManName, getdate(), '�������ر༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˳���['+ @placeID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockPlaceInfoEditor
/*
	name:		unlockPlaceInfoEditor
	function:	3.�ͷų��ر༭��
				ע�⣺�����̲���鳡���Ƿ���ڣ�
	input: 
				@placeID varchar(10),			--���ر��
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-7
	UpdateDate: 
*/
create PROCEDURE unlockPlaceInfoEditor
	@placeID varchar(10),			--���ر��
	@lockManID varchar(10) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from placeInfo where placeID= @placeID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update placeInfo set lockManID = '' where placeID= @placeID
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
	values(@lockManID, @lockManName, getdate(), '�ͷų��ر༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˳���['+ @placeID +']�ı༭����')
GO

drop PROCEDURE addPlaceInfo
/*
	name:		addPlaceInfo
	function:	4.��ӳ�����Ϣ
	input: 
				@placeName nvarchar(30),		--��������
				@placeMapFile varchar(128),		--��������ͼ�ļ�·��
				@buildDate varchar(10),			--���ؽ�������:���á�yyyy-MM-dd����ʽ����
				@keeperID varchar(10),			--�����˹���

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@placeID varchar(10) output		--���ر�ţ���ϵͳʹ�õ�50�ź��뷢����������'CD'+4λ��ݴ���+4λ��ˮ�ţ�
	author:		¬έ
	CreateDate:	2013-1-7
	UpdateDate: 
*/
create PROCEDURE addPlaceInfo
	@placeName nvarchar(30),		--��������
	@placeMapFile varchar(128),		--��������ͼ�ļ�·��
	@buildDate varchar(10),			--���ؽ�������:���á�yyyy-MM-dd����ʽ����
	@keeperID varchar(10),			--�����˹���

	@createManID varchar(10),		--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@placeID varchar(10) output		--���ر�ţ���ϵͳʹ�õ�50�ź��뷢����������'CD'+4λ��ݴ���+4λ��ˮ�ţ�
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢�����������ر�ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 50, 1, @curNumber output
	set @placeID = @curNumber

	--ȡ������/�����˵�������
	declare @keeper nvarchar(30), @createManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert placeInfo(placeID, placeName, placeMapFile, buildDate, keeperID, keeper,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@placeID, @placeName, @placeMapFile, @buildDate, @keeperID, @keeper,
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
	values(@createManID, @createManName, @createTime, '�Ǽǳ���', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ��˳��ء�' + @placeName + '['+@placeID+']����')
GO
--���ԣ�
declare	@Ret		int
declare	@createTime smalldatetime
declare	@placeID varchar(10)
exec dbo.addPlaceInfo '������3', '', '2013-1-13','G201300001','00002', @Ret output, @createTime output, @placeID output
select @Ret, @placeID

select * from placeInfo

drop PROCEDURE updatePlaceInfo
/*
	name:		updatePlaceInfo
	function:	5.�޸ĳ�����Ϣ
	input: 
				@placeID varchar(10),			--���ر��
				@placeName nvarchar(30),		--��������
				@placeMapFile varchar(128),		--��������ͼ�ļ�·��
				@buildDate varchar(10),			--���ؽ�������:���á�yyyy-MM-dd����ʽ����
				@keeperID varchar(10),			--�����˹���

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵĳ��ز����ڣ�
							2:Ҫ�޸ĵĳ����������������༭��
							9:δ֪����
				@modiTime smalldatetime output	--�޸�ʱ��
	author:		¬έ
	CreateDate:	2013-1-7
	UpdateDate: 
*/
create PROCEDURE updatePlaceInfo
	@placeID varchar(10),			--���ر��
	@placeName nvarchar(30),		--��������
	@placeMapFile varchar(128),		--��������ͼ�ļ�·��
	@buildDate varchar(10),			--���ؽ�������:���á�yyyy-MM-dd����ʽ����
	@keeperID varchar(10),			--�����˹���

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����ĳ����Ƿ����
	declare @count as int
	set @count=(select count(*) from placeInfo where placeID= @placeID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from placeInfo where placeID= @placeID
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
	update placeInfo
	set placeName = @placeName, placeMapFile = @placeMapFile,
		buildDate=@buildDate, keeperID = @keeperID, keeper = @keeper,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where placeID= @placeID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸ĳ���', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸��˳��ء�' + @placeName + '['+@placeID+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delPlaceInfo
/*
	name:		delPlaceInfo
	function:	6.ɾ��ָ���ĳ���
	input: 
				@placeID varchar(10),			--���ر��
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĳ��ز����ڣ�2��Ҫɾ���ĳ�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-7
	UpdateDate: 

*/
create PROCEDURE delPlaceInfo
	@placeID varchar(10),			--���ر��
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����ĳ����Ƿ����
	declare @count as int
	set @count=(select count(*) from placeInfo where placeID= @placeID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from placeInfo where placeID= @placeID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete placeInfo where placeID= @placeID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ���˳���['+@placeID+']��')

GO

drop PROCEDURE stopPlaceInfo
/*
	name:		stopPlaceInfo
	function:	7.ͣ��ָ���ĳ���
	input: 
				@placeID varchar(10),			--���ر��
				@stopManID varchar(10) output,	--ͣ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĳ��ز����ڣ�2��Ҫͣ�õĳ�����������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 

*/
create PROCEDURE stopPlaceInfo
	@placeID varchar(10),			--���ر��
	@stopManID varchar(10) output,	--ͣ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫͣ�õĳ����Ƿ����
	declare @count as int
	set @count=(select count(*) from placeInfo where placeID= @placeID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from placeInfo where placeID= @placeID
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end

	update placeInfo 
	set scrappedDate = GETDATE()
	where placeID= @placeID
	set @Ret = 0

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, getdate(), 'ͣ�ó���', '�û�' + @stopManName
												+ 'ͣ���˳���['+@placeID+']��')

GO

----------------------------------------------������������------------------------------------------------------
drop PROCEDURE queryPlaceApplyLocMan
/*
	name:		queryPlaceApplyLocMan
	function:	11.��ѯָ���������뵥�Ƿ��������ڱ༭
	input: 
				@applyID varchar(10),		--�������뵥���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���ĳ������뵥������
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-1-8
	UpdateDate: 
*/
create PROCEDURE queryPlaceApplyLocMan
	@applyID varchar(10),		--�������뵥���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from placeApplyInfo where applyID= @applyID),'')
	set @Ret = 0
GO


drop PROCEDURE lockPlaceApply4Edit
/*
	name:		lockPlaceApply4Edit
	function:	12.�����������뵥�༭������༭��ͻ
	input: 
				@applyID varchar(10),		--�������뵥���
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����ĳ������뵥�����ڣ�2:Ҫ�����ĳ������뵥���ڱ����˱༭��
							3:�õ����Ѿ����������ܱ༭������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-8
	UpdateDate: 
*/
create PROCEDURE lockPlaceApply4Edit
	@applyID varchar(10),		--�������뵥���
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ĳ������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from placeApply where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from placeApplyInfo 
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

	update placeApplyInfo
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
	values(@lockManID, @lockManName, getdate(), '������������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˳�������['+ @applyID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockPlaceApplyEditor
/*
	name:		unlockPlaceApplyEditor
	function:	13.�ͷų������뵥�༭��
				ע�⣺�����̲���鳡�����뵥�Ƿ���ڣ�
	input: 
				@applyID varchar(10),			--�������뵥���
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-8
	UpdateDate: 
*/
create PROCEDURE unlockPlaceApplyEditor
	@applyID varchar(10),			--�������뵥���
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from placeApplyInfo where applyID= @applyID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update placeApplyInfo set lockManID = '' where applyID= @applyID
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
	values(@lockManID, @lockManName, getdate(), '�ͷų�������༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˳������뵥['+ @applyID +']�ı༭����')
GO

drop PROCEDURE addPlaceApply
/*
	name:		addPlaceApply
	function:	14.��ӳ������뵥
	input: 
				@placeID varchar(10),		--���ر�ţ���ʹ�������������ʷ����
				@applyManID varchar(10),	--�����˹���
				@applyTime varchar(10),		--�������ڣ�����"yyyy-MM-dd"��ʽ����
				@usedTime varchar(10),		--����ʹ�����ڣ�����"yyyy-MM-dd"��ʽ����
				@timeBlock xml,				--����ʹ��ʱ�Σ�����--<root>
																	--	<timeBlock>8</timeBlock>
																	--	<timeBlock>9</timeBlock>
																	--</root>
												--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��0~23
				@applyReason nvarchar(300),	--��������
				@linkInvoiceType smallint,	--�����������ͣ�0->δ֪��1->ѧ�����棬2->���飬9->���� 
				@linkInvoice varchar(12),	--�������ݺ�

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@applyID varchar(10) output	--�������뵥��ţ���ϵͳʹ�õ�51�ź��뷢����������'CA'+4λ��ݴ���+4λ��ˮ�ţ�
	author:		¬έ
	CreateDate:	2013-1-8
	UpdateDate: 
*/
create PROCEDURE addPlaceApply
	@placeID varchar(10),		--���ر�ţ���ʹ�������������ʷ����
	@applyManID varchar(10),	--�����˹���
	@applyTime varchar(10),		--�������ڣ�����"yyyy-MM-dd"��ʽ����
	@usedTime varchar(10),		--����ʹ�����ڣ�����"yyyy-MM-dd"��ʽ����
	@timeBlock xml,				--����ʹ��ʱ�Σ�����--<root>
														--	<timeBlock>8</timeBlock>
														--	<timeBlock>9</timeBlock>
														--</root>
									--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��0~23
	@applyReason nvarchar(300),	--��������
	@linkInvoiceType smallint,	--�����������ͣ�0->δ֪��1->ѧ�����棬2->���飬9->���� 
	@linkInvoice varchar(12),	--�������ݺ�
	
	@createManID varchar(10),	--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@applyID varchar(10) output	--�������뵥��ţ���ϵͳʹ�õ�51�ź��뷢����������'CA'+4λ��ݴ���+4λ��ˮ�ţ�
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢�����������ر�ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 51, 1, @curNumber output
	set @applyID = @curNumber
	
	--ȡ�������ƣ�
	declare @placeName nvarchar(30)		--��������
	set @placeName = isnull((select placeName from placeInfo where placeID = @placeID),'')
	--ȡ�����˵�������
	declare @createManName nvarchar(30), @applerMan nvarchar(30)	--����������
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @applerMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	
	set @createTime = getdate()
	insert placeApplyInfo(applyID, placeID, placeName, applyManID, applerMan, 
						applyTime, usedTime, timeBlock,
						applyReason, linkInvoiceType, linkInvoice,
						--����ά�����:
						modiManID, modiManName, modiTime)
	values(@applyID, @placeID, @placeName, @applyManID, @applerMan, 
			@applyTime, @usedTime, @timeBlock,
			@applyReason, @linkInvoiceType, @linkInvoice,
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
	values(@createManID, @createManName, @createTime, '�Ǽǳ�������', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ��˳��ء�' + @placeName + '�������뵥['+@applyID+']����')
GO
--���ԣ�
declare	@Ret		int
declare	@createTime smalldatetime
declare	@applyID varchar(10)
exec dbo.addPlaceApply 'CD20130002', '00002', '2013-01-08', '2013-01-9',
	N'<root>
		<timeBlock>9</timeBlock>
		<timeBlock>10</timeBlock>
		<timeBlock>11</timeBlock>
	</root>',
	'�ٿ���֪�����','','','00002',
	 @Ret output, @createTime output, @applyID output
select @Ret, @applyID
select * from placeApplyInfo

drop PROCEDURE updatePlaceApply
/*
	name:		updatePlaceApply
	function:	15.�޸ĳ������뵥��Ϣ
	input: 
				@applyID varchar(10),		--�������뵥���
				@placeID varchar(10),		--���ر�ţ���ʹ�������������ʷ����
				@applyManID varchar(10),	--�����˹���
				@applyTime varchar(10),		--�������ڣ�����"yyyy-MM-dd"��ʽ����
				@usedTime varchar(10),		--����ʹ�����ڣ�����"yyyy-MM-dd"��ʽ����
				@timeBlock xml,				--����ʹ��ʱ�Σ�����--<root>
																	--	<timeBlock>8</timeBlock>
																	--	<timeBlock>9</timeBlock>
																	--</root>
												--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��0~23
				@applyReason nvarchar(300),	--��������
				@linkInvoiceType smallint,	--�����������ͣ�0->δ֪��1->ѧ�����棬2->���飬9->���� 
				@linkInvoice varchar(12),	--�������ݺ�

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
	CreateDate:	2013-1-8
	UpdateDate: 
*/
create PROCEDURE updatePlaceApply
	@applyID varchar(10),		--�������뵥���
	@placeID varchar(10),		--���ر�ţ���ʹ�������������ʷ����
	@applyManID varchar(10),	--�����˹���
	@applyTime varchar(10),		--�������ڣ�����"yyyy-MM-dd"��ʽ����
	@usedTime varchar(10),		--����ʹ�����ڣ�����"yyyy-MM-dd"��ʽ����
	@timeBlock xml,				--����ʹ��ʱ�Σ�����--<root>
														--	<timeBlock>8</timeBlock>
														--	<timeBlock>9</timeBlock>
														--</root>
									--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��0~23
	@applyReason nvarchar(300),	--��������
	@linkInvoiceType smallint,	--�����������ͣ�0->δ֪��1->ѧ�����棬2->���飬9->���� 
	@linkInvoice varchar(12),	--�������ݺ�

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--ע�⣺����û���������Ƿ���ڵ��жϣ�

	--�ж�Ҫ�����ĳ������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from placeApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from placeApplyInfo 
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

	--ȡ�������ƣ�
	declare @placeName nvarchar(30)		--��������
	set @placeName = isnull((select placeName from placeInfo where placeID = @placeID),'')
	--ȡά����/�����˵�������
	declare @modiManName nvarchar(30), @applerMan nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	set @applerMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')

	set @modiTime = getdate()
	update placeApplyInfo
	set placeID = @placeID, placeName = @placeName,
		applyManID = @applyManID, applerMan = @applerMan, 
		applyTime = @applyTime, usedTime = @usedTime, timeBlock = @timeBlock,
		applyReason = @applyReason, linkInvoiceType = @linkInvoiceType, linkInvoice = @linkInvoice,
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
	values(@modiManID, @modiManName, @modiTime, '�޸ĳ�������', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸��˳��ء�' + @placeName + '�������뵥['+@applyID+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delPlaceApply
/*
	name:		delPlaceApply
	function:	16.ɾ��ָ���ĳ������뵥
	input: 
				@applyID varchar(10),			--�������뵥���
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĳ������뵥�����ڣ�2��Ҫɾ���ĳ������뵥��������������
							3���õ����Ѿ�����������ɾ����
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-8
	UpdateDate: 

*/
create PROCEDURE delPlaceApply
	@applyID varchar(10),			--�������뵥���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����ĳ������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from placeApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from placeApplyInfo 
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

	delete placeApplyInfo where applyID= @applyID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ����������', '�û�' + @delManName
												+ 'ɾ���˳������뵥['+@applyID+']��')

GO

drop PROCEDURE approvePlaceApply
/*
	name:		approvePlaceApply
	function:	17.����ָ���ĳ������뵥
	input: 
				@applyID varchar(10),				--�������뵥���
				@isAgree smallint,					--�Ƿ�ͬ�⣺1->ͬ��,-1����ͬ��
				@approveOpinion nvarchar(300),		--�������
				@approveManID varchar(10) output,	--�����ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output				--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĳ������뵥�����ڣ�2��Ҫ�����ĳ������뵥��������������
							3���ó������뵥�Ѿ�������4:��ִ�й������ݵĲ���ʱ����
							5���õ��������ʱ����Ѿ���ռ�ã�
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-8
	UpdateDate: 

*/
create PROCEDURE approvePlaceApply
	@applyID varchar(10),				--�������뵥���
	@isAgree smallint,					--�Ƿ�ͬ�⣺1->ͬ��,-1����ͬ��
	@approveOpinion nvarchar(300),		--�������
	@approveManID varchar(10) output,	--�����ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����ĳ������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from placeApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	declare @usedTime smalldatetime, @placeID varchar(10)	--ʹ��ʱ�䡢����ID
	declare @linkInvoiceType smallint, @linkInvoice varchar(12)--�����������ͣ�0->δ֪��1->ѧ�����棬2->���飬9->���� /�������ݺ�
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus, @placeID = placeID, @usedTime = usedTime,
		@linkInvoiceType = linkInvoiceType, @linkInvoice = linkInvoice
	from placeApplyInfo 
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
	declare @usedBlock table(placeID varchar(10), block varchar(4))	--����׼���õ�ʱ���
	insert @usedBlock(placeID, block)
	select p.placeID, cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
	from placeApplyInfo p 
	CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
	where convert(varchar(10),p.usedTime,120)=convert(varchar(10),@usedTime,120) and placeID=@placeID and p.applyStatus = 1
	order by timeB;
	
	WITH CTE	--���������ʱ���
	AS ( 
		select p.placeID, cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
		from placeApplyInfo p 
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
	update placeApplyInfo
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
	values(@approveManID, @approveMan, @approveTime, '������������', '�û�' + @approveMan
												+ '�����˳������뵥['+@applyID+']��')
	
	--���ù������ݣ�
	declare @execRet int
	if (@linkInvoiceType=1)	--1->ѧ������
	begin
		exec dbo.placeIsReady4AReport @linkInvoice, @execRet output
		if (@execRet <> 0)
			set @Ret = 4
	end
	else if (@linkInvoiceType=2)--2->����
	begin
		exec dbo.placeIsReady4Meeting @linkInvoice, @execRet output
		if (@execRet <> 0)
			set @Ret = 4
	end

GO
select * from placeApplyInfo
declare @usedTime smalldatetime
set @usedTime = '2013-01-29'
declare @usedBlock table(placeID varchar(10), block varchar(4))	--����׼���õ�ʱ���
insert @usedBlock(placeID, block)
select p.placeID, cast(T2.timeBlock.query('./text()') as varchar(4)) timeB
from placeApplyInfo p 
CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
where convert(varchar(10),p.usedTime,120)=convert(varchar(10),@usedTime,120) and p.applyStatus = 1
order by timeB;
select * from @usedBlock

select * from placeApplyInfo
where applyID='CA20130141'

use hustOA
--���صĲ�ѯ��䣺
select * from placeInfo
select * from placeApplyInfo

use hustOA
--����ʹ��������ѯ��䣺��xml��ʾʱ���
select applyID, placeID, placeName, applyManID, applerMan, applyTime, 
	usedTime, timeBlock,					--����ʹ��ʱ�Σ�����--<root>
											--	<timeBlock>8</timeBlock>
											--	<timeBlock>9</timeBlock>
											--</root>
										--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��0~23
	applyReason, applyStatus, linkInvoiceType, linkInvoice, approveTime, approveManID, approveMan, approveOpinion
from placeApplyInfo

insert placeApplyInfo(applyID, placeID, placeName, applyManID, applerMan, applyTime, 
	usedTime, timeBlock,					--����ʹ��ʱ�Σ�����--<root>
											--	<timeBlock>8</timeBlock>
											--	<timeBlock>9</timeBlock>
											--</root>
										--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��0~23
	applyReason)
values('CA20130002','cd20130002','������','00002','���','2013-01-07','2013-01-08',
	N'<root>' +
		'<timeBlock>14</timeBlock>'+
		'<timeBlock>15</timeBlock>'+
		'<timeBlock>16</timeBlock>'+
	'</root>',
	'ѧ������')

--����ʹ��������ѯ��䣺ʱ���ת��Ϊ�м�
select a.placeID, a.placeName, p.applyID, p.placeID, p.placeName, p.applyManID, p.applerMan, p.applyTime, p.usedTime, 
	p.applyReason, p.applyStatus, p.linkInvoiceType, p.linkInvoice, p.approveTime, p.approveManID, p.approveMan, p.approveOpinion,
	cast(cast(T2.timeBlock.query('./text()') as varchar(4)) as int) timeB
from placeInfo a left join (placeApplyInfo p 
CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)) on a.placeID = p.placeID 
order by a.placeID, timeB

--����ʱ��״̬��ѯ��䣺
select p.placeID, p.placeName, p.applyID, p.applyManID, p.applerMan, p.applyTime, p.usedTime, 
	p.applyReason, p.applyStatus, 
	cast(cast(T2.timeBlock.query('./text()') as varchar(4)) as int) timeB
from placeApplyInfo p CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
where p.applyStatus <> -1
order by p.placeID, timeB, p.applyStatus



select applyID, placeID, placeName, applyManID, applerMan, applyTime, 
	usedTime, timeBlock,					--����ʹ��ʱ�Σ�����--<root>
											--	<timeBlock>8</timeBlock>
											--	<timeBlock>9</timeBlock>
											--</root>
										--��ʽ��š�timeBlock�е����ֱ�ʾʱ�Σ�ȡֵ��Χ��0~23
	applyReason, applyStatus, linkInvoiceType, linkInvoice, approveTime, approveManID, approveMan, approveOpinion
from placeApplyInfo
order by applyID desc




select p.applyID, p.placeID, p.placeName, p.applyManID, p.applerMan, p.applyTime, p.usedTime,
p.applyReason, p.applyStatus,
cast(cast(T2.timeBlock.query('./text()') as varchar(4)) as int) timeB
from placeApplyInfo p 
CROSS APPLY timeBlock.nodes('/root/timeBlock') as T2(timeBlock)
where p.applyStatus <> -1
order by p.applyID, timeB, p.applyStatus


update placeApplyInfo
set applyStatus = 1
where applyID = 'CA20130002'

use hustoa
select messageID, messageType, messageLevel, senderID, sender, sendTime, isSend, receiverID, receiver, messageBody from messageInfo where isSend=0



select applyID, placeID, placeName, applyManID, applerMan, 
applyTime,usedTime, timeBlock,applyReason, applyStatus, linkInvoiceType, linkInvoice, 
approveTime, approveManID, approveMan, approveOpinion 
from placeApplyInfo 
where applyID = 'CD20130023' 
order by applyID desc


use hustOA
select * from placeApplyInfo
delete placeApplyInfo where applyID ='CA20130031'

