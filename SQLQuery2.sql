IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Stg_tblSponsor_tmp]') AND type in (N'U'))
BEGIN
   drop TABLE Stg_tblSponsor_tmp
END ;

select A.SponsorID,
A.Sponsor,
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(A.sponsor,'&',' and '),'/',' '),';',' ') ,'.','') ,',','') 
       ,':',' ') ,'@',' '),'Doctor ','Dr '),' 1 ',' One ') ,'  ',' '),' LLC',', LLC.') ,' Co ',' Co. ') ,' Ltd',', Ltd.'),'é','e'),'Assoc ','Association ') as Sponsor_N,
A.Address1,
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(A.Address1,'.',' '),',',' '),'South ','S '),'West','W '),'East','E '),'North','N ')
,'Avenue','Ave') ,'#','Suite') ,' Ste',' Suite')  ,'Two','2') ,'One ','1 ') ,'Three ','3 ') ,'Building',' Bldg'), char(9),' '), char(10),' '), char(13),' ') ,'  ',' '),'  ',' ') as Address1_N,

A.Address2,
replace(replace(replace(replace(replace(replace(replace(replace(replace(A.Address2,'.',' '),',',' '),'United Kingdom','UK'),'First','1st'),' St ',' Street '),'#',''),' Ste ',' Suite '),' Fl ',' Floor '),'  ',' ') as Address2_N,
A.City,Ltrim(Rtrim(case when A.City is null then '' else A.city end )) As City_N,
A.State,Ltrim(Rtrim(case when A.State is null then '' else A.state end )) As State_N,
A.Zip,
ltrim(rtrim(
       case when rtrim(ltrim(A.Zip)) is null then '' 
              when rtrim(ltrim(A.Zip)) like '% %' then substring(rtrim(ltrim(A.Zip)),1,PATINDEX('% %', rtrim(ltrim(A.Zip)) )   )
              when rtrim(ltrim(A.Zip)) like '%-%'  and rtrim(ltrim(A.Zip))  like '_-__%' then rtrim(ltrim(A.Zip))
              when rtrim(ltrim(A.Zip)) like '%-%' then dbo.UFN_SEPARATES_COLUMNS(rtrim(ltrim(A.Zip)), 1, '-')
                     else rtrim(ltrim(A.Zip)) end))  as Zip_N,
ltrim(rtrim(
       case when rtrim(ltrim(A.Zip)) like '% %' and len(rtrim(ltrim(Zip))) >9 
              then substring(ltrim(substring(rtrim(ltrim(Zip)),PATINDEX('% %', rtrim(ltrim(Zip))),len(rtrim(ltrim(Zip))))),1,
PATINDEX('% %', ltrim(substring(rtrim(ltrim(Zip)),PATINDEX('% %', rtrim(ltrim(Zip))),len(rtrim(ltrim(Zip)))))) )

       when rtrim(ltrim(A.Zip)) like '% %' and len(rtrim(ltrim(Zip))) <9    then substring(rtrim(ltrim(A.Zip)),PATINDEX('% %', rtrim(ltrim(A.Zip))),len(rtrim(ltrim(A.Zip))))
              when rtrim(ltrim(A.Zip)) like '%-%'  and rtrim(ltrim(A.Zip))  like '_-__%' then ''
              when rtrim(ltrim(A.Zip)) like '%-%' then dbo.UFN_SEPARATES_COLUMNS(rtrim(ltrim(A.Zip)), 2, '-')
                     else '' end))  as Zip_Suffix_N,
(Case when A.State='UK' then 'UK' else B.Country end ) as Country_N,
A.CurrentSponsor,
replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(A.currentSponsor,'&',' and '),'/',' ') ,'.',''),',','') 
,';',' ') ,':',' ') ,'@',' '),'Doctor ','Dr '),' 1 ',' One ') ,'  ',' '),' LLC',', LLC.'),' Co ',' Co. ') ,' Ltd',', Ltd.') ,'é','e'),'Assoc ','Association ') as CurrentSponsor_N
 
Into Stg_tblSponsor_tmp
from [tblSponsor] A
Left join 
 (Select distinct State,Country from  [ProtocolTracking].[dbo].[tblZipCode]) B
ON A.State=B.State 
where A.Golden_SponsorID is null

;
  select SponsorID,
       Sponsor,
       Address1,
       Address2,
       City,State,Zip,
       CurrentSponsor,
       nullif(rtrim(ltrim(case when sponsor_N like '% Inc%' and sponsor_N not like '% Inco%' then replace(sponsor_N,' Inc',', Inc.') 
              else sponsor_N end)) ,'')  as Sponsor_N,
       cast(nullif(rtrim(ltrim(Case When Address1_N  is null then ''
             when Address1_N like '% Dr' then replace (Address1_N,' Dr',' Drive') 
              when Address1_N like '% Dr %' then replace (Address1_N,' Dr ',' Drive ') 
              when Address1_N like '% Rd' then replace (Address1_N,' Rd',' Road') 
              when Address1_N like '% Rd %' then replace (Address1_N,' Rd ',' Road ')    
              when Address1_N like '% Rte' then replace (Address1_N,' Rte',' Route')     
              when Address1_N like '% Rte %' then replace (Address1_N,' Rte ',' Route ') 
              when Address1_N like '% St' then replace (Address1_N,' St',' Street')      
              when Address1_N like '% St %' then replace (Address1_N,' St ',' Street ') 
              when Address1_N like '% Pkw %' then replace (Address1_N,' Pkw ',' Pkwy ') 
              when Address1_N like '% Parkway %' then replace (Address1_N,' parkway ',' Pkwy ')
             when Address1_N like '% Pkw' then replace (Address1_N,' Pkw',' Pkwy')      
              when Address1_N like '% Parkway' then replace (Address1_N,' Parkway',' Pkwy')
             when Address1_N like '% Hwy' then replace (Address1_N,' Hwy',' Highway')   
              when Address1_N like '% Hwy %' then replace (Address1_N,' Hwy ',' Highway ')      
              when Address1_N like '% Ct' then replace (Address1_N,' Ct',' Court')       
              when Address1_N like '% Ct %' then replace (Address1_N,' Ct ',' Court ')   
              when Address1_N like '%P O Box%' then replace (Address1_N,'P O Box','PO Box')     
              else Address1_N end )),'') as Varchar(75)) as Address1_N,
       cast(nullif(rtrim(ltrim(Case when Address2_N is null then ''
             when Address2_N like '% FL' then replace (Address2_N,' FL',' Floor')
             when Address2_N like '% St' then replace (Address2_N,' St',' Street')
             when Address2_N like '% Rd' then replace (Address2_N,' Rd',' Road')
             when Address2_N like '% Rd %' then replace (Address2_N,' Rd ',' Road ')    
              when Address2_N like '% Dr' then replace (Address2_N,' Dr',' Drive')
             when Address2_N like '% Dr %' then replace (Address2_N,' Dr ',' Drive ')   
              when Address2_N like '%P O Box%' then replace (Address2_N,'P O Box','PO Box')
             else Address2_N end)),'')as Varchar(75))  as Address2_N,
             nullif(City_N,'') as City_N,
             nullif(State_N,'') as State_N,
             nullif(Zip_N,'') as  Zip_N,
             nullif(Zip_Suffix_N,'') as Zip_Suffix_N,
             nullif(Country_N,'') as Country_N,
       cast(nullif(rtrim(ltrim(case when currentSponsor_N like '% Inc%' and currentSponsor_N not like '% Inco%' 
              then replace(currentSponsor_N,' Inc',', Inc.') 
                     else currentSponsor_N end )),'') as Varchar(255))  as CurrentSponsor_N
 
from Stg_tblSponsor_tmp
; 
