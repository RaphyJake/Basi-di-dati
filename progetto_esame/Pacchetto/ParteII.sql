--- Progetto BD 24-25 (6CFU)
--- Gruppo 35
--- Alessio Molinas 5339413
--- Ettore Romano 5644926

--- PARTE 2 
/*************************************************************************************************************************************************************************/
--1a. Schema
CREATE SCHEMA IF NOT EXISTS fantasanremo;
SET search_path TO fantasanremo;

-- ENUM TYPES
CREATE TYPE tipo_voto AS ENUM ('TELEVOTO', 'GIURIA_STAMPA', 'GIURIA_RADIO');
CREATE TYPE tipo_lega AS ENUM ('PUBBLICA', 'PRIVATA', 'SEGRETA');
CREATE TYPE tipo_bonusmalus AS ENUM ('EXTRA', 'STANDARD');
CREATE TYPE tipo_approvazione AS ENUM ('IN_APPROVAZIONE', 'RIFIUTATA', 'APPROVATA');
CREATE TYPE ruolo_compone AS ENUM ('CAPITANO', 'TITOLARE', 'RISERVA');
CREATE TYPE tipo_artista AS ENUM ('C');
CREATE TYPE ruolo_artista AS ENUM ('COMPOSITORE', 'DIRETTORE', 'SCRITTORE');

-- UTENTI
CREATE TABLE utenti (
    username VARCHAR(90) NOT NULL,
    nome VARCHAR(50) NOT NULL,
    cognome VARCHAR(50) NOT NULL,
    CONSTRAINT pk_utenti PRIMARY KEY (username)
);

-- LEGHE
CREATE TABLE leghe (
    codLega INTEGER NOT NULL,
    nome VARCHAR(50) NOT NULL,
    tipo tipo_lega NOT NULL,
    CONSTRAINT pk_leghe PRIMARY KEY (codLega)
);

-- BONUS_MALUS
CREATE TABLE bonus_malus (
    codBonusMalus INTEGER NOT NULL,
    descrizione VARCHAR(100) NOT NULL,
    valore NUMERIC NOT NULL,
    tipo tipo_bonusmalus NOT NULL,
    CONSTRAINT pk_bonus_malus PRIMARY KEY (codBonusMalus)
);

-- ARTISTI
CREATE TABLE artisti (
    codArtista INTEGER NOT NULL,
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
    CONSTRAINT pk_artisti PRIMARY KEY (codArtista),
	CONSTRAINT chk_artista_o_gruppo_esclusivo
		CHECK (
    	(
	        nomegruppo IS NOT NULL
	        AND nome IS NULL
	        AND cognome IS NULL
	        AND datanascita IS NULL
	        AND luogonascita IS NULL
    	)
    	OR
    	(
	        nomegruppo IS NULL
	        AND (
	            nome IS NOT NULL
	            OR cognome IS NOT NULL
	            OR datanascita IS NOT NULL
	            OR luogonascita IS NOT NULL
	        )
    	)
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

-- SQUADRE
CREATE TABLE squadre (
    codSquadra INTEGER NOT NULL,
    nome VARCHAR(50) NOT NULL,
    username VARCHAR(30) NOT NULL,
    CONSTRAINT pk_squadre PRIMARY KEY (codSquadra),
    CONSTRAINT fk_squadre_utenti FOREIGN KEY (username) REFERENCES utenti(username) ON DELETE CASCADE ON UPDATE CASCADE
);

-- SERATE
CREATE TABLE serate (
    nome VARCHAR(50) NOT NULL,
    data DATE,
    CONSTRAINT pk_serate PRIMARY KEY (nome)
);

-- BRANI
CREATE TABLE brani (
    codBrano INTEGER NOT NULL,
    titolo VARCHAR(100) NOT NULL,
    codArtista INTEGER NOT NULL,
    genereMusicale VARCHAR(50) NOT NULL,
    durata INTERVAL NOT NULL DEFAULT INTERVAL '0 seconds',
    CONSTRAINT pk_brani PRIMARY KEY (codBrano),
    CONSTRAINT uq_brani_artista_titolo UNIQUE (codArtista, titolo),
    CONSTRAINT fk_brani_artisti FOREIGN KEY (codArtista) REFERENCES artisti(codArtista) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_durata_min CHECK (durata > INTERVAL '0 seconds')
);

-- FORMAZIONI
CREATE TABLE formazioni (
    codArtista INTEGER NOT NULL,
    codSquadra INTEGER NOT NULL,
    nomeSerata VARCHAR(50) NOT NULL,
    ruolo ruolo_compone NOT NULL,
    dataModifica TIMESTAMP NOT NULL,
    CONSTRAINT pk_formazioni PRIMARY KEY (codArtista, codSquadra, nomeSerata),
    CONSTRAINT fk_formazioni_artisti FOREIGN KEY (codArtista) REFERENCES artisti(codArtista) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_formazioni_squadre FOREIGN KEY (codSquadra) REFERENCES squadre(codSquadra) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_formazioni_serate FOREIGN KEY (nomeSerata) REFERENCES serate(nome) ON DELETE CASCADE ON UPDATE CASCADE
);

-- GESTIONE_LEGHE
CREATE TABLE gestione_leghe (
    username VARCHAR(30) NOT NULL,
    codLega INTEGER NOT NULL,
    proprietario BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT pk_gestione_leghe PRIMARY KEY (username, codLega),
    CONSTRAINT fk_gestione_leghe_utenti FOREIGN KEY (username) REFERENCES utenti(username) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_gestione_leghe_leghe FOREIGN KEY (codLega) REFERENCES leghe(codLega) ON DELETE CASCADE ON UPDATE CASCADE
);

-- PARTECIPAZIONE_LEGHE
CREATE TABLE partecipazione_leghe (
    codSquadra INTEGER NOT NULL,
    codLega INTEGER NOT NULL,
    statoApprovazione tipo_approvazione NOT NULL,
    CONSTRAINT pk_partecipazione_leghe PRIMARY KEY (codSquadra, codLega),
    CONSTRAINT fk_partecipazione_leghe_squadre FOREIGN KEY (codSquadra) REFERENCES squadre(codSquadra) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_partecipazione_leghe_leghe FOREIGN KEY (codLega) REFERENCES leghe(codLega) ON DELETE CASCADE ON UPDATE CASCADE
);

-- BONUS_ASSEGNATI
CREATE TABLE bonus_assegnati (
    codSquadra INTEGER NOT NULL,
    codArtista INTEGER NOT NULL,
    nomeSerata VARCHAR(50) NOT NULL,
    codBonusMalus INTEGER NOT NULL,
    valoreEffettivo NUMERIC NOT NULL,
    CONSTRAINT pk_bonus_assegnati PRIMARY KEY (codSquadra, codArtista, nomeSerata, codBonusMalus),
    CONSTRAINT fk_bonus_assegnati_squadre FOREIGN KEY (codSquadra) REFERENCES squadre(codSquadra) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_bonus_assegnati_artisti FOREIGN KEY (codArtista) REFERENCES artisti(codArtista) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_bonus_assegnati_serate FOREIGN KEY (nomeSerata) REFERENCES serate(nome) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_bonus_assegnati_bonus FOREIGN KEY (codBonusMalus) REFERENCES bonus_malus(codBonusMalus) ON DELETE CASCADE ON UPDATE CASCADE
);

-- ESIBIZIONI
CREATE TABLE esibizioni (
    codBrano INTEGER NOT NULL,
    codArtista INTEGER NOT NULL,
    nomeSerata VARCHAR(50) NOT NULL,
    orario TIME NOT NULL,
    ordineEsibizione INTEGER NOT NULL,
    CONSTRAINT pk_esibizioni PRIMARY KEY (codBrano, codArtista, nomeSerata),
    CONSTRAINT fk_esibizioni_brani FOREIGN KEY (codBrano) REFERENCES brani(codBrano) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_esibizioni_artisti FOREIGN KEY (codArtista) REFERENCES artisti(codArtista) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_esibizioni_serate FOREIGN KEY (nomeSerata) REFERENCES serate(nome) ON DELETE CASCADE ON UPDATE CASCADE
);

-- VOTI
CREATE TABLE voti (
    codVoto INTEGER NOT NULL,
    codBrano INTEGER NOT NULL,
    codArtista INTEGER NOT NULL,
    nomeSerata VARCHAR(50) NOT NULL,
    tipo tipo_voto NOT NULL,
    dataOra TIMESTAMP NOT NULL,
    CONSTRAINT pk_voti PRIMARY KEY (codVoto),
    CONSTRAINT fk_voti_brani FOREIGN KEY (codBrano) REFERENCES brani(codBrano) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_voti_artisti FOREIGN KEY (codArtista) REFERENCES artisti(codArtista) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_voti_serate FOREIGN KEY (nomeSerata) REFERENCES serate(nome) ON DELETE CASCADE ON UPDATE CASCADE
);

-- CONTRIBUTI_BRANI
CREATE TABLE contributi_brani (
    codBrano INTEGER NOT NULL,
    codArtista INTEGER NOT NULL,
    tipo ruolo_artista NOT NULL,
    CONSTRAINT pk_contributi_brani PRIMARY KEY (codBrano, codArtista, tipo),
    CONSTRAINT fk_contributi_brani_brani FOREIGN KEY (codBrano) REFERENCES brani(codBrano) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_contributi_brani_artisti FOREIGN KEY (codArtista) REFERENCES artisti(codArtista) ON DELETE CASCADE ON UPDATE CASCADE
);

/* inserire qui i comandi SQL per la creazione dello schema logico della base di dati in accordo allo schema relazionale ottenuto alla fine della fase di progettazione logica, per la porzione necessaria per i punti successivi (cio le tabelle coinvolte dalle interrogazioni nel carico di lavoro, nella definizione della vista, nelle interrogazioni, in funzioni, procedure e trigger). Lo schema dovrˆ essere comprensivo dei vincoli esprimibili con check. */

/*************************************************************************************************************************************************************************/ 
--1b. Popolamento 
/*************************************************************************************************************************************************************************/
/* inserire qui i comandi SQL per il popolamento 'in piccolo' di tale base di dati (utile per il test dei vincoli e delle operazioni in parte 2.) */
-- INSERT SERATE
INSERT INTO serate (nome, data) VALUES
  ('Prima Serata', DATE '2025-02-11'),
  ('Seconda Serata', DATE '2025-02-12'),
  ('Terza Serata', DATE '2025-02-13'),
  ('Quarta Serata', DATE '2025-02-14'),
  ('Finale', DATE '2025-02-15'),
  ('Extra', NULL);


-- INSERT UTENTI
INSERT INTO utenti (username, nome, cognome) VALUES
  ('m.rossi1@email.it', 'Marco', 'Rossi'),
  ('l.bianchi2@email.it', 'Luca', 'Bianchi'),
  ('a.verdi3@email.it', 'Alessia', 'Verdi'),
  ('s.neri4@email.it', 'Sara', 'Neri'),
  ('f.russo5@email.it', 'Francesco', 'Russo'),
  ('g.martini6@email.it', 'Giulia', 'Martini'),
  ('d.ferrari7@email.it', 'Davide', 'Ferrari');
  
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (1, NULL, 'Rkomi', NULL, DATE '1994-04-19', 'Milano', 'C', 'Cantautore e performer provocatorio.', 'Pop', '2019,2022', 10);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (2, NULL, 'Francesco', 'Gabbani', DATE '1982-09-09', 'Carrara', 'C', 'Voce emergente.', 'Pop', '2024', 15);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (3, NULL, 'Gaia', NULL, DATE '1997-09-29', 'Guastalla', 'C', 'Giovane trapper.', 'Trap', '2024', 12);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (4, NULL, 'Noemi', NULL, DATE '1982-01-25', 'Roma', 'C', 'Cantautore lucano.', 'Indie', '2018,2024', 14);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (5, NULL, 'Irama', NULL, DATE '1995-12-20', 'Carrara', 'C', 'Esordiente indie pop.', 'Pop', '2024', 9);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (6, 'Coma_Cose', NULL, NULL, NULL, NULL, 'C', 'Duo indie pop milanese.', 'Indie Pop', '2022,2023', 10);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (7, NULL, 'Simone', 'Cristicchi', DATE '1977-05-02', 'Roma', 'C', 'Artista e icona di stile.', 'Pop', '2017,2020,2024', 14);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (8, NULL, 'Marcella', 'Bella', DATE '1952-06-18', 'Catania', 'C', 'Rapper e personaggio mediatico.', 'Pop Rap', '2020,2024', 15);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (9, NULL, 'Achille', 'Lauro', DATE '1990-11-07', 'Verona', 'C', 'Cantautrice e producer.', 'Pop', '2016,2017,2024', 7);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (10, NULL, 'Giorgia', NULL, DATE '1971-01-26', 'Roma', 'C', 'Vincitore di Sanremo 2017.', 'Pop', '2016,2017,2024', 10);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (11, NULL, 'Fabio', 'Barnaba', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (12, NULL, 'Andrea', 'Benassai', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (13, NULL, 'Daniel', 'Bestonzo', NULL, NULL, NULL, NULL, NULL, NULL, NULL);

  
INSERT INTO brani (codBrano, titolo, codArtista, genereMusicale, durata) VALUES
(1, 'Il ritmo delle cose', 1, 'Pop Rap', INTERVAL '185 seconds'),
(2, 'Viva la vita', 2, 'Pop', INTERVAL '210 seconds'),
(3, 'Chiamo io chiami tu', 3, 'Pop', INTERVAL '200 seconds'),
(4, 'Se t innamori muori', 4, 'Pop', INTERVAL '205 seconds'),
(5, 'Lentamente', 5, 'Pop', INTERVAL '190 seconds'),
(6, 'Cuoricini', 6, 'Indie Pop', INTERVAL '195 seconds'),
(7, 'Quando sarai piccola', 7, 'Cantautorato', INTERVAL '215 seconds'),
(8, 'Pelle diamante', 8, 'Pop', INTERVAL '180 seconds'),
(9, 'Incoscienti giovani', 9, 'Pop', INTERVAL '200 seconds'),
(10, 'La cura per me', 10, 'Pop', INTERVAL '220 seconds');

INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (3, 3, 'Prima Serata', TIME '21:00:00', 1);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (2, 2, 'Prima Serata', TIME '21:05:00', 2);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (1, 1, 'Prima Serata', TIME '21:10:00', 3);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (4, 4, 'Prima Serata', TIME '21:15:00', 4);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (5, 5, 'Prima Serata', TIME '21:20:00', 5);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (6, 6, 'Seconda Serata', TIME '21:00:00', 1);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (7, 7, 'Seconda Serata', TIME '21:05:00', 2);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (8, 8, 'Seconda Serata', TIME '21:10:00', 3);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (9, 9, 'Seconda Serata', TIME '21:15:00', 4);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (10, 10, 'Seconda Serata', TIME '21:20:00', 5);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (2, 2, 'Terza Serata', TIME '21:00:00', 1);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (4, 4, 'Terza Serata', TIME '21:05:00', 2);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (6, 6, 'Terza Serata', TIME '21:10:00', 3);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (7, 7, 'Quarta Serata', TIME '21:00:00', 1);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (8, 8, 'Quarta Serata', TIME '21:05:00', 2);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (10, 10, 'Quarta Serata', TIME '21:10:00', 3);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (3, 3, 'Finale', TIME '21:00:00', 1);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (2, 2, 'Finale', TIME '21:05:00', 2);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (7, 7, 'Finale', TIME '21:10:00', 3);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (9, 9, 'Finale', TIME '21:15:00', 4);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (10, 10, 'Finale', TIME '21:20:00', 5);

-- Brano 1
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (1, 11, 'COMPOSITORE');
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (1, 12, 'DIRETTORE');
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (1, 13, 'SCRITTORE');

-- Brano 2
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (2, 12, 'COMPOSITORE');
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (2, 13, 'DIRETTORE');
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (2, 11, 'SCRITTORE');

-- Brano 3
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (3, 13, 'COMPOSITORE');
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (3, 11, 'DIRETTORE');
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (3, 12, 'SCRITTORE');

-- Brano 4
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (4, 11, 'COMPOSITORE');
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (4, 12, 'DIRETTORE');
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (4, 13, 'SCRITTORE');

-- Brano 5
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (5, 12, 'COMPOSITORE');
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (5, 13, 'DIRETTORE');
INSERT INTO contributi_brani (codBrano, codArtista, tipo) VALUES (5, 11, 'SCRITTORE');


INSERT INTO bonus_malus (codBonusMalus, descrizione, valore, tipo) VALUES (1, 'Cantante suona uno strumento', 10, 'STANDARD');
INSERT INTO bonus_malus (codBonusMalus, descrizione, valore, tipo) VALUES (2, 'Presenza di ballerini', 10, 'STANDARD');
INSERT INTO bonus_malus (codBonusMalus, descrizione, valore, tipo) VALUES (3, 'Esibizione con performer non in gara (esclusi ballerini)', 15, 'STANDARD');
INSERT INTO bonus_malus (codBonusMalus, descrizione, valore, tipo) VALUES (4, 'Invasione di palco non programmata', 30, 'STANDARD');
INSERT INTO bonus_malus (codBonusMalus, descrizione, valore, tipo) VALUES (5, 'Seda una rissa in diretta', 25, 'STANDARD');
INSERT INTO bonus_malus (codBonusMalus, descrizione, valore, tipo) VALUES (6, 'Nomina il FantaSanremo sul palco', -10, 'STANDARD');
INSERT INTO bonus_malus (codBonusMalus, descrizione, valore, tipo) VALUES (7, 'Il presentatore sbaglia il titolo della canzone', -10, 'STANDARD');
INSERT INTO bonus_malus (codBonusMalus, descrizione, valore, tipo) VALUES (8, 'Il presentatore sbaglia il nome dell’artista', -5, 'STANDARD');
INSERT INTO bonus_malus (codBonusMalus, descrizione, valore, tipo) VALUES (9, 'Outfit total black', -5, 'STANDARD');
INSERT INTO bonus_malus (codBonusMalus, descrizione, valore, tipo) VALUES (10, 'Non ringrazia verbalmente al termine dell’esibizione', -5, 'STANDARD');
INSERT INTO bonus_malus (codBonusMalus, descrizione, valore, tipo) VALUES (11, 'Batti 5 alla statua di Mike Bongiorno', 10, 'EXTRA');
INSERT INTO bonus_malus (codBonusMalus, descrizione, valore, tipo) VALUES (12, 'Canta con i fan per le vie di Sanremo', 10, 'EXTRA');
INSERT INTO bonus_malus (codBonusMalus, descrizione, valore, tipo) VALUES (13, 'Canta la sigla “Occhi di FantaSanremo” di Cristina D’Avena', 10, 'EXTRA');

INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (1, 6, 6, 'Seconda Serata', 'GIURIA_RADIO', '2025-02-12 21:00:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (2, 8, 8, 'Seconda Serata', 'GIURIA_STAMPA', '2025-02-12 21:10:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (3, 10, 10, 'Seconda Serata', 'TELEVOTO', '2025-02-12 21:20:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (4, 7, 7, 'Seconda Serata', 'TELEVOTO', '2025-02-12 21:05:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (5, 9, 9, 'Seconda Serata', 'TELEVOTO', '2025-02-12 21:15:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (6, 5, 5, 'Prima Serata', 'TELEVOTO', '2025-02-11 21:20:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (7, 2, 2, 'Prima Serata', 'GIURIA_STAMPA', '2025-02-11 21:05:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (8, 4, 4, 'Prima Serata', 'GIURIA_RADIO', '2025-02-11 21:15:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (9, 1, 1, 'Prima Serata', 'GIURIA_STAMPA', '2025-02-11 21:10:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (10, 3, 3, 'Prima Serata', 'GIURIA_RADIO', '2025-02-11 21:00:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (11, 2, 2, 'Terza Serata', 'GIURIA_RADIO', '2025-02-13 21:00:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (12, 4, 4, 'Terza Serata', 'GIURIA_STAMPA', '2025-02-13 21:05:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (13, 6, 6, 'Terza Serata', 'GIURIA_RADIO', '2025-02-13 21:10:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (14, 8, 8, 'Quarta Serata', 'GIURIA_RADIO', '2025-02-14 21:05:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (15, 10, 10, 'Quarta Serata', 'GIURIA_STAMPA', '2025-02-14 21:10:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (16, 7, 7, 'Quarta Serata', 'GIURIA_RADIO', '2025-02-14 21:00:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (17, 10, 10, 'Finale', 'GIURIA_STAMPA', '2025-02-15 21:20:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (18, 7, 7, 'Finale', 'TELEVOTO', '2025-02-15 21:10:00');
INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra) VALUES (19, 2, 2, 'Finale', 'GIURIA_RADIO', '2025-02-15 21:05:00');

INSERT INTO squadre (codSquadra, nome, username) VALUES (1, 'Sanremo Stars', 'm.rossi1@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (2, 'Festival Fighters', 'l.bianchi2@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (3, 'Note Ribelli', 'a.verdi3@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (4, 'Gli Urlatori', 's.neri4@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (5, 'Melodici Anonimi', 'f.russo5@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (6, 'Quelli del Fantasanremo', 'g.martini6@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (7, 'I Votatori Seriali', 'd.ferrari7@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (8, 'RaiRebels', 'm.rossi1@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (9, 'Canzonissimi', 'l.bianchi2@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (10, 'Gli Aristoniani', 'a.verdi3@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (11, 'Microfoni Bollenti', 's.neri4@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (12, 'Tutti cantano Sanremo', 'f.russo5@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (13, 'Liguri in Gara', 'g.martini6@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (14, 'Coda alla Rampa', 'd.ferrari7@email.it');
INSERT INTO squadre (codSquadra, nome, username) VALUES (15, 'Ultimi Ma Belli', 'm.rossi1@email.it');

INSERT INTO leghe (codLega, nome, tipo) VALUES (1, 'Liguri in Gara', 'PUBBLICA');
INSERT INTO leghe (codLega, nome, tipo) VALUES (2, 'Gli Amici del Fantasanremo', 'PRIVATA');
INSERT INTO leghe (codLega, nome, tipo) VALUES (3, 'Giocati di Casa', 'PUBBLICA');
INSERT INTO leghe (codLega, nome, tipo) VALUES (4, 'I Segretissimi', 'SEGRETA');
INSERT INTO leghe (codLega, nome, tipo) VALUES (5, 'Team Festivalieri', 'PRIVATA');


INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (4, 1, 'Prima Serata', 'CAPITANO', '2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (10, 1, 'Prima Serata', 'TITOLARE','2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (6, 1, 'Prima Serata', 'TITOLARE', '2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (7, 1, 'Prima Serata', 'TITOLARE', '2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (2, 1, 'Prima Serata', 'TITOLARE', '2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (9, 1, 'Prima Serata', 'RISERVA', '2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (3, 1, 'Prima Serata', 'RISERVA', '2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (2, 1, 'Seconda Serata', 'CAPITANO', '2025-02-12 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (3, 1, 'Seconda Serata', 'TITOLARE', '2025-02-12 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (1, 1, 'Seconda Serata', 'TITOLARE', '2025-02-12 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (8, 1, 'Seconda Serata', 'TITOLARE', '2025-02-12 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (7, 1, 'Seconda Serata', 'TITOLARE', '2025-02-12 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (10, 1, 'Seconda Serata', 'RISERVA', '2025-02-12 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (9, 1, 'Seconda Serata', 'RISERVA', '2025-02-12 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (1, 2, 'Prima Serata', 'CAPITANO', '2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (7, 2, 'Prima Serata', 'TITOLARE', '2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (10, 2, 'Prima Serata', 'TITOLARE', '2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (4, 2, 'Prima Serata', 'TITOLARE', '2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (9, 2, 'Prima Serata', 'TITOLARE', '2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (8, 2, 'Prima Serata', 'RISERVA', '2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (3, 2, 'Prima Serata', 'RISERVA', '2025-02-11 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (9, 2, 'Seconda Serata', 'CAPITANO', '2025-02-12 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (7, 2, 'Seconda Serata', 'TITOLARE', '2025-02-12 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (2, 2, 'Seconda Serata', 'TITOLARE', '2025-02-12 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (5, 2, 'Seconda Serata', 'TITOLARE', '2025-02-12 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (6, 2, 'Seconda Serata', 'TITOLARE', '2025-02-12 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (4, 2, 'Seconda Serata', 'RISERVA', '2025-02-12 12:00:00');
INSERT INTO formazioni (codArtista, codSquadra, nomeSerata, ruolo, dataModifica) VALUES (8, 2, 'Seconda Serata', 'RISERVA', '2025-02-12 12:00:00');

-- Lega 1: Liguri in Gara
INSERT INTO gestione_leghe (username, codLega, proprietario) VALUES ('m.rossi1@email.it', 1, TRUE);
INSERT INTO gestione_leghe (username, codLega, proprietario) VALUES ('s.neri4@email.it', 1, FALSE);

-- Lega 2: Gli Amici del Fantasanremo
INSERT INTO gestione_leghe (username, codLega, proprietario) VALUES ('a.verdi3@email.it', 2, TRUE);
INSERT INTO gestione_leghe (username, codLega, proprietario) VALUES ('f.russo5@email.it', 2, FALSE);

-- Lega 3: Giocati di Casa
INSERT INTO gestione_leghe (username, codLega, proprietario) VALUES ('l.bianchi2@email.it', 3, TRUE);
INSERT INTO gestione_leghe (username, codLega, proprietario) VALUES ('g.martini6@email.it', 3, FALSE);

-- Lega 4: I Segretissimi
INSERT INTO gestione_leghe (username, codLega, proprietario) VALUES ('d.ferrari7@email.it', 4, TRUE);
INSERT INTO gestione_leghe (username, codLega, proprietario) VALUES ('m.rossi1@email.it', 4, FALSE);

-- Lega 5: Team Festivalieri
INSERT INTO gestione_leghe (username, codLega, proprietario) VALUES ('g.martini6@email.it', 5, TRUE);
INSERT INTO gestione_leghe (username, codLega, proprietario) VALUES ('l.bianchi2@email.it', 5, FALSE);

-- Partecipazione alla lega 1 (Liguri in Gara)
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (1, 1, 'APPROVATA');
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (2, 1, 'APPROVATA');
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (3, 1, 'APPROVATA');
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (4, 1, 'APPROVATA');
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (5, 1, 'APPROVATA');
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (6, 1, 'APPROVATA');
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (7, 1, 'APPROVATA');
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (8, 1, 'APPROVATA');

-- Partecipazione alla lega 3 (Giocati di Casa)
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (9, 3, 'APPROVATA');
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (10, 3, 'APPROVATA');
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (11, 3, 'APPROVATA');
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (12, 3, 'APPROVATA');
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (13, 3, 'APPROVATA');
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (14, 3, 'APPROVATA');
INSERT INTO partecipazione_leghe (codSquadra, codLega, statoApprovazione) VALUES (15, 3, 'APPROVATA');


INSERT INTO bonus_assegnati (codSquadra, codArtista, nomeSerata, codBonusMalus, valoreEffettivo) VALUES (1, 4, 'Prima Serata', 10, -5);
INSERT INTO bonus_assegnati (codSquadra, codArtista, nomeSerata, codBonusMalus, valoreEffettivo) VALUES (1, 4, 'Prima Serata', 9, -5);
INSERT INTO bonus_assegnati (codSquadra, codArtista, nomeSerata, codBonusMalus, valoreEffettivo) VALUES (1, 10, 'Prima Serata', 6, -10);
INSERT INTO bonus_assegnati (codSquadra, codArtista, nomeSerata, codBonusMalus, valoreEffettivo) VALUES (1, 6, 'Prima Serata', 5, 25);
INSERT INTO bonus_assegnati (codSquadra, codArtista, nomeSerata, codBonusMalus, valoreEffettivo) VALUES (1, 6, 'Prima Serata', 8, -5);
INSERT INTO bonus_assegnati (codSquadra, codArtista, nomeSerata, codBonusMalus, valoreEffettivo) VALUES (1, 7, 'Prima Serata', 5, 25);
INSERT INTO bonus_assegnati (codSquadra, codArtista, nomeSerata, codBonusMalus, valoreEffettivo) VALUES (1, 7, 'Prima Serata', 3, 15);
INSERT INTO bonus_assegnati (codSquadra, codArtista, nomeSerata, codBonusMalus, valoreEffettivo) VALUES (1, 2, 'Prima Serata', 10, -5);
INSERT INTO bonus_assegnati (codSquadra, codArtista, nomeSerata, codBonusMalus, valoreEffettivo) VALUES (1, 9, 'Prima Serata', 9, -5);
INSERT INTO bonus_assegnati (codSquadra, codArtista, nomeSerata, codBonusMalus, valoreEffettivo) VALUES (1, 9, 'Prima Serata', 8, -5);
INSERT INTO bonus_assegnati (codSquadra, codArtista, nomeSerata, codBonusMalus, valoreEffettivo) VALUES (1, 3, 'Prima Serata', 9, -5);
INSERT INTO bonus_assegnati (codSquadra, codArtista, nomeSerata, codBonusMalus, valoreEffettivo) VALUES (1, 3, 'Prima Serata', 8, -5);

/*************************************************************************************************************************************************************************/ 
--2. Vista 
/*
Per ogni serata, per ogni squadra e per ogni versione della formazione (identificata dalla data di modifica), la vista mostra il nome della squadra, il costo medio in baudi degli artisti schierati, il costo minimo e il costo massimo all'interno di quella formazione.
*/ 
CREATE OR REPLACE VIEW v_costi_formazione_squadra AS
SELECT
    f.nomeSerata,
    f.codSquadra,
    s.nome AS nomeSquadra,
    f.dataModifica,
    ROUND(AVG(a.costoBaudi), 2) AS costo_medio_baudi,
    MIN(a.costoBaudi) AS costo_min_baudi,
    MAX(a.costoBaudi) AS costo_max_baudi
FROM
    formazioni f
JOIN artisti a ON f.codArtista = a.codArtista
JOIN squadre s ON f.codSquadra = s.codSquadra
GROUP BY
    f.nomeSerata, f.codSquadra, s.nome, f.dataModifica;

/*************************************************************************************************************************************************************************/ 
--3. Interrogazioni
/*************************************************************************************************************************************************************************/
/* 3a (interrogazione con operazione insiemistica)															 */
/*
	Scrittura di una query che visualizza gli artisti che si sono esibiti sia nella serata "Finale" e nella serata "Prima serata"
*/
SELECT DISTINCT codArtista
FROM esibizioni
WHERE nomeSerata = 'Finale'
INTERSECT
SELECT DISTINCT codArtista
FROM esibizioni
WHERE nomeSerata = 'Prima Serata';

/*************************************************************************************************************************************************************************/ 
/* 3b (interrogazione di divisione) */
/* Trovare gli artisti che hanno ricevuto almeno un voto in tutte le serate in cui si sono esibiti. */ 
SELECT e.codArtista
FROM esibizioni e
WHERE NOT EXISTS (
    SELECT 1
    FROM esibizioni es
    WHERE es.codArtista = e.codArtista
    AND NOT EXISTS (
        SELECT 1
        FROM voti v
        WHERE v.codArtista = es.codArtista
          AND v.nomeSerata = es.nomeSerata
    )
)
GROUP BY e.codArtista;

/*************************************************************************************************************************************************************************/ 
/* 3c (interrogazione con sottointerrogazione correlata) */
/* Elencare i nomi e cognomi degli artisti che hanno ricevuto almeno un voto in una serata in cui la loro squadra non li aveva schierati. */ 
SELECT DISTINCT a.nome, a.cognome, v.nomeSerata
FROM voti v
JOIN artisti a ON v.codArtista = a.codArtista
WHERE NOT EXISTS (
    SELECT 1
    FROM formazioni f
    WHERE f.codArtista = v.codArtista
      AND f.nomeSerata = v.nomeSerata
);
/*************************************************************************************************************************************************************************/ 
--4. Funzioni
/*************************************************************************************************************************************************************************/ 
/* 4a: operazione di inserimento non banale, effettuando tutti gli opportuni controlli e calcoli di dati derivati. */
/* Funzione utile all'inserimento di un voto in tabella, assicurandosi che:
- Il brano e l'artista esistano e siano correttamente associati.
- La serata esista.
- Il timestamp del voto sia coerente (non futuro).
- Si assegni automaticamente un codice voto progressivo (MAX+1).
- Se uno di questi controlli fallisce, si solleva un errore.*/ 

CREATE OR REPLACE FUNCTION inserisci_voto(
    p_codBrano INTEGER,
    p_codArtista INTEGER,
    p_nomeSerata VARCHAR,
    p_tipo tipo_voto,
    p_dataOra TIMESTAMP
) RETURNS VOID AS $$
DECLARE
    nuovo_codVoto INTEGER;
    artista_brano_ok BOOLEAN;
BEGIN
    -- Controllo che artista e brano siano collegati correttamente
    SELECT EXISTS (
        SELECT 1
        FROM brani
        WHERE codBrano = p_codBrano AND codArtista = p_codArtista
    ) INTO artista_brano_ok;

    IF NOT artista_brano_ok THEN
        RAISE EXCEPTION 'Errore: il brano % non è associato all’artista %', p_codBrano, p_codArtista;
    END IF;

    -- Controllo che la serata esista
    IF NOT EXISTS (
        SELECT 1 FROM serate WHERE nome = p_nomeSerata
    ) THEN
        RAISE EXCEPTION 'Errore: la serata "%" non esiste', p_nomeSerata;
    END IF;

    -- Controllo che il timestamp non sia nel futuro
    IF p_dataOra > NOW() THEN
        RAISE EXCEPTION 'Errore: la data/ora del voto è nel futuro (% > %)', p_dataOra, NOW();
    END IF;

    -- Calcolo nuovo codVoto
    SELECT COALESCE(MAX(codVoto), 0) + 1 INTO nuovo_codVoto FROM voti;

    -- Inserimento
    INSERT INTO voti (codVoto, codBrano, codArtista, nomeSerata, tipo, dataOra)
    VALUES (nuovo_codVoto, p_codBrano, p_codArtista, p_nomeSerata, p_tipo, p_dataOra);
END;
$$ LANGUAGE plpgsql;

/*************************************************************************************************************************************************************************/ -- NON VA BENE
/* 4b: calcolo di un'informazione derivata rilevante e non banale, che richieda l'accesso a diverse tabelle e un'aggregazione */
/* Calcolo del punteggio totale ottenuto da ogni squadra in una specifica serata */

CREATE OR REPLACE FUNCTION fantasanremo.punteggio_squadre_per_serata(p_nomeSerata VARCHAR)
RETURNS TABLE (
    codSquadra INTEGER,
    nomeSquadra VARCHAR,
    punteggioTotale NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        sq.codSquadra,
        sq.nome,
        SUM(ba.valoreEffettivo) AS punteggioTotale
    FROM bonus_assegnati ba
    JOIN squadre sq ON sq.codSquadra = ba.codSquadra
    WHERE ba.nomeSerata = p_nomeSerata
    GROUP BY sq.codSquadra, sq.nome
    ORDER BY punteggioTotale DESC;
END;
$$ LANGUAGE plpgsql;

/*************************************************************************************************************************************************************************/ 
--5. Trigger
/*************************************************************************************************************************************************************************/ 
/* 5a: trigger per la verifica di un vincolo che non sia implementabile come vincolo CHECK */
/* Il trigger trg_check_formazione si attiva prima dell'inserimento di una nuova riga nella tabella formazioni e ha lo scopo di verificare il rispetto di alcune regole di composizione delle squadre per ciascuna serata del Festival.
In particolare, per ogni combinazione di squadra (codSquadra) e serata (nomeSerata), il trigger controlla che:
	- Non siano presenti più di 7 artisti in totale nella formazione della squadra per quella serata. Se si tenta di inserire un artista in una squadra che ha già raggiunto questo limite, l'inserimento viene bloccato.

    - Non venga superato il numero massimo consentito per ciascun ruolo, ovvero:

        - Al massimo 1 CAPITANO per squadra e serata.

		- Al massimo 2 RISERVE per squadra e serata.

		- Al massimo 4 TITOLARI per squadra e serata.
Se si tenta di inserire un artista con un ruolo che supererebbe uno di questi limiti, l’inserimento viene annullato e viene mostrato un messaggio di errore esplicativo. */

CREATE OR REPLACE FUNCTION check_formazione_regole()
RETURNS TRIGGER AS $$
DECLARE
    num_artisti INTEGER := 0;
    num_capitani INTEGER := 0;
    num_riserve INTEGER := 0;
    num_titolari INTEGER := 0;
BEGIN
    -- Conta il numero totale di artisti già presenti per squadra e serata
    SELECT COUNT(*) INTO num_artisti
    FROM formazioni
    WHERE codSquadra = NEW.codSquadra
      AND nomeSerata = NEW.nomeSerata;

    IF num_artisti >= 7 THEN
        RAISE EXCEPTION 'Una squadra non può avere più di 7 artisti in formazione per la serata %', NEW.nomeSerata;
    END IF;

    -- Conta i ruoli specifici esistenti per la squadra e la serata
    SELECT COUNT(*) INTO num_capitani
    FROM formazioni
    WHERE codSquadra = NEW.codSquadra
      AND nomeSerata = NEW.nomeSerata
      AND ruolo = 'CAPITANO';

    SELECT COUNT(*) INTO num_riserve
    FROM formazioni
    WHERE codSquadra = NEW.codSquadra
      AND nomeSerata = NEW.nomeSerata
      AND ruolo = 'RISERVA';

    SELECT COUNT(*) INTO num_titolari
    FROM formazioni
    WHERE codSquadra = NEW.codSquadra
      AND nomeSerata = NEW.nomeSerata
      AND ruolo = 'TITOLARE';

    -- Verifica i limiti per ruolo
    IF NEW.ruolo = 'CAPITANO' AND num_capitani >= 1 THEN
        RAISE EXCEPTION 'È già presente un CAPITANO per questa squadra nella serata %', NEW.nomeSerata;
    ELSIF NEW.ruolo = 'RISERVA' AND num_riserve >= 2 THEN
        RAISE EXCEPTION 'Non si possono avere più di 2 RISERVE per questa squadra nella serata %', NEW.nomeSerata;
    ELSIF NEW.ruolo = 'TITOLARE' AND num_titolari >= 4 THEN
        RAISE EXCEPTION 'Non si possono avere più di 4 TITOLARI per questa squadra nella serata %', NEW.nomeSerata;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_formazione
BEFORE INSERT ON formazioni
FOR EACH ROW
EXECUTE FUNCTION check_formazione_regole();


/*************************************************************************************************************************************************************************/
/* 5b: trigger per il mantenimento di informazione derivata o per l'implementazione di una regola di dominio*/                                                                          
/* Questo trigger si attiva prima di ogni inserimento nella tabella partecipazione_leghe. Se il campo statoApprovazione non viene valorizzato esplicitamente, il sistema lo imposta automaticamente in base al tipo di lega:
	- Se la lega è di tipo PUBBLICA, la partecipazione è approvata automaticamente (APPROVATA)
	- Se la lega è di tipo PRIVATA o SEGRETA, la partecipazione entra in fase di approvazione (IN_APPROVAZIONE)*/ 

CREATE OR REPLACE FUNCTION imposta_stato_approvazione()
RETURNS TRIGGER AS $$
DECLARE
    tipoLega tipo_lega;
BEGIN
    -- Prende il tipo della lega a cui si sta iscrivendo
    SELECT tipo INTO tipoLega
    FROM leghe
    WHERE codLega = NEW.codLega;

    -- Se lo stato approvazione non è stato fornito, lo assegna in automatico
    IF NEW.statoApprovazione IS NULL THEN
        IF tipoLega = 'PUBBLICA' THEN
            NEW.statoApprovazione := 'APPROVATA';
        ELSE
            NEW.statoApprovazione := 'IN_APPROVAZIONE';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_imposta_stato_approvazione
BEFORE INSERT ON partecipazione_leghe
FOR EACH ROW
EXECUTE FUNCTION imposta_stato_approvazione();