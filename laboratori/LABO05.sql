/**
	Author: Team 35
	Description: Laboratorio dati derivati e viste
	Date: 08/05/2025
*/
set search_path to "unicorsi";
--VINCOLI
/**
	Specificare attraverso un vincolo CHECK che un esame 
	non può essere sostenuto in data successiva alla data odierna. 
	Si riesce ad aggiungere tale vincolo? Perchè?

	Sì, si riesce ad aggiungere il vincolo in quanto il check è corretto
	e non esiste alcuna tupla che viola il check aggiunto

*/

ALTER TABLE esami
ADD CONSTRAINT CK_DATE CHECK (data <= current_date)

--Prova vincolo
INSERT into esami
values ('23glot5','algo1','2025-05-09', 30)

/**
	Specificare attraverso un vincolo CHECK che un esame 
	non può essere sostenuto in data precedente il 1 gennaio 2014. 
	Si riesce ad aggiungere tale vincolo? Perchè?

	No, tale vincolo non si può aggiungere in quanto nelle tuple
	vi sono dati che violano il vincolo da aggiungere
*/
--Prova
ALTER TABLE esami
ADD CONSTRAINT CK_DT_2014 CHECK(EXTRACT(year from data) >= 2014 and
								EXTRACT(month from data) >= 1 and
								EXTRACT(day from data) >= 1);

/**
	Specificare attraverso un vincolo CHECK che non è mai possibile che 
	il relatore non sia specificato (relatore nullo) per uno studente 
	che si è già laureato( laurea non nulla)

	No, non è possibile aggiungere tale vincolo in quanto le tuple 
	hanno dati nulli in relatore che violano l'aggiunta del vincolo
*/
--Prova
ALTER TABLE studenti 
ADD CONSTRAINT CK_NULL_REL CHECK (relatore is not null);

--MODIFICHE
--i dati relativi al Professore Prini Gian Franco con identificativo 38 e stipendio 50000 euro;
insert into professori
values(38,'Prini','Gian Franco', 50000);

-- i dati relativi alla Professoressa Stefania Bandini, 
--con identificativo 39, senza specificare un valore per stipendio;
insert into professori(id, Cognome, Nome)
VALUES(39, 'Bandini', 'Stefania');

/**
	i dati relativi alla Professorressa Rosti, con identificativo 40, 
	senza specificare nome proprio né stipendio.
	I comandi vanno a buon fine? Perchè?

	Non va a buon fine perché il campo nome è definito come non nullable
*/

INSERT INTO professori (id, Cognome)
values (40, 'Rosti');

/**
	Aumentare di 5000 euro lo stipendio dei Professori 
	che hanno uno stipendio inferiore a 15000 euro.
*/


update professori
set stipendio = stipendio + 5000
where stipendio < 15000;

--Rimuovere il vincolo not null su Esami.voto
ALTER TABLE esami alter column voto drop not null;

/**
	Inserire ora il corso di ’Laboratorio di Informatica’ (id ’labinfo’) 
	per il corso di laurea di Informatica (id corso di laurea 9). 
	Inserire il fatto che gli studenti di Informatica non ancora in tesi hanno sostenuto 
	tale esame in data odierna (senza inserire votazione). 
	Modificare i voti degli studenti che hanno sostenuto tale corso
	e non hanno assegnata una votazione assegnando come votazione la votazione media dello studente.
*/

INSERT INTO corsi(id, corsodilaurea, denominazione,attivato)
values('labinfo',9,'Laboratorio di informatica',true);
--INSERT
insert into esami
select matricola,'labinfo' as corso,current_date as data
from studenti
where laurea is null and relatore is null;

--update
UPDATE esami e
set voto = (select avg(e1.voto) 
			 from esami e1
			 where e.studente = e1.studente)
where voto is null and corso = 'labinfo';

--VISTE
/**
	Creare una vista StudentiNonInTesi che permetta di visualizzare 
	i dati (matricola, cognome, nome, residenza, data di nascita, 
	luogo di nascita, corso di laurea, anno accademico di iscrizione)
	degli studenti non ancora in tesi (che non hanno assegnato alcun relatore).
*/
CREATE VIEW StudentiNonInTesi
AS
SELECT matricola, cognome, nome, residenza, datanascita, luogonascita, corsodilaurea, iscrizione
from studenti
where laurea is null and relatore is null;

--Interrogare la vista StudentiNonInTesi per determinare gli studenti non in tesi nati e residenti a Genova.
select *
from StudentiNonInTesi
where luogonascita = 'Genova';

/**
Creare la vista StudentiMate degli 
studenti di matematica non ancora laureati in cui ad 
ogni studente sono associate le informazioni sul numero di esami 
che ha sostenuto e la votazione media conseguita. 
Nella vista devono comparire anche gli studenti che non hanno sostenuto alcun esame.
*/

CREATE VIEW StudentiMate
AS
select s.nome, s.cognome, count(e.voto) as numeroEsami, avg(e.voto) as mediaVoto
from studenti s left join esami e on s.matricola = e.studente
inner join corsidilaurea cdl on cdl.id = s.corsodilaurea
where cdl.denominazione = 'Matematica' and s.laurea is null
group by s.nome, s.cognome;

--Numero esami
select sum(numeroesami)
from StudentiMate;
--Va a buon fine perché la vista pesca da una sola tabella
insert into StudentiNonInTesi
values('kee45srtf','Romano','Ettore','La Spezia','2000-03-24', 'La Spezia',6,2010);


--In studenti mate non va a buon fine perché presenta funzioni di gruppo