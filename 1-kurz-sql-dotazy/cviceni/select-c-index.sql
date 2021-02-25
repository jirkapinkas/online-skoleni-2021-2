-- I001:
CREATE INDEX AERO.ix_zamestnanec_jmeno
ON AERO.zamestnanec (prijmeni, jmeno);
-- pro otestovani muzeme pouzit
ALTER INDEX AERO.ix_zamestnanec_jmeno UNUSABLE;
ALTER INDEX AERO.ix_zamestnacec_jmeno REBUILD;


-- I002
CREATE INDEX AERO.ix_zamestnanec_plat
ON AERO.zamestnanec(ROUND(plat,-4));
-- pouziti
select * from AERO.zamestnanec WHERE round(plat,-4) = 10000;


-- I003
CREATE INDEX AERO.ix_casy_odletu
ON AERO.zastavka(to_char(pravidelny_cas_odletu, 'hh24:mi:ss'));
-- pouziti
SELECT cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky,
  to_char(pravidelny_cas_odletu, 'hh24:mi:ss') pravidelny_cas_odletu
FROM AERO.zastavka
  WHERE to_char(pravidelny_cas_odletu, 'hh24:mi:ss') = '23:00:00';