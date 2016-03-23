use hustOA
/*
	ǿ�ų����İ칫ϵͳ-������Form�����
	author:		¬έ
	CreateDate:	2014-1-1
	UpdateDate: 
*/
--3.������ģ��������һ��������ģ����������
drop table workFlowTemplateForms
CREATE TABLE workFlowTemplateForms(
	templateID varchar(10) not null,	--����/�����������ģ����
	formID varchar(10) not null,		--������������ģ��ʹ�õ��ı�ID,��ϵͳʹ�õ� �ź��뷢����������'FM'+4λ��ݴ���+4λ��ˮ�ţ�
	formType smallint not null,			--�ڵ�ʹ�ñ����ͣ�0->��ʾ��1->�༭
	formName nvarchar(30) null,			--������

	formPageFile varchar(128) not null,	--����̬ҳ��ҳ��·����������Ϊ���ݱ��Ĳ������ݿⶨ�����ɵľ�̬ҳ�棩
	--��formHtmlFileΪnullʱ��ʹ�����ݿ�洢�ı��ؼ���
	formTab varchar(60) null,			--����Ӧ�����ݿ����������
	paperWidth int not null,			--ֽ�ſ�ȣ���mmΪ��λ
	paperHeight int not null,			--ֽ�Ÿ߶ȣ���mmΪ��λ
	paddingLeft int default(0),			--�����գ���mmΪ��λ
	paddingRight int default(0),		--�����գ���mmΪ��λ
	paddingTop int default(0),			--�����գ���mmΪ��λ
	paddingBottom int default(0),		--�����գ���mmΪ��λ
	
	--�ĵ��ĺ��뷢������
	DocEncoderID int default(0),		--���뷢������ID�ţ�0->��ʹ��
	DocEncoderPrefix varchar(8),		--ǰ׺
	DocEncoderDateType int,				--�������ʽ��0->��ʹ��������,1->4λ���+2λ�·�+2λ����,2->4λ���+2λ�·�,3->4λ���
	DocEncoderSerialNumLen int,			--��ˮ�볤��
	DocEncoderSerialNumInc int,			--��ˮ������
	DocEncoderSuffix varchar(8),		--��׺
	
	haveAttach int default(0),			--�Ƿ������ϴ�������0->������1->����
	/*
		��չ����Ӧ�ð���ҳ����ʹ�õĿؼ����ͣ����ַ�ʽ���������ƣ���Ӧ�����ݿ��ֶΣ���֤�õ�������ʽ��
	*/
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_workFlowTemplateForms] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[formID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[workFlowTemplateForms] WITH CHECK ADD CONSTRAINT [FK_workFlowTemplateForms_workFlowTemplate] FOREIGN KEY([templateID])
REFERENCES [dbo].[workFlowTemplate] ([templateID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[workFlowTemplateForms] CHECK CONSTRAINT [FK_workFlowTemplateForms_workFlowTemplate] 
GO

--3.1.������ģ����ؼ�һ����
drop table formCtrolList
CREATE TABLE formCtrolList(
	templateID varchar(10) not null,	--����/�����������ģ����
	formID varchar(10) not null,		--����/�����������ģ��ʹ�õ��ı�ID
	
	ctrolType int not null,			--�ؼ�����
	ctrolTypeName nvarchar(30) not null,--������ƣ��ؼ���������
	ctrolName varchar(30) not null,	--�������ؼ�����
	ctrolCName nvarchar(30) not null,	--�ؼ���������
	
	styleDesc varchar(1024) null,		--�ؼ�����ʽ����������λ�á����塢�ֺš���ɫ���ּ�ࡢ�иߡ���ɫ���߿��������ա��������ա����Ҷ��뷽ʽ���������ط�ʽ���Ƿ�ת��
 CONSTRAINT [PK_formCtrolList] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[formID] ASC,
	[ctrolName] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[formCtrolList] WITH CHECK ADD CONSTRAINT [FK_workFlowTemplateForms_formCtrolList] FOREIGN KEY([templateID],[formID])
REFERENCES [dbo].[workFlowTemplateForms] ([templateID],[formID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[formCtrolList] CHECK CONSTRAINT [FK_workFlowTemplateForms_formCtrolList] 
GO
--����ؼ�������
--3.2.��ǩ������
drop table ctrolLabel
CREATE TABLE ctrolLabel(
	templateID varchar(10) not null,--����/�����������ģ����
	formID varchar(10) not null,	--����/�����������ģ��ʹ�õ��ı�ID
	ctrolName varchar(30) not null,	--����/������ؼ�����

	labelText nvarchar(256),		--�ı�����
CONSTRAINT [PK_ctrolLabel] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[formID] ASC,
	[ctrolName] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[ctrolLabel] WITH CHECK ADD CONSTRAINT [FK_formCtrolList_ctrolLabel] FOREIGN KEY([templateID],[formID],[ctrolName])
REFERENCES [dbo].[formCtrolList] ([templateID],[formID],[ctrolName])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ctrolLabel] CHECK CONSTRAINT [FK_formCtrolList_ctrolLabel] 
GO


--3.3.�����ı������������
drop table ctrolTextbox
CREATE TABLE ctrolTextbox(
	templateID varchar(10) not null,--����/�����������ģ����
	formID varchar(10) not null,	--����/�����������ģ��ʹ�õ��ı�ID
	ctrolName varchar(30) not null,	--����/������ؼ�����

	fieldName varchar(30) null,		--��Ӧ���ֶ���
	defaultText nvarchar(256),		--Ĭ���ı�
	mask varchar(30),				--��Ĥ��
	maxLen int default(256),		--��󳤶�
	reg varchar(1024),				--��֤������ʽ
	validatorFun varchar(32),		--��֤�ú�������ע��reg���ȣ�
CONSTRAINT [PK_ctrolTextbox] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[formID] ASC,
	[ctrolName] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[ctrolTextbox] WITH CHECK ADD CONSTRAINT [FK_formCtrolList_ctrolTextbox] FOREIGN KEY([templateID],[formID],[ctrolName])
REFERENCES [dbo].[formCtrolList] ([templateID],[formID],[ctrolName])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ctrolTextbox] CHECK CONSTRAINT [FK_formCtrolList_ctrolTextbox] 
GO

--3.4.�����ı������������
drop table ctrolTextArea
CREATE TABLE ctrolTextArea(
	templateID varchar(10) not null,--����/�����������ģ����
	formID varchar(10) not null,	--����/�����������ģ��ʹ�õ��ı�ID
	ctrolName varchar(30) not null,	--����/������ؼ�����

	fieldName varchar(30) null,		--��Ӧ���ֶ���
	defaultText nvarchar(256),		--Ĭ���ı�
	maxLen int default(256),		--��󳤶�
	reg varchar(1024),				--��֤������ʽ
	validatorFun varchar(32),		--��֤�ú�������ע��reg���ȣ�
CONSTRAINT [PK_ctrolTextArea] PRIMARY KEY CLUSTERED 
(
	[templateID] ASC,
	[formID] ASC,
	[ctrolName] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--�����
ALTER TABLE [dbo].[ctrolTextArea] WITH CHECK ADD CONSTRAINT [FK_formCtrolList_ctrolTextArea] FOREIGN KEY([templateID],[formID],[ctrolName])
REFERENCES [dbo].[formCtrolList] ([templateID],[formID],[ctrolName])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ctrolTextArea] CHECK CONSTRAINT [FK_formCtrolList_ctrolTextArea] 
GO


drop PROCEDURE queryWorkFlowTemplateLocMan
/*
	name:		queryWorkFlowTemplateLocMan
	function:	1.��ѯָ���Ĺ�����ģ���Ƿ��������ڱ༭
	input: 
				@templateID varchar(10),--������ģ����
	output: 
				@Ret		int output	--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ĺ�����ģ�岻����
				@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2014-1-1
	UpdateDate: 
*/
create PROCEDURE queryWorkFlowTemplateLocMan
	@templateID varchar(10),	--������ģ����
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from workFlowTemplate where templateID= @templateID),'')
	set @Ret = 0
GO


drop PROCEDURE lockWorkFlowTemplate4Edit
/*
	name:		lockWorkFlowTemplate4Edit
	function:	2.����������ģ��༭������༭��ͻ
	input: 
				@templateID varchar(10),		--������ģ����
				@lockManID varchar(10) output,	--�����ˣ������ǰ������ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ĺ�����ģ�岻���ڣ�2:Ҫ�����Ĺ�����ģ�����ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2014-1-1
	UpdateDate: 
*/
create PROCEDURE lockWorkFlowTemplate4Edit
	@templateID varchar(10),	--������ģ����
	@lockManID varchar(10) output,	--�����ˣ������ǰ������ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ĺ�����ģ���Ƿ����
	declare @count as int
	set @count=(select count(*) from workFlowTemplate where templateID= @templateID)
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	select @thisLockMan = isnull(lockManID,'') from workFlowTemplate where templateID= @templateID
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update workFlowTemplate 
	set lockManID = @lockManID 
	where templateID= @templateID
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
	values(@lockManID, @lockManName, getdate(), '����������ģ��༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˹�����ģ��['+ @templateID +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockWorkFlowTemplateEditor
/*
	name:		unlockWorkFlowTemplateEditor
	function:	3.�ͷŹ�����ģ��༭��
				ע�⣺�����̲���鹤����ģ���Ƿ���ڣ�
	input: 
				@templateID varchar(10),		--������ģ����
				@lockManID varchar(10) output,	--�����ˣ������ǰ������ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2014-1-1
	UpdateDate: 
*/
create PROCEDURE unlockWorkFlowTemplateEditor
	@templateID varchar(10),		--������ģ����
	@lockManID varchar(10) output,	--�����ˣ������ǰ������ģ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from workFlowTemplate where templateID= @templateID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update workFlowTemplate set lockManID = '' where templateID= @templateID
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
	values(@lockManID, @lockManName, getdate(), '�ͷŹ�����ģ��༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˹�����ģ��['+ @templateID +']�ı༭����')
GO

drop PROCEDURE addWorkFlowTemplate
/*
	name:		addWorkFlowTemplate
	function:	4.��ӹ�����ģ��
	input: 
				@templateName nvarchar(60),		--ģ������
				@formDBTable varchar(30),		--�����ݿ����
				@createFormID varchar(10),		--������ģ��ʹ�õĴ����ĵ��ı�ID
				@completedFormID varchar(10),	--������ģ��ʹ�õ�����ĵ�����ʾ��ID
				@stopFormID varchar(10),		--������ģ��ʹ�õ���ֹ�ĵ�����ʾ��ID
				@showFormID varchar(10),		--������ģ��ʹ�õ�ͨ�õ��ĵ�����ʾ��ID

				--����ģ��ʹ�������ƣ�add by lw 2013-2-20
				@templateRole xml,				--����ģ��ʹ���˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
												--roleΪ��������ɫ������еĽ�ɫ
												--sysRoleΪϵͳ��ɫ���еĽ�ɫ
												--userΪϵͳ�е��û�
												--exceptUserΪ������Ա
				@templateLogo varchar(128),		--ģ������ͼƬ
				@templateIntroImage varchar(128),--ģ�����ͼƬ
				
				@createrID varchar(10),			--�����˹���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@templateID varchar(10) output	--������������ģ����,��ϵͳʹ�õ� �ź��뷢����������'WF'+4λ��ݴ���+4λ��ˮ�ţ�
	author:		¬έ
	CreateDate:	2014-1-1
*/
create PROCEDURE addWorkFlowTemplate
	@templateName nvarchar(60),		--ģ������
	@formDBTable varchar(30),		--�����ݿ����
	@createFormID varchar(10),		--������ģ��ʹ�õĴ����ĵ��ı�ID
	@completedFormID varchar(10),	--������ģ��ʹ�õ�����ĵ�����ʾ��ID
	@stopFormID varchar(10),		--������ģ��ʹ�õ���ֹ�ĵ�����ʾ��ID
	@showFormID varchar(10),		--������ģ��ʹ�õ�ͨ�õ��ĵ�����ʾ��ID

	--����ģ��ʹ�������ƣ�add by lw 2013-2-20
	@templateRole xml,				--����ģ��ʹ���˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
									--roleΪ��������ɫ������еĽ�ɫ
									--sysRoleΪϵͳ��ɫ���еĽ�ɫ
									--userΪϵͳ�е��û�
									--exceptUserΪ������Ա
	@templateLogo varchar(128),		--ģ������ͼƬ
	@templateIntroImage varchar(128),--ģ�����ͼƬ
	
	@createrID varchar(10),			--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@templateID varchar(10) output	--������������ģ����,��ϵͳʹ�õ� �ź��뷢����������'WF'+4λ��ݴ���+4λ��ˮ�ţ�
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
	@templateID varchar(10) output	--������������ģ����,��ϵͳʹ�õ� �ź��뷢����������'WF'+4λ��ݴ���+4λ��ˮ�ţ�,��ʱ���ֹ�ά��
	@templateName nvarchar(60),		--ģ������
	@formDBTable varchar(30),		--�����ݿ����
	@createFormID varchar(10),		--������ģ��ʹ�õĴ����ĵ��ı�ID
	@completedFormID varchar(10),	--������ģ��ʹ�õ�����ĵ�����ʾ��ID
	@stopFormID varchar(10),		--������ģ��ʹ�õ���ֹ�ĵ�����ʾ��ID
	@showFormID varchar(10),		--������ģ��ʹ�õ�ͨ�õ��ĵ�����ʾ��ID

	--����ģ��ʹ�������ƣ�add by lw 2013-2-20
	@templateRole xml,				--����ģ��ʹ���˵Ľ�ɫ������'<root><role id="100" desc="ȫ����Ա"></roleID></root>'��ʽ���
									--roleΪ��������ɫ������еĽ�ɫ
									--sysRoleΪϵͳ��ɫ���еĽ�ɫ
									--userΪϵͳ�е��û�
									--exceptUserΪ������Ա
	@templateLogo varchar(128),		--ģ������ͼƬ
	@templateIntroImage varchar(128),--ģ�����ͼƬ
	
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


--3.������ģ������壺һ��������ģ����������
select * from workFlowTemplateForms
delete workFlowTemplateForms
--�������������
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130001', 'FM20130001',1,'�½������','../workFlowDoc/addLeave.html')
--�������ʾҳ�棺
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130001', 'FM20130002',0,'��ʾ�����','../workFlowDoc/leaveDetail.html')
--������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130001', 'FM20130003',1,'�༭�����','../workFlowDoc/editLeave.html')

--�豸�ɹ��������������
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130002', 'FM20130010',1,'�½��豸�ɹ����뵥','../workFlowDoc/addEqpApply.html')
--�豸�ɹ�������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130002', 'FM20130011',1,'�༭�豸�ɹ����뵥', '../workFlowDoc/editEqpApply.html')
--�豸�ɹ�������б�����Ϣ�������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130002', 'FM20130012',1,'��豸�б���Ϣ', '../workFlowDoc/editEqpApply2.html')
--�豸�ɹ��������ʾҳ�棺
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130002', 'FM20130013',0,'��ʾ�豸�ɹ����뵥','../workFlowDoc/eqpApplyDetail.html')

--���ķ��������������
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130003', 'FM20130020',1,'�½����ķ�������','../workFlowDoc/addThesisApply.html')
--���ķ��������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130003', 'FM20130021',1,'�༭���ķ�������', '../workFlowDoc/editThesisApply.html')
--���ķ����������ʾҳ�棺
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130003', 'FM20130022',0,'��ʾ���ķ�������','../workFlowDoc/thesisApplyDetail.html')


--����ӹ������������
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130004', 'FM20130030',1,'��������ӹ�����','../workFlowDoc/addWorkshopApply.html')
--����ӹ������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130004', 'FM20130031',1,'�༭����ӹ�����','../workFlowDoc/editWorkshopApply.html')
--����ӹ������ӹ�״̬�����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130004', 'FM20130032',1,'�����ӹ������ӹ�״̬','../workFlowDoc/addWorkshopStatus.html')
--����ӹ��������ʾҳ�棺
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130004', 'FM20130033',0,'��ʾ����ӹ�����','../workFlowDoc/workshopApplyDetail.html')

--���������������
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130005', 'FM20130040',1,'������������','../workFlowDoc/addOhterApply.html')
--���������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130005', 'FM20130041',1,'�༭��������','../workFlowDoc/editOhterApply.html')
--�����������ʾҳ�棺
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130005', 'FM20130042',0,'��ʾ��������','../workFlowDoc/otherApplyDetail.html')

--�豸�ɹ�����2����������
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130006', 'FM20130010',1,'�½��豸�ɹ����뵥','../workFlowDoc/addEqpApply.html')
--�豸�ɹ�������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130006', 'FM20130011',1,'�༭�豸�ɹ����뵥', '../workFlowDoc/editEqpApply.html')
--�豸�ɹ�������б�����Ϣ�������༭����
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130006', 'FM20130012',1,'��豸�б���Ϣ', '../workFlowDoc/editEqpApply2.html')
--�豸�ɹ��������ʾҳ�棺
insert workFlowTemplateForms(templateID, formID, formType, formName, formPageFile)
values('WF20130006', 'FM20130013',0,'��ʾ�豸�ɹ����뵥','../workFlowDoc/eqpApplyDetail.html')

