
CREATE TABLE cheesess (
    id VARCHAR2(20) NOT NULL,
    fromage VARCHAR2(50) NULL,
    family VARCHAR2(50) NULL,
    paste VARCHAR2(50) NULL,
    prix NUMBER(10),
    PRIMARY KEY(id)
);

-- Create the ventes table with foreign key constraints
CREATE TABLE ventes (
    cheeses VARCHAR2(50),
    vente_date VARCHAR2(50),
    quantites NUMBER,
    PRIMARY KEY (cheeses),
    CONSTRAINT fk_Ventesdate FOREIGN KEY (vente_date) REFERENCES Ventesdate(id),
    CONSTRAINT fk_cheesess FOREIGN KEY (cheeses) REFERENCES cheesess(id)
);

CREATE TABLE sales (
    cheeses VARCHAR2(50),
    vente_date VARCHAR2(50),
    quantites VARCHAR2(5)
    
);


INSERT INTO cheeses (id, fromage, family, paste, prix) 
SELECT DISTINCT id, fromage, FAMILY, PASTE, PRICE
FROM ODSFROMAGES;
SELECT * FROM cheeses;
DELETE FROM cheeses;
TRUNCATE TABLE cheeses;
------------------------------
CREATE TABLE ODSFROMAGES (
   id VARCHAR2(50),
   fromage VARCHAR2(50),
   family VARCHAR2(50),
   paste VARCHAR2(50),
   price VARCHAR2(50),
   "date" VARCHAR2(50),  
   image_filename VARCHAR2(50),
   PRIMARY KEY(id)
);
-- -- INSERTION DES DONNEES DANS LA TABLE CHEESES
-- INSERT INTO cheesess (id, fromage, family, paste, prix) 
-- SELECT DISTINCT 
--     REPLACE(TRIM(id || fromage || family || paste), ' ', '') AS id_concatenated, 
--     fromage, 
--     odsfromages.family, 
--     paste, 
--     price AS prix
-- FROM ODSFROMAGES;
-- -- creation de table temporaire vente 
-- CREATE TABLE ventes (
--     cheeses VARCHAR2(50),
--     dates DATE,
--     quantites NUMBER
-- );
---- insertion des donnees dans la table ventes
-- INSERT INTO DATES (DATEID, SALE_DATE) 
-- SELECT DISTINCT ventes.dates AS DATEID,
-- TO_DATE(ventes.dates, 'YYYY-MM-DD') AS SALE_DATE
-- FROM VENTES;

--insertion des cheess INSERT INTO cheeses (fromage, family, paste, prix)
-- INSERT INTO cheesess (id,fromage, family, paste, prix)
-- SELECT DISTINCT  ODSFROMAGES.FROMAGE , fromage, family, paste,price
    
-- FROM ODSFROMAGES ;
-- joint la table ventes avec la table cheeses puor affriche le prix

--- insertion des donnees dans la table ventes
INSERT INTO ventes (ventes_id, cheeses, vente_date, quantites)
SELECT 
    SYS_GUID() AS vente_id,
    c.family AS cheesess,
    t.vente_date,
    t.quantites 
FROM sales t
JOIN cheesess c ON t.cheeses = c.family;

----- afficher les donnees de la table ventes
SELECT
    v.ventes_id,
    v.cheeses,
    v.vente_date,
    v.quantites

    
FROM
    ventes v
JOIN
    cheesess c ON v.cheeses = c.family
WHERE
    c.prix IS NOT NULL;

SELECT
    v.ventes_id,
    v.cheeses,
    v.vente_date,
    v.quantites,
    c.prix,
    TO_NUMBER(c.prix)* (v.quantites) as Montant
FROM
    ventes v
JOIN
    cheesess c ON v.cheeses = c.family
WHERE
    REGEXP_LIKE(c.prix, '^-?\d+(\.\d+)?$');

----- motant par ventes 

SELECT
   v.ventes_id,
    v.cheeses,
    v.vente_date,
    v.quantites,
    c.prix as prix_unitaire,
    v.quantites * TO_NUMBER(REGEXP_SUBSTR(c.prix, '^-?\d+(\.\d+)?')) AS montant_total
FROM
    ventes v
JOIN
    cheesess c ON v.cheeses = c.family
WHERE
    REGEXP_LIKE(c.prix, '^-?\d+(\.\d+)?$');

------------------------------------------------------------
--v
Le nombre de fromages par famille :
SELECT
    c.family,
    COUNT(c.fromage) AS nombre_de_fromages
FROM
    cheesess c
GROUP BY
    c.family;

--Le jour ayant réalisé le plus de chiffre d'affaires :

 LES 3 FROMAGE LE PLUS VENDU
SELECT
    c.fromage,
    SUM(v.quantites) AS total_quantites_vendues
FROM
    ventes v
JOIN
    cheesess c ON v.cheeses = c.family
GROUP BY
    c.fromage
ORDER BY
    total_quantites_vendues DESC
FETCH FIRST 3 ROWS ONLY;


-- SELECT
--     c.fromage,
--     SUM(v.quantites) AS total_quantites_vendues
-- FROM
--     ventes v
-- JOIN
--     cheesess c ON v.cheeses = c.family
-- GROUP BY
--     c.fromage
-- ORDER BY
--     total_quantites_vendues DESC
-- FETCH FIRST 3 ROWS ONLY;

--Le jour ayant réalisé le plus de chiffre d'affaires :

SELECT
    c.fromage,
    v.vente_date,
    count(TO_NUMBER(v.quantites, '999999999.99') * TO_NUMBER(c.prix, '999999999.99')) AS chiffre_affaires_total
FROM
    ventes v
JOIN
    cheesess c ON v.cheeses = c.family
GROUP BY
    c.fromage, v.vente_date
ORDER BY
    chiffre_affaires_total DESC
FETCH FIRST 1 ROW ONLY;



