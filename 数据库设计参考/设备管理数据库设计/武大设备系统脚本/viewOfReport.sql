use epdc211
--报表设计视图：

--1.验收申请一览表视图
drop view eqpAcceptApplyInfoView
create view eqpAcceptApplyInfoView
as 
	select e.*,a.aName,f.fName,c.cName
	from dbo.eqpAcceptInfo e left join country c on e.cCode = c.cCode
    left join fundSrc f on e.fCode = f.fCode
    left join appDir a on e.aCode = a.aCode
go
select * from eqpAcceptApplyInfoView

--1.1.验收单一览表视图
drop view eqpAcceptInfoView
create view eqpAcceptInfoView
as 
	select e.*,a.aName,f.fName,c.cName,act.accountName
	from dbo.eqpAcceptInfo e left join country c on e.cCode = c.cCode
    left join fundSrc f on e.fCode = f.fCode
    left join appDir a on e.aCode = a.aCode
    left join accountTitle act on e.accountCode = act.accountCode
go
select * from eqpAcceptInfoView
select e.*,a.aName,f.fName,c.cName,act.accountName from dbo.eqpAcceptInfo e left join country c on e.cCode = c.cCode
    left join fundSrc f on e.fCode = f.fCode
    left join appDir a on e.aCode = a.aCode
    left join accountTitle act on e.accountCode = act.accountCode
where acceptApplyID='201305171005'

--2.采购申请一览表的视图
--主表直接使用基表
--从表视图：
drop view eqpPlanInfoView
create view eqpPlanInfoView
as
	select p.*,a.aName,f.fName
	from eqpPlanInfo p left join fundSrc f on p.fCode = f.fCode
	left join appDir a on p.aCode = a.aCode
go		

--3.设备卡片报表设计视图：
drop view equipmentCardView 
create view equipmentCardView 
as 
	select e.*,t.aTypeName , c.cName, f.fName, a.aName, clg.clgName, u.uName
	from equipmentList e left join typeCodes t on  e.eTypeCode=t.eTypeCode and e.eTypeName=t.eTypeName
		left join country c on e.cCode = c.cCode
        left join fundSrc f on e.fCode = f.fCode 
        left join appDir a on e.aCode = a.aCode 
        left join college clg on e.clgCode = clg.clgCode 
        left join useUnit u on e.uCode = u.uCode
go


select * from equipmentCardView 


--3.1.大型设备报废单打印设计视图：
drop view [dbo].[bEquipmentScrapDetailRpt]
CREATE view [dbo].[bEquipmentScrapDetailRpt]
as
	select b.scrapNum, eqs.isBigEquipment, l.eName, l.eModel, l.eFormat, b.eCode, b.eTypeCode,
		l.buyDate, l.price, l.totalAmount, 
		eqs.applyMan, eqs.applyDate, b.applyDesc,
		eqs.clgName,u.uName, b.clgDesc, b.clgManager, b.identifyDesc, b.tManager, 
		eqs.processMan, processDate, eqs.processDesc,
		eqs.eManager, eqs.scrapDate, eqs.scrapDesc, b.notificationNum, b.gzwDesc,
		case replyState when 0 then '未处置' when 1 then '全部同意' when 2 then '部分同意' when 3 then '全部不同意' end replyState
	from  dbo.equipmentScrap eqs 
		left join bEquipmentScrapDetail b on b.scrapNum=eqs.scrapNum
		left join equipmentList l on b.eCode = l.eCode
		left join useUnit u on l.uCode = u.uCode
GO


--3.2报废申请单、报废单一览表报表设计视图：
--主表直接使用基表
--从表视图：
drop view eqpScrapDetailView
CREATE view eqpScrapDetailView
as
	select '0' rowNum, b.scrapNum, b.eCode, b.eName, b.eModel, b.eFormat, b.oldEqpStatus, b.buyDate, b.eTypeCode, b.eTypeName,
		b.totalAmount, b.leaveMoney, 
		b.applyDesc, b.clgDesc, b.clgManagerID, b.clgManager, b.mDate,
		b.identifyDesc, b.tManagerID, b.tManager, b.tDate,
		b.gzwDesc, b.notificationNum, s.replyState
	from bEquipmentScrapDetail b inner join equipmentScrap s on s.scrapNum=b.scrapNum
	union all
	select rowNum, scrapNum, eCode, eName, eModel, eFormat, oldEqpStatus, buyDate, eTypeCode, eTypeName,
		totalAmount, leaveMoney, 
		scrapDesc, '', '', '', null, 
		identifyDesc, '', '', null, 
		'', '', processState
	from sEquipmentScrapDetail
go
select * from eqpScrapDetailView order by rowNum

			
--4.1调拨单一览表报表设计视图
--主表直接使用基表：
select * from equipmentAllocation
--从表使用的视图：
CREATE VIEW eqpAlcDetailView
as
	select a.*, e.eModel, e.eFormat 
	from equipmentAllocationDetail a left join equipmentList e on a.eCode=e.eCode
go

select * from eqpAlcDetailView

--4.2调拨单卡片报表：
CREATE VIEW eqpAlcDetail
AS
	select a.alcNum, a.eCode, a.eName, e.eModel, e.eFormat, a.totalAmount 
	from equipmentAllocationDetail a left join equipmentList e on a.eCode = e.eCode
go



--代码字典类报表视图：
--10.使用单位报表视图：
drop VIEW useUnitView
CREATE VIEW useUnitView
AS
	select u.rowNum,u.uCode,u.uName,u.manager,u.uType,u.clgCode,c.clgName,u.inputCode,
	u.isOff,convert(char(10), u.offDate, 120) offDate,
	u.modiManID,u.modiManName,u.modiTime,u.lockManID
	from useUnit u left join college c on u.clgCode = c.clgCode
go

--11.设备分类代码报表视图：
drop VIEW typeCodesView
CREATE VIEW typeCodesView
AS
	select e.rowNum,e.eTypeCode, e.eTypeName, a.aTypeCode, a.aTypeName,a.unit,e.inputCode, a.inputCode  cInputCode,
	e.isOff,convert(char(10), e.offDate, 120) offDate,
	e.modiManID,e.modiManName,e.modiTime,e.lockManID
	from typeCodes e left join GBT14885 a on e.aTypeCode = a.aTypeCode
go
select * from typeCodesView

--一般代码字典报表视图：
drop VIEW codeDictionaryView
CREATE VIEW codeDictionaryView
AS
	select m.objDesc classDesc, c.* from codeDictionary c left join codeDictionary m on c.classCode=m.objCode and m.classCode=0
	where c.classCode<>0
go

select * from codeDictionaryView

order by c.classCode, c.objCode

select * from codeDictionary where classCode=0




--运维类报表设计视图：
--20.用户卡片报表用视图：
create view [dbo].[userInfoView]
as
select jobNumber,cName,pID,mobileNum,telNum,e_mail,homeAddress,clgCode,clgName,uCode,uName,
sysUserName,sysUserDesc,dbo.getSysUserRole(jobNumber) sysRoleName,sysPassword,pswProtectQuestion,psqProtectAnswer,
case isOff when '0' then '√' else '' end isOff,
case isOff when '0' then '' else convert(char(10), setOffDate, 120) end offDate,
modiManID,modiManName,modiTime,lockManID
from userInfo
go


select * from kindTypeCodes 
select * from collegeCode
select * from college
select * from useUnit u left join  college c on u.clgCode=c.clgCode


select e.eCode,e.eName,e.eModel,e.eFormat,e.unit,e.cCode,e.factory,e.serialNumber,e.annexCode,e.annexName,
e.annexAmount,e.business,e.eTypeCode,e.eTypeName,e.aTypeCode,e.fCode,e.aCode,
convert(varchar(10),e.makeDate,120) as makeDate,
convert(varchar(10),e.buyDate,120) as buyDate,e.price,e.totalAmount,e.clgCode,e.uCode,e.keeper,
isnull(e.notes,'') notes,e.oprMan,e.acceptMan,convert(varchar(10),e.acceptDate,120) acceptDate,
e.curEqpStatus,e.scrapDate,c.cName,f.fName,a.aName,clg.clgName,
isnull(clg.Manager,'') clgManager,u.uName,acceptApplyID, e.keeperID, e.eqpLocate,e.obtainMode,e.purchaseMode 
from equipmentList e left join country c on e.cCode = c.cCode 
left join fundSrc f on e.fCode = f.fCode 
left join appDir a on e.aCode = a.aCode 
left join college clg on e.clgCode = clg.clgCode 
left join useUnit u on e.uCode = u.uCode where e.eCode ='13005489'; 
select * from eqpLifeCycle where eCode ='13005489'




select p.planApplyID,convert(varchar(10),p.applyDate,120) applyDate,p.clgCode,p.clgName,p.uCode,p.uName,p.totalNum,p.totalMoney,p.totalNowNum,
p.buyReason,p.clgManager,convert(varchar(10),p.clgManagerADate,120) clgManagerADate,p.leaderComments,p.leaderName,convert(varchar(10),p.leaderADate,120) leaderADate,
p.processManID,p.processMan,convert(varchar(10),p.processDate,120) processDate,a.aName aCode,f.fName fCode 
from eqpPlanInfo p left join fundSrc f on p.fCode = f.fCode  left join appDir a on p.aCode = a.aCode  
where p.planApplyID='201305210002'; 
select rowNum,planApplyID,eTypeCode,eTypeName,aTypeCode,eName,eModel,price,sumNumber,nowNum 
from eqpPlanDetail 
where planApplyID='201305210002' 
order by rowNum


select * from college



select * from userInfo
