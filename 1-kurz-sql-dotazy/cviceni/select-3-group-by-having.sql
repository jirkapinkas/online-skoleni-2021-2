-- S300_0:
SELECT hodnost, COUNT(*) pocet FROM AERO.pilot
GROUP BY hodnost;

-- S300:
SELECT tl.typ_letadla_id, tl.nazev, COUNT(l.letadlo_id) AS pocet_letadel
FROM AERO.typ_letadla tl, AERO.letadlo l
WHERE tl.typ_letadla_id = l.typ_letadla_id
GROUP BY tl.typ_letadla_id, tl.nazev;

-- S301:
SELECT tl.typ_letadla_id, tl.nazev, COUNT(l.letadlo_id) AS pocet_letadel
FROM AERO.typ_letadla tl, AERO.letadlo l
WHERE tl.typ_letadla_id = l.typ_letadla_id
GROUP BY tl.typ_letadla_id, tl.nazev
HAVING COUNT(l.letadlo_id) >=2
ORDER BY tl.nazev;

-- S302:
SELECT lt.cislo_letu, ll.nazev AS nazev_linky, z.jmeno AS jmeno_pilota, 
z.prijmeni AS prijmeni_pilota, tl.nazev AS typ_letadla, 
lt.cas_odletu, SUM(ul.cena) AS zisk
FROM AERO.ucastnik_letu ul, AERO.let lt, AERO.letadlo ld, AERO.typ_letadla tl, 
AERO.letova_linka ll, AERO.pilot p, AERO.zamestnanec z
WHERE ul.cislo_letu = lt.cislo_letu 
AND lt.cislo_letove_linky = ll.cislo_letove_linky AND lt.pilot_id = p.pilot_id
AND p.zamestnanec_id = z.zamestnanec_id AND lt.letadlo_id = ld.letadlo_id
AND ld.typ_letadla_id = tl.typ_letadla_id
GROUP BY lt.cislo_letu, ll.nazev, z.jmeno, z.prijmeni, tl.nazev, lt.cas_odletu
ORDER BY lt.cas_odletu DESC;

-- S303:
SELECT lt.cislo_letu, ll.nazev AS nazev_linky, z.jmeno AS jmeno_pilota, 
z.prijmeni AS prijmeni_pilota, tl.nazev AS typ_letadla, 
lt.cas_odletu, SUM(ul.cena) AS zisk, COUNT(ul.pasazer_id) AS pocet_pasazeru, 
tl.pocet_mist mist_celkem
FROM AERO.ucastnik_letu ul, AERO.let lt, AERO.letadlo ld, AERO.typ_letadla tl, 
AERO.letova_linka ll, AERO.pilot p, AERO.zamestnanec z
WHERE ul.cislo_letu = lt.cislo_letu 
AND lt.cislo_letove_linky = ll.cislo_letove_linky AND lt.pilot_id = p.pilot_id
AND p.zamestnanec_id = z.zamestnanec_id AND lt.letadlo_id = ld.letadlo_id
AND ld.typ_letadla_id = tl.typ_letadla_id
GROUP BY lt.cislo_letu, ll.nazev, z.jmeno, z.prijmeni, tl.nazev, 
lt.cas_odletu, tl.pocet_mist
HAVING SUM(ul.cena) < 20000
ORDER BY lt.cas_odletu DESC;

-- S304:
SELECT AVG(SUM(cena)) AS prumerny_zisk_letu FROM AERO.ucastnik_letu
GROUP BY cislo_letu;
-- GROUP BY se aplikuje na prvni agregacni funkci SUM

-- S305:
SELECT tl.nazev FROM AERO.typ_letadla tl, AERO.letadlo l, AERO.let let
WHERE tl.typ_letadla_id = l.typ_letadla_id AND l.letadlo_id = let.letadlo_id
GROUP BY tl.nazev
HAVING COUNT(let.cislo_letu) >= 2;

-- S306:
SELECT LET.CISLO_LETU,
  COUNT(PASAZER.PASAZER_ID) AS pocet_problem_pasazeru
FROM LET
INNER JOIN UCASTNIK_LETU
ON LET.CISLO_LETU = UCASTNIK_LETU.CISLO_LETU
INNER JOIN PASAZER
ON PASAZER.PASAZER_ID       = UCASTNIK_LETU.PASAZER_ID
WHERE PASAZER.PROBLEMATICKY = 'y'
GROUP BY LET.CISLO_LETU
ORDER BY COUNT(PASAZER.PASAZER_ID) DESC;

-- S307:
SELECT DESTINACE.NAZEV,
  SUM(UCASTNIK_LETU.CENA)
FROM UCASTNIK_LETU
INNER JOIN DESTINACE
ON DESTINACE.DESTINACE_ID = UCASTNIK_LETU.KAM
GROUP BY DESTINACE.NAZEV
ORDER BY SUM(UCASTNIK_LETU.CENA) DESC

-- S308:
SELECT LETOVA_LINKA.NAZEV,
  COUNT(ZASTAVKA.PORADI_ZASTAVKY)
FROM LETOVA_LINKA
INNER JOIN ZASTAVKA
ON LETOVA_LINKA.CISLO_LETOVE_LINKY = ZASTAVKA.CISLO_LETOVE_LINKY
GROUP BY LETOVA_LINKA.NAZEV
ORDER BY COUNT(ZASTAVKA.PORADI_ZASTAVKY) DESC

-- S309:
SELECT COUNT(PASAZER.PROBLEMATICKY),
  LETOVA_LINKA.NAZEV
FROM LET
INNER JOIN UCASTNIK_LETU
ON LET.CISLO_LETU = UCASTNIK_LETU.CISLO_LETU
INNER JOIN PASAZER
ON PASAZER.PASAZER_ID = UCASTNIK_LETU.PASAZER_ID
INNER JOIN LETOVA_LINKA
ON LETOVA_LINKA.CISLO_LETOVE_LINKY = LET.CISLO_LETOVE_LINKY
where PASAZER.PROBLEMATICKY        = 'y'
GROUP BY LETOVA_LINKA.NAZEV

-- X104:
select nazev_pozice, listagg(jmeno || ' ' || prijmeni, ', ') within group (order by jmeno) zamestnanci
from zamestnanec
join zamestnani
using (zamestnani_id)
group by nazev_pozice;

-- X106:
select jmeno || ' ' || prijmeni, listagg(nazev, ', ') within group (order by nazev)
from pasazer
join ucastnik_letu
using (pasazer_id)
join destinace
on kam = destinace_id
group by jmeno, prijmeni