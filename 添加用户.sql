--���÷ѱ�������
drop table TravelExpensesDetails 
create table TravelExpensesDetails(
TravelExpensesDetailsIDint int identity(1,1),	--���÷ѱ�������ID
ExpRemSingleID varchar(13)Primary Key (TravelExpensesDetailsIDint, ExpRemSingleID)  not null,	--���������
StartDate smalldatetime	not null,	--��ʼʱ��
endDate smalldatetime not null,	--��������
startingPoint varchar(20) not null,	--���
destination varchar(20) not null,	--�յ�
vehicle		varchar(12)	not null,	--��ͨ����
documentsNum	int	not null,	--��������
vehicleSum	numeric(15,2) not null,	--��ͨ�ѽ��
financialAccountID	varchar(13)	not null,	--��ĿID
financialAccount	varchar(20) not null,	--��Ŀ����
peopleNum	int not null,	--����
travelDays float ,	-- ��������
TravelAllowanceStandard	numeric(15,2),	--�������׼
travelAllowancesum	numeric(15,2)	not null,	--�������
otherExpenses	varchar(20) ,	--��������
otherExpensesSum	numeric(15,2)	null	--�������ý��
)
GO




use pm100

--�����û���
declare	@Ret int
declare	@userID varchar(10)
exec dbo.addUser '����֤', 1,	--����֤�š����1->��ͨԱ����9->�߹�
	--������Ϣ��
	'��ӱ', 2, '1987-10-15',	--�������Ա𡢳�������
	--������Ϣ��
	'O201511002',	--����
	--������Ϣ��
	'�ƶ��˿���Ա',
	--��ϵ��ʽ��	
	'81814535','15071458715','403925982@qq.com',
	--ϵͳ��¼��Ϣ��
	'hy',		--ϵͳ��¼��
	'hy',		--�û�����
	'9888FF20ABD6E7DA4B9D5A3ACDB4E6D1',--���룺123456
					--'D63F7AB0AA4546EC668C1D11EB795819' --���룺''
	'Hello','a',	--���뱣��
	'U201605003',	--������
	@ret output, @userID output
select @ret, @userID

select * from userInfo
select * from organization

--�����ɫ��
declare	@modiManID varchar(10),@updateTime smalldatetime, @Ret int 
set @modiManID = 'U201605003'
exec dbo.addUserRole 'U201605013',1, @modiManID output,@updateTime output, @Ret output	--���賬���û�
select @Ret
