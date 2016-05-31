CREATE PROCEDURE [dbo].[ManipulateItems]
	@StackableItemManip		[TStackableItemManip] READONLY,
	@NonStackableItemCreate	[TNonStackableItemCreate] READONLY,
	@NonStackableItemMove	[TNonStackableItemMove] READONLY
AS

DECLARE @tran VARCHAR(20) = 'manip_item_tran';

BEGIN TRANSACTION @tran
BEGIN TRY
	
	EXEC _ManipulateStackableItems @StackableItemManip;

	EXEC _ManipulateNonStackableItems @NonStackableItemCreate, @NonStackableItemMove;

END TRY
BEGIN CATCH
	PRINT error_message();
	ROLLBACK TRAN @tran
	RETURN -1;
END CATCH

COMMIT TRAN @tran
RETURN 0;
