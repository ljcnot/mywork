/*
	����豸������Ϣϵͳ-��������
	author:		¬έ
	CreateDate:	2011-11-20
	UpdateDate: 
*/
use epdc2
--����ȱʧ�������������豸��
select * from equipmentList where cCode not in (select cCode from country)

--���ɳ���ȱʧ���豸��
select * from equipmentList where isnull(factory,'') = '' or factory = '*'

--���۵�λȱʧ���豸��
select * from equipmentList where isnull(business,'') = '' or business = '*'

--������Դȱʧ����������豸��
select * from equipmentList where fCode not in(select fCode from fundSrc)

--ʹ�÷���ȱʧ����������豸��
select * from equipmentList where aCode not in(select aCode from appDir)

--�豸����������򲻷��������λ����Ϊ��00��������豸��
select eTypeCode, aTypeCode, * from equipmentList where eTypeCode not in(select eTypeCode from typeCodes)

--û��Ժ�����豸��
select clgCode, * from equipmentList where clgCode not in(select clgCode from college)

--û��ʹ�õ�λ��ʹ�õ�λ�������в�һ�µ��豸��
select clgCode, uCode, * from equipmentList where clgCode+'|'+uCode not in(select clgCode + '|' + uCode from useUnit)

--�ϴ����������ʱ������غ��豸��
select * from equipmentList where eCode like '%T%'



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

	--�Ѿ����ϵ��豸״̬���Ե��豸��
select curEqpStatus, scrapDate, * from equipmentList 
where eCode in (
		select eCode from sEquipmentScrapDetail 
		where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1','2'))
		union all
		select eCode from bEquipmentScrapDetail
		where scrapNum in (select scrapNum from equipmentScrap where replyState in ('1','2'))
		)
and curEqpStatus <> '6'


--ȱ��������Ϣ���豸��
select acceptApplyID, acceptDate, oprMan, acceptManID, acceptMan, * from equipmentList 
where isnull(acceptApplyID,'') ='' or isnull(acceptDate,'') = '' or isnull(oprMan,'')='' or isnull(acceptManID,'') = '' or isnull(acceptMan,'') = ''
	--���ֲ����豸�������˿���ʹ�����յ��е���������䣺
select acceptManID, acceptMan, * from eqpAcceptInfo where acceptApplyID = '0000032773'
select * from userInfo where cName = '����'	--����˲������ˣ�
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

--���û���������ڱ���Ϣ���豸��
select * from equipmentList
where eCode not in (select eCode from eqpLifeCycle)
