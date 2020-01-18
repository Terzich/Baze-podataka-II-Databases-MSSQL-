create database IB170116

use IB170116

create table Autori(
AutorID nvarchar(11) not null constraint Autor_PK primary key,
Prezime nvarchar(25) not null,
Ime nvarchar(25) not null,
Telefon nvarchar(20) default null,
DatumKreiranjaZapisa datetime not null default sysdatetime(),
DatumModifikovanjaZapisa datetime default null
)

create table Izdavaci(
IzdavacID nvarchar(4) not null constraint Izdavac_PK primary key,
Naziv nvarchar(100) not null unique nonclustered,
Biljeske nvarchar(1000) default 'Lorem ipsum',
DatumKreiranjaZapisa datetime not null default sysdatetime(),
DatumModifikovanjaZapisa datetime default null
)

create table Naslovi(
NaslovID nvarchar(6) not null constraint Naslov_PK primary key,
IzdavacID nvarchar(4) not null constraint Izdavac_FK foreign key references Izdavaci(IzdavacID),
Naslov nvarchar(100) not null,
Cijena money,
DatumIzdavanja datetime not null default sysdatetime(),
DatumKreiranjaZapisa datetime not null default sysdatetime(),
DatumModifikovanjaZapisa datetime default null
)

create table NasloviAutori(
AutorID nvarchar(11) not null constraint Autor_FK foreign key references Autori(AutorID),
NaslovID nvarchar(6) not null constraint Naslov_FK foreign key references Naslovi(NaslovID),
constraint Naslovi_Autori_PK primary key(AutorID,NaslovID),
DatumKreiranjaZapisa datetime not null default sysdatetime(),
DatumModifikovanjaZapisa datetime default null
)

select *
from pubs.dbo.publishers

select *
from pubs.dbo.pub_info

insert into Autori(AutorID,Prezime,Ime,Telefon)
select A.au_id,A.au_lname,A.au_fname,A.phone
from (select au_id,au_lname,au_fname,phone from pubs.dbo.authors) as A
order by NEWID()

select *
from Autori

insert into Izdavaci(IzdavacID,Naziv,Biljeske)
select PUB.pub_id,PUB.pub_name,SUBSTRING(PUB.pr_info,1,100)
from (select P.pub_id,P.pub_name,Pinf.pr_info from pubs.dbo.publishers as P inner join pubs.dbo.pub_info as Pinf on P.pub_id=Pinf.pub_id) as PUB
order by NEWID()

select * from Izdavaci

insert into Naslovi(NaslovID,IzdavacID,Naslov,Cijena,DatumIzdavanja)
select t.title_id,t.pub_id,t.title,t.price,t.pubdate
from (select T.title_id,P.pub_id,T.title,T.price,T.pubdate from pubs.dbo.titles as T inner join pubs.dbo.publishers as P on T.pub_id=P.pub_id) as t

select * from Naslovi

insert into NasloviAutori(AutorID,NaslovID)
select TA.au_id,TA.title_id
from (select a.au_id,t.title_id from pubs.dbo.titleauthor as ta inner join pubs.dbo.titles as t on ta.title_id=t.title_id inner join pubs.dbo.authors as a
on ta.au_id=a.au_id) as TA

select * from NasloviAutori

create table Gradovi(
GradID int not null identity(5,5) constraint Grad_PK primary key,
Naziv nvarchar(100) not null unique nonclustered,
DatumKreiranjaZapisa datetime not null default sysdatetime(),
DatumModifikovanjaZapisa datetime default null
)

insert into Gradovi(Naziv)
select A.city
from (select distinct city from pubs.dbo.authors) as A 

select * from Gradovi

alter table Autori
add GradID int constraint Grad_FK foreign key references Gradovi(GradID)

go
create proc AddSF_TOP10
as
begin 
update Autori
set GradID=G.GradID,DatumModifikovanjaZapisa=SYSDATETIME()
from Gradovi as G
where G.Naziv ='San Francisco' and AutorID in (select top 10 AutorID from Autori)
end

exec AddSF_TOP10

select * from Autori

go
create proc AddBE_notTOP10
as
begin 
update Autori
set GradID=G.GradID,DatumModifikovanjaZapisa=SYSDATETIME()
from Gradovi as G
where G.Naziv ='Berkeley' and AutorID not in (select top 10 AutorID from Autori)
end

exec AddBE_notTOP10

select * from Autori

go
create view AutoriDjelaIzdavaci
as
select A.Ime+' '+A.Prezime as ImeIPrezime,G.Naziv as Grad,N.Naslov,N.Cijena,I.Naziv,I.Biljeske
from Autori as A inner join NasloviAutori as NA on A.AutorID=NA.AutorID inner join Naslovi as N on NA.NaslovID=N.NaslovID inner join Izdavaci as I
on N.IzdavacID=I.IzdavacID inner join Gradovi as G on A.GradID=G.GradID
where N.Cijena is not null and N.Cijena>10 and I.Naziv like '%&%' and G.Naziv='San Francisco'
go

select A.ImeIPrezime,A.Grad,A.Naslov,A.Cijena,A.Naziv,A.Biljeske
from AutoriDjelaIzdavaci as A

alter table Autori
add Email nvarchar(100) default null

go
create proc AddMail_ImePrezime
as
begin
update Autori
set Email=Ime+'.'+Prezime+'@fit.ba'
from Gradovi as G
where Autori.GradID=G.GradID and G.Naziv='San Francisco'
end

exec AddMail_ImePrezime

select * from Autori

go
create proc AddMail_PrezimeIme
as
begin
update Autori
set Email=Prezime+'.'+Ime+'@fit.ba'
from Gradovi as G
where Autori.GradID=G.GradID and G.Naziv='Berkeley'
end

exec AddMail_PrezimeIme

select * from Autori

select *
from AdventureWorks2014.Person.Person


select ISNULL(skup.Title,'N/A')as Title,skup.LastName,skup.FirstName,skup.EmailAddress,skup.PhoneNumber,skup.CardNumber,skup.FirstName+'.'+skup.LastName
as Username,SUBSTRING(LOWER(REPLACE(newid(),'-',7)),1,16) as Password
into #PrivremenaTabela 
from (select P.Title,P.LastName,P.FirstName,EA.EmailAddress,PP.PhoneNumber,CC.CardNumber
from AdventureWorks2014.Person.BusinessEntity as BE inner join AdventureWorks2014.Person.Person as P on BE.BusinessEntityID=P.BusinessEntityID
inner join AdventureWorks2014.Person.EmailAddress as EA on BE.BusinessEntityID=EA.BusinessEntityID inner join AdventureWorks2014.Person.PersonPhone as PP
on BE.BusinessEntityID=PP.BusinessEntityID left outer join AdventureWorks2014.Sales.PersonCreditCard as PCC on BE.BusinessEntityID=PCC.BusinessEntityID 
left outer join AdventureWorks2014.Sales.CreditCard as CC on PCC.CreditCardID=CC.CreditCardID) as skup
order by skup.FirstName,skup.LastName

select * from #PrivremenaTabela

create nonclustered index NIX_UserFirstLast
on #PrivremenaTabela(Username)
include (FirstName,LastName)

select PT.Username,PT.PhoneNumber,PT.Password,PT.CardNumber
from #PrivremenaTabela as PT

select PT.LastName,PT.FirstName,PT.PhoneNumber,PT.CardNumber
from #PrivremenaTabela as PT

go
create proc Delete_WhereCCisNULL
as
begin
delete #PrivremenaTabela
where CardNumber IS NULL
end

exec Delete_WhereCCisNULL

select * from #PrivremenaTabela

backup database IB170116

