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