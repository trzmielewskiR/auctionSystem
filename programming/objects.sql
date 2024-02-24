--english lang--

SET LANGUAGE 'english'

---drop commands---
DROP FUNCTION IF EXISTS udf_items_of_selected_user;
DROP FUNCTION IF EXISTS udf_delivery_options_for_selected_item;
DROP VIEW IF EXISTS Offers_with_numeration;

DROP PROCEDURE IF EXISTS usp_new_user;
DROP PROCEDURE IF EXISTS usp_new_user_extended;
DROP PROCEDURE IF EXISTS usp_auction_item;
DROP PROCEDURE IF EXISTS usp_add_bid;
DROP PROCEDURE IF EXISTS usp_finish_auction;

GO

--create commands--

CREATE OR ALTER PROCEDURE usp_new_user
    @login VARCHAR(32),
    @first_name VARCHAR(20),
    @last_name VARCHAR(25),
    @address VARCHAR(50),
    @email VARCHAR (40)
AS

    INSERT INTO Users (login, first_name, last_name, address, email)
    VALUES (@login, @first_name, @last_name, @address, @email);
GO


CREATE OR ALTER PROCEDURE usp_new_user_extended
    @login VARCHAR(32),
    @first_name VARCHAR(20),
    @last_name VARCHAR(25),
    @address VARCHAR(50),
    @email VARCHAR (40),
    @account_number CHAR(26),
    @delivery_address VARCHAR(50),
    @phone_number CHAR(9)
AS

    INSERT INTO Users (login, first_name, last_name, address, email, account_number, delivery_address, phone_number)
    VALUES (@login, @first_name, @last_name, @address, @email, @account_number, @delivery_address, @phone_number);
GO


CREATE OR ALTER PROCEDURE usp_auction_item
    @name VARCHAR(30),
    @category VARCHAR(30),
    @entry_price MONEY,
    @owner VARCHAR(32)
AS
    IF NOT EXISTS (SELECT login FROM Users WHERE login = @owner)
    BEGIN
        RAISERROR(N'No such user exists', 16, 1);
        RETURN;
    END;

    INSERT INTO Items (name, category, entry_price, owner)
    VALUES(@name, @category, @entry_price, @owner);

    DECLARE @status VARCHAR(30);
    SET @status = 'in progress';

    DECLARE @item INT;
    SET @item = (SELECT MAX(id)
                 FROM Items);

    DECLARE @start_date DATE;
    SET @start_date = GETDATE();

    INSERT INTO Auctions (item, start_date, status)
    VALUES(@item, @start_date, @status);

GO


CREATE OR ALTER PROCEDURE usp_add_bid
    @amount MONEY,
    @auction_number INT,
    @username VARCHAR(32)
AS
     IF NOT EXISTS (SELECT login FROM Users WHERE login = @username)
    BEGIN
        RAISERROR(N'No such user exists', 16, 1 );
        RETURN;
    END

     IF NOT EXISTS (SELECT id FROM Auctions WHERE id = @auction_number)
    BEGIN
        RAISERROR(N'No auction with this number exists', 
                   16, 
                   1);
        RETURN;
    END;

    DECLARE @bid_date DATE;
    SET @bid_date = GETDATE();

    DECLARE @bid_hour TIME(0);
    SET @bid_hour = (SELECT convert(varchar(10), GETDATE(), 108));

    INSERT INTO Bids VALUES
    (@bid_date, @bid_hour, @amount, @auction_number, @username);

GO


CREATE OR ALTER PROCEDURE usp_finish_auction
    @auction_number INT,
    @status VARCHAR(30)
AS
    DECLARE @highest_bid MONEY;
    DECLARE @winner VARCHAR(32);

    IF @status = 'finished without buying'
        BEGIN 
            UPDATE Auctions
            SET end_date = GETDATE(),
                status = @status
            WHERE id = @auction_number;
        END
    ELSE IF @status = 'finished with buying'
        BEGIN
            SET @highest_bid = (SELECT MAX(amount)
                               FROM Bids
                               WHERE auction_number = @auction_number);

            --possible shortcute for this one--
            SET @winner = (SELECT username
                              FROM Bids
                              WHERE amount = (SELECT MAX(amount)
                                               FROM Bids
                                               WHERE auction_number = @auction_number));

            DECLARE @end_date DATE;
            SET @end_date = GETDATE();

            UPDATE Auctions
            SET end_date = @end_date,
                winner = @winner,
                status = @status
            WHERE id = @auction_number;

            UPDATE Items
            SET Items.exit_price = @highest_bid
            FROM Items
                JOIN Auctions
                    ON Items.id = Auctions.item
            WHERE Auctions.id = @auction_number;
        END
    ELSE
        BEGIN
            RAISERROR(N'Incorrectly entered status',17,1)
            RETURN;
        END;
GO


CREATE FUNCTION udf_items_of_selected_user
(
    @login VARCHAR(32)
)
    RETURNS TABLE
AS
    RETURN SELECT *
           FROM Items
           WHERE owner = @login;
GO


CREATE FUNCTION udf_delivery_options_for_selected_item
(
    @number  INT
)
    RETURNS TABLE
AS
    RETURN SELECT Deliveries.id, Deliveries.service_name, Deliveries.company, Deliveries.price
           FROM Deliveries
                JOIN Possession
                    ON Possession.delivery_number = Deliveries.id
           WHERE Possession.item = @number;
GO


CREATE VIEW Offers_with_numeration(number, auction_number, bid_date, bid_hour, username)
AS
(
    SELECT
    ROW_NUMBER() OVER(PARTITION BY auction_number ORDER BY auction_number) AS number,
    auction_number, 
    bid_date,
	bid_hour,
    username
    FROM Bids
);
GO