--CREATTION DE TABLE CHEESES
CREATE TABLE IF NOT EXISTS cheeses (
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
    FOREIGN KEY (sale_date_id) REFERENCES D_sale_dates(id) ON DELETE CASCADE
);

INSERT INTO cheeses (id, fromage, family, paste, prix) 
SELECT DISTINCT id, fromage, FAMILY, PASTE, PRICE
FROM ODSFROMAGES;
SELECT * FROM cheeses;
DELETE FROM cheeses;
TRUNCATE TABLE cheeses;
------------------------------
-- INSERTION DES DONNEES DANS LA TABLE CHEESES
INSERT INTO cheeses (id, fromage, family, paste, prix) 
SELECT DISTINCT 
    REPLACE(TRIM(id || fromage || family || paste), ' ', '') AS id_concatenated, 
    fromage, 
    odsfromages.family, 
    paste, 
    price AS prix
FROM ODSFROMAGES;
