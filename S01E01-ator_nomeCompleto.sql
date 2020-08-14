/*[ator_nomeCompleto] Exiba o primeiro e o último nome dos 
atores no formato "Sobrenome, Nome".*/

USE sakila;

SELECT concat(a.last_name, ', ', a.first_name) 
  FROM actor a;