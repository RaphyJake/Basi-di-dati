-- ####################################################################
--  Gruppo Botto Ugo, Molinas Alessio, Romano Ettore
-- #####################################################################
-- ESERCIZIO 1

---- ESERCIZIO 1.0
CREATE SCHEMA corsi;
set search_path to corsi;

---- ESERCIZIO 1.1
CREATE TABLE Professori
	(Id DECIMAL(5) PRIMARY KEY,
	 Cognome VARCHAR(20) NOT NULL,
	 Nome VARCHAR(20) NOT NULL,
	 Stipendio DECIMAL (8,2) DEFAULT 15000,
	 InCongedo BOOLEAN DEFAULT FALSE,
	 UNIQUE(Nome,Cognome)
	);

INSERT INTO Professori VALUES (54661, 'guerrini','giovanna', 123456.78, FALSE); 
INSERT INTO Professori VALUES (54662, 'catania','barbara', 12000.78, FALSE); 
INSERT INTO Professori VALUES (54663, 'chiola','giovanni');

INSERT INTO Professori VALUES (54664);
--NotNullViolation: null value in column "cognome" of relation "professori" violates not-null constraint
--DETAIL:  Failing row contains (54664, null, null, 15000.00, f).



INSERT INTO Professori VALUES (54665, 'chiola','giovanni'); -- errore per (cognome,nome) duplicato
--  UniqueViolation: duplicate key value violates unique constraint "professori_nome_cognome_key"
--DETAIL:  Key (nome, cognome)=(giovanni, chiola) already exists.




INSERT INTO Professori VALUES (54661, 'camminata','alessio', 123456.78, FALSE); -- errore per chiave duplicata
--  UniqueViolation: duplicate key value violates unique constraint "professori_pkey"
--DETAIL:  Key (id)=(54661) already exists.



INSERT INTO Professori VALUES (54664, 'camminata','alessio',10000,FALSE);

---- ESERCIZIO 1.2
CREATE TABLE Corsi
	(Id CHAR(10) PRIMARY KEY,
	 CorsoDiLaurea VARCHAR(20) NOT NULL,
	 Nome VARCHAR(70) NOT NULL,
	 Professori_Id DECIMAL(5),
	 Attivato BOOLEAN DEFAULT FALSE,
	 FOREIGN KEY (Professori_Id) REFERENCES Professori ON UPDATE CASCADE ON DELETE NO ACTION
	);
INSERT INTO Corsi VALUES ('SETI_T2025','Informatica','SISTEMI DI ELABORAZIONE E TRASMISSIONE DELL INFORMAZIONE',54663,TRUE);
INSERT INTO Corsi VALUES ('BASDAT1_25','Informatica','BASI DI DATI 1', 54661,TRUE);
INSERT INTO Corsi VALUES ('BASDAT2_25','Informatica','BASI DI DATI 2', 54662,TRUE);
--INSERT INTO Corsi VALUES ('ALGEBR2025','Informatica','ALGEBRA', 54664,TRUE);
--INSERT INTO Corsi VALUES ('ALGLOG2025','Informatica','ALGEBRA & LOGICA');
SELECT * FROM Corsi;

-- TEST
UPDATE Professori SET Id = 64661 WHERE id = 54661;
SELECT * FROM  Corsi where Professori_Id=64661;
-- Update eseguito

-- TEST
DELETE FROM Professori WHERE id = 64661;
-- ForeignKeyViolation: update or delete on table "professori" violates foreign key constraint "corsi_professori_id_fkey" on table "corsi"
--DETAIL:  Key (id)=(64661) is still referenced from table "corsi".



-- ##################################################################################################################
-- ESERCIZIO 2 - Ulteriori attività di laboratorio su SQL DDL (se volete esercitarvi ulteriormente su questa parte)
-- ##################################################################################################################
---- ESERCIZIO 2.0 Posizionarsi nello schema "corsi" creato nell'esercitazione di laboratorio eseguendo set search_path to “corsi”
set search_path to corsi;

---- ESERCIZIO 2.1 Creare la relazione che mantiene i dati degli studenti dell'Università di Genova
CREATE TABLE Studenti
	(Matricola SERIAL PRIMARY KEY,
	 Cognome VARCHAR(20) NOT NULL,
	 Nome VARCHAR(20) NOT NULL,
	 CorsoDiLaurea VARCHAR(20) NOT NULL,
	 Iscrizione CHAR(9) NOT NULL, 
	 Relatore DECIMAL(5),
	 FOREIGN KEY (Relatore) REFERENCES Professori ON UPDATE CASCADE ON DELETE NO ACTION
	);
INSERT INTO Studenti VALUES(DEFAULT,'MOLINAS','ALESSIO','INFORMATICA','2022/2023');
INSERT INTO Studenti VALUES(DEFAULT,'BOTTO','UGO','INFORMATICA','2021/2022');
INSERT INTO Studenti VALUES(DEFAULT,'ROMANO','ETTORE','INFORMATICA','2021/2022');

INSERT INTO Studenti VALUES(DEFAULT,'ROSSI','GIANFRANCO','INFORMATICA','2021/2022',5512);
-- ForeignKeyViolation: insert or update on table "studenti" violates foreign key constraint "studenti_relatore_fkey"
-- DETAIL:  Key (relatore)=(5512) is not present in table "professori".

INSERT INTO Studenti VALUES(DEFAULT,'ROSSI','GIANFRANCO','INFORMATICA','2021/2022',64661);
-- TEST 1
UPDATE Professori SET Id = 54660 WHERE id = 64661;
SELECT * FROM  Studenti where Relatore=54660;
-- TEST 2
DELETE FROM Professori WHERE id = 54660;
-- ForeignKeyViolation: update or delete on table "professori" violates foreign key constraint "corsi_professori_id_fkey" on table "corsi"
--DETAIL:  Key (id)=(54660) is still referenced from table "corsi".

-- 4 Provare a modificare le tabelle definite, in particolare provare a
---- 4.1 Modificare la tabella Corsi aggiungendo un attributo opzionale MutuaDa alfanumerico di 10 caratteri che costituisce una chiave esterna su Corsi e rappresenta l’identificatore del corso da cui il corso è eventualmente mutuato. Specificare il comportamento che si ritiene più opportuno in caso di violazioni dell’integrità referenziale. Inserire una nuova tupla corrispondente al corso di Basi di dati per Smid che mutua da Basi di dati per Informatica.

ALTER TABLE Corsi ADD column MutuaDa TYPE CHAR(10) REFERENCES Corsi ON UPDATE CASCADE ON DELETE NO ACTION;