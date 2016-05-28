CREATE TYPE [dbo].[TStackableItemManip] AS TABLE
(
	inventory_id BIGINT NOT NULL,
	class_id BIGINT NOT NULL,
	diff_amount BIGINT NOT NULL
)
