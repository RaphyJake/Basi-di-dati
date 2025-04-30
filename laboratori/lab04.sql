-- ####################################################################
--  Gruppo Molinas Alessio, Romano Ettore
-- #####################################################################
set search_path to "unicorsi";

-- SOTTOINTERROGAZIONI
/**** 1. (*) [questa interrogazione corrisponde a un'interrogazione già formulata in esercitazioni precedenti (con INTERSECT e IN), la richiesta è ora di formularla  IN DUE DIVERSI MODI: usando EXISTS e una sotto-interrogazione correlata E senza usare sotto-interrogazioni ma usando due alias sulle relazioni] la matricola degli studenti di informatica che nel mese di giugno 2010 hanno registrato voti sia per il corso di basi di dati 1 che per quello di interfacce grafiche; ****/


/**** 2. la matricola degli studenti di informatica che hanno sostenuto basi di dati 1 con votazione superiore alla votazione media (per tale esame); ****/
SELECT DISTINCT e1.Studente
FROM Esami e1
JOIN Corsi c ON c.id=e1.corso
JOIN CorsiDiLaurea cdl ON cdl.Id=c.CorsoDiLaurea
WHERE cdl.Denominazione='Informatica'
AND c.Denominazione = 'Basi Di Dati 1'
AND e1.voto > (SELECT AVG(e.voto) FROM Esami e WHERE e.Corso=e1.Corso)

/**** 3. i nominativi dei professori che insegnano nel maggior numero di corsi; [nota: non è possibile annidare funzioni di gruppo (es. MAX(COUNT)), ma si può usare  >= ALL invece di MAX] ****/
SELECT p.Cognome, p.Nome,COUNT(c.Professore) FROM Professori p
JOIN Corsi c ON c.Professore = p.id
GROUP BY p.Cognome, p.Nome
HAVING COUNT (c.Professore)>= ALL (SELECT COUNT (Professore) FROM Corsi Group By Professore)


/**** 4. i professori che sono titolari dei corsi i cui voti medi sono i più  alti; ****/

/**** 5. per ogni corso, la matricola degli studenti che hanno ottenuto un voto sotto la votazione media del corso, indicando anche corso e voto; ****/
SELECT e.Studente,e.Corso, e.Voto FROM Esami e 
WHERE e.Voto < (SELECT AVG(e2.Voto FROM Esami e2) WHERE e2.Corso = e.Corso)

/****  6. per ogni docente, il suo tesista con la votazione media più alta; ****/
SELECT p1.Nome, p1.Cognome, s1.Nome, s1.Cognome
FROM Esami e1
JOIN Studenti s1 ON s1.Matricola = e1.Studente
JOIN Professori p1 ON p1.Id = s1.Relatore
GROUP BY p1.Nome, p1.Cognome, s1.Nome, s1.Cognome,s1.Relatore
HAVING AVG(e1.Voto)>= ALL (SELECT AVG(e.Voto)
FROM Esami e 
JOIN Studenti s ON s.Matricola = e.Studente
WHERE s.Relatore=s1.Relatore
GROUP BY s.Cognome, s.Nome,s.Relatore)
ORDER BY p1.Nome, p1.Cognome

/**** 7. per ogni docente, i corsi correntemente attivati in cui ha attribuito una votazione media superiore alla votazione media assegnata da tale docente (indipendentemente dal corso); ****/
SELECT p1.Nome, p1.Cognome, c1.id AS corso
FROM Professori p1
JOIN Corsi c1 ON c1.Professore=p1.Id
JOIN Esami e1 ON e1.Corso=c1.Id
WHERE c1.Attivato IS TRUE

GROUP BY p1.Cognome, p1.Nome, c1.id,p1.Id
HAVING AVG(e1.voto)> (SELECT AVG(e.Voto) FROM Professori p
JOIN Corsi c ON c.Professore = p.Id
JOIN Esami e ON e.Corso=c.id
WHERE c.Attivato IS TRUE and p1.Id=p.Id)

/**** (*) [divisione] gli studenti non ancora in tesi che hanno passato tutti gli esami del proprio corso di laurea. ****/
/*** Seleziono in maniera distinta gli studenti che sono senza relatore. Prendo tutti i corsi del corso di laurea dello studente della prima query e verifico che non esistano esami per quello studente, con voto superiore a 18 e per lo stesso corso
****/
SELECT DISTINCT s1.Matricola FROM Studenti s1 WHERE s1.Relatore IS NULL AND NOT EXISTS
(SELECT * FROM Corsi c1 WHERE c1.CorsoDiLaurea = s1.CorsoDiLaurea AND NOT EXISTS
(SELECT * FROM Esami e1 WHERE e1.Studente = s1.Matricola AND e1.Corso = c1.Id and e1.Voto>=18)
)