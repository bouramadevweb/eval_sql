# Entrepôt de Données pour La Boite du Fromager

## Introduction

Pour répondre aux besoins de l'entreprise "La Boite du Fromager", un entrepôt de données a été créé pour consolider les données dimensionnelles du site web de l'entreprise et les données transactionnelles provenant du csv. L'objectif est d'optimiser l'analyse des ventes de fromages et de faciliter l'accès aux informations essentielles.

## Schéma de la Base de Données

L'entrepôt de données comprend deux principales sources de données :
- **Données Dimensionnelles (Site Web)** : Ces données incluent des informations sur les fromages, comme la famille, la texture, le prix, etc.
- **Données Transactionnelles en CSV ** : Ces données contiennent des détails sur les ventes, telles que la quantité vendue, le chiffre d'affaires réalisé, la date de vente, etc.

## Fonctionnalités de l'Application Tkinter

L'application Tkinter a été développée pour permettre aux utilisateurs d'obtenir rapidement des informations clés sur les ventes de fromages. Voici quelques fonctionnalités principales :

### Les Trois Fromages les Plus Vendus

Affichez les trois fromages qui ont réalisé le plus de ventes.

### Le Jour avec le Plus de Chiffre d'Affaires

Identifiez le jour qui a généré le chiffre d'affaires le plus élevé.

### Nombre de Fromages par Famille

Fournissez le nombre de fromages disponibles dans chaque famille.

## Exemple de Requêtes SQL

Pour atteindre ces objectifs, l'application utilise des requêtes SQL. Par exemple :

### Les Trois Fromages les Plus Vendus

```sql
SELECT fromage, SUM(quantity) AS total_sales
FROM F_sales
JOIN D_cheeses ON F_sales.cheese_id = D_cheeses.id
GROUP BY fromage
ORDER BY total_sales DESC
LIMIT 3;
