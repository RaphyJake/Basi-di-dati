-- A Determinare il numero di telefono dei clienti che
---- 1 hanno ordinato (almeno una volta) vegetariana
πTelC(σNome='vegetariana'(Pizza)⨝Ordine)

---- 2 hanno ordinato (almeno una volta) vegetariana oppure quattro formaggi
πTelC(σNome='vegetariana'∨Nome='quattro formaggi'(Pizza)⨝Ordine)

---- 3 hanno ordinato (almeno una volta) vegetariana e (almeno una volta) quattro formaggi
πTelC(σNome='vegetariana'(Pizza)⨝Ordine)∩πTelC(σNome='quattro formaggi'(Pizza)⨝Ordine)

---- 4 hanno ordinato vegetariana ma mai quattro formaggi
πTelC(σNome='vegetariana'(Pizza)⨝Ordine)-πTelC(σNome='quattro formaggi'(Pizza)⨝Ordine)

---- 5 non hanno mai ordinato vegetariana
πTelC(Ordine)-πTelC(σNome='vegetariana'(Pizza)⨝Ordine)

---- 6 hanno ordinato almeno due (tipi di) pizze diverse
πTelC1(σ (TelC1 = TelC∧ CodP1 ≠ CodP) (πTelC1, CodP1(ρTelC1 ←TelC, CodP1←CodP(Ordine))⨯(πTelC, CodP(Ordine))))

---- 7 hanno ordinato sempre lo stesso tipo di pizza
---- Prendo tutti i clienti che hanno prese due diverse e li tolgo da quelli che hanno ordinato
πTelC(Ordine)-πTelC(σ(TelC1=TelC ∧ CodP1≠CodP) (πTelC1,CodP1(ρTelC1←TelC,CodP1←CodP(Ordine)) ⨝ (πTelC, CodP(Ordine))))

-- B Determinare i nomi dei clienti che hanno ordinato (almeno una volta) vegetariana e (almeno una volta) quattro formaggi
πNomeC((πTelC(σNome='vegetariana'(Pizza)⨝Ordine)∩πTelC(σNome='quattro formaggi'(Pizza)⨝Ordine))⨝Cliente)

-- C Determinare la pizza
---- a (*) più cara
--- Prendo tutte le pizze e sottraggo le pizze che hanno costo più basso nel prodotto cartesiano e rimangono le pizze con prezzo massimo
π Nome, Costo(Pizza)-π Nome, Costo(σ Costo < Costo1 (π Nome, Costo (Pizza)⨯(πCosto1(ρ Costo1←Costo(Pizza)))))

---- b (*) che è stata ordinata almeno una volta da tutti i clienti
πNome((πCodP,TelC(Ordine)÷(πTelC(Cliente)))⨝Pizza)

-- D Determinare il numero di telefono dei clienti che
---- a hanno ordinato solo pizze che costano 6 euro
πTelC(Ordine)-πTelC(σCosto≠6(Pizza⨝Ordine))

---- b hanno ordinato tutte le pizze che costano 6 euro
πTelC,CodP(Ordine)÷πCodP(σCosto=6(Pizza⨝Ordine))

-- E Determinare la pizza più venduta
---- mette male fare la somma, ecc... non esiste operatore dell'algebra relazionale
-- F. Determinare le pizze che sono state ordinate almeno una volta da tutti i clienti
πNome((πCodP,TelC(Ordine)÷(πTelC(Cliente)))⨝Pizza)

-- G. Determinare il numero di telefono dei clienti che hanno effettuato un ordine contenente due tipi di pizza diversi (=hanno ordinato nella stessa data due tipi di pizza diversi)
πTelC(σTelC1 = TelC ∧ CodP1≠CodP ∧ Data1=Data (πTelC1,Data1,CodP1(ρTelC1←TelC, Data1←Data, CodP1←CodP(Ordine))⨝Ordine))

-- H.  Determinare per ogni cliente la sua pizza preferita (=la pizza che ha ordinato in quantitativo maggiore)
---- mette male fare la somma, ecc... non esiste operatore dell'algebra relazionale