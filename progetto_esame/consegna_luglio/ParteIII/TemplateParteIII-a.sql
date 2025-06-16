--- Progetto BD 24-25 (12 CFU)
--- Gruppo 35
--- Alessio Molinas 5339413
--- Ettore Romano 5644926


--- PARTE III 
/*************************************************************************************************************************************************************************/ 
--1b. Schema per popolamento in the large
/*************************************************************************************************************************************************************************/ 
/* per ogni relazione R coinvolta nel carico di lavoro, inserire qui i comandi SQL per creare una nuova relazione R_CL con schema equivalente a R ma senza vincoli di chiave primaria, secondaria o esterna e con eventuali attributi dummy */

CREATE TYPE tipo_artista AS ENUM ('C');
CREATE TYPE tipo_lega AS ENUM ('PUBBLICA', 'PRIVATA', 'SEGRETA');
CREATE TYPE tipo_approvazione AS ENUM ('IN_APPROVAZIONE', 'RIFIUTATA', 'APPROVATA');

-- ARTISTI_CL con CHECK
CREATE TABLE artisti_cl (
    codArtista INTEGER,
    nomeGruppo VARCHAR(50),
    nome VARCHAR(50),
    cognome VARCHAR(50),
    dataNascita DATE,
    luogoNascita VARCHAR(100),
    tipo tipo_artista,
    biografia VARCHAR(255),
    genereMusicale VARCHAR(50),
    edizioniPassate VARCHAR(100),
    costoBaudi NUMERIC,
    CONSTRAINT chk_artista_o_gruppo_esclusivo
        CHECK (
            (nomeGruppo IS NOT NULL AND nome IS NULL AND cognome IS NULL AND dataNascita IS NULL AND luogoNascita IS NULL)
            OR
            (nomeGruppo IS NULL AND nome IS NOT NULL AND cognome IS NOT NULL AND dataNascita IS NOT NULL AND luogoNascita IS NOT NULL)
        ),
    CONSTRAINT chk_dati_cantante_con_tipo
        CHECK (
            (
                tipo = 'C' AND 
                biografia IS NOT NULL AND 
                genereMusicale IS NOT NULL AND 
                edizioniPassate IS NOT NULL AND 
                costoBaudi IS NOT NULL
            )
            OR
            (
                tipo <> 'C' AND 
                biografia IS NULL AND 
                genereMusicale IS NULL AND 
                edizioniPassate IS NULL AND 
                costoBaudi IS NULL
            )
        )
);

-- LEGHE_CL senza vincoli
CREATE TABLE leghe_cl (
    codLega INTEGER,
    nome VARCHAR(50),
    tipo tipo_lega
);

-- PARTECIPAZIONE_LEGHE_CL senza vincoli
CREATE TABLE partecipazione_leghe_cl (
    codSquadra INTEGER,
    codLega INTEGER,
    statoApprovazione tipo_approvazione
);

-- SQUADRE_CL senza vincoli
CREATE TABLE squadre_cl (
    codSquadra INTEGER,
    nome VARCHAR(50),
    username VARCHAR(30)
);
/*************************************************************************************************************************************************************************/
--1c. Carico di lavoro
/*************************************************************************************************************************************************************************/ 
/*************************************************************************************************************************************************************************/ 
/* Q1: Query con singola selezione e nessun join */
/*************************************************************************************************************************************************************************/ 
/* inserire qui i comandi SQL per la creazione della query, in modo da visualizzarne piane di esecuzione e tempi di esecuzione */ 

SELECT COALESCE(nomeGruppo, CONCAT(nome, ' ', cognome)) AS nome_artista, biografia
FROM artisti
WHERE tipo = 'C';

/*************************************************************************************************************************************************************************/ 
/* Q2: Query con condizione di selezione complessa e nessun join */
/*************************************************************************************************************************************************************************/ 
/* inserire qui i comandi SQL per la creazione della query, in modo da visualizzarne piane di esecuzione e tempi di esecuzion */ 

SELECT *
FROM artisti
WHERE tipo = 'C' AND dataNascita > DATE '1992-01-01';
/*************************************************************************************************************************************************************************/ 
/* Q3: Query con almeno un join e almeno una condizione di selezione */
/*************************************************************************************************************************************************************************/ 
/* inserire qui i comandi SQL per la creazione della query, in modo da visualizzarne piane di esecuzione e tempi di esecuzione */ 
SELECT l.nome AS nome_lega, s.nome AS nome_squadra
FROM leghe l
JOIN partecipazione_leghe pl ON l.codLega = pl.codLega
JOIN squadre s ON pl.codSquadra = s.codSquadra
WHERE l.tipo = 'PUBBLICA';

/*************************************************************************************************************************************************************************/
--1e. Schema fisico
/*************************************************************************************************************************************************************************/ 
/* inserire qui i comandi SQL per cancellare tutti gli indici già esistenti per le tabelle coinvolte nel carico di lavoro */
--- non capisco la richiesta... in realtà dovrebbe essere creato sulle tabelle dummy...che non hanno indici già presenti.

/* inserire qui i comandi SQL per la creazione dello schema fisico della base di dati in accordo al risultato della fase di progettazione fisica per il carico di lavoro. */
--- artisti
CREATE INDEX idx_artisti_cl_tipo_datanascita 
ON artisti_cl(tipo, dataNascita);
CLUSTER artisti_cl 
USING idx_artisti_cl_tipo_datanascita;

--- leghe
CREATE INDEX idx_leghe_cl_tipo 
ON leghe_cl(tipo);
CLUSTER leghe_cl 
USING idx_leghe_cl_tipo;

--- partecipazione_leghe
CREATE INDEX idx_partecipazione_leghe_cl_codlega 
ON partecipazione_leghe_cl(codLega);

--- squadre
CREATE INDEX idx_squadre_cl_codSquadra 
ON squadre_cl(codSquadra);

/*************************************************************************************************************************************************************************/ 
--2. Controllo dell'accesso 
/*************************************************************************************************************************************************************************/ 

/* inserire qui i comandi SQL per la definizione della politica di controllo dell'accesso della base di dati  (definizione ruoli, gerarchia, definizione utenti, assegnazione privilegi) in modo che, dopo l'esecuzione di questi comandi, 
le operazioni corrispondenti ai privilegi delegati ai ruoli e agli utenti sia correttamente eseguibili. */








