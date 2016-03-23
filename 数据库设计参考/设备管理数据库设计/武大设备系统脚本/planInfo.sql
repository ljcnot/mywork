use epdc211

/*
	����豸������Ϣϵͳ-�ɹ��ƻ������洢����
	author:		¬έ
	CreateDate:	2010-12-1
	UpdateDate: modi by lw 2012-8-15���漰����Ա�Ĳ��ָĳ�ʹ�ù��ſ��ƣ����Ӵ������ֶΣ�����ϸ���͸�Ҫ���洢���̴�����
*/


--�ͻ����󣺿��ǲɹ����룬�ɹ���������Ҫ����ͬ���豸���

--1.�ɹ��ƻ���Ҫ����
select ROW_NUMBER() OVER(order by buyDate) AS RowID, eTypeCode, eTypeName, aTypeCode, eName, eModel, eFormat, convert(char(10),buyDate,120) buyDate, price, totalAmount, keeper
from equipmentList

select * from eqpPlanInfo
delete eqpPlanInfo where planApplyID not in ('201101240001','201101230003')
drop TABLE eqpPlanInfo

alter TABLE eqpPlanInfo alter column totalMoney numeric(15,2) default(0)--�ܽ��:�޸��������� modi by lw 2012-10-27
alter TABLE eqpPlanInfo alter column totalNowNum int default(0)			--����������


drop TABLE eqpPlanInfo
CREATE TABLE eqpPlanInfo
(
	planApplyID char(12) not null,		--�������ɹ��ƻ����ţ�ʹ�õ� 10 �ź��뷢��������
	applyDate smalldatetime default(getdate()),	--��������
	planApplyStatus int default(0),		--�ɹ��ƻ���״̬��0->���ڱ��ƣ�1->��ִ��

	--���뵥λ����Ҫ�û�ȷ����ֻ��Ժ�����ǵ�ʹ�õ�λ����
	clgCode char(3) not null,			--ѧԺ����
	clgName nvarchar(30) null,			--ѧԺ����:������ƣ�������ʷ����
	uCode varchar(8) null,				--ʹ�õ�λ����, modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	uName nvarchar(30) null,			--ʹ�õ�λ����:������ƣ�������ʷ����

	fCode char(2) not null,				--������Դ����
	aCode char(2) not null,				--ʹ�÷������
	
	totalNum int default(0),			--������:����������100����
	totalMoney numeric(15,2) default(0),--�ܽ��:�޸��������� modi by lw 2012-10-27
	totalNowNum int default(0),			--����������
	
	buyReason nvarchar(300) null,		--���빺������
	clgManagerID varchar(10) null,		--��λ�����˹��� add by lw 2012-8-15
	clgManager nvarchar(30) null,		--��λ������
	clgManagerADate smalldatetime null,	--��λ������ǩ������
	
	leaderComments nvarchar(300) null,	--У�쵼���
	leaderID varchar(10) null,			--У�쵼���� add by lw 2012-8-15
	leaderName nvarchar(30) null,		--У�쵼����
	leaderADate smalldatetime null,		--У�쵼ǩ������
	
	processManID varchar(10) null,		--ִ���ˣ��豸����Ա�����ţ�UI����ʱ��Ҫ���֣�ֱ��ʹ�õ�ǰ�û��浵��
	processMan nvarchar(30) null,		--ִ���ˣ��豸����Ա��
	processDate smalldatetime null,		--ִ������

	--�����ˣ�add by lw 2012-8-15Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_eqpPlanInfo] PRIMARY KEY CLUSTERED 
(
	[planApplyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
CREATE NONCLUSTERED INDEX [IX_eqpPlanInfo] ON [dbo].[eqpPlanInfo] 
(
	[clgCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_eqpPlanInfo_1] ON [dbo].[eqpPlanInfo] 
(
	[applyDate] desc
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_eqpPlanInfo_2] ON [dbo].[eqpPlanInfo] 
(
	[processDate] desc
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_eqpPlanInfo_3] ON [dbo].[eqpPlanInfo] 
(
	[fCode] desc
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_eqpPlanInfo_4] ON [dbo].[eqpPlanInfo] 
(
	[aCode] desc
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--2.�ɹ��ƻ���ϸ��
drop table eqpPlanDetail
CREATE TABLE eqpPlanDetail(
	planApplyID char(12) not null,		--�������ɹ��ƻ����ţ�ʹ�õ� 10 �ź��뷢��������
	rowNum int IDENTITY(1,1) NOT NULL,	--���
	eTypeCode char(8) not null,			--�����ţ��̣�
	eTypeName nvarchar(30) not null,	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
	aTypeCode char(6) not null,			--�����ţ��ƣ�
	
	eName nvarchar(30) not null,		--�豸����
	eModel nvarchar(20) not null,		--�豸�ͺ�
	price numeric(12,2) null,			--����:�޸��������� modi by lw 2012-10-27
	sumNumber int not null,				--����
	nowNum int default(0),				--��������
 CONSTRAINT [PK_eqpPlanDetail] PRIMARY KEY CLUSTERED 
(
	[planApplyID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[eqpPlanDetail] WITH CHECK ADD CONSTRAINT [FK_eqpPlanDetail_eqpPlanInfo] FOREIGN KEY([planApplyID])
REFERENCES [dbo].[eqpPlanInfo] ([planApplyID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpPlanDetail] CHECK CONSTRAINT [FK_eqpPlanDetail_eqpPlanInfo]
GO

select * from eqpPlanDetail
insert eqpPlanDetail(planApplyID, eTypeCode, eTypeName, aTypeCode, eName,eModel,price,sumNumber,nowNum)
select planApplyID, eTypeCode, eTypeName, aTypeCode, '�����豸',eModel,price,sumNumber,nowNum
from eqpPlanDetail

drop PROCEDURE addPlanInfo
/*
	name:		addPlanInfo
	function:	1.��Ӳɹ��ƻ����뵥
				ע�⣺�ô洢�����Զ���������
	input: 
				@applyDate varchar(10),			--��������
				--���뵥λ��
				@clgCode char(3),				--ѧԺ����
				@uCode varchar(8),				--ʹ�õ�λ����
				@fCode char(2),					--������Դ����
				@aCode char(2),					--ʹ�÷������
				@planApplyDetail xml,			--ʹ��xml�洢����ϸ�嵥��N'<root>
																			--<row id="1">
																			--	<eTypeCode>04090401</eTypeCode>
																			--	<eTypeName>�����綯��</eTypeName>
																			--	<aTypeCode>603200</aTypeCode>
																			--	<eName>һ����;�첽�綯��</eName>
																			--	<eModel>YD100</eModel>
																			--	<price>1250.00</price>
																			--	<sumNumber>5</sumNumber>
																			--	<nowNum>10</nowNum>
																			--</row>
																			--<row id="2">
																			--	<eTypeCode>04090401</eTypeCode>
																			--	<eTypeName>���໬��ʽ�첽���</eTypeName>
																			--	<aTypeCode>603200</aTypeCode>
																			--	<eName>һ����;�첽�綯��</eName>
																			--	<eModel>SX100</eModel>
																			--	<price>2000.00</price>
																			--	<sumNumber>2</sumNumber>
																			--	<nowNum>5</nowNum>
																			--</row>
																		--</root>'
				@buyReason nvarchar(300),		--���빺������
				@clgManagerID varchar(10),		--��λ�����˹���
				@clgManagerADate varchar(10),	--��λ������ǩ������
				
				@leaderComments nvarchar(300),	--У�쵼���
				@leaderID varchar(10),			--У�쵼����
				@leaderADate varchar(10),		--У�쵼ǩ������
				
				@createManID varchar(10),		--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output	--���ʱ��
				@planApplyID char(12) output	--�������ɹ��ƻ����ţ�ʹ�õ� 10 �ź��뷢��������
	author:		¬έ
	CreateDate:	2011-1-16
	UpdateDate: modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2012-8-15����Ա���ù��Ŵ�������ϸ���ı�����ڱ������ڲ������Ӵ������ֶ�
				modi by lw 2012-10-27�޸Ľ������ֶε���������
*/
create PROCEDURE addPlanInfo
	@applyDate varchar(10),			--��������
	--���뵥λ��
	@clgCode char(3),				--ѧԺ����
	@uCode varchar(8),				--ʹ�õ�λ����
	@fCode char(2),					--������Դ����
	@aCode char(2),					--ʹ�÷������
	@planApplyDetail xml,			--ʹ��xml�洢����ϸ�嵥
	@buyReason nvarchar(300),		--���빺������
	@clgManagerID varchar(10),		--��λ�����˹���
	@clgManagerADate varchar(10),	--��λ������ǩ������
	
	@leaderComments nvarchar(300),	--У�쵼���
	@leaderID varchar(10),			--У�쵼����
	@leaderADate varchar(10),		--У�쵼ǩ������
	
	@createManID varchar(10),		--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,
	@planApplyID char(12) output	--�������ɹ��ƻ����ţ�ʹ�õ� 10 �ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10, 1, @curNumber output
	set @planApplyID = @curNumber

	--��ȡԺ���ʹ�õ�λ�����ƣ�
	declare @clgName nvarchar(30), @uName nvarchar(30)	--ѧԺ����/ʹ�õ�λ����
	set @clgName = (select clgName from college where clgCode = @clgCode)
	set @uName = (select uName from useUnit where uCode = @uCode)

	--��ȡ��λ������\У�쵼������
	declare @clgManager nvarchar(30), @leaderName nvarchar(30)
	set @clgManager = isnull((select cName from userInfo where jobNumber = @clgManagerID),'')
	set @leaderName = isnull((select cName from userInfo where jobNumber = @leaderID),'')

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	begin tran
		insert eqpPlanInfo(planApplyID,applyDate,
							--���뵥λ����Ҫ�û�ȷ����ֻ��Ժ�����ǵ�ʹ�õ�λ����
							clgCode, clgName, uCode, uName,
							fCode, aCode,
							buyReason, clgManagerID, clgManager, clgManagerADate,
							leaderComments, leaderID, leaderName, leaderADate,
							processManID, processMan,
							lockManID, modiManID, modiManName, modiTime,
							createManID, createManName, createTime) 
		values (@planApplyID,@applyDate,
							--���뵥λ����Ҫ�û�ȷ����ֻ��Ժ�����ǵ�ʹ�õ�λ����
							@clgCode, @clgName, @uCode, @uName,
							@fCode, @aCode,
							@buyReason, @clgManagerID, @clgManager, @clgManagerADate,
							@leaderComments, @leaderID, @leaderName, @leaderADate,
							@createManID, @createManName,
							@createManID, @createManID, @createManName, @createTime,
							@createManID, @createManName, @createTime) 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--������ϸ��
		insert eqpPlanDetail(planApplyID, eTypeCode, eTypeName, aTypeCode,	
								eName, eModel, price, sumNumber, nowNum)
		select @planApplyID, cast(T.x.query('data(./eTypeCode)') as char(8)), 
			cast(T.x.query('data(./eTypeName)') as nvarchar(30)),
			cast(T.x.query('data(./aTypeCode)') as char(8)), 
			cast(T.x.query('data(./eName)') as nvarchar(30)), 
			cast(T.x.query('data(./eModel)') as nvarchar(20)), 
			cast(cast(T.x.query('data(./price)') as varchar(20)) as numeric(12,2)), 
			cast(cast(T.x.query('data(./sumNumber)') as varchar(10)) as int), 
			cast(cast(T.x.query('data(./nowNum)') as varchar(10)) as int)
			from(select @planApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--���������Ϣ��
		declare @totalNum int, @totalMoney numeric(15,2), @totalNowNum int			--������/�ܽ��/����������
		select @totalNum = sum(sumNumber), @totalMoney = sum(price * sumNumber), @totalNowNum = sum(nowNum)
		from eqpPlanDetail
		where planApplyID = @planApplyID
		
		update eqpPlanInfo
		set totalNum = @totalNum, totalMoney = @totalMoney, totalNowNum = @totalNowNum
		where planApplyID = @planApplyID
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
	values(@createManID, @createManName, @createTime, '��Ӳɹ��ƻ����뵥', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˲ɹ��ƻ����뵥[' + @planApplyID + ']��')
GO
--���ԣ�
select * from eqpPlanInfo
declare @createTime smalldatetime; set @createTime = getdate();
declare	@planApplyID char(12), @Ret int
DECLARE @String xml;
set @String = N'
<root>
	<row id="1">
	<eTypeCode>01010101</eTypeCode>
	<eTypeName>��ѧ�����÷�</eTypeName>
	<aTypeCode>025201 </aTypeCode>
	<eName>��ѧ�����÷�</eName>
	<eModel>*</eModel>
	<price>20101.00</price>
	<sumNumber>2</sumNumber>
	<nowNum>0</nowNum>
	</row>
</root>
'
exec dbo.addPlanInfo @createTime, '000', '00000','1','1', '00000000000', @Ret output, @createTime output, @planApplyID output
select @createTime, @planApplyID, @Ret

select * from eqpPlanInfo


update eqpPlanInfo 
set lockManID = ''
where planApplyID = '201101180004'
select * from eqpPlanDetail where planApplyID = '201101180004'
select * from eqpPlanInfo where planApplyID = '201101180004'
select * from workNote order by actionTime desc

drop PROCEDURE updatePlanInfo
/*
	name:		updatePlanInfo
	function:	2.���²ɹ��ƻ���
	input: 
				@planApplyID char(12),				--�ɹ��ƻ�����
				@applyDate varchar(10),				--��������

				--���뵥λ����Ҫ�û�ȷ����ֻ��Ժ�����ǵ�ʹ�õ�λ����
				@clgCode char(3),					--ѧԺ����
				@uCode varchar(8),					--ʹ�õ�λ����

				@fCode char(2),						--������Դ����
				@aCode char(2),						--ʹ�÷������
				@planApplyDetail xml,			--ʹ��xml�洢����ϸ�嵥��N'<root>
																			--<row id="1">
																			--	<eTypeCode>04090401</eTypeCode>
																			--	<eTypeName>�����綯��</eTypeName>
																			--	<aTypeCode>603200</aTypeCode>
																			--	<eName>һ����;�첽�綯��</eName>
																			--	<eModel>YD100</eModel>
																			--	<price>1250.00</price>
																			--	<sumNumber>5</sumNumber>
																			--	<nowNum>10</nowNum>
																			--</row>
																			--<row id="2">
																			--	<eTypeCode>04090401</eTypeCode>
																			--	<eTypeName>���໬��ʽ�첽���</eTypeName>
																			--	<aTypeCode>603200</aTypeCode>
																			--	<eName>һ����;�첽�綯��</eName>
																			--	<eModel>SX100</eModel>
																			--	<price>2000.00</price>
																			--	<sumNumber>2</sumNumber>
																			--	<nowNum>5</nowNum>
																			--</row>
																		--</root>'
				
				@buyReason nvarchar(300),			--���빺������
				@clgManagerID varchar(10),			--��λ�����˹���
				@clgManagerADate varchar(10),		--��λ������ǩ������
				
				@leaderComments nvarchar(300),		--У�쵼���
				@leaderID nvarchar(30),				--У�쵼����
				@leaderADate varchar(10),			--У�쵼ǩ������

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ�ɹ��ƻ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0���ɹ���1��Ҫ���µĵ��ݲ����ڣ�
							2��Ҫ���µĲɹ��ƻ�����������������
							3���õ����Ѿ�ִ�У��������޸ģ�
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-1-16
	UpdateDate: modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2012-8-15����Ա���ù��Ŵ�������ϸ���ı�����ڱ������ڲ�
				modi by lw 2012-10-27�޸Ľ������ֶε���������
*/
create PROCEDURE updatePlanInfo
	@planApplyID char(12),				--�ɹ��ƻ�����
	@applyDate varchar(10),				--��������

	--���뵥λ����Ҫ�û�ȷ����ֻ��Ժ�����ǵ�ʹ�õ�λ����
	@clgCode char(3),					--ѧԺ����
	@uCode varchar(8),					--ʹ�õ�λ����

	@fCode char(2),						--������Դ����
	@aCode char(2),						--ʹ�÷������
	@planApplyDetail xml,				--ʹ��xml�洢����ϸ�嵥
	
	@buyReason nvarchar(300),			--���빺������
	@clgManagerID varchar(10),			--��λ�����˹���
	@clgManagerADate varchar(10),		--��λ������ǩ������
	
	@leaderComments nvarchar(300),		--У�쵼���
	@leaderID varchar(10),				--У�쵼����
	@leaderADate varchar(10),			--У�쵼ǩ������
	
	--ά����:
	@modiManID varchar(10) output,		--ά���ˣ������ǰ�ɹ��ƻ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,	--����ʱ��
	@Ret		int output				--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpPlanInfo where planApplyID = @planApplyID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpPlanInfo where planApplyID = @planApplyID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	declare @planApplyStatus int
	set @planApplyStatus = (select planApplyStatus from eqpPlanInfo where planApplyID = @planApplyID)
	if (@planApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end
	
	--��ȡԺ���ʹ�õ�λ�����ƣ�
	declare @clgName nvarchar(30), @uName nvarchar(30)	--ѧԺ����/ʹ�õ�λ����
	set @clgName = (select clgName from college where clgCode = @clgCode)
	set @uName = (select uName from useUnit where uCode = @uCode)

	--��ȡ��λ������\У�쵼������
	declare @clgManager nvarchar(30), @leaderName nvarchar(30)
	set @clgManager = isnull((select cName from userInfo where jobNumber = @clgManagerID),'')
	set @leaderName = isnull((select cName from userInfo where jobNumber = @leaderID),'')

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		--���¸�Ҫ��
		update eqpPlanInfo 
		set applyDate = @applyDate, 
			clgCode = @clgCode, clgName = @clgName, uCode = @uCode, uName = @uName,
			fCode = @fCode, aCode = @aCode,
			buyReason = @buyReason, clgManagerID = @clgManagerID, clgManager = @clgManager, clgManagerADate = @clgManagerADate,	
			leaderComments = @leaderComments, leaderID = @leaderID, leaderName = @leaderName, leaderADate = @leaderADate,
			processManID = @modiManID, processMan = @modiManName,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where planApplyID = @planApplyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--ɾ��ԭ�ɹ��ƻ���ϸ����
		delete eqpPlanDetail where planApplyID = @planApplyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--������ϸ����
		insert eqpPlanDetail(planApplyID, eTypeCode, eTypeName, aTypeCode,	
								eName, eModel, price, sumNumber, nowNum)
		select @planApplyID, cast(T.x.query('data(./eTypeCode)') as char(8)), 
			cast(T.x.query('data(./eTypeName)') as nvarchar(30)),
			cast(T.x.query('data(./aTypeCode)') as char(8)), 
			cast(T.x.query('data(./eName)') as nvarchar(30)), 
			cast(T.x.query('data(./eModel)') as nvarchar(20)), 
			cast(cast(T.x.query('data(./price)') as varchar(20)) as numeric(12,2)), 
			cast(cast(T.x.query('data(./sumNumber)') as varchar(10)) as int), 
			cast(cast(T.x.query('data(./nowNum)') as varchar(10)) as int)
			from(select @planApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--���������Ϣ��
		declare @totalNum int, @totalMoney numeric(15,2), @totalNowNum int			--������/�ܽ��/����������
		select @totalNum = sum(sumNumber), @totalMoney = sum(price * sumNumber), @totalNowNum = sum(nowNum)
		from eqpPlanDetail
		where planApplyID = @planApplyID
		
		update eqpPlanInfo
		set totalNum = @totalNum, totalMoney = @totalMoney, totalNowNum = @totalNowNum
		where planApplyID = @planApplyID
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
	values(@modiManID, @modiManName, @updateTime, '���²ɹ��ƻ���', '�û�' + @modiManName 
												+ '�����˲ɹ��ƻ���['+ @planApplyID +']��')
GO




drop PROCEDURE queryPlanApplyLocMan
/*
	name:		queryPlanApplyLocMan
	function:	3.��ѯָ���ɹ��ƻ����뵥�Ƿ��������ڱ༭
	input: 
				@planApplyID char(12),		--�������ɹ��ƻ����ţ�ʹ�õ� 10 �ź��뷢��������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ĳɹ��ƻ���������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2011-1-16
	UpdateDate: 
*/
create PROCEDURE queryPlanApplyLocMan
	@planApplyID char(12),		--�������ɹ��ƻ����ţ�ʹ�õ� 10 �ź��뷢��������
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from eqPlanInfo where planApplyID = @planApplyID),'')
	set @Ret = 0
GO


drop PROCEDURE lockPlanInfo4Edit
/*
	name:		lockPlanInfo4Edit
	function:	4.�����ɹ��ƻ����༭������༭��ͻ
	input: 
				@planApplyID char(12),		--�������ɹ��ƻ����ţ�ʹ�õ� 10 �ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�ɹ��ƻ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ĳɹ��ƻ��������ڣ�2:Ҫ�����Ĳɹ��ƻ������ڱ����˱༭��3:�õ��������
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-1-16
	UpdateDate: 
*/
create PROCEDURE lockPlanInfo4Edit
	@planApplyID char(12),		--�������ɹ��ƻ����ţ�ʹ�õ� 10 �ź��뷢��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�ɹ��ƻ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĳɹ��ƻ����Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpPlanInfo where planApplyID = @planApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpPlanInfo where planApplyID = @planApplyID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	declare @planApplyStatus int
	set @planApplyStatus = (select planApplyStatus from eqpPlanInfo where planApplyID = @planApplyID)
	if (@planApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end

	update eqpPlanInfo 
	set lockManID = @lockManID 
	where planApplyID = @planApplyID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�����ɹ��ƻ����༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˲ɹ��ƻ���['+ @planApplyID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockPlanInfoEditor
/*
	name:		unlockPlanInfoEditor
	function:	5.�ͷŲɹ��ƻ����༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@planApplyID char(12),		--�������ɹ��ƻ����ţ�ʹ�õ� 10 �ź��뷢��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ�ɹ��ƻ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2011-1-16
	UpdateDate: 
*/
create PROCEDURE unlockPlanInfoEditor
	@planApplyID char(12),		--�������ɹ��ƻ����ţ�ʹ�õ� 10 �ź��뷢��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ�ɹ��ƻ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpPlanInfo where planApplyID = @planApplyID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update eqpPlanInfo set lockManID = '' where planApplyID = @planApplyID
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
	values(@lockManID, @lockManName, getdate(), '�ͷŲɹ��ƻ����༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˲ɹ��ƻ���['+ @planApplyID +']�ı༭����')
GO



drop PROCEDURE delPlanApply
/*
	name:		delPlanApply
	function:	7.ɾ��ָ�����������뵥
	input: 
				@planApplyID char(12),	--�������뵥��
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�����������뵥�����ڣ�2��Ҫɾ�����������뵥��������������3��������ִ�У�����ɾ����9��δ֪����
	author:		¬έ
	CreateDate:	2011-1-16
	UpdateDate: 

*/
create PROCEDURE delPlanApply
	@planApplyID char(12),	--�ɹ��ƻ�����
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ�����������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from eqpPlanInfo where planApplyID = @planApplyID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpPlanInfo where planApplyID = @planApplyID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	--��鵥��״̬:
	declare @planApplyStatus int			--�ɹ��ƻ���״̬��0->δִ�У� 1->��ִ��
	set @planApplyStatus = (select planApplyStatus from eqpPlanInfo where planApplyID = @planApplyID)
	if (@planApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end

	delete eqpPlanInfo where planApplyID = @planApplyID
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���������뵥', '�û�' + @delManName
												+ 'ɾ�����������뵥['+ @planApplyID +']��')

GO


drop PROCEDURE execPlanApply
/*
	name:		execPlanApply
	function:	8.ִ�вɹ��ƻ����뵥�����������յ�
	input: 
				@planApplyID char(12),			--�ɹ��ƻ�����

				--ά����:
				@execManID varchar(10) output,	--ִ���ˣ������ǰ�ɹ��ƻ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@execDate smalldatetime output,	--ִ������
				@Ret		int output				--�����ɹ���ʶ
													0:�ɹ���1��Ҫִ�еĲɹ��ƻ�����������������2���òɹ��ƻ����Ѿ�ִ�У�3��ϵͳ��ִ�вɹ��ƻ���ʱ����δ֪����
													9��δ֪����
	author:		¬έ
	CreateDate:	201-1-16
	UpdateDate: modi by lw 2012-6-10����������벻��Ϊ�յĴ���
				modi by lw 2012-10-27�޸Ľ������ֶε���������
*/
create PROCEDURE execPlanApply
	@planApplyID char(12),			--�ɹ��ƻ�����

	--ά����:
	@execManID varchar(10) output,	--ִ���ˣ������ǰ�ɹ��ƻ������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@execDate smalldatetime output,	--ִ������
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpPlanInfo where planApplyID = @planApplyID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @execManID)
	begin
		set @execManID = @thisLockMan
		set @Ret = 1
		return
	end

	--�ٴμ�鵥��״̬:
	declare @planApplyStatus int			--�ɹ��ƻ���״̬��0->δִ�У� 1->��ִ��
	set @planApplyStatus = (select planApplyStatus from eqpPlanInfo where planApplyID = @planApplyID)
	if (@planApplyStatus <> 0)
	begin
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @execMan nvarchar(30)
	set @execMan = isnull((select userCName from activeUsers where userID = @execManID),'')
	
	set @execDate = getdate()
	
	--ȡ��Ҫ���е����뵥λ����Ϣ��
	declare @clgCode char(3)	--ѧԺ����
	declare @uCode char(5)		--ʹ�õ�λ����
	declare @fCode char(2)		--������Դ����
	declare @aCode char(2)		--ʹ�÷������
	select @clgCode = clgCode, @uCode = uCode, @fCode = fCode, @aCode = aCode
	from eqpPlanInfo 
	where planApplyID = @planApplyID
	--��ȡԺ���ʹ�õ�λ�����ƣ�
	declare @clgName nvarchar(30), @uName nvarchar(30)	--ѧԺ����/ʹ�õ�λ����
	set @clgName = (select clgName from college where clgCode = @clgCode)
	set @uName = (select uName from useUnit where uCode = @uCode)
	--ִ�вɹ����뵥��
	begin tran
		set @Ret = 3
		--����������������嵥��
		declare @eTypeCode char(8)		--�����ţ��̣�
		declare @eTypeName nvarchar(30)	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
		declare @aTypeCode char(6)		--�����ţ��ƣ�
		declare @eName nvarchar(30)		--�豸����
		declare @eModel nvarchar(20)	--�豸�ͺ�
		declare @price money			--����
		declare @sumNumber int			--����
		declare tar cursor for
		select eTypeCode, eTypeName, aTypeCode, eName, eModel, price, sumNumber
		from eqpPlanDetail
		where planApplyID = @planApplyID
		order by rowNum
		OPEN tar
		FETCH NEXT FROM tar INTO @eTypeCode, @eTypeName, @aTypeCode, @eName, @eModel, @price, @sumNumber
		WHILE @@FETCH_STATUS = 0
		begin
			--ʹ�ú��뷢���������µĺ��룺
			declare @acceptApplyID char(12)			--���յ���
			declare @curNumber varchar(50)
			exec dbo.getClassNumber 1, 1, @curNumber output
			set @acceptApplyID = @curNumber

			--�����
			declare @totalAmount numeric(12,2)			--�ܼ�, >0�����ۣ�
			declare @sumAmount numeric(15,2)			--�ϼƽ��
			set @totalAmount = 	@price
			set @sumAmount = @totalAmount * @sumNumber
			
			--�������������������ź͸�����ţ�
			declare @serialNumber nvarchar(2100)	--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
			declare @annexCode nvarchar(2100)		--����������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
			exec dbo.buildNumberString @sumNumber, @serialNumber output
			exec dbo.buildNumberString @sumNumber, @annexCode output
			
			insert eqpAcceptInfo(acceptApplyID, applyDate, procurementPlanID, eTypeCode, eTypeName, aTypeCode, eName,
									eModel, eFormat, cCode, serialNumber, 
									clgCode, clgName, uCode, uName, 
									fCode, aCode,
									factory, buyDate, business,
									price, totalAmount, sumNumber, sumAmount,
									lockManID, modiManID, modiManName, modiTime) 
			values (@acceptApplyID, @execDate, @planApplyID, @eTypeCode, @eTypeName, @aTypeCode, @eName,
									@eModel, '', '', @serialNumber, 
									@clgCode, @clgName, @uCode, @uName, 
									@fCode, @aCode,
									'', GETDATE(), '',
									@price, @totalAmount, @sumNumber, @sumAmount,
									'', @execManID, @execMan, @execDate)
			if @@ERROR <> 0 
			begin
				rollback tran
				CLOSE tar
				DEALLOCATE tar
				set @Ret = 9
				return
			end    
			FETCH NEXT FROM tar INTO @eTypeCode, @eTypeName, @aTypeCode, @eName, @eModel, @price, @sumNumber
		end
		CLOSE tar
		DEALLOCATE tar

		--���²ɹ����뵥״̬��
		update eqpPlanInfo
		set planApplyStatus = 1,	 --�ɹ��ƻ���״̬��0->δִ�У� 1->��ִ��
			--ִ����
			processManID = @execManID, processMan = @execMan, processDate = @execDate,
			--ά���ˣ�
			modiManID = @execManID, modiManName = @execMan,	modiTime = @execDate
		where planApplyID = @planApplyID
	commit tran	
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@execManID, @execMan, @execDate, 'ִ�вɹ��ƻ�', '�û�' + @execMan
												+ 'ִ���˲ɹ��ƻ���['+ @planApplyID +'],ϵͳ�Զ���������Ӧ�����յ���')
GO
--���ԣ�
select * from eqpPlanDetail where planApplyID = '201101180003'
select * from eqpPlanInfo where planApplyID = '201101180003'
select * from workNote order by actionTime desc
update eqpPlanInfo
set lockManID = ''
where planApplyID = '201101180003'

declare @execDate smalldatetime
declare @Ret int
exec dbo.execPlanApply '201101180003', '10000020', @execDate output, @Ret output
select @execDate, @Ret

select top 1000 * from eqpAcceptInfo order by applyDate desc

drop PROCEDURE buildNumberString
/*
	name:		buildNumberString
	function:	8.1�����á�|���ָ���ִ�
	input: 
				@items int,						--����
	output: 
				@sNumber varchar(2000) output	--������ַ���
	author:		¬έ
	CreateDate:	201-1-18
	UpdateDate: 
*/
create PROCEDURE buildNumberString
	@items int,						--����
	@sNumber nvarchar(2100) output	--������ַ���
	WITH ENCRYPTION 
AS
	set @sNumber = ''
    if (@items <= 0)
        return

    declare @i int
    set @i = 1
    while @i <= @items
    begin
		set @sNumber = @sNumber + ltrim(str(@i)) + '|'
	    set @i = @i + 1
    end
	set @sNumber = substring(@sNumber, 1, len(@sNumber) -1)
go
--���ԣ�
declare @str varchar(2000)
exec dbo.buildNumberString 5,@str output
select @str

drop PROCEDURE unexecPlanApply
/*
	name:		unexecPlanApply
	function:	9.ȡ��ִ�вɹ��ƻ����뵥������Ӧɾ�����ɵ����յ�
	input: 
				@planApplyID char(12),			--�ɹ��ƻ�����

				--ά����:
				@unexecManID varchar(10),		--ȡ��ִ����
	output: 
				@unexecDate smalldatetime output,	--ȡ������
				@Ret		int output				--�����ɹ���ʶ
													0:�ɹ���
													1: �õ��ݲ�����ִ��״̬��
													2��Ҫȡ���Ĳɹ��ƻ������ɵ��������뵥�������������༭��
													3��Ҫȡ���Ĳɹ��ƻ������ɵ��������뵥�Ѿ�ִ�У�����ȡ�����գ�
													9��δ֪����
	author:		¬έ
	CreateDate:	201-1-18
	UpdateDate: 
*/
create PROCEDURE unexecPlanApply
	@planApplyID char(12),			--�ɹ��ƻ�����

	--ά����:
	@unexecManID varchar(10),		--ȡ��ִ����
	@unexecDate smalldatetime output,--ȡ������
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--��鵥��״̬:
	declare @planApplyStatus int			--�ɹ��ƻ���״̬��0->δִ�У� 1->��ִ��
	set @planApplyStatus = (select planApplyStatus from eqpPlanInfo where planApplyID = @planApplyID)
	if (@planApplyStatus <> 1)
	begin
		set @Ret = 1
		return
	end

	--ȡά���˵�������
	declare @unexecMan nvarchar(30)
	set @unexecMan = isnull((select userCName from activeUsers where userID = @unexecManID),'')
	
	--�жϸüƻ����ɵ����յ���״̬��
	declare @count int
		--�ж����յ��Ƿ����������༭
	set @count = (select count(*) from eqpAcceptInfo
					where procurementPlanID = @planApplyID and isnull(lockManID,'') <> '')
	if (@count > 0)
	begin
		set @Ret = 2
		return
	end
		--�ж����յ��Ƿ��Ѿ����
	set @count = (select count(*) from eqpAcceptInfo
					where procurementPlanID = @planApplyID and acceptApplyStatus <> 0)
	if (@count > 0)
	begin
		set @Ret = 3
		return
	end
	
	set @unexecDate = getdate()
	
	begin tran
		delete eqpAcceptInfo
		where procurementPlanID = @planApplyID
		--���²ɹ����뵥״̬��
		update eqpPlanInfo
		set planApplyStatus = 0,	 --�ɹ��ƻ���״̬��0->δִ�У� 1->��ִ��
			--ִ����
			processManID = @unexecManID, processMan = @unexecMan, processDate = null,
			--ά���ˣ�
			modiManID = @unexecManID, modiManName = @unexecMan,	modiTime = @unexecDate
		where planApplyID = @planApplyID
	commit tran	
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@unexecManID, @unexecMan, @unexecDate, 'ȡ��ִ�вɹ��ƻ�', '�û�' + @unexecMan
												+ 'ȡ����ִ�еĲɹ��ƻ���['+ @planApplyID +'],ϵͳ�Զ�ɾ������Ӧ�����յ���')
GO
--���ԣ�
declare @unexecDate smalldatetime
declare @Ret int
exec dbo.unexecPlanApply '201101180003', '10000020', @unexecDate output, @Ret output
select @unexecDate, @Ret

select top 1000 * from eqpAcceptInfo order by applyDate desc
select * from eqpPlanInfo where planApplyID = '201101180003'


select * from wd.dbo.eqpPlanInfo




--�ɹ��б��������ͼ��
use epdc211
create view procurementInfo
as
	select p.planApplyID,convert(varchar(10),p.applyDate,120) applyDate,
			p.clgCode,p.clgName,p.uCode,p.uName,p.fCode,p.aCode,p.totalNum,p.totalMoney,p.totalNowNum,
            p.buyReason,p.clgManager,convert(varchar(10),p.clgManagerADate,120) clgManagerADate,p.leaderComments,p.leaderName,convert(varchar(10),p.leaderADate,120) leaderADate,
            p.processManID,p.processMan,convert(varchar(10),p.processDate,120) processDate,a.aName,f.fName
	from eqpPlanInfo p left join fundSrc f on p.fCode = f.fCode
		 left join appDir a on p.aCode = a.aCode
go




