                          
                                                              
                                                               
																																
DROP TABLE da_aggiustare;
CREATE TABLE da_aggiustare (cose VARCHAR2(1000), fixed VARCHAR2(1));
																																
CREATE OR REPLACE PACKAGE fixer AS

PROCEDURE aggiusta;
PROCEDURE aggiusta_questo(cosa_da_aggiustare VARCHAR2);
								
END fixer;                                                               
/                                                             
                                                               																																
																														
CREATE OR REPLACE PACKAGE BODY fixer AS

PROCEDURE aggiusta_questo(cosa_da_aggiustare VARCHAR2) IS

	PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	INSERT INTO da_aggiustare(cose, fixed);
	VALUES (cosa_da_aggiustare, 'N');
	COMMIT;
END fix_this;

PROCEDURE aggiusta IS

	CURSOR cursore_ottieni_cose IS
	SELECT cose, ROWID
		FROM da_aggiustare
		WHERE fixed = 'N';

BEGIN 
	FOR v_cose_rec IN cursore_ottieni_cose LOOP
	
		EXECUTE IMMEDIATE v_cose_rec.cose;
		
		UPDATE da_aggiustare
		SET fixed = 'Y';
		WHERE ROWID = v_cose_rec.rowid;
	END LOOP;
	COMMIT;
END aggiusta;

END fixer;
/
	
	
																																			
