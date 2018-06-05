	IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Stg_tblDrugs_rnk2]') AND type in (N'U'))
BEGIN
   drop TABLE Stg_tblDrugs_rnk2
END ;


select DIStinct ClusterId,DrugID,rnk 
into Stg_tblDrugs_rnk2
from (
select distinct drugid,GenericName,ind,GenericName_N,ClusterId
,Row_Number() over ( partition by ClusterId order by DrugID desc ) as rnk
from Stg_tblDrugs_Union
where flag=2 and GDFlag=2 and GenericName is not null
) as x
where rnk=1 and ClusterId is not null ;



select  A.DrugID,A.GenericName,A.IND,A.GenericName_N,Flag,
(case when Flag=2 then A.DrugID
     else A.Golden_GenericID end ) as Golden_GenericID
	
from  [dbo].Stg_tblDrugs_Union  A
	left join 	Stg_tblDrugs_rnk2 B
	ON A.ClusterId=B.ClusterId
	where  GDFlag=2 and A.DrugID =85;

select * from (
select drugName,drugName_N,golden_drugid from	tblDrugs_Golden
except 
select drugName,drugName_N,golden_drugid from	tblDrugs_Golden_31122017
) x
order by 3

SELECT * FROM tblDrugs_Golden_31122017 WHERE drugName LIKE '%oxycodone hydrochloride%';
SELECT * FROM tblDrugs_Golden WHERE GenericName='natalizumab'
drugName LIKE '%oxycodone hydrochloride%';
SELECT * FROM tblDrugs WHERE drugName LIKE '%oxycodone hydrochloride%';

SELECT * FROM [dbo].[tblDrugs_Golden_bkp]
WHERE drugName LIKE '%oxycodone hydrochloride%';



select DrugID,
	ltrim(rtrim(replace(replace(replace(DrugName, char(9),''), char(10),''), char(13),''))) as DrugName,
	IND,
	ltrim(rtrim(replace(replace(replace(GenericName, char(9),''), char(10),''), char(13),''))) as GenericName,
	Golden_DrugID,
	ltrim(rtrim(replace(replace(replace(DrugName_N, char(9),''), char(10),''), char(13),'')))  as DrugName_N,
	Golden_GenericID,
	ltrim(rtrim(replace(replace(replace(GenericName_N, char(9),''), char(10),''), char(13),'')))  as GenericName_N
    from	select * from tblDrugs_Golden_31122017