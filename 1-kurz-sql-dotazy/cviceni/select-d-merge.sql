-- M001:
merge into zamestnanec a 
using (
SELECT COUNT(LET.CISLO_LETU) AS pocet_letu,
  PILOT.ZAMESTNANEC_ID
FROM LET
INNER JOIN PILOT
ON PILOT.PILOT_ID = LET.PILOT_ID
GROUP BY PILOT.ZAMESTNANEC_ID) b
on (a.zamestnanec_id = b.zamestnanec_id)
when matched then update set plat = plat + (pocet_letu * 1000);

-- M002:
merge into pasazer a 
using (
SELECT PASAZER.PASAZER_ID,
  PASAZER.PROBLEMATICKY,
  SUM(UCASTNIK_LETU.CENA) soucet
FROM PASAZER
INNER JOIN UCASTNIK_LETU
ON PASAZER.PASAZER_ID = UCASTNIK_LETU.PASAZER_ID
where problematicky = 'y'
GROUP BY PASAZER.PASAZER_ID,
  PASAZER.PROBLEMATICKY
  having sum(cena) > 5000) b
on (a.pasazer_id = b.pasazer_id)
when matched then update set problematicky = 'n'