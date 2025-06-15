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
  
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (1, NULL, 'Rkomi', NULL, DATE '1994-04-19', 'Milano', 'CANTANTE', 'Cantautore e performer provocatorio.', 'Pop', '2019,2022', 10);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (2, NULL, 'Francesco', 'Gabbani', DATE '1982-09-09', 'Carrara', 'CANTANTE', 'Voce emergente.', 'Pop', '2024', 15);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (3, NULL, 'Gaia', NULL, DATE '1997-09-29', 'Guastalla', 'CANTANTE', 'Giovane trapper.', 'Trap', '2024', 12);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (4, NULL, 'Noemi', NULL, DATE '1982-01-25', 'Roma', 'CANTANTE', 'Cantautore lucano.', 'Indie', '2018,2024', 14);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (5, NULL, 'Irama', NULL, DATE '1995-12-20', 'Carrara', 'CANTANTE', 'Esordiente indie pop.', 'Pop', '2024', 9);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (6, 'Coma_Cose', NULL, NULL, NULL, NULL, 'CANTANTE', 'Duo indie pop milanese.', 'Indie Pop', '2022,2023', 10);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (7, NULL, 'Simone', 'Cristicchi', DATE '1977-05-02', 'Roma', 'CANTANTE', 'Artista e icona di stile.', 'Pop', '2017,2020,2024', 14);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (8, NULL, 'Marcella', 'Bella', DATE '1952-06-18', 'Catania', 'CANTANTE', 'Rapper e personaggio mediatico.', 'Pop Rap', '2020,2024', 15);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (9, NULL, 'Achille', 'Lauro', DATE '1990-11-07', 'Verona', 'CANTANTE', 'Cantautrice e producer.', 'Pop', '2016,2017,2024', 7);
INSERT INTO artisti (codArtista, nomeGruppo, nome, cognome, dataNascita, luogoNascita, tipo, biografia, genereMusicale, edizioniPassate, costoBaudi) VALUES (10, NULL, 'Giorgia', NULL, DATE '1971-01-26', 'Roma', 'CANTANTE', 'Vincitore di Sanremo 2017.', 'Pop', '2016,2017,2024', 10);
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