---
layout: post
title:  "Notes on 70-761: Querying Data with Transact-SQL"
date:   2019-05-05 15:00:00 +0100
categories: sql certification 70-761
---

These are some notes I took for the Microsoft exam 70-761: Querying Data with Transact-SQL,
which is a part of [MCSA: SQL 2016 Database Development][microsoft-mcsa-sql-2016-database-development].

This is for the syllabus as it was in May 2019. The syllabus might change in the future.

## Manage data with Transact-SQL (40–45%)

# Create Transact-SQL SELECT queries

### Syllabus

*Identify proper SELECT query structure, write specific queries to satisfy
business requirements, construct results from multiple queries using set operators,
distinguish between UNION and UNION ALL behaviour, identify the query that would return
expected results based on provided table structure and/or data*

#### SELECT in general

General `SELECT`:

```sql
SELECT * FROM accounts
```

`SELECT` with `WHERE` clause:

```sql
SELECT * FROM accounts WHERE accountId = 12
```

`SELECT` with `WHERE` clause containing `AND`:

```sql
SELECT * FROM customers WHERE city = 'New York City' AND gender = 'Male'
```

`SELECT` that only gets certain columns:

```sql
SELECT firstName, lastName FROM customers
```

`SELECT` with alias for columns:

```sql
SELECT firstName AS [First name], lastName AS [Last name] FROM customers
```

or

```sql
SELECT firstName AS 'First name', lastName AS 'Last name' FROM customers
```

Get only distinct elements:

```sql
SELECT DISTINCT lastName FROM customers
```

Search with `LIKE`:

```sql
SELECT * FROM customers WHERE lastName LIKE '%son'
```

Wildcards:

| Wildcard | Description                                 |
|----------|---------------------------------------------|
| `%`      | Any string                                  |
| `_`      | Any single character                        |
| `[ABC]`  | A single character, either A, B or C        |
| `[A-R]`  | A single character, in the range A to R     |
| `[ABC]`  | A single character, not A, B or C           |
| `[^A-R]` | A single character, not in the range A to R |

Get `TOP` elements:

```sql
SELECT TOP (100) *
FROM customers
ORDER BY customerId
```

or skip the parentheses (correct is with):

```sql
SELECT TOP 100 *
FROM customers
ORDER BY customerId
```

Get `TOP` percent elements:

```sql
SELECT TOP (10) PERCENT *
FROM customers
ORDER BY customerId
```

Amount of rows returned with `PERCENT` is rounded up.

`ORDER BY` should be used with `TOP`, otherwise the order is non-deterministic and pretty much like
the data is stored on disk.

`OFFSET` and `FETCH`:

```sql
SELECT *
FROM customers
ORDER BY customerId
OFFSET 50 ROWS FETCH NEXT 10 ROWS ONLY
```

`ORDER BY` is mandatory with `OFFSET` and `FETCH`. `OFFSET` is mandatory with `FETCH`.

`OFFSET` and `FETCH` are part of the SQL standard. `TOP` is not.

#### UNION and UNION ALL

`UNION` is all rows in A and all rows in B. Distinct rows only.

```sql
SELECT firstName, lastName FROM peopleA
UNION ALL
SELECT firstName, lastName FROM peopleB
```

![Example of INTERSECT]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/union.png" | absolute_url }})

`UNION ALL` is all rows in A and all rows in B. Non-distinct rows are also returned.

```sql
SELECT firstName, lastName FROM peopleA
UNION ALL
SELECT firstName, lastName FROM peopleB
```

![Example of INTERSECT]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/union-all.png" | absolute_url }})

- Number of columns must be the same in the two sets.
- Column data type must be the same or compatible (implicitly covertable).

#### INTERSECT

Finds rows that are common for both table A and B.

```sql
SELECT firstName, lastName FROM peopleA
INTERSECT
SELECT firstName, lastName FROM peopleB
```

![Example of INTERSECT]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/intersect.png" | absolute_url }})

- Number of columns must be the same in the two sets.
- Column data type must be the same or compatible (implicitly covertable).

#### EXCEPT

Finds rows that are in A, but not in B.

```sql
SELECT firstName, lastName FROM peopleA
EXCEPT
SELECT firstName, lastName FROM peopleB
```

![Example of EXCEPT 1]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/except-1.png" | absolute_url }})

```sql
SELECT firstName, lastName FROM peopleB
EXCEPT
SELECT firstName, lastName FROM peopleA
```

![Example of EXCEPT 2]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/except-2.png" | absolute_url }})

- Number of columns must be the same in the two sets.
- Column data type must be the same or compatible (implicitly covertable).

#### Special rules

- Presedence order: parantheses, `NOT`, `AND` and then `OR`.
- SQL Server doesn't necessarily go left-to-right in `WHERE` clause predicates.
- Thus no short-circuiting in `WHERE` clause predicates.
- Keyed-in order:
  * SELECT
  * FROM
  * WHERE
  * GROUP BY
  * HAVING
  * ORDER BY
- Phases of logic querying processing:
  * FROM
  * WHERE
  * GROUP BY
  * HAVING
  * SELECT
  * ORDER BY

	Because `SELECT` is processed after `FROM`, `WHERE`, etc. you can't use column
  aliases made in `SELECT` in `FROM`, `WHERE`, etc.
- When `ORDER BY` is used the result is no longer relational.


#### Difference between UNION and UNION ALL

Stack Overflow: [What is the difference between UNION and UNION ALL?][stackoverflow-union-and-union-all]

Union is the union of two sets, e.g. two tables merged together.
`UNION` will remove duplicates, while `UNION ALL` will not.

`UNION ALL` is faster as it doesn't have to scan for duplicates.

## Query multiple tables by using joins

### Syllabus

*Write queries with join statements based on provided tables, data, and requirements;
determine proper usage of INNER JOIN, LEFT/RIGHT/FULL OUTER JOIN, and CROSS JOIN; construct
multiple JOIN operators using AND and OR; determine the correct results when presented with
multi-table SELECT statements and source data; write queries with NULLs on joins*

#### INNER JOIN

#### LEFT JOIN

#### RIGHT JOIN

#### FULL OUTER JOIN

#### CROSS JOIN

## Implement functions and aggregate data

### Syllabus

*Construct queries using scalar-valued and table-valued functions; identify the impact of
function usage to query performance and WHERE clause sargability; identify the differences
between deterministic and non-deterministic functions; use built-in aggregate functions;
use arithmetic functions, date-related functions, and system functions*

#### Scalar-valued functions

See section: *Create database programmability objects by using Transact-SQL*.

#### Table-valued functions

See section: *Create database programmability objects by using Transact-SQL*.

#### WHERE clause sargability

Stack Overflow: [What makes a SQL statement sargable?][stackoverflow-where-clause-sargability]

Blog: [SARGable functions in SQL Server][lobsterpot-sargable-functions]

**Search Argument Able**

A `WHERE` clause is sargable when the query engine can use index seek rather than scan. That means
a query that is made in such a way that it uses a created index. This makes the query much faster
than a query that doesn't use a created index, because these queries have to go through the entire
table to find matches. We should therefore strive to make queries sargable.

The following can make queries non-sargable:

- Manipulation of filtered columns in most cases.
- Functions that have a column as argument, except in certain circumstances.
- `LIKE` clauses like this: `'%test%'`. `'test%'` would be ok.
- Using `ISNULL()` in the `WHERE` clause.
- Using arithemtic on the filtered column.

Exceptions:

- `CAST(datetime AS DATE) = '20190505'`, when datetime is indexed and of datetime type. SQL Server
  can convert this to an interval.

#### Differences between deterministic and non-deterministic functions

[Deterministic and non-deterministic functions on MSDN][microsoft-deterministic-and-non-deterministic-functions]

* Deterministic functions always return the same given a specific input and state of database.
  E.g. `AVG()`.
* Non-deterministic functions can return different values each time they are called, even
  though the input and state of database is the same. E.g. `GETDATE()`.
* Determinism of a function determine the ability of SQL Server to index the result of a
  function.
* A clustered index cannot be created on a view that uses a non-deterministic function.
* Certain non-determinstic functions can be used in indexed views if they are used in a
  deterministic matter. E.g. `RAND` when a seed is specified.

#### Type conversion functions

[Documentation on MSDN][microsoft-conversion-functions]

T-SQL has two main functions for conversion purposes: `CAST()` and `CONVERT()`. `CONVERT()` is T-SQL
only, while `CAST()` is a part of the SQL standard.

Example:

`CAST` syntax:

```sql
SELECT CAST('123' AS INT)   -- outputs 123
```

`CONVERT` syntax without style:

```sql
SELECT CONVERT(INT, '123')   -- outputs 123
```

`CONVERT` syntax with style:

```sql
SELECT CONVERT(VARCHAR, GETDATE(), 103)   -- outputs '05/05/2019'
```

There are also a couple of other type conversion functions that can be used:

`PARSE` (alternative to `CAST`):

```sql
SELECT PARSE('01/05/2019' AS DATE USING 'en-US')  -- outputs 2019-01-05
SELECT PARSE('01/05/2019' AS DATE USING 'no-NO')  -- outputs 2019-05-01
```

`FORMAT` (alternative to `CONVERT`):

```sql
SELECT FORMAT(GETDATE(), 'yyyy-MM-dd')  -- outputs 2019-05-05
```

`PARSE` and `FORMAT` are slow.

`TRY_CAST`, `TRY_CONVERT` and `TRY_PARSE` will return `NULL` if they fail to convert:

```sql
SELECT PARSE('40/05/2019' AS DATE USING 'en-US')
-- exception: Error converting string value '40/05/2019' into data type date using culture 'en-US'.
```

```sql
SELECT TRY_PARSE('40/05/2019' AS DATE USING 'en-US')  -- outputs NULL
```

#### Built-in aggregate functions

[Documentation on MSDN][microsoft-aggregate-functions]

*"An aggregate function performs a calculation on a set of values, and returns a single value."*

```sql
CREATE TABLE people (
    Id    INT            IDENTITY(1,1)    NOT NULL
  , name  VARCHAR(100)
  , age   INT
)

INSERT INTO people (name, age) VALUES
    ('John Smith',      27)
  , ('Kaylee Smith',    26)
  , ('Peter Hernandez', 52)
  , ('George Lopez',    77)
```

Not needing `GROUP BY`:

```sql
SELECT COUNT(*)    FROM people -- outputs 4
SELECT AVG(age)    FROM people -- outputs 45
SELECT MIN(age)    FROM people -- outputs 26
SELECT MAX(age)    FROM people -- outputs 77
SELECT SUM(age)    FROM people -- outputs 182
SELECT VAR(age)    FROM people -- outputs 585.666666666667 - variance for subset
SELECT VARP(age)   FROM people -- outputs 439.25           - variance for population
SELECT STDEV(age)  FROM people -- outputs 24.2005509579155 - std dev for subset
SELECT STDEVP(age) FROM people -- outputs 20.9582919151347 - std dev for population
```

- All functions ignore `NULL`, except `COUNT`.

#### Arithmetic functions

Operators:

- `+`: addition
- `-`: subtraction
- `*`: multiplication
- `/`: division
- `%`: modulo

Precedence is like in ordinary mathematics.

Integer division gives an integer as result:

```sql
SELECT 25 / 2		-- outputs 12
```

It rounds down.

#### Date-related functions

#### System functions

[Documentation on MSDN][microsoft-system-functions]

- `@@ROWCOUNT`: returns number of rows affected by last statement as `INT`.
- `@@ROWCOUNT_BIG`: returns number of rows affected by last statement as `BIGINT`.


`COMPRESS()` compresses string with gzip:

```sql
INSERT INTO customers (name, customer_data)
  VALUES('John Smith', COMPRESS(@data))
```

`DECOMPRESS()` decompresses data that was compressed with `COMPRESS()`:

```sql
SELECT
  name,
  CAST(DECOMPRESS(customer_data) AS NVARCHAR(MAX)) AS customer_data
FROM customers
```

- `COMPRESS()` and `DECOMPRESS()` requires SQL Server 2016.

`CONTEXT_INFO` can be used to pass parameters to modules that don't support parameters, such as
triggers.

`CONTEXT_INFO`: `VARBINARY(128)`

Storing in `CONTEXT_INFO`:

```sql
DECLARE @context_info VARBINARY(128) = CAST('test' AS VARBINARY(128))
SET CONTEXT_INFO @context_info
```

Reading from `CONTEXT_INFO`:

```sql
SELECT CAST(CONTEXT_INFO() AS VARCHAR(128))
```

- There is only one context info per session.

`SESSION_CONTEXT` can also be used to pass parameters to modules that don't support parameters.
`SESSION_CONTEXT` acts as a key-value store rather than a single binary string.

Storing in `SESSION_CONTEXT`:

```sql
EXEC sys.sp_set_session_context
    @key   = N'environment'
  , @value = N'test'
```

Reading from `SESSION_CONTEXT`:

```sql
SELECT SESSION_CONTEXT(N'environment') AS environment
```

- `SESSION_CONTEXT` is available from SQL Server 2016.


`NEWID()` can be used to generate GUIDs.

Example:

```sql
SELECT NEWID()  -- outputs A182DF6A-80AD-4F23-870F-B0BC6973D1C2
```

`NEWSEQUENTIALID()` can be used to generate always-increasing GUIDs. Can only be used in default
constraints.

## Modify data

### Syllabus

*Write INSERT, UPDATE, and DELETE statements; determine which statements can be used to
load data to a table based on its structure and constraints; construct Data Manipulation
Language (DML) statements using the OUTPUT statement; determine the results of Data
Definition Language (DDL) statements on supplied tables and data*

#### INSERT

There are four different ways to insert rows in tables:

- `INSERT VALUES`
- `INSERT SELECT`
- `INSERT EXEC`
- `SELECT INTO`

Example with `INSERT VALUES`:

```sql
INSERT INTO customers (firstName, lastName) VALUES
	('John', 'Smith'),
	('Mary', 'Lietchstad')
```

- If a column does not get a value set, it has to have a `DEFAULT` constraint, have an `IDENTITY`
  property or be able to store `NULL`.
- Use `SET IDENTITY_INSERT dbo.customers ON` to manually specify values for columns with the
  `IDENTITY` property. Use `SET IDENTITY_INSERT dbo.customers OFF` afterwards.

Example with `INSERT SELECT`:

```sql
INSERT INTO customers (firstName, lastName)
  SELECT firstName, lastName FROM newCustomers
```

Example with `INSERT EXEC`:

```sql
INSERT INTO customers (firstName, lastName)
  EXEC CreateNewCustomer @firstName = 'Peter', @lastName = 'Anderson'
```

Example with `SELECT INTO`:

```sql
SELECT firstName, lastName
INTO export_to_DWH
FROM customers c
  INNER JOIN accounts c.account_id = a.id
```

- Definition is taken from the result of the query.
- Indexes, constraints, triggers and permissions are not copied to the new table.

#### UPDATE

Examples:

Ordinary:

```sql
UPDATE customers
SET lastName = 'Whitaker'
WHERE id = 3
```

Compound assignment:

```sql
UPDATE customers
SET age += 1
WHERE id = 1
```

With join:

```sql
UPDATE c
SET c.status = 'inactive'
FROM customers c
  INNER JOIN accounts a ON c.id = a.customer_id
WHERE a.status = 'inactive'
```

- Using joins in `UPDATE` is T-SQL.

With variable:

```sql
DECLARE @age INT

UPDATE customers
SET @age = age += 1
WHERE id = 1
```

#### DELETE

Example:

```sql
DELETE FROM customers
WHERE lastName = 'Smithers'
```

Or everything in the customers table:

```sql
DELETE FROM customers
```

With join:

```sql
DELETE FROM c
  FROM customers c
  INNER JOIN accounts a ON c.id = a.customer_id
WHERE a.status = 'inactive'
```

- Ids are not reused after a row is deleted with `DELETE`.
- `DELETE` is logged.

Truncating a table:

```sql
TRUNCATE TABLE customers
```

- The identity columns will be reset, e.g. `id` will start at 1 again.
- Truncating uses optimized logging and therefore faster than deleting.

#### MERGE

#### OUTPUT

## Query data with advanced Transact-SQL components (30–35%)

# Query data by using subqueries and APPLY

### Syllabus

*Determine the results of queries using subqueries and table joins, evaluate performance
differences between table joins and correlated subqueries based on provided data and query
plans, distinguish between the use of CROSS APPLY and OUTER APPLY, write APPLY statements
that return a given data set based on supplied data*

#### CROSS APPLY

Apply a function to every row.

#### OUTER APPLY

# Query data by using table expressions

### Syllabus

*Identify basic components of table expressions, define usage differences between table
expressions and temporary tables, construct recursive table expressions to meet business
requirements*

#### Table expressions

#### Table expressions vs. temporary tables

#### Recursive CTEs

# Group and pivot data by using queries

### Syllabus

*Use windowing functions to group and rank the results of a query; distinguish between using
windowing functions and GROUP BY; construct complex GROUP BY clauses using GROUPING SETS,
and CUBE; construct PIVOT and UNPIVOT statements to return desired results based on supplied
data; determine the impact of NULL values in PIVOT and UNPIVOT queries*

#### GROUPING SETS

#### CUBE

#### PIVOT and UNPIVOT statements

# Query temporal data and non-relational data

### Syllabus

*Query historic data by using temporal tables, query and output JSON data, query and output
XML data*

#### XML output

[Official documentation][microsoft-for-xml]

The `FOR XML` clause is used to output XML. It has four modes:

- `RAW`: Generates a single `<row>` element per row in the rowset returned by `SELECT`.
- `AUTO`: Generates nesting in the resulting XML based on how the `SELECT` is formed.
- `EXPLICIT`: Can be used to generate XML with more control than `RAW` and `AUTO`. Can specify
  whether selected column should be element or attribute. Element and attributes can be mixed.
- `PATH`: Has the flexibility of `EXPLICIT`, but is easier to use.

#### XML parsing

[Official documentation][microsoft-openxml]

`OPENXML`

#### XML querying

#### JSON output

#### JSON parsing

#### JSON querying

## Program databases by using Transact-SQL (25–30%)

# Create database programmability objects by using Transact-SQL

### Syllabus

*Create stored procedures, table-valued and scalar-valued user-defined functions, triggers,
and views; implement input and output parameters in stored procedures; identify whether to use
scalar-valued or table-valued functions; distinguish between deterministic and non-deterministic
functions; create indexed views*

#### Stored procedures

Stored procedures cannot be used in queries.


#### Table-valued user-defined function

Table-valued user-defined functions return a table.

Example:

```sql
CREATE FUNCTION GetCustomersWithLastName
(
    @lastName VARCHAR(100)
)
RETURNS TABLE
AS
    RETURN
        SELECT *
        FROM customers
        WHERE lastName = @lastName
```

Usage:

```sql
SELECT *
FROM GetCustomersWithLastName('Smith')
```

#### Scalar-valued user-defined function

Scalar-valued user-defined functions return one value.

Example:

```sql
CREATE FUNCTION GetBirthMonthFromSSN
(
    @SSN VARCHAR(11)
)
RETURNS int
AS
BEGIN
    DECLARE @BirthMonth INT
    SET @BirthMonth = CAST(SUBSTRING(@SSN, 3, 2) AS INT)

    RETURN @BirthMonth
END
```

Usage:

```sql
DECLARE @BirthMonth INT

EXEC @BirthMonth = dbo.GetBirthMonthFromSSN '24119812345'

PRINT @BirthMonth   -- prints 11
```

#### Functions in general

- User-defined functions can be used in queries.
- Have to return a value.
- Cannot use `PRINT` or `SELECT` inside them.
- Can have schema bindings.

#### Triggers

Triggers are special stored procedures that are connected to tables. Triggers can be set to fire
when INSERT, UPDATE, DELETE and similar statements are used on a table. Triggers are often used to
maintain the integrity of the table.

Triggers use virtual tables that are called *inserted* and *deleted*. The rows that are supposed to
be deleted or inserted are put in these tables first. The trigger will then act on these tables to
check whether the rows should be inserted/deleted or not.

Triggers should not be used for ordinary integrity checks. Native constraints (check contraints,
uniqueness, etc.) should be used instead. This is because triggers have a performance overhead.

```sql
CREATE TRIGGER dbo.accounts_trgi ON dbo.accounts AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  IF EXISTS(SELECT 1 FROM inserted WHERE firstName = '' OR lastName = '')
      BEGIN
        RAISERROR('accounts_trgi: The first name or last name cannot be blank.', 16, 1)
        ROLLBACK TRAN
        RETURN
      END

  IF EXISTS(SELECT 1 FROM inserted i INNER JOIN accounts a ON a.SSN = i.SSN)
      BEGIN
        RAISERROR('accounts_trgi: Person already exists with that SSN.', 16, 1)
        ROLLBACK TRAN
        RETURN
      END
END

GO

ALTER TABLE dbo.accounts ENABLE TRIGGER accounts_trgi
```

#### Views

Restrictions:

* 1024 columns
* Single query
* Single table when using `INSERT`
* Restricted data modifications
* No `TOP` without `ORDER BY`
* No `ORDER BY` without `TOP`, `OFFSET` or `FOR XML`.

- `WITH SCHEMABINDING`: No changes to underlying table.
- `WITH ENCRYPTION`: Encrypts the view.
- `WITH CHECK`: Cannot do updates that removes the updated rows from the view.

#### Indexed views

- Needs `WITH SCHEMABINDING`.
- Cannot use non-deterministic functions in the view.
- Cannot use functions that returns values with `FLOAT` type.

- When the view is schema bound you cannot use `SELECT *`.

# Implement error handling and transactions

### Syllabus

*Determine results of Data Definition Language (DDL) statements based on transaction control
statements, implement TRY…CATCH error handling with Transact-SQL, generate error messages with
THROW and RAISERROR, implement transaction control in conjunction with error handling in stored
procedures*

#### Transaction control

#### TRY-CATCH

#### THROW

`THROW` raises an error.

Example:

```sql
THROW 50000, 'Error message', 1;
```

The first parameter is the error number, the second is the error message and the third is a state
variable. The error number must be 50000 or larger. State are between 1 and 255 and are used for
informational purposes.

Or without parameters:

```sql
THROW;
```

This rethrows the original error.

If the throw happens outside a `TRY` block it will abort the batch. If it's inside it will activate
the `CATCH` block.

#### RAISERROR

`RAISERROR()` is older, but has more options, than `THROW`.

Example:

```sql
RAISERROR('Error message', 16, 1)
```

The first parameter is the error message, the second is the severity and the third is a state
variable. Severity determines how the system should behave towards the error:

- 0 to 10 are informational and are only printed.
- 11 to 19 are errors that can be cought.
- 20 to 25 terminates the connection.

State are between 1 and 255 and are used for informational purposes.

There is also a variant with printf-style syntax:

```sql
RAISERROR('Error message: %s, %s', 16, 1, 'test1', 'test2')
```

There two extra options that can be added to `RAISERROR()`:

- `WITH NOWAIT`: used to raise the error immidiatly, rather than wait until the buffer is full.
- `WITH LOG`: have to be used for severity 19 and up.

Example:

```sql
RAISERROR('Error message', 16, 1) WITH NOWAIT
RAISERROR('Error message', 22, 1) WITH LOG
```

#### THROW vs RAISERROR

# Implement data types and NULLs

### Syllabus

*Evaluate results of data type conversions, determine proper data types for given data elements
or table columns, identify locations of implicit data type conversions in queries, determine
the correct results of joins and functions in the presence of NULL values, identify proper
usage of ISNULL and COALESCE functions*

#### Data type conversions

#### Proper data types

#### Locations of implicit data type conversions in queries

#### Correct results when joins and NULL values

#### ISNULL()

#### COALESCE()

#### ISNULL() vs. COALESCE()

[microsoft-mcsa-sql-2016-database-development]: https://www.microsoft.com/en-us/learning/mcsa-sql2016-database-development-certification.aspx
[microsoft-70-761-curriculum]: https://www.microsoft.com/en-us/learning/exam-70-761.aspx
[microsoft-deterministic-and-non-deterministic-functions]: https://docs.microsoft.com/en-us/sql/relational-databases/user-defined-functions/deterministic-and-nondeterministic-functions
[microsoft-conversion-functions]: https://docs.microsoft.com/en-us/sql/t-sql/functions/conversion-functions-transact-sql
[microsoft-aggregate-functions]: https://docs.microsoft.com/en-us/sql/t-sql/functions/aggregate-functions-transact-sql
[microsoft-system-functions]: https://docs.microsoft.com/en-us/sql/t-sql/functions/system-functions-transact-sql
[microsoft-for-xml]: https://docs.microsoft.com/en-us/sql/relational-databases/xml/for-xml-sql-server
[microsoft-openxml]: https://docs.microsoft.com/en-us/sql/relational-databases/xml/openxml-sql-server
[stackoverflow-union-and-union-all]: https://stackoverflow.com/questions/49925/what-is-the-difference-between-union-and-union-all
[stackoverflow-where-clause-sargability]: https://stackoverflow.com/questions/799584/what-makes-a-sql-statement-sargable
[lobsterpot-sargable-functions]: http://blogs.lobsterpot.com.au/2010/01/22/sargable-functions-in-sql-server/
