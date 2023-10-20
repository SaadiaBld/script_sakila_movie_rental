--requête test simple
SELECT *
FROM  actor;

--requete test simple
SELECT first_name
FROM actor;

--requete test
SELECT first_name, last_name
from actor

--liste titres films
SELECT title
FROM film 

--Nombre de films par catégorie
SELECT name, COUNT(*) as nombre_films
FROM category as cat, film_category as film_cat
WHERE cat.category_id = film_cat.category_id 
GROUP BY name 

--Liste films durée >120min
SELECT title , length
FROM film 
WHERE length > 120

--Liste films sortis entre 2004 et 2006
SELECT title, release_year
FROM film 
WHERE release_year BETWEEN "2004" and "2006"  --obligé de mettre des ""

--liste de films action ou comedy
SELECT title, cat.name 
FROM film as f, category as cat, film_category as fc
WHERE cat.category_id = fc.category_id  and f.film_id = fc.film_id  and (cat.name = "Comedy" or cat.name = "Action")

--liste de films action ou comedy
SELECT title, cat.name 
FROM film as f
JOIN category as cat ON cat.category_id = fc.category_id  
JOIN film_category as fc ON f.film_id = fc.film_id  
WHERE cat.name = "Comedy" or cat.name = "Action"

--Liste des différentes années de sortie des films
SELECT DISTINCT release_year
FROM film 

--nombre total de films
SELECT COUNT(*) as nombre_de_films
FROM film as f

--notes moyennes par categorie
SELECT c.name, AVG(rental_rate) 
FROM film_category fc 
join film f 
ON f.film_id = fc.film_id 
join category c 
on c.category_id = fc.category_id 
group by c.name 

--liste des 10 films les plus loués
SELECT f.title, COUNT(r.rental_date) as total_rent
FROM film f 
join inventory i 
ON f.film_id = i.film_id 
JOIN rental r 
ON r.inventory_id = i.inventory_id 
group by f.title 
ORDER BY total_rent DESC 
LIMIT 10

--acteurs ayant joué dans le plus grand nombre de films
SELECT a.first_name, a.last_name, COUNT(*) as nb_fois_acteur
FROM actor a 
Join film_actor fa 
On a.actor_id = fa.actor_id 
GROUP by a.actor_id  
ORDER BY nb_fois_acteur DESC 
LIMIT 10

---revenu total généré par mois par toutes les locations
SELECT STRFTIME("%Y-%m", payment_date) as mois, SUM(amount)  
FROM payment p 
GROUP BY mois

--revenu total généré par chaque magasin par mois pour l'année 2005
SELECT store_id, STRFTIME("%Y-%m", payment_date) as mois_compte, SUM(amount) 
FROM payment p 
JOIN staff s 
ON s.staff_id =p.staff_id 
--WHERE payment_date LIKE 
GROUP BY store_id, mois_compte
HAVING mois_compte like "%2005%"

---Clients les plus fidèles basés sur nombre de locations
SELECT r.customer_id, COUNT (*) as nb_locations
FROM customer c 
JOIN rental r 
ON c.customer_id = r.customer_id 
GROUP BY r.customer_id 
ORDER BY nb_locations DESC


--Films qui n'ont pas été loués au cours des 6 derniers mois. (LEFT JOIN, WHERE, DATE functions, Sub-query)
---on definit notre periode date max - 6mois
WITH datelimite AS (
SELECT DATE_SUB(SELECT MAX(rental_date) FROM rental), INTERVAL 6 MONTH) as datedebut)

SELECT f.title, r.rental_date
FROM rental r  
JOIN inventory i 
ON r.inventory_id = i.inventory_id 
RIGHT JOIN film f
ON i.film_id = f.film_id 
WHERE r.rental_date is null 
AND r.rental_date > (SELECT datedebut FROM datelimite);



--Le revenu total de chaque membre du personnel à partir des locations. (JOIN, GROUP BY, ORDER BY, SUM)
SELECT s.staff_id, SUM (amount) as total
FROM staff s 
LEFT JOIN payment p 
ON s.staff_id = p.staff_id 
GROUP BY s.staff_id 
ORDER BY total DESC



--Catégories de films les plus populaires parmi les clients. (JOIN, GROUP BY, ORDER BY, LIMIT)
SELECT c.category_id, c.name, COUNT(r.rental_id) as nb_location
FROM rental r 
JOIN inventory i 
ON r.inventory_id = i.inventory_id 
JOIN film f 
ON i.film_id = f.film_id 
JOIN film_category fc 
ON fc.film_id = f.film_id 
JOIN category c 
ON c.category_id = fc.category_id 
GROUP BY c.category_id 
ORDER BY nb_location DESC

--Durée moyenne entre la location d'un film et son retour. (SELECT, AVG, DATE functions)
SELECT AVG(JULIANDAY(return_date) - JULIANDAY(rental_date)) as duree_moy(jours)
FROM rental r 

--Acteurs qui ont joué ensemble dans le plus grand nombre de films. Afficher l'acteur 1, l'acteur 2 et le nombre de films en commun. 
--Trier les résultats par ordre décroissant. Attention aux répétitons. (JOIN, GROUP BY, ORDER BY, Self-join)
SELECT e1.actor_id AS acteur_1, e2.actor_id AS acteur_2, COUNT(DISTINCT e1.film_id) AS nb_film
FROM film_actor e1
JOIN film_actor e2 ON e1.film_id = e2.film_id
WHERE e1.actor_id < e2.actor_id
GROUP BY acteur_1, acteur_2
ORDER BY nb_film DESC 

--Clients qui ont loué des films mais n'ont pas fait au moins une location dans les 30 jours qui suivent. 
--(JOIN, WHERE, DATE functions, Sub-query)

SELECT r1.customer_id 
FROM rental r1
JOIN rental r2
ON  r2.customer_id <> r1.customer_id
WHERE CAST(JULIANDAY(r2.return_date) - JULIANDAY(r1.rental_date) as Integer) < 30
--r1.customer_id < r2.customer_id



-- on veut prendre un customer dans la table rental et vérifier qu'il y a au moins 1 location dans les 30 jours qui suivent
-- = on élimine tous les customers qui ont loué 1 fois et n'ont pas loué entre date 1 et date 2

--SELECT r1.customer_id  
--FROM rental r1
--EXCEPT 
--SELECT r2.customer_id  FROM rental r2 WHERE JULIANDAY(r2.return_date) - JULIANDAY(r2.rental_date) > 30


--Refaire la même question pour un intervalle de 15 jours pour le mois d'août 2005.
SELECT r1.customer_id 
FROM rental r1
JOIN rental r2
ON  r2.customer_id <> r1.customer_id
WHERE JULIANDAY(r2.rental_date) - JULIANDAY(r1.rental_date) < 15 
AND strftime('%Y', r1.rental_date) = '2005'
AND strftime('%m', r1.rental_date) = '08'
AND strftime('%Y', r2.rental_date) = '2005'
AND strftime('%m', r2.rental_date) = '08';

--la fonction strftime pour extraire l'année (%Y) et le mois (%m) des dates de location (rental_date) 
--et de retour (return_date). Ensuite, nous vérifions si l'année est égale à 2005 et si le mois est égal à 08 (août) pour les deux dates.


--Ajoutez un nouveau film dans la base de données. Ce film est intitulé "Sunset Odyssey", est sorti en 2023, dure 125 minutes e
--t appartient à la catégorie "Drama".

INSERT INTO film
(film_id, title, language_id, release_year, length, last_update) VALUES ('1001','Sunset Odyssey', '1', '2023', '125', (SELECT date('now')))

UPDATE film 
SET 
length = '52',
release_year = "2005"
WHERE film_id = 1000

--Mettez à jour le film intitulé "Sunset Odyssey" pour qu'il appartienne à la catégorie "Adventure".
INSERT INTO category 
(category_id, name, last_update) VALUES  ('17', 'Adventure', (SELECT date('now')))

INSERT INTO film_category 
(film_id, category_id, last_update) VALUES ('1001', '17', (SELECT date('now')))


