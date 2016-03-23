alter TABLE [dbo].[plan] add othermana numeric(18,2) NULL			--����Ԥ�����ķ�˰���벦�� 
drop TABLE [dbo].[plan]
CREATE TABLE [dbo].[plan](
	OrganCode varchar(15) default('42000186-X'),	--��֯����
	serialNum int NULL,						--���
	purchseApplicationID varchar(18) null,	--����
	[depart] [nvarchar](255) NULL,			--����
	projectName [nvarchar](100) NULL,		--��Ŀ����
	AssetClassCode varchar(10) NULL,		--�������������
	AssetClassName nvarchar(100) NULL,		--��������������
	Unitage nvarchar(50) null,				--������λ
	AssetName nvarchar(100) NULL,			--�ʲ�����
	Amount numeric(18,2) NULL,				--����
	[Sum] numeric(18,2) NULL,				--���
	Finance numeric(18,2) NULL,				--�������С�ƣ�
	othermana numeric(18,2) NULL,			--����Ԥ�����ķ�˰���벦�� 


) ON [PRIMARY]

GO

select * from [plan]
order by serialNum
--�����ţ�
update [plan]
set purchseApplicationID='201211020001'

update [plan]
set othermana=Finance
update [plan]
set Finance=null

--���ɼ�����λ��
update [plan]
set AssetClassName = a.aTypeName, Unitage = a.Unitage
from [plan] p inner join aTypeCodeList a on p.AssetClassCode= a.aTypeCode



create table aTypeCodeList
(
	aTypeCode varchar(7) null,	--����
	aTypeName nvarchar(100) null,--����
	Unitage nvarchar(50) null,	--������λ
	notes nvarchar(300) null,	--˵ ��
)

select * from aTypeCodeList
where aTypeCode is null

update aTypeCodeList
set aTypeName = LTRIM(rtrim(aTypeName))




exec sp_addlinkedserver
     @server = MPS,--Linkedserver������
     @provider = 'Microsoft.ACE.OLEDB.12.0',--ʹ��JET 4.0�����ã����������
     @srvproduct = 'ACCESS 2000',
     @datasrc = 'F:\lw\�����Ŀ\������\����豸������Ϣϵͳ\ʡ��ԺУ����ϵͳ\����ʡ������ҵ��λ�ʲ��������\data\hbgydx\hbgydx_V7.mdb'  --��Ӧ�����ݿ�ȫ·��GO
go

EXEC sp_addlinkedsrvlogin 
     @rmtsrvname = N'MPS',
     @useself = N'FALSE',
     @locallogin = NULL, 
     @rmtuser = N'Admin', --���Access��û�н��û���Ĭ��ΪAdmin,����Ϊ��
     @rmtpassword = NULL
GO


--�������ݣ�
select OrganCode, SerialNumber, purchseApplicationID, projectName, AssetClassCode, AssetClassName,
	Unitage, AssetName, Amount, [Sum],othermanagementuntaxation
from   OPENDATASOURCE( 'Microsoft.ACE.OLEDB.12.0',   
'Data Source=F:\lw\�����Ŀ\������\����豸������Ϣϵͳ\ʡ��ԺУ����ϵͳ\����ʡ������ҵ��λ�ʲ��������\data\hbgydx\hbgydx_V7.mdb;User ID=Admin;Password=')...PurchaseApplicationDetail


insert OPENDATASOURCE( 'Microsoft.ACE.OLEDB.12.0',   
'Data Source=F:\lw\�����Ŀ\������\����豸������Ϣϵͳ\ʡ��ԺУ����ϵͳ\����ʡ������ҵ��λ�ʲ��������\data\hbgydx\hbgydx_V7.mdb;User ID=Admin;Password=')...PurchaseApplicationDetail
(OrganCode, SerialNumber, purchseApplicationID, projectName, AssetClassCode, AssetClassName,
	Unitage, AssetName, Amount, [Sum],othermanagementuntaxation)
select OrganCode, serialNum, purchseApplicationID, projectName, AssetClassCode, AssetClassName,
	Unitage, AssetName, Amount, [Sum], othermana
from [plan]


delete from OPENDATASOURCE( 'Microsoft.ACE.OLEDB.12.0',   
'Data Source=F:\lw\�����Ŀ\������\����豸������Ϣϵͳ\ʡ��ԺУ����ϵͳ\����ʡ������ҵ��λ�ʲ��������\data\hbgydx\hbgydx_V7.mdb;User ID=Admin;Password=')...PurchaseApplicationDetail
