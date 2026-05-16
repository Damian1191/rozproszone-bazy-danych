zad 1.
DECLARE
    v_liczba_kursantow NUMBER;
    v_liczba_kursow NUMBER;
    v_liczba_wykladowcow NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_liczba_kursantow FROM kursanci;
    SELECT COUNT(*) INTO v_liczba_kursow FROM kursy;
    SELECT COUNT(*) INTO v_liczba_wykladowcow FROM wykladowcy;

    DBMS_OUTPUT.PUT_LINE('Liczba kursantów: ' || v_liczba_kursantow);
    DBMS_OUTPUT.PUT_LINE('Liczba kursów: ' || v_liczba_kursow);
    DBMS_OUTPUT.PUT_LINE('Liczba wykładowców: ' || v_liczba_wykladowcow);
END;
/
zad.2
DECLARE
    v_laczna_wartosc NUMBER;
BEGIN
    -- Łączymy tabele, aby dostać się do ceny kursu (zakładamy, że cena jest w tabeli 'rodzaje')
    SELECT NVL(SUM(r.cena), 0) INTO v_laczna_wartosc
    FROM umowy u
    JOIN kursy k ON u.kurs_id = k.kurs_id
    JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = 'BYDGOSZCZ';

    DBMS_OUTPUT.PUT_LINE('Łączna wartość umów dla BYDGOSZCZY: ' || v_laczna_wartosc || ' zł');
END;
/
zad 3.
DECLARE
    v_miasto VARCHAR2(50) := 'BYDGOSZCZ';
    v_liczba_umow NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_liczba_umow
    FROM umowy
    WHERE miasto = v_miasto;

    IF v_liczba_umow = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Brak umów dla miasta');
    ELSIF v_liczba_umow < 50 THEN
        DBMS_OUTPUT.PUT_LINE('Mała liczba umów');
    ELSIF v_liczba_umow BETWEEN 50 AND 100 THEN
        DBMS_OUTPUT.PUT_LINE('Średnia liczba umów');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Duża liczba umów');
    END IF;
END;
/
zad.4.
  BEGIN
    FOR r IN (
        SELECT k.kurs_id, ro.nazwa, ro.liczba_godzin, ro.cena, w.imie, w.nazwisko
        FROM kursy k
        JOIN rodzaje ro ON k.rodzaj_id = ro.rodzaj_id
        JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Kurs ' || r.kurs_id || ': ' || r.nazwa || ', ' || 
                             r.liczba_godzin || 'h, ' || r.cena || ' zł, prowadzący: ' || 
                             r.imie || ' ' || r.nazwisko);
    END LOOP;
END;
/
zad 5.
CREATE OR REPLACE PROCEDURE raport_umow_miasto(p_miasto IN VARCHAR2)
IS
    v_liczba_umow NUMBER;
    v_laczna_wartosc NUMBER;
    v_srednia_wartosc NUMBER;
BEGIN
    SELECT COUNT(*), NVL(SUM(r.cena), 0), NVL(AVG(r.cena), 0)
    INTO v_liczba_umow, v_laczna_wartosc, v_srednia_wartosc
    FROM umowy u
    JOIN kursy k ON u.kurs_id = k.kurs_id
    JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = p_miasto;

    DBMS_OUTPUT.PUT_LINE('Raport dla miasta: ' || p_miasto);
    DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_liczba_umow);
    DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || v_laczna_wartosc || ' zł');
    DBMS_OUTPUT.PUT_LINE('Średnia wartość umowy: ' || ROUND(v_srednia_wartosc, 2) || ' zł');
END;
/

zad 6.
CREATE OR REPLACE FUNCTION wartosc_kursu(p_kurs_id IN NUMBER)
RETURN NUMBER
IS
    v_cena NUMBER;
BEGIN
    SELECT r.cena
    INTO v_cena
    FROM kursy k
    JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
    WHERE k.kurs_id = p_kurs_id;

    RETURN v_cena;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Wariant rozszerzony: zwracamy 0 w przypadku braku kursu
        RETURN 0;
END;
/
 zad 7.
CREATE OR REPLACE PROCEDURE pokaz_kursanta(p_kursant_id IN NUMBER)
IS
    v_imie kursanci.imie%TYPE;
    v_nazwisko kursanci.nazwisko%TYPE;
BEGIN
    SELECT imie, nazwisko
    INTO v_imie, v_nazwisko
    FROM kursanci
    WHERE kursant_id = p_kursant_id;

    DBMS_OUTPUT.PUT_LINE(v_imie || ' ' || v_nazwisko);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta o ID: ' || p_kursant_id);
END;
/

zad.8.
  DECLARE
    CURSOR c_umowy IS
        SELECT u.umowa_id, ku.imie, ku.nazwisko, r.nazwa, r.cena
        FROM umowy u
        JOIN kursanci ku ON u.kursant_id = ku.kursant_id
        JOIN kursy k ON u.kurs_id = k.kurs_id
        JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
        WHERE u.miasto = 'BYDGOSZCZ';

    v_umowa c_umowy%ROWTYPE;
BEGIN
    OPEN c_umowy;
    LOOP
        FETCH c_umowy INTO v_umowa;
        EXIT WHEN c_umowy%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE('Umowa ' || v_umowa.umowa_id || ' | ' || 
                             v_umowa.imie || ' ' || v_umowa.nazwisko || ' | ' || 
                             v_umowa.nazwa || ' | ' || v_umowa.cena || ' zł');
    END LOOP;
    CLOSE c_umowy;
END;
/

zad.9.
  CREATE OR REPLACE PROCEDURE raport_umow_szczecin
IS
BEGIN
    -- Używamy tabel z bazy lokalnej (umowy) oraz migawek danych filii
    FOR r IN (
        SELECT u.umowa_id, kf.imie, kf.nazwisko, rf.nazwa, rf.cena, u.miasto
        FROM umowy u
        JOIN mv_kursanci_filia kf ON u.kursant_id = kf.kursant_id
        JOIN mv_kursy_filia k ON u.kurs_id = k.kurs_id
        JOIN mv_rodzaje_filia rf ON k.rodzaj_id = rf.rodzaj_id
        WHERE u.miasto = 'SZCZECIN'
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Umowa ' || r.umowa_id || ' | ' || 
                             r.imie || ' ' || r.nazwisko || ' | ' || 
                             r.nazwa || ' | ' || r.cena || ' zł | ' || r.miasto);
    END LOOP;
END;
/
zad.10.
  CREATE OR REPLACE PROCEDURE raport_uczelni
IS
    -- Zmienne statystyczne dla Bydgoszczy
    v_b_liczba NUMBER := 0;
    v_b_wartosc NUMBER := 0;
    v_b_max_cena NUMBER := 0;
    v_b_najdrozdzy VARCHAR2(100);
    v_b_najpopularniejszy VARCHAR2(100);

    -- Zmienne statystyczne dla Szczecina
    v_s_liczba NUMBER := 0;
    v_s_wartosc NUMBER := 0;
    v_s_max_cena NUMBER := 0;
    v_s_najdrozdzy VARCHAR2(100);
    v_s_najpopularniejszy VARCHAR2(100);
BEGIN
    DBMS_OUTPUT.PUT_LINE('RAPORT UCZELNI');
    DBMS_OUTPUT.PUT_LINE('------------------------------------');

    SELECT COUNT(*), NVL(SUM(r.cena), 0)
    INTO v_b_liczba, v_b_wartosc
    FROM umowy u
    JOIN kursy k ON u.kurs_id = k.kurs_id
    JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = 'BYDGOSZCZ';

    -- Najdroższy kurs (Bydgoszcz)
    BEGIN
        SELECT nazwa, cena INTO v_b_najdrozdzy, v_b_max_cena
        FROM (SELECT r.nazwa, r.cena FROM rodzaje r ORDER BY r.cena DESC)
        WHERE ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_b_najdrozdzy := 'Brak'; v_b_max_cena := 0; END;

    -- Najpopularniejszy kurs (Bydgoszcz)
    BEGIN
        SELECT nazwa INTO v_b_najpopularniejszy
        FROM (
            SELECT r.nazwa, COUNT(*) as popularnosc
            FROM umowy u
            JOIN kursy k ON u.kurs_id = k.kurs_id
            JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
            WHERE u.miasto = 'BYDGOSZCZ'
            GROUP BY r.nazwa
            ORDER BY popularnosc DESC
        ) WHERE ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_b_najpopularniejszy := 'Brak'; END;

    -- Wypisanie Bydgoszczy
    DBMS_OUTPUT.PUT_LINE('Miasto: BYDGOSZCZ');
    DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_b_liczba);
    DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || v_b_wartosc || ' zł');
    DBMS_OUTPUT.PUT_LINE('Najdroższy kurs: ' || v_b_najdrozdzy || ' (' || v_b_max_cena || ' zł)');
    DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || v_b_najpopularniejszy);
    DBMS_OUTPUT.PUT_LINE('');

    SELECT COUNT(*), NVL(SUM(rf.cena), 0)
    INTO v_s_liczba, v_s_wartosc
    FROM umowy u
    JOIN mv_kursy_filia k ON u.kurs_id = k.kurs_id
    JOIN mv_rodzaje_filia rf ON k.rodzaj_id = rf.rodzaj_id
    WHERE u.miasto = 'SZCZECIN';

    -- Najdroższy kurs (Szczecin)
    BEGIN
        SELECT nazwa, cena INTO v_s_najdrozdzy, v_s_max_cena
        FROM (SELECT rf.nazwa, rf.cena FROM mv_rodzaje_filia rf ORDER BY rf.cena DESC)
        WHERE ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_s_najdrozdzy := 'Brak'; v_s_max_cena := 0; END;

    -- Najpopularniejszy kurs (Szczecin)
    BEGIN
        SELECT nazwa INTO v_s_najpopularniejszy
        FROM (
            SELECT rf.nazwa, COUNT(*) as popularnosc
            FROM umowy u
            JOIN mv_kursy_filia k ON u.kurs_id = k.kurs_id
            JOIN mv_rodzaje_filia rf ON k.rodzaj_id = rf.rodzaj_id
            WHERE u.miasto = 'SZCZECIN'
            GROUP BY rf.nazwa
            ORDER BY popularnosc DESC
        ) WHERE ROWNUM = 1;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_s_najpopularniejszy := 'Brak'; END;

    -- Wypisanie Szczecina
    DBMS_OUTPUT.PUT_LINE('Miasto: SZCZECIN');
    DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_s_liczba);
    DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: ' || v_s_wartosc || ' zł');
    DBMS_OUTPUT.PUT_LINE('Najdroższy kurs: ' || v_s_najdrozdzy || ' (' || v_s_max_cena || ' zł)');
    DBMS_OUTPUT.PUT_LINE('Najpopularniejszy kurs: ' || v_s_najpopularniejszy);
    DBMS_OUTPUT.PUT_LINE('');

    -- ==============================================
    -- PODSUMOWANIE CAŁKOWITE
    -- ==============================================
    DBMS_OUTPUT.PUT_LINE('PODSUMOWANIE');
    DBMS_OUTPUT.PUT_LINE('Liczba wszystkich umów: ' || (v_b_liczba + v_s_liczba));
    DBMS_OUTPUT.PUT_LINE('Łączna wartość wszystkich umów: ' || (v_b_wartosc + v_s_wartosc) || ' zł');
END;
/

