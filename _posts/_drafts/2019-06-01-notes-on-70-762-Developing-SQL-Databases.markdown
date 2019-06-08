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
  - [Design and implement indexes](#design_and_implement_indexes)
  - [Design and implement views](#design_and_implement_views)
  - [Implement columnstore indexes](#implement_columnstore_indexes)
- [Implement programmability objects](#implement_programmability_objects)
  - [Ensure data integrity with constraints](#ensure_data_integrity_with_constraints)
  - [Create stored procedures](#create_stored_procedures)
  - [Create triggers and user-defined functions](#create_triggers_and_user_defined_functions)
- [Manage database concurrency](#manage_database_concurrency)
  - [Implement transactions](#implement_transactions)
  - [Manage isolation levels](#manage_isolation_levels)
  - [Optimize concurrency and locking behavior](#optimize_concurrency_and_locking_behavior)
  - [Implement memory-optimized tables and native stored procedures](#implement_memory_optimized_tables_and_native_stored_procedures)
- [Optimize database objects and SQL infrastructure](#optimize_database_objects_and_sql_infrastructure)
  - [Optimize statistics and indexes](#optimize_statistics_and_indexes)
  - [Analyze and troubleshoot query plans](#analyze_and_troubleshoot_query_plans)
  - [Manage performance for database instances](#manage_performance_for_database_instances)
  - [Monitor and trace SQL Server baseline performance metrics](#monitor_and_trace_sql_server_baseline_performance_metrics)

---

<br/><br/><br/>

<a name="design_and_implement_database_objects"></a>

## Design and implement database objects (25–30%)

<a name="design_and_implement_a_relational_database_schema"></a>

# Design and implement a relational database schema

### Syllabus

*Design tables and schemas based on business requirements, improve the design of tables by using
normalization, write table create statements, determine the most efficient data types to use*

---

<br/><br/><br/>

<a name="design_and_implement_indexes"></a>

# Design and implement indexes

### Syllabus

*Design new indexes based on provided tables, queries, or plans; distinguish between indexed columns
and included columns; implement clustered index columns by using best practices; recommend new
indexes based on query plans*

---

<br/><br/><br/>

<a name="design_and_implement_views"></a>

# Design and implement views

### Syllabus

*Design a view structure to select data based on user or business requirements, identify the steps
necessary to design an updateable view, implement partitioned views, implement indexed views*

---

<br/><br/><br/>

<a name="implement_columnstore_indexes"></a>

# Implement columnstore indexes

### Syllabus

*Determine use cases that support the use of columnstore indexes, identify proper usage of clustered
and non-clustered columnstore indexes, design standard non-clustered indexes in conjunction with
clustered columnstore indexes, implement columnstore index maintenance*

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

---

<br/><br/><br/>

<a name="create_stored_procedures"></a>

# Create stored procedures

### Syllabus

*Design stored procedure components and structure based on business requirements, implement input
and output parameters, implement table-valued parameters, implement return codes, streamline
existing stored procedure logic, implement error handling and transaction control logic within
stored procedures*

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

---

<br/><br/><br/>

<a name="manage_database_concurrency"></a>

## Manage database concurrency (25–30%)

<a name="implement_transactions"></a>

# Implement transactions

### Syllabus

*Identify DML statement results based on transaction behavior, recognize differences between and
identify usage of explicit and implicit transactions, implement savepoints within transactions,
determine the role of transactions in high-concurrency databases*

---

<br/><br/><br/>

<a name="manage_isolation_levels"></a>

# Manage isolation levels

### Syllabus

*Identify differences between Read Uncommitted, Read Committed, Repeatable Read, Serializable, and
Snapshot isolation levels; define results of concurrent queries based on isolation level; identify
the resource and performance impact of given isolation levels*

---

<br/><br/><br/>

<a name="optimize_concurrency_and_locking_behavior"></a>

# Optimize concurrency and locking behavior

### Syllabus

*Troubleshoot locking issues, identify lock escalation behaviors, capture and analyze deadlock
graphs, identify ways to remediate deadlocks*

---

<br/><br/><br/>

<a name="implement_memory_optimized_tables_and_native_stored_procedures"></a>

# Implement memory-optimized tables and native stored procedures

### Syllabus

*Define use cases for memory-optimized tables versus traditional disk-based tables, optimize
performance of in-memory tables by changing durability settings, determine best case usage scenarios
for natively compiled stored procedures, enable collection of execution statistics for natively
compiled stored procedures*

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

---

<br/><br/><br/>

<a name="analyze_and_troubleshoot_query_plans"></a>

# Analyze and troubleshoot query plans

### Syllabus

*Capture query plans using extended events and traces, identify poorly performing query plan
operators, create efficient query plans using Query Store, compare estimated and actual query
plans and related metadata, configure Azure SQL Database Performance Insight*

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


[microsoft-mcsa-sql-2016-database-development]: https://www.microsoft.com/en-us/learning/mcsa-sql2016-database-development-certification.aspx
[microsoft-70-762-curriculum]: https://www.microsoft.com/en-us/learning/exam-70-762.aspx
[amazon-developing-sql-databases]: https://www.amazon.com/Exam-Ref-70-762-Developing-Databases/dp/1509304916
[erland-sommerskog-error-handling]: http://www.sommarskog.se/error_handling/Part1.html
