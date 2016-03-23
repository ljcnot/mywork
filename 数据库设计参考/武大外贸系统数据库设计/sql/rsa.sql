RSA加密算法

--判断是否为素数
if object_id('f_primeNumTest') is not null

 drop function f_primeNumTest

go

create function [dbo].[f_primeNumTest]
(@p int)
returns bit
begin
	declare @flg bit,@i int
	select @flg=1, @i=2
	while @i<sqrt(@p)
	begin
		if(@p%@i=0 )
		begin
			set @flg=0
			break
		end 
		set @i=@i+1
	end
	return @flg
end
go

--判断两个数是否互素
if object_id('f_isNumsPrime') is not null
 drop function f_isNumsPrime
go

create function f_isNumsPrime
(@num1 int,@num2 int)
returns bit
begin
	declare @tmp int,@flg bit
	set @flg=1
	while (@num2%@num1<>0)
	begin
		select @tmp=@num1,@num1=@num2%@num1,@num2=@tmp
	end
	if @num1=1
		set @flg=0
	return @flg
end
go

--产生密钥对
if object_id('p_createKey') is not null
 drop proc p_createKey
go

create proc p_createKey
@p int,@q int
as
begin
	declare @n bigint,@t bigint,@flag int,@d int
    if dbo.f_primeNumTest(@p)=0
    begin
print cast(@p as varchar)+'不是素数，请重新选择数据'
		return
    end

    if dbo.f_primeNumTest(@q)=0
    begin
print cast(@q as varchar)+'不是素数，请重新选择数据'
		return
	end
print '请从下列数据中选择其中一对，作为密钥'
    select @n=@p*@q,@t=(@p-1)*(@q-1)
    declare @e int
    set @e=2
    while @e<@t
    begin
		if dbo.f_isNumsPrime(@e,@t)=0
		begin
			set @d=2
			while @d<@n
            begin
				if(@e*@d%@t=1)
					print cast(@e as varchar)+space(5)+cast(@d as varchar)
				set @d=@d+1
            end
		end
		set @e=@e+1        
	end
end
go

 

/*加密函数说明，@key 为上一个存储过程中选择的密码中的一个 ,@p ,@q 产生密钥对时选择的两个数。获取每一个字符的unicode值，然后进行加密，产生3个字节的16位数据*/
if object_id('f_RSAEncry') is not null
 drop function f_RSAEncry
go

create function f_RSAEncry
(@s varchar(100),@key int ,@p int ,@q int)
returns nvarchar(4000)
as
begin
	declare @crypt varchar(8000)
    set @crypt=''
	while len(@s)>0
	begin
		declare @i bigint,@tmp varchar(10),@k2 int,@leftchar int
		select @leftchar=unicode(left(@s,1)),@k2=@key/2,@i=1
		while @k2>0
		begin
			set @i=(cast(power(@leftchar,2) as bigint)*@i)%(@p*@q)
			set @k2=@k2-1
		end 
		set @i=(@leftchar*@i)%(@p*@q)    
		set @tmp=''
		select @tmp=case when @i%16 between 10 and 15 then char( @i%16+55) else cast(@i%16 as varchar) end +@tmp,@i=@i/16
		from (select number from master.dbo.spt_values where type='p' and number<10 )K
		order by number desc

		set @crypt=@crypt+right(@tmp,6)
		set @s=stuff(@s,1,1,'')
	end
	return @crypt
end
go

 

--解密：@key 为一个存储过程中选择的密码对中另一个数字 ,@p ,@q 产生密钥对时选择的两个数
if object_id('f_RSADecry') is not null
 drop function f_RSADecry
go

create function f_RSADecry
(@s nvarchar(4000),@key int ,@p int ,@q int)
returns nvarchar(4000)
as
begin
	declare @crypt varchar(8000)
	set @crypt=''
	while len(@s)>0
    begin
		declare @leftchar bigint
		select @leftchar=sum(data1)
		from (select case upper(substring(left(@s,6), number, 1)) when 'A' then 10 
						when 'B' then 11
						when 'C' then 12 
						when 'D' then 13 
						when 'E' then 14
						when 'F' then 15 
						else substring(left(@s,6), number, 1)
					end* power(16, len(left(@s,6)) - number) data1 
				from (select number from master.dbo.spt_values where type='p')K
		where number <= len(left(@s,6))) L
		declare @k2 int,@j bigint
		select @k2=@key/2,@j=1
		while @k2>0
		begin
			set @j=(cast(power(@leftchar,2)as bigint)*@j)%(@p*@q)
			set @k2=@k2-1
		end 
		set @j=(@leftchar*@j)%(@p*@q)
		set @crypt=@crypt+nchar(@j)
		set @s=stuff(@s,1,6,'')
	end
	return @crypt
end
go

--测试：
if object_id('tb') is not null
   drop table tb
go

create table tb(id int identity(1,1),col varchar(100))
go
--加密：
insert into tb values(dbo.f_RSAEncry('中国人',779,1163,59))
insert into tb values(dbo.f_RSAEncry('Chinese',779,1163,59))
insert into tb values(dbo.f_RSAEncry('ChineseMan',779,1163,59))

--解密：
select *, dbo.f_RSADecry(col,35039,1163,59) from tb






--MD5
/*
	MD5算法是MD4算法的改进算法。Ron Rivest于1990年提出MD4单向散列函数，MD表示消息摘要(Message Digest)，对输入消息，算法产生128位散列值。
该算法首次公布之后，Ben den Boer和Antoon Bosselaers对算法三轮中的后两轮进行了成功的密码分析。在一个不相关的分析结果中，Ralph MerKle成功
地攻击了前两轮。尽管这些攻击都没有扩展到整个算法，但Rivest还是改进了其算法，结果就是MD5算法。MD5算法是MIM 的改进算法，它比MIM更复杂，但
设计思想相似，输入的消息可任意长，输出结果也仍为128位，特别适用于高速软件实现，是基于32位操作数的一些简单的位操作。
	算法描述：
	该算法的输入是一个字节串，每个字节8个bit。  
	算法的执行分为以下几个步骤：
	第一步．补位：
	MD5算法先对输入的数据进行补位，使得数据的长度(以byte为单位)对64求余的结果是56。即数据扩展至LEN=K*64+56个字节 ，K为整数。
	补位方法：补一个l，然后补0至满足上述要求。相当于补一个0x80的字节，再补值为0的字节。这一步里总共补充的字节数为0～63个。
	第二步，附加数据长度：
	用一个64位的整数表示数据的原始长度(以bit为单位)，将这个数字的8个字节按低位的在前，高位在后的顺序附加在补位后的数据后面。这时，数据被填补后的总长度为：
	LEN =K*64+56+8 (K+1)*64 Bytes。
	※ 注意那个64位整数是输入数据的原始长度而不是填充字节后的长度。
	第三步，初始化MD5参数：
	有4个32位整数变量(A，B，C，D)用来计算信息摘要，每一个变量被初始化成以下以十六进制数表示的数值，低位的字节在前面。
			word A：01 23 45 67
			word B：89 ab cd ef
			word C：fe dc ba 98
			word D：76 54 32 10
	第四步，定义四个MD5基本的按位操作函数：
	x，Y，z为32位整数。
	F(X，Y，Z)=(X and Y)or(not(x)and z)
	c(x，Y，z)= (X and Z)or(Y and not(Z))
	II(a，b，c，d，Mj，s，ti )表示a=b+((a+(H(b，c，d)++ ti)<<<s)
	I(x，Y，Z)=Y or(X or not(z))  
	再定义四个分别用于四轮变换的函数。
	设Mj表示消息的第J个子分组(从0到l5)，<<<S表示循环左移S位，则四种操作为：
	FF(a, b, c，d，Mj，s，ti)表示a=b+((a+(F(b，c，d)+Mj+ti)<<<s)
	G(X，Y，Z)= (x and z)or(Y and not(Z))
	ml(a，b，c，d，Mj，s，ti)表示a=b+((a+(rI(b，c，d)+Mi+ti)<<<s)
	Ⅱ(a，b，c，d，Mj's'ti)表示a=b+((a+(I(b，c，d)+Mj+ti)<<<s)
	第五步，对输入数据作变换：
	处理数据，N是总的字节数，以64个字节为一组，每组作一次循环，每次循环进行四轮操作。要变换的64个字节用16个32位的整数数
	组M[0……15]表示。而数组T[1……64]表示一组常数，T[i]为4294967296*abs(sin(i))的32位整数部分，i的单位是弧度，i的取值从1到64。
	MD5的典型应用是对一段信息(message)产生信息摘要(message—digest)，以防止被篡改。比如，在unix下有很多软件在下载的时候都
有一个文件名相同，文件扩展名为．md5的文件，在这个文件中通常只有一行文本，大致结构如：
	MD5(tanajiya．tar．gz)= 0ca17569cOf726a831d895e269332461
	这就是tanajiya．tar．gz文件的数字签名。MD5将整个文件当作一个大文本信息，通过其不可逆的任何形式的改变(包括人为修字符串
变换算法，产生了这个唯一的MD5信息摘要。如果在以后传播这个文件的过程中，无论文件的内容发生了改或者下载过程中线路不稳定引起
的传输错误等)，只要你对这个文件重新计算MD5时就会发现信息摘要不相同，由此可以确定你得到的只是一个不正确的文件。如果再有一个
第三方的认证机构，用MD5还可以防止文件作者的“抵赖”，这就是所谓的数字签名应用。
	MD5算法目前已经较为完善，大部分编程语言(环境)都提供了MD5算法的实现。
	数字签名可以保证信息的原始性、完整性。因此，数字签名可以解决否认、伪造、篡改及冒充等问题。具体要求：发送：昔事后不能否
认发送的报文签名、接收者能够核实发送者发送的报文签名、接收者不能伪造发送者的报文签名、接收者不能对发送者的报文进行部分篡改、
网络中的某一用户不能冒充另一用户作为发送者或接收者。数字签名的应用范围十分广泛，在保障电子数据交换(EDI)的安全性上是一个突破
性的进展，凡是需要对用户的身份进行判断的情况都可以使用数字签名，比如加密信件、商务信函、定货购买系统、远程金融交易、电子政
务、自动模式处理等等。 
*/
public string EncryptStr(string PWD, int Format)
{
    string str = "";
    switch (Format)
    {
        case 0:
            str = FormsAuthentication.HashPasswordForStoringInConfigFile(PWD, "SHA1");
            break;
        case 1:
            str = FormsAuthentication.HashPasswordForStoringInConfigFile(PWD, "MD5");
            break;
    }
    return str;
}
money