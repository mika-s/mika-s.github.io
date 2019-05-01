---
layout: post
title:  "Notes on 70-761: Querying Data with Transact-SQL"
date:   2019-01-31 15:00:00 +0100
categories: sql certification 70-761
---

These are some notes I took for the Microsoft exam 70-761: Querying Data with Transact-SQL,
which is a part of [MCSA: SQL 2016 Database Development][microsoft-mcsa-sql-2016-database-development].

## Manage data with Transact-SQL (40–45%)

# Create Transact-SQL SELECT queries

#### Syllabus

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
SELECT * FROM customers WHERE city = "New York City" AND gender = "Male"
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
| [ABC]    | A single character, either A, B or C        |
| [A-R]    | A single character, in the range A to R     |
| [ABC]    | A single character, not A, B or C           |
| [^A-R]   | A single character, not in the range A to R |

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

`PERCENT` rounds up.

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

- Number of columns must be the same in the two sets.
- Column data type must be the same or compatible (implicitly covertable).

#### INTERSECT

#### EXCEPT

#### Special rules

- Presedence order: parantheses, `NOT`, `AND` and then `OR`.
- SQL Server doesn't necessarily go left-to-right in `WHERE` clause predictes.
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

#### Syllabus

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

#### Syllabus

*Construct queries using scalar-valued and table-valued functions; identify the impact of
function usage to query performance and WHERE clause sargability; identify the differences
between deterministic and non-deterministic functions; use built-in aggregate functions;
use arithmetic functions, date-related functions, and system functions*

#### Scalar-valued functions

#### Table-valued functions

#### WHERE clause sargability

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

#### Built-in aggregate functions

#### Date-related functions

#### System functions

## Modify data

#### Syllabus

*Write INSERT, UPDATE, and DELETE statements; determine which statements can be used to
load data to a table based on its structure and constraints; construct Data Manipulation
Language (DML) statements using the OUTPUT statement; determine the results of Data
Definition Language (DDL) statements on supplied tables and data*

#### INSERT

#### UPDATE

#### DELETE

#### MERGE

#### OUTPUT

## Query data with advanced Transact-SQL components (30–35%)

# Query data by using subqueries and APPLY

#### Syllabus

*Determine the results of queries using subqueries and table joins, evaluate performance
differences between table joins and correlated subqueries based on provided data and query
plans, distinguish between the use of CROSS APPLY and OUTER APPLY, write APPLY statements
that return a given data set based on supplied data*

#### CROSS APPLY

Apply a function to every row.

#### OUTER APPLY

# Query data by using table expressions

#### Syllabus

*Identify basic components of table expressions, define usage differences between table
expressions and temporary tables, construct recursive table expressions to meet business
requirements*

#### Table expressions

#### Table expressions vs. temporary tables

#### Recursive CTEs

# Group and pivot data by using queries

#### Syllabus

*Use windowing functions to group and rank the results of a query; distinguish between using
windowing functions and GROUP BY; construct complex GROUP BY clauses using GROUPING SETS,
and CUBE; construct PIVOT and UNPIVOT statements to return desired results based on supplied
data; determine the impact of NULL values in PIVOT and UNPIVOT queries*

#### GROUPING SETS

#### CUBE

#### PIVOT and UNPIVOT statements

# Query temporal data and non-relational data

#### Syllabus

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

#### Syllabus

*Create stored procedures, table-valued and scalar-valued user-defined functions, triggers,
and views; implement input and output parameters in stored procedures; identify whether to use
scalar-valued or table-valued functions; distinguish between deterministic and non-deterministic
functions; create indexed views*

#### Stored procedures

#### Table-valued user-defined function

#### Scalar-valued user-defined function

#### Triggers

#### Views

Restrictions:

* 1024 columns
* Single query
* Single table when using `INSERT`
* Restricted data modifications
* No `TOP` without `ORDER BY`

WITH SCHEMABINDING: No changes to underlying table.
WITH ENCRYPTION: Encrypts the view.
WITH CHECK: Cannot do updates that removes the updated rows from the view.

#### Indexed views

Needs SCHEMABINDING.

# Implement error handling and transactions

### Syllabus

*Determine results of Data Definition Language (DDL) statements based on transaction control
statements, implement TRY…CATCH error handling with Transact-SQL, generate error messages with
THROW and RAISERROR, implement transaction control in conjunction with error handling in stored
procedures*

#### Transaction control

#### TRY-CATCH

#### THROW

#### RAISERROR

#### THROW vs RAISERROR

# Implement data types and NULLs

#### Syllabus

Evaluate results of data type conversions, determine proper data types for given data elements
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
[microsoft-for-xml]: https://docs.microsoft.com/en-us/sql/relational-databases/xml/for-xml-sql-server
[microsoft-openxml]: https://docs.microsoft.com/en-us/sql/relational-databases/xml/openxml-sql-server
[stackoverflow-union-and-union-all]: https://stackoverflow.com/questions/49925/what-is-the-difference-between-union-and-union-all
