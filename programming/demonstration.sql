EXEC usp_nowy_uzytkownik 'samik', 'Jan', 'Dobrasiewicz', 'Ko³o ul. Poznañska 6', 'samik451@gmail.com'
EXEC usp_nowy_uzytkownik 'hytry', 'Henryk', 'Sienkiewicz', 'Tarnowo ul. Mas³owska 15/6', 'slawnypisarzonet.pl'

SELECT * FROM U¿ytkownicy;

EXEC usp_wystawienie_przedmiotu_i_licytacja 'komputer', 'elektronika', '780', 'helo'
EXEC usp_wystawienie_przedmiotu_i_licytacja 'telefon', 'elektronika', '460', 'radtrz'

SELECT * FROM Przedmioty;

EXEC usp_dodanie_oferty '130', '15' , 'samik'
EXEC usp_dodanie_oferty '140', '15', 'popa'
EXEC usp_dodanie_oferty '160', '15', 'samik'

SELECT * FROM Oferty;

EXEC usp_zakoncz_licytacje '15', 'zakoñczona bez kupnem'

SELECT * FROM Przedmioty;
SELECT * FROM Licytacje;

SELECT *
FROM udf_przedmioty_wybranego_uzytkownika('popa')

SELECT * 
FROM udf_opcje_dostawy_dla_wybranego_przedmiotu(1)

SELECT *
FROM Oferty_numeracja;