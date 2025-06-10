DO
$$
DECLARE
  v_cognome VARCHAR;
  v_nome VARCHAR;
  cur CURSOR FOR SELECT nome, cognome FROM clienti;
BEGIN
  OPEN cur;
  FETCH cur INTO v_nome, v_cognome;
	WHILE FOUND LOOP
		BEGIN
			RAISE NOTICE 'Ciao % %', v_nome, v_cognome;
		    FETCH cur INTO v_nome, v_cognome;
		END;
	  END LOOP;
  CLOSE cur;
END;
$$;