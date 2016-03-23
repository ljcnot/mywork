use epdc211
/*
	武大设备管理信息系统-特种设备附加信息
	author:		卢苇
	CreateDate:	2012-9-29
	UpdateDate: 
*/
--1.eqpCarExtAcceptInfo（特种设备-车辆验收扩展信息表）：
drop TABLE eqpCarExtAcceptInfo
CREATE TABLE eqpCarExtAcceptInfo(
	acceptApplyID char(12) not null,--主键/外键：验收单号
	eCode char(8) null,				--设备编号
	origin int null,				--车辆产地(CheLCDID),由第20号代码字典定义
	carModle nvarchar(30) null,		--规格型号(Spec)
	chassisNumber nvarchar(36) null,--车架号(CheJH)	
	licensePlate nvarchar(10) null,	--车牌号(ChePH)	
	brandModel nvarchar(20) null,	--厂牌型号(ChangPXH)	
	engineNumber nvarchar(20) null,	--发动机号(FaDJH)	
	powerNumber varchar(4) null,	--排气量(PaiQL)	
	--arrangePlait int null,		--编制情况(BianZQKID),由第
	useDirection int null,			--车辆用途分类，由第21号代码字典定义

 CONSTRAINT [PK_eqpCarExtAcceptInfo] PRIMARY KEY CLUSTERED 
(
	[acceptApplyID] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[eqpCarExtAcceptInfo] WITH CHECK ADD CONSTRAINT [FK_eqpCarExtAcceptInfo_eqpAcceptInfo] FOREIGN KEY([acceptApplyID])
REFERENCES [dbo].[eqpAcceptInfo] ([acceptApplyID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpCarExtAcceptInfo] CHECK CONSTRAINT [FK_eqpCarExtAcceptInfo_eqpAcceptInfo]
GO

--索引：
--设备编号:
CREATE NONCLUSTERED INDEX [IX_eqpCarExtAcceptInfo] ON [dbo].[eqpCarExtAcceptInfo] 
(
	[eCode] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

--车牌号:
CREATE NONCLUSTERED INDEX [IX_eqpCarExtAcceptInfo_1] ON [dbo].[eqpCarExtAcceptInfo] 
(
	[licensePlate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]


--2.eqpCarExtInfo（特种设备-车辆扩展信息表）：
drop TABLE eqpCarExtInfo
CREATE TABLE eqpCarExtInfo(
	eCode char(8) not null,			--主键/外键：设备编号
	origin int null,				--车辆产地(CheLCDID),由第20号代码字典定义
	carModle nvarchar(30) null,		--规格型号(Spec)
	chassisNumber nvarchar(36) null,--车架号(CheJH)	
	licensePlate nvarchar(10) null,	--车牌号(ChePH)	
	brandModel nvarchar(20) null,	--厂牌型号(ChangPXH)	
	engineNumber nvarchar(20) null,	--发动机号(FaDJH)	
	powerNumber varchar(4) null,	--排气量(PaiQL)	
	--arrangePlait int null,		--编制情况(BianZQKID),由第
	useDirection int null,			--车辆用途分类，由第21号代码字典定义

 CONSTRAINT [PK_eqpCarExtInfo] PRIMARY KEY CLUSTERED 
(
	[eCode] ASC
)WITH (IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

--外键：
ALTER TABLE [dbo].[eqpCarExtInfo] WITH CHECK ADD CONSTRAINT [FK_eqpCarExtInfo_equipmentList] FOREIGN KEY([eCode])
REFERENCES [dbo].[equipmentList] ([eCode])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[eqpCarExtInfo] CHECK CONSTRAINT [FK_eqpCarExtInfo_equipmentList]
GO

--索引：
--车牌号:
CREATE NONCLUSTERED INDEX [IX_eqpCarExtInfo] ON [dbo].[eqpCarExtInfo] 
(
	[licensePlate] ASC
)WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF) ON [PRIMARY]

