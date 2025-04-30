/**
	Author: Team 35
	Descrizione: Laboratorio 4 sottointerrogazioni
	Date: 29/04/2025
*/

set search_path to "unicorsi";

/*
	(*) [questa interrogazione corrisponde a un'interrogazione 
	già formulata in esercitazioni precedenti (con INTERSECT e IN), 
	la richiesta è ora di formularla  IN DUE DIVERSI MODI: usando EXISTS 
	e una sotto-interrogazione correlata E senza usare sotto-interrogazioni 
	ma usando due alias sulle relazioni] la matricola degli studenti di informatica 
	che nel mese di giugno 
	2010 hanno registrato voti sia per il corso di basi 
	di dati 1 che per quello di interfacce grafiche;
*/
--Usando exists
select e.studente,*
from esami e inner join corsi c on c.id = e.corso
where c.denominazione = 'Basi Di Dati 1' 
AND EXTRACT(YEAR FROM e.data) = '2010'
AND EXTRACT(MONTH FROM e.data) = '6' 
AND EXISTS (select *
			from esami e2 inner join corsi c2 on c2.id = e2.corso
			where c2.denominazione = 'Interfacce Grafiche' 
			AND EXTRACT(YEAR FROM e2.data) = '2010'
			AND EXTRACT(MONTH FROM e2.data) = '6' 
			and e.studente = e2.studente);
--Seconda senza sottointerrogazione
SELECT e1.studente
FROM esami e1
JOIN corsi c1 ON c1.id = e1.corso
JOIN esami e2 ON e1.studente = e2.studente
JOIN corsi c2 ON c2.id = e2.corso
JOIN studenti s ON s.matricola = e1.studente
WHERE c1.denominazione = 'Basi Di Dati 1'
  AND c2.denominazione = 'Interfacce Grafiche'
  AND EXTRACT(YEAR FROM e1.data) = 2010
  AND EXTRACT(MONTH FROM e1.data) = 6
  AND EXTRACT(YEAR FROM e2.data) = 2010
  AND EXTRACT(MONTH FROM e2.data) = 6;
  
 
 /**
	la matricola degli studenti di informatica che hanno 
	sostenuto basi di dati 1 con votazione superiore 
	alla votazione media (per tale esame);
*/

SELECT e.studente
FROM esami e
JOIN corsi c ON c.id = e.corso
JOIN studenti s ON s.matricola = e.studente
WHERE c.denominazione = 'Basi Di Dati 1'
  AND e.voto > (
    SELECT AVG(e1.voto)
    FROM esami e1
    WHERE e1.corso = e.corso AND e1.data = e.data
  );
  
  /**
	i nominativi dei professori che insegnano 
	nel maggior numero di corsi; 
	[nota: non è possibile annidare funzioni di gruppo (es. MAX(COUNT)), ma si può usare  >= ALL invece di MAX]
*/

select p.cognome || ' ' || p.nome as nomeprof, count(c.id)
from Professori p inner join corsi c on c.professore = p.id
group by 1
having count(c.id) >= ALL (select count(*)
							from corsi c2
							group by c2.professore);
							
							
							
/**
	i professori che sono titolari dei corsi i cui voti medi sono i più  alti; 
*/
SELECT p.cognome || ' ' || p.nome AS nomeprofessore
FROM corsi c
INNER JOIN professori p ON p.id = c.professore
WHERE c.id IN (
    SELECT e.corso
    FROM esami e
    GROUP BY e.corso
    HAVING AVG(e.voto) >= ALL (
        SELECT AVG(e1.voto)
        FROM esami e1
        GROUP BY e1.corso
    )
);

/**
per ogni corso, la matricola degli studenti che hanno ottenuto un voto 
sotto la votazione media del corso, indicando anche corso e voto;
*/

select s.nome || ' ' || s.cognome as nomestud, c.denominazione, e.voto
from corsi c inner join esami e on e.corso = c.id
inner join studenti s on s.matricola = e.studente
where e.voto < (
	select avg(e1.voto)
	from esami e1
	where e1.corso = e.corso
);

/**
	per ogni docente, i corsi 
	correntemente attivati in cui ha attribuito una votazione media superiore 
	alla votazione media assegnata da tale docente (indipendentemente dal corso);
*/

select p.id, c.id,avg(e.voto)
from professori p inner join corsi c on c.professore = p.id
inner join esami e on e.corso = c.id
where c.attivato = true 
group by p.id, c.id
having avg(e.voto) > (select avg(voto)
					  from esami e2 inner join corsi c2 on c2.id = e2.corso
					  where c2.professore = p.id);
					  

/**
(*) [divisione] gli studenti non ancora in tesi che hanno passato tutti gli esami del proprio corso di laurea.
*/

SELECT *
FROM studenti s
WHERE s.relatore IS NULL
  AND NOT EXISTS (
    SELECT *
    FROM corsi c
    WHERE c.corsodilaurea = s.corsodilaurea
      AND NOT EXISTS (
        SELECT *
        FROM esami e
        WHERE e.studente = s.matricola
          AND e.corso = c.id
          AND e.voto >= 18
      )
  );
