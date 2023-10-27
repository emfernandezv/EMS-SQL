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

--creates first entries ID if there is none
IF @RunHistoryID IS NULL
  BEGIN 
    SET @RunHistoryID = 1
    SET @LastRunDate = '1/1/1900'
  END

-- ot update the patients table
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
  [SendApptReminderCall] = isnull(t.[SendApptReminderCall],0),
  [SendOnlineStatementText] = t.[SendOnlineStatementText],
  [SendOnlineStatementEmail] = t.[SendOnlineStatementEmail],
  [SendApptReminderToResponsibleParty] = t.[SendApptReminderToResponsibleParty],
  [SendApptReminderText] = t.[SendApptReminderText],
  [SendOtherEmail] = t.[SendOtherEmail],
  [SendOtherText] = t.[SendOtherText],
  [SendNotificationEmail] = t.[SendNotificationEmail],
  [SendNotificationText] = isnull(t.[SendNotificationText],0)
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

  -- to insert new patients table
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
    PreferredLastName,
	[SendApptReminderEmail] ,
  [SendOnlineStatementText],
  [SendOnlineStatementEmail],
  [SendApptReminderToResponsibleParty],
  [SendApptReminderText],
  [SendOtherEmail],
  [SendOtherText],
  [SendNotificationEmail],
  [SendNotificationText],
  [SendApptReminderCall])
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
    s.PreferredLastName,
	s.[SendApptReminderEmail] ,
  s.[SendOnlineStatementText],
  s.[SendOnlineStatementEmail],
  s.[SendApptReminderToResponsibleParty],
  s.[SendApptReminderText],
  s.[SendOtherEmail],
  s.[SendOtherText],
  s.[SendNotificationEmail],
  isnull(s.[SendNotificationText],0),
  isnull(s.[SendApptReminderCall],0)
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
  
  -- ot update the appointments table
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
  -- ot insert new appointments data
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

  -- ot update the providers table

SET @SQL = '
UPDATE vw_ODBC_mf_PGProfiles
SET LicenseKey = t.LicenseKey, 
  Profile_UID = t.Profile_UID, 
  ProfileCode = t.ProfileCode, 
  [Description] = t.[Description], 
  AptSte = t.AptSte, 
  [Address] = t.[Address], 
  ZipCode = t.ZipCode, 
  City = t.City, 
  [State] = t.[State], 
  AreaCode = t.AreaCode, 
  CountryCode = t.CountryCode, 
  OfficePhone = t.OfficePhone, 
  OfficeExtension = t.OfficeExtension, 
  Fax = t.Fax, 
  FacilityFID = t.FacilityFID, 
  License = t.License, 
  FederalID = t.FederalID, 
  CLIANumber = t.CLIANumber, 
  UserFileFID = t.UserFileFID, 
  FeeScheduleFID = t.FeeScheduleFID, 
  FinancialSummaryFID = t.FinancialSummaryFID, 
  AccountReceivableFID = t.AccountReceivableFID, 
  ProviderFID = t.ProviderFID, 
  GroupFID = t.GroupFID, 
  PracticeFID = t.PracticeFID, 
  ReferringProviderFID = t.ReferringProviderFID, 
  StatementGroupFID = t.StatementGroupFID, 
  Display = t.Display, 
  BillAsFID = t.BillAsFID, 
  Taxonomy = t.Taxonomy, 
  NPINumber = t.NPINumber, 
  XRefIDsChangedAt = t.XRefIDsChangedAt, 
  IsDefault = t.IsDefault, 
  HideInChargeEntry = t.HideInChargeEntry, 
  CreatedBy = t.CreatedBy, 
  CreatedAt = t.CreatedAt, 
  ChangedBy = t.ChangedBy, 
  ChangedAt = t.ChangedAt, 
  CodeSetPreference = t.CodeSetPreference, 
  DEANumber = t.DEANumber, 
  NADEANumber = t.NADEANumber
FROM vw_ODBC_mf_PGProfiles s
  INNER JOIN (SELECT * FROM OPENQUERY([OAK], ''SELECT * FROM vw_ODBC_mf_PGProfiles WHERE ChangedAt > ''''' + @LastRunDate + ''''''')) t
    ON s.Profile_UID = t.Profile_UID
    AND s.LicenseKey = t.LicenseKey'

  PRINT 'Starting to update data for vw_ODBC_mf_PGProfiles'

  --Set the start time
  SET @DD = GETDATE()

EXECUTE sp_executesql @SQL

  --Insert the time to run into the table
  INSERT INTO ODBC_RunHistory VALUES(
    @RunHistoryID, 
    @RunDate, 
    'vw_ODBC_mf_PGProfiles', 
    'U',
    @DD,
    GETDATE(),
    CONVERT(varchar(100), GETDATE() - @DD, 14),
    @@ROWCOUNT
  )

  PRINT 'Data update for vw_ODBC_mf_PGProfiles is done!'+ Char(13) + Char(10)

SET @SQL = '
INSERT INTO vw_ODBC_mf_PGProfiles (LicenseKey, 
    Profile_UID, 
    ProfileCode, 
    [Description], 
    AptSte, 
    [Address], 
    ZipCode, 
    City, 
    [State], 
    AreaCode, 
    CountryCode, 
    OfficePhone, 
    OfficeExtension, 
    Fax, 
    FacilityFID, 
    License, 
    FederalID, 
    CLIANumber, 
    UserFileFID, 
    FeeScheduleFID, 
    FinancialSummaryFID, 
    AccountReceivableFID, 
    ProviderFID, 
    GroupFID, 
    PracticeFID, 
    ReferringProviderFID, 
    StatementGroupFID, 
    Display, 
    BillAsFID, 
    Taxonomy, 
    NPINumber, 
    XRefIDsChangedAt, 
    IsDefault, 
    HideInChargeEntry, 
    CreatedBy, 
    CreatedAt, 
    ChangedBy, 
    ChangedAt, 
    CodeSetPreference, 
    DEANumber, 
    NADEANumber)
  SELECT s.LicenseKey, 
    s.Profile_UID, 
    s.ProfileCode, 
    s.[Description], 
    s.AptSte, 
    s.[Address], 
    s.ZipCode, 
    s.City, 
    s.[State], 
    s.AreaCode, 
    s.CountryCode, 
    s.OfficePhone, 
    s.OfficeExtension, 
    s.Fax, 
    s.FacilityFID, 
    s.License, 
    s.FederalID, 
    s.CLIANumber, 
    s.UserFileFID, 
    s.FeeScheduleFID, 
    s.FinancialSummaryFID, 
    s.AccountReceivableFID, 
    s.ProviderFID, 
    s.GroupFID, 
    s.PracticeFID, 
    s.ReferringProviderFID, 
    s.StatementGroupFID, 
    s.Display, 
    s.BillAsFID, 
    s.Taxonomy, 
    s.NPINumber, 
    s.XRefIDsChangedAt, 
    s.IsDefault, 
    s.HideInChargeEntry, 
    s.CreatedBy, 
    s.CreatedAt, 
    s.ChangedBy, 
    s.ChangedAt, 
    s.CodeSetPreference, 
    s.DEANumber, 
    s.NADEANumber
  FROM (SELECT * FROM OPENQUERY([OAK], ''SELECT * FROM vw_ODBC_mf_PGProfiles WHERE CreatedAt > ''''' + @LastRunDate + ''''''')) s
  LEFT OUTER JOIN vw_ODBC_mf_PGProfiles t
    ON s.Profile_UID = t.Profile_UID
    AND s.LicenseKey = t.LicenseKey
  WHERE t.LicenseKey IS NULL'

  PRINT 'Starting to add new data for vw_ODBC_mf_PGProfiles'

  --Set the start time
  SET @DD = GETDATE()

EXECUTE sp_executesql @SQL

  --Insert the time to run into the table
  INSERT INTO ODBC_RunHistory VALUES(
    @RunHistoryID, 
    @RunDate, 
    'vw_ODBC_mf_PGProfiles', 
    'N',
    @DD,
    GETDATE(),
    CONVERT(varchar(100), GETDATE() - @DD, 14),
    @@ROWCOUNT
  )

  PRINT 'Adding new data for vw_ODBC_mf_PGProfiles is done!'+ Char(13) + Char(10)

  select * from ODBC_RunHistory