use epdc2


select '=trim("'+ c.clgCode + '")', c.clgName, '=trim("'+ u.uCode+'")', u.uName 
from college c left join useUnit u on  c.clgCode = u.clgCode
order by c.clgCode, u.uCode

select * from useUnit