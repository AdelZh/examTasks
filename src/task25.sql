create type gender as enum(
	'Female',
	'Male'
);


create type marital_status as enum(
	'Divorced',
	'Married',
	'Single'
);


create type house_type as enum(
	'Apartment',
	'House'
);


create table owners(
                       id serial primary key,
                       first_name varchar,
                       last_name varchar,
                       email varchar unique,
                       date_of_birth timestamp,
                       Gender gender);

create table address(
                        id serial primary key,
                        city varchar,
                        region varchar,
                        street varchar);



create table customers(
                          id serial primary key,
                          first_name varchar,
                          last_name varchar,
                          email varchar unique,
                          date_of_birth date,
                          Gender gender,
                          nationality varchar,
                          Marital_status marital_status);




create table houses(
                       id serial primary key,
                       House_type house_type,
                       price numeric,
                       rating int,
                       description text,
                       room int,
                       furniture boolean,
                       address_id integer references address(id),
                       owners_id integer references owners(id));



create table agencies(
                         id serial primary key,
                         name varchar not null,
                         address_id integer references address(id),
                         phone_number varchar);




create table rent_info(
                          id serial primary key,
                          owners_id integer references owners(id),
                          customer_id integer references customers(id),
                          agency_id integer references agencies(id),
                          house_id integer references houses(id),
                          check_in date,
                          check_out date);


--1
SELECT
    CASE
        WHEN price BETWEEN 1500 AND 2000 THEN 'true'
        ELSE 'false'
        END AS price_range
FROM houses;



--3
SELECT
    address,
    CASE
        WHEN id IN (5, 6, 7, 8, 9, 10) THEN 'Yes'
        ELSE 'Absent'
        END AS houses
FROM address;



--4
SELECT
    concat(o.first_name, ' ', o.last_name) AS owner_name,
    h.description AS house_name,
    concat(a.name, ' - ', c.first_name, ' ', c.last_name) AS agency_customer_name
FROM
    houses h
        INNER JOIN
    owners o ON h.owners_id = o.id
        INNER JOIN
    agencies a ON h.address_id = a.id
        INNER JOIN
    rent_info r ON h.id = r.house_id
        INNER JOIN
    customers c ON r.customer_id = c.id;


--5
SELECT * FROM customers
WHERE date_of_birth > '1988-06-13'
    LIMIT 15;

--6
SELECT * FROM houses
ORDER BY rating ASC;


SELECT * FROM houses
ORDER BY rating DESC;

--7
SELECT
    COUNT(h.id) AS apartment_count,
    SUM(h.price) AS total_apartment_price
FROM
    houses h
        JOIN
    rent_info r ON h.id = r.house_id
WHERE
        h.House_type = 'Apartment';


--7
SELECT
    COUNT(h.house_type) AS apartment_count,
    SUM(h.price) AS total_apartment_price
FROM
    houses h
group by h.house_type

--8
SELECT
    a.name AS agency_name,
    adr.city AS agency_city,
    adr.region AS agency_region,
    adr.street AS agency_street,
    h.*
FROM
    agencies a
        INNER JOIN
    address adr ON a.address_id = adr.id
        INNER JOIN
    houses h ON a.id = h.address_id
WHERE
        a.name = 'My House';


--9
SELECT
    h.price AS house_price,
    h.rating AS house_rating,
    h.description AS house_description,
    adr.city AS house_city,
    adr.region AS house_region,
    adr.street AS house_street,
    o.first_name AS owner_first_name,
    o.last_name AS owner_last_name
FROM
    houses h
        INNER JOIN
    address adr ON h.address_id = adr.id
        INNER JOIN
    owners o ON h.owners_id = o.id
WHERE
        h.furniture = true;



--10
SELECT
    h.id AS house_id,
    h.House_type,
    h.price,
    h.rating,
    h.description,
    h.room,
    h.furniture,
    a.city AS house_city,
    a.region AS house_region,
    a.street AS house_street,
    ag.name AS agency_name
FROM
    houses h
        inner JOIN
    address a ON h.address_id = a.id
        inner JOIN
    agencies ag ON h.owners_id = ag.id
WHERE
        h.id NOT IN (SELECT DISTINCT house_id FROM rent_info);




--11
select nationality, count(*) as count from customers group by nationality


--12
select min(rating), max(rating), avg(rating) limit 3 from houses


--13
-- Houses without customers
SELECT h.*
FROM houses h
         LEFT JOIN rent_info r ON h.id = r.house_id
WHERE r.customer_id IS NULL;

-- Customers without houses
SELECT c.*
FROM customers c
         LEFT JOIN rent_info r ON c.id = r.customer_id
WHERE r.house_id IS NULL;

--14
SELECT AVG(price) AS average_house_price
FROM houses;


--15
SELECT o.first_name AS owner_first_name, c.first_name AS customer_first_name
FROM owners o
         JOIN houses h ON o.id = h.owners_id
         LEFT JOIN rent_info r ON h.id = r.house_id
         JOIN customers c ON r.customer_id = c.id
WHERE o.first_name like 'A%';

--16
SELECT o.first_name, MAX(house_id) as max_houses_rented
FROM owners o
         INNER JOIN rent_info r ON o.id = r.owners_id
GROUP BY o.first_name
ORDER BY max_houses_rented desc limit 1;

--17
select * from customers where  nationality='Kyrgyz' and marital_status='Married'

--18
select o.first_name,a.city, a.region, a.street, max(room) as room_count
from owners o
         inner join houses h on o.id=h.owners_id
         inner join address a on a.id=h.address_id
group by  o.first_name, a.city, a.region, a.street
order by room_count desc limit 1

--19
select a.city, c.first_name, h.House_type, h.description
from address a
         inner join houses h on a.id=h.address_id
         inner join rent_info r on h.id=r.house_id
         inner join customers c on c.id=r.customer_id
where a.city='Bishkek'


--20
SELECT gender, COUNT(*) AS gender_count
FROM customers
GROUP BY gender;

--22
select h.description as home_description, o.first_name as owner_name, max(h.price) as max_price
from owners o
         inner join houses h on o.id=h.owners_id
group by h.description, o.first_name
order by max_price desc limit 1


--23
select an.name, a.region
from agencies an
         inner join address a on a.id=an.address_id
where a.region='Asanbai';


--24
select * from houses order by rating desc limit 5


--25
select AVG(EXTRACT(YEAR FROM AGE(o.date_of_birth))) AS avg_owner_age, o.first_name, h.description, a.region
from owners o
         inner join rent_info r on o.id=r.owners_id
         inner join houses h on h.id=r.house_id
         inner join address a on a.id=h.address_id
group by o.first_name, h.description, a.region































