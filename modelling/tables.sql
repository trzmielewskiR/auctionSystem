CREATE DATABASE AuctionSystem;

USE AuctionSystem;

--english language--

SET LANGUAGE 'english'

--drop commands--

DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Items;
DROP TABLE IF EXISTS Auctions;
DROP TABLE IF EXISTS Bids;
DROP TABLE IF EXISTS Deliveries;
DROP TABLE IF EXISTS Possession;

--create commands--

CREATE TABLE Users
(
    login             VARCHAR(32) NOT NULL CONSTRAINT usr_login PRIMARY KEY,
    first_name        VARCHAR(20) NOT NULL,
    last_name         VARCHAR(25) NOT NULL,
    address           VARCHAR(50) NOT NULL,
    email             VARCHAR(40) NOT NULL UNIQUE CONSTRAINT usr_email_chk CHECK (email LIKE '%_@_%_.__%'),
    account_number    CHAR(26) NULL CONSTRAINT usr_account_num_chk CHECK (account_number LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    delivery_address  VARCHAR(50) NULL,
    phone_number      CHAR(9) NULL CONSTRAINT usr_phone_number_chk CHECK(phone_number LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

CREATE TABLE Items
(
    id          INT IDENTITY(1,1) NOT NULL CONSTRAINT itm_id PRIMARY KEY,
    name        VARCHAR(40) NOT NULL,
    category    VARCHAR(30) NOT NULL,
    entry_price MONEY NOT NULL CONSTRAINT item_entry_price_chk CHECK (entry_price > 0),
    description VARCHAR(150) NULL,
    exit_price  MONEY NULL,
    owner       VARCHAR(32) CONSTRAINT item_owner_chk FOREIGN KEY REFERENCES Users(login),
    CONSTRAINT item_exit_price_chk CHECK (exit_price >= entry_price)
);

CREATE TABLE Auctions
(
    id          INT IDENTITY(1,1) NOT NULL CONSTRAINT auc_id PRIMARY KEY,
    item        INT CONSTRAINT auc_item_fk FOREIGN KEY REFERENCES Items(id),
    start_date  DATE NOT NULL,
    end_date    DATE,
    status      VARCHAR(30) CONSTRAINT auc_status_check CHECK (status in('in progress', 'finished with buying', 'finished without buying')) DEFAULT 'in progress',
    winner      VARCHAR(32) CONSTRAINT auc_winner_fk NULL REFERENCES Users(login),
);

CREATE TABLE Bids
(
    bid_date            DATE NOT NULL,
    bid_hour            TIME(0) NOT NULL,
    amount              MONEY NOT NULL,
    auction_number      INT CONSTRAINT bid_auction_fk REFERENCES Auctions(id),
    username            VARCHAR(32) CONSTRAINT bid_user_fk REFERENCES Users(login),
    CONSTRAINT bid_primary_key PRIMARY KEY (auction_number, username, bid_date, bid_hour)
);

CREATE TABLE Deliveries
(
    id              INT NOT NULL CONSTRAINT del_id PRIMARY KEY,
    service_name    VARCHAR(30) NOT NULL,
    company         VARCHAR(30) NOT NULL,
    price           MONEY NOT NULL CONSTRAINT del_price_chk CHECK (price >= 0)
);

CREATE TABLE Possession
(
    item                INT NOT NULL CONSTRAINT own_item_fk REFERENCES Items(id),
    delivery_number     INT NOT NULL CONSTRAINT own_delivery_fk REFERENCES Deliveries(id),
    CONSTRAINT posiadanie_key PRIMARY KEY(item, delivery_number)
);

GO

--insert commands--

INSERT INTO Users (login, first_name, last_name, address, email, account_number, delivery_address, phone_number)
VALUES
('maryjane', 'Mary', 'Jane', '789 Pine St', 'maryjane@example.com', '11112222333344445555666677', '101 Chestnut Ave', '555666777'),
('bobross', 'Bob', 'Ross', '321 Cedar St', 'bobross@example.com', '88889999000011112222333344', '202 Walnut Ave', '888999000'),
('samwilson', 'Sam', 'Wilson', '456 Red St', 'samwilson@example.com', '33334444555566667777888899', '303 Elm St', '111222333'),
('janedoe', 'Jane', 'Doe', '789 Green St', 'janedoe@example.com', '12341234123412341234123456', '404 Oak St', '444555666'),
('tonystark', 'Tony', 'Stark', '123 Blue St', 'tonystark@example.com', '98769876987698769876987654', '505 Walnut St', '777888999'),
('johndoe', 'John', 'Doe', '123 Main St', 'johndoe@example.com', '12345678901234567890123456', '456 Elm St', '123456789'),
('alice_smith', 'Alice', 'Smith', '456 Oak St', 'alice_smith@example.com', '98765432109876543210987654', '789 Maple Ave', '987654321');

INSERT INTO Items (name, category, entry_price, description, exit_price, owner)
VALUES
('Smartphone', 'Electronics', 600, 'Latest model smartphone', 650, 'maryjane'),
('Fishing Rod', 'Outdoor', 50, 'Carbon fiber fishing rod', 60, 'bobross'),
('Digital Camera', 'Electronics', 400, 'Professional DSLR camera', 450, 'samwilson'),
('Garden Hose', 'Garden', 20, '50ft heavy-duty garden hose', 25, 'janedoe'),
('Sunglasses', 'Fashion', 50, 'Polarized sunglasses', 60, 'tonystark'),
('Laptop', 'Electronics', 800, 'Brand new laptop', NULL, 'johndoe'),
('Bicycle', 'Sports', 300, 'Mountain bike', 400, 'alice_smith'),
('Bluetooth Speaker', 'Electronics', 100, 'Portable Bluetooth speaker', 120, 'samwilson'),
('Running Shoes', 'Sport', 80, 'High-performance running shoes', 90, 'samwilson'),
('Coffee Maker', 'Kitchen', 50, 'Drip coffee maker', 60, 'samwilson'),
('Backpack', 'Outdoor', 40, 'Waterproof hiking backpack', 50, 'samwilson'),
('Desk Lamp', 'Home', 30, 'Adjustable desk lamp', 35, 'samwilson');

INSERT INTO Deliveries (id, service_name, company, price)
VALUES
(503, 'Next Day Delivery', 'SpeedyShip', 25),
(504, 'Economy Delivery', 'BudgetShip', 5),
(505, '2-Day Shipping', 'SwiftShip', 15),
(506, 'Standard Ground Shipping', 'GroundShip', 8),
(507, 'International Shipping', 'GlobalShip', 30),
(501, 'Express Delivery', 'FastShip', 20),
(502, 'Standard Delivery', 'SlowShip', 10);

INSERT INTO Possession (item, delivery_number)
VALUES
(1, 501),
(2, 502),
(3, 503),
(4, 504),
(5, 505),
(6, 506),
(7, 507);


INSERT INTO Auctions (item, start_date, end_date, status, winner)
VALUES
(1, '2024-02-25', '2024-03-10', 'in progress', NULL),
(2, '2024-03-01', '2024-03-15', 'finished without buying', NULL),
(3, '2024-03-05', '2024-03-20', 'in progress', NULL),
(4, '2024-03-10', '2024-03-25', 'in progress', NULL),
(5, '2024-03-10', '2024-03-25', 'in progress', NULL),
(6, '2024-03-15', '2024-03-30', 'in progress', NULL),
(7, '2024-03-20', '2024-04-05', 'in progress', NULL),
(8, '2024-03-25', '2024-04-10', 'finished with buying', 'tonystark'),
(9, '2024-03-25', '2024-04-10', 'finished with buying', 'johndoe'),
(10, '2024-03-30', '2024-04-15', 'finished without buying', NULL);

INSERT INTO Bids (bid_date, bid_hour, amount, auction_number, username)
VALUES
('2024-02-27', '12:00:00', 850, 1, 'johndoe'),
('2024-03-05', '14:30:00', 320, 3, 'alice_smith'),
('2024-03-08', '10:00:00', 700, 3, 'bobross'),
('2024-03-15', '16:45:00', 55, 4, 'maryjane'),
('2024-03-12', '11:30:00', 420, 5, 'janedoe'),
('2024-03-18', '14:15:00', 30, 6, 'samwilson'),
('2024-03-22', '09:00:00', 65, 7, 'tonystark');

--select commands--

SELECT * FROM Users;
SELECT * FROM Items;
SELECT * FROM Auctions;
SELECT * FROM Bids;
SELECT * FROM Deliveries;
SELECT * FROM Possession;

-------------------
