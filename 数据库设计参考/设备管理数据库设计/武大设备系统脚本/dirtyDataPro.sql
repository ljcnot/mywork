/*
	����豸������Ϣϵͳ-��������
	author:		¬έ
	CreateDate:	2011-11-20
	UpdateDate: 
*/
use epdc2
--����ȱʧ�������������豸��
select * from equipmentList where cCode not in (select cCode from country)
and cCode = ''
update equipmentList
set cCode = '203'
where cCode = '200'
update equipmentList
set cCode = '203'
where cCode = '810'

update equipmentList
set cCode = '156'
where cCode = '000'

update equipmentList
set cCode = '156'
where cCode = ''

select * from country where cName like '�й�'
	--����һ��������������
	

--���ɳ���ȱʧ���豸��
select * from equipmentList where isnull(factory,'') = '' or factory = '*'
	--�*��
update equipmentList 
set factory='*'
where isnull(factory,'') = '' or factory = '*'
	
--���۵�λȱʧ���豸��
select * from equipmentList where isnull(business,'') = '' or business = '*'
	--�����������������۵�λ
update equipmentList
set business = factory
where isnull(business,'') = '' or business = '*'
	

--������Դȱʧ����������豸��
select fCode,aCode, * from equipmentList where fCode not in(select fCode from fundSrc)
	--ԭ����Ϊ��9���ĸ�Ϊ��������ҵ�ѡ�
select * from equipmentList where fCode not in(select fCode from fundSrc)
update equipmentList 
set fCode=1
where fCode not in(select fCode from fundSrc)

	--����ʹ�÷���ȷ��������ѧ��-����������ҵ�ѡ��������С�-�������С�
select * from appDir
select * from fundSrc
	
--ʹ�÷���ȱʧ����������豸��
select * from equipmentList where aCode not in(select aCode from appDir)

--�������ڵ��豸��
select * from equipmentList where makeDate is null
	--�ֹ�ȷ��
update equipmentList 
set makeDate='2001-11-19'
where eCode='03010006'

update equipmentList 
set makeDate='2000-01-01'
where makeDate is null

--�������ڵ��豸��
	--�ֹ�ȷ��
select * from equipmentList where buyDate is null
update equipmentList 
set buyDate='2000-01-01'
where buyDate is null
	
--�豸����������򲻷��������λ����Ϊ��00��������豸��
use epdc2
select '="'+eTypeCode+'"' [����������], eTypeName [������������], '="'+aTypeCode+'"' [����������], '="'+eCode+'"', '="'+acceptApplyID+'"', e.* , c.clgName, u.uName
from equipmentList e left join college c on e.clgCode=c.clgCode left join useUnit u on e.uCode = u.uCode
where eTypeCode not in(select eTypeCode from typeCodes)
order by [����������]
	--�ֹ�ȷ��
select eTypeCode, aTypeCode, * from equipmentList where isnull(eTypeCode,'') = ''

select eTypeCode, aTypeCode, * 
from equipmentList 
where isnull(eTypeCode,'') = '' and eName like '%DELL%'

update equipmentList 
set eTypeCode='04070704',
	eTypeName='�������������յ�����',
	aTypeCode='165000'
where isnull(eTypeCode,'') = '' and eName like '%�յ�%'

select * from typeCodes
where eTypeCode='04070704'

update equipmentList 
set eTypeCode='05010104',
	eTypeName='ר�÷�����',
	aTypeCode='711104'
where isnull(eTypeCode,'') = '' and eName like '%DELL%'

update equipmentList 
set eTypeCode='03170318',
	eTypeName='���ֻ�����ϵͳ',
	aTypeCode='464302'
where eCode = '10000777'

--09004555	��Ƭ���������
update equipmentList 
set eTypeCode='05010710',
	eTypeName='���ϵͳ',
	aTypeCode='719000  '
where eCode = '09004555'

--10010814	����
update equipmentList 
set eTypeCode='04070711',
	eTypeName='���ʹ�',
	aTypeCode='163000  '
where eCode = '10010814'

--10T01731	��Դ
update equipmentList 
set eTypeCode='03021018',
	eTypeName='����ϵ�Դ',
	aTypeCode='614202'
where eCode = '10T01731'

--11000080	����ISCSI�洢
update equipmentList 
set eTypeCode='05010535',
	eTypeName='���̴洢��',
	aTypeCode='712199'
where eCode = '11000080'

--11002647	Һ������
update equipmentList 
set eTypeCode='04170910',
	eTypeName='Һ����������(Һ����)',
	aTypeCode='352900'
where eCode = '11002647'

update equipmentList 
set eTypeCode='05010105',
	eTypeName='΢�͵��Ӽ����',
	aTypeCode='711105'
where eCode = '11002423'

update equipmentList 
set eTypeCode='05010549',
	eTypeName='�����ӡ��',
	aTypeCode='714103'
where eCode = '05000699'

update equipmentList 
set eTypeCode='03010132',
	eTypeName='�����¶���',
	aTypeCode='741129'
where etypecode='03010100'

update equipmentList 
set eTypeCode='03020408',
	eTypeName='���ܵ���',
	aTypeCode='742401'
where etypecode='03020400' and eName = '��ƽ�����'

update equipmentList 
set eTypeCode='05040301',
	eTypeName='���ػ�',
	aTypeCode='708500'
where eTypeCode='03011100' and eName like '%�п�%'

update equipmentList 
set eTypeCode='03061601',
	eTypeName='�̽���',
	aTypeCode='746805'
where eTypeCode='03021601'

update equipmentList 
set eTypeCode='03021018',
	eTypeName='����ϵ�Դ',
	aTypeCode='614202'
where eTypeCode='03011018'

update equipmentList 
set eTypeCode='03150840',
	eTypeName='��Ƶ��·ʵ��װ��',
	aTypeCode='764107'
where eTypeCode='03041815'


update equipmentList 
set eTypeCode='04070304',
	eTypeName='���ķ��',
	aTypeCode='134100'
where eCode = '04005312'

update equipmentList 
set eTypeCode='03060906',
	eTypeName='���Ⱥ���������',
	aTypeCode='746499'
where eTypeCode='03066906'

update equipmentList 
set eTypeCode='03060220',
	eTypeName='���ϵͳ',
	aTypeCode='746799'
where eCode in('03003221')

update equipmentList 
set eTypeCode='05010522',
	eTypeName='����Ƭ��',
	aTypeCode='714900'
where  eTypeCode not in(select eTypeCode from typeCodes) and (eName like '%ѧ��Ʊ֤��αʶ����')


select eTypeCode [����������], eTypeName [������������], aTypeCode [����������], * from equipmentList where eTypeCode not in(select eTypeCode from typeCodes)
order by eName

select eTypeCode,* from equipmentList  where eTypeCode not in(select eTypeCode from typeCodes) and (eName like '%ѧ��Ʊ֤��αʶ����') 
order by eName

select eTypeCode,* from equipmentList  where eTypeCode in('03040310') and eName like '%��'
select eTypeCode,* from equipmentList  where len(eTypeCode)=7
select eTypeCode,* from equipmentList  where eTypeCode not in(select eTypeCode from typeCodes) and RIGHT(eTypeCode,2)<>'00' and eName like '%��%��%'
select * from typeCodes
where eTypeName like '%����%'
where eTypeCode='05010919'

WHERE eKind = '13'


select * from kindTypeCodes
select * from classTypeCodes
WHERE eKind = '13'
select * from subClassTypeCodes
WHERE eKind = '03'

select eTypeCode a, aTypeCode, * from equipmentList where eTypeCode not in(select eTypeCode from typeCodes) and RIGHT(eTypeCode,2)<>'00'
order by a

--û��Ժ�����豸��
select clgCode a, * from equipmentList where clgCode not in(select clgCode from college)
order by a
	--����3λ�ı��벹��0��
select clgCode a, * from equipmentList where clgCode not in(select clgCode from college) and LEN(clgCode) < 3
order by a
update equipmentList 
set clgCode = '0' + clgCode
where clgCode not in(select clgCode from college) and LEN(clgCode) < 3
	--�ֹ�ȷ��
update equipmentList 
set clgCode = '123'
where eCode = '11015937'

select * from college where clgName like '%����%'

--û��ʹ�õ�λ��ʹ�õ�λ�������в�һ�µ��豸��
select clgCode a, keeper, oprman, uCode, * from equipmentList where clgCode+'|'+uCode not in(select clgCode + '|' + uCode from useUnit)
order by a
	--�ֹ�ȷ��
update equipmentList 
set uCode = '15602'
where clgCode ='156' and keeper='������' and (clgCode+'|'+uCode not in(select clgCode + '|' + uCode from useUnit))

select clgcode,uCode from equipmentList where keeper='������'
select clgCode,uCode,* from userInfo where cName ='�����'
select * from useUnit
select * from equipmentList 
where clgCode ='0' and (clgCode+'|'+uCode not in(select clgCode + '|' + uCode from useUnit))


--�ϴ����������ʱ������غ��豸��
select * from equipmentList where eCode like '%T%'


--�豸״̬��������б�
select curEqpStatus,* from equipmentList
where eCode in
(
select eCode from sEquipmentScrapDetail 
where scrapNum = '0000002303'
)

select * from bEquipmentScrapDetail
where oldEqpStatus is null

update bEquipmentScrapDetail
set oldEqpStatus = 1
where oldEqpStatus is null

update sEquipmentScrapDetail 
set oldEqpStatus = 1
where scrapNum = '0000002303'


--�ٴ�ͨ�����ϵ�ȷ�ϱ����豸��
select * from equipmentScrap where replyState in ('1','2')
	--ȫ��ͬ��ĵ��ݣ�
select * from equipmentScrap where replyState in ('1')
	--����ͬ���С���豸���ϵ���
select * from equipmentScrap where replyState in ('2')

	--δ��Ч�ı��ϵ���
select * from equipmentScrap where replyState in ('0')

	--��ͬ�ⱨ�ϵı��ϵ���ǩ�����������ĵ��ݣ�
select * from equipmentScrap where replyState in ('3') and processDesc <> 'ȫ����ͬ��' and processDesc <> '��ͬ��'


	--С���豸���ϵ���ͬ�ⱨ�ϵ��豸��
select eCode from sEquipmentScrapDetail 
where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1','2'))
	and processState = '1'
	--�����豸���ϵ���ͬ�ⱨ�ϵ��豸��
select eCode,* from bEquipmentScrapDetail
where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1'))
	--������ϵ���״̬�����⣺Ӧ��Ϊȫ��ͬ�⣡
select eCode,* from bEquipmentScrapDetail
where scrapNum in (select scrapNum from equipmentScrap where replyState in ('2'))
	--��������ԭʼ���ݵ����⣬ֱ��ɾ����������ϸ���ݣ�
delete bEquipmentScrapDetail
where scrapNum in ('0000000069','0000001235')

	--������С�͵ģ�������ϸ���Ǵ��͵ĵ��ݣ���175̨�豸
select '="' + scrapNum + '"','="' + eCode + '"', eName, * from bEquipmentScrapDetail
where scrapNum in(
	select scrapNum from equipmentScrap 
	where isBigEquipment = 0
)

select isBigEquipment, '="' + b.scrapNum + '"','="' + eCode + '"', eName, * 
from bEquipmentScrapDetail b right join equipmentScrap e on  b.scrapNum= e.scrapNum and isnull(e.isBigEquipment,0) = 1
where eCode in
(
	select eCode from bEquipmentScrapDetail
	where scrapNum in(
		select scrapNum from equipmentScrap 
		where isBigEquipment = 0
	)
)

select * from bEquipmentScrapDetail
where eCode in (
	select eCode from bEquipmentScrapDetail
	where scrapNum in(
		select scrapNum from equipmentScrap 
		where isBigEquipment = 0
	)
)
order by eCode

	--�����Ǵ��͵ģ�������ϸ����С�͵ĵ��ݣ�
select eCode,* from sEquipmentScrapDetail
where scrapNum in(
	select scrapNum from equipmentScrap 
	where isBigEquipment = 1
)

select curEqpStatus, * from equipmentList e
where eCode in
(
select eCode from sEquipmentScrapDetail
where scrapNum in(
	select scrapNum from equipmentScrap 
	where isBigEquipment = 1
)
)
order by e.curEqpStatus

select * from bEquipmentScrapDetail
where eCode in ('01009356','00021927')

select eCode,* from sEquipmentScrapDetail
where scrapNum in ('0000000069','0000001235')

select * from equipmentScrap
where scrapNum in ('0000000069','0000001235')

	--С�ͱ����豸���ϵ��в���ͬ�ⱨ�ϵ��豸
select * from sEquipmentScrapDetail 
where scrapNum in (select scrapNum from equipmentScrap where replyState in ('2'))
	and processState = '1'


	--�Ѿ����ϵ��豸״̬���Ե��豸��ֻ������2011-10-01�Ժ�ĵ��ݣ�
select curEqpStatus, scrapDate, * from equipmentList 
where eCode in (
		select eCode from sEquipmentScrapDetail 
		where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1','2')  and convert(char(10),scrapDate,120) > '2011-10-01') and processState = '1'
		union all
		select eCode from bEquipmentScrapDetail
		where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1') and convert(char(10),scrapDate,120) > '2011-10-01')
		)
and curEqpStatus <> '6'


update equipmentList 
set curEqpStatus = '6'
where eCode in (
		select eCode from sEquipmentScrapDetail 
		where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1','2')  and convert(char(10),scrapDate,120) > '2011-10-01') and processState = '1'
		union all
		select eCode from bEquipmentScrapDetail
		where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1') and convert(char(10),scrapDate,120) > '2011-10-01')
		)
and curEqpStatus <> '6'





select * from bEquipmentScrapDetail b left join equipmentScrap e on b.scrapNum = e.scrapNum and isBigEquipment = 1
where eCode in
(
	select eCode from equipmentList 
	where eCode in (
			--select eCode from sEquipmentScrapDetail 
			--where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1','2')) and processState = '1'
			--union all
			select eCode from bEquipmentScrapDetail
			where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1'))
			)
	and curEqpStatus <> '6'
)

--���¼���������豸��
select * from 
equipmentScrap 
where isBigEquipment = 1 and replyState in ('0')

select e.scrapNum, * 
from bEquipmentScrapDetail b inner join equipmentScrap e on b.scrapNum = e.scrapNum and e.isBigEquipment = 1
where e.replyState in ('0')

select curEqpStatus, * from equipmentList
where eCode in
(
	select b.eCode 
	from bEquipmentScrapDetail b inner join equipmentScrap e on b.scrapNum = e.scrapNum and e.isBigEquipment = 1
	where e.replyState in ('0')
)

select b.eCode, count(*) 
from bEquipmentScrapDetail b inner join equipmentScrap e on b.scrapNum = e.scrapNum and e.isBigEquipment = 1
where e.replyState in ('0')
group by b.eCode
having count(*) > 1

--ɾ���������ظ��Ĵ����豸���ϵ���
0000001329,0000002234
201110190002,0000002235  �����ŵ���ʱ������

update equipmentList
set curEqpStatus = 4
where eCode in
(
select eCode from bEquipmentScrapDetail
where scrapNum in ('201110190002','0000002235')
)

--ɾ���������ظ���С���豸���ϵ���
0000002477,0000002478
0000002479���������ŵ���
update equipmentList
set curEqpStatus = 4
where eCode in
(
select eCode from sEquipmentScrapDetail
where scrapNum in ('0000002479')
)

select * from bEquipmentScrapDetail 
where eCode in ('06000054','20H00566')


select * from 
equipmentScrap 
where isBigEquipment = 0 and replyState in ('0')

select s.eCode, count(*) 
from sEquipmentScrapDetail s inner join equipmentScrap e on s.scrapNum = e.scrapNum and e.isBigEquipment = 0
where e.replyState in ('0')
group by s.eCode
having count(*) > 1
select * from sEquipmentScrapDetail
where eCode in('15010035','15010050')



select curEqpStatus, * from equipmentList
where eCode in
(
	select s.eCode
	from sEquipmentScrapDetail s inner join equipmentScrap e on s.scrapNum = e.scrapNum and e.isBigEquipment = 0
	where e.replyState in ('0')
) and curEqpStatus <> '4'

--ȱ��������Ϣ���豸��
select acceptApplyID, acceptDate, oprMan, acceptManID, acceptMan, * from equipmentList 
where isnull(acceptApplyID,'') ='' or isnull(acceptDate,'') = '' or isnull(oprMan,'')='' or isnull(acceptManID,'') = '' or isnull(acceptMan,'') = ''
	--���ֲ����豸�������˿���ʹ�����յ��е���������䣺
select acceptManID, acceptMan, * from eqpAcceptInfo where acceptApplyID = '0000032773'
select * from userInfo where cName = '��  ��'	--����˲������ˣ�
	--û�����յ���û�б��ϵ��豸��ʹ��2010-12-31�����̵���⣿
select acceptApplyID, acceptDate, oprMan, acceptManID, acceptMan, curEqpStatus, * from equipmentList 
where isnull(acceptApplyID,'') ='' and curEqpStatus <> '6'

--���յ��Ĳ��빤��Ӧ�ð���������������
--1.�Ȳ����豸����Ϣ��
--2.�����ϵ��豸һ�»���
--3.�����豸��Ϣ������⣺��������һ�����⣬��ƿ�Ŀ���趨����
	--3.1�����豸�嵥�������յ���
	--3.2�����豸�������ڣ�
--4.�����̵��豸�������豸�ı�����Ϣ����չ��Ϣ
--������������Ϊ�������ڣ�����

--���û���������ڱ���Ϣ���豸��
select * from equipmentList
where eCode not in (select eCode from eqpLifeCycle)
