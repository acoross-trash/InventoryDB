CREATE TYPE [dbo].[TNonStackableItemMove] AS TABLE
(
	item_dbid BIGINT NOT NULL,
	from_inventory_id BIGINT NOT NULL,
	to_inventory_id BIGINT -- remove, if null
)
