-- Création PDB dans le cdb
CREATE PLUGGABLE DATABASE Entreprise_db  ADMIN USER pdb_adm  IDENTIFIED BY oracle
FILE_NAME_CONVERT=('/opt/oracle/oradata/FREE/pdbseed/','/opt/oracle/oradata/FREE/pdb1/');

-- Vérification de la commande
SELECT pdb_name, status FROM dba_pdbs ORDER BY pdb_name;
-- Vérification du mode 
SELECT name, open_mode FROM v$pdbs ORDER BY name;

-- Créez la clé principale pour le chiffrement
ALTER SYSTEM SET ENCRYPTION KEY IDENTIFIED BY "oracle";

-- Vérifiez que le Wallet est ouvert
SELECT * FROM V$ENCRYPTION_WALLET;

-- Étape 3 : Chiffrer les tablespaces existants
-- Remplacez les chemins et noms des fichiers par ceux de votre environnement

ALTER TABLESPACE system ENCRYPTION ONLINE USING 'AES256' ENCRYPT 
FILE_NAME_CONVERT=('/opt/oracle/oradata/FREE/system01.dbf',
'/opt/oracle/oradata/FREE/system01_enc.dbf');

ALTER TABLESPACE sysaux ENCRYPTION ONLINE USING 'AES256' ENCRYPT 
FILE_NAME_CONVERT=('/opt/oracle/oradata/FREE/sysaux01.dbf', 
'/opt/oracle/oradata/FREE/sysaux01_enc.dbf');

ALTER TABLESPACE undotbs1 ENCRYPTION ONLINE USING 'AES256' ENCRYPT 
FILE_NAME_CONVERT=('/opt/oracle/oradata/FREE/undotbs1.dbf', 
'/opt/oracle/oradata/FREE/undotbs1_enc.dbf');

ALTER TABLESPACE users ENCRYPTION ONLINE USING 'AES256' ENCRYPT 
FILE_NAME_CONVERT=('/opt/oracle/oradata/FREE/users01.dbf',
'/opt/oracle/oradata/FREE/users01_enc.dbf');


