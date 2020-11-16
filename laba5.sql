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

#5 Создать хранимую процедуру, вычисляющую агрегированные
# характеристики записей таблицы (например, минимальное, максимальное и среднее значение некоторых полей)
# и использующую курсор для построчного обхода строк.
use bank;

drop procedure if exists max_spent;

delimiter $$
CREATE  PROCEDURE max_spent(out arg_max int)
begin
    declare done int default false;
	declare tmp, s, c int default 0;
    DECLARE cur1 CURSOR FOR SELECT p.start_money ,p.current_money FROM person p;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur1;
    while not done do
		FETCH cur1 INTO s, c;
		if (s-c)>tmp then
			set tmp=s-c;
		end if;
	end while;
    close cur1;
    select  tmp into arg_max;
end$$
delimiter ;

set @max=0;
call max_spent(@max);
select @max; 




#6. Создать хранимую процедуру,
#    выполняющую задание из п.5 без использования курсора.
use bank;
drop procedure if exists max_spent2;

delimiter $$
create procedure max_spent2()
begin
	select  max(t.spend) as max_spent 
    from (select (p.start_money-p.current_money) as spend from person p) t;
end$$
delimiter ;



 #7. Создать две хранимых процедуры. Обе процедуры должны возвращать строки одной из таблиц по условию,
 #которое указывается в качестве параметра процедуры. Первая процедура должна быть реализована
 #без использования подготовленных запросоа, соответственно вторая – с использованием. 
#Для каждой из процедур выполнить запросы, демонстрирующие стандартное поведение и реализующие SQL инъекцию.

use world;

drop procedure if exists contry1 ;

delimiter //
CREATE PROCEDURE contry1(IN _name varchar(45))
BEGIN
SET @str = concat("SELECT * FROM country c WHERE c.Name = ", _name, ";");
PREPARE stmt FROM @str;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END; //
delimiter ;

drop procedure if exists contry2 ;

delimiter //
CREATE PROCEDURE contry2(IN _name varchar(45))
BEGIN
PREPARE stmt FROM "SELECT * FROM country c WHERE c.Name = ?";
SET @str = _name;
EXECUTE stmt USING @str;
DEALLOCATE PREPARE stmt;
END; //
delimiter ;


CALL contry1("'Afghanistan'");
CALL contry1("'Afghanistan' or '' = ''");

CALL contry2("Afghanistan");
CALL contry2("'Afghanistan' or '' = ''");
