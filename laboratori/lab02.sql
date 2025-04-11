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
SELECT Matricola FROM Studenti, CorsiDiLaurea where CorsoDiLaurea = CorsiDiLaurea.Id  and Laurea < '01-11-2009' and Denominazione = 'Informatica'

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


---------------DA RIVEDERE
/***** Ho scritto alla proff per chiarimenti *****/
/**** 2. gli studenti di informatica che hanno passato basi di dati 1 ma non interfacce grafiche nel giugno del 2010.  
nella nostra interpretazione, non avere passato IG  include anche non averlo proprio sostenuto (o essersi ritirati) non necessariamente avere una registrazione con voto < 18
****/
set search_path to 'unicorsi';

SELECT s.Matricola FROM Studenti s
JOIN CorsiDiLaurea cdl ON s.CorsoDiLaurea = cdl.id
WHERE cdl.Denominazione = 'Informatica'
AND s.Matricola IN (SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' and e.Data <='2010-06-30' and c.Denominazione = 'Basi Di Dati 1' and e.voto >=18)
AND s.Matricola NOT IN (SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' and e.Data <='2010-06-30' and c.Denominazione = 'Interfacce Grafiche' and e.voto >=18)

/**** 3. gli studenti di informatica che hanno passato sia basi di dati 1 che interfacce grafiche nel giugno del 2010. ****/
set search_path to 'unicorsi';
SELECT s.Matricola FROM Studenti s
JOIN CorsiDiLaurea cdl ON s.CorsoDiLaurea = cdl.id
WHERE cdl.Denominazione = 'Informatica'
AND s.Matricola IN (SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' AND e.Data <='2010-06-30' AND c.Denominazione = 'Basi Di Dati 1' AND e.voto >=18)
AND s.Matricola IN (SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' AND e.Data <='2010-06-30' AND c.Denominazione = 'Interfacce Grafiche' AND e.voto >=18)





/**** Ulteriori attività di laboratorio su SQL - query SPJ e operazioni insiemistiche (se volete esercitarvi ulteriormente su questa parte)****/
/**** INTERROGAZIONI SU SINGOLA RELAZIONE ****/

/**** 1. la matricola dello studente ‘Mario Rossi’, iscritto nell’anno accademico 2009/2010; ****/
set search_path to 'unicorsi';
SELECT matricola from Studenti WHERE Nome ='Mario' AND Cognome = 'Rossi' AND iscrizione = 2009;

/**** 2. l’elenco alfabetico dei comuni, diversi da Genova, in cui risiedono studenti (senza duplicati); ****/
set search_path to 'unicorsi';
SELECT DISTINCT Residenza from Studenti WHERE residenza <> 'Genova' ORDER BY Residenza;

/**** 3. la matricola degli studenti che hanno registrato dei voti dal 2 febbraio del 2009; ****/
set search_path to 'unicorsi';
SELECT DISTINCT e.Studente FROM Esami e WHERE e.Data >= '2009-02-02';

/**** 4. gli identificativi dei professori il cui nome contenga la stringa ‘te’ che abbiano uno stipendio compreso tra i 12500 e i 16000 euro l’anno. ****/
set search_path to 'unicorsi';
SELECT Id FROM Professori WHERE Nome LIKE '%te%' AND Stipendio BETWEEN 12500 and 16000;

---------------------------------------------
-- Interrogazioni su più relazioni.        --
---------------------------------------------

/**** 1. l’elenco dei nominativi dei professori, con, per ognuno, i corsi di cui sono titolari, in ordine decrescente di identificativo di corso; ****/
set search_path to 'unicorsi';
SELECT p.Cognome, p.Nome, c.Denominazione, c.id AS corso
FROM Professori p, Corsi c
WHERE p.Id=c.Professore
ORDER BY c.id DESC;

/**** 2. l’elenco alfabetico dei corsi, con i nominativi dei professori titolari, ordinati per corso di laurea, attivati; ****/
set search_path to 'unicorsi';
SELECT c.Denominazione, c.CorsoDiLaurea, p.Cognome 
FROM Professori p, Corsi c
WHERE p.Id=c.Professore and c.Attivato IS TRUE
ORDER BY c.CorsoDiLaurea, c.Denominazione

/**** 3. l’elenco dei corsi attivi nell’anno accademico corrente presso il corso di laurea di informatica, il cui nome abbia, come terza lettera, la lettera ‘s’ ; ****/
set search_path to 'unicorsi';
SELECT *
FROM Corsi c
INNER JOIN CorsiDiLaurea cdl ON c.CorsoDiLaurea=cdl.id
WHERE c.Attivato IS TRUE
AND cdl.Attivazione=anno in corso
and cdl.Denominazione='Informatica'
and c.Denominazione like '__s%'

/**** 4. la matricola degli studenti di matematica che hanno registrato voti sufficienti per l’esame di ‘Informatica Generale’ svoltosi il 15 febbraio 2012; ****/
set search_path to 'unicorsi';
SELECT e.Studente
FROM Esami e
JOIN Corsi c ON e.Corso=e.Id
JOIN CorsiDiLaurea cdl ON c.CorsoDiLaurea = cdl.id
WHERE e.voto>=18
AND e.data ='2012-02-15'
AND c.Denominazione = 'Informatica Generale'
AND cdl.Denominazione = 'Matematica';


---------------------------------------------
-- Operazioni insiemistiche                --
---------------------------------------------

/**** 1. cognome e nome di studenti e professori. ****/
set search_path to 'unicorsi';
SELECT Nome, Cognome FROM Studenti
UNION
SELECT Nome, Cognome FROM Professori;

/**** 2. i professori  che hanno omonimi tra gli studenti (cioè studenti con lo stesso nome e cognome dei professori). ****/
set search_path to 'unicorsi';
SELECT p.Nome, p.cognome FROM Professori p
INTERSECT
SELECT s.Nome, s.cognome FROM Studenti s;

/**** 3. gli studenti che NON hanno omonimi tra i professori. ****/
set search_path to 'unicorsi';
SELECT s.Nome, s.cognome FROM Studenti s
EXCEPT
SELECT p.Nome, p.cognome FROM Professori p;