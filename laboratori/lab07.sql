/*** Scrivere una interrogazione SQL per recuperare tutte le tuple contenute nella tabella catalogo information_schema.table_privileges, analizzarne lo schema e l'istanza. Cercate di comprendere il significato degli attributi (escluso l'attributo with_hierarchy).

-- query select * from information_schema.table_privileges;
-- grantor -> chi concedere il privilegio
-- grantee -> chi riceve il privilegio
-- table_catalog ->
-- table_schema -> a quale schema si riferisce il privilegio
-- table_name -> a quale tabella si riferisce il privilegio
-- privilege_type -> a quale operazione fa riferimento il privilegio
-- is_grantable -> il grantee può concedere quel privilegio ad altri utenti (se YES, altrimenti NO)

****/
/**** RICHIESTE

1. Scrivere una o più interrogazioni  per recuperare dal catalogo information_schema.table_privileges le informazioni relative ai privilegi delle tabelle contenute nello schema unicorsi. Non considerate la colonna with_hierarchy.
****/
select * from information_schema.table_privileges where table_schema='unicorsi';

/**** 2. Creare l'utente yodaX (con password yodaX) e l'utente lukeX (con password lukeX), dove X è la vostra matricola.
Usare il comando CREATE USER nome PASSWORD 'password') 
[in Postgres ogni utente è visto come un ruolo che ha la possibilità di connettersi al DBMS].
****/
set search_path='unicorsi';
CREATE USER yoda5339413 PASSWORD 'yoda5339413';
CREATE USER luke5339413 PASSWORD 'luke5339413';

/**** 3. Siete collegati con le vostre credenziali.
Concedere a yodaX per prima cosa il privilegio di utilizzare lo schema unicorsi (con grant option) mediante il comando:
GRANT USAGE ON SCHEMA unicorsi TO yoda WITH GRANT OPTION.
Questo comando permetterà all'utente yoda di utilizzare le tabelle presenti nello schema secondo i privilegi che gli verranno concessi.
****/
GRANT USAGE ON SCHEMA unicorsi TO yoda5339413 WITH GRANT OPTION;

/**** 4. Siete collegati con le vostre credenziali.
Attribuitevi il ruolo utente yodaX con il comando:
GRANT yodaX to <vostro_utente>; 
e poi, senza disconnettervi, cambiate il vostro ruolo/utente in yodaX (ricordate che in PostgreSQL ogni utente è anche un ruolo) con il comando SET ROLE yodaX.
****/
GRANT yoda5339413 to s5339413;
SET ROLE yoda5339413;

/**** 5. Adesso rivestite il ruolo yodaX;
Provate ad eseguire la query per recuperare le informazioni di tutti gli studenti. Riuscite ad eseguire l'operazione? Quale risultato viene restituito? Perché?
****/
SELECT * FROM Studenti;
---- InsufficientPrivilege: permission denied for table studenti
---- Accade perchè il ruolo yoda5339413 ha il permesso di utilizzare lo schema, ma di fatto non può fare nulla sullo schema

/**** 6. A questo punto, ritornate al vostro utente con il comando
SET ROLE nomeutente;
Concedete a yodaX il privilegio di lettura su tutte le tabelle tranne pianidistudio. Solo il privilegio di lettura concesso sulle tabelle corsidilaurea e corsi deve essere delegabile.
****/
SET ROLE s5339413;
GRANT SELECT on  esami, professori, studenti  TO yoda5339413;
GRANT SELECT ON corsi, corsidilaurea TO yoda5339413 WITH GRANT OPTION;

/**** 7. Siete collegati con le vostre credenziali.
Attribuitevi il ruolo utente yodaX con il comando:
GRANT yodaX to <vostro_utente>;
e poi cambiate il vostro ruolo/utente in yodaX (ricordate che in PostgreSQL ogni utente è anche un ruolo) con il comando SET ROLE yodaX.
****/
SET ROLE s5339413;
GRANT yoda5339413 to s5339413;
SET ROLE yoda5339413;

/**** 8. Adesso agite come yodaX. Eseguite di nuovo la query per recuperare le informazioni degli studenti. Riuscite ad eseguire l'operazione? Quale risultato viene restituito? Perché? ****/
SET ROLE yoda5339413;
SELECT * FROM Studenti;
--- Riesco a recuperare i risultati perchè abbiamo creato il ruolo yoda5339413, siamo entrati con il nostro utente, dato i permessi al ruolo yoda, entrati come yoda

/**** 9. (+) Agite come utente yodaX, seguendo quanto descritto precedentemente. Scrivere una o più interrogazioni per recuperare dal catalogo information_schema.table_privileges le informazioni relative ai privilegi dell'utente yodaX e cercate conferma alla motivazione proposta al punto (8).
****/
select * from information_schema.table_privileges where table_schema='unicorsi';
--- Riesco a vedere che la tabella studenti ha il grant per il ruolo yoda5339413 

/***** 10. Agite come utente  yodaX, seguendo quanto descritto in precedenza. Concedere a lukeX il privilegio di lettura su studenti, in modalità non delegabile. Riuscite ad eseguire l'operazione? Quale risultato viene restituito? Perché?*****/
SET ROLE yoda5339413;
GRANT SELECT on studenti  TO luke5339413;

--- la query non restituisce errore, ma non vedo variazioni in information_schema.table_privileges (non devo avvenire perchè l'utente non ha la grant option)


/**** 11. Agite come utente  yodaX, seguendo quanto descritto in precedenza. Ora concedere a lukeX il privilegio di lettura su corsi. Riuscite ad eseguire l'operazione? Quale risultato viene restituito? Perché? ****/
SET ROLE yoda5339413;
GRANT SELECT on corsi  TO luke5339413;
--- la query è andata a buon fine, ma il risultato è visibile in information_schema.table_privileges (perchè yoda ha i permessi di delega su corsi e non su studenti)

/**** 12. Ritornate ad agire con le vostre credenziali:  cambiate il vostro ruolo/utente (ricordate che in PostgreSQL ogni utente è anche un ruolo) con il comando SET ROLE nomeutente.****/
SET ROLE s5339413;

/**** 13. Siete collegati con le vostre credenziali. Revocare all'utente yodaX  il privilegio di lettura sulla tabella corsi, con modalità RESTRICT. Riuscite ad eseguire l'operazione? Quale risultato viene restituito? Perché?
****/
SET ROLE s5339413;
REVOKE SELECT ON corsi from yoda5339413 RESTRICT;
-- l'operazione non va a buon fine perchè yoda5339413 ha concesso i permessi a luke5339413 --- DependentObjectsStillExist: dependent privileges exist

/**** 14.(+) Siete collegati con le vostre credenziali. Scrivere una o più interrogazioni sul catalogo information_schema.table_privileges per trovare la conferma alla motivazione data al punto (13). ****/
select * from information_schema.table_privileges where table_schema='unicorsi' and grantor='yoda5339413';
--- si può vedere che l'utente yoda5339413 ha concesso i privilegi a luke5339413 e quindi non possono essere revocati in modalità strict

/**** 15. Siete collegati con le vostre credenziali. Revocare a yodaX  il privilegio di lettura sulla tabella corsi, con modalità CASCADE. Riuscite ad eseguire l'operazione? Quale risultato viene restituito? Perché? ****/
SET ROLE s5339413;
REVOKE SELECT ON corsi from yoda5339413 CASCADE;

--- l'operazione va a buon fine perchè è presente il CASCADE che va a rimuovere tutte le dipendenze (quindi il privileggio di yoda5339413 a luke5339413)

/**** 16. (+) Siete collegati con le vostre credenziali. Scrivere una o più interrogazioni sul catalogo table_privileges per trovare la conferma alla motivazione data al punto (15).
*****/
SET ROLE s5339413;
select * from information_schema.table_privileges where table_schema='unicorsi' and grantor='yoda5339413';
-- il grant è stato rimosso con successo

/**** 17.
(*) Siete collegati con le vostre credenziali. Create i ruoli jediX e maestroJediX con il comando CREATE ROLE nomeruolo, dove X è il vostro numero di gruppo. Utilizzando la documentazione  di PostgreSQL, individuare ed eseguire i seguenti comandi:

    revocate il privilegio di SELECT su corsi e studenti a jodaX e lukeX;
    definire il ruolo maestroJediX come ruolo padre rispetto al ruolo jedi (quindi il maestroJediX può fare almeno tutto quello che può fare uno jedi);
    attribuire al ruolo jediX tutti i privilegi sulla tabella studenti;
    attribuire al maestroJediX tutti i privilegi sulla tabella corsi, oltre a tutti i privilegi sulla tabella studenti, sfruttando la gerachia precedentemente definita;
    attribuire il ruolo jediX a lukeX e il ruolo maestroJediX a yodaX;
    eseguendo opportune query (eventualmente anche sul catalogo) provare a capire se lukeX e yodaX hanno adesso i privilegi che vi aspettate.
****/