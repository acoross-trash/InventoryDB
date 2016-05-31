CREATE PROCEDURE [dbo].[_ManipulateStackableItems]
	@StackableItemManip		[TStackableItemManip] READONLY
AS
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
