CREATE DATABASE [database];
GO

USE [database];
GO

CREATE TABLE [user] (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    name NVARCHAR(255) NOT NULL,
    email NVARCHAR(255) NOT NULL,
    password NVARCHAR(255) NOT NULL,
    accountNumber NVARCHAR(255) NOT NULL,
    -- role NVARCHAR(255) NOT NULL CHECK (role IN ('admin', 'project_creator', 'user')),
    UNIQUE (email)
);
GO

CREATE INDEX idx_user_email ON [user](email);
CREATE INDEX idx_user_name ON [user](name);
CREATE INDEX idx_user_accountNumber ON [user](accountNumber);
GO

CREATE TABLE balance (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    userId UNIQUEIDENTIFIER NOT NULL,
    amount DECIMAL(18, 2) NOT NULL,
    FOREIGN KEY (userId) REFERENCES [user](id),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX idx_balance_userId ON balance(userId);
CREATE INDEX idx_balance_amount ON balance(amount);
CREATE INDEX idx_balance_created_at ON balance(created_at);
GO

CREATE TABLE [transaction] (
    id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    userId UNIQUEIDENTIFIER NOT NULL,
    amount DECIMAL(18, 2) NOT NULL,
    type NVARCHAR(255) NOT NULL CHECK (type IN ('credit', 'debit')),
    FOREIGN KEY (userId) REFERENCES [user](id),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);
GO

CREATE INDEX idx_transaction_userId ON [transaction](userId);
CREATE INDEX idx_transaction_amount ON [transaction](amount);
CREATE INDEX idx_transaction_created_at ON [transaction](created_at);
GO

CREATE PROCEDURE make_transaction
    @payerId UNIQUEIDENTIFIER,
    @payeeId UNIQUEIDENTIFIER,
    @amount DECIMAL(18, 2)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO [transaction] (userId, amount, type)
        VALUES (@payerId, @amount, 'debit');

        INSERT INTO [transaction] (userId, amount, type)
        VALUES (@payeeId, @amount, 'credit');

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

CREATE TRIGGER trg_transaction_insert
ON [transaction]
AFTER INSERT
AS
BEGIN
    DECLARE @userId UNIQUEIDENTIFIER;
    DECLARE @amount DECIMAL(18, 2);
    DECLARE @type NVARCHAR(255);
    DECLARE @balance DECIMAL(18, 2);

    SELECT @userId = userId, @amount = amount, @type = type
    FROM inserted;

    SELECT TOP 1 @balance = amount
    FROM balance
    WHERE userId = @userId
    ORDER BY created_at DESC;

    IF @type = 'credit'
    BEGIN
        SET @balance = @balance + @amount;
    END
    ELSE
    BEGIN
        SET @balance = @balance - @amount;

        IF @balance < 0
        BEGIN
            THROW 50000, 'Insufficient balance', 1;
        END
    END

    INSERT INTO balance (userId, amount, created_at, updated_at)
    VALUES (@userId, @balance, GETDATE(), GETDATE());
END;
GO
