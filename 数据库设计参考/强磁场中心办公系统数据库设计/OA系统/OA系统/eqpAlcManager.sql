use hustOA
/*
	����豸������Ϣϵͳ-�豸��������
	author:		¬έ
	CreateDate:	2010-11-28
	UpdateDate: 
*/

--1.�豸��������
--ԭ��Ƶ�����ֻ��һ�ű�ÿ�ε���ֻ��һ���豸������������������
--���û�ͬ��ĳ����ӱ�ṹ����������ʱ��
--��λ�ϲ���ʱ����ͨ�����������豸
drop TABLE equipmentAllocation
CREATE TABLE equipmentAllocation(
	alcNum char(12) not null,			--��������������,�ɵ�3�ź��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	alcStatus int default(0),			--������״̬��0->δ��Ч�� 2->��Ч
	alcDate smalldatetime not null,		--����ʱ��									

	oldClgCode char(3) not null,		--ԭԺ������
	oldClgName nvarchar(30) not null,	--ԭԺ������:�����ֶΣ����ǿ��Ա�����ʷ����
	oldClgManager nvarchar(30) null,	--ԭԺ��������:�����ֶΣ����ǿ��Ա�����ʷ����
	oldUCode varchar(8) not null,		--ԭʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	oldUName nvarchar(30) not null,		--ԭʹ�õ�λ����:�����ֶΣ����ǿ��Ա�����ʷ����	

	newClgCode char(3) not null,		--��Ժ������
	newClgName nvarchar(30) not null,	--��Ժ������:�����ֶΣ����ǿ��Ա�����ʷ����
	newClgManager nvarchar(30) null,	--�µ�λ������:�����ֶΣ����ǿ��Ա�����ʷ����
	newUCode varchar(8) not null,		--��ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	newUName nvarchar(30) not null,		--��ʹ�õ�λ����:�����ֶΣ����ǿ��Ա�����ʷ����

	alcReason nvarchar(300) null,		--����ԭ��
	totalNum int default(0),			--������
	totalMoney money default(0),		--�ܽ�ԭֵ��

	--notes nvarchar(300) null,			--��ע	add by lw 2011-12-15

	acceptComments nvarchar(300) null,	--�������
	acceptManID varchar(10) null,		--���ܸ����˹��� add by lw 2012-8-9
	acceptMan nvarchar(30) null,		--���ܸ�����
	eManagerID char(10) null,			--�豸����������ID
	eManager nvarchar(30) null,			--�豸����������

	--�����ˣ�add by lw 2012-8-9Ϊ�˱��ֲ����ķ�Χ�������˵�һ�������ӵ��ֶ�
	createManID varchar(10) null,		--�����˹���
	createManName varchar(30) null,		--����������
	createTime smalldatetime null,		--����ʱ��

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_equipmentAllocation] PRIMARY KEY CLUSTERED 
(
	[alcNum] DESC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


select * from equipmentAllocationDetail
--2.�豸������ϸ��
drop table equipmentAllocationDetail
CREATE TABLE equipmentAllocationDetail(
	alcNum char(12) not null,			--�������������
	rowNum int IDENTITY(1,1) NOT NULL,	--���
	eCode char(8) not null,				--�豸���
	eName nvarchar(30) not null,		--�豸����:��������
	totalAmount money null,				--�ܼ�, >0������+�����۸�
	
	--add by lw 2011-10-15����Ӷ��ʹ�õ�λ�����豸���
	oldClgCode char(3) null,			--ԭѧԺ����
	oldUCode varchar(8) null,			--ԭʹ�õ�λ����
	oldUName nvarchar(30) null,			--ԭʹ�õ�λ����:�����ֶΣ����ǿ��Ա�����ʷ����	
	oldKeepID varchar(10) null,			--ԭ�����˹��ţ��豸����Ա��,add by lw 2011-10-12�ƻ������豸��������Ϣ���������Ա�Ǽ��ˣ�������Ϣֻ���ɹ���Ա��д
	oldKeeper nvarchar(30) null,		--ԭ������
	--add by lw 2012-8-9
	newKeeperID varchar(10) null,		--�±����˹���
	newKeeper nvarchar(30) null,		--�±�����
CONSTRAINT [PK_equipmentAllocationDetail] PRIMARY KEY CLUSTERED 
(
	[alcNum]ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[equipmentAllocationDetail] WITH CHECK ADD CONSTRAINT [FK_equipmentAllocationDetail_equipmentAllocation] FOREIGN KEY([alcNum])
REFERENCES [dbo].[equipmentAllocation] ([alcNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[equipmentAllocationDetail] CHECK CONSTRAINT [FK_equipmentAllocationDetail_equipmentAllocation]
GO




drop PROCEDURE addAlcApply
/*
	name:		addAlcApply
	function:	1.����豸�������뵥����Ҫ��Ϣ��
				ע�⣺���洢�����Զ������༭����Ҫ�ֹ��ͷű༭����
	input: 
				@alcDate varchar(10),		--����ʱ��								
				@alcApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥��N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<newKeeperID>00000008</newKeeperID>
																	--		<newKeeper>��  ��</newKeeper>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<newKeeperID>00000008</newKeeperID>
																	--		<newKeeper>��  ��</newKeeper>
																	--	</row>
																	--	...
																	--</root>'

				@oldClgCode char(3),		--ԭԺ������
				@oldUCode varchar(8),		--ԭʹ�õ�λ����
				--@oldKeeper nvarchar(30),	--ԭ������del by lw 2012-8-9

				@newClgCode char(3),		--��Ժ������
				@newUCode varchar(8),		--��ʹ�õ�λ����
				--@newKeeper nvarchar(30),	--�±�����del by lw 2012-8-9

				@alcReason nvarchar(300),	--����ԭ��

				@acceptComments nvarchar(300),--�������
				@acceptManID varchar(10),	--���ܸ����˹��� add by lw 2012-8-9
				--@acceptMan nvarchar(30),	--���ܸ�����del by lw 2012-8-9

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�������豸�б༭������������9��δ֪����
				@createTime smalldatetime output,
				@alcNum varchar(12) output	--�������������ţ�ʹ�õ� 3 �ź��뷢��������
	author:		¬έ
	CreateDate:	2010-11-29
	UpdateDate: modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2012-8-9���ӽ����˹����ֶΣ�ɾ��ԭ�����ˡ��±������ֶΣ�����ϸ���ı������һ��
*/
create PROCEDURE addAlcApply
	@alcDate varchar(10),		--����ʱ��								
	@alcApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥��N'<root>
														--	<row id="1">
														--		<eCode>10000014</eCode>
														--		<newKeeperID>00000008</newKeeperID>
														--		<newKeeper>��  ��</newKeeper>
														--	</row>
														--	<row id="2">
														--		<eCode>10000015</eCode>
														--		<newKeeperID>00000008</newKeeperID>
														--		<newKeeper>��  ��</newKeeper>
														--	</row>
														--	...
														--</root>'

	@oldClgCode char(3),		--ԭԺ������
	@oldUCode varchar(8),		--ԭʹ�õ�λ����

	@newClgCode char(3),		--��Ժ������
	@newUCode varchar(8),		--��ʹ�õ�λ����

	@alcReason nvarchar(300),	--����ԭ��

	@acceptComments nvarchar(300),--�������
	@acceptManID varchar(10),	--���ܸ����˹��� add by lw 2012-8-9
	--@acceptMan nvarchar(30),	--���ܸ�����del by lw 2012-8-9

	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@createTime smalldatetime output,
	@alcNum varchar(12) output	--�������������ţ�ʹ�õ� 3 �ź��뷢��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���������豸�Ƿ��б༭������������
	declare @count int
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select cast(T.x.query('data(./eCode)') as char(8)) eCode
										from(select @alcApplyDetail.query('/root/row') Col1) A
											OUTER APPLY A.Col1.nodes('/row') AS T(x)
										)
						  and (isnull(lockManID,'') <> '' or lock4LongTime <> '0'))
	if (@count>0)
	begin
		set @Ret = 1
		return
	end

	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 3, 1, @curNumber output
	set @alcNum = @curNumber

	--��ȡԭ��λ���µ�λ�����ơ������˵ȣ�
	declare @oldClgName nvarchar(30), @oldClgManager nvarchar(30), @oldUName nvarchar(30)	--ԭԺ������\ԭԺ��������\ԭʹ�õ�λ����
	declare @newClgName nvarchar(30), @newClgManager nvarchar(30), @newUName nvarchar(30) 	--��Ժ������\�µ�λ������\��ʹ�õ�λ����
	select @oldClgName = clgName, @oldClgManager = manager from college where clgCode = @oldClgCode
	select @oldUName = uName from useUnit where uCode = @oldUCode
	select @newClgName = clgName, @newClgManager = manager from college where clgCode = @newClgCode
	select @newUName = uName from useUnit where uCode = @newUCode

	--ȡ���ܸ����˵�������
	declare @acceptMan nvarchar(30)
	set @acceptMan = isnull((select cName from userInfo where jobNumber = @acceptManID),'')
	
	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	begin tran
		insert equipmentAllocation(alcNum, alcDate,
								oldClgCode, oldClgName, oldClgManager, oldUCode, oldUName,
								newClgCode, newClgName, newClgManager, newUCode, newUName,
								alcReason, 
								acceptComments, acceptManID, acceptMan,
								lockManID, modiManID, modiManName, modiTime, 
								createManID, createManName, createTime) 
		values (@alcNum, @alcDate,
				@oldClgCode, @oldClgName, @oldClgManager, @oldUCode, @oldUName,
				@newClgCode, @newClgName, @newClgManager, @newUCode, @newUName,
				@alcReason, 
				@acceptComments, @acceptManID, @acceptMan,
				@createManID, @createManID, @createManName, @createTime,
				@createManID, @createManName, @createTime) 
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		--������ϸ��
		declare @runRet int 
		exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
		if (@runRet <>0)
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '��ӵ������뵥', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ������˵������뵥[' + @alcNum + ']��')
GO

drop PROCEDURE queryAlcApplyLocMan
/*
	name:		queryAlcApplyLocMan
	function:	2.��ѯָ���������뵥�Ƿ��������ڱ༭
	input: 
				@alcNum char(12),			--��������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���ĵ�����������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2010-11-29
	UpdateDate: 
*/
create PROCEDURE queryAlcApplyLocMan
	@alcNum char(12),			--��������
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockAlcApply4Edit
/*
	name:		lockAlcApply4Edit
	function:	3.�����������༭������༭��ͻ
	input: 
				@alcNum char(12),				--��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����ĵ����������ڣ�2:Ҫ�����ĵ��������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-29
	UpdateDate: 
*/
create PROCEDURE lockAlcApply4Edit
	@alcNum char(12),				--��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����ĵ������Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentAllocation where alcNum = @alcNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update equipmentAllocation
	set lockManID = @lockManID 
	where alcNum = @alcNum
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�����������༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˵�����['+ @alcNum +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockAlcApplyEditor
/*
	name:		unlockAlcApplyEditor
	function:	4.�ͷŵ������༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@alcNum char(12),				--��������
				@lockManID varchar(10) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-29
	UpdateDate: 
*/
create PROCEDURE unlockAlcApplyEditor
	@alcNum char(12),				--��������
	@lockManID varchar(10) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update equipmentAllocation set lockManID = '' where alcNum = @alcNum
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
	values(@lockManID, @lockManName, getdate(), '�ͷŵ������༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˵�����['+ @alcNum +']�ı༭����')
GO

drop PROCEDURE addAlcApplyDetail
/*
	name:		addAlcApplyDetail
	function:	5.����豸������ϸ��
				ע�⣺����洢������ɾ��ȫ������ϸ���ݣ�Ȼ�������
	input: 
				@alcNum varchar(12),		--��������
				@alcApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥��N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<newKeeperID>00000008</newKeeperID>
																	--		<newKeeper>��  ��</newKeeper>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<newKeeperID>00000008</newKeeperID>
																	--		<newKeeper>��  ��</newKeeper>
																	--	</row>
																	--	...
																	--</root>'
				
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-29
	UpdateDate: modi by lw 2011-10-15����ϸ�������ӱ���ԭ��λ�ͱ�������Ϣ��
				modi by lw 2012-8-9�����豸�����������������±�������Ϣ�����ô洢���̸ĳ��ڲ��洢���̣�ȡ��������
				
*/
create PROCEDURE addAlcApplyDetail
	@alcNum varchar(12),		--��������
	@alcApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����豸����������
	update equipmentList
	set lock4LongTime = '2', lInvoiceNum=@alcNum
	where eCode in (select cast(T.x.query('data(./eCode)') as char(8)) eCode
					from(select @alcApplyDetail.query('/root/row') Col1) A
						OUTER APPLY A.Col1.nodes('/row') AS T(x)
					)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	--������ϸ��
	insert equipmentAllocationDetail(alcNum, eCode, eName, totalAmount,oldClgCode, oldUCode, oldKeepID, oldKeeper, newKeeperID, newKeeper)
	select @alcNum, d.eCode, e.eName, e.totalAmount, e.clgCode, e.uCode, e.keeperID, e.keeper, d.newKeeperID, d.newKeeper
	from (select cast(T.x.query('data(./eCode)') as char(8)) eCode,
				cast(T.x.query('data(./newKeeperID)') as varchar(10)) newKeeperID,
				cast(T.x.query('data(./newKeeper)') as nvarchar(30)) newKeeper
		from(select @alcApplyDetail.query('/root/row') Col1) A
			OUTER APPLY A.Col1.nodes('/row') AS T(x)
		) as d left join equipmentList e on d.eCode = e.eCode
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	--���������Ϣ��
	declare @totalNum int, @totalMoney money			--������/�ܽ��
	select @totalNum = count(*), @totalMoney = sum(totalAmount) 
	from equipmentAllocationDetail
	where alcNum = @alcNum
		
	update equipmentAllocation 
	set totalNum = @totalNum, totalMoney = @totalMoney
	where alcNum = @alcNum
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	set @Ret = 0
GO
--���ԣ�
DECLARE @String xml;
set @String = N'
	<root>
		<row id="1">
			<eCode>10000014</eCode>
			<newKeeperID>00000008</newKeeperID>
			<newKeeper>��  ��</newKeeper>
		</row>
		<row id="2">
			<eCode>10000015</eCode>
			<newKeeperID>00000020</newKeeperID>
			<newKeeper>���ˮ</newKeeper>
		</row>
	</root>
'
declare @updateTime smalldatetime
declare @Ret int
exec dbo.addAlcApplyDetail '10', @String, '2010112301', @updateTime output, @Ret output
select @Ret
select * from userInfo
select * from equipmentAllocation where alcNum = '10'
update equipmentAllocation
set alcStatus = 0
where alcNum = '10'

select * from equipmentAllocationDetail where alcNum = '10'
select * from workNote order by actionTime desc

drop PROCEDURE updateAlcApplyInfo
/*
	name:		updateAlcApplyInfo
	function:	6.���µ�����
	input: 
				@alcNum varchar(12),		--��������������,�ɵ�3�ź��뷢��������
														--8λ���ڴ���+4λ��ˮ��
				@alcDate varchar(10),		--����ʱ��								
				@alcApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥��N'<root>
																	--	<row id="1">
																	--		<eCode>10000014</eCode>
																	--		<newKeeperID>00000008</newKeeperID>
																	--		<newKeeper>��  ��</newKeeper>
																	--	</row>
																	--	<row id="2">
																	--		<eCode>10000015</eCode>
																	--		<newKeeperID>00000008</newKeeperID>
																	--		<newKeeper>��  ��</newKeeper>
																	--	</row>
																	--	...
																	--</root>'

				@oldClgCode char(3),		--ԭԺ������
				@oldUCode varchar(8),		--ԭʹ�õ�λ����
				--@oldKeeper nvarchar(30),	--ԭ������ del by lw 2012-8-9

				@newClgCode char(3),		--��Ժ������
				@newUCode varchar(5),		--��ʹ�õ�λ����
				--@newKeeper nvarchar(30),	--�±����� del by lw 2012-8-9

				@alcReason nvarchar(300),	--����ԭ��

				@acceptComments nvarchar(300),--�������
				@acceptManID varchar(10),	--���ܸ����˹��� add by lw 2012-8-9
				--@acceptMan nvarchar(30),	--���ܸ�����del by lw 2012-8-9

				--ά����:
				@modiManID varchar(10) output,		--ά���ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĵ����������ڣ�2��Ҫ���µĵ�������������������3:�õ����Ѿ�ͨ����ˣ��������޸ģ�
									4���õ����е��豸�б༭������������9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-29
	UpdateDate: modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
				modi by lw 2012-8-9���ӽ����˹����ֶΣ�ɾ��ԭ�����ˡ��±������ֶΣ�����ϸ��Ĵ洢���̷���һ��
*/
create PROCEDURE updateAlcApplyInfo
	@alcNum varchar(12),		--��������������,�ɵ�3�ź��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	@alcDate varchar(10),		--����ʱ��								
	@alcApplyDetail xml,		--ʹ��xml�洢����ϸ�嵥

	@oldClgCode char(3),		--ԭԺ������
	@oldUCode varchar(8),		--ԭʹ�õ�λ����

	@newClgCode char(3),		--��Ժ������
	@newUCode varchar(8),		--��ʹ�õ�λ����

	@alcReason nvarchar(300),	--����ԭ��

	@acceptComments nvarchar(300),--�������
	@acceptManID varchar(10),	--���ܸ����˹��� add by lw 2012-8-9
	--@acceptMan nvarchar(30),	--���ܸ�����del by lw 2012-8-9

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�ָ���ĵ������Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentAllocation where alcNum = @alcNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	declare @alcStatus int			--������״̬��0->δ��Ч�� 2->��Ч
	select @alcStatus = alcStatus from equipmentAllocation where alcNum = @alcNum
	if (@alcStatus <> 0)
	begin
		set @Ret = 3
		return
	end

	--���������豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select cast(T.x.query('data(./eCode)') as char(8)) eCode
										from(select @alcApplyDetail.query('/root/row') Col1) A
											OUTER APPLY A.Col1.nodes('/row') AS T(x)
										)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> '0' and not(lock4LongTime = '2' and lInvoiceNum=@alcNum))))
	if (@count>0)
	begin
		set @Ret = 4
		return
	end
	
	--��ȡԭ��λ���µ�λ�����ơ������˵ȣ�
	declare @oldClgName nvarchar(30), @oldClgManager nvarchar(30), @oldUName nvarchar(30)	--ԭԺ������\ԭԺ��������\ԭʹ�õ�λ����
	declare @newClgName nvarchar(30), @newClgManager nvarchar(30), @newUName nvarchar(30) 	--��Ժ������\�µ�λ������\��ʹ�õ�λ����
	select @oldClgName = clgName, @oldClgManager = manager from college where clgCode = @oldClgCode
	select @oldUName = uName from useUnit where uCode = @oldUCode
	select @newClgName = clgName, @newClgManager = manager from college where clgCode = @newClgCode
	select @newUName = uName from useUnit where uCode = @newUCode
	--ȡ���ܸ����˵�������
	declare @acceptMan nvarchar(30)
	set @acceptMan = isnull((select cName from userInfo where jobNumber = @acceptManID),'')
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	begin tran
		--��������
		update equipmentAllocation
		set alcDate = @alcDate,
			oldClgCode = @oldClgCode, oldClgName = @oldClgName, oldClgManager = @oldClgManager, 
			oldUCode = @oldUCode, oldUName = @oldUName,
			newClgCode = @newClgCode, newClgName = @newClgName, newClgManager = @newClgManager, 
			newUCode = @newUCode, newUName = @newUName,
			alcReason = @alcReason, 
			acceptComments = @acceptComments, acceptManID = @acceptManID, acceptMan = @acceptMan,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where alcNum = @alcNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end
		
		--�ͷ�ԭ��ϸ���е��豸����������
		update equipmentList
		set lock4LongTime = '0', lInvoiceNum=''
		where eCode in (select eCode from equipmentAllocationDetail where alcNum = @alcNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			return
		end    
		
		--ɾ��ԭ��ϸ���¼��
		delete equipmentAllocationDetail where alcNum = @alcNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	
		--������ϸ��
		declare @runRet int 
		exec dbo.addAlcApplyDetail @alcNum, @alcApplyDetail, @runRet output
		if (@runRet <>0)
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���µ�����', '�û�' + @modiManName 
												+ '�����˵�����['+ @alcNum +']��')
GO
select * from equipmentAllocation
drop PROCEDURE verifyAlcApply
/*
	name:		verifyAlcApply
	function:	7.��ˣ���Ч��������
				ע�⣺����洢����ͬʱҲ��Ч������
	input: 
				@alcNum char(12),				--��������������,�ɵ�3�ź��뷢��������
														--8λ���ڴ���+4λ��ˮ��
				@eManagerID char(10),			--�豸����������ID
				
				--ά����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µĵ�����Ϣ��������������2:�õ����Ѿ�ͨ����ˣ���Ч�����������޸ģ�9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-29
	UpdateDate: modi by lw 2011-10-15�����豸�������ڱ��еı䶯ƾ֤�Ǽǣ�
				modi by lw 2012-8-9�����ͷ��豸�ĳ�������,�޸��±����˴���
*/
create PROCEDURE verifyAlcApply
	@alcNum char(12),				--��������������,�ɵ�3�ź��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	@eManagerID char(10),			--�豸����������ID

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end
	
	--��鵥��״̬:
	declare @alcStatus int			--������״̬��0->δ��Ч�� 2->��Ч
	select @alcStatus = alcStatus from equipmentAllocation where alcNum = @alcNum
	if (@alcStatus <> 0)
	begin
		set @Ret = 2
		return
	end
	
	--��ȡ�����������
	declare @eManager nvarchar(30)		--�豸����������
	set @eManager = isnull((select cName from userInfo where jobNumber = @eManagerID),'')

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--��ȡ�µ�λ��������ƣ�
	declare @newClgCode char(3), @newClgName nvarchar(30)		--��Ժ������/��Ժ������
	declare @newUCode varchar(8), @newUName nvarchar(30)		--��ʹ�õ�λ����/��ʹ�õ�λ����
	select @newClgCode = newClgCode, @newClgName = newClgName, @newUCode = newUCode, @newUName= newUName 
	from equipmentAllocation 
	where alcNum = @alcNum

	set @updateTime = getdate()

	--��Ч��������
	begin tran
		--�����豸�б�
		update equipmentList
		set 
			clgCode = @newClgCode,
			uCode = @newUCode,
			keeperID = a.newKeeperID,
			keeper = a.newKeeper,
			lock4LongTime = '0', lInvoiceNum=''	--�ͷų�������
		from equipmentList e inner join equipmentAllocationDetail a on e.eCode = a.eCode and a.alcNum = @alcNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--�����豸�������ڱ�
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,
			changeType, changeInvoiceID) 
		select e.eCode, e.eName, e.eModel, e.eFormat, 
			e.clgCode, clg.clgName, e.uCode, u.uName, e.keeper,
			e.annexAmount, e.price, e.totalAmount,
			@updateTime, '���豸���������µ�λ��'+@newClgName+'[' + @newUName +']',
			'����', @alcNum
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
							left join useUnit u on e.uCode = u.uCode
		where e.eCode in (select eCode 
						from equipmentAllocationDetail 
						where alcNum = @alcNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		update equipmentAllocation
		set eManagerID = @eManagerID, eManager = @eManager,
			alcStatus = 2,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where alcNum = @alcNum
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
	values(@modiManID, @modiManName, @updateTime, '�����Ч������', '�û�' + @modiManName 
												+ '��˲���Ч�˵�����['+ @alcNum +']��')
GO
--���ԣ�
declare @updateTime smalldatetime
declare @Ret		int
exec dbo.verifyAlcApply '10', '2010112301', '2010112301',  @updateTime output, @Ret output
select @updateTime, @Ret

select * from equipmentList 
where eCode in (select eCode 
				from equipmentAllocationDetail 
				where alcNum = '10')

select * from equipmentAllocation where alcNum = '10'

drop PROCEDURE effectAlcApply
/*
	name:		effectAlcApply
	function:	7.1.��Ч������
				ע�⣺����洢���̲���Ҫ����ˣ�ֻ�����ڱ�Ժ���ڵ�����
	input: 
				@alcNum char(12),				--��������������,�ɵ�3�ź��뷢��������
														--8λ���ڴ���+4λ��ˮ��
				
				--ά����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µĵ�����Ϣ��������������2:�õ����Ѿ�ͨ����ˣ���Ч�����������޸ģ�9��δ֪����
	author:		¬έ
	CreateDate:	2011-11-15
	UpdateDate: modi by lw 2012-8-9�����ͷ��豸�ĳ�������,�޸��±����˴���
				modi by lw 2013-8-19�޶�@newUCode���ȴ�������

*/
create PROCEDURE effectAlcApply
	@alcNum char(12),				--��������������,�ɵ�3�ź��뷢��������
											--8λ���ڴ���+4λ��ˮ��

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end
	
	--��鵥��״̬:
	declare @alcStatus int			--������״̬��0->δ��Ч�� 2->��Ч
	select @alcStatus = alcStatus from equipmentAllocation where alcNum = @alcNum
	if (@alcStatus <> 0)
	begin
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--��ȡ�µ�λ�����±�����
	declare @newClgCode char(3)		--��Ժ������
	declare @newUCode varchar(8)	--��ʹ�õ�λ����
	select @newClgCode = newClgCode, @newUCode = newUCode from equipmentAllocation where alcNum = @alcNum
	set @updateTime = getdate()

	--��Ч��������
	begin tran
	
		--�����豸�б�
		update equipmentList
		set 
			clgCode = @newClgCode,
			uCode = @newUCode,
			keeperID = a.newKeeperID,
			keeper = a.newKeeper,
			lock4LongTime = '0', lInvoiceNum=''	--�ͷų�������
		from equipmentList e inner join equipmentAllocationDetail a on e.eCode = a.eCode and a.alcNum = @alcNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--�����豸�������ڱ�
		insert eqpLifeCycle(eCode,eName, eModel, eFormat,
			clgCode, clgName, uCode, uName, keeper,
			annexAmount, price, totalAmount,
			changeDate, changeDesc,
			changeType, changeInvoiceID) 
		select e.eCode, e.eName, e.eModel, e.eFormat, 
			e.clgCode, clg.clgName, e.uCode, u.uName, e.keeper,
			e.annexAmount, e.price, e.totalAmount,
			@updateTime, '���豸���������±����ˣ�'+e.keeper,
			'����', @alcNum
		from equipmentList e left join college clg on e.clgCode = clg.clgCode
							left join useUnit u on e.uCode = u.uCode
		where e.eCode in (select eCode 
						from equipmentAllocationDetail 
						where alcNum = @alcNum)
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		update equipmentAllocation
		set eManagerID = @modiManID, eManager = @modiManName,
			alcStatus = 2,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where alcNum = @alcNum
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
	values(@modiManID, @modiManName, @updateTime, '��Ч������', '�û�' + @modiManName 
												+ '��Ч�˵�����['+ @alcNum +']��')
GO
--���ԣ�
declare	@updateTime smalldatetime --����ʱ��
declare	@Ret		int --�����ɹ���ʶ

exec dbo.effectAlcApply '201308190001','G201300052',@updateTime output, @Ret output
select @Ret

update equipmentAllocation set alcStatus=0
select * from equipmentAllocationDetail
delete eqpLifeCycle where eCode='20130020'
select * from equipmentList where eCode='20130020'


/*
	name:		delAlcApply
	function:	8.ɾ��ָ���ĵ������뵥
	input: 
				@alcNum char(12),				--��������������,�ɵ�3�ź��뷢��������
													--8λ���ڴ���+4λ��ˮ��
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĵ������뵥�����ڣ�2��Ҫɾ���ĵ������뵥��������������
							3�������뵥�Ѿ��������Ч������ɾ����9��δ֪����
	author:		¬έ
	CreateDate:	2010-11-29
	UpdateDate: modi by lw 2012-8-9�����ͷ��豸�ĳ�������

*/
create PROCEDURE delAlcApply
	@alcNum char(12),				--��������������,�ɵ�3�ź��뷢��������
											--8λ���ڴ���+4λ��ˮ��
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������뵥���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ĵ������뵥�Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentAllocation where alcNum = @alcNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	declare @alcStatus int			--������״̬��0->δ��Ч�� 2->��Ч
	select @alcStatus = alcStatus from equipmentAllocation where alcNum = @alcNum
	if (@alcStatus <> 0)
	begin
		set @Ret = 3
		return
	end
	begin tran
		--�����豸�б�,�ͷų���������
		update equipmentList
		set 
			lock4LongTime = '0', lInvoiceNum=''
		from equipmentList e inner join equipmentAllocationDetail a on e.eCode = a.eCode and a.alcNum = @alcNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		delete equipmentAllocation where alcNum = @alcNum	--��ϸ�����Զ�����ɾ����
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���������뵥', '�û�' + @delManName
												+ 'ɾ���˵������뵥['+ @alcNum +']��')

GO

drop PROCEDURE cancelVerifyAlcApply
/*
	name:		cancelVerifyAlcApply
	function:	9.�������������
				ע�⣺����洢���̼��������Ƿ������ݸ���������и����򷵻س�����Ϣ��
	input: 
				@alcNum char(12),				--��������������,�ɵ�3�ź��뷢��������
														--8λ���ڴ���+4λ��ˮ��
				
				--ά����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��ָ���ĵ�����������,2��Ҫȡ����˵ĵ�������������������
							3���õ��ݲ��������״̬��
							4���õ����е��豸�Ѿ��䶯��5���õ������е��豸�����˱༭���г���������
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-10-15
	UpdateDate: modi by lw 2012-8-9���ӳ�����������
*/
create PROCEDURE cancelVerifyAlcApply
	@alcNum char(12),				--��������������,�ɵ�3�ź��뷢��������
											--8λ���ڴ���+4λ��ˮ��

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ���ĵ������Ƿ����
	declare @count as int
	set @count=(select count(*) from equipmentAllocation where alcNum = @alcNum)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from equipmentAllocation where alcNum = @alcNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--��鵥��״̬:
	declare @alcStatus int			--������״̬��0->δ��Ч�� 2->��Ч
	select @alcStatus = alcStatus from equipmentAllocation where alcNum = @alcNum
	if (@alcStatus <> 2)
	begin
		set @Ret = 3
		return
	end

	--���õ������漰���豸�Ƿ��б༭������������
	set @count = (select COUNT(*) from equipmentList
					where eCode in (select eCode from equipmentAllocationDetail where alcNum = @alcNum)
						  and (isnull(lockManID,'') <> '' 
								or (lock4LongTime <> '0' and not(lock4LongTime = '2' and lInvoiceNum=@alcNum))))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end

	--���ɨ�������ɵ��豸����������䶯
	declare @eCode char(8)
	declare tar cursor for
	select eCode from equipmentAllocationDetail
	where alcNum = @alcNum
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
		select @lastChangeInvoiceID , @lastChangeType 
		
		if (isnull(@lastChangeType,'')<>'����' and isnull(@lastChangeInvoiceID,'')<>@alcNum)	--����������
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

	--������Ч��������
	begin tran
		--�����豸�б�
		update equipmentList
		set 
			clgCode = a.oldClgCode,
			uCode = a.oldUCode,
			keeperID = a.oldKeepID,
			keeper = a.oldKeeper,
			lock4LongTime = '2', lInvoiceNum=@alcNum	--����������������
		from equipmentList e inner join equipmentAllocationDetail a on e.eCode = a.eCode and a.alcNum = @alcNum
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
		
		--ɾ���豸�������ڱ��еĵ�����Ϣ��
		delete eqpLifeCycle where changeInvoiceID= @alcNum and changeType = '����'
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		update equipmentAllocation
		set eManagerID = '', eManager = '',
			alcStatus = 0,
			--ά�����:
			modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where alcNum = @alcNum
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
	values(@modiManID, @modiManName, @updateTime, 'ȡ���������', '�û�' + @modiManName 
												+ 'ȡ���˵�����['+ @alcNum +']����ˡ�')
GO




use epdc2
select * from equipmentAllocation 
where alcNum in (select alcNum from equipmentAllocationDetail where eCode ='10000129')

select * from equipmentAllocationDetail where alcNum='201101150005'


--��ӡ�������ͼ��
--�б���
CREATE VIEW [dbo].[eqpAllocation]
AS
SELECT     dbo.equipmentAllocation.alcNum, dbo.equipmentAllocationDetail.eName, dbo.equipmentAllocationDetail.totalAmount, dbo.equipmentAllocation.alcDate, 
                      dbo.equipmentAllocation.oldClgName, dbo.equipmentAllocation.oldUName, dbo.equipmentAllocation.newClgName, dbo.equipmentAllocation.newUName, 
                      dbo.equipmentAllocation.totalNum, dbo.equipmentAllocation.totalMoney, dbo.equipmentAllocation.oldKeeper, dbo.equipmentAllocation.newKeeper
FROM         dbo.equipmentAllocation INNER JOIN
                      dbo.equipmentAllocationDetail ON dbo.equipmentAllocation.alcNum = dbo.equipmentAllocationDetail.alcNum

GO


--��Ƭ����
CREATE VIEW eqpAlcDetail
AS
select a.alcNum, a.eCode, a.eName, e.eModel, e.eFormat, a.totalAmount 
from equipmentAllocationDetail a left join equipmentList e on a.eCode = e.eCode
go


