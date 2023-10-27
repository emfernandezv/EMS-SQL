--Adding new fields to existing tables
-- The program should delete this fields
alter table [dbo].[vw_ODBC_pt_PatientInfo] add newColumnVarchar varchar(5);
alter table [dbo].[vw_ODBC_pt_PatientInfo] add newColumnInt Int;
alter table [dbo].[vw_ODBC_appts_Appointments] add newColumnChar varchar(5);
alter table [dbo].[vw_ODBC_appts_Appointments] add newColumnFloat float;
alter table [dbo].vw_ODBC_mf_PGProfiles add newColumnDateTime datetime;
alter table [dbo].vw_ODBC_mf_PGProfiles add newColumnDecimal decimal(18,2);

--Modifying Current fields to different sizes
-- The program should change back the sizes to the original ones
alter table [dbo].[vw_ODBC_pt_PatientInfo] alter column Employer varchar(200);
alter table [dbo].[vw_ODBC_pt_PatientInfo] alter column PreviousZipCode char(20);
alter table [dbo].[vw_ODBC_appts_Appointments] alter column Comments varchar(500);
alter table [dbo].[vw_ODBC_appts_Appointments] alter column BillingNote varchar(200);
alter table [dbo].vw_ODBC_mf_PGProfiles alter column [UserFileFID] float;
alter table [dbo].vw_ODBC_mf_PGProfiles alter column [FederalID] varchar(45);

--Deleting Existing fields 
-- The Program should add them back
alter table [dbo].[vw_ODBC_pt_PatientInfo] drop column CountryCode;
alter table [dbo].[vw_ODBC_pt_PatientInfo] drop column Email;
alter table [dbo].[vw_ODBC_appts_Appointments] drop column RecurringAppointmentFID;
alter table [dbo].[vw_ODBC_appts_Appointments] drop column PendingDate;
alter table [dbo].vw_ODBC_mf_PGProfiles drop column [BillAsFID];
alter table [dbo].vw_ODBC_mf_PGProfiles drop column [DEANumber];

