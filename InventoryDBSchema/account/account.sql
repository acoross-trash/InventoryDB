CREATE TABLE [dbo].[account]
(
	[account_id] BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	[account_name] TAccountName NOT NULL
)
