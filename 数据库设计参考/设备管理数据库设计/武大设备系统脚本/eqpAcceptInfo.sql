use epdc211
/*
	武大设备管理信息系统-验收管理
	author:		卢苇
	CreateDate:	2010-10-31
	UpdateDate: 
*/

--验收单：
update eqpAcceptInfo
set unit = g.unit
from eqpAcceptInfo e left join GBT14885 g on e.aTypeCode = g.aTypeCode

update eqpAcceptInfo 
set obtainMode = 1,purchaseMode=2

alter TABLE eqpAcceptInfo add	photoXml xml null					--设备照片：add by lw 2012-10-25
update 	eqpAcceptInfo
set photoXml=N'<root></root>'

alter TABLE eqpAcceptInfo add eqpLocate nvarchar(100) null	--设备所在地址:设备所在地add by lw 2012-10-27
alter TABLE eqpAcceptInfo add photoXml xml null					--设备照片：add by lw 2012-10-25
alter TABLE eqpAcceptInfo add eqpLocate nvarchar(100) null		--设备所在地址:设备所在地add by lw 2012-10-27
select * from eqpAcceptInfo where acceptApplyID='201209290007'
drop TABLE eqpAcceptInfo
CREATE TABLE eqpAcceptInfo
(
	acceptApplyType smallint default(0),--验收单类型：0->主设备验收单，1->附件验收单 add by lw 2011-6-28修改为支持
	acceptApplyID char(12) not null,	--主键：验收单号，使用第 1 号号码发生器产生
	applyDate smalldatetime default(getdate()),	--申请日期 add by lw 2010-12-5
	acceptApplyStatus int default(0),	--验收单状态：0->正在编制，1->已发送未审核，2->已审核通过；未审核通过直接恢复0状态
	procurementPlanID char(12) null,	--对应的采购计划单号，这是一个留待扩展的字段
	
	eTypeCode char(8) not null,			--分类编号（教）
	eTypeName nvarchar(30) not null,	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
	aTypeCode varchar(7) not null,		--分类编号（财）
										--根据GB/T 14885-2010规定将编码延长到7位modi by lw 2012-2-23
	
	eName nvarchar(30) not null,		--设备名称
	eModel nvarchar(20) not null,		--设备型号
	eFormat nvarchar(20) not null,		--设备规格
	unit nvarchar(10) null,				--计量单位：add by lw 2012-10-5该单位从GBT14885表中获取
	cCode char(3) not null,				--国家代码
	factory	nvarchar(20) not null,		--生产厂家
	makeDate smalldatetime null,		--出厂日期，在界面上拦截
	serialNumber nvarchar(2100) null,	--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
	buyDate smalldatetime not null,		--购置日期，不允许空值，老数据有部分是空值，这个需要先行转换数据
	business nvarchar(20) not null,		--销售单位
	fCode char(2) not null,				--经费来源代码
	aCode char(2) null,					--使用方向代码：老数据中有空值，需要用户确认是否允许空值！！！不允许！
	clgCode char(3) not null,			--学院代码
	clgName nvarchar(30) null,			--学院名称:冗余设计，保存历史数据 add by lw 2010-11-30
	uCode varchar(8) null,				--使用单位代码：老数据中有空值，需要用户确认是否允许空值！！！不允许,modi by lw 2011-2-11根据设备处要求延长编码长度！
	uName nvarchar(30) null,			--使用单位名称:冗余设计，保存历史数据 add by lw 2010-11-30
	keeperID varchar(10) null,			--保管人工号,add by lw 2012-8-10
	keeper nvarchar(30) null,			--保管人
	eqpLocate nvarchar(100) null,		--设备所在地址:设备所在地add by lw 2012-10-27

	annexName nvarchar(20) null,		--附件名称
	--modi by lw 2011-2-22 应小毕的要求，不需要随机附件编号，UI中已经删除，数据库暂时不动
	--annexCode nvarchar(2100) null,	--随机附件编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
	annexAmount	numeric(12,2) null,		--附件单价

	price numeric(12,2) null,			--单价，>0
	totalAmount numeric(12,2) null,		--总价, >0（单价+附件价格）
	sumNumber int not null,				--数量
	sumAmount numeric(15,2) not null,	--合计金额
	oprManID varchar(10) null,			--经办人工号,add by lw 2012-8-10
	oprMan nvarchar(30) null,			--经办人

	notes nvarchar(50) null,			--备注
	startECode char(8) null,			--设备起始编号,使用号码发生器产生或手工输入，但是要检查重码
										--2位年份代码+6位流水号，号码预先生成，每个人有一个号段XXX
										--使用手工输入号码，自动检测号码是否重号
	endECode char(8) null,				--设备结束编号
	accountCode varchar(9) null,		--会计科目代码 --modi by lw 2011-4-4修改为动态扩展字符串
	acceptDate smalldatetime null,		--验收日期
	acceptManID varchar(10) null,		--验收人工号
	acceptMan nvarchar(30) null,		--验收人
	photoXml xml null,					--设备照片：add by lw 2012-10-25
	--计划增加的字段：毕处同意增加 2012-10-3
	obtainMode int default(1),			--取得方式：由第11号代码字典定义，add by lw 2012-10-1默认方式：购置
	purchaseMode int default(2),		--采购组织形式：由第18号代码字典定义，add by lw 2012-10-1默认值：部门集中采购


	
	--创建人：add by lw 2012-8-8为了保持操作的范围——个人的一致性增加的字段
	createManID varchar(10) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间
	
	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName varchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
 CONSTRAINT [PK_eqpAcceptInfo] PRIMARY KEY CLUSTERED 
(
	[acceptApplyID] desc
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
--索引：
CREATE NONCLUSTERED INDEX [IX_eqpAcceptInfo] ON [dbo].[eqpAcceptInfo] 
(
	[clgCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_eqpAcceptInfo_1] ON [dbo].[eqpAcceptInfo] 
(
	[clgCode] ASC,
	[uCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



select * from accountTitle where accountCode ='14003040 '

drop FUNCTION getSerialNumber
/*
	name:		getSerialNumber
	function:	0.1.将验收单的出厂编号转换为行集
	input: 
				@acceptApplyID char(12)	--验收单号
	output: 
				return table
				(
					serialNumber varchar(20)
				)		--出厂编号的行集
	author:		卢苇
	CreateDate:	2012-9-18
	UpdateDate: 
*/
create FUNCTION getSerialNumber
(  
	@acceptApplyID char(12)	--验收单号
)  
RETURNS @ret table
(
	serialNumber nvarchar(20)
)
WITH ENCRYPTION
AS      
begin
	DECLARE @String NVARCHAR(max);
	SET @String = isnull((select serialNumber from eqpAcceptInfo where acceptApplyID = @acceptApplyID),'')
	insert @ret
	SELECT convert(nvarchar(20),T.x.query('data(.)')) FROM 
			(SELECT CONVERT(XML,'<x>'+REPLACE(@String,'|','</x><x>')+'</x>',1) Col1) A
			OUTER APPLY A.Col1.nodes('/x') AS T(x)
	return
end
--测试：
select * from dbo.getSerialNumber('201208250001')

drop FUNCTION includedSerialNumber
/*
	name:		includedSerialNumber
	function:	0.2.检查验收单的出厂编号集中是否包含指定的出厂编号
	input: 
				@acceptApplyID char(12),	--验收单号
				@serialNumber nvarchar(20)	--出厂编号
	output: 
				return int,					--是否包含指定的出厂编号：0->不包含，1->包含
	author:		卢苇
	CreateDate:	2012-9-18
	UpdateDate: 
*/
create FUNCTION includedSerialNumber
(  
	@acceptApplyID char(12),	--验收单号
	@serialNumber nvarchar(20)	--出厂编号
)  
RETURNS int
WITH ENCRYPTION
AS      
begin
	DECLARE @String NVARCHAR(max);
	SET @String = isnull((select serialNumber from eqpAcceptInfo where acceptApplyID = @acceptApplyID),'')
	declare @ret int
	set @ret = 0
	if @serialNumber in (SELECT convert(nvarchar(20),T.x.query('data(.)')) FROM 
			(SELECT CONVERT(XML,'<x>'+REPLACE(@String,'|','</x><x>')+'</x>',1) Col1) A
			OUTER APPLY A.Col1.nodes('/x') AS T(x))
		set @ret = 1
	else
		set @ret = 0
	return @ret
end
--测试：
select dbo.includedSerialNumber('201208250001','50')

drop FUNCTION includedSerialNumber2
/*
	name:		includedSerialNumber2
	function:	0.3.检查验收单的出厂编号集中是否包含指定的出厂编号（使用字符串匹配方法）
	input: 
				@acceptApplyID char(12),	--验收单号
				@serialNumber nvarchar(20)	--出厂编号
	output: 
				return int,					--是否包含指定的出厂编号：0->不包含，1->包含
	author:		卢苇
	CreateDate:	2012-9-18
	UpdateDate: 
*/
create FUNCTION includedSerialNumber2
(  
	@acceptApplyID char(12),	--验收单号
	@serialNumber nvarchar(20)	--出厂编号
)  
RETURNS int
WITH ENCRYPTION
AS      
begin
	DECLARE @String NVARCHAR(2100);
	SET @String = isnull((select serialNumber from eqpAcceptInfo where acceptApplyID = @acceptApplyID),'')
	declare @ret int
	set @ret = CHARINDEX(@serialNumber, @String)
	
	if @ret > 0
	begin
		if @ret > 1
		begin
			if (substring(@String,@ret - 1,1)<>'|')
				return 0
		end
		declare @len int
		set @len = len(@serialNumber)
		if (@ret + @len <= len(@string))
		begin
			if (substring(@String,@ret + @len,1)<>'|')
				return 0
		end
		set @ret = 1
	end
	else
		set @ret = 0
	return @ret
end
--测试：
select dbo.includedSerialNumber2('201208250001','50')

--比较两种算法的速度：
select acceptApplyID, serialNumber, flag
from (select acceptApplyID, serialNumber, dbo.includedSerialNumber(acceptApplyID,N'1') flag from eqpAcceptInfo) as tab
where tab.flag=1 

select acceptApplyID, serialNumber, flag
from (select acceptApplyID, serialNumber, dbo.includedSerialNumber2(acceptApplyID,N'49') flag from eqpAcceptInfo) as tab
where tab.flag=1 

select * from
(select acceptApplyID, serialNumber, flag
from (select acceptApplyID, serialNumber, dbo.includedSerialNumber(acceptApplyID,N'1') flag from eqpAcceptInfo) as tab
where tab.flag=1) as t1
right join
(select acceptApplyID, serialNumber, flag
from (select acceptApplyID, serialNumber, dbo.includedSerialNumber2(acceptApplyID,N'1') flag from eqpAcceptInfo) as tab
where tab.flag=1) as t2 on t1.acceptApplyID = t2.acceptApplyID
where t1.acceptApplyID is null

drop FUNCTION findIncludedSerialNumber
/*
	name:		findIncludedSerialNumber
	function:	0.4.检查验收单表中的出厂编号集，返回包含指定的出厂编号（使用字符串匹配方法,出厂编号可能为多个，使用“,”分隔）的行集
	input: 
				@serialNumber nvarchar(max),	--出厂编号：多个出厂编号使用","分隔
				@matchType int	--匹配方式：0->完整匹配，1->左端匹配
	output: 
				return int,					--是否包含指定的出厂编号：0->不包含，1->包含
	author:		卢苇
	CreateDate:	2012-9-18
	UpdateDate: 
*/
create FUNCTION findIncludedSerialNumber
(  
	@serialNumber nvarchar(max),	--出厂编号：多个出厂编号使用","分隔
	@matchType int	--匹配方式：0->完整匹配，1->左端匹配
)  
RETURNS @retTab table
(
	acceptApplyID char(12) not null	--验收单号
)
WITH ENCRYPTION
AS      
begin
	--将要匹配的出厂编号分解成行集：
	declare @m table
	(
		s nvarchar(20)
	)
	insert @m
	SELECT convert(nvarchar(20),T.x.query('data(.)')) FROM 
			(SELECT CONVERT(XML,'<x>'+REPLACE(@serialNumber,',','</x><x>')+'</x>',1) Col1) A
			OUTER APPLY A.Col1.nodes('/x') AS T(x)
	declare @s nvarchar(20)
	declare tar cursor Scroll for
	select s from @m
	For Read Only
	OPEN tar
	
	DECLARE @acceptApplyID char(12)	--验收单号
	DECLARE @String NVARCHAR(2100);
	declare tar1 cursor for
	select acceptApplyID, serialNumber from eqpAcceptInfo
	OPEN tar1
	FETCH NEXT FROM tar1 INTO @acceptApplyID, @String
	WHILE @@FETCH_STATUS = 0
	begin
		FETCH first FROM tar INTO @s
		WHILE @@FETCH_STATUS = 0
		begin
			declare @ret int
			set @ret = CHARINDEX(@s, @String)
			
			if @ret > 0
			begin
				if @ret > 1
				begin
					if (substring(@String,@ret - 1,1)<>'|')
						break
				end
				if (@matchType=0)	--完整匹配
				begin
					declare @len int
					set @len = len(@s)
					if (@ret + @len <= len(@string))
					begin
						if (substring(@String,@ret + @len,1)<>'|')
							break
					end
				end
				insert @retTab
				values(@acceptApplyID)
			end
			FETCH NEXT FROM tar INTO @s
		end
		
		FETCH NEXT FROM tar1 INTO @acceptApplyID, @String
	end
	CLOSE tar1
	DEALLOCATE tar1

	CLOSE tar
	DEALLOCATE tar

	return
end
--测试：
select acceptApplyID, serialNumber from eqpAcceptInfo where acceptApplyID in (select acceptApplyID from dbo.findIncludedSerialNumber('50,10',0))

select distinct acceptApplyID
from
((select acceptApplyID, serialNumber, flag
from (select acceptApplyID, serialNumber, dbo.includedSerialNumber2(acceptApplyID,N'49') flag from eqpAcceptInfo) as tab
where tab.flag=1) 
union all
(select acceptApplyID, serialNumber, flag
from (select acceptApplyID, serialNumber, dbo.includedSerialNumber2(acceptApplyID,N'99') flag from eqpAcceptInfo) as tab
where tab.flag=1)
) as t


drop PROCEDURE addAcceptApply
/*
	name:		addAcceptApply
	function:	1.添加验收申请单
				注意：该存储过程自动锁定单据
	input: 
				@eTypeCode char(8),			--分类编号（教）
				@eTypeName nvarchar(30),	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
				@aTypeCode varchar(7),		--分类编号（财）
				@eName nvarchar(30),		--设备名称
				@eModel nvarchar(20),		--设备型号
				@eFormat nvarchar(20),		--设备规格
				@cCode char(3),				--国家代码
				@factory nvarchar(20),		--出厂厂家
				@makeDate smalldatetime,	--出厂日期，在界面上拦截
				@serialNumber nvarchar(2100),--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
				@buyDate smalldatetime,		--购置日期
				@business nvarchar(20),		--销售单位
				@fCode char(2),				--经费来源代码
				@aCode char(2),				--使用方向代码
				@clgCode char(3),			--学院代码
				@uCode varchar(8),			--使用单位代码
				@keeperID varchar(10),		--保管人工号,add by lw 2012-8-10
				@annexName nvarchar(20),	--附件名称
				--modi by lw 2011-2-22 应小毕的要求，不需要随机附件编号
				--@annexCode nvarchar(2100),--随机附件编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
				@annexAmount numeric(12,2),	--附件金额
				@price numeric(12,2),		--单价，>0
				@sumNumber int,				--数量
				@oprManID varchar(10),		--经办人工号,add by lw 2012-8-10
				@notes nvarchar(50),		--备注
				@photoXml xml,				--设备照片：add by lw 2012-10-25
				@eqpLocate nvarchar(100),	--设备所在地址:设备所在地add by lw 2012-12-19

				@createManID varchar(10),	--创建人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9:未知错误
				@createTime smalldatetime output	--添加时间
				@acceptApplyID char(12) output	--生成的验收单号，使用第 1 号号码发生器产生
	author:		卢苇
	CreateDate:	2010-10-31
	UpdateDate: modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2011-2-22 应小毕的要求，不需要随机附件编号

				modi by lw 2012-2-23根据新国标GB/T 14885-2010延长财政部分类编号长度，
				增加教育部分类名称的备注和财政部分类的备注
				modi by lw 2012-8-8增加创建人字段
				modi by lw 2012-8-9保管人和经办人使用工号输入
				modi by lw 2012-10-5增加计量单位字段，根据财政部编码自动检索GBT14885获取相应的计量单位，本次修改未修订接口
				modi by lw 2012-10-25增加设备照片处理
				modi by lw 2012-10-27修改了内部合计金额变量长度不够的问题
				modi by lw 2012-12-19增加设备所在地字段
*/
create PROCEDURE addAcceptApply
	@eTypeCode char(8),			--分类编号（教）
	@eTypeName nvarchar(30),	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
	@aTypeCode varchar(7),		--分类编号（财）
	@eName nvarchar(30),		--设备名称
	@eModel nvarchar(20),		--设备型号
	@eFormat nvarchar(20),		--设备规格
	@cCode char(3),				--国家代码
	@factory nvarchar(20),		--出厂厂家
	@makeDate smalldatetime,	--出厂日期，在界面上拦截
	@serialNumber nvarchar(2100),--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
	@buyDate smalldatetime,		--购置日期
	@business nvarchar(20),		--销售单位
	@fCode char(2),				--经费来源代码
	@aCode char(2),				--使用方向代码
	@clgCode char(3),			--学院代码
	@uCode varchar(8),			--使用单位代码
	@keeperID varchar(10),		--保管人工号,add by lw 2012-8-10
	@annexName nvarchar(20),	--附件名称
	--modi by lw 2011-2-22 应小毕的要求，不需要随机附件编号
	--@annexCode nvarchar(2100),--随机附件编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
	@annexAmount numeric(12,2),	--附件金额
	@price numeric(12,2),		--单价，>0
	@sumNumber int,				--数量
	@oprManID varchar(10),		--经办人工号,add by lw 2012-8-10
	@notes nvarchar(50),		--备注
	@photoXml xml,				--设备照片：add by lw 2012-10-25
	@eqpLocate nvarchar(100),	--设备所在地址:设备所在地add by lw 2012-12-19

	@createManID varchar(10),	--创建人工号

	@Ret		int output,
	@createTime smalldatetime output,
	@acceptApplyID char(12) output	--主键：验收单号，使用第 1 号号码发生器产生
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--使用号码发生器产生新的号码：
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 1, 1, @curNumber output
	set @acceptApplyID = @curNumber

	--取维护人的姓名：
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--取计量单位：
	declare @unit nvarchar(10)
	set @unit = ISNULL((select unit from GBT14885 where aTypeCode = @aTypeCode),'')
	
	--计算金额：
	declare @totalAmount numeric(12,2)			--总价, >0（单价+附件价格）
	declare @sumAmount numeric(15,2)			--合计金额
	set @totalAmount = 	@annexAmount + @price
	set @sumAmount = @totalAmount * @sumNumber
	
	--获取院别和使用单位的名称：
	declare @clgName nvarchar(30), @uName nvarchar(30)	--学院名称/使用单位名称
	set @clgName = (select clgName from college where clgCode = @clgCode)
	set @uName = (select uName from useUnit where uCode = @uCode)

	--取保管人、经办人的姓名：
	declare @keeper nvarchar(30),@oprMan nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @oprMan = isnull((select cName from userInfo where jobNumber = @oprManID),'')
	
	set @createTime = getdate()
	insert eqpAcceptInfo(acceptApplyID, eTypeCode, eTypeName, aTypeCode, eName,
							eModel, eFormat, unit, cCode, factory, makeDate, serialNumber, buyDate, business, fCode, aCode, 
							clgCode, clgName, uCode, uName, 
							keeperID, keeper, annexName, annexAmount, price, totalAmount, sumNumber, sumAmount,
							oprManID, oprMan, notes,photoXml, eqpLocate,
							lockManID, modiManID, modiManName, modiTime,
							createManID, createManName, createTime) 
	values (@acceptApplyID, @eTypeCode, @eTypeName, @aTypeCode, @eName,
							@eModel, @eFormat, @unit, @cCode, @factory, @makeDate, @serialNumber, @buyDate, @business, @fCode, @aCode, 
							@clgCode, @clgName, @uCode, @uName, 
							@keeperID, @keeper, @annexName, @annexAmount, @price, @totalAmount, @sumNumber, @sumAmount,
							@oprManID, @oprMan, @notes,@photoXml, @eqpLocate,
							@createManID, @createManID, @createManName, @createTime,
							@createManID, @createManName, @createTime) 
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '添加验收申请单', '系统根据用户' + @createManName + 
					'的要求添加了验收申请单[' + @acceptApplyID + ']。')
GO

drop PROCEDURE queryAcceptApplyLocMan
/*
	name:		queryAcceptApplyLocMan
	function:	2.查询指定验收申请单是否有人正在编辑
	input: 
				@acceptApplyID char(12),	--主键：验收单号，使用第 1 号号码发生器产生
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：查询出错，可能是指定的验收单不存在
				@lockManID varchar(10) output		--当前正在编辑的人的工号
	author:		卢苇
	CreateDate:	2010-10-31
	UpdateDate: 
*/
create PROCEDURE queryAcceptApplyLocMan
	@acceptApplyID char(12),	--主键：验收单号，使用第 1 号号码发生器产生
	@Ret int output,			--操作成功标识
	@lockManID varchar(10) output		--当前正在编辑的人的工号
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from eqpAcceptInfo where acceptApplyID = @acceptApplyID),'')
	set @Ret = 0
GO


drop PROCEDURE lockAcceptInfo4Edit
/*
	name:		lockAcceptInfo4Edit
	function:	3.锁定验收单编辑，避免编辑冲突
	input: 
				@acceptApplyID char(12),	--主键：验收单号，使用第 1 号号码发生器产生
				@lockManID varchar(10) output,	--锁定人，如果当前验收单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1：要锁定的验收单不存在，2:要锁定的验收单正在被别人编辑，3:该单据已审核
							9：未知错误
	author:		卢苇
	CreateDate:	2010-10-31
	UpdateDate: 
*/
create PROCEDURE lockAcceptInfo4Edit
	@acceptApplyID char(12),		--主键：验收单号，使用第 1 号号码发生器产生
	@lockManID varchar(10) output,	--锁定人，如果当前验收单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断要锁定的验收单是否存在
	declare @count as int
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpAcceptInfo where acceptApplyID = @acceptApplyID),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	declare @acceptApplyStatus int
	set @acceptApplyStatus = (select acceptApplyStatus from eqpAcceptInfo where acceptApplyID = @acceptApplyID)
	if (@acceptApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end

/*	根据毕处的要求，放开单据修改权限，所以删除！del by lw 2010-11-22
	--取最后维护人的ID
	declare @modiManID int
	set @modiManID = (select modiManID from eqpAcceptInfo where acceptApplyID = @acceptApplyID)
	--检查权限：
	if @lockManID <> @modiManID	--设备管理员只能锁定自己的单据
	begin
		set @Ret = 3
		return
	end
*/
	update eqpAcceptInfo 
	set lockManID = @lockManID 
	where acceptApplyID = @acceptApplyID
	set @Ret = 0

	--取维护人的姓名：
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '锁定验收单编辑', '系统根据用户' + @lockManName
												+ '的要求锁定了验收单['+ @acceptApplyID +']为独占式编辑。')
GO

drop PROCEDURE unlockAcceptInfoEditor
/*
	name:		unlockAcceptInfoEditor
	function:	4.释放验收单编辑锁
				注意：本过程不检查单据是否存在！
	input: 
				@acceptApplyID char(12),		--主键：验收单号，使用第 1 号号码发生器产生
				@lockManID varchar(10) output,	--锁定人，如果当前验收单正在被人占用编辑则返回该人的工号
	output: 
				@Ret int output					--操作成功标识
												0:成功，1：要释放编辑锁的锁定人不是自己，9：未知错误
	author:		卢苇
	CreateDate:	2010-10-31
	UpdateDate: 
*/
create PROCEDURE unlockAcceptInfoEditor
	@acceptApplyID char(12),		--主键：验收单号，使用第 1 号号码发生器产生
	@lockManID varchar(10) output,	--锁定人，如果当前验收单正在被人占用编辑则返回该人的工号
	@Ret int output					--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--检查编辑锁：
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from eqpAcceptInfo where acceptApplyID = @acceptApplyID),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update eqpAcceptInfo set lockManID = '' where acceptApplyID = @acceptApplyID
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
	values(@lockManID, @lockManName, getdate(), '释放验收单编辑锁', '系统根据用户' + @lockManName
												+ '的要求释放了验收单['+ @acceptApplyID +']的编辑锁。')
GO


drop PROCEDURE updateAcceptInfo
/*
	name:		updateAcceptInfo
	function:	5.更新验收单
	input: 
				@acceptApplyID char(12),	--验收单号
				@applyDate smalldatetime,	--申请日期
				@eTypeCode char(8),			--分类编号（教）
				@eTypeName nvarchar(30),	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
				@aTypeCode varchar(7),		--分类编号（财）
				@eName nvarchar(30),		--设备名称
				@eModel nvarchar(20),		--设备型号
				@eFormat nvarchar(20),		--设备规格
				@cCode char(3),				--国家代码
				@factory nvarchar(20),		--出厂厂家
				@makeDate smalldatetime,	--出厂日期，在界面上拦截
				@serialNumber nvarchar(2100),--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
				@buyDate smalldatetime,		--购置日期
				@business nvarchar(20),		--销售单位
				@fCode char(2),				--经费来源代码
				@aCode char(2),				--使用方向代码
				@clgCode char(3),			--学院代码
				@uCode varchar(8),			--使用单位代码
				@keeperID varchar(10),		--保管人工号,add by lw 2012-8-10
				@annexName nvarchar(20),	--附件名称
				--modi by lw 2011-2-22 应小毕的要求，不需要随机附件编号
				--@annexCode nvarchar(2100),--随机附件编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
				@annexAmount numeric(12,2),	--附件金额
				@price numeric(12,2),		--单价，>0
				@sumNumber int,				--数量
				@oprManID varchar(10),		--经办人人工号,add by lw 2012-8-10
				@notes nvarchar(50),		--备注
				@photoXml xml,				--设备照片：add by lw 2012-10-25
				@eqpLocate nvarchar(100),	--设备所在地址:设备所在地add by lw 2012-12-19

				--维护人:
				@modiManID varchar(10) output,		--维护人，如果当前验收单正在被人占用编辑则返回该人的工号
	output: 
				@updateTime smalldatetime output,	--更新时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的验收申请单不存在，2：要更新的验收单正被别人锁定，3:该单据已经通过审核，不允许修改，9：未知错误
	author:		卢苇
	CreateDate:	2010-10-31
	UpdateDate: 2011-1-18增加申请日期的修改
				modi by lw 2011-2-11根据设备处要求延长编码长度！
				modi by lw 2011-2-22 应小毕的要求，不需要随机附件编号
				modi by lw 2012-2-23根据新国标GB/T 14885-2010延长财政部分类编号长度，
				增加教育部分类名称的备注和财政部分类的备注
				modi by lw 2012-10-5增加计量单位字段，根据财政部编码自动检索GBT14885获取相应的计量单位，本次修改未修订接口
				modi by lw 2012-10-25增加设备照片处理
				modi by lw 2012-12-19增加设备所在地字段
*/
create PROCEDURE updateAcceptInfo
	@acceptApplyID char(12),	--验收单号
	@applyDate smalldatetime,	--申请日期
	@eTypeCode char(8),			--分类编号（教）
	@eTypeName nvarchar(30),	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
	@aTypeCode varchar(7),		--分类编号（财）
	@eName nvarchar(30),		--设备名称
	@eModel nvarchar(20),		--设备型号
	@eFormat nvarchar(20),		--设备规格
	@cCode char(3),				--国家代码
	@factory nvarchar(20),		--出厂厂家
	@makeDate smalldatetime,	--出厂日期，在界面上拦截
	@serialNumber nvarchar(2100),--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
	@buyDate smalldatetime,		--购置日期
	@business nvarchar(20),		--销售单位
	@fCode char(2),				--经费来源代码
	@aCode char(2),				--使用方向代码
	@clgCode char(3),			--学院代码
	@uCode varchar(8),			--使用单位代码
	@keeperID varchar(10),		--保管人工号,add by lw 2012-8-10
	@annexName nvarchar(20),	--附件名称
	--modi by lw 2011-2-22 应小毕的要求，不需要随机附件编号
	--@annexCode nvarchar(2100),--随机附件编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
	@annexAmount numeric(12,2),	--附件金额
	@price numeric(12,2),		--单价，>0
	@sumNumber int,				--数量
	@oprManID varchar(10),		--经办人工号,add by lw 2012-8-10
	@notes nvarchar(50),		--备注
	@photoXml xml,				--设备照片：add by lw 2012-10-25
	@eqpLocate nvarchar(100),	--设备所在地址:设备所在地add by lw 2012-12-19

	--维护人:
	@modiManID varchar(10) output,		--维护人，如果当前验收单正在被人占用编辑则返回该人的工号

	@updateTime smalldatetime output,	--更新时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的验收申请单是否存在
	declare @count as int
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @acceptApplyStatus int
	select @thisLockMan = isnull(lockManID,''), @acceptApplyStatus = acceptApplyStatus
	from eqpAcceptInfo 
	where acceptApplyID = @acceptApplyID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end
	
	--检查单据状态:
	if (@acceptApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end
	
	--计算金额：
	declare @totalAmount numeric(12,2)			--总价, >0（单价+附件价格）
	declare @sumAmount numeric(15,2)			--合计金额
	set @totalAmount = 	@annexAmount + @price
	set @sumAmount = @totalAmount * @sumNumber
	
	--取计量单位：
	declare @unit nvarchar(10)
	set @unit = ISNULL((select unit from GBT14885 where aTypeCode = @aTypeCode),'')

	--获取院别和使用单位的名称：
	declare @clgName nvarchar(30), @uName nvarchar(30)	--学院名称/使用单位名称
	set @clgName = (select clgName from college where clgCode = @clgCode)
	set @uName = (select uName from useUnit where uCode = @uCode)

	--取保管人、经办人姓名的姓名：
	declare @keeper nvarchar(30),@oprMan nvarchar(30)
	set @keeper = isnull((select cName from userInfo where jobNumber = @keeperID),'')
	set @oprMan = isnull((select cName from userInfo where jobNumber = @oprManID),'')

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @updateTime = getdate()
	update eqpAcceptInfo 
	set applyDate = @applyDate, eTypeCode = @eTypeCode, eTypeName = @eTypeName, aTypeCode = @aTypeCode, eName = @eName,
		eModel = @eModel, eFormat = @eFormat, unit = @unit, cCode = @cCode, 
		factory = @factory, makeDate = @makeDate, serialNumber = @serialNumber, 
		buyDate = @buyDate, business = @business, fCode = @fCode, aCode = @aCode, 
		clgCode = @clgCode, clgName = @clgName, uCode = @uCode, uName = @uName,
		keeperID = @keeperID, keeper = @keeper, annexName = @annexName, annexAmount = @annexAmount, 
		price = @price, totalAmount = @totalAmount, sumNumber = @sumNumber, sumAmount = @sumAmount,
		oprManID = @oprManID, oprMan = @oprMan, notes = @notes,
		photoXml = @photoXml, eqpLocate = @eqpLocate,
		--维护情况:
		modiManID = @modiManID, modiManName = @modiManName,	modiTime = @updateTime
	where acceptApplyID = @acceptApplyID
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @updateTime, '更新验收单', '用户' + @modiManName 
												+ '更新了验收单['+ @acceptApplyID +']。')
GO


drop PROCEDURE delAcceptApply
/*
	name:		delAcceptApply
	function:	6.删除指定的验收申请单
	input: 
				@acceptApplyID char(12),	--验收申请单号
				@delManID varchar(10) output,	--删除人，如果当前验收申请单正在被人占用编辑则返回该人的工号
	output: 
				@Ret		int output			--操作成功标识
							0:成功，1：指定的验收申请单不存在，2：要删除的验收申请单正被别人锁定，3：单据已审核生效，不能删除，9：未知错误
	author:		卢苇
	CreateDate:	2010-10-31
	UpdateDate: 

*/
create PROCEDURE delAcceptApply
	@acceptApplyID char(12),	--验收单号
	@delManID varchar(10) output,	--删除人，如果当前验收申请单正在被人占用编辑则返回该人的工号
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的验收申请单是否存在
	declare @count as int
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @acceptApplyStatus int
	select @thisLockMan = isnull(lockManID,''), @acceptApplyStatus = acceptApplyStatus
	from eqpAcceptInfo 
	where acceptApplyID = @acceptApplyID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@acceptApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end

	delete eqpAcceptInfo where acceptApplyID = @acceptApplyID
	set @Ret = 0

	--取维护人的姓名：
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), '删除验收申请单', '用户' + @delManName
												+ '删除了验收申请单['+ @acceptApplyID +']。')

GO


drop PROCEDURE sendAcceptApply
/*
	name:		sendAcceptApply
	function:	7.发送验收单
				备注：该存储过程现在没有使用！！
	input: 
				@acceptApplyID char(12),	--验收单号

				--维护人:
				@sendManID varchar(10) output,	--发送人，如果当前验收单正在被人占用编辑则返回该人的工号
	output: 

				@sendTime smalldatetime output,	--发送时间
				@Ret		int output		--操作成功标识
							0:成功，1：指定的验收申请单不存在，2：要发送的验收单正被别人锁定，3：单据已送审，不能再次发送，9：未知错误
	author:		卢苇
	CreateDate:	2010-10-31
	UpdateDate: 
*/
create PROCEDURE sendAcceptApply
	@acceptApplyID char(12),	--验收单号

	--维护人:
	@sendManID varchar(10) output,	--发送人，如果当前验收单正在被人占用编辑则返回该人的工号

	@sendTime smalldatetime output,	--发送时间
	@Ret		int output		--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--判断指定的验收申请单是否存在
	declare @count as int
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @acceptApplyStatus int
	select @thisLockMan = isnull(lockManID,''), @acceptApplyStatus = acceptApplyStatus
	from eqpAcceptInfo 
	where acceptApplyID = @acceptApplyID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @sendManID)
	begin
		set @sendManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@acceptApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end

	--取维护人的姓名：
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @sendManID),'')
	
	set @sendTime = getdate()
	update eqpAcceptInfo
	set acceptApplyStatus = 1,	--验收单状态：0->正在编制，1->已发送未审核，2->已审核通过；未审核通过直接恢复0状态
		--维护人：
		modiManID = @sendManID, modiManName = @modiManName,	modiTime = @sendTime
	where acceptApplyID = @acceptApplyID
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@sendManID, @modiManName, @sendTime, '发送验收单', '用户' + @modiManName 
												+ '发送了验收单['+ @acceptApplyID +']。')
GO

drop PROCEDURE verifyAcceptApply
/*
	name:		verifyAcceptApply
	function:	8.审核验收申请单，并生成设备清单
	input: 
				@acceptApplyID char(12),	--验收单号
				@eTypeCode char(8),			--分类编号（教）
				@eTypeName nvarchar(30),	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
				@aTypeCode varchar(7),		--分类编号（财）
				@startECode char(8),		--设备起始编号
				@accountCode varchar(9),	--会计科目代码

				--维护人:
				@verifyManID varchar(10) output,	--审核人，如果当前验收单正在被人占用编辑则返回该人的工号
	output: 
				@acceptDate smalldatetime output,	--验收日期
				@Ret		int output				--操作成功标识
													0:成功，1：指定的验收申请单不存在,2：要审核的验收单正被别人锁定，
													3：该验收单已经审核，4:定义的号码段被占用，9：未知错误
	author:		卢苇
	CreateDate:	2010-11-24
	UpdateDate: 2011-1-18增加设备生命周期信息登记
				modi by lw 2011-2-19修改验收人设置错误
				modi by lw 2011-2-22 应小毕的要求，不需要随机附件编号
				modi by lw 2011-4-4延长会计科目长度
				modi by lw 2011-6-28修改未登记附件库的错误，增加“添加附件”功能支持
				modi by lw 2011-10-8修改设备验收审核未登记设备eTypeName字段导致执行不成功错误和附件登记条件错错误！
				modi by lw 2011-10-15增加设备生命周期表中的变动类型、变动凭证登记！
				modi by lw 2011-10-16应客户要求验收审核的时候可以修改设备分类代码而增加的接口
				modi by lw 2012-2-23根据新国标GB/T 14885-2010延长财政部分类编号长度，
				增加教育部分类名称的备注和财政部分类的备注
				modi by lw 2012-8-9增加保管人和经办人工号
				modi by lw 2012-10-5增加计量单位\取得方式\采购组织形式字段传送，本次修改未修订接口
				modi by lw 2012-10-6删除了附件的锁定字段和维护字段
				modi by lw 2012-10-27增加设备照片送入设备现状库
				modi by lw 2012-12-19增加设备所占地字段处理
*/
create PROCEDURE verifyAcceptApply
	@acceptApplyID char(12),	--验收单号
	@eTypeCode char(8),			--分类编号（教）
	@eTypeName nvarchar(30),	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
	@aTypeCode varchar(7),		--分类编号（财）
	@startECode char(8),		--设备起始编号
	@accountCode varchar(9),	--会计科目代码

	--维护人:
	@verifyManID varchar(10) output,	--审核人，如果当前验收单正在被人占用编辑则返回该人的工号

	@acceptDate smalldatetime output,	--验收日期
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的验收申请单是否存在
	declare @count as int
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptApplyID)	
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @thisLockMan varchar(10), @acceptApplyStatus int
	declare @clgCode char(3), @uCode char(5)
	select @thisLockMan = isnull(lockManID,''), @acceptApplyStatus = acceptApplyStatus, @clgCode = clgCode, @uCode = uCode
	from eqpAcceptInfo 
	where acceptApplyID = @acceptApplyID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @verifyManID)
	begin
		set @verifyManID = @thisLockMan
		set @Ret = 2
		return
	end
	--再次检查单据状态:
	if (@acceptApplyStatus <> 0)
	begin
		set @Ret = 3
		return
	end

	--获取院别和使用单位的名称：
	declare @clgName nvarchar(30), @uName nvarchar(30)	--学院名称/使用单位名称
	set @clgName = (select clgName from college where clgCode = @clgCode)
	set @uName = (select uName from useUnit where uCode = @uCode)

	--构造出厂编号和附件编号表：
	declare @serialNumber nvarchar(2100)--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
	--modi by lw 2011-2-22 应小毕的要求，不需要随机附件编号
	--declare @annexCode nvarchar(2100)	--随机附件编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
	select @serialNumber = serialNumber	--, @annexCode = annexCode
	from eqpAcceptInfo 
	where acceptApplyID = @acceptApplyID
	declare @xmlSerialNumber xml	--, @xmlAnnexCode xml
	set @xmlSerialNumber = '<s>'+REPLACE(@serialNumber,'|','</s><s>')+'</s>'
	--set @xmlAnnexCode = '<a>'+REPLACE(@annexCode,'|','</a><a>')+'</a>'

	--取维护人的姓名：
	declare @acceptMan nvarchar(30)
	set @acceptMan = isnull((select userCName from activeUsers where userID = @verifyManID),'')

	set @acceptDate = getdate()
	
	declare @length int
	set @length = (select sumNumber from eqpAcceptInfo where acceptApplyID = @acceptApplyID)
	--生成设备清单：
	begin tran
		--继续检查设备编号是否占用
		declare @execRet int
		exec dbo.checkEqpCodes @startECode, @length, @execRet output
		if (@execRet <> 0)
		begin 
			set @Ret = @execRet
			if (@Ret = -1)
				set @Ret = 4
			rollback tran
			return
		end
		--生成结束号码
		declare @intEndNum int
		set @intEndNum = cast(right(@startECode,6) as int) + @length - 1
		declare @endCode as varchar(8)
		set @endCode = left(@startECode,2) + right('00000' + ltrim(convert(varchar(6),@intEndNum)), 6)
		--占用该号码段：
		update eqpCodeList 
		set isUsed = 'Y'
		where eCode >= @startECode and eCode <= @endCode
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    

		--获取附件信息：
		declare @annexName nvarchar(20), @annexAmount numeric(12,2)	--附件名称,附件金额（就是附件单价）
		select @annexName = annexName, @annexAmount = annexAmount
		from eqpAcceptInfo 
		where acceptApplyID = @acceptApplyID
				
		declare @rowID int --行号，用来取设备出厂编号和附件编号的序列号
		set @rowID = 1
		
		--逐个生成设备清单：
		declare @eCode char(8)
		declare tar cursor for
		select eCode from eqpCodeList 
		where eCode >= @startECode and eCode <= @endCode
		OPEN tar
		FETCH NEXT FROM tar INTO @eCode
		WHILE @@FETCH_STATUS = 0
		begin
			declare @curSerialNumber nvarchar(20)	--当前设备的出厂编号
			--declare @curAnnexCode nvarchar(20)		--当前设备的随机附件编号
			set @curSerialNumber = (select cast(@xmlSerialNumber.query('(/s)[sql:variable("@rowID")]/text()') as nvarchar(20)))
			--set @curAnnexCode = (select cast(@xmlAnnexCode.query('(/a)[sql:variable("@rowID")]/text()') as nvarchar(20)))
			--生成设备清单：
			insert equipmentList(eCode, acceptApplyID, eName, eModel, eFormat, unit, cCode, factory, annexName, annexAmount, business,
				eTypeCode, eTypeName, aTypeCode, 
				fCode, aCode, makeDate, buyDate, price, totalAmount, clgCode, uCode, keeperID, keeper,eqpLocate, notes,
				acceptDate, oprManID, oprMan, acceptManID, acceptMan, curEqpStatus,
				serialNumber, annexCode, obtainMode, purchaseMode,
				--最新维护情况:
				modiManID, modiManName, modiTime)
			select @eCode, @acceptApplyID, eName, eModel, eFormat, unit, cCode, factory, annexName, annexAmount, business,
				--modi by lw 2011-10-16
				@eTypeCode,@eTypeName,@aTypeCode,
				fCode, aCode, makeDate, buyDate, price, totalAmount, clgCode, uCode, keeperID, keeper,eqpLocate, notes,
				@acceptDate, oprManID, oprMan, @verifyManID, @acceptMan, '1',
				@curSerialNumber, '', obtainMode, purchaseMode,
				--最新维护情况:
				@verifyManID, @acceptMan, @acceptDate
			from eqpAcceptInfo 
			where acceptApplyID = @acceptApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			
			--生成附件库：add by lw 2011-6-28 modi by lw 2011-10-8判断条件错
			if rtrim(ltrim(isnull(@annexName,''))) not in('','无')
			begin
				insert equipmentAnnex(acceptApplyID, eCode, annexName, annexFormat, cCode, fCode,
					business, buyDate, factory, makeDate, quantity, price, totalAmount, oprMan, acceptMan, acceptManID)

				select @acceptApplyID, @eCode, annexName, '*', cCode, fCode,
					business, buyDate, factory, makeDate, 1, annexAmount, annexAmount, oprMan, @acceptMan, @verifyManID


				from eqpAcceptInfo 
				where acceptApplyID = @acceptApplyID
				if @@ERROR <> 0 
				begin
					set @Ret = 9
					rollback tran
					return
				end    
			end
						
			--登记设备的生命周期：
			insert eqpLifeCycle(eCode,eName, eModel, eFormat,
				clgCode, clgName, uCode, uName, keeper,
				annexAmount, price, totalAmount,
				changeDate, changeDesc,changeType,changeInvoiceID) 
			select @eCode, eName, eModel, eFormat, 
				clgCode, @clgName, uCode, @uName, keeper,
				annexAmount, price, totalAmount,
				@acceptDate, '验收通过，创建了该设备',
				'验收',@acceptApplyID
			from eqpAcceptInfo
			where acceptApplyID = @acceptApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end
			
			--生成设备现状库：add by lw 2012-10-27
			--只有数量为1的验收单允许输入设备照片，这需要在UI上做限制
			if (@length = 1)
			begin
				insert eqpStatusInfo(eCode, eName, sNumber, checkDate, keeperID, keeper, 
							eqpLocate, checkStatus,		--设备状态：
											--0：状态不明 --这种状态自动变更为正常
											--1：正常；
											--3：待修；
											--4：待报废；
											--5：有帐无物；
											--6：无帐无物；--这种状态应该无法确定！
											--9：其他。
							statusNotes, invoiceType, invoiceNum)
				select @eCode, eName, 1, acceptDate, keeperID, keeper, eqpLocate, 1,
					'设备入库状态', '1', acceptApplyID 
				from eqpAcceptInfo
				where acceptApplyID = @acceptApplyID

				insert eqpStatusPhoto(eCode, eName, sNumber, photoDate, aFilename, notes)
				select @eCode, eName, 1, cast(T.photo.query('data(./@photoDate)') as varchar(10)), 
					cast(T.photo.query('data(./@aFileName)') as varchar(128)), 
					cast(T.photo.query('data(./@notes)') as nvarchar(100))
				from eqpAcceptInfo CROSS APPLY photoXml.nodes('/root/photo') as T(photo)
				where acceptApplyID = @acceptApplyID
			end
			set @rowID = @rowID + 1
			FETCH NEXT FROM tar INTO @eCode
		end
		CLOSE tar
		DEALLOCATE tar

		--更新设备验收申请单状态：
		update eqpAcceptInfo
		set acceptApplyStatus = 2,	--验收单状态：0->正在编制，1->已发送未审核，2->已审核通过；未审核通过直接恢复0状态
			--add by lw 2011-10-16
			eTypeCode = @eTypeCode,	--分类编号（教）
			eTypeName = @eTypeName,	--教育部分类名称:为了解决多对多的问题需要增加的字段
			aTypeCode = @aTypeCode,	--分类编号（财）
			
			startECode = @startECode,
			endECode = @endCode,
			accountCode = @accountCode,
			acceptDate = @acceptDate,
			acceptManID = @verifyManID,
			acceptMan = @acceptMan,
			--维护人：
			modiManID = @verifyManID, modiManName = @acceptMan,	modiTime = @acceptDate
		where acceptApplyID = @acceptApplyID
		if @@ERROR <> 0 
		begin
			set @Ret = 9
			rollback tran
			return
		end    
	commit tran	
	
	set @Ret = 0

	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@verifyManID, @acceptMan, @acceptDate, '验收', '用户' + @acceptMan
												+ '审核通过了验收单['+ @acceptApplyID +'],系统生成了相应设备清单。')
GO
--测试：
select * from eqpAcceptInfo where acceptApplyID = '201210030001'
select * from equipmentList where acceptApplyID = '0000019968'
select * from workNote order by actionTime desc
select * from eqpCodeList
update eqpAcceptInfo
set acceptApplyStatus = 0
where acceptApplyID = '0000019968'
delete equipmentList where acceptApplyID = '0000019968'

select * from equipmentList where acceptApplyID = '201110080105'
select * from eqpAcceptInfo  where acceptApplyID = '201110080105'
update eqpAcceptInfo 
set acceptApplyStatus = 0
where acceptApplyID = '201110080105'

select * from eqpCodeList 

declare @acceptDate smalldatetime
declare @Ret int
exec dbo.verifyAcceptApply '201110080105', '11000010', '140030201', '00200977', @acceptDate output, @Ret output
select @acceptDate, @Ret

delete equipmentList where eCode = '10000016'
--Ret:0:成功，1：要审核的验收单正被别人锁定，2：该验收单已经审核，3:定义的号码段被占用，9：未知错误

drop PROCEDURE cancelVerifyAccept
/*
	name:		cancelVerifyAccept
	function:	9.取消验收单审核（撤销验收）
				注意：该存储过程会检查设备的生命周期表，如果该设备有调拨或报废操作则拒绝撤销！
	input: 
				@acceptApplyID char(12),			--验收单号

				--维护人:
				@cancelManID varchar(10) output,	--取消人，如果当前验收单正在被人占用编辑则返回该人的工号
	output: 
				@cancelDate smalldatetime output,	--取消日期
				@Ret		int output				--操作成功标识
													0:成功，1：指定的验收单不存在,2：要取消审核的验收单正被别人锁定，
													3：该单据不是已审核状态，
													4：该验收单所指定的设备已经有调拨或报废操作，
													5：该验收单生成的设备有编辑锁或长事务锁
													9：未知错误
	author:		卢苇
	CreateDate:	2011-10-9
	UpdateDate: modi by lw 2011-10-12增加释放编辑锁
				modi by lw 2011-10-30支持附件验收单的撤销
				modi by lw 2011-11-4支持老设备号码的回收
				modi by lw 2012-8-12增加检查设备是否有编辑锁或长事务锁检查
*/
create PROCEDURE cancelVerifyAccept
	@acceptApplyID char(12),			--验收单号
	@cancelManID varchar(10) output,	--取消人，如果当前验收单正在被人占用编辑则返回该人的工号
	@cancelDate smalldatetime output,	--取消日期
	@Ret		int output				--操作成功标识
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--判断指定的验收单是否存在
	declare @count as int
	set @count=(select count(*) from eqpAcceptInfo where acceptApplyID = @acceptApplyID)
	if (@count = 0)	--不存在
	begin
		set @Ret = 1
		return
	end

	declare @acceptApplyType smallint --验收单类型：0->主设备验收单，1->附件验收单 add by lw 2011-6-28修改为支持
	declare @thisLockMan varchar(10), @acceptApplyStatus int
	select @thisLockMan = isnull(lockManID,''), @acceptApplyStatus = acceptApplyStatus, @acceptApplyType = acceptApplyType
	from eqpAcceptInfo 
	where acceptApplyID = @acceptApplyID
	--检查编辑锁：
	if (@thisLockMan <> '' and @thisLockMan <> @cancelManID)
	begin
		set @cancelManID = @thisLockMan
		set @Ret = 2
		return
	end
	--检查单据状态:
	if (@acceptApplyStatus <> 2)
	begin
		set @Ret = 3
		return
	end
	--检查要取消验收的设备是否有编辑锁或长事务锁：
	set @count = (select COUNT(*) from equipmentList
					where  (acceptApplyID = @acceptApplyID 
							or eCode in (select eCode from equipmentAnnex where acceptApplyID = @acceptApplyID))
						  and (isnull(lockManID,'') <> '' or lock4LongTime <> 0))
	if (@count>0)
	begin
		set @Ret = 5
		return
	end

	--取维护人的姓名\时间：
	declare @cancelMan nvarchar(30)
	set @cancelMan = isnull((select userCName from activeUsers where userID = @cancelManID),'')
	set @cancelDate = getdate()

	declare @eCode char(8)
	if @acceptApplyType = 0
	begin
		--逐个扫描检查生成的设备：检查是否有调拨、报废、维修等操作
		declare tar cursor for
		select eCode from equipmentList
		where acceptApplyID = @acceptApplyID
		OPEN tar
		FETCH NEXT FROM tar INTO @eCode
		WHILE @@FETCH_STATUS = 0
		begin
			set @count=isnull((select count(*) from eqpLifeCycle where eCode = @eCode),0)
			if (@count > 1)	--有其他操作
			begin
				CLOSE tar
				DEALLOCATE tar
				set @Ret = 4
				return
			end
			FETCH NEXT FROM tar INTO @eCode
		end
		CLOSE tar
		DEALLOCATE tar

		begin tran
			--回收设备编号：
			update eqpCodeList 
			set isUsed = 'N'
			where eCode in (select eCode from equipmentList where acceptApplyID = @acceptApplyID)
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
			--对于老设备的号码回收要插入编号：
			insert eqpCodeList
			select eCode,'N' from equipmentList 
			where acceptApplyID = @acceptApplyID and eCode not in (select eCode from eqpCodeList)

			--删除所包含的设备：
			delete equipmentList
			where acceptApplyID = @acceptApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			--更新设备验收申请单状态：
			update eqpAcceptInfo
			set acceptApplyStatus = 0,	--验收单状态：0->正在编制，1->已发送未审核，2->已审核通过；未审核通过直接恢复0状态
				startECode = '',
				endECode = '',
				accountCode = '',
				acceptDate = null,
				acceptManID = null,
				acceptMan = null,
				lockManID = '',
				--维护人：
				modiManID = @cancelManID, modiManName = @cancelMan,	modiTime = @cancelDate
			where acceptApplyID = @acceptApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		commit tran	
		--登记工作日志：
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@cancelManID, @cancelMan, @cancelDate, '取消验收审核', '用户' + @cancelMan
													+ '取消了验收单['+ @acceptApplyID +']的审核。')
	end
	else	--附件验收单的处理
	begin
		begin tran
			--删除设备生命周期中的记录：
			delete eqpLifeCycle where changeInvoiceID= @acceptApplyID and changeType = '添加附件'
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			--更新主设备的附件信息和设备总价：
			--declare @eCode char(8)			--主设备编号
			declare @annexName nvarchar(20)	--附件名称
			declare @sumAmount numeric(12,2)		--合计金额
			select @annexName = annexName, @sumAmount = totalAmount, @eCode = eCode
			from equipmentAnnex
			where acceptApplyID = @acceptApplyID

			declare @curAnnexName nvarchar(20)
			set @curAnnexName = isnull((select annexName from equipmentList where eCode = @eCode),'')
			if @curAnnexName = @annexName
				set @curAnnexName = ''
			update equipmentList
			set annexName = @curAnnexName,
				annexAmount	= isnull(annexAmount,0) - @sumAmount,
				totalAmount = isnull(totalAmount,0) - @sumAmount
			where eCode = @eCode
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			--删除附件表中的记录：
			delete equipmentAnnex
			where acceptApplyID = @acceptApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    

			--更新附件验收单：
			update eqpAcceptInfo
			set acceptApplyStatus = 0,	--验收单状态：0->正在编制，1->已发送未审核，2->已审核通过；未审核通过直接恢复0状态
				acceptDate = null,
				lockManID = '',
				--维护人：
				modiManID = @cancelManID, modiManName = @cancelMan,	modiTime = @cancelDate
			where acceptApplyID = @acceptApplyID
			if @@ERROR <> 0 
			begin
				set @Ret = 9
				rollback tran
				return
			end    
		commit tran	

		--登记工作日志：
		insert workNote(userID, userName, actionTime, actions, actionObject)
		values(@cancelManID, @cancelMan, @cancelDate, '取消附件验收审核', '用户' + @cancelMan
													+ '取消了附件验收单['+ @acceptApplyID +']的审核。')
	end	
	set @Ret = 0

GO
--测试：
select * from eqpAcceptInfo 
where acceptApplyType = 1





--报表设计视图：
--验收单
drop view acceptInfoPView
create view acceptInfoPView
AS
	select e.acceptApplyID, convert(varchar(10), e.applyDate, 120) applyDate, 
	e.acceptApplyStatus, e.procurementPlanID,
	e.eTypeCode, e.eTypeName, e.aTypeCode, t.aTypeName, e.eName, e.eModel, e.eFormat, e.unit, e.cCode, c.cName,
	e.factory, convert(varchar(10), e.makeDate, 120) makeDate,
	e.serialNumber, convert(varchar(10),e.buyDate,120) buyDate,e.business,e.fCode, f.fName,e.aCode, a.aName,
	e.clgCode, e.clgName,clg.manager,e.uCode, e.uName,e.keeperID,e.keeper, 
	e.annexName, isnull(e.annexAmount,0) annexAmount,
	isnull(e.price,0) price, isnull(e.totalAmount,0) totalAmount,e.sumNumber,isnull(e.sumAmount,0) sumAmount,e.oprManID,e.oprMan,
	e.notes, startECode, endECode, e.accountCode, act.accountName, convert(varchar(10), e.acceptDate, 120) acceptDate, e.acceptMan,
	dbo.cUCaseForMoneyWithUnit(e.sumAmount)as UCaseForMoney,
	e.createManID, e.createManName,obtainMode,purchaseMode,photoXml,e.eqpLocate
	from eqpAcceptInfo e left join country c on e.cCode = c.cCode
	left join fundSrc f on e.fCode = f.fCode
	left join appDir a on e.aCode = a.aCode
	left join accountTitle act on e.accountCode = act.accountCode
	left join typeCodes t on e.eTypeCode = t.eTypeCode and e.eTypeName = t.eTypeName and e.aTypeCode = t.aTypeCode
	left join college clg on e.clgCode = clg.clgCode

GO


select fCode,oprMan,oprManID,* from eqpAcceptInfo where acceptApplyID='201305300004'

