use hustOA
/*
	ǿ�ų����İ칫ϵͳ-�ɹ�����
	author:		¬έ
	CreateDate:	2012-12-21
	UpdateDate: 
*/

--1.���ĵǼǱ�
alter TABLE thesisInfo alter column	thesisTitle nvarchar(100) null		--������Ŀ
update thesisInfo 
set affectFact = affectFact*10

alter TABLE thesisInfo alter column	firstAuthorID varchar(10) null	--��һ���߹���
alter TABLE thesisInfo drop column	elseAuthorID

alter TABLE thesisInfo alter column	thesisTitle nvarchar(300) null		--������Ŀ,modi by lw 2014-4-18���ݳ�Զ��ʦ������ӳ���300��
alter TABLE thesisInfo alter column	periodicalName nvarchar(100) not null--�ڿ�(���飩����,modi by lw 2014-4-18���ݳ�Զ��ʦ������ӳ���100��

select * from thesisInfo
select str(affectFact/100.0,4,2), * from thesisInfo
drop table thesisInfo
CREATE TABLE thesisInfo(
	thesisId varchar(10) not null,		--���������ı��,��ϵͳʹ�õ�100�ź��뷢����������'LW'+4λ��ݴ���+4λ��ˮ�ţ�
	thesisTitle nvarchar(300) null,		--������Ŀ,modi by lw 2014-4-18���ݳ�Զ��ʦ������ӳ���300��
	summary nvarchar(300) null,			--���ݼ��
	keys nvarchar(30) null,				--�ؼ��֣�����ؼ���ʹ��","�ָ�

	firstAuthorType smallint null,		--��һ�������1->�̹���9->ѧ��, 0->������� add by lw 2014-4-4
	firstAuthorID varchar(10) null,		--��һ���߹��� modi by lw 2014-4-4���ݳ�Զ��ʦ��Ҫ��֧�ַ�ϵͳ�û�
	firstAuthor nvarchar(30) not null,	--��һ�����������������
	tutorID varchar(10) null,			--��ʦ����:����һ����Ϊѧ��ʱҪ������
	tutorName nvarchar(30) null,		--��ʦ����:����һ����Ϊѧ��ʱҪ�����롣�������

	--elseAuthorID varchar(100) not null,	--�������߹��ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���,����ֶ���ʱû����˼��û�����ã�del by lw 2014-4-8
	elseAuthor nvarchar(300) not null,	--��������������֧�ֶ���ˣ�����"1":"V1";"2":"V2";��ֵ�Ը�ʽ��š�
	
	periodicalName nvarchar(100) not null,--�ڿ�(���飩����,modi by lw 2014-4-18���ݳ�Զ��ʦ������ӳ���100��
	ISSN varchar(16) not null,			--�ڿ��ţ����ʱ�׼����ISSN ��ISSNΪǰ׺����8λ������ɡ�8λ���ַ�Ϊǰ�����θ�4λ���м������Ӻ���������ʽ���£�ISSN XXXX-XXXX
										--		  ����ͳһ����CN CN���ű�׼��ʽ�ǣ�CNXX-XXXX������ǰ��λ�Ǹ�ʡ�������У����š���ӡ�С�CN��HK������CNXXX��HK��/R������Ȼ���ǺϷ��Ĺ���ͳһ���š�
	periodicalNature int not null,		--�ڿ����ʣ��ɵ�50�Ŵ����ֵ�
	periodicalType int not null,		--�ڿ�����ɵ�51�Ŵ����ֵ�
	publishTime smalldatetime null,		--�������飩ʱ��
	authorRank smallint default(0),		--��������
	thesisType int null,				--���ķ��ࣺ���õ�52�����ֵ�
	affectFact smallint default(0),		--Ӱ������:Ӧ����С��������*100����
	citedTimes smallint default(0),		--������Ƶ��
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_thesisInfo] PRIMARY KEY CLUSTERED 
(
	[thesisId] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--�ؼ���������
CREATE NONCLUSTERED INDEX [IX_thesisInfo] ON [dbo].[thesisInfo] 
(
	[keys] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--��һ���߹���������
CREATE NONCLUSTERED INDEX [IX_thesisInfo_0] ON [dbo].[thesisInfo] 
(
	[firstAuthorID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--��һ��������������
CREATE NONCLUSTERED INDEX [IX_thesisInfo_1] ON [dbo].[thesisInfo] 
(
	[firstAuthor] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�ڿ���������
CREATE NONCLUSTERED INDEX [IX_thesisInfo_2] ON [dbo].[thesisInfo] 
(
	[ISSN] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�ڿ�����������
CREATE NONCLUSTERED INDEX [IX_thesisInfo_3] ON [dbo].[thesisInfo] 
(
	[periodicalNature] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�ڿ����������
CREATE NONCLUSTERED INDEX [IX_thesisInfo_4] ON [dbo].[thesisInfo] 
(
	[periodicalType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�������飩ʱ��������
CREATE NONCLUSTERED INDEX [IX_thesisInfo_5] ON [dbo].[thesisInfo] 
(
	[publishTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--���ķ���������
CREATE NONCLUSTERED INDEX [IX_thesisInfo_6] ON [dbo].[thesisInfo] 
(
	[thesisType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--��ʦ����������
CREATE NONCLUSTERED INDEX [IX_thesisInfo_7] ON [dbo].[thesisInfo] 
(
	[tutorID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.ר���ǼǱ�
drop table monographInfo
CREATE TABLE monographInfo(
	monographId varchar(10) not null,		--������ר�����,��ϵͳʹ�õ�101�ź��뷢����������'ZZ'+4λ��ݴ���+4λ��ˮ�ţ�
	monographName nvarchar(40) null,		--ר������
	summary nvarchar(300) null,				--���ݼ��
	keys nvarchar(30) null,					--�ؼ��֣�����ؼ���ʹ��","�ָ�
	monographType int not null,				--ר������ɵ�53�Ŵ����ֵ䶨��
	firstAuthorType smallint null,			--��һ�������1->�̹���9->ѧ��
	firstAuthorID varchar(10) not null,		--��һ���߹���
	firstAuthor nvarchar(30) not null,		--��һ�����������������
	tutorID varchar(10) null,				--��ʦ����:����һ����Ϊѧ��ʱҪ������
	tutorName nvarchar(30) null,			--��ʦ����:����һ����Ϊѧ��ʱҪ�����롣�������

	elseAuthorID varchar(100) not null,		--�������߹��ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
	elseAuthor nvarchar(300) not null,		--��������������֧�ֶ���ˣ�����"XXX,XXX"��ʽ��š��������

	ISBN varchar(30) null,					--����ţ�ȫ��Ϊ����׼��š����Ǳ�ʶ���������ע��ĳ������������ÿһ�ֳ������ÿ���汾�Ĺ����Ե�Ψһ���롣
											--�ҹ����ù��ʱ�׼���International Standard Book Numbering��ISBN����Ϊ�й���׼��š�
											--һ�������Ĺ��ʱ�׼����ɱ�ʶ��ISBN��10λ���±�׼ǰ�����EANǰ׺3λ���ֱ�Ϊ13λ�룩������ɣ����������ְ����Ĳ��֣�
											--�����ţ���������ߵĹ��ҡ����������ɹ���ISBN����ͳһ���÷��䣬�ҹ�Ϊ��7������ʾ���Գ�1�����顣
											--�����ߺţ�����һ�����������й�ISBN���ķֱ����úͷ��䣬����Ϊ2��7λ��
											--������ţ���1��ͼ��1���ţ��ɳ��������з��䡣
											--У���룺�̶���1λ���֡�
											--���磺����������ѡ����һ��ƽװ�������ΪISBN 7-01-005674-9��
	publishHouse nvarchar(60) null,			--������
	publishTime smalldatetime null,			--����ʱ��
	frontCoverFile varchar(128) null,		--�����ϴ���ͼƬ·��
	summaryCopyFile varchar(128) null,		--���ݼ���ͼƬ·��
	backCoverFile varchar(128) null,		--����ϴ���ͼƬ·��
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_monographInfo] PRIMARY KEY CLUSTERED 
(
	[monographId] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--�ؼ���������
CREATE NONCLUSTERED INDEX [IX_monographInfo] ON [dbo].[monographInfo] 
(
	[keys] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--���������
CREATE NONCLUSTERED INDEX [IX_monographInfo_0] ON [dbo].[monographInfo] 
(
	[monographType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--���߹���������
CREATE NONCLUSTERED INDEX [IX_monographInfo_1] ON [dbo].[monographInfo] 
(
	[firstAuthorID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--��������������
CREATE NONCLUSTERED INDEX [IX_monographInfo_2] ON [dbo].[monographInfo] 
(
	[firstAuthor] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--ISBN���������
CREATE NONCLUSTERED INDEX [IX_monographInfo_3] ON [dbo].[monographInfo] 
(
	[ISBN] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--����ʱ��������
CREATE NONCLUSTERED INDEX [IX_monographInfo_4] ON [dbo].[monographInfo] 
(
	[publishTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--3.ר���ǼǱ�
drop table patentInfo
CREATE TABLE patentInfo(
	patentId varchar(10) not null,		--������ר�����,��ϵͳʹ�õ�102�ź��뷢����������'ZL'+4λ��ݴ���+4λ��ˮ�ţ�
	invenName nvarchar(40) not null,	--��������
	patentType int not null,			--ר�����ͣ��ɵ�54�Ŵ����ֵ䶨��
	invenManID varchar(100) null,		--�����ˣ������ˣ���ר����׼�������˾��Ƿ����ˣ����ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
	invenMan nvarchar(300) null,		--�����ˣ������ˣ���ר����׼�������˾��Ƿ����ˣ�������"XXX,XXX"��ʽ��š��������
	applyTime smalldatetime null,		--����ʱ��
	isWarranted char(1) default('N'),	--�Ƿ�����Ȩ��'N'->δ��Ȩ��'Y'����Ȩ
	warrantTime smalldatetime null,		--��Ȩʱ��
	patentNum varchar(13) null,			--ר���ţ�ר������ű����ʽ����12λ���֣�����һ��С���㣩:�������+ר����������+����˳���+�����У��λ
										--ǰ4λ���ֱ�ʾ������ţ���5λ���ֱ�ʾ�������ࣺ
										--1=����ר������,2=ʵ������ר������,3=������ר������,8=�����й����ҽ׶ε�PCT����ר������,9=�����й����ҽ׶ε�PCTʵ������ר������
										--����2003 1 0100002.X ��ʾ����ר������
										--    2003 2 0100002.5 ��ʾʵ������ר������
	patentCopyFile varchar(128) null,	--ר����ӡ���ϴ�ͼƬ
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_patentInfo] PRIMARY KEY CLUSTERED 
(
	[patentId] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--ר������������
CREATE NONCLUSTERED INDEX [IX_patentInfo_1] ON [dbo].[patentInfo] 
(
	[patentType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�����ˣ������ˣ�����������
CREATE NONCLUSTERED INDEX [IX_patentInfo_2] ON [dbo].[patentInfo] 
(
	[invenManID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--�����ˣ������ˣ�����������
CREATE NONCLUSTERED INDEX [IX_patentInfo_3] ON [dbo].[patentInfo] 
(
	[invenMan] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--����ʱ��������
CREATE NONCLUSTERED INDEX [IX_patentInfo_4] ON [dbo].[patentInfo] 
(
	[applyTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--��Ȩʱ��������
CREATE NONCLUSTERED INDEX [IX_patentInfo_5] ON [dbo].[patentInfo] 
(
	[warrantTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--4.����Ϣ�ǼǱ�
drop table awardInfo
CREATE TABLE awardInfo(
	awardId varchar(10) not null,		--�������񽱱��,��ϵͳʹ�õ�103�ź��뷢����������'HJ'+4λ��ݴ���+4λ��ˮ�ţ�
	awardName nvarchar(30) not null,	--������
	completeManId nvarchar(100) null,	--�����Ա���������ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ��ţ�������ⲿ��Ա��ȱ���
	completeMan nvarchar(300) null,		--�����Ա������������"XXX,XXX"��ʽ��š�������ƣ�������ⲿ��Ա��ȱ���
	unitRank nvarchar(300) null,		--��λ������֧�ֶ����λ������"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
	awardTime smalldatetime null,		--��ʱ�䣺����"yyyy-MM-dd"��ʽ���
	certiCopyFile varchar(128) null,	--֤�鸴ӡ���ϴ�ͼƬ
	remark nvarchar(100) null,			--��ע
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_awardInfo] PRIMARY KEY CLUSTERED 
(
	[awardId] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--������������
CREATE NONCLUSTERED INDEX [IX_awardInfo_1] ON [dbo].[awardInfo] 
(
	[awardName] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--��ʱ��������
CREATE NONCLUSTERED INDEX [IX_awardInfo_2] ON [dbo].[awardInfo] 
(
	[awardTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--5.������Ŀ�ǼǱ�
drop table projectInfo
CREATE TABLE projectInfo(
	projectId varchar(10) not null,		--��������Ŀ�ڲ����,��ϵͳʹ�õ�104�ź��뷢����������'XM'+4λ��ݴ���+4λ��ˮ�ţ�
	projectNum varchar(30) null,		--��Ŀ��ţ�ѧУ�ı�ţ�
	consignUnit nvarchar(60) null,		--ί�е�λ
	consignUnitLocateCode varchar(6) null,	--ί�е�λ��Դ��������
	securityClass int null,				--�ܼ����ɵ�57�Ŵ����ֵ䶨��
	projectName nvarchar(30) not null,	--��Ŀ����
	applyTime smalldatetime null,		--��Ŀ�걨ʱ��
	
	projectNature int not null,			--��Ŀ���ʣ��ɵ�55�Ŵ����ֵ䶨��
	projectType int null,				--��Ŀ����ɵ�56�Ŵ����ֵ䶨��
	projectFund numeric(12,2) null,		--��Ŀ���ѣ���Ԫ��
	startTime smalldatetime null,		--��ʼʱ��
	endTime smalldatetime null,			--����ʱ��
	projectManagerID varchar(10) null,	--��Ŀ�����˹���
	projectManager nvarchar(30) null,	--��Ŀ������
	summary nvarchar(300) null,			--�о�����ժҪ
	
	--����ά�����:
	modiManID varchar(10) null,			--ά���˹���
	modiManName nvarchar(30) null,		--ά��������
	modiTime smalldatetime null,		--���ά��ʱ��

	--�༭�����ˣ�
	lockManID varchar(10),				--��ǰ���������༭���˹���
 CONSTRAINT [PK_projectInfo] PRIMARY KEY CLUSTERED 
(
	[projectId] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--������
--�걨ʱ��������
CREATE NONCLUSTERED INDEX [IX_projectInfo_1] ON [dbo].[projectInfo] 
(
	[applyTime] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--��Ŀ���������
CREATE NONCLUSTERED INDEX [IX_projectInfo_2] ON [dbo].[projectInfo] 
(
	[projectNum] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--�ܼ�������
CREATE NONCLUSTERED INDEX [IX_projectInfo_3] ON [dbo].[projectInfo] 
(
	[securityClass] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--��Ŀ����������
CREATE NONCLUSTERED INDEX [IX_projectInfo_4] ON [dbo].[projectInfo] 
(
	[projectNature] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--��Ŀ���������
CREATE NONCLUSTERED INDEX [IX_projectInfo_5] ON [dbo].[projectInfo] 
(
	[projectType] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]
--��Ŀ�����˹���������
CREATE NONCLUSTERED INDEX [IX_projectInfo_6] ON [dbo].[projectInfo] 
(
	[projectManagerID] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]



drop PROCEDURE queryThesisInfoLocMan
/*
	name:		queryThesisInfoLocMan
	function:	1.��ѯָ�������Ƿ��������ڱ༭
	input: 
				@thesisId varchar(10),		--���ı��
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ�������Ĳ�����
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE queryThesisInfoLocMan
	@thesisId varchar(10),		--���ı��
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from thesisInfo where thesisId= @thesisId),'')
	set @Ret = 0
GO


drop PROCEDURE lockThesisInfo4Edit
/*
	name:		lockThesisInfo4Edit
	function:	2.�������ı༭������༭��ͻ
	input: 
				@thesisId varchar(10),		--���ı��
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ���������Ĳ����ڣ�2:Ҫ�������������ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE lockThesisInfo4Edit
	@thesisId varchar(10),		--���ı��
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from thesisInfo where thesisId= @thesisId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from thesisInfo where thesisId= @thesisId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update thesisInfo
	set lockManID = @lockManID 
	where thesisId= @thesisId
	
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�������ı༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ������������['+ @thesisId +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockThesisInfoEditor
/*
	name:		unlockThesisInfoEditor
	function:	3.�ͷ����ı༭��
				ע�⣺�����̲���������Ƿ���ڣ�
	input: 
				@thesisId varchar(10),			--���ı��
				@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE unlockThesisInfoEditor
	@thesisId varchar(10),			--���ı��
	@lockManID varchar(10) output,	--�����ˣ������ǰ���������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from thesisInfo where thesisId= @thesisId),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update thesisInfo set lockManID = '' where thesisId= @thesisId
	end
	else
	begin
		set @Ret = 0
		return
	end
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷ����ı༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ�������['+ @thesisId +']�ı༭����')
GO

drop PROCEDURE addThesisInfo
/*
	name:		addThesisInfo
	function:	4.���������Ϣ
	input: 
				@thesisTitle nvarchar(300),	--������Ŀ
				@summary nvarchar(300),		--���ݼ��
				@keys nvarchar(30),			--�ؼ��֣�����ؼ���ʹ��","�ָ�

				@firstAuthorType smallint,	--��һ�������1->�̹���9->ѧ��
				@firstAuthorID varchar(10),	--��һ���߹���
				@firstAuthor nvarchar(30),	--��һ������������ϵͳ�û�ֱ��ʹ������
				@tutorID varchar(10),		--��ʦ����:����һ����Ϊѧ��ʱҪ������
				@tutorName nvarchar(30),	--��ʦ����:����һ����Ϊѧ��ʱҪ�����롣��ϵͳ�û�ֱ��ʹ������

				@elseAuthor nvarchar(300),	--��������������֧�ֶ���ˣ�����"1":"V1";"2":"V2";��ֵ�Ը�ʽ��š�
				
				@periodicalName nvarchar(100),--�ڿ�(���飩����
				@ISSN varchar(16),			--�ڿ��ţ����ʱ�׼����ISSN ��ISSNΪǰ׺����8λ������ɡ�8λ���ַ�Ϊǰ�����θ�4λ���м������Ӻ���������ʽ���£�ISSN XXXX-XXXX
											--		  ����ͳһ����CN CN���ű�׼��ʽ�ǣ�CNXX-XXXX������ǰ��λ�Ǹ�ʡ�������У����š���ӡ�С�CN��HK������CNXXX��HK��/R������Ȼ���ǺϷ��Ĺ���ͳһ���š�
				@periodicalNature int,		--�ڿ����ʣ��ɵ�50�Ŵ����ֵ�
				@periodicalType int,		--�ڿ�����ɵ�51�Ŵ����ֵ�
				@publishTime varchar(10),	--�������飩ʱ��:���á�yyyy-MM-dd����ʽ���
				@authorRank smallint,		--��������
				@thesisType int,			--���ķ��ࣺ���õ�52�����ֵ�
				@affectFact smallint,		--Ӱ������:Ӧ����С��������*100����
				@citedTimes smallint,		--������Ƶ��

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,	--���ʱ��
				@thesisId varchar(10) output		--���ı��
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: modi by lw 2014-4-4���ݳ�Զ��ʦ��Ҫ��֧�ַ�ϵͳ�û���2014-4-9���������߸ĳɼ�ֵ�Է�ʽ
				modi by lw 2014-4-18���ݳ�Զ��ʦ������ӳ�thesisTitle��periodicalName�ֶ�
*/
create PROCEDURE addThesisInfo
	@thesisTitle nvarchar(300),	--������Ŀ
	@summary nvarchar(300),		--���ݼ��
	@keys nvarchar(30),			--�ؼ��֣�����ؼ���ʹ��","�ָ�

	@firstAuthorType smallint,	--��һ�������1->�̹���9->ѧ��
	@firstAuthorID varchar(10),	--��һ���߹���
	@firstAuthor nvarchar(30),	--��һ������������ϵͳ�û�ֱ��ʹ������
	@tutorID varchar(10),		--��ʦ����:����һ����Ϊѧ��ʱҪ������
	@tutorName nvarchar(30),	--��ʦ����:����һ����Ϊѧ��ʱҪ�����롣��ϵͳ�û�ֱ��ʹ������

	@elseAuthor nvarchar(300),	--��������������֧�ֶ���ˣ�����"1":"V1";"2":"V2";��ֵ�Ը�ʽ��š�
	
	@periodicalName nvarchar(100),--�ڿ�(���飩����
	@ISSN varchar(16),			--�ڿ��ţ����ʱ�׼����ISSN ��ISSNΪǰ׺����8λ������ɡ�8λ���ַ�Ϊǰ�����θ�4λ���м������Ӻ���������ʽ���£�ISSN XXXX-XXXX
										--		  ����ͳһ����CN CN���ű�׼��ʽ�ǣ�CNXX-XXXX������ǰ��λ�Ǹ�ʡ�������У����š���ӡ�С�CN��HK������CNXXX��HK��/R������Ȼ���ǺϷ��Ĺ���ͳһ���š�
	@periodicalNature int,		--�ڿ����ʣ��ɵ�50�Ŵ����ֵ�
	@periodicalType int,		--�ڿ�����ɵ�51�Ŵ����ֵ�
	@publishTime varchar(10),	--�������飩ʱ��:���á�yyyy-MM-dd����ʽ���
	@authorRank smallint,		--��������
	@thesisType int,			--���ķ��ࣺ���õ�52�����ֵ�
	@affectFact smallint,		--Ӱ������:Ӧ����С��������*100����
	@citedTimes smallint,		--������Ƶ��

	@createManID varchar(10),	--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@thesisId varchar(10) output		--���ı��
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢�����������ı�ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 100, 1, @curNumber output
	set @thesisId = @curNumber

	--ȡ��һ��������/��ʦ����:����һ����Ϊѧ��ʱҪ������/�����˵�������
	declare @createManName nvarchar(30)
	if (@firstAuthorID is not null and @firstAuthorID<>'')
		set @firstAuthor = isnull((select cName from userInfo where jobNumber = @firstAuthorID),'')
	if (@firstAuthorType=1)
		set @tutorName = ''
	else if (@tutorID is not null and @tutorID<>'')
		set @tutorName = isnull((select cName from userInfo where jobNumber = @tutorID),'')
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert thesisInfo(thesisId, thesisTitle, summary, keys, 
					firstAuthorType, firstAuthorID, firstAuthor, tutorID, tutorName,  elseAuthor, 
					periodicalName, ISSN, periodicalNature, periodicalType, publishTime, 
					authorRank, thesisType, affectFact,citedTimes,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@thesisId, @thesisTitle, @summary, @keys, 
					@firstAuthorType, @firstAuthorID, @firstAuthor, @tutorID, @tutorName, @elseAuthor, 
					@periodicalName, @ISSN, @periodicalNature, @periodicalType, @publishTime, 
					@authorRank, @thesisType, @affectFact,@citedTimes,
					--����ά�����:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�Ǽ�����', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ����ġ�' + @thesisTitle + '['+@thesisId+']����')
GO
--���ԣ�
declare @Ret		int, @createTime smalldatetime, @thesisId varchar(10)
exec dbo.addThesisInfo '������������','����','����',1,'','��С��','','','','������־','1213',1,1,'2014-04-04',1,1,10.05,1,'G201300052',
	@ret output,@createTime output, @thesisId output
select * from thesisInfo order by thesisId desc


drop PROCEDURE updateThesisInfo
/*
	name:		updateThesisInfo
	function:	5.�޸�������Ϣ
	input: 
				@thesisId varchar(10),		--���ı��
				@thesisTitle nvarchar(300),	--������Ŀ
				@summary nvarchar(300),		--���ݼ��
				@keys nvarchar(30),			--�ؼ��֣�����ؼ���ʹ��","�ָ�

				@firstAuthorType smallint,	--��һ�������1->�̹���9->ѧ��
				@firstAuthorID varchar(10),	--��һ���߹���
				@firstAuthor nvarchar(30),	--��һ������������ϵͳ�û�ֱ��ʹ������
				@tutorID varchar(10),		--��ʦ����:����һ����Ϊѧ��ʱҪ������
				@tutorName nvarchar(30),	--��ʦ����:����һ����Ϊѧ��ʱҪ�����롣��ϵͳ�û�ֱ��ʹ������

				@elseAuthor nvarchar(300),	--��������������֧�ֶ���ˣ�����"1":"V1";"2":"V2";��ֵ�Ը�ʽ��š�
				
				@periodicalName nvarchar(100),--�ڿ�(���飩����
				@ISSN varchar(16),			--�ڿ��ţ����ʱ�׼����ISSN ��ISSNΪǰ׺����8λ������ɡ�8λ���ַ�Ϊǰ�����θ�4λ���м������Ӻ���������ʽ���£�ISSN XXXX-XXXX
													--		  ����ͳһ����CN CN���ű�׼��ʽ�ǣ�CNXX-XXXX������ǰ��λ�Ǹ�ʡ�������У����š���ӡ�С�CN��HK������CNXXX��HK��/R������Ȼ���ǺϷ��Ĺ���ͳһ���š�
				@periodicalNature int,		--�ڿ����ʣ��ɵ�50�Ŵ����ֵ�
				@periodicalType int,		--�ڿ�����ɵ�51�Ŵ����ֵ�
				@publishTime varchar(10),	--�������飩ʱ��:���á�yyyy-MM-dd����ʽ���
				@authorRank smallint,		--��������
				@thesisType int,				--���ķ��ࣺ���õ�52�����ֵ�
				@affectFact smallint,		--Ӱ������:Ӧ����С��������*10����
				@citedTimes smallint,		--������Ƶ��

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ����Ĳ����ڣ�
							2:Ҫ�޸ĵ������������������༭��
							9:δ֪����
				@modiTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: modi by lw 2014-4-4���ݳ�Զ��ʦ��Ҫ��֧�ַ�ϵͳ�û���2014-4-9���������߸ĳɼ�ֵ�Է�ʽ
				modi by lw 2014-4-18���ݳ�Զ��ʦ������ӳ�thesisTitle��periodicalName�ֶ�
*/
create PROCEDURE updateThesisInfo
	@thesisId varchar(10),		--���ı��
	@thesisTitle nvarchar(300),	--������Ŀ
	@summary nvarchar(300),		--���ݼ��
	@keys nvarchar(30),			--�ؼ��֣�����ؼ���ʹ��","�ָ�

	@firstAuthorType smallint,	--��һ�������1->�̹���9->ѧ��
	@firstAuthorID varchar(10),	--��һ���߹���
	@firstAuthor nvarchar(30),	--��һ������������ϵͳ�û�ֱ��ʹ������
	@tutorID varchar(10),		--��ʦ����:����һ����Ϊѧ��ʱҪ������
	@tutorName nvarchar(30),	--��ʦ����:����һ����Ϊѧ��ʱҪ�����롣��ϵͳ�û�ֱ��ʹ������

	@elseAuthor nvarchar(300),	--��������������֧�ֶ���ˣ�����"1":"V1";"2":"V2";��ֵ�Ը�ʽ��š�
	
	@periodicalName nvarchar(100),--�ڿ�(���飩����
	@ISSN varchar(16),			--�ڿ��ţ����ʱ�׼����ISSN ��ISSNΪǰ׺����8λ������ɡ�8λ���ַ�Ϊǰ�����θ�4λ���м������Ӻ���������ʽ���£�ISSN XXXX-XXXX
										--		  ����ͳһ����CN CN���ű�׼��ʽ�ǣ�CNXX-XXXX������ǰ��λ�Ǹ�ʡ�������У����š���ӡ�С�CN��HK������CNXXX��HK��/R������Ȼ���ǺϷ��Ĺ���ͳһ���š�
	@periodicalNature int,		--�ڿ����ʣ��ɵ�50�Ŵ����ֵ�
	@periodicalType int,		--�ڿ�����ɵ�51�Ŵ����ֵ�
	@publishTime varchar(10),	--�������飩ʱ��:���á�yyyy-MM-dd����ʽ���
	@authorRank smallint,		--��������
	@thesisType int,				--���ķ��ࣺ���õ�52�����ֵ�
	@affectFact smallint,		--Ӱ������:Ӧ����С��������*10����
	@citedTimes smallint,		--������Ƶ��

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from thesisInfo where thesisId= @thesisId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from thesisInfo where thesisId= @thesisId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--ȡ��һ��������/��ʦ����:����һ����Ϊѧ��ʱҪ������/�����˵�������
	if (@firstAuthorID is not null and @firstAuthorID<>'')
		set @firstAuthor = isnull((select cName from userInfo where jobNumber = @firstAuthorID),'')
	if (@firstAuthorType=1)
		set @tutorName = ''
	else if (@tutorID is not null and @tutorID<>'')
		set @tutorName = isnull((select cName from userInfo where jobNumber = @tutorID),'')
	
	set @modiTime = getdate()
	update thesisInfo
	set thesisId = @thesisId, thesisTitle = @thesisTitle, summary = @summary, keys = @keys, 
		firstAuthorType = @firstAuthorType, firstAuthorID = @firstAuthorID, firstAuthor = @firstAuthor, 
		tutorID = @tutorID, tutorName = @tutorName, elseAuthor = @elseAuthor, 
		periodicalName = @periodicalName, ISSN = @ISSN, periodicalNature = @periodicalNature, periodicalType = @periodicalType, 
		publishTime = @publishTime, authorRank = @authorRank, thesisType = @thesisType, affectFact = @affectFact, citedTimes = @citedTimes,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where thesisId= @thesisId
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸�����', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸������ġ�' + @thesisTitle + '['+@thesisId+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delThesisInfo
/*
	name:		delThesisInfo
	function:	6.ɾ��ָ��������
	input: 
				@thesisId varchar(10),		--���ı��
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ�������Ĳ����ڣ�2��Ҫɾ����������������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 

*/
create PROCEDURE delThesisInfo
	@thesisId varchar(10),		--���ı��
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����������Ƿ����
	declare @count as int
	set @count=(select count(*) from thesisInfo where thesisId= @thesisId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from thesisInfo where thesisId= @thesisId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete thesisInfo where thesisId= @thesisId
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ������', '�û�' + @delManName
												+ 'ɾ��������['+@thesisId+']��')

GO


--���ĵĲ�ѯ��䣺
select t.thesisId, t.thesisTitle, t.summary, t.keys,
	t.firstAuthorType, t.firstAuthorID, t.firstAuthor, t.tutorID, t.tutorName,
	t.elseAuthorID, t.elseAuthor,
	t.periodicalName, t.ISSN, t.periodicalNature, cd1.objDesc periodicalNatureDesc, t.periodicalType, cd2.objDesc periodicalTypeDesc, t.publishTime,
	t.authorRank, t.thesisType, t.affectFact, t.citedTimes
from thesisInfo t
left join codeDictionary cd1 on t.periodicalNature = cd1.objCode and cd1.classCode=50
left join codeDictionary cd2 on t.periodicalType = cd2.objCode and cd2.classCode=51



drop PROCEDURE queryMonographInfoLocMan
/*
	name:		queryMonographInfoLocMan
	function:	11.��ѯָ��ר���Ƿ��������ڱ༭
	input: 
				@monographId varchar(10),	--ר�����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����ר��������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE queryMonographInfoLocMan
	@monographId varchar(10),	--ר�����
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from monographInfo where monographId= @monographId),'')
	set @Ret = 0
GO


drop PROCEDURE lockMonographInfo4Edit
/*
	name:		lockMonographInfo4Edit
	function:	12.����ר���༭������༭��ͻ
	input: 
				@monographId varchar(10),		--ר�����
				@lockManID varchar(10) output,	--�����ˣ������ǰר�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������ר�������ڣ�2:Ҫ������ר�����ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE lockMonographInfo4Edit
	@monographId varchar(10),		--ר�����
	@lockManID varchar(10) output,	--�����ˣ������ǰר�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������ר���Ƿ����
	declare @count as int
	set @count=(select count(*) from monographInfo where monographId= @monographId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from monographInfo where monographId= @monographId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update monographInfo
	set lockManID = @lockManID 
	where monographId= @monographId
	
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����ר���༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ��������ר��['+ @monographId +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockMonographInfoEditor
/*
	name:		unlockMonographInfoEditor
	function:	13.�ͷ�ר���༭��
				ע�⣺�����̲����ר���Ƿ���ڣ�
	input: 
				@monographId varchar(10),		--ר�����
				@lockManID varchar(10) output,	--�����ˣ������ǰר�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE unlockMonographInfoEditor
	@monographId varchar(10),		--ר�����
	@lockManID varchar(10) output,	--�����ˣ������ǰר�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from monographInfo where monographId= @monographId),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update monographInfo set lockManID = '' where monographId= @monographId
	end
	else
	begin
		set @Ret = 0
		return
	end
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷ�ר���༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ���ר��['+ @monographId +']�ı༭����')
GO


drop PROCEDURE addMonographInfo
/*
	name:		addMonographInfo
	function:	14.���ר����Ϣ
	input: 
				@monographName nvarchar(40),		--ר������
				@summary nvarchar(300),				--���ݼ��
				@keys nvarchar(30) ,				--�ؼ��֣�����ؼ���ʹ��","�ָ�
				@monographType int,					--ר������ɵ�53�Ŵ����ֵ䶨��
				@firstAuthorType smallint,			--��һ�������1->�̹���9->ѧ��
				@firstAuthorID varchar(10),			--��һ���߹���
				@tutorID varchar(10),				--��ʦ����:����һ����Ϊѧ��ʱҪ������

				@elseAuthorID varchar(10),			--�������߹��ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
				@elseAuthor nvarchar(30),			--��������������֧�ֶ���ˣ�����"XXX,XXX"��ʽ��š��������

				@ISBN varchar(30),					--����ţ�ȫ��Ϊ����׼��š����Ǳ�ʶ���������ע��ĳ������������ÿһ�ֳ������ÿ���汾�Ĺ����Ե�Ψһ���롣
														--�ҹ����ù��ʱ�׼���International Standard Book Numbering��ISBN����Ϊ�й���׼��š�
														--һ�������Ĺ��ʱ�׼����ɱ�ʶ��ISBN��10λ���±�׼ǰ�����EANǰ׺3λ���ֱ�Ϊ13λ�룩������ɣ����������ְ����Ĳ��֣�
														--�����ţ���������ߵĹ��ҡ����������ɹ���ISBN����ͳһ���÷��䣬�ҹ�Ϊ��7������ʾ���Գ�1�����顣
														--�����ߺţ�����һ�����������й�ISBN���ķֱ����úͷ��䣬����Ϊ2��7λ��
														--������ţ���1��ͼ��1���ţ��ɳ��������з��䡣
														--У���룺�̶���1λ���֡�
														--���磺����������ѡ����һ��ƽװ�������ΪISBN 7-01-005674-9��
				@publishHouse nvarchar(60),			--������
				@publishTime varchar(10),			--����ʱ��
				@frontCoverFile varchar(128),		--�����ϴ���ͼƬ·��
				@summaryCopyFile varchar(128),		--���ݼ���ͼƬ·��
				@backCoverFile varchar(128),		--����ϴ���ͼƬ·��

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,	--���ʱ��
				@monographId varchar(10) output		--ר�����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE addMonographInfo
	@monographName nvarchar(40),		--ר������
	@summary nvarchar(300),				--���ݼ��
	@keys nvarchar(30) ,				--�ؼ��֣�����ؼ���ʹ��","�ָ�
	@monographType int,					--ר������ɵ�53�Ŵ����ֵ䶨��
	@firstAuthorType smallint,			--��һ�������1->�̹���9->ѧ��
	@firstAuthorID varchar(10),			--��һ���߹���
	@tutorID varchar(10),				--��ʦ����:����һ����Ϊѧ��ʱҪ������

	@elseAuthorID varchar(10),			--�������߹��ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
	@elseAuthor nvarchar(30),			--��������������֧�ֶ���ˣ�����"XXX,XXX"��ʽ��š��������

	@ISBN varchar(30),					--����ţ�ȫ��Ϊ����׼��š����Ǳ�ʶ���������ע��ĳ������������ÿһ�ֳ������ÿ���汾�Ĺ����Ե�Ψһ���롣
											--�ҹ����ù��ʱ�׼���International Standard Book Numbering��ISBN����Ϊ�й���׼��š�
											--һ�������Ĺ��ʱ�׼����ɱ�ʶ��ISBN��10λ���±�׼ǰ�����EANǰ׺3λ���ֱ�Ϊ13λ�룩������ɣ����������ְ����Ĳ��֣�
											--�����ţ���������ߵĹ��ҡ����������ɹ���ISBN����ͳһ���÷��䣬�ҹ�Ϊ��7������ʾ���Գ�1�����顣
											--�����ߺţ�����һ�����������й�ISBN���ķֱ����úͷ��䣬����Ϊ2��7λ��
											--������ţ���1��ͼ��1���ţ��ɳ��������з��䡣
											--У���룺�̶���1λ���֡�
											--���磺����������ѡ����һ��ƽװ�������ΪISBN 7-01-005674-9��
	@publishHouse nvarchar(60),			--������
	@publishTime varchar(10),			--����ʱ��
	@frontCoverFile varchar(128),		--�����ϴ���ͼƬ·��
	@summaryCopyFile varchar(128),		--���ݼ���ͼƬ·��
	@backCoverFile varchar(128),		--����ϴ���ͼƬ·��

	@createManID varchar(10),	--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@monographId varchar(10) output		--ר�����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢��������ר����ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 101, 1, @curNumber output
	set @monographId = @curNumber

	--ȡ��һ��������/��ʦ����:����һ����Ϊѧ��ʱҪ������/�����˵�������
	declare @firstAuthor nvarchar(30), @tutorName nvarchar(30), @createManName nvarchar(30)
	set @firstAuthor = isnull((select cName from userInfo where jobNumber = @firstAuthorID),'')
	if (@firstAuthorType=9)
		set @tutorName = isnull((select cName from userInfo where jobNumber = @tutorID),'')
	else
		set @tutorName = ''
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert monographInfo(monographId, monographName, summary, keys, monographType,
					firstAuthorType, firstAuthorID, firstAuthor, tutorID, tutorName, elseAuthorID, elseAuthor, 
					ISBN, publishHouse, publishTime, frontCoverFile, 
					summaryCopyFile, backCoverFile,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@monographId, @monographName, @summary, @keys, @monographType,
					@firstAuthorType, @firstAuthorID, @firstAuthor, @tutorID, @tutorName, @elseAuthorID, @elseAuthor, 
					@ISBN, @publishHouse, @publishTime, @frontCoverFile, 
					@summaryCopyFile, @backCoverFile,
					--����ά�����:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�Ǽ�ר��', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ�ר����' + @monographName + '['+@monographId+']����')
GO

drop PROCEDURE updateMonographInfo
/*
	name:		updateMonographInfo
	function:	15.�޸�ר����Ϣ
	input: 
				@monographId varchar(10),			--ר�����
				@monographName nvarchar(40),		--ר������
				@summary nvarchar(300),				--���ݼ��
				@keys nvarchar(30) ,				--�ؼ��֣�����ؼ���ʹ��","�ָ�
				@monographType int,					--ר������ɵ�53�Ŵ����ֵ䶨��
				@firstAuthorType smallint,			--��һ�������1->�̹���9->ѧ��
				@firstAuthorID varchar(10),			--��һ���߹���
				@tutorID varchar(10),				--��ʦ����:����һ����Ϊѧ��ʱҪ������

				@elseAuthorID varchar(10),			--�������߹��ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
				@elseAuthor nvarchar(30),			--��������������֧�ֶ���ˣ�����"XXX,XXX"��ʽ��š��������

				@ISBN varchar(30),					--����ţ�ȫ��Ϊ����׼��š����Ǳ�ʶ���������ע��ĳ������������ÿһ�ֳ������ÿ���汾�Ĺ����Ե�Ψһ���롣
														--�ҹ����ù��ʱ�׼���International Standard Book Numbering��ISBN����Ϊ�й���׼��š�
														--һ�������Ĺ��ʱ�׼����ɱ�ʶ��ISBN��10λ���±�׼ǰ�����EANǰ׺3λ���ֱ�Ϊ13λ�룩������ɣ����������ְ����Ĳ��֣�
														--�����ţ���������ߵĹ��ҡ����������ɹ���ISBN����ͳһ���÷��䣬�ҹ�Ϊ��7������ʾ���Գ�1�����顣
														--�����ߺţ�����һ�����������й�ISBN���ķֱ����úͷ��䣬����Ϊ2��7λ��
														--������ţ���1��ͼ��1���ţ��ɳ��������з��䡣
														--У���룺�̶���1λ���֡�
														--���磺����������ѡ����һ��ƽװ�������ΪISBN 7-01-005674-9��
				@publishHouse nvarchar(60),			--������
				@publishTime varchar(10),			--����ʱ��
				@frontCoverFile varchar(128),		--�����ϴ���ͼƬ·��
				@summaryCopyFile varchar(128),		--���ݼ���ͼƬ·��
				@backCoverFile varchar(128),		--����ϴ���ͼƬ·��

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ�ר�������ڣ�
							2:Ҫ�޸ĵ�ר���������������༭��
							9:δ֪����
				@modiTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE updateMonographInfo
	@monographId varchar(10),			--ר�����
	@monographName nvarchar(40),		--ר������
	@summary nvarchar(300),				--���ݼ��
	@keys nvarchar(30) ,				--�ؼ��֣�����ؼ���ʹ��","�ָ�
	@monographType int,					--ר������ɵ�53�Ŵ����ֵ䶨��
	@firstAuthorType smallint,			--��һ�������1->�̹���9->ѧ��
	@firstAuthorID varchar(10),			--��һ���߹���
	@tutorID varchar(10),				--��ʦ����:����һ����Ϊѧ��ʱҪ������

	@elseAuthorID varchar(10),			--�������߹��ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
	@elseAuthor nvarchar(30),			--��������������֧�ֶ���ˣ�����"XXX,XXX"��ʽ��š��������

	@ISBN varchar(30),					--����ţ�ȫ��Ϊ����׼��š����Ǳ�ʶ���������ע��ĳ������������ÿһ�ֳ������ÿ���汾�Ĺ����Ե�Ψһ���롣
											--�ҹ����ù��ʱ�׼���International Standard Book Numbering��ISBN����Ϊ�й���׼��š�
											--һ�������Ĺ��ʱ�׼����ɱ�ʶ��ISBN��10λ���±�׼ǰ�����EANǰ׺3λ���ֱ�Ϊ13λ�룩������ɣ����������ְ����Ĳ��֣�
											--�����ţ���������ߵĹ��ҡ����������ɹ���ISBN����ͳһ���÷��䣬�ҹ�Ϊ��7������ʾ���Գ�1�����顣
											--�����ߺţ�����һ�����������й�ISBN���ķֱ����úͷ��䣬����Ϊ2��7λ��
											--������ţ���1��ͼ��1���ţ��ɳ��������з��䡣
											--У���룺�̶���1λ���֡�
											--���磺����������ѡ����һ��ƽװ�������ΪISBN 7-01-005674-9��
	@publishHouse nvarchar(60),			--������
	@publishTime varchar(10),			--����ʱ��
	@frontCoverFile varchar(128),		--�����ϴ���ͼƬ·��
	@summaryCopyFile varchar(128),		--���ݼ���ͼƬ·��
	@backCoverFile varchar(128),		--����ϴ���ͼƬ·��

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������ר���Ƿ����
	declare @count as int
	set @count=(select count(*) from monographInfo where monographId= @monographId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from monographInfo where monographId= @monographId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	--ȡ��һ��������/��ʦ����:����һ����Ϊѧ��ʱҪ�����룺
	declare @firstAuthor nvarchar(30), @tutorName nvarchar(30)
	set @firstAuthor = isnull((select cName from userInfo where jobNumber = @firstAuthorID),'')
	if (@firstAuthorType=9)
		set @tutorName = isnull((select cName from userInfo where jobNumber = @tutorID),'')
	else
		set @tutorName = ''
	
	set @modiTime = getdate()
	update monographInfo
	set monographId = @monographId, monographName = @monographName, summary = @summary, keys = @keys, monographType = @monographType,
		firstAuthorType = @firstAuthorType, firstAuthorID = @firstAuthorID, firstAuthor = @firstAuthor, tutorID = @tutorID, tutorName = @tutorName, 
		elseAuthorID = @elseAuthorID, elseAuthor = @elseAuthor, 
		ISBN = @ISBN, publishHouse = @publishHouse, publishTime = @publishTime, 
		frontCoverFile = @frontCoverFile, summaryCopyFile = @summaryCopyFile, backCoverFile = @backCoverFile,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where monographId= @monographId
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸�ר��', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸���ר����' + @monographName + '['+@monographId+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delMonographInfo
/*
	name:		delMonographInfo
	function:	6.ɾ��ָ����ר��
	input: 
				@monographId varchar(10),		--ר�����
				@delManID varchar(10) output,	--ɾ���ˣ������ǰר�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ר�������ڣ�2��Ҫɾ����ר����������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 

*/
create PROCEDURE delMonographInfo
	@monographId varchar(10),		--ר�����
	@delManID varchar(10) output,	--ɾ���ˣ������ǰר�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������ר���Ƿ����
	declare @count as int
	set @count=(select count(*) from monographInfo where monographId= @monographId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from monographInfo where monographId= @monographId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete monographInfo where monographId= @monographId
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��ר��', '�û�' + @delManName
												+ 'ɾ����ר��['+@monographId+']��')

GO

--ר����ѯ��䣺
select m.monographId, m.monographName, m.summary, m.keys, 
	m.monographType, cd1.objDesc monographTypeDesc,
	m.firstAuthorType, m.firstAuthorID, m.firstAuthor, m.tutorID, m.tutorName,
	m.elseAuthorID, m.elseAuthor,
	m.ISBN, m.publishHouse, CONVERT(varchar(10), m.publishTime, 120) publishTime, m.frontCoverFile, m.summaryCopyFile, m.backCoverFile
from monographInfo m
left join codeDictionary cd1 on m.monographType = cd1.objCode and cd1.classCode = 53


drop PROCEDURE queryPatentInfoLocMan
/*
	name:		queryPatentInfoLocMan
	function:	11.��ѯָ��ר���Ƿ��������ڱ༭
	input: 
				@patentId varchar(10),		--ר�����
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ����ר��������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE queryPatentInfoLocMan
	@patentId varchar(10),		--ר�����
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from patentInfo where patentId= @patentId),'')
	set @Ret = 0
GO


drop PROCEDURE lockPatentInfo4Edit
/*
	name:		lockPatentInfo4Edit
	function:	12.����ר���༭������༭��ͻ
	input: 
				@patentId varchar(10),			--ר�����
				@lockManID varchar(10) output,	--�����ˣ������ǰר�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ������ר�������ڣ�2:Ҫ������ר�����ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE lockPatentInfo4Edit
	@patentId varchar(10),			--ר�����
	@lockManID varchar(10) output,	--�����ˣ������ǰר�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ������ר���Ƿ����
	declare @count as int
	set @count=(select count(*) from patentInfo where patentId= @patentId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from patentInfo where patentId= @patentId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update patentInfo
	set lockManID = @lockManID 
	where patentId= @patentId
	
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����ר���༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ��������ר��['+ @patentId +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockPatentInfoEditor
/*
	name:		unlockPatentInfoEditor
	function:	13.�ͷ�ר���༭��
				ע�⣺�����̲����ר���Ƿ���ڣ�
	input: 
				@patentId varchar(10),			--ר�����
				@lockManID varchar(10) output,	--�����ˣ������ǰר�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE unlockPatentInfoEditor
	@patentId varchar(10),			--ר�����
	@lockManID varchar(10) output,	--�����ˣ������ǰר�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from patentInfo where patentId= @patentId),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update patentInfo set lockManID = '' where patentId= @patentId
	end
	else
	begin
		set @Ret = 0
		return
	end
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷ�ר���༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ���ר��['+ @patentId +']�ı༭����')
GO



drop PROCEDURE addPatentInfo
/*
	name:		addPatentInfo
	function:	14.���ר����Ϣ
	input: 
				@invenName nvarchar(40),	--��������
				@patentType int,			--ר�����ͣ��ɵ�54�Ŵ����ֵ䶨��
				@invenManID varchar(100),	--�����ˣ������ˣ���ר����׼�������˾��Ƿ����ˣ����ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
				@invenMan nvarchar(300),	--�����ˣ������ˣ���ר����׼�������˾��Ƿ����ˣ�������"XXX,XXX"��ʽ��š��������
				@applyTime varchar(10),		--����ʱ��:����"yyyy-MM-dd"��ʽ���
				@isWarranted char(1),		--�Ƿ�����Ȩ��'N'->δ��Ȩ��'Y'����Ȩ
				@warrantTime varchar(10),	--��Ȩʱ��:����"yyyy-MM-dd"��ʽ���
				@patentNum varchar(13),		--ר���ţ�ר������ű����ʽ����12λ���֣�����һ��С���㣩:�������+ר����������+����˳���+�����У��λ
											--ǰ4λ���ֱ�ʾ������ţ���5λ���ֱ�ʾ�������ࣺ
											--1=����ר������,2=ʵ������ר������,3=������ר������,8=�����й����ҽ׶ε�PCT����ר������,9=�����й����ҽ׶ε�PCTʵ������ר������
											--����2003 1 0100002.X ��ʾ����ר������
											--    2003 2 0100002.5 ��ʾʵ������ר������
				@patentCopyFile varchar(128),--ר����ӡ���ϴ�ͼƬ

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@patentId varchar(10) output--ר�����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE addPatentInfo
	@invenName nvarchar(40),	--��������
	@patentType int,			--ר�����ͣ��ɵ�54�Ŵ����ֵ䶨��
	@invenManID varchar(100),	--�����ˣ������ˣ���ר����׼�������˾��Ƿ����ˣ����ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
	@invenMan nvarchar(300),	--�����ˣ������ˣ���ר����׼�������˾��Ƿ����ˣ�������"XXX,XXX"��ʽ��š��������
	@applyTime varchar(10),		--����ʱ��:����"yyyy-MM-dd"��ʽ���
	@isWarranted char(1),		--�Ƿ�����Ȩ��'N'->δ��Ȩ��'Y'����Ȩ
	@warrantTime varchar(10),	--��Ȩʱ��:����"yyyy-MM-dd"��ʽ���
	@patentNum varchar(13),		--ר���ţ�ר������ű����ʽ����12λ���֣�����һ��С���㣩:�������+ר����������+����˳���+�����У��λ
								--ǰ4λ���ֱ�ʾ������ţ���5λ���ֱ�ʾ�������ࣺ
								--1=����ר������,2=ʵ������ר������,3=������ר������,8=�����й����ҽ׶ε�PCT����ר������,9=�����й����ҽ׶ε�PCTʵ������ר������
								--����2003 1 0100002.X ��ʾ����ר������
								--    2003 2 0100002.5 ��ʾʵ������ר������
	@patentCopyFile varchar(128),--ר����ӡ���ϴ�ͼƬ

	@createManID varchar(10),	--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@patentId varchar(10) output--ר�����
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢��������ר����ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 102, 1, @curNumber output
	set @patentId = @curNumber

	--ȡ�����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert patentInfo(patentId, invenName, patentType, invenManID, invenMan, 
					applyTime, isWarranted, warrantTime, patentNum,patentCopyFile,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@patentId, @invenName, @patentType, @invenManID, @invenMan, 
					@applyTime, @isWarranted, @warrantTime, @patentNum, @patentCopyFile,
					--����ά�����:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�Ǽ�ר��', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽ�ר����' + @invenName + '['+@patentId+']����')
GO

drop PROCEDURE updatePatentInfo
/*
	name:		updatePatentInfo
	function:	15.�޸�ר����Ϣ
	input: 
				@patentId varchar(10),		--ר�����
				@invenName nvarchar(40),	--��������
				@patentType int,			--ר�����ͣ��ɵ�54�Ŵ����ֵ䶨��
				@invenManID varchar(100),	--�����ˣ������ˣ���ר����׼�������˾��Ƿ����ˣ����ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
				@invenMan nvarchar(300),	--�����ˣ������ˣ���ר����׼�������˾��Ƿ����ˣ�������"XXX,XXX"��ʽ��š��������
				@applyTime varchar(10),		--����ʱ��:����"yyyy-MM-dd"��ʽ���
				@isWarranted char(1),		--�Ƿ�����Ȩ��'N'->δ��Ȩ��'Y'����Ȩ
				@warrantTime varchar(10),	--��Ȩʱ��:����"yyyy-MM-dd"��ʽ���
				@patentNum varchar(13),		--ר���ţ�ר������ű����ʽ����12λ���֣�����һ��С���㣩:�������+ר����������+����˳���+�����У��λ
											--ǰ4λ���ֱ�ʾ������ţ���5λ���ֱ�ʾ�������ࣺ
											--1=����ר������,2=ʵ������ר������,3=������ר������,8=�����й����ҽ׶ε�PCT����ר������,9=�����й����ҽ׶ε�PCTʵ������ר������
											--����2003 1 0100002.X ��ʾ����ר������
											--    2003 2 0100002.5 ��ʾʵ������ר������
				@patentCopyFile varchar(128),--ר����ӡ���ϴ�ͼƬ

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵ�ר�������ڣ�
							2:Ҫ�޸ĵ�ר���������������༭��
							9:δ֪����
				@modiTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE updatePatentInfo
	@patentId varchar(10),		--ר�����
	@invenName nvarchar(40),	--��������
	@patentType int,			--ר�����ͣ��ɵ�54�Ŵ����ֵ䶨��
	@invenManID varchar(100),	--�����ˣ������ˣ���ר����׼�������˾��Ƿ����ˣ����ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
	@invenMan nvarchar(300),	--�����ˣ������ˣ���ר����׼�������˾��Ƿ����ˣ�������"XXX,XXX"��ʽ��š��������
	@applyTime varchar(10),		--����ʱ��:����"yyyy-MM-dd"��ʽ���
	@isWarranted char(1),		--�Ƿ�����Ȩ��'N'->δ��Ȩ��'Y'����Ȩ
	@warrantTime varchar(10),	--��Ȩʱ��:����"yyyy-MM-dd"��ʽ���
	@patentNum varchar(13),		--ר���ţ�ר������ű����ʽ����12λ���֣�����һ��С���㣩:�������+ר����������+����˳���+�����У��λ
								--ǰ4λ���ֱ�ʾ������ţ���5λ���ֱ�ʾ�������ࣺ
								--1=����ר������,2=ʵ������ר������,3=������ר������,8=�����й����ҽ׶ε�PCT����ר������,9=�����й����ҽ׶ε�PCTʵ������ר������
								--����2003 1 0100002.X ��ʾ����ר������
								--    2003 2 0100002.5 ��ʾʵ������ר������
	@patentCopyFile varchar(128),--ר����ӡ���ϴ�ͼƬ

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������ר���Ƿ����
	declare @count as int
	set @count=(select count(*) from patentInfo where patentId= @patentId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from patentInfo where patentId= @patentId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update patentInfo
	set patentId = @patentId, invenName = @invenName, patentType = @patentType, invenManID = @invenManID, invenMan = @invenMan, 
		applyTime = @applyTime, isWarranted = @isWarranted, warrantTime = @warrantTime,patentNum = @patentNum, patentCopyFile= @patentCopyFile,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where patentId= @patentId
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸�ר��', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸���ר����' + @invenName + '['+@patentId+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delPatentInfo
/*
	name:		delPatentInfo
	function:	6.ɾ��ָ����ר��
	input: 
				@patentId varchar(10),			--ר�����
				@delManID varchar(10) output,	--ɾ���ˣ������ǰר�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ����ר�������ڣ�2��Ҫɾ����ר����������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 

*/
create PROCEDURE delPatentInfo
	@patentId varchar(10),			--ר�����
	@delManID varchar(10) output,	--ɾ���ˣ������ǰר�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ������ר���Ƿ����
	declare @count as int
	set @count=(select count(*) from patentInfo where patentId= @patentId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from patentInfo where patentId= @patentId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete patentInfo where patentId= @patentId
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��ר��', '�û�' + @delManName
												+ 'ɾ����ר��['+@patentId+']��')

GO


--ר����ѯ���:
select p.patentId, p.invenName, p.patentType, cd1.objDesc patentTypeDesc,
	p.invenManID, p.invenMan, convert(varchar(10),p.applyTime,120) applyTime, p.isWarranted, 
	convert(varchar(10),p.warrantTime,120) warrantTime, p.patentNum, p.patentCopyFile
from patentInfo p
left join codeDictionary cd1 on p.patentType = cd1.objCode and cd1.classCode = 54


drop PROCEDURE queryAwardInfoLocMan
/*
	name:		queryAwardInfoLocMan
	function:	11.��ѯָ�����Ƿ��������ڱ༭
	input: 
				@awardId varchar(10),		--�񽱱��
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ļ񽱲�����
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE queryAwardInfoLocMan
	@awardId varchar(10),		--�񽱱��
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from awardInfo where awardId= @awardId),'')
	set @Ret = 0
GO


drop PROCEDURE lockAwardInfo4Edit
/*
	name:		lockAwardInfo4Edit
	function:	12.�����񽱱༭������༭��ͻ
	input: 
				@awardId varchar(10),			--�񽱱��
				@lockManID varchar(10) output,	--�����ˣ������ǰ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ļ񽱲����ڣ�2:Ҫ�����Ļ����ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE lockAwardInfo4Edit
	@awardId varchar(10),			--�񽱱��
	@lockManID varchar(10) output,	--�����ˣ������ǰ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ļ��Ƿ����
	declare @count as int
	set @count=(select count(*) from awardInfo where awardId= @awardId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from awardInfo where awardId= @awardId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update awardInfo
	set lockManID = @lockManID 
	where awardId= @awardId
	
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�����񽱱༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˻�['+ @awardId +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockAwardInfoEditor
/*
	name:		unlockAwardInfoEditor
	function:	13.�ͷŻ񽱱༭��
				ע�⣺�����̲������Ƿ���ڣ�
	input: 
				@awardId varchar(10),			--�񽱱��
				@lockManID varchar(10) output,	--�����ˣ������ǰ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE unlockAwardInfoEditor
	@awardId varchar(10),			--�񽱱��
	@lockManID varchar(10) output,	--�����ˣ������ǰ�������ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from awardInfo where awardId= @awardId),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update awardInfo set lockManID = '' where awardId= @awardId
	end
	else
	begin
		set @Ret = 0
		return
	end
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷŻ񽱱༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˻�['+ @awardId +']�ı༭����')
GO


drop PROCEDURE addAwardInfo
/*
	name:		addAwardInfo
	function:	14.��ӻ���Ϣ
	input: 
				@awardName nvarchar(30),		--������
				@completeManId nvarchar(100),	--�����Ա���������ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ��ţ�������ⲿ��Ա��ȱ���
				@completeMan nvarchar(300),		--�����Ա������������"XXX,XXX"��ʽ��š�������ƣ�������ⲿ��Ա��ȱ���
				@unitRank nvarchar(300),		--��λ������֧�ֶ����λ������"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
				@awardTime varchar(10),			--��ʱ�䣺����"yyyy-MM-dd"��ʽ���
				@certiCopyFile varchar(128),	--֤�鸴ӡ���ϴ�ͼƬ
				@remark nvarchar(100),			--��ע

				@createManID varchar(10),	--�����˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9:δ֪����
				@createTime smalldatetime output,--���ʱ��
				@awardId varchar(10) output--�񽱱��
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE addAwardInfo
	@awardName nvarchar(30),		--������
	@completeManId nvarchar(100),	--�����Ա���������ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ��ţ�������ⲿ��Ա��ȱ���
	@completeMan nvarchar(300),		--�����Ա������������"XXX,XXX"��ʽ��š�������ƣ�������ⲿ��Ա��ȱ���
	@unitRank nvarchar(300),		--��λ������֧�ֶ����λ������"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
	@awardTime varchar(10),			--��ʱ�䣺����"yyyy-MM-dd"��ʽ���
	@certiCopyFile varchar(128),	--֤�鸴ӡ���ϴ�ͼƬ
	@remark nvarchar(100),			--��ע

	@createManID varchar(10),	--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@awardId varchar(10) output--�񽱱��
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢���������񽱱�ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 103, 1, @curNumber output
	set @awardId = @curNumber

	--ȡ�����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')
	
	set @createTime = getdate()
	insert awardInfo(awardId, awardName, completeManId, completeMan, unitRank, awardTime, certiCopyFile, remark,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@awardId, @awardName, @completeManId, @completeMan, @unitRank, @awardTime, @certiCopyFile, @remark,
					--����ά�����:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�Ǽǻ�', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽǻ񽱡�' + @awardName + '['+@awardId+']��Ϣ����')
GO


drop PROCEDURE updateAwardInfo
/*
	name:		updateAwardInfo
	function:	15.�޸Ļ���Ϣ
	input: 
				@awardId varchar(10),		--�񽱱��
				@awardName nvarchar(30),		--������
				@completeManId nvarchar(100),	--�����Ա���������ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ��ţ�������ⲿ��Ա��ȱ���
				@completeMan nvarchar(300),		--�����Ա������������"XXX,XXX"��ʽ��š�������ƣ�������ⲿ��Ա��ȱ���
				@unitRank nvarchar(300),		--��λ������֧�ֶ����λ������"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
				@awardTime varchar(10),			--��ʱ�䣺����"yyyy-MM-dd"��ʽ���
				@certiCopyFile varchar(128),	--֤�鸴ӡ���ϴ�ͼƬ
				@remark nvarchar(100),			--��ע

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵĻ񽱲����ڣ�
							2:Ҫ�޸ĵĻ��������������༭��
							9:δ֪����
				@modiTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE updateAwardInfo
	@awardId varchar(10),		--�񽱱��
	@awardName nvarchar(30),		--������
	@completeManId nvarchar(100),	--�����Ա���������ţ�֧�ֶ���ˣ�����"XXXXXXXXXX,XXXXXXXXXX"��ʽ��ţ�������ⲿ��Ա��ȱ���
	@completeMan nvarchar(300),		--�����Ա������������"XXX,XXX"��ʽ��š�������ƣ�������ⲿ��Ա��ȱ���
	@unitRank nvarchar(300),		--��λ������֧�ֶ����λ������"XXXXXXXXXX,XXXXXXXXXX"��ʽ���
	@awardTime varchar(10),			--��ʱ�䣺����"yyyy-MM-dd"��ʽ���
	@certiCopyFile varchar(128),	--֤�鸴ӡ���ϴ�ͼƬ
	@remark nvarchar(100),			--��ע

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ��Ƿ����
	declare @count as int
	set @count=(select count(*) from awardInfo where awardId= @awardId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from awardInfo where awardId= @awardId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')

	set @modiTime = getdate()
	update awardInfo
	set awardId = @awardId, awardName = @awardName, completeManId = @completeManId, completeMan = @completeMan, 
		unitRank = @unitRank, awardTime = @awardTime, certiCopyFile = @certiCopyFile, remark = @remark,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where awardId= @awardId
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸Ļ�', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸��˻񽱡�' + @awardName + '['+@awardId+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delAwardInfo
/*
	name:		delAwardInfo
	function:	6.ɾ��ָ���Ļ�
	input: 
				@awardId varchar(10),			--�񽱱��
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ļ񽱲����ڣ�2��Ҫɾ���Ļ���������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 

*/
create PROCEDURE delAwardInfo
	@awardId varchar(10),			--�񽱱��
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ļ��Ƿ����
	declare @count as int
	set @count=(select count(*) from awardInfo where awardId= @awardId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from awardInfo where awardId= @awardId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete awardInfo where awardId= @awardId
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ����', '�û�' + @delManName
												+ 'ɾ���˻�['+@awardId+']��Ϣ��')

GO

--�񽱲�ѯ��䣺
select a.awardId, a.awardName, a.completeManId, a.completeMan, a.unitRank, 
	convert(varchar(10),a.awardTime,120) awardTime, a.certiCopyFile, a.remark
from awardInfo a

drop PROCEDURE queryProjectInfoLocMan
/*
	name:		queryProjectInfoLocMan
	function:	11.��ѯָ��������Ŀ�Ƿ��������ڱ༭
	input: 
				@projectId varchar(10),		--������Ŀ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���9����ѯ����������ָ���Ŀ�����Ŀ������
				@lockManID varchar(10) output		--��ǰ���ڱ༭���˵Ĺ���
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE queryProjectInfoLocMan
	@projectId varchar(10),		--������Ŀ���
	@Ret int output,			--�����ɹ���ʶ
	@lockManID varchar(10) output	--��ǰ���ڱ༭���˵Ĺ���
	WITH ENCRYPTION 
AS
	set @Ret = 9
	set @lockManID = isnull((select lockManID from projectInfo where projectId= @projectId),'')
	set @Ret = 0
GO


drop PROCEDURE lockProjectInfo4Edit
/*
	name:		lockProjectInfo4Edit
	function:	12.����������Ŀ�༭������༭��ͻ
	input: 
				@projectId varchar(10),			--������Ŀ���
				@lockManID varchar(10) output,	--�����ˣ������ǰ������Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���1��Ҫ�����Ŀ�����Ŀ�����ڣ�2:Ҫ�����Ŀ�����Ŀ���ڱ����˱༭��
							9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE lockProjectInfo4Edit
	@projectId varchar(10),			--������Ŀ���
	@lockManID varchar(10) output,	--�����ˣ������ǰ������Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--�ж�Ҫ�����Ŀ�����Ŀ�Ƿ����
	declare @count as int
	set @count=(select count(*) from projectInfo where projectId= @projectId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from projectInfo where projectId= @projectId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @lockManID)
	begin
		set @lockManID = @thisLockMan
		set @Ret = 2
		return
	end

	update projectInfo
	set lockManID = @lockManID 
	where projectId= @projectId
	
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '����������Ŀ�༭', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ�������˿�����Ŀ['+ @projectId +']Ϊ��ռʽ�༭��')
GO

drop PROCEDURE unlockProjectInfoEditor
/*
	name:		unlockProjectInfoEditor
	function:	13.�ͷſ�����Ŀ�༭��
				ע�⣺�����̲���������Ŀ�Ƿ���ڣ�
	input: 
				@projectId varchar(10),			--������Ŀ���
				@lockManID varchar(10) output,	--�����ˣ������ǰ������Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret int output					--�����ɹ���ʶ
												0:�ɹ���1��Ҫ�ͷű༭���������˲����Լ���9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE unlockProjectInfoEditor
	@projectId varchar(10),			--������Ŀ���
	@lockManID varchar(10) output,	--�����ˣ������ǰ������Ŀ�����ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret int output					--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from projectInfo where projectId= @projectId),'')
	if (@thisLockMan <> '')
	begin
		if (@thisLockMan <> @lockManID)
		begin
			set @lockManID = @thisLockMan
			set @Ret = 1
			return
		end
		update projectInfo set lockManID = '' where projectId= @projectId
	end
	else
	begin
		set @Ret = 0
		return
	end
	set @Ret = 0

	--ȡά���˵�������
	declare @lockManName nvarchar(30)
	set @lockManName = isnull((select userCName from activeUsers where userID = @lockManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@lockManID, @lockManName, getdate(), '�ͷſ�����Ŀ�༭��', 'ϵͳ�����û�' + @lockManName
												+ '��Ҫ���ͷ��˿�����Ŀ['+ @projectId +']�ı༭����')
GO


drop PROCEDURE addProjectInfo
/*
	name:		addProjectInfo
	function:	14.��ӿ�����Ŀ��Ϣ
	input: 
				@projectNum varchar(30),			--��Ŀ��ţ�ѧУ�ı�ţ�
				@consignUnit nvarchar(60),			--ί�е�λ
				@consignUnitLocateCode varchar(6),	--ί�е�λ��Դ��������
				@securityClass int,					--�ܼ����ɵ�57�Ŵ����ֵ䶨��
				@projectName nvarchar(30),			--��Ŀ����
				@applyTime varchar(10),				--��Ŀ�걨ʱ��:����"yyyy-MM-dd"��ʽ���
				
				@projectNature int,					--��Ŀ���ʣ��ɵ�55�Ŵ����ֵ䶨��
				@projectType int,					--��Ŀ����ɵ�56�Ŵ����ֵ䶨��
				@projectFund numeric(12,2),			--��Ŀ���ѣ���Ԫ��
				@startTime varchar(10),				--��ʼʱ��:����"yyyy-MM-dd"��ʽ���
				@endTime varchar(10),				--����ʱ��:����"yyyy-MM-dd"��ʽ���
				@projectManagerID varchar(10),		--��Ŀ�����˹���
				@summary nvarchar(300),				--�о�����ժҪ

				@createManID varchar(10),			--�����˹���
	output: 
				@Ret		int output				--�����ɹ���ʶ:0:�ɹ���9:δ֪����
				@createTime smalldatetime output,	--���ʱ��
				@projectId varchar(10) output		--������Ŀ���(ϵͳ�ڲ����)
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE addProjectInfo
	@projectNum varchar(30),			--��Ŀ��ţ�ѧУ�ı�ţ�
	@consignUnit nvarchar(60),			--ί�е�λ
	@consignUnitLocateCode varchar(6),	--ί�е�λ��Դ��������
	@securityClass int,					--�ܼ����ɵ�57�Ŵ����ֵ䶨��
	@projectName nvarchar(30),			--��Ŀ����
	@applyTime varchar(10),				--��Ŀ�걨ʱ��:����"yyyy-MM-dd"��ʽ���
	
	@projectNature int,					--��Ŀ���ʣ��ɵ�55�Ŵ����ֵ䶨��
	@projectType int,					--��Ŀ����ɵ�56�Ŵ����ֵ䶨��
	@projectFund numeric(12,2),			--��Ŀ���ѣ���Ԫ��
	@startTime varchar(10),				--��ʼʱ��:����"yyyy-MM-dd"��ʽ���
	@endTime varchar(10),				--����ʱ��:����"yyyy-MM-dd"��ʽ���
	@projectManagerID varchar(10),		--��Ŀ�����˹���
	@summary nvarchar(300),				--�о�����ժҪ

	@createManID varchar(10),			--�����˹���
	@Ret		int output,
	@createTime smalldatetime output,
	@projectId varchar(10) output		--������Ŀ���(ϵͳ�ڲ����)
	WITH ENCRYPTION 
AS
	set @Ret = 9
	--ʹ�ú��뷢��������������Ŀ��ţ�
	declare @curNumber varchar(50)
	exec dbo.getClassNumber 104, 1, @curNumber output
	set @projectId = @curNumber

	--ȡ�����˵�������
	declare @createManName nvarchar(30)
	set @createManName = isnull((select userCName from activeUsers where userID = @createManID),'')

	--ȡ��Ŀ������������
	declare @projectManager nvarchar(30)		--��Ŀ������
	set @projectManager = isnull((select cName from userInfo where jobNumber = @projectManagerID),'')
	
	set @createTime = getdate()
	insert projectInfo(projectId, projectNum, consignUnit, consignUnitLocateCode, securityClass, projectName, applyTime,
					projectNature, projectType, projectFund, startTime, endTime, projectManagerID, projectManager, summary,
					--����ά�����:
					modiManID, modiManName, modiTime)
	values(@projectId, @projectNum, @consignUnit, @consignUnitLocateCode, @securityClass, @projectName, @applyTime,
					@projectNature, @projectType, @projectFund, @startTime, @endTime, @projectManagerID, @projectManager, @summary,
					--����ά�����:
					@createManID, @createManName, @createTime)
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@createManID, @createManName, @createTime, '�Ǽǿ�����Ŀ', 'ϵͳ�����û�' + @createManName + 
					'��Ҫ��Ǽǿ�����Ŀ��' + @projectName + '['+@projectId+']��Ϣ����')
GO

drop PROCEDURE updateProjectInfo
/*
	name:		updateProjectInfo
	function:	15.�޸Ŀ�����Ŀ��Ϣ
	input: 
				@projectId varchar(10),				--������Ŀ���
				@projectNum varchar(30),			--��Ŀ��ţ�ѧУ�ı�ţ�
				@consignUnit nvarchar(60),			--ί�е�λ
				@consignUnitLocateCode varchar(6),	--ί�е�λ��Դ��������
				@securityClass int,					--�ܼ����ɵ�57�Ŵ����ֵ䶨��
				@projectName nvarchar(30),			--��Ŀ����
				@applyTime varchar(10),				--��Ŀ�걨ʱ��:����"yyyy-MM-dd"��ʽ���
				
				@projectNature int,					--��Ŀ���ʣ��ɵ�55�Ŵ����ֵ䶨��
				@projectType int,					--��Ŀ����ɵ�56�Ŵ����ֵ䶨��
				@projectFund numeric(12,2),			--��Ŀ���ѣ���Ԫ��
				@startTime varchar(10),				--��ʼʱ��:����"yyyy-MM-dd"��ʽ���
				@endTime varchar(10),				--����ʱ��:����"yyyy-MM-dd"��ʽ���
				@projectManagerID varchar(10),		--��Ŀ�����˹���
				@summary nvarchar(300),				--�о�����ժҪ

				@modiManID varchar(10) output,	--�޸��˹���
	output: 
				@Ret		int output		--�����ɹ���ʶ
							0:�ɹ���
							1:Ҫ�޸ĵĿ�����Ŀ�����ڣ�
							2:Ҫ�޸ĵĿ�����Ŀ�������������༭��
							9:δ֪����
				@modiTime smalldatetime output	--���ʱ��
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 
*/
create PROCEDURE updateProjectInfo
	@projectId varchar(10),				--������Ŀ���
	@projectNum varchar(30),			--��Ŀ��ţ�ѧУ�ı�ţ�
	@consignUnit nvarchar(60),			--ί�е�λ
	@consignUnitLocateCode varchar(6),	--ί�е�λ��Դ��������
	@securityClass int,					--�ܼ����ɵ�57�Ŵ����ֵ䶨��
	@projectName nvarchar(30),			--��Ŀ����
	@applyTime varchar(10),				--��Ŀ�걨ʱ��:����"yyyy-MM-dd"��ʽ���
	
	@projectNature int,					--��Ŀ���ʣ��ɵ�55�Ŵ����ֵ䶨��
	@projectType int,					--��Ŀ����ɵ�56�Ŵ����ֵ䶨��
	@projectFund numeric(12,2),			--��Ŀ���ѣ���Ԫ��
	@startTime varchar(10),				--��ʼʱ��:����"yyyy-MM-dd"��ʽ���
	@endTime varchar(10),				--����ʱ��:����"yyyy-MM-dd"��ʽ���
	@projectManagerID varchar(10),		--��Ŀ�����˹���
	@summary nvarchar(300),				--�о�����ժҪ

	@modiManID varchar(10) output,	--�޸��˹���
	@Ret		int output,
	@modiTime smalldatetime output	--�޸�ʱ��
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ŀ�����Ŀ�Ƿ����
	declare @count as int
	set @count=(select count(*) from projectInfo where projectId= @projectId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from projectInfo where projectId= @projectId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @modiManID)
	begin
		set @modiManID = @thisLockMan
		set @Ret = 2
		return
	end

	--ȡά���˵�������
	declare @modiManName nvarchar(30)
	set @modiManName = isnull((select userCName from activeUsers where userID = @modiManID),'')
	
	--ȡ��Ŀ������������
	declare @projectManager nvarchar(30)		--��Ŀ������
	set @projectManager = isnull((select cName from userInfo where jobNumber = @projectManagerID),'')

	set @modiTime = getdate()
	update projectInfo
	set projectId = @projectId, projectNum = @projectNum, consignUnit = @consignUnit, consignUnitLocateCode = @consignUnitLocateCode, 
					securityClass = @securityClass, projectName = @projectName, applyTime = @applyTime,
					projectNature = @projectNature, projectType = @projectType, projectFund = @projectFund, 
					startTime = @startTime, endTime = @endTime, projectManagerID = @projectManagerID, projectManager = @projectManager, summary = @summary,
		--����ά�����:
		modiManID = @modiManID, modiManName = @modiManName, modiTime = @modiTime
	where projectId= @projectId
	if @@ERROR <> 0 
	begin
		set @Ret = 9
		return
	end    
	
	set @Ret = 0

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@modiManID, @modiManName, @modiTime, '�޸Ŀ�����Ŀ', 'ϵͳ�����û�' + @modiManName + 
					'��Ҫ���޸��˿�����Ŀ��' + @projectName + '['+@projectId+']���ĵǼ���Ϣ��')
GO

drop PROCEDURE delProjectInfo
/*
	name:		delProjectInfo
	function:	6.ɾ��ָ���Ŀ�����Ŀ
	input: 
				@projectId varchar(10),			--������Ŀ���
				@delManID varchar(10) output,	--ɾ���ˣ������ǰ������Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	output: 
				@Ret		int output			--�����ɹ���ʶ
							0:�ɹ���1��ָ���Ŀ�����Ŀ�����ڣ�2��Ҫɾ���Ŀ�����Ŀ��������������9��δ֪����
	author:		¬έ
	CreateDate:	2012-12-22
	UpdateDate: 

*/
create PROCEDURE delProjectInfo
	@projectId varchar(10),			--������Ŀ���
	@delManID varchar(10) output,	--ɾ���ˣ������ǰ������Ŀ���ڱ���ռ�ñ༭�򷵻ظ��˵Ĺ���
	@Ret		int output			--�����ɹ���ʶ
	WITH ENCRYPTION 
AS
	set @Ret = 9

	--�ж�Ҫ�����Ŀ�����Ŀ�Ƿ����
	declare @count as int
	set @count=(select count(*) from projectInfo where projectId= @projectId)	
	if (@count = 0)	--������
	begin
		set @Ret = 1
		return
	end

	--���༭����
	declare @thisLockMan varchar(10)
	set @thisLockMan = isnull((select lockManID from projectInfo where projectId= @projectId),'')
	if (@thisLockMan <> '' and @thisLockMan <> @delManID)
	begin
		set @delManID = @thisLockMan
		set @Ret = 2
		return
	end

	delete projectInfo where projectId= @projectId
	set @Ret = 0

	--ȡά���˵�������
	declare @delManName nvarchar(30)
	set @delManName = isnull((select userCName from activeUsers where userID = @delManID),'')

	--�Ǽǹ�����־��
	insert workNote(userID, userName, actionTime, actions, actionObject)
	values(@delManID, @delManName, getdate(), 'ɾ��������Ŀ', '�û�' + @delManName
												+ 'ɾ���˿�����Ŀ['+@projectId+']��Ϣ��')

GO

--������Ŀ��
select p.projectId, p.projectNum, p.consignUnit, p.consignUnitLocateCode, p.securityClass, cd1.objDesc securityClassDesc,
	p.projectName, convert(varchar(10),p.applyTime,120) applyTime, p.projectNature, cd2.objDesc projectNatureDesc,
	p.projectType, cd3.objDesc projectTypeDesc,
	p.projectFund, convert(char(10),p.startTime,120) startTime, convert(varchar(10),p.endTime,120)endTime,
	p.projectManagerID, p.projectManager, p.summary
from projectInfo p
left join codeDictionary cd1 on p.securityClass = cd1.objCode and cd1.classCode = 57
left join codeDictionary cd2 on p.projectNature = cd2.objCode and cd2.classCode = 55
left join codeDictionary cd3 on p.projectType = cd3.objCode and cd3.classCode = 56


