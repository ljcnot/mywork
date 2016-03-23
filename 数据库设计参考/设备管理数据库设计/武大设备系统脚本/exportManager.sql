use epdc211
/*
	����豸������Ϣϵͳ-���������������Ƽܹ�
	author:		¬έ
	CreateDate:	2013-11-27
	UpdateDate: 
*/

drop TABLE exportInfo
CREATE TABLE exportInfo(
	rowNum int IDENTITY(1,1) NOT NULL,	--���
	guidFilename varchar(128) not null,	--GUID�ļ���
	filename varchar(128) not null,		--�ļ���ʾ��
	totalRecord bigint default(0),		--�ܼ�¼��
	curRecord bigint default(0),		--��ǰ�����ļ�¼��
	exportStatus varchar(30) default(''),--��ǰ�����״̬��''->��ʼ��״̬,'processing'->���ڴ���,'completed'->�����,'userBreak'->�û��ж�,'error'->����
	errorDesc nvarchar(300) default(''),--��ϸ�ĳ�����Ϣ
	startTime datetime default(getdate()),	--��������ʱ��
	lastTime datetime default(getdate()),	--�ϴ�д��¼ʱ��
	IsCancelRequested int default(0),	--�û��Ƿ������жϸý��̣�0->δ���룬1->�����ж�
	
	exporterID varchar(10) null,		--�����˹���
	exporter varchar(30) null,			--����������

 CONSTRAINT [PK_exportInfo] PRIMARY KEY CLUSTERED 
(
	[rowNum] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]


drop PROCEDURE addExportInfo
/*
	name:		addExportInfo
	function:	1.�Ǽǵ�������
	input: 
				@guidFilename varchar(128),	--GUID�ļ���
				@filename varchar(128),		--�ļ���ʾ��
				@totalRecord bigint,		--�ܼ�¼��
				@exporterID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-11-27
*/
create PROCEDURE addExportInfo
	@guidFilename varchar(128),	--GUID�ļ���
	@filename varchar(128),		--�ļ���ʾ��
	@totalRecord bigint,		--�ܼ�¼��
	@exporterID varchar(10),	--�����˹���
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ȡ�����˵�������
	declare @exporter nvarchar(30)
	set @exporter = isnull((select userCName from activeUsers where userID = @exporterID),'')

	insert exportInfo(guidFilename, filename, totalRecord, exporterID, exporter)
	values (@guidFilename, @filename, @totalRecord, @exporterID, @exporter)

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@exporterID, @exporter, GETDATE(), '����', '�û�' + @exporter + 
					'��ʼ��[' + @filename + ']�ĵ������̡�')
GO
--���ԣ�
declare @Ret int
exec dbo.addExportInfo '123456789', '��������.xlsx', 2000, '00200977', @Ret output
select @Ret

select * from exportInfo

drop PROCEDURE addExportProcess
/*
	name:		addExportProcess
	function:	2.�Ǽǵ�������
	input: 
				@guidFilename varchar(128),	--GUID�ļ���
				@curRecord bigint,			--��ǰ�����ļ�¼��
				@exporterID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1:û�иõ����ļ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-11-27
*/
create PROCEDURE addExportProcess
	@guidFilename varchar(128),	--GUID�ļ���
	@curRecord bigint,			--��ǰ�����ļ�¼��
	@exporterID varchar(10),	--�����˹���
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
--���ԣ�
declare @Ret int
exec dbo.addExportProcess '123456789',1100, '00200977', @Ret output
select @Ret

select * from exportInfo

drop PROCEDURE exportCancelRequest
/*
	name:		exportCancelRequest
	function:	3.�����жϵ�������
	input: 
				@guidFilename varchar(128),	--GUID�ļ���
				@exporterID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1:û�иõ����ļ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-11-27
*/
create PROCEDURE exportCancelRequest
	@guidFilename varchar(128),	--GUID�ļ���
	@exporterID varchar(10),	--�����˹���
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @filename varchar(128)		--�ļ���ʾ��
	select @filename = filename from exportInfo where guidFilename=@guidFilename and exporterID=@exporterID
	if ISNULL(@filename,'')=''
	begin
		set @Ret = 1
		return
	end

	--ȡ�����˵�������
	declare @exporter nvarchar(30)
	set @exporter = isnull((select userCName from activeUsers where userID = @exporterID),'')

	update exportInfo
	set IsCancelRequested=1
	where guidFilename = @guidFilename

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@exporterID, @exporter, GETDATE(), '�жϵ���', '�û�' + @exporter + 
					'�ж���[' + @filename + ']�ĵ������̡�')
GO
--���ԣ�
declare @Ret int
exec dbo.exportCancelRequest '123456789','00200977', @Ret output
select @Ret

select * from exportInfo

drop PROCEDURE addExportErrorInfo
/*
	name:		addExportErrorInfo
	function:	4.�Ǽǵ���������Ϣ
	input: 
				@guidFilename varchar(128),	--GUID�ļ���
				@errorDesc nvarchar(300),	--��ϸ�ĳ�����Ϣ
				@exporterID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1:û�иõ����ļ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-11-27
*/
create PROCEDURE addExportErrorInfo
	@guidFilename varchar(128),	--GUID�ļ���
	@errorDesc nvarchar(300),	--��ϸ�ĳ�����Ϣ
	@exporterID varchar(10),	--�����˹���
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @filename varchar(128)		--�ļ���ʾ��
	select @filename = filename from exportInfo where guidFilename=@guidFilename and exporterID=@exporterID
	if ISNULL(@filename,'')=''
	begin
		set @Ret = 1
		return
	end

	--ȡ�����˵�������
	declare @exporter nvarchar(30)
	set @exporter = isnull((select userCName from activeUsers where userID = @exporterID),'')

	update exportInfo
	set exportStatus ='error', errorDesc=@errorDesc
	where guidFilename = @guidFilename

	set @Ret = 0
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@exporterID, @exporter, GETDATE(), '��������', 'ϵͳ��ִ���û�' + @exporter + 
					'����[' + @filename + ']�Ľ���ʱ����������ϸ��Ϣ��'+@errorDesc)
GO
--���ԣ�
declare @Ret int
exec dbo.addExportErrorInfo '123456789','���󣺲��Գ�����Ϣ','00200977', @Ret output
select @Ret

select * from exportInfo

drop PROCEDURE completeExport
/*
	name:		completeExport
	function:	5.��ɵ�������
	input: 
				@guidFilename varchar(128),	--GUID�ļ���
				@exporterID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1:û�иõ����ļ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-11-27
*/
create PROCEDURE completeExport
	@guidFilename varchar(128),	--GUID�ļ���
	@exporterID varchar(10),	--�����˹���
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	declare @filename varchar(128)		--�ļ���ʾ��
	declare @IsCancelRequested int		--�Ƿ��������ж�
	select @filename = filename, @IsCancelRequested = IsCancelRequested 
	from exportInfo 
	where guidFilename=@guidFilename and exporterID=@exporterID
	if ISNULL(@filename,'')=''
	begin
		set @Ret = 1
		return
	end

	--ȡ�����˵�������
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
	
	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@exporterID, @exporter, GETDATE(), '��ɵ���', 'ϵͳ������û�' + @exporter + 
					'����[' + @filename + ']�Ľ��̡�����ʱ��'+str(@usedTime) + 'ms��')
GO
--���ԣ�
declare @Ret int
exec dbo.completeExport '123456789','00200977', @Ret output
select @Ret
select * from exportInfo
select * from workNote order by actionTime desc

drop PROCEDURE delExportInfo
/*
	name:		delExportInfo
	function:	6.ɾ����������
	input: 
				@guidFilename varchar(128),	--GUID�ļ���
				@exporterID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-11-27
*/
create PROCEDURE delExportInfo
	@guidFilename varchar(128),	--GUID�ļ���
	@exporterID varchar(10),	--�����˹���
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	delete exportInfo where guidFilename = @guidFilename and exporterID = @exporterID

	set @Ret = 0
GO
--���ԣ�
declare @Ret int
exec dbo.delExportInfo '123456789','00200977', @Ret output
select @Ret

drop PROCEDURE delAllExportInfo
/*
	name:		delAllExportInfo
	function:	7.ɾ��ȫ���ĵ�������
	input: 
				@exporterID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9��δ֪����
	author:		¬έ
	CreateDate:	2013-11-27
*/
create PROCEDURE delAllExportInfo
	@exporterID varchar(10),	--�����˹���
	@Ret int output
	WITH ENCRYPTION 
AS
	set @Ret = 9

	delete exportInfo where exporterID = @exporterID

	set @Ret = 0
GO
--���ԣ�
declare @Ret int
exec dbo.delAllExportInfo '00200977', @Ret output
select @Ret

select * from exportInfo
delete exportInfo




drop proc export2ExcelFile
/*
	���ݵ���EXCEL
	������ѯ�е����ݵ�Excel,�����ֶ���,�ļ�Ϊ������Excel�ļ�
	����ļ�������,���Զ������ļ�
	���������,���Զ�������
	����ͨ���Կ���,��֧�ֵ�����׼��������

	����ʾ��
	p_exporttb @sqlstr='select * from ��������'
	,@path='c:\',@fname='aa.xls',@sheetname='��������'
*/
create proc export2ExcelFile
	@sqlstr varchar(8000),	--��ѯ���,�����ѯ�����ʹ����order by ,�����top 100 percent
	@path nvarchar(1000),	--�ļ����Ŀ¼
	@fname nvarchar(250),	--�ļ���
	@sheetname varchar(250)=''--Ҫ�����Ĺ�������,Ĭ��Ϊ�ļ���
as
	declare @err int,@src nvarchar(255),@desc nvarchar(255),@out int
	declare @obj int,@constr nvarchar(1000),@sql varchar(8000),@fdlist varchar(8000)

	--�������
	if isnull(@fname,'')=''
		set @fname='temp.xls'
	if isnull(@sheetname,'')='' 
		set @sheetname=replace(@fname,'.','#')

	--����ļ��Ƿ��Ѿ�����
	if right(@path,1)<>'\' 
		set @path=@path+'\'
	create table #tb(a bit,b bit,c bit)
	set @sql=@path+@fname
	insert into #tb exec master..xp_fileexist @sql

	--���ݿⴴ�����
	set @sql=@path+@fname
	if exists(select 1 from #tb where a=1)
		set @constr='DRIVER={Microsoft Excel Driver (*.xls)};DSN='''';READONLY=FALSE'
		+';CREATE_DB="'+@sql+'";DBQ='+@sql
	else
		set @constr='Provider=Microsoft.Jet.OLEDB.4.0;Extended Properties="Excel 8.0;HDR=YES'
		+';DATABASE='+@sql+'"'

	--�������ݿ�
	exec @err=sp_oacreate 'adodb.connection',@obj out
	if @err<>0 
		goto lberr

	exec @err=sp_oamethod @obj,'open',null,@constr
	if @err<>0 
		goto lberr

	--�������SQL
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

	--��������
	set @sql='openrowset(''MICROSOFT.JET.OLEDB.4.0'',''Excel 8.0;HDR=YES;DATABASE='+@path+@fname+''',['+@sheetname+'$])'
	exec('insert into '+@sql+'('+@fdlist+') select '+@fdlist+' from ['+@tbname+']')

	set @sql='drop table ['+@tbname+']'
	exec(@sql)
	return

lberr:
	exec sp_oageterrorinfo 0,@src out,@desc out
lbexit:
	select cast(@err as varbinary(4)) as �����
	,@src as ����Դ,@desc as ��������
	select @sql,@constr,@fdlist
go

export2ExcelFile @sqlstr='select * from college'
	,@path='c:\',@fname='aa.xls',@sheetname='Ժ��'




--����ʾ����ʾ����β鿴 OLE Automation Procedures �ĵ�ǰ���á�
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO

EXEC sp_configure 'Ole Automation Procedures';
GO




--����ʾ����ʾ��������� OLE Automation Procedures��
sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE;
GO


--����Ad Hoc Distributed Queries��
exec sp_configure 'show advanced options',1
reconfigure
go
exec sp_configure 'Ad Hoc Distributed Queries',1
reconfigure
go
--��ѯ����ֵ
select value,value_in_use,name
from sys.configurations
where name='Ad Hoc Distributed Queries'

--ʹ����ɺ󣬹ر�Ad Hoc Distributed Queries��
exec sp_configure 'Ad Hoc Distributed Queries',0
reconfigure
exec sp_configure 'show advanced options',0
reconfigure 

--��Excel�ļ���
 
    --�������빦��
    exec sp_configure 'show advanced options',1
    reconfigure
    go
    exec sp_configure 'Ad Hoc Distributed Queries',1
    reconfigure
    go
    --�����ڽ�����ʹ��ACE.OLEDB.12
    EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
    --����̬����
    EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
 
SELECT * 
FROM OpenDataSource( 'Microsoft.ACE.OLEDB.12.0','Data Source="c:\���Ƶ�.xlsx";Extended properties=Excel 8.0')...[Sheet1$]

SELECT * FROM OPENDATASOURCE('Microsoft.ACE.OLEDB.12.0',
'Data Source=C:\�ڿ��豸һ����.xls;Extended Properties=EXCEL 5.0')...[Sheet1$] ;


insert into OPENDATASOURCE('Microsoft.ACE.OLEDB.12.0',
'Data Source=d:\lw\�ڿ��豸һ����.xls;Extended Properties=EXCEL 8.0;HDR=YES;')...[Sheet1$]
select top 1000 e.eCode,
convert(varchar(10),e.acceptDate,120) as acceptDate,
--modi by lw 2011-1-26�������¶�����豸��״���޸ģ�
case curEqpStatus when '1' then '����' when '2' then '����' when '3' then '����' when '4' then '������'
when '5' then '��ʧ' when '6' then '����' when '7' then '����' when '8' then '����' when '9' then '����' else 'δ֪' end curEqpStatus,
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




--�������빦��
exec sp_configure 'show advanced options',1
reconfigure
exec sp_configure 'Ad Hoc Distributed Queries',1
reconfigure
--�����ڽ�����ʹ��ACE.OLEDB.12
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
--����̬����
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1

SELECT * FROM OPENDATASOURCE('Microsoft.ACE.OLEDB.12.0',
'Data Source=C:\�ڿ��豸һ����.xls;Extended Properties=EXCEL 5.0')...[Sheet1$] ;

--������ʱ�� 
--exec ('insert into jihua(id,[���κ�],Right('''+ @filepath +''',charindex(''\'',REVERSE('''+ @filepath +'''))-1),getdate() FROM OPENDATASOURCE (''Microsoft.ACE.OLEDB.12.0'', ''Data Source='+@filepath+';User ID=Admin;Password='' )...�ƻ����ܱ�')

--ע�����Ҫ�ȹر���Χ�����ã�Ȼ���ٹرո߼�ѡ��
exec sp_configure'Ad Hoc Distributed Queries',0
reconfigure
exec sp_configure'show advanced options',0
reconfigure
--�ر�ACE.OLEDB.12��ѡ��
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 0
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 0



insert into OPENDATASOURCE('Microsoft.ACE.OLEDB.12.0',
'Data Source=d:\lw\�ڿ��豸һ����.xlsx;Extended Properties=EXCEL 8.0')...[Sheet1$]([�豸���],[��������],[״̬],[�豸����])

declare @temp as table([�豸���] varchar(8),[��������] varchar(10),[״̬] varchar(10),[�豸����] nvarchar(30))
insert into @temp
select e.eCode,
convert(varchar(10),e.acceptDate,120) as acceptDate,
--modi by lw 2011-1-26�������¶�����豸��״���޸ģ�
case curEqpStatus when '1' then '����' when '2' then '����' when '3' then '����' when '4' then '������'
when '5' then '��ʧ' when '6' then '����' when '7' then '����' when '8' then '����' when '9' then '����' else 'δ֪' end curEqpStatus,
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
create table #temp([�豸���] varchar(8),[��������] varchar(10),[״̬] varchar(10),[�豸����] nvarchar(30))
insert into #temp
    OUTPUT INSERTED.�豸���
        INTO insertInfo
select e.eCode,
convert(varchar(10),e.acceptDate,120) as acceptDate,
--modi by lw 2011-1-26�������¶�����豸��״���޸ģ�
case curEqpStatus when '1' then '����' when '2' then '����' when '3' then '����' when '4' then '������'
when '5' then '��ʧ' when '6' then '����' when '7' then '����' when '8' then '����' when '9' then '����' else 'δ֪' end curEqpStatus,
e.eName
from equipmentList e left join country c on e.cCode = c.cCode
left join fundSrc f on e.fCode = f.fCode
left join appDir a on e.aCode = a.aCode
left join college clg on e.clgCode = clg.clgCode
left join useUnit u on e.uCode = u.uCode

--Display the result set of the table variable.
SELECT ScrapReasonID, Name, ModifiedDate FROM insertInfo;

