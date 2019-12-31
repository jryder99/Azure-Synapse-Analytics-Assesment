SELECT sm.name [schema] ,
tb.name logical_table_name ,
dp.distribution_policy_desc,
SUM(rg.total_rows) total_rows
FROM   sys.schemas sm
INNER JOIN sys.tables tb ON sm.schema_id = tb.schema_id
INNER JOIN sys.pdw_table_mappings mp ON tb.object_id = mp.object_id
INNER JOIN sys.pdw_nodes_tables nt ON nt.name = mp.physical_name
INNER JOIN sys.dm_pdw_nodes_db_column_store_row_group_physical_stats rg
	ON rg.object_id = nt.object_id
	AND rg.pdw_node_id = nt.pdw_node_id
	AND rg.distribution_id = nt.distribution_id

left JOIN sys.pdw_table_distribution_properties DP
ON tb.object_id = dp.object_id
--WHERE 1 = 1
GROUP BY sm.name, tb.name,dp.distribution_policy_desc
ORDER BY SUM(rg.total_rows) DESC
