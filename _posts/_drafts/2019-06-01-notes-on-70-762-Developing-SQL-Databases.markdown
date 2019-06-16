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

<a name="write_table_create_statements"></a>

#### Write table create statements

<a name="determine_the_most_efficient_data_types_to_use"></a>

#### Determine the most efficient data types to use

---

<br/><br/><br/>

<a name="design_and_implement_indexes"></a>

# Design and implement indexes

### Syllabus

*Design new indexes based on provided tables, queries, or plans; distinguish between indexed columns
and included columns; implement clustered index columns by using best practices; recommend new
indexes based on query plans*

<a name="design_new_indexes"></a>

#### Design new indexes based on provided tables, queries, or plans

<a name="distinguish_between_indexed_columns_and_included_columns"></a>

#### Distinguish between indexed columns and included columns

<a name="implement_clustered_index_columns"></a>

#### Implement clustered index columns by using best practices

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

<a name="identify_steps_to_design_updatable_view"></a>

#### Identify the steps necessary to design an updateable view

<a name="implement_partioned_views"></a>

#### Implement partitioned views

<a name="implement_indexed_views"></a>

#### Implement indexed views

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

<a name="write_tsql_statements_to_add_constraints"></a>

#### Write Transact-SQL statements to add constraints to tables

<a name="identify_results_of_dml_statements_given_tables_and_constraints"></a>

#### Identify results of Data Manipulation Language (DML) statements given existing tables and constraints

<a name="identify_proper_usage_of_primary_key_constraints"></a>

#### Identify proper usage of PRIMARY KEY constraints

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

<a name="implement_input_and_output_parameters"></a>

#### Implement input and output parameters

<a name="implement_table_valued_parameters"></a>

#### Implement table-valued parameters

<a name="implement_return_codes"></a>

#### Implement return codes

<a name="streamline_existing_stored_procedure_logic"></a>

#### Streamline existing stored procedure logic

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

<a name="design_trigger_logic"></a>

#### Design trigger logic based on business requirements

<a name="determine_when_to_use_DML_triggers_ddl_triggers_logon_triggers"></a>

#### Determine when to use Data Manipulation Language (DML) triggers, Data Definition Language (DDL) triggers, or logon triggers

<a name="recognize_results_based_on_execution_of_after_or_instead_of_triggers"></a>

#### Recognize results based on execution of AFTER or INSTEAD OF triggers

<a name="design_scalar_valued_and_table_valued_functions"></a>

#### Design scalar-valued and table-valued user-defined functions based on business requirements

<a name="identify_differences_between_deterministic_and_non_deterministic_functions"></a>

#### Identify differences between deterministic and non-deterministic functions

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

<a name="define_results_of_concurrent_queries_based_on_isolation_level"></a>

#### Define results of concurrent queries based on isolation level

<a name="identify_the_resource_and_performance_impact_of_given_isolation_levels"></a>

#### Identify the resource and performance impact of given isolation levels

---

<br/><br/><br/>

<a name="optimize_concurrency_and_locking_behavior"></a>

# Optimize concurrency and locking behavior

### Syllabus

*Troubleshoot locking issues, identify lock escalation behaviors, capture and analyze deadlock
graphs, identify ways to remediate deadlocks*

<a name="troubleshoot_locking_issues"></a>

#### Troubleshoot locking issues

<a name="identify_lock_escalation_behaviors"></a>

#### Identify lock escalation behaviors

<a name="capture_and_analyze_deadlock_graphs"></a>

#### Capture and analyze deadlock graphs

<a name="identify_ways_to_remediate_deadlocks"></a>

#### Identify ways to remediate deadlocks

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

<a name="design_statistics_mainentance_tasks"></a>

#### Design statistics maintenance tasks

<a name="use_dynamic_management_objects_to_review_current_index_usage_and_identify_missing_indexes"></a>

#### Use dynamic management objects to review current index usage and identify missing indexes

<a name="consolidate_overlapping_indexes"></a>

#### Consolidate overlapping indexes

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

<a name="identify_poorly_performing_query_plan_operators"></a>

#### Identify poorly performing query plan operators

<a name="create_efficient_query_plans_using_query_store"></a>

#### Create efficient query plans using Query Store

<a name="compare_estimated_and_actual_query_plans_and_related_metadata"></a>

#### Compare estimated and actual query plans and related metadata

<a name="configure_azure_sql_database_performance_insight"></a>

#### Configure Azure SQL Database Performance Insight

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

<a name="select_and_appropriate_service_tier_or_edition"></a>

#### Select an appropriate service tier or edition

<a name="optimize_database_file_and_tempdp_configuration"></a>

#### Optimize database file and tempdb configuration

<a name="optimize_memory_configuration"></a>

#### Optimize memory configuration

<a name="monitor_and_diagnose_scheduling_and_wait_statistics_using_dynamic_management_objects"></a>

#### Monitor and diagnose scheduling and wait statistics using dynamic management objects

<a name="troubleshoot_and_analuze_storage_io_and_cache_issues"></a>

#### Troubleshoot and analyze storage, IO, and cache issues

<a name="monitor_azure_sql_database_query_plans"></a>

#### Monitor Azure SQL Database query plans

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
[amazon-developing-sql-databases]: https://www.amazon.com/Exam-Ref-70-762-Developing-Databases/dp/1509304916
[erland-sommerskog-error-handling]: http://www.sommarskog.se/error_handling/Part1.html
