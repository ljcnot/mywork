--使用分隔符分词：
DECLARE @String NVARCHAR(200);
 
SET @String=N'武汉东之友道,三亚友道,琼海友道,友道集团,我们一起干,动起来^_^,创造价值!';

SELECT T.x.query('data(.)') FROM 
(SELECT CONVERT(XML,'<x>'+REPLACE(@String,',','</x><x>')+'</x>',1) Col1) A
OUTER APPLY A.Col1.nodes('/x') AS T(x)


--将表格式化成XML：
declare @elementStatus table(
	id int,
	name varchar(20)
)
insert @elementStatus 
values(1,'Hello world')
insert @elementStatus 
values(2,'Whar are you doing?')

select * FROM @elementStatus
DECLARE @xVar XML
SET     @xVar = (SELECT id, name FROM @elementStatus FOR XML auto, TYPE)
select @xVar

--将XML转换为行集：
DECLARE @xVar XML
--SET @xVar =( --将一查询结果集转换成SQL XML格式
--	select id,name from @elementStatus FOR XML raw 
--)
select @xVar
set @xVar='<root><row id="1" name="Hello world" /><row id="2" name="Whar are you doing?" /></root>'
declare @elementStatus table(
	id int,
	name varchar(20)
)
insert @elementStatus
select t.r.value('(@id)', 'int') id,t.r.value('(@name)', 'varchar(20)') name
from @xVar.nodes('root/row') as t(r)

select * from @elementStatus
 

declare @id int, @name varchar(20)
declare tar cursor for
select id,name from @elementStatus
order by id
OPEN tar
FETCH NEXT FROM tar INTO @id, @name
WHILE @@FETCH_STATUS = 0
begin
	print 'id:'+str(@id,3)+'    name:'+@name
	FETCH NEXT FROM tar INTO @id, @name
end
CLOSE tar
DEALLOCATE tar



--这些函数在中文处理时失效：
DIFFERENCE
SOUNDEX
SELECT SOUNDEX ('Smith'), SOUNDEX ('Smythe')
SELECT SOUNDEX ('长治市城区'), SOUNDEX ('长治城区')


--sqlserver版本检测：
SELECT SERVERPROPERTY('productversion'), SERVERPROPERTY ('productlevel'), SERVERPROPERTY ('edition')
