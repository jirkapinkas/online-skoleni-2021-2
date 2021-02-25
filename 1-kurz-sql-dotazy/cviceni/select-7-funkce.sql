-- F100
SELECT jmeno, prijmeni, ROUND(plat, -4) as plat_desitky_tisic FROM AERO.zamestnanec;


-- F200
SELECT CONCAT(jmeno, CONCAT(' ', prijmeni))  AS cele_jmeno FROM AERO.zamestnanec;
-- nebo
SELECT jmeno || ' ' || prijmeni AS cele_jmeno FROM AERO.zamestnanec;


-- F201
SELECT jmeno, prijmeni, SUBSTR(jmeno, 0, 1) || SUBSTR(prijmeni, 0, 1) as inicialy from AERO.zamestnanec;


-- F202
SELECT l.letadlo_id, tl.nazev, l.datum_porizeni FROM AERO.typ_letadla tl, AERO.letadlo l
WHERE tl.typ_letadla_id = l.typ_letadla_id
  AND INSTR(tl.nazev,'Airbus') > 0;
-- nebo
SELECT l.letadlo_id, tl.nazev, l.datum_porizeni FROM AERO.typ_letadla tl, AERO.letadlo l
WHERE tl.typ_letadla_id = l.typ_letadla_id
  AND tl.nazev LIKE '%Airbus%';


-- F203
-- pokud predpokladame vyskyt pouze oznaceni OK
SELECT REPLACE(cislo_letu,'OK') AS cislo FROM AERO.let;
-- cela abeceda
SELECT REPLACE(TRANSLATE(LOWER(cislo_letu),'abcdefghijklmnopqrstuvxyz','x'),'x') AS cislo FROM AERO.let;

-- F204
select 'OK' || lpad(substr(cislo_letu, 3), 3, '0') from let;

-- F205
select jmeno || ' ' || upper(prijmeni) zamestnanec, plat || ',-Kc' plat from zamestnanec;

-- F206
select replace(nazev, '-', '->') nazev from letova_linka;

-- F207
select popis_prace from zamestnani
where lower(popis_prace) like '%kontrola%'

-- F300
SELECT jmeno, prijmeni, plat, to_char(datum_nastupu, 'YYYY-MM-DD HH24:MI:SS') AS datum_nastupu,
  to_char(datum_ukonceni, 'YYYY-MM-DD HH24:MI:SS') AS datum_ukonceni
FROM AERO.zamestnanec;

-- F301
SELECT sysdate - to_date('09-01-01','YY-MM-DD') from dual;

-- F302
SELECT mesice.mesic, COUNT(l.cislo_letu)  AS pocet_letu from 
(
  SELECT DISTINCT to_char(cas_odletu,'MM') AS mesic FROM AERO.let
) mesice,
(
  SELECT cislo_letu, to_char(cas_odletu,'MM') AS mesic FROM AERO.let WHERE to_char(cas_odletu,'YYYY') = '2009'
) l
WHERE mesice.mesic = l.mesic(+)
GROUP BY mesice.mesic
ORDER BY mesice.mesic;
-- nebo
SELECT mesice.mesic, COUNT(l.cislo_letu)  AS pocet_letu from 
(
  SELECT DISTINCT to_char(cas_odletu,'MM') AS mesic FROM AERO.let
) mesice
  LEFT JOIN (
    SELECT cislo_letu, to_char(cas_odletu,'MM') AS mesic FROM AERO.let WHERE to_char(cas_odletu,'YYYY') = '2009'
    ) l
    ON (mesice.mesic = l.mesic)
GROUP BY mesice.mesic
ORDER BY mesice.mesic;


-- F400
SELECT cislo_letu, cas_odletu FROM AERO.let WHERE cas_odletu < SYSDATE;


-- F401
SELECT z.jmeno, z.prijmeni, count(l.cislo_letu) as pocet_letu
FROM AERO.pilot p, AERO.let l, AERO.zamestnanec z 
WHERE l.pilot_id = p.pilot_id AND z.zamestnanec_id = p.zamestnanec_id
  AND l.cas_odletu BETWEEN TRUNC(NEXT_DAY(TO_DATE('17.02.2009','DD.MM.YYYY'), 1)) AND TRUNC(NEXT_DAY(NEXT_DAY(TO_DATE('17.02.2009','DD.MM.YYYY'), 1), 7))
GROUP BY z.jmeno, z.prijmeni;
-- nebo - bez použití BETWEEN
SELECT z.jmeno, z.prijmeni, count(l.cislo_letu) as pocet_letu
FROM AERO.pilot p, AERO.let l, AERO.zamestnanec z 
WHERE l.pilot_id = p.pilot_id AND z.zamestnanec_id = p.zamestnanec_id
  AND l.cas_odletu >= TRUNC(NEXT_DAY(TO_DATE('17.02.2009','DD.MM.YYYY'), 1)) AND l.cas_odletu <= TRUNC(NEXT_DAY(NEXT_DAY(TO_DATE('17.02.2009','DD.MM.YYYY'), 1), 7))
GROUP BY z.jmeno, z.prijmeni;


-- F402
SELECT ROUND(MONTHS_BETWEEN(ROUND(MAX(cas_odletu)), ROUND(MIN(cas_odletu)))) AS pocet_mesicu FROM AERO.let;


-- F403
SELECT z.poradi_zastavky, d.nazev, to_char(z.pravidelny_cas_odletu, 'HH24:MI:SS') AS pravidelny_cas_odletu,
  to_char(z.pravidelny_cas_odletu + (10/1440), 'HH24:MI:SS') AS zpozdeny_cas_odletu
FROM AERO.zastavka z, AERO.letova_linka ll, AERO.destinace d
WHERE ll.cislo_letove_linky = z.cislo_letove_linky AND z.destinace_id = d.destinace_id
  AND ll.nazev = 'Toronto - London - Prague - Moscow'
ORDER BY z.poradi_zastavky;


-- F500
SELECT z.jmeno, z.prijmeni, nvl(p.hodnost,'Není pilot') hodnost
FROM AERO.zamestnanec z
  LEFT JOIN AERO.pilot p ON (z.zamestnanec_id = p.zamestnanec_id);
-- nebo - zkrácená oracle syntace pro left join
SELECT z.jmeno, z.prijmeni, nvl(p.hodnost,'Není pilot') hodnost
FROM AERO.zamestnanec z, AERO.pilot p
WHERE z.zamestnanec_id = p.zamestnanec_id(+);


-- F501
SELECT jmeno, prijmeni, datum_ukonceni, NVL2(datum_ukonceni, 'Nepracuje', 'Pracuje') AS pracuje_ve_firme
FROM AERO.zamestnanec;

-- F502:
SELECT DESTINACE.NAZEV,
  nvl2(zastavka.destinace_id, 'létá', 'nelétá') "létá se?"
FROM DESTINACE
LEFT JOIN ZASTAVKA
ON DESTINACE.DESTINACE_ID = ZASTAVKA.DESTINACE_ID
GROUP BY DESTINACE.NAZEV,
  ZASTAVKA.DESTINACE_ID


-- F600
SELECT jmeno, prijmeni, plat, postaveni FROM (
  SELECT jmeno, prijmeni, plat, DECODE(nazev_pozice, 'Øeditel aerolinek', '1. Hlavní vedoucí', 
              'Hlavní dispeèer letového provozu', '2. Vedoucí', '3. Øadový zamìstnanec') AS postaveni  
  FROM AERO.zamestnanec zc, AERO.zamestnani zi
  WHERE zc.zamestnani_id = zi.zamestnani_id
)
ORDER BY postaveni ASC;

-- F601
SELECT A.JMENO
  || ' '
  || A.PRIJMENI zamestnanec,
  DECODE(B.JMENO
  || ' '
  || B.PRIJMENI, ' ', 'nema nadrizeneho', B.JMENO
  || ' '
  || B.PRIJMENI) NADRIZENY
FROM ZAMESTNANEC A
LEFT JOIN ZAMESTNANEC B
ON B.ZAMESTNANEC_ID = A.NADRIZENY

-- F602
SELECT jmeno,
  prijmeni,
  plat,
  postaveni
FROM
  (SELECT jmeno,
    prijmeni,
    plat,
    (
    CASE nazev_pozice
      WHEN 'Øeditel aerolinek'
      THEN '1. Hlavní vedoucí'
      WHEN 'Hlavní dispeèer letového provozu'
      THEN '2. Vedoucí'
      ELSE '3. Øadový zamìstnanec'
    END) AS postaveni
  FROM AERO.zamestnanec zc,
    AERO.zamestnani zi
  WHERE zc.zamestnani_id = zi.zamestnani_id
  )
ORDER BY postaveni ASC;

-- F603:
select decode(pasazer.problematicky, 'y', 'Poèet problematických pasažérù:', 'n', 'Poèet pohodových pasažérù:') typ,
  COUNT(PASAZER.PROBLEMATICKY) AS pocet
FROM PASAZER
GROUP BY PASAZER.PROBLEMATICKY;

-- F700:
SELECT trim( TRANSLATE(TO_CHAR(plat, '999,999,999,999'), ',', ' ') )
  || ',- Kè'
FROM zamestnanec;

--F701:
-- F701 Definice funkce:
CREATE OR REPLACE FUNCTION CASTKA 
(
  vstup IN NUMBER  
) RETURN VARCHAR2 AS 
BEGIN
  RETURN trim( TRANSLATE(TO_CHAR(vstup, '999,999,999,999'), ',', ' ') );
END CASTKA;

-- F701 Pouziti:
select castka(plat) from zamestnanec;