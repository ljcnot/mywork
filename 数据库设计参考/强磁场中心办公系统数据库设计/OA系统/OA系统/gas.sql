use hustOA
/*
	ǿ�ų����İ칫ϵͳ-�������
	author:		¬έ
	CreateDate:	2013-1-13
	UpdateDate: 
*/
--1.����һ����
alter TABLE gasInfo add	gasUnit nvarchar(4) null		--������λ
update gasInfo
set gasUnit='L'

select * from gasInfo
drop table gasInfo
CREATE TABLE gasInfo(
	gasID varchar(10) not null,		--������������,��ϵͳʹ�õ�60�ź��뷢����������'QT'+4λ��ݴ���+4λ��ˮ�ţ�
	gasName nvarchar(30) null,		--��������
	gasUnit nvarchar(4) null,		--������λ
	buildDate smalldatetime null,	--���彨������
	scrappedDate smalldatetime null,--�����ֹ����
	keeperID varchar(10) null,		--�����˹���
	keeper nvarchar(30) null,		--������:�������
	
	--����ά�����:
	modiManID varchar(10) null,		--ά���˹���
	modiManName nvarchar(30) null,	--ά��������
	modiTime smalldatetime null,	--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),			--��ǰ���������༭���˹���
 CONSTRAINT [PK_gasInfo] PRIMARY KEY CLUSTERED 
(
	[gasID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--2.����ÿ�մ�������һ����
alter table gasStock add	applyID varchar(10) null		--����ʹ�����뵥��,��������ʱ��дadd by lw 2013-3-24
select * from gasStock
drop table gasStock
CREATE TABLE gasStock(
	rowNum int IDENTITY(1,1) NOT NULL,	--��ţ�����ʹ��
	gasID varchar(10) not null,		--�����������
	gasName nvarchar(30) null,		--�������ƣ��������
	applyID varchar(10) null,		--����ʹ�����뵥��,��������ʱ��д,Ϊ֧��������ĵ��ݼ�������add by lw 2013-3-24
	theDate smalldatetime not null,	--����
	stockQuantity int default(0),	--���������ָ��ӵ�����,��λ��L
	usedQuantity int default(0),	--��������λ��L

 CONSTRAINT [PK_gasStock] PRIMARY KEY CLUSTERED 
(
	[gasID] ASC,
	[theDate] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[gasStock] WITH CHECK ADD CONSTRAINT [FK_gasStock_gasInfo] FOREIGN KEY([gasID])
REFERENCES [dbo].[gasInfo] ([gasID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[gasStock] CHECK CONSTRAINT [FK_gasStock_gasInfo] 
GO


--3.����ʹ�������
drop table gasApplyInfo
CREATE TABLE gasApplyInfo(
	applyID varchar(10) not null,		--����������ʹ�����뵥��,��ϵͳʹ�õ�61�ź��뷢����������'QA'+4λ��ݴ���+4λ��ˮ�ţ�
	gasID varchar(10) not null,			--�����ţ���ʹ�������������ʷ����
	gasName nvarchar(30) null,			--�������ƣ������ֶ�
	applyManID varchar(10) not null,	--�����˹���
	applerMan nvarchar(30) not null,	--����������
	applyTime smalldatetime null,		--��������
	usedTime smalldatetime null,		--����ʹ������
	applyQuantity int default(0),		--��������
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
 CONSTRAINT [PK_gasApplyInfo] PRIMARY KEY CLUSTERED 
(
	[applyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--����ID������
CREATE NONCLUSTERED INDEX [IX_gasApplyInfo] ON [dbo].[gasApplyInfo] 
(
	[gasID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--��������ʹ������״̬������
CREATE NONCLUSTERED INDEX [IX_gasApplyInfo_1] ON [dbo].[gasApplyInfo] 
(
	[gasID] ASC,
	[usedTime] ASC,
	[applyStatus] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



drop PROCEDURE queryGasInfoLocMan
/*
	name:		queryGasInfoLocMan
	function:	1.��ѯָ�������Ƿ��������ڱ༭
	input: 
				@gasID varchar(10),		--������
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ�������岻����
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE queryGasInfoLocMan
	@gasID varchar(10),		--������
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from gasInfo where gasID= @gasID),'')
	set @Ret = 0
GO


drop PROCEDURE lockGasInfo4Edit
/*
	name:		lockGasInfo4Edit
	function:	2.��������༭������༭��ͻ
	input: 
				@gasID varchar(10),				--������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���������岻���ڣ�2:Ҫ�������������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE lockGasInfo4Edit
	@gasID varchar(10),		--������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from gasInfo where gasID= @gasID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from gasInfo where gasID= @gasID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update gasInfo
	set lockManID = @lockManID 
	where gasID= @gasID
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
	values(@lockManID, @lockManName, getdate(), '��������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ������������['+ @gasID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockGasInfoEditor
/*
	name:		unlockGasInfoEditor
	function:	3.�ͷ�����༭��
				ע�⣺�����̲���������Ƿ���ڣ�
	input: 
				@gasID varchar(10),				--������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE unlockGasInfoEditor
	@gasID varchar(10),			--������
	@lockManID varchar(10) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from gasInfo where gasID= @gasID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update gasInfo set lockManID = '' where gasID= @gasID
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�����༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ�������['+ @gasID +']�ı༭����')
GO

drop PROCEDURE addGasInfo
/*
	name:		addGasInfo
	function:	4.���������Ϣ
	input: 
				@gasName nvarchar(30),		--��������
				@gasUnit nvarchar(4),		--������λ
				@buildDate varchar(10),		--���彨������:���á�yyyy-MM-dd����ʽ����
				@keeperID varchar(10),		--�����˹���

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@gasID varchar(10) output		--�����ţ���ϵͳʹ�õ�60�ź��뷢����������'qt'+4λ��ݴ���+4λ��ˮ�ţ�
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: modi by lw 2013-4-23���Ӽ�����λ
*/
create PROCEDURE addGasInfo
	@gasName nvarchar(30),		--��������
	@gasUnit nvarchar(4),		--������λ
	@buildDate varchar(10),		--���彨������:���á�yyyy-MM-dd����ʽ����
	@keeperID varchar(10),		--�����˹���

	@createManID varchar(10),		--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@gasID varchar(10) output		--�����ţ���ϵͳʹ�õ�60�ź��뷢����������'QT'+4λ��ݴ���+4λ��ˮ�ţ�
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢�������������ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 60, 1, @curNumber output
	set @gasID = @curNumber

	--ȡ������/�����˵�������
	declare @keeper nvarchar(30), @createManName nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert gasInfo(gasID, gasName, gasUnit, buildDate, keeperID, keeper,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@gasID, @gasName, @gasUnit, @buildDate, @keeperID, @keeper,
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
	values(@createManID, @createManName, @createTime, '�Ǽ�����', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ������塰' + @gasName + '['+@gasID+']����')
GO
--���ԣ�
declare	@Ret		int
declare	@createTime smalldatetime
declare	@gasID varchar(10)
exec dbo.addGasInfo 'He��', '2013-1-13','G201300001','00002', @Ret output, @createTime output, @gasID output
select @Ret, @gasID

select * from gasInfo

drop PROCEDURE updateGasInfo
/*
	name:		updateGasInfo
	function:	5.�޸�������Ϣ
	input: 
				@gasID varchar(10),			--������
				@gasName nvarchar(30),		--��������
				@gasUnit nvarchar(4),		--������λ
				@buildDate varchar(10),		--���彨������:���á�yyyy-MM-dd����ʽ����
				@keeperID varchar(10),		--�����˹���

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ����岻���ڣ�
							2:Ҫ�޸ĵ������������������༭��
							9:δ֪����
				@modiTime smalldatetime output	--�޸�ʱ��
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: modi by lw 2013-4-23���Ӽ�����λ
*/
create PROCEDURE updateGasInfo
	@gasID varchar(10),			--������
	@gasName nvarchar(30),		--��������
	@gasUnit nvarchar(4),		--������λ
	@buildDate varchar(10),		--���彨������:���á�yyyy-MM-dd����ʽ����
	@keeperID varchar(10),		--�����˹���

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from gasInfo where gasID= @gasID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from gasInfo where gasID= @gasID
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
	update gasInfo
	set gasName = @gasName, gasUnit = @gasUnit,
		buildDate=@buildDate, keeperID = @keeperID, keeper = @keeper,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where gasID= @gasID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸�����', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸������塰' + @gasName + '['+@gasID+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delGasInfo
/*
	name:		delGasInfo
	function:	6.ɾ��ָ��������
	input: 
				@gasID varchar(10),			--������
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������岻���ڣ�2��Ҫɾ����������������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: 

*/
create PROCEDURE delGasInfo
	@gasID varchar(10),			--������
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫɾ���������Ƿ����
	declare @count as int
	set @count=(select count(*) from gasInfo where gasID= @gasID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from gasInfo where gasID= @gasID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete gasInfo where gasID= @gasID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ��������['+@gasID+']��')

GO

drop PROCEDURE stopGasInfo
/*
	name:		stopGasInfo
	function:	7.ͣ��ָ��������
	input: 
				@gasID varchar(10),				--������
				@stopManID varchar(10) output,	--ͣ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������岻���ڣ�2��Ҫͣ�õ�������������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: 

*/
create PROCEDURE stopGasInfo
	@gasID varchar(10),				--������
	@stopManID varchar(10) output,	--ͣ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫͣ�õ������Ƿ����
	declare @count as int
	set @count=(select count(*) from gasInfo where gasID= @gasID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from gasInfo where gasID= @gasID
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end

	update gasInfo 
	set scrappedDate = GETDATE()
	where gasID= @gasID
	set @Ret = 0

	--ȡά���˵�������
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, getdate(), 'ͣ������', '�û�' + @stopManName
												+ 'ͣ��������['+@gasID+']��')

GO


drop PROCEDURE addGasStock
/*
	name:		addGasStock
	function:	8.���ָ��������ָ�����ڵĿ����
	input: 
				@gasID varchar(10),				--������
				@theDate varchar(10),			--ָ�������ڣ����á�yyyy-MM-dd����ʽ����
				@stockQuantity int,				--�����
				@addManID varchar(10) output,	--����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������岻���ڣ�2����������������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: 

*/
create PROCEDURE addGasStock
	@gasID varchar(10),				--������
	@theDate varchar(10),			--ָ�������ڣ����á�yyyy-MM-dd����ʽ����
	@stockQuantity int,				--�����
	@addManID varchar(10) output,	--����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫͣ�õ������Ƿ����
	declare @count as int
	set @count=(select count(*) from gasInfo where gasID= @gasID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10),@gasName nvarchar(30)
	select @thisLockMan = isnull(lockManID,''), @gasName = gasName from gasInfo where gasID= @gasID
	if (@thisLockMan <> '' and @thisLockMan <> @addManID)
	begin
		set @addManID = @thisLockMan
		set @Ret = 2
		return
	end

	--��ǰ��ʣ���������룺add by lw2013-3-24
	insert gasStock(gasID,gasName,theDate,stockQuantity)
	values(@gasID,@gasName,@theDate,@stockQuantity)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0

	--ȡά���˵�������
	declare @addManName nvarchar(30)
	set @addManName = isnull((select userCName from activeUsers where userID = @addManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@addManID, @addManName, getdate(), '�����������', '�û�' + @addManName
												+ '���������['+@gasName+']�Ŀ����['+STR(@stockQuantity,4)+']����')

GO
--���ԣ�
declare	@Ret		int --�����ɹ���ʶ
EXEC DBO.addGasStock 'QT20130004','2013-01-16', 200, 'G201300001', @Ret output
select @Ret

select * from gasInfo
----------------------------------------------������������------------------------------------------------------
drop PROCEDURE queryGasApplyLocMan
/*
	name:		queryGasApplyLocMan
	function:	11.��ѯָ���������뵥�Ƿ��������ڱ༭
	input: 
				@applyID varchar(10),		--�������뵥���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ�����������뵥������
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE queryGasApplyLocMan
	@applyID varchar(10),		--�������뵥���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from gasApplyInfo where applyID= @applyID),'')
	set @Ret = 0
GO


drop PROCEDURE lockGasApply4Edit
/*
	name:		lockGasApply4Edit
	function:	12.�����������뵥�༭������༭��ͻ
	input: 
				@applyID varchar(10),			--�������뵥���
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�������������뵥�����ڣ�2:Ҫ�������������뵥���ڱ����˱༭��
							3:�õ����Ѿ����������ܱ༭������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE lockGasApply4Edit
	@applyID varchar(10),		--�������뵥���
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from gasApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from gasApplyInfo 
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

	update gasApplyInfo
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
												+ '��Ҫ����������������['+ @applyID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockGasApplyEditor
/*
	name:		unlockGasApplyEditor
	function:	13.�ͷ��������뵥�༭��
				ע�⣺�����̲�����������뵥�Ƿ���ڣ�
	input: 
				@applyID varchar(10),			--�������뵥���
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE unlockGasApplyEditor
	@applyID varchar(10),			--�������뵥���
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from gasApplyInfo where applyID= @applyID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update gasApplyInfo set lockManID = '' where applyID= @applyID
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
	values(@lockManID, @lockManName, getdate(), '�ͷ���������༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ����������뵥['+ @applyID +']�ı༭����')
GO

drop PROCEDURE addGasApply
/*
	name:		addGasApply
	function:	14.����������뵥
	input: 
				@gasID varchar(10),			--�����ţ���ʹ�������������ʷ����
				@applyManID varchar(10),	--�����˹���
				@applyTime varchar(10),		--�������ڣ�����"yyyy-MM-dd"��ʽ����
				@usedTime varchar(10),		--����ʹ�����ڣ�����"yyyy-MM-dd"��ʽ����
				@applyQuantity int,			--��������
				@applyReason nvarchar(300),	--��������
				
				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@applyID varchar(10) output	--�������뵥��ţ���ϵͳʹ�õ�61�ź��뷢����������'QA'+4λ��ݴ���+4λ��ˮ�ţ�
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE addGasApply
	@gasID varchar(10),			--�����ţ���ʹ�������������ʷ����
	@applyManID varchar(10),	--�����˹���
	@applyTime varchar(10),		--�������ڣ�����"yyyy-MM-dd"��ʽ����
	@usedTime varchar(10),		--����ʹ�����ڣ�����"yyyy-MM-dd"��ʽ����
	@applyQuantity int,			--��������
	@applyReason nvarchar(300),	--��������
	
	@createManID varchar(10),	--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@applyID varchar(10) output	--�������뵥��ţ���ϵͳʹ�õ�61�ź��뷢����������'QA'+4λ��ݴ���+4λ��ˮ�ţ�
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢�������������ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 61, 1, @curNumber output
	set @applyID = @curNumber
	
	--ȡ�������ƣ�
	declare @gasName nvarchar(30)		--��������
	set @gasName = isnull((select gasName from gasInfo where gasID = @gasID),'')
	--ȡ�����˵�������
	declare @createManName nvarchar(30), @applerMan nvarchar(30)	--����������
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @applerMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	
	set @createTime = getdate()
	insert gasApplyInfo(applyID, gasID, gasName, applyManID, applerMan, 
						applyTime, usedTime, applyQuantity,
						applyReason,
						--����ά�����:
						modiManID, modiManName, modiTime)
	values(@applyID, @gasID, @gasName, @applyManID, @applerMan, 
			@applyTime, @usedTime, @applyQuantity,
			@applyReason,
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
	values(@createManID, @createManName, @createTime, '�Ǽ���������', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ������塰' + @gasName + '�������뵥['+@applyID+']����')
GO
--���ԣ�
declare	@Ret		int
declare	@createTime smalldatetime
declare	@applyID varchar(10)
exec dbo.addGasApply 'QT20130002', '00002', '2013-01-16', '2013-01-16',
	10,'������','00002',
	 @Ret output, @createTime output, @applyID output
select @Ret, @applyID
select * from gasApplyInfo

drop PROCEDURE updateGasApply
/*
	name:		updateGasApply
	function:	15.�޸��������뵥��Ϣ
	input: 
				@applyID varchar(10),		--�������뵥���
				@gasID varchar(10),		--�����ţ���ʹ�������������ʷ����
				@applyManID varchar(10),	--�����˹���
				@applyTime varchar(10),		--�������ڣ�����"yyyy-MM-dd"��ʽ����
				@usedTime varchar(10),		--����ʹ�����ڣ�����"yyyy-MM-dd"��ʽ����
				@applyQuantity int,			--��������
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
	CreateDate:	2013-1-14
	UpdateDate: 
*/
create PROCEDURE updateGasApply
	@applyID varchar(10),		--�������뵥���
	@gasID varchar(10),		--�����ţ���ʹ�������������ʷ����
	@applyManID varchar(10),	--�����˹���
	@applyTime varchar(10),		--�������ڣ�����"yyyy-MM-dd"��ʽ����
	@usedTime varchar(10),		--����ʹ�����ڣ�����"yyyy-MM-dd"��ʽ����
	@applyQuantity int,			--��������
	@applyReason nvarchar(300),	--��������

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--ע�⣺����û���������Ƿ���ڵ��жϣ�

	--�ж�Ҫ�������������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from gasApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from gasApplyInfo 
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
	declare @gasName nvarchar(30)		--��������
	set @gasName = isnull((select gasName from gasInfo where gasID = @gasID),'')
	--ȡά����/�����˵�������
	declare @modiManName nvarchar(30), @applerMan nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	set @applerMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')

	set @modiTime = getdate()
	update gasApplyInfo
	set gasID = @gasID, gasName = @gasName,
		applyManID = @applyManID, applerMan = @applerMan, 
		applyTime = @applyTime, usedTime = @usedTime, applyQuantity = @applyQuantity,
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
	values(@modiManID, @modiManName, @modiTime, '�޸���������', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸������塰' + @gasName + '�������뵥['+@applyID+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delGasApply
/*
	name:		delGasApply
	function:	16.ɾ��ָ�����������뵥
	input: 
				@applyID varchar(10),			--�������뵥���
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�����������뵥�����ڣ�2��Ҫɾ�����������뵥��������������
							3���õ����Ѿ�����������ɾ����
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: 

*/
create PROCEDURE delGasApply
	@applyID varchar(10),			--�������뵥���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫɾ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from gasApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from gasApplyInfo 
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

	delete gasApplyInfo where applyID= @applyID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ����������', '�û�' + @delManName
												+ 'ɾ�����������뵥['+@applyID+']��')

GO


drop PROCEDURE approveGasApply
/*
	name:		approveGasApply
	function:	17.����ָ�����������뵥
	input: 
				@applyID varchar(10),				--�������뵥���
				@isAgree smallint,					--�Ƿ�ͬ�⣺1->ͬ��,-1����ͬ��
				@approveOpinion nvarchar(300),		--�������
				@approveManID varchar(10) output,	--�����ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output				--�����ɹ���ʶ
							0:�ɹ���1��ָ�����������뵥�����ڣ�2��Ҫ�������������뵥��������������
							3�����������뵥�Ѿ�������
							4���õ�����������������������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-14
	UpdateDate: modi by lw 2013-3-24�޸��ڲ��߼�

*/
create PROCEDURE approveGasApply
	@applyID varchar(10),				--�������뵥���
	@isAgree smallint,					--�Ƿ�ͬ�⣺1->ͬ��,-1����ͬ��
	@approveOpinion nvarchar(300),		--�������
	@approveManID varchar(10) output,	--�����ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�������������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from gasApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	declare @gasID varchar(10), @gasName nvarchar(30)		--������������
	declare @usedTime smalldatetime, @applyQuantity	int		--����ʹ�����ڡ�����
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus, 
		@gasID = gasID, @gasName = gasName,
		@usedTime = usedTime, @applyQuantity = applyQuantity
	from gasApplyInfo 
	where applyID= @applyID
	if (@thisLockMan <> '' and @thisLockMan <> @approveManID)
	begin
		set @approveManID = @thisLockMan
		set @Ret = 2
		return
	end
	----��鵥��״̬���������Ա�޸�����
	--if (@applyStatus<>0)
	--begin
	--	set @Ret = 3
	--	return
	--end

	if (@isAgree=1)
	begin
		--���ʣ�����Ƿ񹻣�
		declare @leftQuantity int
		set @leftQuantity = isnull((select SUM(stockQuantity) - SUM(usedQuantity) 
									from gasStock 
									where convert(varchar(10),theDate,120)<= CONVERT(varchar(10),@usedTime,120)
										and gasID = @gasID),0)
		if (@applyQuantity > @leftQuantity)
		begin
			set @Ret = 4
			return
		end
	end
								
	--ȡ�����˵�������
	declare @approveMan nvarchar(30)
	set @approveMan = isnull((select userCName from activeUsers where userID = @approveManID),'')

	declare @approveTime smalldatetime
	set @approveTime = GETDATE()
	begin tran
		update gasApplyInfo
		set applyStatus = @isAgree,approveTime = @approveTime,
			approveManID = @approveManID, approveMan = @approveMan, approveOpinion = @approveOpinion
		where applyID= @applyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		set @Ret = 0
		
		--ɾ�����ܴ��ڵ���ǰͬ�����������
		delete gasStock where gasID = @gasID and applyID= @applyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		if (@isAgree=1)
		begin
			insert gasStock(gasID, gasName, applyID, theDate,usedQuantity)
			values(@gasID, @gasName, @applyID, @usedTime,@applyQuantity)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		end
	commit tran
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@approveManID, @approveMan, @approveTime, '������������', '�û�' + @approveMan
												+ '�������������뵥['+@applyID+']��')
GO



--���������Ϣ��ѯ��䣺
select gasID, gasName, convert(varchar(10),g.buildDate,120) buildDate, keeperID, keeper
from gasInfo g


--����ָ�����ڵĿ������ѯ��䣺
select g.gasID, g.gasName, g.buildDate, g.keeperID, g.keeper, 
	isnull(SUM(s.stockQuantity),0) stockQuantity, isnull(SUM(s.usedQuantity),0) usedQuantity, 
	isnull(SUM(s.stockQuantity),0) - isnull(SUM(s.usedQuantity),0) leftQuantity
from gasInfo g left join gasStock s on g.gasID = s.gasID and CONVERT(varchar(10),s.theDate,120) = '2013-01-16'
group by g.gasID, g.gasName, g.buildDate, g.keeperID, g.keeper

SELECT * FROM gasStock

--��ѯ���뵥��
select g.applyID, g.gasID, g.gasName, g.applyManID, g.applerMan, 
	convert(varchar(10),g.applyTime,120) applyTime, 
	convert(varchar(10),g.usedTime,120) usedTime, 
	g.applyQuantity, g.applyReason, g.applyStatus
from gasApplyInfo g
order by applyTime

select * from user

delete activeUsers