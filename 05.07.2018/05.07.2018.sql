create database IB170116v5

use IB170116v5

create table Zaposlenici(
ZaposlenikID int not null constraint Zaposlenik_PK primary key,
Ime nvarchar(30) not null,
Prezime nvarchar(30) not null,
Spol nvarchar(10) not null,
JMBG nvarchar(13) not null,
DatumRodjenja datetime not null default sysdatetime(),
Adresa nvarchar(100) not null,
Email nvarchar(100) not null unique nonclustered,
KorisnickoIme nvarchar(60) not null,
Lozinka nvarchar(30) not null,
)

create table Artikli(
ArtiklID int not null constraint Artikl_PK primary key,
Naziv nvarchar(50) not null,
Cijena decimal not null,
StanjeNaSkladistu int not null
)

create table Prodaja(
ZaposlenikID int not null constraint Zaposlenik_FK foreign key references Zaposlenici(ZaposlenikID),
ArtiklID int not null constraint Artikl_FK foreign key references Artikli(ArtiklID),
Datum datetime not null default sysdatetime(),
constraint Prodaja_PK primary key(ZaposlenikID,ArtiklID,Datum),
Kolicina decimal not null
)

select *from NORTHWND.dbo.Employees

select *from NORTHWND.dbo.Products

select * from NORTHWND.dbo.Orders

select * from NORTHWND.dbo.[Order Details]

insert into Zaposlenici
select E.EmployeeID,E.FirstName,E.LastName,IIF(E.TitleOfCourtesy='Ms.' or E.TitleOfCourtesy='Mrs.','Zensko','Musko'),CONVERT(nvarchar,DAY(E.BirthDate))+CONVERT(nvarchar,MONTH(E.BirthDate))+CONVERT(nvarchar,YEAR(E.BirthDate)),
E.BirthDate,E.Country+', '+E.City+', '+E.Address, E.FirstName+'['+CONVERT(nvarchar, RIGHT(YEAR(E.BirthDate),2))+']@poslovna.ba',UPPER(E.FirstName)+'.'+UPPER(E.LastName),
REVERSE(REPLACE(SUBSTRING(E.Notes,16,6)+LEFT(E.Extension,2)+' '+CONVERT(nvarchar,DATEDIFF(DAY,E.BirthDate,E.HireDate)),' ','#'))
from NORTHWND.dbo.Employees as E
where DATEDIFF(YEAR,E.BirthDate,GETDATE())>60

select * from Zaposlenici

insert into Artikli
select P.ProductID,P.ProductName,P.UnitPrice,P.UnitsInStock
from NORTHWND.dbo.Products as P 
where P.ProductID=(SELECT distinct OD.ProductID FROM NORTHWND.dbo.[Order Details] as OD inner join  NORTHWND.dbo.Orders as O
ON OD.OrderID=O.OrderID where YEAR(O.OrderDate)='1997' and (MONTH(O.OrderDate)='8' or MONTH(O.OrderDate)='9') and P.ProductID=OD.ProductID)
order by P.ProductName

select * from Artikli

insert into Prodaja
select O.EmployeeID,OD.ProductID,O.OrderDate,OD.Quantity
from NORTHWND.dbo.Orders as O inner join NORTHWND.dbo.[Order Details] as OD on O.OrderID=OD.OrderID
where O.EmployeeID IN (SELECT ZaposlenikID from Zaposlenici) and YEAR(O.OrderDate)='1997' and (MONTH(O.OrderDate)='8' or MONTH(O.OrderDate)='9')

select * from Prodaja

alter table Zaposlenici
alter column Adresa nvarchar(100) null

alter table Artikli
add Kategorija nvarchar(50)

update Artikli
set Kategorija='Hrana'
where ArtiklID%3=0

update Zaposlenici
set DatumRodjenja=convert(date,convert(nvarchar,YEAR(DatumRodjenja)+2)+'/'+convert(nvarchar,MONTH(DatumRodjenja))+'/'+convert(nvarchar,DAY(DatumRodjenja)))
where Spol='Zensko'

update Zaposlenici
set KorisnickoIme=LOWER(Ime)+'_['+SUBSTRING(CONVERT(nvarchar,YEAR(DatumRodjenja)),2,2)+']_'+LOWER(Prezime)

select * from Zaposlenici

select * from Artikli

select * from Prodaja

select A.Naziv,A.StanjeNaSkladistu,count(P.ArtiklID)as BrojNarucenih,sum(P.Kolicina)-A.StanjeNaSkladistu as 'Potrebno naruciti'
from Artikli as A inner join Prodaja as P on A.ArtiklID=P.ArtiklID
where P.Kolicina>A.StanjeNaSkladistu
group by A.Naziv,A.StanjeNaSkladistu
having sum(P.Kolicina)-A.StanjeNaSkladistu>0

select Z.Ime+' '+Z.Prezime as ImeIPrezime,A.Naziv,ISNULL(A.Kategorija,'N/A'),convert(nvarchar,round(SUM(P.Kolicina),2))+' kom' as 'Ukupna prodana kolicina',convert(nvarchar,round(SUM(A.Cijena*P.Kolicina),2))+' KM' as 'Ukupna zarada'
from Zaposlenici as Z inner join Prodaja as P on Z.ZaposlenikID=P.ZaposlenikID inner join Artikli as A on P.ArtiklID=A.ArtiklID
where SUBSTRING(Z.Adresa,1,CHARINDEX(',',Z.Adresa)-1)='USA'
group by Z.Ime,Z.Prezime,A.Naziv,A.Kategorija

select Z.Ime+' '+Z.Prezime as ImeIPrezime,A.Naziv,ISNULL(A.Kategorija,'N/A'),convert(nvarchar,round(SUM(P.Kolicina),2))+' kom' as 'Ukupna prodana kolicina',
convert(nvarchar,round(SUM(A.Cijena*P.Kolicina),2))+' KM' as 'Ukupna zarada',P.Datum
from Zaposlenici as Z inner join Prodaja as P on Z.ZaposlenikID=P.ZaposlenikID inner join Artikli as A on P.ArtiklID=A.ArtiklID
where Z.Spol='Zensko' and A.Naziv LIKE '[CG]%' and A.Kategorija IS NULL and (P.Datum='1997/08/22' or P.Datum='1997/09/22' )
group by Z.Ime,Z.Prezime,A.Naziv,A.Kategorija,P.Datum

select Z.Ime,Z.Prezime,FORMAT(Z.DatumRodjenja,'dd.MM.yyyy'),
Z.Spol,COUNT(P.ArtiklID) as 'Broj prodaja koje je obavio'
from Zaposlenici as Z inner join Prodaja as P on Z.ZaposlenikID=P.ZaposlenikID
where YEAR(P.Datum)='1997' and MONTH(P.Datum)='8'
group by Z.Ime,Z.Prezime,Z.DatumRodjenja,Z.Spol
order by 5 desc

select SUBSTRING(Adresa,CHARINDEX(',',Adresa),CHARINDEX(',',Adresa))
from Zaposlenici
