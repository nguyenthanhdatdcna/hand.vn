-- =============================================
-- 1. Create database Group2Bank
-- =============================================
USE master
GO

-- Drop the database if it already exists
IF  EXISTS (
	SELECT name 
		FROM sys.databases 
		WHERE name = N'Group2Bank'
)
DROP DATABASE Group2Bank
GO

CREATE DATABASE Group2Bank
GO
-- =============================================
USE Group2Bank
GO

-- =============================================
-- 2. Create table Customer
-- =============================================
CREATE TABLE Customer
(
	CustID int IDENTITY(1,1) NOT NULL,
	Name nvarchar(100) NOT NULL,
	Phone varchar(50) NOT NULL,
	Email varchar(100) NOT NULL,
	Addr nvarchar(200) NOT NULL,
	CONSTRAINT PK_Customer PRIMARY KEY(CustID)
)
GO

-- =============================================
-- 3. Create table OverDraftLimit
-- =============================================
CREATE TABLE OverDraftLimit
(
	ODID int IDENTITY(1,1) NOT NULL,
	Value decimal NOT NULL,
	CONSTRAINT PK_OverDraftLimit PRIMARY KEY(ODID)
)
GO

-- =============================================
-- 4. Create table WithDrawLimit
-- =============================================
CREATE TABLE WithDrawLimit
(
	WDID int IDENTITY(1,1) NOT NULL,
	Value decimal NOT NULL,
	CONSTRAINT PK_WithDrawLimit PRIMARY KEY(WDID)
)
GO

-- =============================================
-- 5. Create table ATM
-- =============================================
CREATE TABLE ATM
(
	ATMID int IDENTITY(1,1) NOT NULL,
	Branch nvarchar(50) NOT NULL,
	Address nvarchar(100) NOT NULL,
	CONSTRAINT PK_ATM PRIMARY KEY(ATMID)
)
GO

-- =============================================
-- 6. Create table Money
-- =============================================
CREATE TABLE Money
(
	MoneyID int IDENTITY(1,1) NOT NULL,
	MoneyValue decimal NOT NULL,
	Address nvarchar(100) NOT NULL,
	CONSTRAINT PK_Money PRIMARY KEY(MoneyID)
)
GO

-- =============================================
-- 7. Create table LogType
-- =============================================
CREATE TABLE LogType
(
	LogTypeID int IDENTITY(1,1) NOT NULL,
	Description nvarchar(100) NOT NULL,
	CONSTRAINT PK_LogType PRIMARY KEY(LogTypeID)
)
GO

-- =============================================
-- 8. Create table Account
-- =============================================
CREATE TABLE Account
(
	AccountID int IDENTITY(1,1) NOT NULL,
	CustID int NOT NULL,
	AccountNo varchar(50) NOT NULL,
	ODID int NOT NULL,
	WDID int NOT NULL,
	Balance decimal,
	CONSTRAINT PK_Account PRIMARY KEY(AccountID),
	CONSTRAINT FK_Account_Customer FOREIGN KEY(CustID) REFERENCES dbo.Customer(CustID),
	CONSTRAINT FK_Account_OverDraftLimit FOREIGN KEY(ODID) REFERENCES dbo.OverDraftLimit(ODID),
	CONSTRAINT FK_Account_WithDrawLimit FOREIGN KEY(WDID) REFERENCES dbo.WithDrawLimit(WDID)
)
GO

-- =============================================
-- 9. Create table Card
-- =============================================
CREATE TABLE Card
(
	CardID int IDENTITY(1,1) NOT NULL,
	CardNo varchar(16) NOT NULL,
	Status varchar(30) NOT NULL,
	AccountID int NOT NULL,
	PIN char(6) NOT NULL,
	StartDate datetime NOT NULL,
	ExpiredDate datetime NOT NULL,
	Attempt int NOT NULL,
	CONSTRAINT PK_Card PRIMARY KEY(CardID),
	CONSTRAINT FK_Card_Account FOREIGN KEY(AccountID) REFERENCES dbo.Account(AccountID),
	CONSTRAINT CHK_ExpiredDate CHECK(ExpiredDate>StartDate),
	CONSTRAINT UNQ_CardNo UNIQUE(CardNo)
)
GO

-- =============================================
-- 10. Create table Stock
-- =============================================
CREATE TABLE Stock
(
	StockID int IDENTITY(1,1) NOT NULL,
	MoneyID int NOT NULL,
	ATMID int NOT NULL,
	Quantity int NOT NULL,
	CONSTRAINT PK_Stock PRIMARY KEY(StockID),
	CONSTRAINT FK_Stock_Money FOREIGN KEY(MoneyID) REFERENCES dbo.Money(MoneyID),
	CONSTRAINT FK_Stock_ATM FOREIGN KEY(ATMID) REFERENCES dbo.ATM(ATMID)
)
GO

-- =============================================
-- 11. Create table Log
-- =============================================
CREATE TABLE Logs
(
	LogID int IDENTITY(1,1) NOT NULL,
	LogTypeID int NOT NULL,
	ATMID int NOT NULL,
	CardID int NOT NULL,
	LogDate datetime NOT NULL DEFAULT GETDATE(),
	Amount decimal NOT NULL,
	Details varchar(100) NOT NULL,
	CONSTRAINT PK_Log PRIMARY KEY(LogID),
	CONSTRAINT FK_Log_LogType FOREIGN KEY(LogTypeID) REFERENCES dbo.LogType(LogTypeID),
	CONSTRAINT FK_Log_ATM FOREIGN KEY(ATMID) REFERENCES dbo.ATM(ATMID),
	CONSTRAINT FK_Log_Card FOREIGN KEY(CardID) REFERENCES dbo.Card(CardID)
)
GO

-- =============================================
-- 12. Create table Config
-- =============================================
CREATE TABLE Config
(
	ConfigID int IDENTITY(1,1) NOT NULL,
	DateModified datetime NOT NULL,
	MinWithDraw decimal NOT NULL,
	MaxWithDraw decimal NOT NULL,
	NumPerPage int NOT NULL,
	CONSTRAINT PK_Config PRIMARY KEY(ConfigID)
)
GO

-- =============================================
-- 13. Create store procedure usp_InsertAccount
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_InsertAccount
	@CustID int
    ,@AccountNo varchar(50)
    ,@ODID int
    ,@WDID int
    ,@Balance decimal(18,0)
AS
	BEGIN
		INSERT INTO [dbo].[Account]([CustID],[AccountNo],[ODID],[WDID],[Balance])
		VALUES(@CustID,@AccountNo,@ODID,@WDID,@Balance)
	END
GO
-- =============================================
-- 14. Create store procedure usp_UpdateAccount
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_UpdateAccount
	@CustID int
	,@AccountNo varchar(50)
	,@ODID int
	,@WDID int
	,@Balance decimal(18,0)
AS
	BEGIN
		UPDATE [dbo].[Account]
		SET [AccountNo] = @AccountNo,[ODID] = @ODID,[WDID] = @WDID,[Balance] = @Balance
		WHERE [CustID]  = @CustID
	END
GO
-- =============================================
-- 15. Create store procedure usp_DeleteAccount
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_DeleteAccount
	@CustID int
AS
	BEGIN
		DELETE FROM [dbo].[Account]
		WHERE [CustID] = @CustID
	END
GO
-- =============================================
-- 16. Create store procedure usp_SearchAccountByAccountID
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SearchAccountByAccountID
	@CustID int
AS
	BEGIN
		SELECT [AccountID],[CustID],[AccountNo],[ODID],[WDID],[Balance]
		FROM [dbo].[Account]
		WHERE [CustID] = @CustID
	END
GO
-- =============================================
-- 17. Create store procedure usp_InsertATM
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_InsertATM
	@Branch nvarchar(50)
    ,@Address nvarchar(100)
AS
	BEGIN
		INSERT INTO [dbo].[ATM]([Branch],[Address])
		VALUES (@Branch,@Address)
	END
GO
-- =============================================
-- 18. Create store procedure usp_UpdateATM
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_UpdateATM
	@ATMID int
	,@Branch nvarchar(50)
    ,@Address nvarchar(100)
AS
	BEGIN
		UPDATE [dbo].[ATM]
		SET [Branch]  = @Branch,[Address] = @Address
		WHERE [ATMID] = @ATMID
	END
GO
-- =============================================
-- 19. Create store procedure usp_DeleteATM
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_DeleteATM
	@ATMID int
AS
	BEGIN
		DELETE FROM [dbo].[ATM]
		WHERE [ATMID] = @ATMID
	END
GO
-- =============================================
-- 20. Create store procedure usp_SearchATMByATMID
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SearchATMByATMID
	@ATMID int
AS
	BEGIN
		SELECT [ATMID],[Branch],[Address]
		FROM [dbo].[ATM]
		WHERE [ATMID] = @ATMID
	END
GO
-- =============================================
-- 21. Create store procedure usp_InsertCard
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_InsertCard
	@CardNo varchar(16)
	,@Status varchar(30)
	,@AccountID int
	,@PIN varchar(6)
	,@StartDate datetime
	,@ExpiredDate datetime
	,@Attempt int
AS
	BEGIN
		INSERT INTO [dbo].[Card]([CardNo],[Status],[AccountID],[PIN],[StartDate],[ExpiredDate],[Attempt])
		VALUES(@CardNo,@Status,@AccountID,@PIN,@StartDate,@ExpiredDate,@Attempt)
	END
GO
-- =============================================
-- 22. Create store procedure usp_UpdateCard
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_UpdateCard
	@CardID int
	,@CardNo varchar(16)
	,@Status varchar(30)
	,@AccountID int
	,@PIN varchar(6)
	,@StartDate datetime
	,@ExpiredDate datetime
	,@Attempt int
AS
	BEGIN
		UPDATE [dbo].[Card]
		SET [CardNo]      = @CardNo
		   ,[Status]      = @Status
		   ,[AccountID]   = @AccountID
		   ,[PIN]         = @PIN
		   ,[StartDate]   = @StartDate
		   ,[ExpiredDate] = @ExpiredDate
		   ,[Attempt]     = @Attempt
		WHERE [CardID]    = @CardID
	END
GO
-- =============================================
-- 23. Create store procedure usp_DeleteCard
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_DeleteCard
	@CardID int
AS
	BEGIN
		DELETE FROM [dbo].[Card]
		WHERE [CardID] = @CardID
	END
GO
-- =============================================
-- 24. Create store procedure usp_SearchCardByCardID
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SearchCardByCardID
	@CardID int
AS
	BEGIN
		SELECT [CardID],[CardNo],[Status],[AccountID],[PIN],[StartDate],[ExpiredDate],[Attempt]
		FROM [dbo].[Card]
		WHERE [CardID] = @CardID
	END
GO
-- =============================================
-- 25. Create store procedure usp_ValidateCardNo
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_ValidateCardNo
	@CardNo varchar(16)
AS
	BEGIN
		SELECT [CardID],[CardNo],[Status],[AccountID],[PIN],[StartDate],[ExpiredDate],[Attempt]
		FROM [dbo].[Card]
		WHERE [CardNo] = @CardNo AND [StartDate] <= GETDATE() AND [ExpiredDate] >= GETDATE() AND [Status] = 'active'
	END
GO
-- =============================================
-- 26. Create store procedure usp_ValidatePin
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_ValidateCardPin
	@CardNo varchar(16),
	@PIN varchar(6)
AS
	BEGIN
		SELECT [CardID],[CardNo],[Status],[AccountID],[PIN],[StartDate],[ExpiredDate],[Attempt]
		FROM [dbo].[Card]
		WHERE [CardNo] = @CardNo AND [PIN] = @PIN
	END
GO
-- =============================================
-- 27. Create store procedure usp_SelectAttemptCard
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SelectAttemptCard
	@CardNo varchar(16)
AS
	BEGIN
		SELECT [Attempt]
		FROM [dbo].[Card]
		WHERE [CardNo] = @CardNo
	END
GO
-- =============================================
-- 28. Create store procedure usp_UpdateStatusCard
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateStatusCard]
	@CardNo varchar(16)
	,@Status varchar(30)
AS
	BEGIN
		UPDATE [dbo].[Card]
		SET [Status]      = @Status
		WHERE [CardNo]    = @CardNo
	END
GO
-- =============================================
-- 29. Create store procedure usp_InsertConfig
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_InsertConfig
	@DateModified datetime
	,@MinWithDraw decimal(18,0)
	,@MaxWithDraw decimal(18,0)
	,@NumPerPage int
AS
	BEGIN
		INSERT INTO [dbo].[Config]([DateModified],[MinWithDraw],[MaxWithDraw],[NumPerPage])
		VALUES(@DateModified,@MinWithDraw,@MaxWithDraw,@NumPerPage)
	END
GO
-- =============================================
-- 30. Create store procedure usp_UpdateConfig
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_UpdateConfig
	@ConfigID int
	,@DateModified datetime
	,@MinWithDraw decimal(18,0)
	,@MaxWithDraw decimal(18,0)
	,@NumPerPage int
AS
	BEGIN
		UPDATE [dbo].[Config]
		SET [DateModified] = @DateModified
		   ,[MinWithDraw]  = @MinWithDraw
		   ,[MaxWithDraw]  = @MaxWithDraw
		   ,[NumPerPage]   = @NumPerPage	
		WHERE [ConfigID]   = @ConfigID
	END
GO
-- =============================================
-- 31. Create store procedure usp_DeleteConfig
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_DeleteConfig
	@ConfigID int
AS
	BEGIN
		DELETE FROM [dbo].[Config]	
		WHERE [ConfigID] = @ConfigID
	END
GO
-- =============================================
-- 32. Create store procedure usp_SearchConfigByConfigID
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SearchConfigByConfigID
	@ConfigID int
AS
	BEGIN
		SELECT [ConfigID],[DateModified],[MinWithDraw],[MaxWithDraw],[NumPerPage]
		FROM [dbo].[Config]
		WHERE [ConfigID] = @ConfigID
	END
GO
-- =============================================
-- 33. Create store procedure usp_InsertCustomer
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_InsertCustomer
	@Name nvarchar(100)
	,@Phone varchar(50)
	,@Email varchar(100)
	,@Addr nvarchar(200)
AS
	BEGIN
		INSERT INTO [dbo].[Customer]([Name],[Phone],[Email],[Addr])
		VALUES(@Name,@Phone,@Email,@Addr)
	END
GO
-- =============================================
-- 34. Create store procedure usp_UpdateCustomer
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_UpdateCustomer
	@CustID int
	,@Name nvarchar(100)
	,@Phone varchar(50)
	,@Email varchar(100)
	,@Addr nvarchar(200)
AS
	BEGIN
		UPDATE [dbo].[Customer]
		SET [Name] = @Name
			  ,[Phone] = @Phone
			  ,[Email] = @Email
			  ,[Addr]  = @Addr
		WHERE [CustID] = @CustID
	END
GO
-- =============================================
-- 35. Create store procedure usp_DeleteCustomer
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_DeleteCustomer
	@CustID int
AS
	BEGIN
		DELETE FROM [dbo].[Customer]
		WHERE [CustID] = @CustID
	END
GO
-- =============================================
-- 36. Create store procedure usp_SearchCustomerByCustID
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SearchCustomerByCustID
	@CustID int
AS
	BEGIN
		SELECT [CustID],[Name],[Phone],[Email],[Addr]
		FROM [dbo].[Customer]
		WHERE [CustID] = @CustID
	END
GO
-- =============================================
-- 37. Create store procedure usp_InsertLogs
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_InsertLogs
	@LogTypeID int
	,@ATMID int
	,@CardID int
	,@LogDate datetime
	,@Amount decimal(18,0)
	,@Details varchar(100)
AS
	BEGIN
		INSERT INTO [dbo].[Logs]([LogTypeID],[ATMID],[CardID],[LogDate],[Amount],[Details])
		VALUES(@LogTypeID,@ATMID,@CardID,@LogDate,@Amount,@Details)
	END
GO
-- =============================================
-- 38. Create store procedure usp_UpdateLogs
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_UpdateLogs
	@LogID int
	,@LogTypeID int
	,@ATMID int
	,@CardID int
	,@LogDate datetime
	,@Amount decimal(18,0)
	,@Details varchar(100)
AS
	BEGIN
		UPDATE [dbo].[Logs]
		SET [LogTypeID] = @LogTypeID
		  ,[ATMID] = @ATMID
		  ,[CardID] = @CardID
		  ,[LogDate] = @LogDate
		  ,[Amount] = @Amount
		  ,[Details] = @Details
		WHERE [LogID] = @LogID
	END
GO
-- =============================================
-- 39. Create store procedure usp_DeleteLogs
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_DeleteLogs
	@LogID int
AS
	BEGIN
		DELETE FROM [dbo].[Logs]
		WHERE [LogID] = @LogID
	END
GO
-- =============================================
-- 40. Create store procedure usp_SearchLogsByLogID
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SearchLogsByLogID
	@LogID int
AS
	BEGIN
		SELECT [LogID],[LogTypeID],[ATMID],[CardID],[LogDate],[Amount],[Details]
		FROM [dbo].[Logs]
		WHERE [LogID] = @LogID
	END
GO
-- =============================================
-- 41. Create store procedure usp_InsertLogType
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_InsertLogType
	@Description nvarchar(100)
AS
	BEGIN
		INSERT INTO [dbo].[LogType]([Description])
		VALUES(@Description)
	END
GO
-- =============================================
-- 42. Create store procedure usp_UpdateLogType
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_UpdateLogType
	@LogTypeID int
	,@Description nvarchar(100)
AS
	BEGIN
		UPDATE [dbo].[LogType]
		SET [Description] = @Description
		WHERE [LogTypeID] = @LogTypeID
	END
GO
-- =============================================
-- 43. Create store procedure usp_DeleteLogType
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_DeleteLogType
	@LogTypeID int
AS
	BEGIN
		DELETE FROM [dbo].[LogType]
		WHERE [LogTypeID] = @LogTypeID
	END
GO
-- =============================================
-- 44. Create store procedure usp_SearchLogTypeByLogTypeID
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SearchLogTypeByLogTypeID
	@LogTypeID int
AS
	BEGIN
		SELECT [LogTypeID],[Description]
		FROM [dbo].[LogType]
		WHERE [LogTypeID] = @LogTypeID
	END
GO
-- =============================================
-- 45. Create store procedure usp_InsertMoney
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_InsertMoney
	@MoneyValue decimal(18,0)
	,@Address nvarchar(100)
AS
	BEGIN
		INSERT INTO [dbo].[Money]([MoneyValue],[Address])
		VALUES(@MoneyValue,@Address)
	END
GO
-- =============================================
-- 46. Create store procedure usp_UpdateMoney
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_UpdateMoney
	@MoneyID int
	,@MoneyValue decimal(18,0)
	,@Address nvarchar(100)
AS
	BEGIN
		UPDATE [dbo].[Money]
		SET [MoneyValue] = @MoneyValue
      ,[Address]         = @Address
		WHERE [MoneyID]  = @MoneyID
	END
GO
-- =============================================
-- 47. Create store procedure usp_DeleteMoney
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_DeleteMoney
	@MoneyID int
AS
	BEGIN
		DELETE FROM [dbo].[Money]
		WHERE [MoneyID] = @MoneyID
	END
GO
-- =============================================
-- 48. Create store procedure usp_SearchMoneyByMoneyID
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SearchMoneyByMoneyID
	@MoneyID int
AS
	BEGIN
		SELECT [MoneyID],[MoneyValue],[Address]
		FROM [dbo].[Money]
		WHERE [MoneyID] = @MoneyID
	END
GO
-- =============================================
-- 49. Create store procedure usp_InsertOverDraftLimit
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_InsertOverDraftLimit
	@Value decimal(18,0)
AS
	BEGIN
		INSERT INTO [dbo].[OverDraftLimit]([Value])
		VALUES(@Value)
	END
GO
-- =============================================
-- 50. Create store procedure usp_UpdateOverDraftLimit
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_UpdateOverDraftLimit
	@ODID int
	,@Value decimal(18,0)
AS
	BEGIN
		UPDATE [dbo].[OverDraftLimit]
		SET [Value] = @Value
		WHERE [ODID] = @ODID
	END
GO
-- =============================================
-- 51. Create store procedure usp_DeleteOverDraftLimit
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_DeleteOverDraftLimit
	@ODID int
AS
	BEGIN
		DELETE FROM [dbo].[OverDraftLimit]
		WHERE [ODID] = @ODID
	END
GO
-- =============================================
-- 52. Create store procedure usp_SearchOverDraftLimitByODID
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SearchOverDraftLimitByODID
	@ODID int
AS
	BEGIN
		SELECT [ODID],[Value]
		FROM [dbo].[OverDraftLimit]
		WHERE [ODID] = @ODID
	END
GO
-- =============================================
-- 53. Create store procedure usp_SearchOverDraftLimitByValue
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SearchOverDraftLimitByValue
	@Value decimal(18,0)
AS
	BEGIN
		SELECT [ODID],[Value]
		FROM [dbo].[OverDraftLimit]
		WHERE [Value] = @Value
	END
GO
-- =============================================
-- 54. Create store procedure usp_InsertStock
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_InsertStock
	@MoneyID int
	,@ATMID int
	,@Quantity int
AS
	BEGIN
		INSERT INTO [dbo].[Stock]([MoneyID],[ATMID],[Quantity])
		VALUES(@MoneyID,@ATMID,@Quantity)
	END
GO
-- =============================================
-- 55. Create store procedure usp_UpdateStock
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_UpdateStock
	@StockID int
	,@MoneyID int
	,@ATMID int
	,@Quantity int
AS
	BEGIN
		UPDATE [dbo].[Stock]
		SET [MoneyID]   = @MoneyID
		   ,[ATMID]     = @ATMID
		   ,[Quantity]  = @Quantity
		WHERE [StockID] = @StockID
	END
GO
-- =============================================
-- 56. Create store procedure usp_DeleteStock
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_DeleteStock
	@StockID int
AS
	BEGIN
		DELETE FROM [dbo].[Stock]
		WHERE [StockID] = @StockID
	END
GO
-- =============================================
-- 57. Create store procedure usp_SearchStockByStockID
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SearchStockByStockID
	@StockID int
AS
	BEGIN
		SELECT [StockID],[MoneyID],[ATMID],[Quantity]
		FROM [dbo].[Stock]
		WHERE [StockID] = @StockID
	END
GO
-- =============================================
-- 58. Create store procedure usp_InsertWithDrawLimit
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_InsertWithDrawLimit
	@Value decimal(18,0)
AS
	BEGIN
		INSERT INTO [dbo].[WithDrawLimit]([Value])
		VALUES(@Value)
	END
GO
-- =============================================
-- 59. Create store procedure usp_UpdateWithDrawLimit
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_UpdateWithDrawLimit
	@WDID int
	,@Value decimal(18,0)
AS
	BEGIN
		UPDATE [dbo].[WithDrawLimit]
		SET [Value] = @Value
		WHERE [WDID] = @WDID
	END
GO
-- =============================================
-- 60. Create store procedure usp_DeleteWithDrawLimit
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_DeleteWithDrawLimit
	@WDID int
AS
	BEGIN
		DELETE FROM [dbo].[WithDrawLimit]
		WHERE [WDID] = @WDID
	END
GO
-- =============================================
-- 61. Create store procedure usp_SearchWithDrawLimitByWDID
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SearchWithDrawLimitByWDID
	@WDID int
AS
	BEGIN
		SELECT [WDID],[Value]
		FROM [dbo].[WithDrawLimit]
		WHERE [WDID] = @WDID
	END
GO
-- =============================================
-- 62. Create store procedure usp_SearchWithDrawLimitByValue
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_SearchWithDrawLimitByValue
	@Value decimal(18,0)
AS
	BEGIN
		SELECT [WDID],[Value]
		FROM [dbo].[WithDrawLimit]
		WHERE [Value] = @Value
	END
GO
---------------------------------------------------------------------------------
-- =============================================
-- 63. Create store procedure
-- =============================================
USE [Group2Bank]
GO
CREATE PROCEDURE usp_ViewLogFile
	@CardNo varchar(16)
AS
	BEGIN
		SELECT L.LogID,Description,Branch,Address,CardNo,LogDate,Amount,Details
		FROM dbo.Logs L INNER JOIN dbo.LogType LT ON L.LogTypeID = LT.LogTypeID
						INNER JOIN dbo.ATM A      ON L.ATMID     = A.ATMID 
						INNER JOIN dbo.Card C     ON L.CardID    = C.CardID
		WHERE CardNo = @CardNo
	END
GO
-- =============================================
-- 64. Create store procedure
-- =============================================
USE [Group2Bank]
GO
CREATE PROC dbo.Transfers
	@Amount decimal,
	@AccountID int,
	@AccountID1 int,
	@CardNo nvarchar(16),
	@LogDate datetime,
	@Details nvarchar(50)
AS
BEGIN TRAN
		UPDATE dbo.Account
		SET
		Balance = Balance - @Amount
		WHERE AccountID = @AccountID
		
		UPDATE dbo.Account
		SET
		Balance = Balance + @Amount
		WHERE AccountID = @AccountID1
		
		INSERT INTO dbo.Logs(LogTypeID,CardID,LogDate,Amount,Details)
		VALUES('3',@CardNo,@LogDate,@Amount,@Details)
COMMIT
GO

-- =============================================
-- 65. Create store procedure usp_WithDraw
-- =============================================
USE [Group2Bank]
GO
CREATE PROC dbo.Withdraw
	@Amount decimal,
	@AccountIDWithdraw int,
	@ATMID int,
	@CardNo nvarchar(16),
	@LogDate datetime,
	@Details nvarchar(50)
AS
BEGIN TRAN
		UPDATE dbo.Account
		SET
		Balance = Balance- @Amount
		WHERE AccountID = @AccountIDWithdraw
		
		UPDATE dbo.Money
		SET
		MoneyValue = MoneyValue - @Amount
		where MoneyID = 1
		
		INSERT INTO dbo.Logs(LogTypeID,ATMID,CardID,LogDate,Amount,Details)
		VALUES('1','1',@CardNo,@LogDate,@Amount,@Details)
COMMIT
GO

-- =============================================
-- 66. Create store procedure AccountsSelectByBalance
-- ============================================= 
USE [Group2Bank]
GO
CREATE PROCEDURE AccountsSelectByBalance
	@AccountID int
AS
BEGIN
	SELECT Balance FROM dbo.Account WHERE AccountID= @AccountID
END
GO
-- =============================================
-- 67. Create store procedure MoneysSelectByMoneyValue
-- ============================================= 
CREATE PROCEDURE MoneysSelectByMoneyValue
	@MoneyID int
AS
BEGIN
	SELECT MoneyValue FROM dbo.Money WHERE MoneyID= @MoneyID
END
GO
-- =============================================
-- 68. Create store procedure Check Balance
-- ============================================= 
CREATE PROCEDURE usp_CheckBalance
	@CardNo varchar(16)
AS
BEGIN
	SELECT A.Balance
	FROM Account A INNER JOIN Card C ON A.AccountID=C.AccountID
	WHERE C.CardNo=@CardNo
END

-- =============================================
-- 69. Insert record to database
-- ============================================= 
EXEC usp_InsertCustomer N'Hồ Văn Vượng', '01673546356', 'vuonghv@gmail.com', N'Hà Nội'
GO
EXEC usp_InsertCustomer N'Võ Thị Bạch Dương', '01673543456', 'bachduong@gmail.com', N'Nghệ An'
GO
EXEC usp_InsertCustomer N'Trần Thị Thủy', '01673453467', 'thuytran@gmail.com', N'Nam Định'
GO
EXEC usp_InsertCustomer N'Nguyễn Thị Thảo', '01673453467', 'thaont@gmail.com', N'Thanh Hóa'
GO
EXEC usp_InsertOverDraftLimit 2000000
GO
EXEC usp_InsertOverDraftLimit 2500000
GO
EXEC usp_InsertOverDraftLimit 3000000
GO
EXEC usp_InsertWithdrawLimit 2000000
GO
EXEC usp_InsertWithdrawLimit 2500000
GO
EXEC usp_InsertWithdrawLimit 3000000
GO
EXEC usp_InsertAccount 1,3425345964674, 3, 1, 3500000
GO
EXEC usp_InsertAccount 2,1234567890123, 1, 3, 3500000
GO
EXEC usp_InsertAccount 3,11112222333344, 2, 2, 3500000
GO
EXEC usp_InsertCard '1234567890123456', 'Active', 3, '123456', '02-10-2014', '02-10-2016', 0
GO
EXEC usp_InsertCard '1111111122222222', 'Active', 1, '111111', '08-11-2014', '08-11-2017', 0
GO
EXEC usp_InsertCard '1111111111111111', 'Active', 2, '111111', '12-05-2014', '12-05-2017', 0
GO
EXEC usp_InsertMoney 1000000,''
GO
EXEC usp_InsertMoney 10000000,''
GO
EXEC usp_InsertMoney 100000000 , ''
GO
EXEC usp_InsertATM 'Agribank', 'Nhon'
GO
EXEC usp_InsertATM 'ACB', 'Cau Giay'
GO
EXEC usp_InsertATM 'DongABank', 'My Dinh'
GO
EXEC usp_InsertStock 1, 2, 5
GO
EXEC usp_InsertStock 2, 1, 8
GO
EXEC usp_InsertStock 3, 3, 2
GO
EXEC usp_InsertLogType 'Withdraw'
GO
EXEC usp_InsertLogType 'Check Balance'
GO
EXEC usp_InsertLogType 'Tranfer'
GO
EXEC usp_InsertLogs 1, 1, 2, '02-10-2013', 200000, 'success'
GO
EXEC usp_InsertLogs 2, 3, 1, '02-11-2013', 3000000, 'success'
GO
EXEC usp_InsertLogs 1, 3, 2, '05-10-2013', 2000000, 'success'
GO
EXEC usp_InsertLogs 3, 2, 1, '09-01-2014', 500000, 'To Le Thi Ngoc'
GO
EXEC usp_InsertLogs 3, 2, 2, '05-10-2014', 1000000, 'To Nguyen Thi Men'
GO
EXEC usp_InsertLogs 1, 3, 2, '08-10-2014', 2000000, 'success'
GO
EXEC usp_InsertLogs 2, 3, 2, '07-10-2014', 600000, 'success'
GO
EXEC usp_InsertLogs 1, 3, 2, '05-10-2014', 800000, 'success'
GO
EXEC usp_InsertLogs 1, 3, 2, '09-01-2014', 800000, 'success'
GO
EXEC usp_InsertConfig '01-12-2012','50000', '2000000', 5
GO
EXEC usp_InsertConfig '10-09-2012','100000', '5000000', 5
GO
EXEC usp_InsertConfig '10-02-2013','50000', '3000000', 5
GO
