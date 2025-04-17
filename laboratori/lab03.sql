-- ####################################################################
--  Gruppo Molinas Alessio, Romano Ettore
-- #####################################################################
-- OUTER JOIN
/**** 1. l’elenco in ordine alfabetico (per denominazione) dei corsi, con eventuale nominativo del professore titolare; ****/
SELECT c.id, c.denominazione, p.cognome, p.nome
FROM Corsi c
LEFT JOIN Professori p 
ON c.Professore = p.ID 
ORDER BY c.denominazione

/**** 2. l’elenco alfabetico degli studenti iscritti a matematica, con l’eventuale relatore che li segue per la tesi. ****/
SELECT s.cognome, s.nome, p.cognome
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