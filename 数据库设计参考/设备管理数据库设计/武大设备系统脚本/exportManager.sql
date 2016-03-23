use epdc211
/*
	武大设备管理信息系统-大数据量导出控制架构
	author:		卢苇
	CreateDate:	2013-11-27
	UpdateDate: 
*/

drop TABLE exportInfo
CREATE TABLE exportInfo(
	rowNum int IDENTITY(1,1) NOT NULL,	--序号
	guidFilename varchar(128) not null,	--GUID文件名
	filename varchar(128) not null,		--文件显示名
	totalRecord bigint default(0),		--总记录数
	curRecord bigint default(0),		--当前处理到的记录数
	exportStatus varchar(30) default(''),--当前处理的状态：''->初始化状态,'processing'->正在处理,'completed'->已完成,'userBreak'->用户中断,'error'->出错
	errorDesc nvarchar(300) default(''),--详细的出错信息
	startTime datetime default(getdate()),	--导出启动时间
	lastTime datetime default(getdate()),	--上次写记录时间
	IsCancelRequested int default(0),	--用户是否请求中断该进程：0->未申请，1->申请中断
	
	exporterID varchar(10) null,		--导出人工号
	exporter varchar(30) null,			--导出人姓名

 CONSTRAINT [PK_exportInfo] PRIMARY KEY CLUSTERED 
(
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


drop PROCEDURE addExportInfo
/*
	name:		addExportInfo
	function:	1.登记导出进程
	input: 
				@guidFilename varchar(128),	--GUID文件名
				@filename varchar(128),		--文件显示名
				@totalRecord bigint,		--总记录数
				@exporterID varchar(10),	--导出人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2013-11-27
*/
create PROCEDURE addExportInfo
	@guidFilename varchar(128),	--GUID文件名
	@filename varchar(128),		--文件显示名
	@totalRecord bigint,		--总记录数
	@exporterID varchar(10),	--导出人工号
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--取导出人的姓名：
	declare @exporter nvarchar(30)
	set @exporter = isnull((select userCName from activeUsers where userID = @exporterID),'')

	insert exportInfo(guidFilename, filename, totalRecord, exporterID, exporter)
	values (@guidFilename, @filename, @totalRecord, @exporterID, @exporter)

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@exporterID, @exporter, GETDATE(), '导出', '用户' + @exporter + 
					'开始了[' + @filename + ']的导出进程。')
GO
--测试：
declare @Ret int
exec dbo.addExportInfo '123456789', '测试用例.xlsx', 2000, '00200977', @Ret output
select @Ret

select * from exportInfo

drop PROCEDURE addExportProcess
/*
	name:		addExportProcess
	function:	2.登记导出进度
	input: 
				@guidFilename varchar(128),	--GUID文件名
				@curRecord bigint,			--当前处理到的记录数
				@exporterID varchar(10),	--导出人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1:没有该导出文件，9：未知错误
	author:		卢苇
	CreateDate:	2013-11-27
*/
create PROCEDURE addExportProcess
	@guidFilename varchar(128),	--GUID文件名
	@curRecord bigint,			--当前处理到的记录数
	@exporterID varchar(10),	--导出人工号
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @count int
	set @count = isnull((select count(*) from exportInfo where guidFilename=@guidFilename and exporterID=@exporterID),0)
	if @count<>1
	begin
		set @Ret = 1
		return
	end

	update exportInfo
	set curRecord = @curRecord, lastTime=GETDATE(), exportStatus =case exportStatus when '' then 'processing' else exportStatus end
	where guidFilename = @guidFilename

	set @Ret = 0
GO
--测试：
declare @Ret int
exec dbo.addExportProcess '123456789',1100, '00200977', @Ret output
select @Ret

select * from exportInfo

drop PROCEDURE exportCancelRequest
/*
	name:		exportCancelRequest
	function:	3.申请中断导出进程
	input: 
				@guidFilename varchar(128),	--GUID文件名
				@exporterID varchar(10),	--导出人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1:没有该导出文件，9：未知错误
	author:		卢苇
	CreateDate:	2013-11-27
*/
create PROCEDURE exportCancelRequest
	@guidFilename varchar(128),	--GUID文件名
	@exporterID varchar(10),	--导出人工号
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @filename varchar(128)		--文件显示名
	select @filename = filename from exportInfo where guidFilename=@guidFilename and exporterID=@exporterID
	if ISNULL(@filename,'')=''
	begin
		set @Ret = 1
		return
	end

	--取导出人的姓名：
	declare @exporter nvarchar(30)
	set @exporter = isnull((select userCName from activeUsers where userID = @exporterID),'')

	update exportInfo
	set IsCancelRequested=1
	where guidFilename = @guidFilename

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@exporterID, @exporter, GETDATE(), '中断导出', '用户' + @exporter + 
					'中断了[' + @filename + ']的导出进程。')
GO
--测试：
declare @Ret int
exec dbo.exportCancelRequest '123456789','00200977', @Ret output
select @Ret

select * from exportInfo

drop PROCEDURE addExportErrorInfo
/*
	name:		addExportErrorInfo
	function:	4.登记导出出错信息
	input: 
				@guidFilename varchar(128),	--GUID文件名
				@errorDesc nvarchar(300),	--详细的出错信息
				@exporterID varchar(10),	--导出人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1:没有该导出文件，9：未知错误
	author:		卢苇
	CreateDate:	2013-11-27
*/
create PROCEDURE addExportErrorInfo
	@guidFilename varchar(128),	--GUID文件名
	@errorDesc nvarchar(300),	--详细的出错信息
	@exporterID varchar(10),	--导出人工号
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @filename varchar(128)		--文件显示名
	select @filename = filename from exportInfo where guidFilename=@guidFilename and exporterID=@exporterID
	if ISNULL(@filename,'')=''
	begin
		set @Ret = 1
		return
	end

	--取导出人的姓名：
	declare @exporter nvarchar(30)
	set @exporter = isnull((select userCName from activeUsers where userID = @exporterID),'')

	update exportInfo
	set exportStatus ='error', errorDesc=@errorDesc
	where guidFilename = @guidFilename

	set @Ret = 0
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@exporterID, @exporter, GETDATE(), '导出错误', '系统在执行用户' + @exporter + 
					'导出[' + @filename + ']的进程时发生错误，详细信息：'+@errorDesc)
GO
--测试：
declare @Ret int
exec dbo.addExportErrorInfo '123456789','错误：测试出错信息','00200977', @Ret output
select @Ret

select * from exportInfo

drop PROCEDURE completeExport
/*
	name:		completeExport
	function:	5.完成导出进程
	input: 
				@guidFilename varchar(128),	--GUID文件名
				@exporterID varchar(10),	--导出人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，1:没有该导出文件，9：未知错误
	author:		卢苇
	CreateDate:	2013-11-27
*/
create PROCEDURE completeExport
	@guidFilename varchar(128),	--GUID文件名
	@exporterID varchar(10),	--导出人工号
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @filename varchar(128)		--文件显示名
	declare @IsCancelRequested int		--是否申请呢中断
	select @filename = filename, @IsCancelRequested = IsCancelRequested 
	from exportInfo 
	where guidFilename=@guidFilename and exporterID=@exporterID
	if ISNULL(@filename,'')=''
	begin
		set @Ret = 1
		return
	end

	--取导出人的姓名：
	declare @exporter nvarchar(30)
	set @exporter = isnull((select userCName from activeUsers where userID = @exporterID),'')

	if (@IsCancelRequested=0)
		update exportInfo
		set exportStatus ='completed', lastTime=GETDATE(), curRecord=totalRecord
		where guidFilename = @guidFilename
	else
		update exportInfo
		set exportStatus ='userBreak', lastTime=GETDATE()
		where guidFilename = @guidFilename
	
	set @Ret = 0
	declare @usedTime int
	set @usedTime = (select DATEDIFF(millisecond, startTime, lastTime) from exportInfo where guidFilename = @guidFilename)
	
	--登记工作日志：
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@exporterID, @exporter, GETDATE(), '完成导出', '系统完成了用户' + @exporter + 
					'导出[' + @filename + ']的进程。共用时：'+str(@usedTime) + 'ms。')
GO
--测试：
declare @Ret int
exec dbo.completeExport '123456789','00200977', @Ret output
select @Ret
select * from exportInfo
select * from workNote order by actionTime desc

drop PROCEDURE delExportInfo
/*
	name:		delExportInfo
	function:	6.删除导出进程
	input: 
				@guidFilename varchar(128),	--GUID文件名
				@exporterID varchar(10),	--导出人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2013-11-27
*/
create PROCEDURE delExportInfo
	@guidFilename varchar(128),	--GUID文件名
	@exporterID varchar(10),	--导出人工号
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	delete exportInfo where guidFilename = @guidFilename and exporterID = @exporterID

	set @Ret = 0
GO
--测试：
declare @Ret int
exec dbo.delExportInfo '123456789','00200977', @Ret output
select @Ret

drop PROCEDURE delAllExportInfo
/*
	name:		delAllExportInfo
	function:	7.删除全部的导出进程
	input: 
				@exporterID varchar(10),	--导出人工号
	output: 
				@Ret		int output		--操作成功标识
							0:成功，9：未知错误
	author:		卢苇
	CreateDate:	2013-11-27
*/
create PROCEDURE delAllExportInfo
	@exporterID varchar(10),	--导出人工号
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	delete exportInfo where exporterID = @exporterID

	set @Ret = 0
GO
--测试：
declare @Ret int
exec dbo.delAllExportInfo '00200977', @Ret output
select @Ret

select * from exportInfo
delete exportInfo




drop proc export2ExcelFile
/*
	数据导出EXCEL
	导出查询中的数据到Excel,包含字段名,文件为真正的Excel文件
	如果文件不存在,将自动创建文件
	如果表不存在,将自动创建表
	基于通用性考虑,仅支持导出标准数据类型

	调用示例
	p_exporttb @sqlstr='select * from 地区资料'
	,@path='c:\',@fname='aa.xls',@sheetname='地区资料'
*/
create proc export2ExcelFile
	@sqlstr varchar(8000),	--查询语句,如果查询语句中使用了order by ,请加上top 100 percent
	@path nvarchar(1000),	--文件存放目录
	@fname nvarchar(250),	--文件名
	@sheetname varchar(250)=''--要创建的工作表名,默认为文件名
as
	declare @err int,@src nvarchar(255),@desc nvarchar(255),@out int
	declare @obj int,@constr nvarchar(1000),@sql varchar(8000),@fdlist varchar(8000)

	--参数检测
	if isnull(@fname,'')=''
		set @fname='temp.xls'
	if isnull(@sheetname,'')='' 
		set @sheetname=replace(@fname,'.','#')

	--检查文件是否已经存在
	if right(@path,1)<>'\' 
		set @path=@path+'\'
	create table #tb(a bit,b bit,c bit)
	set @sql=@path+@fname
	insert into #tb exec master..xp_fileexist @sql

	--数据库创建语句
	set @sql=@path+@fname
	if exists(select 1 from #tb where a=1)
		set @constr='DRIVER={Microsoft Excel Driver (*.xls)};DSN='''';READONLY=FALSE'
		+';CREATE_DB="'+@sql+'";DBQ='+@sql
	else
		set @constr='Provider=Microsoft.Jet.OLEDB.4.0;Extended Properties="Excel 8.0;HDR=YES'
		+';DATABASE='+@sql+'"'

	--连接数据库
	exec @err=sp_oacreate 'adodb.connection',@obj out
	if @err<>0 
		goto lberr

	exec @err=sp_oamethod @obj,'open',null,@constr
	if @err<>0 
		goto lberr

	--创建表的SQL
	declare @tbname sysname
	set @tbname='##tmp_'+convert(varchar(38),newid())
	set @sql='select * into ['+@tbname+'] from('+@sqlstr+') a'
	exec(@sql)

	select @sql='',@fdlist=''
	select @fdlist=@fdlist+',['+a.name+']',@sql=@sql+',['+a.name+'] '
		+case
		when b.name like '%char'
		then case when a.length>255 then 'memo'
		else 'text('+cast(a.length as varchar)+')' end
		when b.name like '%int' or b.name='bit' then 'int'
		when b.name like '%datetime' then 'datetime'
		when b.name like '%money' then 'money'
		when b.name like '%text' then 'memo'
		else b.name end
	FROM tempdb..syscolumns a left join tempdb..systypes b on a.xtype=b.xusertype
	where b.name not in('image','uniqueidentifier','sql_variant','varbinary','binary','timestamp')
			and a.id=(select id from tempdb..sysobjects where name=@tbname)

	if @@rowcount=0 
		return

	select @sql='create table ['+@sheetname+']('+substring(@sql,2,8000)+')',@fdlist=substring(@fdlist,2,8000)

	exec @err=sp_oamethod @obj,'execute',@out out,@sql
	if @err<>0 
		goto lberr

	exec @err=sp_oadestroy @obj

	--导入数据
	set @sql='openrowset(''MICROSOFT.JET.OLEDB.4.0'',''Excel 8.0;HDR=YES;DATABASE='+@path+@fname+''',['+@sheetname+'$])'
	exec('insert into '+@sql+'('+@fdlist+') select '+@fdlist+' from ['+@tbname+']')

	set @sql='drop table ['+@tbname+']'
	exec(@sql)
	return

lberr:
	exec sp_oageterrorinfo 0,@src out,@desc out
lbexit:
	select cast(@err as varbinary(4)) as 错误号
	,@src as 错误源,@desc as 错误描述
	select @sql,@constr,@fdlist
go

export2ExcelFile @sqlstr='select * from college'
	,@path='c:\',@fname='aa.xls',@sheetname='院部'




--以下示例显示了如何查看 OLE Automation Procedures 的当前设置。
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

EXEC sp_configure 'Ole Automation Procedures';
GO




--以下示例显示了如何启用 OLE Automation Procedures。
sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE;
GO


--启用Ad Hoc Distributed Queries：
exec sp_configure 'show advanced options',1
reconfigure
go
exec sp_configure 'Ad Hoc Distributed Queries',1
reconfigure
go
--查询配置值
select value,value_in_use,name
from sys.configurations
where name='Ad Hoc Distributed Queries'

--使用完成后，关闭Ad Hoc Distributed Queries：
exec sp_configure 'Ad Hoc Distributed Queries',0
reconfigure
exec sp_configure 'show advanced options',0
reconfigure 

--打开Excel文件：
 
    --开启导入功能
    exec sp_configure 'show advanced options',1
    reconfigure
    go
    exec sp_configure 'Ad Hoc Distributed Queries',1
    reconfigure
    go
    --允许在进程中使用ACE.OLEDB.12
    EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
    --允许动态参数
    EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
 
SELECT * 
FROM OpenDataSource( 'Microsoft.ACE.OLEDB.12.0','Data Source="c:\控制点.xlsx";Extended properties=Excel 8.0')...[Sheet1$]

SELECT * FROM OPENDATASOURCE('Microsoft.ACE.OLEDB.12.0',
'Data Source=C:\在库设备一览表.xls;Extended Properties=EXCEL 5.0')...[Sheet1$] ;


insert into OPENDATASOURCE('Microsoft.ACE.OLEDB.12.0',
'Data Source=d:\lw\在库设备一览表.xls;Extended Properties=EXCEL 8.0;HDR=YES;')...[Sheet1$]
select top 1000 e.eCode,
convert(varchar(10),e.acceptDate,120) as acceptDate,
--modi by lw 2011-1-26根据最新定义的设备现状码修改：
case curEqpStatus when '1' then '在用' when '2' then '多余' when '3' then '待修' when '4' then '待报废'
when '5' then '丢失' when '6' then '报废' when '7' then '调出' when '8' then '降档' when '9' then '其他' else '未知' end curEqpStatus,
e.eName,e.eModel,e.eFormat,e.cCode,c.cName,e.factory,e.serialNumber,convert(varchar(10),e.makeDate,120) as makeDate,e.business,e.annexCode,e.annexName,
e.annexAmount,e.eTypeCode,e.aTypeCode,e.fCode,f.fName,e.aCode,a.aName,convert(varchar(10),e.buyDate,120) as buyDate,
e.price,e.totalAmount,e.clgCode,clg.clgName,e.uCode,u.uName,e.keeperID,e.keeper,e.eqpLocate,e.oprMan, e.acceptMan,
isnull(e.lock4LongTime,0) lock4LongTime, isnull(e.lInvoiceNum,'') lInvoiceNum, e.notes,
case e.curEqpStatus when '6' then convert(char(10), e.scrapDate, 120) else '' end scrapDate, obtainMode, purchaseMode
from equipmentList e left join country c on e.cCode = c.cCode
left join fundSrc f on e.fCode = f.fCode
left join appDir a on e.aCode = a.aCode
left join college clg on e.clgCode = clg.clgCode
left join useUnit u on e.uCode = u.uCode




--开启导入功能
exec sp_configure 'show advanced options',1
reconfigure
exec sp_configure 'Ad Hoc Distributed Queries',1
reconfigure
--允许在进程中使用ACE.OLEDB.12
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
--允许动态参数
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1

SELECT * FROM OPENDATASOURCE('Microsoft.ACE.OLEDB.12.0',
'Data Source=C:\在库设备一览表.xls;Extended Properties=EXCEL 5.0')...[Sheet1$] ;

--导入临时表 
--exec ('insert into jihua(id,[批次号],Right('''+ @filepath +''',charindex(''\'',REVERSE('''+ @filepath +'''))-1),getdate() FROM OPENDATASOURCE (''Microsoft.ACE.OLEDB.12.0'', ''Data Source='+@filepath+';User ID=Admin;Password='' )...计划汇总表')

--注意这里，要先关闭外围的设置，然后再关闭高级选项
exec sp_configure'Ad Hoc Distributed Queries',0
reconfigure
exec sp_configure'show advanced options',0
reconfigure
--关闭ACE.OLEDB.12的选项
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 0
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 0



insert into OPENDATASOURCE('Microsoft.ACE.OLEDB.12.0',
'Data Source=d:\lw\在库设备一览表.xlsx;Extended Properties=EXCEL 8.0')...[Sheet1$]([设备编号],[验收日期],[状态],[设备名称])

declare @temp as table([设备编号] varchar(8),[验收日期] varchar(10),[状态] varchar(10),[设备名称] nvarchar(30))
insert into @temp
select e.eCode,
convert(varchar(10),e.acceptDate,120) as acceptDate,
--modi by lw 2011-1-26根据最新定义的设备现状码修改：
case curEqpStatus when '1' then '在用' when '2' then '多余' when '3' then '待修' when '4' then '待报废'
when '5' then '丢失' when '6' then '报废' when '7' then '调出' when '8' then '降档' when '9' then '其他' else '未知' end curEqpStatus,
e.eName
from equipmentList e left join country c on e.cCode = c.cCode
left join fundSrc f on e.fCode = f.fCode
left join appDir a on e.aCode = a.aCode
left join college clg on e.clgCode = clg.clgCode
left join useUnit u on e.uCode = u.uCode

select * from @temp

SELECT [Spid] = session_Id
, ecid
, [Database] = DB_NAME(sp.dbid)
, [User] = nt_username
, [Status] = er.status
, [Wait] = wait_type
, [Individual Query] = SUBSTRING (qt.text,
er.statement_start_offset/2,
(CASE WHEN er.statement_end_offset = -1
THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
ELSE er.statement_end_offset END -
er.statement_start_offset)/2)
,[Parent Query] = qt.text
, Program = program_name
, Hostname
, nt_domain
, start_time
FROM sys.dm_exec_requests er
INNER JOIN sys.sysprocesses sp ON er.session_id = sp.spid
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle)as qt
WHERE session_Id > 50 -- Ignore system spids.
AND session_Id NOT IN (@@SPID) -- Ignore this current statement.
ORDER BY 1, 2



use epdc211
drop table insertInfo
create table insertInfo( eCode varchar(8));
create table #temp([设备编号] varchar(8),[验收日期] varchar(10),[状态] varchar(10),[设备名称] nvarchar(30))
insert into #temp
    OUTPUT INSERTED.设备编号
        INTO insertInfo
select e.eCode,
convert(varchar(10),e.acceptDate,120) as acceptDate,
--modi by lw 2011-1-26根据最新定义的设备现状码修改：
case curEqpStatus when '1' then '在用' when '2' then '多余' when '3' then '待修' when '4' then '待报废'
when '5' then '丢失' when '6' then '报废' when '7' then '调出' when '8' then '降档' when '9' then '其他' else '未知' end curEqpStatus,
e.eName
from equipmentList e left join country c on e.cCode = c.cCode
left join fundSrc f on e.fCode = f.fCode
left join appDir a on e.aCode = a.aCode
left join college clg on e.clgCode = clg.clgCode
left join useUnit u on e.uCode = u.uCode

--Display the result set of the table variable.
SELECT ScrapReasonID, Name, ModifiedDate FROM insertInfo;

