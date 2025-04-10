/*
	Labo02
	Description: Laboratorio numero 2 di basi di dati
	Author: Ettore Romano
	Date: 10/04/2025
*/
set search_path to "unicorsi"
--Esercizio 1: la matricola e i nominativi degli studenti iscritti prima dell’A.A. 2007/2008 che non sono ancora in tesi (non hanno assegnato nessun relatore);

select matricola, nome, cognome, relatore
from Studenti
where (iscrizione < 2007) AND (relatore is null);

--ES 2
select facolta, denominazione
from CorsiDiLaurea
where (attivazione < '2006/2007') or (attivazione > '2009/2010') 
ORDER BY 1, 2

--ES 3
Select matricola, cognome, nome
from Studenti
where cognome not in ('Serra','Melogno','Giunchi')
OR (residenza in ('La Spezia','Genova','Savona'))
order by matricola desc


--INTERROGAZIONI CHE COINVOLGONO PIù RELAZIONI
--ES.1
--Potrei usare id = 9 nella where ma potrei non sapere l'id della laurea informatica
SELECT *
FROM Studenti s inner join CorsiDiLaurea cdl on cdl.id = s.corsodilaurea
where (laurea is not null) and cdl.denominazione = 'Informatica';

--ES 2
select s.Nome, s.Cognome, p.Cognome as RelatoreAssociato
from Studenti s inner join Professori p on p.id = s.relatore
inner join CorsiDiLaurea cds on cds.id = s.corsodilaurea
WHERE (EXTRACT(YEAR from laurea) < 2009) 
and (EXTRACT(MONTH from laurea) < 11)
and (cds.denominazione = 'Informatica')
ORDER BY 2,1;

--ES 3

SELECT s.cognome, s.nome
FROM Studenti s inner join PianiDiStudio pds on pds.studente = s.matricola
inner join CorsiDiLaurea cds on cds.id = s.corsodilaurea
where (pds.anno = 5) and (cds.denominazione = 'Informatica')
ORDER BY s.cognome desc

--OPERAZIONI INSIEMISTICHE
SELECT Nome, Cognome, 'Studente' as Qualifica
from Studenti
UNION
SELECT Nome, Cognome, 'Professore' as Qualifica
from Professori;

--ES 2

SELECT s.nome, s.cognome, e.voto, c.denominazione, e.data
FROM Studenti s inner join Esami e on e.studente = s.matricola
inner join Corsi c on c.id = e.corso
where (c.denominazione = 'Basi Di Dati 1') 
and (e.voto >= 18)
and EXTRACT(YEAR from e.data) = 2010
and EXTRACT(MONTH from e.data) = 06

INTERSECT

SELECT s.nome, s.cognome, e.voto, c.denominazione, e.data
FROM Studenti s inner join Esami e on e.studente = s.matricola
inner join Corsi c on c.id = e.corso
where (c.denominazione = 'Interfacce Grafiche') 
and (e.voto < 18)
and EXTRACT(YEAR from e.data) = 2010
and EXTRACT(MONTH from e.data) = 06;

--ES 3

SELECT s.matricola
FROM Studenti s inner join Esami e on e.studente = s.matricola
inner join Corsi c on c.id = e.corso
where (c.denominazione = 'Basi Di Dati 1') 
and (e.voto >= 18)
and EXTRACT(YEAR from e.data) = 2010
and EXTRACT(MONTH from e.data) = 06

INTERSECT

SELECT s.matricola
FROM Studenti s inner join Esami e on e.studente = s.matricola
inner join Corsi c on c.id = e.corso
where (c.denominazione = 'Interfacce Grafiche') 
and (e.voto > 18)
and EXTRACT(YEAR from e.data) = 2010
and EXTRACT(MONTH from e.data) = 06;