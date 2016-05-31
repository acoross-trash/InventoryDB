CREATE TABLE [dbo].[stackable_item]
(
	[dbid] BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[inventory_id] BIGINT NOT NULL,
	[class_id] BIGINT NOT NULL,
	[amount] BIGINT NOT NULL CHECK(amount >= 0)
)
GO
CREATE UNIQUE INDEX [IX_stackable_item] 
ON [dbo].[stackable_item](inventory_id, class_id)