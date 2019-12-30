
Tabledefinition

The first query part will give you a good overview of queries to get the table as well as the partition information out of your PDW.

Tabletype

The Most common question is probably about the Table Distribution. Is it either REPLICATE or HASH? With this simple query you can extract the information.

SELECT
 
a.name AS [table]
 
, b.distribution_policy_desc AS [type] FROM sys.tables a
 
JOIN sys.pdw_table_distribution_properties b ON a.object_id = b.object_id 
Distributioncolumn

An easy way to figure out the distribution columns oft he tables is the following statement which gives you all the information.

SELECT a.name AS [table]
 
, c.name AS [column]
 
, b.name AS [datatype] FROM sys.pdw_column_distribution_properties d INNER JOIN sys.columns c ON c.object_id = d.object_id INNER JOIN sys.tables a ON a.object_id = d.object_id LEFT OUTER JOIN sys.types b on c.user_type_id = b.user_type_id WHERE d.distribution_ordinal = 1 AND c.column_id = d.column_id
Partition column

The partition column can be shown with this query. It shows a simple overview oft he table as well as the column.

SELECT
 
t.name AS [table]
 
, c.name AS [column]
 
FROM sys.tables AS t JOIN sys.indexes AS i ON t.object_id = i.object_id JOIN sys.columns AS c ON t.object_id = c.object_id JOIN sys.partition_schemes AS ps ON ps.data_space_id = i.data_space_id JOIN sys.index_columns AS ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.partition_ordinal > 0 WHERE i.type <= 1 AND c.column_id = ic.column_id
Partitiondetails

Now it gets a little bit more into detail on how the data is put on each partition, as well and the distribution on each partition and the boundary values Partitiondefinition

LEFT CREATE TABLE myTable ( id int NOT NULL ,lastName varchar(20) ) WITH ( PARTITION ( id RANGE LEFT FOR VALUES (10, 20, 30, 40 ))) -       Partition 1:      [id]             <=    10 -       Partition 2:      10              <       [id]    <= 20 -       Partition 3:      20              <       [id]    <= 30 -       Partition 4:      30              <       [id]    <= 40 -       Partition 5:      40              <       [id]   Partitiondefinition RIGHT CREATE TABLE myTable ( id int NOT NULL ,lastName varchar(20) ) WITH ( PARTITION ( id RANGE RIGHT FOR VALUES (10, 20, 30, 40 ))) -       Partition 1:      [id]             <       10 -       Partition 2:      10              <=    [id]    < 20 -       Partition 3:      20              <=    [id]    < 30 -       Partition 4:      30              <=    [id]    < 40 -       Partition 5:      40              <=    [id]   Partitiondistribution and boundarys
SELECT
 
t.name AS [table]
 
, p.partition_number
 
, f.type_desc as [function]
 
, CASE f.boundary_value_on_right
 
WHEN 1 THEN 'RIGHT'
 
ELSE 'LEFT'
 
END as [range]
 
, r.boundary_id
 
, r.value AS [boundary_value]
 
FROM sys.tables AS t JOIN sys.indexes AS i ON t.object_id = i.object_id JOIN sys.partitions AS p ON i.object_id = p.object_id AND i.index_id = p.index_id JOIN  sys.partition_schemes AS s ON i.data_space_id = s.data_space_id JOIN sys.partition_functions AS f ON s.function_id = f.function_id LEFT JOIN sys.partition_range_values AS r ON f.function_id = r.function_id and r.boundary_id = p.partition_number WHERE  i.type <= 1 ORDER BY p.partition_number
Monitoringqueries

The second part will include some useful PDW Monitoring Queries.  

Current Queries

The most common question is probably about the queries on your system. A good overview will give you the following query.

select 
 
Q.request_id     as 'request_id'
 
,Q.session_id     as 'session_id' ,S.login_name     as 'user_name' ,S.status         as 'user_status' ,ISNULL(S.app_name,'') as 'user_app' ,Q.submit_time         as 'request_start' ,Q.status              as 'request_status' ,ISNULL(Q.end_time,'2999-12-31 23:59:59')      as 'request_end' ,RIGHT(CONVERT(nvarchar(23)
 
,DATEADD(ms ,Q.total_elapsed_time,'1990-01-01 00:00:00'),121),12) as 'elapsed' ,ISNULL(Q.&SQUARE_BRACKETS_OPEN;label],'') as 'label' ,Q.command             as 'query' ,ISNULL(Q.error_id,'') as 'error_id' ,SUBSTRING(ISNULL(E.details,''),2 ,50) as 'error_desc' ,S.client_id           as 'user_address' from sys.dm_pdw_exec_requests       AS Q inner join sys.dm_pdw_exec_sessions AS S on S.session_id = Q.session_id left join sys.dm_pdw_errors         AS E on Q.error_id=E.error_id and Q.session_id=E.session_id WHERE LEFT(S.client_id, 9) <> '127.0.0.1' AND ISNULL(Q.&SQUARE_BRACKETS_OPEN;label],'') <> 'QUERY-MONITOR' ORDER BY CASE UPPER(Q.status) WHEN 'RUNNING' THEN 0 WHEN 'SUSPENDED' THEN 1 ELSE 2 END ASC ,ISNULL(Q.end_time, SYSDATETIME()) DESC ,ISNULL(Q.submit_time, SYSDATETIME()) DESC OPTION( LABEL='QUERY-MONITOR' )
Current Loads via DWLoader

Another common question is the question about the ongoing loads. So far we checked the queries executing, but what about the loads committed to the appliance?

select
 
run_id
 
,submit_time
 
,start_time
 
,end_time
 
,total_elapsed_time
 
,table_name
 
,status
 
,progress
 
,rows_processed
 
,rows_rejected ,rows_inserted
 
from sys.pdw_loader_backup_runs where operation_type = 'LOAD' order by 1 desc
Performancecounters

An overview about the current performzance can indicate you the following query. It shows you an overview about included nodes.

SELECT  
 
PC.counter_category    as 'type'
 
,PC.counter_name       as 'counter' ,PC.instance_name      as 'instance' ,n.name                as 'node' ,PC.counter_value      as 'value' FROM sys.dm_pdw_os_performance_counters as PC JOIN sys.dm_pdw_nodes as N on N.pdw_node_id = PC.pdw_node_id WHERE DATEDIFF(second, PC.last_update_time, SYSDATETIME()) < 10 order by 1 ,2 ,3 ,4
