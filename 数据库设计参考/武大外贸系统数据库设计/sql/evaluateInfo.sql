use newfTradeDB2
/*
	�����ó��ͬ������Ϣϵͳ-����ϵͳ
	author:		¬έ
	CreateDate:	2013-10-06
	UpdateDate: 
*/
select * from evaluateInfo
--1.ҵ�����������
drop table evaluateInfo
CREATE TABLE evaluateInfo(
	traderID varchar(12) not null,		--����/�������ó��˾���
	traderName nvarchar(30) null,		--��ó��˾���ƣ��������
	abbTraderName nvarchar(6) null,		--��ó��˾��ƣ��������
	contractID varchar(12) not null,	--��������ͬ���
	--���λ��
	clgCode char(3) not null,			--������ѧԺ����
	clgName nvarchar(30) null,			--ѧԺ����:������ƣ�������ʷ����
	abbClgName nvarchar(6) null,		--Ժ�����
	--����ˣ�
	createrID varchar(10) not null,		--�����ID
	creater nvarchar(30) not null,		--�����
	--��ϵ������ϵ��ʽ��
	ordererID varchar(10) not null,		--��������ϵ��ID�����ͬ�еĶ�����һ��
	orderer nvarchar(30) not null,		--��ϵ������
	mobile varchar(30) null,			--��ϵ���ֻ�
	tel varchar(30) null,				--��ϵ�������绰
	--�������ڣ�
	extensionRedLamp int default(0),	--������Ѵ���
	extensionSMS int default(0),		--�������Ѵ���
	--���ۣ�
	qualityOption int default(0),		--��ó��˾����̬�ȼ�������0->��+,1->��,2->��-,3->��+,4->��,5->��-,6->��+,7->��,8->��-
	abilityOption int default(0),		--��ó��˾����̬�ȼ�������0->��+,1->��,2->��-,3->��+,4->��,5->��-,6->��+,7->��,8->��-
	--�ӳٵ�����Ҫԭ��
	extensionReason nvarchar(300) null,
	--Ҫ�󼰽���	
	suggestion nvarchar(300) null,
	--��ֵ��
	score int default(0),

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_evaluateInfo] PRIMARY KEY CLUSTERED 
(
	[traderID] ASC,
	[contractID] ASC,
	[clgCode] ASC,
	[ordererID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[evaluateInfo] WITH CHECK ADD CONSTRAINT [FK_evaluateInfo_traderInfo] FOREIGN KEY([traderID])
REFERENCES [dbo].[traderInfo] ([traderID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[evaluateInfo] CHECK CONSTRAINT [FK_evaluateInfo_traderInfo]
GO


--2.��ó��˾��ȷ���÷�һ����
drop table traderEvaluateInfo
CREATE TABLE traderEvaluateInfo(
	traderID varchar(12) not null,		--����/�������ó��˾���
	theYear varchar(4) not null,		--���
	traderName nvarchar(30) null,		--��ó��˾���ƣ��������
	abbTraderName nvarchar(6) null,		--��ó��˾��ƣ��������

	newContract int default(0),			--����������ͬ��
	newContractMoney money default(0),	--����������ͬ����Ԫ��
	yearTotalCompletedContract int default(0),		--�����ۼ���ɺ�ͬ��
	yearTotalCompletedContractMoney money default(0),--�����ۼ���ɺ�ͬ����Ԫ��
	evaluatedContract int default(0),	--�����ۼ�������۱��ͬ��
	score int default(0)				--��ֵ��ƽ���֣���
 CONSTRAINT [PK_traderEvaluateInfo] PRIMARY KEY CLUSTERED 
(
	[traderID] ASC,
	[theYear] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[traderEvaluateInfo] WITH CHECK ADD CONSTRAINT [FK_traderEvaluateInfo_traderInfo] FOREIGN KEY([traderID])
REFERENCES [dbo].[traderInfo] ([traderID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[traderEvaluateInfo] CHECK CONSTRAINT [FK_traderEvaluateInfo_traderInfo]
GO

drop FUNCTION getScore
/*
	name:		getScore
	function:	0.���ݷ�ֵ���Ż�ȡ�÷�
	input: 
				@id int	--��ֵ�ֵ���
	output: 
				return int		--��ֵ
	author:		¬έ
	CreateDate:	2013-10-06
	UpdateDate: 
*/
create FUNCTION getScore
(  
	@id int	--��ֵ�ֵ���
)  
RETURNS int
WITH ENCRYPTION
AS      
begin
	declare @scoreStand xml
	set @scoreStand=N'<row id="1">100</row>
						<row id="2">90</row>
						<row id="3">80</row>
						<row id="4">75</row>
						<row id="5">70</row>
						<row id="6">60</row>
						<row id="7">55</row>
						<row id="8">30</row>
						<row id="9">0</row>'
	declare @score int
	set @score = (select score 
					from(
						SELECT cast(convert(varchar(3),T.x.query('data(./@id)')) as int) id, cast(convert(varchar(3),T.x.query('data(.)')) as int) score
						FROM (SELECT @scoreStand Col1) A
							OUTER APPLY A.Col1.nodes('/row') AS T(x)
						) as scoreTab
					where id = @id+1)
	return @score
end
--���ԣ�
declare @s1 int,@s2 int
set @s1 = dbo.getScore(2)
set @s2 = dbo.getScore(2)*30/100 +  dbo.getScore(3)*30/100
select @s2

drop PROCEDURE addEvaluateInfo
/*
	name:		addEvaluateInfo
	function:	1.���ҵ�����������
				ע�⣺�ô洢�����Զ�������¼
	input: 
				@contractID varchar(12),		--��ͬ���
				@clgCode char(3),				--���λ����Ӧ��ͬ�еĶ�����λ
				@ordererID varchar(10),			--��ϵ��ID����Ӧ��ͬ�еĶ�����
				@mobile varchar(30),			--��ϵ���ֻ�
				@tel varchar(30),				--��ϵ�������绰
				--���ۣ�
				@qualityOption int,				--��ó��˾����̬�ȼ�������0->��+,1->��,2->��-,3->��+,4->��,5->��-,6->��+,7->��,8->��-
				@abilityOption int,				--��ó��˾ҵ��������0->��+,1->��,2->��-,3->��+,4->��,5->��-,6->��+,7->��,8->��-
				@extensionReason nvarchar(300),	--�ӳٵ�����Ҫԭ��
				@suggestion nvarchar(300),		--Ҫ�󼰽���	
				@createrID varchar(10),			--�����ID
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1:�ú�ͬ�����۱��Ѿ����ɣ�2:�ú�ͬ������,3:������λ�򶩻��˲��Ǹú�ͬ�ж���ģ�9:δ֪����
	author:		¬έ
	CreateDate:	2013-10-06
	UpdateDate: 

*/
create PROCEDURE addEvaluateInfo
	@contractID varchar(12),		--��ͬ���
	@clgCode char(3),				--���λ����Ӧ��ͬ�еĶ�����λ
	@ordererID varchar(10),			--��ϵ��ID����Ӧ��ͬ�еĶ�����
	@mobile varchar(30),			--��ϵ���ֻ�
	@tel varchar(30),				--��ϵ�������绰
	--���ۣ�
	@qualityOption int,				--��ó��˾����̬�ȼ�������0->��+,1->��,2->��-,3->��+,4->��,5->��-,6->��+,7->��,8->��-
	@abilityOption int,				--��ó��˾ҵ��������0->��+,1->��,2->��-,3->��+,4->��,5->��-,6->��+,7->��,8->��-
	@extensionReason nvarchar(300),	--�ӳٵ�����Ҫԭ��
	@suggestion nvarchar(300),		--Ҫ�󼰽���	
	@createrID varchar(10),			--�����ID
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--������۱��Ƿ��Ѿ����壺
	declare @count int
	set @count = ISNULL((select count(*) from evaluateInfo where contractID=@contractID and clgCode = @clgCode and ordererID = @ordererID),0)
	if (@count > 0)
	begin 
		set @Ret = 1
		return 
	end
	--���ݺ�ͬ��Ż�ȡ��ó��˾
	declare @traderID varchar(12), @traderName nvarchar(30), @abbTraderName nvarchar(6)--��ó��˾��š����ơ����
	select @traderID = c.traderID, @traderName = c.traderName, @abbTraderName = c.abbTraderName
	from contractInfo c left join contractCollege clg on c.contractID=clg.contractID
	where c.contractID = @contractID
	if (@traderName is null)
	begin
		set @Ret = 2
		return
	end
	--���ݺ�ͬ��Ż�ȡ������λ��Ϣ��
	declare @clgName nvarchar(30),@abbClgName nvarchar(6) --��ͬ�еĶ�����λ���롢���ơ����
	select @clgName = clg.clgName, @abbClgName = clg.abbClgName
	from contractCollege clg
	where contractID = @contractID and @clgCode=@clgCode and ordererID = @ordererID
	if (@clgName is null)
	begin
		set @Ret = 3
		return
	end
	
	--��ȡ�����������ݣ�
	declare @extensionYellowLamp int, @extensionRedLamp int, @extensionSMS int	--�������ڣ��Ƶơ���ơ��������Ѵ���
	select @extensionYellowLamp= isnull(sum(yellowLampTimes),0), @extensionRedLamp= isnull(sum(redLampTimes),0), @extensionSMS = isnull(SUM(SMSTimes),0)
	from contractFlow
	where contractID = @contractID and nodeNum <=5 --ͳ���ͽ�����ǰ�����ڴ���

	--��ȡ��ϵ����Ϣ��	
	declare @orderer nvarchar(30)
	set @orderer = isnull((select cName from userInfo where jobNumber=@ordererID),'')
	--��ȡ�����������
	declare @creater nvarchar(30)
	set @creater = isnull((select userCName from activeUsers where userID = @createrID),'')
	
	--�����ֵ��
	--�ܷ�ֵ��100�֣����л������ڷ�ֵ��40�֣�����������30�֣�ҵ��������30�֡�
	--�������ڣ����һ�ο�1�֣���������һ�ο�1�֣�ֱ������Ϊֹ��ֻͳ�ơ�ǩ������Э��\ǩ����ó��ͬ\��֤����\�������\����\�ͽ����ϡ���Щ��ó��˾���뻷�ڡ�
	--����������ҵ�������У���+   �� 100�֣���    �� 90�֣���-   �� 80��	��+   �� 75�֣���   �� 70�֣���-   �� 60��	��+   �� 55�֣���   ��  30�֣���-   �� 0��
	--Ȼ�󽫸÷�ֵ���㵽�ܷ�ֵ���������ֵ*30%��
	declare @score int
	set @score = 40-@extensionRedLamp-@extensionSMS
	if (@score<0)
		set @score = 0
	set @score = @score + dbo.getScore(@qualityOption) * 30/100 +  dbo.getScore(@abilityOption) * 30/100

	insert evaluateInfo(traderID, traderName, abbTraderName, contractID,
						--���λ��
						clgCode, clgName, abbClgName,
						--����ˣ�
						createrID, creater,
						--��ϵ������ϵ��ʽ��
						ordererID, orderer, mobile, tel,
						--�������ڣ�
						extensionRedLamp, extensionSMS,
						--���ۣ�
						qualityOption, abilityOption,
						--�ӳٵ�����Ҫԭ��
						extensionReason,
						--Ҫ�󼰽���	
						suggestion,
						--��ֵ��
						score,
						--ά�������
						lockManID, modiManID, modiManName, modiTime) 
	values(@traderID, @traderName, @abbTraderName, @contractID,
						--���λ��
						@clgCode, @clgName, @abbClgName,
						--����ˣ�
						@createrID, @creater,
						--��ϵ������ϵ��ʽ��
						@ordererID, @orderer, @mobile, @tel,
						--�������ڣ�
						@extensionRedLamp, @extensionSMS,
						--���ۣ�
						@qualityOption, @abilityOption,
						--�ӳٵ�����Ҫԭ��
						@extensionReason,
						--Ҫ�󼰽���	
						@suggestion,
						--��ֵ��
						@score,
						--ά�����
						@createrID, @createrID, @creater, GETDATE())

	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  
		  
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createrID, @creater, GETDATE(), '������۱�', 'ϵͳ�����û�' + @creater + 
					'��Ҫ������˺�ͬ['+@contractID+']��ҵ�����������')
GO
--���ԣ�
declare @Ret int
exec dbo.addEvaluateInfo '20130249','00006327','13902702392','87889011',0,0,'��Ϊ�չ�','ͨ������Ҫ��ǿ','00006327',@Ret output
select @Ret

delete evaluateInfo 
select * from evaluateInfo 


drop PROCEDURE queryEvaluateInfoLocMan
/*
	name:		queryEvaluateInfoLocMan
	function:	2.��ѯָ��ҵ������������Ƿ��������ڱ༭
	input: 
				@contractID varchar(12),	--��ͬ���
				@clgCode char(3),			--���λ����Ӧ��ͬ�еĶ�����λ
				@ordererID varchar(10),		--��ϵ��ID����Ӧ��ͬ�еĶ�����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����ҵ���������������
				@lockManID varchar(10) output--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2013-10-06
	UpdateDate: 
*/
create PROCEDURE queryEvaluateInfoLocMan
	@contractID varchar(12),	--��ͬ���
	@clgCode char(3),			--���λ����Ӧ��ͬ�еĶ�����λ
	@ordererID varchar(10),		--��ϵ��ID����Ӧ��ͬ�еĶ�����
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from evaluateInfo 
						where contractID = @contractID and contractID=@contractID and clgCode = @clgCode and ordererID = @ordererID),'')
	set @Ret = 0
GO


drop PROCEDURE lockEvaluateInfo4Edit
/*
	name:		lockEvaluateInfo4Edit
	function:	3.����ҵ�����������༭������༭��ͻ
	input: 
				@contractID varchar(12),		--��ͬ���
				@clgCode char(3),				--���λ����Ӧ��ͬ�еĶ�����λ
				@ordererID varchar(10),			--��ϵ��ID����Ӧ��ͬ�еĶ�����
				@lockManID varchar(10) output,	--�����ˣ������ǰҵ��������������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������ҵ��������������ڣ�2:Ҫ������ҵ��������������ڱ����˱༭
							9��δ֪����
	author:		¬έ
	CreateDate:	2013-10-06
	UpdateDate: 
*/
create PROCEDURE lockEvaluateInfo4Edit
	@contractID varchar(12),		--��ͬ���
	@clgCode char(3),				--���λ����Ӧ��ͬ�еĶ�����λ
	@ordererID varchar(10),			--��ϵ��ID����Ӧ��ͬ�еĶ�����
	@lockManID varchar(10) output,	--�����ˣ������ǰҵ��������������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������ҵ������������Ƿ����
	declare @count as int
	set @count = ISNULL((select count(*) from evaluateInfo 
						where contractID = @contractID and contractID=@contractID and clgCode = @clgCode and ordererID = @ordererID),0)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from evaluateInfo 
	where contractID = @contractID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update evaluateInfo 
	set lockManID = @lockManID 
	where contractID = @contractID and clgCode = @clgCode and ordererID = @ordererID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�������۱�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˺�ͬ['+ @contractID +']��ҵ�����������Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockEvaluateInfoEditor
/*
	name:		unlockEvaluateInfoEditor
	function:	4.�ͷ�ҵ�����������༭��
				ע�⣺�����̲����ҵ������������Ƿ���ڣ�
	input: 
				@contractID varchar(12),		--��ͬ���
				@clgCode char(3),				--���λ����Ӧ��ͬ�еĶ�����λ
				@ordererID varchar(10),			--��ϵ��ID����Ӧ��ͬ�еĶ�����
				@lockManID varchar(10) output,	--�����ˣ������ǰҵ��������������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-10-06
	UpdateDate: 
*/
create PROCEDURE unlockEvaluateInfoEditor
	@contractID varchar(12),		--��ͬ���
	@clgCode char(3),				--���λ����Ӧ��ͬ�еĶ�����λ
	@ordererID varchar(10),			--��ϵ��ID����Ӧ��ͬ�еĶ�����
	@lockManID varchar(10) output,	--�����ˣ������ǰҵ��������������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from evaluateInfo 
						where contractID = @contractID and contractID=@contractID and clgCode = @clgCode and ordererID = @ordererID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update evaluateInfo set lockManID = '' where contractID = @contractID and clgCode = @clgCode and ordererID = @ordererID
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
	values(@lockManID, @lockManName, getdate(), '�ͷ����۱��༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˺�ͬ['+ @contractID +']��ҵ�����������ı༭����')
GO

select * from evaluateInfo
drop PROCEDURE updateEvaluateInfo
/*
	name:		updateEvaluateInfo
	function:	5.����ҵ�����������
	input: 
				@contractID varchar(12),		--��ͬ���
				@clgCode char(3),				--���λ����Ӧ��ͬ�еĶ�����λ
				@ordererID varchar(10),			--��ϵ��ID����Ӧ��ͬ�еĶ�����
				@mobile varchar(30),			--��ϵ���ֻ�
				@tel varchar(30),				--��ϵ�������绰
				--���ۣ�
				@qualityOption int,				--��ó��˾����̬�ȼ�������0->��+,1->��,2->��-,3->��+,4->��,5->��-,6->��+,7->��,8->��-
				@abilityOption int,				--��ó��˾ҵ��������0->��+,1->��,2->��-,3->��+,4->��,5->��-,6->��+,7->��,8->��-
				@extensionReason nvarchar(300),	--�ӳٵ�����Ҫԭ��
				@suggestion nvarchar(300),		--Ҫ�󼰽���	

				@modiManID varchar(10) output,	--ά���ˣ������ǰҵ��������������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ҵ��������������ڣ�2��Ҫ���µ�ҵ�������������������������
							3:�ú�ͬ������,4:������λ�򶩻��˲��Ǹú�ͬ�ж���ģ�9��δ֪����
	author:		¬έ
	CreateDate:	2013-10-06
	UpdateDate: 
*/
create PROCEDURE updateEvaluateInfo
	@contractID varchar(12),		--��ͬ���
	@clgCode char(3),				--���λ����Ӧ��ͬ�еĶ�����λ
	@ordererID varchar(10),			--��ϵ��ID����Ӧ��ͬ�еĶ�����
	@mobile varchar(30),			--��ϵ���ֻ�
	@tel varchar(30),				--��ϵ�������绰
	--���ۣ�
	@qualityOption int,				--��ó��˾����̬�ȼ�������0->��+,1->��,2->��-,3->��+,4->��,5->��-,6->��+,7->��,8->��-
	@abilityOption int,				--��ó��˾����̬�ȼ�������0->��+,1->��,2->��-,3->��+,4->��,5->��-,6->��+,7->��,8->��-
	@extensionReason nvarchar(300),	--�ӳٵ�����Ҫԭ��
	@suggestion nvarchar(300),		--Ҫ�󼰽���	
	
	@modiManID varchar(10) output,	--ά���ˣ������ǰҵ��������������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--������۱��Ƿ��Ѿ����壺
	declare @count int
	set @count = ISNULL((select count(*) from evaluateInfo where contractID=@contractID and clgCode = @clgCode and ordererID = @ordererID),0)
	if (@count = 0)
	begin 
		set @Ret = 1
		return 
	end
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'')
	from evaluateInfo
	where contractID = @contractID and clgCode = @clgCode and ordererID = @ordererID
	--���༭����
	if (@thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	--���ݺ�ͬ��Ż�ȡ��ó��˾��Ϣ��
	declare @traderID varchar(12), @traderName nvarchar(30), @abbTraderName nvarchar(6)--��ó��˾��š����ơ����
	select @traderID = c.traderID, @traderName = c.traderName, @abbTraderName = c.abbTraderName
	from contractInfo c left join contractCollege clg on c.contractID=clg.contractID
	where c.contractID = @contractID
	if (@traderName is null)
	begin
		set @Ret = 3
		return
	end
	--���ݺ�ͬ��Ż�ȡ������λ��Ϣ��
	declare @clgName nvarchar(30),@abbClgName nvarchar(6) --��ͬ�еĶ�����λ���롢���ơ����
	select @clgName = clg.clgName, @abbClgName = clg.abbClgName
	from contractCollege clg
	where contractID = @contractID and @clgCode=@clgCode and ordererID = @ordererID
	if (@clgName is null)
	begin
		set @Ret = 4
		return
	end
	
	--��ȡ�����������ݣ�
	declare @extensionYellowLamp int, @extensionRedLamp int, @extensionSMS int	--�������ڣ��Ƶơ���ơ��������Ѵ���
	select @extensionYellowLamp= isnull(sum(yellowLampTimes),0), @extensionRedLamp= isnull(sum(redLampTimes),0), @extensionSMS = isnull(SUM(SMSTimes),0)
	from contractFlow
	where contractID = @contractID and nodeNum <=5 --ͳ���ͽ�����ǰ�����ڴ���

	--��ȡ��ϵ����Ϣ��	
	declare @orderer nvarchar(30)
	set @orderer = isnull((select cName from userInfo where jobNumber=@ordererID),'')
	--��ȡά����������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--�����ֵ��
	--�ܷ�ֵ��100�֣����л������ڷ�ֵ��40�֣�����������30�֣�ҵ��������30�֡�
	--�������ڣ����һ�ο�1�֣���������һ�ο�1�֣�ֱ������Ϊֹ��ֻͳ�ơ�ǩ������Э��\ǩ����ó��ͬ\��֤����\�������\����\�ͽ����ϡ���Щ��ó��˾���뻷�ڡ�
	--����������ҵ�������У���+   �� 100�֣���    �� 90�֣���-   �� 80��	��+   �� 75�֣���   �� 70�֣���-   �� 60��	��+   �� 55�֣���   ��  30�֣���-   �� 0��
	--Ȼ�󽫸÷�ֵ���㵽�ܷ�ֵ���������ֵ*30%��
	declare @score int
	set @score = 40-@extensionRedLamp-@extensionSMS
	if (@score<0)
		set @score = 0
	set @score = @score + dbo.getScore(@qualityOption) * 30/100 +  dbo.getScore(@abilityOption) * 30/100

	update evaluateInfo
	set traderID = @traderID, traderName = @traderName, abbTraderName = @abbTraderName, contractID = @contractID,
	--���λ��
	clgCode = @clgCode, clgName = @clgName, abbClgName = @abbClgName,
	--��ϵ������ϵ��ʽ��
	ordererID = @ordererID, orderer = @orderer, mobile = @mobile, tel = @tel,
	--�������ڣ�
	extensionRedLamp = @extensionRedLamp, extensionSMS = @extensionSMS,
	--���ۣ�
	qualityOption = @qualityOption, abilityOption = @abilityOption,
	--�ӳٵ�����Ҫԭ��
	extensionReason = @extensionReason,
	--Ҫ�󼰽���	
	suggestion = @suggestion,
	--��ֵ��
	score = @score,
	--ά�������
	modiManID = @modiManID, modiManName = @modiManName, modiTime = GETDATE() 
	where contractID = @contractID and clgCode = @clgCode and ordererID = @ordererID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end  
		  
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, GETDATE(), '�������۱�', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ������˺�ͬ['+@contractID+']��ҵ�����������')
GO


drop PROCEDURE delEvaluateInfo
/*
	name:		delEvaluateInfo
	function:	6.ɾ��ָ����ҵ�����������
	input: 
				@contractID char(12),			--��ͬ���
				@clgCode char(3),				--���λ����Ӧ��ͬ�еĶ�����λ
				@ordererID varchar(10),			--��ϵ��ID����Ӧ��ͬ�еĶ�����
				@delManID varchar(10) output,	--ɾ���ˣ������ǰҵ��������������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ҵ��������������ڣ�2��Ҫɾ����ҵ�������������������������9��δ֪����
	author:		¬έ
	CreateDate:	2013-10-06
	UpdateDate: 

*/
create PROCEDURE delEvaluateInfo
	@contractID char(12),			--��ͬ���
	@clgCode char(3),				--���λ����Ӧ��ͬ�еĶ�����λ
	@ordererID varchar(10),			--��ϵ��ID����Ӧ��ͬ�еĶ�����
	@delManID varchar(10) output,	--ɾ���ˣ������ǰҵ��������������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫָ����ҵ������������Ƿ����
	declare @count as int
	set @count = ISNULL((select count(*) from evaluateInfo where contractID=@contractID and clgCode = @clgCode and ordererID = @ordererID),0)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan= isnull(lockManID,'')
	from evaluateInfo 
	where contractID = @contractID
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete evaluateInfo where contractID = @contractID and clgCode = @clgCode and ordererID = @ordererID
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end

	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��ҵ�����������', '�û�' + @delManName
												+ 'ɾ���˺�ͬ['+ @contractID +']��ҵ�����������')
GO
--���ԣ�


drop proc makeTraderEvaluateInfo
/*
	name:		makeTraderEvaluateInfo
	function:	10.ͳ��ָ����ȵ���ó��˾�������۱�
	input: 
				@theYear varchar(4),			--ͳ�����
				@makerID varchar(10),			--�Ʊ��˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	author:		¬έ
	CreateDate:	2013-10-07
	UpdateDate: 
*/
create PROCEDURE makeTraderEvaluateInfo
	@theYear varchar(4),			--ͳ�����
	@makerID varchar(10),			--�Ʊ��˹���
	@Ret int output					--�����ɹ���ʶ��0:�ɹ���9:δ֪����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--��ȡ�Ʊ���������
	declare @maker nvarchar(30)
	set @maker = isnull((select userCName from activeUsers where userID = @makerID),'')
	--�Ʊ����ڣ�
	declare @makeDate smalldatetime		--�Ʊ�����
	set @makeDate = GETDATE()

	begin tran
		--ɾ�����ܴ��ڵ����ͳ�Ʊ�
		delete traderEvaluateInfo where theYear=@theYear
		--���ɨ����ó��˾ͳ�ƺ�ͬ�͵÷֣�
		declare @traderID varchar(12),@traderName nvarchar(30),@abbTraderName nvarchar(6)		--����/�������ó��˾��š����ơ����
		declare tar cursor for
		select traderID, traderName, abbTraderName from traderInfo order by traderID
		OPEN tar
		FETCH NEXT FROM tar INTO @traderID,@traderName,@abbTraderName
		WHILE @@FETCH_STATUS = 0
		begin
			declare @newContract int,@newContractMoney money			--����������ͬ��/����������ͬ����Ԫ��
			declare @yearTotalCompletedContract int, @yearTotalCompletedContractMoney money		--�����ۼ���ɺ�ͬ��/�����ۼ���ɺ�ͬ����Ԫ��
			declare @evaluatedContract int, @sumScore int	--�����ۼ�������۱��ͬ��/�ܷ�
			set @newContract = (select count(*) from contractInfo	--������ͬ
								where convert(varchar(4),startTime,120)=@theYear and traderID=@traderID)
			set @newContractMoney=isnull((select sum(isnull(dollar,0)) from contractInfo		--������ͬ����Ԫ��
								where convert(varchar(4),startTime,120)=@theYear and traderID=@traderID),0)
			set @yearTotalCompletedContract = (select count(*) from contractInfo	--�����ۼ���ɺ�ͬ��
								where convert(varchar(4),completedTime,120)=@theYear and traderID=@traderID)
			set @yearTotalCompletedContractMoney=isnull((select sum(isnull(dollar,0)) from contractInfo		--�����ۼ���ɺ�ͬ����Ԫ��
								where convert(varchar(4),completedTime,120)=@theYear and traderID=@traderID),0)
			select @evaluatedContract = count(*), @sumScore=SUM(cScore/num)
			from (select count(*) num, SUM(score) cScore 
				from evaluateInfo e left join contractInfo c on e.contractID=c.contractID
				where convert(varchar(4),c.completedTime,120)=@theYear
				group by e.contractID) as t
			insert traderEvaluateInfo(traderID, theYear, traderName, abbTraderName,
					newContract, newContractMoney, yearTotalCompletedContract, yearTotalCompletedContractMoney, 
					evaluatedContract, score)
			values(@traderID, @theYear, @traderName, @abbTraderName,
					@newContract, @newContractMoney, @yearTotalCompletedContract, @yearTotalCompletedContractMoney, 
					@evaluatedContract, @sumScore/@evaluatedContract)
			if (@@ERROR <> 0)
			begin
				set @Ret = 9
				rollback tran
				CLOSE tar
				DEALLOCATE tar
				return
			end
			FETCH NEXT FROM tar INTO @traderID,@traderName,@abbTraderName
		end
		CLOSE tar
		DEALLOCATE tar
		set @Ret = 0
	commit tran
	--д������־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makerID, @maker, @makeDate, '������ó�������۱�', 'ϵͳ�����û�' + @maker + 
					'��Ҫ��������['+@theYear+']�����ó��˾����÷ֱ�')
GO
--���ԣ�
declare @Ret		int
exec dbo.makeTraderEvaluateInfo '2012','0000000000',@Ret output
select @Ret
select * from traderEvaluateInfo


--���۱�
select e.traderID, e.traderName, e.abbTraderName, c.contractID, e.clgCode, e.clgName, e.abbClgName,
	e.createrID, e.creater, e.ordererID, e.orderer, e.mobile, e.tel, e.extensionRedLamp, e.extensionSMS,
	e.qualityOption, e.abilityOption, e.extensionReason, e.suggestion, e.score, 
	e.modiManID, e.modiManName, convert(varchar(10),e.modiTime,120) modiTime
from evaluateInfo e left join contractInfo c on e.contractID=c.contractID
where convert(varchar(4),c.completedTime,120)='2013' and e.traderID=''

--��ͬ����ó��˾��Ҫ��Ϣ��
select c.contractID, c.traderID, c.traderName, c.abbTraderName, c.traderOprManID,c.traderOprMan,c.traderOprManMobile,c.traderOprManTel
from contractInfo c
--��ͬ�Ķ�����λ��Ҫ��Ϣ��
select c.contractID, c.traderID, c.traderName, c.abbTraderName, c.traderOprManID,c.traderOprMan,c.traderOprManMobile,c.traderOprManTel
select * from contractInfo c
--��ͬ�豸��Ҫ��Ϣ��
select e.eName, e.eFormat, e.price, c.currency, cd.objDesc currencyName
from contractEqp e left join contractInfo c on e.contractID=c.contractID
left join codeDictionary cd on cd.classCode=3 and cd.objCode = c.currency

select * from contractEqp


select traderID, theYear, traderName, abbTraderName, 
	newContract, newContractMoney, yearTotalCompletedContract, yearTotalCompletedContractMoney, 
	evaluatedContract, score
from traderEvaluateInfo
