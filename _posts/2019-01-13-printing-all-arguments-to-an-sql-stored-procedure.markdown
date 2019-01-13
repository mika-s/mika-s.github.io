---
layout: post
title:  "Printing all arguments to a SQL stored procedure (for SQL Server)"
date:   2019-01-13 15:00:00 +0100
categories: sql debugging stored-procedure
---

Here's a short SQL script I made that can be used to print all the arguments passed to a given
stored procedure. It's for SQL Server and will not work with other RMDBS. It can be used,
for example, for debugging business logic that is represented as stored procedures. By print
I mean the [print statement][print-statement-docs] that exists in Transact-SQL.

To use it, run this script in SQL Server Management Studio:


```sql
IF OBJECT_ID('tempdb..#Params') IS NOT NULL DROP TABLE #Params

CREATE TABLE #Params (Id INT IDENTITY(1,1), ParamName VARCHAR(300), ParamType VARCHAR(20))

INSERT INTO #Params
  SELECT name AS 'ParamName', type_name(user_type_id) AS 'ParamType'
  FROM sys.parameters
  WHERE object_id = object_id('dbo.AddOrderToCustomer')

DECLARE @CurrentString    VARCHAR(MAX) = ''
DECLARE @FinalString      VARCHAR(MAX) = 'DECLARE @DebugString VARCHAR(MAX) = '''''
DECLARE @CurrentParamName VARCHAR(300)
DECLARE @CurrentParamType VARCHAR(20)

DECLARE @Pos INT = 1
DECLARE @Cnt INT
SELECT @Cnt = COUNT(*) FROM #Params

WHILE @Pos <= @Cnt
BEGIN
  SELECT @CurrentParamName = ParamName, @CurrentParamType = ParamType
  FROM #Params WHERE Id = @Pos

  SET @CurrentString = '+ char(13) + char(10) + char(9) + ''' +
    CASE
      WHEN @CurrentParamType IN ('varchar', 'char') THEN
        @CurrentParamName + ': '' + ' + 'ISNULL(' + @CurrentParamName + ', ''NULL'')'
      WHEN @CurrentParamType IN ('int', 'money', 'datetime', 'uniqueidentifier', 'bit') THEN
        @CurrentParamName + ': '' + ' + 'ISNULL(CONVERT(VARCHAR(200), ' + @CurrentParamName + '), ''NULL'')'
      ELSE
        @CurrentParamName + ': '' + ' + 'ISNULL(' + @CurrentParamName + ', ''NULL'')'
      END

  SET @FinalString = @FinalString + char(13) + char(10) + char(9) + @CurrentString
  SET @Pos = @Pos + 1
END

SET @FinalString = @FinalString + char(13) + char(10) + 'PRINT @DebugString'

PRINT @FinalString

DROP TABLE #Params
```

It will output a string that can be copied and pasted at the top of the stored procedure. It doesn't
have any other effects, other than creating a temporary table that is dropped at the end. You have to
insert the name of the stored procedure as an argument to `object_id()`.

---
Here's an example:

In my case I have a stored procedure called `AddOrderToCustomer` that is called like this:

```sql
EXEC AddOrderToCustomer
   @IsAlreadyCustomer = 0
  ,@CustomerId = NULL
  ,@OrderId = 123
  ,@Address1 = 'A Street'
  ,@Address2 = ''
  ,@PostalCode = '12345'
  ,@City = 'A-TOWN'
  ,@Country = 'Antartica'
```

When I run the script with `dbo.AddOrderToCustomer` as an argument it will output the following string:

```sql
DECLARE @DebugString VARCHAR(MAX) = ''
  + char(13) + char(10) + char(9) + '@IsAlreadyCustomer: ' + ISNULL(CONVERT(VARCHAR(200), @IsAlreadyCustomer), 'NULL')
  + char(13) + char(10) + char(9) + '@CustomerId: ' + ISNULL(CONVERT(VARCHAR(200), @CustomerId), 'NULL')
  + char(13) + char(10) + char(9) + '@OrderId: ' + ISNULL(CONVERT(VARCHAR(200), @OrderId), 'NULL')
  + char(13) + char(10) + char(9) + '@Address1: ' + ISNULL(@Address1, 'NULL')
  + char(13) + char(10) + char(9) + '@Address2: ' + ISNULL(@Address2, 'NULL')
  + char(13) + char(10) + char(9) + '@PostalCode: ' + ISNULL(@PostalCode, 'NULL')
  + char(13) + char(10) + char(9) + '@City: ' + ISNULL(@City, 'NULL')
  + char(13) + char(10) + char(9) + '@Country: ' + ISNULL(@Country, 'NULL')
PRINT @DebugString
```

This can be copied and pasted into the beginning of the stored procedure. When calling the stored
procedure now we will get the following printed into the Messages window:

```
  @IsAlreadyCustomer: 0
  @CustomerId: NULL
  @OrderId: 123
  @Address1: A Street
  @Address2:
  @PostalCode: 12345
  @City: A-TOWN
  @Country: Antartica
```

`char(13)` is CR, `char(10)` is LF and `char(9)` is tab. They can be removed of course, if you want
everything on one line.

[print-statement-docs]: https://docs.microsoft.com/en-us/sql/t-sql/language-elements/print-transact-sql
