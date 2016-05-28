CREATE PROCEDURE [dbo].[ManipulateItems]
	@StackableItemManip		[TStackableItemManip] READONLY,
	@NonStackableItemCreate	[TNonStackableItemCreate] READONLY,
	@NonStackableItemMove	[TNonStackableItemMove] READONLY
AS

DECLARE @tran VARCHAR(20) = 'manip_item_tran';

BEGIN TRANSACTION @tran
BEGIN TRY
	MERGE stackable_item si
	USING (
		SELECT inventory_id, class_id, SUM(diff_amount) AS diff_amount
		FROM @StackableItemManip
		GROUP BY inventory_id, class_id
	) manip
		ON si.inventory_id = manip.inventory_id AND si.class_id = manip.class_id
	WHEN MATCHED AND (si.amount + manip.diff_amount) = 0 THEN
		DELETE
	WHEN MATCHED THEN
		UPDATE SET amount = amount + manip.diff_amount
	WHEN NOT MATCHED THEN
		INSERT (inventory_id, class_id, amount) VALUES(manip.inventory_id, manip.class_id, manip.diff_amount)
	OUTPUT deleted.*, inserted.*
	;
END TRY
BEGIN CATCH
	PRINT error_message();
	ROLLBACK TRAN @tran
	RETURN -1;
END CATCH

BEGIN TRY
	INSERT INTO nonstackable_item (inventory_id, class_id)
		OUTPUT inserted.*
	SELECT * FROM @NonStackableItemCreate manip
	;
END TRY
BEGIN CATCH
	PRINT error_message();
	ROLLBACK TRAN @tran
	RETURN -3;
ENd CATCH

BEGIN TRY
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
END TRY
BEGIN CATCH
	PRINT error_message();
	ROLLBACK TRAN @tran
	RETURN -2;
ENd CATCH

COMMIT TRAN @tran
RETURN 0;
