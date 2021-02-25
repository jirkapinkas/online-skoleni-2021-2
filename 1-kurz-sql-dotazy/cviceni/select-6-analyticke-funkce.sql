-- X100:
SELECT *
FROM
  (SELECT jmeno,
    prijmeni,
    datum_nastupu              AS datum,
    MIN(datum_nastupu) over () AS max_datum,
    MAX(datum_nastupu) over () AS min_datum
  FROM zamestnanec
  )
WHERE datum in (max_datum, min_datum);

-- X101:
SELECT cas_odletu,
  lead (cas_odletu) over (order by cas_odletu) AS dalsi,
  lag (cas_odletu) over (order by cas_odletu)  AS predchozi
FROM let;

-- X102:
SELECT jmeno,
  prijmeni,
  nazev_pozice,
  plat
FROM
  (SELECT jmeno,
    prijmeni,
    nazev_pozice,
    plat,
    MIN(plat) over (partition BY zamestnani_id) AS min_plat,
    MAX(plat) over (partition BY zamestnani_id) AS max_plat
  FROM zamestnanec
  JOIN zamestnani USING (zamestnani_id)
  )
WHERE plat IN (min_plat, max_plat);

-- X103:
SELECT *
FROM
  (SELECT jmeno,
    prijmeni,
    COUNT(*) over (partition BY cislo_letu) AS pocet_pasazeru
  FROM pasazer
  JOIN ucastnik_letu USING (pasazer_id)
  )
WHERE pocet_pasazeru > 10;

-- X104:
select * from (
select tabule.*, rownum as poradi from (
select distinct cislo_letu, 
sum (cena) over (partition by cislo_letu) prijem from ucastnik_letu order by prijem desc) tabule) where poradi = 1;


-- X106:
select typ_letadla_id, porizovaci_cena / 1000000000, datum_porizeni, sum(porizovaci_cena) over (order by datum_porizeni, letadlo_id) / 1000000000 from letadlo
order by datum_porizeni;

-- X107:
select extract(year from datum_porizeni), count(*) pocet
from letadlo
group by extract(year from datum_porizeni)
order by pocet;

-- X108:
select typ_letadla_id, datum_porizeni, row_number() over (order by datum_porizeni) 
from letadlo
order by datum_porizeni;
-- nebo:
select letadla.*, rownum from (
select typ_letadla_id, datum_porizeni
from letadlo order by datum_porizeni) letadla;

-- X109:
with zamestnanci as (
select jmeno, prijmeni, plat, zamestnani_id, dense_rank() over (partition by zamestnani_id order by plat desc) poradi
from zamestnanec)
select * from zamestnanci join zamestnani using (zamestnani_id) where poradi = 1;
--NEBO:
with zamestnanci as (
select jmeno, prijmeni, plat, zamestnani_id, first_value(plat) over (partition by zamestnani_id order by plat desc) max_plat
from zamestnanec)
select * from zamestnanci join zamestnani using (zamestnani_id) where max_plat = plat;

-- X110:
with roky as (select distinct extract(year from date_time_start) rok from calendar order by extract(year from date_time_start)), 
min_max as (select extract(year from min(datum_nastupu)) min_rok, extract(year from max(datum_nastupu)) max_rok from zamestnanec),
zamestnanci as (
select count(*) pocet, extract(year from datum_nastupu) as rok_nastupu
from zamestnanec
group by extract(year from datum_nastupu)
order by rok_nastupu)
select distinct rok, nvl(pocet, 0) from zamestnanci right join roky
on rok_nastupu = rok cross join min_max
where rok between min_rok and max_rok
order by rok;