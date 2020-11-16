#1. Создать хранимую процедуру, которая возвращает связанные записи нескольких таблиц.
use sakila;
drop procedure if exists film_by_category;

delimiter $$
create procedure film_by_category(in arg_name varchar(25))
comment 'all films with genre'
begin
	select f.title ,l.name as language, f.description ,c.name as category from film_category fc
    inner join film f on f.film_id=fc.film_id
    inner join (select c.category_id ,c.name  from category c where c.name=arg_name) c
    on c.category_id=fc.category_id
    inner join language l on l.language_id=f.language_id;
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




#4. Создать функцию, использующую конструкцию 
#   CASE (например, для вывода текстового описания справочника по идентификатору),
#   вывести результат выполнения функции в запросе.
use factory;

drop function if exists information_about_position ;

delimiter $$
create function information_about_position(p_id int)
returns varchar(90)
DETERMINISTIC 
begin 
	declare str varchar(90) default null;
	case p_id
    when 1 then
		set str="Занимает должность President"; 
	when 2 then
		set str="Занимает должность Vice President"; 
	when 3 then
		set str="Занимает должность Master"; 
	when 4 then
		set str="Занимает должность Plant Manager";
	when 5 then
		set str="Занимает должность Trainee"; 
	when 6 then
		set str="Занимает должность Line worker"; 
	when 7 then
		set str="Занимает должность Storekeeper"; 
	when 8 then
		set str="Занимает должность Booker";
	when 9 then
		set str="Занимает должность Secretary"; 
	when 10 then
		set str="Занимает должность Personnel Clerk";
	else 
		set str="НЕТ ДОЛЖНОСТИ ";
	end case;
    return str;
end$$
delimiter ;

select get_FIO_workman(w.registration_number) as FIO , information_about_position(w.id_position) as post from workman w;


