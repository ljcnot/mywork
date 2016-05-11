--差旅费报销详情
drop table TravelExpensesDetails 
create table TravelExpensesDetails(
TravelExpensesDetailsIDint int identity(1,1),	--差旅费报销详情ID
ExpRemSingleID varchar(13)Primary Key (TravelExpensesDetailsIDint, ExpRemSingleID)  not null,	--报销单编号
StartDate smalldatetime	not null,	--起始时间
endDate smalldatetime not null,	--结束日期
startingPoint varchar(20) not null,	--起点
destination varchar(20) not null,	--终点
vehicle		varchar(12)	not null,	--交通工具
documentsNum	int	not null,	--单据张数
vehicleSum	numeric(15,2) not null,	--交通费金额
financialAccountID	varchar(13)	not null,	--科目ID
financialAccount	varchar(20) not null,	--科目名称
peopleNum	int not null,	--人数
travelDays float ,	-- 出差天数
TravelAllowanceStandard	numeric(15,2),	--出差补贴标准
travelAllowancesum	numeric(15,2)	not null,	--补贴金额
otherExpenses	varchar(20) ,	--其他费用
otherExpensesSum	numeric(15,2)	null	--其他费用金额
)
GO




use pm100

--创建用户：
declare	@Ret int
declare	@userID varchar(10)
exec dbo.addUser '工作证', 1,	--工作证号、类别：1->普通员工，9->高管
	--个人信息：
	'胡颖', 2, '1987-10-15',	--姓名、性别、出生日期
	--隶属信息：
	'O201511002',	--部门
	--工作信息：
	'移动端开发员',
	--联系方式：	
	'81814535','15071458715','403925982@qq.com',
	--系统登录信息：
	'hy',		--系统登录名
	'hy',		--用户描述
	'9888FF20ABD6E7DA4B9D5A3ACDB4E6D1',--密码：123456
					--'D63F7AB0AA4546EC668C1D11EB795819' --密码：''
	'Hello','a',	--密码保护
	'U201605003',	--创建人
	@ret output, @userID output
select @ret, @userID

select * from userInfo
select * from organization

--分配角色：
declare	@modiManID varchar(10),@updateTime smalldatetime, @Ret int 
set @modiManID = 'U201605003'
exec dbo.addUserRole 'U201605013',1, @modiManID output,@updateTime output, @Ret output	--赋予超级用户
select @Ret
