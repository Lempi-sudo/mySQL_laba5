use sakila;

#1. Создать хранимую процедуру, которая возвращает связанные записи нескольких таблиц.
drop procedure if exists film_by_category;

delimiter $$
create procedure film_by_category(in name varchar(25))
comment 'all films with genre'
begin
	select f.title , f.description  from film_category fc
    inner join film f on f.film_id=fc.film_id
    inner join (select c.category_id  from category c where c.name=name) c
    on c.category_id=fc.category_id;
end$$
delimiter ;


#2 Создать функцию, выполняющую конкатенацию нескольких полей таблицы (например, ФИО),
#  вывести результат выполнения функции в запросе дополнительно к полям таблиц.

use factory;

drop function if exists get_FIO_workman;

delimiter $$
create function get_FIO_workman(w_id int)
returns varchar(90)
DETERMINISTIC 
begin 
	declare fio varchar(90) default null;
    select concat(w.name,' ',w.surname,' ',w.patronymic) into fio from workman w
    where w.registration_number=w_id;
    return fio;
end$$
delimiter ;

select w.registration_number, get_FIO_workman(w.registration_number) as FIO,w.birth_date,w.gender from workman w;




# 3. Создать функцию, выполняющую арифметическую операцию над полями таблицы,
# использовать функцию для фильтрации записей в предложении WHERE запроса.
use factory;

drop function if exists experience_year_workman;

delimiter $$
create function experience_year_workman(w_id int)
returns int
DETERMINISTIC 
begin 
	declare experience int default 0;
    select year(current_date())-year(w.start_date) into experience  from workman w
    where w.registration_number=w_id;
    return experience;
end$$
delimiter ;

select *  from workman 
where experience_year_workman(registration_number)=5;


