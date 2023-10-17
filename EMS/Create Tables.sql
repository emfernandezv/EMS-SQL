GO;
Create table EMS_Employee (
 Vendor varchar(8) not null,
 FirstName varchar(20) null,
 LastName varchar(20) null,
 DayOfBirth date null,
 IdGender varchar(1) not null,
 Address varchar(100) null,
 Status varchar(1) not null,
 IdArea varchar(2) not null,
 HiringDate date null,
 Salary float null,
 CreatedBy varchar(20) not null,
 CreatedDate datetime not null,
 ModifiedBy varchar(20) not null,
 ModifiedDate datetime not null,
 CONSTRAINT PK_Employee PRIMARY KEY (Vendor),
 CONSTRAINT FK_Area FOREIGN KEY (IdArea) REFERENCES EMS_Area(IdArea),
 CONSTRAINT FK_Gender FOREIGN KEY (IdGender) REFERENCES EMS_Gender(IdGender)
);
GO;
Create table EMS_Gender (
IdGender varchar(1) not null,
Description varchar(10) null,
CONSTRAINT PK_Gender PRIMARY KEY (IdGender)
);

GO;
Create table EMS_Area(
IdArea varchar(2) not null,
Description varchar(20) null,
CONSTRAINT PK_Area PRIMARY KEY (IdArea)
);

