drop table borrowSingle 
create table borrwSingle(
	borrowSingleID varchar(13) not null,  --借支单号
	borrowDate smalldatetime	not null,	--借支时间
	employeeID varchar(11)	not null,		--员工编号
	borrowName varchar(16)	not null,		--借支人姓名
	position	varchar(10)	not null,	--职务
	borrowReason	varchar(200)	not null,	--借支事由
	borrowSum	float	not null,	--金额
	approved	varchar(16),	--核准
	accounting	varchar(16),	--会计
	cashier	varchar(16),	--出纳
	borrowMan	varchar(16),	--借支人
	department	varchar(16)	not null,	--部门
	documentTemplate	int default(0) not null,	---公文模板
	flowProgress	int default(0) not null,	--流转进度
	IssueSituation	int default(0) not null,	--发放情况
	--创建人：add by lw 2012-8-9为了保持操作的范围——个人的一致性增加的字段
	createManID varchar(10) null,		--创建人工号
	createManName varchar(30) null,		--创建人姓名
	createTime smalldatetime null,		--创建时间

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号

















	





