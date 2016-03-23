use hustOA
/*
	武大设备管理信息系统-代码字典类表与存储过程
	author:		卢苇
	CreateDate:	2010-8-13
	UpdateDate: 2010-10-30 根据最新的渐进增强自动完成控件要求将所有代码字典类表增加输入码字段
				modi by lw 1011-10-16将设备分类代码表分拆成4个表，建立门类、大类、中类索引表，增加分类代码的样式字段
				将代码字典移入typeCode.sql
*/

--2.国别（country）：

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

drop PROCEDURE checkCountryEnName
/*
	name:		checkCountryEnName
	function:	0.3.检查指定的国家英文名称是否已经存在
	input: 
				@rowNum int,			--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@enName nvarchar(60),	--国家英文名称
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2012-9-9
	UpdateDate: 
*/
create PROCEDURE checkCountryEnName
	@rowNum int,			--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@enName nvarchar(60),	--国家英文名称
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该国名是否存在：
	declare @count int
	set @count = (select count(*) from country where enName = @enName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkCountryFullName
/*
	name:		checkCountryFullName
	function:	0.4.检查指定的国家中英文全称是否已经存在
	input: 
				@rowNum int,			--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@fullName nvarchar(100),--国家中英文全称
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2012-9-9
	UpdateDate: 
*/
create PROCEDURE checkCountryFullName
	@rowNum int,			--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@fullName nvarchar(100),--国家中英文全称
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该国名是否存在：
	declare @count int
	set @count = (select count(*) from country where fullName = @fullName and rowNum<>@rowNum)
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
	set @rowNum =(select rowNum from country where cCode = @cCode)

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

--3.fundSrc（经费来源）：
drop TABLE fundSrc
CREATE TABLE fundSrc(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	fCode char(2) not null,			--主键：经费来源代码
	fName nvarchar(20) not null,	--经费来源名称	
	inputCode varchar(5) null,		--输入码

	--为了保证编码的历史数据正确性，增加启用和停用功能而增加的字段：
	isOff char(1) default('0') null,		--停用标识:“0”代表在用，“1”代表停用
	offDate smalldatetime null,			--停用日期

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_fundSrc] PRIMARY KEY CLUSTERED 
(
	[fCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--索引：
CREATE NONCLUSTERED INDEX [IX_fundSrc] ON [dbo].[fundSrc] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

select * from fundSrc

drop PROCEDURE checkFundSrcCode
/*
	name:		checkFundSrcCode
	function:	0.1.检查指定的经费来源代码是否已经存在
	input: 
				@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@fCode char(2),			--主键：经费来源代码
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-5-31增加修改状态下的检查
*/
create PROCEDURE checkFundSrcCode
	@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@fCode char(2),			--主键：经费来源代码
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该代码是否存在：
	declare @count int
	set @count = (select count(*) from fundSrc where fCode = @fCode and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkFundSrcName
/*
	name:		checkFundSrcName
	function:	0.2.检查指定的经费来源名称是否已经存在
	input: 
				@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@fName nvarchar(20),	--经费来源名称	
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-5-31增加修改状态下的检查
*/
create PROCEDURE checkFundSrcName
	@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@fName nvarchar(20),	--经费来源名称	
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该名称是否存在：
	declare @count int
	set @count = (select count(*) from fundSrc where fName = @fName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE addFundSrc
/*
	name:		addFundSrc
	function:	1.添加经费来源
				注意：本存储过程不锁定编辑！
	input: 
				@fCode char(2),			--主键：经费来源代码
				@fName nvarchar(20),	--经费来源名称	
				@inputCode varchar(5),	--输入码

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该经费来源名称或代码已存在，9：未知错误
				@rowNum		int output,		--序号
				@createTime smalldatetime output
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw 根据编辑要求增加rowNum返回参数
*/
create PROCEDURE addFundSrc
	@fCode char(2),			--主键：经费来源代码
	@fName nvarchar(20),	--经费来源名称	
	@inputCode varchar(5),	--输入码

	@createManID varchar(10),--创建人工号

	@Ret		int output,
	@rowNum		int output,		--序号
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查是否重码重名：
	declare @count int
	set @count = (select count(*) from fundSrc where fCode = @fCode or fName = @fName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert fundSrc(fCode, fName, inputCode,
						lockManID, modiManID, modiManName, modiTime) 
	values (@fCode, @fName, @inputCode,
			'', @createManID, @createManName, @createTime)

	set @rowNum =(select rowNum from fundSrc where fCode = @fCode or fName = @fName)

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加经费来源', '系统根据用户' + @createManName + 
					'的要求添加了经费来源[' + @fName +'('+ @fCode +')' + ']。')
GO

drop PROCEDURE queryFundSrcLocMan
/*
	name:		queryFundSrcLocMan
	function:	2.查询指定经费来源是否有人正在编辑
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的经费来源不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryFundSrcLocMan
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockFundSrc4Edit
/*
	name:		lockFundSrc4Edit
	function:	3.锁定经费来源编辑，避免编辑冲突
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前经费来源正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的经费来源不存在，2:要锁定的经费来源正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockFundSrc4Edit
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前经费来源正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的经费来源是否存在
	declare @count as int
	set @count=(select count(*) from fundSrc where rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update fundSrc
	set lockManID = @lockManID 
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定经费来源编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了行号为：[' + str(@rowNum,6) + ']的经费来源为独占式编辑。')
GO

drop PROCEDURE unlockFundSrcEditor
/*
	name:		unlockFundSrcEditor
	function:	4.释放经费来源编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前经费来源正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockFundSrcEditor
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前经费来源正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update fundSrc set lockManID = '' where rowNum = @rowNum
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
	values(@lockManID, @lockManName, getdate(), '释放经费来源编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了行号为：[' + str(@rowNum,6) + ']的经费来源的编辑锁。')
GO


drop PROCEDURE updateFundSrc
/*
	name:		updateFundSrc
	function:	5.更新经费来源
	input: 
				@rowNum int,			--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@fCode char(2),			--主键：经费来源代码
				@fName nvarchar(20),	--经费来源名称	
				@inputCode varchar(5),	--输入码

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前经费来源正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的经费来源正被别人锁定，2:有重复的经费来源代码或名称，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE updateFundSrc
	@rowNum int,			--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@fCode char(2),			--主键：经费来源代码
	@fName nvarchar(20),	--经费来源名称	
	@inputCode varchar(5),	--输入码

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前经费来源正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--检查是否重码重名：
	declare @count int
	set @count = (select count(*) from fundSrc where (fCode = @fCode or fName = @fName) and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update fundSrc
	set fCode = @fCode, fName = @fName, inputCode = @inputCode,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新经费来源', '用户' + @modiManName 
												+ '更新了行号为：[' + str(@rowNum,6) + ']的经费来源。')
GO

drop PROCEDURE delFundSrc
/*
	name:		delFundSrc
	function:	6.删除指定的经费来源
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@delManID varchar(10) output,	--删除人，如果当前经费来源正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的经费来源不存在，2：要删除的经费来源正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delFundSrc
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@delManID varchar(10) output,	--删除人，如果当前经费来源正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的经费来源是否存在
	declare @count as int
	set @count=(select count(*) from fundSrc where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete fundSrc where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除经费来源', '用户' + @delManName
												+ '删除了行号为：[' + str(@rowNum,6) + ']的经费来源。')
GO

drop PROCEDURE setFundSrcOff
/*
	name:		setFundSrcOff
	function:	7.停用指定的经费来源
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@stopManID varchar(10) output,	--停用人，如果当前经费来源正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的经费来源不存在，2：要停用的经费来源正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setFundSrcOff
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@stopManID varchar(10) output,	--停用人，如果当前经费来源正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的经费来源是否存在
	declare @count as int
	set @count=(select count(*) from fundSrc where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update fundSrc
	set isOff = '1', offDate = @stopTime
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '停用经费来源', '用户' + @stopManName
												+ '停用了行号为：[' + str(@rowNum,6) + ']的经费来源。')
GO

drop PROCEDURE setFundSrcActive
/*
	name:		setFundSrcActive
	function:	8.启用指定的经费来源
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@activeManID varchar(10) output,	--启用人，如果当前经费来源正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的经费来源不存在，2：要启用的经费来源正被别人锁定，3：该经费来源本就是激活状态，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setFundSrcActive
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@activeManID varchar(10) output,	--启用人，如果当前经费来源正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的经费来源是否存在
	declare @count as int
	set @count=(select count(*) from fundSrc where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from fundSrc where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查状态：
	declare @status char(1)
	set @status = isnull((select isOff from fundSrc where rowNum = @rowNum),'')
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update fundSrc
	set isOff = '0', offDate = null
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '重新启用经费来源', '用户' + @activeManName
												+ '重新启用了行号为：[' + str(@rowNum,6) + ']的经费来源。')
GO

--4.appDir（使用方向）：
CREATE TABLE appDir(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	aCode varchar(2) not null,		--主键：使用方向代码
	aName nvarchar(20) not null,	--使用方向名称	
	inputCode varchar(5) null,		--输入码

	--为了保证编码的历史数据正确性，增加启用和停用功能而增加的字段：
	isOff char(1) default('0') null,		--停用标识:“0”代表在用，“1”代表停用
	offDate smalldatetime null,			--停用日期

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_appDir] PRIMARY KEY CLUSTERED 
(
	[aCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--索引：
CREATE NONCLUSTERED INDEX [IX_appDir] ON [dbo].[appDir] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


drop PROCEDURE checkAppDirCode
/*
	name:		checkAppDirCode
	function:	0.1.检查指定的使用方向代码是否已经存在
	input: 
				@rowNum int,			--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@aCode char(2),			--主键：使用方向代码
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-5-31增加修改状态下的检查
*/
create PROCEDURE checkAppDirCode
	@rowNum int,			--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@aCode char(2),			--主键：使用方向代码
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该代码是否存在：
	declare @count int
	set @count = (select count(*) from appDir where aCode = @aCode and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkAppDirName
/*
	name:		checkAppDirName
	function:	0.2.检查指定的使用方向名称是否已经存在
	input: 
				@rowNum int,			--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@aName nvarchar(20),	--使用方向名称	
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2012-5-31增加修改状态下的检查
*/
create PROCEDURE checkAppDirName
	@rowNum int,			--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@aName nvarchar(20),	--使用方向名称	
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该名称是否存在：
	declare @count int
	set @count = (select count(*) from appDir where aName = @aName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE addAppDir
/*
	name:		addAppDir
	function:	1.添加使用方向
				注意：本存储过程不锁定编辑！
	input: 
				@aCode char(2),			--主键：使用方向代码
				@aName nvarchar(20),	--使用方向名称	
				@inputCode varchar(5),	--输入码

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该使用方向名称或代码已存在，9：未知错误
				@rowNum		int output,		--序号
				@createTime smalldatetime output
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw 根据编辑要求增加rowNum返回参数
*/
create PROCEDURE addAppDir
	@aCode char(2),			--主键：使用方向代码
	@aName nvarchar(20),	--使用方向名称	
	@inputCode varchar(5),	--输入码

	@createManID varchar(10),--创建人工号

	@Ret		int output,
	@rowNum		int output,		--序号
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查是否重码重名：
	declare @count int
	set @count = (select count(*) from appDir where aCode = @aCode or aName = @aName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert appDir(aCode, aName, inputCode,
						lockManID, modiManID, modiManName, modiTime) 
	values (@aCode, @aName, @inputCode,
			'', @createManID, @createManName, @createTime)
	set @rowNum =(select rowNum from appDir where aCode = @aCode or aName = @aName)

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加使用方向', '系统根据用户' + @createManName + 
					'的要求添加了使用方向[' + @aName +'('+ @aCode +')' + ']。')
GO

drop PROCEDURE queryAppDirLocMan
/*
	name:		queryAppDirLocMan
	function:	2.查询指定使用方向是否有人正在编辑
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的使用方向不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryAppDirLocMan
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockAppDir4Edit
/*
	name:		lockAppDir4Edit
	function:	3.锁定使用方向编辑，避免编辑冲突
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前使用方向正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的使用方向不存在，2:要锁定的使用方向正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockAppDir4Edit
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前使用方向正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的使用方向是否存在
	declare @count as int
	set @count=(select count(*) from appDir where rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update appDir
	set lockManID = @lockManID 
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定使用方向编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了行号为：[' + str(@rowNum,6) + ']的使用方向为独占式编辑。')
GO

drop PROCEDURE unlockAppDirEditor
/*
	name:		unlockAppDirEditor
	function:	4.释放使用方向编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前使用方向正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockAppDirEditor
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前使用方向正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update appDir set lockManID = '' where rowNum = @rowNum
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
	values(@lockManID, @lockManName, getdate(), '释放使用方向编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了行号为：[' + str(@rowNum,6) + ']的使用方向的编辑锁。')
GO


drop PROCEDURE updateAppDir
/*
	name:		updateAppDir
	function:	5.更新使用方向
	input: 
				@rowNum int,			--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@aCode char(2),			--主键：使用方向代码
				@aName nvarchar(20),	--使用方向名称	
				@inputCode varchar(5),	--输入码

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前使用方向正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的使用方向正被别人锁定，2:有重复的使用方向代码或名称，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE updateAppDir
	@rowNum int,			--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@aCode char(2),			--主键：使用方向代码
	@aName nvarchar(20),	--使用方向名称	
	@inputCode varchar(5),	--输入码

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前使用方向正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--检查是否重码重名：
	declare @count int
	set @count = (select count(*) from appDir where (aCode = @aCode or aName = @aName) and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update appDir
	set aCode = @aCode, aName = @aName, inputCode = @inputCode,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新使用方向', '用户' + @modiManName 
												+ '更新了行号为：[' + str(@rowNum,6) + ']的使用方向。')
GO

drop PROCEDURE delAppDir
/*
	name:		delAppDir
	function:	6.删除指定的使用方向
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@delManID varchar(10) output,	--删除人，如果当前使用方向正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的使用方向不存在，2：要删除的使用方向正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delAppDir
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@delManID varchar(10) output,	--删除人，如果当前使用方向正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的使用方向是否存在
	declare @count as int
	set @count=(select count(*) from appDir where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete appDir where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除使用方向', '用户' + @delManName
												+ '删除了行号为：[' + str(@rowNum,6) + ']的使用方向。')
GO

drop PROCEDURE setAppDirOff
/*
	name:		setAppDirOff
	function:	7.停用指定的使用方向
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@stopManID varchar(10) output,	--停用人，如果当前使用方向正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的使用方向不存在，2：要停用的使用方向正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setAppDirOff
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@stopManID varchar(10) output,	--停用人，如果当前使用方向正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的使用方向是否存在
	declare @count as int
	set @count=(select count(*) from appDir where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update appDir
	set isOff = '1', offDate = @stopTime
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '停用使用方向', '用户' + @stopManName
												+ '停用了行号为：[' + str(@rowNum,6) + ']的使用方向。')
GO

drop PROCEDURE setAppDirActive
/*
	name:		setAppDirActive
	function:	8.启用指定的使用方向
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@activeManID varchar(10) output,	--启用人，如果当前使用方向正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的使用方向不存在，2：要启用的使用方向正被别人锁定，3：该使用方向本就是激活状态，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setAppDirActive
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@activeManID varchar(10) output,	--启用人，如果当前使用方向正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的使用方向是否存在
	declare @count as int
	set @count=(select count(*) from appDir where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from appDir where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查状态：
	declare @status char(1)
	set @status = isnull((select isOff from appDir where rowNum = @rowNum),'')
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update appDir
	set isOff = '0', offDate = null
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '重新启用使用方向', '用户' + @activeManName
												+ '重新启用了行号为：[' + str(@rowNum,6) + ']的使用方向。')
GO


--5.college（院部表）：
--指学院（系）、研究所、实验中心及处级单位
use hustOA
select * from college
alter TABLE college add abbClgName nvarchar(6) null		--院部简称	add by lw 2012-5-19根据客户要求增加
alter TABLE college add managerID varchar(10) null			--院部负责人工号 add by lw 2012-6-4为了增加短信功能而新增的精确定位负责人的字段
alter TABLE college add postName nvarchar(10) null			--职务：这是应工作流的需要增加的字段 add by lw 2012-12-29
alter TABLE college add deputyManID varchar(10) null		--副职负责人工号：这是应工作流的需要增加的字段 add by lw 2012-12-29
alter TABLE college add deputyMan nvarchar(30) null		--副职负责人：这是应工作流的需要增加的字段 add by lw 2012-12-29
alter TABLE college add deputyPost nvarchar(10) null		--副职职务：这是应工作流的需要增加的字段 add by lw 2012-12-29
drop table college
CREATE TABLE college(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	clgCode char(3) not null,			--主键：院部代码
	clgName nvarchar(30) not null,		--院部名称	
	abbClgName nvarchar(6) null,		--院部简称	与外贸系统一致化增加（外贸系统add by lw 2012-5-19根据客户要求增加）
	managerID varchar(10) null,			--院部负责人工号 add by lw 2012-6-4为了增加短信功能而新增的精确定位负责人的字段
	manager nvarchar(30) null,			--院部负责人
	postName nvarchar(10) null,			--职务：这是应工作流的需要增加的字段 add by lw 2012-12-29
	deputyManID varchar(10) null,		--副职负责人工号：这是应工作流的需要增加的字段 add by lw 2012-12-29
	deputyMan nvarchar(30) null,		--副职负责人：这是应工作流的需要增加的字段 add by lw 2012-12-29
	deputyPost nvarchar(10) null,		--副职职务：这是应工作流的需要增加的字段 add by lw 2012-12-29
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
				@postName nvarchar(10),		--职务：这是应工作流的需要增加的字段 add by lw 2012-12-29
				@deputyManID varchar(10),	--副职负责人工号：这是应工作流的需要增加的字段 add by lw 2012-12-29
				@deputyMan nvarchar(30),	--副职负责人：这是应工作流的需要增加的字段 add by lw 2012-12-29
				@deputyPost nvarchar(10),	--副职职务：这是应工作流的需要增加的字段 add by lw 2012-12-29
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
				modi by lw 2012-12-29根据工作流的需要增加职务与副职的字段
*/
create PROCEDURE addCollege
	@clgCode char(3),			--主键：院部代码
	@clgName nvarchar(30),		--院部名称	
	@abbClgName nvarchar(6),	--院部简称
	@managerID varchar(10),		--院部负责人工号 add by lw 2012-6-4为了增加短信功能而新增的精确定位负责人的字段
	@manager nvarchar(30),		--院部负责人
	@postName nvarchar(10),		--职务：这是应工作流的需要增加的字段 add by lw 2012-12-29
	@deputyManID varchar(10),	--副职负责人工号：这是应工作流的需要增加的字段 add by lw 2012-12-29
	@deputyMan nvarchar(30),	--副职负责人：这是应工作流的需要增加的字段 add by lw 2012-12-29
	@deputyPost nvarchar(10),	--副职职务：这是应工作流的需要增加的字段 add by lw 2012-12-29
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
	if (@deputyManID<>'') --副职负责人工号
	begin
		set @deputyMan = isnull((select cName from userInfo where jobNumber=@deputyManID),'')
	end

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	set @createTime = getdate()
	insert college(clgCode, clgName, abbClgName, managerID, manager, inputCode,
						postName, deputyManID, deputyMan, deputyPost,
						lockManID, modiManID, modiManName, modiTime) 
	values (@clgCode, @clgName, @abbClgName, @managerID, @manager, @inputCode,
			@postName, @deputyManID, @deputyMan, @deputyPost,
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
				@postName nvarchar(10),		--职务：这是应工作流的需要增加的字段 add by lw 2012-12-29
				@deputyManID varchar(10),	--副职负责人工号：这是应工作流的需要增加的字段 add by lw 2012-12-29
				@deputyMan nvarchar(30),	--副职负责人：这是应工作流的需要增加的字段 add by lw 2012-12-29
				@deputyPost nvarchar(10),	--副职职务：这是应工作流的需要增加的字段 add by lw 2012-12-29
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
				modi by lw 2012-12-29根据工作流的需要增加职务与副职的字段
*/
create PROCEDURE updateCollege
	@rowNum int,			--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@clgCode char(3),			--主键：院部代码
	@clgName nvarchar(30),		--院部名称	
	@abbClgName nvarchar(6),	--院部简称
	@managerID varchar(10),		--院部负责人工号 add by lw 2012-6-4为了增加短信功能而新增的精确定位负责人的字段
	@manager nvarchar(30),		--院部负责人
	@postName nvarchar(10),		--职务：这是应工作流的需要增加的字段 add by lw 2012-12-29
	@deputyManID varchar(10),	--副职负责人工号：这是应工作流的需要增加的字段 add by lw 2012-12-29
	@deputyMan nvarchar(30),	--副职负责人：这是应工作流的需要增加的字段 add by lw 2012-12-29
	@deputyPost nvarchar(10),	--副职职务：这是应工作流的需要增加的字段 add by lw 2012-12-29
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
	if (@deputyManID<>'') --副职负责人工号
	begin
		set @deputyMan = isnull((select cName from userInfo where jobNumber=@deputyManID),'')
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update college
	set clgCode = @clgCode, clgName = @clgName, abbClgName = @abbClgName,
		managerID = @managerID, manager = @manager, inputCode = @inputCode,
		postName = @postName, deputyManID = @deputyManID, deputyMan = @deputyMan, deputyPost = @deputyPost,
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
alter table useUnit add	managerID varchar(10) null			--使用单位负责人工号 add by lw 2012-12-27
drop table useUnit
CREATE TABLE useUnit(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	uCode varchar(8) not null,			--主键：使用单位代码,modi by lw 2011-2-11根据设备处要求延长编码长度！
	uName nvarchar(30) not null,		--使用单位名称	
	managerID varchar(10) null,			--使用单位负责人工号 add by lw 2012-12-27
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
				@managerID varchar(10),	--使用单位负责人工号（这里不检查工号与姓名的关系！）
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
				modi by lw 2013-2-26增加单位负责人工号字段
*/
create PROCEDURE addUseUnit
	@uCode varchar(8),	--主键：使用单位代码
	@uName nvarchar(30),	--使用单位名称	
	@managerID varchar(10),	--使用单位负责人工号
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
	insert useUnit(uCode, uName, managerID, manager, clgCode, inputCode, uType,
						lockManID, modiManID, modiManName, modiTime) 
	values (@uCode, @uName, @managerID, @manager, @clgCode, @inputCode, @uType,
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
				@managerID varchar(10),	--使用单位负责人工号（这里不检查工号与姓名的关系！）
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
				modi by lw 2013-2-26增加单位负责人工号字段
*/
create PROCEDURE updateUseUnit
	@rowNum int,			--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@uCode varchar(8),		--主键：使用单位代码
	@uName nvarchar(30),	--使用单位名称	
	@managerID varchar(10),	--使用单位负责人工号（这里不检查工号与姓名的关系！）
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
	set uCode = @uCode, uName = @uName, managerID = @managerID, manager = @manager, clgCode = @clgCode, inputCode = @inputCode,
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


--代码字典（主要是单位）允许：合并（一种被吸收、一种成立新单位）、修改、删除

--7.会计科目代码字典表
drop table accountTitle
CREATE TABLE accountTitle(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	accountCode varchar(9) not null,		--主键：会计科目代码
	accountName nvarchar(30) not null,		--会计科目中文名称
	accountEName varchar(60) null,			--会计科目英文名称
	accountTypeCode char(1) not null,		--科目类别
	accountTypeName nvarchar(30) not null,	--科目类别中文名称
	accountTypeEName varchar(60) null,		--科目类别英文名称
	inputCode varchar(5) null,				--输入码
	
	--根据毕处意见：增加会计科目同使用方向的级联add by lw 2011-2-19
	aCode char(2) not null,					--使用方向代码
	aName nvarchar(20) not null,			--使用方向名称：冗余字段！
	

	--为了保证编码的历史数据正确性，增加启用和停用功能而增加的字段：
	isOff char(1) default('0') null,		--停用标识:“0”代表在用，“1”代表停用
	offDate smalldatetime null,			--停用日期

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_accountTitle] PRIMARY KEY CLUSTERED 
(
	[accountCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--索引：
CREATE NONCLUSTERED INDEX [IX_accountTitle] ON [dbo].[accountTitle] 
(
	[inputCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_accountTitle_1] ON [dbo].[accountTitle] 
(
	[accountTypeCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_accountTitle_2] ON [dbo].[accountTitle] 
(
	[aCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

drop PROCEDURE checkAccountTitleCode
/*
	name:		checkAccountTitleCode
	function:	0.1.检查指定的会计科目代码是否已经存在
	input: 
				@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@accountCode varchar(9),	--主键：会计科目代码
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2011-10-17增加修改状态下的检查
*/
create PROCEDURE checkAccountTitleCode
	@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@accountCode varchar(9),	--主键：会计科目代码
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该代码是否存在：
	declare @count int
	set @count = (select count(*) from accountTitle where accountCode = @accountCode and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE checkAccountTitleName
/*
	name:		checkAccountTitleName
	function:	0.2.检查指定的会计科目名称是否已经存在
	input: 
				@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
				@accountName nvarchar(30),		--会计科目中文名称
	output: 
				@Ret		int output		--操作成功标识
							0:不存在，>1：存在，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2011-10-17增加修改状态下的检查
*/
create PROCEDURE checkAccountTitleName
	@rowNum int,		--序号:为了保证用户在修改状态下做唯一性检查而增加的定位行号，为‘0’时表示新增状态
	@accountName nvarchar(30),		--会计科目中文名称
	@Ret		int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查该名称是否存在：
	declare @count int
	set @count = (select count(*) from accountTitle where accountName = @accountName and rowNum<>@rowNum)
	set @Ret = @count
GO

drop PROCEDURE addAccountTitle
/*
	name:		addAccountTitle
	function:	1.添加会计科目
				注意：本存储过程不锁定编辑！
	input: 
				@accountCode varchar(9),	--主键：会计科目代码
				@accountName nvarchar(30),		--会计科目中文名称
				@accountEName varchar(60),		--会计科目英文名称
				@accountTypeCode char(1),		--科目类别
				@accountTypeName nvarchar(30),	--科目类别中文名称
				@accountTypeEName varchar(60),	--科目类别英文名称
				@inputCode varchar(5),			--输入码
				--级联的使用方向：add by lw 2011-2-19
				@aCode char(2),					--使用方向代码

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：该会计科目名称或代码已存在，9：未知错误
				@rowNum		int output,		--序号
				@createTime smalldatetime output
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 2011-1-26 by lw 根据编辑要求增加rowNum返回参数
				2011-2-19 by lw 增加使用方向的级联
*/
create PROCEDURE addAccountTitle
	@accountCode varchar(9),	--主键：会计科目代码
	@accountName nvarchar(30),		--会计科目中文名称
	@accountEName varchar(60),		--会计科目英文名称
	@accountTypeCode char(1),		--科目类别
	@accountTypeName nvarchar(30),	--科目类别中文名称
	@accountTypeEName varchar(60),	--科目类别英文名称
	@inputCode varchar(5),			--输入码
	--级联的使用方向：add by lw 2011-2-19
	@aCode char(2),					--使用方向代码

	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@rowNum		int output,		--序号
	@createTime smalldatetime output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查是否重码重名：
	declare @count int
	set @count = (select count(*) from accountTitle where accountCode = @accountCode or accountName = @accountName)
	if @count > 0
	begin
		set @Ret = 1
		return
	end

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--获取级联的使用方向名称：
	declare @aName nvarchar(20)
	set @aName = (select aName from appDir where aCode = @aCode)

	set @createTime = getdate()
	insert accountTitle(accountCode, accountName, accountEName, accountTypeCode, accountTypeName, accountTypeEName, inputCode,
						aCode, aName,
						lockManID, modiManID, modiManName, modiTime) 
	values (@accountCode, @accountName, @accountEName, @accountTypeCode, @accountTypeName, @accountTypeEName, @inputCode,
			@aCode, @aName,
			'', @createManID, @createManName, @createTime)
	set @rowNum =(select rowNum from accountTitle where accountCode = @accountCode or accountName = @accountName)

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加会计科目', '系统根据用户' + @createManName + 
					'的要求添加了会计科目[' + @accountName +'('+ @accountCode +')' + ']。')
GO

drop PROCEDURE queryAccountTitleLocMan
/*
	name:		queryAccountTitleLocMan
	function:	2.查询指定会计科目是否有人正在编辑
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的会计科目不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE queryAccountTitleLocMan
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output	--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	set @Ret = 0
GO


drop PROCEDURE lockAccountTitle4Edit
/*
	name:		lockAccountTitle4Edit
	function:	3.锁定会计科目编辑，避免编辑冲突
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前会计科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的会计科目不存在，2:要锁定的会计科目正在被别人编辑，
							9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE lockAccountTitle4Edit
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前会计科目正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的会计科目是否存在
	declare @count as int
	set @count=(select count(*) from accountTitle where rowNum = @rowNum)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update accountTitle
	set lockManID = @lockManID 
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定会计科目编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了行号为：[' + str(@rowNum,6) + ']的会计科目为独占式编辑。')
GO

drop PROCEDURE unlockAccountTitleEditor
/*
	name:		unlockAccountTitleEditor
	function:	4.释放会计科目编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@lockManID varchar(10) output,	--锁定人，如果当前会计科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 
*/
create PROCEDURE unlockAccountTitleEditor
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@lockManID varchar(10) output,	--锁定人，如果当前会计科目正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update accountTitle set lockManID = '' where rowNum = @rowNum
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
	values(@lockManID, @lockManName, getdate(), '释放会计科目编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了行号为：[' + str(@rowNum,6) + ']的会计科目的编辑锁。')
GO


drop PROCEDURE updateAccountTitle
/*
	name:		updateAccountTitle
	function:	5.更新会计科目
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@accountCode varchar(9),		--主键：会计科目代码
				@accountName nvarchar(30),		--会计科目中文名称
				@accountEName varchar(60),		--会计科目英文名称
				@accountTypeCode char(1),		--科目类别
				@accountTypeName nvarchar(30),	--科目类别中文名称
				@accountTypeEName varchar(60),	--科目类别英文名称
				@inputCode varchar(5),			--输入码
				--级联的使用方向：add by lw 2011-2-19
				@aCode char(2),					--使用方向代码

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前会计科目正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：要更新的会计科目正被别人锁定，2:有重复的会计科目代码或名称，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: modi by lw 2011-2-19增加与使用方向的级联
*/
create PROCEDURE updateAccountTitle
	@rowNum int,					--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@accountCode varchar(9),		--主键：会计科目代码
	@accountName nvarchar(30),		--会计科目中文名称
	@accountEName varchar(60),		--会计科目英文名称
	@accountTypeCode char(1),		--科目类别
	@accountTypeName nvarchar(30),	--科目类别中文名称
	@accountTypeEName varchar(60),	--科目类别英文名称
	@inputCode varchar(5),			--输入码
	--级联的使用方向：add by lw 2011-2-19
	@aCode char(2),					--使用方向代码

	--维护人:
	@modiManID varchar(10) output,	--维护人，如果当前会计科目正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 1
		return
	end

	--检查是否重码重名：
	declare @count int
	set @count = (select count(*) from accountTitle where (accountCode = @accountCode or accountName = @accountName) and rowNum <> @rowNum)
	if @count > 0
	begin
		set @Ret = 2
		return
	end
	
	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--获取级联的使用方向名称：
	declare @aName nvarchar(20)
	set @aName = (select aName from appDir where aCode = @aCode)

	set @updateTime = getdate()
	update accountTitle
	set accountCode = @accountCode, accountName = @accountName, accountEName = @accountEName, 
		accountTypeCode = @accountTypeCode, accountTypeName = @accountTypeName, accountTypeEName = @accountTypeEName, 
		inputCode = @inputCode,
		aCode = @aCode, aName = @aName,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where rowNum = @rowNum
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新会计科目', '用户' + @modiManName 
												+ '更新了行号为：[' + str(@rowNum,6) + ']的会计科目。')
GO

drop PROCEDURE delAccountTitle
/*
	name:		delAccountTitle
	function:	6.删除指定的会计科目
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@delManID varchar(10) output,	--删除人，如果当前会计科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会计科目不存在，2：要删除的会计科目正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE delAccountTitle
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@delManID varchar(10) output,	--删除人，如果当前会计科目正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的会计科目是否存在
	declare @count as int
	set @count=(select count(*) from accountTitle where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	delete accountTitle where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除会计科目', '用户' + @delManName
												+ '删除了行号为：[' + str(@rowNum,6) + ']的会计科目。')
GO

drop PROCEDURE setAccountTitleOff
/*
	name:		setAccountTitleOff
	function:	7.停用指定的会计科目
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@stopManID varchar(10) output,	--停用人，如果当前会计科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会计科目不存在，2：要停用的会计科目正被别人锁定，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setAccountTitleOff
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@stopManID varchar(10) output,	--停用人，如果当前会计科目正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的会计科目是否存在
	declare @count as int
	set @count=(select count(*) from accountTitle where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @stopManID)
	begin
		set @stopManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	declare @stopTime smalldatetime
	set @stopTime = getdate()
	update accountTitle
	set isOff = '1', offDate = @stopTime
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @stopManName nvarchar(30)
	set @stopManName = isnull((select userCName from activeUsers where userID = @stopManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@stopManID, @stopManName, @stopTime, '停用会计科目', '用户' + @stopManName
												+ '停用了行号为：[' + str(@rowNum,6) + ']的会计科目。')
GO

drop PROCEDURE setAccountTitleActive
/*
	name:		setAccountTitleActive
	function:	8.启用指定的会计科目
	input: 
				@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
				@activeManID varchar(10) output,	--启用人，如果当前会计科目正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的会计科目不存在，2：要启用的会计科目正被别人锁定，3：该会计科目本就是激活状态，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-30
	UpdateDate: 

*/
create PROCEDURE setAccountTitleActive
	@rowNum int,				--序号:为了保证用户可以编辑编码而增加的行号 add by lw 2010-11-30
	@activeManID varchar(10) output,	--启用人，如果当前会计科目正在被人占用编辑则返回该人的工号
	@Ret		int output			--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的会计科目是否存在
	declare @count as int
	set @count=(select count(*) from accountTitle where rowNum = @rowNum)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end
	
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from accountTitle where rowNum = @rowNum),'')
	if (@thisLockMan <> '' and @thisLockMan <> @activeManID)
	begin
		set @activeManID = @thisLockMan
		set @Ret = 2
		return
	end

	--检查状态：
	declare @status char(1)
	set @status = isnull((select isOff from accountTitle where rowNum = @rowNum),'')
	if (@status = '0')
	begin
		set @Ret = 3
		return
	end
	
	declare @activeTime smalldatetime
	set @activeTime = getdate()
	update accountTitle
	set isOff = '0', offDate = null
	where rowNum = @rowNum
	set @Ret = 0

	--取维护人的姓名：
	declare @activeManName nvarchar(30)
	set @activeManName = isnull((select userCName from activeUsers where userID = @activeManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@activeManID, @activeManName, @activeTime, '重新启用会计科目', '用户' + @activeManName
												+ '重新启用了行号为：[' + str(@rowNum,6) + ']的会计科目。')
GO



select * from wd.dbo.accountTitle

