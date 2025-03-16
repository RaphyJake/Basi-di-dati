# Esercitazione 2 - progettazione concettuale
Di seguito tutta la documentazione a corredo della seconda esercitazione - progettazione concettuale

# Documentazione a corredo
Nel luogo dello svolgimento corso, ho pensato di aggiungere la sala per rendere univoca l'identificazione (nella stessa sala, stesso orario, non posso avere più corsi).
La denominazione sociale "in sede" permette di avere i campi di posizionamento della sede vuoti.

## Vincoli
* V1: il giudizio dell'edizione da parte del partecipante è obbligatorio per le edizioni terminate (date fine) da più di un mese

## Domini
* (livello, dipendenti) = dom_livello
    * dom_livello:[A-D]
* (durata, corsi) = dom_ore
    * dom_ore: interi

## Dizionario delle entità
|Nome|Descrizione|Attributi|Identificatori|
|---|---|---|---|
|corsi|Contiene i corsi disponibili a catalogo|codice, titolo, durata, area|codice|
|edizioni|Contiene le edizioni programmate dei corsi|data inizio, data fine, orario inizio|{corsi, data inizio, data fine, orario inizio, luogo}|
|docenti|Contiene tutti i docenti dei corsi|codice fiscale, nome, cognome, data di nascita, luogo di nascita, recapiti telefonici |{codice fiscale}|
|partecipanti|Contiene le anagrafiche dei partecipanti|codice fiscale, nome, cognome, data di nascita, luogo di nascita, sesso, areee di interesse, azienda attuale, numero di telefono|{codice fiscale}|

## Dizionario delle associazioni
|Nome|Descrizione|Attributi|Entità collegate|
|---|---|---|---|
|fanno parte di|I corsi possono far parte di 0 o più edizioni|-|corsi, edizioni|
|tengono|I docenti tengono 1 o più edizioni|-|docenti,edizioni|
|abilitati|I docenti sono abilitati a dei corsi (1 o più di uno)|-|docenti, corsi|
|partecipano|I partecipanti partecipano alle edizioni|giudizio|partecipanti, edizioni|

## Gerarchia di generalizzazione
|Entità padre|Entità figlie|Tipologia|
|---|---|---|
|docenti|dipendenti|totale, esclusiva|
|docenti|collaboratori esterni|totale, esclusiva|