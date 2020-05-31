CREATE OR REPLACE TRIGGER dopo_sospensione
AFTER SUSPEND
ON DATABASE
DECLARE

  CURSOR cursore_per_username IS
  SELECT username
    FROM v$session
   WHERE audsid = SYS_CONTEXT('USEREN
