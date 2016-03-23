RSA�����㷨

--�ж��Ƿ�Ϊ����
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

--�ж��������Ƿ���
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

--������Կ��
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
print cast(@p as varchar)+'����������������ѡ������'
		return
    end

    if dbo.f_primeNumTest(@q)=0
    begin
print cast(@q as varchar)+'����������������ѡ������'
		return
	end
print '�������������ѡ������һ�ԣ���Ϊ��Կ'
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

 

/*���ܺ���˵����@key Ϊ��һ���洢������ѡ��������е�һ�� ,@p ,@q ������Կ��ʱѡ�������������ȡÿһ���ַ���unicodeֵ��Ȼ����м��ܣ�����3���ֽڵ�16λ����*/
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

 

--���ܣ�@key Ϊһ���洢������ѡ������������һ������ ,@p ,@q ������Կ��ʱѡ���������
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

--���ԣ�
if object_id('tb') is not null
   drop table tb
go

create table tb(id int identity(1,1),col varchar(100))
go
--���ܣ�
insert into tb values(dbo.f_RSAEncry('�й���',779,1163,59))
insert into tb values(dbo.f_RSAEncry('Chinese',779,1163,59))
insert into tb values(dbo.f_RSAEncry('ChineseMan',779,1163,59))

--���ܣ�
select *, dbo.f_RSADecry(col,35039,1163,59) from tb






--MD5
/*
	MD5�㷨��MD4�㷨�ĸĽ��㷨��Ron Rivest��1990�����MD4����ɢ�к�����MD��ʾ��ϢժҪ(Message Digest)����������Ϣ���㷨����128λɢ��ֵ��
���㷨�״ι���֮��Ben den Boer��Antoon Bosselaers���㷨�����еĺ����ֽ����˳ɹ��������������һ������صķ�������У�Ralph MerKle�ɹ�
�ع�����ǰ���֡�������Щ������û����չ�������㷨����Rivest���ǸĽ������㷨���������MD5�㷨��MD5�㷨��MIM �ĸĽ��㷨������MIM�����ӣ���
���˼�����ƣ��������Ϣ�����ⳤ��������Ҳ��Ϊ128λ���ر������ڸ������ʵ�֣��ǻ���32λ��������һЩ�򵥵�λ������
	�㷨������
	���㷨��������һ���ֽڴ���ÿ���ֽ�8��bit��  
	�㷨��ִ�з�Ϊ���¼������裺
	��һ������λ��
	MD5�㷨�ȶ���������ݽ��в�λ��ʹ�����ݵĳ���(��byteΪ��λ)��64����Ľ����56����������չ��LEN=K*64+56���ֽ� ��KΪ������
	��λ��������һ��l��Ȼ��0����������Ҫ���൱�ڲ�һ��0x80���ֽڣ��ٲ�ֵΪ0���ֽڡ���һ�����ܹ�������ֽ���Ϊ0��63����
	�ڶ������������ݳ��ȣ�
	��һ��64λ��������ʾ���ݵ�ԭʼ����(��bitΪ��λ)����������ֵ�8���ֽڰ���λ����ǰ����λ�ں��˳�򸽼��ڲ�λ������ݺ��档��ʱ�����ݱ������ܳ���Ϊ��
	LEN =K*64+56+8 (K+1)*64 Bytes��
	�� ע���Ǹ�64λ�������������ݵ�ԭʼ���ȶ���������ֽں�ĳ��ȡ�
	����������ʼ��MD5������
	��4��32λ��������(A��B��C��D)����������ϢժҪ��ÿһ����������ʼ����������ʮ����������ʾ����ֵ����λ���ֽ���ǰ�档
			word A��01 23 45 67
			word B��89 ab cd ef
			word C��fe dc ba 98
			word D��76 54 32 10
	���Ĳ��������ĸ�MD5�����İ�λ����������
	x��Y��zΪ32λ������
	F(X��Y��Z)=(X and Y)or(not(x)and z)
	c(x��Y��z)= (X and Z)or(Y and not(Z))
	II(a��b��c��d��Mj��s��ti )��ʾa=b+((a+(H(b��c��d)++ ti)<<<s)
	I(x��Y��Z)=Y or(X or not(z))  
	�ٶ����ĸ��ֱ��������ֱ任�ĺ�����
	��Mj��ʾ��Ϣ�ĵ�J���ӷ���(��0��l5)��<<<S��ʾѭ������Sλ�������ֲ���Ϊ��
	FF(a, b, c��d��Mj��s��ti)��ʾa=b+((a+(F(b��c��d)+Mj+ti)<<<s)
	G(X��Y��Z)= (x and z)or(Y and not(Z))
	ml(a��b��c��d��Mj��s��ti)��ʾa=b+((a+(rI(b��c��d)+Mi+ti)<<<s)
	��(a��b��c��d��Mj's'ti)��ʾa=b+((a+(I(b��c��d)+Mj+ti)<<<s)
	���岽���������������任��
	�������ݣ�N���ܵ��ֽ�������64���ֽ�Ϊһ�飬ÿ����һ��ѭ����ÿ��ѭ���������ֲ�����Ҫ�任��64���ֽ���16��32λ��������
	��M[0����15]��ʾ��������T[1����64]��ʾһ�鳣����T[i]Ϊ4294967296*abs(sin(i))��32λ�������֣�i�ĵ�λ�ǻ��ȣ�i��ȡֵ��1��64��
	MD5�ĵ���Ӧ���Ƕ�һ����Ϣ(message)������ϢժҪ(message��digest)���Է�ֹ���۸ġ����磬��unix���кܶ���������ص�ʱ��
��һ���ļ�����ͬ���ļ���չ��Ϊ��md5���ļ���������ļ���ͨ��ֻ��һ���ı������½ṹ�磺
	MD5(tanajiya��tar��gz)= 0ca17569cOf726a831d895e269332461
	�����tanajiya��tar��gz�ļ�������ǩ����MD5�������ļ�����һ�����ı���Ϣ��ͨ���䲻������κ���ʽ�ĸı�(������Ϊ���ַ���
�任�㷨�����������Ψһ��MD5��ϢժҪ��������Ժ󴫲�����ļ��Ĺ����У������ļ������ݷ����˸Ļ������ع�������·���ȶ�����
�Ĵ�������)��ֻҪ�������ļ����¼���MD5ʱ�ͻᷢ����ϢժҪ����ͬ���ɴ˿���ȷ����õ���ֻ��һ������ȷ���ļ����������һ��
����������֤��������MD5�����Է�ֹ�ļ����ߵġ����������������ν������ǩ��Ӧ�á�
	MD5�㷨Ŀǰ�Ѿ���Ϊ���ƣ��󲿷ֱ������(����)���ṩ��MD5�㷨��ʵ�֡�
	����ǩ�����Ա�֤��Ϣ��ԭʼ�ԡ������ԡ���ˣ�����ǩ�����Խ�����ϡ�α�졢�۸ļ�ð������⡣����Ҫ�󣺷��ͣ����º��ܷ�
�Ϸ��͵ı���ǩ�����������ܹ���ʵ�����߷��͵ı���ǩ���������߲���α�췢���ߵı���ǩ���������߲��ܶԷ����ߵı��Ľ��в��ִ۸ġ�
�����е�ĳһ�û�����ð����һ�û���Ϊ�����߻�����ߡ�����ǩ����Ӧ�÷�Χʮ�ֹ㷺���ڱ��ϵ������ݽ���(EDI)�İ�ȫ������һ��ͻ��
�ԵĽ�չ��������Ҫ���û�����ݽ����жϵ����������ʹ������ǩ������������ż��������ź�����������ϵͳ��Զ�̽��ڽ��ס�������
���Զ�ģʽ����ȵȡ� 
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