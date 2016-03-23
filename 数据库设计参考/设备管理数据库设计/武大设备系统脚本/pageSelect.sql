use epdc211
/*
	武大设备管理系统-分页查询
	根据警用地理信息系统改编
	author:		卢苇
	CreateDate:	2010-7-11
	UpdateDate: 
*/

drop PROCEDURE pageSelect
/*
	name:		pageSelect
	function:	1.采用分页技术查询数据
				注意：本函数有一定的风险, @tb + @colList + @strWhere + @strOrder总长度不能超过8000个字符或4000个unicode字符
	input: 
				@tb  nvarchar(1000),   --表名
				@colList nvarchar(800),--要查询出的字段列表,*表示全部字段   
				@strWhere nvarchar(4000),--where子句
				@strOrder nvarchar(200),	--order子句
				@pageSize int,      --每页行数   
				@page     int,      --指定页   
	output: 
--				@rows  int OUTPUT,	--总行数
--				@pages int OUTPUT	--总页数   
	author:		卢苇
	CreateDate:	2010-3-5
	UpdateDate: 2010-7-4为了提高速度，将查询总行数和总页数放到外部
*/
CREATE PROCEDURE pageSelect
    @tb  nvarchar(1000),   --表名
    @colList nvarchar(1000),--要查询出的字段列表,*表示全部字段   
    @strWhere nvarchar(4000),--where子句
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
	set @sql = N'select * from (' + @sql + ') tab1'
	if @pageSize > 0
		set @sql = @sql + N' where RowID BETWEEN ' + str(@page * @pageSize + 1 ,10) + ' AND ' + @topRows
--	print @sql
	EXEC(@sql)   
GO

drop PROCEDURE queryPages
/*
	name:		queryPages
	function:	2.查询行数和分页总数
				为了提高速度，将查询总行数和总页数放到外部
	input: 
				@tb  nvarchar(1000),   --表名
				@strWhere nvarchar(4000),--where子句
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
    @strWhere nvarchar(4000),--where子句
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
