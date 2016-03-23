use epdc2
/*
	武大设备管理信息系统-数据库初始化和数据清理
	从设计和平时数据清理中集中过来的代码,2011年10月7日正式切换数据库
	author:		卢苇
	CreateDate:	2011-10-7
	UpdateDate: 
*/

--一、代码字典的数据：
--1：系统参数代码表
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 1, '系统参数', '', '')
insert codeDictionary(classCode, objCode, objDesc)	--系统使用单位代码
values(1, 1, '10486')
insert codeDictionary(classCode, objCode, objDesc)	--系统使用单位名称
values(1, 2, '武汉大学')

--2：设备现状码：
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 2, '设备现状码', '高等学校仪器设备管理基本信息集', '')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 1, '在用', 1, '1')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 2, '多余', 1, '2')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 3, '待修', 1, '3')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 4, '待报废', 1, '4')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 5, '丢失', 1, '5')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 6, '报废', 1, '6')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 7, '调出', 1, '7')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 8, '降档', 1, '8')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 9, '其他', 1, '9')

--10：使用单位类型：
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 10, '使用单位类型', '自定义')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 1, '教学')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 2, '科研')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 3, '行政')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 4, '后勤')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 9, '其他')

--99.系统数据对象操作分类
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 99, '系统数据对象操作分类', '自定义')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 1, '查询类操作')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 2, '编辑类操作')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 3, '导出类操作')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 4, '审计类操作')

--100：角色分级类型：
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 100, '角色分级类型', '自定义')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 1, '通用的校级角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 2, '通用的院部级角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 3, '通用的单位角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 4, '隶属于特定院部的角色')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 5, '隶属于特定单位的角色')

--900：教育部报表类型
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 900, '教育部报表类型', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(900, 901, '教学科研仪器设备表')
insert codeDictionary(classCode, objCode, objDesc)
values(900, 902, '教学科研仪器设备增减变动情况表')
insert codeDictionary(classCode, objCode, objDesc)
values(900, 903, '贵重仪器设备表')

--901：财政部报表类型
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 901, '财政部报表类型', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 101, '土地')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 102, '房屋构筑物')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 103, '通用设备')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 104, '专用设备')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 105, '交通运输设备')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 106, '电气设备')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 107, '电子产品及通信设备')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 108, '仪器仪表及量具')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 109, '文艺体育设备')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 110, '图书文物及陈列品')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 111, '家具用具及其他类')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 112, '无形资产')

update codeDictionary
set inputCode = upper(dbo.getChinaPYCode(objDesc))

--二、参数表数据：

--1.设备分类代码表：含教育部和财政部两类分类标准
select * from typeCodes 
order by eTypeCode
where eTypeCode is null or ltrim(rtrim(eTypeCode )) = ''

drop table typeCodes
--备份数据库：
truncate table typeCodes
insert typeCodes(eTypeCode, eTypeName, aTypeCode, aTypeName,typeUnit, inputCode,cInputCode)
select eTypeCode, eTypeName, aTypeCode, aTypeName,typeUnit, inputCode,cInputCode from typeCodes2

select eTypeCode, eTypeName, aTypeCode, aTypeName,typeUnit, inputCode,cInputCode from typeCodes
--2011-10-8根据小毕提供的固定资产分类代码表增加数据：
insert typeCodes(eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit)
select flh, flmc, '','','台/套' from fldm
where flh not in (select eTypeCode from typeCodes)



--生成编码的快速索引：
update typeCodes
set eTypeCode4 = left(eTypeCode,4),
	eTypeCode5 = left(eTypeCode,5),
	eTypeCode6 = left(eTypeCode,6),
	eTypeCode7 = left(eTypeCode,7)

--有完全重复的代码43条：

CREATE TABLE #t(
	eTypeCode char(8) not null,		--分类编号（教）
	eTypeName nvarchar(30) not null,--教育部分类名称
	aTypeCode char(8) not null,		--分类编号（财政部）
	aTypeName nvarchar(30) not null,--财政部分类名称
	typeUnit nvarchar(10) not null,	--计量单位
-- CONSTRAINT [PK_typeCode] PRIMARY KEY CLUSTERED 
--(
--	[eTypeCode] ASC
--)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
insert #t 
select distinct * from typeCodes
truncate table typeCodes

insert typeCodes
select * from #t

update typeCodes
set inputCode = ''

select top 1000 * from typeCodes
where inputCode like '%'

select count(*) from typeCodes

select * from czmis.dbo.ttt

--输入码转换：
select * from t where len(输入码) > 5
update t
set 输入码= rtrim(ltrim(upper(输入码))),
	财输入码= rtrim(ltrim(upper(财输入码)))

select substring(输入码,0,4) + right(输入码,1), * from t
where len(输入码) > 5

update t
set 输入码= substring(输入码,0,4) + right(输入码,1)
where len(输入码) > 5

update t
set 财输入码= substring(财输入码,0,4) + right(财输入码,1)
where len(财输入码) > 5

update typeCodes
set inputCode = t.输入码, cInputCode = t.财输入码
from typeCodes c left join t on c.eTypeCode = t.flh and c.eTypeName = t.mc

--根据毕处指出将分类编码（教）中的尾号为‘0’的编码剔除，就没有了多对多的关系，所以输入的时候要检查！
select * from typeCodes 
where right(eTypeCode,1) = '0'
order by eTypeCode

select * from typeCodes 
where right(eTypeCode,1) <> '0'
order by eTypeCode

select * from typeCodes 
order by eTypeCode
--剔除有子分类的编码后依然存在多对多的关系：
select * from typeCodes 
where eTypeCode in 
(select eTypeCode
from typeCodes 
group by eTypeCode
having count(eTypeCode) > 1)
order by eTypeCode
--解决办法就是将分类名称也存放到设备表中，但是老的数据清理工作就只能靠人工辨别了！

--恢复备份：
use epdc2
truncate table typeCodes
insert typeCodes(eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate)
select eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, 
	cInputCode, isOff, offDate 
from dbo.typeCodes2
order by eTypeCode

--自动生成拼音代码：
select eTypeName, dbo.getChinaPYCode(eTypeName), inputCode from typeCodes
update typeCodes
set inputCode = upper(dbo.getChinaPYCode(eTypeName))
where inputCode is null

update typeCodes
set cInputCode = upper(dbo.getChinaPYCode(aTypeName))
where cInputCode is null

--2.国别（country）：
select rowNum,cCode,cName,enName,fullName,inputCode,case isOff when '0' then '√' else '' end isOff, 
case isOff when '0' then '' else convert(char(10), offDate, 120) end offDate, 
modiManID,modiManName,modiTime,lockManID
from country
order by cCode

select * from country where cCode not in (select dm from epdbc.dbo.gb)
select * from epdbc.dbo.gb
--备份数据：
truncate table country
insert country(cCode, cName, enName, fullName,inputCode)
select cCode, cName, enName, fullName,inputCode from country2

select * from country
where cCode is null or ltrim(rtrim(cCode)) = ''

--转换数据：
insert country(cCode, cName)
select dm, mc from epdbc.dbo.gb

select cCode, cName, enName, inputCode from country order by inputCode
update country
set cName = LTRIM(rtrim(cName))

--增加输入码和中英文全称：
select * from t
select * from country
select c.*, t.* from country c left join t on c.cCode = t.阿拉伯数字代码

update country
set inputCode = t.输入码,
	fullName = t.中文和英文全称
from country c left join t on c.cCode = t.阿拉伯数字代码

--恢复备份：
truncate table country
insert country(cCode, cName, enName, fullName, inputCode, isOff, offDate)
select cCode, cName, enName, fullName, inputCode, isOff, offDate from country2
	
--自动生成拼音代码：
select cName, dbo.getChinaPYCode(cName), inputCode from country
update country
set inputCode = upper(dbo.getChinaPYCode(cName))
where inputCode is null


--3.fundSrc（经费来源）：
select * from fundSrc
select * from fundSrc2
where fCode is null or ltrim(rtrim(fCode)) = ''

drop table fundSrc
--备份数据库：
truncate table fundSrc
insert fundSrc(fCode,fName,inputCode)
select fCode,fName,inputCode from fundSrc2
--恢复备份：
truncate table fundSrc
insert fundSrc(fCode,fName,inputCode)
select fCode,fName,inputCode from fundSrc2

select fCode,fName,inputCode from fundSrc
--自动生成拼音代码：
select fName, dbo.getChinaPYCode(fName), inputCode from fundSrc
update fundSrc
set inputCode = upper(dbo.getChinaPYCode(fName))
where inputCode is null

--转换数据：
insert fundSrc(fCode, fName)
select dm, mc from epdbc.dbo.jfly

update fundSrc
set fName = LTRIM(rtrim(fName))

--4.appDir（使用方向）：
select * from appDir
where aCode is null or ltrim(rtrim(aCode))=''

select len(aName), * from appDir
drop table appDir
--备份数据库：
insert appDir2(aCode, aName, inputCode)
select aCode, aName, inputCode from appDir
--恢复备份：
truncate table appDir
insert appDir(aCode, aName, inputCode)
select aCode, aName, inputCode from appDir2
--自动生成拼音代码：
select aName, dbo.getChinaPYCode(aName), inputCode from appDir
update appDir
set inputCode = upper(dbo.getChinaPYCode(aName))
where inputCode is null



--转换数据：
insert appDir(aCode, aName)
select dm, mc from epdbc.dbo.syfx

select * from appDir
update appDir
set aName = LTRIM(rtrim(aName))


--5.college（院部表）：
--指学院（系）、研究所、实验中心及处级单位
select * from college
where clgCode is null or ltrim(rtrim(clgCode))=''

drop table college
--备份数据库：
insert college2(clgCode,clgName,manager,inputCode)
select clgCode,clgName,manager,inputCode from college
--恢复备份：
truncate table college
insert college(clgCode,clgName,manager,inputCode)
select clgCode,clgName,manager,inputCode from college2

--转换数据：
insert college(clgCode, clgName, manager)
select dm, mc, ybfzr from epdbc.dbo.yb
where dm not in (select clgCode from college)

--自动生成拼音代码：
select clgName, dbo.getChinaPYCode(clgName), inputCode from college
update college
set inputCode = upper(dbo.getChinaPYCode(clgName))
where inputCode is null

--需要确认原数据库中的“px”字段的含义:常用单位的标识符，改成累计次数

--确认数据：
select * from college c right join epdbc.dbo.yb y on c.clgCode = y.dm and c.clgName = y.mc

--导入输入码：
select * from t
select * from college
select * from t where len(输入码) > 5
update t
set 输入码= rtrim(ltrim(upper(输入码)))

update college
set inputCode = t.输入码
from college c left join t on c.clgCode = t.编码

use epdc2
select * from college
select * from useUnit

select c.clgCode, u.uCode clgName, uName 
from college c left join useUnit u on c.clgCode = u.clgCode
order by c.clgCode, u.uCode

select c.clgCode, u.uCode, c.clgName, u.uName 
from college c left join useUnit u on c.clgCode = u.clgCode 
order by c.clgCode, u.uCode

select * from college where clgCode = '152'

--6.useUnit（使用单位）：
select * from useUnit
where uCode is null or ltrim(rtrim(uCode))=''

select len(uName),* from useUnit
drop table useUnit
--备份数据库：
insert useUnit2(uCode,uName,manager,clgCode,inputCode)
select uCode,uName,manager,clgCode,inputCode from useUnit
--恢复备份：
truncate table useUnit
insert useUnit(uCode,uName,manager,clgCode,inputCode)
select uCode,uName,manager,clgCode,inputCode from useUnit2
select * from useUnit

--转换数据：
insert useUnit(uCode, uName, manager, clgCode)
select dm, mc, fzr, yb from epdbc.dbo.sydw
where yb in (select dm from epdbc.dbo.yb)
and dm not in (select uCode from useUnit)

--自动生成拼音代码：
select uName, dbo.getChinaPYCode(uName), inputCode from useUnit
update useUnit
set inputCode = upper(dbo.getChinaPYCode(uName))
where inputCode is null

--需要确认的异常数据处理：
select * from epdbc.dbo.sydw where yb not in (select dm from epdbc.dbo.yb)

--确认数据：
select * from useUnit u left join epdbc.dbo.sydw d on u.uCode = d.dm and u.uName = d.mc

select e.eCode, e.eName, e.eModel, e.eFormat, e.cCode, c.cName
from equipmentList e left join country c on e.cCode = c.cCode
--导入输入码：
select * from tt
select * from useUnit
select * from tt where len(输入码) > 5
update tt
set 输入码= rtrim(ltrim(upper(输入码)))

update tt
set 输入码= substring(输入码,0,4) + right(输入码,1)
where len(输入码) > 5

update useUnit
set inputCode = tt.输入码
from useUnit u left join tt on u.ucode = tt.编码

--7.会计科目代码字典表
select * from accountTitle
where accountCode is null or ltrim(rtrim(accountCode)) = ''

drop table accountTitle
--备份数据库：
insert accountTitle2(accountCode, accountName, accountEName, accountTypeCode, accountTypeName, accountTypeEName, inputCode)
select accountCode, accountName, accountEName, accountTypeCode, accountTypeName, accountTypeEName, inputCode from accountTitle
--恢复备份：
truncate table accountTitle
insert accountTitle(accountCode, accountName, accountEName, accountTypeCode, accountTypeName, accountTypeEName, inputCode)
select accountCode, accountName, accountEName, accountTypeCode, accountTypeName, accountTypeEName, inputCode from accountTitle2
--自动生成拼音代码：
select accountName, dbo.getChinaPYCode(accountName), inputCode from accountTitle
update accountTitle
set inputCode = upper(dbo.getChinaPYCode(accountName))
where inputCode is null

select * from accountTitle
update accountTitle
set accountName = ltrim(rtrim(accountName))

--装入数据：
insert accountTitle(accountCode, accountName, accountEName, accountTypeCode,
	accountTypeName, accountTypeEName, inputCode)
select 科目代码, 科目名称, 英文名称, 类别代码, 类别, 类别英文名, 输入码 from t

select * from t where len(输入码) > 5
select * from t where len(科目代码) > 6
select * from t where len(科目名称) > 30
select *, len(英文名称) from t where len(英文名称) > 50

select accountCode, accountName, accountEName, accountTypeCode,
	accountTypeName, accountTypeEName, inputCode 
from accountTitle order by inputCode


select * 
from 
equipmentList e left join country c on e.cCode = c.cCode 
left join fundSrc f on e.fCode = f.fCode 
left join appDir a on e.aCode = a.aCode 
left join college clg on e.clgCode = clg.clgCode 
left join useUnit u on e.uCode = u.uCode 
order by eName asc


--制作拼音码：
select * from appdir
update appdir
set inputCode = upper(dbo.getChinaPYCode(aname))

select * from country
update country
set inputCode = upper(dbo.getChinaPYCode(cName))
where isnull(inputCode,'') = ''

update fundSrc
set inputCode = upper(dbo.getChinaPYCode(fName))
where isnull(inputCode,'') = ''


--三、权限表
--1.0权限表：
select * from sysRight
--更新数据：2011-10-2
update sysRight
set Url = 'systemTools/sysAdvTools.html'
where rightName = '系统高级设置'

update sysRight
set Url = 'userInfo/sysResources.html'
where rightName = '定义系统'

insert sysRight(rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse, rightDesc)
values('清除编辑锁','clearAllLock','','F',7,7,3,'Y','该功能将清除所有用户的编辑锁，同时清除所有在线用户。')

--增加系统资源：add by lw 2011-11-20
SELECT * FROM sysRight
insert sysRight(rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, 
				canUse, canQuery4Global, canQuery4Local, canQuery4UnitLocal, 
				canEdit4Global, canEdit4Local, canEdit4UnitLocal, 
				canOutput4Global, canOutput4Local, canOutput4UnitLocal,
				canCheck4Global, canCheck4Local, canCheck4UnitLocal,
				rightDesc)
values('盘点表','eqpCheckInfoList','eqpManager/eqpCheckInfoList.html','D',3,6,0,
				'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','可以查询、删除、导出盘点表和审计的权利。')

insert sysRight(rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, 
				canUse, canQuery4Global, canEdit4Global, canOutput4Global,
						canCheck4Global, rightDesc)
values('使用单位代码映射表','useUnitCodeMap','reportCenter/useUnitCodeMap.html','D',6,3,0,'Y','Y','Y','Y','Y',
	'可以使用单位映射表的权利。')

--增加系统资源：add by lw 2011-11-26
update sysRight
set rightName = '系统设定'
where rightName = '系统工具'

insert sysRight(rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	canQuery4Global, canEdit4Global, canOutput4Global, canCheck4Global,
	rightDesc)
values('运行维护','oprMaintenance','','F',8,0,0,'Y',
	'Y','Y','Y','N','可以对在线用户、工作日志、公告、论坛管理的权限')

insert sysRight(rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	canQuery4Global, canEdit4Global, canOutput4Global, canCheck4Global,
	rightDesc)
values('公告管理','bulletinList','bulletin/bulletinList.html','D',8,2,0,'Y',
	'Y','Y','Y','N','管理公告的权利')

--更正数据：
select * from sysRight
where rightEName = 'userList'
update sysRight
set rightType = 'D'
where rightEName = 'userList'

--调整导航栏：2011-11-28
select * from sysRight
where rightEName = 'userReport'
select * from [sysDataOpr]
where rightKind =8 and rightClass =4 and rightItem =0

select * from sysRoleOpr
where rightEName = 'userReport'
select * from [sysRoleDataOpr]
where rightKind =8 and rightClass =4 and rightItem =0

update sysRight
set rightKind =8, rightClass =4, rightItem =0
where rightEName = 'userReport'

select * from sysRight
where rightEName = 'workNoteList'

update sysRight
set rightKind =8, rightClass =5, rightItem =0
where rightEName = 'workNoteList'

select * from sysRight
where rightKind =7 and rightClass =7

update sysRight
set rightKind =7, rightClass =5
where rightKind =7 and rightClass =7


select * from sysRight
where rightEName = 'sysManagerForm'
select * from sysRoleRight
where rightEName = 'sysManagerForm'

update sysRight
set rightName = '系统设定'
where rightEName = 'sysManagerForm'

update sysRoleRight
set rightName = '系统设定'
where rightEName = 'sysManagerForm'



--1.1数据操作集（由于这个数据表为静态数据，所以并没有将操作集单独设计成一个表）：
--获取系统所有的操作：
select distinct oprType, oprName, oprEName, oprDesc 
from sysDataOpr

SELECT * FROM sysDataOpr
--增加的操作集：
insert sysDataOpr
values(7,3,0,2,'授权','cmdAut','设置角色（用户）的权限')
insert sysDataOpr
values(7,4,0,2,'重置密码','cmdUpdatePW','重置用户的密码')
insert sysDataOpr
values(7,4,0,2,'授权','cmdAut','设置角色（用户）的权限')

--增加的操作集：add by lw 2011-11-20
select * from sysDataOpr where rightKind = 3 and rightClass = 1 and rightItem = 0 and oprType = 2 and oprEName='cmdRep'
update sysDataOpr 
set oprName = '盘点',
	oprEName = 'cmdChecking',
	oprDesc = '清点设备，报告设备现状和位置'
where rightKind = 3 and rightClass = 1 and rightItem = 0 and oprType = 2 and oprEName='cmdRep'

insert sysDataOpr
values(3,6,0,1,'默认列表','cmdDefaultList','设备盘点表默认列表功能')
insert sysDataOpr
values(3,6,0,1,'筛选','cmdFilter','设定查询条件，约束数据列表的显示范围')
insert sysDataOpr
values(3,6,0,1,'查阅卡片','cmdShowCard','查看指定行的盘点详细信息')
insert sysDataOpr
values(3,6,0,2,'删除','cmdDel','删除指定行的盘点信息')
insert sysDataOpr
values(3,6,0,3,'打印卡片','cmdPrintCard','打印指定行的盘点详细信息')
insert sysDataOpr
values(3,6,0,3,'打印（列表）','cmdPrint','打印列表')
insert sysDataOpr
values(3,6,0,3,'导出','cmdOutput','导出当前数据窗口中的列表')
insert sysDataOpr
values(3,6,0,4,'审核','cmdVerify','审核并生效盘点信息')
insert sysDataOpr
values(3,6,0,4,'取消审核','cmdCancelVerify','取消盘点信息的审核执行')

--增加的公告板操作集：add by lw 2011-11-25
insert sysDataOpr
values(8,2,0,1,'默认列表','cmdDefaultList','公告默认列表功能')
insert sysDataOpr
values(8,2,0,1,'筛选','cmdFilter','设定查询条件，约束公告列表的显示范围')
insert sysDataOpr
values(8,2,0,1,'查阅','cmdShowCard','查看指定公告的详细信息')
insert sysDataOpr
values(8,2,0,1,'预览','cmdPreview','模拟登录后公告的显示')

insert sysDataOpr
values(8,2,0,2,'新建','cmdNew','新建公告')
insert sysDataOpr
values(8,2,0,2,'修改','cmdUpdate','修改制定的公告')
insert sysDataOpr
values(8,2,0,2,'删除','cmdDel','删除指定的公告')
insert sysDataOpr
values(8,2,0,2,'发布','cmdActive','发布指定的公告')
insert sysDataOpr
values(8,2,0,2,'关闭','cmdSetOff','关闭指定的公告')

insert sysDataOpr
values(8,2,0,3,'打印卡片','cmdPrintCard','打印指定公告详细信息')
insert sysDataOpr
values(8,2,0,3,'打印（列表）','cmdPrint','打印公告列表')
insert sysDataOpr
values(8,2,0,3,'导出','cmdOutput','导出当前数据窗口中的公告列表')


--2.0.角色表：
--预定义的角色：
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType, modiManID)
values('超级用户', '系统预设的拥有全部权限的用户', 1, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('校级系统管理员', '系统预设的拥有全部权限的用户', 1, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('院部系统管理员', '系统预设的隶属于院部的系统管理员，拥有本院部特定角色定义权限', 2, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('单位系统管理员', '系统预设的隶属于单位的系统管理员，拥有本单位特定角色定义权限', 3, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('一般用户', '系统预设的普通用户，系统默认分配该角色给每一个新建用户，该用户只拥有本单位的单据查询权限', 3, '0000000000')

select * from codeDictionary where classCode = 100
select * from sysRole

--2.1.角色权限表：
truncate table sysRoleRight
--预定义的角色：超级用户，拥有全部权限：
insert sysRoleRight(sysRoleID,
	rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--以下是针对数据的操作：
	canQuery, canEdit, canOutput, canCheck, rightDesc)
select 1, rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--以下是针对数据的操作：
	case canQuery4Global when 'Y' then 9 else 0 end, 
	case canEdit4Global when 'Y' then 9 else 0 end, 
	case canOutput4Global when 'Y' then 9 else 0 end, 
	case canCheck4Global when 'Y' then 9 else 0 end, 
	rightDesc 
from sysRight
where rightKind * 1000 + rightClass * 100 + rightItem not in (select rightKind * 1000 + rightClass * 100 + rightItem from sysRoleRight where sysRoleID = 1)

--预定义的角色：系统管理员，拥有全部权限：
select * from sysRole where sysRoleID < 5
select * from sysRoleRight
insert sysRoleRight(sysRoleID,
	rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--以下是针对数据的操作：
	canQuery, canEdit, canOutput, canCheck, rightDesc)
select 2, rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--以下是针对数据的操作：
	case canQuery4Global when 'Y' then 9 else 0 end, 
	case canEdit4Global when 'Y' then 9 else 0 end, 
	case canOutput4Global when 'Y' then 9 else 0 end, 
	case canCheck4Global when 'Y' then 9 else 0 end, 
	rightDesc 
from sysRight
where rightKind * 1000 + rightClass * 100 + rightItem not in (select rightKind * 1000 + rightClass * 100 + rightItem from sysRoleRight where sysRoleID = 2)

--预定义的角色：院部系统管理员，拥有院部的全部权限，可以定义本院部的特定角色：
insert sysRoleRight(sysRoleID,
	rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--以下是针对数据的操作：
	canQuery, canEdit, canOutput, canCheck, rightDesc)
select 3, rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--以下是针对数据的操作：
	case canQuery4Local when 'Y' then 2 else 0 end, 
	case canEdit4Local when 'Y' then 2 else 0 end, 
	case canOutput4Local when 'Y' then 2 else 0 end, 
	case canCheck4Local when 'Y' then 2 else 0 end, 
	rightDesc 
from sysRight

--预定义的角色：单位系统管理员，拥有单位的全部权限，可以定义本单位的特定角色：
insert sysRoleRight(sysRoleID,
	rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--以下是针对数据的操作：
	canQuery, canEdit, canOutput, canCheck, rightDesc)
select 4, rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--以下是针对数据的操作：
	case canQuery4UnitLocal when 'Y' then 1 else 0 end, 
	case canEdit4UnitLocal when 'Y' then 1 else 0 end, 
	case canOutput4UnitLocal when 'Y' then 1 else 0 end, 
	case canCheck4UnitLocal when 'Y' then 1 else 0 end, 
	rightDesc 
from sysRight

--预定义的角色：一般用户（every one），拥有本部门的查询权限：
insert sysRoleRight(sysRoleID,
	rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--以下是针对数据的操作：
	canQuery, canEdit, canOutput, canCheck, rightDesc)
select 5, rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--以下是针对数据的操作：
	case canQuery4UnitLocal when 'Y' then 1 else 0 end, 0, 0, 0, rightDesc 
from sysRight
delete sysRoleRight where sysRoleID = 5 and rightKind = 7

select * from sysRoleRight where sysRoleID = 1


--2.2.角色权限操作表：
--预设置数据：
truncate table sysRoleDataOpr
--增加超级用户的角色权限操作：
select * from sysRoleDataOpr
insert sysRoleDataOpr
select 1, r.rightKind, r.rightClass, r.rightItem, o.oprType, o.oprName, o.oprEName, o.oprDesc, 
case o.oprType when 1 then r.canQuery when 2 then r.canEdit when 3 then r.canOutput when 4 then r.canCheck end
from sysRoleRight r left join  sysDataOpr o on r.rightKind = o.rightKind and r.rightClass = o.rightClass and r.rightItem = o.rightItem
where r.rightType = 'D' and cast((r.rightKind * 1000 + r.rightClass * 100 + r.rightItem) as varchar(20)) + o.oprName  
							not in (select cast((rightKind * 1000 + rightClass * 100 + rightItem) as varchar(20)) + oprName from sysRoleDataOpr where sysRoleID = 1)

insert sysRoleDataOpr
select sysRoleID, r.rightKind, r.rightClass, r.rightItem, o.oprType, o.oprName, o.oprEName, o.oprDesc, 
case o.oprType when 1 then r.canQuery when 2 then r.canEdit when 3 then r.canOutput when 4 then r.canCheck end
from sysRoleRight r left join  sysDataOpr o on r.rightKind = o.rightKind and r.rightClass = o.rightClass and r.rightItem = o.rightItem
where r.rightType = 'D'

--更改操作名称：by lw 2011-11-21
select * from sysRoleDataOpr where rightKind = 3 and rightClass = 1 and rightItem = 0 and oprType = 2 and oprEName='cmdRep'
update sysRoleDataOpr
set oprName = '盘点',
	oprEName = 'cmdChecking',
	oprDesc = '清点设备，报告设备现状和位置'
where rightKind = 3 and rightClass = 1 and rightItem = 0 and oprType = 2 and oprEName='cmdRep'
select * from sysRoleDataOpr where rightKind = 3 and rightClass = 1 and rightItem = 0 and oprType = 2 and oprEName='cmdChecking'

--3.用户角色表：
--添加一个初始超级用户的权限：
delete userInfo where jobNumber = '0000000000'
insert userInfo(jobNumber, cName, clgCode, clgName, sysUserName, sysPassword, modiManID)
values('0000000000','超级用户','000','实验室与设备管理处', 'admin','D63F7AB0AA4546EC668C1D11EB795819','0000000000')
--初始密码是''

--给每个用户"一般用户"角色:
insert sysUserRole
select jobNumber, sysUserName, 5, '一般用户', 3 from userInfo

--系统预定义的超级用户的角色：
insert sysUserRole
select '0000000000','超级用户', sysRoleID, sysRoleName, sysRoleType
from sysRole
where sysRoleID = 1


select * from userInfo
select * from useUnit
select * from sysRoleRight
select * from sysUserRole
select sysRoleID, sysRoleName, sysRoleType
from sysUserRole
where jobNumber = '0000000000'

use epdc2
update userInfo 
set sysRoleID = 1, sysRoleName='超级用户'
where jobNumber = '2010112301'


--四、系统用户信息表：
insert userInfo(jobNumber, cName, clgCode, clgName, sysUserName, sysPassword, modiManID)
values('2010112301','卢苇','001','党委办公室','lw','930522','2010112301')

insert userInfo(jobNumber, cName, clgCode, clgName, sysUserName, sysPassword, modiManID)
values('2010112302','张明丽','001','党委办公室','zml','123','2010112301')
--1.系统用户信息表 （userInfo）：

select * from userInfo
delete userInfo where jobNumber ='3692581470'

--导入武大校园卡数据：

--启用Ad Hoc Distributed Queries：
exec sp_configure 'show advanced options',1
reconfigure
exec sp_configure 'Ad Hoc Distributed Queries',1
reconfigure
--使用完成后，关闭Ad Hoc Distributed Queries：
exec sp_configure 'Ad Hoc Distributed Queries',0
reconfigure
exec sp_configure 'show advanced options',0
reconfigure 

select * from college where clgName like '%珞珈%'
--校园卡数据库中使用名字来定义各院部,同我们的数据库不能完全匹配,一些可以分辨的院部我已经改了,但是还有很多需要人工分辨的,请设备处人员处理:
select distinct t.gz88 from 
(select gz50, gz05, gz88
from 
OpenRowSet('Microsoft.Jet.OLEDB.4.0','Excel 5.0;hdr=Yes;DataBase=C:\Users\Administrator\Desktop\武汉大学校园卡数据库.xls',fangkun$)) t
left join college c on left(t.gz88,2) = LEFT(c.clgName,2)
where c.clgName is null

--临时中转表
create table tempClgCard(
	jobNumber varchar(10),
	cName varchar(30),
	clgName varchar(30)
)
insert tempClgCard(jobNumber, cName, clgName)
select t.gz50, t.gz05, c.clgName
from 
OpenRowSet('Microsoft.Jet.OLEDB.4.0','Excel 5.0;hdr=Yes;DataBase=C:\Users\Administrator\Desktop\武汉大学校园卡数据库.xls',fangkun$) t
left join college c on left(t.gz88,2) = LEFT(c.clgName,2)
where rtrim(ltrim(t.gz05)) <> '' and  t.gz05 is not null and t.gz50 not in (select jobNumber from userInfo)

select * from userInfo where sysUserName = 'fk'
update userInfo 
set sysPassWord='123456'
where sysUserName = 'fjc'

insert userInfo(jobNumber, cName, clgCode, clgName, sysUserName, sysUserDesc, sysPassword, modiManID)
select t.jobNumber, t.cName, c.clgCode, t.clgName, lower(dbo.getChinaPYCode(t.cName)), '校园卡用户', t.jobNumber, ''
from 
tempclgCard t
left join college c on t.clgName = c.clgName
where rtrim(ltrim(t.jobNumber)) <> '' and  t.jobNumber is not null and t.jobNumber not in (select jobNumber from userInfo)
and clgCode is not null
and t.jobNumber not in 
(select jobNumber from tempClgCard
group by jobNumber
having count(*) > 1
)




--五、验收单：
--转换数据：
select distinct ysdh from epdbc.dbo.ysd

--使用设备表中的分类代码（财）设置验收单中的空字段：
select * from epdbc.dbo.ysd
where flbhj is null

use epdbc
create table t
(
	sbbh varchar(8),
	flbhj varchar(8)
)
insert epdbc.dbo.t
select sbbh, flbhj
from epdbc.dbo.sbmain

delete epdbc.dbo.t
where sbbh in(
select left(sbbh,8)
from epdbc.dbo.ysd
where flbhj is not null
)

delete epdbc.dbo.t
where left(sbbh,1) not in ('0','1','2','3','4','5','6','7','8','9')
or substring(sbbh,2,1) not in ('0','1','2','3','4','5','6','7','8','9')
or substring(sbbh,3,1) not in ('0','1','2','3','4','5','6','7','8','9')
or substring(sbbh,4,1) not in ('0','1','2','3','4','5','6','7','8','9')
or substring(sbbh,5,1) not in ('0','1','2','3','4','5','6','7','8','9')
or substring(sbbh,6,1) not in ('0','1','2','3','4','5','6','7','8','9')
or substring(sbbh,7,1) not in ('0','1','2','3','4','5','6','7','8','9')
or substring(sbbh,8,1) not in ('0','1','2','3','4','5','6','7','8','9')

select * from epdbc.dbo.t
select cast(sbbh as bigint), flbhj from epdbc.dbo.t

select cast(left(sbbh,8) as bigint), cast(substring(sbbh,10,8) as bigint), 
cast(substring(sbbh,6,3) as bigint),
cast(substring(sbbh,15,3) as bigint), 
*
from epdbc.dbo.ysd
where flbhj is null

update epdbc.dbo.ysd
set flbhj = tab.rflbhj
from (
	select y.sbbh rsbbh, s.sbbh, y.flbhj, s.flbhj rflbhj
	from (select * from epdbc.dbo.ysd
	where flbhj is null) as y 
	left join epdbc.dbo.t s 
	on (right(rtrim(y.sbbh),1)='-' and left(y.sbbh,8) = s.sbbh)
		or (len(rtrim(y.sbbh)) = 9 and y.sbbh = s.sbbh)
		or (len(rtrim(y.sbbh))=17 and left(y.sbbh,5) = left(s.sbbh,5) and 
			cast(substring(y.sbbh,6,3) as bigint) <= cast(substring(s.sbbh,6,3) as bigint) and
			cast(substring(y.sbbh,15,3) as bigint) >= cast(substring(s.sbbh,6,3) as bigint)
			)
	where y.flbhj is null) tab
where ysd.sbbh = tab.rsbbh


select * from epdbc.dbo.ysd
where flbhj is null

select * from epdbc.dbo.sbmain 
where sbbh in (select left(sbbh,8) from epdbc.dbo.ysd where flbhj is null)

select *
from epdbc.dbo.sbmain 
where sbbh is null
where flbhj is null

--发现有重复单据号
select * from epdbc.dbo.ysd 
where ysdh in (
	select ysdh from (
		select ysdh, count(*) as itemNum 
		from epdbc.dbo.ysd 
		group by ysdh
		having count(*)  > 1) tab)
order by ysdh
					
insert eqpAcceptInfo(acceptApplyID, acceptMan, acceptDate, annexName, oprMan, buyDate, 
			clgCode, uCode, eTypeCode, eTypeName, aTypeCode,
			annexAmount, price, sumNumber, eName, eModel, eFormat, notes, 
			fCode, aCode, keeper, totalAmount, sumAmount, startECode, endECode, business,
			accountCode,	--会计科目代码:用户确认;原来老系统的分类编码（财）中放的是会计科目！
			--原数据库验收单中没有的字段，使用设备库中反向设置：
			cCode,factory, makeDate, serialNumber
			)
select ysdh, ysr, ysdate, sjfj, jbr, gzrq, 
			yb, sydw, flbhj, '', '', 
			fjje, dj, sl, isnull(sbmc,''), sbxh, isnull(sbgg,'*'), bz, 
			jfly, syfx, sbbg, sbzj, hjje, LEFT(sbbh,8), substring(sbbh, charIndex('-',sbbh)+1, 8), xsdw,
			flbhc,
			'','',null,''
from epdbc.dbo.ysd
where ysdh not in (select ysdh from (
					select ysdh, count(*) as itemNum 
					from epdbc.dbo.ysd 
					group by ysdh
					having count(*)  > 1) tab)
	and flbhj is not null

select * from eqpAcceptInfo
select * from epdbc.dbo.ysd 
where flbhj is null

--定义验收单的状态：
update eqpAcceptInfo
set acceptApplyStatus = 2
from eqpAcceptInfo e left join epdbc.dbo.ysd y on e.acceptApplyID = y.ysdh
where y.ysr is not null and y.ysr <>''

update eqpAcceptInfo
set acceptApplyStatus = 0
from eqpAcceptInfo e left join epdbc.dbo.ysd y on e.acceptApplyID = y.ysdh
where y.ysr is null or y.ysr =''

--以下字段的转换要给出规则：
--以下字段原数据库中没有,好像直接存放到设备表中去了，所以要从设备表中反向获取回来：
	cCode char(3) null,					--国家代码：需要用户确认是否允许空值！！！不允许！！
	factory	nvarchar(20) null,			--出厂厂家
	makeDate smalldatetime null,		--出厂日期，在界面上拦截
	serialNumber nvarchar(15) null,		--出厂编号

--逐个生成验收单中的国家代码、出厂编号等信息：
declare @acceptApplyID char(12)
declare tar cursor for
select acceptApplyID from eqpAcceptInfo
where acceptApplyID in (select acceptApplyID from equipmentList)
OPEN tar
FETCH NEXT FROM tar INTO @acceptApplyID
WHILE @@FETCH_STATUS = 0
begin
	declare @cCode char(3)				--国家代码：需要用户确认是否允许空值！！！不允许！！
	declare @factory nvarchar(20)		--出厂厂家
	declare @makeDate smalldatetime		--出厂日期，在界面上拦截
	declare @serialNumber nvarchar(15)	--出厂编号
	declare @str nvarchar(2000)			--合成后的出厂编号
	set @str = ''
	declare s cursor for
	select cCode, factory, makeDate, serialNumber
	from equipmentList
	where acceptApplyID = @acceptApplyID
	order by eCode
	OPEN s
	FETCH NEXT FROM s INTO @cCode,@factory,@makeDate,@serialNumber
	WHILE @@FETCH_STATUS = 0
	begin
		set @str = @str + '|' + @serialNumber
		FETCH NEXT FROM s INTO @cCode,@factory,@makeDate,@serialNumber
	end
	CLOSE s
	DEALLOCATE s
	
	if (len(@str) > 0)
		set @str = right(@str, len(@str) -1)
	--print 'ApplyID:' + @acceptApplyID + 'serialNumber:' + @str
	
	update eqpAcceptInfo
	set cCode = @cCode, factory = @factory, makeDate = @makeDate, serialNumber = @str
	where acceptApplyID = @acceptApplyID
	
	FETCH NEXT FROM tar INTO @acceptApplyID
end
CLOSE tar
DEALLOCATE tar

--检查会计科目是否对应：
select *
from eqpAcceptInfo a 
where isnull(a.accountCode,'') = '' 

select a.accountCode, t.accountName, a.*
from eqpAcceptInfo a left join accountTitle t on a.accountCode = t.accountCode
where isnull(a.accountCode,'') <> '' and t.accountName is null


select * from eqpAcceptInfo

--2010-11-30为了解决多对多的关系增加了分类名称字段，需要处理的数据：
--发现分类代码库中少了很多代码：
select e.eTypeCode, t.eTypeName, t.aTypeCode
from eqpAcceptInfo e left join typeCodes t on e.eTypeCode = t.eTypeCode
where t.eTypeName is null
--根据小毕提供的固定资产分类代码表增加数据：
insert typeCodes(eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit)
select flh, flmc, '','','台/套' from fldm
where flh not in (select eTypeCode from typeCodes)

select * from eqpAcceptInfo where eTypeName = ''

update eqpAcceptInfo
set eTypeName = isnull(t.eTypeName,''), aTypeCode = isnull(t.aTypeCode,'')
from eqpAcceptInfo e left join typeCodes t on e.eTypeCode = t.eTypeCode
where e.eTypeName = ''

--这个转换后还需要人工辨认分类名称再修正分类！！

--处理增加的院别名称和使用单位名称字段：
update eqpAcceptInfo
set clgName = clg.clgName,
	uName = u.uName
from eqpAcceptInfo e left join college clg on e.clgCode = clg.clgCode
	left join useUnit u on e.uCode = u.uCode
where isnull(e.uName,'') = '' or isnull(e.clgName,'') = ''

select e.clgCode, e.clgName, e.uCode, e.uName, * 
from eqpAcceptInfo e left join college clg on e.clgCode = clg.clgCode
	left join useUnit u on e.uCode = u.uCode
where isnull(e.uName,'') = '' or isnull(e.clgName,'') = ''

----------------------------------------------------
--处理当天的数据：
insert eqpAcceptInfo(acceptApplyID, acceptApplyStatus, acceptMan, acceptDate, annexName, oprMan, buyDate, 
			clgCode, uCode, eTypeCode, eTypeName, aTypeCode,
			annexAmount, price, sumNumber, eName, eModel, eFormat, notes, 
			fCode, aCode, keeper, totalAmount, sumAmount, startECode, endECode, business,
			accountCode,	--会计科目代码:用户确认;原来老系统的分类编码（财）中放的是会计科目！
			--原数据库验收单中没有的字段，使用设备库中反向设置：
			cCode,factory, makeDate, serialNumber
			)
select ysdh, 2, ysr, ysdate, sjfj, jbr, gzrq, 
			yb, sydw, flbhj, '', '', 
			fjje, dj, sl, isnull(sbmc,''), sbxh, isnull(sbgg,'*'), bz, 
			jfly, syfx, sbbg, sbzj, hjje, LEFT(sbbh,8), substring(sbbh, charIndex('-',sbbh)+1, 8), xsdw,
			flbhc,
			'','',null,''
from ysd
where convert(char(10),ysDate,120) = '2011-10-08' and ysdh <> '0000040262'

select sum(sl)
from ysd
where convert(char(10),ysDate,120) = '2011-10-08' and ysdh <> '0000040262'

--定义验收单的状态：
select * from eqpAcceptInfo
update eqpAcceptInfo
set acceptApplyStatus = 2
where convert(char(10),acceptDate,120) = '2011-10-08'

--这张错误的设备编号的单据退回：
update eqpAcceptInfo
set acceptApplyStatus = 0
where acceptApplyID = '0000040262'

--更新申请日期：
update eqpAcceptInfo
set applyDate = acceptDate

select * from eqpAcceptInfo where acceptApplyStatus = 0 and acceptApplyID <> '0000040262'
select * from epApp
--导入申请单：
	--逐个生成申请单号：
begin tran
	declare @acceptApplyID char(12)
	declare @eTypeCode char(8)			--分类编号（教）
	declare @eTypeName nvarchar(30)	--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
	declare @aTypeCode char(6)			--分类编号（财）
	
	declare @eName nvarchar(30)		--设备名称
	declare @eModel nvarchar(20)		--设备型号
	declare @eFormat nvarchar(20)		--设备规格
	declare @cCode char(3)				--国家代码
	declare @factory nvarchar(20)		--生产厂家
	declare @makeDate smalldatetime		--出厂日期，在界面上拦截
	declare @serialNumber nvarchar(2100)	--出厂编号:采用“1|2|3|..."方式存放,最长支持20字符*100个号码
	declare @buyDate smalldatetime	--购置日期，不允许空值
	declare @business nvarchar(20)	--销售单位
	declare @fCode char(2)	--经费来源代码
	declare @aCode char(2)	--使用方向代码：老数据中有空值，需要用户确认是否允许空值！！！不允许！
	declare @clgCode char(3)	--学院代码
	declare @clgName nvarchar(30)	--学院名称:冗余设计，保存历史数据 add by lw 2010-11-30
	declare @uCode varchar(8)	--使用单位代码：老数据中有空值，需要用户确认是否允许空值！！！不允许,modi by lw 2011-2-11根据设备处要求延长编码长度！
	declare @uName nvarchar(30)	--使用单位名称:冗余设计，保存历史数据 add by lw 2010-11-30
	declare @keeper nvarchar(30)	--保管人
	declare @annexName nvarchar(20)	--附件名称
	declare @annexAmount money	--附件单价

	declare @price money	--单价，>0
	declare @totalAmount money	--总价, >0（单价+附件价格）
	declare @sumNumber int	--数量
	declare @sumAmount money	--合计金额
	declare @oprMan nvarchar(30)	--经办人

	declare @notes nvarchar(50)	--备注
	declare tar cursor for
	select sjfj, jbr, qzrq, 
			yb, sydw, flbhj,
			fjje, sbdj, sbsl, isnull(sbmc,''), sbxh, isnull(sbgg,'*'), bz, 
			jfly, syfx, sbbg, sbzj, hjje, xsdw,
			guobie,sccj,ccrq,ccbh
	from epApp
	OPEN tar
	FETCH NEXT FROM tar INTO @annexName, @oprMan, @buyDate, 
					@clgCode, @uCode, @eTypeCode,
					@annexAmount, @price, @sumNumber, @eName, @eModel, @eFormat, @notes, 
					@fCode, @aCode, @keeper, @totalAmount, @sumAmount, @business,
					@cCode, @factory, @makeDate, @serialNumber
	WHILE @@FETCH_STATUS = 0
	begin
		declare @curNumber varchar(50)
		exec dbo.getClassNumber 1, 1, @curNumber output
		set @acceptApplyID = @curNumber

		select @eTypeName = isnull(eTypeName,''), @aTypeCode = aTypeCode
		from typeCodes
		where eTypeCode = @eTypeCode

		select @clgName = clg.clgName, @uName = u.uName
		from college clg left join useUnit u on clg.clgCode = u.clgCode and u.uCode = @uCode

		insert eqpAcceptInfo(acceptApplyID, applyDate, acceptApplyType, acceptApplyStatus,
					annexName, oprMan, buyDate, 
					clgCode, uCode, eTypeCode, eTypeName, aTypeCode,
					annexAmount, price, sumNumber, eName, eModel, eFormat, notes, 
					fCode, aCode, keeper, totalAmount, sumAmount, business,
					cCode,factory, makeDate, serialNumber
					)
		values(@acceptApplyID, getdate(), 0, 0,
					@annexName, @oprMan, @buyDate, 
					@clgCode, @uCode, @eTypeCode, isnull(@eTypeName,''), isnull(@aTypeCode,''),
					@annexAmount, @price, @sumNumber, @eName, @eModel, @eFormat, @notes, 
					@fCode, @aCode, @keeper, @totalAmount, @sumAmount, @business,
					@cCode,@factory, @makeDate, @serialNumber)
		
		FETCH NEXT FROM tar INTO @annexName, @oprMan, @buyDate, 
						@clgCode, @uCode, @eTypeCode,
						@annexAmount, @price, @sumNumber, @eName, @eModel, @eFormat, @notes, 
						@fCode, @aCode, @keeper, @totalAmount, @sumAmount, @business,
						@cCode, @factory, @makeDate, @serialNumber
	end
	CLOSE tar
	DEALLOCATE tar
commit tran

--六、设备表：
--1.equipmentList（设备表）：
--特殊设备要增加字段，做成派生结构
update equipmentList
set scrapFlag = 0
where scrapFlag =2
select * from equipmentList where eCode='11000054'
--修正设备现状码字段及值含义：wrt by lw 2011-1-26
--scrapFlag int default(0),		--是否报废:0->否，1->是；这是申请报废字段，
									--本字段改成现状码：0-在用，1-待修，2-待报废，3-已申请报废 4-已报废，
									--前2种状态院系设备保管员可以直接修改，状态2由申请报废单设置，状态4由复核设置，状态3预留扩展
update equipmentList
set curEqpStatus = case scrapFlag when 0 then '1' when 1 then '3' when 2 then '4' when 4 then '6' end
alter table equipmentList drop column scrapFlag

select count(*), sum(cast(totalAmount as numeric(18,2))) from equipmentList



--数据转换：
select * from epdbc.dbo.sbmain
--发现部分设备数量不是唯一：
select sbbh, count(*) num 
from epdbc.dbo.sbmain
where sbbh is not null
group by sbbh
having count(*) <> 1

insert equipmentList(eCode, eName, eModel, eFormat, cCode, 
	factory, serialNumber, annexCode, annexAmount, business, 
	eTypeCode, eTypeName, aTypeCode, fCode, aCode,
	makeDate, buyDate, price, totalAmount, 
	clgCode, uCode, keeper, notes, 
	curEqpStatus, acceptDate, oprMan, acceptMan)
select t0.SBBH,isnull(t0.SBMC,''),t0.SBXH,t0.SBGG,isnull(t0.GUOBIE,''),
	t0.SCCJ,t0.CCBH,t0.SJFJ,t0.FJJE,t0.XSDW,
	isnull(t0.FLBHJ,''),'','',t0.JFLY,t0.SYFX,
	t0.CCRQ,t0.GZRQ,t0.SBDJ,t0.SBZJ,
	t0.YB,t0.SYDW,t0.SBBG,t0.BZ,
	t0.SBBF,t0.YSRQ,t0.JBR,t0.YSR
from epdbc.dbo.sbmain t0 inner join 
	(select sbbh, count(*) num 
	from epdbc.dbo.sbmain
	where sbbh is not null
	group by sbbh) as t1 on t0.sbbh = t1.sbbh and t1.num = 1

--暂时保留两个与报废相关的字段：
ALTER TABLE equipmentList ADD [SBBF] [bit] NULL
ALTER TABLE equipmentList ADD [ISDORE] [bit] NULL
update equipmentList
set [SBBF]  = o.[SBBF] ,
	[ISDORE] = o.[ISDORE]
from equipmentList t left join epdbc.dbo.sbmain o on t.eCode = o.sbbh

select * from equipmentList
--删除字段中的多余空格：
update equipmentList set keeper = ltrim(rtrim(keeper))

--老数据中的脏数据：
select t0.*
from epdbc.dbo.sbmain t0
inner join 
	(select sbbh, count(*) num 
	from epdbc.dbo.sbmain
	where sbbh is not null
	group by sbbh) as t1 on t0.sbbh = t1.sbbh and t1.num > 1
order by t0.sbbh

select distinct substring(sbbh,3,1) from epdbc.dbo.sbmain order by substring(sbbh,3,1)
--重复设备编号的将第3位改成“T”
CREATE TABLE [dbo].[sbmain](
	[SBBH] [char](8) NULL,
	[SBMC] [nvarchar](30) NULL,
	[SBXH] [nvarchar](20) NULL,
	[SBGG] [nvarchar](20) NULL,
	[GUOBIE] [char](3) NULL,
	[SCCJ] [nvarchar](20) NULL,
	[CCBH] [nvarchar](15) NULL,
	[SJFJ] [nvarchar](20) NULL,
	[FJJE] [money] NULL,
	[XSDW] [nvarchar](20) NULL,
	[FLBHJ] [char](8) NULL,
	[FLBHC] [char](10) NULL,
	[JFLY] [char](1) NULL,
	[SYFX] [char](1) NULL,
	[CCRQ] [smalldatetime] NULL,
	[GZRQ] [smalldatetime] NULL,
	[SBDJ] [money] NULL,
	[SBZJ] [money] NULL,
	[YB] [char](3) NULL,
	[SYDW] [char](5) NULL,
	[SBBG] [char](8) NULL,
	[BZ] [nvarchar](50) NULL,
	[SBBF] [bit] NOT NULL,
	[ISDORE] [bit] NOT NULL,
	[YSRQ] [smalldatetime] NULL,
	[JBR] [char](8) NULL,
	[YSR] [char](8) NULL
) ON [PRIMARY]
insert sbmain
select t0.*
from epdbc.dbo.sbmain t0
inner join 
	(select sbbh, count(*) num 
	from epdbc.dbo.sbmain
	where sbbh is not null
	group by sbbh) as t1 on t0.sbbh = t1.sbbh and t1.num > 1
order by t0.sbbh

  
insert equipmentList(eCode, eName, eModel, eFormat, cCode, 
	factory, serialNumber, annexCode, annexAmount, business, 
	eTypeCode, eTypeName, aTypeCode, fCode, aCode,
	makeDate, buyDate, price, totalAmount, 
	clgCode, uCode, keeper, notes, 
	curEqpStatus, acceptDate, oprMan, acceptMan)
select t0.SBBH,isnull(t0.SBMC,''),isnull(t0.SBXH,'*'),isnull(t0.SBGG,'*'),isnull(t0.GUOBIE,''),
	t0.SCCJ,t0.CCBH,t0.SJFJ,t0.FJJE,t0.XSDW,
	isnull(t0.FLBHJ,''),'','',t0.JFLY,t0.SYFX,
	t0.CCRQ,t0.GZRQ,t0.SBDJ,t0.SBZJ,
	t0.YB,t0.SYDW,t0.SBBG,t0.BZ,
	t0.SBBF,t0.YSRQ,t0.JBR,t0.YSR
from sbmain t0 inner join 
	(select sbbh, count(*) num 
	from sbmain
	where sbbh is not null
	group by sbbh) as t1 on t0.sbbh = t1.sbbh and t1.num = 1

update equipmentList
set [SBBF]  = o.[SBBF] ,
	[ISDORE] = o.[ISDORE]
from equipmentList t left join sbmain o on t.eCode = o.sbbh
where t.eCode in (select sbbh from sbmain)

delete sbmain 
where sbbh in
	(select sbbh
	from sbmain
	where sbbh is not null
	group by sbbh
	having count(*) = 1)

select * from sbmain
drop table sbmain

select * from equipmentList
where isnull(eTypeName,'') = ''
select * from epdbc.dbo.sbmain

--2010-11-30为了解决多对多的关系增加了分类名称字段，需要处理的数据：
select * from equipmentList e 
where isnull(e.eTypeName,'') = ''

update equipmentList
set eTypeName = isnull(t.eTypeName,''), aTypeCode = isnull(t.aTypeCode,'')
from equipmentList e left join typeCodes t on e.eTypeCode = t.eTypeCode
where isnull(e.eTypeName,'') = ''
--这个转换后还需要人工辨认分类名称再修正分类！！

--处理增加对应的报废单号数据：2011-5-16
select * from equipmentScrap order by scrapNum desc
select * from bEquipmentScrapDetail
select * from sEquipmentScrapDetail

select b.*, c.*
from equipmentList a left join sEquipmentScrapDetail b on a.eCode = b.eCode 
left join equipmentScrap c on b.scrapNum = c.scrapNum
where b.processState = 1 and c.replyState <> 0

update equipmentList
set scrapNum = b.scrapNum
from equipmentList a left join sEquipmentScrapDetail b on a.eCode = b.eCode 
left join equipmentScrap c on b.scrapNum = c.scrapNum
where b.processState = 1 and c.replyState <> 0
	--检查数据：
select * 
from sEquipmentScrapDetail b left join equipmentScrap c on b.scrapNum = c.scrapNum
where processState = 1 and c.applyState = 3
select * from sEquipmentScrapDetail
select * from equipmentList where eCode in (select eCode from sEquipmentScrapDetail)

update equipmentList
set scrapNum = b.scrapNum
from equipmentList a left join bEquipmentScrapDetail b on a.eCode = b.eCode 
left join equipmentScrap c on b.scrapNum = c.scrapNum
where c.replyState = 1
	--检查数据：
select * 
from bEquipmentScrapDetail b left join equipmentScrap c on b.scrapNum = c.scrapNum
where c.applyState = 3
select * from bEquipmentScrapDetail
select * from equipmentList where eCode in (select eCode from bEquipmentScrapDetail)

--查询已经报废的设备：
select * from equipmentList where scrapDate is not null
select * from equipmentList where scrapNum is not null
select * from equipmentList where ISDORE = 1

--设置报废的日期、设备状态：
update equipmentList
set scrapDate = s.scrapDate
from equipmentList e left join equipmentScrap s on e.scrapNum = s.scrapNum
where e.scrapNum is not null and ISDORE = 1

update equipmentList
set curEqpStatus = 1
--已报废设备：
update equipmentList
set curEqpStatus = 6
where ISDORE = 1

update equipmentList
set scrapDate = '2011-06-30'
where curEqpStatus = 6 and scrapNum is null

--待报废设备：
update equipmentList
set curEqpStatus = 1
where SBBF =  1 and ISDORE = 0

update equipmentList
set curEqpStatus = 4
where SBBF =  1 and ISDORE =0
	and eCode in (select isnull(m.eCode,'') 
					from equipmentScrap s left join sEquipmentScrapDetail m on s.scrapNum = m.scrapNum
					where s.applyState = 0 and replyState = 0
					union all
					select m.eCode 
					from equipmentScrap s left join bEquipmentScrapDetail m on s.scrapNum = m.scrapNum
					where s.applyState = 0 and replyState = 0)
--输出待报废设备，让各院部重新提交报废申请单：
select c.clgName, u.uName, e.* from equipmentList e left join college c on e.clgCode = c.clgCode
left join useUnit u on u.clgCode = e.clgCode and u.uCode = e.uCode
where SBBF =  1 and ISDORE = 0
and cast(eCode as varchar(8)) not in (select cast(isnull(m.eCode,'') as varchar(8)) eCode
					from equipmentScrap s left join sEquipmentScrapDetail m on s.scrapNum = m.scrapNum
					where s.applyState = 0 and replyState = 0
					union all
					select cast(isnull(m.eCode,'') as varchar(8))
					from equipmentScrap s left join bEquipmentScrapDetail m on s.scrapNum = m.scrapNum
					where s.applyState = 0 and replyState = 0)

--由于设备重号修改了设备编号，导致有些报废单中的设备不再对应到相应的设备中，请复查以下单据：
select * from sEquipmentScrapDetail 
where cast(eCode as varchar(8)) not in (select cast(eCode as varchar(8)) from equipmentList)

select s.scrapNum, s.clgName, s.uName, m.eCode, m.eName
from equipmentScrap s right join sEquipmentScrapDetail m on s.scrapNum = m.scrapNum
where s.applyState = 0 and s.replyState = 0 
	and cast(m.eCode as varchar(8)) not in (select cast(eCode as varchar(8)) from equipmentList)
order by s.clgCode, s.uCode
	
select * from bEquipmentScrapDetail
where cast(eCode as varchar(8)) not in (select cast(eCode as varchar(8)) from equipmentList)

select s.scrapNum, s.clgName, s.uName, m.eCode, m.eName
from equipmentScrap s right join bEquipmentScrapDetail m on s.scrapNum = m.scrapNum
where s.applyState = 0 and replyState = 0
	and cast(m.eCode as varchar(8)) not in (select cast(eCode as varchar(8)) from equipmentList)
order by s.clgCode, s.uCode
--没有发现该类数据！！！


select * from equipmentList where curEqpStatus = 4
ALTER TABLE equipmentList ADD [SBBF] [bit] NULL
ALTER TABLE equipmentList ADD [ISDORE] [bit] NULL


--设置对应的验收单号：
select * from equipmentList
select * from eqpAcceptInfo

drop TABLE eqpTmp
CREATE TABLE eqpTmp(
	eCode char(8) not null,			--主键：设备编号,使用特殊的号码发生器产生
											--2位年份代码+6位流水号，号码预先生成
											--使用手工输入号码，自动检测号码是否重号
	acceptApplyID char(12) null,	--对应的验收单号
	eName nvarchar(30) not null,	--设备名称:需要用户确认是否允许空值！！！不允许！！
	eModel nvarchar(20) not null,	--设备型号
	eFormat nvarchar(30) not null,	--设备规格：根据教育部要求延长字段长度为20位 modi by lw 2011-1-26
	cCode char(3) not null,			--国家代码：需要用户确认是否允许空值！！！不允许！！
	factory	nvarchar(20) null,		--生产厂家
	makeDate smalldatetime null,	--出厂日期，在界面上拦截
	serialNumber nvarchar(20) null,	--出厂编号
	business nvarchar(20) null,		--销售单位
	buyDate smalldatetime null,		--购置日期，不允许空值
	annexName nvarchar(20) null,	--附件名称	add by lw 2010-12-4与验收单一致化
	annexCode nvarchar(20) null,	--随机附件编号
	annexAmount	money null,			--附件金额（就是附件单价）

	eTypeCode char(8) not null,		--分类编号（教）最后4位不允许同时为“0”
	eTypeName nvarchar(30) not null,--教育部分类名称:为了解决多对多的问题需要增加的字段，add by lw 2010-11-30
	aTypeCode char(6) not null,		--分类编号（财）分类编号（财）=f（分类编号（数））使用映射表

	fCode char(2) not null,			--经费来源代码
	aCode char(2) null,				--使用方向代码：老数据中有空值，需要用户确认是否允许空值！！！不允许！
	price money null,				--单价，>0
	totalAmount money null,			--总价, >0（单价+附件价格）
	clgCode char(3) not null,		--学院代码
	uCode varchar(8) null,			--使用单位代码：老数据中有空值，需要用户确认是否允许空值！！！不允许.modi by lw 2011-2-11根据设备处要求延长编码长度！
	keeper nvarchar(30) null,		--保管人
	notes nvarchar(50) null,		--备注
	acceptDate smalldatetime null,	--验收日期
	oprMan nvarchar(30) null,		--经办人
	acceptManID varchar(10) null,	--验收人工号,add by lw 2011-2-19
	acceptMan nvarchar(30) null,	--验收人
	--计划废止：
	--scrapFlag int default(0),		--是否报废:0->否，1->是；这是申请报废字段，
									--本字段改成现状码：0-在用，1-待修，2-待报废，3-已申请报废 4-已报废，
									--前2种状态院系设备保管员可以直接修改，状态2由申请报废单设置，状态4由复核设置，状态3预留扩展
	curEqpStatus char(1) not null,	--根据报表的规定重新定义设备的现状代码含义：本字段由第2号代码字典定义 modi by lw 2011-1-26
									--1：在用，指正在使用的仪器设备；
									--2：多余，指具有使用价值而未使用的仪器设备；
									--3：待修，指待修或正在修理的仪器设备；
									--4：待报废：指已经失去使用价值，而未履行正式报废手续的仪器设备；
									--5：丢失，
									--6：报废，
									--7：调出，
									--8：降档，指金学校批准允许降档次使用、管理的仪器设备；
									--9：其他，现状不详的仪器设备。
	scrapDate smalldatetime null,	--报废日期，原[ISDORE] [bit] NOT NULL,是已经确认报废，现改为使用报废日期
	--add by lw 2011-05-16,因为筛选中的条件构造比较麻烦，所以增加该字段
	--注意：相应修改了报废的存储过程，在处理原始数据的时候需要处理
	scrapNum char(12) null,		--对应的设备报废单号

	--最新维护情况:
	modiManID varchar(10) null,			--维护人工号
	modiManName nvarchar(30) null,		--维护人姓名
	modiTime smalldatetime null,		--最后维护时间

	--编辑锁定人：
	lockManID varchar(10),				--当前正在锁定编辑的人工号
	[SBBF] [bit] NULL,
	[ISDORE] [bit] NULL
) ON [PRIMARY]
go

insert eqpTmp
select * from equipmentList

delete eqpTmp
where substring(eCode,6,1) not in ('0','1','2','3','4','5','6','7','8','9')
	or substring(eCode,7,1) not in ('0','1','2','3','4','5','6','7','8','9')
	or substring(eCode,8,1) not in ('0','1','2','3','4','5','6','7','8','9')

select * from equipmentList where acceptApplyID is null

update equipmentList
set acceptApplyID = tab.acceptApplyID
from equipmentList e left join 
		(select a.acceptApplyID, a.startECode, a.endECode, e.eCode, e.eName 
		 from eqpAcceptInfo a left join eqpTmp e 
			on (e.eCode = a.startECode and endECode = '')
				or (left(a.startECode,5) = left(e.eCode,5) and 
					cast(substring(a.startECode,6,3) as bigint) <= cast(substring(e.eCode,6,3) as bigint) and
					cast(substring(a.endECode,6,3) as bigint) >= cast(substring(e.eCode,6,3) as bigint)
				)
		) as tab on e.eCode = tab.eCode
where isnull(e.acceptApplyID,'') = ''

select * from equipmentList

select * from sbmain


--分类代码表中没有的代码：
select eTypeCode, * from equipmentList where eTypeCode not in (select eTypeCode from typeCodes)
--------------------------------------------------------------------
--处理当天的数据：
select * from equipmentList where acceptApplyID = '0000038977'
select * from equipmentList
where eCode in (select sbbh from sbmain 
				where convert(char(10),ysrq,120) = convert(char(10),getdate(),120))
select * from ysd 
where ysdh = '0000038977'
select * from eqpAcceptInfo where acceptApplyID = '0000038977'

		
where convert(char(10),acceptDate,120) = convert(char(10),getdate(),120)

select * from ysd 
where convert(char(10),ysdate,120) = convert(char(10),getdate(),120)

--发现今天又一个验收单生成的设备编号重号：验收单号：0000040262 设备编号：11009195-11009196
--与0000038977号单重号！！！
insert equipmentList(eCode, eName, eModel, eFormat, cCode, 
	factory, serialNumber, annexCode, annexAmount, business, 
	eTypeCode, eTypeName, aTypeCode, fCode, aCode,
	makeDate, buyDate, price, totalAmount, 
	clgCode, uCode, keeper, notes, 
	curEqpStatus, acceptDate, oprMan, acceptMan,
	SBBF,ISDORE)
select t0.SBBH,isnull(t0.SBMC,''),isnull(t0.SBXH,'*'),isnull(t0.SBGG,'*'),isnull(t0.GUOBIE,''),
	t0.SCCJ,t0.CCBH,t0.SJFJ,t0.FJJE,t0.XSDW,
	isnull(t0.FLBHJ,''),'','',t0.JFLY,t0.SYFX,
	t0.CCRQ,t0.GZRQ,t0.SBDJ,t0.SBZJ,
	t0.YB,t0.SYDW,t0.SBBG,t0.BZ,
	t0.SBBF,t0.YSRQ,t0.JBR,t0.YSR,
	SBBF,ISDORE
from sbmain t0 
where convert(char(10),ysrq,120) = convert(char(10),getdate(),120)
	and sbbh not in (select eCode from equipmentList)

select * from equipmentList where convert(char(10),acceptDate,120) = '2011-10-08'

--设置设备状态：
update equipmentList
set curEqpStatus = 1
where convert(char(10),acceptDate,120) = '2011-10-08'

--设置对应的验收单号：
insert eqpTmp
select * from equipmentList
where convert(char(10),acceptDate,120) = '2011-10-08'

select * from eqpTmp
update equipmentList
set acceptApplyID = tab.acceptApplyID
from equipmentList e left join 
		(select a.acceptApplyID, a.startECode, a.endECode, e.eCode, e.eName 
		 from eqpAcceptInfo a left join eqpTmp e 
			on (e.eCode = a.startECode and endECode = '')
				or (left(a.startECode,5) = left(e.eCode,5) and 
					cast(substring(a.startECode,6,3) as bigint) <= cast(substring(e.eCode,6,3) as bigint) and
					cast(substring(a.endECode,6,3) as bigint) >= cast(substring(e.eCode,6,3) as bigint)
				)
		) as tab on e.eCode = tab.eCode
where isnull(acceptApplyID,'') = ''


--毕处提出原来的验收单中使用单位和院部没有级联，需要使用单位名称重新生成单位号码：select clgCode, uCode, * 
from equipmentList 
where clgCode <> left(uCode,3)
	and isnull(uCode,'') <> ''
update equipmentList
set uCode =

update equipmentList 
set uCode = u2.uCode
from equipmentList e left join useUnit u on e.uCode = u.uCode 
	left join useUnit u2 on e.clgCode = u2.clgCode and u.uName = u2.uName
where e.clgCode <> left(e.uCode,3)
	and isnull(e.uCode,'') <> ''


select clgCode, clgName, uCode, uName, * 
from eqpAcceptInfo 
where clgCode <> left(uCode,3)
	and isnull(uCode,'') <> ''
select * from college where clgCode = '153'

update eqpAcceptInfo 
set clgName = c.clgName, uCode = u2.uCode, uName = u2.uName
from eqpAcceptInfo e left join useUnit u on e.uCode = u.uCode 
	left join college c on e.clgCode = c.clgCode
	left join useUnit u2 on e.clgCode = u2.clgCode and u.uName = u2.uName
where e.clgCode <> left(e.uCode,3)
	and isnull(e.uCode,'') <> ''


select oldClgCode, oldClgName, oldUCode, oldUName, * 
from equipmentAllocation 
where oldClgCode <> left(oldUCode,3)
	and isnull(oldUCode,'') <> ''

update equipmentAllocation 
set oldClgName = c.clgName, oldUCode = u2.uCode, oldUName = u2.uName
from equipmentAllocation e left join useUnit u on e.oldUCode = u.uCode 
	left join college c on e.oldClgCode = c.clgCode
	left join useUnit u2 on e.oldClgCode = u2.clgCode and u.uName = u2.uName
where e.oldClgCode <> left(e.oldUCode,3)
	and isnull(e.oldUCode,'') <> ''

select newClgCode, newClgName, newUCode, newUName, * 
from equipmentAllocation 
where newClgCode <> left(newUCode,3)
	and isnull(newUCode,'') <> ''

update equipmentAllocation 
set newClgName = c.clgName, newUCode = u2.uCode, newUName = u2.uName
from equipmentAllocation e left join useUnit u on e.newUCode = u.uCode 
	left join college c on e.newClgCode = c.clgCode
	left join useUnit u2 on e.newClgCode = u2.clgCode and u.uName = u2.uName
where e.newClgCode <> left(e.newUCode,3)
	and isnull(e.newUCode,'') <> ''

--报废单中因为没有填写使用单位所以不存在该问题：
select clgCode, clgName, uCode, uName, * 
from equipmentScrap
where clgCode <> left(uCode,3)
	and isnull(uCode,'') <> ''

select clgCode, clgName, uCode, uName, * 
from equipmentScrap
where isnull(uName,'') = ''

select * from college where clgCode = '153'

--2.equipmentAnnex（设备附件）：需要用户确认设备附件是否可以与设备分开购置！！！
--数据转换：
select * from epdbc.dbo.sbfj
select * from equipmentAnnex
insert equipmentAnnex(eCode, buyDate, annexName, annexFormat,
	quantity, price, totalAmount, oprMan, business,
	fCode )
select f.sbbh, f.gzrq, f.fjmc, f.xhgg, f.sl, f.dj, f.zj, f.jbr, f.xsdw, e.JFLY
from epdbc.dbo.sbfj f left join epdbc.dbo.sbmain e on f.sbbh = e.sbbh
where f.sbbh in (select eCode from equipmentList)

--发现一个设备附件没有对应的主设备：
select f.sbbh, f.gzrq, f.fjmc, f.xhgg, f.sl, f.dj, f.zj, f.jbr, f.xsdw, e.JFLY
from epdbc.dbo.sbfj f left join epdbc.dbo.sbmain e on f.sbbh = e.sbbh
where cast(f.sbbh as varchar(8)) not in (select eCode from equipmentList)

select * from equipmentList where eCode in ('08006794','08T06794','08TT6794')


--七、设备报废单：
--1.设备报废单：
--转换数据：
--原系统sbbfd设备报废主表
select * from epdbc.dbo.sbbfd
where bgdw not in(select clgName from college)
select * from equipmentScrap

insert equipmentScrap(scrapNum, applyState, replyState, 
		clgCode, clgName, clgManager, applyMan, eManager, scrapDesc, scrapDate,
		processMan, processDesc, isBigEquipment, totalNum, totalMoney, notes, applyDate, tel,
		uCode,uName)

select bfdh, case rtrim(state) when '等待审核' then 0 else 1 end [applyState], case rtrim(state) when '等待审核' then 0 
																		when '全部同意' then 1
																		when '部分同意' then 2
																		when '全部不同意' then 3 
																		when '不同意' then 3 
																		else 4 end [replyState],
		c.clgCode, bgdw, ybfzr, bgr, glfzr, czjg, czsj,
		jbr, state, bigsb, zsl, zje, bz, sqdate, tel,
		'',''
from epdbc.dbo.sbbfd s join college c on s.bgdw = c.clgName

--将原状态修正：
update equipmentScrap
set applyState = 3
where replyState <> 0

--2.小型设备报废明细单:

select * from sEquipmentScrapDetail
select * from epdbc.dbo.xbfmxd
select distinct bfdh from epdbc.dbo.sbbfd
--转换数据：
--xbfmxd 小型设备报废明细单
insert sEquipmentScrapDetail(scrapNum, eCode, totalAmount, leaveMoney, 
		scrapDesc, identifyDesc, processState,
		eName, eModel, eFormat, buyDate, eTypeCode, eTypeName)
select s.bfdh, sbbh, isnull(sbzj,0), isnull(sbcz,0), 
		bfyy, jsjdyj, case mx.state when '同意' then 1 else 0 end,
		eName, eModel, eFormat, buyDate, eTypeCode, eTypeName
from epdbc.dbo.xbfmxd mx inner join epdbc.dbo.sbbfd s on mx.bfmxd = s.bfmxd
	left join equipmentList e on mx.sbbh = e.eCode
where s.bfdh in (select scrapNum from equipmentScrap)
and eName is not null
order by mx.bfmxd

--3.大型设备报废明细表:
select * from epdbc.dbo.dbfmxd
--转换数据：
--dbfmxd 大型设备报废明细表
insert bEquipmentScrapDetail(scrapNum, eCode, applyDesc, clgDesc, identifyDesc, 
		tManager, gzwDesc, notificationNum,
		eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount)
select s.bfdh, sbbh, bfyy, ybyj, jdyj, 
		jdr, sbcyj, gzwyj,
		eName, eModel, eFormat, buyDate, eTypeCode, eTypeName, totalAmount
from epdbc.dbo.dbfmxd mx left join epdbc.dbo.sbbfd s on mx.bfmxd = s.bfmxd
	left join equipmentList e on mx.sbbh = e.eCode
where s.bfdh in (select scrapNum from equipmentScrap)
order by  mx.bfmxd
--注意：gzwDesc里填写的是原明细单中的sbcyj

select s.bfdh, mx.bfmxd, e.scrapDesc, mx.sbcyj, mx.*
from epdbc.dbo.dbfmxd mx left join epdbc.dbo.sbbfd s on mx.bfmxd = s.bfmxd
	left join equipmentScrap e on e.scrapNum = s.bfdh

select * from epdbc.dbo.dbfmxd mx
select * from bEquipmentScrapDetail

--八、设备调拨单
--1.设备调拨单：
--原设备调拨单字段一览：
select * from epdbc.dbo.sbdb
xh		序号
sbbh	调拨单号
dbyy	调拨原因
ydwfzr	原单位负责人
yyb		原院别
ydw		原使用单位
ybg		原保管
xdwfzr	新单位负责人
xyb		新院别
xdw		新使用单位
xbg		新保管
jsyj	接受意见
jsfzr	接受负责人
glfzr	设备处管理负责人

--转换数据：
insert equipmentAllocation(alcNum, alcStatus, alcDate, oldClgCode, oldClgName, oldClgManager, oldUCode, oldUName, oldKeeper,
	newClgCode, newClgName, newClgManager, newUCode, newUName, newKeeper,
	alcReason, totalNum, totalMoney,
	acceptComments, acceptMan, eManagerID, eManager)
select e.xh, 2, getdate(), c.clgCode, c.clgName, c.manager, u.uCode, u.uName, e.ybg, 
	c2.clgCode, c2.clgName, c2.manager, u2.uCode, u2.uName, e.xbg,
	e.dbyy, 1, eqp.totalAmount,
	e.jsyj, e.jsfzr, '', e.glfzr
from epdbc.dbo.sbdb e left join college c on e.yyb = c.clgCode
		left join useUnit u on e.ydw = u.uCode
		left join college c2 on e.xyb = c2.clgCode
		left join useUnit u2 on e.xdw = u2.uCode
		left join equipmentList eqp on e.sbbh = eqp.eCode
where u.uCode is not null and u2.uCode is not null and c.clgCode is not null and c2.clgCode is not null

insert equipmentAllocationDetail(alcNum, eCode, eName, totalAmount)
select e.xh, e.sbbh, eqp.eName, eqp.totalAmount
from epdbc.dbo.sbdb e left join equipmentList eqp on e.sbbh = eqp.eCode
where e.xh in (select alcNum from equipmentAllocation) and eqp.eCode is not null

select * from equipmentAllocation
select * from epdbc.dbo.sbdb
select * from equipmentAllocationDetail
--调拨单中有问题的数据：
select *
from epdbc.dbo.sbdb e left join college c on e.yyb = c.clgCode
		left join useUnit u on e.ydw = u.uCode
		left join college c2 on e.xyb = c2.clgCode
		left join useUnit u2 on e.xdw = u2.uCode
		left join equipmentList eqp on e.sbbh = eqp.eCode
where u.uCode is null or u2.uCode is null or c.clgCode is null or c2.clgCode is null


