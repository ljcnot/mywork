use epdc2
/*
	����豸������Ϣϵͳ-���ݿ��ʼ������������
	����ƺ�ƽʱ���������м��й����Ĵ���,2011��10��7����ʽ�л����ݿ�
	author:		¬έ
	CreateDate:	2011-10-7
	UpdateDate: 
*/

--һ�������ֵ�����ݣ�
--1��ϵͳ���������
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 1, 'ϵͳ����', '', '')
insert codeDictionary(classCode, objCode, objDesc)	--ϵͳʹ�õ�λ����
values(1, 1, '10486')
insert codeDictionary(classCode, objCode, objDesc)	--ϵͳʹ�õ�λ����
values(1, 2, '�人��ѧ')

--2���豸��״�룺
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 2, '�豸��״��', '�ߵ�ѧУ�����豸���������Ϣ��', '')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 1, '����', 1, '1')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 2, '����', 1, '2')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 3, '����', 1, '3')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 4, '������', 1, '4')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 5, '��ʧ', 1, '5')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 6, '����', 1, '6')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 7, '����', 1, '7')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 8, '����', 1, '8')
insert codeDictionary(classCode, objCode, objDesc, GBDigiCode, GBEngCode)
values(2, 9, '����', 1, '9')

--10��ʹ�õ�λ���ͣ�
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 10, 'ʹ�õ�λ����', '�Զ���')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 1, '��ѧ')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 2, '����')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 3, '����')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 4, '����')
insert codeDictionary(classCode, objCode, objDesc)
values(10, 9, '����')

--99.ϵͳ���ݶ����������
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 99, 'ϵͳ���ݶ����������', '�Զ���')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 1, '��ѯ�����')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 2, '�༭�����')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 3, '���������')
insert codeDictionary(classCode, objCode, objDesc)
values(99, 4, '��������')

--100����ɫ�ּ����ͣ�
insert codeDictionary(classCode, objCode, objDesc, standardName) 
values ( 0, 100, '��ɫ�ּ�����', '�Զ���')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 1, 'ͨ�õ�У����ɫ')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 2, 'ͨ�õ�Ժ������ɫ')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 3, 'ͨ�õĵ�λ��ɫ')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 4, '�������ض�Ժ���Ľ�ɫ')
insert codeDictionary(classCode, objCode, objDesc)
values(100, 5, '�������ض���λ�Ľ�ɫ')

--900����������������
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 900, '��������������', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(900, 901, '��ѧ���������豸��')
insert codeDictionary(classCode, objCode, objDesc)
values(900, 902, '��ѧ���������豸�����䶯�����')
insert codeDictionary(classCode, objCode, objDesc)
values(900, 903, '���������豸��')

--901����������������
insert codeDictionary(classCode, objCode, objDesc, standardName, GBDigiCode) 
values ( 0, 901, '��������������', '', '')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 101, '����')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 102, '���ݹ�����')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 103, 'ͨ���豸')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 104, 'ר���豸')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 105, '��ͨ�����豸')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 106, '�����豸')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 107, '���Ӳ�Ʒ��ͨ���豸')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 108, '�����Ǳ�����')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 109, '���������豸')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 110, 'ͼ�����Ｐ����Ʒ')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 111, '�Ҿ��þ߼�������')
insert codeDictionary(classCode, objCode, objDesc)
values(901, 112, '�����ʲ�')

update codeDictionary
set inputCode = upper(dbo.getChinaPYCode(objDesc))

--�������������ݣ�

--1.�豸�����������������Ͳ�������������׼
select * from typeCodes 
order by eTypeCode
where eTypeCode is null or ltrim(rtrim(eTypeCode )) = ''

drop table typeCodes
--�������ݿ⣺
truncate table typeCodes
insert typeCodes(eTypeCode, eTypeName, aTypeCode, aTypeName,typeUnit, inputCode,cInputCode)
select eTypeCode, eTypeName, aTypeCode, aTypeName,typeUnit, inputCode,cInputCode from typeCodes2

select eTypeCode, eTypeName, aTypeCode, aTypeName,typeUnit, inputCode,cInputCode from typeCodes
--2011-10-8����С���ṩ�Ĺ̶��ʲ����������������ݣ�
insert typeCodes(eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit)
select flh, flmc, '','','̨/��' from fldm
where flh not in (select eTypeCode from typeCodes)



--���ɱ���Ŀ���������
update typeCodes
set eTypeCode4 = left(eTypeCode,4),
	eTypeCode5 = left(eTypeCode,5),
	eTypeCode6 = left(eTypeCode,6),
	eTypeCode7 = left(eTypeCode,7)

--����ȫ�ظ��Ĵ���43����

CREATE TABLE #t(
	eTypeCode char(8) not null,		--�����ţ��̣�
	eTypeName nvarchar(30) not null,--��������������
	aTypeCode char(8) not null,		--�����ţ���������
	aTypeName nvarchar(30) not null,--��������������
	typeUnit nvarchar(10) not null,	--������λ
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

--������ת����
select * from t where len(������) > 5
update t
set ������= rtrim(ltrim(upper(������))),
	��������= rtrim(ltrim(upper(��������)))

select substring(������,0,4) + right(������,1), * from t
where len(������) > 5

update t
set ������= substring(������,0,4) + right(������,1)
where len(������) > 5

update t
set ��������= substring(��������,0,4) + right(��������,1)
where len(��������) > 5

update typeCodes
set inputCode = t.������, cInputCode = t.��������
from typeCodes c left join t on c.eTypeCode = t.flh and c.eTypeName = t.mc

--���ݱϴ�ָ����������루�̣��е�β��Ϊ��0���ı����޳�����û���˶�Զ�Ĺ�ϵ�����������ʱ��Ҫ��飡
select * from typeCodes 
where right(eTypeCode,1) = '0'
order by eTypeCode

select * from typeCodes 
where right(eTypeCode,1) <> '0'
order by eTypeCode

select * from typeCodes 
order by eTypeCode
--�޳����ӷ���ı������Ȼ���ڶ�Զ�Ĺ�ϵ��
select * from typeCodes 
where eTypeCode in 
(select eTypeCode
from typeCodes 
group by eTypeCode
having count(eTypeCode) > 1)
order by eTypeCode
--����취���ǽ���������Ҳ��ŵ��豸���У������ϵ�������������ֻ�ܿ��˹�����ˣ�

--�ָ����ݣ�
use epdc2
truncate table typeCodes
insert typeCodes(eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, cInputCode, isOff, offDate)
select eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit, inputCode, 
	cInputCode, isOff, offDate 
from dbo.typeCodes2
order by eTypeCode

--�Զ�����ƴ�����룺
select eTypeName, dbo.getChinaPYCode(eTypeName), inputCode from typeCodes
update typeCodes
set inputCode = upper(dbo.getChinaPYCode(eTypeName))
where inputCode is null

update typeCodes
set cInputCode = upper(dbo.getChinaPYCode(aTypeName))
where cInputCode is null

--2.����country����
select rowNum,cCode,cName,enName,fullName,inputCode,case isOff when '0' then '��' else '' end isOff, 
case isOff when '0' then '' else convert(char(10), offDate, 120) end offDate, 
modiManID,modiManName,modiTime,lockManID
from country
order by cCode

select * from country where cCode not in (select dm from epdbc.dbo.gb)
select * from epdbc.dbo.gb
--�������ݣ�
truncate table country
insert country(cCode, cName, enName, fullName,inputCode)
select cCode, cName, enName, fullName,inputCode from country2

select * from country
where cCode is null or ltrim(rtrim(cCode)) = ''

--ת�����ݣ�
insert country(cCode, cName)
select dm, mc from epdbc.dbo.gb

select cCode, cName, enName, inputCode from country order by inputCode
update country
set cName = LTRIM(rtrim(cName))

--�������������Ӣ��ȫ�ƣ�
select * from t
select * from country
select c.*, t.* from country c left join t on c.cCode = t.���������ִ���

update country
set inputCode = t.������,
	fullName = t.���ĺ�Ӣ��ȫ��
from country c left join t on c.cCode = t.���������ִ���

--�ָ����ݣ�
truncate table country
insert country(cCode, cName, enName, fullName, inputCode, isOff, offDate)
select cCode, cName, enName, fullName, inputCode, isOff, offDate from country2
	
--�Զ�����ƴ�����룺
select cName, dbo.getChinaPYCode(cName), inputCode from country
update country
set inputCode = upper(dbo.getChinaPYCode(cName))
where inputCode is null


--3.fundSrc��������Դ����
select * from fundSrc
select * from fundSrc2
where fCode is null or ltrim(rtrim(fCode)) = ''

drop table fundSrc
--�������ݿ⣺
truncate table fundSrc
insert fundSrc(fCode,fName,inputCode)
select fCode,fName,inputCode from fundSrc2
--�ָ����ݣ�
truncate table fundSrc
insert fundSrc(fCode,fName,inputCode)
select fCode,fName,inputCode from fundSrc2

select fCode,fName,inputCode from fundSrc
--�Զ�����ƴ�����룺
select fName, dbo.getChinaPYCode(fName), inputCode from fundSrc
update fundSrc
set inputCode = upper(dbo.getChinaPYCode(fName))
where inputCode is null

--ת�����ݣ�
insert fundSrc(fCode, fName)
select dm, mc from epdbc.dbo.jfly

update fundSrc
set fName = LTRIM(rtrim(fName))

--4.appDir��ʹ�÷��򣩣�
select * from appDir
where aCode is null or ltrim(rtrim(aCode))=''

select len(aName), * from appDir
drop table appDir
--�������ݿ⣺
insert appDir2(aCode, aName, inputCode)
select aCode, aName, inputCode from appDir
--�ָ����ݣ�
truncate table appDir
insert appDir(aCode, aName, inputCode)
select aCode, aName, inputCode from appDir2
--�Զ�����ƴ�����룺
select aName, dbo.getChinaPYCode(aName), inputCode from appDir
update appDir
set inputCode = upper(dbo.getChinaPYCode(aName))
where inputCode is null



--ת�����ݣ�
insert appDir(aCode, aName)
select dm, mc from epdbc.dbo.syfx

select * from appDir
update appDir
set aName = LTRIM(rtrim(aName))


--5.college��Ժ������
--ָѧԺ��ϵ�����о�����ʵ�����ļ�������λ
select * from college
where clgCode is null or ltrim(rtrim(clgCode))=''

drop table college
--�������ݿ⣺
insert college2(clgCode,clgName,manager,inputCode)
select clgCode,clgName,manager,inputCode from college
--�ָ����ݣ�
truncate table college
insert college(clgCode,clgName,manager,inputCode)
select clgCode,clgName,manager,inputCode from college2

--ת�����ݣ�
insert college(clgCode, clgName, manager)
select dm, mc, ybfzr from epdbc.dbo.yb
where dm not in (select clgCode from college)

--�Զ�����ƴ�����룺
select clgName, dbo.getChinaPYCode(clgName), inputCode from college
update college
set inputCode = upper(dbo.getChinaPYCode(clgName))
where inputCode is null

--��Ҫȷ��ԭ���ݿ��еġ�px���ֶεĺ���:���õ�λ�ı�ʶ�����ĳ��ۼƴ���

--ȷ�����ݣ�
select * from college c right join epdbc.dbo.yb y on c.clgCode = y.dm and c.clgName = y.mc

--���������룺
select * from t
select * from college
select * from t where len(������) > 5
update t
set ������= rtrim(ltrim(upper(������)))

update college
set inputCode = t.������
from college c left join t on c.clgCode = t.����

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

--6.useUnit��ʹ�õ�λ����
select * from useUnit
where uCode is null or ltrim(rtrim(uCode))=''

select len(uName),* from useUnit
drop table useUnit
--�������ݿ⣺
insert useUnit2(uCode,uName,manager,clgCode,inputCode)
select uCode,uName,manager,clgCode,inputCode from useUnit
--�ָ����ݣ�
truncate table useUnit
insert useUnit(uCode,uName,manager,clgCode,inputCode)
select uCode,uName,manager,clgCode,inputCode from useUnit2
select * from useUnit

--ת�����ݣ�
insert useUnit(uCode, uName, manager, clgCode)
select dm, mc, fzr, yb from epdbc.dbo.sydw
where yb in (select dm from epdbc.dbo.yb)
and dm not in (select uCode from useUnit)

--�Զ�����ƴ�����룺
select uName, dbo.getChinaPYCode(uName), inputCode from useUnit
update useUnit
set inputCode = upper(dbo.getChinaPYCode(uName))
where inputCode is null

--��Ҫȷ�ϵ��쳣���ݴ���
select * from epdbc.dbo.sydw where yb not in (select dm from epdbc.dbo.yb)

--ȷ�����ݣ�
select * from useUnit u left join epdbc.dbo.sydw d on u.uCode = d.dm and u.uName = d.mc

select e.eCode, e.eName, e.eModel, e.eFormat, e.cCode, c.cName
from equipmentList e left join country c on e.cCode = c.cCode
--���������룺
select * from tt
select * from useUnit
select * from tt where len(������) > 5
update tt
set ������= rtrim(ltrim(upper(������)))

update tt
set ������= substring(������,0,4) + right(������,1)
where len(������) > 5

update useUnit
set inputCode = tt.������
from useUnit u left join tt on u.ucode = tt.����

--7.��ƿ�Ŀ�����ֵ��
select * from accountTitle
where accountCode is null or ltrim(rtrim(accountCode)) = ''

drop table accountTitle
--�������ݿ⣺
insert accountTitle2(accountCode, accountName, accountEName, accountTypeCode, accountTypeName, accountTypeEName, inputCode)
select accountCode, accountName, accountEName, accountTypeCode, accountTypeName, accountTypeEName, inputCode from accountTitle
--�ָ����ݣ�
truncate table accountTitle
insert accountTitle(accountCode, accountName, accountEName, accountTypeCode, accountTypeName, accountTypeEName, inputCode)
select accountCode, accountName, accountEName, accountTypeCode, accountTypeName, accountTypeEName, inputCode from accountTitle2
--�Զ�����ƴ�����룺
select accountName, dbo.getChinaPYCode(accountName), inputCode from accountTitle
update accountTitle
set inputCode = upper(dbo.getChinaPYCode(accountName))
where inputCode is null

select * from accountTitle
update accountTitle
set accountName = ltrim(rtrim(accountName))

--װ�����ݣ�
insert accountTitle(accountCode, accountName, accountEName, accountTypeCode,
	accountTypeName, accountTypeEName, inputCode)
select ��Ŀ����, ��Ŀ����, Ӣ������, ������, ���, ���Ӣ����, ������ from t

select * from t where len(������) > 5
select * from t where len(��Ŀ����) > 6
select * from t where len(��Ŀ����) > 30
select *, len(Ӣ������) from t where len(Ӣ������) > 50

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


--����ƴ���룺
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


--����Ȩ�ޱ�
--1.0Ȩ�ޱ�
select * from sysRight
--�������ݣ�2011-10-2
update sysRight
set Url = 'systemTools/sysAdvTools.html'
where rightName = 'ϵͳ�߼�����'

update sysRight
set Url = 'userInfo/sysResources.html'
where rightName = '����ϵͳ'

insert sysRight(rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse, rightDesc)
values('����༭��','clearAllLock','','F',7,7,3,'Y','�ù��ܽ���������û��ı༭����ͬʱ������������û���')

--����ϵͳ��Դ��add by lw 2011-11-20
SELECT * FROM sysRight
insert sysRight(rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, 
				canUse, canQuery4Global, canQuery4Local, canQuery4UnitLocal, 
				canEdit4Global, canEdit4Local, canEdit4UnitLocal, 
				canOutput4Global, canOutput4Local, canOutput4UnitLocal,
				canCheck4Global, canCheck4Local, canCheck4UnitLocal,
				rightDesc)
values('�̵��','eqpCheckInfoList','eqpManager/eqpCheckInfoList.html','D',3,6,0,
				'Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','Y','���Բ�ѯ��ɾ���������̵�����Ƶ�Ȩ����')

insert sysRight(rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, 
				canUse, canQuery4Global, canEdit4Global, canOutput4Global,
						canCheck4Global, rightDesc)
values('ʹ�õ�λ����ӳ���','useUnitCodeMap','reportCenter/useUnitCodeMap.html','D',6,3,0,'Y','Y','Y','Y','Y',
	'����ʹ�õ�λӳ����Ȩ����')

--����ϵͳ��Դ��add by lw 2011-11-26
update sysRight
set rightName = 'ϵͳ�趨'
where rightName = 'ϵͳ����'

insert sysRight(rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	canQuery4Global, canEdit4Global, canOutput4Global, canCheck4Global,
	rightDesc)
values('����ά��','oprMaintenance','','F',8,0,0,'Y',
	'Y','Y','Y','N','���Զ������û���������־�����桢��̳�����Ȩ��')

insert sysRight(rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	canQuery4Global, canEdit4Global, canOutput4Global, canCheck4Global,
	rightDesc)
values('�������','bulletinList','bulletin/bulletinList.html','D',8,2,0,'Y',
	'Y','Y','Y','N','�������Ȩ��')

--�������ݣ�
select * from sysRight
where rightEName = 'userList'
update sysRight
set rightType = 'D'
where rightEName = 'userList'

--������������2011-11-28
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
set rightName = 'ϵͳ�趨'
where rightEName = 'sysManagerForm'

update sysRoleRight
set rightName = 'ϵͳ�趨'
where rightEName = 'sysManagerForm'



--1.1���ݲ�����������������ݱ�Ϊ��̬���ݣ����Բ�û�н�������������Ƴ�һ������
--��ȡϵͳ���еĲ�����
select distinct oprType, oprName, oprEName, oprDesc 
from sysDataOpr

SELECT * FROM sysDataOpr
--���ӵĲ�������
insert sysDataOpr
values(7,3,0,2,'��Ȩ','cmdAut','���ý�ɫ���û�����Ȩ��')
insert sysDataOpr
values(7,4,0,2,'��������','cmdUpdatePW','�����û�������')
insert sysDataOpr
values(7,4,0,2,'��Ȩ','cmdAut','���ý�ɫ���û�����Ȩ��')

--���ӵĲ�������add by lw 2011-11-20
select * from sysDataOpr where rightKind = 3 and rightClass = 1 and rightItem = 0 and oprType = 2 and oprEName='cmdRep'
update sysDataOpr 
set oprName = '�̵�',
	oprEName = 'cmdChecking',
	oprDesc = '����豸�������豸��״��λ��'
where rightKind = 3 and rightClass = 1 and rightItem = 0 and oprType = 2 and oprEName='cmdRep'

insert sysDataOpr
values(3,6,0,1,'Ĭ���б�','cmdDefaultList','�豸�̵��Ĭ���б���')
insert sysDataOpr
values(3,6,0,1,'ɸѡ','cmdFilter','�趨��ѯ������Լ�������б����ʾ��Χ')
insert sysDataOpr
values(3,6,0,1,'���Ŀ�Ƭ','cmdShowCard','�鿴ָ���е��̵���ϸ��Ϣ')
insert sysDataOpr
values(3,6,0,2,'ɾ��','cmdDel','ɾ��ָ���е��̵���Ϣ')
insert sysDataOpr
values(3,6,0,3,'��ӡ��Ƭ','cmdPrintCard','��ӡָ���е��̵���ϸ��Ϣ')
insert sysDataOpr
values(3,6,0,3,'��ӡ���б�','cmdPrint','��ӡ�б�')
insert sysDataOpr
values(3,6,0,3,'����','cmdOutput','������ǰ���ݴ����е��б�')
insert sysDataOpr
values(3,6,0,4,'���','cmdVerify','��˲���Ч�̵���Ϣ')
insert sysDataOpr
values(3,6,0,4,'ȡ�����','cmdCancelVerify','ȡ���̵���Ϣ�����ִ��')

--���ӵĹ�����������add by lw 2011-11-25
insert sysDataOpr
values(8,2,0,1,'Ĭ���б�','cmdDefaultList','����Ĭ���б���')
insert sysDataOpr
values(8,2,0,1,'ɸѡ','cmdFilter','�趨��ѯ������Լ�������б����ʾ��Χ')
insert sysDataOpr
values(8,2,0,1,'����','cmdShowCard','�鿴ָ���������ϸ��Ϣ')
insert sysDataOpr
values(8,2,0,1,'Ԥ��','cmdPreview','ģ���¼�󹫸����ʾ')

insert sysDataOpr
values(8,2,0,2,'�½�','cmdNew','�½�����')
insert sysDataOpr
values(8,2,0,2,'�޸�','cmdUpdate','�޸��ƶ��Ĺ���')
insert sysDataOpr
values(8,2,0,2,'ɾ��','cmdDel','ɾ��ָ���Ĺ���')
insert sysDataOpr
values(8,2,0,2,'����','cmdActive','����ָ���Ĺ���')
insert sysDataOpr
values(8,2,0,2,'�ر�','cmdSetOff','�ر�ָ���Ĺ���')

insert sysDataOpr
values(8,2,0,3,'��ӡ��Ƭ','cmdPrintCard','��ӡָ��������ϸ��Ϣ')
insert sysDataOpr
values(8,2,0,3,'��ӡ���б�','cmdPrint','��ӡ�����б�')
insert sysDataOpr
values(8,2,0,3,'����','cmdOutput','������ǰ���ݴ����еĹ����б�')


--2.0.��ɫ��
--Ԥ����Ľ�ɫ��
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType, modiManID)
values('�����û�', 'ϵͳԤ���ӵ��ȫ��Ȩ�޵��û�', 1, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('У��ϵͳ����Ա', 'ϵͳԤ���ӵ��ȫ��Ȩ�޵��û�', 1, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('Ժ��ϵͳ����Ա', 'ϵͳԤ���������Ժ����ϵͳ����Ա��ӵ�б�Ժ���ض���ɫ����Ȩ��', 2, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('��λϵͳ����Ա', 'ϵͳԤ��������ڵ�λ��ϵͳ����Ա��ӵ�б���λ�ض���ɫ����Ȩ��', 3, '0000000000')
insert sysRole(sysRoleName, sysRoleDesc, sysRoleType,modiManID)
values('һ���û�', 'ϵͳԤ�����ͨ�û���ϵͳĬ�Ϸ���ý�ɫ��ÿһ���½��û������û�ֻӵ�б���λ�ĵ��ݲ�ѯȨ��', 3, '0000000000')

select * from codeDictionary where classCode = 100
select * from sysRole

--2.1.��ɫȨ�ޱ�
truncate table sysRoleRight
--Ԥ����Ľ�ɫ�������û���ӵ��ȫ��Ȩ�ޣ�
insert sysRoleRight(sysRoleID,
	rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--������������ݵĲ�����
	canQuery, canEdit, canOutput, canCheck, rightDesc)
select 1, rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--������������ݵĲ�����
	case canQuery4Global when 'Y' then 9 else 0 end, 
	case canEdit4Global when 'Y' then 9 else 0 end, 
	case canOutput4Global when 'Y' then 9 else 0 end, 
	case canCheck4Global when 'Y' then 9 else 0 end, 
	rightDesc 
from sysRight
where rightKind * 1000 + rightClass * 100 + rightItem not in (select rightKind * 1000 + rightClass * 100 + rightItem from sysRoleRight where sysRoleID = 1)

--Ԥ����Ľ�ɫ��ϵͳ����Ա��ӵ��ȫ��Ȩ�ޣ�
select * from sysRole where sysRoleID < 5
select * from sysRoleRight
insert sysRoleRight(sysRoleID,
	rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--������������ݵĲ�����
	canQuery, canEdit, canOutput, canCheck, rightDesc)
select 2, rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--������������ݵĲ�����
	case canQuery4Global when 'Y' then 9 else 0 end, 
	case canEdit4Global when 'Y' then 9 else 0 end, 
	case canOutput4Global when 'Y' then 9 else 0 end, 
	case canCheck4Global when 'Y' then 9 else 0 end, 
	rightDesc 
from sysRight
where rightKind * 1000 + rightClass * 100 + rightItem not in (select rightKind * 1000 + rightClass * 100 + rightItem from sysRoleRight where sysRoleID = 2)

--Ԥ����Ľ�ɫ��Ժ��ϵͳ����Ա��ӵ��Ժ����ȫ��Ȩ�ޣ����Զ��屾Ժ�����ض���ɫ��
insert sysRoleRight(sysRoleID,
	rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--������������ݵĲ�����
	canQuery, canEdit, canOutput, canCheck, rightDesc)
select 3, rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--������������ݵĲ�����
	case canQuery4Local when 'Y' then 2 else 0 end, 
	case canEdit4Local when 'Y' then 2 else 0 end, 
	case canOutput4Local when 'Y' then 2 else 0 end, 
	case canCheck4Local when 'Y' then 2 else 0 end, 
	rightDesc 
from sysRight

--Ԥ����Ľ�ɫ����λϵͳ����Ա��ӵ�е�λ��ȫ��Ȩ�ޣ����Զ��屾��λ���ض���ɫ��
insert sysRoleRight(sysRoleID,
	rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--������������ݵĲ�����
	canQuery, canEdit, canOutput, canCheck, rightDesc)
select 4, rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--������������ݵĲ�����
	case canQuery4UnitLocal when 'Y' then 1 else 0 end, 
	case canEdit4UnitLocal when 'Y' then 1 else 0 end, 
	case canOutput4UnitLocal when 'Y' then 1 else 0 end, 
	case canCheck4UnitLocal when 'Y' then 1 else 0 end, 
	rightDesc 
from sysRight

--Ԥ����Ľ�ɫ��һ���û���every one����ӵ�б����ŵĲ�ѯȨ�ޣ�
insert sysRoleRight(sysRoleID,
	rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--������������ݵĲ�����
	canQuery, canEdit, canOutput, canCheck, rightDesc)
select 5, rightName, rightEName, Url, rightType, rightKind, rightClass, rightItem, canUse,
	--������������ݵĲ�����
	case canQuery4UnitLocal when 'Y' then 1 else 0 end, 0, 0, 0, rightDesc 
from sysRight
delete sysRoleRight where sysRoleID = 5 and rightKind = 7

select * from sysRoleRight where sysRoleID = 1


--2.2.��ɫȨ�޲�����
--Ԥ�������ݣ�
truncate table sysRoleDataOpr
--���ӳ����û��Ľ�ɫȨ�޲�����
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

--���Ĳ������ƣ�by lw 2011-11-21
select * from sysRoleDataOpr where rightKind = 3 and rightClass = 1 and rightItem = 0 and oprType = 2 and oprEName='cmdRep'
update sysRoleDataOpr
set oprName = '�̵�',
	oprEName = 'cmdChecking',
	oprDesc = '����豸�������豸��״��λ��'
where rightKind = 3 and rightClass = 1 and rightItem = 0 and oprType = 2 and oprEName='cmdRep'
select * from sysRoleDataOpr where rightKind = 3 and rightClass = 1 and rightItem = 0 and oprType = 2 and oprEName='cmdChecking'

--3.�û���ɫ��
--���һ����ʼ�����û���Ȩ�ޣ�
delete userInfo where jobNumber = '0000000000'
insert userInfo(jobNumber, cName, clgCode, clgName, sysUserName, sysPassword, modiManID)
values('0000000000','�����û�','000','ʵ�������豸����', 'admin','D63F7AB0AA4546EC668C1D11EB795819','0000000000')
--��ʼ������''

--��ÿ���û�"һ���û�"��ɫ:
insert sysUserRole
select jobNumber, sysUserName, 5, 'һ���û�', 3 from userInfo

--ϵͳԤ����ĳ����û��Ľ�ɫ��
insert sysUserRole
select '0000000000','�����û�', sysRoleID, sysRoleName, sysRoleType
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
set sysRoleID = 1, sysRoleName='�����û�'
where jobNumber = '2010112301'


--�ġ�ϵͳ�û���Ϣ��
insert userInfo(jobNumber, cName, clgCode, clgName, sysUserName, sysPassword, modiManID)
values('2010112301','¬έ','001','��ί�칫��','lw','930522','2010112301')

insert userInfo(jobNumber, cName, clgCode, clgName, sysUserName, sysPassword, modiManID)
values('2010112302','������','001','��ί�칫��','zml','123','2010112301')
--1.ϵͳ�û���Ϣ�� ��userInfo����

select * from userInfo
delete userInfo where jobNumber ='3692581470'

--�������У԰�����ݣ�

--����Ad Hoc Distributed Queries��
exec sp_configure 'show advanced options',1
reconfigure
exec sp_configure 'Ad Hoc Distributed Queries',1
reconfigure
--ʹ����ɺ󣬹ر�Ad Hoc Distributed Queries��
exec sp_configure 'Ad Hoc Distributed Queries',0
reconfigure
exec sp_configure 'show advanced options',0
reconfigure 

select * from college where clgName like '%����%'
--У԰�����ݿ���ʹ�������������Ժ��,ͬ���ǵ����ݿⲻ����ȫƥ��,һЩ���Էֱ��Ժ�����Ѿ�����,���ǻ��кܶ���Ҫ�˹��ֱ��,���豸����Ա����:
select distinct t.gz88 from 
(select gz50, gz05, gz88
from 
OpenRowSet('Microsoft.Jet.OLEDB.4.0','Excel 5.0;hdr=Yes;DataBase=C:\Users\Administrator\Desktop\�人��ѧУ԰�����ݿ�.xls',fangkun$)) t
left join college c on left(t.gz88,2) = LEFT(c.clgName,2)
where c.clgName is null

--��ʱ��ת��
create table tempClgCard(
	jobNumber varchar(10),
	cName varchar(30),
	clgName varchar(30)
)
insert tempClgCard(jobNumber, cName, clgName)
select t.gz50, t.gz05, c.clgName
from 
OpenRowSet('Microsoft.Jet.OLEDB.4.0','Excel 5.0;hdr=Yes;DataBase=C:\Users\Administrator\Desktop\�人��ѧУ԰�����ݿ�.xls',fangkun$) t
left join college c on left(t.gz88,2) = LEFT(c.clgName,2)
where rtrim(ltrim(t.gz05)) <> '' and  t.gz05 is not null and t.gz50 not in (select jobNumber from userInfo)

select * from userInfo where sysUserName = 'fk'
update userInfo 
set sysPassWord='123456'
where sysUserName = 'fjc'

insert userInfo(jobNumber, cName, clgCode, clgName, sysUserName, sysUserDesc, sysPassword, modiManID)
select t.jobNumber, t.cName, c.clgCode, t.clgName, lower(dbo.getChinaPYCode(t.cName)), 'У԰���û�', t.jobNumber, ''
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




--�塢���յ���
--ת�����ݣ�
select distinct ysdh from epdbc.dbo.ysd

--ʹ���豸���еķ�����루�ƣ��������յ��еĿ��ֶΣ�
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

--�������ظ����ݺ�
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
			accountCode,	--��ƿ�Ŀ����:�û�ȷ��;ԭ����ϵͳ�ķ�����루�ƣ��зŵ��ǻ�ƿ�Ŀ��
			--ԭ���ݿ����յ���û�е��ֶΣ�ʹ���豸���з������ã�
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

--�������յ���״̬��
update eqpAcceptInfo
set acceptApplyStatus = 2
from eqpAcceptInfo e left join epdbc.dbo.ysd y on e.acceptApplyID = y.ysdh
where y.ysr is not null and y.ysr <>''

update eqpAcceptInfo
set acceptApplyStatus = 0
from eqpAcceptInfo e left join epdbc.dbo.ysd y on e.acceptApplyID = y.ysdh
where y.ysr is null or y.ysr =''

--�����ֶε�ת��Ҫ��������
--�����ֶ�ԭ���ݿ���û��,����ֱ�Ӵ�ŵ��豸����ȥ�ˣ�����Ҫ���豸���з����ȡ������
	cCode char(3) null,					--���Ҵ��룺��Ҫ�û�ȷ���Ƿ������ֵ��������������
	factory	nvarchar(20) null,			--��������
	makeDate smalldatetime null,		--�������ڣ��ڽ���������
	serialNumber nvarchar(15) null,		--�������

--����������յ��еĹ��Ҵ��롢������ŵ���Ϣ��
declare @acceptApplyID char(12)
declare tar cursor for
select acceptApplyID from eqpAcceptInfo
where acceptApplyID in (select acceptApplyID from equipmentList)
OPEN tar
FETCH NEXT FROM tar INTO @acceptApplyID
WHILE @@FETCH_STATUS = 0
begin
	declare @cCode char(3)				--���Ҵ��룺��Ҫ�û�ȷ���Ƿ������ֵ��������������
	declare @factory nvarchar(20)		--��������
	declare @makeDate smalldatetime		--�������ڣ��ڽ���������
	declare @serialNumber nvarchar(15)	--�������
	declare @str nvarchar(2000)			--�ϳɺ�ĳ������
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

--����ƿ�Ŀ�Ƿ��Ӧ��
select *
from eqpAcceptInfo a 
where isnull(a.accountCode,'') = '' 

select a.accountCode, t.accountName, a.*
from eqpAcceptInfo a left join accountTitle t on a.accountCode = t.accountCode
where isnull(a.accountCode,'') <> '' and t.accountName is null


select * from eqpAcceptInfo

--2010-11-30Ϊ�˽����Զ�Ĺ�ϵ�����˷��������ֶΣ���Ҫ��������ݣ�
--���ַ������������˺ܶ���룺
select e.eTypeCode, t.eTypeName, t.aTypeCode
from eqpAcceptInfo e left join typeCodes t on e.eTypeCode = t.eTypeCode
where t.eTypeName is null
--����С���ṩ�Ĺ̶��ʲ����������������ݣ�
insert typeCodes(eTypeCode, eTypeName, aTypeCode, aTypeName, typeUnit)
select flh, flmc, '','','̨/��' from fldm
where flh not in (select eTypeCode from typeCodes)

select * from eqpAcceptInfo where eTypeName = ''

update eqpAcceptInfo
set eTypeName = isnull(t.eTypeName,''), aTypeCode = isnull(t.aTypeCode,'')
from eqpAcceptInfo e left join typeCodes t on e.eTypeCode = t.eTypeCode
where e.eTypeName = ''

--���ת������Ҫ�˹����Ϸ����������������࣡��

--�������ӵ�Ժ�����ƺ�ʹ�õ�λ�����ֶΣ�
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
--����������ݣ�
insert eqpAcceptInfo(acceptApplyID, acceptApplyStatus, acceptMan, acceptDate, annexName, oprMan, buyDate, 
			clgCode, uCode, eTypeCode, eTypeName, aTypeCode,
			annexAmount, price, sumNumber, eName, eModel, eFormat, notes, 
			fCode, aCode, keeper, totalAmount, sumAmount, startECode, endECode, business,
			accountCode,	--��ƿ�Ŀ����:�û�ȷ��;ԭ����ϵͳ�ķ�����루�ƣ��зŵ��ǻ�ƿ�Ŀ��
			--ԭ���ݿ����յ���û�е��ֶΣ�ʹ���豸���з������ã�
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

--�������յ���״̬��
select * from eqpAcceptInfo
update eqpAcceptInfo
set acceptApplyStatus = 2
where convert(char(10),acceptDate,120) = '2011-10-08'

--���Ŵ�����豸��ŵĵ����˻أ�
update eqpAcceptInfo
set acceptApplyStatus = 0
where acceptApplyID = '0000040262'

--�����������ڣ�
update eqpAcceptInfo
set applyDate = acceptDate

select * from eqpAcceptInfo where acceptApplyStatus = 0 and acceptApplyID <> '0000040262'
select * from epApp
--�������뵥��
	--����������뵥�ţ�
begin tran
	declare @acceptApplyID char(12)
	declare @eTypeCode char(8)			--�����ţ��̣�
	declare @eTypeName nvarchar(30)	--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
	declare @aTypeCode char(6)			--�����ţ��ƣ�
	
	declare @eName nvarchar(30)		--�豸����
	declare @eModel nvarchar(20)		--�豸�ͺ�
	declare @eFormat nvarchar(20)		--�豸���
	declare @cCode char(3)				--���Ҵ���
	declare @factory nvarchar(20)		--��������
	declare @makeDate smalldatetime		--�������ڣ��ڽ���������
	declare @serialNumber nvarchar(2100)	--�������:���á�1|2|3|..."��ʽ���,�֧��20�ַ�*100������
	declare @buyDate smalldatetime	--�������ڣ��������ֵ
	declare @business nvarchar(20)	--���۵�λ
	declare @fCode char(2)	--������Դ����
	declare @aCode char(2)	--ʹ�÷�����룺���������п�ֵ����Ҫ�û�ȷ���Ƿ������ֵ������������
	declare @clgCode char(3)	--ѧԺ����
	declare @clgName nvarchar(30)	--ѧԺ����:������ƣ�������ʷ���� add by lw 2010-11-30
	declare @uCode varchar(8)	--ʹ�õ�λ���룺���������п�ֵ����Ҫ�û�ȷ���Ƿ������ֵ������������,modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	declare @uName nvarchar(30)	--ʹ�õ�λ����:������ƣ�������ʷ���� add by lw 2010-11-30
	declare @keeper nvarchar(30)	--������
	declare @annexName nvarchar(20)	--��������
	declare @annexAmount money	--��������

	declare @price money	--���ۣ�>0
	declare @totalAmount money	--�ܼ�, >0������+�����۸�
	declare @sumNumber int	--����
	declare @sumAmount money	--�ϼƽ��
	declare @oprMan nvarchar(30)	--������

	declare @notes nvarchar(50)	--��ע
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

--�����豸��
--1.equipmentList���豸����
--�����豸Ҫ�����ֶΣ����������ṹ
update equipmentList
set scrapFlag = 0
where scrapFlag =2
select * from equipmentList where eCode='11000054'
--�����豸��״���ֶμ�ֵ���壺wrt by lw 2011-1-26
--scrapFlag int default(0),		--�Ƿ񱨷�:0->��1->�ǣ��������뱨���ֶΣ�
									--���ֶθĳ���״�룺0-���ã�1-���ޣ�2-�����ϣ�3-�����뱨�� 4-�ѱ��ϣ�
									--ǰ2��״̬Ժϵ�豸����Ա����ֱ���޸ģ�״̬2�����뱨�ϵ����ã�״̬4�ɸ������ã�״̬3Ԥ����չ
update equipmentList
set curEqpStatus = case scrapFlag when 0 then '1' when 1 then '3' when 2 then '4' when 4 then '6' end
alter table equipmentList drop column scrapFlag

select count(*), sum(cast(totalAmount as numeric(18,2))) from equipmentList



--����ת����
select * from epdbc.dbo.sbmain
--���ֲ����豸��������Ψһ��
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

--��ʱ���������뱨����ص��ֶΣ�
ALTER TABLE equipmentList ADD [SBBF] [bit] NULL
ALTER TABLE equipmentList ADD [ISDORE] [bit] NULL
update equipmentList
set [SBBF]  = o.[SBBF] ,
	[ISDORE] = o.[ISDORE]
from equipmentList t left join epdbc.dbo.sbmain o on t.eCode = o.sbbh

select * from equipmentList
--ɾ���ֶ��еĶ���ո�
update equipmentList set keeper = ltrim(rtrim(keeper))

--�������е������ݣ�
select t0.*
from epdbc.dbo.sbmain t0
inner join 
	(select sbbh, count(*) num 
	from epdbc.dbo.sbmain
	where sbbh is not null
	group by sbbh) as t1 on t0.sbbh = t1.sbbh and t1.num > 1
order by t0.sbbh

select distinct substring(sbbh,3,1) from epdbc.dbo.sbmain order by substring(sbbh,3,1)
--�ظ��豸��ŵĽ���3λ�ĳɡ�T��
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

--2010-11-30Ϊ�˽����Զ�Ĺ�ϵ�����˷��������ֶΣ���Ҫ��������ݣ�
select * from equipmentList e 
where isnull(e.eTypeName,'') = ''

update equipmentList
set eTypeName = isnull(t.eTypeName,''), aTypeCode = isnull(t.aTypeCode,'')
from equipmentList e left join typeCodes t on e.eTypeCode = t.eTypeCode
where isnull(e.eTypeName,'') = ''
--���ת������Ҫ�˹����Ϸ����������������࣡��

--�������Ӷ�Ӧ�ı��ϵ������ݣ�2011-5-16
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
	--������ݣ�
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
	--������ݣ�
select * 
from bEquipmentScrapDetail b left join equipmentScrap c on b.scrapNum = c.scrapNum
where c.applyState = 3
select * from bEquipmentScrapDetail
select * from equipmentList where eCode in (select eCode from bEquipmentScrapDetail)

--��ѯ�Ѿ����ϵ��豸��
select * from equipmentList where scrapDate is not null
select * from equipmentList where scrapNum is not null
select * from equipmentList where ISDORE = 1

--���ñ��ϵ����ڡ��豸״̬��
update equipmentList
set scrapDate = s.scrapDate
from equipmentList e left join equipmentScrap s on e.scrapNum = s.scrapNum
where e.scrapNum is not null and ISDORE = 1

update equipmentList
set curEqpStatus = 1
--�ѱ����豸��
update equipmentList
set curEqpStatus = 6
where ISDORE = 1

update equipmentList
set scrapDate = '2011-06-30'
where curEqpStatus = 6 and scrapNum is null

--�������豸��
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
--����������豸���ø�Ժ�������ύ�������뵥��
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

--�����豸�غ��޸����豸��ţ�������Щ���ϵ��е��豸���ٶ�Ӧ����Ӧ���豸�У��븴�����µ��ݣ�
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
--û�з��ָ������ݣ�����


select * from equipmentList where curEqpStatus = 4
ALTER TABLE equipmentList ADD [SBBF] [bit] NULL
ALTER TABLE equipmentList ADD [ISDORE] [bit] NULL


--���ö�Ӧ�����յ��ţ�
select * from equipmentList
select * from eqpAcceptInfo

drop TABLE eqpTmp
CREATE TABLE eqpTmp(
	eCode char(8) not null,			--�������豸���,ʹ������ĺ��뷢��������
											--2λ��ݴ���+6λ��ˮ�ţ�����Ԥ������
											--ʹ���ֹ�������룬�Զ��������Ƿ��غ�
	acceptApplyID char(12) null,	--��Ӧ�����յ���
	eName nvarchar(30) not null,	--�豸����:��Ҫ�û�ȷ���Ƿ������ֵ��������������
	eModel nvarchar(20) not null,	--�豸�ͺ�
	eFormat nvarchar(30) not null,	--�豸��񣺸��ݽ�����Ҫ���ӳ��ֶγ���Ϊ20λ modi by lw 2011-1-26
	cCode char(3) not null,			--���Ҵ��룺��Ҫ�û�ȷ���Ƿ������ֵ��������������
	factory	nvarchar(20) null,		--��������
	makeDate smalldatetime null,	--�������ڣ��ڽ���������
	serialNumber nvarchar(20) null,	--�������
	business nvarchar(20) null,		--���۵�λ
	buyDate smalldatetime null,		--�������ڣ��������ֵ
	annexName nvarchar(20) null,	--��������	add by lw 2010-12-4�����յ�һ�»�
	annexCode nvarchar(20) null,	--����������
	annexAmount	money null,			--���������Ǹ������ۣ�

	eTypeCode char(8) not null,		--�����ţ��̣����4λ������ͬʱΪ��0��
	eTypeName nvarchar(30) not null,--��������������:Ϊ�˽����Զ��������Ҫ���ӵ��ֶΣ�add by lw 2010-11-30
	aTypeCode char(6) not null,		--�����ţ��ƣ������ţ��ƣ�=f�������ţ�������ʹ��ӳ���

	fCode char(2) not null,			--������Դ����
	aCode char(2) null,				--ʹ�÷�����룺���������п�ֵ����Ҫ�û�ȷ���Ƿ������ֵ������������
	price money null,				--���ۣ�>0
	totalAmount money null,			--�ܼ�, >0������+�����۸�
	clgCode char(3) not null,		--ѧԺ����
	uCode varchar(8) null,			--ʹ�õ�λ���룺���������п�ֵ����Ҫ�û�ȷ���Ƿ������ֵ������������.modi by lw 2011-2-11�����豸��Ҫ���ӳ����볤�ȣ�
	keeper nvarchar(30) null,		--������
	notes nvarchar(50) null,		--��ע
	acceptDate smalldatetime null,	--��������
	oprMan nvarchar(30) null,		--������
	acceptManID varchar(10) null,	--�����˹���,add by lw 2011-2-19
	acceptMan nvarchar(30) null,	--������
	--�ƻ���ֹ��
	--scrapFlag int default(0),		--�Ƿ񱨷�:0->��1->�ǣ��������뱨���ֶΣ�
									--���ֶθĳ���״�룺0-���ã�1-���ޣ�2-�����ϣ�3-�����뱨�� 4-�ѱ��ϣ�
									--ǰ2��״̬Ժϵ�豸����Ա����ֱ���޸ģ�״̬2�����뱨�ϵ����ã�״̬4�ɸ������ã�״̬3Ԥ����չ
	curEqpStatus char(1) not null,	--���ݱ���Ĺ涨���¶����豸����״���뺬�壺���ֶ��ɵ�2�Ŵ����ֵ䶨�� modi by lw 2011-1-26
									--1�����ã�ָ����ʹ�õ������豸��
									--2�����ָ࣬����ʹ�ü�ֵ��δʹ�õ������豸��
									--3�����ޣ�ָ���޻���������������豸��
									--4�������ϣ�ָ�Ѿ�ʧȥʹ�ü�ֵ����δ������ʽ���������������豸��
									--5����ʧ��
									--6�����ϣ�
									--7��������
									--8��������ָ��ѧУ��׼��������ʹ�á�����������豸��
									--9����������״����������豸��
	scrapDate smalldatetime null,	--�������ڣ�ԭ[ISDORE] [bit] NOT NULL,���Ѿ�ȷ�ϱ��ϣ��ָ�Ϊʹ�ñ�������
	--add by lw 2011-05-16,��Ϊɸѡ�е���������Ƚ��鷳���������Ӹ��ֶ�
	--ע�⣺��Ӧ�޸��˱��ϵĴ洢���̣��ڴ���ԭʼ���ݵ�ʱ����Ҫ����
	scrapNum char(12) null,		--��Ӧ���豸���ϵ���

	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
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


--����������û�еĴ��룺
select eTypeCode, * from equipmentList where eTypeCode not in (select eTypeCode from typeCodes)
--------------------------------------------------------------------
--����������ݣ�
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

--���ֽ�����һ�����յ����ɵ��豸����غţ����յ��ţ�0000040262 �豸��ţ�11009195-11009196
--��0000038977�ŵ��غţ�����
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

--�����豸״̬��
update equipmentList
set curEqpStatus = 1
where convert(char(10),acceptDate,120) = '2011-10-08'

--���ö�Ӧ�����յ��ţ�
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


--�ϴ����ԭ�������յ���ʹ�õ�λ��Ժ��û�м�������Ҫʹ�õ�λ�����������ɵ�λ���룺select clgCode, uCode, * 
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

--���ϵ�����Ϊû����дʹ�õ�λ���Բ����ڸ����⣺
select clgCode, clgName, uCode, uName, * 
from equipmentScrap
where clgCode <> left(uCode,3)
	and isnull(uCode,'') <> ''

select clgCode, clgName, uCode, uName, * 
from equipmentScrap
where isnull(uName,'') = ''

select * from college where clgCode = '153'

--2.equipmentAnnex���豸����������Ҫ�û�ȷ���豸�����Ƿ�������豸�ֿ����ã�����
--����ת����
select * from epdbc.dbo.sbfj
select * from equipmentAnnex
insert equipmentAnnex(eCode, buyDate, annexName, annexFormat,
	quantity, price, totalAmount, oprMan, business,
	fCode )
select f.sbbh, f.gzrq, f.fjmc, f.xhgg, f.sl, f.dj, f.zj, f.jbr, f.xsdw, e.JFLY
from epdbc.dbo.sbfj f left join epdbc.dbo.sbmain e on f.sbbh = e.sbbh
where f.sbbh in (select eCode from equipmentList)

--����һ���豸����û�ж�Ӧ�����豸��
select f.sbbh, f.gzrq, f.fjmc, f.xhgg, f.sl, f.dj, f.zj, f.jbr, f.xsdw, e.JFLY
from epdbc.dbo.sbfj f left join epdbc.dbo.sbmain e on f.sbbh = e.sbbh
where cast(f.sbbh as varchar(8)) not in (select eCode from equipmentList)

select * from equipmentList where eCode in ('08006794','08T06794','08TT6794')


--�ߡ��豸���ϵ���
--1.�豸���ϵ���
--ת�����ݣ�
--ԭϵͳsbbfd�豸��������
select * from epdbc.dbo.sbbfd
where bgdw not in(select clgName from college)
select * from equipmentScrap

insert equipmentScrap(scrapNum, applyState, replyState, 
		clgCode, clgName, clgManager, applyMan, eManager, scrapDesc, scrapDate,
		processMan, processDesc, isBigEquipment, totalNum, totalMoney, notes, applyDate, tel,
		uCode,uName)

select bfdh, case rtrim(state) when '�ȴ����' then 0 else 1 end [applyState], case rtrim(state) when '�ȴ����' then 0 
																		when 'ȫ��ͬ��' then 1
																		when '����ͬ��' then 2
																		when 'ȫ����ͬ��' then 3 
																		when '��ͬ��' then 3 
																		else 4 end [replyState],
		c.clgCode, bgdw, ybfzr, bgr, glfzr, czjg, czsj,
		jbr, state, bigsb, zsl, zje, bz, sqdate, tel,
		'',''
from epdbc.dbo.sbbfd s join college c on s.bgdw = c.clgName

--��ԭ״̬������
update equipmentScrap
set applyState = 3
where replyState <> 0

--2.С���豸������ϸ��:

select * from sEquipmentScrapDetail
select * from epdbc.dbo.xbfmxd
select distinct bfdh from epdbc.dbo.sbbfd
--ת�����ݣ�
--xbfmxd С���豸������ϸ��
insert sEquipmentScrapDetail(scrapNum, eCode, totalAmount, leaveMoney, 
		scrapDesc, identifyDesc, processState,
		eName, eModel, eFormat, buyDate, eTypeCode, eTypeName)
select s.bfdh, sbbh, isnull(sbzj,0), isnull(sbcz,0), 
		bfyy, jsjdyj, case mx.state when 'ͬ��' then 1 else 0 end,
		eName, eModel, eFormat, buyDate, eTypeCode, eTypeName
from epdbc.dbo.xbfmxd mx inner join epdbc.dbo.sbbfd s on mx.bfmxd = s.bfmxd
	left join equipmentList e on mx.sbbh = e.eCode
where s.bfdh in (select scrapNum from equipmentScrap)
and eName is not null
order by mx.bfmxd

--3.�����豸������ϸ��:
select * from epdbc.dbo.dbfmxd
--ת�����ݣ�
--dbfmxd �����豸������ϸ��
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
--ע�⣺gzwDesc����д����ԭ��ϸ���е�sbcyj

select s.bfdh, mx.bfmxd, e.scrapDesc, mx.sbcyj, mx.*
from epdbc.dbo.dbfmxd mx left join epdbc.dbo.sbbfd s on mx.bfmxd = s.bfmxd
	left join equipmentScrap e on e.scrapNum = s.bfdh

select * from epdbc.dbo.dbfmxd mx
select * from bEquipmentScrapDetail

--�ˡ��豸������
--1.�豸��������
--ԭ�豸�������ֶ�һ����
select * from epdbc.dbo.sbdb
xh		���
sbbh	��������
dbyy	����ԭ��
ydwfzr	ԭ��λ������
yyb		ԭԺ��
ydw		ԭʹ�õ�λ
ybg		ԭ����
xdwfzr	�µ�λ������
xyb		��Ժ��
xdw		��ʹ�õ�λ
xbg		�±���
jsyj	�������
jsfzr	���ܸ�����
glfzr	�豸����������

--ת�����ݣ�
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
--������������������ݣ�
select *
from epdbc.dbo.sbdb e left join college c on e.yyb = c.clgCode
		left join useUnit u on e.ydw = u.uCode
		left join college c2 on e.xyb = c2.clgCode
		left join useUnit u2 on e.xdw = u2.uCode
		left join equipmentList eqp on e.sbbh = eqp.eCode
where u.uCode is null or u2.uCode is null or c.clgCode is null or c2.clgCode is null


