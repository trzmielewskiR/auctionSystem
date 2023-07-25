--jezyk polski--

SET LANGUAGE 'polski'

--polecenia drop--

DROP TABLE IF EXISTS U¿ytkownicy;
DROP TABLE IF EXISTS Przedmioty;
DROP TABLE IF EXISTS Licytacje;
DROP TABLE IF EXISTS Oferty;
DROP TABLE IF EXISTS Dostawy;
DROP TABLE IF EXISTS Posiadanie;

--polecenia create--

CREATE TABLE U¿ytkownicy
(
    login       VARCHAR(32) NOT NULL CONSTRAINT uz_login PRIMARY KEY,
    imie        VARCHAR(20) NOT NULL,
    nazwisko    VARCHAR(25) NOT NULL,
    adres_zam   VARCHAR(50) NOT NULL,
    email       VARCHAR(40) NOT NULL UNIQUE CONSTRAINT uz_email_pop CHECK (email LIKE '%_@_%_.__%'),
    numer_konta CHAR(26) NULL CONSTRAINT uz_numer_konta_pop CHECK (numer_konta LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    adres_dos   VARCHAR(50) NULL,
    telefon     CHAR(9) NULL CONSTRAINT uz_telefon_pop CHECK(telefon LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);

CREATE TABLE Przedmioty
(
    numer       INT IDENTITY(1,1) NOT NULL CONSTRAINT prz_numer PRIMARY KEY,
    nazwa       VARCHAR(40) NOT NULL,
    kategoria   VARCHAR(30) NOT NULL,
    cena_wyjsc  MONEY NOT NULL CONSTRAINT prz_cenaw CHECK (cena_wyjsc > 0),
    opis        VARCHAR(150) NULL,
    cena_zak    MONEY NULL,
    wlasciciel  VARCHAR(32) CONSTRAINT prz_numer_obcy FOREIGN KEY REFERENCES U¿ytkownicy(login),
    CONSTRAINT prz_cenaz CHECK (cena_zak >= cena_wyjsc)
);

CREATE TABLE Licytacje
(
    id          INT IDENTITY(10,1) NOT NULL CONSTRAINT lic_id PRIMARY KEY,
    przedmiot   INT CONSTRAINT licz_prz FOREIGN KEY REFERENCES Przedmioty(numer),
    data_rozp   DATE NOT NULL,
    data_zakon  DATE,
    status      VARCHAR(30) CONSTRAINT lic_status_pop CHECK (status in('w trakcie', 'zakoñczona kupnem', 'zakoñczona bez kupna')) DEFAULT 'w trakcie',
    zwyciezca   VARCHAR(32) CONSTRAINT lic_winner NULL REFERENCES U¿ytkownicy(login),
);

CREATE TABLE Oferty
(
    data_of             DATE NOT NULL,
    godzina             TIME(0) NOT NULL,
    kwota               MONEY NOT NULL,
    numer_licytacji     INT CONSTRAINT of_lic REFERENCES Licytacje(id),
    uzytkownik          VARCHAR(32) CONSTRAINT of_uz REFERENCES U¿ytkownicy(login),
    CONSTRAINT of_key PRIMARY KEY (numer_licytacji, uzytkownik, data_of, godzina)
);

CREATE TABLE Dostawy
(
    id          INT NOT NULL CONSTRAINT dos_key PRIMARY KEY,
    nazwa       VARCHAR(30) NOT NULL,
    firma       VARCHAR(30) NOT NULL,
    cena        MONEY NOT NULL CONSTRAINT dos_cena CHECK (cena >= 0)
);

CREATE TABLE Posiadanie
(
    przedmiot       INT NOT NULL CONSTRAINT pos_prz REFERENCES Przedmioty(numer),
    numer_dostawy   INT NOT NULL CONSTRAINT pos_dos REFERENCES Dostawy(id),
    CONSTRAINT posiadanie_key PRIMARY KEY(przedmiot, numer_dostawy)
);

GO
--polecenia INSERT--

INSERT INTO U¿ytkownicy VALUES
('radtrz', 'Rados³aw', 'Trzmielewski', 'Morys³awice 5C', 'rarrrrr@gmail.com', null, 'Morys³awice 5C', '997886775'),
('popa', 'Jan', 'Nowak', 'Mielno ul. Mickiewicza 5/23', 'polski_orzel@onet.com', null, null, '998867112'),
('mak12', 'Maciej', 'B¹k', 'Poznañ ul. Norwida 19/14', 'maciejbaak@wp.com','47212110090000000235698741' , null, null),
('krzysztof_kr', 'Krzysztof', 'Krowa', 'Sompolno ul. Poznañska 4', 'krzysztof_krowa@gmail.com',null , 'Poznañ ul. Rzymska 88', '654342978');
INSERT INTO U¿ytkownicy VALUES
('bananowy_marzyciel', 'Krystyna', 'Czóbuwna', 'Warszawa ul. Kotarskiego 39/4', 'czubuwienkaonet.pl,', null, null, '687419324');


INSERT INTO Przedmioty VALUES
('drukarka', 'elektronika', '500', 'Mam na sprzedaz drukarke marki brother, wiecej szczegolow w wiadomosci priv', NULL, 'radtrz'),
('kubek', 'porcelana', '25', 'Wlasnorecznie robiony kubek juz dzis w cenie 25 zlotych, zapraszam do licytacji', '80' , 'radtrz'),
('kubek', 'porcelana', '25', 'Wlasnorecznie robiony kubek juz dzis w cenie 25 zlotych, zapraszam do licytacji', null , 'radtrz'),
('pralka', 'sprzet AGD', '150', 'Pralka frania, chce sie jej jak najszybciej pozbyc bo zajmuje tylko miejsce, stan doskonaly', '250' , 'popa'),
('dywan', 'Dom i Ogród', '120', null , null , 'mak12');
INSERT INTO Przedmioty VALUES
('taczka', 'Dom i Ogród', '50' , 'taczka na kó³ku', '25', 'krzysztof_kr');

INSERT INTO Licytacje VALUES
('1', '20-4-2020', '25-4-2020', 'zakoñczona bez kupna', null),
('2', '20-4-2020', '22-4-2020', 'zakoñczona kupnem', 'popa'),
('4', '4-6-2020', '29-6-2020', 'zakoñczona kupnem', 'krzysztof_kr'),
('3', '28-11-2020', '17-12-2020', 'zakoñczona bez kupna', null),
('5', '28-5-2021', null, 'w trakcie', null);
INSERT INTO Licytacje VALUES
('5', '28-5-2021', '25-4-2021', 'zakoñczona kupnem', 'radtrz');

INSERT INTO Oferty VALUES
('20-4-2020','16:00', '30', '11', 'mak12'),
('21-4-2020','15:00', '45', '11', 'popa'),
('22-4-2020','9:15:45', '67', '11', 'mak12'),
('25-4-2020','5:00', '80', '11', 'popa'),
('28-6-2020','16:00', '250', '12', 'krzysztof_kr');
INSERT INTO Oferty VALUES
('27-6-2020', '15:43', 'piêædziesi¹t trzy z³ote', '12', 'mak12');

INSERT INTO Dostawy VALUES
('101', 'paczkomat do 15 kg', 'POSTatP', '15'),
('102', 'paczkomat powyzej 15 kg', 'POSTatP', '25'),
('103', 'kurier przedp³ata', 'POSTatP', '10'),
('201', 'kurier przedp³ata', 'MKD', '12'),
('202', 'kurier pobranie', 'MKD', '15,99'),
('203', 'odbiór osobisty', 'MKD', '0'),
('301', 'odbiór osobisty', 'PaczKDP', '0');
INSERT INTO Dostawy VALUES
('401', 'paczkomat', 'PaczKDP', '-5');

INSERT INTO Posiadanie VALUES
('1', '101'),
('1', '102'),
('1', '103'),
('1', '201'),
('2', '202'),
('2', '203'),
('3', '301'),
('4', '101'),
('4', '102'),
('4', '201'),
('5', '301');
INSERT INTO Posiadanie VALUES
('5', '501');


--polecenia SELECT--

SELECT * FROM U¿ytkownicy;
SELECT * FROM Przedmioty;
SELECT * FROM Licytacje;
SELECT * FROM Oferty;
SELECT * FROM Dostawy;
SELECT * FROM Posiadanie;

-------------------
