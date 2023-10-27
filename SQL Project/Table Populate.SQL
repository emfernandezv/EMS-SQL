SET NOCOUNT ON

DECLARE @RunDate datetime,
  @RunHistoryID int,
  @LastRunDate varchar(10),
  @DD datetime

DECLARE @SQL nvarchar(max)

SELECT @RunDate = GETDATE(),
  @RunHistoryID = MAX(RunHistoryID) + 1,
  @LastRunDate = CONVERT(varchar(10), MAX(RunDate), 101)
FROM ODBC_RunHistory

IF @RunHistoryID IS NULL
  BEGIN 
    SET @RunHistoryID = 1
    SET @LastRunDate = '1/1/1900'
  END

SET @SQL = '
UPDATE vw_ODBC_pt_PatientInfo
SET LicenseKey = t.LicenseKey, 
  Patient_UID = t.Patient_UID, 
  LastName = t.LastName, 
  FirstName = t.FirstName, 
  MiddleName = t.MiddleName, 
  ChartNumber = t.ChartNumber, 
  Title = t.Title, 
  AptSte = t.AptSte, 
  [Address] = t.[Address], 
  ZipCode = t.ZipCode, 
  City = t.City, 
  [State] = t.[State], 
  AreaCode = t.AreaCode, 
  CountryCode = t.CountryCode, 
  OfficePhone = t.OfficePhone, 
  OfficeExtension = t.OfficeExtension, 
  HomePhone = t.HomePhone, 
  Other = t.Other, 
  PhoneType = t.PhoneType, 
  Email = t.Email, 
  MaritalStatus = t.MaritalStatus, 
  DOB = t.DOB, 
  Deceased = t.Deceased, 
  Gender = t.Gender, 
  SSN = t.SSN, 
  Relationship = t.Relationship, 
  HIPAARelationship = t.HIPAARelationship, 
  ResponsiblePartyFID = t.ResponsiblePartyFID, 
  ProfileFID = t.ProfileFID, 
  FinancialClassFID = t.FinancialClassFID, 
  Employer = t.Employer, 
  EmployerFID = t.EmployerFID, 
  InsuranceOrder = t.InsuranceOrder, 
  AR_PatPortionFID = t.AR_PatPortionFID, 
  AR_InsPortionFID = t.AR_InsPortionFID, 
  CreatedAt = t.CreatedAt, 
  CreatedBy = t.CreatedBy, 
  Display = t.Display, 
  RecalcBuckets = t.RecalcBuckets, 
  FullName = t.FullName, 
  ChangedAt = t.ChangedAt, 
  ChangedBy = t.ChangedBy, 
  BucketsUpdatedAt = t.BucketsUpdatedAt, 
  BirthMonth = t.BirthMonth, 
  IsDeceased = t.IsDeceased, 
  EthnicityFID = t.EthnicityFID, 
  LanguageFID = t.LanguageFID, 
  Language = t.Language, 
  CommunicationNote = t.CommunicationNote, 
  ContactName = t.ContactName, 
  Fax = t.Fax, 
  Cell = t.Cell, 
  Pager = t.Pager, 
  ConversionID = t.ConversionID, 
  PreferredCommunicationFID = t.PreferredCommunicationFID, 
  ConfidentialCommunicationFID = t.ConfidentialCommunicationFID, 
  Consent = t.Consent, 
  AdditionalMrn = t.AdditionalMrn, 
  Inactive = t.Inactive, 
  InactiveStatusFID = t.InactiveStatusFID, 
  GenderIdentityFID = t.GenderIdentityFID, 
  GenderIdentityOtherFID = t.GenderIdentityOtherFID, 
  SexualOrientationFID = t.SexualOrientationFID, 
  SexualOrientationOtherFID = t.SexualOrientationOtherFID, 
  PrimaryCarePhysicianFID = t.PrimaryCarePhysicianFID, 
  PreviousFirstName = t.PreviousFirstName, 
  PreviousMiddleName = t.PreviousMiddleName, 
  PreviousLastName = t.PreviousLastName, 
  PreviousAddress1 = t.PreviousAddress1, 
  PreviousAddress2 = t.PreviousAddress2, 
  PreviousCity = t.PreviousCity, 
  PreviousState = t.PreviousState, 
  PreviousZipCode = t.PreviousZipCode, 
  PreviousCountryCode = t.PreviousCountryCode, 
  TimeZoneFID = t.TimeZoneFID, 
  PreferredFirstName = t.PreferredFirstName, 
  PreferredMiddleName = t.PreferredMiddleName, 
  PreferredLastName = t.PreferredLastName,
  [SendApptReminderEmail] = t.[SendApptReminderEmail],
  [SendOnlineStatementText] = t.[SendOnlineStatementText],
  [SendOnlineStatementEmail] = t.[SendOnlineStatementEmail],
  [SendApptReminderToResponsibleParty] = t.[SendApptReminderToResponsibleParty],
  [SendApptReminderText] = t.[SendApptReminderText],
  [SendOtherEmail] = t.[SendOtherEmail],
  [SendOtherText] = t.[SendOtherText],
  [SendNotificationEmail] = t.[SendNotificationEmail],
  [SendNotificationText] = t.[SendNotificationText]
FROM vw_ODBC_pt_PatientInfo s
  INNER JOIN (SELECT * FROM OPENQUERY([OAK], ''SELECT * FROM vw_ODBC_pt_PatientInfo WHERE ChangedAt > ''''' + @LastRunDate + ''''''')) t
    ON s.Patient_UID = t.Patient_UID
    AND s.LicenseKey = t.LicenseKey'

  PRINT 'Starting to update data for vw_ODBC_pt_PatientInfo'

  --Set the start time
  SET @DD = GETDATE()

EXECUTE sp_executesql @SQL

  --Insert the time to run into the table
  INSERT INTO ODBC_RunHistory VALUES(
    @RunHistoryID, 
    @RunDate, 
    'vw_ODBC_pt_PatientInfo', 
    'U',
    @DD,
    GETDATE(),
    CONVERT(varchar(100), GETDATE() - @DD, 14),
    @@ROWCOUNT
  )

  PRINT 'Data update for vw_ODBC_pt_PatientInfo is done!'+ Char(13) + Char(10)

SET @SQL = '
INSERT INTO vw_ODBC_pt_PatientInfo (LicenseKey, 
    Patient_UID, 
    LastName, 
    FirstName, 
    MiddleName, 
    ChartNumber, 
    Title, 
    AptSte, 
    [Address], 
    ZipCode, 
    City, 
    [State], 
    AreaCode, 
    CountryCode, 
    OfficePhone, 
    OfficeExtension, 
    HomePhone, 
    Other, 
    PhoneType, 
    Email, 
    MaritalStatus, 
    DOB, 
    Deceased, 
    Gender, 
    SSN, 
    Relationship, 
    HIPAARelationship, 
    ResponsiblePartyFID, 
    ProfileFID, 
    FinancialClassFID, 
    Employer, 
    EmployerFID, 
    InsuranceOrder, 
    AR_PatPortionFID, 
    AR_InsPortionFID, 
    CreatedAt, 
    CreatedBy, 
    Display, 
    RecalcBuckets, 
    FullName, 
    ChangedAt, 
    ChangedBy, 
    BucketsUpdatedAt, 
    BirthMonth, 
    IsDeceased, 
    EthnicityFID, 
    LanguageFID, 
    Language, 
    CommunicationNote, 
    ContactName, 
    Fax, 
    Cell, 
    Pager, 
    ConversionID, 
    PreferredCommunicationFID, 
    ConfidentialCommunicationFID, 
    Consent, 
    AdditionalMrn, 
    Inactive, 
    InactiveStatusFID, 
    GenderIdentityFID, 
    GenderIdentityOtherFID, 
    SexualOrientationFID, 
    SexualOrientationOtherFID, 
    PrimaryCarePhysicianFID, 
    PreviousFirstName, 
    PreviousMiddleName, 
    PreviousLastName, 
    PreviousAddress1, 
    PreviousAddress2, 
    PreviousCity, 
    PreviousState, 
    PreviousZipCode, 
    PreviousCountryCode, 
    TimeZoneFID, 
    PreferredFirstName, 
    PreferredMiddleName, 
    PreferredLastName)
  SELECT s.LicenseKey, 
    s.Patient_UID, 
    s.LastName, 
    s.FirstName, 
    s.MiddleName, 
    s.ChartNumber, 
    s.Title, 
    s.AptSte, 
    s.[Address], 
    s.ZipCode, 
    s.City, 
    s.[State], 
    s.AreaCode, 
    s.CountryCode, 
    s.OfficePhone, 
    s.OfficeExtension, 
    s.HomePhone, 
    s.Other, 
    s.PhoneType, 
    s.Email, 
    s.MaritalStatus, 
    s.DOB, 
    s.Deceased, 
    s.Gender, 
    s.SSN, 
    s.Relationship, 
    s.HIPAARelationship, 
    s.ResponsiblePartyFID, 
    s.ProfileFID, 
    s.FinancialClassFID, 
    s.Employer, 
    s.EmployerFID, 
    s.InsuranceOrder, 
    s.AR_PatPortionFID, 
    s.AR_InsPortionFID, 
    s.CreatedAt, 
    s.CreatedBy, 
    s.Display, 
    s.RecalcBuckets, 
    s.FullName, 
    s.ChangedAt, 
    s.ChangedBy, 
    s.BucketsUpdatedAt, 
    s.BirthMonth, 
    s.IsDeceased, 
    s.EthnicityFID, 
    s.LanguageFID, 
    s.Language, 
    s.CommunicationNote, 
    s.ContactName, 
    s.Fax, 
    s.Cell, 
    s.Pager, 
    s.ConversionID, 
    s.PreferredCommunicationFID, 
    s.ConfidentialCommunicationFID, 
    s.Consent, 
    s.AdditionalMrn, 
    s.Inactive, 
    s.InactiveStatusFID, 
    s.GenderIdentityFID, 
    s.GenderIdentityOtherFID, 
    s.SexualOrientationFID, 
    s.SexualOrientationOtherFID, 
    s.PrimaryCarePhysicianFID, 
    s.PreviousFirstName, 
    s.PreviousMiddleName, 
    s.PreviousLastName, 
    s.PreviousAddress1, 
    s.PreviousAddress2, 
    s.PreviousCity, 
    s.PreviousState, 
    s.PreviousZipCode, 
    s.PreviousCountryCode, 
    s.TimeZoneFID, 
    s.PreferredFirstName, 
    s.PreferredMiddleName, 
    s.PreferredLastName
  FROM (SELECT * FROM OPENQUERY([OAK], ''SELECT * FROM vw_ODBC_pt_PatientInfo WHERE CreatedAt > ''''' + @LastRunDate + ''''''')) s
  LEFT OUTER JOIN vw_ODBC_pt_PatientInfo t
    ON s.Patient_UID = t.Patient_UID
    AND s.LicenseKey = t.LicenseKey
  WHERE t.LicenseKey IS NULL'

  PRINT 'Starting to add new data for vw_ODBC_pt_PatientInfo'

  --Set the start time
  SET @DD = GETDATE()

EXECUTE sp_executesql @SQL

  --Insert the time to run into the table
  INSERT INTO ODBC_RunHistory VALUES(
    @RunHistoryID, 
    @RunDate, 
    'vw_ODBC_pt_PatientInfo', 
    'N',
    @DD,
    GETDATE(),
    CONVERT(varchar(100), GETDATE() - @DD, 14),
    @@ROWCOUNT
  )

  PRINT 'Adding new data for vw_ODBC_pt_PatientInfo is done!'+ Char(13) + Char(10)

  SET @SQL = '
UPDATE vw_ODBC_appts_Appointments
SET LicenseKey = t.LicenseKey, 
  Appointment_UID = t.Appointment_UID, 
  PatientFID = t.PatientFID, 
  ColumnHeadingFID = t.ColumnHeadingFID, 
  StartDateTime = t.StartDateTime, 
  Duration = t.Duration, 
  Color = t.Color, 
  ProfileFID = t.ProfileFID, 
  WaitList = t.WaitList, 
  Comments = t.Comments, 
  ApptStatus = t.ApptStatus, 
  ArriveTime = t.ArriveTime, 
  OtherTime = t.OtherTime, 
  SeenTime = t.SeenTime, 
  VisitPosted = t.VisitPosted, 
  ConfirmUser = t.ConfirmUser, 
  ConfirmDate = t.ConfirmDate, 
  ConfirmMethodFID = t.ConfirmMethodFID, 
  ChangedAt = t.ChangedAt, 
  CreatedAt = t.CreatedAt, 
  ChangedBy = t.ChangedBy, 
  CreatedBy = t.CreatedBy, 
  ReferralPlanFID = t.ReferralPlanFID, 
  UpdateReferral = t.UpdateReferral, 
  ExtraInsuranceInformationFID = t.ExtraInsuranceInformationFID, 
  EpisodeFID = t.EpisodeFID, 
  FacilityFID = t.FacilityFID, 
  VisitNote = t.VisitNote, 
  IncludeOnHCFA = t.IncludeOnHCFA, 
  InsuranceBillingSequence = t.InsuranceBillingSequence, 
  AcceptAssignment = t.AcceptAssignment, 
  ForcePaperClaim = t.ForcePaperClaim, 
  PaymentFID = t.PaymentFID, 
  ApprovedBy = t.ApprovedBy, 
  ApprovedAt = t.ApprovedAt, 
  ClaimEditStatusFID = t.ClaimEditStatusFID, 
  ReferenceID = t.ReferenceID, 
  DocumentationComplete = t.DocumentationComplete, 
  ApptTypes = t.ApptTypes, 
  ApptInstructions = t.ApptInstructions, 
  RecurringAppointmentFID = t.RecurringAppointmentFID, 
  BillingNote = t.BillingNote, 
  VisitActionHistoryFID = t.VisitActionHistoryFID, 
  PendingDate = t.PendingDate, 
  IsTeleMedicine = t.IsTeleMedicine, 
  AppointmentGroupFID = t.AppointmentGroupFID
FROM vw_ODBC_appts_Appointments s
  INNER JOIN (SELECT * FROM OPENQUERY([OAK], ''SELECT * FROM vw_ODBC_appts_Appointments WHERE ChangedAt > ''''' + @LastRunDate + ''''''')) t
    ON s.Appointment_UID = t.Appointment_UID
    AND s.LicenseKey = t.LicenseKey'

  PRINT 'Starting to update data for vw_ODBC_appts_Appointments'

  --Set the start time
  SET @DD = GETDATE()

EXECUTE sp_executesql @SQL

  --Insert the time to run into the table
  INSERT INTO ODBC_RunHistory VALUES(
    @RunHistoryID, 
    @RunDate, 
    'vw_ODBC_appts_Appointments', 
    'U',
    @DD,
    GETDATE(),
    CONVERT(varchar(100), GETDATE() - @DD, 14),
    @@ROWCOUNT
  )

  PRINT 'Data update for vw_ODBC_appts_Appointments is done!'+ Char(13) + Char(10)

SET @SQL = '
INSERT INTO vw_ODBC_appts_Appointments (LicenseKey, 
    Appointment_UID, 
    PatientFID, 
    ColumnHeadingFID, 
    StartDateTime, 
    Duration, 
    Color, 
    ProfileFID, 
    WaitList, 
    Comments, 
    ApptStatus, 
    ArriveTime, 
    OtherTime, 
    SeenTime, 
    VisitPosted, 
    ConfirmUser, 
    ConfirmDate, 
    ConfirmMethodFID, 
    ChangedAt, 
    CreatedAt, 
    ChangedBy, 
    CreatedBy, 
    ReferralPlanFID, 
    UpdateReferral, 
    ExtraInsuranceInformationFID, 
    EpisodeFID, 
    FacilityFID, 
    VisitNote, 
    IncludeOnHCFA, 
    InsuranceBillingSequence, 
    AcceptAssignment, 
    ForcePaperClaim, 
    PaymentFID, 
    ApprovedBy, 
    ApprovedAt, 
    ClaimEditStatusFID, 
    ReferenceID, 
    DocumentationComplete, 
    ApptTypes, 
    ApptInstructions, 
    RecurringAppointmentFID, 
    BillingNote, 
    VisitActionHistoryFID, 
    PendingDate, 
    IsTeleMedicine, 
    AppointmentGroupFID)
  SELECT s.LicenseKey, 
    s.Appointment_UID, 
    s.PatientFID, 
    s.ColumnHeadingFID, 
    s.StartDateTime, 
    s.Duration, 
    s.Color, 
    s.ProfileFID, 
    s.WaitList, 
    s.Comments, 
    s.ApptStatus, 
    s.ArriveTime, 
    s.OtherTime, 
    s.SeenTime, 
    s.VisitPosted, 
    s.ConfirmUser, 
    s.ConfirmDate, 
    s.ConfirmMethodFID, 
    s.ChangedAt, 
    s.CreatedAt, 
    s.ChangedBy, 
    s.CreatedBy, 
    s.ReferralPlanFID, 
    s.UpdateReferral, 
    s.ExtraInsuranceInformationFID, 
    s.EpisodeFID, 
    s.FacilityFID, 
    s.VisitNote, 
    s.IncludeOnHCFA, 
    s.InsuranceBillingSequence, 
    s.AcceptAssignment, 
    s.ForcePaperClaim, 
    s.PaymentFID, 
    s.ApprovedBy, 
    s.ApprovedAt, 
    s.ClaimEditStatusFID, 
    s.ReferenceID, 
    s.DocumentationComplete, 
    s.ApptTypes, 
    s.ApptInstructions, 
    s.RecurringAppointmentFID, 
    s.BillingNote, 
    s.VisitActionHistoryFID, 
    s.PendingDate, 
    s.IsTeleMedicine, 
    s.AppointmentGroupFID
  FROM (SELECT * FROM OPENQUERY([OAK], ''SELECT * FROM vw_ODBC_appts_Appointments WHERE CreatedAt > ''''' + @LastRunDate + ''''''')) s
  LEFT OUTER JOIN vw_ODBC_appts_Appointments t
    ON s.Appointment_UID = t.Appointment_UID
    AND s.LicenseKey = t.LicenseKey
  WHERE t.LicenseKey IS NULL'

  PRINT 'Starting to add new data for vw_ODBC_appts_Appointments'

  --Set the start time
  SET @DD = GETDATE()

EXECUTE sp_executesql @SQL

  --Insert the time to run into the table
  INSERT INTO ODBC_RunHistory VALUES(
    @RunHistoryID, 
    @RunDate, 
    'vw_ODBC_appts_Appointments', 
    'N',
    @DD,
    GETDATE(),
    CONVERT(varchar(100), GETDATE() - @DD, 14),
    @@ROWCOUNT
  )

  PRINT 'Adding new data for vw_ODBC_appts_Appointments is done!'+ Char(13) + Char(10)

  
SET @SQL = '
UPDATE vw_ODBC_mf_PGProviders
SET LicenseKey = t.LicenseKey, 
  Provider_UID = t.Provider_UID, 
  LastName = t.LastName, 
  FirstName = t.FirstName, 
  MiddleName = t.MiddleName, 
  Title = t.Title, 
  Cell = t.Cell, 
  Pager = t.Pager, 
  HomePhone = t.HomePhone, 
  Email = t.Email, 
  FinancialSummaryFID = t.FinancialSummaryFID, 
  AccountReceivableFID = t.AccountReceivableFID, 
  PracticeFID = t.PracticeFID, 
  [Type] = t.[Type], 
  [Status] = t.[Status], 
  IsInstitutional = t.IsInstitutional, 
  PayScheduleFID = t.PayScheduleFID, 
  InactiveAt = t.InactiveAt, 
  InactiveBy = t.InactiveBy, 
  Display = t.Display, 
  UPINNumber = t.UPINNumber, 
  EMRAccess = t.EMRAccess, 
  EMRActiveAt = t.EMRActiveAt, 
  CreatedBy = t.CreatedBy, 
  CreatedAt = t.CreatedAt, 
  ChangedBy = t.ChangedBy, 
  ChangedAt = t.ChangedAt, 
  FullName = t.FullName, 
  VerificationStatusFID = t.VerificationStatusFID, 
  VerificationAttempt = t.VerificationAttempt, 
  PreferredName = t.PreferredName, 
  Specialty = t.Specialty, 
  PreferredPhone = t.PreferredPhone, 
  [Description] = t.[Description], 
  HasOLSProfileImage = t.HasOLSProfileImage, 
  ProviderTypeFID = t.ProviderTypeFID, 
  PDMPConsentDate = t.PDMPConsentDate, 
  PracticeOrganizationNameFID = t.PracticeOrganizationNameFID
FROM vw_ODBC_mf_PGProviders s
  INNER JOIN (SELECT * FROM OPENQUERY([OAK], ''SELECT * FROM vw_ODBC_mf_PGProviders WHERE ChangedAt > ''''' + @LastRunDate + ''''''')) t
    ON s.Provider_UID = t.Provider_UID
    AND s.LicenseKey = t.LicenseKey'

  PRINT 'Starting to update data for vw_ODBC_mf_PGProviders'

  --Set the start time
  SET @DD = GETDATE()

EXECUTE sp_executesql @SQL

  --Insert the time to run into the table
  INSERT INTO ODBC_RunHistory VALUES(
    @RunHistoryID, 
    @RunDate, 
    'vw_ODBC_mf_PGProviders', 
    'U',
    @DD,
    GETDATE(),
    CONVERT(varchar(100), GETDATE() - @DD, 14),
    @@ROWCOUNT
  )

  PRINT 'Data update for vw_ODBC_mf_PGProviders is done!'+ Char(13) + Char(10)

SET @SQL = '
INSERT INTO vw_ODBC_mf_PGProviders (LicenseKey, 
    Provider_UID, 
    LastName, 
    FirstName, 
    MiddleName, 
    Title, 
    Cell, 
    Pager, 
    HomePhone, 
    Email, 
    FinancialSummaryFID, 
    AccountReceivableFID, 
    PracticeFID, 
    [Type], 
    [Status], 
    IsInstitutional, 
    PayScheduleFID, 
    InactiveAt, 
    InactiveBy, 
    Display, 
    UPINNumber, 
    EMRAccess, 
    EMRActiveAt, 
    CreatedBy, 
    CreatedAt, 
    ChangedBy, 
    ChangedAt, 
    FullName, 
    VerificationStatusFID, 
    VerificationAttempt, 
    PreferredName, 
    Specialty, 
    PreferredPhone, 
    [Description], 
    HasOLSProfileImage, 
    ProviderTypeFID, 
    PDMPConsentDate, 
    PracticeOrganizationNameFID)
  SELECT s.LicenseKey, 
    s.Provider_UID, 
    s.LastName, 
    s.FirstName, 
    s.MiddleName, 
    s.Title, 
    s.Cell, 
    s.Pager, 
    s.HomePhone, 
    s.Email, 
    s.FinancialSummaryFID, 
    s.AccountReceivableFID, 
    s.PracticeFID, 
    s.[Type], 
    s.[Status], 
    s.IsInstitutional, 
    s.PayScheduleFID, 
    s.InactiveAt, 
    s.InactiveBy, 
    s.Display, 
    s.UPINNumber, 
    s.EMRAccess, 
    s.EMRActiveAt, 
    s.CreatedBy, 
    s.CreatedAt, 
    s.ChangedBy, 
    s.ChangedAt, 
    s.FullName, 
    s.VerificationStatusFID, 
    s.VerificationAttempt, 
    s.PreferredName, 
    s.Specialty, 
    s.PreferredPhone, 
    s.[Description], 
    s.HasOLSProfileImage, 
    s.ProviderTypeFID, 
    s.PDMPConsentDate, 
    s.PracticeOrganizationNameFID
  FROM (SELECT * FROM OPENQUERY([OAK], ''SELECT * FROM vw_ODBC_mf_PGProviders WHERE CreatedAt > ''''' + @LastRunDate + ''''''')) s
  LEFT OUTER JOIN vw_ODBC_mf_PGProviders t
    ON s.Provider_UID = t.Provider_UID
    AND s.LicenseKey = t.LicenseKey
  WHERE t.LicenseKey IS NULL'

  PRINT 'Starting to add new data for vw_ODBC_mf_PGProviders'

  --Set the start time
  SET @DD = GETDATE()

EXECUTE sp_executesql @SQL

  --Insert the time to run into the table
  INSERT INTO ODBC_RunHistory VALUES(
    @RunHistoryID, 
    @RunDate, 
    'vw_ODBC_mf_PGProviders', 
    'N',
    @DD,
    GETDATE(),
    CONVERT(varchar(100), GETDATE() - @DD, 14),
    @@ROWCOUNT
  )

  PRINT 'Adding new data for vw_ODBC_mf_PGProviders is done!'+ Char(13) + Char(10)

  select * from ODBC_RunHistory