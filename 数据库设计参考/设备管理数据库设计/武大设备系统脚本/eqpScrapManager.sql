use ydepdc211
/*
	����豸������Ϣϵͳ-�豸���Ϲ���
	����
		1.�豸�������̣�����->���->����
		2.�豸һ�������������ͽ����豸״̬ת�롰�����ϡ���
		3.���˺��漰���豸ת�롰�ѱ��ϡ���
	author:		¬έ
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw �������ݿ���ƣ����Ӵ����豸��ϸ�ֶΣ��޸���Ӧ�洢���̣������豸״̬ά��
				modi by lw 2012-8-10�����ͱ��ϵ���С�ͱ��ϵ�����Ӻ͸��¹��̷ֲ𣬽���ϸ����д����̱���ڲ����̣�
									���ӳ������������ӵ��ݴ������ֶ�
*/


--1.�豸���ϵ���
--ע�⣺�����豸���۸񳬹�10��Ԫ��һ�ŵ���һ���豸
select * from sEquipmentScrapDetail 

--��ֵ�ϼ��ֶ�����Ҫ��������ת����
	--����С�ͱ��ϵ��ĺϼƲ�ֵ��
select e.scrapNum, e.sumLeaveMoney, sum(d.leaveMoney) 
from equipmentScrap e left join sEquipmentScrapDetail d on e.scrapNum = d.scrapNum
where e.isBigEquipment = 0
group by e.scrapNum, e.sumLeaveMoney, d.scrapNum

update equipmentScrap
set sumLeaveMoney = t.total
from equipmentScrap e left join 
	(select scrapNum, sum(leaveMoney) total from sEquipmentScrapDetail group by scrapNum) as t on e.scrapNum = t.scrapNum
where e.isBigEquipment = 0
	--������ͱ��ϵ��ĺϼƲ�ֵ��
update equipmentScrap
set sumLeaveMoney = b.leaveMoney
from equipmentScrap e left join bEquipmentScrapDetail b on e.scrapNum = b.scrapNum
where e.isBigEquipment = 1

select * from equipmentScrap where scrapNum='201312030002'
drop table equipmentScrap
CREATE TABLE equipmentScrap(
	scrapNum char(12) not null,			--�������豸���ϵ���,ʹ��2�ź��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	applyState int default(0),			--�豸���ϵ�״̬��0->�½���1->�ѷ��ͣ��ȴ���ˣ�2->����ˣ�һ������3->�Ѵ��ã����Ѹ��ˣ�
	replyState int default(0),			--���ý����0->δ���ã�1->ȫ��ͬ�⣬2->����ͬ�⣬3->ȫ����ͬ�⡣ԭ�ֶΣ�state
	--�������ͣ�	
	isBigEquipment int default(0),		--�Ƿ�����豸:0->С���豸��1->�����豸
	
	--���뱨�ϵ�λ��
	clgCode char(3) not null,			--ѧԺ����
	clgName nvarchar(30) not null,		--ѧԺ���ƣ������ֶΣ����ǿ��Խ�����ʷ����
	clgManager nvarchar(30) null,		--Ժ�����ˣ�����Ժ����Ϣ�ж����Ժ���쵼�������ֶΣ����ǿ��Խ�����ʷ����
		--add by lw 2011-1-19
	uCode varchar(8) not null,			--ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	uName nvarchar(30) null,			--ʹ�õ�λ����:�����ֶΣ����ǿ��Ա�����ʷ����
	
	--�޷�ͳһ������ɾ����keeper nvarchar(30) null,			--������:�����ֶΣ����ǿ��Ա�����ʷ����
	
	applyManID varchar(10) null,		--�����˹���add by lw 2012-8-10
	applyMan nvarchar(30) null,			--�����ˣ�ԭbgr[������]��
	applyDate smalldatetime not null,	--��������
	tel varchar(30) null,				--�绰
	
	--ͳ����Ϣ��
	totalNum int default(0),			--������
	totalMoney numeric(15,2) default(0),--�ܽ�ԭֵ��
	sumLeaveMoney numeric(15,2) default(0),--��ֵ�ϼƣ�add by lw 2012-9-18

	--С���豸���ϵľ�������������豸���ϵĸ�����������豸���ܲ����������
	processManID char(10) null,			--������ID���豸����Ա������һ�������Ա��
	processMan nvarchar(30) null,		--�����ˣ��豸����Ա��
	processDesc nvarchar(300) null,		--���������С���豸�ɲ��
	processDate smalldatetime null,		--������ǩ����������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ������
	--С���豸���ϵĸ�������������豸���ϵ�����������
	eManagerID char(10) null,			--�豸���ܲ��Ÿ�����ID��������Ա��
	eManager nvarchar(30) null,			--�豸���ܲ��Ÿ�����
	scrapDesc nvarchar(300) null,		--�豸���ܲ������,ԭczjg[���ý��]�ֶεĺ���
	scrapDate smalldatetime null,		--����ʱ�䣺�ֿ�Ƭ��û�е��ֶΣ�Ԥ������

	notes nvarchar(200) null,			--��ע

	--�����ˣ�add by lw 2012-8-8Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_equipmentScrap] PRIMARY KEY CLUSTERED 
(
	[scrapNum] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


--������
CREATE NONCLUSTERED INDEX [IX_equipmentScrap] ON [dbo].[equipmentScrap] 
(
	[isBigEquipment] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_equipmentScrap_1] ON [dbo].[equipmentScrap] 
(
	[scrapDate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.С���豸������ϸ��:
update sEquipmentScrapDetail
set scrapDesc='����'
where isnull(scrapDesc,'')=''
select * from sEquipmentScrapDetail d left join equipmentList e on e.eCode=d.eCode
where e.eName is null
select * from equipmentList 
drop table sEquipmentScrapDetail
CREATE TABLE sEquipmentScrapDetail(
	rowNum int IDENTITY(1,1) NOT NULL,	--���
	scrapNum char(12) not null,			--������豸���ϵ���
	eCode char(8) not null,				--�豸���
	eName nvarchar(30) not null,		--�豸���ƣ������ֶΣ���֤��ʷ���ݵ�������
	eModel nvarchar(20),				--�豸�ͺţ������ֶΣ���֤��ʷ���ݵ�������
	eFormat nvarchar(20),				--�豸��������ֶΣ���֤��ʷ���ݵ�������
	oldEqpStatus char(1) null,			--ԭ�豸״̬ add by lw 2011-10-15
	buyDate smalldatetime null,			--�������ڣ������ֶΣ���֤��ʷ���ݵ�������
	eTypeCode char(8) not null,			--�����ţ��̣����4λ������ͬʱΪ��0���������ֶΣ���֤��ʷ���ݵ�������
	eTypeName nvarchar(30),				--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ������ֶΣ���֤��ʷ���ݵ�������
	totalAmount numeric(12,2) not null,	--�豸�ܼۣ�ԭֵ��
	leaveMoney numeric(12,2) default(0),		--�豸��ֵ
	scrapDesc nvarchar(300) null,		--����ԭ��
	identifyDesc nvarchar(300) null,	--�������
	--lydate?
	processState int default(0),		--������״̬��0->��ͬ�⣬1->ͬ�⣬9->δ��
 CONSTRAINT [PK_sEquipmentScrapDetail] PRIMARY KEY CLUSTERED 
(
	[scrapNum] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[sEquipmentScrapDetail] WITH CHECK ADD CONSTRAINT [FK_sEquipmentScrapDetail_equipmentScrap] FOREIGN KEY([scrapNum])
REFERENCES [dbo].[equipmentScrap] ([scrapNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sEquipmentScrapDetail] CHECK CONSTRAINT [FK_sEquipmentScrapDetail_equipmentScrap]
GO


--3.�����豸������ϸ��:
drop table bEquipmentScrapDetail
CREATE TABLE bEquipmentScrapDetail(
	scrapNum char(12) not null,			--������豸���ϵ���
	eCode char(8) not null,				--�豸���
	eName nvarchar(30) not null,		--�豸���ƣ������ֶΣ���֤��ʷ���ݵ�������
	eModel nvarchar(20) not null,		--�豸�ͺţ������ֶΣ���֤��ʷ���ݵ�������
	eFormat nvarchar(20) not null,		--�豸��������ֶΣ���֤��ʷ���ݵ�������
	oldEqpStatus char(1) null,			--ԭ�豸״̬ add by lw 2011-10-15
	buyDate smalldatetime null,			--�������ڣ������ֶΣ���֤��ʷ���ݵ�������
	eTypeCode char(8) not null,			--�����ţ��̣����4λ������ͬʱΪ��0���������ֶΣ���֤��ʷ���ݵ�������
	eTypeName nvarchar(30) null,		--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ������ֶΣ���֤��ʷ���ݵ�������

	totalAmount numeric(12,2) not null,	--�豸�ܼۣ�ԭֵ��
	leaveMoney numeric(12,2) default(0),--�豸��ֵ��Ԥ�������ֶΣ�
	
	applyDesc nvarchar(300) null,		--����ԭ��������������д��ͬ����������ˡ���������һ����ɡ�����ԭ��һ����
	
	clgDesc nvarchar(300) null,			--���ڵ�λ�����Ժ�������
	clgManagerID varchar(10) null,		--���ڵ�λ�����˹���add by lw 2012-8-10
	clgManager nvarchar(30) null,		--���ڵ�λ����������
	mDate smalldatetime null,			--������ǩ��������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ������
	
	identifyDesc nvarchar(300) null,	--�����������
	tManagerID varchar(10) null,		--�����˹���add by lw 2012-8-10
	tManager varchar(30) null,			--������
	tDate smalldatetime null,			--�������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ������
	
	gzwDesc nvarchar(300) null,			--����ί���
	notificationNum nvarchar(20) null,	--���ʴ���֪ͨ����

 CONSTRAINT [PK_bEquipmentScrapDetail] PRIMARY KEY CLUSTERED 
(
	[scrapNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[bEquipmentScrapDetail] WITH CHECK ADD CONSTRAINT [FK_bEquipmentScrapDetail_equipmentScrap] FOREIGN KEY([scrapNum])
REFERENCES [dbo].[equipmentScrap] ([scrapNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[bEquipmentScrapDetail] CHECK CONSTRAINT [FK_bEquipmentScrapDetail_equipmentScrap]
GO

drop FUNCTION getEqpStatusBeforeScrap
/*
	name:		getEqpStatusBeforeScrap
	function:	0.1.��ȡ�豸����ǰ��״̬
	input: 
				@eCode char(8)	--�豸���
	output: 
				return char(1)	--�豸����ǰ��״̬
	author:		¬έ
	CreateDate:	2012-9-18
	UpdateDate: 
*/
create FUNCTION getEqpStatusBeforeScrap
(  
	@eCode char(8)	--�豸���
)  
RETURNS char(1)
WITH ENCRYPTION
AS      
begin
	DECLARE @status char(1);
	--����top 1��Ŀ���Ǳ����α��ϵ�������
	set @status = (select top 1 oldEqpStatus from sEquipmentScrapDetail where eCode = @eCode)
	if (@status is null)
		set @status = (select top 1 oldEqpStatus from bEquipmentScrapDetail where eCode = @eCode)
	if (@status is null)
		set @status = '9'	--��������״����
	return @status
end
--���ԣ�
select dbo.getEqpStatusBeforeScrap('00019951')

drop PROCEDURE addSmallScrapApply
/*
	name:		addSmallScrapApply
	function:	1.���С���豸�������뵥
				ע�⣺���洢�����Զ������༭����Ҫ�ֹ��ͷű༭����
	input: 
				--���뱨�ϵ�λ��
				@clgCode char(3),			--ѧԺ����
				@uCode varchar(8),			--ʹ�õ�λ����
				@applyManID varchar(10),	--�����˹���add by lw 2012-8-10
				@applyDate varchar(19),		--��������:����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
				@tel varchar(30),			--�绰
				@scrapApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥��N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<leaveMoney>0</leaveMoney>
																	--		<scrapDesc>����ԭ����</scrapDesc>
																	--		<identifyDesc>�����������ͬ��</identifyDesc>
																	--		<processState>1</processState>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<leaveMoney>200.01</leaveMoney>
																	--		<scrapDesc>����ԭ����</scrapDesc>
																	--		<identifyDesc>�������������ͬ��</identifyDesc>
																	--		<processState>0</processState>
																	--	</row>
																	--	...
																	--</root>'
				
				@notes nvarchar(200),		--��ע

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output,	--�����ɹ���ʶ��
										0:�ɹ���
										1��Ҫ���ϵ��豸�б༭������������
										4:�������豸�嵥�����豸���ǡ����á���״��
										9��δ֪����
				@createTime smalldatetime output,	--ʵ�ʴ������ڣ�����������������ڿ��Բ�ͬ��
				@scrapNum char(12) output	--���������ϵ��ţ�ʹ�õ� 2 �ź��뷢��������
	author:		¬έ
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw ������������\ʹ�õ�λ�ֶ�
				modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2012-8-10�������豸���ϵ��ֲ��ȥ������ϸ����д����̱���ڲ�����,���ӳ��������������Ӵ������ֶΣ�
									�������˸ĳɹ���
*/
create PROCEDURE addSmallScrapApply
	--���뱨�ϵ�λ��
	@clgCode char(3),			--ѧԺ����
	@uCode varchar(8),			--ʹ�õ�λ����
	@applyManID varchar(10),	--�����˹���add by lw 2012-8-10
	@applyDate varchar(19),		--��������:����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
	@tel varchar(30),			--�绰
	@scrapApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥
	@notes nvarchar(200),		--��ע

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,	--ʵ�ʴ������ڣ�����������������ڿ��Բ�ͬ��
	@scrapNum char(12) output	--���������ϵ��ţ�ʹ�õ� 2 �ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--��鱨�ϵ��豸�Ƿ��б༭������������
	declare @count int
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select cast(T.x.query('data(./eCode)') as char(8)) eCode
										from(select @scrapApplyDetail.query('/root/row') Col1) A
											OUTER APPLY A.Col1.nodes('/row') AS T(x)
										)
						  and (isnull(lockManID,'') <> '' or lock4LongTime <> 0))
	if (@count>0)
	begin
		set @Ret = 1
		return
	end
	
	--���������豸�嵥���Ƿ��зǡ����á��������ޡ������ϡ��ѱ��ϡ���״̬���豸��
	set @count = (select count(*)
					from (select cast(T.x.query('data(./eCode)') as char(8)) eCode
							from(select @scrapApplyDetail.query('/root/row') Col1) A
								OUTER APPLY A.Col1.nodes('/row') AS T(x)
						) as d left join equipmentList e on d.eCode = e.eCode
					where e.curEqpStatus not in ('1', '3'))
	if (@count > 0)
	begin
		set @Ret = 4
		return
	end


	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 2, 1, @curNumber output
	set @scrapNum = @curNumber

	--��ȡԺ������\����������\ʹ�õ�λ���ƣ�
	declare @clgName nvarchar(30), @clgManager nvarchar(30)		--ѧԺ����/Ժ������
	select @clgName = clgName, @clgManager = manager from college where clgCode = @clgCode
	declare @uName nvarchar(30)	--ʹ�õ�λ����:�����ֶΣ����ǿ��Ա�����ʷ����
	if (@uCode <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	else 
		set @uName = ''
		
	--ȡ������������
	declare @applyMan nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--��������Ƿ���Ч��
	if (@applyDate='')
		set @applyDate = convert(varchar(19), getdate(), 120)

	set @createTime = getdate()
	begin tran
		insert equipmentScrap(scrapNum, clgCode, clgName, clgManager, uCode, uName, 
								applyManID, applyMan, applyDate, tel, isBigEquipment, notes,
								lockManID, modiManID, modiManName, modiTime,
								createManID, createManName, createTime) 
		values (@scrapNum, @clgCode, @clgName, @clgManager, @uCode, @uName, 
								@applyManID, @applyMan, convert(smalldatetime, @applyDate, 120), @tel, 0, @notes,
								@createManID, @createManID, @createManName, @createTime,
								@createManID, @createManName, @createTime) 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--������ϸ�����ݣ�
		insert sEquipmentScrapDetail(scrapNum, eCode, eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount,
									leaveMoney, scrapDesc, identifyDesc, processState, oldEqpStatus)
		select @scrapNum, d.eCode, e.eName, e.eModel, e.eFormat, e.buyDate, e.eTypeCode, e.eTypeName, e.totalAmount, 
				d.leaveMoney, d.scrapDesc, d.identifyDesc, d.processState, e.curEqpStatus
		from (select cast(T.x.query('data(./eCode)') as char(8)) eCode, cast(cast(T.x.query('data(./leaveMoney)') as varchar(13)) as numeric(12,2)) leaveMoney,
				cast(T.x.query('data(./scrapDesc)') as nvarchar(300)) scrapDesc, cast(T.x.query('data(./identifyDesc)') as nvarchar(300)) identifyDesc,
				cast(cast(T.x.query('data(./processState)') as varchar(10)) as int) processState
			from(select @scrapApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
			) as d left join equipmentList e on d.eCode = e.eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		--���ô������豸�嵥����״��
		update equipmentList
		set curEqpStatus = '4',	--��״�룺
									--1�����ã�ָ����ʹ�õ������豸��
									--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
									--3�����ޣ�ָ���޻���������������豸��
									--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
									--5����ʧ��
									--6�����ϣ�
									--7��������
									--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
									--9����������״����������豸��
				scrapNum = @scrapNum,	--��Ӧ�ı��ϵ���,add by lw 2011-05-16
				lock4LongTime = 3, lInvoiceNum=@scrapNum	--��������
		where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--���������Ϣ��
		declare @totalNum int, @totalMoney numeric(15,2), @sumLeaveMoney numeric(15,2)	--������/�ܽ��/��ֵ�ϼ�
		select @totalNum = count(*), @totalMoney = sum(totalAmount), @sumLeaveMoney = SUM(leaveMoney)
		from sEquipmentScrapDetail 
		where scrapNum = @scrapNum
		
		--�ǼǸ�Ҫ��Ϣ��
		update equipmentScrap 
		set totalNum = @totalNum, totalMoney = @totalMoney, sumLeaveMoney = @sumLeaveMoney
		where scrapNum = @scrapNum
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
	values(@createManID, @createManName, @createTime, '���С���豸���ϵ�', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ�������С���豸�������뵥[' + @scrapNum + ']��')
GO

drop PROCEDURE updateSmallScrapApplyInfo
/*
	name:		updateSmallScrapApplyInfo
	function:	2.����С���豸���ϵ�
	input: 
				@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
														--8λ���ڴ���+4λ��ˮ��
				--���뱨�ϵ�λ��
				@clgCode char(3),			--ѧԺ����
				@uCode varchar(8),			--ʹ�õ�λ����
				@applyManID varchar(10),	--�����˹���add by lw 2012-8-10
				@applyDate varchar(19),		--��������:����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
				@tel varchar(30),			--�绰
				@scrapApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥��N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<leaveMoney>0</leaveMoney>
																	--		<scrapDesc>����ԭ����</scrapDesc>
																	--		<identifyDesc>�����������ͬ��</identifyDesc>
																	--		<processState>1</processState>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<leaveMoney>200.01</leaveMoney>
																	--		<scrapDesc>����ԭ����</scrapDesc>
																	--		<identifyDesc>�������������ͬ��</identifyDesc>
																	--		<processState>0</processState>
																	--	</row>
																	--	...
																	--</root>'
				
				@notes nvarchar(200),		--��ע

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0���ɹ���
							1��ָ����С�ͱ��ϵ������ڣ�
							2��Ҫ���µı��ϵ���������������
							3���õ����Ѿ�ͨ����ˣ��������޸ģ�
							4��Ҫ���ϵ��豸�б༭������������
							5���������豸�嵥�����豸���ǡ����á��򡰴��ޡ���״��
							6���ñ��ϵ��е��豸������飬
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw ������������\ʹ�õ�λ�ֶ�
				modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2012-8-10����ϸ��ĸ��°����ڱ������ڲ������ӳ������������������˸ĳɹ���
				modi by lw 2013-5-27����Ƿ��е��ӵ��豸�����������
*/
create PROCEDURE updateSmallScrapApplyInfo
	@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	--���뱨�ϵ�λ��
	@clgCode char(3),			--ѧԺ����
	@uCode varchar(8),			--ʹ�õ�λ����
	@applyManID varchar(10),	--�����˹���add by lw 2012-8-10
	@applyDate varchar(19),		--��������:����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
	@tel varchar(30),			--�绰
	@scrapApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥��N'<root>
	
	@notes nvarchar(200),		--��ע

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ı��ϵ��Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum and isBigEquipment=0)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	declare @applyState int
	declare @isBigEquipment int			--���ϵ����ͣ��Ƿ�����豸��:0->С���豸��1->�����豸
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @isBigEquipment = isBigEquipment
	from equipmentScrap 
	where scrapNum = @scrapNum
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@applyState <> 0)
	begin
		set @Ret = 3
		return
	end
	
	--���ԭ���ϵ��豸�Ƿ��б༭�������������������������
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end

	--��鱨�ϵ��豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select cast(T.x.query('data(./eCode)') as char(8)) eCode
										from(select @scrapApplyDetail.query('/root/row') Col1) A
											OUTER APPLY A.Col1.nodes('/row') AS T(x)
										)
						  and (isnull(lockManID,'') <> '' or (lock4LongTime <> 0 and not (lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 4
		return
	end

	--���������豸�嵥���Ƿ��зǡ����û���ޡ����������ϡ��ѱ��ϡ���״̬���豸��
	set @count = (select count(*)
					from (select cast(T.x.query('data(./eCode)') as char(8)) eCode
							from(select @scrapApplyDetail.query('/root/row') Col1) A
								OUTER APPLY A.Col1.nodes('/row') AS T(x)
						) as d left join equipmentList e on d.eCode = e.eCode
					where e.curEqpStatus not in ('1', '3') and d.eCode not in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum))
	if (@count > 0)
	begin
		set @Ret = 5
		return
	end

	--��������Ƿ���Ч��
	if (@applyDate='')
		set @applyDate = convert(varchar(19), getdate(), 120)
		
	--��ȡԺ�����ƺ͸�����������
	declare @clgName nvarchar(30), @rClgManager nvarchar(30)		--ѧԺ����/Ժ�����ˣ�Ժ����Ϣ�ж�����쵼��
	select @clgName = clgName, @rClgManager = manager from college where clgCode = @clgCode
	declare @uName nvarchar(30)	--ʹ�õ�λ����:�����ֶΣ����ǿ��Ա�����ʷ����
	set @uName = (select uName from useUnit where uCode = @uCode)
	
	--ȡ������������
	declare @applyMan nvarchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		update equipmentScrap 
		set clgCode = @clgCode, clgName = @clgName, clgManager = @rClgManager, uCode = @uCode, uName = @uName,
			applyManID = @applyManID, applyMan = @applyMan, applyDate = convert(smalldatetime, @applyDate, 120), tel = @tel, 
			isBigEquipment = @isBigEquipment, notes = @notes,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where scrapNum = @scrapNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--������ϸ��
		--�ָ�ԭ�������豸�嵥����״��
		update equipmentList
		set curEqpStatus = s.oldEqpStatus,	--��״�룺
									--1�����ã�ָ����ʹ�õ������豸��
									--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
									--3�����ޣ�ָ���޻���������������豸��
									--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
									--5����ʧ��
									--6�����ϣ�
									--7��������
									--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
									--9����������״����������豸��
				scrapNum = null,	--��Ӧ�ı��ϵ���,add by lw 2011-05-16
				lock4LongTime = 0, lInvoiceNum=''	--�ͷų�������
		from equipmentList e left join sEquipmentScrapDetail s on e.eCode = s.eCode and s.scrapNum = @scrapNum
		where e.eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--���´������豸�б�
		delete sEquipmentScrapDetail where scrapNum = @scrapNum
		insert sEquipmentScrapDetail(scrapNum, eCode, eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount,
									leaveMoney, scrapDesc, identifyDesc, processState, oldEqpStatus)
		select @scrapNum, d.eCode, e.eName, e.eModel, e.eFormat, e.buyDate, e.eTypeCode, e.eTypeName, e.totalAmount, 
				d.leaveMoney, d.scrapDesc, d.identifyDesc, d.processState, e.curEqpStatus
		from (select cast(T.x.query('data(./eCode)') as char(8)) eCode, cast(cast(T.x.query('data(./leaveMoney)') as varchar(13)) as numeric(12,2)) leaveMoney,
				cast(T.x.query('data(./scrapDesc)') as nvarchar(300)) scrapDesc, 
				cast(T.x.query('data(./identifyDesc)') as nvarchar(300)) identifyDesc,
				cast(cast(T.x.query('data(./processState)') as varchar(10)) as int) processState
			from(select @scrapApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
			) as d left join equipmentList e on d.eCode = e.eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
			
		--���ô������豸�嵥����״��
		update equipmentList
		set curEqpStatus = '4',	--��״�룺
									--1�����ã�ָ����ʹ�õ������豸��
									--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
									--3�����ޣ�ָ���޻���������������豸��
									--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
									--5����ʧ��
									--6�����ϣ�
									--7��������
									--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
									--9����������״����������豸��
				scrapNum = @scrapNum,	--��Ӧ�ı��ϵ���,add by lw 2011-05-16
				lock4LongTime = 3, lInvoiceNum=@scrapNum	--��������
		where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--���������Ϣ��
		declare @totalNum int, @totalMoney numeric(12,2), @sumLeaveMoney numeric(12,2)	--������/�ܽ��/��ֵ�ϼ�
		select @totalNum = count(*), @totalMoney = sum(totalAmount), @sumLeaveMoney = SUM(leaveMoney)
		from sEquipmentScrapDetail 
		where scrapNum = @scrapNum
		
		--�ǼǸ�Ҫ��Ϣ��
		update equipmentScrap 
		set totalNum = @totalNum, totalMoney = @totalMoney, sumLeaveMoney = @sumLeaveMoney
		where scrapNum = @scrapNum
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
	values(@modiManID, @modiManName, @updateTime, '����С���豸���ϵ�', '�û�' + @modiManName 
												+ '������С���豸���ϵ�['+ @scrapNum +']��')
GO


drop PROCEDURE smallScrapInfoCheck1
/*
	name:		smallScrapInfoCheck1
	function:	3.���С���豸���ϵ�
	input: 
				@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
														--8λ���ڴ���+4λ��ˮ��
				@scrapApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥��N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<leaveMoney>0</leaveMoney>
																	--		<scrapDesc>����ԭ����</scrapDesc>
																	--		<identifyDesc>�����������ͬ��</identifyDesc>
																	--		<processState>1</processState>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<leaveMoney>200.01</leaveMoney>
																	--		<scrapDesc>����ԭ����</scrapDesc>
																	--		<identifyDesc>�������������ͬ��</identifyDesc>
																	--		<processState>0</processState>
																	--	</row>
																	--	...
																	--</root>'
				@processManID char(10),		--������ID���豸����Ա������һ�������Ա��
				@processDesc nvarchar(300),	--���������С���豸�ɲ��
				@processDate varchar(19),	--������ǩ����������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"

				@notes nvarchar(200),		--��ע�������������£�
				
				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1��ָ����С�ͱ��ϵ������ڣ�
							2��Ҫ��˵ı��ϵ���������������
							3���õ����Ѿ�ͨ����ˣ��������޸ģ�
							6���ñ��ϵ��е��豸������飬
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw ���ӡ�������ǩ����������ڡ��ֶ�
				modi by lw 2011-12-16���ݱϴ�������������豸���ϵ�������С���豸���ϵ����̲�һ�����������豸���ϵ���˷ֲ������
				modi by lw 2012-8-10��������ϸ��Ĺ��̺ϲ����ù����ڲ�
				modi by lw 2012-10-6������û�б����豸ԭ״̬�Ĵ���
				modi by lw 2013-5-27����Ƿ��е��ӵ��豸�����������
*/
create PROCEDURE smallScrapInfoCheck1
	@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	@scrapApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥
	@processManID char(10),		--������ID���豸����Ա������һ�������Ա��
	@processDesc nvarchar(300),	--����������������С���豸�ɲ��
	@processDate varchar(19),	--������ǩ����������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"

	@notes nvarchar(200),		--��ע�������������£�

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���ı��ϵ��Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum and isBigEquipment=0)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	declare @applyState int
	declare @isBigEquipment int			--���ϵ����ͣ��Ƿ�����豸��:0->С���豸��1->�����豸
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @isBigEquipment = isBigEquipment
	from equipmentScrap 
	where scrapNum = @scrapNum
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@applyState >= 2)
	begin
		set @Ret = 3
		return
	end
	
	--��鱨�ϵ��豸�Ƿ��б༭�������������������������
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end

	--��ȡ��������������
	declare @processMan nvarchar(30)	--�����ˣ��豸����Ա��
	set @processMan = isnull((select cName from userInfo where jobNumber = @processManID),'')

	--��������Ƿ���Ч��
	if (@processDate='')
		set @processDate = convert(varchar(19), getdate(), 120)

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		--������ϸ�б�ļ��������������豸�ı༭���������������豸״̬
		--�����豸��ԭ״̬��
		declare @sTab as table (
			eCode char(8) not null,			--�豸���
			oldEqpStatus char(1) not null	--�豸��ԭ��״̬
		)
		insert @sTab(eCode,oldEqpStatus)
		select eCode,oldEqpStatus
		from sEquipmentScrapDetail 
		where scrapNum = @scrapNum
		
		delete sEquipmentScrapDetail where scrapNum = @scrapNum
		insert sEquipmentScrapDetail(scrapNum, eCode, eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount,
									leaveMoney, scrapDesc, identifyDesc, processState,oldEqpStatus)
		select @scrapNum, d.eCode, e.eName, e.eModel, e.eFormat, e.buyDate, e.eTypeCode, e.eTypeName, e.totalAmount, 
				d.leaveMoney, d.scrapDesc, d.identifyDesc, d.processState,s.oldEqpStatus
		from (select cast(T.x.query('data(./eCode)') as char(8)) eCode, cast(cast(T.x.query('data(./leaveMoney)') as varchar(13)) as numeric(12,2)) leaveMoney,
				cast(T.x.query('data(./scrapDesc)') as nvarchar(300)) scrapDesc, cast(T.x.query('data(./identifyDesc)') as nvarchar(300)) identifyDesc,
				cast(cast(T.x.query('data(./processState)') as varchar(10)) as int) processState
			from(select @scrapApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
			) as d left join equipmentList e on d.eCode = e.eCode left join @sTab s on e.eCode = s.eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--���������Ϣ��
		declare @totalNum int, @totalMoney numeric(15,2), @sumLeaveMoney numeric(15,2)	--������/�ܽ��/��ֵ�ϼ�
		select @totalNum = count(*), @totalMoney = sum(totalAmount), @sumLeaveMoney = SUM(leaveMoney)
		from sEquipmentScrapDetail 
		where scrapNum = @scrapNum and processState<>0
		--���¸�Ҫ��
		update equipmentScrap 
		set processManID = @processManID, processMan = @processMan, processDesc = @processDesc,
			processDate = convert(smalldatetime,@processDate,120), notes = @notes,
			applyState = 2,	--�豸���ϵ�״̬��0->�½���1->�ѷ��ͣ��ȴ���ˣ�2->����ˣ�һ������3->�Ѵ��ã����Ѹ��ˣ�
			totalNum = @totalNum, totalMoney = @totalMoney, sumLeaveMoney = @sumLeaveMoney,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where scrapNum = @scrapNum
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
	values(@modiManID, @modiManName, @updateTime, '���С���豸���ϵ�', '�û�' + @modiManName 
												+ '�����С���豸���ϵ�['+ @scrapNum +']��')
GO

drop PROCEDURE smallScrapInfoCheck2
/*
	name:		smallScrapInfoCheck2
	function:	4.����С���豸���ϵ�
				ע�⣺����洢����ͬʱҲ��Ч���ϵ�
					  ����洢����û�м�ⵥ���Ƿ���ڣ�����Ҫ����������
					  ����洢����ֻ����С���豸���ϵ��ĸ��ˣ������豸���ϵ��ֲ��ȥ�ˣ�
	input: 
				@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
														--8λ���ڴ���+4λ��ˮ��
				@scrapApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥��N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<leaveMoney>0</leaveMoney>
																	--		<scrapDesc>����ԭ����</scrapDesc>
																	--		<identifyDesc>�����������ͬ��</identifyDesc>
																	--		<processState>1</processState>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<leaveMoney>200.01</leaveMoney>
																	--		<scrapDesc>����ԭ����</scrapDesc>
																	--		<identifyDesc>�������������ͬ��</identifyDesc>
																	--		<processState>0</processState>
																	--	</row>
																	--	...
																	--</root>'
				@eManagerID char(10),		--�豸����������ID
				@scrapDesc nvarchar(300),	--�������,ԭczjg[���ý��]�ֶεĺ���
				@scrapDate varchar(19),		--����ʱ�䣺�ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
							
				@notes nvarchar(200),		--��ע

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0���ɹ���
							1��ָ����С�ͱ��ϵ������ڣ�
							2��Ҫ���˵ı��ϵ���������������
							3���õ����Ѿ�ͨ�����ˣ���Ч�����������޸ģ�
							4�����ǩ��ȫ��
							5��������������˲�����ͬ��
							6���õ��ݻ�û�����, 
							7���ñ��ϵ��е��豸������飬
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw ���Ӵ������ڣ����ô��ý����ά���豸����������Ϣ
				modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2011-5-16������ɸѡ����ʱ���ֹ���where�Ӿ䲻���㣬���豸�嵥�������ˡ���Ӧ�ı��ϵ����ֶζ�������Ӧ�޸ģ�
				modi by lw 2011-10-15�����豸�������ڱ��еı䶯���͡��䶯ƾ֤�Ǽǣ���ϸ���еǼ����豸ԭ״̬����Ӧ�ָ��豸ԭ״̬��
				modi by lw 2011-12-15�����豸�����Һͱϴ�������������豸���ϵ�����ίǩ��������븴�˽׶Σ���˽������豸���ϵ��ĸ��˷ֲ��ȥ��
									��������һ��5��6�ŷ�����Ϣ��
				modi by lw 2012-8-9��������ϸ������ڹ����ڲ������ӳ�����������
				modi by lw 2012-10-6������û�б����豸ԭ״̬�Ĵ���
				modi by lw 2013-5-27����Ƿ��е��ӵ��豸�����������
*/
create PROCEDURE smallScrapInfoCheck2
	@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	@scrapApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥
	@eManagerID char(10),		--�豸����������ID
	@scrapDesc nvarchar(300),	--�������,ԭczjg[���ý��]�ֶεĺ���
	@scrapDate varchar(19),		--����ʱ�䣺�ֿ�Ƭ��û�е��ֶΣ�Ԥ������
	
	@notes nvarchar(200),		--��ע

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���ı��ϵ��Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum and isBigEquipment=0)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)	--������
	declare @applyState int				--����״̬
	declare @processManID char(10)		--�����
	declare @isBigEquipment int			--���ϵ����ͣ��Ƿ�����豸��:0->С���豸��1->�����豸
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @processManID = processManID, @isBigEquipment = isBigEquipment
	from equipmentScrap where scrapNum = @scrapNum
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	if (@applyState >= 3)
	begin
		set @Ret = 3
		return
	end
	else if (@applyState < 2)
	begin
		set @Ret = 6
		return
	end
	
	--��鸴���˺�������Ƿ���ͬ:
	if (@processManID = @eManagerID)
	begin
		set @Ret = 5
		return
	end
	
	--��鱨�ϵ��豸�Ƿ��б༭�������������������������
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 7
		return
	end
	--��ȡ������������
	declare @eManager nvarchar(30)		--�豸����������
	set @eManager = isnull((select cName from userInfo where jobNumber = @eManagerID),'')

	--��������Ƿ���Ч��
	if (@scrapDate='')
		set @scrapDate = convert(varchar(19), getdate(), 120)

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	--��Ч���ϵ���
	declare @replyState int	--���ý����0->δ���ã�1->ȫ��ͬ�⣬2->����ͬ�⣬3->ȫ����ͬ�⡣ԭ�ֶΣ�state
	begin tran
		--������ϸ�б�ļ��������������豸�ı༭���������������豸״̬
		--�����豸��ԭ״̬��
		declare @sTab as table (
			eCode char(8) not null,			--�豸���
			oldEqpStatus char(1) not null	--�豸��ԭ��״̬
		)
		insert @sTab(eCode,oldEqpStatus)
		select eCode,oldEqpStatus
		from sEquipmentScrapDetail 
		where scrapNum = @scrapNum

		delete sEquipmentScrapDetail where scrapNum = @scrapNum
		insert sEquipmentScrapDetail(scrapNum, eCode, eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount,
									leaveMoney, scrapDesc, identifyDesc, processState, oldEqpStatus)
		select @scrapNum, d.eCode, e.eName, e.eModel, e.eFormat, e.buyDate, e.eTypeCode, e.eTypeName, e.totalAmount, 
				d.leaveMoney, d.scrapDesc, d.identifyDesc, d.processState, s.oldEqpStatus
		from (select cast(T.x.query('data(./eCode)') as char(8)) eCode, cast(cast(T.x.query('data(./leaveMoney)') as varchar(13)) as numeric(12,2)) leaveMoney,
				cast(T.x.query('data(./scrapDesc)') as nvarchar(300)) scrapDesc, cast(T.x.query('data(./identifyDesc)') as nvarchar(300)) identifyDesc,
				cast(cast(T.x.query('data(./processState)') as varchar(10)) as int) processState
			from(select @scrapApplyDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
			) as d left join equipmentList e on d.eCode = e.eCode left join @sTab s on e.eCode = s.eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--���㱨�ϵķ�Χ��
		declare @rows int, @scrappedRows int
		set @rows = (select count(*) from sEquipmentScrapDetail where scrapNum = @scrapNum)
		set @scrappedRows = (select count(*) from sEquipmentScrapDetail where scrapNum = @scrapNum and processState = 1)
		--���ý����0->δ���ã�1->ȫ��ͬ�⣬2->����ͬ�⣬3->ȫ����ͬ�⡣ԭ�ֶΣ�state
		if (@scrappedRows = 0)
			set @replyState = 3
		else if (@scrappedRows = @rows)
			set @replyState = 1
		else
			set @replyState = 2
		
		--�����豸��
		--ȷ�����ϵ��豸��
		update equipmentList
		set curEqpStatus = '6',	--�豸��״�룺
								--1�����ã�ָ����ʹ�õ������豸��
								--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
								--3�����ޣ�ָ���޻���������������豸��
								--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
								--5����ʧ��
								--6�����ϣ�
								--7��������
								--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
								--9����������״����������豸��
			scrapDate = @updateTime,--�������ڣ�ԭ[ISDORE] [bit] NOT NULL,���Ѿ�ȷ�ϱ��ϣ��ָ�Ϊʹ�ñ�������
			scrapNum = @scrapNum,	--��Ӧ�ı��ϵ���,add by lw 2011-05-16
			lock4LongTime = 0, lInvoiceNum=''	--�ͷų�������
		where eCode in (select eCode 
						from sEquipmentScrapDetail 
						where scrapNum = @scrapNum and processState = 1)
		--���β����ϵ��豸�ָ�ԭ״�����ã���
		update equipmentList
		set curEqpStatus = s.oldEqpStatus,		--��״�룺
									--1�����ã�ָ����ʹ�õ������豸��
									--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
									--3�����ޣ�ָ���޻���������������豸��
									--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
									--5����ʧ��
									--6�����ϣ�
									--7��������
									--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
									--9����������״����������豸��
			scrapDate = null,	--�������ڣ�ԭ[ISDORE] [bit] NOT NULL,���Ѿ�ȷ�ϱ��ϣ��ָ�Ϊʹ�ñ�������
			scrapNum = null,	--��Ӧ�ı��ϵ���,add by lw 2011-05-16
			lock4LongTime = 0, lInvoiceNum=''	--�ͷų�������
		from equipmentList e left join sEquipmentScrapDetail s on e.eCode = s.eCode and s.scrapNum = @scrapNum
		where e.eCode in (select eCode 
						from sEquipmentScrapDetail 
						where scrapNum = @scrapNum and processState <> 1)

		--�Ǽ��豸����������Ϣ��
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,changeType,changeInvoiceID) 
		select s.eCode, e.eName, e.eModel, e.eFormat,
				e.clgCode, clg.clgName, e.uCode, u.uName, e.keeper,
				e.annexAmount, e.price, e.totalAmount,
				@scrapDate, '�豸����','����',@scrapNum
		from sEquipmentScrapDetail s left join equipmentList e on s.eCode = e.eCode 
				left join college clg on e.clgCode = clg.clgCode
				left join useUnit u on e.uCode = u.uCode
		where s.scrapNum = @scrapNum and s.processState = 1

		--���������Ϣ��
		declare @totalNum int, @totalMoney numeric(15,2), @sumLeaveMoney numeric(15,2)	--������/�ܽ��/��ֵ�ϼ�
		select @totalNum = count(*), @totalMoney = sum(totalAmount), @sumLeaveMoney = SUM(leaveMoney)
		from sEquipmentScrapDetail 
		where scrapNum = @scrapNum and processState<>0
		--���±��ϵ�
		update equipmentScrap 
		set eManagerID = @eManagerID, eManager = @eManager, scrapDesc = @scrapDesc,
			scrapDate = convert(smalldatetime,@scrapDate,120), notes = @notes,
			applyState = 3,				--�豸���ϵ�״̬��0->�½���1->�ѷ��ͣ��ȴ���ˣ�2->����ˣ�һ������3->�Ѵ��ã����Ѹ��ˣ�
			replyState = @replyState,	--���ý����0->δ���ã�1->ȫ��ͬ�⣬2->����ͬ�⣬3->ȫ����ͬ�⡣ԭ�ֶΣ�state
			totalNum = @totalNum, totalMoney = @totalMoney, sumLeaveMoney = @sumLeaveMoney,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where scrapNum = @scrapNum
		set @Ret = 0
	commit tran
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '����С���豸���ϵ�', '�û�' + @modiManName 
												+ '���˲���Ч��С�ͱ��ϵ�['+ @scrapNum +']��')
GO



drop PROCEDURE addBigScrapApply
/*
	name:		addBigScrapApply
	function:	5.��Ӵ����豸�������뵥
				ע�⣺���洢�����Զ������༭����Ҫ�ֹ��ͷű༭����
	input: 
				--���뱨�ϵ�λ��
				@clgCode char(3),			--ѧԺ����
				@uCode varchar(8),			--ʹ�õ�λ����
				@applyManID varchar(10),	--�����˹���add by lw 2012-8-10
				@applyDate varchar(19),		--��������:����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
				@tel varchar(30),			--�绰
				@notes nvarchar(200),		--��ע
				--��ϸ����Ŀ��
				@eCode char(8),				--�豸���
				@leaveMoney numeric(12,2),			--�豸��ֵ��Ԥ�������ֶΣ�
				@applyDesc nvarchar(300),	--����ԭ��������������д��ͬ����������ˡ���������һ����ɡ�����ԭ��һ����
				@clgDesc nvarchar(300),		--Ժ�����
				@clgManagerID varchar(10),	--���ڵ�λ�����˹���add by lw 2012-8-10
				@mDate varchar(19),			--������ǩ��������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
				@identifyDesc nvarchar(300),--�������
				@tManagerID varchar(10),	--�����˹���add by lw 2012-8-10
				@tDate varchar(19),			--�������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output,	--�����ɹ���ʶ��
										0:�ɹ���
										1��Ҫ���ϵ��豸�б༭������������
										4:�������豸���ǡ����á���״��
										9��δ֪����
				@createTime smalldatetime output,	--ʵ�ʴ������ڣ�����������������ڿ��Բ�ͬ��
				@scrapNum char(12) output	--���������ϵ��ţ�ʹ�õ� 2 �ź��뷢��������
	author:		¬έ
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw ������������\ʹ�õ�λ�ֶ�
				modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2012-8-10����ϸ��Ĵ�������ڱ������ڲ������ӳ��������������Ӵ������ֶΣ�
									�������ˡ�Ժ�������ˡ�������ʹ�ù��Ŵ���
*/
create PROCEDURE addBigScrapApply
	--���뱨�ϵ�λ��
	@clgCode char(3),			--ѧԺ����
	@uCode varchar(8),			--ʹ�õ�λ����
	@applyManID varchar(10),	--�����˹���add by lw 2012-8-10
	@applyDate varchar(19),		--��������:����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
	@tel varchar(30),			--�绰
	@notes nvarchar(200),		--��ע
	--��ϸ����Ŀ��
	@eCode char(8),				--�豸���
	@leaveMoney numeric(12,2),			--�豸��ֵ��Ԥ�������ֶΣ�
	@applyDesc nvarchar(300),	--����ԭ��������������д��ͬ����������ˡ���������һ����ɡ�����ԭ��һ����
	@clgDesc nvarchar(300),		--Ժ�����
	@clgManagerID varchar(10),	--���ڵ�λ�����˹���add by lw 2012-8-10
	@mDate varchar(19),			--������ǩ��������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
	@identifyDesc nvarchar(300),--�������
	@tManagerID varchar(10),	--�����˹���add by lw 2012-8-10
	@tDate varchar(19),			--�������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,	--ʵ�ʴ������ڣ�����������������ڿ��Բ�ͬ��
	@scrapNum char(12) output	--���������ϵ��ţ�ʹ�õ� 2 �ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--��鱨�ϵ��豸�Ƿ��б༭������������
	declare @count int
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode
						  and (isnull(lockManID,'') <> '' or lock4LongTime <> 0))
	if (@count>0)
	begin
		set @Ret = 1
		return
	end
	--���������豸�嵥���Ƿ��зǡ����á��򡰴��ޡ��������ޡ������ϡ��ѱ��ϡ���״̬���豸��
	declare @curEqpStatus char(1)
	set @curEqpStatus =(select curEqpStatus from equipmentList where eCode = @eCode)
	if (@curEqpStatus <> '1' and @curEqpStatus <> '3')
	begin
		set @Ret = 4
		return
	end

	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 2, 1, @curNumber output
	set @scrapNum = @curNumber

	--��ȡԺ������\����������\ʹ�õ�λ���ƣ�
	declare @clgName nvarchar(30), @rClgManager nvarchar(30)		--ѧԺ����/Ժ�����ˣ�Ժ����Ϣ�еǼǵ��쵼��
	select @clgName = clgName, @rClgManager = manager from college where clgCode = @clgCode
	declare @uName nvarchar(30)	--ʹ�õ�λ����:�����ֶΣ����ǿ��Ա�����ʷ����
	if (@uCode <> '')
		set @uName = (select uName from useUnit where uCode = @uCode)
	else 
		set @uName = ''

	--ȡ�����ˡ����ڵ�λ�����ˡ�������������
	declare @applyMan nvarchar(30), @clgManager nvarchar(30), @tManager varchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	set @clgManager = isnull((select cName from userInfo where jobNumber = @clgManagerID),'')
	set @tManager = isnull((select cName from userInfo where jobNumber = @tManagerID),'')

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--��������Ƿ���Ч��
	if (@applyDate='')
		set @applyDate = convert(varchar(19), getdate(), 120)

	set @createTime = getdate()
	begin tran 
		insert equipmentScrap(scrapNum, clgCode, clgName, clgManager, uCode, uName, 
								applyManID, applyMan, applyDate, tel, isBigEquipment, notes,
								lockManID, modiManID, modiManName, modiTime,
								createManID, createManName, createTime) 
		values (@scrapNum, @clgCode, @clgName, @rClgManager, @uCode, @uName, 
								@applyManID, @applyMan, convert(smalldatetime, @applyDate, 120), @tel, 1, @notes,
								@createManID, @createManID, @createManName, @createTime,
								@createManID, @createManName, @createTime) 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--����������豸�б�
		insert bEquipmentScrapDetail(scrapNum, eCode, eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount,
							leaveMoney, applyDesc, clgDesc, clgManagerID, clgManager, mDate, 
							identifyDesc, tManagerID, tManager, tDate,
							oldEqpStatus)
		select @scrapNum, eCode, eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount,
							@leaveMoney, @applyDesc, @clgDesc, @clgManagerID, @clgManager, convert(smalldatetime, @mDate, 120), 
							@identifyDesc, @tManagerID, @tManager, convert(smalldatetime, @tDate, 120),
							curEqpStatus
		from equipmentList 
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--���ô������豸�嵥����״��
		update equipmentList
		set curEqpStatus = '4',		--��״�룺
									--1�����ã�ָ����ʹ�õ������豸��
									--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
									--3�����ޣ�ָ���޻���������������豸��
									--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
									--5����ʧ��
									--6�����ϣ�
									--7��������
									--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
									--9����������״����������豸��
				scrapNum = @scrapNum,		--��Ӧ�ı��ϵ���,add by lw 2011-05-16
				lock4LongTime = 3, lInvoiceNum=@scrapNum	--��������
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--���������Ϣ��
		declare @totalMoney numeric(15,2)	--�ܽ��
		select @totalMoney = totalAmount
		from equipmentList
		where eCode = @eCode
		
		--�ǼǸ�Ҫ��Ϣ��ά����Ϣ��
		update equipmentScrap 
		set totalNum = 1, totalMoney = @totalMoney, sumLeaveMoney = @leaveMoney
		where scrapNum = @scrapNum
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
	values(@createManID, @createManName, @createTime, '��Ӵ����豸���ϵ�', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˴����豸�������뵥[' + @scrapNum + ']��')
GO


drop PROCEDURE updateBigScrapApplyInfo
/*
	name:		updateBigScrapApplyInfo
	function:	6.���´��ͱ��ϵ�
	input: 
				@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
														--8λ���ڴ���+4λ��ˮ��
				--���뱨�ϵ�λ��
				@clgCode char(3),			--ѧԺ����
				@uCode varchar(8),			--ʹ�õ�λ����
				@applyManID varchar(10),	--�����˹���add by lw 2012-8-10
				@applyDate varchar(19),		--��������:����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
				@tel varchar(30),			--�绰
				@notes nvarchar(200),		--��ע
				--��ϸ����Ŀ��
				@eCode char(8),				--�豸��ţ�ע����²��������豸��
				@leaveMoney numeric(12,2),			--�豸��ֵ��Ԥ�������ֶΣ�
				@applyDesc nvarchar(300),	--����ԭ��������������д��ͬ����������ˡ���������һ����ɡ�����ԭ��һ����
				@clgDesc nvarchar(300),		--Ժ�����
				@clgManagerID varchar(10),	--���ڵ�λ�����˹���add by lw 2012-8-10
				@mDate varchar(19),			--������ǩ��������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
				@identifyDesc nvarchar(300),--�������
				@tManagerID varchar(10),	--�����˹���add by lw 2012-8-10
				@tDate varchar(19),			--�������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0���ɹ���
							1��ָ���Ĵ����豸���ϵ������ڣ�
							2��Ҫ���µı��ϵ�Ϣ��������������
							3���õ����Ѿ�ͨ����ˣ��������޸ģ�
							6���ñ��ϵ��е��豸������飬
							8���ñ��ϵ����豸��ϸ��¼��ɾ��
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw ������������\ʹ�õ�λ�ֶ�
				modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2012-8-10����ϸ��Ĵ�������ڱ������ڣ������漰���������ˡ������˵�ʹ�ù��Ŵ���
				modi by lw 2013-5-27����Ƿ��е��ӵ��豸�����������
*/
create PROCEDURE updateBigScrapApplyInfo
	@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	--���뱨�ϵ�λ��
	@clgCode char(3),			--ѧԺ����
	@uCode varchar(8),			--ʹ�õ�λ����
	@applyManID varchar(10),	--�����˹���add by lw 2012-8-10
	@applyDate varchar(19),		--��������:����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
	@tel varchar(30),			--�绰
	@notes nvarchar(200),		--��ע
	--��ϸ����Ŀ��
	@eCode char(8),				--�豸��ţ�ע����²��������豸��
	@leaveMoney numeric(12,2),	--�豸��ֵ��Ԥ�������ֶΣ�
	@applyDesc nvarchar(300),	--����ԭ��������������д��ͬ����������ˡ���������һ����ɡ�����ԭ��һ����
	@clgDesc nvarchar(300),		--Ժ�����
	@clgManagerID varchar(10),	--���ڵ�λ�����˹���add by lw 2012-8-10
	@mDate varchar(19),			--������ǩ��������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
	@identifyDesc nvarchar(300),--�������
	@tManagerID varchar(10),	--�����˹���add by lw 2012-8-10
	@tDate varchar(19),			--�������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ı��ϵ��Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum and isBigEquipment=1)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	declare @applyState int
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState
	from equipmentScrap 
	where scrapNum = @scrapNum
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@applyState <> 0)
	begin
		set @Ret = 3
		return
	end

	--�����ϸ�����е��豸�Ƿ���ڣ�
	set @count=(select count(*) from bEquipmentScrapDetail where scrapNum = @scrapNum and eCode=@eCode)	
	if (@count = 0)	--������
	begin
		set @Ret = 8
		return
	end
	
	--��������Ƿ���Ч��
	if (@applyDate='')
		set @applyDate = convert(varchar(19), getdate(), 120)
		
	--���ԭ���ϵ��豸�Ƿ��б༭�������������������������
	set @count = (select COUNT(*) from equipmentList
					where eCode = @eCode
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end

	--��ȡԺ��\ʹ�õ�λ���ƣ�
	declare @clgName nvarchar(30),@rClgManager nvarchar(30)		--Ժ������\Ժ���쵼
	select @clgName = clgName, @rClgManager = manager from college where clgCode = @clgCode
	declare @uName nvarchar(30)	--ʹ�õ�λ����:�����ֶΣ����ǿ��Ա�����ʷ����
	set @uName = (select uName from useUnit where uCode = @uCode)
	
	--ȡ�����ˡ����ڵ�λ�����ˡ�������������
	declare @applyMan nvarchar(30), @clgManager nvarchar(30), @tManager varchar(30)
	set @applyMan = isnull((select cName from userInfo where jobNumber = @applyManID),'')
	set @clgManager = isnull((select cName from userInfo where jobNumber = @clgManagerID),'')
	set @tManager = isnull((select cName from userInfo where jobNumber = @tManagerID),'')

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		update equipmentScrap 
		set clgCode = @clgCode, clgName = @clgName, clgManager = @rClgManager, uCode = @uCode, uName = @uName,
			applyManID = @applyManID, applyMan = @applyMan, applyDate = convert(smalldatetime, @applyDate, 120), tel = @tel, 
			sumLeaveMoney = @leaveMoney,
			isBigEquipment = 1, notes = @notes,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where scrapNum = @scrapNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--������ϸ��
		update bEquipmentScrapDetail
		set leaveMoney = @leaveMoney, applyDesc = @applyDesc, 
			clgDesc = @clgDesc, clgManagerID=@clgManagerID, clgManager=@clgManager, mDate = convert(smalldatetime, @mDate, 120), 
			identifyDesc=@identifyDesc, tManagerID=@tManagerID, tManager=@tManager, tDate=convert(smalldatetime, @tDate, 120)
		where scrapNum = @scrapNum and eCode = @eCode
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
	values(@modiManID, @modiManName, @updateTime, '���´����豸���ϵ�', '�û�' + @modiManName 
												+ '�����˴����豸���ϵ�['+ @scrapNum +']��')
GO

drop PROCEDURE checkBigScrappedInfo
/*
	name:		checkBigScrappedInfo
	function:	7.��˴����豸���ϵ�����豸���ܲ��������
	input: 
				@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
														--8λ���ڴ���+4λ��ˮ��
				@eManagerID char(10),		--�豸����������ID
				@scrapDesc nvarchar(300),	--�������,ԭczjg[���ý��]�ֶεĺ���
				@scrapDate varchar(19),		--����ʱ�䣺�ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"

				@notes nvarchar(200),		--��ע�������������£�
				
				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1��ָ���Ĵ����豸���ϵ������ڣ�
							2��Ҫ���µı��ϵ�Ϣ��������������
							3:�õ����Ѿ�ͨ����ˣ��������ٴ���ˣ�
							6���ñ��ϵ��е��豸������飬
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-12-16
	UpdateDate: modi by lw 2012-8-10�����˳�����Ϣ
				modi by lw 2013-5-27����Ƿ��е��ӵ��豸�����������
*/
create PROCEDURE checkBigScrappedInfo
	@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	@eManagerID char(10),		--�豸����������ID
	@scrapDesc nvarchar(300),	--�������,ԭczjg[���ý��]�ֶεĺ���
	@scrapDate varchar(19),		--����ʱ�䣺�ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"

	@notes nvarchar(200),		--��ע�������������£�

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ı��ϵ��Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum and isBigEquipment=1)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)
	declare @applyState int
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState from equipmentScrap where scrapNum = @scrapNum
	--���༭����
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@applyState >= 2)
	begin
		set @Ret = 3
		return
	end
	
	--���ԭ���ϵ��豸�Ƿ��б༭�������������������������
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end

	--��ȡ�豸���ܲ��Ÿ�����������
	declare @eManager nvarchar(30)
	set @eManager = isnull((select cName from userInfo where jobNumber = @eManagerID),'')

	--��������Ƿ���Ч��
	if (@scrapDate='')
		set @scrapDate = convert(varchar(19), getdate(), 120)

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update equipmentScrap 
	set eManagerID = @eManagerID, eManager = @eManager, 
		scrapDesc = @scrapDesc, scrapDate = convert(smalldatetime,@scrapDate,120),
		notes = @notes,
		applyState = 2,	--�豸���ϵ�״̬��0->�½���1->�ѷ��ͣ��ȴ���ˣ�2->����ˣ�һ������3->�Ѵ��ã����Ѹ��ˣ�
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where scrapNum = @scrapNum
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '��˴����豸���ϵ�', '�û�' + @modiManName 
												+ '����˴����豸���ϵ�['+ @scrapNum +']��')
GO


drop PROCEDURE recheckBigScrappedInfo
/*
	name:		recheckBigScrappedInfo
	function:	8.���˴����豸���ϵ�
				ע�⣺����洢����û�м�ⵥ���Ƿ���ڣ�����Ҫ����������
					   ���洢�����Ǵ�updateScrapCheck2Info�зֲ������
	input: 
				@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
														--8λ���ڴ���+4λ��ˮ��
				@processManID char(10),		--������ID���豸����Ա������һ�������Ա��
				@processDesc nvarchar(300),	--���������С���豸�ɲ��
				@processDate varchar(19),	--������ǩ����������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
							
				@gzwDesc nvarchar(300),		--����ί���
				@notificationNum nvarchar(20),--���ʴ���֪ͨ����
				@notes nvarchar(200),		--��ע

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1��ָ���Ĵ����豸���ϵ������ڣ�
							2��Ҫ���µı��ϵ�Ϣ��������������
							3���õ����Ѿ�ͨ�����ˣ���Ч�����������ٴθ��ˣ�
							4�����ǩ��ȫ��
							5��������������˲�����ͬ��
							6���õ��ݻ�û�����, 
							7���ñ��ϵ��е��豸������飬
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-12-15
	UpdateDate: modi by lw 2011-12-16���ݱϴ��������������������븴�˹��̣�
				modi by lw 2012-8-10���ӳ��������Ĵ���
				modi by lw 2013-5-27����Ƿ��е��ӵ��豸�����������
*/
create PROCEDURE recheckBigScrappedInfo
	@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	@processManID char(10),		--������ID���豸����Ա������һ�������Ա��
	@processDesc nvarchar(300),	--���������С���豸�ɲ��
	@processDate varchar(19),	--������ǩ����������ڣ��ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
	
	@gzwDesc nvarchar(300),		--����ί���
	@notificationNum nvarchar(20),--���ʴ���֪ͨ����
	@notes nvarchar(200),		--��ע

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���ı��ϵ��Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum and isBigEquipment=1)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)	--������
	declare @applyState int				--����״̬
	declare @eManagerID char(10)		--����ˣ��豸���ܲ��Ÿ����ˣ�
	--���༭����
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @eManagerID = eManagerID
	from equipmentScrap where scrapNum = @scrapNum
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@applyState >= 3)
	begin
		set @Ret = 3
		return
	end
	else if (@applyState < 2)
	begin
		set @Ret = 6
		return
	end
	--��鸴���˺�������Ƿ���ͬ:
	if (@processManID = @eManagerID)
	begin
		set @Ret = 5
		return
	end

	--���ԭ���ϵ��豸�Ƿ��б༭�������������������������
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end

	--��ȡ������������
	declare @processMan nvarchar(30)	--�����ˣ��豸����Ա��
	set @processMan = isnull((select cName from userInfo where jobNumber = @processManID),'')

	--��������Ƿ���Ч��
	if (@processDate='')
		set @processDate = convert(varchar(19), getdate(), 120)

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	--��Ч���ϵ���
	begin tran
		declare @eCode char(8), @eName nvarchar(30), @eModel nvarchar(20), @eFormat nvarchar(20)	--�豸���/����/�ͺ�/���
		declare @clgCode char(3), @clgName nvarchar(30), @uCode varchar(8), @uName nvarchar(30), @keeper nvarchar(30)	--��������Ϣ:Ժ��/ʹ�õ�λ/������
		declare @annexAmount numeric(12,2), @price numeric(12,2), @totalAmount numeric(12,2)			--��ֵ���������/����/�ܼ�
		--�����ǩ���ֶΣ�
		declare @applyDesc nvarchar(300), @clgDesc nvarchar(300), @clgManager nvarchar(30)	--����ԭ��/Ժ�����/Ժ������
		declare @identifyDesc nvarchar(300), @tManager varchar(30)		--�������/������/�豸�����
		declare @scrapDesc nvarchar(300)			--�豸���ܲ��Ÿ����ˡ����������ʱ�䣺�ֿ�Ƭ��û�е��ֶΣ�Ԥ�����䡣����ODBC��ʽ��ŵ�����ʱ���ʽ���ַ�������"yyyy-MM-dd hh:mm:ss"
		
		select @eCode = s.eCode, @eName = e.eName, @eModel = e.eModel, @eFormat = e.eFormat,
				@clgCode = e.clgCode, @clgName = clg.clgName, @uCode = e.uCode, @uName = u.uName, @keeper = e.keeper,
				@annexAmount = e.annexAmount, @price = e.price, @totalAmount = e.totalAmount,
				@applyDesc = applyDesc, @clgDesc = clgDesc, @clgManager = clgManager, @identifyDesc = identifyDesc, @tManager = tManager
		from bEquipmentScrapDetail s left join equipmentList e on s.eCode = e.eCode 
				left join college clg on e.clgCode = clg.clgCode
				left join useUnit u on e.uCode = u.uCode
		where s.scrapNum = @scrapNum
		select @eManagerID = eManagerID, @scrapDesc = scrapDesc
		from equipmentScrap
		where scrapNum = @scrapNum
		
		--�������Ƿ�ǩ���걸��
		if (rtrim(isnull(@applyDesc,'')) = '' or rtrim(isnull(@clgDesc,'')) = '' or rtrim(isnull(@clgManager,'')) = ''
			or rtrim(isnull(@identifyDesc,'')) = '' or rtrim(isnull(@tManager,'')) = '' 
			or rtrim(isnull(@gzwDesc,'')) = '' or rtrim(isnull(@notificationNum,'')) = ''
			or rtrim(isnull(@scrapDesc,'')) = '')
		begin
			set @Ret = 4
			rollback tran
			return
		end
		--�����豸��
		update equipmentList
		set curEqpStatus = '6',	--�豸��״�룺
								--1�����ã�ָ����ʹ�õ������豸��
								--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
								--3�����ޣ�ָ���޻���������������豸��
								--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
								--5����ʧ��
								--6�����ϣ�
								--7��������
								--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
								--9����������״����������豸��
			scrapDate = convert(smalldatetime, @processDate,120),	--�������ڣ�ԭ[ISDORE] [bit] NOT NULL,���Ѿ�ȷ�ϱ��ϣ��ָ�Ϊʹ�ñ�������
			scrapNum = @scrapNum,	--��Ӧ�ı��ϵ���,add by lw 2011-05-16
			lock4LongTime = 0, lInvoiceNum=''	--�ͷų�������
		where eCode = @eCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--�Ǽ��豸����������Ϣ��
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,changeType,changeInvoiceID) 
		values(@eCode, @eName, @eModel, @eFormat, 
			@clgCode, @clgName, @uCode, @uName, @keeper,
			@annexAmount, @price, @totalAmount,
			@processDate, '�豸����','����',@scrapNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--���±��ϵ���
		update equipmentScrap 
		set processManID = @processManID, processMan = @processMan, processDesc = @processDesc, processDate = convert(smalldatetime,@processDate,120),
			notes = @notes,
			applyState = 3,				--�豸���ϵ�״̬��0->�½���1->�ѷ��ͣ��ȴ���ˣ�2->����ˣ�һ������3->�Ѵ��ã����Ѹ��ˣ�
			replyState = 1,	--���ý����0->δ���ã�1->ȫ��ͬ�⣬2->����ͬ�⣬3->ȫ����ͬ�⡣ԭ�ֶΣ�state
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where scrapNum = @scrapNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--���±�����ϸ����
		update bEquipmentScrapDetail
		set gzwDesc = @gzwDesc, notificationNum = @notificationNum
		where scrapNum = @scrapNum
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
	values(@modiManID, @modiManName, @updateTime, '���˴����豸���ϵ�', '�û�' + @modiManName 
												+ '���˲���Ч�˴����豸���ϵ�['+ @scrapNum +']��')
GO

drop PROCEDURE queryScrapApplyLocMan
/*
	name:		queryScrapApplyLocMan
	function:	9.��ѯָ���������뵥�Ƿ��������ڱ༭
	input: 
				@scrapNum char(12),			--���ϵ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���ı��ϵ�������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2010-11-28
	UpdateDate: 
*/
create PROCEDURE queryScrapApplyLocMan
	@scrapNum char(12),			--���ϵ���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from equipmentScrap where scrapNum = @scrapNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockScrapApply4Edit
/*
	name:		lockScrapApply4Edit
	function:	10.�������ϵ��༭������༭��ͻ
	input: 
				@scrapNum char(12),			--���ϵ���
				@lockManID varchar(10) output,	--�����ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����ı��ϵ������ڣ�2:Ҫ�����ı��ϵ����ڱ����˱༭��
							3�������뵥�Ѿ��������Ч�����ܱ༭��
							6���ñ��ϵ��е��豸������飬
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-28
	UpdateDate: modi by lw 2013-5-27����Ƿ��е��ӵ��豸�����������
*/
create PROCEDURE lockScrapApply4Edit
	@scrapNum char(12),			--���ϵ���
	@lockManID varchar(10) output,	--�����ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ı��ϵ��Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @applyState int, @isBigEquipment int	--�Ƿ�����豸:0->С���豸��1->�����豸
	declare @thisLockMan varchar(10)
	--���༭����
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @isBigEquipment = isBigEquipment
	from equipmentScrap 
	where scrapNum = @scrapNum
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@applyState = 3)
	begin
		set @Ret = 3
		return
	end

	--��鱨�ϵ��豸�Ƿ��б༭�������������������������
	if (@isBigEquipment=1)
		set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	else
		set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end
	
	update equipmentScrap
	set lockManID = @lockManID 
	where scrapNum = @scrapNum
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�������ϵ��༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˱��ϵ�['+ @scrapNum +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockScrapApplyEditor
/*
	name:		unlockScrapApplyEditor
	function:	11.�ͷű��ϵ��༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@scrapNum char(12),				--���ϵ���
				@lockManID varchar(10) output,	--�����ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-28
	UpdateDate: 
*/
create PROCEDURE unlockScrapApplyEditor
	@scrapNum char(12),				--���ϵ���
	@lockManID varchar(10) output,	--�����ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentScrap where scrapNum = @scrapNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update equipmentScrap set lockManID = '' where scrapNum = @scrapNum
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
	values(@lockManID, @lockManName, getdate(), '�ͷű��ϵ��༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˱��ϵ�['+ @scrapNum +']�ı༭����')
GO


drop PROCEDURE delScrapApply
/*
	name:		delScrapApply
	function:	12.ɾ��ָ���ı������뵥
	input: 
				@scrapNum char(12),			--�豸���ϵ���
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ı������뵥�����ڣ�2��Ҫɾ���ı������뵥��������������3�������뵥�Ѿ��������Ч������ɾ����
							6���ñ��ϵ��е��豸������飬
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-28
	UpdateDate: 2011-1-19 by lw �ָ��豸��״�뵽�����á�
				modi by lw 2011-5-16������ɸѡ����ʱ���ֹ���where�Ӿ䲻���㣬���豸�嵥�������ˡ���Ӧ�ı��ϵ����ֶζ�������Ӧ�޸ģ�
				modi by lw 2011-10-15�����豸��������ǰ״̬�����ӡ����ޡ�״̬�������뱨�ϣ���Ӧ�޸ı��洢���ָ̻�״̬��ԭ״̬��
				modi by lw 2012-8-10���ӳ�����������
				modi by lw 2013-5-27����Ƿ��е��ӵ��豸�����������
*/
create PROCEDURE delScrapApply
	@scrapNum char(12),			--�豸���ϵ���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ı������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	declare @thisLockMan varchar(10)	--������
	declare @applyState int, @isBigEquipment int	--�Ƿ�����豸:0->С���豸��1->�����豸
	--���༭����
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @isBigEquipment = isBigEquipment
	from equipmentScrap where scrapNum = @scrapNum
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@applyState <> 0)
	begin
		set @Ret = 3
		return
	end
	
	--��鱨�ϵ��豸�Ƿ��б༭�������������������������
	if (@isBigEquipment=1)
		set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	else
		set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 6
		return
	end

	begin tran
		--�ָ��豸��״��
		if (@isBigEquipment = 0) --С���豸
			update equipmentList
			set curEqpStatus = s.oldEqpStatus,		--��״�룺
										--1�����ã�ָ����ʹ�õ������豸��
										--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
										--3�����ޣ�ָ���޻���������������豸��
										--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
										--5����ʧ��
										--6�����ϣ�
										--7��������
										--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
										--9����������״����������豸��
					scrapNum = null,	--��Ӧ�ı��ϵ���,add by lw 2011-05-16
					lock4LongTime = 0, lInvoiceNum=''	--�ͷų�������
			from equipmentList e left join sEquipmentScrapDetail s on e.eCode = s.eCode and s.scrapNum = @scrapNum
			where e.eCode in (select eCode 
							from sEquipmentScrapDetail 
							where scrapNum = @scrapNum)
		else --�����豸
			update equipmentList
			set curEqpStatus = b.oldEqpStatus,		--��״�룺
										--1�����ã�ָ����ʹ�õ������豸��
										--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
										--3�����ޣ�ָ���޻���������������豸��
										--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
										--5����ʧ��
										--6�����ϣ�
										--7��������
										--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
										--9����������״����������豸��
					scrapNum = null,	--��Ӧ�ı��ϵ���,add by lw 2011-05-16
					lock4LongTime = 0, lInvoiceNum=''	--�ͷų�������
			from equipmentList e left join bEquipmentScrapDetail b on e.eCode = b.eCode and b.scrapNum = @scrapNum
			where e.eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		delete equipmentScrap where scrapNum = @scrapNum	--��ϸ�����Զ�����ɾ����
	commit tran
	set @Ret = 0
	
	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���������뵥', '�û�' + @delManName
												+ 'ɾ���˱������뵥['+ @scrapNum +']��')
GO

drop PROCEDURE cancelScrapCheck2
/*
	name:		cancelScrapCheck2
	function:	13.�������ϵ��������������������
				ע�⣺����洢���̼�鸴�˺��Ƿ������ݸ���������и����򷵻س�����Ϣ��
					  ���洢����ֱ�ӽ����ϵ��ָ�������״̬
	input: 
				@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
														--8λ���ڴ���+4λ��ˮ��
				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ı��ϵ�������,2��Ҫȡ�����˵ı��ϵ���������������
							3���õ��ݲ����Ѹ���״̬��
							4���ñ��ϵ��е��豸�Ѿ��䶯�����б�����Ͳ���Ҫ�ټ���豸�ġ����á�״̬��
							5���ñ��ϵ��е��豸�����˱༭���г���������
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-10-15
	UpdateDate: modi by lw 2011-11-29�������ϵ�ʱ�򲻼�顰��ͬ�⡱���ϵ��豸��״̬
				modi by lw 2011-12-16�ͻ�Ҫ���˻ص���һ���������ݷֲ�����豸���ϵ�����Ӧ����
				modi by lw 2012-8-10���ӳ�����������
				modi by lw 2013-5-27�޶�����Ƿ��е��ӵ��豸����������Ĵ���
*/
create PROCEDURE cancelScrapCheck2
	@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ı��ϵ��Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)	--������
	declare @applyState int				--����״̬
	declare @isBigEquipment int			--�Ƿ�����豸:0->С���豸��1->�����豸
	--���༭����
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @isBigEquipment = isBigEquipment
	from equipmentScrap where scrapNum = @scrapNum
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	if (@applyState <> 3)
	begin
		set @Ret = 3
		return
	end
	
	--���ñ��ϵ��漰���豸�Ƿ��б༭������������
	if (@isBigEquipment = 0)	--С���豸���ϵ�
		set @count = (select COUNT(*) from equipmentList
						where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
							  and (isnull(lockManID,'') <> '' 
									or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	else
		set @count = (select COUNT(*) from equipmentList
						where eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
							  and (isnull(lockManID,'') <> '' 
									or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end

	--���ɨ�������ɵ��豸����鱨�Ϻ��Ƿ��б䶯
	declare @eCode char(8)
	if (@isBigEquipment = 0)	--С���豸���ϵ�
	begin	
		declare tar cursor for
		select eCode from sEquipmentScrapDetail
		where scrapNum = @scrapNum and processState = 1
	end
	else	--�����豸���ϵ�
	begin	
		declare tar cursor for
		select eCode from bEquipmentScrapDetail
		where scrapNum = @scrapNum
	end
	OPEN tar
	FETCH NEXT FROM tar INTO @eCode
	WHILE @@FETCH_STATUS = 0
	begin
		declare @lastChangeType varchar(10)
		declare @lastChangeInvoiceID varchar(30)
		select top 1 @lastChangeInvoiceID = changeInvoiceID, @lastChangeType = changeType 
		from eqpLifeCycle 
		where eCode = @eCode
		order by rowNum desc
		
		if (isnull(@lastChangeType,'')<>'����' and isnull(@lastChangeInvoiceID,'')<>@scrapNum)	--����������
		begin
			CLOSE tar
			DEALLOCATE tar
			set @Ret = 4
			return
		end
		FETCH NEXT FROM tar INTO @eCode
	end
	CLOSE tar
	DEALLOCATE tar
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	--ȡ����Ч���ϵ���
	begin tran
		if (@isBigEquipment = 1)	--�����豸���ϵ�
		begin
			--�����豸��
			update equipmentList
			set curEqpStatus = 4,		--��״�룺
										--1�����ã�ָ����ʹ�õ������豸��
										--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
										--3�����ޣ�ָ���޻���������������豸��
										--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
										--5����ʧ��
										--6�����ϣ�
										--7��������
										--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
										--9����������״����������豸��
					scrapNum = null,	--��Ӧ�ı��ϵ���,add by lw 2011-05-16
					lock4LongTime = 3, lInvoiceNum=@scrapNum	--��������
			where eCode = @eCode
		end
		else	--С���豸���ϵ�
		begin
			--�����豸��
			update equipmentList
			set curEqpStatus = 4,		--��״�룺
										--1�����ã�ָ����ʹ�õ������豸��
										--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
										--3�����ޣ�ָ���޻���������������豸��
										--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
										--5����ʧ��
										--6�����ϣ�
										--7��������
										--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
										--9����������״����������豸��
					scrapNum = null,	--��Ӧ�ı��ϵ���,add by lw 2011-05-16
					lock4LongTime = 3, lInvoiceNum=@scrapNum	--��������
			where eCode in (select eCode 
							from sEquipmentScrapDetail 
							where scrapNum = @scrapNum)

		end
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--ɾ���豸�������ڱ��еı�����Ϣ��
		delete eqpLifeCycle where changeInvoiceID= @scrapNum and changeType = '����'

		if (@isBigEquipment=1)	--�����豸���ϵ�
		begin
			update equipmentScrap 
			set applyState = 2,		--�豸���ϵ�״̬��0->�½���1->�ѷ��ͣ��ȴ���ˣ�2->����ˣ�һ������3->�Ѵ��ã����Ѹ��ˣ�
				replyState = 0,		--���ý����0->δ���ã�1->ȫ��ͬ�⣬2->����ͬ�⣬3->ȫ����ͬ�⡣ԭ�ֶΣ�state
				processManID = '', processMan = '', processDesc = '', processDate = null,
				--ά�����:
				modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
			where scrapNum = @scrapNum
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			update bEquipmentScrapDetail
			set gzwDesc='', notificationNum = ''
			where scrapNum = @scrapNum
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		end
		else	--С���豸���ϵ�
		begin
			update equipmentScrap 
			set applyState = 2,		--�豸���ϵ�״̬��0->�½���1->�ѷ��ͣ��ȴ���ˣ�2->����ˣ�һ������3->�Ѵ��ã����Ѹ��ˣ�
				replyState = 0,		--���ý����0->δ���ã�1->ȫ��ͬ�⣬2->����ͬ�⣬3->ȫ����ͬ�⡣ԭ�ֶΣ�state
				eManagerID = '', eManager = '', scrapDesc = '', scrapDate = null,
				--ά�����:
				modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
			where scrapNum = @scrapNum
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
	values(@modiManID, @modiManName, @updateTime, 'ȡ�����˱��ϵ�', '�û�' + @modiManName 
												+ 'ȡ���˱��ϵ�['+ @scrapNum +']�ĸ��ˡ�')
GO

drop PROCEDURE cancelScrapCheck1
/*
	name:		cancelScrapCheck1
	function:	14.�������ϵ�������
	input: 
				@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
														--8λ���ڴ���+4λ��ˮ��
				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1��ָ���ı��ϵ�������,
							2��Ҫȡ����˵ı��ϵ���������������
							3���õ��ݲ��������״̬��
							5���ñ��ϵ��е��豸�����˱༭���г���������
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-10-15
	UpdateDate: modi by lw 2011-12-16�ֲ�����豸���ϵ�����Ӧ����
				modi by lw 2013-5-27����Ƿ��е��ӵ��豸�����������
*/
create PROCEDURE cancelScrapCheck1
	@scrapNum char(12),			--�������豸���ϵ���,ʹ�ú��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ���ϵ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ı��ϵ��Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentScrap where scrapNum = @scrapNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10)	--������
	declare @applyState int				--����״̬
	declare @isBigEquipment int			--�Ƿ�����豸:0->С���豸��1->�����豸
	--���༭����
	select @thisLockMan = isnull(lockManID,''), @applyState = applyState, @isBigEquipment = isBigEquipment
	from equipmentScrap where scrapNum = @scrapNum
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--��鵥��״̬:
	if (@applyState <> 2)
	begin
		set @Ret = 3
		return
	end

	--���ñ��ϵ��漰���豸�Ƿ��б༭������������
	if (@isBigEquipment = 0)	--С���豸���ϵ�
		set @count = (select COUNT(*) from equipmentList
						where eCode in (select eCode from sEquipmentScrapDetail where scrapNum = @scrapNum)
							  and (isnull(lockManID,'') <> '' 
									or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	else
		set @count = (select COUNT(*) from equipmentList
						where eCode in (select eCode from bEquipmentScrapDetail where scrapNum = @scrapNum)
							  and (isnull(lockManID,'') <> '' 
									or (lock4LongTime <> 0 and not(lock4LongTime = 3 and lInvoiceNum=@scrapNum))))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	--��Чȡ�����ϵ���ˣ�
	begin tran
		if (@isBigEquipment=1)
		begin
			update equipmentScrap 
			set applyState = 0,				--�豸���ϵ�״̬��0->�½���1->�ѷ��ͣ��ȴ���ˣ�2->����ˣ�һ������3->�Ѵ��ã����Ѹ��ˣ�
				replyState = 0,	--���ý����0->δ���ã�1->ȫ��ͬ�⣬2->����ͬ�⣬3->ȫ����ͬ�⡣ԭ�ֶΣ�state
				eManagerID ='', eManager = '', scrapDesc = '', scrapDate =null,
				--ά�����:
				modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
			where scrapNum = @scrapNum
		end
		else
		begin
			update equipmentScrap 
			set applyState = 0,				--�豸���ϵ�״̬��0->�½���1->�ѷ��ͣ��ȴ���ˣ�2->����ˣ�һ������3->�Ѵ��ã����Ѹ��ˣ�
				replyState = 0,	--���ý����0->δ���ã�1->ȫ��ͬ�⣬2->����ͬ�⣬3->ȫ����ͬ�⡣ԭ�ֶΣ�state
				processManID = '', processMan = '', processDesc = '', processDate = null,
				--ά�����:
				modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
			where scrapNum = @scrapNum
		end
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
	values(@modiManID, @modiManName, @updateTime, 'ȡ����˱��ϵ�', '�û�' + @modiManName 
												+ 'ȡ���˱��ϵ�['+ @scrapNum +']����ˡ�')
GO


select scrapNum, convert(varchar(10),applyDate,120) as applyDate,case applyState when 0 then '' when 1 then '...' when 2 then '��' when 3 then '��' end applyState,
case replyState when 0 then '' when 1 then '��' when 2 then '��' when 3 then '�w' end replyState,
clgCode, clgName, clgManager, uCode, uName, applyMan, tel,case isBigEquipment when 0 then '' when 1 then '��' end isBigEquipment,
totalNum, totalMoney,processManID, processMan, processDesc,convert(varchar(10),processDate,120) as processDate, eManagerID, eManager, scrapDesc,
convert(varchar(10),scrapDate,120) as scrapDate,notes 
from equipmentScrap where scrapNum='201101200017';
select scrapNum,eCode, eName, eModel, eFormat, eTypeCode, eTypeName,convert(varchar(10),buyDate,120) as buyDate,
totalAmount, leaveMoney,applyDesc, clgDesc, clgManager, convert(varchar(10), mDate, 120) as mDate,identifyDesc, tManager,
convert(varchar(10),tDate,120) as tDate, gzwDesc, notificationNum
from bEquipmentScrapDetail
where scrapNum='201101200017'






