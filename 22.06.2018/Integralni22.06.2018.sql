create database IB170116v2

use IB170116v2

create table Otkupljivaci(
OtkupljivacID int not null constraint Otkupljivac_PK primary key,	
Ime nvarchar(50) not null,
Prezime nvarchar(50) not null,
DatumRodjenja date not null default sysdatetime(),
JMBG nvarchar(13) not null,
Spol char not null,
Grad nvarchar(50) not null,
Adresa nvarchar(100) not null,
Email nvarchar(100) not null unique nonclustered,
Aktivan bit not null default 1
)

create table Proizvodi(
ProizvodID int not null constraint Proizvod_PK primary key,	
Naziv nvarchar(50) not null,
Sorta nvarchar(50) not null,
OtkupnaCijena decimal not null,
Opis text
)

create table OtkupProizvoda(
OtkupljivacID int not null constraint Otkupljivac_FK foreign key references Otkupljivaci(OtkupljivacID),
ProizvodID int not null constraint Proizvod_FK foreign key references Proizvodi(ProizvodID),
Datum date not null default getdate(),
constraint OtkupProizvoda_PK primary key (OtkupljivacID,ProizvodID,Datum),
Kolicina decimal not null,
BrojGajbica int not null
)

insert into Otkupljivaci
select top 5 E.EmployeeID,E.FirstName,E.LastName,E.BirthDate,convert(nvarchar,REVERSE(YEAR(E.BirthDate)))+CONVERT(nvarchar,DAY(E.BirthDate))+
CONVERT(nvarchar,MONTH(E.BirthDate))+SUBSTRING(E.HomePhone,CHARINDEX('-',E.HomePhone)+1,len(E.HomePhone)),'M',E.City,
REPLACE(E.Address,' ','_'),E.FirstName+'_'+E.LastName+'@efu.fit.ba',1
from NORTHWND.dbo.Employees as E
order by E.BirthDate desc

select * from Otkupljivaci

insert into Proizvodi
select p.ProductID,p.ProductName,c.CategoryName,p.UnitPrice,c.Description
from NORTHWND.dbo.Products as p inner join NORTHWND.dbo.Categories as c on p.CategoryID=c.CategoryID

select * from Proizvodi

select * from NORTHWND.dbo.Orders
select * from NORTHWND.dbo.[Order Details]

insert OtkupProizvoda
select O.EmployeeID,OD.ProductID,O.OrderDate,OD.Quantity*8,OD.Quantity
from NORTHWND.dbo.[Order Details] as OD inner join NORTHWND.dbo.Orders as O on OD.OrderID=O.OrderID
where O.EmployeeID in (select OtkupljivacID from Otkupljivaci)

select *
from NORTHWND.dbo.Employees

