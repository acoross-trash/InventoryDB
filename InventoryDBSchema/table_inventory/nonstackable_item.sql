CREATE TABLE [dbo].[nonstackable_item]
(
	[dbid] BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[inventory_id] BIGINT NOT NULL,
	[class_id] BIGINT NOT NULL
)
