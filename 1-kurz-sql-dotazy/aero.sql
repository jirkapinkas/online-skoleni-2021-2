
-- test encoding
-- UTF-8
-- upper row:
-- ěščřžýáíéĚŠČŘŽÝÁÍÉ

-- Create User

drop user aero cascade;
create user aero identified by aero;
grant all privileges to aero;

ALTER SESSION SET CURRENT_SCHEMA = aero;

-- Create Tables section


Create table zamestnani (
	zamestnani_id Number(3,0) NOT NULL ,
	nazev_pozice Varchar2 (64 CHAR) NOT NULL ,
	popis_prace Varchar2 (128),
 Constraint pk_zamestnani primary key (zamestnani_id) 
) 
/

Create table zamestnanec (
	zamestnanec_id Number(7,0) NOT NULL ,
	zamestnani_id Number(3,0) NOT NULL ,
	nadrizeny Number(7,0),
	jmeno Varchar2 (32 CHAR) NOT NULL ,
	prijmeni Varchar2 (32 CHAR) NOT NULL ,
	plat Number(6,0) Constraint zamestnanec_plat_chk Check (plat > 8000 ) ,
	datum_nastupu Date NOT NULL ,
	datum_ukonceni Date,
	aktivni Char (1) Default 'n' NOT NULL  Constraint zamestnanec_aktivni_chk Check (aktivni IN ('y', 'n') ) ,
 Constraint pk_zamestnanec primary key (zamestnanec_id) 
) 
/

Create table pilot (
	pilot_id Number(4,0) NOT NULL ,
	zamestnanec_id Number(7,0) NOT NULL ,
	hodnost Varchar2 (30) Default 'Trainee' NOT NULL  Constraint pilot_hodnost_chk Check (hodnost IN ('Trainee', 'First Officer', 'Senior First Officer', 'Captain', 'Senior Captain', 'Instructor') ) ,
 Constraint pk_pilot primary key (pilot_id) 
) 
/

Create table destinace (
	destinace_id Number(10,0) NOT NULL ,
	nazev Varchar2 (30 CHAR) NOT NULL  UNIQUE ,
 Constraint pk_destinace primary key (destinace_id) 
) 
/

Create table letova_linka (
	cislo_letove_linky Number(4,0) NOT NULL ,
	nazev Varchar2 (64),
 Constraint pk_letova_linka primary key (cislo_letove_linky) 
) 
/

Create table zastavka (
	cislo_letove_linky Number(4,0) NOT NULL ,
	poradi_zastavky Number(3,0) NOT NULL  Constraint zastavka_poradi_zastavky_chk Check (poradi_zastavky >= 0 ) ,
	km_od_minule_zastavky Number(5,0) NOT NULL  Constraint zastavka_km_od_minule_zastavky Check (km_od_minule_zastavky >= 0 ) ,
	pravidelny_cas_odletu Date NOT NULL ,
	destinace_id Number(10,0) NOT NULL ,
 Constraint pk_zastavka primary key (cislo_letove_linky,poradi_zastavky) 
) 
/

Create table typ_letadla (
	typ_letadla_id Varchar2 (14 CHAR) NOT NULL ,
	nazev Varchar2 (32 CHAR) NOT NULL ,
	pocet_mist Number(3,0) NOT NULL  Constraint typ_letadla_pocet_mist_chk Check (pocet_mist > 0 ) ,
 Constraint pk_typ_letadla primary key (typ_letadla_id) 
) 
/

Create table letadlo (
	letadlo_id Number(6,0) NOT NULL ,
	typ_letadla_id Varchar2 (14) NOT NULL ,
	datum_porizeni Date NOT NULL ,
	porizovaci_cena Number(12,0) Constraint letadlo_porizovaci_cena_chk Check (porizovaci_cena > 0 ) ,
 Constraint pk_letadlo primary key (letadlo_id) 
) 
/

Create table pasazer (
	pasazer_id Number(15,0) NOT NULL ,
	jmeno Varchar2 (32 CHAR) NOT NULL ,
	prijmeni Varchar2 (32 CHAR) NOT NULL ,
	problematicky Char (1) Default 'n' NOT NULL  Constraint pasazer_problematicky_chk Check (problematicky IN ('y', 'n') ) ,
 Constraint pk_pasazer primary key (pasazer_id) 
) 
/

Create table let (
	cislo_letu Varchar2 (14 CHAR) NOT NULL ,
	pilot_id Number(4,0) NOT NULL ,
	letadlo_id Number(6,0) NOT NULL ,
	cislo_letove_linky Number(4,0) NOT NULL ,
	cas_odletu Date NOT NULL ,
 Constraint pk_let primary key (cislo_letu) 
) 
/

Create table ucastnik_letu (
	cislo_letu Varchar2 (14) NOT NULL ,
	pasazer_id Number(15,0) NOT NULL ,
	odkud Number(10,0) NOT NULL ,
	kam Number(10,0) NOT NULL ,
	cena Number(7,2) Constraint ucastnik_letu_cena_chk Check (cena IS NULL OR cena >= 0 ) ,
	pocet_prestupku Number(2,0) Default 0 NOT NULL  Constraint ucastnik_letu_pocet_prestupku_ Check (pocet_prestupku >= 0 ) ,
 Constraint pk_ucastnik_letu primary key (cislo_letu,pasazer_id) 
) 
/


-- Create Indexes section


-- Create Foreign keys section
Create Index IX_pracuje_jako ON zamestnanec (zamestnani_id)
/
Alter table zamestnanec add Constraint pracuje_jako foreign key (zamestnani_id) references zamestnani (zamestnani_id) 
/
Create Index IX_ma_nadrizeneho ON zamestnanec (nadrizeny)
/
Alter table zamestnanec add Constraint ma_nadrizeneho foreign key (nadrizeny) references zamestnanec (zamestnanec_id) 
/
Create Index IX_je_zamestnan ON pilot (zamestnanec_id)
/
Alter table pilot add Constraint je_zamestnan foreign key (zamestnanec_id) references zamestnanec (zamestnanec_id) 
/
Create Index IX_ridi ON let (pilot_id)
/
Alter table let add Constraint ridi foreign key (pilot_id) references pilot (pilot_id) 
/
Create Index IX_je_mistem_pristani ON zastavka (destinace_id)
/
Alter table zastavka add Constraint je_mistem_pristani foreign key (destinace_id) references destinace (destinace_id) 
/
Create Index IX_leti_z ON ucastnik_letu (odkud)
/
Alter table ucastnik_letu add Constraint leti_z foreign key (odkud) references destinace (destinace_id) 
/
Create Index IX_leti_do ON ucastnik_letu (kam)
/
Alter table ucastnik_letu add Constraint leti_do foreign key (kam) references destinace (destinace_id) 
/
Create Index IX_linka_ma_zastavky ON zastavka (cislo_letove_linky)
/
Alter table zastavka add Constraint linka_ma_zastavky foreign key (cislo_letove_linky) references letova_linka (cislo_letove_linky) 
/
Create Index IX_ma_rozvrh_letu ON let (cislo_letove_linky)
/
Alter table let add Constraint ma_rozvrh_letu foreign key (cislo_letove_linky) references letova_linka (cislo_letove_linky) 
/
Create Index IX_je_typu ON letadlo (typ_letadla_id)
/
Alter table letadlo add Constraint je_typu foreign key (typ_letadla_id) references typ_letadla (typ_letadla_id) 
/
Create Index IX_vykonavan_letadlem ON let (letadlo_id)
/
Alter table let add Constraint vykonavan_letadlem foreign key (letadlo_id) references letadlo (letadlo_id) 
/
Create Index IX_leti_konkretnim_letem ON ucastnik_letu (pasazer_id)
/
Alter table ucastnik_letu add Constraint leti_konkretnim_letem foreign key (pasazer_id) references pasazer (pasazer_id) 
/
Create Index IX_ma_pasazery ON ucastnik_letu (cislo_letu)
/
Alter table ucastnik_letu add Constraint ma_pasazery foreign key (cislo_letu) references let (cislo_letu) 
/


-- Create Views section


-- Create Sequences section

CREATE SEQUENCE zamestnani_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE zamestnanec_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE pilot_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE letadlo_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE let_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE letova_linka_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE pasazer_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE destinace_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/


/* Trigger for sequence zamestnani_seq for table zamestnani attribute zamestnani_id */
Create or replace trigger t_zamestnani_seq before insert
on zamestnani for each row
begin
	SELECT zamestnani_seq.nextval INTO :new.zamestnani_id FROM dual;
end;
/
Create or replace trigger t_zamestnani_seq_upd after update of zamestnani_id
on zamestnani for each row
begin
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column zamestnani_id in table zamestnani as it uses sequence.');
end;
/
 
/* Trigger for sequence pilot_seq for table pilot attribute pilot_id */
Create or replace trigger t_pilot_seq before insert
on pilot for each row
begin
	SELECT pilot_seq.nextval INTO :new.pilot_id FROM dual;
end;
/
Create or replace trigger t_pilot_seq_upd after update of pilot_id
on pilot for each row
begin
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column pilot_id in table pilot as it uses sequence.');
end;
/
 
/* Trigger for sequence letadlo_seq for table letadlo attribute letadlo_id */
Create or replace trigger t_letadlo_seq before insert
on letadlo for each row
begin
	SELECT letadlo_seq.nextval INTO :new.letadlo_id FROM dual;
end;
/
Create or replace trigger t_letadlo_seq_upd after update of letadlo_id
on letadlo for each row
begin
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column letadlo_id in table letadlo as it uses sequence.');
end;
/
 
/* Trigger for sequence pasazer_seq for table pasazer attribute pasazer_id */
Create or replace trigger t_pasazer_seq before insert
on pasazer for each row
begin
	SELECT pasazer_seq.nextval INTO :new.pasazer_id FROM dual;
end;
/
Create or replace trigger t_pasazer_seq_upd after update of pasazer_id
on pasazer for each row
begin
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column pasazer_id in table pasazer as it uses sequence.');
end;
/
 
/* Trigger for sequence letova_linka_seq for table letova_linka attribute cislo_letove_linky */
Create or replace trigger t_letova_linka_seq before insert
on letova_linka for each row
begin
	SELECT letova_linka_seq.nextval INTO :new.cislo_letove_linky FROM dual;
end;
/
Create or replace trigger t_letova_linka_seq_upd after update of cislo_letove_linky
on letova_linka for each row
begin
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column cislo_letove_linky in table letova_linka as it uses sequence.');
end;
/
 
/* Trigger for sequence zamestnanec_seq for table zamestnanec attribute zamestnanec_id */
CREATE OR REPLACE TRIGGER t_zamestnanec_seq BEFORE INSERT
ON zamestnanec FOR EACH ROW
BEGIN
	SELECT zamestnanec_seq.NEXTVAL INTO :new.zamestnanec_id FROM dual;
END;
/
CREATE OR REPLACE TRIGGER t_zamestnanec_seq_upd AFTER UPDATE 
OF zamestnanec_id ON zamestnanec FOR EACH ROW
BEGIN
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column zamestnanec_id in table zamestnanec as it uses sequence.');
END;
/
 
/* Trigger for sequence destinace_seq for table destinace attribute destinace_id */
Create or replace trigger t_destinace_seq before insert
on destinace for each row
begin
	SELECT destinace_seq.nextval INTO :new.destinace_id FROM dual;
end;
/
Create or replace trigger t_destinace_seq_upd after update of destinace_id
on destinace for each row
begin
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column destinace_id in table destinace as it uses sequence.');
end;
/

-- Create Triggers from referential integrity section


-- Create user Triggers section


-- Create Table comments section

Comment on table zamestnani is 'Zamestnani (pozice) zamestnance'
/
Comment on table zamestnanec is 'Zamestnanec aerolinek'
/
Comment on table pilot is 'Pilot aerolinek'
/
Comment on table destinace is 'Letova destinace - typicky mesto, primorske stredisko, cil vojenske operace'
/
Comment on table letova_linka is 'Letova linka/letovy rad'
/
Comment on table zastavka is 'Zastavka na letove lince'
/
Comment on table typ_letadla is 'Typ (model) letadla'
/
Comment on table letadlo is 'Konkretni letadlo aerolinek'
/
Comment on table pasazer is 'Cestujici, ktery vyuziva sluzeb aerolinek'
/
Comment on table let is 'Informace o konkretnim letu, na kterem dane letadlo ridi dany pilot podle daneho letoveho radu'
/
Comment on table ucastnik_letu is 'Ucast pasazera na konkretnim letu'
/

-- Create Attribute comments section

Comment on column zamestnani.zamestnani_id is 'Identifikator zamestnani - pracovni pozice'
/
Comment on column zamestnani.nazev_pozice is 'Nazev pozice'
/
Comment on column zamestnani.popis_prace is 'Popis prace'
/
Comment on column zamestnanec.zamestnanec_id is 'Identifikacni cislo zamestnance'
/
Comment on column zamestnanec.zamestnani_id is 'Identifikacni cislo zamestnani (pozice)'
/
Comment on column zamestnanec.nadrizeny is 'Identifikacni cislo nadrizeneho zamestnance'
/
Comment on column zamestnanec.jmeno is 'Jmeno zamestnance'
/
Comment on column zamestnanec.prijmeni is 'Prijmeni zamestnance'
/
Comment on column zamestnanec.plat is 'Plat zamestnance'
/
Comment on column zamestnanec.datum_nastupu is 'Datum nastupu do prace'
/
Comment on column zamestnanec.datum_ukonceni is 'Datum ukonceni pracovniho pomeru v pripade, ze zamestnanec uz nepracuje, nebo NULL'
/
Comment on column zamestnanec.aktivni is 'Je zamestnanec aktivni pro vykon sve prace? Tj. neni nemocny, na dovolene, propusteny.'
/
Comment on column pilot.pilot_id is 'Identifikacni cislo pilota'
/
Comment on column pilot.zamestnanec_id is 'Odkaz na zamestnanecke udaje'
/
Comment on column pilot.hodnost is 'Hodnost pilota'
/
Comment on column destinace.destinace_id is 'Identifikator destinace'
/
Comment on column destinace.nazev is 'Nazev mesta/strediska/uzemi'
/
Comment on column letova_linka.cislo_letove_linky is 'Cislo letove linky'
/
Comment on column letova_linka.nazev is 'Nazev letove linky (napr. Praha - Londyn)'
/
Comment on column zastavka.cislo_letove_linky is 'Cislo letove linky/letoveho radu'
/
Comment on column zastavka.poradi_zastavky is 'Poradi zastavky v ramci letove linky (0, 1, 2, ...). 0 pro pocatecni misto odletu.'
/
Comment on column zastavka.km_od_minule_zastavky is 'Pocet kilometru vzdusnou carou od minule zastavky'
/
Comment on column zastavka.pravidelny_cas_odletu is 'Pravidelny cas odletu (bez konkretniho data)'
/
Comment on column zastavka.destinace_id is 'Identifikator destinace'
/
Comment on column typ_letadla.typ_letadla_id is 'Kod typu letadla'
/
Comment on column typ_letadla.nazev is 'Nazev typu letadla'
/
Comment on column typ_letadla.pocet_mist is 'Pocet mist v letadle'
/
Comment on column letadlo.letadlo_id is 'Identifikacni cislo letadla'
/
Comment on column letadlo.typ_letadla_id is 'Kod typu letadla'
/
Comment on column letadlo.datum_porizeni is 'Datum porizeni letadla'
/
Comment on column letadlo.porizovaci_cena is 'Porizovaci cena letadla'
/
Comment on column pasazer.pasazer_id is 'Identifikacni cislo cestujiciho'
/
Comment on column pasazer.jmeno is 'Jmeno cestujiciho'
/
Comment on column pasazer.prijmeni is 'Prijmeni cestujiciho'
/
Comment on column pasazer.problematicky is 'Priznak, zda je pasazer problematicky (ma prestupky z minulych letu)'
/
Comment on column let.cislo_letu is 'Cislo letu, obsahuje kod aerolinek a poradove cislo letu'
/
Comment on column let.pilot_id is 'Identifikacni cislo pilota'
/
Comment on column let.letadlo_id is 'Identifikacni cislo letadla'
/
Comment on column let.cislo_letove_linky is 'Identifikacni cislo linky/letoveho radu'
/
Comment on column let.cas_odletu is 'Planovany datum a cas odletu konkretniho letu'
/
Comment on column ucastnik_letu.cislo_letu is 'Identifikacni cislo letu'
/
Comment on column ucastnik_letu.pasazer_id is 'Identifikacni cislo pasazera'
/
Comment on column ucastnik_letu.odkud is 'Identifikator destinace, odkud pasazer leti'
/
Comment on column ucastnik_letu.kam is 'Identifikator destinace, kam pasazer leti'
/
Comment on column ucastnik_letu.cena is 'Cena, kterou pasazer zaplatil za letenku a palivo'
/
Comment on column ucastnik_letu.pocet_prestupku is 'Pocet zavaznejsich prestupku pasazera behem letu'
/

-- After section
/* Trigger kontrolujici spravnost casoveho intervalu <datum_nastupu, 
datum_ukonceni> */
CREATE OR REPLACE TRIGGER t_zamestnanec_int_prace BEFORE INSERT
ON zamestnanec FOR EACH ROW
BEGIN
  IF :NEW.datum_nastupu IS NOT NULL AND :NEW.datum_ukonceni IS NOT NULL 
  AND :NEW.datum_nastupu >= :NEW.datum_ukonceni THEN
    -- cislo aplikacni chyby muze byt od -20000 do -20999
    RAISE_APPLICATION_ERROR(-20100, 'Neplatny casovy interval.');
  END IF;
END;
/

/* Trigger kontrolujici spravnost casoveho intervalu <datum_nastupu, 
datum_ukonceni> */
CREATE OR REPLACE TRIGGER t_zamestnanec_int_prace_upd BEFORE UPDATE
ON zamestnanec FOR EACH ROW
BEGIN
  IF :NEW.datum_nastupu IS NOT NULL AND :NEW.datum_ukonceni IS NOT NULL 
  AND :NEW.datum_nastupu >= :NEW.datum_ukonceni THEN
    -- cislo aplikacni chyby muze byt od -20000 do -20999
    RAISE_APPLICATION_ERROR(-20100, 'Neplatny casovy interval.');
  END IF;
END;
/

/* Trigger kontrolujici neaktivitu zamestnance pri zadanem datu 
ukonceni prace */
CREATE OR REPLACE TRIGGER t_zamestnanec_aktivita BEFORE INSERT
ON zamestnanec FOR EACH ROW
BEGIN
  IF :NEW.datum_ukonceni IS NOT NULL AND :NEW.aktivni = 'y' THEN
    RAISE_APPLICATION_ERROR(-20101, 'Zamestnanec s ukoncenym pracovnim pomerem nemuze byt aktivni.');
  END IF;
END;
/

/* Trigger kontrolujici neaktivitu zamestnance pri zadanem datu 
ukonceni prace */
CREATE OR REPLACE TRIGGER t_zamestnanec_aktivita_upd BEFORE UPDATE
ON zamestnanec FOR EACH ROW
BEGIN
  IF :NEW.datum_ukonceni IS NOT NULL AND :NEW.aktivni = 'y' THEN
    RAISE_APPLICATION_ERROR(-20101, 'Zamestnanec s ukoncenym pracovnim pomerem nemuze byt aktivni.');
  END IF;
END;
/

/* Trigger kontrolujici max. pocet cestujicich ucastnicich se letu */
CREATE OR REPLACE TRIGGER t_ucastnik_letu_max_cest BEFORE INSERT
ON ucastnik_letu FOR EACH ROW
DECLARE
  pocet_cestujicich INT;
  pocet_mist_v_letadle INT;
BEGIN
  SELECT COUNT(pasazer_id) INTO pocet_cestujicich 
  FROM ucastnik_letu
  WHERE cislo_letu = :NEW.cislo_letu;
  
  SELECT tl.pocet_mist INTO pocet_mist_v_letadle 
  FROM typ_letadla tl, letadlo l, let lt
  WHERE tl.typ_letadla_id = l.typ_letadla_id AND l.letadlo_id = lt.letadlo_id
  AND lt.cislo_letu = :NEW.cislo_letu;

  IF pocet_cestujicich >= pocet_mist_v_letadle THEN
    RAISE_APPLICATION_ERROR(-20102, 'Nelze pridat cestujiciho. V letadle uz neni misto.');
  END IF;
END;
/

/* Trigger kontrolujici interval <datum porizeni letadla, cas odletu> */
CREATE OR REPLACE TRIGGER t_let_int_porizeni_casodl BEFORE INSERT
ON let FOR EACH ROW
DECLARE 
  datum_porizeni_letadla DATE;
BEGIN
  SELECT datum_porizeni INTO datum_porizeni_letadla FROM letadlo
  WHERE letadlo_id = :NEW.letadlo_id;

  IF datum_porizeni_letadla > :NEW.cas_odletu THEN
    RAISE_APPLICATION_ERROR(-20103, 'Letadlo nemuze odletat v zadanou dobu, v tu dobu jeste neni koupeno.');
  END IF;
END;
/

/* Trigger kontrolujici interval <datum porizeni letadla, cas odletu> */
CREATE OR REPLACE TRIGGER t_let_int_porizeni_casodl_upd BEFORE UPDATE
ON let FOR EACH ROW
DECLARE 
  datum_porizeni_letadla DATE;
BEGIN
  SELECT datum_porizeni INTO datum_porizeni_letadla FROM letadlo
  WHERE letadlo_id = :NEW.letadlo_id;

  IF datum_porizeni_letadla > :NEW.cas_odletu THEN
    RAISE_APPLICATION_ERROR(-20103, 'Letadlo nemuze odletat v zadanou dobu, v tu dobu jeste neni koupeno.');
  END IF;
END;
/

/* Trigger kontrolujici zda jsou na lince zvoleneho letu pozadovane zastavky
odkud, kam */
CREATE OR REPLACE TRIGGER t_ucastnik_letu_exist_zast BEFORE INSERT
ON ucastnik_letu FOR EACH ROW
DECLARE 
  existuji_zastavky CHAR(1) DEFAULT 'n';
BEGIN
  SELECT 'y' INTO existuji_zastavky FROM DUAL 
    WHERE :NEW.odkud IN (
      SELECT z.destinace_id FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky 
      AND l.cislo_letu = :NEW.cislo_letu)
    AND :NEW.kam IN (
      SELECT z.destinace_id FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky 
      AND l.cislo_letu = :NEW.cislo_letu)
    AND (
      SELECT MIN(z.poradi_zastavky) FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky
      AND l.cislo_letu = :NEW.cislo_letu AND z.destinace_id = :NEW.odkud)
      < (
      SELECT MAX(z.poradi_zastavky) FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky
      AND l.cislo_letu = :NEW.cislo_letu AND z.destinace_id = :NEW.kam)
    AND ROWNUM = 1;

  IF existuji_zastavky = 'n' THEN
    RAISE_APPLICATION_ERROR(-20104, 'Zastavky, kde chce cestujici nastupovat/vystupovat na vybranem letu neexistuji, nebo jsou ve spatnem poradi.');
  END IF;
END;
/

/* Trigger kontrolujici zda jsou na lince zvoleneho letu pozadovane zastavky
odkud, kam */
CREATE OR REPLACE TRIGGER t_ucastnik_letu_exist_zast_upd BEFORE UPDATE
ON ucastnik_letu FOR EACH ROW
DECLARE 
  existuji_zastavky CHAR(1) DEFAULT 'n';
BEGIN
  SELECT 'y' INTO existuji_zastavky FROM DUAL 
    WHERE :NEW.odkud IN (
      SELECT z.destinace_id FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky 
      AND l.cislo_letu = :NEW.cislo_letu)
    AND :NEW.kam IN (
      SELECT z.destinace_id FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky 
      AND l.cislo_letu = :NEW.cislo_letu)
    AND (
      SELECT MIN(z.poradi_zastavky) FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky
      AND l.cislo_letu = :NEW.cislo_letu AND z.destinace_id = :NEW.odkud)
      < (
      SELECT MAX(z.poradi_zastavky) FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky
      AND l.cislo_letu = :NEW.cislo_letu AND z.destinace_id = :NEW.kam)
    AND ROWNUM = 1;

  IF existuji_zastavky = 'n' THEN
    RAISE_APPLICATION_ERROR(-20104, 'Zastavky, kde chce cestujici nastupovat/vystupovat na vybranem letu neexistuji, nebo jsou ve spatnem poradi.');
  END IF;
END;
/

/* Trigger kontrolujici interval <datum nastoupeni pilota, cas odletu> */
CREATE OR REPLACE TRIGGER t_let_int_nastuppil_casodl BEFORE INSERT
ON let FOR EACH ROW
DECLARE 
  datum_nastupu_pilota DATE;
BEGIN
  SELECT datum_nastupu INTO datum_nastupu_pilota FROM zamestnanec z,
  pilot p WHERE z.zamestnanec_id = p.zamestnanec_id 
  AND p.pilot_id = :NEW.pilot_id;

  IF datum_nastupu_pilota > :NEW.cas_odletu THEN
    RAISE_APPLICATION_ERROR(-20105, 'Letadlo nemuze odletat v dobu, kdy jeste pilot nenastoupil do prace.');
  END IF;
END;
/

/* Trigger kontrolujici interval <datum nastoupeni pilota, cas odletu> */
CREATE OR REPLACE TRIGGER t_let_int_nastuppil_casodl_upd BEFORE UPDATE
ON let FOR EACH ROW
DECLARE 
  datum_nastupu_pilota DATE;
BEGIN
  SELECT datum_nastupu INTO datum_nastupu_pilota FROM zamestnanec z,
  pilot p WHERE z.zamestnanec_id = p.zamestnanec_id 
  AND p.pilot_id = :NEW.pilot_id;

  IF datum_nastupu_pilota > :NEW.cas_odletu THEN
    RAISE_APPLICATION_ERROR(-20105, 'Letadlo nemuze odletat v dobu, kdy jeste pilot nenastoupil do prace.');
  END IF;
END;
/

/* Procedura resetujici zadanou sekvenci na nasledujici cislo 1 */
CREATE OR REPLACE PROCEDURE reset_seq(p_seq_name IN VARCHAR2) IS
  l_val number;
BEGIN
  EXECUTE IMMEDIATE
  'SELECT ' || p_seq_name || '.NEXTVAL FROM DUAL' INTO l_val;
  EXECUTE IMMEDIATE
  'ALTER SEQUENCE ' || p_seq_name || ' INCREMENT BY -' || l_val || ' MINVALUE 0';
  EXECUTE IMMEDIATE
  'SELECT ' || p_seq_name || '.NEXTVAL FROM DUAL' INTO l_val;
  EXECUTE IMMEDIATE
  'ALTER SEQUENCE ' || p_seq_name || ' INCREMENT BY 1 MINVALUE 0';
END;
/

/* tabulka s kalendarem */
 create table calendar as (
 SELECT TO_NUMBER (TO_CHAR (mydate, 'yyyymmdd')) AS date_key,
       mydate AS date_time_start,
       mydate + 1 - 1/86400 AS date_time_end,
       TO_CHAR (mydate, 'dd-MON-yyyy') AS date_value,
       TO_NUMBER (TO_CHAR (mydate, 'D')) AS day_of_week_number,
       TO_CHAR (mydate, 'Day') AS day_of_week_desc,
       TO_CHAR (mydate, 'DY') AS day_of_week_sdesc,
       CASE WHEN TO_NUMBER (TO_CHAR (mydate, 'D')) IN (1, 7) THEN 1
            ELSE 0
       END AS weekend_flag,
       TO_NUMBER (TO_CHAR (mydate, 'W')) AS week_in_month_number,
       TO_NUMBER (TO_CHAR (mydate, 'WW')) AS week_in_year_number,
       TRUNC(mydate, 'w') AS week_start_date,
       TRUNC(mydate, 'w') + 7 - 1/86400 AS week_end_date,
       TO_NUMBER (TO_CHAR (mydate, 'IW')) AS iso_week_number,
       TRUNC(mydate, 'iw') AS iso_week_start_date,
       TRUNC(mydate, 'iw') + 7 - 1/86400 AS iso_week_end_date,
       TO_NUMBER (TO_CHAR (mydate, 'DD')) AS day_of_month_number,
       TO_CHAR (mydate, 'MM') AS month_value,
       TO_CHAR (mydate, 'Month') AS month_desc,
       TO_CHAR (mydate, 'MON') AS month_sdesc,
       TRUNC (mydate, 'mm') AS month_start_date,
       LAST_DAY (TRUNC (mydate, 'mm')) + 1 - 1/86400 AS month_end_date,
       TO_NUMBER ( TO_CHAR( LAST_DAY (TRUNC (mydate, 'mm')), 'DD')) AS days_in_month,
       CASE WHEN mydate = LAST_DAY (TRUNC (mydate, 'mm')) THEN 1
            ELSE 0
       END AS last_day_of_month_flag,
       TRUNC (mydate) - TRUNC (mydate, 'Q') + 1 AS day_of_quarter_number,
       TO_CHAR (mydate, 'Q') AS quarter_value,
       'Q' || TO_CHAR (mydate, 'Q') AS quarter_desc,
       TRUNC (mydate, 'Q') AS quarter_start_date,
       ADD_MONTHS (TRUNC (mydate, 'Q'), 3) - 1/86400 AS quarter_end_date,
       ADD_MONTHS (TRUNC (mydate, 'Q'), 3) - TRUNC (mydate, 'Q') AS days_in_quarter,
       CASE WHEN mydate = ADD_MONTHS (TRUNC (mydate, 'Q'), 3) - 1 THEN 1
            ELSE 0
       END AS last_day_of_quarter_flag,
       TO_NUMBER (TO_CHAR (mydate, 'DDD')) AS day_of_year_number,
       TO_CHAR (mydate, 'yyyy') AS year_value,
       'YR' || TO_CHAR (mydate, 'yyyy') AS year_desc,
       'YR' || TO_CHAR (mydate, 'yy') AS year_sdesc,
       TRUNC (mydate, 'Y') AS year_start_date,
       ADD_MONTHS (TRUNC (mydate, 'Y'), 12) - 1/86400 AS year_end_date,
       ADD_MONTHS (TRUNC (mydate, 'Y'), 12) - TRUNC (mydate, 'Y') AS days_in_year
  FROM ( SELECT to_date('1.1.1980', 'DD.MM.YYYY') - 1 + LEVEL AS mydate
           FROM dual
         CONNECT BY LEVEL <= (SELECT   TRUNC (ADD_MONTHS (SYSDATE, 1440), 'yy')
                                     - TRUNC (ADD_MONTHS (SYSDATE, -12), 'yy')
                                FROM DUAL
                             )
                             ));
/

create table calendar_week as (
select * from (select distinct DAY_OF_WEEK_NUMBER, DAY_OF_WEEK_DESC, DAY_OF_WEEK_SDESC
from calendar
order by DAY_OF_WEEK_NUMBER));

/

create table calendar_year as
with yearlist (year) as 
(
    select 1980 as year from dual
    union all
    select yl.year + 1 as year
    from yearlist yl
    where yl.year + 1 <= 2100
)
select year from yearlist order by year;


alter table calendar add year number;
update calendar set year = year_value;
commit;

/

/* rozsireni tabulky zamestnanec o sloupec pohlavi */
alter table zamestnanec add (pohlavi char(1) default 'm' not null);
/

alter table zamestnanec add constraint pohlavi_m_f check (pohlavi in ('m', 'f'));
/

-- Petr Bilek 2006, 2013 
-- http://sallyx.org/
--

CREATE TABLE calendar_svatek (
	den CHAR(2) NOT NULL,
	mesic CHAR(2) NOT NULL,
	jmeno VARCHAR(20),
	svatek VARCHAR(100)
);


INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('01','01',NULL,'Státní svátek (Den obnovy samos. č. st.), Nový rok');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('02','01','Karina');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('03','01','Radmila');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('04','01','Diana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('05','01','Dalimil');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('06','01',NULL,'Tři králové');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','01','Vilma');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('08','01','Čestmír');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('09','01','Vladan');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('10','01','Břetislav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('11','01','Bohdana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('12','01','Pravoslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('13','01','Edita');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('14','01','Radovan');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('15','01','Alice');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','01','Ctirad');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('17','01','Drahoslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('18','01','Vladislav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('19','01','Doubravka');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('20','01','Ilona');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('21','01','Běla');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('22','01','Slavomír');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('23','01','Zdeněk');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('24','01','Milena');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('25','01','Miloš');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('26','01','Zora');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('27','01','Ingrid');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('28','01','Otýlie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','01','Zdislava');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('30','01','Robin');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('31','01','Marika');

INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('01','02','Hynek');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('02','02','Nela','Hromnice');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('03','02','Blažej');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('04','02','Jarmila');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('05','02','Dobromila');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('06','02','Vanda');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','02','Veronika');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('08','02','Milada');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('09','02','Apolena');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('10','02','Mojmír');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('11','02','Božena');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('12','02','Slavěna');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('13','02','Věnceslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('14','02','Valentýn');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('15','02','Jiřina');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','02','Ljuba');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('17','02','Miloslava');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('18','02','Gizela');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('19','02','Patrik');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('20','02','Oldřich');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('21','02','Lenka');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('22','02','Petr');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('23','02','Svatopluk');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('24','02','Matěj');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('25','02','Liliana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('26','02','Dorota');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('27','02','Alexandr');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('28','02','Lumír');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','02','Horymír');

INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('01','03','Bedřich');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('02','03','Anežka');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('03','03','Kamil');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('04','03','Stela');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('05','03','Kazimír');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('06','03','Miroslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','03','Tomáš');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('08','03','Gabriela');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('09','03','Františka');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('10','03','Viktorie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('11','03','Anděla');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('12','03','Řehoř','vstup ČR do NATO');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('13','03','Růžena');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('14','03','Rút');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('14','03','Matylda');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('15','03','Ida');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','03','Elena');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','03','Herbert');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('17','03','Vlastimil');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('18','03','Eduard');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('19','03','Josef');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('20','03','Světlana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('21','03','Radek');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('22','03','Leona');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('23','03','Ivona');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('24','03','Gabriel');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('25','03','Marián');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('26','03','Emanuel');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('27','03','Dita');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('28','03','Soňa');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','03','Taťána');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('30','03','Arnošt');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('31','03','Kvido');

INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('01','04','Hugo');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('02','04','Erika');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('03','04','Richard');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('04','04','Ivana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('05','04','Miroslava');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('06','04','Vendula');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','04','Heřman');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','04','Hermína');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('08','04','Ema');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('09','04','Dušan');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('10','04','Darja');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('11','04','Izabela');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('12','04','Julius');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('13','04','Aleš');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('14','04','Vincenc');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('15','04','Anastázie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','04','Irena');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('17','04','Rudolf');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('18','04','Valérie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('19','04','Rostislav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('20','04','Marcela');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('21','04','Alexandra');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('22','04','Evženie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('23','04','Vojtěch');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('24','04','Jiří');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('25','04','Marek');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('26','04','Oto');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('27','04','Jaroslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('28','04','Vlastislav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','04','Robert');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('30','04','Blahoslav');

INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('01','05',NULL,'Svátek práce');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('02','05','Zikmund');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('03','05','Alexej');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('04','05','Květoslav');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('05','05','Klaudie','Květnové povstání českého lidu r.1945');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('06','05','Radoslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','05','Stanislav');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('08','05',NULL,'Státní svátek (osvobození od fašismu r.1945)');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('09','05','Ctibor');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('10','05','Blažena');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('11','05','Svatava','Den matek');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('12','05','Pankrác');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('13','05','Servác');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('14','05','Bonifác');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('15','05','Žofie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','05','Přemysl');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('17','05','Aneta');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('18','05','Nataša');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('19','05','Ivo');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('20','05','Zbyšek');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('21','05','Monika');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('22','05','Emil');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('23','05','Vladimír');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('24','05','Jana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('25','05','Viola');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('26','05','Filip');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('27','05','Valdemar');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('28','05','Vilém');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','05','Maxmilián');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','05','Maxim');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('30','05','Ferdinand');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('31','05','Kamila');

INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('01','06','Laura');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('02','06','Jarmil');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('03','06','Tamara');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('04','06','Dalibor');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('05','06','Dobroslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('06','06','Norbert');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','06','Iveta');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','06','Slavoj');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('08','06','Medard');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('09','06','Stanislava');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('10','06','Gita');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('11','06','Bruno');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('12','06','Antonie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('13','06','Antonín');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('14','06','Roland');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('15','06','Vít');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','06','Zbyněk');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('17','06','Adolf');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('18','06','Milan');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('19','06','Leoš');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('20','06','Květa');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('21','06','Alois');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('22','06','Pavla');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('23','06','Zdeňka');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('24','06','Jan');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('25','06','Ivan');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('26','06','Adriana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('27','06','Ladislav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('28','06','Lubomír');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','06','Petr');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','06','Pavel');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('30','06','Šárka');

INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('01','07','Jaroslava');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('02','07','Patricie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('03','07','Radomír');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('04','07','Prokop');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('05','07','Cyril','Státní svátek (Cyril a Metoděj)');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('05','07','Metoděj','Státní svátek (Cyril a Metoděj)');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('06','07',NULL,'Státní svátek (Mistr Jan Hus upálen r.1415)');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','07','Bohuslava');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('08','07','Nora');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('09','07','Drahoslava');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('10','07','Libuše');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('10','07','Amálie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('11','07','Olga');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('12','07','Bořek');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('13','07','Markéta');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('14','07','Karolína');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('15','07','Jindřich');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','07','Luboš');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('17','07','Martina');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('18','07','Drahomíra');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('19','07','Čeněk');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('20','07','Ilja');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('21','07','Vítězslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('22','07','Magdaléna');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('23','07','Libor');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('24','07','Kristýna');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('25','07','Jakub');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('26','07','Anna');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('27','07','Věroslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('28','07','Viktor');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','07','Marta');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('30','07','Bořivoj');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('31','07','Ignác');

INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('01','08','Oskar');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('02','08','Gustav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('03','08','Miluše');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('04','08','Dominik');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('05','08','Kristián');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('06','08','Oldřiška');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','08','Lada');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('08','08','Soběslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('09','08','Roman');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('10','08','Vavřinec');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('11','08','Zuzana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('12','08','Klára');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('13','08','Alena');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('14','08','Alan');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('15','08','Hana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','08','Jáchym');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('17','08','Petra');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('18','08','Helena');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('19','08','Ludvík');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('20','08','Bernard');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('21','08','Johana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('22','08','Bohuslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('23','08','Sandra');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('24','08','Bartoloměj');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('25','08','Radim');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('26','08','Luděk');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('27','08','Otakar');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('28','08','Augustýn');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','08','Evelína');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('30','08','Vladěna');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('31','08','Pavlína');

INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('01','09','Linda');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('01','09','Samuel');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('02','09','Adéla');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('03','09','Bronislav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('04','09','Jindřiška');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('05','09','Boris');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('06','09','Boleslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','09','Regína');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('08','09','Mariana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('09','09','Daniela');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('10','09','Irma');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('11','09','Denisa');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('12','09','Marie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('13','09','Lubor');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('14','09','Radka');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('15','09','Jolana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','09','Ludmila');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('17','09','Naděžda');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('18','09','Kryštof');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('19','09','Zita');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('20','09','Oleg');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('21','09','Matouš');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('22','09','Darina');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('23','09','Berta');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('24','09','Jaromír');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('25','09','Zlata');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('26','09','Andrea');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('27','09','Jonáš');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('28','09','Václav','Státní svátek (den české státnosti');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','09','Michal');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('30','09','Jeroným');

INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('01','10','Igor');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('02','10','Olívie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('02','10','Oliver');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('03','10','Bohumil');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('04','10','František');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('05','10','Eliška');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('06','10','Hanuš');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','10','Justýna');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('08','10','Věra');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('09','10','Štefan');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('09','10','Sára');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('10','10','Marina');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('11','10','Andrej');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('12','10','Marcel');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('13','10','Renáta');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('14','10','Agáta');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('15','10','Tereza');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','10','Havel');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('17','10','Hedvika');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('18','10','Lukáš');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('19','10','Michaela');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('20','10','Vendelín');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('21','10','Brigita');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('22','10','Sabina');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('23','10','Teodor');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('24','10','Nina');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('25','10','Beáta');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('26','10','Erik');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('27','10','Šarlota');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('27','10','Zoe');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('28','10',NULL,'Státní svátek (Den vzniku samost.Českosl.r.1918)');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','10','Silvie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('30','10','Tadeáš');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('31','10','Štěpánka');

INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('01','11','Felix');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('02','11',NULL,'Památka zesnulých');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('03','11','Hubert');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('04','11','Karel');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('05','11','Miriam');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('06','11','Liběna');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','11','Saskie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('08','11','Bohumír');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('09','11','Bohdan');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('10','11','Evžen');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('11','11','Martin');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('12','11','Benedikt');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('13','11','Tibor');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('14','11','Sáva');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('15','11','Leopold');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','11','Otmar');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','11','Mahulena');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('17','11',NULL,'Státní svátek (Den boje studentů za demokracii)');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('18','11','Romana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('19','11','Alžběta');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('20','11','Nikola');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('21','11','Albert');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('22','11','Cecílie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('23','11','Klement');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('24','11','Emílie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('25','11','Kateřina');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('26','11','Artur');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('27','11','Xenie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('28','11','René');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','11','Zina');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('30','11','Ondřej');

INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('01','12','Iva');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('02','12','Blanka');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('03','12','Svatoslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('04','12','Barbora');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('05','12','Jitka');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('06','12','Mikuláš');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','12','Ambrož');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('07','12','Benjamín');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('08','12','Květoslava');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('09','12','Vratislav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('10','12','Julie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('11','12','Dana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('12','12','Simona');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('13','12','Lucie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('14','12','Lýdie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('15','12','Radana');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('16','12','Albína');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('17','12','Daniel');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('18','12','Miloslav');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('19','12','Ester');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('20','12','Dagmar');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('21','12','Natálie');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('22','12','Šimon');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('23','12','Vlasta');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('24','12','Adam','Štědrý den');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('24','12','Eva','Štědrý den');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('25','12',NULL,'Boží hod vánoční (1. svátek vánoční)');
INSERT INTO calendar_svatek(den,mesic,jmeno,svatek) VALUES ('26','12','Štěpán','2. svátek vánoční');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('27','12','Žaneta');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('28','12','Bohumila');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('29','12','Judita');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('30','12','David');
INSERT INTO calendar_svatek(den,mesic,jmeno) VALUES ('31','12','Silvestr');
commit;




create table calendar_horoskop as 
(
select 'Beran'    as name, 21 as day_from, 3 as month_from, 20 as day_to, 4 as month_to from dual
union all 
select 'Býk'      as name, 21 as day_from, 4 as month_from, 21 as day_to, 5 as month_to from dual
union all 
select 'Blíženci' as name, 22 as day_from, 5 as month_from, 21 as day_to, 6 as month_to from dual
union all 
select 'Rak'      as name, 22 as day_from, 6 as month_from, 22 as day_to, 7 as month_to from dual
union all 
select 'Lev'      as name, 23 as day_from, 7 as month_from, 22 as day_to, 8 as month_to from dual
union all 
select 'Panna'    as name, 23 as day_from, 8 as month_from, 22 as day_to, 9 as month_to from dual
union all 
select 'Váhy'     as name, 23 as day_from, 9 as month_from, 23 as day_to, 10 as month_to from dual
union all 
select 'Štír'     as name, 24 as day_from, 10 as month_from, 22 as day_to, 11 as month_to from dual
union all 
select 'Střelec'  as name, 23 as day_from, 11 as month_from, 21 as day_to, 12 as month_to from dual
union all 
select 'Kozoroh'  as name, 22 as day_from, 12 as month_from, 20 as day_to, 1 as month_to from dual
union all 
select 'Vodnář'   as name, 21 as day_from, 1 as month_from, 20 as day_to, 2 as month_to from dual
union all 
select 'Ryby'     as name, 21 as day_from, 2 as month_from, 20 as day_to, 3 as month_to from dual
);

/

declare
 first_name varchar(255);
 last_name varchar(255);
 fn_size number;
 ln_size number;
begin
  begin
    execute immediate 'drop table text_data';
  exception
    when others then dbms_output.put_line('ignore');
  end;
  execute immediate 'create table text_data (first_name varchar(200) , last_name varchar(200) )';
  for i in 1 .. 100000
  loop
    fn_size := dbms_random.value(1,5);
    ln_size := dbms_random.value(5,20);
    select dbms_random.string('L', fn_size), dbms_random.string('L', ln_size) into first_name, last_name from dual;
    execute immediate 'insert into text_data values (:arg0, :arg1)'
    using first_name, last_name;
  end loop;
  begin
    execute immediate 'create index i_text_data_1 on text_data (first_name, last_name)';
  end;
  begin
    execute immediate 'create index i_text_data_2 on text_data (last_name, first_name)';
  end;
  commit;
end;

/


-- test encoding
-- UTF-8
-- upper row:
-- ěščřžýáíéĚŠČŘŽÝÁÍÉ

ALTER SESSION SET CURRENT_SCHEMA = aero;

-- Reset sequences
EXECUTE reset_seq('zamestnani_seq');
EXECUTE reset_seq('zamestnanec_seq');
EXECUTE reset_seq('pilot_seq');
EXECUTE reset_seq('letadlo_seq');
EXECUTE reset_seq('let_seq');
EXECUTE reset_seq('letova_linka_seq');
EXECUTE reset_seq('pasazer_seq');
EXECUTE reset_seq('destinace_seq');

-- INSERTs
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('A310', 'Airbus A310', 150);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('A319', 'Airbus A319', 170);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('A320', 'Airbus A320', 145);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('A321', 'Airbus A321', 210);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('B737-400', 'Boeing B737-400', 120);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('B737-500', 'Boeing B737-500', 107);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('ATR72-202', 'ATR 72-202', 80);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('ATR42-320', 'ATR 42-320/500', 86);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('An-22', 'Antonov An-22', 240);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('An-2', 'Antonov An-2', 220);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('An-124', 'Antonov An-124', 240);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('C172', 'Cessna 172', 2);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('Concorde', 'Concorde', 160);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('IL-96', 'Iljušin IL-96', 140);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('IL-76', 'Iljušin IL-76', 150);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('Tu-154', 'Tupolev Tu-154', 176);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('SR-71', 'SR-71 Blackbird', 2);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('MiG-25', 'MiG-25 Foxbat', 2);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('Tu-16', 'Tu-16 Badger', 4);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('F-14', 'F-14 Tomcat', 2);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('F/A-18', 'F/A-18 Hornet', 2);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('F-117', ' F-117 Nighthawk', 2);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('B-52', 'B-52 Stratofortress', 8);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('F-22', 'F-22 Raptor', 2);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('B-2', 'B-2 Spirit', 2);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('EF-2000', 'EF-2000 Eurofighter', 2);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('JAS39', 'JAS 39 Gripen', 2);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('Tu-22M', 'Tu-22M Backfire', 2);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('M2000C', 'Dassault Mirage 2000C', 2);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('C-5', 'C-5 Galaxy', 8);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('An-225', 'Antonov 225 Mrija', 146);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('L-1011-500', 'Lockheed L-1011-500 Tri Star', 120);
INSERT INTO typ_letadla (typ_letadla_id, nazev, pocet_mist) VALUES ('Dc-10', 'Douglas Dc-10', 108);

INSERT INTO destinace (nazev) VALUES ('Trondheim');
INSERT INTO destinace (nazev) VALUES ('Stockholm');
INSERT INTO destinace (nazev) VALUES ('Moscow');
INSERT INTO destinace (nazev) VALUES ('Samara');
INSERT INTO destinace (nazev) VALUES ('Tbilisi');
INSERT INTO destinace (nazev) VALUES ('Cairo');
INSERT INTO destinace (nazev) VALUES ('Dubai');
INSERT INTO destinace (nazev) VALUES ('Heraklion');
INSERT INTO destinace (nazev) VALUES ('Malta');
INSERT INTO destinace (nazev) VALUES ('Malorca');
INSERT INTO destinace (nazev) VALUES ('Palma');
INSERT INTO destinace (nazev) VALUES ('Ibiza');
INSERT INTO destinace (nazev) VALUES ('Barcelona');
INSERT INTO destinace (nazev) VALUES ('Madrid');
INSERT INTO destinace (nazev) VALUES ('Valencia');
INSERT INTO destinace (nazev) VALUES ('Prague');
INSERT INTO destinace (nazev) VALUES ('Paris');
INSERT INTO destinace (nazev) VALUES ('Lisbon');
INSERT INTO destinace (nazev) VALUES ('Malaga');
INSERT INTO destinace (nazev) VALUES ('Lion');
INSERT INTO destinace (nazev) VALUES ('Alicante');
INSERT INTO destinace (nazev) VALUES ('New York');
INSERT INTO destinace (nazev) VALUES ('London');
INSERT INTO destinace (nazev) VALUES ('Manchester');
INSERT INTO destinace (nazev) VALUES ('Hamburg');
INSERT INTO destinace (nazev) VALUES ('Helsinki');
INSERT INTO destinace (nazev) VALUES ('Edinburgh');
INSERT INTO destinace (nazev) VALUES ('Bergen');
INSERT INTO destinace (nazev) VALUES ('Stavanger');
INSERT INTO destinace (nazev) VALUES ('Copenhagen');
INSERT INTO destinace (nazev) VALUES ('Amsterdam');
INSERT INTO destinace (nazev) VALUES ('Zurich');
INSERT INTO destinace (nazev) VALUES ('Zagreb');
INSERT INTO destinace (nazev) VALUES ('Krakow');
INSERT INTO destinace (nazev) VALUES ('Warsaw');
INSERT INTO destinace (nazev) VALUES ('Minsk');
INSERT INTO destinace (nazev) VALUES ('Kiev');
INSERT INTO destinace (nazev) VALUES ('Vilnius');
INSERT INTO destinace (nazev) VALUES ('Tallinn');
INSERT INTO destinace (nazev) VALUES ('Riga');
INSERT INTO destinace (nazev) VALUES ('Kaliningrad');
INSERT INTO destinace (nazev) VALUES ('Kosice');
INSERT INTO destinace (nazev) VALUES ('Budapest');
INSERT INTO destinace (nazev) VALUES ('Naples');
INSERT INTO destinace (nazev) VALUES ('Rome');
INSERT INTO destinace (nazev) VALUES ('Split');
INSERT INTO destinace (nazev) VALUES ('Milan');
INSERT INTO destinace (nazev) VALUES ('Lyon');
INSERT INTO destinace (nazev) VALUES ('Hanover');
INSERT INTO destinace (nazev) VALUES ('Frankfurt');
INSERT INTO destinace (nazev) VALUES ('Oslo');
INSERT INTO destinace (nazev) VALUES ('Dubrovnik');
INSERT INTO destinace (nazev) VALUES ('Belgrade');
INSERT INTO destinace (nazev) VALUES ('Istanbul');
INSERT INTO destinace (nazev) VALUES ('Yerevan');
INSERT INTO destinace (nazev) VALUES ('Odessa');
INSERT INTO destinace (nazev) VALUES ('Gothenburg');
INSERT INTO destinace (nazev) VALUES ('Berlin');
INSERT INTO destinace (nazev) VALUES ('Munich');
INSERT INTO destinace (nazev) VALUES ('Brussels');
INSERT INTO destinace (nazev) VALUES ('St Petersburg');
INSERT INTO destinace (nazev) VALUES ('Tel Aviv');
INSERT INTO destinace (nazev) VALUES ('Damaskus');
INSERT INTO destinace (nazev) VALUES ('Larnaca');
INSERT INTO destinace (nazev) VALUES ('Beirut');
INSERT INTO destinace (nazev) VALUES ('Ekaterinburg');
INSERT INTO destinace (nazev) VALUES ('Tyumen');
INSERT INTO destinace (nazev) VALUES ('Almaty');
INSERT INTO destinace (nazev) VALUES ('Tashkent');
INSERT INTO destinace (nazev) VALUES ('Seoul');
INSERT INTO destinace (nazev) VALUES ('Los Angeles');
INSERT INTO destinace (nazev) VALUES ('Toronto');
INSERT INTO destinace (nazev) VALUES ('Atlanta');
INSERT INTO destinace (nazev) VALUES ('Fort Lauderdale');
INSERT INTO destinace (nazev) VALUES ('Washington');
INSERT INTO destinace (nazev) VALUES ('Nha Trang');
INSERT INTO destinace (nazev) VALUES ('Thái Nguyen');
INSERT INTO destinace (nazev) VALUES ('Sofia');
INSERT INTO destinace (nazev) VALUES ('Peking');
INSERT INTO destinace (nazev) VALUES ('Osaka');
INSERT INTO destinace (nazev) VALUES ('Tokio');
INSERT INTO destinace (nazev) VALUES ('Dakar');
INSERT INTO destinace (nazev) VALUES ('Lhasa');
INSERT INTO destinace (nazev) VALUES ('Hanoj');
INSERT INTO destinace (nazev) VALUES ('Lusaka');
INSERT INTO destinace (nazev) VALUES ('Harare');
INSERT INTO destinace (nazev) VALUES ('Caracas');
INSERT INTO destinace (nazev) VALUES ('Vatikán');
INSERT INTO destinace (nazev) VALUES ('Kingstown');
INSERT INTO destinace (nazev) VALUES ('Tunis');
INSERT INTO destinace (nazev) VALUES ('Apia');
INSERT INTO destinace (nazev) VALUES ('Kigali');
INSERT INTO destinace (nazev) VALUES ('Wien');
INSERT INTO destinace (nazev) VALUES ('Sarajevo');
INSERT INTO destinace (nazev) VALUES ('Santiago');
INSERT INTO destinace (nazev) VALUES ('Havana');
INSERT INTO destinace (nazev) VALUES ('Kuvajt');
INSERT INTO destinace (nazev) VALUES ('Bogotá');
INSERT INTO destinace (nazev) VALUES ('Ciudad de México');
INSERT INTO destinace (nazev) VALUES ('Dublin');
INSERT INTO destinace (nazev) VALUES ('Stavenger');

INSERT INTO zamestnani (nazev_pozice, popis_prace) VALUES ('Letecký mechanik', 'Opravy letadel');
INSERT INTO zamestnani (nazev_pozice, popis_prace) VALUES ('Pilot', 'Pilotování letů');
INSERT INTO zamestnani (nazev_pozice, popis_prace) VALUES ('Letuška/steward', 'Uvítání cestujících, obsluha cestujících, kontrola letenek');
INSERT INTO zamestnani (nazev_pozice, popis_prace) VALUES ('Provozní chemik', 'Kontrola technického stavu letadel, podpora pro oddělení výzkumu a vývoje');
INSERT INTO zamestnani (nazev_pozice, popis_prace) VALUES ('Dispečer letového provozu', 'Kontrola a řízení letového provozu');
INSERT INTO zamestnani (nazev_pozice, popis_prace) VALUES ('Hlavní dispečer letového provozu', 'Kontrola a řízení letového provozu, dohled nad ostatními dispečery');
INSERT INTO zamestnani (nazev_pozice, popis_prace) VALUES ('Ředitel aerolinek', 'Ředitel společnosti');
INSERT INTO zamestnani (nazev_pozice, popis_prace) VALUES ('Uklízečka', 'Zametání, mytí, drhnutí, špionáž u konkurence');
INSERT INTO zamestnani (nazev_pozice, popis_prace) VALUES ('Instruktor pilotáže letadel', 'Instruktor školící piloty');

INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Ředitel aerolinek'), NULL, 'Michael', 'Boss', 230000, TO_DATE('20.01.2000', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Hlavní dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Milan', 'Flemming', 80000, TO_DATE('03.12.2002', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Hlavní dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Helena', 'Rosická', 75000, TO_DATE('31.08.2004', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Hlavní dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Jan', 'Ostrovid', 82000, TO_DATE('30.03.2003', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Hlavní dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Václav', 'Falta', 78000, TO_DATE('30.04.2001', 'dd.MM.YYYY'), TO_DATE('30.06.2001', 'dd.MM.YYYY'), 'n');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Hlavní dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Roman', 'Herzog', 76000, TO_DATE('12.09.2007', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Milan' AND prijmeni = 'Flemming'), 'Radek', 'Vosička', 63000, TO_DATE('11.01.2008', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Milan' AND prijmeni = 'Flemming'), 'Kryštof', 'Mazanec', 62000, TO_DATE('14.03.2005', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Helena' AND prijmeni = 'Rosická'), 'Henry', 'Smith', 58000, TO_DATE('10.10.2007', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Helena' AND prijmeni = 'Rosická'), 'Marek', 'Hejma', 49000, TO_DATE('03.05.2004', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Helena' AND prijmeni = 'Rosická'), 'Ondřej', 'Kotrba', 55000, TO_DATE('02.02.2003', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Helena' AND prijmeni = 'Rosická'), 'Jana', 'Drzá', 52000, TO_DATE('02.02.2003', 'dd.MM.YYYY'), TO_DATE('01.01.2005', 'dd.MM.YYYY'), 'n');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Helena' AND prijmeni = 'Rosická'), 'Richard', 'Cholera', 56000, TO_DATE('02.02.2002', 'dd.MM.YYYY'), NULL, 'n');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Roman' AND prijmeni = 'Herzog'), 'Eliška', 'Mánesová', 50000, TO_DATE('01.05.2001', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Roman' AND prijmeni = 'Herzog'), 'Karel', 'Krásenský', 53000, TO_DATE('03.03.2003', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Roman' AND prijmeni = 'Herzog'), 'Veronika', 'Malíková', 48000, TO_DATE('23.04.2003', 'dd.MM.YYYY'), TO_DATE('01.04.2006', 'dd.MM.YYYY'), 'n');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Roman' AND prijmeni = 'Herzog'), 'Monika', 'Veselá', 51000, TO_DATE('24.01.2009', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Jan' AND prijmeni = 'Ostrovid'), 'Jiří', 'Konečný', 45000, TO_DATE('24.07.2007', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Jan' AND prijmeni = 'Ostrovid'), 'Bohuslav', 'Metelka', 49000, TO_DATE('14.05.2005', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Jan' AND prijmeni = 'Ostrovid'), 'Miroslav', 'Hališ', 54000, TO_DATE('10.06.2002', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Dispečer letového provozu'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Roman' AND prijmeni = 'Herzog'), 'Zdeněk', 'Omáčka', 58000, TO_DATE('11.04.2000', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Instruktor pilotáže letadel'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'David', 'Weigel', 92000, TO_DATE('11.03.2000', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Uklízečka'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Kristýna', 'Tichá', 19000, TO_DATE('02.04.2000', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Letecký mechanik'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'René', 'Vyplašil', 43000, TO_DATE('01.03.2001', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Pilot'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'David' AND prijmeni = 'Weigel'), 'Josef', 'Šídlo', 120000, TO_DATE('02.06.2003', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Pilot'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'David' AND prijmeni = 'Weigel'), 'Zdeněk', 'Vesecký', 115000, TO_DATE('05.06.2004', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Pilot'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Alan', 'Messer', 125000, TO_DATE('03.04.2005', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Pilot'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Aleš', 'Arbelovský', 135000, TO_DATE('01.01.2004', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Pilot'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Zuzana', 'Komárková', 122000, TO_DATE('02.03.2003', 'dd.MM.YYYY'), NULL, 'y');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Pilot'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Miloš', 'Zavoral', 120000, TO_DATE('23.04.2003', 'dd.MM.YYYY'), TO_DATE('20.11.2004', 'dd.MM.YYYY'), 'n');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Pilot'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Evžen', 'Renoir', 112000, TO_DATE('20.04.2009', 'dd.MM.YYYY'), NULL, 'n');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Pilot'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Ester', 'Musilová', 111600, TO_DATE('25.03.2009', 'dd.MM.YYYY'), NULL, 'n');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Pilot'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Filip', 'Gregor', 119400, TO_DATE('18.02.2009', 'dd.MM.YYYY'), NULL, 'n');
INSERT INTO zamestnanec (zamestnani_id, nadrizeny, jmeno, prijmeni, plat, datum_nastupu, datum_ukonceni, aktivni) VALUES ((SELECT zamestnani_id FROM zamestnani WHERE nazev_pozice = 'Pilot'), (SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Michael' AND prijmeni = 'Boss'), 'Karel', 'Hrubý', 129300, TO_DATE('17.04.2009', 'dd.MM.YYYY'), NULL, 'y');

INSERT INTO pilot (zamestnanec_id, hodnost) VALUES ((SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'David' AND prijmeni='Weigel'), 'Instructor');
INSERT INTO pilot (zamestnanec_id, hodnost) VALUES ((SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Josef' AND prijmeni='Šídlo'), 'Senior Captain');
INSERT INTO pilot (zamestnanec_id, hodnost) VALUES ((SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Zdeněk' AND prijmeni='Vesecký'), 'Captain');
INSERT INTO pilot (zamestnanec_id, hodnost) VALUES ((SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Alan' AND prijmeni='Messer'), 'Captain');
INSERT INTO pilot (zamestnanec_id, hodnost) VALUES ((SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Aleš' AND prijmeni='Arbelovský'), 'Senior First Officer');
INSERT INTO pilot (zamestnanec_id, hodnost) VALUES ((SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Zuzana' AND prijmeni='Komárková'), 'First Officer');
INSERT INTO pilot (zamestnanec_id, hodnost) VALUES ((SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Miloš' AND prijmeni='Zavoral'), 'First Officer');
INSERT INTO pilot (zamestnanec_id, hodnost) VALUES ((SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Evžen' AND prijmeni='Renoir'), 'Trainee');
INSERT INTO pilot (zamestnanec_id, hodnost) VALUES ((SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Ester' AND prijmeni='Musilová'), 'Trainee');
INSERT INTO pilot (zamestnanec_id, hodnost) VALUES ((SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Filip' AND prijmeni='Gregor'), 'Trainee');
INSERT INTO pilot (zamestnanec_id, hodnost) VALUES ((SELECT zamestnanec_id FROM zamestnanec WHERE jmeno = 'Karel' AND prijmeni='Hrubý'), 'Trainee');

INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A310', TO_DATE('17.04.2004', 'dd.MM.YYYY'), 697000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A310', TO_DATE('13.04.2000', 'dd.MM.YYYY'), 697000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A310', TO_DATE('13.04.2000', 'dd.MM.YYYY'), 697000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A310', TO_DATE('13.04.2000', 'dd.MM.YYYY'), 697000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A319', TO_DATE('02.02.2000', 'dd.MM.YYYY'), 876000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A319', TO_DATE('01.02.2000', 'dd.MM.YYYY'), 860000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A319', TO_DATE('01.02.2000', 'dd.MM.YYYY'), 860000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A319', TO_DATE('01.02.2000', 'dd.MM.YYYY'), 860000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A320', TO_DATE('01.03.2001', 'dd.MM.YYYY'), 892000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A320', TO_DATE('01.03.2001', 'dd.MM.YYYY'), 892000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A320', TO_DATE('23.12.2002', 'dd.MM.YYYY'), 887000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A321', TO_DATE('23.12.2001', 'dd.MM.YYYY'), 887000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A321', TO_DATE('23.12.2001', 'dd.MM.YYYY'), 887000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A321', TO_DATE('14.10.2001', 'dd.MM.YYYY'), 723000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('A321', TO_DATE('14.10.2001', 'dd.MM.YYYY'), 723000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('B737-400', TO_DATE('24.12.2000', 'dd.MM.YYYY'), 1234000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('B737-400', TO_DATE('24.12.2000', 'dd.MM.YYYY'), 1234000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('B737-400', TO_DATE('24.12.2001', 'dd.MM.YYYY'), 1212000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('B737-500', TO_DATE('24.10.2000', 'dd.MM.YYYY'), 1312000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('ATR42-320', TO_DATE('22.03.2000', 'dd.MM.YYYY'), 976000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('An-22', TO_DATE('30.07.2001', 'dd.MM.YYYY'), 768000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('An-22', TO_DATE('29.07.2001', 'dd.MM.YYYY'), 768000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('C172', TO_DATE('29.01.2000', 'dd.MM.YYYY'), 123000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('C172', TO_DATE('29.01.2000', 'dd.MM.YYYY'), 123000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('Concorde', TO_DATE('20.09.2001', 'dd.MM.YYYY'), 1300000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('IL-76', TO_DATE('23.03.2003', 'dd.MM.YYYY'), 1112000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('Tu-154', TO_DATE('19.09.2004', 'dd.MM.YYYY'), 1034000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('Tu-154', TO_DATE('19.09.2004', 'dd.MM.YYYY'), 1034000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('SR-71', TO_DATE('10.03.2000', 'dd.MM.YYYY'), 2020000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('F/A-18', TO_DATE('17.03.2001', 'dd.MM.YYYY'), 3034000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('F-22', TO_DATE('04.04.2000', 'dd.MM.YYYY'), 2800000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('EF-2000', TO_DATE('06.08.2001', 'dd.MM.YYYY'), 2120000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('B-52', TO_DATE('17.05.2000', 'dd.MM.YYYY'), 3604000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('M2000C', TO_DATE('25.02.2002', 'dd.MM.YYYY'), 2104000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('Dc-10', TO_DATE('22.02.2001', 'dd.MM.YYYY'), 798000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('Dc-10', TO_DATE('22.02.2001', 'dd.MM.YYYY'), 798000000);
INSERT INTO letadlo (typ_letadla_id, datum_porizeni, porizovaci_cena) VALUES ('L-1011-500', TO_DATE('02.11.2000', 'dd.MM.YYYY'), 876000000);

INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Milan', 'Zavářka');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Jakub', 'Hejný');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Milada', 'Nárožná');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Luboš', 'Kocián');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Hynek', 'Bašta');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Richard', 'Vejminek');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Zlata', 'Stavařová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('John', 'Smith');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Marry', 'Olbrightová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Vivien', 'Westwoodová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Yoshito', 'Zukurabi');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Will', 'Smith');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Monika', 'Rychtářová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Fred', 'Flinstone');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Marion', 'Forestová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Forest', 'Gump');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Václav', 'Klaus');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Ondřej', 'Vetchý');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Kristián', 'Kulička');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Aneta', 'Chefieldová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Uma', 'Thurman');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Michael', 'Gotling');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Radek', 'Děda');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Kirsten', 'Bovariová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('George', 'Jungle');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Holly', 'Engelsová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Brian', 'Kernigan');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Sadam', 'Husain');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Ali', 'Musset');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Filip', 'Rusnovič');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Velen', 'Drozd');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Fred', 'Roderick');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Sarah', 'Zendová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Emil', 'Zátopek');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Daren', 'Riddick');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Jožko', 'Ďurovec');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Kamil', 'Vejvářka');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Gustav', 'Tišenko');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Táňa', 'Hrochová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Gotlieb', 'Hesna');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Karel', 'Gott');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Richard', 'Krajčo');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Robert', 'Hajný');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Ladislav', 'Ředkvička');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Jana', 'Hrušková');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Martina', 'Postránecká');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Romana', 'Hildebrantová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Milan', 'Rezek');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Leoš', 'Kuzmovič');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Rupert', 'Baal');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Winona', 'Ryder');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Ellen', 'Ripley');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Tamara', 'Hudecká');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Norbert', 'Ditrich');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Nastěnka', 'Ivanovna');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Arnold', 'Schwarzeneger');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('David', 'Schwarz');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Richard', 'Tesařík');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Jan', 'Stejný');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Aneta', 'Dreyerová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Josef', 'Zámotek');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Milena', 'Zvířetová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('René', 'Živočichář');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Tomáš', 'Staněk');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Ladislav', 'Votočka');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Otto', 'Munzar');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Ladislava', 'Munzarová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Filip', 'Ulrich');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Naděžda', 'Ulrichová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Kamil', 'Sytý');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Lenka', 'Sytá');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Michael', 'Ris');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('David', 'Rusnack');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Jan', 'Kopanina');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Eliška', 'Kopaninová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Radka', 'Malá');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Ondřej', 'Konipas');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Ladislav', 'Vlk');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Roman', 'Šakal');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Bořek', 'Stavitel');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Karkulka', 'Červená');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Liběna', 'Rozumná');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Ola', 'Guttenbergová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Will', 'Downhill');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Homer', 'Simpson');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Dana', 'Cudná');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Dobromila', 'Fukalíková');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Zdeněk', 'Hraboš');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Timoty', 'Pilsner');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Xi', 'Xao');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Napoleón', 'Bonnaparte');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Matt', 'Damon');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Jude', 'Law');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Anthony', 'Hopkins');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Robert', 'Redford');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Jura', 'Zmožek');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Jeremy', 'Irons');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Marry', 'Fuchsová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Hynek', 'Herby');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Veronika', 'Viknářová');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Tomáš', 'Kotrba');
INSERT INTO pasazer (jmeno, prijmeni) VALUES ('Roman', 'Záruba');
INSERT INTO pasazer (jmeno, prijmeni, problematicky) VALUES ('Daniel', 'Výbojný', 'y');
INSERT INTO pasazer (jmeno, prijmeni, problematicky) VALUES ('Gabriel', 'Seneca', 'y');
INSERT INTO pasazer (jmeno, prijmeni, problematicky) VALUES ('Norbert', 'Raff', 'y');

INSERT INTO letova_linka (nazev) VALUES ('New York - Prague - Moscow');
INSERT INTO letova_linka (nazev) VALUES ('Prague - Cairo');
INSERT INTO letova_linka (nazev) VALUES ('Lisbon - Prague - St Petersburg');
INSERT INTO letova_linka (nazev) VALUES ('Manchester - Stockholm - Ekaterinburg');
INSERT INTO letova_linka (nazev) VALUES ('Dubai - Prague - Malaga');
INSERT INTO letova_linka (nazev) VALUES ('London - Prague - Heraklion');
INSERT INTO letova_linka (nazev) VALUES ('Prague - Kiev');
INSERT INTO letova_linka (nazev) VALUES ('Madrid - Milan - Vilnius');
INSERT INTO letova_linka (nazev) VALUES ('Toronto - London - Prague - Moscow');
INSERT INTO letova_linka (nazev) VALUES ('Atlanta - Dublin - Prague - Moscow');
INSERT INTO letova_linka (nazev) VALUES ('Malta - Prague - Trondheim');
INSERT INTO letova_linka (nazev) VALUES ('Stavenger - Warsaw - Tbilisi');
INSERT INTO letova_linka (nazev) VALUES ('Oslo - Berlin - Prague');
INSERT INTO letova_linka (nazev) VALUES ('Barcelona - Prague - Kosice');
INSERT INTO letova_linka (nazev) VALUES ('Madrid - Paris - Prague - Istanbul');
INSERT INTO letova_linka (nazev) VALUES ('Prague - Paris - Prague');
INSERT INTO letova_linka (nazev) VALUES ('Prague - London - Prague');

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'New York - Prague - Moscow'), 0, 0, TO_DATE('06:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'New York'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'New York - Prague - Moscow'), 1, 6628, TO_DATE('11:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'New York - Prague - Moscow'), 2, 1611, TO_DATE('16:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Moscow'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Prague - Cairo'), 0, 0, TO_DATE('12:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Prague - Cairo'), 1, 1200, TO_DATE('16:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Cairo'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Lisbon - Prague - St Petersburg'), 0, 0, TO_DATE('05:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Lisbon'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Lisbon - Prague - St Petersburg'), 1, 2238, TO_DATE('10:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Lisbon - Prague - St Petersburg'), 2, 1320, TO_DATE('18:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'St Petersburg'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Manchester - Stockholm - Ekaterinburg'), 0, 0, TO_DATE('13:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Manchester'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Manchester - Stockholm - Ekaterinburg'), 1, 1805, TO_DATE('16:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Stockholm'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Manchester - Stockholm - Ekaterinburg'), 2, 3100, TO_DATE('23:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Ekaterinburg'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Dubai - Prague - Malaga'), 0, 0, TO_DATE('22:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dubai'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Dubai - Prague - Malaga'), 1, 4472, TO_DATE('03:10', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Dubai - Prague - Malaga'), 2, 3456, TO_DATE('08:50', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Malaga'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'London - Prague - Heraklion'), 0, 0, TO_DATE('10:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'London'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'London - Prague - Heraklion'), 1, 950, TO_DATE('13:50', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'London - Prague - Heraklion'), 2, 2700, TO_DATE('18:50', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Heraklion'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Prague - Kiev'), 0, 0, TO_DATE('22:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Prague - Kiev'), 1, 1305, TO_DATE('03:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Kiev'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Madrid - Milan - Vilnius'), 0, 0, TO_DATE('00:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Madrid'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Madrid - Milan - Vilnius'), 1, 1635, TO_DATE('03:30', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Milan'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Madrid - Milan - Vilnius'), 2, 2000, TO_DATE('09:20', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Vilnius'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Toronto - London - Prague - Moscow'), 0, 0, TO_DATE('22:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Toronto'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Toronto - London - Prague - Moscow'), 1, 5647, TO_DATE('04:30', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'London'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Toronto - London - Prague - Moscow'), 2, 950, TO_DATE('09:20', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Toronto - London - Prague - Moscow'), 3, 1865, TO_DATE('13:30', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Moscow'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Atlanta - Dublin - Prague - Moscow'), 0, 0, TO_DATE('01:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Atlanta'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Atlanta - Dublin - Prague - Moscow'), 1, 8345, TO_DATE('08:30', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dublin'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Atlanta - Dublin - Prague - Moscow'), 2, 1565, TO_DATE('10:30', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Atlanta - Dublin - Prague - Moscow'), 3, 1865, TO_DATE('15:50', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Moscow'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Malta - Prague - Trondheim'), 0, 0, TO_DATE('07:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Malta'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Malta - Prague - Trondheim'), 1, 2450, TO_DATE('10:10', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Malta - Prague - Trondheim'), 2, 2025, TO_DATE('13:20', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Trondheim'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Stavenger - Warsaw - Tbilisi'), 0, 0, TO_DATE('09:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Stavenger'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Stavenger - Warsaw - Tbilisi'), 1, 2034, TO_DATE('12:20', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Warsaw'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Stavenger - Warsaw - Tbilisi'), 2, 1790, TO_DATE('14:40', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Tbilisi'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Oslo - Berlin - Prague'), 0, 0, TO_DATE('09:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Oslo'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Oslo - Berlin - Prague'), 1, 1110, TO_DATE('11:20', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Berlin'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Oslo - Berlin - Prague'), 2, 355, TO_DATE('12:10', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Barcelona - Prague - Kosice'), 0, 0, TO_DATE('10:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Barcelona'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Barcelona - Prague - Kosice'), 1, 1755, TO_DATE('14:55', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Barcelona - Prague - Kosice'), 2, 757, TO_DATE('16:10', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Kosice'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Madrid - Paris - Prague - Istanbul'), 0, 0, TO_DATE('23:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Madrid'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Madrid - Paris - Prague - Istanbul'), 1, 1420, TO_DATE('01:50', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Paris'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Madrid - Paris - Prague - Istanbul'), 2, 1040, TO_DATE('03:50', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Madrid - Paris - Prague - Istanbul'), 3, 1865, TO_DATE('06:20', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Istanbul'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Prague - Paris - Prague'), 0, 0, TO_DATE('11:00', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Prague - Paris - Prague'), 1, 1040, TO_DATE('13:25', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Paris'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Prague - Paris - Prague'), 2, 1040, TO_DATE('15:30', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));

INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Prague - London - Prague'), 0, 0, TO_DATE('11:30', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Prague - London - Prague'), 1, 950, TO_DATE('13:25', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'London'));
INSERT INTO zastavka (cislo_letove_linky, poradi_zastavky, km_od_minule_zastavky, pravidelny_cas_odletu, destinace_id) VALUES ((SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Prague - London - Prague'), 2, 950, TO_DATE('14:50', 'HH24:MI'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'));

INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'David' AND z.prijmeni = 'Weigel'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'An-22' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Atlanta - Dublin - Prague - Moscow'), TO_DATE(TO_CHAR(TO_DATE('23.08.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Atlanta - Dublin - Prague - Moscow'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'David' AND z.prijmeni = 'Weigel'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'ATR42-320' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Barcelona - Prague - Kosice'), TO_DATE(TO_CHAR(TO_DATE('20.07.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Barcelona - Prague - Kosice'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'David' AND z.prijmeni = 'Weigel'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'ATR42-320' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Barcelona - Prague - Kosice'), TO_DATE(TO_CHAR(TO_DATE('30.08.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Barcelona - Prague - Kosice'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Josef' AND z.prijmeni = 'Šídlo'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'A310' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Dubai - Prague - Malaga'), TO_DATE(TO_CHAR(TO_DATE('01.06.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Dubai - Prague - Malaga'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Josef' AND z.prijmeni = 'Šídlo'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'A310' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Dubai - Prague - Malaga'), TO_DATE(TO_CHAR(TO_DATE('20.05.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Dubai - Prague - Malaga'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Zdeněk' AND z.prijmeni = 'Vesecký'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'B-52' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Lisbon - Prague - St Petersburg'), TO_DATE(TO_CHAR(TO_DATE('03.03.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Lisbon - Prague - St Petersburg'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Alan' AND z.prijmeni = 'Messer'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'Concorde' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Madrid - Paris - Prague - Istanbul'), TO_DATE(TO_CHAR(TO_DATE('04.12.2008', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Madrid - Paris - Prague - Istanbul'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Zuzana' AND z.prijmeni = 'Komárková'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'B737-400' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'London - Prague - Heraklion'), TO_DATE(TO_CHAR(TO_DATE('05.07.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'London - Prague - Heraklion'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Evžen' AND z.prijmeni = 'Renoir'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'C172' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Malta - Prague - Trondheim'), TO_DATE(TO_CHAR(TO_DATE('06.06.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Malta - Prague - Trondheim'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Evžen' AND z.prijmeni = 'Renoir'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'C172' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Malta - Prague - Trondheim'), TO_DATE(TO_CHAR(TO_DATE('06.07.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Malta - Prague - Trondheim'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Karel' AND z.prijmeni = 'Hrubý'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'EF-2000' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'New York - Prague - Moscow'), TO_DATE(TO_CHAR(TO_DATE('01.09.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'New York - Prague - Moscow'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Karel' AND z.prijmeni = 'Hrubý'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'Dc-10' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Manchester - Stockholm - Ekaterinburg'), TO_DATE(TO_CHAR(TO_DATE('30.04.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Manchester - Stockholm - Ekaterinburg'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'David' AND z.prijmeni = 'Weigel'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'IL-76' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Oslo - Berlin - Prague'), TO_DATE(TO_CHAR(TO_DATE('22.05.2008', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Oslo - Berlin - Prague'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Josef' AND z.prijmeni = 'Šídlo'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'L-1011-500' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Prague - Kiev'), TO_DATE(TO_CHAR(TO_DATE('01.01.2008', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Prague - Kiev'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Aleš' AND z.prijmeni = 'Arbelovský'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'SR-71' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Prague - London - Prague'), TO_DATE(TO_CHAR(TO_DATE('12.12.2007', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Prague - London - Prague'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Aleš' AND z.prijmeni = 'Arbelovský'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'M2000C' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Prague - Paris - Prague'), TO_DATE(TO_CHAR(TO_DATE('28.02.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Prague - Paris - Prague'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Aleš' AND z.prijmeni = 'Arbelovský'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'Tu-154' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Toronto - London - Prague - Moscow'), TO_DATE(TO_CHAR(TO_DATE('27.03.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Toronto - London - Prague - Moscow'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));
INSERT INTO let (cislo_letu, pilot_id, letadlo_id, cislo_letove_linky, cas_odletu) VALUES ('OK' || let_seq.NEXTVAL, (SELECT p.pilot_id FROM pilot p, zamestnanec z WHERE p.zamestnanec_id = z.zamestnanec_id AND z.jmeno = 'Zuzana' AND z.prijmeni = 'Komárková'), (SELECT l.letadlo_id FROM letadlo l WHERE l.typ_letadla_id = 'A319' AND ROWNUM = 1), (SELECT cislo_letove_linky FROM letova_linka WHERE nazev = 'Toronto - London - Prague - Moscow'), TO_DATE(TO_CHAR(TO_DATE('30.03.2009', 'dd.MM.YYYY'), 'dd.MM.YYYY') || ', ' || TO_CHAR((SELECT z.pravidelny_cas_odletu FROM zastavka z, letova_linka l WHERE l.cislo_letove_linky = z.cislo_letove_linky AND z.poradi_zastavky = 0 AND l.nazev = 'Toronto - London - Prague - Moscow'), 'HH24:MI'), 'dd.MM.YYYY, HH24:MI'));

INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK1', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Ali' AND prijmeni = 'Musset'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dublin'), (SELECT destinace_id FROM destinace WHERE nazev = 'Moscow'), 3500.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK1', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Ellen' AND prijmeni = 'Ripley'), (SELECT destinace_id FROM destinace WHERE nazev = 'Atlanta'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dublin'), 8500.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK1', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Filip' AND prijmeni = 'Ulrich'), (SELECT destinace_id FROM destinace WHERE nazev = 'Atlanta'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), 8600.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK2', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Jakub' AND prijmeni = 'Hejný'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), (SELECT destinace_id FROM destinace WHERE nazev = 'Kosice'), 1200.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK2', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Dobromila' AND prijmeni = 'Fukalíková'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), (SELECT destinace_id FROM destinace WHERE nazev = 'Kosice'), 1200.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK2', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Ali' AND prijmeni = 'Musset'), (SELECT destinace_id FROM destinace WHERE nazev = 'Barcelona'), (SELECT destinace_id FROM destinace WHERE nazev = 'Kosice'), 2600.0, 1);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK8', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Anthony' AND prijmeni = 'Hopkins'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), (SELECT destinace_id FROM destinace WHERE nazev = 'Heraklion'), 1400.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK8', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Emil' AND prijmeni = 'Zátopek'), (SELECT destinace_id FROM destinace WHERE nazev = 'London'), (SELECT destinace_id FROM destinace WHERE nazev = 'Heraklion'), 3400.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK5', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Gustav' AND prijmeni = 'Tišenko'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dubai'), (SELECT destinace_id FROM destinace WHERE nazev = 'Malaga'), 2340.90, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK5', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Milan' AND prijmeni = 'Zavářka'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dubai'), (SELECT destinace_id FROM destinace WHERE nazev = 'Malaga'), 2340.90, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK5', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Daniel' AND prijmeni = 'Výbojný'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dubai'), (SELECT destinace_id FROM destinace WHERE nazev = 'Malaga'), 2340.90, 1);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK5', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Roman' AND prijmeni = 'Šakal'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dubai'), (SELECT destinace_id FROM destinace WHERE nazev = 'Malaga'), 2340.90, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK5', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Uma' AND prijmeni = 'Thurman'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), (SELECT destinace_id FROM destinace WHERE nazev = 'Malaga'), 1340.50, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK5', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Gabriel' AND prijmeni = 'Seneca'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), (SELECT destinace_id FROM destinace WHERE nazev = 'Malaga'), 1340.50, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK5', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'John' AND prijmeni = 'Smith'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dubai'), (SELECT destinace_id FROM destinace WHERE nazev = 'Malaga'), 2340.90, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK5', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Luboš' AND prijmeni = 'Kocián'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dubai'), (SELECT destinace_id FROM destinace WHERE nazev = 'Malaga'), 2340.90, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK5', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Ondřej' AND prijmeni = 'Konipas'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dubai'), (SELECT destinace_id FROM destinace WHERE nazev = 'Malaga'), 2340.90, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK5', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Radka' AND prijmeni = 'Malá'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dubai'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), 2140.50, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK5', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Brian' AND prijmeni = 'Kernigan'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dubai'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), 2140.50, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK5', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Jan' AND prijmeni = 'Kopanina'), (SELECT destinace_id FROM destinace WHERE nazev = 'Dubai'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), 2140.50, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK9', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Homer' AND prijmeni = 'Simpson'), (SELECT destinace_id FROM destinace WHERE nazev = 'Malta'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), 2320.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK9', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Hynek' AND prijmeni = 'Herby'), (SELECT destinace_id FROM destinace WHERE nazev = 'Malta'), (SELECT destinace_id FROM destinace WHERE nazev = 'Trondheim'), 3140.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK7', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Filip' AND prijmeni = 'Rusnovič'), (SELECT destinace_id FROM destinace WHERE nazev = 'Madrid'), (SELECT destinace_id FROM destinace WHERE nazev = 'Paris'), 1578.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK7', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Ladislava' AND prijmeni = 'Munzarová'), (SELECT destinace_id FROM destinace WHERE nazev = 'Paris'), (SELECT destinace_id FROM destinace WHERE nazev = 'Istanbul'), 2420.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK7', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Leoš' AND prijmeni = 'Kuzmovič'), (SELECT destinace_id FROM destinace WHERE nazev = 'Paris'), (SELECT destinace_id FROM destinace WHERE nazev = 'Istanbul'), 2420.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK15', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Milena' AND prijmeni = 'Zvířetová'), (SELECT destinace_id FROM destinace WHERE nazev = 'London'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), 1800.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK15', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Sadam' AND prijmeni = 'Husain'), (SELECT destinace_id FROM destinace WHERE nazev = 'London'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), 1800.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK7', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Arnold' AND prijmeni = 'Schwarzeneger'), (SELECT destinace_id FROM destinace WHERE nazev = 'Paris'), (SELECT destinace_id FROM destinace WHERE nazev = 'Istanbul'), 2900.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK6', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Kamil' AND prijmeni = 'Sytý'), (SELECT destinace_id FROM destinace WHERE nazev = 'Lisbon'), (SELECT destinace_id FROM destinace WHERE nazev = 'St Petersburg'), 4900.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK6', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Will' AND prijmeni = 'Downhill'), (SELECT destinace_id FROM destinace WHERE nazev = 'Lisbon'), (SELECT destinace_id FROM destinace WHERE nazev = 'St Petersburg'), 4900.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK6', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Daniel' AND prijmeni = 'Výbojný'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), (SELECT destinace_id FROM destinace WHERE nazev = 'St Petersburg'), 2900.0, 1);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK6', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Forest' AND prijmeni = 'Gump'), (SELECT destinace_id FROM destinace WHERE nazev = 'Lisbon'), (SELECT destinace_id FROM destinace WHERE nazev = 'St Petersburg'), 4900.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK6', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Hynek' AND prijmeni = 'Bašta'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), (SELECT destinace_id FROM destinace WHERE nazev = 'St Petersburg'), 2900.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK6', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Kirsten' AND prijmeni = 'Bovariová'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), (SELECT destinace_id FROM destinace WHERE nazev = 'St Petersburg'), 2900.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK6', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Karel' AND prijmeni = 'Gott'), (SELECT destinace_id FROM destinace WHERE nazev = 'Lisbon'), (SELECT destinace_id FROM destinace WHERE nazev = 'St Petersburg'), 4900.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK6', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Michael' AND prijmeni = 'Gotling'), (SELECT destinace_id FROM destinace WHERE nazev = 'Lisbon'), (SELECT destinace_id FROM destinace WHERE nazev = 'St Petersburg'), 4900.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK17', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Milan' AND prijmeni = 'Rezek'), (SELECT destinace_id FROM destinace WHERE nazev = 'London'), (SELECT destinace_id FROM destinace WHERE nazev = 'Moscow'), 3340.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK17', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Bořek' AND prijmeni = 'Stavitel'), (SELECT destinace_id FROM destinace WHERE nazev = 'London'), (SELECT destinace_id FROM destinace WHERE nazev = 'Moscow'), 3340.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK13', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Daniel' AND prijmeni = 'Výbojný'), (SELECT destinace_id FROM destinace WHERE nazev = 'Oslo'), (SELECT destinace_id FROM destinace WHERE nazev = 'Berlin'), 1900.0, 1);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK13', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Uma' AND prijmeni = 'Thurman'), (SELECT destinace_id FROM destinace WHERE nazev = 'Berlin'), (SELECT destinace_id FROM destinace WHERE nazev = 'Prague'), 890.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK12', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Martina' AND prijmeni = 'Postránecká'), (SELECT destinace_id FROM destinace WHERE nazev = 'Manchester'), (SELECT destinace_id FROM destinace WHERE nazev = 'Ekaterinburg'), 4340.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK12', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Richard' AND prijmeni = 'Tesařík'), (SELECT destinace_id FROM destinace WHERE nazev = 'Stockholm'), (SELECT destinace_id FROM destinace WHERE nazev = 'Ekaterinburg'), 3100.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK12', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Tamara' AND prijmeni = 'Hudecká'), (SELECT destinace_id FROM destinace WHERE nazev = 'Stockholm'), (SELECT destinace_id FROM destinace WHERE nazev = 'Ekaterinburg'), 3100.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK12', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Timoty' AND prijmeni = 'Pilsner'), (SELECT destinace_id FROM destinace WHERE nazev = 'Stockholm'), (SELECT destinace_id FROM destinace WHERE nazev = 'Ekaterinburg'), 3100.0, 0);
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, pocet_prestupku) VALUES ('OK12', (SELECT pasazer_id FROM pasazer WHERE jmeno = 'Winona' AND prijmeni = 'Ryder'), (SELECT destinace_id FROM destinace WHERE nazev = 'Manchester'), (SELECT destinace_id FROM destinace WHERE nazev = 'Ekaterinburg'), 4340.0, 0);

update zamestnanec set pohlavi = 'f' where jmeno = 'Helena' or jmeno = 'Jana'
or jmeno = 'Eliška' or jmeno = 'Monika' or jmeno = 'Kristýna' or jmeno = 'Zuzana';


commit;