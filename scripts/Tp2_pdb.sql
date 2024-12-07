-- Créez un utilisateur nommé Entreprise_admin et 
-- attribuez-lui les droits nécessaires pour gérer la base de données

CREATE USER Entreprise_admin IDENTIFIED BY oracle;

GRANT CONNECT TO Entreprise_admin;

GRANT RESOURCE TO Entreprise_admin;

GRANT CREATE SESSION TO Entreprise_admin;

GRANT CREATE TABLE TO Entreprise_admin;

GRANT UNLIMITED TABLESPACE TO Entreprise_admin;

-- Activation de l'Audit des Connexions

CREATE AUDIT POLICY Connexion_Audit
ACTIONS LOGON, LOGOFF
WHEN 'SYS_CONTEXT(''USERENV'', ''SESSION_USER'') = ''ENTREPRISE_ADMIN'''
EVALUATE PER SESSION;

AUDIT POLICY Connexion_Audit;

-- Configurez l’audit pour enregistrer les opérations 
CREATE AUDIT POLICY Modification_EMP
    ACTIONS INSERT, UPDATE, DELETE ON Entreprise_admin.Employes;

CREATE AUDIT POLICY Modification_PROJET
    ACTIONS INSERT, UPDATE, DELETE ON Entreprise_admin.Projets;
    
AUDIT POLICY Modification_EMP;
AUDIT POLICY Modification_PROJET;

-- Vérification des Logs d'Audit

SELECT EVENT_TIMESTAMP, DBUSERNAME, ACTION_NAME, USERHOST
FROM UNIFIED_AUDIT_TRAIL
WHERE ACTION_NAME IN ('LOGON', 'LOGOFF')
  AND DBUSERNAME = 'ENTREPRISE_ADMIN'
ORDER BY EVENT_TIMESTAMP DESC;

SELECT EVENT_TIMESTAMP, DBUSERNAME, ACTION_NAME, OBJECT_NAME, SQL_TEXT
FROM UNIFIED_AUDIT_TRAIL
WHERE OBJECT_NAME IN ('EMPLOYES', 'PROJETS')
ORDER BY EVENT_TIMESTAMP DESC;



DECLARE
encryption_key RAW(32);
encrypted_nom_projet RAW(2000);
encrypted_budget RAW(2000);
BEGIN
-- Définir une clé de chiffrement
encryption_key := UTL_RAW.CAST_TO_RAW('12345678123456781234567812345678'); 

-- Parcourir les enregistrements existants
FOR rec IN (SELECT id_projet, nom_projet, budget FROM entreprise_admin.Projets) LOOP
-- Chiffrer le nom du projet
encrypted_nom_projet := DBMS_CRYPTO.ENCRYPT(
src => UTL_I18N.STRING_TO_RAW(rec.nom_projet, 'AL32UTF8'),
typ => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
key => encryption_key
);

-- Chiffrer le budget
encrypted_budget := DBMS_CRYPTO.ENCRYPT(
src => UTL_I18N.STRING_TO_RAW(TO_CHAR(rec.budget), 'AL32UTF8'),
typ => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
key => encryption_key
);

-- Mettre à jour la table avec les données chiffrées
UPDATE entreprise_admin.Projets
SET nom_projet_crypt = encrypted_nom_projet,
budget_crypt = encrypted_budget
WHERE id_projet = rec.id_projet;
END LOOP;

COMMIT;
END;
/


DECLARE
encryption_key RAW(32);
decrypted_nom_projet VARCHAR2(200);
decrypted_budget NUMBER(15, 2);
BEGIN
-- Définir la clé de chiffrement
encryption_key := UTL_RAW.CAST_TO_RAW('12345678123456781234567812345678');

-- Parcourir les enregistrements chiffrés
FOR rec IN (SELECT id_projet, nom_projet_crypt, budget_crypt 
FROM entreprise_admin.Projets 
WHERE nom_projet_crypt IS NOT NULL) LOOP

-- Déchiffrer le nom du projet
decrypted_nom_projet := UTL_RAW.CAST_TO_VARCHAR2(
DBMS_CRYPTO.DECRYPT(
src => rec.nom_projet_crypt,
typ => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
key => encryption_key
)
);

-- Déchiffrer le budget
decrypted_budget := TO_NUMBER(
UTL_RAW.CAST_TO_VARCHAR2(
DBMS_CRYPTO.DECRYPT(
src => rec.budget_crypt,
typ => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
key => encryption_key
)
)
);

-- Afficher les données déchiffrées
DBMS_OUTPUT.PUT_LINE('ID Projet: ' || rec.id_projet || 
', Nom Projet: ' || decrypted_nom_projet || 
', Budget: ' || decrypted_budget);
END LOOP;
END;
/








select TABLESPACE NAME, FILE_NAME from dba_data_files;




