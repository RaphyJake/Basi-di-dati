-- CREATE SCHEMA
CREATE SCHEMA IF NOT EXISTS fantasanremo;
SET search_path TO fantasanremo;

-- ENUM TYPES
CREATE TYPE tipo_voto AS ENUM ('TELEVOTO', 'GIURIA_STAMPA', 'GIURIA_RADIO');
CREATE TYPE tipo_lega AS ENUM ('PUBBLICA', 'PRIVATA', 'SEGRETA');
CREATE TYPE tipo_bonusmalus AS ENUM ('EXTRA', 'STANDARD');
CREATE TYPE tipo_approvazione AS ENUM ('IN_APPROVAZIONE', 'RIFIUTATA', 'APPROVATA');
CREATE TYPE ruolo_compone AS ENUM ('CAPITANO', 'TITOLARE', 'RISERVA');
CREATE TYPE tipo_artista AS ENUM ('CANTANTE');
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
    CONSTRAINT pk_artisti PRIMARY KEY (codArtista)
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
  ('d.ferrari7@email.it', 'Davide', 'Ferrari'),
  ('e.gallo8@email.it', 'Elena', 'Gallo'),
  ('m.greco9@email.it', 'Matteo', 'Greco'),
  ('c.milani10@email.it', 'Chiara', 'Milani'),
  ('v.riva11@email.it', 'Valerio', 'Riva'),
  ('i.gatti12@email.it', 'Irene', 'Gatti'),
  ('a.fontana13@email.it', 'Alberto', 'Fontana'),
  ('s.lombardi14@email.it', 'Simone', 'Lombardi'),
  ('l.marino15@email.it', 'Laura', 'Marino'),
  ('n.pellegrini16@email.it', 'Nicola', 'Pellegrini'),
  ('g.sartori17@email.it', 'Giorgia', 'Sartori'),
  ('t.damico18@email.it', 'Tommaso', 'DAmico'),
  ('m.moretti19@email.it', 'Martina', 'Moretti'),
  ('p.romano20@email.it', 'Paolo', 'Romano'),
  ('r.bruno21@email.it', 'Roberta', 'Bruno'),
  ('d.rinaldi22@email.it', 'Dario', 'Rinaldi'),
  ('a.mazzini23@email.it', 'Annalisa', 'Mazzini'),
  ('g.leone24@email.it', 'Gianluca', 'Leone'),
  ('c.costa25@email.it', 'Cristina', 'Costa'),
  ('s.farina26@email.it', 'Stefano', 'Farina'),
  ('m.deangelis27@email.it', 'Marta', 'De Angelis'),
  ('n.gentile28@email.it', 'Noemi', 'Gentile'),
  ('f.mazza29@email.it', 'Fabio', 'Mazza'),
  ('v.romagnoli30@email.it', 'Valentina', 'Romagnoli'),
  ('a.bianco31@email.it', 'Andrea', 'Bianco'),
  ('s.pagliari32@email.it', 'Silvia', 'Pagliari'),
  ('l.colombo33@email.it', 'Lorenzo', 'Colombo'),
  ('m.battaglia34@email.it', 'Michela', 'Battaglia'),
  ('g.napoli35@email.it', 'Gianni', 'Napoli'),
  ('f.basile36@email.it', 'Federica', 'Basile'),
  ('c.serra37@email.it', 'Claudio', 'Serra'),
  ('s.monti38@email.it', 'Sabrina', 'Monti'),
  ('d.caputo39@email.it', 'Diego', 'Caputo'),
  ('r.pace40@email.it', 'Riccardo', 'Pace'),
  ('m.donati41@email.it', 'Monica', 'Donati'),
  ('a.galli42@email.it', 'Antonio', 'Galli'),
  ('c.rizzi43@email.it', 'Caterina', 'Rizzi'),
  ('l.fabbri44@email.it', 'Leonardo', 'Fabbri'),
  ('e.bono45@email.it', 'Emanuela', 'Bono'),
  ('m.fabbro46@email.it', 'Maurizio', 'Fabbro'),
  ('g.mazzei47@email.it', 'Gaia', 'Mazzei'),
  ('s.neri48@email.it', 'Samuel', 'Neri'),
  ('v.giordano49@email.it', 'Vanessa', 'Giordano'),
  ('i.sanna50@email.it', 'Isabella', 'Sanna');



INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (9, NULL, 'Achille', 'Lauro', DATE '1990-11-07', 'Verona', 'CANTANTE', 'Cantautrice e producer.', 'Pop', '2016,2017,2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (85, NULL, 'Alberto', 'Martini', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (121, NULL, 'Alberto', 'Martini', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (59, NULL, 'Alessandro', 'Conti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (98, NULL, 'Alessia', 'Romano', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (33, NULL, 'Alex', 'Wyse', NULL, NULL, 'CANTANTE', NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (110, NULL, 'Alice', 'Lombardi', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (72, NULL, 'Alice', 'Sala', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (38, NULL, 'Andrea', 'Benassai', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (63, NULL, 'Andrea', 'Moretti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (92, NULL, 'Anna', 'Ferri', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (128, NULL, 'Anna', 'Ferri', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (20, NULL, 'Bresh', NULL, NULL, NULL, 'CANTANTE', 'Band rock italiano.', 'Pop Rock', '2011,2018,2023', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (21, NULL, 'Brunori', 'Sas', DATE '1977-09-28', 'Cosenza', 'CANTANTE', 'Cantautore e polistrumentista.', 'Pop', '2011,2012,2019', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (51, NULL, 'Carmelo', 'Patti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (104, NULL, 'Chiara', 'Conti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (66, NULL, 'Chiara', 'Leone', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (86, NULL, 'Chiara', 'Sanna', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (122, NULL, 'Chiara', 'Sanna', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (22, NULL, 'Clara', NULL, DATE '1999-10-25', 'Varese', 'CANTANTE', 'Cantautrice pop urbana, vincitrice Sanremo Giovani 2023.', 'Pop', '2023', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (6, 'Coma_Cose', NULL, NULL, NULL, NULL, 'CANTANTE', 'Duo indie pop milanese.', 'Indie Pop', '2022,2023', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (39, NULL, 'Daniel', 'Bestonzo', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (99, NULL, 'Daniele', 'Farina', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (65, NULL, 'Davide', 'Rinaldi', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (52, NULL, 'Davide', 'Rossi', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (41, NULL, 'Diego', 'Calvetti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (108, NULL, 'Elena', 'Moretti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (76, NULL, 'Elena', 'Parisi', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (62, NULL, 'Elisa', 'Greco', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (96, NULL, 'Elisa', 'Greco', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (19, NULL, 'Elodie', NULL, DATE '1990-03-05', 'Roma', 'CANTANTE', 'Pop‑singer, runner‑up Amici 2016 ora pop star.', 'Pop', '2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (87, NULL, 'Emanuele', 'Villa', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (123, NULL, 'Emanuele', 'Villa', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (47, NULL, 'Enrico', 'Melozzi', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (42, NULL, 'Enzo', 'Campagnoli', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (81, NULL, 'Fabio', 'Amato', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (37, NULL, 'Fabio', 'Barnaba', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (46, NULL, 'Fabio', 'Gurian', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (105, NULL, 'Fabio', 'Rinaldi', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (113, NULL, 'Federico', 'Donati', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (71, NULL, 'Federico', 'Marchetti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (23, NULL, 'Fedez', NULL, DATE '1989-10-15', 'Milano', 'CANTANTE', 'Cantautore e rapper milanese.', 'Pop Rap', '2022,2023,2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (64, NULL, 'Francesca', 'Costa', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (90, NULL, 'Francesca', 'Guerra', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (126, NULL, 'Francesca', 'Guerra', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (24, NULL, 'Francesca', 'Michielin', DATE '1995-02-25', 'Bassano del Grappa', 'CANTANTE', 'Cantautrice e polistrumentista, X Factor, Sanremo.', 'Pop', '2014,2022', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (97, NULL, 'Francesco', 'Barbieri', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (2, NULL, 'Francesco', 'Gabbani', DATE '1982-09-09', 'Carrara', 'CANTANTE', 'Voce emergente.', 'Pop', '2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (3, NULL, 'Gaia', NULL, DATE '1997-09-29', 'Guastalla', 'CANTANTE', 'Giovane trapper.', 'Trap', '2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (26, NULL, 'Ghali', 'Amdouni', DATE '1993-05-21', 'Milano', 'CANTANTE', 'Rapper e produttore', 'Pop', '2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (101, NULL, 'Gianluca', 'Costa', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (10, NULL, 'Giorgia', NULL, DATE '1971-01-26', 'Roma', 'CANTANTE', 'Vincitore di Sanremo 2017.', 'Pop', '2016,2017,2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (117, NULL, 'Giorgio', 'Gatti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (79, NULL, 'Giorgio', 'Pellegrini', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (50, NULL, 'Giovanni', 'Pallotti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (60, NULL, 'Giulia', 'Ferraro', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (94, NULL, 'Giulia', 'Fiori', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (130, NULL, 'Giulia', 'Fiori', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (48, NULL, 'Giulio', 'Nenna', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (80, NULL, 'Ilaria', 'De Luca', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (5, NULL, 'Irama', NULL, DATE '1995-12-20', 'Carrara', 'CANTANTE', 'Esordiente indie pop.', 'Pop', '2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (27, NULL, 'Joan', 'Thiele', DATE '1991-09-21', 'Desenzano del Garda', 'CANTANTE', 'Cantautrice jazz‑pop in gara al Festival 2025.', 'Jazz Pop', '2022,2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (114, NULL, 'Laura', 'Pellegrini', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (78, NULL, 'Laura', 'Riva', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (119, NULL, 'Lorenzo', 'Amato', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (83, NULL, 'Lorenzo', 'Bellini', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (57, NULL, 'Luca', 'Bianchi', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (45, NULL, 'Luca', 'Faraone', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (103, NULL, 'Luca', 'Ferraro', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (28, NULL, 'Lucio', 'Corsi', NULL, NULL, 'CANTANTE', 'Duo esordiente pop.', 'Pop', '2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (44, NULL, 'Lucio', 'Fabbri', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (8, NULL, 'Marcella', 'Bella', DATE '1952-06-18', 'Catania', 'CANTANTE', 'Rapper e personaggio mediatico.', 'Pop Rap', '2020,2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (77, NULL, 'Marco', 'Barone', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (111, NULL, 'Marco', 'Sala', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (100, NULL, 'Maria', 'Leone', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (31, NULL, 'Maria', 'Tomba', DATE '2010-08-10', 'Milano', 'CANTANTE', 'Band pop rock.', 'Pop Rock', '2015,2020,2023', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (118, NULL, 'Marta', 'De Luca', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (82, NULL, 'Marta', 'Fabbri', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (74, NULL, 'Martina', 'Donati', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (106, NULL, 'Martina', 'Parisi', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (58, NULL, 'Martina', 'Rossi', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (29, NULL, 'Massimo', 'Ranieri', DATE '1951-03-05', 'Napoli', 'CANTANTE', 'Cantante e attore storico.', 'Trap', '2023', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (93, NULL, 'Matteo', 'Corsi', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (129, NULL, 'Matteo', 'Corsi', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (61, NULL, 'Matteo', 'Romano', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (55, NULL, 'Michele', 'Michelangelo Zocca', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (49, NULL, 'Mirko', 'Onofrio', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (30, 'Modà', NULL, NULL, NULL, NULL, 'CANTANTE', 'Cantautore e drammaturgo.', 'Cantautorato', '2007,2014,2023', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (89, NULL, 'Nicola', 'De Santis', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (125, NULL, 'Nicola', 'De Santis', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (115, NULL, 'Nicola', 'Fabbri', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (73, NULL, 'Nicola', 'Serra', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (40, NULL, 'Nicole', 'Brancale', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (4, NULL, 'Noemi', NULL, DATE '1982-01-25', 'Roma', 'CANTANTE', 'Cantautore lucano.', 'Indie', '2018,2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (13, NULL, 'Olly', NULL, DATE '2001-05-05', 'Genova', 'CANTANTE', 'Singer‑songwriter, vincitore Sanremo 2025.', 'Pop', NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (95, NULL, 'Paolo', 'Benedetti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (131, NULL, 'Paolo', 'Benedetti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (35, NULL, 'Pinuccio', 'Pirazzoli', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (107, NULL, 'Riccardo', 'Bruno', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (69, NULL, 'Riccardo', 'Lombardi', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (54, NULL, 'Riccardo', 'Zangirolami', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (1, NULL, 'Rkomi', NULL, DATE '1994-04-19', 'Milano', 'CANTANTE', 'Cantautore e performer provocatorio.', 'Pop', '2019,2022', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (91, NULL, 'Roberto', 'Mancini', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (127, NULL, 'Roberto', 'Mancini', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (25, NULL, 'Rocco', 'Hunt', DATE '1994-11-21', 'Salerno', 'CANTANTE', 'Rapper pop rap, vincitore Sanremo Nuove Proposte 2014.', 'Pop Rap', '2023', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (12, NULL, 'Rose', 'Villain', DATE '1989-07-20', 'Milano', 'CANTANTE', 'Pioniere della trap italiana.', 'Trap', '2020,2023', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (112, NULL, 'Sara', 'Serra', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (70, NULL, 'Sara', 'Vitale', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (14, NULL, 'Sarah', 'Toscano', DATE '2006-09-01', 'Vigevano', 'CANTANTE', 'Cantautrice e vincitrice Amici 23.', 'Pop', '2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (15, NULL, 'Serena', 'Brancale', DATE '1989-04-05', 'Bari', 'CANTANTE', 'Cantautrice jazz‑soul italiana.', 'Pop', '2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (32, 'Settembre', NULL, NULL, NULL, NULL, 'CANTANTE', 'Trap emergente.', 'Trap', '2023', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (16, 'Shablo feat Guè, Joshua e Tormento', NULL, NULL, NULL, 'Firenze', 'CANTANTE', 'Cantautore toscano emergente.', 'Pop', '2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (84, NULL, 'Silvia', 'Benedetti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (120, NULL, 'Silvia', 'Benedetti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (102, NULL, 'Simona', 'Rossi', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (7, NULL, 'Simone', 'Cristicchi', DATE '1977-05-02', 'Roma', 'CANTANTE', 'Artista e icona di stile.', 'Pop', '2017,2020,2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (67, NULL, 'Simone', 'Galli', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (36, NULL, 'Stefano', 'Amato', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (109, NULL, 'Stefano', 'Leone', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (75, NULL, 'Stefano', 'Villa', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (17, 'The Kolors', NULL, NULL, NULL, 'Catania', 'CANTANTE', 'Icona della musica italiana.', 'Pop', '1985,1990,1995', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (18, NULL, 'Tony', 'Effe', DATE '1991-05-17', 'Roma', 'CANTANTE', 'Trap rapper della Dark Polo Gang.', 'Pop', '2024', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (34, 'Vale LP e Lil Jolie', NULL, NULL, DATE '1985-09-01', 'Cagliari', 'CANTANTE', 'Cantautore e rapper sarcastico.', 'Indie Rap', '2023', NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (68, NULL, 'Valentina', 'Bruno', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (116, NULL, 'Valentina', 'Villa', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (88, NULL, 'Valeria', 'Gatti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (124, NULL, 'Valeria', 'Gatti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (43, NULL, 'Valeriano', 'Chiaravalle', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (53, NULL, 'Valter', 'Sivilotti', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (11, NULL, 'Willie', 'Peyote', DATE '1985-08-28', 'Torino', 'CANTANTE', 'Rapper e cantautore piemontese.', 'Pop', '2024', NULL);

  
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
(10, 'La cura per me', 10, 'Pop', INTERVAL '220 seconds'),
(11, 'Grazie ma no grazie', 11, 'Indie Rap', INTERVAL '180 seconds'),
(12, 'Fuorilegge', 12, 'Pop Rap', INTERVAL '210 seconds'),
(13, 'Balorda nostalgia', 13, 'Pop', INTERVAL '205 seconds'),
(14, 'Amarcord', 14, 'Cantautorato', INTERVAL '230 seconds'),
(15, 'Anema e core', 15, 'Jazz Pop', INTERVAL '225 seconds'),
(16, 'La mia parola', 16, 'Trap', INTERVAL '200 seconds'),
(17, 'Tu con chi fai l''amore', 17, 'Pop', INTERVAL '210 seconds'),
(18, 'Damme ''na mano', 18, 'Trap', INTERVAL '210 seconds'),
(19, 'Dimenticarsi alle 7', 19, 'Pop', INTERVAL '205 seconds'),
(20, 'La tana del granchio', 20, 'Rap', INTERVAL '195 seconds'),
(21, 'L albero delle noci', 21, 'Indie', INTERVAL '200 seconds'),
(22, 'Febbre', 22, 'Pop', INTERVAL '190 seconds'),
(23, 'Battito', 23, 'Pop Rap', INTERVAL '205 seconds'),
(24, 'Fango in Paradiso', 24, 'Pop', INTERVAL '215 seconds'),
(25, 'Mille vote ancora', 25, 'Pop Rap', INTERVAL '210 seconds'),
(26, 'Casa mia', 26, 'Pop Rap', INTERVAL '205 seconds'),
(27, 'Eco', 27, 'Pop', INTERVAL '185 seconds'),
(28, 'Volevo essere un duro', 28, 'Indie', INTERVAL '220 seconds'),
(29, 'Tra le mani un cuore', 29, 'Pop', INTERVAL '200 seconds'),
(30, 'Non ti dimentico', 30, 'Pop', INTERVAL '190 seconds'),
(31, 'Goodbye (voglio good vibes)', 31, 'Pop', INTERVAL '180 seconds'),
(32, 'Vertebre', 32, 'Indie Pop', INTERVAL '195 seconds'),
(33, 'Rockstar', 33, 'Pop Rock', INTERVAL '220 seconds'),
(34, 'Dimmi tu quando sei pronto per fare l''amore', 34, 'Pop', INTERVAL '190 seconds'),
(35, 'Fiori rosa fiori di pesco', 12, 'Pop', INTERVAL '210 seconds'),
(36, 'Angelo', 30, 'Pop Rock', INTERVAL '215 seconds'),
(37, 'The Sound of Silence', 22, 'Pop', INTERVAL '230 seconds'),
(38, 'Tutto il resto è noia', 4, 'Pop', INTERVAL '210 seconds'),
(39, 'La nuova stella di Broadway', 24, 'Pop Rap', INTERVAL '210 seconds'),
(40, 'Nel blu, dipinto di blu', 28, 'Indie Pop', INTERVAL '200 seconds'),
(41, 'If I Ain''t Got You', 15, 'Jazz Pop', INTERVAL '210 seconds'),
(42, 'Say Something', 5, 'Pop', INTERVAL '215 seconds'),
(43, 'La voglia, la pazzia', 3, 'Pop', INTERVAL '200 seconds'),
(44, 'Rossetto e caffè', 17, 'Pop Rock', INTERVAL '220 seconds'),
(45, 'L''emozione non ha voce', 8, 'Pop', INTERVAL '210 seconds'),
(46, 'Yes I Know My Way', 25, 'Pop Rap', INTERVAL '210 seconds'),
(47, 'Io sono Francesco', 2, 'Pop', INTERVAL '210 seconds'),
(48, 'Skyfall', 10, 'Pop', INTERVAL '220 seconds'),
(49, 'La cura', 7, 'Cantautorato', INTERVAL '215 seconds'),
(50, 'Overdrive', 14, 'Pop', INTERVAL '200 seconds'),
(51, 'L''estate sta finendo', 6, 'Indie Pop', INTERVAL '195 seconds'),
(52, 'Che cosa c''è', 27, 'Pop', INTERVAL '200 seconds'),
(53, 'Il pescatore', 13, 'Pop', INTERVAL '210 seconds'),
(54, 'A mano a mano / Folle città', 19, 'Pop', INTERVAL '215 seconds'),
(55, 'Quando', 29, 'Pop', INTERVAL '210 seconds'),
(56, 'Un tempo piccolo', 11, 'Indie Rap', INTERVAL '180 seconds'),
(57, 'L''anno che verrà', 21, 'Cantautorato', INTERVAL '215 seconds'),
(58, 'Bella stronza', 23, 'Pop Rap', INTERVAL '205 seconds'),
(59, 'Creuza de mä', 20, 'Trap', INTERVAL '210 seconds'),
(60, 'Aspettando il sole / Amor de mi vida', 16, 'Trap', INTERVAL '210 seconds');

INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (3, 3, 'Prima Serata', TIME '21:00:00', 1);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (2, 2, 'Prima Serata', TIME '21:05:00', 2);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (1, 1, 'Prima Serata', TIME '21:10:00', 3);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (4, 4, 'Prima Serata', TIME '21:15:00', 4);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (5, 5, 'Prima Serata', TIME '21:20:00', 5);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (6, 6, 'Prima Serata', TIME '21:25:00', 6);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (7, 7, 'Prima Serata', TIME '21:30:00', 7);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (8, 8, 'Prima Serata', TIME '21:35:00', 8);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (9, 9, 'Prima Serata', TIME '21:40:00', 9);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (10, 10, 'Prima Serata', TIME '21:45:00', 10);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (11, 11, 'Prima Serata', TIME '21:50:00', 11);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (12, 12, 'Prima Serata', TIME '21:55:00', 12);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (13, 13, 'Prima Serata', TIME '22:00:00', 13);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (19, 19, 'Prima Serata', TIME '22:05:00', 14);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (16, 16, 'Prima Serata', TIME '22:10:00', 15);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (29, 29, 'Prima Serata', TIME '22:15:00', 16);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (18, 18, 'Prima Serata', TIME '22:20:00', 17);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (15, 15, 'Prima Serata', TIME '22:25:00', 18);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (21, 21, 'Prima Serata', TIME '22:30:00', 19);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (30, 30, 'Prima Serata', TIME '22:35:00', 20);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (22, 22, 'Prima Serata', TIME '22:40:00', 21);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (28, 28, 'Prima Serata', TIME '22:45:00', 22);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (23, 23, 'Prima Serata', TIME '22:50:00', 23);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (20, 20, 'Prima Serata', TIME '22:55:00', 24);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (14, 14, 'Prima Serata', TIME '23:00:00', 25);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (27, 27, 'Prima Serata', TIME '23:05:00', 26);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (25, 25, 'Prima Serata', TIME '23:10:00', 27);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (24, 24, 'Prima Serata', TIME '23:15:00', 28);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (17, 17, 'Prima Serata', TIME '23:20:00', 29);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (33, 33, 'Seconda Serata', TIME '21:00:00', 1);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (34, 34, 'Seconda Serata', TIME '21:05:00', 2);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (31, 31, 'Seconda Serata', TIME '21:10:00', 3);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (32, 32, 'Seconda Serata', TIME '21:15:00', 4);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (25, 25, 'Seconda Serata', TIME '21:20:00', 5);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (19, 19, 'Seconda Serata', TIME '21:25:00', 6);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (28, 28, 'Seconda Serata', TIME '21:30:00', 7);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (17, 17, 'Seconda Serata', TIME '21:35:00', 8);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (15, 15, 'Seconda Serata', TIME '21:40:00', 9);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (23, 23, 'Seconda Serata', TIME '21:45:00', 10);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (24, 24, 'Seconda Serata', TIME '21:50:00', 11);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (7, 7, 'Seconda Serata', TIME '21:55:00', 12);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (8, 8, 'Seconda Serata', TIME '22:00:00', 13);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (20, 20, 'Seconda Serata', TIME '22:05:00', 14);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (9, 9, 'Seconda Serata', TIME '22:10:00', 15);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (10, 10, 'Seconda Serata', TIME '22:15:00', 16);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (1, 1, 'Seconda Serata', TIME '22:20:00', 17);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (12, 12, 'Seconda Serata', TIME '22:25:00', 18);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (11, 11, 'Seconda Serata', TIME '22:30:00', 19);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (32, 32, 'Terza Serata', TIME '21:00:00', 1);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (33, 33, 'Terza Serata', TIME '21:05:00', 2);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (22, 22, 'Terza Serata', TIME '21:10:00', 3);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (21, 21, 'Terza Serata', TIME '21:15:00', 4);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (14, 14, 'Terza Serata', TIME '21:20:00', 5);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (29, 29, 'Terza Serata', TIME '21:25:00', 6);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (27, 27, 'Terza Serata', TIME '21:30:00', 7);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (16, 16, 'Terza Serata', TIME '21:35:00', 8);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (4, 4, 'Terza Serata', TIME '21:40:00', 9);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (13, 13, 'Terza Serata', TIME '21:45:00', 10);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (6, 6, 'Terza Serata', TIME '21:50:00', 11);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (30, 30, 'Terza Serata', TIME '21:55:00', 12);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (18, 18, 'Terza Serata', TIME '22:00:00', 13);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (5, 5, 'Terza Serata', TIME '22:05:00', 14);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (2, 2, 'Terza Serata', TIME '22:10:00', 15);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (3, 3, 'Terza Serata', TIME '22:15:00', 16);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (35, 12, 'Quarta Serata', TIME '21:00:00', 1);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (36, 30, 'Quarta Serata', TIME '21:05:00', 2);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (37, 22, 'Quarta Serata', TIME '21:10:00', 3);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (38, 4, 'Quarta Serata', TIME '21:15:00', 4);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (39, 24, 'Quarta Serata', TIME '21:20:00', 5);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (40, 28, 'Quarta Serata', TIME '21:25:00', 6);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (41, 15, 'Quarta Serata', TIME '21:30:00', 7);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (42, 5, 'Quarta Serata', TIME '21:35:00', 8);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (43, 3, 'Quarta Serata', TIME '21:40:00', 9);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (44, 17, 'Quarta Serata', TIME '21:45:00', 10);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (45, 8, 'Quarta Serata', TIME '21:50:00', 11);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (46, 25, 'Quarta Serata', TIME '21:55:00', 12);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (47, 2, 'Quarta Serata', TIME '22:00:00', 13);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (48, 10, 'Quarta Serata', TIME '22:05:00', 14);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (49, 7, 'Quarta Serata', TIME '22:10:00', 15);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (50, 14, 'Quarta Serata', TIME '22:15:00', 16);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (51, 6, 'Quarta Serata', TIME '22:20:00', 17);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (52, 27, 'Quarta Serata', TIME '22:25:00', 18);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (53, 13, 'Quarta Serata', TIME '22:30:00', 19);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (54, 19, 'Quarta Serata', TIME '22:35:00', 20);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (55, 29, 'Quarta Serata', TIME '22:40:00', 21);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (56, 11, 'Quarta Serata', TIME '22:45:00', 22);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (57, 21, 'Quarta Serata', TIME '22:50:00', 23);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (58, 23, 'Quarta Serata', TIME '22:55:00', 24);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (59, 20, 'Quarta Serata', TIME '23:00:00', 25);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (60, 16, 'Quarta Serata', TIME '23:05:00', 26);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (24, 24, 'Finale', TIME '21:00:00', 1);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (11, 11, 'Finale', TIME '21:05:00', 2);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (8, 8, 'Finale', TIME '21:10:00', 3);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (20, 20, 'Finale', TIME '21:15:00', 4);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (30, 30, 'Finale', TIME '21:20:00', 5);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (12, 12, 'Finale', TIME '21:25:00', 6);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (18, 18, 'Finale', TIME '21:30:00', 7);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (22, 22, 'Finale', TIME '21:35:00', 8);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (15, 15, 'Finale', TIME '21:40:00', 9);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (21, 21, 'Finale', TIME '21:45:00', 10);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (2, 2, 'Finale', TIME '21:50:00', 11);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (4, 4, 'Finale', TIME '21:55:00', 12);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (25, 25, 'Finale', TIME '22:00:00', 13);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (17, 17, 'Finale', TIME '22:05:00', 14);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (13, 13, 'Finale', TIME '22:10:00', 15);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (9, 9, 'Finale', TIME '22:15:00', 16);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (6, 6, 'Finale', TIME '22:20:00', 17);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (10, 10, 'Finale', TIME '22:25:00', 18);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (7, 7, 'Finale', TIME '22:30:00', 19);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (19, 19, 'Finale', TIME '22:35:00', 20);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (28, 28, 'Finale', TIME '22:40:00', 21);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (5, 5, 'Finale', TIME '22:45:00', 22);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (23, 23, 'Finale', TIME '22:50:00', 23);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (16, 16, 'Finale', TIME '22:55:00', 24);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (27, 27, 'Finale', TIME '23:00:00', 25);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (29, 29, 'Finale', TIME '23:05:00', 26);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (3, 3, 'Finale', TIME '23:10:00', 27);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (1, 1, 'Finale', TIME '23:15:00', 28);
INSERT INTO esibizioni (codBrano, codArtista, nomeSerata, orario, ordineEsibizione) VALUES (14, 14, 'Finale', TIME '23:20:00', 29);