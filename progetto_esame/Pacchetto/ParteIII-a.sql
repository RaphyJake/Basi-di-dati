--- Progetto BD 24-25 (12 CFU)
--- Gruppo 35
--- Alessio Molinas 5339413
--- Ettore Romano 5644926

--- PARTE III 
/*************************************************************************************************************************************************************************/ 
--1b. Schema per popolamento in the large
/*************************************************************************************************************************************************************************/ 
/* per ogni relazione R coinvolta nel carico di lavoro, inserire qui i comandi SQL per creare una nuova relazione R_CL con schema equivalente a R ma senza vincoli di chiave primaria, secondaria o esterna e con eventuali attributi dummy */
-- ARTISTI_CL con CHECK
SET search_path TO fantasanremo;
DROP TABLE IF EXISTS artisti_cl, leghe_cl, partecipazione_leghe_cl, squadre_cl;
CREATE TABLE artisti_cl
(LIKE artisti INCLUDING DEFAULTS EXCLUDING CONSTRAINTS);

-- LEGHE_CL senza vincoli
CREATE TABLE leghe_cl
(LIKE leghe INCLUDING DEFAULTS EXCLUDING CONSTRAINTS);

-- PARTECIPAZIONE_LEGHE_CL senza vincoli
CREATE TABLE partecipazione_leghe_cl
(LIKE partecipazione_leghe INCLUDING DEFAULTS EXCLUDING CONSTRAINTS);

-- SQUADRE_CL senza vincoli
CREATE TABLE squadre_cl
(LIKE squadre INCLUDING DEFAULTS EXCLUDING CONSTRAINTS);
/*************************************************************************************************************************************************************************/
--1c. Carico di lavoro
/*************************************************************************************************************************************************************************/ 
/*************************************************************************************************************************************************************************/ 
/* Q1: Query con singola selezione e nessun join */
/*************************************************************************************************************************************************************************/ 
/* inserire qui i comandi SQL per la creazione della query, in modo da visualizzarne piane di esecuzione e tempi di esecuzione */ 
SELECT *
FROM artisti_cl
WHERE nome = 'Ana';

/*************************************************************************************************************************************************************************/ 
/* Q2: Query con condizione di selezione complessa e nessun join */
/*************************************************************************************************************************************************************************/ 
/* inserire qui i comandi SQL per la creazione della query, in modo da visualizzarne piane di esecuzione e tempi di esecuzion */ 
SELECT *
FROM artisti_cl
WHERE nome = 'Ana' AND dataNascita >= DATE '1992-01-01';

/*************************************************************************************************************************************************************************/ 
/* Q3: Query con almeno un join e almeno una condizione di selezione */
/*************************************************************************************************************************************************************************/ 
/* inserire qui i comandi SQL per la creazione della query, in modo da visualizzarne piane di esecuzione e tempi di esecuzione */ 
SELECT * FROM leghe_cl l
JOIN partecipazione_leghe_cl pl ON l.codLega = pl.codLega
JOIN squadre_cl s ON pl.codSquadra = s.codSquadra
WHERE l.nome = 'Anthony';

/*************************************************************************************************************************************************************************/
--1e. Schema fisico
/*************************************************************************************************************************************************************************/ 
--- Sulle tabelle "_cl" non sono presenti indici da cancellare in quanto non copiati durante la creazione delle stesse

--- artisti
CREATE INDEX idx_artisti_cl_nome_datanascita
ON artisti_cl (nome, dataNascita);
CLUSTER artisti_cl USING idx_artisti_cl_nome_datanascita;

CREATE INDEX idx_leghe_cl_nome
ON leghe_cl (nome);

/*************************************************************************************************************************************************************************/ 
--2. Controllo dell'accesso 
/*************************************************************************************************************************************************************************/ 
/*
	Gerarchia presa in considerazione: Amministratore Fanta > Amministratore Lega > Proprietario Lega > Utente Semplice
*/

-- Creo ruoli
CREATE ROLE admin_fanta NOLOGIN;
CREATE ROLE admin_lega NOLOGIN;
CREATE ROLE proprietario_lega NOLOGIN;
CREATE ROLE utente_semplice NOLOGIN;

-- Gerarchia ruoli: admin_fanta > admin_lega > proprietario_lega > utente_semplice
GRANT utente_semplice TO proprietario_lega;
GRANT proprietario_lega TO admin_lega;
GRANT admin_lega TO admin_fanta;

CREATE USER mario LOGIN PASSWORD 'marioPass123';
CREATE USER lucia LOGIN PASSWORD 'luciaPass123';
CREATE USER alessio LOGIN PASSWORD 'alessioPass123';
CREATE USER sara LOGIN PASSWORD 'saraPass123';

-- Assegnazione ruoli a utenti creati
GRANT admin_fanta TO mario;-- Mario è admin
GRANT admin_lega TO lucia;-- Lucia è amministratore lega
GRANT proprietario_lega TO alessio;-- Alessio è proprietario lega
GRANT utente_semplice TO sara;-- Sara è utente semplice

-- USAGE ON Schema
GRANT USAGE ON SCHEMA fantasanremo TO admin_fanta;
GRANT USAGE ON SCHEMA fantasanremo TO admin_lega;
GRANT USAGE ON SCHEMA fantasanremo TO proprietario_lega;
GRANT USAGE ON SCHEMA fantasanremo TO utente_semplice;

-- ADMIN Fantasanremo
GRANT ALL PRIVILEGES ON TABLE artisti TO admin_fanta;
GRANT ALL PRIVILEGES ON TABLE brani TO admin_fanta;
GRANT ALL PRIVILEGES ON TABLE contributi_brani TO admin_fanta;
GRANT ALL PRIVILEGES ON TABLE esibizioni TO admin_fanta;
GRANT ALL PRIVILEGES ON TABLE serate TO admin_fanta;
GRANT ALL PRIVILEGES ON TABLE voti TO admin_fanta;
GRANT ALL PRIVILEGES ON TABLE bonus_assegnati TO admin_fanta;
GRANT ALL PRIVILEGES ON TABLE bonus_malus TO admin_fanta;
GRANT ALL PRIVILEGES ON TABLE formazioni TO admin_fanta;
GRANT ALL PRIVILEGES ON TABLE gestione_leghe TO admin_fanta;
GRANT ALL PRIVILEGES ON TABLE leghe TO admin_fanta;
GRANT ALL PRIVILEGES ON TABLE partecipazione_leghe TO admin_fanta;
GRANT ALL PRIVILEGES ON TABLE squadre TO admin_fanta;
GRANT ALL PRIVILEGES ON TABLE utenti TO admin_fanta;

--Proprietario Lega
GRANT SELECT ON TABLE artisti TO proprietario_lega;
GRANT SELECT ON TABLE brani TO proprietario_lega;
GRANT SELECT ON TABLE contributi_brani TO proprietario_lega;
GRANT SELECT ON TABLE esibizioni TO proprietario_lega;
GRANT SELECT ON TABLE serate TO proprietario_lega;
GRANT SELECT ON TABLE voti TO proprietario_lega;
GRANT SELECT ON TABLE bonus_assegnati TO proprietario_lega;
GRANT SELECT ON TABLE bonus_malus TO proprietario_lega;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE formazioni TO proprietario_lega;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE partecipazione_leghe TO proprietario_lega;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE squadre TO proprietario_lega;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE leghe TO proprietario_lega;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE gestione_leghe TO proprietario_lega;

--Admin Lega
GRANT SELECT ON TABLE artisti TO admin_lega;
GRANT SELECT ON TABLE brani TO admin_lega;
GRANT SELECT ON TABLE contributi_brani TO admin_lega;
GRANT SELECT ON TABLE esibizioni TO admin_lega;
GRANT SELECT ON TABLE serate TO admin_lega;
GRANT SELECT ON TABLE voti TO admin_lega;
GRANT SELECT ON TABLE bonus_assegnati TO admin_lega;
GRANT SELECT ON TABLE bonus_malus TO admin_lega;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE formazioni TO admin_lega;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE partecipazione_leghe TO admin_lega;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE squadre TO admin_lega;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE leghe TO admin_lega;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE gestione_leghe TO admin_lega;
GRANT SELECT ON TABLE utenti TO admin_lega;

-- Grants per utente_semplice
GRANT SELECT ON artisti TO utente_semplice;
GRANT SELECT ON brani TO utente_semplice;
GRANT SELECT ON contributi_brani TO utente_semplice;
GRANT SELECT ON esibizioni TO utente_semplice;
GRANT SELECT ON serate TO utente_semplice;
GRANT SELECT ON voti TO utente_semplice;
GRANT SELECT ON bonus_assegnati TO utente_semplice;
GRANT SELECT ON bonus_malus TO utente_semplice;
GRANT SELECT, INSERT, UPDATE, DELETE ON formazioni TO utente_semplice;
GRANT SELECT ON leghe TO utente_semplice;
GRANT SELECT, INSERT, UPDATE, DELETE ON partecipazione_leghe TO utente_semplice;
GRANT SELECT, INSERT, UPDATE, DELETE ON squadre TO utente_semplice;