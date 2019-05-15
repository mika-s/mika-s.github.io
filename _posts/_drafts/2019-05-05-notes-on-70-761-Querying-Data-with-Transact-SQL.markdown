---
layout: post
title:  "Notes on 70-761: Querying Data with Transact-SQL"
date:   2019-05-05 15:00:00 +0100
categories: sql certification 70-761
---

These are some notes I took for the Microsoft exam 70-761: Querying Data with Transact-SQL,
which is a part of [MCSA: SQL 2016 Database Development][microsoft-mcsa-sql-2016-database-development].

This is for the syllabus as it was in May 2019. The syllabus might change in the future.

---

## Table of Contents

- [Manage data with Transact-SQL](#manage_data_with_tsql)
  - [Create Transact-SQL SELECT queries](#create_tsql_select_queries)
    - [SELECT in general](#select_in_general)
    - [Search with LIKE](#select_with_like)
    - [SELECT with TOP](#select_with_top)
    - [SELECT with OFFSET AND FETCH](#select_with_offset_and_fetch)
    - [UNION and UNION ALL](#union_and_union_all)
    - [Difference between UNION and UNION ALL](#difference_between_union_and_union_all)
    - [INTERCEPT](#intersect)
    - [EXCEPT](#except)
    - [Special rules](#ch1_special_rules)
  - [Query multiple tables by using joins](#query_with_joins)
    - [INNER JOIN](#inner_join)
    - [LEFT JOIN](#left_join)
    - [RIGHT JOIN](#right_join)
    - [FULL OUTER JOIN](#full_outer_join)
    - [CROSS JOIN](#cross_join)
    - [Query with NULL on joins](#query_with_null_on_joins)
  - [Implement functions and aggregate data](#implement_functions_and_aggregate_data)
    - [Scalar-valued functions](#scalar_valued_functions)
    - [Table-valued functions](#table_valued_functions)
    - [WHERE clause sargability](#where_clause_sargability)
    - [Differences between deterministic and non-deterministic functions](#differences_deterministic_nondeterministic)
    - [Type conversion functions](#type_conversion_functions)
    - [Built-in aggregate functions](#builtin_aggregate_functions)
    - [Arithmetic functions](#arithmetic_functions)
    - [Date-related functions](#date_related_functions)
    - [System functions](#system_functions)

---

<br/><br/><br/>

<a name="manage_data_with_tsql"></a>

## Manage data with Transact-SQL (40–45%)

<a name="create_tsql_select_queries"></a>

# Create Transact-SQL SELECT queries

### Syllabus

*Identify proper SELECT query structure, write specific queries to satisfy
business requirements, construct results from multiple queries using set operators,
distinguish between UNION and UNION ALL behaviour, identify the query that would return
expected results based on provided table structure and/or data*

<a name="select_in_general"></a>

#### SELECT in general

Basic examples:

```sql
-- Generic SELECT
SELECT * FROM accounts

-- SELECT with WHERE clause
SELECT * FROM accounts WHERE accountId = 12

-- SELECT with WHERE clause containing AND:
SELECT * FROM customers WHERE city = 'New York City' AND gender = 'Male'

-- SELECT that only gets certain columns
SELECT firstName, lastName FROM customers

-- SELECT with alias for columns
SELECT firstName AS [First name], lastName AS [Last name] FROM customers

-- or
SELECT firstName AS 'First name', lastName AS 'Last name' FROM customers

-- Get only distinct elements
SELECT DISTINCT lastName FROM customers
```

<a name="select_with_like"></a>

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

<a name="select_with_top"></a>

Get `TOP` elements:

```sql
SELECT TOP (100) *
FROM customers
ORDER BY customerId

-- Or skip the parentheses (correct is with):
SELECT TOP 100 *
FROM customers
ORDER BY customerId

-- Get TOP percent elements:
SELECT TOP (10) PERCENT *
FROM customers
ORDER BY customerId
```

Amount of rows returned with `PERCENT` is rounded up.

`ORDER BY` should be used with `TOP`, otherwise the order is non-deterministic and pretty much like
the data is stored on disk.

<a name="select_with_offset_and_fetch"></a>

`OFFSET` and `FETCH`:

```sql
SELECT *
FROM customers
ORDER BY customerId
OFFSET 50 ROWS FETCH NEXT 10 ROWS ONLY
```

`ORDER BY` is mandatory with `OFFSET` and `FETCH`. `OFFSET` is mandatory with `FETCH`.

`OFFSET` and `FETCH` are part of the SQL standard. `TOP` is not.

<a name="union_and_union_all"></a>

#### UNION and UNION ALL

`UNION` is all rows in A and all rows in B. Distinct rows only.

```sql
SELECT firstName, lastName FROM peopleA
UNION
SELECT firstName, lastName FROM peopleB
```

![Example of UNION]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/union.png" | absolute_url }})

`UNION ALL` is all rows in A and all rows in B. Non-distinct rows are also returned.

```sql
SELECT firstName, lastName FROM peopleA
UNION ALL
SELECT firstName, lastName FROM peopleB
```

![Example of UNION ALL]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/union-all.png" | absolute_url }})

- Number of columns must be the same in the two sets.
- Column data type must be the same or compatible (implicitly convertable).

<a name="difference_between_union_and_union_all"></a>

#### Difference between UNION and UNION ALL

Stack Overflow: [What is the difference between UNION and UNION ALL?][stackoverflow-union-and-union-all]

Union is the union of two sets, e.g. two tables merged together.
`UNION` will remove duplicates, while `UNION ALL` will not.

`UNION ALL` is faster as it doesn't have to scan for duplicates.

<a name="intersect"></a>

#### INTERSECT

Finds rows that are common for both table A and B.

```sql
SELECT firstName, lastName FROM peopleA
INTERSECT
SELECT firstName, lastName FROM peopleB
```

![Example of INTERSECT]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/intersect.png" | absolute_url }})

- Number of columns must be the same in the two sets.
- Column data type must be the same or compatible (implicitly convertable).

<a name="except"></a>

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
- Column data type must be the same or compatible (implicitly convertable).

<a name="ch1_special_rules"></a>

#### Special rules

- Precedence order: parentheses, `NOT`, `AND` and then `OR`.
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

---

<br/><br/><br/>

<a name="query_with_joins"></a>

## Query multiple tables by using joins

### Syllabus

*Write queries with join statements based on provided tables, data, and requirements;
determine proper usage of INNER JOIN, LEFT/RIGHT/FULL OUTER JOIN, and CROSS JOIN; construct
multiple JOIN operators using AND and OR; determine the correct results when presented with
multi-table SELECT statements and source data; write queries with NULLs on joins*

### Joins

This table structure is used in this chapter:

```sql
CREATE TABLE men (
    Id           INT           IDENTITY(1,1)  NOT NULL
  , firstName    VARCHAR(200)
  , lastName     VARCHAR(200)
  , marriedToId  INT
)

CREATE TABLE women (
    Id           INT           IDENTITY(1,1)  NOT NULL
  , firstName    VARCHAR(200)
  , lastName     VARCHAR(200)
  , marriedToId  INT
)

INSERT INTO men (firstName, lastName, marriedToId) VALUES
    ('Samuel', 'McDonald' , 2   )
  , ('Jack'  , 'Lipinski' , 1   )
  , ('Roger' , 'Pierce'   , NULL)
  , ('Travis', 'Danielson', NULL)

INSERT INTO women (firstName, lastName, marriedToId) VALUES
    ('Lisa'   , 'Samson'  , 2   )
  , ('Linda'  , 'Windsor' , 1   )
  , ('Beyonce', 'Corleone', NULL)
```

<a name="inner_join"></a>

#### INNER JOIN

Inner joins will only match if there are values in both left and right tables.

Example:

```sql
SELECT
    m.firstName + ' ' + m.lastName AS Name
  , m.marriedToId
  , w.firstName + ' ' + w.lastName AS Name
  , w.marriedToId
FROM men m
  INNER JOIN women w ON m.Id = w.marriedToId
```

![INNER JOIN query output]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/inner-join.png" | absolute_url }})

<a name="left_join"></a>

#### LEFT JOIN

```sql
SELECT
    m.firstName + ' ' + m.lastName AS Name
  , m.marriedToId
  , w.firstName + ' ' + w.lastName AS Name
  , w.marriedToId
FROM men m
  LEFT JOIN women w ON m.Id = w.marriedToId
```

![LEFT JOIN query output]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/left-join.png" | absolute_url }})

<a name="right_join"></a>

#### RIGHT JOIN

A right join is like a left join, but with left and right tables switched.

```sql
SELECT
    m.firstName + ' ' + m.lastName AS Name
  , m.marriedToId
  , w.firstName + ' ' + w.lastName AS Name
  , w.marriedToId
FROM men m
  RIGHT JOIN women w ON m.Id = w.marriedToId
```

![RIGHT JOIN query output]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/right-join.png" | absolute_url }})

<a name="full_outer_join"></a>

#### FULL OUTER JOIN

```sql
SELECT
    m.firstName + ' ' + m.lastName AS Name
  , m.marriedToId
  , w.firstName + ' ' + w.lastName AS Name
  , w.marriedToId
FROM men m
  FULL JOIN women w ON m.Id = w.marriedToId
```

![FULL OUTER JOIN query output]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/full-join.png" | absolute_url }})

<a name="cross_join"></a>

#### CROSS JOIN

Cross join returns the Cartesian product of left and right table. That is all the possible
combinations of selected rows in left and right.

Example:

```sql
SELECT
    m.firstName + ' ' + m.lastName AS Name
  , w.firstName + ' ' + w.lastName AS Name
FROM men m
  CROSS JOIN women w
```

![CROSS JOIN query output]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/cross-join.png" | absolute_url }})

<a name="query_with_null_on_joins"></a>

#### Query with NULL on joins

---

<br/><br/><br/>

<a name="implement_functions_and_aggregate_data"></a>

## Implement functions and aggregate data

### Syllabus

*Construct queries using scalar-valued and table-valued functions; identify the impact of
function usage to query performance and WHERE clause sargability; identify the differences
between deterministic and non-deterministic functions; use built-in aggregate functions;
use arithmetic functions, date-related functions, and system functions*

<a name="scalar_valued_functions"></a>

#### Scalar-valued functions

See section: *Create database programmability objects by using Transact-SQL*.

<a name="table_valued_functions"></a>

#### Table-valued functions

See section: *Create database programmability objects by using Transact-SQL*.

<a name="where_clause_sargability"></a>

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
- `LIKE` clauses like this: `'%test%'`. `'test%'` would be OK.
- Using `ISNULL()` in the `WHERE` clause.
- Using arithmetic on the filtered column.

Exceptions:

- `CAST(datetime AS DATE) = '20190505'`, when datetime is indexed and of datetime type. SQL Server
  can convert this to an interval.

<a name="differences_deterministic_nondeterministic"></a>

#### Differences between deterministic and non-deterministic functions

[Deterministic and non-deterministic functions on MSDN][microsoft-deterministic-and-non-deterministic-functions]

* Deterministic functions always return the same given a specific input and state of database.
  E.g. `AVG()`.
* Non-deterministic functions can return different values each time they are called, even
  though the input and state of database is the same. E.g. `GETDATE()`.
* Determinism of a function determine the ability of SQL Server to index the result of a
  function.
* A clustered index cannot be created on a view that uses a non-deterministic function.
* Certain non-deterministic functions can be used in indexed views if they are used in a
  deterministic matter. E.g. `RAND` when a seed is specified.

<a name="type_conversion_functions"></a>

#### Type conversion functions

[Official documentation][microsoft-conversion-functions]

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

<a name="builtin_aggregate_functions"></a>

#### Built-in aggregate functions

[Official documentation][microsoft-aggregate-functions]

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

<a name="arithmetic_functions"></a>

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

<a name="date_related_functions"></a>

#### Date-related functions

<a name="system_functions"></a>

#### System functions

[Official documentation][microsoft-system-functions]

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

---

<br/><br/><br/>

<a name="modify_data"></a>

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

[Official documentation][microsoft-merge]

`MERGE` can be used to merge one table into another.

Example:

```sql
CREATE TABLE customers
(
    Id           INT            IDENTITY(1,1)    NOT NULL
  , firstName    VARCHAR(100)
  , lastName     VARCHAR(100)
  , age          INT
)

CREATE TABLE newCustomers
(
    Id           INT            IDENTITY(1,1)    NOT NULL
  , firstName    VARCHAR(100)
  , lastName     VARCHAR(100)
  , age          INT
)

INSERT INTO customers    (firstName, lastName, age) VALUES
    ('John', 'Smith',  45)
  , ('Joe',  'Schmoe', 11)
  , ('Mary', 'Christ', 73)

INSERT INTO newCustomers (firstName, lastName, age) VALUES
    ('John',  'Smith',    46)
  , ('Alan',  'Goldberg', 23)
  , ('Sue',   'Hotz',     66)
  , ('Karen', 'Deville',  32)

SELECT * FROM customers

MERGE INTO customers AS trg
USING newCustomers   AS src
ON trg.firstName = src.firstName AND trg.lastName = src.lastName
WHEN MATCHED THEN
  UPDATE SET
      firstName = src.firstName
    , lastName  = src.lastName
    , age       = src.age
WHEN NOT MATCHED THEN
  INSERT (firstName, lastName, age)
  VALUES (src.firstName, src.lastName, src.age);

SELECT * FROM customers
```

![Example of MERGE]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/merge-1.png" | absolute_url }})

The `OUTPUT` clause is often used with `MERGE`:

```sql
MERGE INTO customers AS trg
USING newCustomers   AS src
ON trg.firstName = src.firstName AND trg.lastName = src.lastName
WHEN MATCHED THEN
  UPDATE SET
      firstName = src.firstName
    , lastName  = src.lastName
    , age       = src.age
WHEN NOT MATCHED THEN
  INSERT (firstName, lastName, age)
  VALUES (src.firstName, src.lastName, src.age)
OUTPUT $action, INSERTED.firstName, INSERTED.lastName, INSERTED.age;
```

![Example of MERGE with OUTPUT]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/merge-2.png" | absolute_url }})

#### OUTPUT

[Official documentation][microsoft-output]

`OUTPUT` is used to output the result of an expression that affects rows. The table `INSERTED` will
contain the new values and `DELETED` will contain the old values.

Example with only updated values:

```sql
UPDATE customers SET age += 1
OUTPUT INSERTED.firstName, INSERTED.lastName, INSERTED.age;
```

![OUTPUT with updated values only]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/output-1.png" | absolute_url }})

Example with old and new values:

```sql
UPDATE customers SET age += 1
OUTPUT DELETED.firstName AS 'Old first name', INSERTED.firstName AS 'New first name',
       DELETED.lastName  AS 'Old last name',  INSERTED.lastName  AS 'New last name',
       DELETED.age       AS 'Old age',        INSERTED.age       AS 'New age';
```

![OUTPUT with both old and new values]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/output-2.png" | absolute_url }})

Example with `*`:

```sql
UPDATE customers SET age += 1
OUTPUT DELETED.*, INSERTED.*
```

![OUTPUT with both old and new values]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/output-3.png" | absolute_url }})

---

<br/><br/><br/>

## Query data with advanced Transact-SQL components (30–35%)

# Query data by using subqueries and APPLY

### Syllabus

*Determine the results of queries using subqueries and table joins, evaluate performance
differences between table joins and correlated subqueries based on provided data and query
plans, distinguish between the use of CROSS APPLY and OUTER APPLY, write APPLY statements
that return a given data set based on supplied data*

#### CROSS APPLY

Apply a function to every row.

CROSS APPLY = lateral join

*"What is the main purpose of using CROSS APPLY?".

The main purpose is to enable table functions with parameters to be executed
once per row and then joined to the results.*


- CROSS APPLY is instead of INNER JOIN when there are complex join conditions.
- For INNER JOIN the left and right tables have to be independent from each other.
  If they are not, we have to use CROSS APPLY.

#### OUTER APPLY

---

<br/><br/><br/>

# Query data by using table expressions

### Syllabus

*Identify basic components of table expressions, define usage differences between table
expressions and temporary tables, construct recursive table expressions to meet business
requirements*

### Table expressions

Table expressions are named queries, according to the [official exam book][amazon-querying-data-with-transact-sql].
It also mentions that there are four types of table expressions:

- Common table expressions (CTEs)
- Views
- Derived tables
- Inline table-valued functions

Views are explained [here](#views). Table-valued functions are explained [here](#table_valued_function).
Derived tables are sub queries.

#### Common table expressions (CTEs)

[Official documentation][microsoft-cte]
[Introduction to CTEs on Essential SQL][essentialsql-intro-to-ctes]

Example of simple CTE:

```sql
WITH customer_order_cte (CustomerId, FirstName, LastName, OrderId, Date) AS
(
SELECT
    c.Id        AS CustomerId
  , c.firstName AS FirstName
  , c.lastName  AS LastName
  , o.Id        AS OrderId
  , o.Date      AS Date
FROM customer c
  INNER JOIN ca_order o ON c.Id = o.CustomerId
)
SELECT *
FROM customer_order_cte
```

Example of chained CTE:

```sql
WITH customer_order_cte (CustomerId, FirstName, LastName, OrderId, Date) AS
(
SELECT
    c.Id        AS CustomerId
  , c.firstName AS FirstName
  , c.lastName  AS LastName
  , o.Id        AS OrderId
  , o.Date      AS Date
FROM customer c
  INNER JOIN ca_order o ON c.Id = o.CustomerId
),
order_order_line_cte (OrderId, Date, OrderLineId, ItemId, Amount) AS
(
SELECT
    o.Id        AS OrderId
  , o.Date      AS Date
  , ol.Id      AS OrderLineId
  , ol.ItemId   AS ItemId
  , ol.Amount   AS Amount
FROM ca_order o
  INNER JOIN ca_order_line ol ON o.Id = ol.OrderId
)
SELECT
    CustomerId
  , FirstName
  , LastName
  , co.OrderId
  , co.Date
  , ItemId
  , Amount
FROM customer_order_cte co
  INNER JOIN order_order_line_cte ool ON co.OrderId = ool.OrderId
```

#### Recursive CTEs

[Recursive CTEs on Essential SQL][essentialsql-recursive-ctes]

Example:

```sql
CREATE TABLE hierarchy (
    Id        INT           IDENTITY(1,1)    NOT NULL
  , Name      VARCHAR(200)
  , ParentId  INT
)

INSERT INTO hierarchy
    (Name          , ParentId) VALUES
    ('Top 1'       , NULL    )
  , ('Middle 1-1'  , 1       )
  , ('Bottom 1-1-1', 2       )
  , ('Bottom 1-1-2', 2       )
  , ('Top 2'       , NULL    )
  , ('Middle 2-1'  , 5       )
  , ('Bottom 2-1-1', 6       )
  , ('Middle 2-2'  , 5       )
  , ('Top 3'       , NULL    )
  , ('Middle 3-1'  , 9       )

----

WITH hierarchy_cte (Id, Name, Level, ParentId, Sort) AS
(
  SELECT
        Id
    , Name
    , 1
    , ParentId
    , CAST (Name AS VARCHAR (200))
  FROM hierarchy
  WHERE ParentId IS NULL

  UNION ALL

  SELECT
      h.Id
    , CAST (REPLICATE('|---', hc.Level) + h.Name AS VARCHAR (200))
    , hc.Level + 1
    , h.ParentId
    , CAST (hc.Sort + '\' + h.Name AS VARCHAR (200))
  FROM hierarchy h
    INNER JOIN hierarchy_cte hc
      ON h.ParentId = hc.Id
)
SELECT
    Name
  , Level
  , ParentId
  , Sort
FROM hierarchy_cte
ORDER BY Sort

```

![Recursive CTE results]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/recursive-cte.png" | absolute_url }})

#### Table expressions vs temporary tables

Temporary tables or table variables should be used when the data is used several times. This is
especially true if the data comes from an expensive query. Storing the data in a temporary table
or table variable means we don't have to perform the expensive query several times. Instead, we can
read the already queried values from the table, which is much cheaper.

Whether to use a temporary table or table variable depends on the size of the table. For small
tables it's better to use table variables, while large tables should be stored in temporary tables.
This is because temporary tables have full statistics, while table variables have very little
statistics on them. Small tables don't need full statistics.

Table expressions are good when the data from the table expression is used only once. Using a table
expression means we don't get the unnecessary overhead that we get when the data is written to the
temporary table.

---

<br/><br/><br/>

# Group and pivot data by using queries

### Syllabus

*Use windowing functions to group and rank the results of a query; distinguish between using
windowing functions and GROUP BY; construct complex GROUP BY clauses using GROUPING SETS,
and CUBE; construct PIVOT and UNPIVOT statements to return desired results based on supplied
data; determine the impact of NULL values in PIVOT and UNPIVOT queries*

#### GROUP BY

```sql
CREATE TABLE people (
    Id          INT           IDENTITY(1,1)    NOT NULL
  , firstName   VARCHAR(200)
  , lastName    VARCHAR(200)
  , age         INT
)

INSERT INTO people (firstName, lastName, age) VALUES
    ('Joe'   , 'Guliani' , 25)
  , ('Aaron' , 'Guliani' , 47)
  , ('Dawn'  , 'Anderson', 55)
  , ('Kilroy', 'Anderson', 52)
  , ('Donald', 'Sanders' , 67)

SELECT
    lastName
  , AVG(age) AS 'Average age'
  , MIN(age) AS 'Min age'
  , MAX(age) AS 'Max age'
FROM people
GROUP BY lastName
```

#### GROUP BY vs windowing functions

#### GROUPING SETS

#### CUBE

#### PIVOT and UNPIVOT statements

#### NULL values in PIVOT and UNPIVOT

---

<br/><br/><br/>

# Query temporal data and non-relational data

### Syllabus

*Query historic data by using temporal tables, query and output JSON data, query and output
XML data*

#### Temporal tables

### XML

#### XML output

[Official documentation][microsoft-for-xml]

The `FOR XML` clause is used to output XML. It has four modes:

- `RAW`: Generates a single `<row>` element per row in the rowset returned by `SELECT`.
- `AUTO`: Generates nesting in the resulting XML based on how the `SELECT` is formed.
- `EXPLICIT`: Can be used to generate XML with more control than `RAW` and `AUTO`. Can specify
  whether selected column should be element or attribute. Element and attributes can be mixed.
- `PATH`: Has the flexibility of `EXPLICIT`, but is easier to use.

**XML RAW:**

```sql
SELECT *
FROM people
FOR XML RAW
```

```xml
<row Id="1" firstName="Joe" lastName="Guliani" age="25" />
<row Id="2" firstName="Aaron" lastName="Guliani" age="17" />
<row Id="3" firstName="Dawn" lastName="Anderson" age="55" />
<row Id="4" firstName="Kilroy" lastName="Anderson" age="5" />
<row Id="5" firstName="Donald" lastName="Sanders" age="18" />
```

**XML AUTO:**

```sql
SELECT *
FROM people
FOR XML AUTO
```

```xml
<people Id="1" firstName="Joe" lastName="Guliani" age="25" />
<people Id="2" firstName="Aaron" lastName="Guliani" age="17" />
<people Id="3" firstName="Dawn" lastName="Anderson" age="55" />
<people Id="4" firstName="Kilroy" lastName="Anderson" age="5" />
<people Id="5" firstName="Donald" lastName="Sanders" age="18" />
```

**XML EXPLICIT:**

```sql
SELECT
    1         AS Tag
  , NULL      AS Parent
  , Id        AS 'Person!1!Id!Element'
  , firstName AS 'Person!1!FirstName'
  , lastName  AS 'Person!1!LastName'
FROM people
FOR XML EXPLICIT
```

```xml
<Person FirstName="Joe" LastName="Guliani">
  <Id>1</Id>
</Person>
<Person FirstName="Aaron" LastName="Guliani">
  <Id>2</Id>
</Person>
<Person FirstName="Dawn" LastName="Anderson">
  <Id>3</Id>
</Person>
<Person FirstName="Kilroy" LastName="Anderson">
  <Id>4</Id>
</Person>
<Person FirstName="Donald" LastName="Sanders">
  <Id>5</Id>
</Person>
```

**XML PATH:**

```sql
SELECT
    Id        AS '@PersonId'
  , firstName AS 'Name/First'
  , lastName  AS 'Name/Last'
  , age       AS 'Age'
FROM people
FOR XML PATH ('Person')
```

```xml
<Person PersonId="1">
  <Name>
    <First>Joe</First>
    <Last>Guliani</Last>
  </Name>
  <Age>25</Age>
</Person>
<Person PersonId="2">
  <Name>
    <First>Aaron</First>
    <Last>Guliani</Last>
  </Name>
  <Age>17</Age>
</Person>
<Person PersonId="3">
  <Name>
    <First>Dawn</First>
    <Last>Anderson</Last>
  </Name>
  <Age>55</Age>
</Person>
<Person PersonId="4">
  <Name>
    <First>Kilroy</First>
    <Last>Anderson</Last>
  </Name>
  <Age>5</Age>
</Person>
<Person PersonId="5">
  <Name>
    <First>Donald</First>
    <Last>Sanders</Last>
  </Name>
  <Age>18</Age>
</Person>
```

#### XML parsing

[Official documentation][microsoft-openxml]

`OPENXML` can be used to parse XML and return the values as rows and columns. `sp_xml_preparedocument`
is used to prepare the XML for parsing.

Example with single element containing sub elements:

```sql
DECLARE @xml VARCHAR(MAX) = 
'<?xml version="1.0" encoding="UTF-8"?>
<Person>
  <FirstName>Monica</FirstName>
  <LastName>Chandloretta</LastName>
  <BirthDate>2001-04-25</BirthDate>
</Person>'

DECLARE @prepped_xml INT

EXEC sp_xml_preparedocument @prepped_xml OUTPUT, @xml; 

SELECT *
FROM OPENXML(@prepped_xml, '/Person', 2)
  WITH (
        FirstName  VARCHAR(200)
      , LastName   VARCHAR(200)
      , BirthDate  DATE
    )
```

![OPENXML results]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/OPENXML-results.png" | absolute_url }})

Example with two elements containing attributes:

```sql
DECLARE @xml VARCHAR(MAX) = 
'<?xml version="1.0" encoding="UTF-8"?>
<People>
  <Person FirstName="Monica"   LastName="Chandloretta" BirthDate="2001-04-25"/>
  <Person FirstName="Chandler" LastName="Moniquer"     BirthDate="1995-08-02"/>
</People>'

DECLARE @prepped_xml INT

EXEC sp_xml_preparedocument @prepped_xml OUTPUT, @xml; 

SELECT *
FROM OPENXML(@prepped_xml, '/People/Person', 1)
  WITH (
        FirstName  VARCHAR(200)
      , LastName   VARCHAR(200)
      , BirthDate  DATE
    )
```

![OPENXML with attributes results]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/OPENXML-attribute-centric-results.png" | absolute_url }})

- The second argument to `OPENXML()` specifies whether the parsing should be element-centric or
  attribute-centric:
    * 1: attribute-centric
    * 2: element-centric

#### XML querying

### JSON

[Official documentation][microsoft-json]

This variable with JSON in it is used in all examples:

```sql
DECLARE @json VARCHAR(MAX) =
'{
  "firstName": "Pete",
  "lastName": "Carpenter",
  "age": 56
}'
```

#### JSON output

Example of `FOR JSON PATH`:

```sql
-- customers table from examples above
SELECT *
FROM customers
FOR JSON PATH
```

Prints:

```json
[
  {
    "Id": 1,
    "firstName": "John",
    "lastName": "Smith",
    "age": 46
  },
  {
    "Id": 2,
    "firstName": "Joe",
    "lastName": "Schmoe",
    "age": 12
  },
  {
    "Id": 3,
    "firstName": "Mary",
    "lastName": "Christ",
    "age": 74
  }
]
```

#### JSON parsing

[Official documentation][microsoft-openjson]

`OPENJSON()` can be used to parse JSON and return the values as rows and columns.

Example:

```sql
SELECT *
FROM OPENJSON(@json)
WITH (
  firstName VARCHAR(50),
  lastName  VARCHAR(100),
  age       INT
)
```

![OPENXML output]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/OPENJSON-output.png" | absolute_url }})

#### JSON querying

To check whether a string is valid JSON, use `ISJSON()`. To read a scalar value, use `JSON_VALUE()`.

```sql
PRINT ISJSON(@json)    -- Outputs 1

PRINT JSON_VALUE(@json, '$.firstName')  -- Outputs 'Pete'
```

To modify the JSON, use `JSON_MODIFY()`:

```sql
SET @json = JSON_MODIFY(@json, '$.firstName', 'Laura')

PRINT @json
```

This would output:

```json
{
  "firstName": "Laura",
  "lastName": "Carpenter",
  "age": 56
}
```

`JSON_QUERY()` is used to get values for objects and arrays. For scalar values, use `JSON_VALUE()`.

Example:

```sql
DECLARE @json VARCHAR(MAX) =
'{
  "name": {
    "firstName": "Pete",
      "lastName": "Carpenter"
  },
  "age": 56
}'

SELECT JSON_QUERY(@json, '$.name')
```

This would output:

```json
{
  "firstName": "Pete",
  "lastName": "Carpenter"
}
```

---

<br/><br/><br/>

## Program databases by using Transact-SQL (25–30%)

# Create database programmability objects by using Transact-SQL

### Syllabus

*Create stored procedures, table-valued and scalar-valued user-defined functions, triggers,
and views; implement input and output parameters in stored procedures; identify whether to use
scalar-valued or table-valued functions; distinguish between deterministic and non-deterministic
functions; create indexed views*

#### Stored procedures

Example:

```sql
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE GetMinAndMaxAgeForLastName
  @lastName VARCHAR(200)
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
      lastName
    , MIN(age) AS 'Min age'
    , MAX(age) AS 'Max age'
  FROM people
  WHERE lastName = @lastName
  GROUP BY lastName
END
GO

EXEC GetMinAndMaxAgeForLastName 'Anderson'
```

![Stored procedure results]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/stored-procedure-results.png" | absolute_url }})

- Stored procedures cannot be used in queries.

<a name="table_valued_function"></a>

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

Triggers should not be used for ordinary integrity checks. Native constraints (check constraint,
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

<a name="views"></a>

#### Views

[Official-documentation][microsoft-create-view]

Views are premade queries.

Example:

```sql
CREATE TABLE people (
    Id           INT            IDENTITY(1,1)    NOT NULL
  , firstName    VARCHAR(200)
  , lastName     VARCHAR(200)
  , age          INT
)

INSERT INTO people (firstName, lastName, age) VALUES
    ('Joe'   , 'Guliani' , 25)
  , ('Aaron' , 'Guliani' , 17)
  , ('Dawn'  , 'Anderson', 55)
  , ('Kilroy', 'Anderson', 5)
  , ('Donald', 'Sanders' , 18)

CREATE VIEW OveragePeople
AS
  SELECT *
  FROM people
  WHERE 18 <= age

SELECT *
FROM OveragePeople
```

![View results]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/view-results.png" | absolute_url }})

Restrictions:

* 1024 columns
* Single query
* Single table when using `INSERT`
* Restricted data modifications
* No `TOP` without `ORDER BY`
* No `ORDER BY` without `TOP`, `OFFSET` or `FOR XML`.

These options can be added to the view:

- `WITH SCHEMABINDING`: No changes to underlying table.
- `WITH ENCRYPTION`: Encrypts the view.
- `WITH CHECK`: Cannot do updates that removes the updated rows from the view.

#### Indexed views

```sql
CREATE VIEW UnderagePeople
WITH SCHEMABINDING
AS
  SELECT
      firstName
    , lastName
    , age
  FROM dbo.people
  WHERE age < 18

CREATE UNIQUE CLUSTERED INDEX IX_lastName 
ON dbo.UnderagePeople(firstName, lastName)

SELECT *
FROM UnderagePeople
```

![Indexed view results]({{ "/assets/notes-on-70-761-Querying-Data-with-Transact-SQL/indexed-view-results.png" | absolute_url }})

- Needs `WITH SCHEMABINDING`.
- Schema name is needed in the table used in `FROM`.
- Cannot use non-deterministic functions in the view.
- Cannot use functions that returns values with `FLOAT` type.

- When the view is schema bound you cannot use `SELECT *`.

---

<br/><br/><br/>

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
- 11 to 19 are errors that can be caught.
- 20 to 25 terminates the connection.

State are between 1 and 255 and are used for informational purposes.

There is also a variant with printf-style syntax:

```sql
RAISERROR('Error message: %s, %s', 16, 1, 'test1', 'test2')
```

There two extra options that can be added to `RAISERROR()`:

- `WITH NOWAIT`: used to raise the error immediately, rather than wait until the buffer is full.
- `WITH LOG`: have to be used for severity 19 and up.

Example:

```sql
RAISERROR('Error message', 16, 1) WITH NOWAIT
RAISERROR('Error message', 22, 1) WITH LOG
```

#### THROW vs RAISERROR

---

<br/><br/><br/>

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

Returns the first value that is not NULL. Supports two parameters.

Example:

```sql
DECLARE @a INT = NULL
DECLARE @b INT = 1

SELECT ISNULL(@a, @b)   -- outputs 1
```

- `ISNULL()` is T-SQL and not part of the SQL standard.

#### COALESCE()

Returns the first value that is not NULL. Supports more than two parameters.

Example:

```sql
DECLARE @a INT = NULL
DECLARE @b INT = NULL
DECLARE @c INT = 2

SELECT COALESCE(@a, @b, @c)   -- outputs 2
```

- `COALESCE()` is part of the SQL standard.

#### ISNULL() vs COALESCE()

The [official exam book][amazon-querying-data-with-transact-sql] has a nice table that summarizes
the differences between `ISNULL()` and `COALESCE()`:

| Property                               | `ISNULL()` | `COALESCE()` |
|----------------------------------------|------------|--------------|
| Parameters                             | 2          | > 2          |
| SQL standard                           | no         | yes          |
| Data type of result                    | 1. If first input has type, then that type.<br>2. Else, if second input has type, then that type.<br>3. If both inputs are untyped NULLs, then INT. | 1. If at least one input has type, then type with highest precedence.<br>2. If all inputs are untyped NULLs, then error. |
| Nullability of result                  | If any input is non-nullable, the result is NOT NULL, otherwise NULL. | If all inputs are non-nullable, the result is NOT NULL, otherwise NULL. |
| Might execute sub query more than once | no         | yes          |


---

<br/><br/><br/>

# Not part of the official syllabus

The things in this chapter is not part of the official syllabus, but should be known about anyway.

### Spatial data

[redgate on spatial data][red-gate-spatial-data]

#### Geography

[Official documentation][microsoft-geography]

`geography` is a data type in SQL Server that stores longitude and latitude.

Example:

```sql
CREATE TABLE customers   
(
    Id                 INT            IDENTITY (1,1)  NOT NULL
  , firstName          VARCHAR(200)
  , lastName           VARCHAR(200)
  , customer_location  geography
)

INSERT INTO customers (firstName, lastName, customer_location) VALUES
    ('Jon' , 'Snow' , geography::Parse('POINT(5.0 60.0)'))
  , ('Arya', 'Stark', geography::Parse('POINT(4.0 58.0)'))
```

#### Geometry

[Official documentation][microsoft-geometry]

`geometry` is a data type in SQL Server that stores spatial data in a flat coordinate system.

Example:

```sql
CREATE TABLE employees   
(
    Id                 INT            IDENTITY (1,1)  NOT NULL
  , firstName          VARCHAR(200)
  , lastName           VARCHAR(200)
  , desk_location      geometry
)

INSERT INTO employees (firstName, lastName, desk_location) VALUES
    ('Jon' , 'Snow' , geometry::Parse('POINT(44 27 0)'))
  , ('Arya', 'Stark', geometry::Parse('POINT(44 15 1)'))

SELECT
    firstName + ' ' + lastName AS Name
  , desk_location.STX AS X
  , desk_location.STY AS Y
  , desk_location.Z   AS Z
FROM employees
```

#### Geography vs geometry

- `geography` uses a round-earth coordinate system.
- `geometry` uses a flat coordinate system.

#### Cursors

- A control structure that enables traversal over the records in a database.
- Similar to an iterator in programming languages.
- A pointer to one row in a set of rows.

Example:

```sql
DECLARE @Name VARCHAR(40)

DECLARE cursor_test CURSOR FOR
  SELECT TOP 10 Name FROM accounts

OPEN cursor_test

FETCH NEXT FROM cursor_test INTO @Name

WHILE @@FETCH_STATUS = 0  
BEGIN   
  PRINT @Name

  FETCH NEXT FROM cursor_test INTO @Name
END

CLOSE cursor_test
DEALLOCATE cursor_test
```

[microsoft-mcsa-sql-2016-database-development]: https://www.microsoft.com/en-us/learning/mcsa-sql2016-database-development-certification.aspx
[microsoft-70-761-curriculum]: https://www.microsoft.com/en-us/learning/exam-70-761.aspx
[microsoft-deterministic-and-non-deterministic-functions]: https://docs.microsoft.com/en-us/sql/relational-databases/user-defined-functions/deterministic-and-nondeterministic-functions
[microsoft-conversion-functions]: https://docs.microsoft.com/en-us/sql/t-sql/functions/conversion-functions-transact-sql
[microsoft-aggregate-functions]: https://docs.microsoft.com/en-us/sql/t-sql/functions/aggregate-functions-transact-sql
[microsoft-system-functions]: https://docs.microsoft.com/en-us/sql/t-sql/functions/system-functions-transact-sql
[microsoft-merge]: https://docs.microsoft.com/en-us/sql/t-sql/statements/merge-transact-sql
[microsoft-output]: https://docs.microsoft.com/en-us/sql/t-sql/queries/output-clause-transact-sql
[microsoft-cte]: https://docs.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql
[microsoft-for-xml]: https://docs.microsoft.com/en-us/sql/relational-databases/xml/for-xml-sql-server
[microsoft-openxml]: https://docs.microsoft.com/en-us/sql/relational-databases/xml/openxml-sql-server
[microsoft-json]: https://docs.microsoft.com/en-us/sql/relational-databases/json/json-data-sql-server
[microsoft-openjson]: https://docs.microsoft.com/en-us/sql/t-sql/functions/openjson-transact-sql
[microsoft-create-view]: https://docs.microsoft.com/en-us/sql/t-sql/statements/create-view-transact-sql
[microsoft-geography]: https://docs.microsoft.com/en-us/sql/t-sql/spatial-geography/spatial-types-geography
[microsoft-geometry]: https://docs.microsoft.com/en-us/sql/t-sql/spatial-geometry/spatial-types-geometry-transact-sql
[essentialsql-intro-to-ctes]: https://www.essentialsql.com/introduction-common-table-expressions-ctes/
[essentialsql-recursive-ctes]: https://www.essentialsql.com/recursive-ctes-explained/
[red-gate-spatial-data]: https://www.red-gate.com/simple-talk/sql/t-sql-programming/introduction-to-sql-server-spatial-data/
[stackoverflow-union-and-union-all]: https://stackoverflow.com/questions/49925/what-is-the-difference-between-union-and-union-all
[stackoverflow-where-clause-sargability]: https://stackoverflow.com/questions/799584/what-makes-a-sql-statement-sargable
[lobsterpot-sargable-functions]: http://blogs.lobsterpot.com.au/2010/01/22/sargable-functions-in-sql-server/
[amazon-querying-data-with-transact-sql]: https://www.amazon.com/Exam-70-761-Querying-Data-Transact-SQL/dp/1509304339
