SET NOCOUNT ON;
-- VARIABLES DECLARATION
DECLARE @Counter INT,
		@CurrentTable varchar(255),
		@SQL varchar(max),
		@LSName varchar(100)

-- Linked Server Name
SET @LSName = 'OAK'

--Creating the View List
CREATE TABLE #ODBC_VIEWS (
	view_id int not null IDENTITY(1,1),
	View_name varchar(150) null
	);

-- populating the list of PM Views
INSERT INTO #ODBC_VIEWS (view_name)
	Select 'vw_ODBC_pt_PatientInfo'
	UNION Select 'vw_ODBC_appts_Appointments'
	UNION Select 'vw_ODBC_mf_PGProfiles';

--to control the updates
IF OBJECT_ID (N'ODBC_RunHistory', N'U') IS NULL 
BEGIN
	CREATE TABLE ODBC_RunHistory (
	  RunHistoryID int,
	  RunDate datetime,
	  TableName varchar(100),
	  [Type] char(1),
	  BeginTime datetime,
	  EndTime datetime,
	  RunTime varchar(20),
	  [Rows] int
	)
	print 'Table ODBC_RunHistory was created';
END

SET NOCOUNT OFF;
-- loop the view list to create the structure automatically
SET @Counter=1

WHILE ( @Counter <= (SELECT max(view_id) FROM #ODBC_VIEWS))
BEGIN
    SELECT @CurrentTable = View_name FROM #ODBC_VIEWS WHERE view_id = @Counter;

	-- If it doesnt exists, creates the table from the structure available from the ODBC Connection
	IF OBJECT_ID (N''+@CurrentTable+'', N'U') IS NULL 
	BEGIN
	SET NOCOUNT ON;
	SET @SQL = 'select top 0 * into '+@CurrentTable+' from OPENQUERY(['+@LSName+'],''select top 0 * from '+@CurrentTable+''')';
	EXECUTE (@SQL)
	SET NOCOUNT OFF;
	print 'Table '+@CurrentTable+' was created';

	END
    
	SET @Counter  = @Counter  + 1
END

drop table #ODBC_VIEWS;


