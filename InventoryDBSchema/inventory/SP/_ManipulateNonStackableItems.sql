CREATE PROCEDURE [dbo].[_ManipulateNonStackableItems]
	@NonStackableItemCreate	[TNonStackableItemCreate] READONLY,
	@NonStackableItemMove	[TNonStackableItemMove] READONLY
AS
	INSERT INTO nonstackable_item (inventory_id, class_id)
		OUTPUT null, null, null, inserted.*
	SELECT * FROM @NonStackableItemCreate manip
	;

	MERGE nonstackable_item ni
	USING @NonStackableItemMove manip
		ON ni.dbid = manip.item_dbid AND ni.inventory_id = manip.from_inventory_id
	WHEN MATCHED AND manip.to_inventory_id IS NULL THEN
		DELETE
	WHEN MATCHED THEN
		UPDATE SET inventory_id = manip.to_inventory_id
	WHEN NOT MATCHED THEN
		INSERT (inventory_id, class_id) VALUES(manip.to_inventory_id, null)	-- crash!
	OUTPUT deleted.*, inserted.*
	;
