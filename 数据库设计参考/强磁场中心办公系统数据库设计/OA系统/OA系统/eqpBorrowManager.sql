use hustOA
/*
	ǿ�ų����İ칫ϵͳ-�����豸����
	author:		¬έ
	CreateDate:	2013-1-22
	UpdateDate: 
*/
--1.�����豸״̬������һ�����豸���й����豸һһ��Ӧ��һ���豸״̬��
--Ϊ�˱�����ʷ���ݣ������û����Ƴ����豸�����������豸�����ʱ��Ҫ��Ӧ���ñ���
update shareEqpStatus
set borrowerID='',
	borrower='',
	lentTime=null,
	expectedReturnTime=null,
	borrowReason=''
select * from shareEqpStatus
DROP TABLE shareEqpStatus
CREATE TABLE shareEqpStatus(
	eCode char(8) not null,				--�������豸���

	borrowerID varchar(10) null,		--�ֽ����˹���
	borrower nvarchar(30) null,			--�ֽ�����
	lentTime smalldatetime null,		--���ʱ��
	expectedReturnTime smalldatetime null,--Ԥ�ƹ黹ʱ��
	borrowReason nvarchar(300) null,	--��������
	
	isShare int default(1),				--�Ƿ�������ã�0->������1->��������ֶ������豸���Ƿ������趨�ģ�
	setOffDate smalldatetime,			--ȡ�����Խ��ã��������Ե�����

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_shareEqpStatus] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--������������
CREATE NONCLUSTERED INDEX [IX_shareEqpStatus] ON [dbo].[shareEqpStatus] 
(
	[borrower] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--���ʱ��������
CREATE NONCLUSTERED INDEX [IX_shareEqpStatus_1] ON [dbo].[shareEqpStatus] 
(
	[lentTime] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--Ԥ�ƹ黹ʱ��������
CREATE NONCLUSTERED INDEX [IX_shareEqpStatus_2] ON [dbo].[shareEqpStatus] 
(
	[expectedReturnTime] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�Ƿ��������������
CREATE NONCLUSTERED INDEX [IX_shareEqpStatus_3] ON [dbo].[shareEqpStatus] 
(
	[isShare] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--2.�豸��������ǼǱ�

select * from eqpBorrowInfo
drop table eqpBorrowInfo
CREATE TABLE eqpBorrowInfo(
	rowNum int IDENTITY (1, 1) NOT FOR REPLICATION  NOT NULL, --�������ڲ��к�
	eCode char(8) not null,				--�������豸���

	applyID varchar(10) null,			--���뵥�ţ�����Ϊ�գ����豸�Ľ����������
	borrowerID varchar(10) not null,	--�����˹���
	borrower nvarchar(30) not null,		--������
	lentTime smalldatetime not null,	--���ʱ��
	expectedReturnTime smalldatetime null,--Ԥ�ƹ黹ʱ��
	borrowReason nvarchar(300) null,	--��������
	returnTime smalldatetime null,		--ʵ�ʹ黹ʱ��
 CONSTRAINT [PK_eqpBorrowInfo] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[eqpBorrowInfo] WITH CHECK ADD CONSTRAINT [FK_eqpBorrowInfo_shareEqpStatus] FOREIGN KEY([eCode])
REFERENCES [dbo].[shareEqpStatus] ([eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpBorrowInfo] CHECK CONSTRAINT [FK_eqpBorrowInfo_shareEqpStatus]
GO

--������
--���ʱ��������
CREATE NONCLUSTERED INDEX [IX_eqpBorrowInfo] ON [dbo].[eqpBorrowInfo] 
(
	[lentTime] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--Ԥ�ƹ黹ʱ��������
CREATE NONCLUSTERED INDEX [IX_eqpBorrowInfo_1] ON [dbo].[eqpBorrowInfo] 
(
	[expectedReturnTime] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--ʵ�ʹ黹ʱ��������
CREATE NONCLUSTERED INDEX [IX_eqpBorrowInfo_2] ON [dbo].[eqpBorrowInfo] 
(
	[returnTime] DESC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--3.�����豸���������
alter table eqpBorrowApplyInfo add linkInvoiceType smallint default(0)--�������ݣ�0->δ֪��1->ѧ�����棬2->���飬9->���� 
alter table eqpBorrowApplyInfo add linkInvoice varchar(12) null		--�������ݺ�
drop table eqpBorrowApplyInfo
CREATE TABLE eqpBorrowApplyInfo(
	applyID varchar(10) not null,		--�������豸�������ʹ�����뵥��,��ϵͳʹ�õ�7�ź��뷢����������'JY'+4λ��ݴ���+4λ��ˮ�ţ�
	eCode char(8) not null,				--�������豸���,��ϵͳʹ�õ�6�ź��뷢����������4λ��ݴ���+4λ��ˮ�ţ�
	applyStatus smallint default(0),	--��������״̬��0->δ����1->����׼��-1������׼
	eName nvarchar(30) not null,		--�豸���ƣ��������ƣ�:�������
	eModel nvarchar(20) not null,		--�豸�ͺ�:�������
	eFormat nvarchar(30) not null,		--�豸���:�������

	borrowerID varchar(10) not null,	--�����˹���
	borrower nvarchar(30) not null,		--������
	lentTime smalldatetime not null,	--���ʱ��
	expectedReturnTime smalldatetime null,--Ԥ�ƹ黹ʱ��
	borrowReason nvarchar(300) null,	--��������
	--add by lw 2013-1-29
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
 CONSTRAINT [PK_eqpBorrowApplyInfo] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC,
	[applyID] DESC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--������
--������������
CREATE NONCLUSTERED INDEX [IX_eqpBorrowApplyInfo] ON [dbo].[eqpBorrowApplyInfo] 
(
	[borrowerID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

drop PROCEDURE queryShareEqpLocMan
/*
	name:		queryShareEqpLocMan
	function:	1.��ѯָ�������豸�Ƿ��������ڱ༭
	input: 
				@eCode char(8),				--�������豸���
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ĺ����豸������
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE queryShareEqpLocMan
	@eCode char(8),				--�������豸���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from shareEqpStatus where eCode= @eCode),'')
	set @Ret = 0
GO


drop PROCEDURE lockShareEqp4Lent
/*
	name:		lockShareEqp4Lent
	function:	2.���������豸����������ͻ
	input: 
				@eCode char(8),				--�������豸���
				@lockManID varchar(10) output,	--�����ˣ������ǰ�����豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ĺ����豸�����ڣ�2:Ҫ�����Ĺ����豸���ڱ����˱༭��
							3:���豸�Ѿ����ǹ���״̬��
							4�����豸�Ѿ������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE lockShareEqp4Lent
	@eCode char(8),					--�������豸���
	@lockManID varchar(10) output,	--�����ˣ������ǰ�����豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from shareEqpStatus where eCode= @eCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from shareEqpStatus where eCode= @eCode
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	--��ȡ�����豸״̬/�ֽ����ˣ�
	declare @isShare int, @borrowerID varchar(10)
	select @isShare = isShare, @borrowerID= borrowerID from shareEqpStatus where eCode = @eCode
	--���״̬��
	if (@isShare=0)
	begin
		set @Ret = 3
		return
	end
	if (isnull(@borrowerID,'') <> '')
	begin
		set @Ret = 4
		return
	end

	update shareEqpStatus
	set lockManID = @lockManID 
	where eCode = @eCode
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
	values(@lockManID, @lockManName, getdate(), '���������豸����༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������豸['+@eCode+']Ϊ��ռʽ����༭��')
GO

drop PROCEDURE lockShareEqp4Return
/*
	name:		lockShareEqp4Return
	function:	3.���������豸������黹��ͻ
	input: 
				@eCode char(8),				--�������豸���
				@lockManID varchar(10) output,	--�����ˣ������ǰ�����豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ĺ����豸�����ڣ�2:Ҫ�����Ĺ����豸���ڱ����˱༭��
							4�����豸�Ѿ��黹��
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE lockShareEqp4Return
	@eCode char(8),					--�������豸���
	@lockManID varchar(10) output,	--�����ˣ������ǰ�����豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from shareEqpStatus where eCode= @eCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from shareEqpStatus where eCode= @eCode
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	--��ȡ�ֽ����ˣ�
	declare @isShare int, @borrowerID varchar(10)
	select @isShare = isShare, @borrowerID= borrowerID from shareEqpStatus where eCode = @eCode
	if (isnull(@borrowerID,'') = '')
	begin
		set @Ret = 4
		return
	end

	update shareEqpStatus
	set lockManID = @lockManID 
	where eCode = @eCode
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
	values(@lockManID, @lockManName, getdate(), '���������豸�黹�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������豸['+@eCode+']Ϊ��ռʽ�黹�༭��')
GO

drop PROCEDURE unlockShareEqpEditor
/*
	name:		unlockShareEqpEditor
	function:	4.�ͷŹ����豸�༭��
				ע�⣺�����̲���鹲���豸�Ƿ���ڣ�
	input: 
				@eCode char(8),					--�������豸���
				@lockManID varchar(10) output,	--�����ˣ������ǰ�����豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE unlockShareEqpEditor
	@eCode char(8),					--�������豸���
	@lockManID varchar(10) output,	--�����ˣ������ǰ�����豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from shareEqpStatus where eCode= @eCode),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update shareEqpStatus set lockManID = '' where eCode= @eCode
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
	values(@lockManID, @lockManName, getdate(), '�ͷŹ����豸�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ����豸['+@eCode+']�ı༭����')
GO

drop PROCEDURE lentEqp
/*
	name:		lentEqp
	function:	5.����豸�Ǽ�
	input: 
				@eCode char(8),					--�豸���
				@applyID varchar(10),			--���뵥�ţ�����Ϊ�գ����豸�Ľ����������
				@borrowerID varchar(10),		--�����˹���
				@lentTime varchar(19),			--���ʱ��
				@expectedReturnTime varchar(19),--Ԥ�ƹ黹ʱ��
				@borrowReason nvarchar(300),	--��������

				@keeperID varchar(10)  output,	--�����˹��ţ������ǰ�����豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���õĹ����豸�����ڣ�2:Ҫ���õĹ����豸���ڱ����˱༭��
							3:���豸�Ѿ����ǹ���״̬��
							4�����豸�Ѿ������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE lentEqp
	@eCode char(8),					--�豸���
	@applyID varchar(10),			--���뵥�ţ�����Ϊ�գ����豸�Ľ����������
	@borrowerID varchar(10),		--�����˹���
	@lentTime varchar(19),			--���ʱ��
	@expectedReturnTime varchar(19),--Ԥ�ƹ黹ʱ��
	@borrowReason nvarchar(300),	--��������

	@keeperID varchar(10) output,	--�����˹��ţ������ǰ�����豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ����豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from shareEqpStatus where eCode= @eCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from shareEqpStatus where eCode= @eCode
	if (@thisLockMan <> '' and @thisLockMan <> @keeperID)
	begin
		set @keeperID = @thisLockMan
		set @Ret = 2
		return
	end

	--��ȡ�����豸״̬/�ֽ����ˣ�
	declare @isShare int, @curBorrowerID varchar(10)
	select @isShare = isShare, @curBorrowerID= borrowerID from shareEqpStatus where eCode = @eCode
	--���״̬��
	if (@isShare=0)
	begin
		set @Ret = 3
		return
	end
	if (isnull(@curBorrowerID,'') <> '')
	begin
		set @Ret = 4
		return
	end

	--ȡ������/�����˵�������
	declare @keeper nvarchar(30), @borrower nvarchar(30)
	set @keeper = isnull((select userCName from activeUsers where userID = @keeperID),'')
	set @borrower = isnull((select cName from userInfo where jobNumber = @borrowerID),'')
	
	declare @createTime smalldatetime
	set @createTime = getdate()
	begin tran
		--�Ǽ��豸��������ǼǱ�
		insert eqpBorrowInfo(eCode, applyID, borrowerID, borrower, lentTime, expectedReturnTime, borrowReason)
		values(@eCode, @applyID, @borrowerID, @borrower, @lentTime, @expectedReturnTime, @borrowReason)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end   
		--���¹����豸״̬�� 
		update shareEqpStatus
		set borrowerID = @borrowerID, borrower = @borrower,
			lentTime = @lentTime, expectedReturnTime = @expectedReturnTime,
			borrowReason = @borrowReason,	--��������
			--����ά�����:
			modiManID = @keeperID, modiManName = @keeper, modiTime = @createTime
		where eCode = @eCode
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
	values(@keeperID, @keeper, @createTime, '����豸', 'ϵͳ�����û�' + @keeper + 
					'��Ҫ��Ǽ����豸['+@eCode+']���������')
GO
--���ԣ�
declare	@Ret		int
declare	@createTime smalldatetime
declare	@rowNum varchar(10)

select * from eqpBorrowInfo

drop PROCEDURE returnEqp
/*
	name:		returnEqp
	function:	6.�黹�豸
	input: 
				@eCode char(8),					--�豸���
				@borrowerID varchar(10),		--�����˹���
				@returnTime varchar(19),		--ʵ�ʹ黹ʱ��

				@keeperID varchar(10),			--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�黹�Ĺ����豸�����ڣ�2:Ҫ�黹�Ĺ����豸���ڱ����˱༭��
							3���黹�˲��ǽ�����
							4�����豸�Ѿ��黹��
							5��û�н�����ݣ�
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE returnEqp
	@eCode char(8),					--�豸���
	@borrowerID varchar(10),		--�����˹���
	@returnTime varchar(19),		--ʵ�ʹ黹ʱ��

	@keeperID varchar(10) output,	--�����˹��ţ������ǰ�����豸���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ĺ����豸�Ƿ����
	declare @count as int
	set @count=(select count(*) from shareEqpStatus where eCode= @eCode)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from shareEqpStatus where eCode= @eCode
	if (@thisLockMan <> '' and @thisLockMan <> @keeperID)
	begin
		set @keeperID = @thisLockMan
		set @Ret = 2
		return
	end

	--��ȡ�ֽ����ˣ�
	declare @curBorrowerID varchar(10)
	select @curBorrowerID= borrowerID from shareEqpStatus where eCode = @eCode
	if (isnull(@curBorrowerID,'') = '')
	begin
		set @Ret = 4
		return
	end
	if (@curBorrowerID<>@borrowerID)
	begin
		set @Ret = 3
		return
	end
	
	--��ȡ���õǼ���Ϣ���ݵ��кţ�
	declare @rowNum int 
	set @rowNum = (select top 1 rowNum from eqpBorrowInfo 
					where eCode = @eCode and borrowerID=@borrowerID and returnTime is null order by lentTime desc)
	if (@rowNum is null)
	begin
		set @Ret = 5
		return
	end

	--ȡ������/�����˵�������
	declare @keeper nvarchar(30), @borrower nvarchar(30)
	set @keeper = isnull((select userCName from activeUsers where userID = @keeperID),'')
	set @borrower = isnull((select cName from userInfo where jobNumber = @borrowerID),'')

	declare @modiTime smalldatetime
	set @modiTime = getdate()
	begin tran
		--�Ǽ��豸��������ǼǱ�
		update eqpBorrowInfo
		set returnTime = @returnTime
		where rowNum=@rowNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end   
		--���¹����豸״̬�� 
		update shareEqpStatus
		set borrowerID = '', borrower = '',
			lentTime = null, expectedReturnTime = null,
			borrowReason = '',	--��������
			--����ά�����:
			modiManID = @keeperID, modiManName = @keeper, modiTime = @modiTime
		where eCode = @eCode
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
	values(@keeperID, @keeper, @modiTime, '�黹�豸', 'ϵͳ�����û�' + @keeper + 
					'��Ҫ��Ǽ����豸['+@eCode+']�Ĺ黹�����')
GO


----------------------------------------------�豸����������뵥����------------------------------------------------------
drop PROCEDURE queryEqpBorrowApplyLocMan
/*
	name:		queryEqpBorrowApplyLocMan
	function:	11.��ѯָ���豸�������뵥�Ƿ��������ڱ༭
	input: 
				@applyID varchar(10),		--�豸�������뵥���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ�����豸�������뵥������
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE queryEqpBorrowApplyLocMan
	@applyID varchar(10),		--�豸�������뵥���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from eqpBorrowApplyInfo where applyID= @applyID),'')
	set @Ret = 0
GO

drop PROCEDURE lockEqpBorrowApply4Edit
/*
	name:		lockEqpBorrowApply4Edit
	function:	12.�����豸�������뵥�༭������༭��ͻ
	input: 
				@applyID varchar(10),			--�豸�������뵥���
				@lockManID varchar(10) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�������豸�������뵥�����ڣ�2:Ҫ�������豸�������뵥���ڱ����˱༭��
							3:�õ����Ѿ����������ܱ༭������
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE lockEqpBorrowApply4Edit
	@applyID varchar(10),		--�豸�������뵥���
	@lockManID varchar(10) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�������豸�������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpBorrowApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from eqpBorrowApplyInfo 
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

	update eqpBorrowApplyInfo
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
	values(@lockManID, @lockManName, getdate(), '�����豸��������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���������豸�������뵥['+ @applyID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockEqpBorrowApplyEditor
/*
	name:		unlockEqpBorrowApplyEditor
	function:	13.�ͷ��豸�������뵥�༭��
				ע�⣺�����̲�����豸�������뵥�Ƿ���ڣ�
	input: 
				@applyID varchar(10),			--�豸�������뵥���
				@lockManID varchar(10) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE unlockEqpBorrowApplyEditor
	@applyID varchar(10),			--�豸�������뵥���
	@lockManID varchar(10) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpBorrowApplyInfo where applyID= @applyID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update eqpBorrowApplyInfo set lockManID = '' where applyID= @applyID
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
	values(@lockManID, @lockManName, getdate(), '�ͷ��豸����������', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ����豸�������뵥['+ @applyID +']�ı༭����')
GO


drop PROCEDURE addEqpBorrowApply
/*
	name:		addEqpBorrowApply
	function:	14.����豸�������뵥
	input: 
				@eCode char(8),					--�豸���
				@borrowerID varchar(10),		--�����˹���
				@lentTime varchar(19),			--���ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
				@expectedReturnTime varchar(19),--Ԥ�ƹ黹ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
				@borrowReason nvarchar(300),	--��������
				@linkInvoiceType smallint,		--�������ݣ�0->δ֪��1->ѧ�����棬2->���飬9->���� 
				@linkInvoice varchar(12),		--�������ݺ�

				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@applyID varchar(10) output		--�豸�������뵥��ţ���ϵͳʹ�õ�7�ź��뷢����������'JY'+4λ��ݴ���+4λ��ˮ�ţ�
	author:		¬έ
	CreateDate:	2013-1-22
	UpdateDate: modi by lw 2013-1-29�����豸���������������
*/
create PROCEDURE addEqpBorrowApply
	@eCode char(8),					--�豸���
	@borrowerID varchar(10),		--�����˹���
	@lentTime varchar(19),			--���ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
	@expectedReturnTime varchar(19),--Ԥ�ƹ黹ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
	@borrowReason nvarchar(300),	--��������
	@linkInvoiceType smallint,		--�������ݣ�0->δ֪��1->ѧ�����棬2->���飬9->���� 
	@linkInvoice varchar(12),		--�������ݺ�

	@createManID varchar(10),		--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@applyID varchar(10) output		--�豸�������뵥��ţ���ϵͳʹ�õ�7�ź��뷢����������'JY'+4λ��ݴ���+4λ��ˮ�ţ�
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢���������豸�������뵥��ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 7, 1, @curNumber output
	set @applyID = @curNumber
	
	--ȡ�����ˡ�������������
	declare @createManName nvarchar(30), @borrower nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	set @borrower = isnull((select cName from userInfo where jobNumber = @borrowerID),'')
	
	set @createTime = getdate()
	insert eqpBorrowApplyInfo(applyID, eCode, eName, eModel, eFormat,
						borrowerID, borrower, lentTime, expectedReturnTime, borrowReason,
						linkInvoiceType, linkInvoice,		--��������
						--����ά�����:
						modiManID, modiManName, modiTime)
	select @applyID, @eCode, eName, eModel, eFormat,
			@borrowerID, @borrower, @lentTime, @expectedReturnTime, @borrowReason,
			@linkInvoiceType,@linkInvoice,		--��������
						--����ά�����:
			@createManID, @createManName, @createTime
	from equipmentList
	where eCode = @eCode
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�Ǽ��豸��������', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ����豸�������뵥['+@applyID+']��')
GO
--���ԣ�
declare	@Ret		int
declare	@createTime smalldatetime
declare	@applyID varchar(10)
select @Ret, @applyID
select * from gasApplyInfo

drop PROCEDURE updateEqpBorrowApply
/*
	name:		updateEqpBorrowApply
	function:	15.�޸��豸�������뵥��Ϣ
	input: 
				@applyID varchar(10),			--�豸�������뵥���
				@eCode char(8),					--�豸���
				@borrowerID varchar(10),		--�����˹���
				@lentTime varchar(19),			--���ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
				@expectedReturnTime varchar(19),--Ԥ�ƹ黹ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
				@borrowReason nvarchar(300),	--��������
				@linkInvoiceType smallint,		--�������ݣ�0->δ֪��1->ѧ�����棬2->���飬9->���� 
				@linkInvoice varchar(12),		--�������ݺ�

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
	CreateDate:	2013-1-22
	UpdateDate: 
*/
create PROCEDURE updateEqpBorrowApply
	@applyID varchar(10),		--�豸�������뵥���
	@eCode char(8),					--�豸���
	@borrowerID varchar(10),		--�����˹���
	@lentTime varchar(19),			--���ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
	@expectedReturnTime varchar(19),--Ԥ�ƹ黹ʱ��:���á�yyyy-MM-dd hh:mm:ss����ʽ����
	@borrowReason nvarchar(300),	--��������
	@linkInvoiceType smallint,		--�������ݣ�0->δ֪��1->ѧ�����棬2->���飬9->���� 
	@linkInvoice varchar(12),		--�������ݺ�

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9
	
	--ע�⣺����û����Ҫ���õ��豸�Ƿ���ڵ��жϣ�

	--�ж�Ҫ�������豸�������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpBorrowApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from eqpBorrowApplyInfo
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

	--ȡά����/�����˵�������
	declare @modiManName nvarchar(30), @borrower nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	set @borrower = isnull((select cName from userInfo where jobNumber = @borrowerID),'')

	set @modiTime = getdate()
	update eqpBorrowApplyInfo
	set borrowerID = @borrowerID, borrower = @borrower, lentTime = @lentTime, 
		expectedReturnTime = @expectedReturnTime, borrowReason = @borrowReason,
		linkInvoiceType = @linkInvoiceType, linkInvoice = @linkInvoice,		--��������
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
	values(@modiManID, @modiManName, @modiTime, '�޸��豸��������', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸����豸�������뵥['+@applyID+']����Ϣ��')
GO

drop PROCEDURE delEqpBorrowApply
/*
	name:		delEqpBorrowApply
	function:	16.ɾ��ָ�����豸�������뵥
	input: 
				@applyID varchar(10),			--�豸�������뵥���
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�����豸�������뵥�����ڣ�2��Ҫɾ�����豸�������뵥��������������
							3���õ����Ѿ�����������ɾ����
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-22
	UpdateDate: 

*/
create PROCEDURE delEqpBorrowApply
	@applyID varchar(10),			--�豸�������뵥���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫɾ�����豸�������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpBorrowApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	select @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus 
	from eqpBorrowApplyInfo
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

	delete eqpBorrowApplyInfo where applyID= @applyID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���豸��������', '�û�' + @delManName
												+ 'ɾ�����豸�������뵥['+@applyID+']��')

GO
--���ԣ�
declare @Ret		int		--�����ɹ���ʶ
exec dbo.delEqpBorrowApply 'JY20130298','G201300001',@Ret output
select @Ret


drop PROCEDURE approveEqpBorrowApply
/*
	name:		approveEqpBorrowApply
	function:	17.����ָ�����豸�������뵥
	input: 
				@applyID varchar(10),				--�豸�������뵥���
				@isAgree smallint,					--�Ƿ�ͬ�⣺1->ͬ��,-1����ͬ��
				@approveOpinion nvarchar(300),		--�������
				@approveManID varchar(10) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output				--�����ɹ���ʶ
							0:�ɹ���1��ָ�����豸�������뵥�����ڣ�2��Ҫ�������豸�������뵥��������������
							3�����豸�������뵥�Ѿ�������
							4���õ��������ʱ����Ѿ���ռ�ã�
							5:��ִ�й������ݵĲ���ʱ����
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-1-22
	UpdateDate: modi by lw 2013-3-34���ӹ������ݴ���

*/
create PROCEDURE approveEqpBorrowApply
	@applyID varchar(10),				--�豸�������뵥���
	@isAgree smallint,					--�Ƿ�ͬ�⣺1->ͬ��,-1����ͬ��
	@approveOpinion nvarchar(300),		--�������
	@approveManID varchar(10) output,	--�����ˣ������ǰ�豸�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�������豸�������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpBorrowApplyInfo where applyID= @applyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10), @applyStatus smallint	--������/��������״̬��0->δ����1->����׼��-1������׼
	declare @eCode char(8)	--�豸���
	select @eCode = eCode, @thisLockMan = isnull(lockManID,''), @applyStatus = applyStatus
	from eqpBorrowApplyInfo 
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
	
	--��ȡ������Ϣ�����ʱ����Ƿ��ͻ��
	declare @lentTime smalldatetime, @expectedReturnTime smalldatetime
	declare @linkInvoiceType smallint	--�������ݣ�0->δ֪��1->ѧ�����棬2->���飬9->���� 
	declare @linkInvoice varchar(12)	--�������ݺ�
	select @lentTime = lentTime, @expectedReturnTime = expectedReturnTime, 
			@linkInvoiceType = linkInvoiceType, @linkInvoice = linkInvoice
	from eqpBorrowApplyInfo
	where applyID = @applyID
	set @count = isnull((select count(*) from eqpBorrowApplyInfo
					where eCode = @eCode and applyStatus = 1 and (@lentTime between lentTime and expectedReturnTime 
											or @expectedReturnTime between lentTime and expectedReturnTime )),0)
	if (@count > 0)
	begin
		set @Ret = 4
		return
	end

	--ȡ�����˵�������
	declare @approveMan nvarchar(30)
	set @approveMan = isnull((select userCName from activeUsers where userID = @approveManID),'')

	declare @approveTime smalldatetime
	set @approveTime = GETDATE()
	update eqpBorrowApplyInfo
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
	values(@approveManID, @approveMan, @approveTime, '�����豸��������', '�û�' + @approveMan
												+ '�������豸�������뵥['+@applyID+']��')

	--���ù������ݣ�
	declare @execRet int
	declare @needEqpCodes varchar(80)	--�������ݵ��豸���
	if (@linkInvoiceType=1)	--1->ѧ������
	begin
		set @needEqpCodes = isnull((select needEqpCodes from academicReports where aReportID = @linkInvoice),'')

		set @count = isnull((select count(*) from eqpBorrowApplyInfo 
						where linkInvoiceType = 1 and linkInvoice = @linkInvoice and applyStatus=0
						and eCode in (SELECT cast(T.x.query('data(.)') as char(8)) FROM 
										(SELECT CONVERT(XML,'<x>'+REPLACE(@needEqpCodes,',','</x><x>')+'</x>',1) Col1) A
										OUTER APPLY A.Col1.nodes('/x') AS T(x))
									),'')
		if (@count=0)
		begin
			exec dbo.eqpIsReady4Meeting @linkInvoice, @execRet output
			if (@execRet <> 0)
				set @Ret = 5
		end
	end
	else if (@linkInvoiceType=2)--2->����
	begin
		set @needEqpCodes = isnull((select needEqpCodes from meetingInfo where meetingID = @linkInvoice),'')

		set @count = isnull((select count(*) from eqpBorrowApplyInfo 
						where linkInvoiceType = 2 and linkInvoice = @linkInvoice and applyStatus=0
						and eCode in (SELECT cast(T.x.query('data(.)') as char(8)) FROM 
										(SELECT CONVERT(XML,'<x>'+REPLACE(@needEqpCodes,',','</x><x>')+'</x>',1) Col1) A
										OUTER APPLY A.Col1.nodes('/x') AS T(x))
									),'')
		if (@count=0)
		begin
			exec dbo.eqpIsReady4Meeting @linkInvoice, @execRet output
			if (@execRet <> 0)
				set @Ret = 5
		end
	end
GO



--�����豸״̬һ�����ѯ��䣺
select s.eCode, e.eName, e.eModel, e.eFormat, e.curEqpStatus, e.unit, e.price, e.totalAmount, 
	e.currency, e.cPrice, e.cTotalAmount, 
	e.uCode, u.uName, e.keeperID, e.keeper, e.eqpLocate,
	isnull(s.borrowerID,'') borrowerID, isnull(s.borrower,''), convert(varchar(19),s.lentTime,120) lentTime, 
	convert(varchar(19),s.expectedReturnTime,120) expectedReturnTime, s.borrowReason,
	s.isShare, convert(varchar(19),s.setOffDate,120) setOffDate
from shareEqpStatus s left join equipmentList e on s.eCode = e.eCode
	left join useUnit u on u.uCode = e.uCode


--ָ���Ĺ����豸��������ǼǱ�
select b.eCode, e.eName, e.eModel, e.eFormat,
	isnull(b.applyID,'') applyID, isnull(b.borrowerID,''), isnull(b.borrower,''), 
	convert(varchar(19),b.lentTime,120) lentTime, 
	convert(varchar(19),b.expectedReturnTime,120) expectedReturnTime,
	b.borrowReason, convert(varchar(19),b.returnTime,120) returnTime
from eqpBorrowInfo b left join equipmentList e on b.eCode = e.eCode
order by rowNum desc



--��ѯָ�������豸ָ�����ں�����н������뵥��
select applyID, eCode, applyStatus, eName, eModel, eFormat, 
	borrowerID, borrower,
	convert(varchar(19),lentTime,120) lentTime, 
	convert(varchar(19),expectedReturnTime,120) expectedReturnTime,
	borrowReason
from eqpBorrowApplyInfo


select b.eCode, e.eName, e.eModel, e.eFormat,isnull(b.applyID,'') applyID, isnull(b.borrowerID,'') borrowerID, 
isnull(b.borrower,'') borrower, convert(varchar(19),b.lentTime,120) lentTime, 
convert(varchar(19),b.expectedReturnTime,120) expectedReturnTime,b.borrowReason, 
convert(varchar(19),b.returnTime,120) returnTime
from  eqpBorrowInfo b left join equipmentList e on b.eCode = e.eCode




select s.eCode, e.eName, e.eModel, e.eFormat, e.curEqpStatus, e.unit, e.price, 
e.totalAmount, e.currency, e.cPrice, e.cTotalAmount,e.uCode, u.uName, e.keeperID, e.keeper, e.eqpLocate,
isnull(s.borrowerID,'') borrowerID, isnull(s.borrower,'') borrower, 
convert(varchar(19),s.lentTime,120) lentTime, 
convert(varchar(19),s.expectedReturnTime,120) expectedReturnTime, 
s.borrowReason,s.isShare, convert(varchar(19),s.setOffDate,120) setOffDate
from shareEqpStatus s left join equipmentList e on s.eCode = e.eCode
left join useUnit u on u.uCode = e.uCode


select applyID, eCode, applyStatus, eName, eModel, eFormat,
borrowerID, borrower,
convert(varchar(19),lentTime,120) lentTime, 
convert(varchar(19),expectedReturnTime,120) expectedReturnTime,
borrowReason
from eqpBorrowApplyInfo
where eCode = '20130190' and (lentTime BETWEEN '2013-03-20 12:00:00' and '2013-03-20 14:00:00')
order by lentTime
