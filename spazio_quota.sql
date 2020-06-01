CREATE OR REPLACE TRIGGER dopo_sospensione
AFTER SUSPEND
ON DATABASE
DECLARE

  CURSOR cursore_per_username IS
  SELECT username
    FROM v$session
   WHERE audsid = SYS_CONTEXT('USERENV', 'SESSIONID');
   v_username VARCHAR(30);
   
   --cursor per ottenere la quota dello user/tablespace
   CURSOR cursore_per_quota (cp_tbspc VARCHAR2, cp_user VARCHAR2) IS
   SELECT max_bytes
    FROM dba_ts_quotas WHERE tablespace_name = cp_tbspc
    AND username = cp_user;
   v_old_quota NUMBER;
   v_new_quota NUMBER;
   
   --variabili perc onservare informazioni da SPACE_ERROR_INFO
    v_tipo_errore VARCHAR(30);
    v_tipo_oggetto VARCHAR(30);
    v_proprietario_oggetto VARCHAR(30);
    v_tbspc_nome VARCHAR(30);
    v_nome_oggetto VARCHAR(30);
    v_sub-oggetto_nome VARCHAR(30);
    
   --variabile per memorizzare query SQL
   v_sql VARCHAR(1000);
   
BEGIN
  --se esisste un errore relativo allo spazio
  IF ORA_SPACE_ERROR_INFO(error_type => v_tipo_errore,
                          object_type => v_tipo_oggetto,
                          object_owner => v_proprietario_oggetto, 
                          table_space_name => v_tbspc_nome,
                          object_name => v_nome_oggetto,
                          sub_object_name => v_sub-oggetto_name) THEN
                          
  --se l'errore è di un tablespace quota superato
  IF v_tipo_errore = 'SPACE QUOTA EXCEEDED' AND 
     v_tipo_oggetto = 'TABLE SPACE' THEN
     
     --ottieni lo username
     OPEN  cursore_per_username;
     FETCH curs_get_username INTO v_username;
     CLOSE cursore_per_username;
     
     --ottieni la quota attuale
     OPEN cursore_per_quota(v_nome_oggetto, v_username);
     FETCH cursore_per_quota INTO v_old_quota;
     CLOSE cursore_per_quota;
     
     --crea uno statement ALTER USER ed invialo a fixer job. Se lo proviamo qui 
     --partirà l'errore ORA-30511: invalid DDL operation in system trigger
     v_new_quota := v_old_quota + 40960;
     v_sql := 'ALTER USER' || v_username || ' ' ||
              'QUOTA ' || v_new_quota || ' ' ||
              'ON ' || v_nome_oggetto;
     fixer.fix_this(v_sql);
   
   END IF;
   
  END IF;
  
 END;
 /
                          
                         
   
    
