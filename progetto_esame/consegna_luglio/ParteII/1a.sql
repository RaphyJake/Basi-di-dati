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