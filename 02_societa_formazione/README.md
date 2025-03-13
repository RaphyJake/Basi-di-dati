# Esercitazione 2 - progettazione concettuale
Di seguito tutta la documentazione a corredo della seconda esercitazione - progettazione concettuale

# Documentazione a corredo

## Vincoli
V1: esempio

## Domini
dom

## Dizionario delle entità
|Nome|Descrizione|Attributi|Identificatori|
|---|---|---|---|
|corsi|Contiene i corsi disponibili a catalogo|codice, titolo, durata, area|codice|
|edizioni|Contiene le edizioni programmate dei corsi|data inizio, data fine, orario inizio|{corsi, data inizio, data fine, orario inizio, luogo}|

## Dizionario delle associazioni
|Nome|Descrizione|Attributi|Entità collegate|
|---|---|---|---|
|fanno parte di|I corsi possono far parte di 0 o più edizioni|-|corsi, edizioni|

## Gerarchia di generalizzazione
|Entità padre|Entità figlie|Tipologia|
|---|---|---|
|-|-|-|