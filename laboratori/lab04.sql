-- ####################################################################
--  Gruppo Molinas Alessio, Romano Ettore
-- #####################################################################
set search_path to "unicorsi";

-- SOTTOINTERROGAZIONI
/**** 1. (*) [questa interrogazione corrisponde a un'interrogazione già formulata in esercitazioni precedenti (con INTERSECT e IN), la richiesta è ora di formularla  IN DUE DIVERSI MODI: usando EXISTS e una sotto-interrogazione correlata E senza usare sotto-interrogazioni ma usando due alias sulle relazioni] la matricola degli studenti di informatica che nel mese di giugno 2010 hanno registrato voti sia per il corso di basi di dati 1 che per quello di interfacce grafiche; ****/
--- VERSIONE 1

SELECT DISTINCT e1.Studente
FROM Esami e1 
JOIN Corsi c1 ON e1.Corso = c1.id
WHERE e1.Voto>=18
AND e1.Data BETWEEN '2010-06-01' AND '2010-06-30'
AND c1.Denominazione ='Basi Di Dati 1'
AND EXISTS (SELECT *
			FROM Esami e2
			JOIN Corsi c2 ON e2.Corso=c2.Id
			WHERE e2.Voto>=18
			AND e2.Data BETWEEN '2010-06-01' AND '2010-06-30'
			AND c2.Denominazione ='Interfacce Grafiche'
			AND e1.Studente = e2.Studente)

-- VERSIONE 2
SELECT DISTINCT e1.Studente
FROM Esami e1
JOIN Esami e2 ON e1.Studente = e2.Studente and e1.Corso <> e2.Corso
JOIN Corsi c1 ON e1.Corso=c1.Id
JOIN Corsi c2 ON e2.Corso=c2.id
WHERE e1.Voto>=18
	AND e1.Data BETWEEN '2010-06-01' AND '2010-06-30'
	AND e2.Voto>=18
	AND e2.Data BETWEEN '2010-06-01' AND '2010-06-30'
	AND c1.Denominazione = 'Basi Di Dati 1'
	AND c2.Denominazione='Interfacce Grafiche'

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
SELECT p.Cognome, p.Nome, p.Id
FROM Professori p
JOIN Corsi c on c.Professore=p.Id
JOIN Esami e ON e.Corso = c.Id
GROUP BY p.Cognome,p.Nome, p.Id, c.Denominazione
HAVING AVG(e.Voto)>=ALL (
	SELECT AVG(e1.Voto) FROM Esami e1 GROUP BY e1.Corso
	)
	
/**** 5. per ogni corso, la matricola degli studenti che hanno ottenuto un voto sotto la votazione media del corso, indicando anche corso e voto; ****/
SELECT e.Studente,e.Corso, e.Voto
FROM Esami e 
WHERE e.Voto < (
	SELECT AVG(e2.Voto) FROM Esami e2
	WHERE e2.Corso = e.Corso)

/****  6. per ogni docente, il suo tesista con la votazione media più alta; ****/
SELECT p1.Nome, p1.Cognome, s1.Nome, s1.Cognome
FROM Esami e1
JOIN Studenti s1 ON s1.Matricola = e1.Studente
JOIN Professori p1 ON p1.Id = s1.Relatore
GROUP BY p1.Nome, p1.Cognome, s1.Nome, s1.Cognome,s1.Relatore
HAVING AVG(e1.Voto)>= ALL (
	SELECT AVG(e.Voto)
	FROM Esami e 
	JOIN Studenti s ON s.Matricola = e.Studente
	WHERE s.Relatore=s1.Relatore
	GROUP BY s.Cognome, s.Nome,s.Relatore
	)

/**** 7. per ogni docente, i corsi correntemente attivati in cui ha attribuito una votazione media superiore alla votazione media assegnata da tale docente (indipendentemente dal corso); ****/
SELECT p1.Nome, p1.Cognome, c1.id AS corso
FROM Professori p1
JOIN Corsi c1 ON c1.Professore=p1.Id
JOIN Esami e1 ON e1.Corso=c1.Id
WHERE c1.Attivato IS TRUE
GROUP BY p1.Cognome, p1.Nome, c1.id,p1.Id
HAVING AVG(e1.voto)> (
	SELECT AVG(e.Voto) FROM Professori p
	JOIN Corsi c ON c.Professore = p.Id
	JOIN Esami e ON e.Corso=c.id
	WHERE c.Attivato IS TRUE
	AND p1.Id=p.Id)

/**** (*) [divisione] gli studenti non ancora in tesi che hanno passato tutti gli esami del proprio corso di laurea. ****/
/*** Seleziono in maniera distinta gli studenti che sono senza relatore. Prendo tutti i corsi del corso di laurea dello studente della prima query e verifico che non esistano esami per quello studente, con voto superiore a 18 e per lo stesso corso ****/
SELECT DISTINCT s.Matricola
FROM Studenti s
WHERE s.Relatore IS NULL
	AND NOT EXISTS (
		SELECT *
		FROM Corsi c1
		WHERE c1.CorsoDiLaurea = s.CorsoDiLaurea
			AND NOT EXISTS (
				SELECT * FROM Esami e1
				WHERE e1.Studente=s.Matricola
					AND e1.Corso=c1.Id
					AND e1.Voto>=18
				)
		)

/**** Ulteriori esercizi di laboratorio - sottointerrogazioni (se volete esercitarvi ulteriormente su questa parte) ****/
/**** SOTTOINTERROGAZIONI ****/
/**** 1. la matricola la matricola degli studenti di informatica che nel mese di giugno 2010 hanno registrato voti per il corso di basi di dati 1 ma non per quello di interfacce grafiche - formulare senza usare operatori insiemistici [Formulare l'interrogazione senza usare operatori insiemistici, usando NOT EXISTS e sottointerrogazione correlata]; ****/
SELECT e.Studente
FROM Esami e
JOIN Corsi c ON c.Id = e.corso
JOIN CorsiDiLaurea cdl ON cdl.Id=c.CorsoDiLaurea
WHERE c.Denominazione='Basi Di Dati 1'
	AND cdl.Denominazione='Informatica'
	AND e.Data BETWEEN '2010-06-01' AND '2010-06-30'
	AND NOT EXISTS(
		SELECT *
		FROM Esami e1
		JOIN Corsi c1 ON e1.Corso=c1.Id
		JOIN CorsiDiLaurea cdl1 ON cdl1.Id=c1.CorsoDiLaurea
		WHERE c1.Denominazione = 'Interfacce Grafiche'
			AND cdl1.Denominazione='Informatica' 
			AND e1.Studente=e.Studente)

/**** 2. la matricola dello studente di informatica che ha la votazione media più alta; ****/
SELECT e.Studente
FROM Esami e
JOIN Studenti s ON s.Matricola=e.Studente
JOIN CorsiDiLaurea cdl ON cdl.Id = s.CorsoDiLaurea
WHERE cdl.Denominazione='Informatica'
GROUP BY e.Studente
HAVING AVG(e.Voto)>=ALL(
	SELECT AVG (e.Voto)
	FROM Esami e
	JOIN Studenti s ON s.Matricola=e.Studente
	JOIN CorsiDiLaurea cdl ON cdl.Id = s.CorsoDiLaurea
	WHERE cdl.Denominazione='Informatica'
	GROUP BY e.Studente
)

/**** 3. per ogni corso di informatica, di cui siano stati registrati almeno 2 esami con votazione superiore a 27, la votazione minima, media e massima conseguita in tale corso, insieme al nome del corso e al numero di esami registrati; ****/
SELECT c.Denominazione, MIN(e.Voto), AVG(e.Voto), MAX (e.Voto), COUNT(e.Voto)
FROM Esami e
JOIN Corsi c ON c.Id= e.Corso
JOIN CorsiDiLaurea cdl ON cdl.Id = c.CorsoDiLaurea
WHERE cdl.Denominazione='Informatica'
GROUP BY e.Corso, c.Denominazione
HAVING (
	SELECT COUNT(*)
	FROM Esami e1
	WHERE e1.Voto>27 and e1.Corso=e.Corso) >=2


/****  4. i corsi in cui si ha il maggior numero di studenti con voti insufficienti; ****/
SELECT e.Corso, COUNT(e.voto) 
FROM Esami e
JOIN Corsi c ON c.Id = e.Corso
WHERE e.Voto < 18
GROUP BY e.Corso
HAVING COUNT(e.Studente) >= ALL (
	SELECT COUNT(e1.Studente)
	FROM Esami e1
	WHERE e1.Voto<18
	GROUP BY e1.Corso)
	
/**** 5. i corsi il cui professore titolare è relatore di qualche studente di un corso di laurea diverso da quello del corso; [è possibile formularla senza sottointerrogazioni, provate però a usare una sottointerrogazione per esercitarvi]****/
SELECT c.Id, c.Denominazione
FROM Corsi c
WHERE EXISTS(
	SELECT * FROM Studenti s
	WHERE s.Relatore = c.Professore
		AND s.CorsoDiLaurea <> c.CorsoDiLaurea)

/**** 6. (*) la frequenza delle bocciature, suddivisa per sessione, ovvero per mesi (hint: si può raggruppare rispetto ad un’espressione; se serve potete usare tabelle temporanee - Fare riferimento al comando CREATE [TEMPORARY] TABLE AS, di cui trovate i dettagli sul manuale - Fare attenzione al fatto che la divisione tra interi restituisce un intero (cioè 3/4 fa 0). Un modo di ottenere 0.75 dovete fare CAST a float dei due numeri prima di effettuare la divisione); ****/
CREATE TEMPORARY TABLE EsamiNonPassati AS (
SELECT count(e.Voto)as insuf, EXTRACT(MONTH FROM e.Data) as Mese
FROM Esami e
WHERE E.Voto <18
group by EXTRACT(MONTH FROM e.Data));

CREATE TEMPORARY TABLE EsamiTotali AS
SELECT count(e.Voto)as tot, EXTRACT(MONTH FROM e.Data) as Mese
FROM Esami e
group by EXTRACT(MONTH FROM e.Data);

SELECT t.Mese as session, (n.insuf::float/t.tot::float)*100 AS perc 
FROM EsamiTotali t
JOIN EsamiNonPassati n ON n.Mese=t.Mese;


/**** 7. per ogni corso, il cognome e il nome degli studenti che hanno ottenuto un voto sotto la votazione media del corso, indicando anche denominazione del corso e voto. ****/
SELECT c.Denominazione, s.Cognome,s.Nome, e.Voto
FROM Esami e
JOIN Studenti s ON s.Matricola = e.Studente
JOIN Corsi c ON c.Id=e.Corso
GROUP BY e.Corso,c.Denominazione, s.Cognome,s.Nome,e.Voto
HAVING  e.Voto < (
	SELECT AVG(e1.Voto)
	FROM Esami e1
	WHERE e1.Corso=e.Corso
	GROUP BY e1.Corso)