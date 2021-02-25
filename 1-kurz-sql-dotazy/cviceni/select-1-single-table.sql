-- S001:
SELECT jmeno, prijmeni, datum_nastupu FROM AERO.zamestnanec;

-- S002:
SELECT * FROM AERO.pasazer WHERE prijmeni LIKE 'K%';

-- S003:
SELECT * FROM AERO.typ_letadla;

-- S004:
SELECT * FROM AERO.zamestnanec WHERE plat >= 100000;

-- S005:
SELECT (3 * 4 + 6) || ' m2' AS vysledek FROM DUAL;

-- S006:
SELECT MAX(plat) FROM AERO.zamestnanec;

-- S007:
SELECT COUNT(*) AS aktualni_pocet_zamestnancu FROM AERO.zamestnanec
WHERE datum_ukonceni IS NULL;

-- S008:
SELECT 1 FROM dual;
-- lze pouzit pro validaci pripojeni k databazi (na pripojeni je mozne 
-- vykonavat dotazy)

-- S009:
SELECT jmeno || ' ' || prijmeni pasazer 
from pasazer 
where problematicky = 'y';

-- S010:
SELECT COUNT(LETADLO.LETADLO_ID) pocet_letadel
FROM LETADLO
WHERE LETADLO.PORIZOVACI_CENA > 1000000000;

-- S011:
SELECT MIN(ZAMESTNANEC.PLAT) AS min_plat,
  MAX(ZAMESTNANEC.PLAT)      AS max_plat,
  AVG(ZAMESTNANEC.PLAT)      AS avg_plat
FROM ZAMESTNANEC;

-- S012:
SELECT LET.CISLO_LETU,
  LET.CAS_ODLETU
FROM LET
WHERE LET.CAS_ODLETU > '1.6.2009'
ORDER BY LET.CAS_ODLETU;

-- S013:
SELECT LETOVA_LINKA.NAZEV
FROM LETOVA_LINKA
WHERE LETOVA_LINKA.NAZEV LIKE '%Prague%';

-- S014:
SELECT COUNT(PILOT.PILOT_ID) POCET_PILOTU_V_TRENINKU
FROM PILOT
WHERE PILOT.HODNOST = 'Trainee';

-- S015:
SELECT * FROM TYP_LETADLA
where POCET_MIST between 100 and 200

-- S016:
SELECT * FROM TYP_LETADLA
WHERE (NAZEV LIKE '%Airbus%' OR NAZEV LIKE '%Boeing%')
AND POCET_MIST < 150