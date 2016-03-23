use fTradeDB
/*
	�����ó��ͬ������Ϣϵͳ--�û����Ի�����
	author:		¬έ
	CreateDate:	2012-4-18 ������豸����ϵͳ��ֲ
	UpdateDate: 
*/
------------------������ϵͳ�������ñ��ṩUI���û����ã��ɹ�˾ά��--------------------------------------
--ϵͳ�����
drop TABLE sysTheme
CREATE TABLE sysTheme
(
	rowNum int IDENTITY(1,1) NOT NULL,	--���
	themeName varchar(30) not null,		--��������������
	themeCName nvarchar(30) not null,	--������������
	isDefault char(1) default('N')		--�Ƿ�ΪĬ������

CONSTRAINT [PK_sysTheme] PRIMARY KEY CLUSTERED 
(
	[themeName] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

insert sysTheme(themeName, themeCName, isDefault)
values('springBreezeCss','Ц������','Y')
insert sysTheme(themeName, themeCName)
values('metalTextureCss','�����ʸ�')
insert sysTheme(themeName, themeCName)
values('crazyMosaicCss','���������')
insert sysTheme(themeName, themeCName)
values('dazzlBlueCss','����')
insert sysTheme(themeName, themeCName)
values('hyunPurpleCss','����')
insert sysTheme(themeName, themeCName)
values('hyunRedCss','�ź�')
insert sysTheme(themeName, themeCName)
values('inkCss','ˮīɽˮ')
insert sysTheme(themeName, themeCName)
values('whuCss','�ҵ����')

select * from sysTheme

--ϵͳ�Ի��Ͽ�ܱ�
drop TABLE sysDialogFrame
CREATE TABLE sysDialogFrame
(
	rowNum int IDENTITY(1,1) NOT NULL,	--���
	frameName varchar(30) not null,		--�������Ի��Ͽ������
	frameCName nvarchar(30) not null,	--�Ի��Ͽ����������
	default4Theme varchar(300) default('')--����Щ�����Ĭ�Ͽ�ܣ����������á�,���ָ�

CONSTRAINT [PK_sysDialogFrame] PRIMARY KEY CLUSTERED 
(
	[frameName] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

insert sysDialogFrame(frameName,frameCName,default4Theme)
values ('iMacStyle','ƻ�����','springBreezeCss,crazyMosaicCss,hyunRedCss')
insert sysDialogFrame(frameName,frameCName,default4Theme)
values ('xpStyle','XP���','metalTextureCss,')
insert sysDialogFrame(frameName,frameCName,default4Theme)
values ('classiclStyle','������','dazzlBlueCss,hyunPurpleCss')
insert sysDialogFrame(frameName,frameCName,default4Theme)
values ('simpleStyle','��Լ���','inkCss,whuCss')

select * from sysDialogFrame
--ϵͳ�Ի��Ͽ�Ƥ����
drop TABLE sysDialogSkin
CREATE TABLE sysDialogSkin
(
	rowNum int IDENTITY(1,1) NOT NULL,	--���
	frameName varchar(30) not null,		--���/�����������Ի��Ͽ������
	skinName varchar(30) not null,		--�������Ի���Ƥ������
	skinCName nvarchar(30) not null,	--�Ի���Ƥ����������
	default4Theme varchar(300) default('')--����Щ�����Ĭ�Ͽ�ܣ����������á�,���ָ�

CONSTRAINT [PK_sysDialogSkin] PRIMARY KEY CLUSTERED 
(
	[frameName] asc,
	[skinName] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
ALTER TABLE [dbo].[sysDialogSkin] WITH CHECK ADD CONSTRAINT [FK_sysDialogSkin_sysDialogFrame] FOREIGN KEY([frameName])
REFERENCES [dbo].[sysDialogFrame] ([frameName])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysDialogSkin] CHECK CONSTRAINT [FK_sysDialogSkin_sysDialogFrame]
GO

insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','springClassicl','Ц������','springBreezeCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','metalTextureClassicl','�����ʸ�','metalTextureCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','crazyMosaicClassicl','���������','crazyMosaicCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','blueClassicl','����','dazzlBlueCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','purpleClassicl','����','hyunPurpleCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','paperCutClassicl','��ֽ','hyunRedCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','inkClassicl','ˮīɽˮ','inkCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','whuClassicl','�ҵ����','whuCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','defaultClassicl','Ĭ��','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','blueClassicl','��ɫ����','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','cyanblueClassicl','���ž���','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','discuzClassicl','���ž���','')
		
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','springSimple','Ц������','springBreezeCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','metalTextureSimple','�����ʸ�','metalTextureCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','crazyMosaicSimple','���������','crazyMosaicCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','blueSimple','����','dazzlBlueCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','purpleSimple','����','hyunPurpleCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','paperCutSimple','��ֽ','hyunRedCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','inkSimple','ˮīɽˮ','inkCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','whuSimple','�ҵ����','whuCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','blackSimple','��ɫ��Լ','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','blueSimple','��ɫ��Լ','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','greenSimple','��ɫ��Լ','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','macSimple','��ɫ��Լ','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','jtopSimple','���ż�Լ','')

insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','springIMac','Ц������','springBreezeCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','metalTextureIMac','�����ʸ�','metalTextureCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','crazyMosaicIMac','���������','crazyMosaicCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','blueIMac','����','dazzlBlueCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','purpleIMac','����','hyunPurpleCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','paperCutIMac','��ֽ','hyunRedCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','inkIMac','ˮīɽˮ','inkCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','whuIMac','�ҵ����','whuCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','idialog','ƻ����','')

insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','springXP','Ц������','springBreezeCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','metalTextureXP','�����ʸ�','metalTextureCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','crazyMosaicXP','���������','crazyMosaicCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','blueXP','����','dazzlBlueCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','purpleXP','����','hyunPurpleCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','paperCutXP','��ֽ','hyunRedCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','inkXP','ˮīɽˮ','inkCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','whuXP','�ҵ����','whuCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','chrome','�ȸ�','')

select * from sysDialogSkin

------------------������ϵͳ�������ñ��ṩUI���û����ã��ɹ�˾ά��--------------------------------------


--�û����Ի����ñ�
select * from userOption
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
	select @userName = sysUserName, @userCName = cName from sysUserInfo where userID = @userID

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
