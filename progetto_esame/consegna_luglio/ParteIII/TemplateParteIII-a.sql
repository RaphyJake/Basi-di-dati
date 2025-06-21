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
/* inserire qui i comandi SQL per cancellare tutti gli indici già esistenti per le tabelle coinvolte nel carico di lavoro */
---Sulle tabelle "_cl" non sono presenti indici da cancellare in quanto non copiati durante la creazione delle stesse

/* inserire qui i comandi SQL per la creazione dello schema fisico della base di dati in accordo al risultato della fase di progettazione fisica per il carico di lavoro. */
--- artisti
CREATE INDEX idx_artisti_cl_nome_datanascita
ON artisti_cl (nome, dataNascita);
CLUSTER artisti_cl USING idx_artisti_cl_nome_datanascita;

CREATE INDEX idx_leghe_cl_nome
ON leghe_cl (nome);

/*************************************************************************************************************************************************************************/ 
--2. Controllo dell'accesso 
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per la definizione della politica di controllo dell'accesso della base di dati  (definizione ruoli, gerarchia, definizione utenti, assegnazione privilegi) in modo che, dopo l'esecuzione di questi comandi, 
le operazioni corrispondenti ai privilegi delegati ai ruoli e agli utenti sia correttamente eseguibili. */

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
GRANT admin_fanta TO mario;-- Mario è super admin
GRANT admin_lega TO lucia;-- Lucia è amministratore lega
GRANT proprietario_lega TO alessio;-- Alessio è proprietario lega
GRANT utente_semplice TO sara;-- Sara è utente semplice

-- PRIVILEGI SULLE TABELLE

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

-- Grants aggiuntivi per proprietario_lega (solo quelli in più)
GRANT SELECT, INSERT, UPDATE, DELETE ON gestione_leghe TO proprietario_lega;
GRANT SELECT, INSERT, UPDATE, DELETE ON leghe TO proprietario_lega;

-- Grants aggiuntivi per admin_lega
GRANT SELECT ON utenti TO admin_lega;

-- Grants aggiuntivi per admin_fanta
GRANT SELECT, INSERT, UPDATE, DELETE ON bonus_assegnati TO admin_fanta;
GRANT SELECT, INSERT, UPDATE, DELETE ON bonus_malus TO admin_fanta;
GRANT SELECT, INSERT, UPDATE, DELETE ON utenti TO admin_fanta;