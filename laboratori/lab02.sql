---------------------------------------------
-- Interrogazioni su singola relazione     --
---------------------------------------------

/**** 1. la matricola e i nominativi degli studenti iscritti prima dell’A.A. 2007/2008 che non sono ancora in tesi (non hanno assegnato nessun relatore); ****/
set search_path to 'unicorsi';
SELECT Matricola, Cognome, Nome FROM Studenti WHERE Iscrizione<2007 and RELATORE IS NULL;

/**** 2. l’elenco dei corsi di laurea, in ordine alfabetico per facoltà e denominazione del corso di laurea, attivati prima dell’A.A. 2006/2007 (escluso) e dopo l’A.A. 2009/2010 (escluso); ****/
set search_path to 'unicorsi';
SELECT Facolta, Denominazione FROM CorsiDiLaurea WHERE substr(attivazione,1,4) <'2006' OR  substr(attivazione,1,4) >'2009' ORDER BY Facolta, Denominazione;

/**** 3. la matricola e i nominativi, in ordine di matricola inverso, degli studenti che risiedono a Genova, La Spezia e Savona o il cui cognome non è ‘Serra’, ‘Melogno’ o ‘Giunchi’ ****/
set search_path to 'unicorsi';
SELECT matricola, cognome, nome FROM Studenti WHERE Residenza IN ('Genova','La Spezia','Savona') OR Cognome NOT IN ('Serra','Melogno','Giunchi') ORDER BY matricola DESC;

---------------------------------------------
-- Interrogazioni su più relazioni         --
---------------------------------------------
