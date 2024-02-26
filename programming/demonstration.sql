EXEC usp_new_user 'samik', 'Jan', 'Dobrasiewicz', 'Koo ul. Poznaska 6', 'samik451@gmailsdaf.com'
EXEC usp_new_user 'hytry', 'Henryk', 'Sienkiewicz', 'Tarnowo ul. Masowska 15/6', 'slawnypisarzonet.pl'

SELECT * FROM Users

EXEC usp_auction_item 'PC', 'computers', '780', 'alice_smith'
EXEC usp_auction_item 'telephone', 'electronics', '460', 'bobross'

SELECT * FROM Items;

EXEC usp_add_bid '1000', '12', 'samik'
EXEC usp_add_bid '1200', '12', 'maryjane'
EXEC usp_add_bid '1400', '12', 'samik'

SELECT * FROM Auctions;
SELECT * FROM Bids;

EXEC usp_finish_auction '12', 'finished without buying'

SELECT * FROM Items;
SELECT * FROM Auctions;

SELECT *
FROM udf_items_of_selected_user('samwilson')

SELECT * 
FROM udf_delivery_options_for_selected_item(1)

SELECT *
FROM Offers_with_numeration;

SELECT A.id AS auction_id, A.start_date, A.end_date, A.status, A.winner,
       I.name AS item_name, I.category, I.entry_price, I.description, I.exit_price
FROM Auctions A
JOIN Items I ON A.item = I.id;

SELECT B.auction_number, COUNT(*) AS total_bids, MAX(B.amount) AS highest_bid
FROM Bids B
GROUP BY B.auction_number;

SELECT U.login, U.first_name, U.last_name, COUNT(I.id) AS total_items_listed
FROM Users U
LEFT JOIN Items I ON U.login = I.owner
GROUP BY U.login, U.first_name, U.last_name;

SELECT I.id, I.name, I.category, I.entry_price, I.description, I.exit_price,
       COUNT(B.id) AS total_bids, MAX(B.amount) AS highest_bid
FROM Items I
LEFT JOIN Auctions A ON I.id = A.item
LEFT JOIN Bids B ON A.id = B.auction_number
GROUP BY I.id, I.name, I.category, I.entry_price, I.description, I.exit_price;

SELECT TOP 5 U.login, U.first_name, U.last_name, SUM(B.amount) AS total_bid_amount
FROM Users U
INNER JOIN Bids B ON U.login = B.username
GROUP BY U.login, U.first_name, U.last_name
ORDER BY total_bid_amount DESC;

SELECT I.id, I.name, I.category, I.entry_price, MAX(B.amount) AS highest_bid_amount
FROM Items I
INNER JOIN Auctions A ON I.id = A.item
INNER JOIN Bids B ON A.id = B.auction_number
GROUP BY I.id, I.name, I.category, I.entry_price
HAVING MAX(B.amount) > I.entry_price;

SELECT DISTINCT U.login, U.first_name, U.last_name
FROM Users U
INNER JOIN Items I ON U.login = I.owner
INNER JOIN Auctions A ON I.id = A.item
WHERE I.category = 'Electronics';

SELECT DISTINCT U.login, U.first_name, U.last_name
FROM Users U
WHERE EXISTS (
    SELECT 1
    FROM Items I
    INNER JOIN Auctions A ON I.id = A.item
    WHERE I.category = 'Electronics' AND A.status <> 'finished without buying' AND U.login = I.owner
);

SELECT U.login, U.first_name, U.last_name
FROM Users U
WHERE NOT EXISTS (
    SELECT 1
    FROM Bids B
    WHERE B.username = U.login
);

SELECT I.id AS item_id, I.name, I.category, COUNT(B.id) AS total_bids
FROM Items I
LEFT JOIN Auctions A ON I.id = A.item
LEFT JOIN Bids B ON A.id = B.auction_number
GROUP BY I.id, I.name, I.category
HAVING COUNT(B.id) > 0;