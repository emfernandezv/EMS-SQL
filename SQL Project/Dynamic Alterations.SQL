SET NOCOUNT ON;
-- VARIABLES DECLARATION
DECLARE @Counter INT,
		@CurrentTable varchar(255),
		@ODBCTable varchar(255),
		@SQL varchar(max),
		@LSName varchar(100)

-- Linked Server Name
SET @LSName = 'OAK'

--Creating the View List
CREATE TABLE #ODBC_VIEWS (
	view_id int not null IDENTITY(1,1),
	View_name varchar(150) null,
	View_odbc varchar(150) null
	);

-- populating the list of existing PM Views from the local database
INSERT INTO #ODBC_VIEWS (view_name,View_odbc)
SELECT Name,Name+'_new'
FROM sys.tables
WHERE name like 'vw_odbc_%'

--Table that will capture all the modifications needed
	CREATE TABLE #scripts
		(id int not null IDENTITY(1,1),
		 header varchar(10),
		 script varchar(max));

-- loop the view list to create the structure automatically
SET @Counter=1

WHILE ( @Counter <= (SELECT max(view_id) FROM #ODBC_VIEWS))
BEGIN
    SELECT @CurrentTable = View_name FROM #ODBC_VIEWS WHERE view_id = @Counter;

	-- If it exists, creates a comparison table for each to compare existing vs new structure from the ODBC Connection
	IF OBJECT_ID (N''+@CurrentTable+'', N'U') IS NOT NULL 
	BEGIN

	SET @ODBCTable = @CurrentTable+'_new'
	SET @SQL = 'select  top 0 * into '+@ODBCTable+' from OPENQUERY([OAK],''select top 0 * from '+@CurrentTable+''')'

	EXECUTE (@SQL)
	--print 'Comparison Table '+@CurrentTable+' was created';

	SELECT	
			TABLE_CATALOG,
			TABLE_SCHEMA,
			TABLE_NAME,
			COLUMN_NAME,
			CASE WHEN IS_NULLABLE = 'YES' THEN 'NULL' ELSE 'NOT NULL' END as IS_NULLABLE,
			DATA_TYPE,
			CHARACTER_MAXIMUM_LENGTH,
			CHARACTER_OCTET_LENGTH,
			NUMERIC_PRECISION,
			NUMERIC_SCALE
	INTO	#current_table
	FROM
			INFORMATION_SCHEMA.COLUMNS
	WHERE
			TABLE_NAME =  @CurrentTable;

	SELECT	TABLE_CATALOG,
			TABLE_SCHEMA,
			LEFT(TABLE_NAME,len(TABLE_NAME)-4) as TABLE_NAME,
			COLUMN_NAME,
			CASE WHEN IS_NULLABLE = 'YES' THEN 'NULL' ELSE 'NOT NULL' END as IS_NULLABLE,
			DATA_TYPE,
			CHARACTER_MAXIMUM_LENGTH,
			CHARACTER_OCTET_LENGTH,
			NUMERIC_PRECISION,
			NUMERIC_SCALE
	INTO	#odbc_table
	FROM
			INFORMATION_SCHEMA.COLUMNS
	WHERE
			TABLE_NAME =  @ODBCTable;

	-- IDENTIFYING NEW FIELDS FROM THE ODBC
	SELECT	#odbc_table.* 
	INTO	#new_fields
	FROM	#odbc_table
	WHERE	#odbc_table.COLUMN_NAME not in (SELECT	#current_table.COLUMN_NAME
											FROM	#current_table
											WHERE	#current_table.TABLE_CATALOG = #odbc_table.TABLE_CATALOG
												and	#current_table.TABLE_SCHEMA = #odbc_table.TABLE_SCHEMA
												and	#current_table.TABLE_NAME = #odbc_table.TABLE_NAME);

	--print '--changes for table'+@CurrentTable

	-- CREATING THE SCRIPT TO ADD NEW FIELDS
	IF (SELECT count(*) FROM #new_fields) > 0
	BEGIN
		INSERT INTO #scripts (header,script)
		SELECT	'ADD',
				CASE 
					WHEN isnull(CHARACTER_MAXIMUM_LENGTH,0) > 0 -- DATA_TYPE in ('varchar','char','text','nvarchar','varbinary')
						THEN 'ALTER TABLE '+TABLE_NAME+' ADD '+COLUMN_NAME+' '+DATA_TYPE+'('+convert(varchar,CHARACTER_MAXIMUM_LENGTH)+') '+IS_NULLABLE+';'
					WHEN isnull(NUMERIC_PRECISION,0) > 0 and  DATA_TYPE not in ('int') -- DATA_TYPE in ('decimal')
						THEN 'ALTER TABLE '+TABLE_NAME+' ADD '+COLUMN_NAME+' '+DATA_TYPE+'('+convert(varchar,NUMERIC_PRECISION)+','+convert(varchar,NUMERIC_SCALE)+') '+IS_NULLABLE+';'
					ELSE -- DATA_TYPE in ('datetime','bit','money','date','bigint','tinyint','smallint','smallmoney','smalldatetime')
						'ALTER TABLE '+TABLE_NAME+' ADD '+COLUMN_NAME+' '+DATA_TYPE+' '+IS_NULLABLE+';'
				END

		FROM	#new_fields;
	END

	-- IDENTIFYING EXISTING FIELDS WITH NEW DIMENSIONS
	SELECT	#odbc_table.* 
	INTO	#updated_fields
	FROM	#odbc_table,
			#current_table
	WHERE	#current_table.TABLE_CATALOG = #odbc_table.TABLE_CATALOG
		and	#current_table.TABLE_SCHEMA = #odbc_table.TABLE_SCHEMA
		and	#current_table.TABLE_NAME = #odbc_table.TABLE_NAME
		and	#current_table.COLUMN_NAME = #odbc_table.COLUMN_NAME
		and (#current_table.CHARACTER_MAXIMUM_LENGTH <> #odbc_table.CHARACTER_MAXIMUM_LENGTH 
			OR (#current_table.NUMERIC_PRECISION <> #odbc_table.NUMERIC_PRECISION 
				OR #current_table.NUMERIC_SCALE <> #odbc_table.NUMERIC_SCALE ));
	
	declare @hola datetime2 

	-- CREATING THE SCRIPT TO ALTER CURRENT FIELDS WITH NEW DIMENSIONS
	IF (SELECT count(*) FROM #updated_fields) > 0
	BEGIN
		INSERT INTO #scripts (header,script)
		SELECT		'ALTER',
					CASE 
					WHEN isnull(CHARACTER_MAXIMUM_LENGTH,0) > 0 -- DATA_TYPE in ('varchar','char','text','nvarchar','varbinary')
						THEN 'ALTER TABLE '+TABLE_NAME+' ALTER COLUMN '+COLUMN_NAME+' '+DATA_TYPE+'('+convert(varchar,CHARACTER_MAXIMUM_LENGTH)+') '+IS_NULLABLE+';'
					WHEN isnull(NUMERIC_PRECISION,0) > 0 and  DATA_TYPE not in ('int') -- DATA_TYPE in ('decimal')
						THEN 'ALTER TABLE '+TABLE_NAME+' ALTER COLUMN '+COLUMN_NAME+' '+DATA_TYPE+'('+convert(varchar,NUMERIC_PRECISION)+','+convert(varchar,NUMERIC_SCALE)+') '+IS_NULLABLE+';'
					ELSE -- DATA_TYPE in ('int','datetime','bit','money','date','bigint','tinyint','smallint','smallmoney','smalldatetime')
						'ALTER TABLE '+TABLE_NAME+' ALTER COLUMN '+COLUMN_NAME+' '+DATA_TYPE+' '+IS_NULLABLE+';'
				END

		FROM	#updated_fields;
	END

	-- IDENTIFYING DROPPED FIELDS FROM THE ODBC
	SELECT	#current_table.* 
	INTO	#drop_fields
	FROM	#current_table
	WHERE	#current_table.COLUMN_NAME not in (SELECT	#odbc_table.COLUMN_NAME
											FROM	#odbc_table
											WHERE	#current_table.TABLE_CATALOG = #odbc_table.TABLE_CATALOG
												and	#current_table.TABLE_SCHEMA = #odbc_table.TABLE_SCHEMA
												and	#current_table.TABLE_NAME = #odbc_table.TABLE_NAME);

	-- CREATING THE SCRIPT TO ALTER CURRENT FIELDS WITH NEW DIMENSIONS
	IF (SELECT count(*) FROM #updated_fields) > 0
	BEGIN
		INSERT INTO #scripts (header,script)
		SELECT		'DROP',
					'ALTER TABLE '+TABLE_NAME+' DROP COLUMN '+COLUMN_NAME+';'
		FROM	#drop_fields;
	END

	
	
	-- TO DROP THE TEMPORAL TABLE USED
	SET @SQL = 'DROP TABLE '+@ODBCTable+'';
	EXECUTE (@SQL)

	DROP TABLE #odbc_table;
	DROP TABLE #current_table;
	DROP TABLE #new_fields;
	DROP TABLE #updated_fields;
	DROP TABLE #drop_fields;

	END
    
	SET @Counter  = @Counter  + 1;
END

SET NOCOUNT OFF;

-- looping through the changes of structure and applying it to the local database
SET @Counter=1
WHILE ( @Counter <= (SELECT max(id) FROM #scripts))
BEGIN
	
	SELECT @SQL = script FROM #scripts WHERE id = @Counter;
	print 'Executed: '+@sql;
	EXECUTE (@SQL);

	SET @Counter  = @Counter  + 1;
END

DROP TABLE #scripts;
DROP TABLE #ODBC_VIEWS;




