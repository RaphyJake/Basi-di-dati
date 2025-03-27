# Progetto Fantasanremo - progettazione concettuale

# Testo disambiguato

Si richiede la progettazione e realizzazione di una base di dati a supporto della piattaforma social di FantaSanremo, un gioco di fantasia ispirato al Festival di Sanremo.

Il gioco consente agli utenti (che si registrano con nome e cognome, identificati dalla loro username) di creare e gestire squadre virtuali (alle quali attribuiscono un nome, identificate da un codice) di artisti (i cantanti) partecipanti, organizzandosi in leghe (alle quali viene assegnato un nome, identificate da un codice) per competere tra loro. I punteggi vengono assegnati in base alle performance degli artisti e all’applicazione di specifici bonus e malus (con descrizione, valore, tipologia bonus, identificati da un codice). La base di dati dovrà permettere la gestione strategica delle squadre, l’organizzazione delle leghe e il tracciamento in tempo reale dei punteggi durante il Festival.

Un primo aspetto fondamentale riguarda la gestione del Festival stesso. È necessario memorizzare le informazioni relative agli artisti in gara, inclusi dettagli come nome, biografia, genere musicale, provenienza (luogo e data di nascita) e partecipazioni passate. Per ogni artista, sarà importante associare i brani eseguiti, registrandone titolo, autori, compositori, durata e genere musicale. E' inoltre importante sapere chi dirige il brano. Ogni esibizione dovrà essere collegata a una specifica serata del Festival (le serete vengono considerate come dei contenitori), con indicazione dell’ordine di esibizione, dell’orario e di eventuali altri dettagli rilevanti.
Inoltre, il sistema dovrà raccogliere e conservare i voti assegnati dai diversi organi di giuria e dal pubblico, consentendo così di monitorare l’andamento della competizione e aggiornare la classifica del Festival in base ai risultati (tipologia voto, data ed ora, identificato da un codice progressivo).

Parallelamente, la base di dati dovrà supportare le dinamiche del gioco FantaSanremo. Gli utenti dovranno registrarsi con un nome univoco (username che di fatto corrisponde all'indirizzo e-mail) e fornire informazioni personali essenziali (nome, cognome). Ogni utente avrà la possibilità di creare squadre, rispettando un budget di crediti virtuali 100 (baudi), con cui selezionare sette artisti tra quelli in gara. La formazione prevede cinque titolari, due riserve e un capitano scelto tra i titolari. Sarà possibile iscrivere e modificare la squadra entro una data limite, con la possibilità di riorganizzare la formazione giornalmente durante la settimana del Festival, rispettando precise fasce orarie. I punteggi vengono assegnati in base a un regolamento che prevede l’attribuzione di bonus e malus agli artisti in base alle loro performance e ad altri criteri specificati (sono censiti con descrizione, tipo, valore (positivo/negativo) ed  indentificati da un codice).

Gli artisti schierati tra i titolari contribuiscono al punteggio totale della squadra con tutti i bonus e malus accumulati, mentre quelli tra le riserve influenzano il punteggio solo con bonus e malus di tipo extra. Il capitano ottiene un trattamento speciale per alcuni bonus, con punteggi raddoppiati in determinate circostanze. Il gioco si articola in leghe (con nome, tipo visibilita), che permettono agli utenti di sfidarsi in campionati separati. Le leghe possono essere pubbliche, private o segrete, con diverse modalità di accesso e visibilità. Ogni lega ha un nome personalizzabile e può essere amministrata da un proprietario (l’utente che l’ha creata) e da eventuali amministratori delegati.
Il proprietario e gli amministratori hanno il compito di gestire la lega e approvare le richieste di iscrizione nelle leghe private e segrete, ma non possono intervenire sui punteggi assegnati agli artisti, che vengono determinati secondo il regolamento ufficiale del gioco. Ogni utente può creare un numero limitato di leghe e partecipare a un massimo di venticinque leghe contemporaneamente. Ogni lega consente a ciascun partecipante di iscrivere una sola squadra, e tutte le squadre sono automaticamente iscritte anche al Campionato Mondiale dell’edizione in corso del Festival (una lega pubblica). Durante lo svolgimento del Festival, il sistema dovrà calcolare e aggiornare i punteggi delle squadre al termine di ogni serata, aggiornando di conseguenza la classifica delle leghe e quella generale del Campionato Mondiale. Al termine della competizione, la squadra con il punteggio più alto all’interno di ciascuna lega sarà dichiarata vincitrice.




## Vincoli
* V1: un utente con le proprie squadre non può partecipare a più di 25 leghe
* V2: ogni utente, per ciascuna formazione di una squadra, ha a disposizione 100 baudi
* V3: una squadra, per ciascuna serata, può avere al massimo 7 partecipanti alla formazione (se durante la giornata la formazione cambia più volte nella fascia oraria concessa, sarà sovrascritta ed aggiornata la data di modifica). 
* V4: per ciascuna data, per ciascuna squadra potremo avere al massimo 4 titolari, 2 riserve, 1 capitano all'interno della formazione
* V4: se la tipologia di lega è pubblica il tipo approvazione dell'associazione partecipano è valorizzato ad APPROVATA
* V5: se l'artista ha il nome gruppo allora non può scrivere, comporre e dirigere brani

## Dettagli a livello applicativo
* la squadra può essere modificata entro un determinato termine (a livello applicativo)
* la squadra, durante il festival, può essere modificata in determinate fasce orarie (a livello applicativo)
* nell'entità delle formazioni, ogni serata del festival prevede che vengano replicati i dati della formazione della squadra (la data di modifica viene aggiornata solo in caso di modifiche)

## Domini
* (tipo, voti) = tipo_voto
    * tipo_voto: {televoto, giuria_stampa, giuria_radio}
* (tipo, leghe) = tipo_lega
    * tipo_voto: {pubblica, privata, segreta}
* (username, utenti) = stringa
* (proprietario, gestiscono) = bool
* (stato approvazione, partecipano) = tipo_approvazione
    * tipo_approvazione = {IN_APPROVAZIONE, RIFIUTATA, APPROVATA}
* (tipo, bonus malus) = tipo_bonusmalus
    * tipo_bonusmalus = {extra,standard}
* (valore, bonus malus) = real (può essere negativo per i malus)
* (ruolo, compone) = ruolo_compone
    * ruolo_compone = {capitano, titolare, riserva}
* (durata, brani) = real (secondi durata brano)

## Dizionario delle entità
|Nome|Descrizione|Attributi|Identificatori|
|---|---|---|---|
|artisti|gli artisti sono tutti coloro che lavorano per l'arte (compositori, scrittori, cantanti, direttori d'orchestra, ecc...)|nome, cognome, data nascita, luogo nascita| {nome, cognome, data nascita} {nome gruppo}|
|cantanti|specializzazione di artista|biografia, genere musicale, edizioni passate, costo in baudi| ereditato|
|brani|tutti i brani che possono essere eseguiti durante le serate|titolo, genere musicale, durata|{artista scrittore, titolo}|
|esibizioni|informazioni relative alle esibizioni|orario, ordine di esibizione| {cantante, brano, serata}|
|voti|informazioni relative al voto del pubblico/giuria|codVoto, tipo, data/ora|codVoto|
|serata|informazioni delle serate, esiste una serata speciale dedicata agli "extra punteggi" senza alcuna data|nome, data|{nome}|
|utenti|informazioni di base degli utenti iscritti al FantaSanremo|username, nome, cognome|username|
|leghe|informazioni relative alle leghe|codLega, nome, tipo|codLega|
|squadre|informazioni relative alle squadre create dai partecipanti al FantaSanremo|codSquadra, nome|codSquadra|
|formazione|le formazioni delle squadre, modificabili ogni giorno risiedono in questa entità|data modifica| {squadre, cantanti, serate}|
|bonus malus|descrizione di tutti i bonus-malus previsti dal regolamento|codBonusMalus, descrizione, valore, tipo|codBonusMalus|


## Dizionario delle associazioni
|Nome|Descrizione|Attributi|Entità collegate|
|---|---|---|---|
|gestiscono|Gli utenti si occupano di creare/gestire le leghe. Se sono proprietari l'attributo proprietario è "vero" altrimenti vengono considerati come amministratori delegati di quelle leghe|proprietario|utenti, leghe|
|partecipano|Le squadre possono partecipare a delle leghe|stato approvazione|squadre, leghe|
|possiedono|Gli utenti possiedono le squadre||utenti, squadre|
|schierano|Le squadre schierano formazioni| |squadre, formazioni|
|fa parte di|I cantanti fanno parte di una formazione|ruolo|cantanti, formazioni|
|appartengono|Le formazioni appartengono alle serate||formazioni, serate|
|ottengono|Le formazioni ottengono dei bonus/malus| valore effetivo| bonus-malus, formazioni|
|scritto|Un artista scrive un brano||artisti, brani|
|composto|Un artista compone un brano||artisti, brani|
|diretto|Un artista dirige un brano||artisti, brani|
|si esibiscono| Un cantante si esibisce in un'esibizizione||cantanti, esibizioni|
|esecuzione|Un bravo viene eseguito in un'esibizione|| brano, esibizioni|
|sono giudicate| Un'esibizionie è giudicata da voti espressi da pubblico/giuria||esibizioni,voti|
|si svolge| Un'esibizione si svolge in una serata||serate, esibizioni|

## Gerarchia di generalizzazione
|Entità padre|Entità figlie|Tipologia|Attributi aggiuntivi|
|---|---|---|---|
|artisti|cantanti|associazione di sottoinsieme: parziale ed esclusiva|biografia, genere musicale, edizioni passate, costo in baudi|