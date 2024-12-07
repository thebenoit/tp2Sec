-- Création des tables

CREATE TABLE Departements (
    id_departement NUMBER(5) PRIMARY KEY,
    nom_departement VARCHAR2(50) NOT NULL,
    localisation VARCHAR2(50)
);
CREATE TABLE Employes (
    id_employe NUMBER(5) PRIMARY KEY,
    nom VARCHAR2(50) NOT NULL,
    prenom VARCHAR2(50) NOT NULL,
    id_departement NUMBER(5),
    salaire NUMBER(10, 2),
    date_embauche DATE,
    FOREIGN KEY (id_departement) REFERENCES Departements(id_departement)
);
CREATE TABLE Projets (
    id_projet NUMBER(5) PRIMARY KEY,
    nom_projet VARCHAR2(100) NOT NULL,
    id_departement NUMBER(5),
    budget NUMBER(15, 2),
    FOREIGN KEY (id_departement) REFERENCES Departements(id_departement)
);

-- Insertion dans les tables 

INSERT INTO Departements VALUES (1, 'Informatique', 'Montréal');
INSERT INTO Departements VALUES (2, 'Marketing', 'Toronto');
INSERT INTO Departements VALUES (3, 'Ressources Humaines', 'Vancouver');
INSERT INTO Departements VALUES (4, 'Finance', 'Québec');
INSERT INTO Employes VALUES (101, 'Dupont', 'Jean', 1, 70000, 
TO_DATE('2020-05-01', 'YYYY-MM-DD'));
INSERT INTO Employes VALUES (102, 'Martin', 'Claire', 2, 60000,
TO_DATE('2019-03-15', 'YYYY-MM-DD'));
INSERT INTO Employes VALUES (103, 'Bernard', 'Luc', 3, 50000, 
TO_DATE('2021-07-10', 'YYYY-MM-DD'));
INSERT INTO Employes VALUES (104, 'Durand', 'Sophie', 4, 75000, 
TO_DATE('2018-01-20', 'YYYY-MM-DD'));

INSERT INTO Projets VALUES (202, 'Campagne Publicitaire', 2, 800000);
INSERT INTO Projets VALUES (203, 'Formation Interne', 3, 50000);
INSERT INTO Projets VALUES (204, 'Audit Financier', 4, 300000);

-- Affichage tables 

SELECT column_name, data_type, nullable, data_length
FROM USER_TAB_COLUMNS
WHERE table_name = 'DEPARTEMENTS';
SELECT column_name, data_type, nullable, data_length
FROM USER_TAB_COLUMNS
WHERE table_name = 'EMPLOYES';
SELECT column_name, data_type, nullable, data_length
FROM USER_TAB_COLUMNS
WHERE table_name = 'PROJETS';

SELECT * FROM Departements;
SELECT * FROM Employes;
SELECT * FROM Projets;


-- Chiffrement de la Table

ALTER TABLE Projets 
ADD (nom_projet_crypt RAW(2000),
     budget_crypt RAW(2000));

GRANT SELECT, UPDATE ON entreprise_admin.Projets TO sys;



