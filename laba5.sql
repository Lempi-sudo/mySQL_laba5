use sakila;

#1. Создать хранимую процедуру, которая возвращает связанные записи нескольких таблиц.
drop procedure if exists film_by_category;

delimiter $$
create procedure film_by_category(in name varchar(25) )
comment 'all films with genre'
begin
	select f.title , f.description  from film_category fc
    inner join film f on f.film_id=fc.film_id
    inner join (select c.category_id from category c where c.name=name) c
    on c.category_id=fc.category_id;
end$$
delimiter ;