-- P001:
CREATE OR REPLACE VIEW AERO.p_sestava_zamestnanci AS
  SELECT jmeno, prijmeni, datum_nastupu, datum_ukonceni
  FROM AERO.zamestnanec
WITH READ ONLY;


-- P002:
CREATE OR REPLACE VIEW AERO.p_sestava_platy AS
  SELECT jmeno, prijmeni, to_char(plat ,'999999999.99') AS plat, nazev_pozice
  FROM AERO.zamestnanec zc, AERO.zamestnani zi
  WHERE zc.zamestnani_id = zi.zamestnani_id;


-- P003:
CREATE OR REPLACE NOFORCE VIEW AERO.p_piloti AS
	SELECT jmeno, prijmeni, datum_nastupu, zamestnani_id AS pozice_id
	FROM AERO.zamestnanec
	WHERE zamestnani_id = (
			SELECT zamestnani_id FROM AERO.zamestnani
			WHERE nazev_pozice = 'Pilot')
WITH CHECK OPTION CONSTRAINT c_jen_piloti;
-- test
INSERT INTO AERO.p_piloti(jmeno, prijmeni, datum_nastupu, pozice_id)
  VALUES('jmeno','prijmeni', sysdate, (SELECT zamestnani_id FROM AERO.zamestnani WHERE nazev_pozice = 'Pilot'));


-- P004:
CREATE MATERIALIZED VIEW AERO.p_sestava_piloti AS
  SELECT z.prijmeni, z.jmeno, COUNT(l.cislo_letu) AS pocet_letu
  FROM AERO.pilot p LEFT JOIN AERO.let l
  ON l.pilot_id = p.pilot_id, AERO.zamestnanec z
  WHERE p.zamestnanec_id = z.zamestnanec_id
  GROUP BY z.prijmeni, z.jmeno;