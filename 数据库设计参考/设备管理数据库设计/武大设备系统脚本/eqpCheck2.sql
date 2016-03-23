use epdc211
/*
	����豸������Ϣϵͳ-�豸�̵����
	ע�⣺�豸�̵�ָֻ���豸���ڵ�״̬�������ı��豸���κ�״̬������ͨ���̵�������豸�������Ӧ�������ͱ��ϵ���
	author:		¬έ
	CreateDate:	2011-11-20
	UpdateDate: 
*/

--1.�豸�̵���Ϣ��
--1.1�豸�̵��
select * from eqpCheckInfo2
drop TABLE eqpCheckInfo2
CREATE TABLE eqpCheckInfo2(
	checkNum char(12) not null,			--�������豸�̵��,ʹ��4�ź��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	applyDate smalldatetime not null,	--�̵㿪ʼʱ��
	expCompleteDate smalldatetime not null,	--Ԥ�����ʱ�� add by lw 2012-7-27
	applyState int default(0),			--�豸��飨�̵㣩��״̬��0->�½���1->����Ч��2->������
	
	--��飨�̵㣩��Χ��
	clgCode char(3) not null,			--ѧԺ����
	clgName nvarchar(30) not null,		--ѧԺ���ƣ������ֶΣ����ǿ��Խ�����ʷ����	add by lw 2012-5-4
	uCode varchar(8) null,				--ʹ�õ�λ����
	uName nvarchar(30) null,			--ʹ�õ�λ����:�����ֶΣ����ǿ��Ա�����ʷ����add by lw 2012-5-4
	
	checkerID varchar(10) not null,		--�̵㸺���˹���
	checker nvarchar(30) not null,		--�̵㸺����

	verifyManID varchar(10) null,		--��ˣ���Ч���˹���
	verifyMan nvarchar(30) null,		--�����
	verifyDate smalldatetime null,		--�����Чʱ��

	notes nvarchar(100) null,			--��ע
	
	--ͳ����Ϣ��
	staffNumOfLocation int null,		--���ʱ��Ժ������ʹ�õ�λ���������� add by lw 2012-7-27
	eqpNumber int null,					--��飨�̵㣩���豸����
	eqpCheckedNumber int null,			--�Ѿ�ȷ�Ϲ����豸����
	eqpWaitCheckNumber int null,		--��ȷ���豸����
	eqpNoKeeperNumber int null,			--û�б����˵��豸����
	eqpUploadedPhotoNumber int null,	--���ϴ���Ƭ���豸����
	eqpNotExistNumber int null,			--��ȷΪ����������������״̬���豸
	eqpNeedMaintainNumber int null,		--��ȷΪ�����ޡ�״̬���豸
	eqpNeedScrapNumber int null,		--��ȷΪ�������ϡ�״̬���豸
	eqpNormalNumber int null,			--��ȷΪ��������״̬���豸
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_eqpCheckInfo2] PRIMARY KEY CLUSTERED 
(
	[checkNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--�̵㿪ʼ����������
CREATE NONCLUSTERED INDEX [IX_eqpCheckInfo2] ON [dbo].[eqpCheckInfo2] 
(
	[applyDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�̵���Ч����������
CREATE NONCLUSTERED INDEX [IX_eqpCheckInfo2_1] ON [dbo].[eqpCheckInfo2] 
(
	[verifyDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�̵���������
CREATE NONCLUSTERED INDEX [IX_eqpCheckInfo2_2] ON [dbo].[eqpCheckInfo2] 
(
	[checkerID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�����������
CREATE NONCLUSTERED INDEX [IX_eqpCheckInfo2_3] ON [dbo].[eqpCheckInfo2] 
(
	[verifyManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--1.2�豸�̵���ϸ��
select * from eqpCheckDetailInfo2
drop TABLE eqpCheckDetailInfo2
CREATE TABLE eqpCheckDetailInfo2(
	checkNum char(12) not null,			--������豸��鵥��
	eCode char(8) not null,				--�豸��ţ�����Ƴ�����������豸����ɾ���豸�󱻶�ɾ������ʷ��Ϣ��
	eName nvarchar(30) not null,		--�豸����:�������
	lockKeeper smallint default(0),		--�Ƿ����������ˣ�
													--0->δ������
													--1->ǰ���б����ˡ����豸����Աָ���˱�����(�Ѿ�ָ���˱�����)
													--2->ϵͳʹ�������Զ�ƥ�䵽Ψһ�ı����ˣ�
													--9��>������ȷ��
	keeperID varchar(10) null,			--�����˹���
	keeper nvarchar(30) null,			--������
	eqpLocate nvarchar(100) null,		--�豸���ڵ�ַ
	checkDate smalldatetime null,		--ȷ������
	checkStatus char(1) not null,		--���ʱ���豸״̬��
										--0��״̬����
										--1��������
										--3�����ޣ�
										--4�������ϣ�
										--5���������
										--6���������--����״̬Ӧ���޷�ȷ����
										--9��������
	statusNotes nvarchar(100) null,		--�豸��״˵��
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_eqpCheckDetailInfo2] PRIMARY KEY CLUSTERED 
(
	[checkNum] ASC,
	[eCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[eqpCheckDetailInfo2] WITH CHECK ADD CONSTRAINT [FK_eqpCheckDetailInfo2_eqpCheckInfo2] FOREIGN KEY([checkNum])
REFERENCES [dbo].[eqpCheckInfo2] ([checkNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpCheckDetailInfo2] CHECK CONSTRAINT [FK_eqpCheckDetailInfo2_eqpCheckInfo2]
GO
--������
--�̵�����������
CREATE NONCLUSTERED INDEX [IX_eqpCheckDetailInfo2_1] ON [dbo].[eqpCheckDetailInfo2]
(
	[checkDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--������������
CREATE NONCLUSTERED INDEX [IX_eqpCheckDetailInfo2_2] ON [dbo].[eqpCheckDetailInfo2]
(
	[keeperID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

delete eqpCheckPhoto
select * from eqpCheckPhoto
--1.3�豸��״��Ƭ�����������ϸ���һ������
--ͼƬ�ļ�����eqpCheckPhoto/201111,��Ŀ¼Ϊ�ϴ������ڵ�����
drop TABLE eqpCheckPhoto
CREATE TABLE eqpCheckPhoto(
	checkNum char(12) not null,			--������豸��鵥��
	eCode char(8) not null,				--���:�豸���
	eName nvarchar(30) not null,		--�豸����:�������
	rowNum bigint IDENTITY(1,1) NOT NULL,--����:���
	photoDate smalldatetime not null,	--��������
	aFilename varchar(128) not NULL,	--������ͼƬ�ļ���Ӧ��36λȫ��Ψһ�����ļ���
	notes nvarchar(100) null,			--˵��
 CONSTRAINT [PK_eqpCheckPhoto] PRIMARY KEY CLUSTERED 
(
	[checkNum] ASC,
	[eCode] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[eqpCheckPhoto]  WITH CHECK ADD  CONSTRAINT [FK_eqpCheckPhoto_eqpCheckDetailInfo] FOREIGN KEY([checkNum], [eCode])
REFERENCES [dbo].[eqpCheckDetailInfo2] ([checkNum], [eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpCheckPhoto] CHECK CONSTRAINT [FK_eqpCheckPhoto_eqpCheckDetailInfo]
GO
--������
--ͼƬ��������
CREATE NONCLUSTERED INDEX [IX_eqpCheckPhoto] ON [dbo].[eqpCheckPhoto]
(
	[aFilename] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE buildCheckApply
/*
	name:		buildCheckApply
	function:	1.�����豸��飨�̵㣩��
				ע�⣺�ô洢���̲���������
	input: 
				@applyDate varchar(10),		--�̵㿪ʼʱ��
				@expCompleteDate varchar(10),--Ԥ�����ʱ�� add by lw 2012-7-27
				@clgCode char(3),			--ѧԺ����
				@uCode varchar(8),			--ʹ�õ�λ����
				@checkerID varchar(10),		--��鸺���ˣ��̵��ˣ����� add by lw 2012-7-27
				@notes nvarchar(100),		--��ע

				@createManID varchar(10),	--������(����Ա)����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ����������豸���ڱ����˱༭�򱻳�����������9:δ֪����
				@createTime smalldatetime output	--���ʱ��
				@checkNum char(12) output			--���ɵ��豸�̵��,ʹ��4�ź��뷢��������
	author:		¬έ
	CreateDate:	2011-11-22
	UpdateDate: ����ʹ�õ�λ���� modi by lw 2012-5-4
				������鷶Χ���ڵ�λ����Ժ����������ͳ�ƣ�����鸺���˺Ͳ���Ա���� modi by lw 2012-7-27
				���Ӽ������豸�ı༭���ͳ������� modi by lw 2012-7-28

*/
create PROCEDURE buildCheckApply
	@applyDate varchar(10),		--�̵㿪ʼʱ��
	@expCompleteDate varchar(10),--Ԥ�����ʱ�� add by lw 2012-7-27
	@clgCode char(3),			--ѧԺ����
	@uCode varchar(8),			--ʹ�õ�λ����
	@checkerID varchar(10),		--��鸺���ˣ��̵��ˣ����� add by lw 2012-7-27
	@notes nvarchar(100),		--��ע

	@createManID varchar(10),	--������(����Ա)����

	@Ret		int output,
	@createTime smalldatetime output,
	@checkNum char(12) output	--���ɵ��豸�̵��,ʹ��4�ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 4, 1, @curNumber output
	set @checkNum = @curNumber

	--ȡʹ�õ�λ���ƣ�
	declare @clgName nvarchar(30)	--ѧԺ����
	declare @uName nvarchar(30)		--ʹ�õ�λ����
	set @clgName = (select clgName from college where clgCode = @clgCode)
	if (@uCode <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	else
		set @uName = ''

	--�������������豸�Ƿ��б༭������������
	declare @count int
	set @count = (select COUNT(*) from equipmentList
					where clgCode = @clgCode and (@uCode='' or uCode = @uCode) and curEqpStatus not in('6','7')
						  and (isnull(lockManID,'') <> '' or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 1
		return
	end
	
	--ͳ����鵥λ��������
	declare @staffNumOfLocation int		--���ʱ��Ժ������ʹ�õ�λ���������� add by lw 2012-7-27
	if (@uCode <> '')
		set @staffNumOfLocation = (select COUNT(*) from userInfo where clgCode = @clgCode and uCode = @uCode)
	else
		set @staffNumOfLocation = (select COUNT(*) from userInfo where clgCode = @clgCode)
		
	--ȡ��鸺����������
	declare @checker nvarchar(30)
	set @checker = isnull((select userCName from activeUsers where userID = @checkerID),'')
	--ȡά����������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	if (@applyDate='')
		set @applyDate = convert(varchar(10), getdate(), 120)
		
	set @createTime = getdate()
	begin tran
		insert eqpCheckInfo2(checkNum, applyDate, expCompleteDate, clgCode, clgName, uCode, uName, checkerID, checker, 
							staffNumOfLocation, notes,
							lockManID, modiManID, modiManName, modiTime) 
		values (@checkNum, @applyDate, @expCompleteDate, @clgCode, @clgName, @uCode, @uName, @checkerID, @checker, 
							@staffNumOfLocation, @notes,
							'', @createManID, @createManName, @createTime)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--�����̵���豸��ϸ��
		insert eqpCheckDetailInfo2(checkNum, eCode, eName, checkStatus, keeperID, keeper)
		select @checkNum, eCode, eName, 0, keeperID, keeper
		from equipmentList
		where clgCode = @clgCode and (@uCode='' or uCode = @uCode) and curEqpStatus not in('6','7')
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--�����豸�б���ֹ������������Ӹ��������������ϵ��豸�䶯��
		update equipmentList
		set lock4LongTime = '1', lInvoiceNum = @checkNum
		where clgCode = @clgCode and (@uCode='' or uCode = @uCode) and curEqpStatus not in('6','7')
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
	commit tran
	set @Ret = 0

	--��������豸�ı�����״̬��
	--���ݱϴ�Ҫ������б�����ID��ֱ�����ñ�����ID�������Ψһ����������ƥ������Զ�ƥ��״̬��������������ƥ��״̬
	declare @execRet int
	exec dbo.calcLockKeeperStatus @checkNum, @execRet output

	--����ͳ����Ϣ�� 
	exec dbo.updateCheckTotalInfo @checkNum, @execRet output

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '������鵥', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ���������豸��鵥[' + @checkNum + ']��')
GO
--���ԣ�
declare @Ret int,@createTime smalldatetime, @checkNum char(12)
exec dbo.buildCheckApply '2012-07-28','2012-08-27','000','','00200977','���Դ洢����','00200977', @Ret output, @createTime output, @checkNum output
select @Ret, @createTime, @checkNum

select * from eqpCheckInfo2 where checkNum='201207280006'
select * from eqpCheckDetailInfo2 where checkNum='201207280006'
select * from equipmentList where eCode = '11003199'

drop PROCEDURE calcLockKeeperStatus
/*
	name:		calcLockKeeperStatus
	function:	1.1.��������豸�ı���������״̬:
					���û�б�����ID��ϵͳʹ������ƥ�䣬�����Ψһ�Ľ�ְ��������鷶Χ�ڵģ�����ƥ�䣬���Զ����뱣����ID
				ע�⣺�ô洢���̲����༭����Ҳ���Ǽǹ�����־���ô洢����ĿǰΪ�ڲ����̣����ṩC#�ӿڣ�
	input: 
				@checkNum char(12),			--�豸��鵥��
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ������鵥�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2012-7-27
	UpdateDate: 

*/
create PROCEDURE calcLockKeeperStatus
	@checkNum char(12),			--�豸��鵥��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ������鵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--��ȡ��鵥����鷶Χ��Ժ������ʹ�õ�λ���룩��
	declare @clgCode char(3), @uCode varchar(8)	--ѧԺ����/ʹ�õ�λ����
	select @clgCode= clgCode, @uCode = uCode from eqpCheckInfo2 where checkNum = @checkNum
	
	--���㱣��������״̬��
	--���ɨ������豸�����û�б�����ID����ʹ�������Զ�ƥ�䱣����
	declare @eCode char(8), @keeperID varchar(10), @keeper nvarchar(30)	--�豸��ţ������˹��ţ�������
	declare tar cursor for
	select eCode, keeperID, keeper from eqpCheckDetailInfo2
	where checkNum = @checkNum
	OPEN tar
	FETCH NEXT FROM tar INTO @eCode, @keeperID, @keeper
	WHILE @@FETCH_STATUS = 0
	begin
		if (@keeperID<> '')	--����ȷ�ı�����
			update eqpCheckDetailInfo2
			set lockKeeper = 1
			where checkNum = @checkNum and eCode = @eCode
		else if (rtrim(ltrim(@keeper))='')	--û�б�����
			update eqpCheckDetailInfo2
			set lockKeeper = 0, keeperID = '', keeper = ''
			where checkNum = @checkNum and eCode = @eCode
		else --ʹ������ƥ�䱣����
		begin
			declare @sName nvarchar(30) --��׼���ƣ������ո���Ӣ�ģ�
			set @sName = replace(replace(@keeper,' ',''),'��','')
			declare @pNum int	--����ƥ��ļ�¼��
			if (@uCode <> '')
				set @pNum = (select count(*) from userInfo 
				where isOff=0 and clgCode=@clgCode and (uCode is null or uCode = @uCode) and replace(replace(cName,' ',''),'��','') =@sName)
			else 
				set @pNum = (select count(*) from userInfo 
				where isOff=0 and clgCode=@clgCode and replace(replace(cName,' ',''),'��','') =@sName)
			
			if (@pNum = 1)	--����ȷ��Ψһƥ��ı�����
			begin
				if (@uCode <> '')
					select @keeperID = jobNumber, @keeper = cName from userInfo 
					where isOff=0 and clgCode=@clgCode and (uCode is null or uCode = @uCode) and replace(replace(cName,' ',''),'��','') =@sName
				else 
					select @keeperID = jobNumber, @keeper = cName from userInfo 
					where isOff=0 and clgCode=@clgCode and replace(replace(cName,' ',''),'��','') =@sName
				update eqpCheckDetailInfo2
				set lockKeeper = 2, keeperID = @keeperID, keeper = @keeper
				where checkNum = @checkNum and eCode = @eCode
			end
			else	--û��ƥ��ı����˻�ֹһ��ƥ��ı�����
				update eqpCheckDetailInfo2
				set lockKeeper = 0, keeperID = ''
				where checkNum = @checkNum and eCode = @eCode
		end
		FETCH NEXT FROM tar INTO @eCode, @keeperID, @keeper
	end
	CLOSE tar
	DEALLOCATE tar
	
	set @Ret = 0
GO
--���ԣ�
select * from eqpCheckInfo2
update eqpCheckDetailInfo2
set keeperID='', keeper='�� �� ��'
where checkNum='201207270001' and eCode = '12000048'

declare @execRet int
exec dbo.calcLockKeeperStatus '201207270001', @execRet output
select @execRet

select * from eqpCheckDetailInfo2 where checkNum = '201207270001'

drop PROCEDURE updateCheckTotalInfo
/*
	name:		updateCheckTotalInfo
	function:	1.2.����ָ������飨�̵㣩��ͳ����Ϣ
				ע�⣺�ô洢���̲����༭����Ҳ���Ǽǹ�����־��
	input: 
				@checkNum char(12),			--�豸��飨�̵㣩����
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ������飨�̵㣩�������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-22
	UpdateDate: 

*/
create PROCEDURE updateCheckTotalInfo
	@checkNum char(12),			--�豸��飨�̵㣩����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ������飨�̵㣩���Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--ͳ����Ϣ��
	declare @eqpNumber int				--��飨�̵㣩���豸����
	set @eqpNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum)
	declare @eqpCheckedNumber int, @eqpWaitCheckNumber int, @eqpNoKeeperNumber int
	set @eqpCheckedNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and lockKeeper = 9)		--�Ѿ�ȷ�Ϲ����豸����
	set @eqpWaitCheckNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and lockKeeper in(1,2))	--��ȷ���豸����
	set @eqpNoKeeperNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and lockKeeper = 0)	--û�б����˵��豸����
	
	declare @eqpUploadedPhotoNumber int	--���ϴ���Ƭ���豸����
	set @eqpUploadedPhotoNumber = (select count(*) from eqpCheckDetailInfo2 
							where checkNum = @checkNum and eCode in (select eCode from eqpCheckPhoto where checkNum = @checkNum))

	--checkStatus char(1) not null,		--�̵�ʱ���豸״̬��
										--0��״̬����
										--1����ã�
										--3�����ޣ�
										--4�������ϣ�
										--5���������
										--6���������
										--9��������
	declare @eqpNormalNumber int		--��ȷΪ��������״̬���豸
	set @eqpNormalNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and checkStatus = '1')
	declare @eqpNeedMaintainNumber int	--��ȷΪ�����ޡ�״̬���豸
	set @eqpNeedMaintainNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and checkStatus = '3')
	declare @eqpNeedScrapNumber int		--��ȷΪ�������ϡ�״̬���豸
	set @eqpNeedScrapNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and checkStatus = '4')
	declare @eqpNotExistNumber int		--��ȷΪ����������������״̬���豸
	set @eqpNeedScrapNumber = (select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and checkStatus in('5','6'))

	update eqpCheckInfo2
	set eqpNumber = @eqpNumber, eqpCheckedNumber = @eqpCheckedNumber, eqpWaitCheckNumber = @eqpWaitCheckNumber, eqpNoKeeperNumber = @eqpNoKeeperNumber,
		eqpUploadedPhotoNumber =@eqpUploadedPhotoNumber,
		eqpNormalNumber = @eqpNormalNumber, eqpNeedMaintainNumber = @eqpNeedMaintainNumber, eqpNeedScrapNumber = @eqpNeedScrapNumber,
		eqpNotExistNumber = @eqpNotExistNumber
	where checkNum = @checkNum
	set @Ret = 0
GO


drop PROCEDURE queryCheckApplyLocMan
/*
	name:		queryCheckApplyLocMan
	function:	2.��ѯָ���豸��飨�̵㣩���Ƿ��������ڱ༭
	input: 
				@checkNum char(12),			--�豸��飨�̵㣩����,ʹ��4�ź��뷢��������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ������飨�̵㣩��������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2011-11-22
	UpdateDate: 
*/
create PROCEDURE queryCheckApplyLocMan
	@checkNum char(12),			--�豸��飨�̵㣩����,ʹ��4�ź��뷢��������
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from eqpCheckInfo2 where checkNum = @checkNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockCheckInfo4Edit
/*
	name:		lockCheckInfo4Edit
	function:	3.������飨�̵㣩����ʼ��飨�̵㣩������༭��ͻ
	input: 
				@checkNum char(12),			--�豸��飨�̵㣩����,ʹ��4�ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ��飨�̵㣩�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ��������飨�̵㣩�������ڣ�2:Ҫ��������飨�̵㣩�����ڱ����˱༭��3:�õ�������ˣ���Ч��
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-22
	UpdateDate: 
*/
create PROCEDURE lockCheckInfo4Edit
	@checkNum char(12),				--�豸��飨�̵㣩����,ʹ��4�ź��뷢��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ��飨�̵㣩�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������̵㵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpCheckInfo2 where checkNum = @checkNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	declare @applyState int
	set @applyState = (select applyState from eqpCheckInfo2 where checkNum = @checkNum)
	if (@applyState <> 0)
	begin
		set @Ret = 3
		return
	end

	update eqpCheckInfo2
	set lockManID = @lockManID 
	where checkNum = @checkNum
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '������鵥�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ����������鵥['+ @checkNum +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockCheckInfoEditor
/*
	name:		unlockCheckInfoEditor
	function:	4.�ͷ���飨�̵㣩���༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@checkNum char(12),				--�豸��飨�̵㣩����,ʹ��4�ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ��飨�̵㣩�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-22
	UpdateDate: 
*/
create PROCEDURE unlockCheckInfoEditor
	@checkNum char(12),				--�豸��飨�̵㣩����,ʹ��4�ź��뷢��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ��飨�̵㣩�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpCheckInfo2 where checkNum = @checkNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update eqpCheckInfo2 set lockManID = '' where checkNum = @checkNum
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
	values(@lockManID, @lockManName, getdate(), '�ͷ���鵥�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ�����鵥['+ @checkNum +']�ı༭����')
GO

drop PROCEDURE queryCheckEqpLocMan
/*
	name:		queryCheckEqpLocMan
	function:	5.��ѯָ������豸�Ƿ��������ڱ༭
	input: 
				@checkNum char(12),			--�豸��鵥��
				@eCode char(8),				--�豸���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ��������豸������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-7-27
	UpdateDate: 
*/
create PROCEDURE queryCheckEqpLocMan
	@checkNum char(12),			--�豸��鵥��
	@eCode char(8),				--�豸���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode = @eCode),'')
	set @Ret = 0
GO


drop PROCEDURE lockCheckEqp4Edit
/*
	name:		lockCheckEqp4Edit
	function:	6.������鵥��ָ���豸������༭��ͻ
	input: 
				@checkNum char(12),				--�豸��鵥��
				@eCode char(8),					--�豸���
				@lockManID varchar(10) output,	--�����ˣ������ǰ��鵥�е�ָ���豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ����������豸�����ڣ�2:Ҫ����������豸���ڱ����˱༭��3:�õ�������ˣ���Ч��
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-7-27
	UpdateDate: 
*/
create PROCEDURE lockCheckEqp4Edit
	@checkNum char(12),				--�豸��鵥��
	@eCode char(8),					--�豸���
	@lockManID varchar(10) output,	--�����ˣ������ǰ��鵥�е�ָ���豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ����������豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode = @eCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode = @eCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	declare @applyState int
	set @applyState = (select applyState from eqpCheckInfo2 where checkNum = @checkNum)
	if (@applyState <> 0)
	begin
		set @Ret = 3
		return
	end

	update eqpCheckDetailInfo2
	set lockManID = @lockManID 
	where checkNum = @checkNum and eCode = @eCode
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '��������豸�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ����������鵥['+ @checkNum +']���豸['+@eCode+']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockCheckEqpEditor
/*
	name:		unlockCheckEqpEditor
	function:	7.�ͷ�����豸�༭��
				ע�⣺�����̲�����豸�Ƿ���ڣ�
	input: 
				@checkNum char(12),				--�豸��鵥��
				@eCode char(8),					--�豸���
				@lockManID varchar(10) output,	--�����ˣ������ǰ����豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-7-27
	UpdateDate: 
*/
create PROCEDURE unlockCheckEqpEditor
	@checkNum char(12),				--�豸��鵥��
	@eCode char(8),					--�豸���
	@lockManID varchar(10) output,	--�����ˣ������ǰ����豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode = @eCode),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update eqpCheckDetailInfo2 set lockManID = '' where checkNum = @checkNum and eCode = @eCode
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�����豸�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ�����鵥['+ @checkNum +']���豸['+@eCode+']�ı༭����')
GO

drop PROCEDURE changeKeeping
/*
	name:		changeKeeping
	function:	8.ָ���豸����
				ע�⣺��飨�̵㣩����Чǰ�豸����Ϣ������ģ�
				�������˵Ĺ��ź�ά���˵Ĺ�����ͬһ���˵�ʱ�򣬸ù����Զ�����ȷ��״̬��
				�������˵Ĺ���Ϊ�յ�ʱ�򣬸ù���Ϊ����ָ�������ˡ�
	input: 
				@checkNum char(12),				--�豸��鵥��
				@eCode char(8),					--�豸���
				@keeperID varchar(10),			--�±����˹���
				@eqpLocate nvarchar(100),		--���豸���ڵ�ַ

				--ά����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ�豸������ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 

				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1�����豸�����ڣ�2�����豸�������������༭��9��δ֪����
	author:		¬έ
	CreateDate:	2012-6-27
	UpdateDate: 
*/
create PROCEDURE changeKeeping
	@checkNum char(12),				--�豸��鵥��
	@eCode char(8),					--�豸���
	@keeperID varchar(10),			--�±����˹���
	@eqpLocate nvarchar(100),		--���豸���ڵ�ַ

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ�豸������ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode= @eCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode= @eCode),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	set @updateTime = getdate()
	if (@keeperID<>'')
	begin
		--��ȡ������������
		declare @keeper nvarchar(30)
		set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
		declare @status smallint
		if (@keeperID = @modiManID)	--ȷ��
			set @status = 9
		else
			set @status = 1			--ָ��������
		update eqpCheckDetailInfo2
		set keeperID = @keeperID, keeper = @keeper, eqpLocate = @eqpLocate, 
			checkDate = @updateTime, lockKeeper = @status,	--0->δ������
															--1->ǰ���б����ˡ����豸����Աָ���˱�����
															--2->ϵͳʹ�������Զ�ƥ�䵽Ψһ�ı����ˣ�
															--9��>������ȷ��
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where eCode= @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
		--�Ǽǹ�����־��
		if (@keeperID = @modiManID)	--ȷ��
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@modiManID, @modiManName, @updateTime, '�豸����ȷ��', '�û�[' + @keeper + ']' 
														+ '�������豸['+ @eCode +']��')
		else	--ָ�ɱ�����
			insert workNote(userID, userName, actionTime, actions, actionObject)
			values(@modiManID, @modiManName, @updateTime, 'ָ���豸����', '�û�' + @modiManName 
														+ '���豸['+ @eCode +']������ָ��Ϊ['+@keeper+']��')
	end
	else	--����������
	begin
		update eqpCheckDetailInfo2
		set keeperID = '', keeper = '', eqpLocate = @eqpLocate, 
			checkDate = @updateTime, lockKeeper = 0,--0->δ����
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where eCode= @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
		--�Ǽǹ�����־��
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@modiManID, @modiManName, @updateTime, '�����豸����', '�û�' + @modiManName 
													+ '�������豸['+ @eCode +']�ı����ˡ�')
	end
	
	--����ͳ����Ϣ��
	exec dbo.updateCheckTotalInfo @checkNum, @Ret output
	
	set @Ret = 0

GO


drop PROCEDURE updateEqpCheckStatus
/*
	name:		updateEqpCheckStatus
	function:	9.��������豸��״̬�����豸��״���豸��״ͼ��
				ע�⣺�����̼��༭��
	input: 
				@checkNum char(12),			--�豸��鵥��
				@eCode char(8),				--�豸���
				@checkStatus char(1),		--���ʱ���豸״̬��
													--0��״̬����
													--1��������
													--3�����ޣ�
													--4�������ϣ�
													--5���������
													--6���������--����״̬Ӧ���޷�ȷ����
													--9��������
				@statusNotes nvarchar(100),	--�豸��״˵��
				@photos xml,				--��Ƭ��Ϣ���������·�ʽ���:
									N'<root>
									  <photo aFileName="90b2bd1c-8789-4223-9f05-2c38f6f000a7.png" photoDate="2012-06-11" notes="�豸������"/>
									  <photo aFileName="bc1a3c47-00c1-4c7c-93de-f75149db7a9d.png" photoDate="2012-06-11" notes="�豸����"/>
									</root>'				
				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ����豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ��������豸�����ڣ�
							2:�õ����Ѿ���Ч�����ϣ��������޸ģ�3��Ҫ���µ�����豸��������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-22
	UpdateDate: �����豸��״˵���ֶΣ�ɾ��ȷ�������ֶ� modi by lw 2012-7-27
*/
create PROCEDURE updateEqpCheckStatus
	@checkNum char(12),			--�豸��鵥��
	@eCode char(8),				--�豸���
	@checkStatus char(1),		--���ʱ���豸״̬��
										--0��״̬����
										--1��������
										--3�����ޣ�
										--4�������ϣ�
										--5���������
										--6���������--����״̬Ӧ���޷�ȷ����
										--9��������
	@statusNotes nvarchar(100),	--�豸��״˵��
	@photos xml,				--��Ƭ��Ϣ���������·�ʽ���:
						/*	N'<root>
								<photo aFileName="90b2bd1c-8789-4223-9f05-2c38f6f000a7.png" photoDate="2012-06-11" notes="�豸������"/>
								<photo aFileName="bc1a3c47-00c1-4c7c-93de-f75149db7a9d.png" photoDate="2012-06-11" notes="�豸����"/>
							</root>'
						*/				
	--ά����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ����豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ��������豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode = @eCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from eqpCheckDetailInfo2 where checkNum = @checkNum and eCode = @eCode
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @applyState int
	select @applyState = applyState from eqpCheckInfo2 where checkNum = @checkNum
	--��鵥��״̬:
	if (@applyState <> 0)
	begin
		set @Ret = 3
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')


	--ȡ�豸���ƣ�
	declare @eName nvarchar(30)	
	set @eName = isnull((select eName from equipmentList where eCode = @eCode),'')

	set @updateTime = getdate()
	begin tran
		--��������豸��״:
		update eqpCheckDetailInfo2
		set checkStatus = @checkStatus, statusNotes = @statusNotes,
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime 
		where checkNum = @checkNum and eCode = @eCode
		if @@ERROR <> 0 
		begin
			rollback tran
			set @Ret = 9
			return
		end    
		
		--ɾ���豸��״ͼ��
		delete eqpCheckPhoto where checkNum = @checkNum and eCode = @eCode
		--����豸��״ͼ��
		if (cast(@photos as nvarchar(max))<>N'<root/>')
		begin
			--�Ǽ�ͼƬ��
			insert eqpCheckPhoto(checkNum, eCode, eName, aFileName, photoDate, notes)
			select @checkNum, @eCode, @eName, 
					cast(T.x.query('data(./@aFileName)') as varchar(128)) aFileName,
					cast(T.x.query('data(./@photoDate)') as nvarchar(19)) photoDate,
					cast(T.x.query('data(./@notes)') as nvarchar(500)) notes
			from (select @photos.query('/root/photo') Col1) A OUTER APPLY A.Col1.nodes('/photo') AS T(x)
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
	values(@modiManID, @modiManName, @updateTime, '��������豸��״', '�û�' + @modiManName 
												+ '��������鵥['+ @checkNum +']���豸['+ @eCode +']��״̬��')
GO
--���ԣ�
declare	@Ret	int
exec dbo.updateEqpCheckStatus '201206110009', '11003199', '1', '�豸����ʹ�ã�ά���������', 
						'<root>
						  <photo aFileName="90b2bd1c-8789-4223-9f05-2c38f6f000a7.png" photoDate="2012-06-11" notes="�豸������"/>
						  <photo aFileName="bc1a3c47-00c1-4c7c-93de-f75149db7a9d.png" photoDate="2012-06-11" notes="�豸����"/>
						</root>','00011275',@Ret output
select @Ret
select * from eqpCheckInfo2
select * from eqpCheckPhoto



drop PROCEDURE delCheckInfo
/*
	name:		delCheckInfo
	function:	10.ɾ��ָ�����豸��鵥
	input: 
				@checkNum char(12),				--�豸��鵥��
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ��鵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ������鵥�����ڣ�2��Ҫɾ������鵥��������������3:�õ����Ѿ���Ч������ɾ����9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-22
	UpdateDate: modi by lw 2012-7-28 ���ӳ�����������

*/
create PROCEDURE delCheckInfo
	@checkNum char(12),				--�豸��鵥��
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ��鵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ������鵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @applyState int
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState
	from eqpCheckInfo2 
	where checkNum = @checkNum
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	if (@applyState = 1)
	begin
		set @Ret = 3
		return
	end
	
	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	begin tran
		--�����豸�ĳ���������
		update equipmentList
		set lock4LongTime = '0', lInvoiceNum = ''
		where eCode in (select eCode from eqpCheckDetailInfo2 where checkNum = @checkNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--ɾ������
		delete eqpCheckInfo2 where checkNum = @checkNum
	commit tran
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���豸��鵥', '�û�' + @delManName
												+ 'ɾ�����豸��鵥['+ @checkNum +']��')

GO

drop PROCEDURE verifyCheckApply
/*
	name:		verifyCheckApply
	function:	11.��Ч��鵥
	input: 
				@checkNum char(12),					--�豸��鵥��

				--ά����:
				@verifyManID varchar(10) output,	--��Ч�ˣ�����ˣ��������ǰ��鵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@verifyDate smalldatetime output,	--�����Ч��������
				@Ret		int output				--�����ɹ���ʶ
													0:�ɹ���1��ָ������鵥�����ڣ�2��Ҫ��Ч����鵥��������������
													3:Ҫ��Ч����鵥�е��豸���б༭��δ�ͷţ�
													5������鵥�Ѿ���Ч�����ϣ�9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-22
	UpdateDate: modi by lw 2012-7-28
				1.��������豸�ı༭���жϣ�������ȷ����Ϣ����״��Ϣд���豸�б�
				2.����������Ч����
*/
create PROCEDURE verifyCheckApply
	@checkNum char(12),					--�豸��鵥��

	@verifyManID varchar(10) output,	--��Ч�ˣ������ǰ��鵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@verifyDate smalldatetime output,	--��Ч����
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����̵㵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @applyState int
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState
	from eqpCheckInfo2 
	where checkNum = @checkNum
	--��鵥�ݱ༭����
	if (@thisLockMan <> '' and @thisLockMan <> @verifyManID)
	begin
		set @verifyManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	if (@applyState <> 0)
	begin
		set @Ret = 5
		return
	end
	
	--�������豸�༭����
	select @count = (select COUNT(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and isnull(lockManID,'') <> '')
	if (@count > 0)
	begin
		set @Ret = 3
		return
	end
	

	--ȡά���˵�������
	declare @verifyMan nvarchar(30)
	set @verifyMan = isnull((select userCName from activeUsers where userID = @verifyManID),'')

	--����ͳ����Ϣ��
	declare @execRet int
	exec dbo.updateCheckTotalInfo @checkNum, @execRet output

	set @verifyDate = getdate()
	
	begin tran
		--���ɨ������豸�������豸�б���豸��״��
		declare @eCode char(8)	--�豸��鵥��/�豸���
		declare @lockKeeper smallint	--�Ƿ����������ˣ�
										--0->δ������
										--1->ǰ���б����ˡ����豸����Աָ���˱�����
										--2->ϵͳʹ�������Զ�ƥ�䵽Ψһ�ı����ˣ�
										--9��>������ȷ��
		declare @keeperID varchar(10), @keeper nvarchar(30), @eqpLocate nvarchar(100)	--�����˹���/������/�豸���ڵ�ַ
		declare tar cursor for
		select eCode, lockKeeper, keeperID, keeper, eqpLocate
		from eqpCheckDetailInfo2
		where checkNum = @checkNum
		OPEN tar
		FETCH NEXT FROM tar INTO @eCode, @lockKeeper, @keeperID, @keeper, @eqpLocate
		WHILE @@FETCH_STATUS = 0
		begin
			--����״д���豸��״��
			--�����豸��״���κţ�
			declare @sNumber int	--��״���κ�
			set @sNumber = ISNULL((select MAX(sNumber) from eqpStatusInfo where eCode = @eCode),0)
			set @sNumber = @sNumber + 1
			if (@lockKeeper<>9)
			begin
				set @keeperID = ''
				set @keeper = ''
			end
			insert into eqpStatusInfo(eCode, eName, sNumber, checkDate, keeperID, keeper, eqpLocate, 
								checkStatus, statusNotes, invoiceType, invoiceNum)
			select @eCode, eName, @sNumber, checkDate, @keeperID, @keeper, @eqpLocate, 
								case checkStatus when '0' then '1' else checkStatus end, statusNotes, '5', @checkNum
								--�Զ���״̬����ת��Ϊ����״̬
			from eqpCheckDetailInfo2
			where checkNum = @checkNum and eCode = @eCode
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			--����״ͼд���豸��״ͼ��
			insert into eqpStatusPhoto(eCode, eName, sNumber, photoDate, aFilename, notes)
			select @eCode, eName, @sNumber, photoDate, aFilename, notes
			from eqpCheckPhoto
			where checkNum = @checkNum and eCode = @eCode
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			
			if (@lockKeeper=9) --���豸ȷ����Ϣ
			begin
				--��ȡ�豸�����˵�����Ժ����ʹ�õ�λ��Ϣ��
				declare @clgCode char(3), @uCode varchar(8)		--ѧԺ����/ʹ�õ�λ����
				select @clgCode = clgCode, @uCode = uCode
				from userInfo
				where jobNumber = @keeperID
				
				--��ȡԭ�豸������Ϣ��
				declare @oldClgCode char(3), @oldUCode varchar(8)		--ԭѧԺ����/ԭʹ�õ�λ����
				declare @oldKeeperID varchar(10), @oldEqpLocate nvarchar(100)	--ԭ�����˹���/�豸���ڵ�ַ
				select @oldClgCode = clgCode, @oldUCode = uCode, @oldKeeperID = keeperID, @oldEqpLocate = eqpLocate
				from equipmentList
				where eCode = @eCode
				
				if (@clgCode is null)
				begin
					set @clgCode = @oldClgCode
					set @uCode = @oldUCode
				end
				else if (@uCode is null)
				begin
					set @uCode = @oldUCode
				end
				--����䶯�˱�����Ϣ��
				if ((@clgCode is not null and @clgCode <> @oldClgCode)
					or (@uCode is not null and @uCode <> @oldUCode)
					or @keeperID <> @oldKeeperID or @eqpLocate <> @oldEqpLocate)
				begin
					--�Ǽ��豸�������ڱ�:
					insert eqpLifeCycle(eCode,eName, eModel, eFormat, clgCode, clgName, uCode, uName, 
						keeperID, keeper, eqpLocate,
						annexAmount, price, totalAmount,
						changeDate, changeDesc,changeType,changeInvoiceID) 
					select @eCode, e.eName, e.eModel, e.eFormat, @clgCode, clg.clgName, @uCode, u.uName, 
						@keeperID, @keeper, @eqpLocate,
						e.annexAmount, e.price, e.totalAmount,
						c.checkDate, '����豸ʱ����˸��豸�ı�����Ϣ',
						'���',@checkNum
					from equipmentList e inner join eqpCheckDetailInfo2 c on e.eCode = c.eCode
						left join college clg on clg.clgCode = @clgCode
						left join useUnit u on u.clgCode = @clgCode and u.uCode = @uCode
					where c.checkNum = @checkNum and c.eCode = @eCode
					
					--�����豸������Ϣ��
					update equipmentList
					set clgCode = @clgCode, uCode = @uCode, keeperID = @keeperID, keeper = @keeper, eqpLocate = @eqpLocate
					where eCode = @eCode
					if @@ERROR <> 0 
					begin
						set @Ret = 9
						rollback tran
						return
					end    
				end
			end

			FETCH NEXT FROM tar INTO @eCode, @lockKeeper, @keeperID, @keeper, @eqpLocate
		end
		CLOSE tar
		DEALLOCATE tar
		
		--���豸������Ϊ��Ч״̬��
		update eqpCheckInfo2
		set applyState = 1,	--�豸�̵㵥״̬��0->�½���1->����Ч��2->������
			verifyManID = @verifyManID, verifyMan = @verifyMan, verifyDate = @verifyDate
		where checkNum = @checkNum 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--�ͷ��豸����������
		update equipmentList
		set lock4LongTime = '0', lInvoiceNum = ''
		where eCode in (select eCode from eqpCheckDetailInfo2 where checkNum = @checkNum)
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
	values(@verifyManID, @verifyMan, @verifyDate, '��鵥��Ч', '�û�' + @verifyMan
												+ '�����Ч���豸��鵥['+ @checkNum +']��')
GO
--���ԣ�


drop PROCEDURE cancelVerifyCheck
/*
	name:		cancelVerifyCheck
	function:	12.������鵥����Ч
				ע�⣺�ù��ܲ��ܳ����豸�����µ�״̬��Ҳ�п����޷������豸�������ڱ�����ӵļ�¼��
	input: 
				@checkNum char(12),					--�豸��鵥��

				--ά����:
				@cancelManID varchar(10) output,	--ȡ���ˣ������ǰ��鵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@cancelDate smalldatetime output,	--ȡ������
				@Ret		int output				--�����ɹ���ʶ
													0:�ɹ���1��ָ������鵥������,2��Ҫ������Ч����鵥��������������
													3���õ��ݲ�������Ч״̬��
													4��Ҫ������Ч����鵥�е��豸�������˱༭������9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-22
	UpdateDate: modi by lw 2012-7-28
				1.����ɾ����Ч��鵥����ӵ��豸��״��¼���豸�������ڼ�¼
				2.�����豸�ĳ�������
*/
create PROCEDURE cancelVerifyCheck
	@checkNum char(12),					--�豸��鵥��
	@cancelManID varchar(10) output,	--ȡ���ˣ������ǰ��鵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@cancelDate smalldatetime output,	--ȡ������
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ������鵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @applyState int
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState
	from eqpCheckInfo2 
	where checkNum = @checkNum
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @cancelManID)
	begin
		set @cancelManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--������״̬:
	if (@applyState <> 1)
	begin
		set @Ret = 3
		return
	end

	--�������������豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from eqpCheckDetailInfo2 where checkNum = @checkNum)
						  and (isnull(lockManID,'') <> '' or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 4
		return
	end

	--ȡά���˵�����\ʱ�䣺
	declare @cancelMan nvarchar(30)
	set @cancelMan = isnull((select userCName from activeUsers where userID = @cancelManID),'')
	set @cancelDate = getdate()

	begin tran
		--ɾ������鵥���ɵ��豸��״���¼��
		delete eqpStatusInfo
		where invoiceType = '5' and invoiceNum = @checkNum

		--���豸ɾ�����ܵ���鵥���ɵ��豸�������ڱ��¼:���������һ��
		declare @eCode char(8)	--�豸��鵥��/�豸���
		declare tar cursor for
		select eCode from eqpCheckDetailInfo2 where checkNum = @checkNum
		OPEN tar
		FETCH NEXT FROM tar INTO @eCode
		WHILE @@FETCH_STATUS = 0
		begin
			declare @changeType varchar(10), @changeInvoiceID varchar(30)	--�䶯����/�䶯ƾ֤��
			select top 1 @changeType = changeType, @changeInvoiceID = changeInvoiceID 
			from eqpLifeCycle
			where eCode = @eCode
			order by rowNum desc
			
			if (@changeType='���' and @changeInvoiceID = @checkNum)
			begin
				delete eqpLifeCycle
				where eCode = @eCode and changeType='���' and changeInvoiceID = @checkNum
			end
			
			FETCH NEXT FROM tar INTO @eCode
		end
		CLOSE tar
		DEALLOCATE tar
		
		--���豸������Ϊ�״̬��
		update eqpCheckInfo2
		set applyState = 0,	--�豸��鵥״̬��0->�½���1->����Ч��2->������
			verifyManID = '', verifyMan = '', verifyDate = null
		where checkNum = @checkNum 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--���������豸����������
		update equipmentList
		set lock4LongTime = '1', lInvoiceNum = @checkNum
		where eCode in (select eCode from eqpCheckDetailInfo2 where checkNum = @checkNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	
	commit tran
	
	set @Ret = 0
	--����ͳ����Ϣ��
	declare @execRet int
	exec dbo.updateCheckTotalInfo @checkNum, @execRet output

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@cancelManID, @cancelMan, @cancelDate, '������鵥��Ч', '�û�' + @cancelMan
												+ '��������鵥['+ @checkNum +']����Ч��')

GO

drop PROCEDURE revokeCheckApply
/*
	name:		revokeCheckApply
	function:	13.�ϳ���鵥
	input: 
				@checkNum char(12),					--�豸��鵥��

				--ά����:
				@revokeManID varchar(10) output,	--�ϳ��ˣ������ǰ��鵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@revokeDate smalldatetime output,	--�ϳ�����
				@Ret		int output				--�����ɹ���ʶ
													0:�ɹ���1��ָ������鵥�����ڣ�2��Ҫ�ϳ�����鵥��������������
													3:Ҫ�ϳ�����鵥�е��豸���б༭��δ�ͷţ�
													5������鵥�Ѿ���Ч��ϳ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-7-28
	UpdateDate: 
*/
create PROCEDURE revokeCheckApply
	@checkNum char(12),					--�豸��鵥��

	@revokeManID varchar(10) output,	--�ϳ��ˣ������ǰ��鵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@revokeDate smalldatetime output,	--�ϳ�����
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����̵㵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpCheckInfo2 where checkNum = @checkNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @applyState int
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState
	from eqpCheckInfo2 
	where checkNum = @checkNum
	--��鵥�ݱ༭����
	if (@thisLockMan <> '' and @thisLockMan <> @revokeManID)
	begin
		set @revokeManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	if (@applyState <> 0)
	begin
		set @Ret = 5
		return
	end
	
	--�������豸�༭����
	select @count = (select COUNT(*) from eqpCheckDetailInfo2 where checkNum = @checkNum and isnull(lockManID,'') <> '')
	if (@count > 0)
	begin
		set @Ret = 3
		return
	end
	

	--ȡά���˵�������
	declare @revokeMan nvarchar(30)
	set @revokeMan = isnull((select userCName from activeUsers where userID = @revokeManID),'')

	set @revokeDate = getdate()
	
	begin tran
		--���豸������Ϊ��Ч״̬��
		update eqpCheckInfo2
		set applyState = 2,	--�豸�̵㵥״̬��0->�½���1->����Ч��2->������
			verifyManID = @revokeManID, verifyMan = @revokeMan, verifyDate = @revokeDate
		where checkNum = @checkNum 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--�ͷ��豸����������
		update equipmentList
		set lock4LongTime = '0', lInvoiceNum = ''
		where eCode in (select eCode from eqpCheckDetailInfo2 where checkNum = @checkNum)
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
	values(@revokeManID, @revokeMan, @revokeDate, '��鵥����', '�û�' + @revokeMan
												+ '���豸��鵥['+ @checkNum +']���ϡ�')
GO




select 
checkNum, convert(varchar(10),applyDate,120) applyDate, case applyState when 0 then '�E' when 1 then '��' when 2 then '�w' end applyState,
clgCode, clgName, uCode, uName, checkerID, checker, verifyManID, verifyMan, isnull(convert(varchar(10),verifyDate,120),'') verifyDate,
eqpNumber, eqpCheckedNumber, eqpNotExistNumber, 
eqpNeedMaintainNumber, eqpNeedScrapNumber, eqpNormalNumber, notes, eqpUploadedPhotoNumber
from
eqpCheckInfo2
select * 
	
	
	
use epdc2	
select ch.lockKeeper,e.eCode,convert(varchar(10),e.acceptDate,120) as acceptDate,case e.curEqpStatus when '1' then '����' when '2' then '����' when '3' then '����' when '4' then '������'when '5' then '��ʧ' when '6' then '����' when '7' then '����' when '8' then '����' when '9' then '����' else 'δ֪' end curEqpStatus,e.eName,e.eModel,e.eFormat,clg.clgName,u.uName,e.keeper,ch.keeper,c.cName,e.factory,e.serialNumber,convert(varchar(10),e.makeDate,120) as makeDate,e.business,e.annexCode,e.annexName,e.annexAmount,e.eTypeCode,e.aTypeCode,f.fName,a.aName,convert(varchar(10),e.buyDate,120) as buyDate,e.price,e.totalAmount,e.oprMan, e.acceptMan, e.notes,case e.curEqpStatus when '6' then convert(char(10), e.scrapDate, 120) else '' end scrapDate,e.cCode,e.fCode,e.aCode,e.clgCode,e.uCode
from 
 eqpCheckDetailInfo2 ch left join equipmentList e on ch.eCode = e.eCode 
	left join country c on e.cCode = c.cCode 
	left join fundSrc f on e.fCode = f.fCode 
	left join appDir a on e.aCode = a.aCode 
	left join college clg on e.clgCode = clg.clgCode 
	left join useUnit u on e.uCode = u.uCode 
