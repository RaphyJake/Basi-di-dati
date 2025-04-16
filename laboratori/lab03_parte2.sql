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