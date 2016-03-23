use fTradeDB
/*
	武大外贸合同管理信息系统-其他辅助表
	根据警用地理信息系统、设备管理系统改编
	author:		卢苇
	CreateDate:	2011-7-6
	UpdateDate: modi by lw 2011-10-15增加用户报告处理回复意见
*/

--1.userReport（用户意见回馈表）：
drop TABLE userReport
CREATE TABLE userReport(
	reportID char(12) not null,		--主键：用户意见单号，使用第10000号号码发生器
	reportDate smalldatetime null,	--报告日期
	unitName nvarchar(30) not null,	--所在单位名称
	reporterID varchar(10) null,	--报告人工号
	reporter nvarchar(30) null,		--报告人
	tel varchar(30) null,			--联系电话
	Email varchar(30) null,			--邮箱
	title nvarchar(50) null,		--意见标题
	reportTag nvarchar(50) null,	--意见分类
	descTxt nvarchar(500) null,		--意见描述
	reportStatus int default(0),	--意见状态：0->未处理，1->已处理 add by lw 2011-10-15
 CONSTRAINT [PK_userReport] PRIMARY KEY CLUSTERED 
(
	[reportID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--索引：
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
--1.1.userReportAppendFile（用户意见回馈表附件表）：
drop table userReportAppendFile
CREATE TABLE userReportAppendFile(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	fileGUID36 varchar(36) not NULL,	--附件对应的36位全球唯一编码文件名
	oldFilename varchar(128) not null,	--原始文件名
	extFileName varchar(8) NULL,		--附件的扩展名
	reportID char(12) not null,			--外键：用户意见单号
 CONSTRAINT [PK_userReportAppendFile] PRIMARY KEY CLUSTERED 
(
	[fileGUID36] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[userReportAppendFile] WITH CHECK ADD CONSTRAINT [FK_userReportAppendFile_userReport] FOREIGN KEY([reportID])
REFERENCES [dbo].[userReport] ([reportID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[userReportAppendFile] CHECK CONSTRAINT [FK_userReportAppendFile_userReport]
GO

	
drop TABLE userReportAnswer
CREATE TABLE userReportAnswer(
	rowNum int IDENTITY(1,1) NOT NULL,	--行号
	reportID char(12) not null,		--外键：用户意见单号
	answerDate smalldatetime null,	--回复日期
	unitName nvarchar(30) not null,	--所在单位名称
	answerID varchar(10) null,		--回复人工号
	answer nvarchar(30) null,		--回复人
	answerTag nvarchar(50) null,	--回复意见分类
	descTxt nvarchar(500) null,		--回复意见描述
 CONSTRAINT [PK_userReportAnswer] PRIMARY KEY CLUSTERED 
(
	[reportID] ASC,
	[rowNum] asc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
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
	function:	1.添加用户报告意见
				注意：本存储过程不锁定编辑！
	input: 
				@unitName nvarchar(30),	--所在单位名称
				@reporterID varchar(10),	--报告人工号
				@tel varchar(30),			--联系电话
				@Email varchar(30),			--邮箱
				@title nvarchar(50),		--意见标题
				@reportTag nvarchar(50),	--意见分类
				@descTxt nvarchar(500),		--意见描述

	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
				@reportID char(12) output,	--用户意见单号
				@reportDate smalldatetime output--报告日期
	author:		卢苇
	CreateDate:	2011-7-6
	UpdateDate: modi by lw 2012-4-19根据新的系统用户表更新接口
*/
create PROCEDURE addUserReport
	@unitName nvarchar(30),	--所在单位名称
	@reporterID varchar(10),	--报告人工号
	@tel varchar(30),			--联系电话
	@Email varchar(30),			--邮箱
	@title nvarchar(50),		--意见标题
	@reportTag nvarchar(50),	--意见分类
	@descTxt nvarchar(500),		--意见描述

	@Ret		int output,
	@reportID char(12) output,	--用户意见单号
	@reportDate smalldatetime output--报告日期
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 10000, 1, @curNumber output
	set @reportID = @curNumber

	--取维护人的姓名：
	declare @reporter nvarchar(30)		--报告人姓名
	select @reporter = cName from userInfo where jobNumber = @reporterID

	set @reportDate = getdate()
	insert userReport(reportID, reportDate, unitName,
						reporterID, reporter, tel, Email, title, reportTag, descTxt)
	values (@reportID, @reportDate, @unitName,
			@reporterID, @reporter, @tel, @Email, @title, @reportTag, @descTxt)

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@reporterID, @reporter, @reportDate, '用户报告', '用户' + @reporter + 
					'提交了编号为[' + @reportID + ']的报告。')
GO
--测试：
select * from userInfo where cName = '毕卫民'
select * from useUnit where clgCode = '000'

declare @Ret int, @reportID char(12), @reportDate smalldatetime
exec dbo.addUserReport '000', '00000', '00200977', '测试意见', '功能缺陷', '测试用户意见表！', @Ret output, @reportID output, @reportDate output
select @Ret, @reportID, @reportDate
select * from userReport



drop PROCEDURE addUserReportAppendFile
/*
	name:		1.1.addUserReportAppendFile
	function:	添加用户反馈意见的附件
	input: 
				@reportID char(12),			--用户意见单号
				@oldFilename varchar(128),	--原始文件名
				@extFileName varchar(8),	--附件的扩展名
	output: 
				@Ret		int output,	--操作成功标识
							0:成功，9：出错
				@fileGUID36 varchar(36) output	--系统分配的唯一文件名
	author:		卢苇
	CreateDate:	2011-7-6
	UpdateDate: 
*/
create PROCEDURE addUserReportAppendFile
	@reportID char(12),			--用户意见单号
	@oldFilename varchar(128),	--原始文件名
	@extFileName varchar(8),	--附件的扩展名

	@Ret int output,			--操作成功标识
	@fileGUID36 varchar(36) output	--系统分配的唯一文件名
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--生成唯一的文件名：
	set @fileGUID36 = (select newid())

	--登记附件信息：
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
	function:	2.删除指定的用户回馈意见
				注意：该存储过程并不删除附件文件！
	input: 
				@reportID char(12),			--用户意见单号
				@delManID varchar(10),		--删除人
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该用户意见不存在，9：未知错误
	author:		卢苇
	CreateDate:	2011-7-9
	UpdateDate: 
*/
create PROCEDURE delUserReport
	@reportID char(12),			--用户意见单号
	@delManID varchar(10),		--删除人
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的用户回馈意见是否存在
	declare @count as int
	set @count=(select count(*) from userReport where reportID = @reportID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	delete userReport where reportID = @reportID --附件表级联删除，附件文件请用手工删除
	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除用户意见表', '用户' + @delManName
												+ '删除了用户意见表['+ @reportID +']的信息。')

GO


drop PROCEDURE delUserReports
/*
	name:		delUserReports
	function:	3.删除指定范围的用户回馈意见
				注意：该存储过程并不删除附件文件！
	input: 
				@where varchar(4000),		--指定范围
				@delManID varchar(10),		--删除人
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2011-7-11
	UpdateDate: 
*/
create PROCEDURE delUserReports
	@where varchar(4000),		--指定范围
	@delManID varchar(10),		--删除人
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	exec('delete userReport ' + @where) --附件表级联删除，附件文件请用手工删除
	
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除用户意见表', '用户' + @delManName
												+ '删除了['+ @where +']范围内的所有用户意见表。')

GO



drop PROCEDURE addUserReportAnswer
/*
	name:		addUserReportAnswer
	function:	1.添加用户报告意见回复意见
				注意：本存储过程不锁定编辑！
	input: 
				@reportID char(12),			--用户意见单号
				@answerID varchar(10),		--回复人工号
				@answerTag nvarchar(50),	--回复意见分类
				@descTxt nvarchar(500),		--回复意见描述
	output: 
				@Ret		int output,		--操作成功标识
							0:成功，9：未知错误
				@answerDate smalldatetime output	--回复日期
	author:		卢苇
	CreateDate:	2011-10-15
	UpdateDate: 
*/
create PROCEDURE addUserReportAnswer
	@reportID char(12),			--用户意见单号
	@answerID varchar(10),		--回复人工号
	@answerTag nvarchar(50),	--回复意见分类
	@descTxt nvarchar(500),		--回复意见描述

	@Ret		int output,
	@answerDate smalldatetime output	--回复日期
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--取回复人的姓名：
	declare @answer nvarchar(30)		--回复人姓名
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
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@answerID, @answer, @answerDate, '回复用户报告', '用户' + @answer + 
					'回复了编号为[' + @reportID + ']的报告。')
GO

--测试：
select * from userInfo where cName = '毕卫民'
select * from useUnit where clgCode = '000'

select * from userReport
declare @Ret int, @reportDate smalldatetime
exec dbo.addUserReportAnswer '201107070004', '00200977', '测试意见', '测试回复用户意见表！', @Ret output, @reportDate output
select @Ret, @reportDate
select * from userReportAnswer





--检查系统最大连接数：
select count(*) from master.dbo.sysprocesses where dbid=db_id()
select @@max_connections
