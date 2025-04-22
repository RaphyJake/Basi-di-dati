-- ####################################################################
--  Gruppo Molinas Alessio, Romano Ettore
-- #####################################################################
set search_path to "unicorsi";

-- OUTER JOIN
/**** 1. l’elenco in ordine alfabetico (per denominazione) dei corsi, con eventuale nominativo del professore titolare; ****/
SELECT c.id, c.denominazione, p.cognome, p.nome
FROM Corsi c
LEFT JOIN Professori p 
ON c.Professore = p.ID 
ORDER BY c.denominazione

/**** 2. l’elenco alfabetico degli studenti iscritti a matematica, con l’eventuale relatore che li segue per la tesi. ****/
SELECT s.cognome, s.nome, p.cognome as relatore
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
ORDER BY p.cognome, p.nome
GROUP BY p.cognome, p.nome

/**** 4. (*) la matricola degli studenti iscritti al corso di studi in informatica che hanno registrato (almeno) due voti per corsi diversi nello stesso mese, con la media dei voti riportati [suggerimento: utilizzare la funzione extract per il tipo di dato DATE - ad esempio, per estrarre l'anno  EXTRACT (YEAR FROM Data). verificare sul manuale PostgreSQL] ****/
SELECT DISTINCT e.Studente, EXTRACT (MONTH FROM e.Data) as mese, EXTRACT (YEAR FROM e.Data) as anno, AVG(voto), count (e.Corso)
FROM Esami e
INNER JOIN Corsi c ON c.Id=e.Corso
INNER JOIN CorsiDiLaurea cdl ON cdl.Id = c.CorsoDiLaurea
GROUP BY e.Studente,EXTRACT (MONTH FROM e.Data), EXTRACT (YEAR FROM e.Data)
HAVING COUNT (DISTINCT e.Corso) >=2;


--- SOTTOINTERROGAZIONI SEMPLICI

/**** 1. (* e’ più difficile della 2, iniziare dalla 2) l’elenco dei corsi di laurea che nell’A.A. 2010/2011 hanno meno iscritti di quelli che si sono avuti ad informatica nello stesso A.A. (per filtrare sull'anno accademico di iscrizione utilizzare l'attributo Iscrizione della relazione Studenti);
[Suggerimento: ritrovare tramite un'interrogazione il numero di studenti iscritti a informatica nell'A.A.2010/2011 e utilizzare tale (sotto)interrogazione nella formula della clausola WHERE dell'interrogazione principale] ****/

SELECT cdl.Denominazione
FROM CorsiDiLaurea cdl
JOIN Studenti s ON s.CorsoDiLaurea=cdl.id
where s.Iscrizione = 2010 
GROUP BY cdl.Denominazione
HAVING COUNT(s.Matricola)<(
						SELECT COUNT(s.Matricola)
						FROM Studenti s
						JOIN CorsiDiLaurea cdl ON cdl.Id = s.CorsoDiLaurea
						WHERE s.Iscrizione = 2010 and cdl.Denominazione = 'Informatica')

/****Vorrei visualizzare anche quelli che non hanno iscritti ***/
/***ATTENZIONE: l'anno per il filtro va messo nella left join altrimenti proverei prima a fare match e poi filtrare quelli con anno = 2010
IN QUESTO MODO ESEGUO IL MATCH DI QUELLI CHE HANNO ID UGUALE ED ANNO = 2010  e non li tolgo in caso in cui l'anno sia NULL***/
SELECT cdl.Denominazione
FROM CorsiDiLaurea cdl
LEFT JOIN Studenti s ON s.CorsoDiLaurea = cdl.Id and s.Iscrizione = 2010
GROUP BY cdl.Denominazione
HAVING COUNT(s.Matricola)<(
						SELECT COUNT(s.Matricola)
						FROM Studenti s
						JOIN CorsiDiLaurea cdl ON cdl.Id = s.CorsoDiLaurea
						WHERE s.Iscrizione = 2010 and cdl.Denominazione = 'Informatica')
						
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

/**** Ulteriori attività di laboratorio su SQL - outer join, group by e prime sottointerrogazioni (se volete esercitarvi ulteriormente su questa parte) ****/
/**** OUTER JOIN ****/
/**** l’elenco dei cognomi, in ordine di codice identificativo, dei professori con l’indicazione del cognome, del nome e della matricola degli studenti di cui sono relatori, laddove seguano degli studenti per la tesi ****/
set search_path to 'unicorsi';
SELECT p.Id, p.cognome, s.cognome, s.nome, s.matricola
FROM professori p LEFT JOIN studenti s ON p.Id=s.relatore
ORDER BY p.Id;

/**** FUNZIONI DI GRUPPO ****/
/**** 1. lo stipendio massimo, minimo e medio dei professori; ****/
set search_path to 'unicorsi';
SELECT MAX(stipendio), MIN(stipendio), AVG(stipendio)
FROM Professori;

/**** 2. il voto massimo registrato in ogni corso di laurea; ****/
set search_path to 'unicorsi';
SELECT cdl.Facolta, cdl.Denominazione, MAX(voto)
FROM CorsiDiLaurea cdl JOIN Corsi c ON cdl.Id=c.CorsoDiLaurea JOIN Esami e ON e.Corso = c.Id
GROUP by cdl.Facolta, cdl.Denominazione;

/****3. i nomi dei corsi del corso di studio in informatica per i quali sono stati registrati meno di 5 esami a partire dal 1 aprile 2012 [(*) includendo anche i corsi per cui non sono stati registrati esami a partire dal 1 aprile 2012]; ****/
SELECT c.Denominazione
FROM Corsi c
INNER JOIN CorsiDiLaurea cdl ON cdl.Id = c.CorsoDiLaurea 
LEFT JOIN Esami e ON e.Corso = c.Id AND Data >='2012-04-01'
WHERE cdl.Denominazione = 'Informatica'
GROUP BY c.denominazione
HAVING COUNT(e.Corso) <5


/**** SOTTOINTERROGAZIONI SEMPLICI ****/
/**** 1. (manca risultato) il professore titolare del corso in cui ́è stata assegnata la votazione più alta; ****/
set search_path to 'unicorsi';
SELECT p.cognome, p.nome
FROM Professori p
INNER JOIN Corsi c ON c.Professore = p.Id
INNER JOIN ESAMI e ON e.Corso = c.Id
WHERE e.voto = (SELECT MAX(voto) FROM Esami)

/**** 2. la matricola degli studenti che si sono laureati in informatica prima del novembre 2009 - formulare usando una sotto-interrogazione e non join nè prodotto Cartesiano. ****/
set search_path to 'unicorsi';
SELECT s.Matricola
FROM Studenti s
WHERE s.Laurea < '2009-11-01' and s.CorsoDiLaurea IN (SELECT id FROM CorsiDiLaurea WHERE Denominazione = 'Informatica')

/**** 3. la matricola la matricola degli studenti di informatica che nel mese di giugno 2010 hanno registrato voti per il corso di basi di dati 1 ma non per quello di interfacce grafiche - formulare senza usare operatori insiemistici. ****/
set search_path to 'unicorsi';
SELECT s.Matricola FROM Studenti s
JOIN CorsiDiLaurea cdl ON s.CorsoDiLaurea = cdl.id
WHERE cdl.Denominazione = 'Informatica'
and s.Matricola IN(SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' AND e.Data <='2010-06-30' AND c.Denominazione = 'Basi Di Dati 1' AND e.voto >=18)
and s.Matricola NOT IN(SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' AND e.Data <='2010-06-30' AND c.Denominazione = 'Interfacce Grafiche' AND e.voto >=18)

/**** 4. (il risultato è riportato come ultima  interrogazione di quelle proposte per il laboratorio 3) la matricola la matricola degli studenti di informatica che nel mese di giugno 2010 hanno registrato voti sia per il corso di basi di dati 1 che per quello di interfacce grafiche - formulare senza usare operatori insiemistici. ****/
set search_path to 'unicorsi';
SELECT s.Matricola FROM Studenti s
JOIN CorsiDiLaurea cdl ON s.CorsoDiLaurea = cdl.id
WHERE cdl.Denominazione = 'Informatica'
and s.Matricola IN(SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' AND e.Data <='2010-06-30' AND c.Denominazione = 'Basi Di Dati 1' AND e.voto >=18)
and s.Matricola IN(SELECT e.studente FROM Esami e JOIN Corsi c ON e.corso = c.id
WHERE e.Data >='2010-06-01' AND e.Data <='2010-06-30' AND c.Denominazione = 'Interfacce Grafiche' AND e.voto >=18)

-- ####################################################################
--  Gruppo Molinas Alessio, Romano Ettore
-- #####################################################################
/**** Terza esercitazione di laboratorio - Parte 2 [SOLO BD 12 CFU] - livello fisico - Materiale e testo ****/

/**** 1. PostgreSQL memorizza tutti i file di organizzazione primaria e secondaria in una cartella. Gli amministratori della macchina su cui è installato il DBMS possono recuperare la cartella del file system all'interno della quale PostgreSQL memorizza il livello fisico.con il seguente comando (voi non potete farlo): SHOW data_directory
In genere, il path è: /Library/Postgres/<numero versione>/data ****/
SHOW data_directory;

/**** 2. Eseguite adesso la seguente interrogazione, che restituisce il nome dei database (datname) presenti sul server e l’identificativo corrispondente (oid), contenuti nel catalogo pg_database: ****/
SELECT datname,oid FROM pg_database;
/****
datname 	oid
s5339413 	16637 ****/


/**** 3. Adesso proviamo a individuare i nomi dei file corrispondenti alle tabelle dello schema unicorsi.
Per farlo, eseguiamo la seguente interrogazione in una finestra di query associata al vostro database. L’interrogazione:

    mette in join i cataloghi pg_namespace, che contiene una tupla per ogni schema presente nella base di dati per la quale è stata creata la finestra di query, e pg_class, una tupla per ogni oggetto presente nel database  (quindi anche per ogni tabella);
    seleziona dal catalogo pg_namespace l’identificativo (oid) dello schema unicorsi;
    seleziona dal catalogo pg_class le tuple corrispondenti alle relazioni dello schema unicorsi;
    restituisce il numero  identificativo dello schema (oid), il nome dello schema (nspname),  il nome della tabella (relname), il numero identificativo del file contenente l'istanza della tabella (relfilenode), il numero di pagine del file (relpages), il numero di tuple nella tabella (reltuples).
****/
SELECT N.oid, N.nspname, C.relname, C.relfilenode, C.relpages, C.reltuples
FROM pg_namespace N JOIN pg_class C ON N.oid = C.relnamespace
WHERE  N.nspname = 'unicorsi' AND relname IN ('corsi','corsidilaurea', 'professori','studenti','esami','pianidistudio');

SELECT * FROM pg_namespace where nspname='unicorsi'
/**** 
oid 	nspname 	
22898 	unicorsi
****/
SELECT oid, 	relname 	 FROM pg_class where relnamespace = 22898 AND relname IN ('corsi','corsidilaurea', 'professori','studenti','esami','pianidistudio');
/****
oid 	relname
22913 	corsi
22906 	corsidilaurea
22948 	esami
22964 	pianidistudio
22899 	professori
22931 	studenti
****/

--- CREAZIONE INDICI
/**** Eseguite la seguente interrogazione per recuperare dal catalogo pg_class informazioni su eventuali indici già creati dal sistema per le tabelle dello schema unicorsi:

SELECT C.oid, relname, relfilenode, relam, relpages, relhasindex, relkind
FROM pg_namespace N JOIN pg_class C ON N.oid = C.relnamespace
WHERE N.nspname = 'unicorsi' 

Interpretate il risultato ottenuto utilizzando le informazioni preliminari fornite.
Sono già presenti indici? Per quali chiavi di ricerca (=per quali attributi)? Riportate le vostre considerazioni nel file delle risposte. 

oid 	relname 	relfilenode 	relam 	relpages 	relhasindex 	relkind
22917 	corsi_pkey 	22917 	403 	2 	False 	i
22934 	studenti_pkey 	22934 	403 	2 	False 	i
22952 	esami_pkey 	22952 	403 	2 	False 	i
22919 	corsi_corsodilaurea_denominazione_key 	22919 	403 	2 	False 	i
22936 	studenti_cognome_nome_datanascita_luogonascita_corsodilaure_key 	22936 	403 	2 	False 	i
22968 	pianidistudio_pkey 	22968 	403 	2 	False 	i
22904 	professori_pkey 	22904 	403 	2 	False 	i
22909 	corsidilaurea_pkey 	22909 	403 	2 	False 	i
22911 	corsidilaurea_facolta_denominazione_key 	22911 	403 	2 	False 	i

Sono presenti le seguenti chiavi primarie, unique, non clusterizzate:
- corsi_pkey btree
- studenti_pkey btree
- esami_pkey btree
- pianidistudio_pkey btree
- professori_pkey btree
- corsidilaurea_pkey btree

Inoltre abbiamo le seguenti chiavi alternative non primarie, unique, non clusterizzate:
- corsi_corsodilaurea_denominazione_key btree
- studenti_cognome_nome_datanascita_luogonascita_corsodilaure_key btree
- corsidilaurea_facolta_denominazione_key btree
****/

/**** 3. Create adesso: 
	- un indice ordinato secondario sull’attributo voto della tabella esami
	CREATE INDEX idx_ord_voto_esami ON esami(voto);
	
	- un indice hash secondario sull’attributo iscrizione della tabella studenti
	CREATE INDEX idx_hash_iscrizione_studenti ON studenti USING HASH (iscrizione);
	
	- un indice ordinato clusterizzato sull’attributo corsodilaurea della tabella studenti
	CREATE INDEX idx_ord_corsodilaurea_studenti ON studenti(corsodilaurea);
	CLUSTER studenti USING idx_ord_corsodilaurea_studenti;


****/
/**** 4. Rieseguite il comando proposto al punto (2) e  verificate se qualcosa è cambiato. Riportate le vostre considerazioni nel file delle risposte.

SELECT C.oid, relname, relam, relpages, relkind, indexrelid, indrelid, indnatts, indisunique, indisprimary, indisclustered, indkey
FROM (pg_namespace N JOIN pg_class C ON N.oid = C.relnamespace) JOIN pg_index ON C.oid = indexrelid
WHERE N.nspname = 'unicorsi'  ;

SELECT oid, amname FROM pg_am;
403 	btree
405 	hash

Gli indici creati sono non chiave primaria, non unique, non clusterizzati:

- idx_ord_voto_esami (btree)
- idx_hash_iscrizione_studenti (HASH)

Gli indici creati sono non chiave primaria, non unique, clusterizzati:
- idx_ord_corsodilaurea_studenti (btree)
****/