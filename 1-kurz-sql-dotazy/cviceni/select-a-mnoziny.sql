-- M001:
select * from (
select zamestnani.nazev_pozice,
  round(avg(zamestnanec.plat)) prumer,
  min(zamestnanec.plat) minimum,
  max(zamestnanec.plat) maximum,
  count(zamestnanec.plat) pocet_zamestnancu,
  sum(zamestnanec.plat) celkem_platba
FROM ZAMESTNANI
INNER JOIN ZAMESTNANEC
on zamestnani.zamestnani_id = zamestnanec.zamestnani_id
group by zamestnani.nazev_pozice
order by prumer desc
)
union all
select 'Celkove hodnoty:', round(avg(plat)), min(plat), 
max(plat), count(zamestnanec_id), sum(plat) from zamestnanec;

