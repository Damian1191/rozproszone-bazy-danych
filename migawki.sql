zad 1

CREATE MATERIALIZED VIEW REP_wykladowcy
REFRESH COMPLETE ON DEMAND
AS 
SELECT * FROM wykladowcy@dblinkFilia;

zad 2

INSERT INTO wykladowcy (wykladowca_id, imie, nazwisko, stawka) 
VALUES (150, 'BARTŁOMIEJ', 'KACZKA', 150);

COMMIT;

zad 3

SELECT * FROM REP_wykladowcy;

zad 4

EXEC DBMS_MVIEW.REFRESH('REP_wykladowcy', 'C');

zad 5
SELECT * FROM REP_wykladowcy;

zad 6

CREATE MATERIALIZED VIEW REP_godz_wykladowcy_godziny
BUILD DEFERRED
REFRESH COMPLETE
START WITH LAST_DAY(SYSDATE)
NEXT SYSDATE + 1/24
AS
SELECT 
    w.imie, 
    w.nazwisko, 
    SUM(r.godz) AS laczna_liczba_godzin
FROM wykladowcy@dblinkFilia w
JOIN kursy@dblinkFilia k ON w.wykladowca_id = k.wykladowca_id
JOIN rodzaje@dblinkFilia r ON k.rodzaj_id = r.rodzaj_id
GROUP BY w.imie, w.nazwisko;

zad7

CREATE MATERIALIZED VIEW REP_kursy
BUILD IMMEDIATE
REFRESH COMPLETE
NEXT SYSDATE + 7
AS
SELECT 
    r.nazwa AS nazwa_kursu, 
    w.imie, 
    w.nazwisko, 
    r.godz AS ilosc_godzin, 
    r.cena AS oplata_za_kurs
FROM kursy@dblinkFilia k
JOIN rodzaje@dblinkFilia r ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcy@dblinkFilia w ON k.wykladowca_id = w.wykladowca_id;

zad 8

CREATE OR REPLACE VIEW kursy_Siedziba_i_Filia_V AS
-- Dane pobierane na żywo z Siedziby (Bydgoszcz)
SELECT 
    r.nazwa AS nazwa_kursu, 
    w.imie, 
    w.nazwisko, 
    r.godz AS ilosc_godzin, 
    r.cena AS oplata_za_kurs,
    'SIEDZIBA' AS lokalizacja
FROM kursy k
JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id

UNION ALL

-- Dane pobierane z Twojej migawki (Filia - Szczecin)
SELECT 
    nazwa_kursu, 
    imie, 
    nazwisko, 
    ilosc_godzin, 
    oplata_za_kurs,
    'FILIA' AS lokalizacja
FROM REP_kursy;

zad 9

SELECT 
    mview_name,            -- Nazwa migawki 
    last_refresh_date,     -- Kiedy ostatnio zaciągnęła dane [cite: 154]
    next_refresh_date,     -- Kiedy planuje następny skok po dane [cite: 154]
    refresh_method,        -- Czy robi to w trybie COMPLETE czy FAST [cite: 154]
    refresh_mode           -- Czy odświeża się ON DEMAND czy inaczej [cite: 154]
FROM USER_MVIEWS;




SELECT 
    mview_name, 
    query 
FROM USER_MVIEWS;
