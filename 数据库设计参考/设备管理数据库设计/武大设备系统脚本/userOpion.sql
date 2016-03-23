use epdc211
/*
	����豸������Ϣϵͳ-�û����Ի�����
	author:		¬έ
	CreateDate:	2012-3-15
	UpdateDate: modi by lw 2012-5-21������óϵͳ�������һ�»���
*/
--�û����Ի����ñ�
select * from  userOption
drop TABLE userOption
CREATE TABLE userOption
(
	rowNum int default(0),				--���:Ϊ�˱�֤�û���¼ʱȡ����Ŀ�����ʽ������
	userID varchar(10) not null,		--�û�����
	userName varchar(30) not null,		--�û���
	userCName nvarchar(30) not null,	--�û�������
	userIP varchar(40) not null,		--�Ự�ͻ���IP

	privateTheme varchar(128),			--�û����Ի����⣨��ʽ��·����
	privateDialogStyle varchar(128),	--�û����Ի��Ի��Ϸ��
	privateDialogSkin varchar(128),		--�û����Ի��Ի���Ƥ��
	
	--����Ϊ����Ի����ڵ����֡��߿���������ɫ��Ԫ����ʽ��
	privateFormCss varchar(8000),		--�û����Ի�ҵ�����ʽ��
	privateReadOnlyFormCss varchar(8000),	--�û����Ի�ֻ��ҵ�����ʽ��
	privateDialogCss varchar(8000),		--�û����Ի��Ի�����ʽ��

CONSTRAINT [PK_userOption] PRIMARY KEY CLUSTERED 
(
	[userID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
CREATE NONCLUSTERED INDEX [IX_userOption] ON [dbo].[userOption] 
(
	[userIP] ASC,
	[rowNum] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select * from userOption

drop PROCEDURE setOption
/*
	name:		setOption
	function:	1.�����û����Ի�����
				ע�⣺��Ϊ������ù�������û�з��ֲ������������û��������
	input: 
				@userID varchar(10),				--�û�����
				@userIP varchar(40),				--�Ự�ͻ���IP
				@privateTheme varchar(128),			--�û����Ի���ʽ��·��
				@privateDialogStyle varchar(128),	--�û����Ի��Ի��Ϸ��
				@privateDialogSkin varchar(128),	--�û����Ի��Ի���Ƥ��
				@privateFormCss varchar(8000),		--�û����Ի�ҵ�����ʽ��
				@privateReadOnlyFormCss varchar(8000),--�û����Ի�ֻ��ҵ�����ʽ��
				@privateDialogCss varchar(8000),	--�û����Ի��Ի�����ʽ��
	output: 
				@Ret int output				--�����ɹ���ʶ��0:�ɹ���9������
	author:		¬έ
	CreateDate:	2012-4-18
	UpdateDate: modi by lw 2012-5-20��չ���Ի�������֧�ֶԻ��Ϸ�񡢶Ի���Ƥ���Ѿ�Ԫ�ص���ʽ
*/
create PROCEDURE setOption
	@userID varchar(10),				--�û�����
	@userIP varchar(40),				--�Ự�ͻ���IP
	@privateTheme varchar(128),			--�û����Ի���ʽ��·��
	@privateDialogStyle varchar(128),	--�û����Ի��Ի��Ϸ��
	@privateDialogSkin varchar(128),	--�û����Ի��Ի���Ƥ��
	@privateFormCss varchar(8000),		--�û����Ի�ҵ�����ʽ��
	@privateReadOnlyFormCss varchar(8000),--�û����Ի�ֻ��ҵ�����ʽ��
	@privateDialogCss varchar(8000),	--�û����Ի��Ի�����ʽ��
	@Ret int output						--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ȡ�û�����������
	declare @userName varchar(30), @userCName nvarchar(30)	--�û���/�û�������
	select @userName = sysUserName, @userCName = cName from userInfo where jobNumber = @userID

	--ɾ�����û���ԭ�趨��
	delete userOption where userID = @userID
	
	--����IP�ϵĸ��Ի�������������
	update userOption
	set rowNum = s.RowID
	from userOption u left join (select ROW_NUMBER() OVER(order by rowNum) AS RowID, userID
									from userOption where userIP = @userIP) as s on u.userID = s.userID
	where u.userIP = @userIP
	
	insert userOption(userID, userName, userCName, userIP, 
			privateTheme, privateDialogStyle, privateDialogSkin, 
			privateFormCss, privateReadOnlyFormCss, privateDialogCss)
	values(@userID, @userName, @userCName, @userIP, 
			@privateTheme, @privateDialogStyle, @privateDialogSkin, 
			@privateFormCss, @privateReadOnlyFormCss, @privateDialogCss)
	if @@ERROR <> 0 
	begin
		return
	end    
	set @Ret = 0
GO


drop PROCEDURE updateUserLoginIP
/*
	name:		updateUserLoginIP
	function:	2.�����û���¼IP��������ڸ��û��ĸ��Ի����ã���������Ϊ��IP��Ĭ������
				ע�⣺��Ϊ������ù�������û�з��ֲ������������û��������
	input: 
				@userID varchar(10),				--�û�����
				@userIP varchar(40),				--�Ự�ͻ���IP
	output: 
				@Ret int output						--�����ɹ���ʶ��0:�ɹ���1:���û�û�и��Ի����ã�9������
	author:		¬έ
	CreateDate:	2012-5-21
	UpdateDate: 
*/
create PROCEDURE updateUserLoginIP
	@userID varchar(10),				--�û�����
	@userIP varchar(40),				--�Ự�ͻ���IP
	@Ret int output						--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	declare @count as int
	set @count = (select count(*) from userOption where userID = @userID)
	if (@count = 0)
	begin
		set @Ret = 1
		return
	end
	
	--����IP�ϵĸ��Ի�������������
	update userOption
	set rowNum = s.RowID
	from userOption u left join (select ROW_NUMBER() OVER(order by rowNum) AS RowID, userID
									from userOption where userIP = @userIP) as s on u.userID = s.userID
	where u.userIP = @userIP
	
	update userOption
	set userIP = @userIP, rowNum = 0
	where userID = @userID

	set @Ret = 0
GO
