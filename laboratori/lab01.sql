--Gruppo Molinas Alessio, Romano Ettore, Botto Ugo
CREATE SCHEMA corsi;
set search_path to corsi;

--PUNTO UNO
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
manca errore

INSERT INTO Professori VALUES (54665, 'chiola','giovanni'); -- errore per (cognome,nome) duplicato
-- UniqueViolation: duplicate key value violates unique constraint "professori_nome_cognome_key" 


INSERT INTO Professori VALUES (54661, 'camminata','alessio', 123456.78, FALSE); -- errore per chiave duplicata
-- UniqueViolation: duplicate key value violates unique constraint "professori_pkey" 

INSERT INTO Professori VALUES (54664, 'camminata','alessio',10000,FALSE);

--SECONDA PARTE
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

--TEST INSERIMENTO
SELECT * FROM Corsi;

-- TEST 1
UPDATE Professori SET Id = 64661 WHERE id = 54661;
SELECT * FROM  Corsi where Professori_Id=64661;
-- Update eseguito

-- TEST 2
DELETE FROM Professori WHERE id = 54661;
SELECT * FROM  Professori where Id=64661;
-- Cancellazione non avvenuta