
select	Pt.ChartNumber,
		Pt.FullName,
		Appt.startdatetime,
		Appt.Comments,
		Appt.ApptStatus,
		Pro.Description as 'Provider'
from vw_ODBC_pt_PatientInfo Pt
inner join vw_ODBC_appts_Appointments Appt
	ON Pt.LicenseKey = Appt.LicenseKey
	AND Pt.Patient_UID = Appt.PatientFID
	and Appt.startdatetime between '2023-10-01' and '2023-10-31'
inner join vw_ODBC_mf_PGProfiles Pro
	ON Pt.LicenseKey = Pro.LicenseKey
	AND Appt.profilefid = Pro.profile_uid

	
