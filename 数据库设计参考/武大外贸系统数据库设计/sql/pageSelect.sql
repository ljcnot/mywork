use fTradeDB
/*
	武大外贸合同管理信息系统--分页查询
	根据警用地理信息系统、设备管理系统改编
	author:		卢苇
	CreateDate:	2010-7-11
	UpdateDate: 
*/

drop PROCEDURE pageSelect
/*
	name:		pageSelect
	function:	1.采用分页技术查询数据
	input: 
				@tb  nvarchar(1000),   --表名
				@colList nvarchar(2280),--要查询出的字段列表,*表示全部字段   
				@strWhere nvarchar(3000),--where子句
				@strOrder nvarchar(200),	--order子句
				@pageSize int,      --每页行数   
				@page     int,      --指定页   
	output: 
--				@rows  int OUTPUT,	--总行数
--				@pages int OUTPUT	--总页数   
	author:		卢苇
	CreateDate:	2010-3-5
	UpdateDate: 2010-7-4为了提高速度，将查询总行数和总页数放到外部
				modi by lw 2012-4-19 延长列名长度
*/
CREATE PROCEDURE pageSelect
    @tb  nvarchar(1000),   --表名
    @colList nvarchar(2280),--要查询出的字段列表,*表示全部字段   
    @strWhere nvarchar(3000),--where子句
	@strOrder nvarchar(200),	--order子句
    @pageSize int,      --每页行数   
    @page     int		--指定页   
--    @rows  int OUTPUT,	--总行数
--    @pages int OUTPUT	--总页数   
	WITH ENCRYPTION 
AS   
	DECLARE @sql Nvarchar(4000)

--	SET @sql = N'select @row_num = count(*) from ' + @tb + N' ' + @strWhere
--	EXECUTE sp_executesql @sql, N'@row_num int OUTPUT', @row_num=@rows OUTPUT;
--	set @pages = (@rows + @pageSize -1) / @pageSize
--
	declare @topRows as varchar(10)
	set @topRows = ltrim(str((@page+1) * @pageSize, 10))
	set @sql = N'select ' + 'top '+ @topRows + ' ROW_NUMBER() OVER(' + @strOrder + ') AS RowID, ' + @colList + N' from ' + @tb + ' ' + @strWhere
--print @sql
	set @sql = N'select * from (' + @sql + ') tab1'
	if @pageSize > 0
		set @sql = @sql + N' where RowID BETWEEN ' + str(@page * @pageSize + 1 ,10) + ' AND ' + @topRows
--	print @sql
	EXEC(@sql)   
GO
--测试：
declare @tb  nvarchar(1000)   --表名
declare @colList nvarchar(1280)--要查询出的字段列表,*表示全部字段   
declare @strWhere nvarchar(4000)--where子句
declare	@strOrder nvarchar(200)	--order子句
declare @pageSize int      --每页行数   
declare @page     int		--指定页   
set @tb = N' contractInfo ci left join codeDictionary cd on ci.currency = cd.objCode and cd.classCode=3 left join codeDictionary cd2 on ci.paymentMode = cd2.objCode and cd2.classCode=4 left join contractFlow f1 on ci.contractID = f1.contractID and f1.nodeName =' + char(39) + '办理签订委托代理进口协议' + char(39) + ' left join contractFlow f2 on ci.contractID = f2.contractID and f2.nodeName =' + char(39) + '开信用证或付款' + char(39) + ' left join contractFlow f3 on ci.contractID = f3.contractID and f3.nodeName =' + char(39) + '办理免表' + char(39) + ' left join contractFlow f4 on ci.contractID = f4.contractID and f4.nodeName =' + char(39) + '办理报关单' + char(39) + ' ' 
set @colList = N' contractStatus, ci.curLeftDays, ci.contractID, curNode, curNodeName,dbo.getEqpInfoOfContract(ci.contractID) eqpInfo,totalAmount, currency, cd.objDesc currencyName,dbo.getClgInfoOfContract(ci.contractID) clgInfo,supplierID, supplierName, supplierOprMan, supplierOprManMobile, supplierOprManTel, convert(varchar(10),supplierSignedTime,120) supplierSignedTime,traderID, traderName, traderOprMan, traderOprManMobile, traderOprManTel, convert(varchar(10),traderSignedTime,120) traderSignedTime,case f1.nStatus when 0 then ' + char(39) + '' + char(39) + ' when 1 then cast(f1.curLeftDays as varchar(10)) when -1 then ' + char(39) + '←' + char(39) + ' when 9 then ' + char(39) + '√' + char(39) + ' end nodeSignContract,case f2.nStatus when 0 then ' + char(39) + '' + char(39) + ' when 1 then cast(f2.curLeftDays as varchar(10)) when -1 then ' + char(39) + '←' + char(39) + ' when 9 then ' + char(39) + '√' + char(39) + ' end nodePay,case f3.nStatus when 0 then ' + char(39) + '' + char(39) + ' when 1 then cast(f3.curLeftDays as varchar(10)) when -1 then ' + char(39) + '←' + char(39) + ' when 9 then ' + char(39) + '√' + char(39) + ' end nodeTaxFree,case f4.nStatus when 0 then ' + char(39) + '' + char(39) + ' when 1 then cast(f4.curLeftDays as varchar(10)) when -1 then ' + char(39) + '←' + char(39) + ' when 9 then ' + char(39) + '√' + char(39) + ' end nodeDeclaration,ci.contractID timeoutRecord, ci.contractID haveMsg,paymentMode, cd2.objDesc paymentModeDesc, goodsArrivalTime,convert(varchar(10),acceptedTime,120) acceptedTime, convert(varchar(10),completedTime,120) completedTime, notes'
set @strWhere = 'where contractStatus in (0,1) and contractStatus<>9'
set @strOrder = 'order by cd.objDesc'

exec dbo.pageSelect @tb, @colList,@strWhere, @strOrder, 20, 0



drop PROCEDURE queryPages
/*
	name:		queryPages
	function:	2.查询行数和分页总数
				为了提高速度，将查询总行数和总页数放到外部
	input: 
				@tb  nvarchar(1000),   --表名
				@strWhere nvarchar(3000),--where子句
				@pageSize int,      --每页行数   
	output: 
				@rows  int OUTPUT,	--总行数
				@pages int OUTPUT	--总页数   
	author:		卢苇
	CreateDate:	2010-7-4
	UpdateDate: 
*/
CREATE PROCEDURE queryPages
    @tb  nvarchar(1000),   --表名
    @strWhere nvarchar(3000),--where子句
    @pageSize int,      --每页行数   
    @rows  int OUTPUT,	--总行数
    @pages int OUTPUT	--总页数   
	WITH ENCRYPTION 
AS   
	DECLARE @sql Nvarchar(4000)

	SET @sql = N'select @row_num = count(*) from ' + @tb + N' ' + @strWhere
	EXECUTE sp_executesql @sql, N'@row_num int OUTPUT', @row_num=@rows OUTPUT;
	set @pages = (@rows + @pageSize -1) / @pageSize

go
