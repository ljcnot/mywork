use hustOA
/*
	����豸������Ϣϵͳ-ͳ��
	author:		¬έ
	CreateDate:	2011-2-8
	UpdateDate: 
*/
select * from statisticTemplate
select * from wd.dbo.statisticTemplate
--1.ͳ��ģ���
select * from statisticTemplate
drop table statisticTemplate
CREATE TABLE [dbo].[statisticTemplate](
	templateID smallint IDENTITY(1,1) NOT NULL,	--ģ��ID
	templateType smallint default(0),	--ģ�����0->�豸������ܣ�1->���ֶλ��ܣ�2->��λ�������,3->ʹ�÷���4->������Դ
	templateName nvarchar(30) not null,	--ͳ��ģ������
	templateDesc nvarchar(300) null,	--ͳ��ģ�������
	
	--ͳ�ƵĲ�����
	--del by lw 2011-2-19��Ϊ��ͳ�Ƶ�ʱ����Է�����趨����������������ɾ����
	--statisticUnitType int not null,		--ͳ�Ʒ�Χ:0->ȫУ��1->Ժ��
	--particleSize int not null,			--���飨ͳ�Ƶ�λ������ȣ�:0->ȫУ��1->Ժ����2->ʹ�õ�λ����ģ������Ϊ��2->��λ����ʱֻ��ѡ��1��2
	
	--ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName varchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��
	--�༭�����ˣ�
	lockManID varchar(18) null,			--��ǰ���������༭������ݺ���
 CONSTRAINT [PK_statisticTemplate] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

insert statisticTemplate(templateType, templateName, templateDesc)
values(0, '��Ϣ���ʲ�����ͳ��ģ��','')
insert statisticTemplate(templateType, templateName, templateDesc)
values(0, '�����ʲ�������������ͳ��ģ��','')

select * from wd.dbo.subTotalTemplateQuota
--2.�������ͳ��ģ���ָ�꣺
drop table subTotalTemplateQuota
CREATE TABLE [dbo].[subTotalTemplateQuota](
	templateID smallint not null,	--ģ��ID
	rowNum smallint NOT NULL,		--���
	eTypeCode char(8) not null,		--�����ţ��̣�
	eTypeName nvarchar(30) not null,--�������ƣ�ע������ķ������ƿ������������е����Ʋ�һ�£���
 CONSTRAINT [PK_subTotalTemplateQuota] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--�����
ALTER TABLE [dbo].[subTotalTemplateQuota] WITH CHECK ADD CONSTRAINT [FK_subTotalTemplateQuota_statisticTemplate] FOREIGN KEY([templateID])
REFERENCES [dbo].[statisticTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[subTotalTemplateQuota] CHECK CONSTRAINT [FK_subTotalTemplateQuota_statisticTemplate] 
GO

--ע�⣺������������������룡�����λΪ0ʱ��С�࣬���4λΪ0ʱ�����࣬���6λΪ0ʱ�Ǵ��ࡣ
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,1, '05010105', 'PC��') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,2, '05010104', '������') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,3, '05010904', '������') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,4, '05010710', '���ϵͳ�������') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,5, '05010508', 'Ӳ�����������洢��') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,6, '05010535', '���̴洢')
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,7, '03040310', 'ͶӰ��') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,8, '03160602', 'ͶӰ��') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,9, '05010501', '��ʽ����ɫ��ī��ӡ��') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,10, '05010549', '�����ӡ��') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,11, '05010550', 'ɨ����') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(1,12, '05010902', '·����') 


--------����ͳ��
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,1, '04130301', 'С�γ�') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,2, '04130201', '����ԽҰ����') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,3, '04130202', '����ԽҰ����') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,4, '04130300', '�ͳ�') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,5, '04130302', '��γ�') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,6, '04130303', '���г�') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,7, '04130103', '����') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,8, '04130104', '΢������') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,9, '04130105', '��ж��������') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,10, '04130400', '���ֳ�') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,11, '04130401', '���ɷ�������/������') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,12, '04130402', '�Ȼ���') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,13, '04130404', '��ˮ��') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,14, '04130407', '���߳������޹�������/˫��ר�ó�') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,15, '04130408', '�߿���ҵ��') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,16, '04130412', '������/�������ϳ�') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,17, '04130500', 'Ħ�г�') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,18, '04130501', '����Ħ�г�') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,19, '04130503', '����Ħ�г�') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,20, '04130601', '����Ħ�г�') 
insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
values(2,21, '04130602', '����������/������') 

--3.���ֶ�ͳ��ģ���ָ�꣺
drop table moneySectionQuota
CREATE TABLE [dbo].[moneySectionQuota](
	templateID smallint not null,	--ģ��ID
	rowNum smallint NOT NULL,		--���
	startMoney money null,			--�����
	endMoney money null,			--������-1��ʾ�����
 CONSTRAINT [PK_moneySectionQuota] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--�����
ALTER TABLE [dbo].[moneySectionQuota] WITH CHECK ADD CONSTRAINT [FK_moneySectionQuota_statisticTemplate] FOREIGN KEY([templateID])
REFERENCES [dbo].[statisticTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[moneySectionQuota] CHECK CONSTRAINT [FK_moneySectionQuota_statisticTemplate]
GO

--4.ʹ�÷���ͳ��ģ���ָ�꣺
drop table appDirQuota
CREATE TABLE [dbo].[appDirQuota](
	templateID smallint not null,	--ģ��ID
	rowNum smallint NOT NULL,		--���
	aCode char(2) not null,			--ʹ�÷������
	aName nvarchar(20) not null,	--ʹ�÷�������	
 CONSTRAINT [PK_appDirQuota] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--�����
ALTER TABLE [dbo].[appDirQuota] WITH CHECK ADD CONSTRAINT [FK_appDirQuota_statisticTemplate] FOREIGN KEY([templateID])
REFERENCES [dbo].[statisticTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[appDirQuota] CHECK CONSTRAINT [FK_appDirQuota_statisticTemplate]
GO

--5.������Դͳ��ģ���ָ�꣺
drop table fundSrcQuota
CREATE TABLE [dbo].[fundSrcQuota](
	templateID smallint not null,	--ģ��ID
	rowNum smallint NOT NULL,		--���
	fCode char(2) not null,			--������Դ����
	fName nvarchar(20) not null,	--������Դ����	
 CONSTRAINT [PK_fundSrcQuota] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--�����
ALTER TABLE [dbo].[fundSrcQuota] WITH CHECK ADD CONSTRAINT [FK_fundSrcQuota_statisticTemplate] FOREIGN KEY([templateID])
REFERENCES [dbo].[statisticTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[fundSrcQuota] CHECK CONSTRAINT [FK_fundSrcQuota_statisticTemplate]
GO

--ͳ��ģ��༭�洢���̣�
drop PROCEDURE checkStatisticTemplate
/*
	name:		checkStatisticTemplate
	function:	0.���ָ����ͳ��ģ���Ƿ��Ѿ�����
	input: 
				@templateName nvarchar(30),	--ͳ��ģ������
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�����ڣ�>1�����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2011-2-9
	UpdateDate: 
*/
create PROCEDURE checkStatisticTemplate
	@templateName nvarchar(30),		--ͳ��ģ������
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����ͳ��ģ�������Ƿ�������
	declare @count int
	set @count = (select count(*) from statisticTemplate where templateName = @templateName)
	set @Ret = @count
GO

drop PROCEDURE addStatisticTemplate
/*
	name:		addStatisticTemplate
	function:	1.���ͳ��ģ��
				ע�⣺���洢���������༭��
	input: 
				@templateType smallint,		--ģ�����0->�豸������ܣ�1->���ֶλ��ܣ�2->��λ����,3->ʹ�÷���4->������Դ
				@templateName nvarchar(30),	--ͳ��ģ������
				@templateDesc nvarchar(300),--ͳ��ģ�������
				
				----ͳ�ƵĲ�����
				--@statisticUnitType int,		--ͳ�Ʒ�Χ:0->ȫУ��1->Ժ��
				--@particleSize int,			--ͳ�Ƶ�λ�������ȣ�:0->ȫУ��1->Ժ����2->ʹ�õ�λ
				
				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1����ģ���Ѿ��Ǽǹ���9��δ֪����
				@templateID smallint output,	--ģ��ID
				@createTime smalldatetime output
	author:		¬έ
	CreateDate:	2011-2-9
	UpdateDate:modi by lw 2011-2-19ɾ��ͳ�Ʒ�Χ�ͷ���������������
			   modi by lw 2011-3-10���ݱϴ�Ҫ�����ӡ�ʹ�÷��򡢾�����Դ������ģ��
*/
create PROCEDURE addStatisticTemplate
	@templateType smallint,		--ģ�����0->�豸������ܣ�1->���ֶλ��ܣ�2->��λ����,3->ʹ�÷���4->������Դ
	@templateName nvarchar(30),	--ͳ��ģ������
	@templateDesc nvarchar(300),--ͳ��ģ�������
	
	--ͳ�ƵĲ�����
	--@statisticUnitType int,		--ͳ�Ʒ�Χ:0->ȫУ��1->Ժ��
	--@particleSize int,			--ͳ�Ƶ�λ�������ȣ�:0->ȫУ��1->Ժ����2->ʹ�õ�λ
	
	@createManID varchar(10),	--�����˹���

	@Ret		int output,
	@templateID smallint output,	--ģ��ID
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--����ģ���Ƿ�������
	declare @count int
	set @count = (select count(*) from statisticTemplate where templateName = @templateName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--ȡά���˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert statisticTemplate(templateType, templateName, templateDesc, 
						lockManID, modiManID, modiManName, modiTime) 
	values (@templateType, @templateName, @templateDesc, 
			@createManID, @createManID, @createManName, @createTime)
	set @templateID =(select templateID from statisticTemplate where templateName = @templateName)
	
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '���ͳ��ģ��', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ�������ͳ��ģ��[' + @templateName + ']��')
GO

drop PROCEDURE queryStatisticTemplateLocMan
/*
	name:		queryStatisticTemplateLocMan
	function:	2.��ѯָ��ͳ��ģ���Ƿ��������ڱ༭
	input: 
				@templateID smallint,		--ģ��ID
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����ͳ��ģ�岻����
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2011-2-9
	UpdateDate: 
*/
create PROCEDURE queryStatisticTemplateLocMan
	@templateID smallint,		--ģ��ID
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	set @Ret = 0
GO


drop PROCEDURE lockStatisticTemplate4Edit
/*
	name:		lockStatisticTemplate4Edit
	function:	3.����ͳ��ģ��༭������༭��ͻ
	input: 
				@templateID smallint,		--ģ��ID
				@lockManID varchar(10) output,	--�����ˣ������ǰģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������ͳ��ģ�岻���ڣ�2:Ҫ������ͳ��ģ�����ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2011-2-9
	UpdateDate: 
*/
create PROCEDURE lockStatisticTemplate4Edit
	@templateID smallint,		--ģ��ID
	@lockManID varchar(10) output,	--�����ˣ������ǰģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������ͳ��ģ���Ƿ����
	declare @count as int
	set @count=(select count(*) from statisticTemplate where templateID = @templateID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update statisticTemplate
	set lockManID = @lockManID 
	where templateID = @templateID
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����ͳ��ģ��༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˵�[' + str(@templateID,6) + ']��ͳ��ģ��Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockStatisticTemplateEditor
/*
	name:		unlockStatisticTemplateEditor
	function:	4.�ͷ�ͳ��ģ��༭��
				ע�⣺�����̲���鵥���Ƿ���ڣ�
	input: 
				@templateID smallint,		--ģ��ID
				@lockManID varchar(10) output,	--�����ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2011-2-9
	UpdateDate: 
*/
create PROCEDURE unlockStatisticTemplateEditor
	@templateID smallint,		--ģ��ID
	@lockManID varchar(10) output,	--�����ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update statisticTemplate set lockManID = '' where templateID = @templateID
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
	values(@lockManID, @lockManName, getdate(), '�ͷ�ͳ��ģ��༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˵�[' + str(@templateID,6) + ']��ͳ��ģ��ı༭����')
GO

drop PROCEDURE addSubTotalTemplateQuota
/*
	name:		addSubTotalTemplateQuota
	function:	5.����豸�������ͳ��ָ��
				ע�⣺����洢������ɾ��ȫ������ϸ���ݣ�Ȼ������ӡ�
				��ʹ���豸����Լ��������ģ�嶼Ҫ���øô洢���̱������ݣ�
	input: 
				@templateID smallint,	--ģ��ID
				@quotaDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
																	--	<row id="1">
																	--		<eTypeCode>05010549</eTypeCode>
																	--		<eTypeName>�����ӡ��</eTypeName>
																	--	</row>
																	--	<row id="2">
																	--		<eTypeCode>05010550</eTypeCode>
																	--		<eTypeName>ɨ����</eTypeName>
																	--	</row>
																	--	...
																	--</root>'
				--ά����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µ�ͳ��ģ����������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-2-9
	UpdateDate: 
*/
create PROCEDURE addSubTotalTemplateQuota
	@templateID smallint,	--ģ��ID
	@quotaDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<eTypeCode>05010549</eTypeCode>
														--		<eTypeName>�����ӡ��</eTypeName>
														--	</row>
														--	<row id="2">
														--		<eTypeCode>05010550</eTypeCode>
														--		<eTypeName>ɨ����</eTypeName>
														--	</row>
														--	...
														--</root>'
	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	--���²����豸�������ָ�꣺
	begin tran
		delete subTotalTemplateQuota where templateID = @templateID

		insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
		select @templateID, cast(cast(T.x.query('data(./@id)') as varchar(8)) as smallint) rowNum, 
				cast(T.x.query('data(./eTypeCode)') as char(8)) eTypeCode, 
				cast(T.x.query('data(./eTypeName)') as nvarchar(30)) eTypeName
		from(select @quotaDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
		
		update statisticTemplate
		set modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where templateID = @templateID
		set @Ret = 0
	commit tran
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���²���������ָ��', '�û�' + @modiManName 
												+ '���²����˵�['+ str(@templateID,6) +']��ͳ��ģ����豸�������ָ�ꡣ')
GO
--���ԣ�
declare	@quotaDetail xml
set @quotaDetail = N'<root>
						<row id="1">
							<eTypeCode>05010549</eTypeCode>
							<eTypeName>�����ӡ��</eTypeName>
						</row>
						<row id="2">
							<eTypeCode>05010550</eTypeCode>
							<eTypeName>ɨ����</eTypeName>
						</row>
					</root>'
declare @updateTime smalldatetime
declare @Ret int
exec dbo.addSubTotalTemplateQuota 1, @quotaDetail, '2010112301', @updateTime output, @Ret output
select @Ret

select * from subTotalTemplateQuota

drop PROCEDURE addMoneySectionQuota
/*
	name:		addMoneySectionQuota
	function:	6.��ӽ��ֶλ���ͳ��ָ��
				ע�⣺����洢������ɾ��ȫ������ϸ���ݣ�Ȼ������ӡ����洢����ά�������ӱ�
	input: 
				@templateID smallint,	--ģ��ID
				@quotaDetail xml,		--ʹ��xml�洢�ķ���Լ��������N'<root>
																	--	<row id="1">
																	--		<eTypeCode>05010549</eTypeCode>
																	--		<eTypeName>�����ӡ��</eTypeName>
																	--	</row>
																	--	<row id="2">
																	--		<eTypeCode>05010550</eTypeCode>
																	--		<eTypeName>ɨ����</eTypeName>
																	--	</row>
																	--	...
																	--</root>'
				@moneySectionDetail xml,--ʹ��xml�洢�Ľ��ֶ�����ָ�꣺N'<root>
																	--	<row id="1">
																	--		<startMoney>0</startMoney>
																	--		<endMoney>10000</endMoney>
																	--	</row>
																	--	<row id="2">
																	--		<startMoney>10000</startMoney>
																	--		<endMoney>20000</endMoney>
																	--	</row>
																	--	<row id="3">
																	--		<startMoney>20000</startMoney>
																	--		<endMoney>-1</endMoney>
																	--	</row>
																	--	...
																	--</root>'
				--ά����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µ�ͳ��ģ����������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-2-9
	UpdateDate: 
*/
create PROCEDURE addMoneySectionQuota
	@templateID smallint,	--ģ��ID
	@quotaDetail xml,		--ʹ��xml�洢�ķ���Լ��������N'<root>
														--	<row id="1">
														--		<eTypeCode>05010549</eTypeCode>
														--		<eTypeName>�����ӡ��</eTypeName>
														--	</row>
														--	<row id="2">
														--		<eTypeCode>05010550</eTypeCode>
														--		<eTypeName>ɨ����</eTypeName>
														--	</row>
														--	...
														--</root>'
	@moneySectionDetail xml,--ʹ��xml�洢�Ľ��ֶ�����ָ�꣺N'<root>
														--	<row id="1">
														--		<startMoney>0</startMoney>
														--		<endMoney>10000</endMoney>
														--	</row>
														--	<row id="2">
														--		<startMoney>10000</startMoney>
														--		<endMoney>20000</endMoney>
														--	</row>
														--	<row id="3">
														--		<startMoney>20000</startMoney>
														--		<endMoney>-1</endMoney>
														--	</row>
														--	...
														--</root>'
	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	--���²�����ֶλ���ָ�꣺
	begin tran
		delete subTotalTemplateQuota where templateID = @templateID
		delete moneySectionQuota where templateID = @templateID
		--���²����豸�������ָ�꣺
		if (cast(@quotaDetail as varchar(max))<>'' and cast(@quotaDetail as varchar(max))<>'<root></root>')
			insert subTotalTemplateQuota(templateID, rowNum, eTypeCode, eTypeName)
			select @templateID, cast(cast(T.x.query('data(./@id)') as varchar(8)) as smallint) rowNum, 
					cast(T.x.query('data(./eTypeCode)') as char(8)) eTypeCode, 
					cast(T.x.query('data(./eTypeName)') as nvarchar(30)) eTypeName
			from(select @quotaDetail.query('/root/row') Col1) A
					OUTER APPLY A.Col1.nodes('/row') AS T(x)
		--���²�����ֶλ���ָ�꣺
		insert moneySectionQuota(templateID, rowNum, startMoney, endMoney)
		select @templateID, cast(cast(T.x.query('data(./@id)') as varchar(8)) as smallint) rowNum, 
				cast(cast(T.x.query('data(./startMoney)') as varchar(14)) as money) startMoney, 
				cast(cast(T.x.query('data(./endMoney)') as varchar(14)) as money) endMoney
		from(select @moneySectionDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)

		update statisticTemplate
		set modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where templateID = @templateID
		set @Ret = 0
	commit tran
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���²���������ָ��', '�û�' + @modiManName 
												+ '���²����˵�['+ str(@templateID,6) +']��ͳ��ģ��Ľ��ֶλ���ָ�ꡣ')
GO
--���ԣ�
declare	@quotaDetail xml
set @quotaDetail = N''
declare	@moneySectionDetail xml
set @moneySectionDetail =N'<root>
						<row id="1">
							<startMoney>0</startMoney>
							<endMoney>10000</endMoney>
						</row>
						<row id="2">
							<startMoney>10000</startMoney>
							<endMoney>20000</endMoney>
						</row>
						<row id="3">
							<startMoney>20000</startMoney>
							<endMoney>-1</endMoney>
						</row>
						...
					</root>'
declare @updateTime smalldatetime
declare @Ret int
exec dbo.addMoneySectionQuota 1, @quotaDetail, @moneySectionDetail, '2010112301', @updateTime output, @Ret output
select @Ret

select * from subTotalTemplateQuota
select * from moneySectionQuota

drop PROCEDURE addAppDirQuota
/*
	name:		addAppDirQuota
	function:	7.���ʹ�÷���ͳ��ָ��
				ע�⣺����洢������ɾ��ȫ������ϸ���ݣ�Ȼ������ӡ�
	input: 
				@templateID smallint,	--ģ��ID
				@appDirDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
																	--	<row id="1">
																	--		<aCode>1</aCode>
																	--		<aName>��ѧ</aName>
																	--	</row>
																	--	<row id="2">
																	--		<aCode>2</aCode>
																	--		<aName>����</aName>
																	--	</row>
																	--	...
																	--</root>'
				--ά����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µ�ͳ��ģ����������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-3-10
	UpdateDate: 
*/
create PROCEDURE addAppDirQuota
	@templateID smallint,	--ģ��ID
	@appDirDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
													--	<row id="1">
													--		<aCode>1</aCode>
													--		<aName>��ѧ</aName>
													--	</row>
													--	<row id="2">
													--		<aCode>2</aCode>
													--		<aName>����</aName>
													--	</row>
													--	...
													--</root>'
	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	--���²���ʹ�÷���ָ�꣺
	begin tran
		delete appDirQuota where templateID = @templateID

		insert appDirQuota(templateID, rowNum, aCode, aName)
		select @templateID, cast(cast(T.x.query('data(./@id)') as varchar(8)) as smallint) rowNum, 
				cast(T.x.query('data(./aCode)') as char(8)) eTypeCode, 
				cast(T.x.query('data(./aName)') as nvarchar(30)) eTypeName
		from(select @appDirDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
		
		update statisticTemplate
		set modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where templateID = @templateID
		set @Ret = 0
	commit tran
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���²���ʹ�÷���ָ��', '�û�' + @modiManName 
												+ '���²����˵�['+ str(@templateID,6) +']��ͳ��ģ���ʹ�÷���ָ�ꡣ')
GO
--���ԣ�
declare	@quotaDetail xml
set @quotaDetail = N'<root>
						<row id="1">
							<aCode>1</aCode>
							<aName>��ѧ</aName>
						</row>
						<row id="2">
							<aCode>2</aCode>
							<aName>����</aName>
						</row>
					</root>'
declare @updateTime smalldatetime
declare @Ret int
exec dbo.addAppDirQuota 3, @quotaDetail, '2010112301', @updateTime output, @Ret output
select @Ret

select * from appDirQuota

drop PROCEDURE addFundSrcQuota
/*
	name:		addFundSrcQuota
	function:	8.��Ӿ�����Դͳ��ָ��
				ע�⣺����洢������ɾ��ȫ������ϸ���ݣ�Ȼ������ӡ�
	input: 
				@templateID smallint,	--ģ��ID
				@fundSrcDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
																	--	<row id="1">
																	--		<fCode>1</fCode>
																	--		<fName>������ҵ��</fName>
																	--	</row>
																	--	<row id="2">
																	--		<fCode>2</fCode>
																	--		<fName>����ר������</fName>
																	--	</row>
																	--	...
																	--</root>'
				--ά����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µ�ͳ��ģ����������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-3-10
	UpdateDate: 
*/
create PROCEDURE addFundSrcQuota
	@templateID smallint,	--ģ��ID
	@fundSrcDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<fCode>1</fCode>
														--		<fName>������ҵ��</fName>
														--	</row>
														--	<row id="2">
														--		<fCode>2</fCode>
														--		<fName>����ר������</fName>
														--	</row>
														--	...
														--</root>'
	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()

	--���²���ʹ�÷���ָ�꣺
	begin tran
		delete fundSrcQuota where templateID = @templateID

		insert fundSrcQuota(templateID, rowNum, fCode, fName)
		select @templateID, cast(cast(T.x.query('data(./@id)') as varchar(8)) as smallint) rowNum, 
				cast(T.x.query('data(./fCode)') as char(8)) eTypeCode, 
				cast(T.x.query('data(./fName)') as nvarchar(30)) eTypeName
		from(select @fundSrcDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
		
		update statisticTemplate
		set modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
		where templateID = @templateID
		set @Ret = 0
	commit tran
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '���²��뾭����Դָ��', '�û�' + @modiManName 
												+ '���²����˵�['+ str(@templateID,6) +']��ͳ��ģ��ľ�����Դָ�ꡣ')
GO
--���ԣ�
declare	@quotaDetail xml
set @quotaDetail = N'<root>
						<row id="1">
							<fCode>1</fCode>
							<fName>������ҵ��</fName>
						</row>
						<row id="2">
							<fCode>2</fCode>
							<fName>����ר������</fName>
						</row>
					</root>'
declare @updateTime smalldatetime
declare @Ret int
exec dbo.addFundSrcQuota 4, @quotaDetail, '2010112301', @updateTime output, @Ret output
select @Ret

select * from fundSrcQuota

drop PROCEDURE updateStatisticTemplate
/*
	name:		updateStatisticTemplate
	function:	9.����ͳ��ģ��
	input: 
				@templateID smallint,		--ģ��ID
				@templateType smallint,		--ģ�����0->�豸������ܣ�1->���ֶλ��ܣ�2->��λ����,3->ʹ�÷���4->������Դ
				@templateName nvarchar(30),	--ͳ��ģ������
				@templateDesc nvarchar(300),--ͳ��ģ�������
				
				--ͳ�ƵĲ�����
				--@statisticUnitType int,		--ͳ�Ʒ�Χ:0->ȫУ��1->Ժ��
				--@particleSize int,			--ͳ�Ƶ�λ�������ȣ�:0->ȫУ��1->Ժ����2->ʹ�õ�λ

				--ά����:
				@modiManID varchar(10) output,	--ά���ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@updateTime smalldatetime output,	--����ʱ��
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���µ�ͳ��ģ����������������2:���ظ���ģ�����ƣ�9��δ֪����
	author:		¬έ
	CreateDate:	2011-2-9
	UpdateDate: modi by lw 2011-2-19ɾ��ͳ�Ʒ�Χ�ͷ���������������
*/
create PROCEDURE updateStatisticTemplate
	@templateID smallint,		--ģ��ID
	@templateType smallint,		--ģ�����0->�豸������ܣ�1->���ֶλ��ܣ�2->��λ����,3->ʹ�÷���4->������Դ
	@templateName nvarchar(30),	--ͳ��ģ������
	@templateDesc nvarchar(300),--ͳ��ģ�������
	
	--ͳ�ƵĲ�����
	--@statisticUnitType int,		--ͳ�Ʒ�Χ:0->ȫУ��1->Ժ��
	--@particleSize int,			--ͳ�Ƶ�λ�������ȣ�:0->ȫУ��1->Ժ����2->ʹ�õ�λ

	--ά����:
	@modiManID varchar(10) output,	--ά���ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���

	@updateTime smalldatetime output,--����ʱ��
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--����Ƿ�����������
	declare @count int
	set @count = (select count(*) from statisticTemplate where templateName = @templateName and templateID <> @templateID)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update statisticTemplate
	set templateType = @templateType, templateName = @templateName, templateDesc = @templateDesc, 
		--ά�����:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where templateID = @templateID
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '����ͳ��ģ��', '�û�' + @modiManName 
												+ '�����˵�[' + str(@templateID,6) + ']��ͳ��ģ�塣')
GO
--���ԣ�
select * from statisticTemplate
update statisticTemplate
set lockManID=''
select lockManID from statisticTemplate where templateID = 16
select count(*) from statisticTemplate where templateName = 'Hello'

declare @modiManID varchar(10), @updateTime smalldatetime, @Ret	int
set @modiManID='201100001'
exec dbo.updateStatisticTemplate 16,0,'Hello world!','����һ������ģ��',0, 0, @modiManID output, @updateTime output, @Ret output
select @modiManID, @updateTime, @Ret

drop PROCEDURE delStatisticTemplate
/*
	name:		delStatisticTemplate
	function:	10.ɾ��ָ����ͳ��ģ��
	input: 
				@templateID smallint,			--ģ��ID
				@delManID varchar(10) output,	--ɾ���ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���ķ�����벻���ڣ�2��Ҫɾ���ķ��������������������9��δ֪����
	author:		¬έ
	CreateDate:	2011-2-9
	UpdateDate: 

*/
create PROCEDURE delStatisticTemplate
	@templateID smallint,			--ģ��ID
	@delManID varchar(10) output,	--ɾ���ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ����ͳ��ģ���Ƿ����
	declare @count as int
	set @count=(select count(*) from statisticTemplate where templateID = @templateID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from statisticTemplate where templateID = @templateID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete statisticTemplate where templateID = @templateID
	--����û��ɾ��������ͳ�����ݣ�����û�Ҫ������ɾ��������ͳ���������������ӣ�
	
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��ͳ��ģ��', '�û�' + @delManName
												+ 'ɾ���˵�[' + str(@templateID,6) + ']��ͳ��ģ�塣')
GO

select * from wd.dbo.totalcenter
--10.ͳ�����Ĺ��������������ŵ���ָ��ͳ��ģ��ͳ�Ƶ����ݣ�
drop table [totalCenter]
CREATE TABLE [dbo].[totalCenter](
	totalTabNum varchar(20) not null,	--������ͳ�Ʊ��ţ�ʹ�õ�1000�ź��뷢��������
	theTitle nvarchar(100) null,		--ͳ�Ʊ����
	templateID smallint NOT NULL,		--ģ��ID
	templateType smallint,				--ģ�����0->�豸������ܣ�1->���ֶλ��ܣ�2->��λ����,3->ʹ�÷���4->������Դ
	
	--ͳ��ʱ�����Ʋ�����
	startAcceptDate varchar(10) not null,	--���տ�ʼ����
	endAcceptDate varchar(10) not null,		--���ս�������
	startScrapDate varchar(10) not null,	--���Ͽ�ʼ����
	endScrapDate varchar(10) not null,		--���Ͻ�������

	--ͳ�ƿռ����Ʋ�����
	statisticUnitType int not null,		--ͳ�Ʒ�Χ:0->ȫУ��1->Ժ��
				--����Ϊ��֧���û���̬����ͳ�Ʒ�Χ��������ƣ�
	statisticUnitCode xml null,			--xml��ʽ��ŵ�ͳ�Ʒ�Χ���壺N'<root>
														--	<row id="1">
														--		<clgCode>027</clgCode>
														--		<clgName>����</clgName>
														--	</row>
														--	<row id="2">
														--		<clgCode>029</clgCode>
														--		<clgName>������ҵ������</clgName>
														--	</row>
														--	...
														--</root>'
	particleSize int not null,			--���飨ͳ�Ƶ�λ������ȣ�:0->ȫУ��1->Ժ����2->ʹ�õ�λ��Ϊ0ʱ��ʹ��ͳ�Ƶ�λ���顣
				--��������Ϊ�˱�֤��ʷ���ݵ���ȷ�Զ�����������ƣ�
	--��Ϊ��ϸ�������Ѿ������˵�λ����ϸ��Ϣ�����Էϳ�particleDesc�ֶ�
	--particleDesc xml null,				--xml��ʽ��ŵ�ͳ�Ƶ�λ������N'<root>
														--	<row id="1">
														--		<clgCode>027</clgCode>
														--		<clgName>����</clgName>
														--		<useUnit id="1">
														--			<uCode>02700</uCode>
														--			<uName>����</uName>
														--		</useUnit>
														--		<useUnit id="2">
														--			<uCode>02701</uCode>
														--			<uName>���ʰ�</uName>
														--		</useUnit>
														--		<useUnit id="3">
														--			<uCode>02702</uCode>
														--			<uName>���ʴ����</uName>
														--		</useUnit>
														--		<useUnit id="4">
														--			<uCode>02703</uCode>
														--			<uName>ѧ�������������</uName>
														--		</useUnit>
														--	</row>
														--	<row id="2">
														--		<clgCode>029</clgCode>
														--		<clgName>������ҵ������</clgName>
														--		<useUnit id="1">
														--			<uCode>02900</uCode>
														--			<uName>������ҵ������</uName>
														--		</useUnit>
														--	</row>
														--	...
														--</root>'

	--ͳ��ָ�꣺����Ϊ��֧���û���̬�޸�ͳ��ָ����������!
	quotaDetail xml null,		--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<eTypeCode>05010549</eTypeCode>
														--		<eTypeName>�����ӡ��</eTypeName>
														--	</row>
														--	<row id="2">
														--		<eTypeCode>05010550</eTypeCode>
														--		<eTypeName>ɨ����</eTypeName>
														--	</row>
														--	...
														--</root>'
	moneySectionDetail xml null,--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<startMoney>0</startMoney>
														--		<endMoney>10000</endMoney>
														--	</row>
														--	<row id="2">
														--		<startMoney>10000</startMoney>
														--		<endMoney>20000</endMoney>
														--	</row>
														--	<row id="3">
														--		<startMoney>20000</startMoney>
														--		<endMoney>-1</endMoney>
														--	</row>
														--	...
														--</root>'
	--���ݱϴ���Ҫ������ʹ�÷���;�����Դ����ģ�壺
	appDirDetail xml null,		--ʹ��xml�洢��ָ�꣺N'<root>
													--	<row id="1">
													--		<aCode>1</aCode>
													--		<aName>��ѧ</aName>
													--	</row>
													--	<row id="2">
													--		<aCode>2</aCode>
													--		<aName>����</aName>
													--	</row>
													--	...
													--</root>'
	fundSrcDetail xml null,		--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<fCode>1</fCode>
														--		<fName>������ҵ��</fName>
														--	</row>
														--	<row id="2">
														--		<fCode>2</fCode>
														--		<fName>����ר������</fName>
														--	</row>
														--	...
														--</root>'
	
	makeDate smalldatetime null,		--ͳ������
	makerID varchar(10) null,			--ͳ���˹���
	maker varchar(30) null,				--ͳ����
 CONSTRAINT [PK_totalCenter] PRIMARY KEY CLUSTERED 
(
	[totalTabNum] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


--11.�������ͳ�Ʊ�
drop table subTotal
CREATE TABLE [dbo].[subTotal](
	totalTabNum varchar(20) not null,	--����/�����ͳ�Ʊ��ţ�ʹ�õ�1000�ź��뷢��������
	ID4Row int not null,				--�������к� modi by lw 2011-12-20 Ϊ��֧�������򣬸���������ԭ����Ϊ��RowID
	clgCode char(3) default(''),	--ѧԺ����
	clgName nvarchar(30) default(''),--Ժ������	
	uCode varchar(8) default(''),	--ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	uName nvarchar(30) default(''),	--ʹ�õ�λ����	
	rowNum int,						--ָ��ţ��豸������
	eTypeCode char(8) not null,		--�����ţ��̣�
	eTypeName nvarchar(30) not null,--�������ƣ�ע������ķ������ƿ������������е����Ʋ�һ�£���
	totalNum int not null,			--��������λ��̨��
	totalMoney numeric(18,2) not null,		--����λ��Ԫ
 CONSTRAINT [PK_subTotal] PRIMARY KEY CLUSTERED 
(
	[totalTabNum] ASC,
	[ID4Row] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--�����
ALTER TABLE [dbo].[subTotal] WITH CHECK ADD CONSTRAINT [FK_subTotal_totalCenter] FOREIGN KEY([totalTabNum])
REFERENCES [dbo].[totalCenter] ([totalTabNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[subTotal] CHECK CONSTRAINT [FK_subTotal_totalCenter] 
GO


--12.���ֶ�ͳ�Ʊ�
drop table moneySectionTotal
CREATE TABLE [dbo].[moneySectionTotal](
	totalTabNum varchar(20) not null,	--����/�����ͳ�Ʊ��ţ�ʹ�õ�1000�ź��뷢��������
	ID4Row int not null,				--�������к� modi by lw 2011-12-20 Ϊ��֧�������򣬸���������ԭ����Ϊ��RowID
	clgCode char(3) default(''),	--ѧԺ����
	clgName nvarchar(30) default(''),--Ժ������	
	uCode varchar(8) default(''),	--ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	uName nvarchar(30) default(''),	--ʹ�õ�λ����	
	rowNum int,						--ָ��ţ����ֶα��
	startMoney money null,			--�����
	endMoney money null,			--������-1��ʾ�����
	totalNum int not null,			--��������λ��̨��
	totalMoney numeric(18,2) not null,		--����λ��Ԫ
 CONSTRAINT [PK_moneySectionTotal] PRIMARY KEY CLUSTERED 
(
	[totalTabNum] ASC,
	[ID4Row] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--�����
ALTER TABLE [dbo].[moneySectionTotal] WITH CHECK ADD CONSTRAINT [FK_moneySectionTotal_totalCenter] FOREIGN KEY([totalTabNum])
REFERENCES [dbo].[totalCenter] ([totalTabNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[moneySectionTotal] CHECK CONSTRAINT [FK_moneySectionTotal_totalCenter]
GO

--13.��λ����ͳ�Ʊ�
drop table unitGroupTotal
CREATE TABLE [dbo].[unitGroupTotal](
	totalTabNum varchar(20) not null,	--����/�����ͳ�Ʊ��ţ�ʹ�õ�1000�ź��뷢��������
	ID4Row int not null,				--�������к� modi by lw 2011-12-20 Ϊ��֧�������򣬸���������ԭ����Ϊ��RowID
	clgCode char(3) default(''),	--ѧԺ����
	clgName nvarchar(30) default(''),--Ժ������	
	uCode varchar(8) default(''),	--ʹ�õ�λ����,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	uName nvarchar(30) default(''),	--ʹ�õ�λ����	
	totalNum int not null,			--��������λ��̨��
	totalMoney numeric(18,2) not null,		--����λ��Ԫ
 CONSTRAINT [PK_unitGroupTotal] PRIMARY KEY CLUSTERED 
(
	[totalTabNum] ASC,
	[ID4Row] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--�����
ALTER TABLE [dbo].[unitGroupTotal] WITH CHECK ADD CONSTRAINT [FK_unitGroupTotal_totalCenter] FOREIGN KEY([totalTabNum])
REFERENCES [dbo].[totalCenter] ([totalTabNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[unitGroupTotal] CHECK CONSTRAINT [FK_unitGroupTotal_totalCenter] 
GO

--14.ʹ�÷������ͳ�Ʊ�
drop table appDirTotal
CREATE TABLE [dbo].[appDirTotal](
	totalTabNum varchar(20) not null,	--����/�����ͳ�Ʊ��ţ�ʹ�õ�1000�ź��뷢��������
	ID4Row int not null,				--�������к� modi by lw 2011-12-20 Ϊ��֧�������򣬸���������ԭ����Ϊ��RowID
	clgCode char(3) default(''),	--ѧԺ����
	clgName nvarchar(30) default(''),--Ժ������	
	uCode varchar(8) default(''),	--ʹ�õ�λ����
	uName nvarchar(30) default(''),	--ʹ�õ�λ����	
	rowNum int,						--ָ��ţ��豸������
	aCode char(2) not null,			--ʹ�÷������
	aName nvarchar(20) not null,	--ʹ�÷�������	
	totalNum int not null,			--��������λ��̨��
	totalMoney numeric(18,2) not null,		--����λ��Ԫ
 CONSTRAINT [PK_appDirTotal] PRIMARY KEY CLUSTERED 
(
	[totalTabNum] ASC,
	[ID4Row] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--�����
ALTER TABLE [dbo].[appDirTotal] WITH CHECK ADD CONSTRAINT [FK_appDirTotal_totalCenter] FOREIGN KEY([totalTabNum])
REFERENCES [dbo].[totalCenter] ([totalTabNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[appDirTotal] CHECK CONSTRAINT [FK_appDirTotal_totalCenter] 
GO

--15.������Դ����ͳ�Ʊ�
drop table fundSrcTotal
CREATE TABLE [dbo].[fundSrcTotal](
	totalTabNum varchar(20) not null,	--����/�����ͳ�Ʊ��ţ�ʹ�õ�1000�ź��뷢��������
	ID4Row int not null,				--�������к� modi by lw 2011-12-20 Ϊ��֧�������򣬸���������ԭ����Ϊ��RowID
	clgCode char(3) default(''),	--ѧԺ����
	clgName nvarchar(30) default(''),--Ժ������	
	uCode varchar(8) default(''),	--ʹ�õ�λ����
	uName nvarchar(30) default(''),	--ʹ�õ�λ����	
	rowNum int,						--ָ��ţ��豸������
	fCode char(2) not null,			--������Դ����
	fName nvarchar(20) not null,	--������Դ����	
	totalNum int not null,			--��������λ��̨��
	totalMoney numeric(18,2) not null,		--����λ��Ԫ
 CONSTRAINT [PK_fundSrcTotal] PRIMARY KEY CLUSTERED 
(
	[totalTabNum] ASC,
	[ID4Row] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO
--�����
ALTER TABLE [dbo].[fundSrcTotal] WITH CHECK ADD CONSTRAINT [FK_fundSrcTotal_totalCenter] FOREIGN KEY([totalTabNum])
REFERENCES [dbo].[totalCenter] ([totalTabNum])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[fundSrcTotal] CHECK CONSTRAINT [FK_fundSrcTotal_totalCenter] 
GO

drop PROCEDURE statisticPro
/*
	name:		statisticPro
	function:	11.��ģ��ͳ��
				ע�⣺�ô洢���̲���ʹ��ͳ��ģ����е����ݣ���ʹ���û���̬�����ָ��ֵ������Ϊ��֧���û���̬�޸�ͳ��ָ�꣡
	input: 
				@templateID smallint,		--ͳ��ģ��ID
				@templateType smallint,		--ģ�����0->�豸������ܣ�1->���ֶλ��ܣ�2->��λ����,3->ʹ�÷���4->������Դ
				
				--ͳ��ʱ�����Ʋ�����
				@startAcceptDate smalldatetime,	--���տ�ʼ����
				@endAcceptDate smalldatetime,	--���ս�������
				@startScrapDate smalldatetime,	--���Ͽ�ʼ����
				@endScrapDate smalldatetime,	--���Ͻ�������

				--ͳ�ƿռ����Ʋ�����
				@statisticUnitType int,			--ͳ�Ʒ�Χ:0->ȫУ��1->Ժ��
				@statisticUnitCode xml,			--xml��ʽ��ŵ�ͳ�Ʒ�Χ���壺N'<root>
																	--	<row id="1">
																	--		<clgCode>027</clgCode>
																	--		<clgName>����</clgName>
																	--	</row>
																	--	<row id="2">
																	--		<clgCode>029</clgCode>
																	--		<clgName>������ҵ������</clgName>
																	--	</row>
																	--	...
																	--</root>'
				@particleSize int,				--ͳ�Ƶ�λ�������ȣ�:0->ȫУ��1->Ժ����2->ʹ�õ�λ��Ϊ0ʱ��ʹ��ͳ�Ƶ�λ���顣

				--ͳ��ָ�꣺����Ϊ��֧���û���̬�޸�ͳ��ָ����������!
				@quotaDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
																	--	<row id="1">
																	--		<eTypeCode>05010549</eTypeCode>
																	--		<eTypeName>�����ӡ��</eTypeName>
																	--	</row>
																	--	<row id="2">
																	--		<eTypeCode>05010550</eTypeCode>
																	--		<eTypeName>ɨ����</eTypeName>
																	--	</row>
																	--	...
																	--</root>'
				@moneySectionDetail xml,--ʹ��xml�洢��ָ�꣺N'<root>
																	--	<row id="1">
																	--		<startMoney>0</startMoney>
																	--		<endMoney>10000</endMoney>
																	--	</row>
																	--	<row id="2">
																	--		<startMoney>10000</startMoney>
																	--		<endMoney>20000</endMoney>
																	--	</row>
																	--	<row id="3">
																	--		<startMoney>20000</startMoney>
																	--		<endMoney>-1</endMoney>
																	--	</row>
																	--	...
																	--</root>'
				@appDirDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
																--	<row id="1">
																--		<aCode>1</aCode>
																--		<aName>��ѧ</aName>
																--	</row>
																--	<row id="2">
																--		<aCode>2</aCode>
																--		<aName>����</aName>
																--	</row>
																--	...
																--</root>'
				@fundSrcDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
																	--	<row id="1">
																	--		<fCode>1</fCode>
																	--		<fName>������ҵ��</fName>
																	--	</row>
																	--	<row id="2">
																	--		<fCode>2</fCode>
																	--		<fName>����ר������</fName>
																	--	</row>
																	--	...
																	--</root>'
				--�������ҳ������
				@pageSize int,      --ÿҳ����   
				@page     int,		--ָ��ҳ   
	output:		
				@rows  int OUTPUT,	--������
				@pages int OUTPUT	--��ҳ��   
				--del by lw 2011-2-15,�µ�ͳ�Ʊ���Ҫ�ò�����
				--ͳ�Ƶ�λ�������ȣ�������ע�⣺����һ��������������Ҫ�Ǳ�֤��ʷ���ݵ���ȷ�ԣ�
				--@particleDesc xml output				--xml��ʽ��ŵ�ͳ�Ƶ�λ������N'<root>
																	--	<row id="1">
																	--		<clgCode>027</clgCode>
																	--		<clgName>����</clgName>
																	--		<useUnit id="1">
																	--			<uCode>02700</uCode>
																	--			<uName>����</uName>
																	--		</useUnit>
																	--		<useUnit id="2">
																	--			<uCode>02701</uCode>
																	--			<uName>���ʰ�</uName>
																	--		</useUnit>
																	--		<useUnit id="3">
																	--			<uCode>02702</uCode>
																	--			<uName>���ʴ����</uName>
																	--		</useUnit>
																	--		<useUnit id="4">
																	--			<uCode>02703</uCode>
																	--			<uName>ѧ�������������</uName>
																	--		</useUnit>
																	--	</row>
																	--	<row id="2">
																	--		<clgCode>029</clgCode>
																	--		<clgName>������ҵ������</clgName>
																	--		<useUnit id="1">
																	--			<uCode>02900</uCode>
																	--			<uName>������ҵ������</uName>
																	--		</useUnit>
																	--	</row>
																	--	...
																	--</root>'
				ʹ�ý��������ͳ��ָ���ָ��ֵ
	author:		¬έ
	CreateDate:	2011-2-10
	UpdateDate: modi by lw 2011-2-14���ݱϴ����������һ����λ����ͳ��ģ�壡���ӽ����ʹ�õ�λ����֧�֣�֧�ֿ����ݷ�����ʾ��
				modi by lw 2011-2-15���ӷ�ҳ�������޸�Ϊ��ҳ��ѯ�ķ�ʽ
				modi by lw 2011-2-15Ϊ�˱�֤���������б����ҳ�������洢���̷ֲ��һ��������������Ӵ洢���̣�
									ͬʱ�µ�ͳ�Ʊ�����в���ʹ��@particleDesc��������ֹ�ô���������
				modi by lw 2011-3-10���ݱϴ�Ҫ������ʹ�÷���;�����Դ����ģ���ͳ��
*/
create PROCEDURE statisticPro
	@templateID smallint,		--ͳ��ģ��ID
	@templateType smallint,		--ģ�����0->�豸������ܣ�1->���ֶλ��ܣ�2->��λ����,3->ʹ�÷���4->������Դ
	
	--ͳ��ʱ�����Ʋ�����
	@startAcceptDate varchar(10),--���տ�ʼ����:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"
	@endAcceptDate varchar(10),	--���ս�������:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"
	@startScrapDate varchar(10),--���Ͽ�ʼ����:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"
	@endScrapDate varchar(10),	--���Ͻ�������:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"

	--ͳ�ƿռ����Ʋ�����
	@statisticUnitType int,			--ͳ�Ʒ�Χ:0->ȫУ��1->Ժ��
	@statisticUnitCode xml,			--xml��ʽ��ŵ�ͳ�Ʒ�Χ���壺N'<root>
														--	<row id="1">
														--		<clgCode>027</clgCode>
														--		<clgName>����</clgName>
														--	</row>
														--	<row id="2">
														--		<clgCode>029</clgCode>
														--		<clgName>������ҵ������</clgName>
														--	</row>
														--	...
														--</root>'
	@particleSize int,				--ͳ�Ƶ�λ�������ȣ�:0->ȫУ��1->Ժ����2->ʹ�õ�λ��Ϊ0ʱ��ʹ��ͳ�Ƶ�λ���顣

	--ͳ��ָ�꣺����Ϊ��֧���û���̬�޸�ͳ��ָ����������!
	@quotaDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<eTypeCode>05010549</eTypeCode>
														--		<eTypeName>�����ӡ��</eTypeName>
														--	</row>
														--	<row id="2">
														--		<eTypeCode>05010550</eTypeCode>
														--		<eTypeName>ɨ����</eTypeName>
														--	</row>
														--	...
														--</root>'
	@moneySectionDetail xml,--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<startMoney>0</startMoney>
														--		<endMoney>10000</endMoney>
														--	</row>
														--	<row id="2">
														--		<startMoney>10000</startMoney>
														--		<endMoney>20000</endMoney>
														--	</row>
														--	<row id="3">
														--		<startMoney>20000</startMoney>
														--		<endMoney>-1</endMoney>
														--	</row>
														--	...
														--</root>'
	@appDirDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
													--	<row id="1">
													--		<aCode>1</aCode>
													--		<aName>��ѧ</aName>
													--	</row>
													--	<row id="2">
													--		<aCode>2</aCode>
													--		<aName>����</aName>
													--	</row>
													--	...
													--</root>'
	@fundSrcDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<fCode>1</fCode>
														--		<fName>������ҵ��</fName>
														--	</row>
														--	<row id="2">
														--		<fCode>2</fCode>
														--		<fName>����ר������</fName>
														--	</row>
														--	...
														--</root>'
	--�������ҳ������
    @pageSize int,      --ÿҳ����   
    @page     int,		--ָ��ҳ   
    @rows  int OUTPUT,	--������
    @pages int OUTPUT	--��ҳ��   
    
    --del by lw 2011-2-15,�µ�ͳ�Ʊ���Ҫ�ò�����
	--ͳ�Ƶ�λ�������ȣ�������ע�⣺����һ��������������Ҫ�Ǳ�֤��ʷ���ݵ���ȷ�ԣ�
	--@particleDesc xml output				--xml��ʽ��ŵ�ͳ�Ƶ�λ������N'<root>
														--	<row id="1">
														--		<clgCode>027</clgCode>
														--		<clgName>����</clgName>
														--		<useUnit id="1">
														--			<uCode>02700</uCode>
														--			<uName>����</uName>
														--		</useUnit>
														--		<useUnit id="2">
														--			<uCode>02701</uCode>
														--			<uName>���ʰ�</uName>
														--		</useUnit>
														--		<useUnit id="3">
														--			<uCode>02702</uCode>
														--			<uName>���ʴ����</uName>
														--		</useUnit>
														--		<useUnit id="4">
														--			<uCode>02703</uCode>
														--			<uName>ѧ�������������</uName>
														--		</useUnit>
														--	</row>
														--	<row id="2">
														--		<clgCode>029</clgCode>
														--		<clgName>������ҵ������</clgName>
														--		<useUnit id="1">
														--			<uCode>02900</uCode>
														--			<uName>������ҵ������</uName>
														--		</useUnit>
														--	</row>
														--	...
														--</root>'
	WITH ENCRYPTION 
AS
	if not (select object_id('Tempdb..#totalResult')) is null 
		drop table #totalResult
	create table #totalResult(RowID int not null)
	ALTER TABLE [dbo].[#totalResult] ADD  CONSTRAINT [PK_totalResult] PRIMARY KEY CLUSTERED 
	(
		[RowID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	
	--����ģ������첻ͬ����ʱ������makeTotal�Ľ������
	if @templateType = 0	--0->�豸�������
	begin
		if @particleSize = 0	--������
			alter table #totalResult add eTypeCode char(8), eTypeName nvarchar(30), totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
										rowNum int, eTypeCode char(8), eTypeName nvarchar(30), totalNum int, totalMoney  numeric(18,2)
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
										rowNum int, eTypeCode char(8), eTypeName nvarchar(30), totalNum int, totalMoney  numeric(18,2)
	end
	else if @templateType = 1	--1->���ֶλ���
	begin
		if @particleSize = 0	--������
			alter table #totalResult add startMoney money, endMoney money, totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
										rowNum int, startMoney money, endMoney money, totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
										rowNum int, startMoney money, endMoney money, totalNum int, totalMoney numeric(18,2)
	end
	else if @templateType = 2	--2->��λ����
	begin
		if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
										totalNum int, totalMoney  numeric(18,2)
	end
	else if @templateType = 3	--3->ʹ�÷������
	begin
		if @particleSize = 0	--������
			alter table #totalResult add aCode char(2), aName nvarchar(20), totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
										rowNum int, aCode char(2), aName nvarchar(20), totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
										rowNum int, aCode char(2), aName nvarchar(20), totalNum int, totalMoney numeric(18,2)
	end
	else if @templateType = 4	--4->������Դ����
	begin
		if @particleSize = 0	--������
			alter table #totalResult add fCode char(2), fName nvarchar(20), totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
										rowNum int, fCode char(2), fName nvarchar(20), totalNum int, totalMoney numeric(18,2)
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
										rowNum int, fCode char(2), fName nvarchar(20), totalNum int, totalMoney numeric(18,2)
	end

	insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
									@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
									@appDirDetail, @fundSrcDetail

	--׼����ҳ��
	declare @topRows as varchar(10)
	set @topRows = ltrim(str((@page+1) * @pageSize, 10))
	declare @sql as nvarchar(max)
	set @sql = N'select ' + 'top '+ @topRows + ' *'
		+ ' from #totalResult'
		+ ' where RowID BETWEEN ' + str(@page * @pageSize + 1 ,10) + ' AND ' + @topRows
		+ ' order by RowID'
	
	set @rows = (select count(*) from #totalResult)	--������
	set @pages = (@rows + @pageSize -1) / @pageSize	--��ҳ��

--print @sql
	EXEC(@sql)   
	drop table #totalResult
GO
--���ԣ�
declare @quotaDetail xml
set @quotaDetail = N'<root>
				</root>'
declare @moneySectionDetail xml
set @moneySectionDetail = N'<root>
					<row id="1">
						<startMoney>0</startMoney>
						<endMoney>10000</endMoney>
					</row>
					<row id="2">
						<startMoney>10000</startMoney>
						<endMoney>20000</endMoney>
					</row>
					<row id="3">
						<startMoney>20000</startMoney>
						<endMoney>-1</endMoney>
					</row>
				</root>'
declare @appDirDetail xml
set @appDirDetail =N'<root>
						<row id="1">
							<aCode>2</aCode>
							<aName>����</aName>
						</row>
						<row id="2">
							<aCode>1</aCode>
							<aName>��ѧ</aName>
						</row>
					</root>'
declare @fundSrcDetail xml
set @fundSrcDetail =N'<root>
						<row id="1">
							<fCode>1</fCode>
							<fName>������ҵ��</fName>
						</row>
						<row id="2">
							<fCode>2</fCode>
							<fName>����ר������</fName>
						</row>
					</root>'
declare @particleDesc xml
declare @rows int, @pages int
exec dbo.statisticPro 31, 4, '2009-01-01', '', '2011-01-01', '', 0, null, 2, @quotaDetail, @moneySectionDetail, 
		@appDirDetail, @fundSrcDetail, 20, 0, @rows output, @pages output
select @rows, @pages

drop PROCEDURE makeTotal
/*
	name:		makeTotal
	function:	12.����ͳ������������ͳ�ƽ����
				���洢������statisticPro�洢���̷ֲ������
				ע�⣺�ô洢���̲���ʹ��ͳ��ģ����е����ݣ���ʹ���û���̬�����ָ��ֵ������Ϊ��֧���û���̬�޸�ͳ��ָ�꣡
					����һ���ڲ��洢���̣�����Ҫ��װ�������У�
	input: 
				@templateType smallint,		--ģ�����0->�豸������ܣ�1->���ֶλ��ܣ�2->��λ����,3->ʹ�÷���4->������Դ
				
				--ͳ��ʱ�����Ʋ�����
				@startAcceptDate smalldatetime,	--���տ�ʼ����
				@endAcceptDate smalldatetime,	--���ս�������
				@startScrapDate smalldatetime,	--���Ͽ�ʼ����
				@endScrapDate smalldatetime,	--���Ͻ�������

				--ͳ�ƿռ����Ʋ�����
				@statisticUnitType int,			--ͳ�Ʒ�Χ:0->ȫУ��1->Ժ��
				@statisticUnitCode xml,			--xml��ʽ��ŵ�ͳ�Ʒ�Χ���壺N'<root>
																	--	<row id="1">
																	--		<clgCode>027</clgCode>
																	--		<clgName>����</clgName>
																	--	</row>
																	--	<row id="2">
																	--		<clgCode>029</clgCode>
																	--		<clgName>������ҵ������</clgName>
																	--	</row>
																	--	...
																	--</root>'
				@particleSize int,				--ͳ�Ƶ�λ�������ȣ�:0->ȫУ��1->Ժ����2->ʹ�õ�λ��Ϊ0ʱ��ʹ��ͳ�Ƶ�λ���顣

				--ͳ��ָ�꣺����Ϊ��֧���û���̬�޸�ͳ��ָ����������!
				@quotaDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
																	--	<row id="1">
																	--		<eTypeCode>05010549</eTypeCode>
																	--		<eTypeName>�����ӡ��</eTypeName>
																	--	</row>
																	--	<row id="2">
																	--		<eTypeCode>05010550</eTypeCode>
																	--		<eTypeName>ɨ����</eTypeName>
																	--	</row>
																	--	...
																	--</root>'
				@moneySectionDetail xml,--ʹ��xml�洢��ָ�꣺N'<root>
																	--	<row id="1">
																	--		<startMoney>0</startMoney>
																	--		<endMoney>10000</endMoney>
																	--	</row>
																	--	<row id="2">
																	--		<startMoney>10000</startMoney>
																	--		<endMoney>20000</endMoney>
																	--	</row>
																	--	<row id="3">
																	--		<startMoney>20000</startMoney>
																	--		<endMoney>-1</endMoney>
																	--	</row>
																	--	...
																	--</root>'
				@appDirDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
																--	<row id="1">
																--		<aCode>1</aCode>
																--		<aName>��ѧ</aName>
																--	</row>
																--	<row id="2">
																--		<aCode>2</aCode>
																--		<aName>����</aName>
																--	</row>
																--	...
																--</root>'
				@fundSrcDetail xml		--ʹ��xml�洢��ָ�꣺N'<root>
																	--	<row id="1">
																	--		<fCode>1</fCode>
																	--		<fName>������ҵ��</fName>
																	--	</row>
																	--	<row id="2">
																	--		<fCode>2</fCode>
																	--		<fName>����ר������</fName>
																	--	</row>
																	--	...
																	--</root>'
	output:		
				ʹ�ý��������ͳ��ָ���ָ��ֵ
	author:		¬έ
	CreateDate:	2011-2-15
	UpdateDate:modi by lw 2011-3-10���ݱϴ�Ҫ������ʹ�÷���;�����Դ����ģ���ͳ��
*/
create PROCEDURE makeTotal
	@templateType smallint,		--ģ�����0->�豸������ܣ�1->���ֶλ��ܣ�2->��λ����,3->ʹ�÷���4->������Դ
	
	--ͳ��ʱ�����Ʋ�����
	@startAcceptDate varchar(10),--���տ�ʼ����:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"
	@endAcceptDate varchar(10),	--���ս�������:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"
	@startScrapDate varchar(10),--���Ͽ�ʼ����:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"
	@endScrapDate varchar(10),	--���Ͻ�������:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"

	--ͳ�ƿռ����Ʋ�����
	@statisticUnitType int,			--ͳ�Ʒ�Χ:0->ȫУ��1->Ժ��
	@statisticUnitCode xml,			--xml��ʽ��ŵ�ͳ�Ʒ�Χ���壺N'<root>
														--	<row id="1">
														--		<clgCode>027</clgCode>
														--		<clgName>����</clgName>
														--	</row>
														--	<row id="2">
														--		<clgCode>029</clgCode>
														--		<clgName>������ҵ������</clgName>
														--	</row>
														--	...
														--</root>'
	@particleSize int,				--ͳ�Ƶ�λ�������ȣ�:0->ȫУ��1->Ժ����2->ʹ�õ�λ��Ϊ0ʱ��ʹ��ͳ�Ƶ�λ���顣

	--ͳ��ָ�꣺����Ϊ��֧���û���̬�޸�ͳ��ָ����������!
	@quotaDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<eTypeCode>05010549</eTypeCode>
														--		<eTypeName>�����ӡ��</eTypeName>
														--	</row>
														--	<row id="2">
														--		<eTypeCode>05010550</eTypeCode>
														--		<eTypeName>ɨ����</eTypeName>
														--	</row>
														--	...
														--</root>'
	@moneySectionDetail xml,--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<startMoney>0</startMoney>
														--		<endMoney>10000</endMoney>
														--	</row>
														--	<row id="2">
														--		<startMoney>10000</startMoney>
														--		<endMoney>20000</endMoney>
														--	</row>
														--	<row id="3">
														--		<startMoney>20000</startMoney>
														--		<endMoney>-1</endMoney>
														--	</row>
														--	...
														--</root>'
	@appDirDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
													--	<row id="1">
													--		<aCode>1</aCode>
													--		<aName>��ѧ</aName>
													--	</row>
													--	<row id="2">
													--		<aCode>2</aCode>
													--		<aName>����</aName>
													--	</row>
													--	...
													--</root>'
	@fundSrcDetail xml		--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<fCode>1</fCode>
														--		<fName>������ҵ��</fName>
														--	</row>
														--	<row id="2">
														--		<fCode>2</fCode>
														--		<fName>����ר������</fName>
														--	</row>
														--	...
														--</root>'
	WITH ENCRYPTION 
AS
	declare @strWhere nvarchar(1000), @groupCol nvarchar(max)
	set @strWhere = N''
	set @groupCol = N''
	--����ʱ��Լ��������
	if @startAcceptDate <> ''
		set @strWhere = @strWhere + ' and e.acceptDate >=' + char(39) + @startAcceptDate + char(39)
	if @endAcceptDate = ''
		set @endAcceptDate = convert(varchar(10),dateadd(day,1,getdate()),120)
	set @strWhere = @strWhere + ' and e.acceptDate <' + char(39) + @endAcceptDate + char(39)

	if @startScrapDate = ''
		set @startScrapDate = convert(varchar(10), dateadd(day,1,getdate()), 120)	--Ϊ�˱�֤��ʷ�����ؽ�����ȷ�ԣ�������ϵ�������
	set @strWhere = @strWhere + ' and (e.scrapDate is null or e.scrapDate >=' + char(39) + @startScrapDate + char(39) + ')'

	if @endScrapDate <> ''
	begin
		set @strWhere = @strWhere + ' and e.scrapDate <' + char(39) + @endScrapDate + char(39)
	end

	--����ռ�����Լ��������
	if @statisticUnitType = 1	--ͳ�Ʒ�Χ:0->ȫУ��1->Ժ��
	begin
		if not (select object_id('Tempdb..#tempUnit')) is null 
			drop table #tempUnit
		create table #tempUnit(clgCode char(3))

		insert #tempUnit(clgCode)
		select cast(T.x.query('data(./clgCode)') as char(3)) 
		from(select @statisticUnitCode.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
		
		set @strWhere = @strWhere + ' and e.clgCode in (select clgCode from #tempUnit)'
	end

	if @strWhere <> N''
		set @strWhere = substring(@strWhere, 5, len(@strWhere) - 4)
		
	--�������������
	if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
		set @groupCol = N' clgCode,'
	if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
		set @groupCol = N' clgCode, uCode, '

	--�����豸�����б�
	if not (select object_id('Tempdb..#tempSubTotal')) is null 
		drop table #tempSubTotal
	create table #tempSubTotal(rowNum int, eTypeCode char(8), eTypeName nvarchar(30))

	declare @strQuotaDetail as varchar(max)
	set @strQuotaDetail = cast(@quotaDetail as varchar(max))
	if @quotaDetail is not null and @strQuotaDetail <> '' and @strQuotaDetail <> '<root></root>' and @strQuotaDetail <> '<root/>'
	begin
		insert #tempSubTotal(rowNum, eTypeCode, eTypeName)
		select cast(cast(T.x.query('data(./@id)') as char(8)) as int), cast(T.x.query('data(./eTypeCode)') as char(8)), cast(T.x.query('data(./eTypeName)') as nvarchar(30)) 
		from(select @quotaDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)
	end
	
	--����ͳ�Ƶ�ָ�����ͣ���ʼͳ�ƣ�
	declare @sql as nvarchar(max)
	if @templateType = 0	--0->�豸�������
	begin
		set @sql = N'
			--ָ����ȷ����ͳ�ƣ�
			select ' + @groupCol + ' eTypeCode, count(*) totalNum, sum(totalAmount) totalMoney
			from equipmentList e
			where '+ @strWhere +' and eTypeCode in (select eTypeCode from #tempSubTotal where right(eTypeCode,2)<>' + char(39) + '00' + char(39) + ')
			group by ' + @groupCol + ' eTypeCode
			union all
			--���ͳ�ƣ�С��
			select ' + @groupCol + ' left(eTypeCode,6) + ' + char(39) + '00' + char(39) + ', count(*), sum(totalAmount)
			from equipmentList e
			where '+ @strWhere +' and left(eTypeCode,6) in (select left(eTypeCode,6) from #tempSubTotal where right(eTypeCode,4)<>' + char(39) + '0000' + char(39) + ' and right(eTypeCode,2)=' + char(39) + '00' + char(39) + ')
			group by ' + @groupCol + ' left(eTypeCode,6) + ' + char(39) + '00' + char(39) + '
			union all
			--���ͳ�ƣ�����
			select ' + @groupCol + ' left(eTypeCode,4) + ' + char(39) + '0000' + char(39) + ', count(*), sum(totalAmount)
			from equipmentList e
			where '+ @strWhere +' and left(eTypeCode,4) in (select left(eTypeCode,4) from #tempSubTotal where right(eTypeCode,6)<>' + char(39) + '000000' + char(39) + ' and right(eTypeCode,4)=' + char(39) + '0000' + char(39) + ')
			group by ' + @groupCol + ' left(eTypeCode,4) + ' + char(39) + '0000' + char(39) + '
			union all
			--���ͳ�ƣ�����
			select ' + @groupCol + ' left(eTypeCode,2) + ' + char(39) + '000000' + char(39) + ', count(*), sum(totalAmount)
			from equipmentList e
			where '+ @strWhere +' and left(eTypeCode,2) in (select left(eTypeCode,2) from #tempSubTotal where right(eTypeCode,6)=' + char(39) + '000000' + char(39) + ')
			group by ' + @groupCol + ' left(eTypeCode,2) + ' + char(39) + '000000' + char(39)
		if @particleSize = 0	--������
			set @sql = N'select ROW_NUMBER() OVER(order by s.rowNum) as RowID, s.eTypeCode, s.eTypeName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from #tempSubTotal s left outer join (' + @sql + ') t on s.eTypeCode = t.eTypeCode'
		else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.rowNum, s.eTypeCode, s.eTypeName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select clgCode, clgName, temp.rowNum, eTypeCode, eTypeName from college , #tempSubTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.eTypeCode = t.eTypeCode'
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.uCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.uCode, s.uName, s.rowNum, s.eTypeCode, s.eTypeName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select c.clgCode, c.clgName, u.uCode, u.uName, temp.rowNum, eTypeCode, eTypeName from college c left join useUnit u on c.clgCode = u.clgCode , #tempSubTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.uCode = t.uCode and s.eTypeCode = t.eTypeCode'
	end
	else if @templateType = 1	--1->���ֶλ���
	begin
		--����������
		if not (select object_id('Tempdb..#tempMoneySectionTotal')) is null 
			drop table #tempMoneySectionTotal
		create table #tempMoneySectionTotal(rowNum int, startMoney money, endMoney money)

		insert #tempMoneySectionTotal(rowNum, startMoney, endMoney)
		select cast(cast(T.x.query('data(./@id)') as char(8)) as int), cast(cast(T.x.query('data(./startMoney)') as char(14)) as money), cast(cast(T.x.query('data(./endMoney)') as varchar(14)) as money)
		from (select @moneySectionDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)

		set @groupCol = @groupCol + N' case '
		declare @i int
		declare @startMoney money, @endMoney money
		declare OB cursor for
		select rowNum, startMoney, endMoney from #tempMoneySectionTotal
		OPEN OB
		FETCH NEXT FROM OB INTO @i, @startMoney, @endMoney
		WHILE @@FETCH_STATUS = 0
		begin
			set @groupCol = @groupCol + ' when totalAmount>=' + str(@startMoney, 14, 2)
			if @endMoney > 0
				set @groupCol = @groupCol + ' and totalAmount < ' + str(@endMoney, 14, 2) 
			set @groupCol = @groupCol + ' then ' + str(@i, 8)
			FETCH NEXT FROM OB INTO @i, @startMoney, @endMoney
		end
		CLOSE OB
		DEALLOCATE OB
		set @groupCol = @groupCol + N' end '

		set @sql = N'select ' + @groupCol + ' moneyLevel, count(*) totalNum, sum(cast(totalAmount as numeric(18,2))) totalMoney'
					+ ' from equipmentList e'
					+ ' where '+ @strWhere 
		if (select count(*) from #tempSubTotal) > 0	--ָ���豸���͵�ͳ��
		begin
			set @sql = @sql 
				--ָ����ȷ����ͳ�ƣ�
				+' and (eTypeCode in (select eTypeCode from #tempSubTotal where right(eTypeCode,2)<>' + char(39) + '00' + char(39) + ')'
				--ָ�����ͳ�ƣ�С��
				+ ' or left(eTypeCode,6) in (select left(eTypeCode,6) from #tempSubTotal where right(eTypeCode,4)<>' + char(39) + '0000' + char(39) + ' and right(eTypeCode,2)=' + char(39) + '00' + char(39) + ')'
				--ָ�����ͳ�ƣ�����
				+ ' or left(eTypeCode,4) in (select left(eTypeCode,4) from #tempSubTotal where right(eTypeCode,6)<>' + char(39) + '000000' + char(39) + ' and right(eTypeCode,4)=' + char(39) + '0000' + char(39) + ')'
				--ָ�����ͳ�ƣ�����
				+ ' or left(eTypeCode,2) in (select left(eTypeCode,2) from #tempSubTotal where right(eTypeCode,6)=' + char(39) + '000000' + char(39) + '))'
		end
		set @sql = @sql + ' group by ' + @groupCol 
		if @particleSize = 0	--������
			set @sql = N'select ROW_NUMBER() OVER(order by s.rowNum) as RowID, s.startMoney, s.endMoney, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+' from #tempMoneySectionTotal s left join (' + @sql + ') t on s.rowNum = t.moneyLevel'
		else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.rowNum, s.startMoney, s.endMoney, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select clgCode, clgName, temp.rowNum, temp.startMoney, temp.endMoney from college, #tempMoneySectionTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.rowNum = t.moneyLevel'
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.uCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.uCode, s.uName, s.rowNum, s.startMoney, s.endMoney, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select c.clgCode, c.clgName, u.uCode, u.uName, temp.rowNum, temp.startMoney, temp.endMoney from college c left join useUnit u on c.clgCode = u.clgCode, #tempMoneySectionTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.uCode = t.uCode and s.rowNum = t.moneyLevel'
	end
	else if @templateType = 2	--2->��λ����
	begin
		set @sql = N'select ' + @groupCol + ' count(*) totalNum, sum(totalAmount) totalMoney
		from equipmentList e
		where '+ @strWhere 
		if (select count(*) from #tempSubTotal) > 0	--ָ���豸���͵�ͳ��
			--ָ����ȷ����ͳ�ƣ�
			set @sql = @sql +' and (eTypeCode in (select eTypeCode from #tempSubTotal where right(eTypeCode,2)<>' + char(39) + '00' + char(39) + ')'
				--ָ�����ͳ�ƣ�С��
				+ ' or left(eTypeCode,6) in (select left(eTypeCode,6) from #tempSubTotal where right(eTypeCode,4)<>' + char(39) + '0000' + char(39) + ' and right(eTypeCode,2)=' + char(39) + '00' + char(39) + ')'
				--ָ�����ͳ�ƣ�����
				+ ' or left(eTypeCode,4) in (select left(eTypeCode,4) from #tempSubTotal where right(eTypeCode,6)<>' + char(39) + '000000' + char(39) + ' and right(eTypeCode,4)=' + char(39) + '0000' + char(39) + ')'
				--ָ�����ͳ�ƣ�����
				+ ' or left(eTypeCode,2) in (select left(eTypeCode,2) from #tempSubTotal where right(eTypeCode,6)=' + char(39) + '000000' + char(39) + '))'
		set @sql = @sql +' group by ' + left(@groupCol, len(@groupCol) -1)

		if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			set @sql = N'select ROW_NUMBER() OVER(order by c.clgCode) as RowID, c.clgCode, c.clgName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from college c left join (' + @sql + ') t on c.clgCode = t.clgCode'
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			set @sql = N'select ROW_NUMBER() OVER(order by c.clgCode, u.uCode) as RowID, c.clgCode, c.clgName, u.uCode, u.uName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from college c left join useUnit u on c.clgCode = u.clgCode '
				+ ' left join (' + @sql + ') t on c.clgCode = t.clgCode and u.uCode = t.uCode'
	end
	else if @templateType = 3	--3->ʹ�÷������
	begin
		--����ʹ�÷�������
		if not (select object_id('Tempdb..#tempAppDirTotal')) is null 
			drop table #tempAppDirTotal
		create table #tempAppDirTotal(rowNum int, aCode char(2), aName nvarchar(20))

		insert #tempAppDirTotal(rowNum, aCode, aName)
		select cast(cast(T.x.query('data(./@id)') as char(8)) as int), cast(T.x.query('data(./aCode)') as char(2)), cast(T.x.query('data(./aName)') as nvarchar(20))
		from (select @appDirDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)

		set @groupCol = @groupCol + N' aCode '

		set @sql = N'select ' + @groupCol + ' , count(*) totalNum, sum(cast(totalAmount as numeric(18,2))) totalMoney'
					+ ' from equipmentList e'
					+ ' where '+ @strWhere + ' and aCode in (select aCode from #tempAppDirTotal)'
		if (select count(*) from #tempSubTotal) > 0	--ָ���豸���͵�ͳ��
		begin
			set @sql = @sql 
				--ָ����ȷ����ͳ�ƣ�
				+' and (eTypeCode in (select eTypeCode from #tempSubTotal where right(eTypeCode,2)<>' + char(39) + '00' + char(39) + ')'
				--ָ�����ͳ�ƣ�С��
				+ ' or left(eTypeCode,6) in (select left(eTypeCode,6) from #tempSubTotal where right(eTypeCode,4)<>' + char(39) + '0000' + char(39) + ' and right(eTypeCode,2)=' + char(39) + '00' + char(39) + ')'
				--ָ�����ͳ�ƣ�����
				+ ' or left(eTypeCode,4) in (select left(eTypeCode,4) from #tempSubTotal where right(eTypeCode,6)<>' + char(39) + '000000' + char(39) + ' and right(eTypeCode,4)=' + char(39) + '0000' + char(39) + ')'
				--ָ�����ͳ�ƣ�����
				+ ' or left(eTypeCode,2) in (select left(eTypeCode,2) from #tempSubTotal where right(eTypeCode,6)=' + char(39) + '000000' + char(39) + '))'
		end
		set @sql = @sql + ' group by ' + @groupCol 
		if @particleSize = 0	--������
			set @sql = N'select ROW_NUMBER() OVER(order by s.rowNum) as RowID, s.aCode, s.aName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+' from #tempAppDirTotal s left join (' + @sql + ') t on s.aCode = t.aCode'
		else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.rowNum, s.aCode, s.aName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select clgCode, clgName, temp.rowNum, temp.aCode, temp.aName from college, #tempAppDirTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.aCode = t.aCode'
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.uCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.uCode, s.uName, s.rowNum, s.aCode, s.aName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select c.clgCode, c.clgName, u.uCode, u.uName, temp.rowNum, temp.aCode, temp.aName from college c left join useUnit u on c.clgCode = u.clgCode, #tempAppDirTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.uCode = t.uCode and s.aCode = t.aCode'
	end
	else if @templateType = 4	--4->������Դ����
	begin
		--����ʹ�÷�������
		if not (select object_id('Tempdb..#tempFundSrcTotal')) is null 
			drop table #tempFundSrcTotal
		create table #tempFundSrcTotal(rowNum int, fCode char(2), fName nvarchar(20))

		insert #tempFundSrcTotal(rowNum, fCode, fName)
		select cast(cast(T.x.query('data(./@id)') as char(8)) as int), cast(T.x.query('data(./fCode)') as char(2)), cast(T.x.query('data(./fName)') as nvarchar(20))
		from (select @fundSrcDetail.query('/root/row') Col1) A
				OUTER APPLY A.Col1.nodes('/row') AS T(x)

		set @groupCol = @groupCol + N' fCode '

		set @sql = N'select ' + @groupCol + ' , count(*) totalNum, sum(cast(totalAmount as numeric(18,2))) totalMoney'
					+ ' from equipmentList e'
					+ ' where '+ @strWhere + ' and fCode in (select fCode from #tempFundSrcTotal)'
		if (select count(*) from #tempSubTotal) > 0	--ָ���豸���͵�ͳ��
		begin
			set @sql = @sql 
				--ָ����ȷ����ͳ�ƣ�
				+' and (eTypeCode in (select eTypeCode from #tempSubTotal where right(eTypeCode,2)<>' + char(39) + '00' + char(39) + ')'
				--ָ�����ͳ�ƣ�С��
				+ ' or left(eTypeCode,6) in (select left(eTypeCode,6) from #tempSubTotal where right(eTypeCode,4)<>' + char(39) + '0000' + char(39) + ' and right(eTypeCode,2)=' + char(39) + '00' + char(39) + ')'
				--ָ�����ͳ�ƣ�����
				+ ' or left(eTypeCode,4) in (select left(eTypeCode,4) from #tempSubTotal where right(eTypeCode,6)<>' + char(39) + '000000' + char(39) + ' and right(eTypeCode,4)=' + char(39) + '0000' + char(39) + ')'
				--ָ�����ͳ�ƣ�����
				+ ' or left(eTypeCode,2) in (select left(eTypeCode,2) from #tempSubTotal where right(eTypeCode,6)=' + char(39) + '000000' + char(39) + '))'
		end
		set @sql = @sql + ' group by ' + @groupCol 
		if @particleSize = 0	--������
			set @sql = N'select ROW_NUMBER() OVER(order by s.rowNum) as RowID, s.fCode, s.fName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+' from #tempFundSrcTotal s left join (' + @sql + ') t on s.fCode = t.fCode'
		else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.rowNum, s.fCode, s.fName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select clgCode, clgName, temp.rowNum, temp.fCode, temp.fName from college, #tempFundSrcTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.fCode = t.fCode'
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			set @sql = N'select ROW_NUMBER() OVER(order by s.clgCode, s.uCode, s.rowNum) as RowID, s.clgCode, s.clgName, s.uCode, s.uName, s.rowNum, s.fCode, s.fName, isnull(t.totalNum,0) totalNum, isnull(t.totalMoney,0) totalMoney'
				+ ' from (select c.clgCode, c.clgName, u.uCode, u.uName, temp.rowNum, temp.fCode, temp.fName from college c left join useUnit u on c.clgCode = u.clgCode, #tempFundSrcTotal temp) s'
				+ ' left join (' + @sql + ') t on s.clgCode = t.clgCode and s.uCode = t.uCode and s.fCode = t.fCode'
	end

--print @sql
	EXEC(@sql)   
GO
--���ԣ�
declare @quotaDetail xml
set @quotaDetail = N'<root></root>'
declare @moneySectionDetail xml
set @moneySectionDetail = N'<root>
					<row id="1">
						<startMoney>0</startMoney>
						<endMoney>10000</endMoney>
					</row>
					<row id="2">
						<startMoney>10000</startMoney>
						<endMoney>20000</endMoney>
					</row>
					<row id="3">
						<startMoney>20000</startMoney>
						<endMoney>-1</endMoney>
					</row>
				</root>'
declare @appDirDetail xml
set @appDirDetail =N'<root>
						<row id="1">
							<aCode>2</aCode>
							<aName>����</aName>
						</row>
						<row id="2">
							<aCode>1</aCode>
							<aName>��ѧ</aName>
						</row>
					</root>'
declare @fundSrcDetail xml
set @fundSrcDetail =N'<root>
						<row id="1">
							<fCode>1</fCode>
							<fName>������ҵ��</fName>
						</row>
						<row id="2">
							<fCode>2</fCode>
							<fName>����ר������</fName>
						</row>
					</root>'
declare @particleDesc xml
declare @rows int, @pages int
exec dbo.makeTotal  3, '2009-01-01', '', '2011-01-01', '', 0, null, 1, @quotaDetail, @moneySectionDetail, @appDirDetail, @fundSrcDetail



drop PROCEDURE saveTotalResult
/*
	name:		saveTotalResult
	function:	13.����ͳ������
				ע�⣺���洢����ͬʱ�������ӱ�����ݣ�
	input: 
				@theTitle nvarchar(100),	--ͳ�Ʊ����
				@templateID smallint,		--ͳ��ģ��ID
				@templateType smallint,		--ģ�����0->�豸������ܣ�1->���ֶλ��ܣ�2->��λ����,3->ʹ�÷���4->������Դ
				
				--ͳ��ʱ�����Ʋ�����
				@startAcceptDate varchar(10),--���տ�ʼ����:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"
				@endAcceptDate varchar(10),	--���ս�������:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"
				@startScrapDate varchar(10),--���Ͽ�ʼ����:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"
				@endScrapDate varchar(10),	--���Ͻ�������:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"

				--ͳ�ƿռ����Ʋ�����
				@statisticUnitType int,			--ͳ�Ʒ�Χ:0->ȫУ��1->Ժ��
				@statisticUnitCode xml,			--xml��ʽ��ŵ�ͳ�Ʒ�Χ���壺N'<root>
																	--	<row id="1">
																	--		<clgCode>027</clgCode>
																	--		<clgName>����</clgName>
																	--	</row>
																	--	<row id="2">
																	--		<clgCode>029</clgCode>
																	--		<clgName>������ҵ������</clgName>
																	--	</row>
																	--	...
																	--</root>'
				@particleSize int,				--ͳ�Ƶ�λ�������ȣ�:0->ȫУ��1->Ժ����2->ʹ�õ�λ��Ϊ0ʱ��ʹ��ͳ�Ƶ�λ���顣

				--ͳ��ָ�꣺����Ϊ��֧���û���̬�޸�ͳ��ָ����������!
				@quotaDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
																	--	<row id="1">
																	--		<eTypeCode>05010549</eTypeCode>
																	--		<eTypeName>�����ӡ��</eTypeName>
																	--	</row>
																	--	<row id="2">
																	--		<eTypeCode>05010550</eTypeCode>
																	--		<eTypeName>ɨ����</eTypeName>
																	--	</row>
																	--	...
																	--</root>'
				@moneySectionDetail xml,--ʹ��xml�洢��ָ�꣺N'<root>
																	--	<row id="1">
																	--		<startMoney>0</startMoney>
																	--		<endMoney>10000</endMoney>
																	--	</row>
																	--	<row id="2">
																	--		<startMoney>10000</startMoney>
																	--		<endMoney>20000</endMoney>
																	--	</row>
																	--	<row id="3">
																	--		<startMoney>20000</startMoney>
																	--		<endMoney>-1</endMoney>
																	--	</row>
																	--	...
																	--</root>'
				
				@appDirDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
																--	<row id="1">
																--		<aCode>1</aCode>
																--		<aName>��ѧ</aName>
																--	</row>
																--	<row id="2">
																--		<aCode>2</aCode>
																--		<aName>����</aName>
																--	</row>
																--	...
																--</root>'
				@fundSrcDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
																	--	<row id="1">
																	--		<fCode>1</fCode>
																	--		<fName>������ҵ��</fName>
																	--	</row>
																	--	<row id="2">
																	--		<fCode>2</fCode>
																	--		<fName>����ר������</fName>
																	--	</row>
																	--	...
																	--</root>'
				@makerID varchar(10),		--ͳ���˹���
	output:		
				@Ret		int output,		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
				@makeDate smalldatetime output,	--ͳ�Ʊ�浵����
				@totalTabNum varchar(20) output	--ͳ�Ʊ���
	author:		¬έ
	CreateDate:	2011-2-15
	UpdateDate: modi by lw 2011-3-11 ���ݱϴ�Ҫ������ʹ�÷���;�����Դ����ģ��
*/
create PROCEDURE saveTotalResult
	@theTitle nvarchar(100),	--ͳ�Ʊ����
	@templateID smallint,		--ͳ��ģ��ID
	@templateType smallint,		--ģ�����0->�豸������ܣ�1->���ֶλ��ܣ�2->��λ����,3->ʹ�÷���4->������Դ
	
	--ͳ��ʱ�����Ʋ�����
	@startAcceptDate varchar(10),--���տ�ʼ����:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"
	@endAcceptDate varchar(10),	--���ս�������:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"
	@startScrapDate varchar(10),--���Ͽ�ʼ����:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"
	@endScrapDate varchar(10),	--���Ͻ�������:��ODBC��ʽ��ŵ�����"YYYY-MM-DD"

	--ͳ�ƿռ����Ʋ�����
	@statisticUnitType int,			--ͳ�Ʒ�Χ:0->ȫУ��1->Ժ��
	@statisticUnitCode xml,			--xml��ʽ��ŵ�ͳ�Ʒ�Χ���壺N'<root>
														--	<row id="1">
														--		<clgCode>027</clgCode>
														--		<clgName>����</clgName>
														--	</row>
														--	<row id="2">
														--		<clgCode>029</clgCode>
														--		<clgName>������ҵ������</clgName>
														--	</row>
														--	...
														--</root>'
	@particleSize int,				--ͳ�Ƶ�λ�������ȣ�:0->ȫУ��1->Ժ����2->ʹ�õ�λ��Ϊ0ʱ��ʹ��ͳ�Ƶ�λ���顣

	--ͳ��ָ�꣺����Ϊ��֧���û���̬�޸�ͳ��ָ����������!
	@quotaDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<eTypeCode>05010549</eTypeCode>
														--		<eTypeName>�����ӡ��</eTypeName>
														--	</row>
														--	<row id="2">
														--		<eTypeCode>05010550</eTypeCode>
														--		<eTypeName>ɨ����</eTypeName>
														--	</row>
														--	...
														--</root>'
	@moneySectionDetail xml,--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<startMoney>0</startMoney>
														--		<endMoney>10000</endMoney>
														--	</row>
														--	<row id="2">
														--		<startMoney>10000</startMoney>
														--		<endMoney>20000</endMoney>
														--	</row>
														--	<row id="3">
														--		<startMoney>20000</startMoney>
														--		<endMoney>-1</endMoney>
														--	</row>
														--	...
														--</root>'
	
	@appDirDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
													--	<row id="1">
													--		<aCode>1</aCode>
													--		<aName>��ѧ</aName>
													--	</row>
													--	<row id="2">
													--		<aCode>2</aCode>
													--		<aName>����</aName>
													--	</row>
													--	...
													--</root>'
	@fundSrcDetail xml,		--ʹ��xml�洢��ָ�꣺N'<root>
														--	<row id="1">
														--		<fCode>1</fCode>
														--		<fName>������ҵ��</fName>
														--	</row>
														--	<row id="2">
														--		<fCode>2</fCode>
														--		<fName>����ר������</fName>
														--	</row>
														--	...
														--</root>'
	@makerID varchar(10),		--ͳ���˹���
	@Ret		int output,		--�����ɹ���ʶ
	@makeDate smalldatetime output,	--ͳ�Ʊ�浵����
	@totalTabNum varchar(20) output	--ͳ�Ʊ���
	
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 1000, 1, @curNumber output
	set @totalTabNum = @curNumber

	--��ȡͳ����������
	declare @maker varchar(30)
	set @maker = isnull((select userCName from activeUsers where userID = @makerID),'')
	
	set @makeDate = getdate()
	--Ϊ��֤��ʷ���ݵ���ȷ�ԣ��鿴��ϸ������ʱ�����������������⴦��
	if @endAcceptDate = ''
		set @endAcceptDate = convert(varchar(10),dateadd(day,1,getdate()),120)
	if @startScrapDate = ''
		set @startScrapDate = convert(varchar(10), dateadd(day,1,getdate()), 120)
	
	begin tran
		--��������
		insert totalCenter(totalTabNum, theTitle, templateID, templateType,
							startAcceptDate, endAcceptDate, startScrapDate, endScrapDate,
							statisticUnitType, statisticUnitCode, particleSize,
							quotaDetail, moneySectionDetail, 
							appDirDetail, fundSrcDetail,
							makeDate, makerID, maker)
		values(@totalTabNum, @theTitle, @templateID, @templateType,
							@startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
							@statisticUnitType, @statisticUnitCode, @particleSize,
							@quotaDetail, @moneySectionDetail, 
							@appDirDetail, @fundSrcDetail,
							@makeDate, @makerID, @maker)
		

		if not (select object_id('Tempdb..#totalResult')) is null 
			drop table #totalResult
		create table #totalResult(RowID int not null)
	
		--����ģ������첻ͬ����ʱ������makeTotal�Ľ����,�Բ�ͬ��ʽ������ϸ���ݣ�
		if @templateType = 0	--0->�豸�������
		begin
			if @particleSize = 0	--������
			begin
				alter table #totalResult add eTypeCode char(8), eTypeName nvarchar(30), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into subTotal(totalTabNum, ID4Row, eTypeCode, eTypeName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
											rowNum int, eTypeCode char(8), eTypeName nvarchar(30), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into subTotal(totalTabNum, ID4Row, clgCode, clgName, rowNum, eTypeCode, eTypeName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
											rowNum int, eTypeCode char(8), eTypeName nvarchar(30), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into subTotal(totalTabNum, ID4Row, clgCode, clgName, uCode, uName, rowNum, eTypeCode, eTypeName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
		end
		else if @templateType = 1	--1->���ֶλ���
		begin
			if @particleSize = 0	--������
			begin
				alter table #totalResult add startMoney money, endMoney money, totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into moneySectionTotal(totalTabNum, ID4Row, startMoney, endMoney, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
											rowNum int, startMoney money, endMoney money, totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into moneySectionTotal(totalTabNum, ID4Row, clgCode, clgName, rowNum, startMoney, endMoney, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
											rowNum int, startMoney money, endMoney money, totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into moneySectionTotal(totalTabNum, ID4Row, clgCode, clgName, uCode, uName, rowNum, startMoney, endMoney, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
		end
		else if @templateType = 2 --2->��λ����
		begin
			if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into unitGroupTotal(totalTabNum, ID4Row, clgCode, clgName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
											totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into unitGroupTotal(totalTabNum, ID4Row, clgCode, clgName, uCode, uName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
		end
		else if @templateType = 3	--3->ʹ�÷������
		begin
			if @particleSize = 0	--������
			begin
				alter table #totalResult add aCode char(2), aName nvarchar(20), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into appDirTotal(totalTabNum, ID4Row, aCode, aName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
											rowNum int, aCode char(2), aName nvarchar(20), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into appDirTotal(totalTabNum, ID4Row, clgCode, clgName, rowNum, aCode, aName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
											rowNum int, aCode char(2), aName nvarchar(20), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into appDirTotal(totalTabNum, ID4Row, clgCode, clgName, uCode, uName, rowNum, aCode, aName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
		end
		else if @templateType = 4	--4->������Դ����
		begin
			if @particleSize = 0	--������
			begin
				alter table #totalResult add fCode char(2), fName nvarchar(20), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into fundSrcTotal(totalTabNum, ID4Row, fCode, fName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), 
											rowNum int, fCode char(2), fName nvarchar(20), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into fundSrcTotal(totalTabNum, ID4Row, clgCode, clgName, rowNum, fCode, fName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
			else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			begin
				alter table #totalResult add clgCode char(3), clgName nvarchar(30), uCode varchar(8), uName nvarchar(30), 
											rowNum int, fCode char(2), fName nvarchar(20), totalNum int, totalMoney numeric(18,2)
				insert into #totalResult exec makeTotal @templateType, @startAcceptDate, @endAcceptDate, @startScrapDate, @endScrapDate,
												@statisticUnitType, @statisticUnitCode, @particleSize, @quotaDetail, @moneySectionDetail,
												@appDirDetail, @fundSrcDetail
				insert into fundSrcTotal(totalTabNum, ID4Row, clgCode, clgName, uCode, uName, rowNum, fCode, fName, totalNum, totalMoney) 
				select @totalTabNum, t.* from #totalResult t
			end
		end
		drop table #totalResult
		
	commit tran
	set @Ret = 0
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@makerID, @maker, @makeDate, '���ͳ�Ʊ�', 'ϵͳ�����û�' + @maker + 
					'��Ҫ�������ͳ�Ʊ�[' + @totalTabNum + ']��')
GO
--���ԣ�
declare @quotaDetail xml
set @quotaDetail = N'<root>
					<row id="1">
						<eTypeCode>05010549</eTypeCode>
						<eTypeName>�����ӡ��</eTypeName>
					</row>
					<row id="2">
						<eTypeCode>05010550</eTypeCode>
						<eTypeName>ɨ����</eTypeName>
					</row>
					<row id="3">
						<eTypeCode>05011549</eTypeCode>
						<eTypeName>��ָ��</eTypeName>
					</row>
				</root>'
declare @moneySectionDetail xml
set @moneySectionDetail = N'<root>
					<row id="1">
						<startMoney>0</startMoney>
						<endMoney>10000</endMoney>
					</row>
					<row id="2">
						<startMoney>10000</startMoney>
						<endMoney>20000</endMoney>
					</row>
					<row id="3">
						<startMoney>20000</startMoney>
						<endMoney>-1</endMoney>
					</row>
				</root>'
declare @appDirDetail xml
set @appDirDetail =N'<root>
						<row id="1">
							<aCode>2</aCode>
							<aName>����</aName>
						</row>
						<row id="2">
							<aCode>1</aCode>
							<aName>��ѧ</aName>
						</row>
					</root>'
declare @fundSrcDetail xml
set @fundSrcDetail =N'<root>
						<row id="1">
							<fCode>1</fCode>
							<fName>������ҵ��</fName>
						</row>
						<row id="2">
							<fCode>2</fCode>
							<fName>����ר������</fName>
						</row>
					</root>'
declare @Ret int	--�����ɹ���ʶ
declare @makeDate smalldatetime	--ͳ�Ʊ�浵����
declare @totalTabNum varchar(20)--ͳ�Ʊ���
exec dbo.saveTotalResult '����ͳ�Ʊ�1', 5, 2, '2009-01-01', '', '2011-01-01', '', 0, null, 1, @quotaDetail, @moneySectionDetail, 
			@appDirDetail, @fundSrcDetail, 
			'00001', @Ret output, @makeDate output, @totalTabNum output

select @Ret, @totalTabNum

select * from totalCenter
select * from subTotal

drop PROCEDURE getTotalResult
/*
	name:		getTotalResult
	function:	14.���÷�ҳ��ʽ��ȡָ����ͳ�Ʊ������
	input: 
				@totalTabNum varchar(20),	--ͳ�Ʊ���
				@strOrder nvarchar(200),	--��������	add by lw 2011-12-20
				--�������ҳ������
				@pageSize int,      --ÿҳ����   
				@page     int,		--ָ��ҳ   
	output:		
				@rows  int OUTPUT,	--������
				@pages int OUTPUT	--��ҳ��   
				ʹ�ý��������ͳ��ָ���ָ��ֵ
	author:		¬έ
	CreateDate:	2011-2-15
	UpdateDate: modi by lw 2011-2-17�޸Ļ�ȡ�����û�мӱ��������ƵĴ��󣬸�Ϊ���ζ�ִ̬����䡣
				modi by lw 2011-3-11 ���ݱϴ�Ҫ������ʹ�÷���;�����Դ����ģ��
				modi by lw 2011-12-20������������
*/
create PROCEDURE getTotalResult
	@totalTabNum varchar(20),	--ͳ�Ʊ���
	@strOrder nvarchar(200),	--��������	add by lw 2011-12-20
	--�������ҳ������
    @pageSize int,      --ÿҳ����   
    @page     int,		--ָ��ҳ   
    @rows  int OUTPUT,	--������
    @pages int OUTPUT	--��ҳ��   
	WITH ENCRYPTION 
AS
	--����order�Ӿ䣺
	if (@strOrder = '')
		set @strOrder = ' order by ID4Row'

	--��ȡ�������ͣ�
	declare @templateType smallint		--ģ�����0->�豸������ܣ�1->���ֶλ��ܣ�2->��λ����,3->ʹ�÷���4->������Դ
	declare @particleSize int			--ͳ�Ƶ�λ�������ȣ�:0->ȫУ��1->Ժ����2->ʹ�õ�λ��Ϊ0ʱ��ʹ��ͳ�Ƶ�λ���顣
	select @templateType = templateType, @particleSize = particleSize from totalCenter where totalTabNum = @totalTabNum
	if @templateType is null
	begin
		set @rows = 0
		set @pages = 0
		return
	end
	
	--׼����ҳ��
	declare @topRows as varchar(10)
	set @topRows = ltrim(str((@page+1) * @pageSize, 10))
	declare @sql as nvarchar(max)
	
	--����ģ������첻ͬ����ʱ������makeTotal�Ľ������
	if @templateType = 0	--0->�豸�������
	begin
		if @particleSize = 0	--������
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, eTypeCode, eTypeName, totalNum, totalMoney'
				+ ' from subTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, rowNum, eTypeCode, eTypeName, totalNum, totalMoney'
				+ ' from subTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, uCode, uName, rowNum, eTypeCode, eTypeName, totalNum, totalMoney'
				+ ' from subTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		set @rows = (select count(*) from subTotal where totalTabNum = @totalTabNum)	--������
	end
	else if @templateType = 1	--1->���ֶλ���
	begin
		if @particleSize = 0	--������
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, startMoney, endMoney, totalNum, totalMoney'
				+ ' from moneySectionTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, rowNum, startMoney, endMoney, totalNum, totalMoney'
				+ ' from moneySectionTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, uCode, uName, rowNum, startMoney, endMoney, totalNum, totalMoney'
				+ ' from moneySectionTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		set @rows = (select count(*) from moneySectionTotal where totalTabNum = @totalTabNum)	--������
	end
	else if @templateType = 2	--2->��λ����
	begin
		if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, totalNum, totalMoney'
				+ ' from unitGroupTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, uCode, uName, totalNum, totalMoney'
				+ ' from unitGroupTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		set @rows = (select count(*) from unitGroupTotal where totalTabNum = @totalTabNum)	--������
	end
	else if @templateType = 3	--3->ʹ�÷������
	begin
		if @particleSize = 0	--������
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, aCode, aName, totalNum, totalMoney'
				+ ' from appDirTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, rowNum, aCode, aName, totalNum, totalMoney'
				+ ' from appDirTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, uCode, uName, rowNum, aCode, aName, totalNum, totalMoney'
				+ ' from appDirTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		set @rows = (select count(*) from appDirTotal where totalTabNum = @totalTabNum)	--������
	end
	else if @templateType = 4	--3->������Դ����
	begin
		if @particleSize = 0	--������
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, fCode, fName, totalNum, totalMoney'
				+ ' from fundSrcTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 1	--���飨ͳ�Ƶ�λ������ȣ�:1->Ժ��
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, rowNum, fCode, fName, totalNum, totalMoney'
				+ ' from fundSrcTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		else if @particleSize = 2	--ͳ�Ƶ�λ�������ȣ�:2->ʹ�õ�λ
			set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, clgCode, clgName, uCode, uName, rowNum, fCode, fName, totalNum, totalMoney'
				+ ' from fundSrcTotal'
				+ ' where totalTabNum = ' + char(39) + @totalTabNum + char(39)
		set @rows = (select count(*) from fundSrcTotal where totalTabNum = @totalTabNum)	--������
	end
	set @pages = (@rows + @pageSize -1) / @pageSize	--��ҳ��
	set @sql = N'select * from (' + @sql + ') tab1'
	if @pageSize > 0
		set @sql = @sql + N' where RowID BETWEEN ' + str(@page * @pageSize + 1 ,10) + ' AND ' + @topRows

--print @sql
	EXEC(@sql)   
GO
--���ԣ�
use epdc2
select * from totalCenter
select * from subTotal
select * from unitGroupTotal

declare @rows int, @pages int
exec dbo.getTotalResult '201103120001', 'order by eTypeCode', 10, 0, @rows output, @pages output
select @rows, @pages


--ɾ��ͳ�Ʊ�
drop PROCEDURE delTotalResult
/*
	name:		delTotalResult
	function:	15.ɾ��ָ���ı�ŵ�ͳ�Ʊ�
	input: 
				@totalTabNum varchar(20),	--ͳ�Ʊ���
				@delManID varchar(10) output,	--ɾ���ˣ������ǰͳ�Ʊ����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ͳ�Ʊ����ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2011-2-15
	UpdateDate: 

*/
create PROCEDURE delTotalResult
	@totalTabNum varchar(20),		--ͳ�Ʊ���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰͳ��ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ����ͳ�Ʊ��Ƿ����
	declare @count as int
	set @count=(select count(*) from totalCenter where totalTabNum = @totalTabNum)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end
	
	delete totalCenter where totalTabNum = @totalTabNum
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��ͳ�Ʊ�', '�û�' + @delManName
												+ 'ɾ���˱��Ϊ[' + @totalTabNum + ']��ͳ�Ʊ�')
GO

