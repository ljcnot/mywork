use fTradeDB
/*
	武大外贸合同管理信息系统-代码字典类表与存储过程
	根据设备管理系统修改,要与设备管理系统中的类似表同时更新!
	该部分的表和存储过程采用引用设备管理系统的webService操作;
	author:		卢苇
	CreateDate:	2010-8-13
	UpdateDate: 
*/

--2.国别（country）：
select * from 
select * from country
drop table country
CREATE TABLE country(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	cCode char(3) not null,			--主键：国家代码
	cName nvarchar(60) not null,	--国家名称	
	enName nvarchar(60) null,		--国家英文名称
	fullName nvarchar(100) null,	--国家中英文全称
	inputCode varchar(5) null,		--输入码

	--为了保证编码的历史数据正确性，增加启用和停用功能而增加的字段：
	isOff char(1) default('0') null,	--停用标识:“0”代表在用，“1”代表停用
	offDate smalldatetime null,			--停用日期

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_country] PRIMARY KEY CLUSTERED 
(
	[cCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--索引：
CREATE NONCLUSTERED INDEX [IX_country] ON [dbo].[country] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

drop PROCEDURE checkCountryCode
/*
	name:		checkCountryCode
	function:	0.1.检查指定的国家代码是否已经存在
	input: 
				@rowNum int,			--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@cCode char(3),			--主键：国家代码
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE checkCountryCode
	@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@cCode char(3),			--主键：国家代码
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该国家代码是否存在：
	declare @count int
	set @count = (select count(*) from country where cCode = @cCode and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkCountryName
/*
	name:		checkCountryName
	function:	0.2.检查指定的国家名称是否已经存在
	input: 
				@rowNum int,			--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@cName nvarchar(60),	--国家名称	
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE checkCountryName
	@rowNum int,			--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@cName nvarchar(60),	--国家名称	
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该国名是否存在：
	declare @count int
	set @count = (select count(*) from country where cName = @cName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE addCountry
/*
	name:		addCountry
	function:	1.添加国别
				注意：本存储过程不锁定编辑！
	input: 
				@cCode char(3),				--主键：国家代码
				@cName nvarchar(60),		--国家名称	
				@enName nvarchar(60),		--国家英文名称
				@fullName nvarchar(100),	--国家中英文全称
				@inputCode varchar(5),		--输入码

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该国别名称或代码已存在，9：未知错误
				@rowNum		int output,		--序号
				@createTime smalldatetime output
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw 根据编辑要求增加rowNum返回参数
*/
create PROCEDURE addCountry
	@cCode char(3),				--主键：国家代码
	@cName nvarchar(60),		--国家名称	
	@enName nvarchar(60),		--国家英文名称
	@fullName nvarchar(100),	--国家中英文全称
	@inputCode varchar(5),		--输入码

	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@rowNum		int output,		--序号
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查是否重码重名：
	declare @count int
	set @count = (select count(*) from country where cCode = @cCode or cName = @cName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert country(cCode, cName, enName, fullName, inputCode,
						lockManID, modiManID, modiManName, modiTime) 
	values (@cCode, @cName, @enName, @fullName, @inputCode,
			'', @createManID, @createManName, @createTime)
	set @rowNum =(select rowNum from countrty where cCode = @cCode or cName = @cName)

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加国别', '系统根据用户' + @createManName + 
					'的要求添加了国别[' + @cName +'('+ @cCode +')' + ']。')
GO

drop PROCEDURE queryCountryLocMan
/*
	name:		queryCountryLocMan
	function:	2.查询指定国别是否有人正在编辑
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的国别不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryCountryLocMan
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from country where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockCountry4Edit
/*
	name:		lockCountry4Edit
	function:	3.锁定国别编辑，避免编辑冲突
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前国别正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的国别不存在，2:要锁定的国别正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockCountry4Edit
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前国别正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的国别是否存在
	declare @count as int
	set @count=(select count(*) from country where rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from country where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update country
	set lockManID = @lockManID 
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定国别编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了行号为：[' + str(@rowNum,6) + ']的国别为独占式编辑。')
GO

drop PROCEDURE unlockCountryEditor
/*
	name:		unlockCountryEditor
	function:	4.释放国别编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前国别正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockCountryEditor
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前国别正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from country where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update country set lockManID = '' where rowNum = @rowNum
	end
	else
	begin
		set @Ret = 0
		return
	end
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放国别编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了行号为：[' + str(@rowNum,6) + ']的国别的编辑锁。')
GO


drop PROCEDURE updateCountry
/*
	name:		updateCountry
	function:	5.更新国别
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@cCode char(3),				--主键：国家代码
				@cName nvarchar(60),		--国家名称	
				@enName nvarchar(60),		--国家英文名称
				@fullName nvarchar(100),	--国家中英文全称
				@inputCode varchar(5),		--输入码

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前国别正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的国别正被别人锁定，2:有重复的国别代码或名称，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE updateCountry
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@cCode char(3),				--主键：国家代码
	@cName nvarchar(60),		--国家名称	
	@enName nvarchar(60),		--国家英文名称
	@fullName nvarchar(100),	--国家中英文全称
	@inputCode varchar(5),		--输入码

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前国别正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from country where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--检查是否重码重名：
	declare @count int
	set @count = (select count(*) from country where (cCode = @cCode or cName = @cName) and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update country
	set cCode = @cCode, cName = @cName, enName = @enName, fullName = @fullName, inputCode = @inputCode,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新国别', '用户' + @modiManName 
												+ '更新了行号为：[' + str(@rowNum,6) + ']的国别。')
GO

drop PROCEDURE delCountry
/*
	name:		delCountry
	function:	6.删除指定的国别
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@delManID varchar(10) output,	--删除人，如果当前国别正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的国别不存在，2：要删除的国别正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delCountry
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@delManID varchar(10) output,	--删除人，如果当前国别正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的国别是否存在
	declare @count as int
	set @count=(select count(*) from country where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from country where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete country where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除国别', '用户' + @delManName
												+ '删除了行号为：[' + str(@rowNum,6) + ']的国别。')
GO

drop PROCEDURE setCountryOff
/*
	name:		setCountryOff
	function:	7.停用指定的国别
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@stopManID varchar(10) output,	--停用人，如果当前国别正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的国别不存在，2：要停用的国别正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setCountryOff
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@stopManID varchar(10) output,	--停用人，如果当前国别正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的国别是否存在
	declare @count as int
	set @count=(select count(*) from country where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from country where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update country
	set isOff = '1', offDate = @stopTime
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '停用国别', '用户' + @stopManName
												+ '停用了行号为：[' + str(@rowNum,6) + ']的国别。')
GO

drop PROCEDURE setCountryActive
/*
	name:		setCountryActive
	function:	8.启用指定的国别
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@activeManID varchar(10) output,	--启用人，如果当前国别正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的国别不存在，2：要启用的国别正被别人锁定，3：该国别本就是激活状态，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setCountryActive
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@activeManID varchar(10) output,	--启用人，如果当前国别正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的国别是否存在
	declare @count as int
	set @count=(select count(*) from country where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from country where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查状态：
	declare @status char(1)
	set @status = isnull((select isOff from country where rowNum = @rowNum),'')
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update country
	set isOff = '0', offDate = null
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '重新启用国别', '用户' + @activeManName
												+ '重新启用了行号为：[' + str(@rowNum,6) + ']的国别。')
GO


--5.college（院部表）：
--指学院（系）、研究所、实验中心及处级单位
alter TABLE college add abbClgName nvarchar(6) null		--院部简称	add by lw 2012-5-19根据客户要求增加
alter TABLE college add managerID varchar(10) null			--院部负责人工号 add by lw 2012-6-4为了增加短信功能而新增的精确定位负责人的字段
drop table college
CREATE TABLE college(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	clgCode char(3) not null,			--主键：院部代码
	clgName nvarchar(30) not null,		--院部名称	
	abbClgName nvarchar(6) null,		--院部简称	add by lw 2012-5-19根据客户要求增加
	managerID varchar(10) null,			--院部负责人工号 add by lw 2012-6-4为了增加短信功能而新增的精确定位负责人的字段
	manager nvarchar(30) null,			--院部负责人
	inputCode varchar(5) null,			--输入码

	--为了保证编码的历史数据正确性，增加启用和停用功能而增加的字段：
	isOff char(1) default('0') null,		--停用标识:“0”代表在用，“1”代表停用
	offDate smalldatetime null,			--停用日期

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_college] PRIMARY KEY CLUSTERED 
(
	[clgCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--索引：
CREATE NONCLUSTERED INDEX [IX_college] ON [dbo].[college] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select clgCode, clgName, manager, inputCode from college order by inputCode

drop PROCEDURE checkCollegeCode
/*
	name:		checkCollegeCode
	function:	0.1.检查指定的院部代码是否已经存在
	input: 
				@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@clgCode char(3),	--主键：院部代码
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/

create PROCEDURE checkCollegeCode
	@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@clgCode char(3),	--主键：院部代码
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该代码是否存在：
	declare @count int
	set @count = (select count(*) from college where clgCode = @clgCode and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkCollegeName
/*
	name:		checkCollegeName
	function:	0.2.检查指定的院部名称是否已经存在
	input: 
				@rowNum int,				--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@clgName nvarchar(30),		--院部名称	
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE checkCollegeName
	@rowNum int,				--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@clgName nvarchar(30),		--院部名称	
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该名称是否存在：
	declare @count int
	set @count = (select count(*) from college where clgName = @clgName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkCollegeAbbName
/*
	name:		checkCollegeAbbName
	function:	0.3.检查指定的院部简称是否已经存在
	input: 
				@rowNum int,				--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@abbClgName nvarchar(6),	--院部简称
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2012-5-19
	UpdateDate: 
*/
create PROCEDURE checkCollegeAbbName
	@rowNum int,				--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@abbClgName nvarchar(6),	--院部简称
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该名称是否存在：
	declare @count int
	set @count = (select count(*) from college where abbClgName = @abbClgName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE addCollege
/*
	name:		addCollege
	function:	1.添加院部
				注意：本存储过程不锁定编辑！
	input: 
				@clgCode char(3),			--主键：院部代码
				@clgName nvarchar(30),		--院部名称	
				@abbClgName nvarchar(6),	--院部简称
				@managerID varchar(10),		--院部负责人工号 add by lw 2012-6-4为了增加短信功能而新增的精确定位负责人的字段
				@manager nvarchar(30),		--院部负责人
				@inputCode varchar(5),		--输入码

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该院部名称或代码已存在，9：未知错误
				@rowNum		int output,		--序号
				@createTime smalldatetime output
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw 根据编辑要求增加rowNum返回参数
				modi by lw 2012-5-19 根据客户要求增加简称
				modi by lw 2012-6-4 增加负责人ID
*/
create PROCEDURE addCollege
	@clgCode char(3),			--主键：院部代码
	@clgName nvarchar(30),		--院部名称	
	@abbClgName nvarchar(6),	--院部简称
	@managerID varchar(10),		--院部负责人工号 add by lw 2012-6-4为了增加短信功能而新增的精确定位负责人的字段
	@manager nvarchar(30),		--院部负责人
	@inputCode varchar(5),		--输入码

	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@rowNum		int output,		--序号
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查是否重码重名：
	declare @count int
	set @count = (select count(*) from college where clgCode = @clgCode or clgName = @clgName or abbClgName = @abbClgName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--检查是否有负责人ID，如果有重新获取姓名：
	if (@managerID<>'')
	begin
		set @manager = isnull((select cName from userInfo where jobNumber=@managerID),'')
	end

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert college(clgCode, clgName, abbClgName, managerID, manager, inputCode,
						lockManID, modiManID, modiManName, modiTime) 
	values (@clgCode, @clgName, @abbClgName, @managerID, @manager, @inputCode,
			'', @createManID, @createManName, @createTime)
	set @rowNum =(select rowNum from college where clgCode = @clgCode or clgName = @clgName)
	

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加院部', '系统根据用户' + @createManName + 
					'的要求添加了院部[' + @clgName +'('+ @clgCode +')' + ']。')
GO

drop PROCEDURE queryCollegeLocMan
/*
	name:		queryCollegeLocMan
	function:	2.查询指定院部是否有人正在编辑
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的院部不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryCollegeLocMan
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from college where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockCollege4Edit
/*
	name:		lockCollege4Edit
	function:	3.锁定院部编辑，避免编辑冲突
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前院部正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的院部不存在，2:要锁定的院部正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockCollege4Edit
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前院部正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的院部是否存在
	declare @count as int
	set @count=(select count(*) from college where rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from college where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update college
	set lockManID = @lockManID 
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定院部编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了行号为：[' + str(@rowNum,6) + ']的院部为独占式编辑。')
GO

drop PROCEDURE unlockCollegeEditor
/*
	name:		unlockCollegeEditor
	function:	4.释放院部编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前院部正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockCollegeEditor
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前院部正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from college where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update college set lockManID = '' where rowNum = @rowNum
	end
	else
	begin
		set @Ret = 0
		return
	end
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放院部编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了行号为：[' + str(@rowNum,6) + ']的院部的编辑锁。')
GO


drop PROCEDURE updateCollege
/*
	name:		updateCollege
	function:	5.更新院部
	input: 
				@rowNum int,			--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@clgCode char(3),			--主键：院部代码
				@clgName nvarchar(30),		--院部名称	
				@abbClgName nvarchar(6),	--院部简称
				@managerID varchar(10),		--院部负责人工号 add by lw 2012-6-4为了增加短信功能而新增的精确定位负责人的字段
				@manager nvarchar(30),		--院部负责人
				@inputCode varchar(5),		--输入码

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前院部正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的院部正被别人锁定，2:有重复的院部代码或名称，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-5-19 根据客户要求增加简称
				modi by lw 2012-6-4 增加负责人ID
*/
create PROCEDURE updateCollege
	@rowNum int,			--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@clgCode char(3),			--主键：院部代码
	@clgName nvarchar(30),		--院部名称	
	@abbClgName nvarchar(6),	--院部简称
	@managerID varchar(10),		--院部负责人工号 add by lw 2012-6-4为了增加短信功能而新增的精确定位负责人的字段
	@manager nvarchar(30),		--院部负责人
	@inputCode varchar(5),		--输入码

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前院部正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from college where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--检查是否重码重名：
	declare @count int
	set @count = (select count(*) from college where (clgCode = @clgCode or clgName = @clgName or abbClgName = @abbClgName) and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--检查是否有负责人ID，如果有重新获取姓名：
	if (@managerID<>'')
	begin
		set @manager = isnull((select cName from userInfo where jobNumber=@managerID),'')
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update college
	set clgCode = @clgCode, clgName = @clgName, abbClgName = @abbClgName,
		managerID = @managerID, manager = @manager, inputCode = @inputCode,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新院部', '用户' + @modiManName 
												+ '更新了行号为：[' + str(@rowNum,6) + ']的院部。')
GO


drop PROCEDURE delCollege
/*
	name:		delCollege
	function:	6.删除指定的院部
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@delManID varchar(10) output,	--删除人，如果当前院部正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的院部不存在，2：要删除的院部正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delCollege
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@delManID varchar(10) output,	--删除人，如果当前院部正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的院部是否存在
	declare @count as int
	set @count=(select count(*) from college where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from college where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete college where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除院部', '用户' + @delManName
												+ '删除了行号为：[' + str(@rowNum,6) + ']的院部。')
GO

drop PROCEDURE setCollegeOff
/*
	name:		setCollegeOff
	function:	7.停用指定的院部
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@stopManID varchar(10) output,	--停用人，如果当前院部正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的院部不存在，2：要停用的院部正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setCollegeOff
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@stopManID varchar(10) output,	--停用人，如果当前院部正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的院部是否存在
	declare @count as int
	set @count=(select count(*) from college where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from college where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update college
	set isOff = '1', offDate = @stopTime
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '停用院部', '用户' + @stopManName
												+ '停用了行号为：[' + str(@rowNum,6) + ']的院部。')
GO

drop PROCEDURE setCollegeActive
/*
	name:		setCollegeActive
	function:	8.启用指定的院部
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@activeManID varchar(10) output,	--启用人，如果当前院部正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的院部不存在，2：要启用的院部正被别人锁定，3：该院部本就是激活状态，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setCollegeActive
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@activeManID varchar(10) output,	--启用人，如果当前院部正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的院部是否存在
	declare @count as int
	set @count=(select count(*) from college where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from college where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查状态：
	declare @status char(1)
	set @status = isnull((select isOff from college where rowNum = @rowNum),'')
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update college
	set isOff = '0', offDate = null
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '重新启用院部', '用户' + @activeManName
												+ '重新启用了行号为：[' + str(@rowNum,6) + ']的院部。')
GO

use epdc2
select * from useUnit where manager like '%卢苇%'
--6.useUnit（使用单位）：
drop table useUnit
CREATE TABLE useUnit(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	uCode varchar(8) not null,			--主键：使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！
	uName nvarchar(30) not null,		--使用单位名称	
	manager nvarchar(30) null,			--使用单位负责人
	uType smallint not null,			--使用单位类型：由第10号代码字典定义。1：教学，2：科研，3：行政，4：后勤，9：其他 add by lw 2011-1-26
	clgCode char(3) not null,			--外键：学院代码
	inputCode varchar(5) null,			--输入码

	--为了保证编码的历史数据正确性，增加启用和停用功能而增加的字段：
	isOff char(1) default('0') null,	--停用标识:“0”代表在用，“1”代表停用
	offDate smalldatetime null,			--停用日期

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_useUnit] PRIMARY KEY CLUSTERED 
(
	[uCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--索引：
CREATE NONCLUSTERED INDEX [IX_useUnit] ON [dbo].[useUnit] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[useUnit] WITH CHECK ADD CONSTRAINT [FK_useUnit_college] FOREIGN KEY([clgCode])
REFERENCES [dbo].[college] ([clgCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[useUnit] CHECK CONSTRAINT [FK_useUnit_college]
GO

select u.uCode, u.uName, u.manager, u.clgCode, c.clgName, u.inputCode 
from useUnit u left join college c on u.clgCode = c.clgCode 
order by inputCode

drop PROCEDURE autoUseUnitCode
/*
	name:		autoUseUnitCode
	function:	0.0.根据院部代码自动生成推荐单位代码
	input: 
				@clgCode char(3),			--所在学院代码
	output: 
				@uCode varchar(8) output	--推荐的使用单位代码
	author:		卢苇
	CreateDate:	2011-10-17
	UpdateDate: 
*/
create PROCEDURE autoUseUnitCode
	@clgCode char(3),			--所在学院代码
	@uCode varchar(8) output	--推荐的使用单位代码
	WITH ENCRYPTION 
AS
	set @uCode = ''

	if (LTRIM(rtrim(isnull(@clgCode,''))) = '')
	begin	
		return
	end

	declare @lastUCode varchar(8)
	set @lastUCode = isnull((select top 1 uCode from useUnit where left(uCode,3) = @clgCode order by uCode desc),'00000')
	
	declare @len int
	set @len = LEN(@lastUCode) - 3
	
	declare @num int
	set @num = cast(SUBSTRING(@lastUCode,4,@len) as int) + 1
	if @@ERROR <> 0 return
	
	set @uCode = @clgCode + right('00000' + CAST(@num as varchar(5)), @len)
GO
--测试：
declare @uCode varchar(8), @clgCode char(3)
set @clgCode = '004'
exec dbo.autoUseUnitCode @clgCode, @uCode output
select @uCode
select * from useUnit where clgCode = @clgCode order by uCode desc

drop PROCEDURE checkUseUnitCode
/*
	name:		checkUseUnitCode
	function:	0.1.检查指定的使用单位代码是否已经存在
	input: 
				@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@uCode varchar(8),	--主键：使用单位代码
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2011-10-17增加修改状态下的检查
*/
create PROCEDURE checkUseUnitCode
	@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@uCode varchar(8),	--主键：使用单位代码
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查是否重码：
	declare @count int
	set @count = (select count(*) from useUnit where uCode = @uCode and rowNum <> @rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkUseUnitName
/*
	name:		checkUseUnitName
	function:	0.2.检查指定的使用单位名称是否已经在本院部内登记
	input: 
				@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@clgCode char(3),	--所在学院代码
				@uName nvarchar(30),--使用单位名称	
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，8：未输入院部代码，无法检查，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2011-10-17应客户要求不做名称唯一性检查,修改为在本院部内部做唯一性检查！增加修改状态下得检查。
*/
create PROCEDURE checkUseUnitName
	@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@clgCode char(3),		--所在学院代码
	@uName nvarchar(30),	--使用单位名称	
	@Ret		int output
	WITH ENCRYPTION 
AS
	if (LTRIM(rtrim(isnull(@clgCode,''))) = '')
	begin	
		set @Ret = 8
		return
	end
	
	set @Ret = 9
	--检查是否在本院部内有重名的单位：
	declare @count int
	set @count = (select count(*) from useUnit where clgCode = @clgCode and uName = @uName and rowNum <> @rowNum)
	set @Ret = @count
GO

drop PROCEDURE addUseUnit
/*
	name:		addUseUnit
	function:	1.添加使用单位
				注意：本存储过程不锁定编辑！
	input: 
				@uCode varchar(8),	--主键：使用单位代码
				@uName nvarchar(30),	--使用单位名称	
				@manager nvarchar(30),	--使用单位负责人
				@clgCode char(3),		--外键：学院代码
				@inputCode varchar(5),	--输入码
				@uType smallint,		--使用单位类型：由第10号代码字典定义。1：教学，2：科研，3：行政，4：后勤，9：其他 add by lw 2011-2-11

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该使用单位代码已存在，2：该使用单位名称已存在（本院部内），9：未知错误
				@rowNum		int output,		--序号
				@createTime smalldatetime output
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw 根据编辑要求增加rowNum返回参数
				modi by lw 2011-2-11根据设备处要求延长编码长度！,增加用户单位类型字段
				modi by lw 2011-10-17应客户要求不做名称唯一性检查,修改为在本院部内部做唯一性检查！
*/
create PROCEDURE addUseUnit
	@uCode varchar(8),	--主键：使用单位代码
	@uName nvarchar(30),	--使用单位名称	
	@manager nvarchar(30),	--使用单位负责人
	@clgCode char(3),		--外键：学院代码
	@inputCode varchar(5),	--输入码
	@uType smallint,		--使用单位类型：由第10号代码字典定义。1：教学，2：科研，3：行政，4：后勤，9：其他 add by lw 2011-2-11

	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@rowNum		int output,		--序号
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查是否重码：
	declare @count int
	set @count = (select count(*) from useUnit where uCode = @uCode)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--检查是否在本院部内有重名的单位：
	set @count = (select count(*) from useUnit where clgCode = @clgCode and uName = @uName)
	if @count > 0
	begin
		set @Ret = 2
		return
	end

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	if @uType=0
		set @uType = null
	set @createTime = getdate()
	insert useUnit(uCode, uName, manager, clgCode, inputCode, uType,
						lockManID, modiManID, modiManName, modiTime) 
	values (@uCode, @uName, @manager, @clgCode, @inputCode, @uType,
			'', @createManID, @createManName, @createTime)
	set @rowNum =(select rowNum from useUnit where uCode = @uCode)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加使用单位', '系统根据用户' + @createManName + 
					'的要求添加了使用单位[' + @uName +'('+ @uCode +')' + ']。')
GO
--测试：
select * from college
declare @createManID varchar(10)
declare @Ret		int
declare @rowNum		int
declare @createTime smalldatetime
exec dbo.addUseUnit '11001111',	'使用单位名称', 'lw', '000','', 1, '000000000', @Ret output, @rowNum output, @createTime output
select @Ret


drop PROCEDURE queryUseUnitLocMan
/*
	name:		queryUseUnitLocMan
	function:	2.查询指定使用单位是否有人正在编辑
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的使用单位不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryUseUnitLocMan
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockUseUnit4Edit
/*
	name:		lockUseUnit4Edit
	function:	3.锁定使用单位编辑，避免编辑冲突
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前使用单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的使用单位不存在，2:要锁定的使用单位正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockUseUnit4Edit
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前使用单位正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的使用单位是否存在
	declare @count as int
	set @count=(select count(*) from useUnit where rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update useUnit
	set lockManID = @lockManID 
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定使用单位编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了行号为：[' + str(@rowNum,6) + ']的使用单位为独占式编辑。')
GO

drop PROCEDURE unlockUseUnitEditor
/*
	name:		unlockUseUnitEditor
	function:	4.释放使用单位编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前使用单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockUseUnitEditor
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前使用单位正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update useUnit set lockManID = '' where rowNum = @rowNum
	end
	else
	begin
		set @Ret = 0
		return
	end
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '释放使用单位编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了行号为：[' + str(@rowNum,6) + ']的使用单位的编辑锁。')
GO


drop PROCEDURE updateUseUnit
/*
	name:		updateUseUnit
	function:	5.更新使用单位
	input: 
				@rowNum int,			--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@uCode varchar(8),		--主键：使用单位代码
				@uName nvarchar(30),	--使用单位名称	
				@manager nvarchar(30),	--使用单位负责人
				@clgCode char(3),		--外键：学院代码
				@inputCode varchar(5),	--输入码
				@uType smallint,		--使用单位类型：由第10号代码字典定义。1：教学，2：科研，3：行政，4：后勤，9：其他 add by lw 2011-2-11

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前使用单位正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的使用单位正被别人锁定，
							2:有重复的使用单位代码，
							3:有重复的使用单位名称（本院部内），
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2011-2-11根据设备处要求延长编码长度！增加单位类型字段
				modi by lw 2011-10-17应客户要求不做名称唯一性检查,修改为在本院部内部做唯一性检查！
*/
create PROCEDURE updateUseUnit
	@rowNum int,			--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@uCode varchar(8),		--主键：使用单位代码
	@uName nvarchar(30),	--使用单位名称	
	@manager nvarchar(30),	--使用单位负责人
	@clgCode char(3),		--外键：学院代码
	@inputCode varchar(5),	--输入码
	@uType smallint,		--使用单位类型：由第10号代码字典定义。1：教学，2：科研，3：行政，4：后勤，9：其他 add by lw 2011-2-11

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前使用单位正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--检查是否重码：
	declare @count int
	set @count = (select count(*) from useUnit where uCode = @uCode and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--检查在本院部内是否有重名：
	set @count = (select count(*) from useUnit where clgCode = @clgCode and uName = @uName and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 3
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update useUnit
	set uCode = @uCode, uName = @uName, manager = @manager, clgCode = @clgCode, inputCode = @inputCode,
		uType = @uType,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新使用单位', '用户' + @modiManName 
												+ '更新了行号为：[' + str(@rowNum,6) + ']的使用单位。')
GO

drop PROCEDURE delUseUnit
/*
	name:		delUseUnit
	function:	6.删除指定的使用单位
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@delManID varchar(10) output,	--删除人，如果当前使用单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的使用单位不存在，2：要删除的使用单位正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delUseUnit
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@delManID varchar(10) output,	--删除人，如果当前使用单位正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的使用单位是否存在
	declare @count as int
	set @count=(select count(*) from useUnit where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete useUnit where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除使用单位', '用户' + @delManName
												+ '删除了行号为：[' + str(@rowNum,6) + ']的使用单位。')
GO

drop PROCEDURE setUseUnitOff
/*
	name:		setUseUnitOff
	function:	7.停用指定的使用单位
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@stopManID varchar(10) output,	--停用人，如果当前使用单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的使用单位不存在，2：要停用的使用单位正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setUseUnitOff
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@stopManID varchar(10) output,	--停用人，如果当前使用单位正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的使用单位是否存在
	declare @count as int
	set @count=(select count(*) from useUnit where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update useUnit
	set isOff = '1', offDate = @stopTime
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '停用使用单位', '用户' + @stopManName
												+ '停用了行号为：[' + str(@rowNum,6) + ']的使用单位。')
GO

drop PROCEDURE setUseUnitActive
/*
	name:		setUseUnitActive
	function:	8.启用指定的使用单位
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@activeManID varchar(10) output,	--启用人，如果当前使用单位正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的使用单位不存在，2：要启用的使用单位正被别人锁定，3：该使用单位本就是激活状态，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setUseUnitActive
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@activeManID varchar(10) output,	--启用人，如果当前使用单位正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的使用单位是否存在
	declare @count as int
	set @count=(select count(*) from useUnit where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from useUnit where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查状态：
	declare @status char(1)
	set @status = isnull((select isOff from useUnit where rowNum = @rowNum),'')
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update useUnit
	set isOff = '0', offDate = null
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '重新启用使用单位', '用户' + @activeManName
												+ '重新启用了行号为：[' + str(@rowNum,6) + ']的使用单位。')
GO


