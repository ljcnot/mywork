use fTradeDB
/*
	武大外贸合同管理信息系统--用户个性化设置
	author:		卢苇
	CreateDate:	2012-4-18 自武大设备管理系统移植
	UpdateDate: 
*/
------------------换肤的系统参数设置表不提供UI给用户设置，由公司维护--------------------------------------
--系统主题表：
drop TABLE sysTheme
CREATE TABLE sysTheme
(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号
	themeName varchar(30) not null,		--主键：主题名称
	themeCName nvarchar(30) not null,	--主题中文名称
	isDefault char(1) default('N')		--是否为默认主题

CONSTRAINT [PK_sysTheme] PRIMARY KEY CLUSTERED 
(
	[themeName] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

insert sysTheme(themeName, themeCName, isDefault)
values('springBreezeCss','笑傲春风','Y')
insert sysTheme(themeName, themeCName)
values('metalTextureCss','金属质感')
insert sysTheme(themeName, themeCName)
values('crazyMosaicCss','疯狂马赛克')
insert sysTheme(themeName, themeCName)
values('dazzlBlueCss','炫蓝')
insert sysTheme(themeName, themeCName)
values('hyunPurpleCss','炫紫')
insert sysTheme(themeName, themeCName)
values('hyunRedCss','炫红')
insert sysTheme(themeName, themeCName)
values('inkCss','水墨山水')
insert sysTheme(themeName, themeCName)
values('whuCss','我的武大')

select * from sysTheme

--系统对话合框架表：
drop TABLE sysDialogFrame
CREATE TABLE sysDialogFrame
(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号
	frameName varchar(30) not null,		--主键：对话合框架名称
	frameCName nvarchar(30) not null,	--对话合框架中文名称
	default4Theme varchar(300) default('')--是那些主题的默认框架：多个主题采用“,”分隔

CONSTRAINT [PK_sysDialogFrame] PRIMARY KEY CLUSTERED 
(
	[frameName] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

insert sysDialogFrame(frameName,frameCName,default4Theme)
values ('iMacStyle','苹果风格','springBreezeCss,crazyMosaicCss,hyunRedCss')
insert sysDialogFrame(frameName,frameCName,default4Theme)
values ('xpStyle','XP风格','metalTextureCss,')
insert sysDialogFrame(frameName,frameCName,default4Theme)
values ('classiclStyle','经典风格','dazzlBlueCss,hyunPurpleCss')
insert sysDialogFrame(frameName,frameCName,default4Theme)
values ('simpleStyle','简约风格','inkCss,whuCss')

select * from sysDialogFrame
--系统对话合框皮肤：
drop TABLE sysDialogSkin
CREATE TABLE sysDialogSkin
(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号
	frameName varchar(30) not null,		--外键/主键：所属对话合框架名称
	skinName varchar(30) not null,		--主键：对话合皮肤名称
	skinCName nvarchar(30) not null,	--对话合皮肤中文名称
	default4Theme varchar(300) default('')--是那些主题的默认框架：多个主题采用“,”分隔

CONSTRAINT [PK_sysDialogSkin] PRIMARY KEY CLUSTERED 
(
	[frameName] asc,
	[skinName] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--级联：
ALTER TABLE [dbo].[sysDialogSkin] WITH CHECK ADD CONSTRAINT [FK_sysDialogSkin_sysDialogFrame] FOREIGN KEY([frameName])
REFERENCES [dbo].[sysDialogFrame] ([frameName])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[sysDialogSkin] CHECK CONSTRAINT [FK_sysDialogSkin_sysDialogFrame]
GO

insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','springClassicl','笑傲春风','springBreezeCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','metalTextureClassicl','金属质感','metalTextureCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','crazyMosaicClassicl','疯狂马赛克','crazyMosaicCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','blueClassicl','炫蓝','dazzlBlueCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','purpleClassicl','炫紫','hyunPurpleCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','paperCutClassicl','剪纸','hyunRedCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','inkClassicl','水墨山水','inkCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','whuClassicl','我的武大','whuCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','defaultClassicl','默认','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','blueClassicl','蓝色经典','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','cyanblueClassicl','淡雅经典','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('classiclStyle','discuzClassicl','素雅经典','')
		
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','springSimple','笑傲春风','springBreezeCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','metalTextureSimple','金属质感','metalTextureCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','crazyMosaicSimple','疯狂马赛克','crazyMosaicCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','blueSimple','炫蓝','dazzlBlueCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','purpleSimple','炫紫','hyunPurpleCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','paperCutSimple','剪纸','hyunRedCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','inkSimple','水墨山水','inkCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','whuSimple','我的武大','whuCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','blackSimple','黑色简约','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','blueSimple','蓝色简约','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','greenSimple','绿色简约','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','macSimple','灰色简约','')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('simpleStyle','jtopSimple','优雅简约','')

insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','springIMac','笑傲春风','springBreezeCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','metalTextureIMac','金属质感','metalTextureCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','crazyMosaicIMac','疯狂马赛克','crazyMosaicCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','blueIMac','炫蓝','dazzlBlueCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','purpleIMac','炫紫','hyunPurpleCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','paperCutIMac','剪纸','hyunRedCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','inkIMac','水墨山水','inkCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','whuIMac','我的武大','whuCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('iMacStyle','idialog','苹果风','')

insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','springXP','笑傲春风','springBreezeCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','metalTextureXP','金属质感','metalTextureCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','crazyMosaicXP','疯狂马赛克','crazyMosaicCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','blueXP','炫蓝','dazzlBlueCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','purpleXP','炫紫','hyunPurpleCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','paperCutXP','剪纸','hyunRedCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','inkXP','水墨山水','inkCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','whuXP','我的武大','whuCss')
insert sysDialogSkin(frameName, skinName, skinCName, default4Theme)
values('xpStyle','chrome','谷歌','')

select * from sysDialogSkin

------------------换肤的系统参数设置表不提供UI给用户设置，由公司维护--------------------------------------


--用户个性化设置表：
select * from userOption
drop TABLE userOption
CREATE TABLE userOption
(
	rowNum int default(0),				--序号:为了保证用户登录时取最近的可能样式而增加
	userID varchar(10) not null,		--用户工号
	userName varchar(30) not null,		--用户名
	userCName nvarchar(30) not null,	--用户中文名
	userIP varchar(40) not null,		--会话客户端IP

	privateTheme varchar(128),			--用户个性化主题（样式表路径）
	privateDialogStyle varchar(128),	--用户个性化对话合风格
	privateDialogSkin varchar(128),		--用户个性化对话合皮肤
	
	--以下为定义对话合内的文字、边框、输入栏底色等元素样式：
	privateFormCss varchar(8000),		--用户个性化业务表单样式表
	privateReadOnlyFormCss varchar(8000),	--用户个性化只读业务表单样式表
	privateDialogCss varchar(8000),		--用户个性化对话合样式表

CONSTRAINT [PK_userOption] PRIMARY KEY CLUSTERED 
(
	[userID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
CREATE NONCLUSTERED INDEX [IX_userOption] ON [dbo].[userOption] 
(
	[userIP] ASC,
	[rowNum] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select * from userOption

drop PROCEDURE setOption
/*
	name:		setOption
	function:	1.设置用户个性化参数
				注意：因为这个设置过程现在没有发现并发情况，所以没有上锁。
	input: 
				@userID varchar(10),				--用户工号
				@userIP varchar(40),				--会话客户端IP
				@privateTheme varchar(128),			--用户个性化样式表路径
				@privateDialogStyle varchar(128),	--用户个性化对话合风格
				@privateDialogSkin varchar(128),	--用户个性化对话合皮肤
				@privateFormCss varchar(8000),		--用户个性化业务表单样式表
				@privateReadOnlyFormCss varchar(8000),--用户个性化只读业务表单样式表
				@privateDialogCss varchar(8000),	--用户个性化对话合样式表
	output: 
				@Ret int output				--操作成功标识：0:成功，9：出错
	author:		卢苇
	CreateDate:	2012-4-18
	UpdateDate: modi by lw 2012-5-20扩展个性化参数，支持对话合风格、对话合皮肤已经元素的样式
*/
create PROCEDURE setOption
	@userID varchar(10),				--用户工号
	@userIP varchar(40),				--会话客户端IP
	@privateTheme varchar(128),			--用户个性化样式表路径
	@privateDialogStyle varchar(128),	--用户个性化对话合风格
	@privateDialogSkin varchar(128),	--用户个性化对话合皮肤
	@privateFormCss varchar(8000),		--用户个性化业务表单样式表
	@privateReadOnlyFormCss varchar(8000),--用户个性化只读业务表单样式表
	@privateDialogCss varchar(8000),	--用户个性化对话合样式表
	@Ret int output						--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--取用户名和姓名：
	declare @userName varchar(30), @userCName nvarchar(30)	--用户名/用户中文名
	select @userName = sysUserName, @userCName = cName from sysUserInfo where userID = @userID

	--删除该用户的原设定：
	delete userOption where userID = @userID
	
	--将该IP上的个性化设置重新排序：
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
	function:	2.更新用户登录IP，如果存在该用户的个性化设置，将其设置为该IP的默认设置
				注意：因为这个设置过程现在没有发现并发情况，所以没有上锁。
	input: 
				@userID varchar(10),				--用户工号
				@userIP varchar(40),				--会话客户端IP
	output: 
				@Ret int output						--操作成功标识：0:成功，1:该用户没有个性化设置，9：出错
	author:		卢苇
	CreateDate:	2012-5-21
	UpdateDate: 
*/
create PROCEDURE updateUserLoginIP
	@userID varchar(10),				--用户工号
	@userIP varchar(40),				--会话客户端IP
	@Ret int output						--操作成功标识
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
	
	--将该IP上的个性化设置重新排序：
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
