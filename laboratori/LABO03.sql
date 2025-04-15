/*
	Date: 15/04/2025
	Description: Laboratorio 03

*/
--OUTER JOIN
set search_path to "unicorsi";

--ESERCIZIO 1: l’elenco in ordine alfabetico (per denominazione) dei corsi, con eventuale nominativo del professore titolare;

SELECT c.denominazione, p.Cognome
FROM Corsi c left outer join Professori p on p.id = c.professore
order by 1;

--l’elenco alfabetico degli studenti iscritti a matematica, con l’eventuale relatore che li segue per la tesi.
SELECT s.cognome || ' ' || s.nome as NomeStudente, p.Cognome || ' ' || p.nome as NomeProfessore
FROM Studenti s 
inner join CorsiDiLaurea cdl on s.corsodilaurea = cdl.id
LEFT OUTER JOIN Professori p on p.id = s.relatore
where cdl.denominazione = 'Matematica'
ORDER BY 1;

--FUNZIONI DI GRUPPO
--la votazione minima, media e massima conseguita nei corsi del corso di laurea in informatica;
SELECT c.denominazione,min(e.voto) as VotoMinimo, avg(e.voto) as VotoMedio, max(e.voto) as votoMassimo
FROM Corsi c inner join CorsiDiLaurea cdl on cdl.id = c.corsodilaurea
inner join Esami e on e.corso = c.id
where cdl.denominazione = 'Informatica'
group by c.denominazione;

--i nominativi, in ordine alfabetico, dei professori titolari di più di due corsi attivati (attributo Attivato in Corsi), con l’indicazione di quanti corsi tengono;
SELECT p.cognome || ' ' || p.nome as nomeProfessore, Count(c.id) as conteggioCorsi
FROM Professori p inner join Corsi c on p.id = c.professore
WHERE c.attivato = true
GROUP BY nomeProfessore
HAVING COUNT(c.id) > 2
ORDER BY 1;

--l’elenco, in ordine alfabetico, dei professori con l’indicazione del numero di studenti di cui sono relatori [(*) indicando 0 se non seguono alcuno studente per la tesi];
SELECT p.cognome || ' ' || p.nome as NomeProfessore,COUNT(s.relatore)
FROM Professori p LEFT OUTER JOIN Studenti s on s.relatore = p.id
GROUP BY NomeProfessore
ORDER BY 1;

/* la matricola degli studenti iscritti al corso di studi in informatica che hanno registrato (almeno) due voti per corsi diversi nello stesso mese, 
con la media dei voti riportati [suggerimento: utilizzare la funzione extract per il tipo di dato DATE - ad esempio, per estrarre l'anno  EXTRACT (YEAR FROM Data).
verificare sul manuale PostgreSQL]*/
SELECT s.matricola,EXTRACT(YEAR FROM e.data) AS anno,EXTRACT(MONTH FROM e.data) AS mese,AVG(e.voto) AS media_voti
FROM Studenti s
inner JOIN CorsiDiLaurea cdl ON s.corsodilaurea = cdl.id
inner JOIN Esami e ON e.studente = s.matricola
inner JOIN Corsi c ON e.corso = c.id
WHERE cdl.denominazione = 'Informatica'
GROUP BY s.matricola, EXTRACT(YEAR FROM e.data), EXTRACT(MONTH FROM e.data)
HAVING COUNT(DISTINCT e.corso) >= 2;


--SOTTOINTERROGAZIONI SEMPLICI
--la matricola dello studente di informatica che ha conseguito la votazione più alta;
SELECT s.matricola
FROM Studenti s
where s.matricola = (select studente
                    from esami where voto = (select max(voto)
                                            from esami)
                    )
					
/*(* e’ più difficile della 2, iniziare dalla 2) l’elenco dei corsi di laurea che nell’A.A. 2010/2011 hanno meno 
iscritti di quelli che si sono avuti ad informatica nello stesso A.A.
(per filtrare sull'anno accademico di iscrizione utilizzare l'attributo Iscrizione della relazione Studenti);*/
SELECT cdl.denominazione, COUNT(s.matricola) AS iscritti
FROM CorsiDiLaurea cdl
LEFT JOIN Studenti s ON s.corsodilaurea = cdl.id AND s.iscrizione = 2010
GROUP BY cdl.denominazione
HAVING COUNT(s.matricola) < (
    SELECT COUNT(*)
    FROM Studenti s2
    INNER JOIN CorsiDiLaurea cdl2 ON s2.corsodilaurea = cdl2.id
    WHERE cdl2.denominazione = 'Informatica' AND s2.iscrizione = 2010
)
order by iscritti desc;