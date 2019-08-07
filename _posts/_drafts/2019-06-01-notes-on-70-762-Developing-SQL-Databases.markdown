---
layout: post
title:  "Notes on 70-762: Developing SQL Databases"
date:   2019-06-01 15:00:00 +0100
categories: sql certification 70-762
---

These are some notes I took for the Microsoft exam 70-762: Developing SQL Databases,
which is a part of [MCSA: SQL 2016 Database Development][microsoft-mcsa-sql-2016-database-development].

This is for the syllabus as it was in June 2019. The syllabus might change in the future. I've mainly
taken notes from the official documentation and the [official exam book][amazon-developing-sql-databases].
I recommend reading some of the articles on Erland Sommerskog's web page, especially the articles
on [error handling][erland-sommerskog-error-handling].

---

## Table of Contents

- [Design and implement database objects](#design_and_implement_database_objects)
  - [Design and implement a relational database schema](#design_and_implement_a_relational_database_schema)
    - [Design tables and schemas based on business requirements](#design_tables_and_schemas)
    - [Improve the design of tables by using normalization](#improve_design_of_tables_using_normalization)
    - [Write table create statements](#write_table_create_statements)
    - [Determine the most efficient data types to use](#determine_the_most_efficient_data_types_to_use)
  - [Design and implement indexes](#design_and_implement_indexes)
    - [Design new indexes based on provided tables, queries, or plans](#design_new_indexes)
    - [Distinguish between indexed columns and included columns](#distinguish_between_indexed_columns_and_included_columns)
    - [Implement clustered index columns by using best practices](#implement_clustered_index_columns)
    - [Recommend new indexes based on query plans](#recommend_new_indexes_based_on_query_plans)
  - [Design and implement views](#design_and_implement_views)
    - [Design a view structure to select data based on user or business requirements](#design_a_view_structure)
    - [Identify the steps necessary to design an updateable view](#identify_steps_to_design_updatable_view)
    - [Implement partitioned views](#implement_partioned_views)
    - [Implement indexed views](#implement_indexed_views)
  - [Implement columnstore indexes](#implement_columnstore_indexes)
    - [Determine use cases that support the use of columnstore indexes](#determine_use_cases_for_columnstore_indexes)
    - [Identify proper usage of clustered and non-clustered columnstore indexes](#identify_proper_usage_of_columnstore_indexes)
    - [Design standard non-clustered indexes in conjunction with clustered columnstore indexes](#design_standard_non_clustered_index_with_clustered_columnstore_indexes)
    - [Implement columnstore index maintenance](#implement_columnstore_index_maintenance)
- [Implement programmability objects](#implement_programmability_objects)
  - [Ensure data integrity with constraints](#ensure_data_integrity_with_constraints)
    - [Define table and foreign key constraints to enforce business rules](#define_table_and_foreign_key_constraints)
    - [Write Transact-SQL statements to add constraints to tables](#write_tsql_statements_to_add_constraints)
    - [Identify results of Data Manipulation Language (DML) statements given existing tables and constraints](#identify_results_of_dml_statements_given_tables_and_constraints)
    - [Identify proper usage of PRIMARY KEY constraints](#identify_proper_usage_of_primary_key_constraints)
  - [Create stored procedures](#create_stored_procedures)
    - [Design stored procedure components and structure based on business requirements](#design_stored_procecure_components_and_structure)
    - [Implement input and output parameters](#implement_input_and_output_parameters)
    - [Implement table-valued parameters](#implement_table_valued_parameters)
    - [Implement return codes](#implement_return_codes)
    - [Streamline existing stored procedure logic](#streamline_existing_stored_procedure_logic)
    - [Implement error handling and transaction control logic within stored procedures](#implement_error_handling_and_transaction_login_in_stored_procedure)
  - [Create triggers and user-defined functions](#create_triggers_and_user_defined_functions)
    - [Design trigger logic based on business requirements](#design_trigger_logic)
    - [Determine when to use Data Manipulation Language (DML) triggers, Data Definition Language (DDL) triggers, or logon triggers](#determine_when_to_use_DML_triggers_ddl_triggers_logon_triggers)
    - [Recognize results based on execution of AFTER or INSTEAD OF triggers](#recognize_results_based_on_execution_of_after_or_instead_of_triggers)
    - [Design scalar-valued and table-valued user-defined functions based on business requirements](#design_scalar_valued_and_table_valued_functions)
    - [Identify differences between deterministic and non-deterministic functions](#identify_differences_between_deterministic_and_non_deterministic_functions)
- [Manage database concurrency](#manage_database_concurrency)
  - [Implement transactions](#implement_transactions)
    - [Identify DML statement results based on transaction behavior](#identify_dml_statements_results_based_on_transaction_behavior)
    - [Recognize differences between and identify usage of explicit and implicit transactions](#recognize_differences_between_and_identify_usage_of_explicit_and_implicit_transactions)
    - [Implement savepoints within transactions](#implement_savepoints_within_transactions)
    - [Determine the role of transactions in high-concurrency databases](#determine_the_role_of_transactions_in_high_concurrency_databases)
  - [Manage isolation levels](#manage_isolation_levels)
    - [Identify differences between Read Uncommitted, Read Committed, Repeatable Read, Serializable, and Snapshot isolation levels](#identify_differences_between_isolation_levels)
    - [Define results of concurrent queries based on isolation level](#define_results_of_concurrent_queries_based_on_isolation_level)
    - [Identify the resource and performance impact of given isolation levels](#identify_the_resource_and_performance_impact_of_given_isolation_levels)
  - [Optimize concurrency and locking behavior](#optimize_concurrency_and_locking_behavior)
    - [Troubleshoot locking issues](#troubleshoot_locking_issues)
    - [Identify lock escalation behaviors](#identify_lock_escalation_behaviors)
    - [Capture and analyze deadlock graphs](#capture_and_analyze_deadlock_graphs)
    - [Identify ways to remediate deadlocks](#identify_ways_to_remediate_deadlocks)
  - [Implement memory-optimized tables and native stored procedures](#implement_memory_optimized_tables_and_native_stored_procedures)
    - [Define use cases for memory-optimized tables versus traditional disk-based tables](#define_use_cases_for_memory_optimized_tables_vs_traditional_disk_based_tables)
    - [Optimize performance of in-memory tables by changing durability settings](#optimize_performance_of_in_memory_tables_by_changing_durability_settings)
    - [Determine best case usage scenarios for natively compiled stored procedures](#determine_best_case_usage_scenarios_for_nativelyl_compiled_stored_procedures)
    - [Enable collection of execution statistics for natively compiled stored procedures](#enable_collection_of_execution_statistics_for_natively_compiled_stored_procedures)
- [Optimize database objects and SQL infrastructure](#optimize_database_objects_and_sql_infrastructure)
  - [Optimize statistics and indexes](#optimize_statistics_and_indexes)
    - [Determine the accuracy of statistics and the associated impact to query plans and performance](#determine_the_accuracy_of_statistics_and_the_associated_impact_to_query_plans_and_performance)
    - [Design statistics maintenance tasks](#design_statistics_mainentance_tasks)
    - [Use dynamic management objects to review current index usage and identify missing indexes](#use_dynamic_management_objects_to_review_current_index_usage_and_identify_missing_indexes)
    - [Consolidate overlapping indexes](#consolidate_overlapping_indexes)
  - [Analyze and troubleshoot query plans](#analyze_and_troubleshoot_query_plans)
    - [Capture query plans using extended events and traces](#capture_query_plans_using_extended_events_and_traces)
    - [Identify poorly performing query plan operators](#identify_poorly_performing_query_plan_operators)
    - [Create efficient query plans using Query Store](#create_efficient_query_plans_using_query_store)
    - [Compare estimated and actual query plans and related metadata](#compare_estimated_and_actual_query_plans_and_related_metadata)
    - [Configure Azure SQL Database Performance Insight](#configure_azure_sql_database_performance_insight)
  - [Manage performance for database instances](#manage_performance_for_database_instances)
    - [Manage database workload in SQL Server](#manage_database_workload_in_sql_server)
    - [Design and implement Elastic Scale for Azure SQL Database](#design_and_implement_elastic_scale_for_azure_sql_database)
    - [Select an appropriate service tier or edition](#select_and_appropriate_service_tier_or_edition)
    - [Optimize database file and tempdb configuration](#optimize_database_file_and_tempdp_configuration)
    - [Optimize memory configuration](#optimize_memory_configuration)
    - [Monitor and diagnose scheduling and wait statistics using dynamic management objects](#monitor_and_diagnose_scheduling_and_wait_statistics_using_dynamic_management_objects)
    - [Troubleshoot and analyze storage, IO, and cache issues](#troubleshoot_and_analuze_storage_io_and_cache_issues)
    - [Monitor Azure SQL Database query plans](#monitor_azure_sql_database_query_plans)
  - [Monitor and trace SQL Server baseline performance metrics](#monitor_and_trace_sql_server_baseline_performance_metrics)
    - [Monitor operating system and SQL Server performance metrics](#monitor_os_and_sql_server_performance_metrics)
    - [Compare baseline metrics to observed metrics while troubleshooting performance issues](#compare_baseline_metrics_to_observed_metrics_while_troubleshooting_performance_issues)
    - [Identify differences between performance monitoring and logging tools, such as perfmon and dynamic management objects](#identify_differences_between_performance_monitoring_and_logging_tools)
    - [Monitor Azure SQL Database performance](#monitor_azure_sql_database_performance)
    - [Determine best practice use cases for extended events](#determine_best_practice_use_cases_for_extended_events)
    - [Distinguish between Extended Events targets](#distinguish_between_extended_event_targets)
    - [Compare the impact of Extended Events and SQL Trace](#compare_the_impact_of_extended_events_and_sql_trace)
    - [Define differences between Extended Events Packages, Targets, Actions, and Sessions](#define_differences_between_extended_events_packages_targets_actions_and_sessions)

---

<br/><br/><br/>

<a name="design_and_implement_database_objects"></a>

## Design and implement database objects (25–30%)

<a name="design_and_implement_a_relational_database_schema"></a>

# Design and implement a relational database schema

### Syllabus

*Design tables and schemas based on business requirements, improve the design of tables by using
normalization, write table create statements, determine the most efficient data types to use*

<a name="design_tables_and_schemas"></a>

#### Design tables and schemas based on business requirements

<a name="improve_design_of_tables_using_normalization"></a>

#### Improve the design of tables by using normalization

- **Natural key:** A unique key based on real-life values, such as email. Based on the other values in
  the same row.
- **Surrogate key:** A unique key that has no meaning outside a database environment. Not based on the
  values in the same row.
- **Candidate key:** A potential primary key. A candidate key is based on a combination of attributes
  in a row that can be used to identify that row, without referring to any other data.

**Forms:**

Listed below are requirements for the various normalization forms.

**First normal form:**

- The columns must be atomic.

  *Example:*
  
  Instead of
  
  | Name            | Age |
  |-----------------|-----|
  | John, Smith     | 30  |
  | Laura, Peterson | 77  |
  
  we do
  
  | FirstName | LastName | Age |
  |-----------|----------|-----|
  | John      | Smith    | 30  |
  | Laura     | Peterson | 77  |
  
- All rows must contain the same number of values. The columns should not contain arrays.

  Example:
  
  Instead of
  
  | CustomerId | Insurances              |
  |------------|-------------------------|
  | 1          | contents,house,accident |
  | 2          | contents,car            |
  
  we do
  
  | CustomerId | Insurance |
  |------------|-----------|
  | 1          | contents  |
  | 1          | house     |
  | 1          | accident  |
  | 2          | contents  |
  | 2          | car       |

**Second normal form:**

- Is in first normal form.
- All columns must be a fact about the entire primary key and not a subset of the primary key.

The second requirement is only a concern if the primary key is composed of multiple columns.

Example:

Instead of

| Manufacturer | ManufacturerCountry | Model      | Color  |
|--------------|---------------------|------------|--------|
| Specialized  | USA                 | Turbo Creo | Black  |
| Specialized  | USA                 | Turbo Vado | Black  |
| Bianchi      | Italy               | Infinito   | Green  |
| Bianchi      | Italy               | Oltre      | Yellow |

we do

| Manufacturer | Model      | Color  |
|--------------|------------|--------|
| Specialized  | Turbo Creo | Black  |
| Specialized  | Turbo Vado | Black  |
| Bianchi      | Infinito   | Green  |
| Bianchi      | Oltre      | Yellow |

| Manufacturer | ManufacturerCountry |
|--------------|---------------------|
| Specialized  | USA                 |
| Bianchi      | Italy               |

**Third normal form:**

- Is in second normal form.
- All columns must be a fact about the entire primary key, and not any non-primary key columns.

Example:

Instead of

we do

**Boyce-Codd normal form:**

Example:

Instead of

we do

<a name="write_table_create_statements"></a>

#### Write table create statements

Tables have been created multiple places in this document, so I will not write anything about that
here.

<a name="determine_the_most_efficient_data_types_to_use"></a>

#### Determine the most efficient data types to use

Choosing the best type is important for the following reasons:

- It serves as a first-level validation against faulty input. E.g. a SSN column with `VARCHAR(20)` type
  can only store 20 characters.
- It limits and models the domain data. E.g. the `DATE` type can only store dates.
- It is important for performance.

Choosing the correct type has already been written about [here][github-70-761-proper-data-types-for-elements-and-columns].

**Computed columns:**

Computed columns are columns that are based on expressions.

If the computed column is deterministic, it is persisted. If it's non-deterministic it will be
computed at query-time.

Example:

```sql
CREATE TABLE PeopleComputed
(
      Id        INT             NOT NULL    IDENTITY(1,1)
    , FirstName VARCHAR(200)    NOT NULL
    , LastName  VARCHAR(200)    NOT NULL
    , Name AS CONCAT(FirstName, ' ', LastName)
)

INSERT INTO PeopleComputed (FirstName, LastName) VALUES ('Anna', 'Kessi')

SELECT * FROM PeopleComputed
```

![Computed column results]({{ "/assets/notes-on-70-762-Developing-SQL-Databases/people-computed-results.png" | absolute_url }})

The `PERSIST` keyword can be used to make SQL Server persist the computed column:

```sql
CREATE TABLE PeopleComputedPersisted
(
      Id        INT             NOT NULL    IDENTITY(1,1)
    , FirstName VARCHAR(200)    NOT NULL
    , LastName  VARCHAR(200)    NOT NULL
    , Name AS CONCAT(FirstName, ' ', LastName) PERSISTED
)
```

**Dynamic data masking:**

[Official documentation][microsoft-dynamic-data-masking]

Dynamic data masking enables the possibility to mask data in columns from users, either fully or
partially.

Data mask functions:

**Default:** Uses the default data mask of the used data type.

**Email:** Masks an email to only show a couple of characters.

**Random:** Mask a number data type by taking a random value in a range.

**Partial:** Replace the center of a string with a fixed string. The beginning and ending
are kept as they are.
  
- `NULL` will still be `NULL` after data masking. 

Example:

```sql
CREATE TABLE People
(
      Id        INT             NOT NULL    IDENTITY(1,1)   PRIMARY KEY
    , FirstName VARCHAR(200)    NOT NULL
    , LastName  VARCHAR(200)    MASKED WITH (FUNCTION = 'partial(1,"XXXXXXX",0)')
    , Age       INT             MASKED WITH (FUNCTION = 'random(1,50)')
    , Email     VARCHAR(150)    MASKED WITH (FUNCTION = 'email()')
)

INSERT INTO Test.People (FirstName, LastName, Age, Email)
VALUES ('John', 'Smith', 33, 'john.smith@example.com')

CREATE USER MaskingTest WITHOUT LOGIN;
GRANT SELECT ON Test.People TO MaskingTest

EXECUTE AS USER = 'MaskingTest'
SELECT * FROM Test.People
```

![Result of query with masked data]({{ "/assets/notes-on-70-762-Developing-SQL-Databases/masking-results.png" | absolute_url }})

---

<br/><br/><br/>

<a name="design_and_implement_indexes"></a>

# Design and implement indexes

### Syllabus

*Design new indexes based on provided tables, queries, or plans; distinguish between indexed columns
and included columns; implement clustered index columns by using best practices; recommend new
indexes based on query plans*

#### Indexes in general

[Official documentation][microsoft-indexes]

*An index is an on-disk structure associated with a table or view that speeds retrieval of rows
from the table or view.*

There are two types of indexes in SQL Server: clustered and non-clustered.

**Clustered:**

- The data in a table are physically stored and sorted after the clustered index.
- A table without a clustered index is called a *heap*.
- Teh maximum key size is 900 bytes.

**Non-clustered:**

- Instead of physically sorting the table after the index, the non-clustered index will have pointers
  that point to the correct row.
- If the table has a clustered index, the non-clustered indexes will point to the clustered index.
- If the table is a heap, the non-clusteded indexes will point directly to the rows.
- The maximum key size is 1700 bytes.

**Misc.:**

- When the index key is a single column, it's called a *simple index*. When it uses multiple columns,
  it's called a *composite index*.
- There can be only one clustered index per table.
- There can be only one columnstore index per table.
- Hash indexes are only used on memory-optimized tables.

<a name="design_new_indexes"></a>

#### Design new indexes based on provided tables, queries, or plans

[Official documentation][microsoft-index-design-guide]

- Indexes will automatically be created when `PRIMARY KEY` and `UNIQUE` constraints are made. SQL Server
  will automatically create a unique clustered index when `PRIMARY KEY` is used (unless a clustered index
  exists already) and a non-clustered index when `UNIQUE` is used.
  
- It is generally a good idea to implement indexes on columns with `FOREIGN KEY` constraints.

- *"Narrow indexes, or indexes with few columns in the index key, require less disk space and maintenance
  overhead."*
  
- *"Large numbers of indexes on a table affect the performance of INSERT, UPDATE, DELETE, and MERGE
  statements because all indexes must be adjusted appropriately as data in the table changes."*
  
- Indexing small tables might not be worth it, due to the overhead that the index lookup has.

- Create non-clustered index on columns that are frequently used in predicates and join conditions in queries.

- On columns without many distinct values, it can be a good idea to use filtered indexes, meaning
  indexes that uses a `WHERE` clause. E.g. columns with mostly `NULL` values, columns with categories
  of values, sparse columns, etc.
  
  **Filtered index:**
  
- The order matters when using composite keys. E.g. if you have a table with FirstName and LastName
  columns, and the index uses (LastName, FirstName), the index will help in the following queries:
  
  ```sql
  SELECT * FROM People WHERE LastName = 'Smith'
  SELECT * FROM People WHERE LastName = 'Smith' AND FirstName = 'Joe'
  ```
  
  but not in this query:
  
  ```sql
  SELECT * FROM People WHERE FirstName = 'Joe'
  ```
  
  The order should also be based on level of distinctness.

  **Covering index:**

  [redgate: Using Covering Indexes to Improve Query Performance][red-gate-covering-index]

  A covering index is an index that completely covers the query. It contains all the information
  necessary to resolve the query.

Be aware: 

- `PRIMARY KEY` constraints do not allow `NULL`, but `UNIQUE` constraints and unique indexes do.

<a name="distinguish_between_indexed_columns_and_included_columns"></a>

#### Distinguish between indexed columns and included columns

[Official documentation on indexes with included columns][microsoft-indexes-with-included-columns]

Included columns are columns that are "included" in an index, but not part of the key (nonkey columns).
The reason we could potentially want included columns is when the index covers the query, but we
don't want the included columns to be a part of the index due to performance issues (increased
size, for instance).

Example:

```sql
CREATE INDEX IX_Customers_Name ON dbo.Customers(LastName) INCLUDE (FirstName, Email)
```

<a name="implement_clustered_index_columns"></a>

#### Implement clustered index columns by using best practices

- The clustered index is usually based on the primary key of the table.
- The clustered index should use a surrogate key with the `IDENTITY` property or `SEQUENCE`
  object as default value.
- Clustered indexes should not be based on wide keys (many or large keys). Wide keys will not only
  affect the clustered index, but also non-clustered indexes that also have to store the wide keys
  because they point to them.
- Columns that change often should not be used as keys in a clustered index, because the clustered
  index is physically sorted using the key. A change means the entire row has to be moved.

<a name="recommend_new_indexes_based_on_query_plans"></a>

#### Recommend new indexes based on query plans

---

<br/><br/><br/>

<a name="design_and_implement_views"></a>

# Design and implement views

### Syllabus

*Design a view structure to select data based on user or business requirements, identify the steps
necessary to design an updateable view, implement partitioned views, implement indexed views*

<a name="design_a_view_structure"></a>

#### Design a view structure to select data based on user or business requirements

I have already written about views [here][github-70-761-views].

Views are usually made to encapsulate a query. This is done for the following reasons, according
to the exam book:

* To hide data. Either to create a new abstraction layer on top of a complex query, or to hide data
  for security purposes.
* To format data. The raw data in the tables can be formatted to be more suitable for customer
  requirements. For example converting 0 to 'Female' and 1 to 'Male', if gender is stored in a
  column with BIT data type.
* Reporting. 
* Provide a table-like interface for applications that only support tables. Not all applications
  or tools can use stored procedures or user-defined functions, but almost all can use views.

<a name="identify_steps_to_design_updatable_view"></a>

#### Identify the steps necessary to design an updateable view

The following proerties are needed to be able to use `INSERT`, `UPDATE` and `DELETE` on a view:

* Only one underlying table can be modified at a time. A view that references only one table will
  almost always be editable. If the view contains joins it will be editable if none of the columns
  from the joined tables are used.
* A row that cannot be seen from the view (i.e. filtered away with `WHERE`), but is in one of the
  underlying tables, cannot be updated or deleted.
* If `WITH CHECK` is used, rows cannot be edited such that they are no longer visible to the view
  after the update.
* `INSTEAD OF` triggers can be used to make all views editable.

<a name="implement_partioned_views"></a>

#### Implement partitioned views

A partitioned view is a view that uses `UNION ALL` to merge multiple tables into one result set.
This can be useful when tables are physically split into partitions and stored on different servers,
but should be treated as one table.

Example:

```sql
CREATE TABLE People1
(
      Id        INT          NOT NULL
        CONSTRAINT Pk_People1_Id PRIMARY KEY
        CONSTRAINT Ck_People1_Id CHECK (1 <= Id AND Id < 20)
    , FirstName VARCHAR(200) NOT NULL
    , LastName  VARCHAR(200) NOT NULL
)

CREATE TABLE People2
(
      Id        INT          NOT NULL
        CONSTRAINT Pk_People2_Id PRIMARY KEY
        CONSTRAINT Ck_People2_Id CHECK (21 <= Id AND Id < 30)
    , FirstName VARCHAR(200) NOT NULL
    , LastName  VARCHAR(200) NOT NULL
)

GO

CREATE VIEW PeoplePartitioned AS
    SELECT * FROM People1
    UNION ALL
    SELECT * FROM People2

GO

INSERT INTO People1 (Id, FirstName, LastName) VALUES ( 1, 'Aaron', 'Smithson'), ( 2, 'Denise', 'Shanique')
INSERT INTO People2 (Id, FirstName, LastName) VALUES (21, 'Sam',   'Crosette'), (22, 'Jaqlin', 'Bonaqua')

SELECT *
FROM PeoplePartitioned
WHERE Id = 1
```

The query plan for the last query will look like this:

![Query plan on partitioned view]({{ "/assets/notes-on-70-762-Developing-SQL-Databases/query-plan-partitioned-view.png" | absolute_url }})

SQL Server will only use one index, instead of using both the index for People1 and People2.

Requirements for partitioned views:

- `PRIMARY KEY` constraints are needed on the Id columns.
- The identity column cannot use `IDENTITY(X,Y)` or a `DEFAULT` constraint.
- `CHECK` constraints are needed to make sure the Ids are in the correct range. The ranges cannot overlap.

<a name="implement_indexed_views"></a>

#### Implement indexed views

I have already written about indexed views [here][github-70-761-indexed-views].

---

<br/><br/><br/>

<a name="implement_columnstore_indexes"></a>

# Implement columnstore indexes

### Syllabus

*Determine use cases that support the use of columnstore indexes, identify proper usage of clustered
and non-clustered columnstore indexes, design standard non-clustered indexes in conjunction with
clustered columnstore indexes, implement columnstore index maintenance*

<a name="determine_use_cases_for_columnstore_indexes"></a>

#### Determine use cases that support the use of columnstore indexes

[redgate: What are Columnstore Indexes?][red-gate-columnstore-index]

In ordinary b-tree (rowstore) indexes, the data is physically and logically stored and organiized
as rows and columns. With columnstore indexes, the data is stored as columns and organized as rows
and columns. The article linked to above will explain the rest of the theoretical stuff.

The following should be known about columnstore indexes:

- Columnstore indexes are specifically built for analytical purposes.
- Columnstore indexes are typically paired with rowstore indexes to allow searching for a single row.
- Clustered columnstore indexes change a table's storage and will compress data. This reduces the IO
  needed to perform queries on very large data sets.
- Nonclustered columnstore indexes can be added to rowstore tables to enable real-time analytics.
- Only one columnstore index per table is supported.
- Columnstore indexes are often used on fact tables in data warehouses.

<a name="identify_proper_usage_of_columnstore_indexes"></a>

#### Identify proper usage of clustered and non-clustered columnstore indexes

<a name="design_standard_non_clustered_index_with_clustered_columnstore_indexes"></a>

#### Design standard non-clustered indexes in conjunction with clustered columnstore indexes

<a name="implement_columnstore_index_maintenance"></a>

#### Implement columnstore index maintenance

---

<br/><br/><br/>

<a name="implement_programmability_objects"></a>

## Implement programmability objects (20–25%)

<a name="ensure_data_integrity_with_constraints"></a>

# Ensure data integrity with constraints

### Syllabus

*Define table and foreign key constraints to enforce business rules, write Transact-SQL statements
to add constraints to tables, identify results of Data Manipulation Language (DML) statements
given existing tables and constraints, identify proper usage of PRIMARY KEY constraints*

<a name="define_table_and_foreign_key_constraints"></a>

#### Define table and foreign key constraints to enforce business rules

Types of constraints:

| Name        | Description                                                                  |
|-------------|------------------------------------------------------------------------------|
| PRIMARY KEY | Enforce primary key.                                                         |
| FOREIGN KEY | Enforce relationships between two tables.                                    |
| DEFAULT     | Provide a default value for a column if no value is provided during inserts. |
| UNIQUE      | Enforce uniqueness for values in a column.                                   |
| CHECK       | Do simple predicate checks for values during inserts or updates.             |

Unique:

- NULL is always unique. Special check has to be implemented if only one NULL is allowed.

Check constraint:

- Validate that an integer is within a range.
- Enforce data format, e.g. SSN.
- Enforce logic.
- NULL is special.
- Use `INSTEAD OF` triggers for more advanced cases.

<a name="write_tsql_statements_to_add_constraints"></a>

#### Write Transact-SQL statements to add constraints to tables

When creating the table:

Inline version:

```sql
CREATE TABLE Customers
(
      Id            INT             NOT NULL IDENTITY(1,1)  CONSTRAINT Pk_Id            PRIMARY KEY 
    , FirstName     VARCHAR(200)    NOT NULL
    , LastName      VARCHAR(200)    NOT NULL
    , Age           INT             NOT NULL                CONSTRAINT Ch_Age           CHECK (18 <= Age AND Age < 100)
    , Email         VARCHAR(150)    NOT NULL                CONSTRAINT Un_Email         UNIQUE
    , IsDisabled    BIT             NOT NULL                CONSTRAINT Df_IsDisabled    DEFAULT (0)
)

CREATE TABLE Accounts
(
      Id            INT             NOT NULL IDENTITY(1,1)  CONSTRAINT Pk_AccId         PRIMARY KEY
    , CustomerId    INT             NOT NULL                CONSTRAINT Fk_CustomerId    FOREIGN KEY REFERENCES dbo.Customers (Id)
    , Balance       DECIMAL(10, 2)  NOT NULL                CONSTRAINT Df_Balance       DEFAULT (0.0)   
)
```

Standalone version:

```sql
CREATE TABLE Customers
(
      Id            INT             NOT NULL IDENTITY(1,1)
    , FirstName     VARCHAR(200)    NOT NULL
    , LastName      VARCHAR(200)    NOT NULL
    , Age           INT             NOT NULL
    , Email         VARCHAR(150)    NOT NULL
    , IsDisabled    BIT             NOT NULL                CONSTRAINT Df_IsDisabled    DEFAULT (0)

    , CONSTRAINT Pk_CustId      PRIMARY KEY (Id)
    , CONSTRAINT Ch_Age         CHECK (18 <= Age AND Age < 100)
    , CONSTRAINT Un_Email       UNIQUE (Email)
)
```

- `DEFAULT` constraints have to be inline.
- If the check constraint is checking multiple columns, it has to be standalone.

Adding constraints when table exists already:

Foreign key:

```sql
ALTER TABLE Accounts
    ADD CONSTRAINT Fk_CustomerId FOREIGN KEY (CustomerId) REFERENCES dbo.Customers (Id)
```

Default:

```sql
ALTER TABLE Customers
    ADD CONSTRAINT Df_IsDisabled DEFAULT(0) FOR IsDisabled
```
	
Unique:

```sql
ALTER TABLE Customers
    ADD CONSTRAINT Un_Email UNIQUE (Email)
```

Check:

```sql
ALTER TABLE Customers
    ADD CONSTRAINT Ch_Age CHECK (18 <= Age AND Age < 100)
```


- Different options: ON CASCADE, WITH CHECK, etc.

<a name="identify_results_of_dml_statements_given_tables_and_constraints"></a>

#### Identify results of Data Manipulation Language (DML) statements given existing tables and constraints

Primary key constraints:

Ok:

Not ok:

Foreign key constraints:

Ok:

Not Ok:

```sql
INSERT INTO Customers (FirstName, LastName, Age, Email) VALUES
      ('John', 'Smith', 30, 'john@smith.com')
    , ('Joey', 'Smith', 44, 'joey@smith.com')
    , ('Anna', 'Smith', 47, 'anna@smith.com')
    , ('Nick', 'Smith', 88, 'nick@smith.com')

INSERT INTO Accounts (CustomerId) VALUES (1), (2), (3)

DELETE FROM Customers WHERE Id = 1  -- will not work due to FK

/*
Msg 547, Level 16, State 0, Line 30
The DELETE statement conflicted with the REFERENCE constraint "Fk_CustomerId". The conflict occurred in database "test", table "dbo.Accounts", column 'CustomerId'.
The statement has been terminated.
*/
```

Default constraints:

Ok:

Not ok:


Unique constraints:

Ok:

This will be ok, as long as the email adresses don't exist in `Customers` already.

```sql
INSERT INTO Customers (FirstName, LastName, Age, Email) VALUES
      ('Albert', 'Smith', 30, 'albert@example.com')
    , ('Alan',   'Smith', 42, 'alan@example.com')
```

Not ok:

This is not ok because the same email is provided twice, and therefore break the unique constraint.


```sql
INSERT INTO Customers (FirstName, LastName, Age, Email) VALUES
      ('John', 'Smith', 30, 'john@example.com')
    , ('John', 'Smith', 30, 'john@example.com')
	
/*
Msg 2627, Level 14, State 1, Line 1
Violation of UNIQUE KEY constraint 'Un_Email'. Cannot insert duplicate key in object 'dbo.Customers'. The duplicate key value is (john@example.com).
The statement has been terminated.
*/
```

Check contraints:

Ok:

- Use `WITH NOCHECK` when adding a check constraint on an already existing table, to ignore checking the already existing rows
  in the column that's getting the check constraint.

Not ok:

This will not work due to the check constraint on age, that requires an age over or equal to 18.

```sql
INSERT INTO Customers (FirstName, LastName, Age, Email) VALUES
      ('Alonso', 'Smith', 17, 'alonso@example.com')
	  
/*
Msg 547, Level 16, State 0, Line 1
The INSERT statement conflicted with the CHECK constraint "Ch_Age". The conflict occurred in database "test", table "dbo.Customers", column 'Age'.
The statement has been terminated.
*/
```

<a name="identify_proper_usage_of_primary_key_constraints"></a>

#### Identify proper usage of PRIMARY KEY constraints

- We typically create an Id column as the primary key.
- `INT` is often used as the type of Id. `IDENTITY(X,Y)` is used to automatically increment the value.
- GUIDs can be used as type for Id. This is slower than using integers, but makes it possible to create Ids on any computer.
  GUIDs also take up a lot of space (16 bytes).

---

<br/><br/><br/>

<a name="create_stored_procedures"></a>

# Create stored procedures

### Syllabus

*Design stored procedure components and structure based on business requirements, implement input
and output parameters, implement table-valued parameters, implement return codes, streamline
existing stored procedure logic, implement error handling and transaction control logic within
stored procedures*

<a name="design_stored_procecure_components_and_structure"></a>

#### Design stored procedure components and structure based on business requirements

I have previously written a little bit about stored procedures [here][github-70-761-stored-procedures].

- Stored procedures can be used to create an abstraction layer between the user and the database.
- Stored procedures can also be used to encapsulate complex code.

Options when creating stored procedures:

- `WITH ENCRYPTION`: The stored procedure source code is encrypted.
- `WITH RECOMPILE`: The execution plan is not cached for the procedure, but calculated every time.
- `WITH EXECUTE AS`: Change the security context for the procedure.
- `WITH REPLICATION`: The procedure is specifically created for replication.

<a name="implement_input_and_output_parameters"></a>

#### Implement input and output parameters

Creation:

```sql
CREATE PROCEDURE dbo.NewCustomer
(
      @FirstName    VARCHAR(200)
    , @LastName     VARCHAR(200)
    , @Id           INT            OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO dbo.Customers (FirstName, LastName) VALUES (@FirstName, @LastName)

    SET @Id = SCOPE_IDENTITY()
END
```

Usage:

```sql
DECLARE @Id VARCHAR(200)

EXEC dbo.NewCustomer 'John', 'Smith', @Id OUTPUT

PRINT @Id  -- outputs 1
```

<a name="implement_table_valued_parameters"></a>

#### Implement table-valued parameters

Create a custom type first:

```sql
CREATE TYPE CustomerType AS TABLE
(
      FirstName VARCHAR(200)
    , LastName  VARCHAR(200)
)
```

Create the stored procedure with the custom type as parameter type. The `READONLY` keyword has to be used.

```sql
CREATE PROCEDURE dbo.NewCustomers
(
      @Customers    CustomerType    READONLY
)
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO dbo.Customers (FirstName, LastName)
    SELECT FirstName, LastName FROM @Customers
END
```

Usage:

```sql
DECLARE @NewCustomers CustomerType

INSERT INTO @NewCustomers (FirstName, LastName) VALUES
    ('Jane', 'Doe'), ('Peter', 'Almone')

EXEC dbo.NewCustomers @NewCustomers
```

<a name="implement_return_codes"></a>

#### Implement return codes

- Default return code is 0 if none is returned expicitly.
- Positive value generally mean positive outcome.
- Negative value generally mean negative outcome.
- 0 as return value usually mean success, without any other information given.

```sql
CREATE PROCEDURE [dbo].[GetData]
(
      @param1    VARCHAR(50)
    , @param2    VARCHAR(50) = NULL
)
AS
BEGIN
    SET NOCOUNT ON

    SELECT FirstName, LastName
    WHERE Param1 = @param1 AND Param2 <> @param2
    
    IF @@ROWCOUNT = 0
        RETURN -1
    
    RETURN 0
END
```

<a name="streamline_existing_stored_procedure_logic"></a>

#### Streamline existing stored procedure logic

- Invalid use of search argument.
- Parameter type mistmatch.

<a name="implement_error_handling_and_transaction_login_in_stored_procedure"></a>

#### Implement error handling and transaction control logic within stored procedures

---

<br/><br/><br/>

<a name="create_triggers_and_user_defined_functions"></a>

# Create triggers and user-defined functions

### Syllabus

*Design trigger logic based on business requirements; determine when to use Data Manipulation
Language (DML) triggers, Data Definition Language (DDL) triggers, or logon triggers; recognize
results based on execution of AFTER or INSTEAD OF triggers; design scalar-valued and table-valued
user-defined functions based on business requirements; identify differences between deterministic
and non-deterministic functions*

I have previously written about triggers [here][github-70-761-triggers].

<a name="design_trigger_logic"></a>

#### Design trigger logic based on business requirements

DML triggers will, when enabled, fire after an `INSERT`, `UPDATE` or `DELETE`. They are used to enforce
integrity of the database, just like the `CHECK` constraint. However, triggers are much more
powerful than the `CHECK` constraint.

There are also DDL triggers that can fire when database objects are created, update or deleted.

According to the exam book, business requirements with respect to triggers are usually based on DML
triggers. In this context, they enable:

* Complex data integrity. As mentioned above, the `CHECK` constraint can only handle simple predicate checks
  that refrences columns in the same row. Triggers can check multiple rows, for instance.
* Running code is response to an action
* Ensuring columnar data is modified. E.g. update an UpdatedAt column with the current datetime.
* Making views editable. If a view is referencing multiple tables it cannot be edited easily. However,
  `INSTEAD OF` triggers makes it easy.
  
There are two kinds of DML triggers:

* `AFTER`: runs after an operation
* `INSTEAD OF`: runs instead of an operation

Misc. about triggers:

* They cannot return values.

<a name="determine_when_to_use_DML_triggers_ddl_triggers_logon_triggers"></a>

#### Determine when to use Data Manipulation Language (DML) triggers, Data Definition Language (DDL) triggers, or logon triggers

**DML triggers:**

[Official documentation][microsoft-dml-triggers]

Triggers that fire instead of or after DML statements. For example after inserting something in a table,
when deleting something, etc.

**DDL triggers:**

[Official documentation][microsoft-ddl-triggers]

- Can be created when code should be run after creating a table, dropping an index, etc.
- There are two types of DDL triggers. The scope is the main difference.
  * Server: Applies to all databases on the server. Stored in the *master* database.
  * Database: Applies only to the database they are stored in.

**Logon triggers:**

[Official documentation][microsoft-logon-triggers]

Logon triggers fire when a user logs on to the database server.
Can be used to restrict certain users from logging in at certain times of the day.

**CLR triggers:**

Triggers written in a .NET language.

<a name="recognize_results_based_on_execution_of_after_or_instead_of_triggers"></a>

#### Recognize results based on execution of AFTER or INSTEAD OF triggers

<a name="design_scalar_valued_and_table_valued_functions"></a>

#### Design scalar-valued and table-valued user-defined functions based on business requirements

I have previously written about that [here][github-70-761-tvf].

<a name="identify_differences_between_deterministic_and_non_deterministic_functions"></a>

#### Identify differences between deterministic and non-deterministic functions

I have previously written about that [here][github-70-761-deterministic-vs-nondeterministic].

---

<br/><br/><br/>

<a name="manage_database_concurrency"></a>

## Manage database concurrency (25–30%)

# Locks in general

[Official documentation on locking][microsoft-locking-in-the-database-engine]
[SQLTeam on locking in SQL Server][sqlteam-introduction-to-locking-in-sql-server]

Here are some notes on locking, before going deeper into concurrency etc.

- Locks can exist on rows, tables, pages or indexes.

**Lock modes:**

[Official documentation][microsoft-lock-modes]

"The lock mode defines the level of dependency the transaction has on the data."

Intent shared lock (IS):

    Intent locks are used to establish lock hierarchies.

Shared lock (S):

    Created when reading data in pessimistic locking model. Other transactions can read but not modify locked data.
    The lock is released after the data is read, except in Read Repeatable or stricter isolation levels, or if
    a lock hint is used to keep the shared lock.

Intent exclusive (IX):

    Intent locks are used to establish lock hierarchies.

Exclusive lock (X):

    Lock used for data-manipulation operations, such as `INSERT`, `UPDATE` or `DELETE`.
    Exclusive locks will prevent other transactions of modifying data that is already being modified by the lock acquirer.
    Data that are exclusive locked cannot be read either, unless the isolation level is Read Uncommited or the `NOLOCK`
    hint is used.

Update lock (U):

    A combination of shared and exclusive lock. During an update the system has to find and then update a row.
    This two-step process could create deadlocks, which is why Update locks are used.

**Lock granularity:**

[Official documentation][microsoft-lock-granularity]

"Locking at a smaller granularity, such as rows, increases concurrency but has a higher overhead because
more locks must be held if many rows are locked. Locking at a larger granularity, such as tables, are
expensive in terms of concurrency because locking an entire table restricts access to any part of the
table by other transactions. However, it has a lower overhead because fewer locks are being maintained."

- ROWLOCK
- PAGLOCK
- TABLOCKX

<a name="implement_transactions"></a>

# Implement transactions

### Syllabus

*Identify DML statement results based on transaction behavior, recognize differences between and
identify usage of explicit and implicit transactions, implement savepoints within transactions,
determine the role of transactions in high-concurrency databases*

<a name="identify_dml_statements_results_based_on_transaction_behavior"></a>

#### Identify DML statement results based on transaction behavior

<a name="recognize_differences_between_and_identify_usage_of_explicit_and_implicit_transactions"></a>

#### Recognize differences between and identify usage of explicit and implicit transactions

<a name="implement_savepoints_within_transactions"></a>

#### Implement savepoints within transactions

<a name="determine_the_role_of_transactions_in_high_concurrency_databases"></a>

#### Determine the role of transactions in high-concurrency databases

---

<br/><br/><br/>

<a name="manage_isolation_levels"></a>

# Manage isolation levels

### Syllabus

*Identify differences between Read Uncommitted, Read Committed, Repeatable Read, Serializable, and
Snapshot isolation levels; define results of concurrent queries based on isolation level; identify
the resource and performance impact of given isolation levels*

<a name="identify_differences_between_isolation_levels"></a>

#### Identify differences between Read Uncommitted, Read Committed, Repeatable Read, Serializable, and Snapshot isolation levels

`SET ISOLATION LEVEL` can be used to change isolation level on session level. The isolation level
can also be changed on transaction level with hints.

| Isolation level          | Dirty reads | Non-repeatable reads | Phantom reads |
|--------------------------|-------------|----------------------|---------------|
| Read Uncommitted         | Yes         | Yes                  | Yes           |
| Read Committed           | No          | Yes                  | Yes           |
| Repeatable Read          | No          | No                   | Yes           |
| Serializable             | No          | No                   | No            |
| Snapshot                 | No          | No                   | No            |
| Read Committed Snapshot  | No          | No                   | No            |

**Read Uncommitted:**

- This is the least restricting isolation level.
- Transaction can read other transaction's uncommited data.

`NOLOCK` can be used as hint to use this isolation level.

**Read Committed:**

- This is the default level in SQL Server.
- It is the second least restricting isolation level.
- Uses pessimistic locking.
- A transaction cannot read uncommitted data that is being changed by another transaction, until
  the other transaction releases the lock.

**Repeatable Read:**

- Stricter level than read committed.
- Values that are read by one transaction are not changed by another transaction.
- Only protects existing data, not rows that are inserted later. Phantom reads are possible.

**Serializable:**

- The most pessimistic isolation level.
- Prevent changes and insertions. Phantom reads are not possible.

**Snapshot isolation levels:**

**Snapshot:**

- Optimistic lock.
- Read and write operations in different transactions can run concurrently without blocking each
  other.
- The database has to be configured to allow it.
- Cannot be used with distributed transactions.
- Uses the tempdb database.

**Read Committed Snapshot:**

- Optimistic lock.
- The database has to be configured to allow it.
- Can be used with distributed transactions.

<a name="define_results_of_concurrent_queries_based_on_isolation_level"></a>

#### Define results of concurrent queries based on isolation level

<a name="identify_the_resource_and_performance_impact_of_given_isolation_levels"></a>

#### Identify the resource and performance impact of given isolation levels

**Read Uncommitted:**

- Bad for integrity, but gives the best performance.
- Does not aquire shared locks for read operations.
- Ignores existing locks.

**Read Committed:**

- A shared lock is aquired for read operations for a single operation.
- Exclusive lock is aquired for write operations.

**Repeatable Read:**

- A shared lock is aquired for the data for the entire transaction.
- Concurrency is reduced because of a high level of locking.
- Dead locks can become more frequent.

**Serializable:**

- Locks data for read operations.
- Uses key-range locks for write operations.
- Concurrency is reduced because of a high level of locking.

Snapshot isolation levels:**

**Snapshot:**

- Locks are not used.
- Deadlocks and lock escalations happens less frequently than for serializeable,
  repeatable read, etc.
- Read operations are not blocked by write operations, and vice versa.
- Overhead: More space (in tempdb) and CPU power and memory is needed by SQL Server.
- Update operations might be slower than other isolation levels. Long-running read operations also.

**Read Committed Snapshot:**

- Shared page and row locks are not used.
- Write operations aquire exclusive locks.

---

<br/><br/><br/>

<a name="optimize_concurrency_and_locking_behavior"></a>

# Optimize concurrency and locking behavior

### Syllabus

*Troubleshoot locking issues, identify lock escalation behaviors, capture and analyze deadlock
graphs, identify ways to remediate deadlocks*

<a name="troubleshoot_locking_issues"></a>

#### Troubleshoot locking issues

The following DMVs can be used to troubleshoot locking issues:

* **sys.dm_tran_locks:** Shows all current locks, etc.

  In *request_status*, *GRANT* means the lock was granted, *WAIT* means the lock is waiting to be
  granted. *CONVERT* means a lock was granted with a certain lock mode, but had to be upgraded to
  a new lock mode, and is now blocked.

* **sys.dm_os_waiting_tasks:** shows tasks that are waiting for resources.

  ```sql
  SELECT
      t1.resource_type AS res_typ,
      t1.resource_database_id AS res_dbid,
      t1.resource_associated_entity_id AS res_entid,
      t1.request_mode AS mode,
      t1.request_session_id AS s_id,
      t2.blocking_session_id AS blocking_s_id
  FROM sys.dm_tran_locks as t1
      INNER JOIN sys.dm_os_waiting_tasks as t2
        ON t1.lock_owner_address = t2.resource_address;
  ```

* **sys.dm_os_wait_stats:** shows how often tasks are waiting while locks are taken.

  Filter to only see lock waits:

  ```sql
  SELECT
      wait_type as wait,
      waiting_tasks_count as wt_cnt,
      wait_time_ms as wt_ms,
      max_wait_time_ms as max_wt_ms,
      signal_wait_time_ms as signal_ms
  FROM sys.dm_os_wait_stats
  WHERE wait_type LIKE 'LCK%'
  ORDER BY wait_time_ms DESC
  ```
  
  The cumulative values can be reset like this:
  
  ```sql
  DBCC SQLPERF (N'sys.dm_os_wait_stats', CLEAR)
  ```

<a name="identify_lock_escalation_behaviors"></a>

#### Identify lock escalation behaviors

[Official documentation on lock escalation]: [microsoft-lock-escalation]
[DBA Stack Exchange on lock escalation][stackexchange-dba-what-is-lock-escalation]

Lock escalation is when SQL Server consolidates multiple locks into a higher-level lock. E.g.
multiple row locks into table lock or multiple page locks into table lock. Lock escalation is done
by the system in order to free up the memory that the finer-grained locks used, and thus increase
performance. There is also a maximum number of allowed locks that the system cannot go over.

To identify lock escalation behaviors:

* Monitor the *Lock:Escalation* event.
* Use the following SQL:

  ```sql
  SELECT
      wait_type as wait,
      wait_time_ms as wt_ms,
      CONVERT(decimal(9,2), 100.0 * wait_time_ms /
      SUM(wait_time_ms) OVER ()) as wait_pct
  FROM sys.dm_os_wait_stats
  WHERE wait_type LIKE 'LCK%'
  ORDER BY wait_time_ms DESC
  ```
  
  to look at how often the intent lock waits (LCK_M_I*) occur compared to ordinary locks.

<a name="capture_and_analyze_deadlock_graphs"></a>

#### Capture and analyze deadlock graphs

[Official documentation on deadlock trace flags][microsoft-deadlock-trace-flags]

First of all, deadlocks can be found without using graphs, using trace flags instead. The trace flags
are 1204 and 1222. The trace flags can be enabled with the following SQL:

```sql
DBCC TRACEON(1204, 1222, -1)
```

Deadlocks are captured in the SQL Server error logs if these trace flags are enabled.

SQL Server Profiler or Extended Events can be used to capture deadlock graphs, which are XML
descriptions of deadlocks.

<a name="identify_ways_to_remediate_deadlocks"></a>

#### Identify ways to remediate deadlocks

* Transactions should be as small as possible to make deadlocks less likely to occur.
* Locking more resources, e.g. an entire table, can also prevent deadlocks. This might cause
  blocking, however.
* We can try to run the code multiple times. The code has to be wrapped in a try-catch and
  inside a loop. If a deadlock occurs we rollback in the catch and continue the loop one
  more time.
* Use SNAPSHOT or READ_COMMITTED_SNAPSHOT isolation levels. This requires a lot of space in tempdb.
* Use the NOLOCK hint (READ_UNCOMMITTED isolation level). The trade-off is potential dirty reads.
* Use UPDLOCK or HOLDLOCK hints to proactivly prevent another transaction from locking a resource
  that our transaction is going to use.
* Add a new convering nonclustered index to provide SQL Server with another way to read data without
  accessing the underlying table. The other transaction cannot use any of the covering index columns.

---

<br/><br/><br/>

<a name="implement_memory_optimized_tables_and_native_stored_procedures"></a>

# Implement memory-optimized tables and native stored procedures

### Syllabus

*Define use cases for memory-optimized tables versus traditional disk-based tables, optimize
performance of in-memory tables by changing durability settings, determine best case usage scenarios
for natively compiled stored procedures, enable collection of execution statistics for natively
compiled stored procedures*

<a name="define_use_cases_for_memory_optimized_tables_vs_traditional_disk_based_tables"></a>

#### Define use cases for memory-optimized tables versus traditional disk-based tables

<a name="optimize_performance_of_in_memory_tables_by_changing_durability_settings"></a>

#### Optimize performance of in-memory tables by changing durability settings

<a name="determine_best_case_usage_scenarios_for_nativelyl_compiled_stored_procedures"></a>

#### Determine best case usage scenarios for natively compiled stored procedures

Natively compiled stored procedures are used with memory-optimized tables. The best case usage
scenarios are:

* When very high performance is needed.
* Queries that execute frequently.

Natively compiled stored procedures are also good at:

* Aggregation
* Nested-loop joins
* Multi-statement CRUD operations
* Complex expressions
* Procedural logic

It is a bad option if only processing a single row.

<a name="enable_collection_of_execution_statistics_for_natively_compiled_stored_procedures"></a>

#### Enable collection of execution statistics for natively compiled stored procedures

---

<br/><br/><br/>

<a name="optimize_database_objects_and_sql_infrastructure"></a>

## Optimize database objects and SQL infrastructure (20–25%)

<a name="optimize_statistics_and_indexes"></a>

# Optimize statistics and indexes

### Syllabus

*Determine the accuracy of statistics and the associated impact to query plans and performance,
design statistics maintenance tasks, use dynamic management objects to review current index usage
and identify missing indexes, consolidate overlapping indexes*

<a name="determine_the_accuracy_of_statistics_and_the_associated_impact_to_query_plans_and_performance"></a>

#### Determine the accuracy of statistics and the associated impact to query plans and performance

- When you create an index, SQL Server will create a statistics (database object).
- A column has a certain cardinality. If a column has only unique values (e.g. primary key column),
  it will have cardinality 1. Highly unique values in a column means high cardinality. When many of
  the values are the same in the column, the cardinality is lower.
- Use `DBCC SHOW_STATISTICS` to show statistics.
- Statistics will by default be updated and created automatically. The following commands can be
  used to change this behavior:
  
```sql
ALTER DATABASE test
    SET AUTO_UPDATE_STATISTICS OFF
    
ALTER DATABASE test
    SET AUTO_UPDATE_STATISTICS_ASYNC OFF
    
ALTER DATABASE test
    SET AUTO_CREATE_STATISTICS OFF
```

- SQL Server has a counter for each column with an index. When rows are inserted or modified this
  counter will be incremented. When statistics is updated the counter is reset to 0. When the server
  reaches a certain threshold it will update the statistics, if auto update is enabled.
  
- The thresholds are:
    * One or more rows are added to an empty table.
    * More than 500 rows are added to a table having fewer than 500 rows.
    * More than 500 rows are added to a table having more than 500 rows, and the number of rows
      added are more than a dynamic percentage of total rows. The dynamic percentage starts at ~20%
      and then reduces with table size.

<a name="design_statistics_mainentance_tasks"></a>

#### Design statistics maintenance tasks

[Official documentation][microsoft-update-statistics]

SQL Server automatically creates and updates statistics for indexes and for all columns used in a
`WHERE` clause or in a join. This can happen when the server is very busy, which affects
performance. It may also not happen often enough. Manually updating the statistics can be used in
cases like these.

SQL Server Agent extended stored procedures has to be enabled before creating maintenance plans:

```sql
EXEC sp_configure 'show advanced options', 1
GO

RECONFIGURE
GO

EXEC sp_configure 'Agent XPs', 1
GO

RECONFIGURE
GO
```

**Examples:**

Update statistics on table:

```sql
USE TestDb
GO

UPDATE STATISTICS dbo.People
WITH FULLSCAN
GO
```

Update statistics on an index:


```sql
USE TestDb
GO

UPDATE STATISTICS dbo.People IX_Email
GO
```

Create and update sample statistics:

```sql
USE TestDb
GO

CREATE STATISTICS People
ON dbo.People ([FirstName], [LastName])
WITH SAMPLE 50 PERCENT

-- Time passes

UPDATE STATISTICS dbo.People(People)
WITH SAMPLE 50 PERCENT
GO
```

Options:

| Option name   | Description              |
|---------------|--------------------------|
| `ALL`         | All existing statistics. |
| `COLUMNS`     | Column statistics only.  |
| `INDEX`       | Index statistics only.   |

Scan type options:

| Option name | Description                                               |
|-------------|-----------------------------------------------------------|
| `FULLSCAN`  | Update statistics by reading all rows in a table or view. |
| `SAMPLE`    | Update statistics based on percentage or number of rows.  |

To create a new maintenance task:

[SSMS...]

<a name="use_dynamic_management_objects_to_review_current_index_usage_and_identify_missing_indexes"></a>

#### Use dynamic management objects to review current index usage and identify missing indexes

**Reviewing current index usage:**

* **sys.dm_db_index_usage_stats**: a view that shows the use of indexes in queries.
* **sys.dm_db_index_physical_stats**: a function that checks the overall status of indexes in the
  database

The data received from `sys.dm_db_index_usage_stats` will be all numerical values. To see more
user-friendly values we can join on `sys.indexes`:

```sql
SELECT
    OBJECT_NAME(ixu.object_id, DB_ID('test')) AS [object_name] ,
    ix.[name] AS index_name ,
    ixu.user_seeks + ixu.user_scans + ixu.user_lookups AS user_reads,
    ixu.user_updates AS user_writes
FROM sys.dm_db_index_usage_stats ixu
INNER JOIN test.sys.indexes ix ON
    ixu.[object_id] = ix.[object_id] AND
    ixu.index_id = ix.index_id
WHERE ixu.database_id = DB_ID('test')
ORDER BY user_reads DESC
```

This is for a database called *test*. It will only show the indexes being used.

An index gets fragmented when inserts, updates and deletes occur. The function
`sys.dm_db_index_physical_stats` is used to determine the health of the indexes.

- When the fragmentation of an index is between 15% and 30%, it should be reorganized.
- When the fragmentation of an index is larger than 30%, it should be rebuilt.

```sql
SELECT * FROM sys.dm_db_index_physical_stats(
      DB_ID(N'test')
    , OBJECT_ID(N'test.dbo.customers')
    , NULL
    , NULL
    , 'Detailed'
)
```

This is for a database called *test* and a table called *dbo.customers*.

**Identify missing indexes:**

The following views can be used to identify missing indexes:

* **sys.dm_db_missing_index_details**: find columns used for equality and inequality predicates.
* **sys.dm_db_missing_index_groups**: an intermediary between dm_db_missing_index_details and
  dm_db_missing_index_group_stats.
* **sys.dm_db_missing_index_group_stats**: find groups of missing indexes.

<a name="consolidate_overlapping_indexes"></a>

#### Consolidate overlapping indexes

When we find overlapping two indexes it might be a good thing to drop one of the indexes, so
maintenance tasks run faster and less storage is needed.

---

<br/><br/><br/>

<a name="analyze_and_troubleshoot_query_plans"></a>

# Analyze and troubleshoot query plans

### Syllabus

*Capture query plans using extended events and traces, identify poorly performing query plan
operators, create efficient query plans using Query Store, compare estimated and actual query
plans and related metadata, configure Azure SQL Database Performance Insight*

<a name="capture_query_plans_using_extended_events_and_traces"></a>

#### Capture query plans using extended events and traces

Extended Events, SQL Trace and SQL Server Profiler are three methods to capture and monitor
execution plans.

Extended Events that can capture query plans:

* **query_pre_execution_showplan:** captures the estimated query plan without executing the query.
* **query_post_execution_showplan:** captures the actual query plan after execution.

Tracing:

* SQL Trace: deprecated server-side tracing.
* SQL Server Profiler: client-side tracing.

* **sp_trace_create**: Creates a trace definition. Will return a handle to the new trace. A filename
  is given to specify where the trace should be stored.
* **sp_trace_setevent**: Adds or removes an event or event column to a trace.
* **sp_trace_setfilter**: Applies a filter to a trace.
* **sp_trace_setstatus**: Modifies the current state of the specified trace.

Flow:

* Create a trace with `sp_trace_create`.
* Add the events to filter for with `sp_trace_setevent`. Has to be called for each column to trace.
* Add filters with `sp_trace_setfilter`. E.g. filter out databases that we are not interested in.
* Start the trace with `sp_trace_setstatus` (1).
* Read the results with:

  ```sql
  SELECT *
  FROM sys.fn_trace_getinfo(0)
  WHERE value = 'C:\trace_file.trc';
  ```
* Stop the trace with `sp_trace_setstatus` (0).
* Close and delete the trace with `sp_trace_setstatus` (2).

To see all events that can be traced:

```sql
SELECT
    e.trace_event_id AS EventID,
    e.name AS EventName,
    c.name AS CategoryName
FROM sys.trace_events e
    INNER JOIN sys.trace_categories c ON e.category_id = c.category_id
ORDER BY e.trace_event_id
```

To see all running traces:

```sql
SELECT * FROM sys.fn_trace_getinfo(0)
```

<a name="identify_poorly_performing_query_plan_operators"></a>

#### Identify poorly performing query plan operators

The following conditions can affect query performance:

* **Query plan optimization:** In the query plan, right click on SELECT and choose Properties.
  *Reason For Early Termination Of Statement Optimization* should be *Good Enough Plan Found*.
  If it's *Timeout*, the query has to be tuned. Otherwise, continue with the next steps.

* **Operators:** Some operators require a lot of memory, e.g. SORT.

* **Arrow width:** The width of the arrows between the operators shows how many rows that are
  being used by that operation. Analyzing arrow widths in the execution plan can help in
  identifying bottle necks etc.

* **Operator cost:** All the operators have a cost that is relative to the total cost (percentage).
  The operators with high cost should be taken a look at.

* **Warnings:** The optimizer will give warnings when the query performance suffers.

Here is a list of operators that can be found in the execution plan:

* **Table Scan operator:**

  SQL Server reads the heap row by row. This operation can be slow for large tables.
  Consider adding a clustered index.

* **Clustered Index Scan operator:**

  SQL Server must read all the data in a table. Could be because there are no advantages of using
  the index. Index scan is not necessarly a bad operation and it's better than table scans. Adding
  more filters (with `WHERE`) can make this operation a seek, which is faster.

* **Index Seek (NonClustered) and Key Lookup (Clustered) operator:**

  Index Seek (NonClustered) can find rows in the index rather than read all the rows. It's a much better
  operator to see than table scan and clustered index scan.

  If the index is not a covering index it will also include a Key Lookup (Clustered) operator, which
  adds a small overhead to performance. When Key Lookup (Clustered) is encountered we can consider
  creating a covering index by adding the necessary columns to the index key or as included columns.

* **Sort operator:**

  The Sort operator can be introduced when using `ORDER BY` in a query, when the column used in the
  `ORDER BY` is not used in the clustered index. This can increase the cost of the query.

* **Hash Match (Aggregate) operator:**

  This operator is introduced when using aggregates in a query. The Hash Match (Aggregate) operator
  can be expensive. Reducing the number of rows that is passed to the operator can increase performance.

  Another thing that can help is to create an indexed view that pre-aggregates the rows.

* **Hash Match (Inner Join) operator:**

  Hash Match (Inner Join) is used by SQL Server when it places data in temporary hash tables, so that it
  can match rows in different data sets and produce a single result set.

  When both data sets in the join are large this will cause performance issues. Hash Match (Inner Join)
  is also a blocking operator, which means the data has to be gathered completely from each set before
  the join is made.

  To improve the query we can add or revise indexes, add `WHERE` filters or make better `WHERE` filters.
  Hash Match (Inner Join) can be replaced with Nested Loop (Inner Join) by making these improvements.
  Nested Loop (Inner Join) can in many circumstances be faster than Hash Match (Inner Loop) if it uses
  indexes.

<a name="create_efficient_query_plans_using_query_store"></a>

#### Create efficient query plans using Query Store

[Official documentation][microsoft-query-store]

The Query Store is used to monitor performance. It automatically captures information about query plans
and runtime execution statistics.

Query Store is disabled by default in ordinary SQL Server, but enabled by default in Azure SQL Server.

To enable with SSMS: Right click on the database in Object Explorer --> Properties --> Query Store -->
Operation Mode Requested = Read Write.

To enable with T-SQL:

```sql
ALTER DATABASE TestDb
  SET QUERY_STORE = ON
  (
      OPERATION_MODE = READ_WRITE
    , CLEANUP_POLICY = ( STALE_QUERY_THRESHOLD_DAYS = 30 )
    , DATA_FLUSH_INTERVAL_SECONDS = 3000
    , MAX_STORAGE_SIZE_MB = 500
    , INTERVAL_LENGTH_MINUTES = 50
  )
```

To purge data from the query store:

```sql
ALTER DATABASE TestDb
SET QUERY_STORE CLEAR ALL
```

The following views can be used to monitor the query store:

* `sys.query_store_plan:` general query plan information.
* `sys.query_store_query:` aggregated runtime execution statistics for a query.
* `sys.query_store_query_text:` the text of the executed query.
* `sys.query_store_runtime_stats:` runtime execution statistics of a query.
* `sys.query_store_runtime_stats_interval:` start and endtime for when SQL Server collects runtime execution
  statistics.

Example of finding top 10 query that requires most logical reads:

```sql
SELECT TOP 10
    qt.query_sql_text,
    CAST(query_plan AS XML) AS QueryPlan,
    rs.avg_logical_io_reads
FROM sys.query_store_plan qp
    INNER JOIN sys.query_store_query q          ON qp.query_id = q.query_id
    INNER JOIN sys.query_store_query_text qt    ON q.query_text_id = qt.query_text_id
    INNER JOIN sys.query_store_runtime_stats rs ON qp.plan_id = rs.plan_id
ORDER BY rs.avg_logical_io_reads DESC
```

The following stored procedures can be used to manage the query store:

* `sp_query_store_flush_db:` flush the query store that is in memory to disk.
* `sp_query_store_force_plan:` force SQL Server to use a certain query plan for a query. 
* `sp_query_store_remove_plan:` remove a query plan from the store.
* `sp_query_store_remove_query:` remove a query from the store, with plan and statistics.
* `sp_query_store_reset_exec_stats:` reset statistics for a plan.
* `sp_query_store_unforce_plan:` no longer force a plan on a query.

There are views in SSMS that can be used to find time-consuming queries, etc.

<a name="compare_estimated_and_actual_query_plans_and_related_metadata"></a>

#### Compare estimated and actual query plans and related metadata

<a name="configure_azure_sql_database_performance_insight"></a>

#### Configure Azure SQL Database Performance Insight

[Official documentation][microsoft-azure-sql-database-query-performance]

Query Performance Insight is a feature in Azure SQL databases. It helps with finding long-running
queries, resource-consuming queries, etc. Query Store has to be enabled on the database.

It looks like this in Azure Portal:

![Resource consuming queries in Azure Portal]({{ "/assets/notes-on-70-762-Developing-SQL-Databases/resource-consuming-queries.png" | absolute_url }})

![Long running queries in Azure Portal]({{ "/assets/notes-on-70-762-Developing-SQL-Databases/long-running-queries.png" | absolute_url }})

We can find the executed SQL by clicking on a query.

---

<br/><br/><br/>

<a name="manage_performance_for_database_instances"></a>

# Manage performance for database instances

### Syllabus

*Manage database workload in SQL Server; design and implement Elastic Scale for Azure SQL Database;
select an appropriate service tier or edition; optimize database file and tempdb configuration;
optimize memory configuration; monitor and diagnose scheduling and wait statistics using dynamic
management objects; troubleshoot and analyze storage, IO, and cache issues; monitor Azure SQL
Database query plans*

<a name="manage_database_workload_in_sql_server"></a>

#### Manage database workload in SQL Server

<a name="design_and_implement_elastic_scale_for_azure_sql_database"></a>

#### Design and implement Elastic Scale for Azure SQL Database

Elastic Scale is a feature that makes it possible to scale database capacity to match the scalability
requirements of the applications that uses it. The database can be grown and shrinked with a technique
called sharding. Elastic Scale provides two thing: the *Elastic database client library* and the
*Split-Merge service*.

**Elastic database client library:**

To use standard sharding patterns we have to use the Elastic database client library. It has the 
following features:

* Shard map management: directs connection requests to the correct shard.
* Data-dependent routing: automatically assign a connection to the correct shard.
* Multishard quering: process queries in parallel across separate shards and then combine the results.
* Shard elasticity: allocate more resources as necessary and shrink database to normal size when the
  extra resources are no longer required.

**Split-Merge service:**

The Split-Merge service can be used to add or remove databases from the shard set, depending on the
resources required. When a shard is added, the service will redistribute data to the new shard. When
the resource demand lowers the shards can be merged into fewer shards.

<a name="select_and_appropriate_service_tier_or_edition"></a>

#### Select an appropriate service tier or edition

The following editions of SQL Server 2016 are available:

* Express
* Web
* Standard
* Enterprise
* Developer
* Evaluation

**Express** is free, but has limited features. It's best suited for small websites and applications.
The maximum database size is 10 GB, maximum memory is 1 GB and supports 1 CPU or 4 cores. Express
has the following editions:

* LocalDB: a local embedded database
* Express: a simple version of SQL Server
* Express with Advanced Series: like Express, but with Full Text Search and Reporting Services
  capabilities

**Web** can use up to 64 GB of memory and supports 4 CPUs or 16 cores. Maximum database size is 524 PB.
It is intended for use in web hosting and lacks many features.

**Standard** can use up to 128 GB of memory and supports 4 CPUs or 24 cores. Maximum database size is
524 PB. This edition has most features, such as BI, high-availability features, dynamic data masking
etc.

**Enterprise** is the full-fledged version of SQL Server. It has no limits on memory or number of CPUs
or cores, other than the limits set by the operating system. Maximum database size is 524 PB. The
Enterprise edition has all available features.

**Developer** has the same features as the Enterprise edition, but cannot be used in a production
environment. It's intended to be used by developers, for testing, etc.

**Evaluation** is the free trial version. It is the Enterprise version, but only works for 180 days.

The following service tiers are available in Azure:

* Basic
* Standard
* Premium

The data below are taken from the exam book, which is from 2017. The 2019 numbers are in parentheses
if the values have changed.

**Basic** has a maximum database size of 2 GB and a performance level of 5 DTUs. This tier is suitable
for small applications with less demanding workloads.

**Standard** has a maximum database size of 250 GB (1 TB) and performance levels between 10 and 100 (3000)
DTUs. This is suitable when the database supports multiple applications or ordinary and large applications.

**Premium** has a maximum database size of 1 TB (4 TB) and performance levels between 125 and 4000 DTUs.
This is suitable for enterprise-level database requirements.

<a name="optimize_database_file_and_tempdp_configuration"></a>

#### Optimize database file and tempdb configuration

[Official documentation][microsoft-database-files-and-filegroups]

Optimizing the database file can increase the performance of read and write operations.

**Optimize database file:**

The following things can be done to optimize the database file:

**File placement:**

- Data and log files should be on separate physical disks. This is useful both for performance
  and redundancy reasons.
- The physical disk for the log file should have high write performance. However, this is less
  important if most of the operations are read operations.

**File groups and secondary data files:**

- To increase the parallelism of data access, we can spread files within a filegroup onto separate
  physical disks.
- "Put objects that compete heavily for space in different filegroups."
- Heavily used tables or indexes can be separated from lesser used tables or indexes by assigning
  them to different filegroups. These file groups are then placed on different physical disks.

**Partitioning:**

- Partitioning can be used to place a table across multiple filegroups. Each partition should be in
  its own filegroup to increase performance.

**Optimize tempdb configuration:**

Configuring tempdb properly is critical for performance.

The following steps can be taken to increase performance:

**SIMPLE recovery model:**

- This is the default recovery model in SQL Server.
- SQL Server reclaims log space automatically, which means the space required by the database is kept
  at a minimum.

**Autogrowth:**

- Autogrowth should be enabled by default.
- tempdb files automatically grow as necessary.

**File placement:**

- The tempdb data and log files should be placed on different physical disks than the main database files.
- The tempdb log file should be on a different physical drive than the data file.
- The tempdb data and log files should be on fast drives.
- Don't put tempdb files on the C drive (or main drive) to prevent the server from starting if the disk
  has run out of space.

**Files per core:**

- There should be a 1:1 ratio of tempdb data files to CPU cores.

**File size:**

- The default file size settings are too conservative for most implementations. The default settings are:
    * Initial size: 8 MB
    * Autogrowth: 64 MB
    
  Initial size can be set to 4096 MB and autogrowth of 512 MB.

<a name="optimize_memory_configuration"></a>

#### Optimize memory configuration

The memory configuration can be optimized to increase performance. SQL Server will deallocate memory
automatically according to the workload on the host computer and in the database engine. The following
settings can be adjusted to change the behavior of SQL Server:

**min server memory:**

- Is used to control the memory usage of SQL Server. Minimum server memory is the minimum amount of
  physical memory that SQL Server will try to keep committed. SQL Server will not release memory below
  this threshold.

**max server memory:**

- Is used to control the memory usage of SQL Server. SQL Server will not allocate more memory than this
  threshold.

**max worker threads:**

- Number of threads available for user operations.
- The default value is 0. This means SQL Server will automatically configure the number when the server starts.

**index create memory:**

- The maximum amount of memory that SQL Server initially allocates to index creation.
- SQL Server will allocate more memory if it's needed and there is enough memory available.
- This number can be increased if SQL Server experiences performance delays related to indexes.

**min memory per query:**

- The minimum amount of memory that is allocated to a query execution.
- SQL Server can use more memory than the minimum number, if enough memory is available.

<a name="monitor_and_diagnose_scheduling_and_wait_statistics_using_dynamic_management_objects"></a>

#### Monitor and diagnose scheduling and wait statistics using dynamic management objects

Wait statistics can be used to find which resource that's being a bottleneck on performance.
Wait statistics allows us to analyze the time a worker thread spends in various states before
it completes a request.

Wait statistics are found in the following DMVs:

* **sys.dm_os_wait_stats:**

  Information about completed waits on the instance level. We can use this to find the most
  frequently occuring waits.

  *Identify CPU issues:*
  
  - The signal wait time can be compared to the total wait tiem to determine the relative
    percentage of tiem that a thread has to wait for its turn to run on the CPU. If the value
    is high, it can indicate that the CPU is overwhelmed. The server either needs more CPU or
    CPU-intensive queries have to be tuned to use less CPU.
  - *SOS_SCHEDULER_YIELD* will occur more often if the CPU is under pressure.

  *Identify IO issues:*
  
  - There can be IO issues if there are many waits with "IO" in the name.
  - Two wait types that often occur when there are IO issues are: *ASYNC_IO_COMPLETION* and
    *IO_COMPLETION*. Physical disk performance counters should be used to confirm this.
    Adding indexes might help with reducing IO contention.
  - *PAGEIOLATCH* waits might be shown when threads are waiting for latches to release after
    writing data page in memory to disk.
  - *WRITELOG* waits might be shown when the log management system is waiting to flush to disk.
  
  *Identify memory pressure:*
  
  - *PAGEIOLATCH* waits might also idicate memory pressure. It appears when SQL Server doesn't
    have enough free memory for the buffer pool. The *Page Life Expectancy* performance counter
    should be checked to see if it's dropping compared to a baseline value.
  - *RESOURCE_SEMAPHORE* waits is an indicator of memory pressure. It occures when a query
    requests more memory than is currently available. There are DMVs that can be used to find
    memory-intensive queries. Their query plans should be reviewed.

* **sys.dm_exec_session_wait_stats:**

  Information about waits on the session level. Similar to sys.dm_os_wait_stats, but contains a
  column for session id. New in SQL Server 2016.

* **sys.dm_os_waiting_tasks:**

  Information about requests on the waiter list. To find performance bottlenecks we can try to
  find tasks that have waited too long.

<a name="troubleshoot_and_analuze_storage_io_and_cache_issues"></a>

#### Troubleshoot and analyze storage, IO, and cache issues

**Storage and IO issues:**

Storage and IO issues can occur when the harddisk is slow or when the RAID is not configured
correctly. The following DMVs can be used to analyze storage and IO issues:

* **sys.dm_os_wait_stats:** seethe  section above.

* **sys.dm_io_virtual_file_stats:**
* **sys.master_files:** these two are used together to get metrics about data and log files. It
  will help us find the busiest files and provides information about IO stalls.

* **sys.dm_os_performance_counters:** performance-counter information.

    - **SQLServer:Buffer Manager: Page lookups/sec:** Average request per second at which SQL Server
      finds a page in the buffer pool. This value should be lower than
      SQLServer:SQL Statistics: Batch Requests/sec multiplied by 100.
      
    - **SQLServer:Buffer Manager: Page reads/sec:** Average rate at which SQL Server reads from disk.
      This value should be lower than the hardware specifications for the IO subsystem's read operations.
    
    - **SQLServer:Buffer Manager: Page writes/sec:** Average rate at which SQL Server writes to disk.
      This value should be lower than the hardware specifications for the IO subsystem's write operations.

   If the counters are too high we can alleviate the issue by adding new indexes, improve
   existing indexes, normalize tables or partition tables. Replacing hardware with faster hardware
   can also help

**Cache issues:**

Cache bottlenecks can occur when SQL Server does not have enough memory to manage.

The following DMVs can be used to analyze caching issues:

* **sys.dm_os_memory_cache_counters:** view the current state of the cache.
* **sys.dm_os_sys_memory:** view resource usage information for the server.
* **sys.dm_os_memory_clerks:** view usage information by memory clerk processes.

The following performance counters are also interesting:

* **SQLServer:Buffer Manager: Free List Stalls/Sec:** Number of requests per second that SQL Server
  waits for a free page in the buffer cache. If this value is greater than zero on a frequent basis,
  the server is experiencing memory pressure.
  
* **SQLServer:Buffer Manager: Lazy Writes/Sec:** Number of times per second that SQL Server flushes
  pages to disk. If this number is rising over time, and Free List Stalls/Sec is also greater than
  zero, you likely need more memory on the server.

* **SQLServer:Memory Manager: Memory Grants Outstanding:** Number of processes that have acquired a
  memory grant successfully. A low value might signify memory pressure.

* **SQLServer:Memory Manager: Memory Grants Pending:** Number of processes that are waiting for a
  memory grant. If this value is greater than zero, consider turning queries or adding memory to the
  server.

<a name="monitor_azure_sql_database_query_plans"></a>

#### Monitor Azure SQL Database query plans

The following methods can be used to monitor Azure SQL Database query plans:

* **SQL statements:** `SET SHOWPLAN_*` can be used to see query plans. The buttons in the toolbar
  in SSMS can do the same.
  
* **Extended events:** Extended events can be used to capture query plans. The syntax is slightly
  different from SQL Server. To write to file we have to use an Azure Storage container. 
  
* **Query Store:** The Query Store is enabled by default in Azure SQL databases. We can either
  use the Query Store views or the Query Store DMVs.
  
SQL Trace cannot be used in Azure SQL Database.

---

<br/><br/><br/>

<a name="monitor_and_trace_sql_server_baseline_performance_metrics"></a>

# Monitor and trace SQL Server baseline performance metrics

### Syllabus

*Monitor operating system and SQL Server performance metrics; compare baseline metrics to observed
metrics while troubleshooting performance issues; identify differences between performance
monitoring and logging tools, such as perfmon and dynamic management objects; monitor Azure SQL
Database performance; determine best practice use cases for extended events; distinguish between
Extended Events targets; compare the impact of Extended Events and SQL Trace; define differences
between Extended Events Packages, Targets, Actions, and Sessions*

<a name="monitor_os_and_sql_server_performance_metrics"></a>

#### Monitor operating system and SQL Server performance metrics

<a name="compare_baseline_metrics_to_observed_metrics_while_troubleshooting_performance_issues"></a>

#### Compare baseline metrics to observed metrics while troubleshooting performance issues

<a name="identify_differences_between_performance_monitoring_and_logging_tools"></a>

#### Identify differences between performance monitoring and logging tools, such as perfmon and dynamic management objects

<a name="monitor_azure_sql_database_performance"></a>

#### Monitor Azure SQL Database performance

<a name="determine_best_practice_use_cases_for_extended_events"></a>

#### Determine best practice use cases for extended events

<a name="distinguish_between_extended_event_targets"></a>

#### Distinguish between Extended Events targets

<a name="compare_the_impact_of_extended_events_and_sql_trace"></a>

#### Compare the impact of Extended Events and SQL Trace

<a name="define_differences_between_extended_events_packages_targets_actions_and_sessions"></a>

#### Define differences between Extended Events Packages, Targets, Actions, and Sessions


[microsoft-mcsa-sql-2016-database-development]: https://www.microsoft.com/en-us/learning/mcsa-sql2016-database-development-certification.aspx
[microsoft-70-762-curriculum]: https://www.microsoft.com/en-us/learning/exam-70-762.aspx
[microsoft-dynamic-data-masking]: https://docs.microsoft.com/en-us/sql/relational-databases/security/dynamic-data-masking
[microsoft-ddl-triggers]: https://docs.microsoft.com/en-us/sql/relational-databases/triggers/ddl-triggers
[microsoft-dml-triggers]: https://docs.microsoft.com/en-us/sql/relational-databases/triggers/dml-triggers
[microsoft-logon-triggers]: https://docs.microsoft.com/en-us/sql/relational-databases/triggers/logon-triggers
[microsoft-indexes]: https://docs.microsoft.com/en-us/sql/relational-databases/indexes/indexes
[microsoft-index-design-guide]: https://docs.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide
[microsoft-indexes-with-included-columns]: https://docs.microsoft.com/en-us/sql/relational-databases/indexes/create-indexes-with-included-columns
[microsoft-locking-in-the-database-engine]: https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms190615(v=sql.105)
[microsoft-lock-granularity]: https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms189849%28v%3dsql.105%29
[microsoft-lock-modes]: https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms175519%28v%3dsql.105%29
[microsoft-lock-escalation]: https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms184286(v=sql.105)
[microsoft-deadlock-trace-flags]: https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms178104(v=sql.105)]
[microsoft-query-store]: https://docs.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store
[microsoft-azure-sql-database-query-performance]: https://docs.microsoft.com/en-us/azure/sql-database/sql-database-query-performance
[microsoft-update-statistics]: https://docs.microsoft.com/en-us/sql/t-sql/statements/update-statistics-transact-sql
[microsoft-database-files-and-filegroups]: https://docs.microsoft.com/en-us/sql/relational-databases/databases/database-files-and-filegroups
[amazon-developing-sql-databases]: https://www.amazon.com/Exam-Ref-70-762-Developing-Databases/dp/1509304916
[erland-sommerskog-error-handling]: http://www.sommarskog.se/error_handling/Part1.html
[red-gate-covering-index]: https://www.red-gate.com/simple-talk/sql/learn-sql-server/using-covering-indexes-to-improve-query-performance/
[red-gate-columnstore-index]: https://www.red-gate.com/simple-talk/sql/sql-development/what-are-columnstore-indexes/
[stackoverflow-what-are-row-page-and-table-locks]: https://stackoverflow.com/questions/9784172/what-are-row-page-and-table-locks-and-when-they-are-acquired
[stackexchange-dba-what-is-lock-escalation]: https://dba.stackexchange.com/questions/12864/what-is-lock-escalation
[sqlteam-introduction-to-locking-in-sql-server]: https://www.sqlteam.com/articles/introduction-to-locking-in-sql-server
[github-70-761-proper-data-types-for-elements-and-columns]: https://mika-s.github.io/sql/certification/70-761/2019/05/27/notes-on-70-761-Querying-Data-with-Transact-SQL.html#proper_data_types_for_elements_and_columns
[github-70-761-views]: https://mika-s.github.io/sql/certification/70-761/2019/05/27/notes-on-70-761-Querying-Data-with-Transact-SQL.html#views
[github-70-761-indexed-views]: https://mika-s.github.io/sql/certification/70-761/2019/05/27/notes-on-70-761-Querying-Data-with-Transact-SQL.html#indexed_views
[github-70-761-stored-procedures]: https://mika-s.github.io/sql/certification/70-761/2019/05/27/notes-on-70-761-Querying-Data-with-Transact-SQL.html#stored_procedures
[github-70-761-triggers]: https://mika-s.github.io/sql/certification/70-761/2019/05/27/notes-on-70-761-Querying-Data-with-Transact-SQL.html#triggers
[github-70-761-tvf]: https://mika-s.github.io/sql/certification/70-761/2019/05/27/notes-on-70-761-Querying-Data-with-Transact-SQL.html#table_valued_function
[github-70-761-deterministic-vs-nondeterministic]: https://mika-s.github.io/sql/certification/70-761/2019/05/27/notes-on-70-761-Querying-Data-with-Transact-SQL.html#differences_deterministic_nondeterministic
