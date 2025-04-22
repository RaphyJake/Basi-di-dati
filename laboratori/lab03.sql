-- ####################################################################
--  Gruppo Molinas Alessio, Romano Ettore
-- #####################################################################
set search_path to "unicorsi";

-- OUTER JOIN
/**** 1. l’elenco in ordine alfabetico (per denominazione) dei corsi, con eventuale nominativo del professore titolare; ****/
SELECT c.id, c.denominazione, p.cognome, p.nome
FROM Corsi c
LEFT JOIN Professori p 
ON c.Professore = p.ID 
ORDER BY c.denominazione

/**** 2. l’elenco alfabetico degli studenti iscritti a matematica, con l’eventuale relatore che li segue per la tesi. ****/
SELECT s.cognome, s.nome, p.cognome as relatore
FROM Studenti s
JOIN CorsiDiLaurea cdl ON s.CorsoDiLaurea = cdl.Id
LEFT JOIN Professori p ON s.Relatore=p.Id
WHERE cdl.Denominazione = 'Matematica'
ORDER BY s.cognome, s.nome

--- FUNZIONI DI GRUPPO
/**** 1. la votazione minima, media e massima conseguita nei corsi del corso di laurea in informatica; ****/
SELECT MIN(voto), AVG(voto), MAX(voto)
FROM Esami e
JOIN Corsi c ON e.Corso = c.id
JOIN CorsiDiLaurea cdl ON c.CorsoDiLaurea=cdl.Id
WHERE cdl.Denominazione = 'Informatica'

/**** 2. i nominativi, in ordine alfabetico, dei professori titolari di più di due corsi attivati (attributo Attivato in Corsi), con l’indicazione di quanti corsi tengono; ****/
SELECT p.cognome, p.nome, COUNT(*)
FROM Professori p
JOIN Corsi c ON p.ID = c.professore
WHERE c.Attivato = TRUE
GROUP BY p.cognome, p.nome
HAVING COUNT(*) >2
ORDER BY p.cognome, p.nome

/**** 3. l’elenco, in ordine alfabetico, dei professori con l’indicazione del numero di studenti di cui sono relatori [(*) indicando 0 se non seguono alcuno studente per la tesi]; ****/
/**** ATTENZIONE: bisogna eseguire il count sulla matricola: in caso di NULL viene contanto 0 
 se vuoi che il conteggio restituisca 0 per i professori senza studenti, devi usare COUNT(s.matricola)***/
SELECT p.cognome, p.nome, COUNT(s.matricola)
FROM Professori p
LEFT JOIN Studenti s ON s.Relatore = p.Id
GROUP BY p.cognome, p.nome
ORDER BY p.cognome, p.nome

/**** 4. (*) la matricola degli studenti iscritti al corso di studi in informatica che hanno registrato (almeno) due voti per corsi diversi nello stesso mese, con la media dei voti riportati [suggerimento: utilizzare la funzione extract per il tipo di dato DATE - ad esempio, per estrarre l'anno  EXTRACT (YEAR FROM Data). verificare sul manuale PostgreSQL] ****/

----- DA FARE ----

--- SOTTOINTERROGAZIONI SEMPLICI

/**** 1. (* e’ più difficile della 2, iniziare dalla 2) l’elenco dei corsi di laurea che nell’A.A. 2010/2011 hanno meno iscritti di quelli che si sono avuti ad informatica nello stesso A.A. (per filtrare sull'anno accademico di iscrizione utilizzare l'attributo Iscrizione della relazione Studenti);
[Suggerimento: ritrovare tramite un'interrogazione il numero di studenti iscritti a informatica nell'A.A.2010/2011 e utilizzare tale (sotto)interrogazione nella formula della clausola WHERE dell'interrogazione principale] ****/

----- DA FARE ----

/**** 2. la matricola dello studente di informatica che ha conseguito la votazione più alta; ****/
SELECT s.Matricola
FROM Esami e
JOIN studenti s ON e.Studente=s.matricola
JOIN CorsiDiLaurea cdl ON s.CorsoDiLaurea=cdl.Id 
WHERE cdl.Denominazione = 'Informatica' and e.voto = (  SELECT MAX(e.Voto)
														FROM Esami e
														JOIN studenti s ON e.Studente=s.matricola
														JOIN CorsiDiLaurea cdl ON s.CorsoDiLaurea=cdl.Id 
														WHERE cdl.Denominazione = 'Informatica'
														)

/**** Ulteriori attività di laboratorio su SQL - outer join, group by e prime sottointerrogazioni (se volete esercitarvi ulteriormente su questa parte) ****/
/**** OUTER JOIN ****/
/**** l’elenco dei cognomi, in ordine di codice identificativo, dei professori con l’indicazione del cognome, del nome e della matricola degli studenti di cui sono relatori, laddove seguano degli studenti per la tesi ****/
set search_path to 'unicorsi';
SELECT p.Id, p.cognome, s.cognome, s.nome, s.matricola
FROM professori p LEFT JOIN studenti s ON p.Id=s.relatore
ORDER BY p.Id;

/**** FUNZIONI DI GRUPPO ****/
/**** 1. lo stipendio massimo, minimo e medio dei professori; ****/
set search_path to 'unicorsi';
SELECT MAX(stipendio), MIN(stipendio), AVG(stipendio)
FROM Professori;

/**** 2. il voto massimo registrato in ogni corso di laurea; ****/
set search_path to 'unicorsi';
SELECT cdl.Facolta, cdl.Denominazione, MAX(voto)
FROM CorsiDiLaurea cdl JOIN Corsi c ON cdl.Id=c.CorsoDiLaurea JOIN Esami e ON e.Corso = c.Id
GROUP by cdl.Facolta, cdl.Denominazione;

/****3. i nomi dei corsi del corso di studio in informatica per i quali sono stati registrati meno di 5 esami a partire dal 1 aprile 2012 [(*) includendo anche i corsi per cui non sono stati registrati esami a partire dal 1 aprile 2012]; ****/
--- DA FAREEEEE


/**** SOTTOINTERROGAZIONI SEMPLICI ****/
/**** 1. (manca risultato) il professore titolare del corso in cui ́è stata assegnata la votazione più alta; ****/
set search_path to 'unicorsi';
SELECT p.cognome, p.nome
FROM Professori p
INNER JOIN Corsi c ON c.Professore = p.Id
INNER JOIN ESAMI e ON e.Corso = c.Id
WHERE e.voto = (SELECT MAX(voto) FROM Esami)

/**** 2. la matricola degli studenti che si sono laureati in informatica prima del novembre 2009 - formulare usando una sotto-interrogazione e non join nè prodotto Cartesiano. ****/
set search_path to 'unicorsi';
SELECT s.Matricola
FROM Studenti s
WHERE s.Laurea < '2009-11-01' and s.CorsoDiLaurea IN (SELECT id FROM CorsiDiLaurea WHERE Denominazione = 'Informatica')

/**** 3. la matricola la matricola degli studenti di informatica che nel mese di giugno 2010 hanno registrato voti per il corso di basi di dati 1 ma non per quello di interfacce grafiche - formulare senza usare operatori insiemistici. ****/
set search_path to 'unicorsi';
SELECT s.Matricola FROM Studenti s
JOIN CorsiDiLaurea cdl ON s.CorsoDiLaurea = cdl.id
WHERE cdl.Denominazione = 'Informatica'
and s.Matricola IN(SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' AND e.Data <='2010-06-30' AND c.Denominazione = 'Basi Di Dati 1' AND e.voto >=18)
and s.Matricola NOT IN(SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' AND e.Data <='2010-06-30' AND c.Denominazione = 'Interfacce Grafiche' AND e.voto >=18)

/**** 4. (il risultato è riportato come ultima  interrogazione di quelle proposte per il laboratorio 3) la matricola la matricola degli studenti di informatica che nel mese di giugno 2010 hanno registrato voti sia per il corso di basi di dati 1 che per quello di interfacce grafiche - formulare senza usare operatori insiemistici. ****/
set search_path to 'unicorsi';
SELECT s.Matricola FROM Studenti s
JOIN CorsiDiLaurea cdl ON s.CorsoDiLaurea = cdl.id
WHERE cdl.Denominazione = 'Informatica'
and s.Matricola IN(SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' AND e.Data <='2010-06-30' AND c.Denominazione = 'Basi Di Dati 1' AND e.voto >=18)
and s.Matricola IN(SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' AND e.Data <='2010-06-30' AND c.Denominazione = 'Interfacce Grafiche' AND e.voto >=18)