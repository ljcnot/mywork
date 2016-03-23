use fTradeDB
/*
	�����ó��ͬ������Ϣϵͳ-����������
	���ݾ��õ�����Ϣϵͳ���豸����ϵͳ�ı�
	author:		¬έ
	CreateDate:	2011-7-6
	UpdateDate: modi by lw 2011-10-15�����û����洦��ظ����
*/

--1.userReport���û������������
drop TABLE userReport
CREATE TABLE userReport(
	reportID char(12) not null,		--�������û�������ţ�ʹ�õ�10000�ź��뷢����
	reportDate smalldatetime null,	--��������
	unitName nvarchar(30) not null,	--���ڵ�λ����
	reporterID varchar(10) null,	--�����˹���
	reporter nvarchar(30) null,		--������
	tel varchar(30) null,			--��ϵ�绰
	Email varchar(30) null,			--����
	title nvarchar(50) null,		--�������
	reportTag nvarchar(50) null,	--�������
	descTxt nvarchar(500) null,		--�������
	reportStatus int default(0),	--���״̬��0->δ����1->�Ѵ��� add by lw 2011-10-15
 CONSTRAINT [PK_userReport] PRIMARY KEY CLUSTERED 
(
	[reportID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
CREATE NONCLUSTERED INDEX [IX_userReport] ON [dbo].[userReport] 
(
	[unitName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_userReport2] ON [dbo].[userReport] 
(
	[reporterID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_userReport3] ON [dbo].[userReport] 
(
	[reportTag] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select * from userReport
select * from userReportAppendFile
--1.1.userReportAppendFile���û����������������
drop table userReportAppendFile
CREATE TABLE userReportAppendFile(
	rowNum int IDENTITY(1,1) NOT NULL,	--���:Ϊ�˱�֤�û����Ա༭��������ӵ��к� add by lw 2010-11-30
	fileGUID36 varchar(36) not NULL,	--������Ӧ��36λȫ��Ψһ�����ļ���
	oldFilename varchar(128) not null,	--ԭʼ�ļ���
	extFileName varchar(8) NULL,		--��������չ��
	reportID char(12) not null,			--������û��������
 CONSTRAINT [PK_userReportAppendFile] PRIMARY KEY CLUSTERED 
(
	[fileGUID36] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[userReportAppendFile] WITH CHECK ADD CONSTRAINT [FK_userReportAppendFile_userReport] FOREIGN KEY([reportID])
REFERENCES [dbo].[userReport] ([reportID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[userReportAppendFile] CHECK CONSTRAINT [FK_userReportAppendFile_userReport]
GO

	
drop TABLE userReportAnswer
CREATE TABLE userReportAnswer(
	rowNum int IDENTITY(1,1) NOT NULL,	--�к�
	reportID char(12) not null,		--������û��������
	answerDate smalldatetime null,	--�ظ�����
	unitName nvarchar(30) not null,	--���ڵ�λ����
	answerID varchar(10) null,		--�ظ��˹���
	answer nvarchar(30) null,		--�ظ���
	answerTag nvarchar(50) null,	--�ظ��������
	descTxt nvarchar(500) null,		--�ظ��������
 CONSTRAINT [PK_userReportAnswer] PRIMARY KEY CLUSTERED 
(
	[reportID] ASC,
	[rowNum] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--�����
ALTER TABLE [dbo].[userReportAnswer] WITH CHECK ADD CONSTRAINT [FK_userReportAnswer_userReport] FOREIGN KEY([reportID])
REFERENCES [dbo].[userReport] ([reportID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[userReportAnswer] CHECK CONSTRAINT [FK_userReportAnswer_userReport]
GO

drop PROCEDURE addUserReport
/*
	name:		addUserReport
	function:	1.����û��������
				ע�⣺���洢���̲������༭��
	input: 
				@unitName nvarchar(30),	--���ڵ�λ����
				@reporterID varchar(10),	--�����˹���
				@tel varchar(30),			--��ϵ�绰
				@Email varchar(30),			--����
				@title nvarchar(50),		--�������
				@reportTag nvarchar(50),	--�������
				@descTxt nvarchar(500),		--�������

	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
				@reportID char(12) output,	--�û��������
				@reportDate smalldatetime output--��������
	author:		¬έ
	CreateDate:	2011-7-6
	UpdateDate: modi by lw 2012-4-19�����µ�ϵͳ�û�����½ӿ�
*/
create PROCEDURE addUserReport
	@unitName nvarchar(30),	--���ڵ�λ����
	@reporterID varchar(10),	--�����˹���
	@tel varchar(30),			--��ϵ�绰
	@Email varchar(30),			--����
	@title nvarchar(50),		--�������
	@reportTag nvarchar(50),	--�������
	@descTxt nvarchar(500),		--�������

	@Ret		int output,
	@reportID char(12) output,	--�û��������
	@reportDate smalldatetime output--��������
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢���������µĺ��룺
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10000, 1, @curNumber output
	set @reportID = @curNumber

	--ȡά���˵�������
	declare @reporter nvarchar(30)		--����������
	select @reporter = cName from userInfo where jobNumber = @reporterID

	set @reportDate = getdate()
	insert userReport(reportID, reportDate, unitName,
						reporterID, reporter, tel, Email, title, reportTag, descTxt)
	values (@reportID, @reportDate, @unitName,
			@reporterID, @reporter, @tel, @Email, @title, @reportTag, @descTxt)

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@reporterID, @reporter, @reportDate, '�û�����', '�û�' + @reporter + 
					'�ύ�˱��Ϊ[' + @reportID + ']�ı��档')
GO
--���ԣ�
select * from userInfo where cName = '������'
select * from useUnit where clgCode = '000'

declare @Ret int, @reportID char(12), @reportDate smalldatetime
exec dbo.addUserReport '000', '00000', '00200977', '�������', '����ȱ��', '�����û������', @Ret output, @reportID output, @reportDate output
select @Ret, @reportID, @reportDate
select * from userReport



drop PROCEDURE addUserReportAppendFile
/*
	name:		1.1.addUserReportAppendFile
	function:	����û���������ĸ���
	input: 
				@reportID char(12),			--�û��������
				@oldFilename varchar(128),	--ԭʼ�ļ���
				@extFileName varchar(8),	--��������չ��
	output: 
				@Ret		int output,	--�����ɹ���ʶ
							0:�ɹ���9������
				@fileGUID36 varchar(36) output	--ϵͳ�����Ψһ�ļ���
	author:		¬έ
	CreateDate:	2011-7-6
	UpdateDate: 
*/
create PROCEDURE addUserReportAppendFile
	@reportID char(12),			--�û��������
	@oldFilename varchar(128),	--ԭʼ�ļ���
	@extFileName varchar(8),	--��������չ��

	@Ret int output,			--�����ɹ���ʶ
	@fileGUID36 varchar(36) output	--ϵͳ�����Ψһ�ļ���
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--����Ψһ���ļ�����
	set @fileGUID36 = (select newid())

	--�ǼǸ�����Ϣ��
	insert userReportAppendFile(fileGUID36, oldFilename, extFileName, reportID)
	values(@fileGUID36, @oldFilename, @extFileName, @reportID)
	set @Ret = 0
GO

select reportID, reportDate, clgCode, clgName, uCode, uName, 
	reporterID, reporter, title, reportTag, descTxt
from userReport

select reportID, convert(char(10), reportDate,120), clgCode, clgName, uCode, uName,reporterID, reporter, title, reportTag, descTxt 
from userReport
order by reportID desc


drop PROCEDURE delUserReport
/*
	name:		delUserReport
	function:	2.ɾ��ָ�����û��������
				ע�⣺�ô洢���̲���ɾ�������ļ���
	input: 
				@reportID char(12),			--�û��������
				@delManID varchar(10),		--ɾ����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1�����û���������ڣ�9��δ֪����
	author:		¬έ
	CreateDate:	2011-7-9
	UpdateDate: 
*/
create PROCEDURE delUserReport
	@reportID char(12),			--�û��������
	@delManID varchar(10),		--ɾ����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�ָ�����û���������Ƿ����
	declare @count as int
	set @count=(select count(*) from userReport where reportID = @reportID)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	delete userReport where reportID = @reportID --��������ɾ���������ļ������ֹ�ɾ��
	
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���û������', '�û�' + @delManName
												+ 'ɾ�����û������['+ @reportID +']����Ϣ��')

GO


drop PROCEDURE delUserReports
/*
	name:		delUserReports
	function:	3.ɾ��ָ����Χ���û��������
				ע�⣺�ô洢���̲���ɾ�������ļ���
	input: 
				@where varchar(4000),		--ָ����Χ
				@delManID varchar(10),		--ɾ����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2011-7-11
	UpdateDate: 
*/
create PROCEDURE delUserReports
	@where varchar(4000),		--ָ����Χ
	@delManID varchar(10),		--ɾ����
	@Ret		int output		--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	exec('delete userReport ' + @where) --��������ɾ���������ļ������ֹ�ɾ��
	
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ���û������', '�û�' + @delManName
												+ 'ɾ����['+ @where +']��Χ�ڵ������û������')

GO



drop PROCEDURE addUserReportAnswer
/*
	name:		addUserReportAnswer
	function:	1.����û���������ظ����
				ע�⣺���洢���̲������༭��
	input: 
				@reportID char(12),			--�û��������
				@answerID varchar(10),		--�ظ��˹���
				@answerTag nvarchar(50),	--�ظ��������
				@descTxt nvarchar(500),		--�ظ��������
	output: 
				@Ret		int output,		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
				@answerDate smalldatetime output	--�ظ�����
	author:		¬έ
	CreateDate:	2011-10-15
	UpdateDate: 
*/
create PROCEDURE addUserReportAnswer
	@reportID char(12),			--�û��������
	@answerID varchar(10),		--�ظ��˹���
	@answerTag nvarchar(50),	--�ظ��������
	@descTxt nvarchar(500),		--�ظ��������

	@Ret		int output,
	@answerDate smalldatetime output	--�ظ�����
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--ȡ�ظ��˵�������
	declare @answer nvarchar(30)		--�ظ�������
	select @answer = cName from userInfo where jobNumber = @answerID

	set @answerDate = getdate()
	begin tran
		insert userReportAnswer(reportID, answerDate, unitName,
								answerID, answer, answerTag, descTxt)
		select @reportID, @answerDate, unitName,
				userID, cName, @answerTag, @descTxt 
		from sysUserInfo
		where userID = @answerID
		if @@ERROR <> 0 
		begin
			rollback tran
			return
		end    
		
		update userReport
		set reportStatus = 1
		where reportID = @reportID
	commit tran
	
	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@answerID, @answer, @answerDate, '�ظ��û�����', '�û�' + @answer + 
					'�ظ��˱��Ϊ[' + @reportID + ']�ı��档')
GO

--���ԣ�
select * from userInfo where cName = '������'
select * from useUnit where clgCode = '000'

select * from userReport
declare @Ret int, @reportDate smalldatetime
exec dbo.addUserReportAnswer '201107070004', '00200977', '�������', '���Իظ��û������', @Ret output, @reportDate output
select @Ret, @reportDate
select * from userReportAnswer





--���ϵͳ�����������
select count(*) from master.dbo.sysprocesses where dbid=db_id()
select @@max_connections
