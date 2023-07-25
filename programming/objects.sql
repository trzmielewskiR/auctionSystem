--jezyk polski--

SET LANGUAGE 'polski'

---polecenia drop---
DROP FUNCTION udf_przedmioty_wybranego_uzytkownika;
DROP FUNCTION udf_opcje_dostawy_dla_wybranego_przedmiotu;
DROP VIEW Oferty_numeracja;

DROP PROCEDURE usp_nowy_uzytkownik;
DROP PROCEDURE usp_wystawienie_przedmiotu_i_licytacja;
DROP PROCEDURE usp_dodanie_oferty;
DROP PROCEDURE usp_zakoncz_licytacje;

--polecenia create--
--trzeba dodać jeszcze kilka triggerow--

CREATE OR ALTER PROCEDURE usp_nowy_uzytkownik
    @login VARCHAR(32),
    @imie VARCHAR(20),
    @nazwisko VARCHAR(25),
    @adres_zam VARCHAR(50),
    @email VARCHAR (40)
AS

    INSERT INTO U�ytkownicy (login, imie, nazwisko, adres_zam, email)
    VALUES (@login, @imie, @nazwisko, @adres_zam, @email);
GO


CREATE OR ALTER PROCEDURE usp_nowy_uzytkownik_rozsz
    @login VARCHAR(32),
    @imie VARCHAR(20),
    @nazwisko VARCHAR(25),
    @adres_zam VARCHAR(50),
    @email VARCHAR (40),
    @numer_konta CHAR(26),
    @adres_dos VARCHAR(50),
    @telefon CHAR(9)
AS

    INSERT INTO U�ytkownicy (login, imie, nazwisko, adres_zam, email, numer_konta, adres_dos, telefon)
    VALUES (@login, @imie, @nazwisko, @adres_zam, @email, @numer_konta, @adres_dos, @telefon);
GO


CREATE OR ALTER PROCEDURE usp_wystawienie_przedmiotu_i_licytacja
    @nazwa VARCHAR(30),
    @kategoria VARCHAR(30),
    @cena_wyjsc MONEY,
    @wlasciciel VARCHAR(32)
AS
    IF NOT EXISTS (SELECT login FROM U�ytkownicy)
    BEGIN
        RAISERROR(N'Nie ma takiego u�ytkownika', 16, 1);
        RETURN;
    END;

    INSERT INTO Przedmioty (nazwa, kategoria, cena_wyjsc, wlasciciel)
    VALUES(@nazwa, @kategoria, @cena_wyjsc, @wlasciciel)

    DECLARE @status VARCHAR(30);
    SET @status = 'w trakcie';

    DECLARE @przedmiot INT;
    SET @przedmiot = (SELECT MAX(numer)
                      FROM Przedmioty);

    DECLARE @data_rozp DATE;
    SET @data_rozp = GETDATE();

    INSERT INTO Licytacje (przedmiot, data_rozp, status)
    VALUES(@przedmiot, @data_rozp, @status);

GO


CREATE OR ALTER PROCEDURE usp_dodanie_oferty
    @kwota MONEY,
    @numer_licytacji INT,
    @uzytkownik VARCHAR(32)
AS
     IF NOT EXISTS (SELECT login FROM U�ytkownicy)
    BEGIN
        RAISERROR(N'Nie ma takiego u�ytkownika', 16, 1 );
        RETURN;
    END

     IF NOT EXISTS (SELECT id FROM Licytacje)
    BEGIN
        RAISERROR(N'Licytacja o tym numerze nie istnieje', 
                   16, 
                   1);
        RETURN;
    END;

    DECLARE @data_of DATE;
    SET @data_of = GETDATE();

    DECLARE @godzina TIME(0);
    SET @godzina = (SELECT convert(varchar(10), GETDATE(), 108));

    INSERT INTO Oferty VALUES
    (@data_of, @godzina, @kwota, @numer_licytacji, @uzytkownik);

GO


CREATE OR ALTER PROCEDURE usp_zakoncz_licytacje
    @numer_licytacji INT,
    @status VARCHAR(30)
AS
    DECLARE @pomocnicza MONEY;
    DECLARE @zwyciezca VARCHAR(32);

    IF @status = 'zako�czona bez kupna'
        BEGIN 
            UPDATE Licytacje
            SET data_zakon = GETDATE(),
                status = @status
            WHERE id = @numer_licytacji;
        END
    ELSE IF @status = 'zako�czona kupnem'
        BEGIN
            SET @pomocnicza = (SELECT MAX(kwota)
                               FROM Oferty
                               WHERE numer_licytacji = @numer_licytacji);

            SET @zwyciezca = (SELECT uzytkownik
                              FROM OFERTY
                              WHERE kwota = (SELECT MAX(kwota)
                                             FROM Oferty
                                             WHERE numer_licytacji = @numer_licytacji));

            DECLARE @data_zakon DATE;
            SET @data_zakon = GETDATE();

            UPDATE Licytacje
            SET data_zakon = @data_zakon,
                zwyciezca = @zwyciezca,
                status = @status
            WHERE id = @numer_licytacji;

            UPDATE Przedmioty
            SET Przedmioty.cena_zak = @pomocnicza
            FROM Przedmioty
                JOIN Licytacje
                    ON Przedmioty.numer = Licytacje.przedmiot
            WHERE Licytacje.id = @numer_licytacji;
        END
    ELSE
        BEGIN
            RAISERROR(N'�le wprowadzony status',17,1)
            RETURN;
        END;
GO


CREATE FUNCTION udf_przedmioty_wybranego_uzytkownika
(
    @login VARCHAR(32)
)
    RETURNS TABLE
AS
    RETURN SELECT *
           FROM Przedmioty
           WHERE wlasciciel = @login;
GO


CREATE FUNCTION udf_opcje_dostawy_dla_wybranego_przedmiotu
(
    @numer  INT
)
    RETURNS TABLE
AS
    RETURN SELECT Dostawy.id, Dostawy.nazwa, Dostawy.firma, Dostawy.cena
           FROM Dostawy
                JOIN Posiadanie
                    ON Posiadanie.numer_dostawy = Dostawy.id
           WHERE Posiadanie.przedmiot = @numer;
GO


CREATE VIEW Oferty_numeracja( data_of, numer_licytacji, godzina, uzytkownik)
AS
(
    SELECT
    ROW_NUMBER() OVER(PARTITION BY numer_licytacji ORDER BY numer_licytacji) AS numer,
    numer_licytacji, 
    godzina,
    uzytkownik
    FROM Oferty
);
GO
