use epdc211
/*
	����豸����ϵͳ-��ҳ��ѯ
	���ݾ��õ�����Ϣϵͳ�ı�
	author:		¬έ
	CreateDate:	2010-7-11
	UpdateDate: 
*/

drop PROCEDURE pageSelect
/*
	name:		pageSelect
	function:	1.���÷�ҳ������ѯ����
				ע�⣺��������һ���ķ���, @tb + @colList + @strWhere + @strOrder�ܳ��Ȳ��ܳ���8000���ַ���4000��unicode�ַ�
	input: 
				@tb  nvarchar(1000),   --����
				@colList nvarchar(800),--Ҫ��ѯ�����ֶ��б�,*��ʾȫ���ֶ�   
				@strWhere nvarchar(4000),--where�Ӿ�
				@strOrder nvarchar(200),	--order�Ӿ�
				@pageSize int,      --ÿҳ����   
				@page     int,      --ָ��ҳ   
	output: 
--				@rows  int OUTPUT,	--������
--				@pages int OUTPUT	--��ҳ��   
	author:		¬έ
	CreateDate:	2010-3-5
	UpdateDate: 2010-7-4Ϊ������ٶȣ�����ѯ����������ҳ���ŵ��ⲿ
*/
CREATE PROCEDURE pageSelect
    @tb  nvarchar(1000),   --����
    @colList nvarchar(1000),--Ҫ��ѯ�����ֶ��б�,*��ʾȫ���ֶ�   
    @strWhere nvarchar(4000),--where�Ӿ�
	@strOrder nvarchar(200),	--order�Ӿ�
    @pageSize int,      --ÿҳ����   
    @page     int		--ָ��ҳ   
--    @rows  int OUTPUT,	--������
--    @pages int OUTPUT	--��ҳ��   
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
	function:	2.��ѯ�����ͷ�ҳ����
				Ϊ������ٶȣ�����ѯ����������ҳ���ŵ��ⲿ
	input: 
				@tb  nvarchar(1000),   --����
				@strWhere nvarchar(4000),--where�Ӿ�
				@pageSize int,      --ÿҳ����   
	output: 
				@rows  int OUTPUT,	--������
				@pages int OUTPUT	--��ҳ��   
	author:		¬έ
	CreateDate:	2010-7-4
	UpdateDate: 
*/
CREATE PROCEDURE queryPages
    @tb  nvarchar(1000),   --����
    @strWhere nvarchar(4000),--where�Ӿ�
    @pageSize int,      --ÿҳ����   
    @rows  int OUTPUT,	--������
    @pages int OUTPUT	--��ҳ��   
	WITH ENCRYPTION 
AS   
	DECLARE @sql Nvarchar(4000)

	SET @sql = N'select @row_num = count(*) from ' + @tb + N' ' + @strWhere
	EXECUTE sp_executesql @sql, N'@row_num int OUTPUT', @row_num=@rows OUTPUT;
	set @pages = (@rows + @pageSize -1) / @pageSize

go
