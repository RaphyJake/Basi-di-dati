CREATE OR REPLACE PROCEDURE public.filtra_clienti(
	IN ilnome varchar(50) DEFAULT NULL,
	IN ilcognome varchar(50) DEFAULT NULL)
LANGUAGE 'plpgsql'
AS
$$
DECLARE
ilComando VARCHAR(100) := 'SELECT nome, cognome FROM clienti';
BEGIN
	IF (ilnome IS NOT NULL) THEN
		ilComando := ilComando ||' WHERE nome='|| (ilnome);
		IF (ilcognome IS NOT NULL) THEN
		ilComando := ilComando ||' AND cognome='|| (ilcognome);
		END IF;
	ELSEIF (ilcognome IS NOT NULL) THEN
		ilComando := ilComando || ' WHERE cognome='|| (ilcognome);
	END IF;
	
	RAISE NOTICE 'Eseguo: %', ilComando;
	EXECUTE ilComando;
END;
$$
