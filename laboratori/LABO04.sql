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
  
  
--ESERCIZI SUPPLEMENTARI
/**
la matricola degli studenti di informatica 
che nel mese di giugno 2010 hanno registrato voti per il corso di basi di dati 1 
ma non per quello di interfacce grafiche - formulare senza usare operatori insiemistici [Formulare 
l'interrogazione senza usare operatori insiemistici, 
usando NOT EXISTS e sottointerrogazione correlata];
*/
set search_path to "unicorsi";
select s.matricola
from studenti s inner join esami e on e.studente = s.matricola
				inner join corsi c on c.id = e.corso
where c.denominazione = 'Basi Di Dati 1'
and extract(YEAR FROM e.data) = 2010
and extract(MONTH FROM e.data) = 6
and not exists (select *
				from esami e1 inner join corsi c1 on c1.id = e1.corso
				where c1.denominazione = 'Interfacce Grafiche' 
				and extract(YEAR FROM e1.data) = 2010
				and extract(MONTH FROM e1.data) = 6
				and s.matricola = e1.studente);				
--la matricola dello studente di informatica che ha la votazione media più alta;
select s.matricola, avg(e.voto)
from studenti s inner join corsidilaurea cdl on s.corsodilaurea = cdl.id
				inner join esami e on e.studente = s.matricola
where cdl.denominazione = 'Informatica'
group by s.matricola
having avg(e.voto) >= ALL(SELECT avg(e1.voto)
						 from studenti s1 inner join esami e1 on e1.studente = s1.matricola
						 inner join corsidilaurea cdl1 on s1.corsodilaurea = cdl1.id
						 where cdl1.denominazione = 'Informatica'
						 group by s1.matricola);

/**
per ogni corso di informatica, 
di cui siano stati registrati almeno 2 esami con votazione superiore a 27, 
la votazione minima,
media e massima conseguita in tale corso,
insieme al nome del corso e al numero di esami registrati;
*/
 
select c.denominazione,min(e.voto) as votoMinimoEsame,max(e.voto) as votoMaxEsame
from corsi c inner join corsidilaurea cdl on c.corsodilaurea = cdl.id
inner join esami e on e.corso = c.id
where cdl.denominazione = 'Informatica' 
and attivato = true
group by c.denominazione
having c.denominazione in (

--Prendo esami con votazione superiore a 27 (almeno 2)
select c.denominazione
from esami e inner join corsi c on c.id = e.corso
where voto >= 27
group by c.denominazione
having count(e.voto) >= 2);

--i corsi in cui si ha il maggior numero di studenti con voti insufficienti;

select c.denominazione, count(e1.voto)
from corsi c inner join esami e1 on e1.corso = c.id
WHERE e1.voto < 18
group by c.denominazione
having count(e1.voto) >= ALL(
select count(e.voto)
from esami e 
where e.voto < 18
group by e.corso);

/**
i corsi il cui professore titolare ́e relatore di qualche studente
di un corso di laurea diverso da quello del corso; 
[è possibile formularla senza sottointerrogazioni, 
provate però a usare una sottointerrogazione per esercitarvi]
*/

select distinct(c.denominazione)
from corsi c 
inner join professori p on p.id = c.professore
inner join studenti s on s.relatore = p.id
where c.corsodilaurea != s.corsodilaurea
and exists (
    select 1
    from corsi c1 
    where c1.professore = p.id 
    and c1.id != c.id
);


/**
	per ogni corso, il cognome e il nome degli studenti 
	che hanno ottenuto un voto sotto la votazione media del corso, 
	indicando anche denominazione del corso e voto.
*/

select s.nome || ' ' || s.cognome as nomestud, e.voto
from corsi c inner join esami e on e.corso = c.id
inner join studenti s on s.matricola = e.studente
where e.voto < (SELECT avg(e1.voto) 
					from esami e1 inner join corsi c1 on c1.id = e1.corso
					where c1.id = c.id
					group by c1.id);

