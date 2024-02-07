--CREATTION DE TABLE CHEESES
CREATE TABLE  cheeses (
    id VARCHAR2(20) NOT NULL,
    fromage VARCHAR2(50) NULL,
    family VARCHAR2(50) NULL,
    paste VARCHAR2(50) NULL,
    prix NUMBER(10),
    PRIMARY KEY(id)
);

--CREATTION DE TABLE DATES
CREATE TABLE  dates (
    id VARCHAR2(50) PRIMARY KEY,
    sale_date TEXT NOT NULL
);
--CREATTION DE TABLE SALES
CREATE TABLE  Sales (
    id_sales VARCHAR2(50) PRIMARY KEY,
    quantity INTEGER NOT NULL,
    id VARCHAR2(50) NOT NULL,
    sale_date_id VARCHAR2(50) NOT NULL,
    FOREIGN KEY (id) REFERENCES D_cheeses(id) ON DELETE CASCADE,
    FOREIGN KEY (sale_date_id) REFERENCES sale_dates(id) ON DELETE CASCADE
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
-- INSERTION DES DONNEES DANS LA TABLE CHEESES
INSERT INTO cheeses (id, fromage, family, paste, prix) 
SELECT DISTINCT 
    REPLACE(TRIM(id || fromage || family || paste), ' ', '') AS id_concatenated, 
    fromage, 
    odsfromages.family, 
    paste, 
    price AS prix
FROM ODSFROMAGES;
-- creation de table temporaire vente 
CREATE TABLE ventes (
    cheeses VARCHAR2(50),
    dates DATE,
    quantites NUMBER
);
---- insertion des donnees dans la table ventes
INSERT INTO DATES (DATEID, SALE_DATE) 
SELECT DISTINCT ventes.dates AS DATEID,
TO_DATE(ventes.dates, 'YYYY-MM-DD') AS SALE_DATE
FROM VENTES;

--insertion des cheess INSERT INTO cheeses (fromage, family, paste, prix)
iNSERT INTO cheeses (fromage, family, paste, prix)
SELECT DISTINCT fromage, family, paste,
    TO_NUMBER(price DEFAULT NULL ON CONVERSION ERROR) AS prix
FROM ODSFROMAGES
WHERE price IS NOT NULL AND LENGTH(TRIM(price)) > 0;






