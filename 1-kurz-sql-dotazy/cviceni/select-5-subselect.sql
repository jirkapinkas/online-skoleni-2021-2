-- S601:
SELECT z.prijmeni, z.jmeno, z.plat
FROM AERO.zamestnanec z, AERO.pilot p 
WHERE z.zamestnanec_id = p.zamestnanec_id
AND z.plat > (
  SELECT AVG(z.plat) AS prumerny_plat_pilota FROM AERO.zamestnanec z, AERO.pilot p
  WHERE z.zamestnanec_id = p.zamestnanec_id
)
ORDER BY z.prijmeni, z.jmeno;

-- S602:
SELECT z.prijmeni, z.jmeno FROM AERO.zamestnanec z, AERO.pilot p, AERO.let l
WHERE z.zamestnanec_id = p.zamestnanec_id AND p.pilot_id = l.pilot_id
GROUP BY z.prijmeni, z.jmeno
HAVING COUNT(l.cislo_letu) > (
  SELECT COUNT(l.cislo_letu) AS pocet_letu_pilota FROM AERO.zamestnanec z, AERO.pilot p, AERO.let l 
  WHERE z.zamestnanec_id = p.zamestnanec_id AND p.pilot_id = l.pilot_id
  AND z.jmeno = 'Zuzana' AND z.prijmeni = 'Komárková'
)
ORDER BY z.prijmeni, z.jmeno;

-- S603:
SELECT DISTINCT pa.prijmeni, pa.jmeno
FROM AERO.pasazer pa, AERO.ucastnik_letu ul, AERO.let l
WHERE pa.pasazer_id = ul.pasazer_id AND ul.cislo_letu = l.cislo_letu
AND l.pilot_id IN (
  SELECT pilot_id FROM AERO.let
  GROUP BY pilot_id
  HAVING COUNT(pilot_id) = 1
)
ORDER BY pa.prijmeni, pa.jmeno;

-- S604:
SELECT z.prijmeni, z.jmeno FROM AERO.zamestnanec z, AERO.pilot p, AERO.let l 
WHERE z.zamestnanec_id = p.zamestnanec_id AND p.pilot_id = l.pilot_id
GROUP BY p.pilot_id, z.prijmeni, z.jmeno
HAVING COUNT(l.cislo_letu) = (
  SELECT MAX(COUNT(l.cislo_letu)) AS max_pocet_letu_pilota FROM AERO.let l
  GROUP BY l.pilot_id
);

-- S605:
-- celkovy pocet naletanych km pro jednotlive piloty
SELECT z.prijmeni, z.jmeno, p.pilot_id,  
  NVL((
    -- celkovy pocet km naletanych pilotem
    SELECT SUM(zast.km_od_minule_zastavky) AS km_na_letu
    FROM AERO.zastavka zast, AERO.letova_linka ll, AERO.let l 
    WHERE zast.cislo_letove_linky = ll.cislo_letove_linky 
    AND ll.cislo_letove_linky = l.cislo_letove_linky
    AND l.cislo_letu IN (
      -- lety absolvovane danym pilotem
      SELECT l.cislo_letu FROM AERO.let l WHERE l.pilot_id = p.pilot_id
    )
  ), 0) AS celkem_km
FROM AERO.zamestnanec z, AERO.pilot p 
WHERE z.zamestnanec_id = p.zamestnanec_id
ORDER BY z.prijmeni, z.jmeno;
-- NEBO RESENI POMOCI KLAUZULE WITH:
WITH LETY AS
  (SELECT LET.CISLO_LETU,
    SUM(ZASTAVKA.KM_OD_MINULE_ZASTAVKY) km
  FROM LET
  INNER JOIN LETOVA_LINKA
  ON LETOVA_LINKA.CISLO_LETOVE_LINKY = LET.CISLO_LETOVE_LINKY
  INNER JOIN ZASTAVKA
  ON LETOVA_LINKA.CISLO_LETOVE_LINKY = ZASTAVKA.CISLO_LETOVE_LINKY
  GROUP BY LET.CISLO_LETU
  ),
  PILOTI AS
  (SELECT ZAMESTNANEC.JMENO,
    ZAMESTNANEC.PRIJMENI,
    LET.CISLO_LETU
  FROM PILOT
  left JOIN LET
  ON PILOT.PILOT_ID = LET.PILOT_ID
  INNER JOIN ZAMESTNANEC
  ON ZAMESTNANEC.ZAMESTNANEC_ID = PILOT.ZAMESTNANEC_ID
  )
  SELECT JMENO, PRIJMENI, SUM(KM) FROM LETY RIGHT JOIN PILOTI
  ON LETY.CISLO_LETU = PILOTI.CISLO_LETU GROUP BY JMENO, PRIJMENI;
  
  
-- S606:
-- piloti (nebo jen jeden pilot), kteri naletali nejvice kilometru
SELECT z.prijmeni, z.jmeno 
FROM AERO.zamestnanec z, AERO.pilot p 
WHERE z.zamestnanec_id = p.zamestnanec_id 
AND 
-- celkovy pocet km naletanych pilotem 
-- = max pocet naletanych km ze vsech pilotu 
NVL((SELECT SUM(zast.km_od_minule_zastavky) AS celkem_km
FROM AERO.zastavka zast, AERO.letova_linka ll, AERO.let l 
WHERE zast.cislo_letove_linky = ll.cislo_letove_linky 
AND ll.cislo_letove_linky = l.cislo_letove_linky
AND l.cislo_letu IN (
  SELECT l.cislo_letu FROM AERO.let l WHERE l.pilot_id = p.pilot_id
)), 0) = (
  -- max pocet naletanych km ze vsech pilotu 
  SELECT 
    MAX(NVL((
      -- celkovy pocet km naletanych pilotem
      SELECT SUM(zast.km_od_minule_zastavky) AS km_na_letu
      FROM AERO.zastavka zast, AERO.letova_linka ll, AERO.let l 
      WHERE zast.cislo_letove_linky = ll.cislo_letove_linky 
      AND ll.cislo_letove_linky = l.cislo_letove_linky
      AND l.cislo_letu IN (
        -- lety absolvovane danym pilotem
        SELECT l.cislo_letu FROM AERO.let l WHERE l.pilot_id = p.pilot_id
      )
    ), 0)) AS max_km
  FROM AERO.zamestnanec z, AERO.pilot p 
  WHERE z.zamestnanec_id = p.zamestnanec_id
);
-- NEBO RESENI POMOCI KLAUZULE WITH:
WITH LETY AS
  (SELECT LET.CISLO_LETU,
    SUM(ZASTAVKA.KM_OD_MINULE_ZASTAVKY) km
  FROM LET
  INNER JOIN LETOVA_LINKA
  ON LETOVA_LINKA.CISLO_LETOVE_LINKY = LET.CISLO_LETOVE_LINKY
  INNER JOIN ZASTAVKA
  ON LETOVA_LINKA.CISLO_LETOVE_LINKY = ZASTAVKA.CISLO_LETOVE_LINKY
  GROUP BY LET.CISLO_LETU
  ),
  PILOTI AS
  (SELECT ZAMESTNANEC.JMENO,
    ZAMESTNANEC.PRIJMENI,
    LET.CISLO_LETU
  FROM PILOT
  LEFT JOIN LET
  ON PILOT.PILOT_ID = LET.PILOT_ID
  INNER JOIN ZAMESTNANEC
  ON ZAMESTNANEC.ZAMESTNANEC_ID = PILOT.ZAMESTNANEC_ID
  )
SELECT JMENO,
  PRIJMENI,
  SUM(KM)
FROM LETY
RIGHT JOIN PILOTI
ON LETY.CISLO_LETU = PILOTI.CISLO_LETU
GROUP BY JMENO,
  PRIJMENI
HAVING SUM(KM) =
  (SELECT MAX(SUM(KM))
  FROM LETY
  JOIN PILOTI
  ON LETY.CISLO_LETU = PILOTI.CISLO_LETU
  GROUP BY JMENO,
    PRIJMENI
  );

-- S607:
SELECT ZAMESTNANEC.JMENO,
  zamestnanec.prijmeni,
  ((COUNT(LET.CISLO_LETU) * 100) / (select 
  sum(COUNT(LET.CISLO_LETU))
from zamestnanec
inner JOIN PILOT
ON ZAMESTNANEC.ZAMESTNANEC_ID = PILOT.ZAMESTNANEC_ID
inner JOIN LET
ON PILOT.PILOT_ID = LET.PILOT_ID
group by zamestnanec.jmeno,
  ZAMESTNANEC.PRIJMENI)) procent
FROM ZAMESTNANEC
inner JOIN PILOT
ON ZAMESTNANEC.ZAMESTNANEC_ID = PILOT.ZAMESTNANEC_ID
left JOIN LET
ON PILOT.PILOT_ID = LET.PILOT_ID
GROUP BY ZAMESTNANEC.JMENO,
  zamestnanec.prijmeni
order by procent desc;

--S608:
SELECT typ_letadla.nazev,
  SUM(ucastnik_letu.cena),
  ((SUM(ucastnik_letu.cena) * 100) /
  (SELECT SUM(UCASTNIK_LETU.CENA) FROM UCASTNIK_LETU
  ) )
FROM TYP_LETADLA
INNER JOIN LETADLO
ON TYP_LETADLA.TYP_LETADLA_ID = LETADLO.TYP_LETADLA_ID
INNER JOIN LET
ON LETADLO.LETADLO_ID = LET.LETADLO_ID
INNER JOIN UCASTNIK_LETU
ON LET.CISLO_LETU = UCASTNIK_LETU.CISLO_LETU
GROUP BY TYP_LETADLA.NAZEV
ORDER BY SUM(UCASTNIK_LETU.CENA) DESC

-- S610:


-- S611:
SELECT (avg_plat - min_plat) rozdil 
FROM
  ( -- dotaz pro zjisteni prumerneho platu pilota
    SELECT AVG(z.plat) avg_plat 
    FROM AERO.zamestnanec z, AERO.pilot p
    WHERE z.zamestnanec_id = p.zamestnanec_id
  ) avg_plat,
  ( -- dotaz pro zjisteni minimalniho platu
    SELECT MIN(plat) min_plat FROM AERO.zamestnanec
  ) min_plat;

-- nebo (mensi narocnost)
SELECT 
  (
    (SELECT AVG(z.plat) avg_plat FROM AERO.zamestnanec z, AERO.pilot p WHERE z.zamestnanec_id = p.zamestnanec_id ) 
    - 
    (SELECT MIN(plat) min_plat FROM AERO.zamestnanec)
  ) rozdil  
FROM dual;

-- S612:
SELECT z.jmeno, z.prijmeni, z.plat
FROM AERO.zamestnanec z, AERO.pilot p
WHERE z.zamestnanec_id = p.zamestnanec_id
  AND plat = ( -- dotaz pro zjisteni maximalniho platu pilota
    SELECT MAX(plat) FROM AERO.zamestnanec z_vnitrni, AERO.pilot p_vnitrni
    WHERE z_vnitrni.zamestnanec_id = p_vnitrni.zamestnanec_id
  );
  
-- nebo s použitím exists ve vnitøní funkci
SELECT z.jmeno, z.prijmeni, z.plat
FROM AERO.zamestnanec z, AERO.pilot p
WHERE z.zamestnanec_id = p.zamestnanec_id
  AND plat = ( -- dotaz pro zjisteni maximalniho platu pilota
    SELECT MAX(z_vnitrni.plat) FROM AERO.zamestnanec z_vnitrni
    WHERE exists (SELECT 1 FROM AERO.pilot WHERE zamestnanec_id = z_vnitrni.zamestnanec_id)
  );
  
-- S613:
SELECT SUM(plat) soucet FROM AERO.zamestnanec
WHERE aktivni = 'y' 
  AND zamestnanec_id NOT IN (SELECT zamestnanec_id FROM AERO.pilot)
  AND plat < (SELECT AVG(plat) FROM AERO.zamestnanec);

-- S900:
SELECT * FROM (
  -- zacatek vlastniho dotazu
  SELECT prijmeni, jmeno FROM AERO.zamestnanec
  WHERE aktivni = 'y'
  ORDER BY prijmeni, jmeno
  -- konec vlastniho dotazu
)
WHERE ROWNUM <= 20;

-- S901:
SELECT * FROM (
  SELECT ROWNUM AS row_num_for_pagination, x.* FROM (
    -- zacatek vlastniho dotazu
    SELECT prijmeni, jmeno FROM AERO.zamestnanec
    WHERE aktivni = 'y'
    ORDER BY prijmeni, jmeno
    -- konec vlastniho dotazu
  ) x WHERE ROWNUM <= 15
)
WHERE row_num_for_pagination >= 6;

-- S902:
SELECT *
FROM
  (SELECT destinace.nazev,
    COUNT(let.cislo_letu)
  FROM zastavka
  INNER JOIN letova_linka
  ON letova_linka.cislo_letove_linky = zastavka.cislo_letove_linky
  INNER JOIN let
  ON letova_linka.cislo_letove_linky = let.cislo_letove_linky
  INNER JOIN destinace
  ON destinace.destinace_id = zastavka.destinace_id
  GROUP BY destinace.nazev
  ORDER BY COUNT(let.cislo_letu) DESC
  )
WHERE rownum <= 3;

-- S950:
CREATE TABLE AERO.typ_letadla_bak AS SELECT * FROM AERO.typ_letadla;

-- S951:
INSERT INTO AERO.typ_letadla_bak (typ_letadla_id, nazev, pocet_mist) 
SELECT typ_letadla_id, nazev, pocet_mist FROM AERO.typ_letadla;
-- nebo
INSERT INTO AERO.typ_letadla_bak 
SELECT * FROM AERO.typ_letadla; -
