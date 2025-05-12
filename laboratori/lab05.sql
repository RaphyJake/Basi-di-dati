-- ####################################################################
--  Gruppo Molinas Alessio, Romano Ettore
-- #####################################################################
set search_path to "unicorsi";
/**** VINCOLI ****/
/**** 1. Specificare attraverso un vincolo CHECK che un esame non può essere sostenuto in data successiva alla data odierna. Si riesce ad aggiungere tale vincolo? Perchè? 
Sì, il vincolo richiesto è statico, i dati contenuti nella tabella non violano questo nuovo vincolo****/

ALTER TABLE esami ADD CONSTRAINT CK_DATE CHECK(data<= current_date);
INSERT into esami
values ('23glot5','algo1','2025-05-09', 30)

/**** 
2. Specificare attraverso un vincolo CHECK che un esame non può essere sostenuto in data precedente il 1 gennaio 2014. Si riesce ad aggiungere tale vincolo? Perchè?
No, non è possibile aggiungere tale vincolo perchè sono presenti tuple che violano tale vincolo
****/
ALTER TABLE esami ADD CONSTRAINT CK_DT_2014 CHECK(data> '2014-01-01');

/****
3. Specificare attraverso un vincolo CHECK che non è mai possibile che il relatore non sia specificato (relatore nullo) per uno studente che si è già laureato( laurea non nulla)

****/
ALTER TABLE studenti
ADD CONSTRAINT CK_NULL_REL
CHECK (NOT (relatore IS NULL AND laurea IS NOT NULL));

/**** MODIFICHE ****/
/**** 1. Inserire nella relazione Professori: ****/
/******** a. i dati relativi al Professore Prini Gian Franco con identificativo 38 e stipendio 50000 euro; ********/
INSERT INTO professori VALUES(38, 'Prini', 'Gian Franco', 50000);
/******** b. i dati relativi alla Professoressa Stefania Bandini, con identificativo 39, senza specificare un valore per stipendio; ********/
INSERT INTO professori VALUES(39, 'Bandini', 'Stefania');
/******** b. i dati relativi alla Professorressa Rosti, con identificativo 40, senza specificare nome proprio né stipendio. 
Non va a buon fine perchè il campo nome è NOT NULL in fase di definizione della tabella ********/
INSERT INTO professori VALUES(40, 'Rosti');



/**** 2. Aumentare di 5000 euro lo stipendio dei Professori che hanno uno stipendio inferiore a 15000 euro. ****/
UPDATE professori set stipendio=stipendio+5000 where stipendio <15000;

/**** 3. Rimuovere il vincolo not null su Esami.voto mediante il comando alter table esami alter column voto drop not null; ****/
ALTER TABLE esami ALTER COLUMN voto DROP NOT NULL;

/****Inserire ora il corso di ’Laboratorio di Informatica’ (id ’labinfo’) per il corso di laurea di Informatica (id corso di laurea 9).
Inserire il fatto che gli studenti di Informatica non ancora in tesi hanno sostenuto tale esame in data odierna (senza inserire votazione).
Modificare i voti degli studenti che hanno sostenuto tale corso e non hanno assegnata una votazione assegnando come votazione la votazione media dello studente.****/
INSERT INTO corsi VALUES('labinfo',9, 'Laboratorio di informatica');
INSERT INTO esami (SELECT matricola, 'labinfo' , current_date FROM studenti s JOIN corsidilaurea cdl ON cdl.id=s.corsodilaurea WHERE relatore IS NULL AND cdl.Denominazione = 'Informatica');

UPDATE esami e SET voto = (SELECT AVG(voto) FROM esami e1 where e1.studente = e.studente) WHERE e.corso='labinfo' AND e.voto is NULL;
--QUERY DI VERIFICA: ho due voti a null
---SELECT *FROM esami WHERE corso='labinfo'
/**** Ripristinare, se possibile, il vincolo not null su Esami.voto
va in errore in quanto non tutti i valori voto sono valorizzati nella tabella****/
alter table esami add constraint vnn check (voto is not null);

/**** DATI DERIVATI, VISTE ****/
/**** 1. Creare una vista StudentiNonInTesi che permetta di visualizzare i dati (matricola, cognome, nome, residenza, data di nascita, luogo di nascita, corso di laurea, anno accademico di iscrizione) degli studenti non ancora in tesi (che non hanno assegnato alcun relatore).
****/
CREATE VIEW StudentiNonInTesi AS
SELECT matricola, cognome, nome, residenza, datanascita, luogonascita,corsodilaurea, iscrizione
FROM studenti
WHERE relatore IS NULL;

/**** 2. Interrogare la vista StudentiNonInTesi per determinare gli studenti non in tesi nati e residenti a Genova. ****/
SELECT *
FROM StudentiNonInTesi
WHERE luogonascita = 'Genova';

/**** 3. Creare la vista StudentiMate degli studenti di matematica non ancora laureati in cui ad ogni studente sono associate le informazioni sul numero di esami che ha sostenuto e la votazione media conseguita. Nella vista devono comparire anche gli studenti che non hanno sostenuto alcun esame. ****/
CREATE VIEW StudentiMate AS 
SELECT s.matricola, s.nome, s.cognome, count(voto) as nesami, AVG(voto)
FROM studenti s
JOIN corsidilaurea cdl on cdl.id = s.corsodilaurea
LEFT JOIN esami e on e.studente=s.matricola
WHERE cdl.Denominazione = 'Matematica'
AND s.laurea IS NULL
GROUP BY s.matricola, s.nome, s.cognome

/**** 4. Utilizzando la vista StudentiMate determinare quanti esami hanno sostenuto complessivamente gli studenti di matematica non ancora laureati. ****/
SELECT SUM(nesami) FROM StudentiMate;
/**** 5. Inserire una tupla a vostra scelta nella vista StudentiNonInTesi. L'inserimento va a buon fine? Perché? Esaminare l'effetto dell'inserimento, se andato a buon fine, sulla tabella Studenti. 
L'inserimento va a buon fine perchè i campi presenti nella vista sono tutti quelli obbligatori, quelli che possono assumere valori null non sono presenti e quindi l'insert va a  buon fine****/
insert into StudentiNonInTesi
values('dd92kdm','Molinas','Alessio','Savona','1992-04-06', 'Savona',6, 2021);

/**** 6. Inserire una tupla a piacere nella vista StudentiMate. L'inserimento va a buon fine? Perché? Esaminare l'effetto dell'inserimento, se andato a buon fine, sulla tabella Studenti.
Non è possibile in quanto sono presenti funzioni di aggregazione come count, avg che non so come poter valorizzare ****/