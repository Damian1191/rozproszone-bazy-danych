zad 5

Baza 11a
CREATE SYNONYM wykladowcySiedziba FOR wykladowcy;
CREATE SYNONYM kursanciSiedziba FOR kursanci;
CREATE SYNONYM rodzajeSiedziba FOR rodzaje;
CREATE SYNONYM kursySiedziba FOR kursy;

Baza 12b

CREATE SYNONYM wykladowcyFilia FOR wykladowcy@dblinkFilia;
CREATE SYNONYM kursanciFilia FOR kursanci@dblinkFilia;
CREATE SYNONYM rodzajeFilia FOR rodzaje@dblinkFilia;
CREATE SYNONYM kursyFilia FOR kursy@dblinkFilia;


zad 6

Widok kursantow

CREATE OR REPLACE VIEW kursanciAll AS
SELECT imie, nazwisko FROM kursanciSiedziba
UNION
SELECT imie, nazwisko FROM kursanciFilia;

Widok Wykladowcow 

CREATE OR REPLACE VIEW wykladowcyAll AS
SELECT imie, nazwisko FROM wykladowcySiedziba
UNION
SELECT imie, nazwisko FROM wykladowcyFilia;


zad7

CREATE OR REPLACE VIEW kursyAll AS
-- Kursy z Siedziby (Bydgoszcz)
SELECT 
    r.nazwa AS nazwa_kursu, 
    w.imie || ' ' || w.nazwisko AS prowadzący, 
    COUNT(u.kursant_id) AS liczba_uczestników
FROM kursySiedziba k
JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id
LEFT JOIN umowy u ON k.kurs_id = u.kurs_id AND u.miasto = 'BYDGOSZCZ'
GROUP BY r.nazwa, w.imie, w.nazwisko

UNION ALL

-- Kursy z Filii (Szczecin)
SELECT 
    r.nazwa, 
    w.imie || ' ' || w.nazwisko, 
    COUNT(u.kursant_id)
FROM kursyFilia k
JOIN rodzajeFilia r ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcyFilia w ON k.wykladowca_id = w.wykladowca_id
LEFT JOIN umowy u ON k.kurs_id = u.kurs_id AND u.miasto = 'SZCZECIN'
GROUP BY r.nazwa, w.imie, w.nazwisko;


zad 8

SELECT SUM(przychody_z_kursu) AS przychod_calkowity
FROM (
    -- Przychód z Siedziby (Bydgoszcz)
    SELECT COUNT(u.kursant_id) * r.cena AS przychody_z_kursu
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    JOIN umowy u ON k.kurs_id = u.kurs_id
    WHERE u.miasto = 'BYDGOSZCZ'
    GROUP BY k.kurs_id, r.cena

    UNION ALL

    -- Przychód z Filii (Szczecin)
    SELECT COUNT(u.kursant_id) * r.cena
    FROM kursyFilia k
    JOIN rodzajeFilia r ON k.rodzaj_id = r.rodzaj_id
    JOIN umowy u ON k.kurs_id = u.kurs_id
    WHERE u.miasto = 'SZCZECIN'
    GROUP BY k.kurs_id, r.cena
);


zad  9

SELECT SUM(koszt_kursu) AS koszty_calkowite
FROM (
    -- Koszty w Siedzibie (Bydgoszcz)
    SELECT r.godz * w.stawka AS koszt_kursu
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id

    UNION ALL

    -- Koszty w Filii (Szczecin)
    SELECT r.godz * w.stawka
    FROM kursyFilia k
    JOIN rodzajeFilia r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcyFilia w ON k.wykladowca_id = w.wykladowca_id
);

zad 10

SELECT 
    lokalizacja,
    nazwa_kursu,
    przychod,
    koszt,
    (przychod - koszt) AS zysk_strata
FROM (
    -- Analiza dla Siedziby (Bydgoszcz)
    SELECT 
        'SIEDZIBA' AS lokalizacja,
        r.nazwa AS nazwa_kursu,
        (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = k.kurs_id AND u.miasto = 'BYDGOSZCZ') * r.cena AS przychod,
        r.godz * w.stawka AS koszt
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id

    UNION ALL

    -- Analiza dla Filii (Szczecin)
    SELECT 
        'FILIA' AS lokalizacja,
        r.nazwa,
        (SELECT COUNT(*) FROM umowy u WHERE u.kurs_id = k.kurs_id AND u.miasto = 'SZCZECIN') * r.cena AS przychod,
        r.godz * w.stawka AS koszt
    FROM kursyFilia k
    JOIN rodzajeFilia r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcyFilia w ON k.wykladowca_id = w.wykladowca_id
)
ORDER BY zysk_strata DESC;



zad 11

SELECT SUM(przychod - koszt) AS laczny_zysk_ogolem
FROM (
    -- Wyniki finansowe z Siedziby (Bydgoszcz)
    SELECT 
        (SELECT COUNT(*) FROM umowy u 
         WHERE u.kurs_id = k.kurs_id AND u.miasto = 'BYDGOSZCZ') * r.cena AS przychod,
        r.godz * w.stawka AS koszt
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcySiedziba w ON k.wykladowca_id = w.wykladowca_id

    UNION ALL

    -- Wyniki finansowe z Filii (Szczecin)
    SELECT 
        (SELECT COUNT(*) FROM umowy u 
         WHERE u.kurs_id = k.kurs_id AND u.miasto = 'SZCZECIN') * r.cena AS przychod,
        r.godz * w.stawka AS koszt
    FROM kursyFilia k
    JOIN rodzajeFilia r ON k.rodzaj_id = r.rodzaj_id
    JOIN wykladowcyFilia w ON k.wykladowca_id = w.wykladowca_id
);
