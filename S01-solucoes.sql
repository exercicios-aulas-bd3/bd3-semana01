/*Parcial dos exercícios de revisão - 20/08/2020*/

USE sakila;

/*[ator_nomeCompleto] Exiba o primeiro e o último nome dos atores no formato "Sobrenome, Nome".*/
# -- https://dev.mysql.com/doc/refman/8.0/en/string-functions.html#function_concat
SELECT CONCAT(a.last_name, ', ', a.first_name) 
  FROM actor a;

/*[ator_nomeCompletoUpper] Exiba o primeiro e o último nome dos atores no formato "NOME SOBRENOME", em caixa alta. O nome da coluna deverá ser Nome do Ator*/  
# -- https://dev.mysql.com/doc/refman/8.0/en/string-functions.html#function_upper
SELECT UPPER(CONCAT(a.first_name, ' ', a.first_name)) as "Nome do Ator"
  FROM actor a;
  
/*[ator_primeiroNome_Joe] Busque o ID, primeiro e último nome de um ator, cujo primeiro nome é Joe.*/  
# -- https://dev.mysql.com/doc/refman/8.0/en/select.html
SELECT a.actor_id
     , a.first_name
     , a.last_name
 FROM actor a
WHERE a.first_name = 'Joe';

/*[ator_nome_gen] Exiba todos os atores cujo último nome contenham GEN.*/  
# -- https://dev.mysql.com/doc/refman/8.0/en/string-comparison-functions.html#operator_like
SELECT a.actor_id
     , a.first_name
     , a.last_name
 FROM actor a
WHERE a.last_name LIKE '%GEN%';
# % - todo e qualquer caracter entre
# _ - único caracter na cadeia

/*[ator_nome_li_ordenado] Exiba todos os atores cujo último nome contenham LI. Ordene o resultado pelo último nome
, de forma ascendente e pelo primeiro nome, de forma descendente.*/
  SELECT a.actor_id
	   , a.first_name
	   , a.last_name
    FROM actor a
   WHERE a.last_name LIKE '%LI%'
ORDER BY a.last_name ASC
       , a.first_name DESC;
       
/*[pais_especificos_in] Utilizando a cláusula IN, exiba os campos country_id e country dos seguintes 
países: Brazil, Chile, Moldova e Saudi Arabia.*/
SELECT c.country_id,
       c.country 
  FROM country c
WHERE c.country IN ('Brazil', 'Chile', 'Moldova', 'Saudi Arabia');

/*[ator_nome_do_meio] Adicione a coluna middle_name (nome do meio) para a tabela de atores. Estruturalmente, 
ela deve estar localizada entre as colunas first_name e last_name. Fica ao seu critério definir o tipo de dados da nova coluna.*/

ALTER TABLE actor
ADD COLUMN middle_name varchar(20)
AFTER first_name;

#verificar resultado
SELECT * FROM actor;

/*[ator_nome_do_meio_o_retorno] Nomes do meio costumam ser grandes, os atores exageram muito! Altere o tipo de dados da coluna middle_name para o tipo blob.*/
ALTER TABLE actor
MODIFY COLUMN middle_name blob;

SELECT * FROM actor;

/*[ator_nome_do_meio_o_fim] Remova a coluna middle_name da tabela de atores.*/
ALTER TABLE actor
DROP COLUMN middle_name;

SELECT * FROM actor;

/*[ator_quanto_sobrenome] Liste todos os sobrenomes dos atores e a quantidade de atores que tenha determinado sobrenome.*/
  SELECT a.last_name,
         COUNT(a.last_name) quantity
    FROM actor a
GROUP BY a.last_name
ORDER BY quantity DESC;

/*[ator_quantidade_unica] Escreva uma query que determine a quantidade de sobrenomes distintos na tabela de atores.*/
# -- https://dev.mysql.com/doc/refman/8.0/en/aggregate-functions.html#function_count-distinct
SELECT COUNT(DISTINCT a.last_name)
  FROM actor a;

/*[ator_quantidade_aparicoes] Qual o ator que apareceu em mais filmes? Escreva uma query que demonstre 
a quantidade de aparições dos atores dos filmes em ordem decrescente, pela quantidade. Não exiba os atores que tiveram zero aparições.*/
SELECT CONCAT (a.first_name, ' ', a.last_name) full_name
     , COUNT(*) quantity
  FROM actor a
INNER JOIN film_actor fa
       ON fa.actor_id = a.actor_id
GROUP BY full_name
HAVING quantity > 0;

/*[filme_disponibilidade_loja] O filme ARMAGEDDON LOST está disponível para locação na loja 1? Escreva uma query que demonstre isso.*/
#Opção 1a - Quais são as cópias
SELECT f.film_id
     , f.title
     , s.store_id
     , i.inventory_id
  FROM inventory i
  JOIN store s using (store_id) 
  JOIN film f using (film_id)
 WHERE f.title = 'ARMAGEDDON LOST' 
   AND s.store_id = 1;
#Opção 1b - Quais são as cópias
SELECT COUNT(1) 
  FROM inventory i
WHERE i.store_id = 1
  AND i.film_id IN 
(SELECT f.film_id 
   FROM film f
  WHERE f.title = 'ARMAGEDDON LOST');

#Parte 2 - Como selecionar um id para alugar
SELECT i.inventory_id
  FROM inventory i 
  JOIN store s using (store_id)
  JOIN film f using (film_id)
 WHERE f.title = 'ARMAGEDDON LOST'
   AND s.store_id = 1
   AND NOT EXISTS (SELECT r.rental_id 
                     FROM rental r
					WHERE r.inventory_id = i.inventory_id
                      AND r.return_date IS NULL);

/*[aluguel_filme] Crie uma query que insira um novo registro que indique a locação do filme ARMAGEDDON LOST, do vendedor Mike Hillyer na loja 1 com a data atual do sistema.*/
INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
					VALUES (NOW(), 174, 1, 1);
/*[aluguel_filme_vencimento] Crie uma query que exiba a data de devolução do aluguel do exercício anterior.*/
#passo 1 - buscar a duração do aluguel do filme 
SELECT f.rental_duration 
  FROM film f 
 WHERE f.title = 'ARMAGEDDON LOST';

  SELECT r.rental_id
	FROM rental r
ORDER BY rental_id DESC LIMIT 1;

SELECT r.rental_date,
       r.rental_date + INTERVAL (SELECT f.rental_duration 
                                   FROM film f 
								  WHERE f.film_id = 1) DAY
								 AS due_date
  FROM rental r
 WHERE rental_id = (SELECT r.rental_id 
                      FROM rental order by rental_id desc limit 1);

/*[filme_media_reproducao] Qual a média de tempo de exibição dos filmes que estão catalogados no Sakila DB? Escreva uma query que mostre isso.*/
SELECT AVG(f.length) 
  FROM film f;

/*[filme_media_reproducao_categoria] Qual a média de tempo de exibição dos filmes que estão catalogados no Sakila DB, agrupados por categoria? 
Escreva uma query que mostre isso.*/
SELECT AVG(f.length)
 , c.name
  FROM film f, film_category fc, category c
WHERE f.film_id = fc.film_id and c.category_id = fc.category_id
GROUP BY c.name;

/*[vendas_por_funcionario_mensal] Escreva uma query que demonstre o total de vendas para cada um dos funcionários em Agosto de 2005. 
Utilize as tabelas staff e payment.*/
SELECT * FROM staff, payment;
SELECT CONCAT(s.first_name, ' ' , s.last_name)
	 , SUM(p.amount)
  FROM staff s,
       payment p
 WHERE p.staff_id = s.staff_id;
/*[vendas_por_cliente_ordenado] Escreva uma query que liste o total pago por cada cliente, em ordem alfabética. 
Utilize as tabelas customer e payment.*/

[vendas_por_loja] Escreva uma query que mostre o total faturado por loja, em dólarespago por cada cliente, em ordem alfabética. Utilize as tabelas store, staff e payment.

[categoria_familia] Queremos fazer uma campanha para as famílias. Escreva uma query que identifique todos os filmes categorizados como familiares.

/*[vendas_por_cliente_ordenado] Escreva uma query que liste o total pago por cada cliente, em ordem alfabética. Utilize as tabelas customer e payment.*/ 
/*
-- SUM: https://dev.mysql.com/doc/refman/8.0/en/aggregate-functions.html#function_sum
-- GROUP BY: 
   https://dev.mysql.com/doc/refman/8.0/en/aggregate-functions-and-modifiers.html
   https://dev.mysql.com/doc/refman/8.0/en/group-by-modifiers.html
   https://dev.mysql.com/doc/refman/8.0/en/group-by-handling.html
*/ 
SELECT c.first_name
     , c.last_name 
     , SUM(p.amount)
  FROM customer c
     , payment p
 WHERE p.customer_id = c.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY c.first_name;

/*[filmes_mais_alugados] Escreva uma query que demonstre os filmes mais alugados 
em ordem decrescente da frequência.*/  
/*
-- COUNT: https://dev.mysql.com/doc/refman/8.0/en/aggregate-functions.html#function_count
-- JOIN / INNER JOIN: https://dev.mysql.com/doc/refman/8.0/en/join.html
*/ 
	SELECT COUNT(r.rental_id) frequencia
		 , f.title
	  FROM film f
#INNER JOIN inventory i using (film_id)
#INNER JOIN rental r using (inventory_id)
INNER JOIN inventory i 
	    ON i.film_id = f.film_id
INNER JOIN rental r
	    ON r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY frequencia DESC;