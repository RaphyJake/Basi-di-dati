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
/**** 1. la matricola degli studenti laureatisi in informatica prima del novembre 2009; ****/
set search_path to 'unicorsi';
SELECT Matricola FROM Studenti JOIN CorsiDiLaurea ON CorsoDiLaurea = CorsiDiLaurea.Id where Laurea < '01-11-2009' and Denominazione = 'Informatica'

/**** 2. l’elenco in ordine alfabetico dei nominativi degli studenti, con, per ognuno, il cognome del relatore associato; ****/
set search_path to 'unicorsi';
SELECT s.Cognome, s.Nome, p.Cognome as Relatore FROM Studenti s JOIN Professori p ON s.Relatore = p.Id order by s.Cognome, s.Nome

/**** 3. l’elenco, senza duplicati e in ordine alfabetico inverso, degli studenti che hanno presentato il piano di studi per il quinto anno del corso di laurea di informatica nell’a.a. 2011/2012 e sono in tesi (hanno assegnato un relatore). ****/
set search_path to 'unicorsi';
SELECT DISTINCT s.Cognome, s.Nome
FROM Studenti s
JOIN CorsiDiLaurea cdl ON s.CorsoDiLaurea  = cdl.id  
JOIN PianiDiStudio pds ON s.Matricola  = pds.Studente
WHERE 	cdl.Denominazione = 'Informatica'
		AND pds.Anno = 5
		AND AnnoAccademico = '2011'
		AND s.Relatore IS NOT NULL
ORDER BY Cognome DESC, Nome DESC

---------------------------------------------
-- Operazioni insiemistiche                --
---------------------------------------------

/**** 1.cognome, nome e qualifica (’studente’/’professore’) di studenti e professori. --- senza ordinamento mette male confrontarli con i risultati (eseguito check su Excel ****/
set search_path to 'unicorsi';
SELECT Nome, Cognome, 'studente' FROM Studenti
UNION ALL
Select Nome, Cognome, 'professore' FROM Professori;

/***** Ho scritto alla proff per chiarimenti *****/
/**** 2. gli studenti di informatica che hanno passato basi di dati 1 ma non interfacce grafiche nel giugno del 2010.  ****/
set search_path to 'unicorsi';

SELECT s.Matricola FROM Studenti s
JOIN CorsiDiLaurea cdl ON s.CorsoDiLaurea = cdl.id
WHERE cdl.Denominazione = 'Informatica'
AND s.Matricola IN (SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' and e.Data <='2010-06-30' and c.Denominazione = 'Basi Di Dati 1' and e.voto >=18)
AND s.Matricola IN (SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' and e.Data <='2010-06-30' and c.Denominazione = 'Interfacce Grafiche' and e.voto <18)

/**** 3. gli studenti di informatica che hanno passato sia basi di dati 1 che interfacce grafiche nel giugno del 2010. ****/
set search_path to 'unicorsi';
SELECT s.Matricola FROM Studenti s
JOIN CorsiDiLaurea cdl ON s.CorsoDiLaurea = cdl.id
WHERE cdl.Denominazione = 'Informatica'
AND s.Matricola IN (SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' and e.Data <='2010-06-30' and c.Denominazione = 'Basi Di Dati 1' and e.voto >=18)
AND s.Matricola IN (SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' and e.Data <='2010-06-30' and c.Denominazione = 'Interfacce Grafiche' and e.voto >=18)