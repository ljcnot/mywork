--ʹ�÷ָ����ִʣ�
DECLARE @String NVARCHAR(200);
 
SET @String=N'�人��֮�ѵ�,�����ѵ�,���ѵ�,�ѵ�����,����һ���,������^_^,�����ֵ!';

SELECT T.x.query('data(.)') FROM 
(SELECT CONVERT(XML,'<x>'+REPLACE(@String,',','</x><x>')+'</x>',1) Col1) A
OUTER APPLY A.Col1.nodes('/x') AS T(x)


--�����ʽ����XML��
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

--��XMLת��Ϊ�м���
DECLARE @xVar XML
--SET @xVar =( --��һ��ѯ�����ת����SQL XML��ʽ
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



--��Щ���������Ĵ���ʱʧЧ��
DIFFERENCE
SOUNDEX
SELECT SOUNDEX ('Smith'), SOUNDEX ('Smythe')
SELECT SOUNDEX ('�����г���'), SOUNDEX ('���γ���')


--sqlserver�汾��⣺
SELECT SERVERPROPERTY('productversion'), SERVERPROPERTY ('productlevel'), SERVERPROPERTY ('edition')
