drop table if exists sucursal cascade;
create table sucursal (
	id serial primary key,
	direccion varchar(100) not null
);

drop table if exists categoria cascade;
create table categoria(
	id serial primary key,
	nombre varchar(25) not null
);

drop table if exists pelicula cascade;
create table pelicula (
	id serial primary key,
	genero int not null,
	titulo varchar(100) not null,
	director varchar(100) not null,
	year int not null,
	precio decimal(10,2) not null, -- USD
	foreign key (genero) references categoria(id),
	check(year>1899)
);

drop table if exists disponibilidad;
create table disponibilidad (
	sucursal int not null,
	pelicula int not null,
	foreign key (sucursal) references sucursal(id),
	foreign key (pelicula) references pelicula(id),
	primary key (sucursal, pelicula)
);

drop table if exists cliente cascade;
create table cliente (
	id serial primary key,
	cedula varchar(20) unique not null,
	nombre varchar(100) not null,
	contacto varchar(10) not null, -- celular
	direccion varchar(255) not null,
	check(length(cedula)>6),
	check(length(contacto)=10)
);

drop table if exists alquiler;
create table alquiler (
	cliente int not null,
	pelicula int not null,
	fecha_inicio date not null,
	fecha_fin date not null,
	precio decimal(10,2) not null,
	foreign key (cliente) references cliente(id),
	foreign key (pelicula) references pelicula(id)
);

insert into cliente (cedula, nombre, contacto, direccion) values
	(1097910330, 'Mateo', '3002119990', 'calle 1 #2-3'),
	(1097910331, 'Marcos', '3002119991', 'carrera 1 #2-3'),
	(1097910332, 'Lucas', '3002119992', 'calle 2 #3-4'),
	(1097910333, 'Juan', '3002119993', 'carrera 2 #3-4'),
	(1097910334, 'Hugo', '3002119994', 'calle 3 #4-5'),
	(1097910335, 'Paco', '3002119995', 'carrera 3 #4-5'),
	(1097910336, 'Luis', '3002119996', 'calle 4 #5-6'),
	(1097910337, 'Carlos', '3002119997', 'carrera 4 #5-6'),
	(1097910338, 'Karen', '3002119998', 'calle 5 #6-7'),
	(1097910339, 'Andrés', '3002119999', 'carrera 5 #6-7')
;

insert into categoria (nombre) values
	('Acción'),
	('Comedia'),
	('Drama'),
	('Romance'),
	('Fantasía'),
	('Ciencia Ficción'),
	('Terror'),
	('Documental')
;

insert into pelicula (genero, titulo, director, year, precio) values
	(1, 'Revengers', 'Kevin Fakey', 2012, 2.50),
	(2, 'Son como adultos', 'Adam Sandor', 2014, 3.99),
	(3, 'Sínclave', 'John Doe', 2024, 4.20),
	(4, 'Amor en los tiempos del COVID', 'Gabriel G. Mendez', 1993, 1.50),
	(5, 'Henry Porras y la roca filosófica', 'J.K. Ramírez', 2002, 5.00),
	(6, 'Guerras Espaciales: Episodio I', 'Jorge Lucas', 1981, 5.00),
	(7, 'Choky el muñeco diabólico', 'Jane Doe', 1999, 1.50),
	(8, 'Magia Salvaje', 'Simón Bolivar', 2014, 2.00),
	(1, 'Justice Team', 'Jack Snaider', 2014, 10.00),
	(1, 'Catman VS. Capitanazo', 'Jack Snaider', 2016, 10.50),
	(1, 'AguaMan', 'Jack Snaider', 2018, 10.50),
	(1, 'Wonderful-Woman', 'Jack Snaider', 2019, 11.00),
	(1, 'Escuadrón Homicida', 'Margarita Robbin', 2017, 12.00),
	(1, 'Birds of Grey', 'Margarita Robbin', 2021, 13.00),
	(1, 'El Señor de la Noche', 'Carlos Rueda', 2025, 15.50)
;

insert into alquiler (cliente, pelicula, fecha_inicio, fecha_fin, precio) values
	(8, 15, '2025-05-19', '2025-06-02', 15.50),
	(2, 14, '2025-05-20', '2025-06-03', 13.50),
	(3, 13, '2025-05-21', '2025-06-04', 12.00),
	(4, 12, '2025-05-22', '2025-06-05', 11.00),
	(5, 11, '2025-05-23', '2025-06-06', 10.50),
	(6, 10, '2025-05-24', '2025-06-07', 10.50),
	(7, 9, '2025-05-25', '2025-06-08', 10.00),
	(1, 8, '2025-05-26', '2025-06-09', 2.00),
	(9, 7, '2025-05-27', '2025-06-10', 1.50),
	(10, 6, '2025-05-28', '2025-06-11', 5.00)
;

insert into sucursal (direccion) values
	('avenida 1 #2-3'),
	('diagonal 1 #2-3'),
	('avenida 2 #3-4'),
	('diagonal 2 #3-4'),
	('avenida 3 #4-5')
;

insert into disponibilidad (sucursal, pelicula) values
	(1,15),
	(1,1),
	(2,14),
	(2,2),
	(3,13),
	(3,3),
	(4,12),
	(4,4),
	(5,11),
	(5,5)
;

select s.id as sucursal, SUM(a.precio) as ingresos
from sucursal s
join disponibilidad d on s.id = d.sucursal
join pelicula p on d.pelicula = p.id
join alquiler a on p.id = a.pelicula
where (
	select distinct date_part('month', a2.fecha_inicio) 
	from alquiler a2 
) = '05'
group by s.id
order by sucursal;

select c.id, c.nombre, SUM(a.precio) as total
from cliente c 
join alquiler a on c.id = a.cliente
group by c.id
order by total desc
limit 1;

select c.id, c.nombre, (
	((select count(c2.id) from categoria c2)/(select count(p2.id)from pelicula p2))*100
) as porcentaje
from pelicula p
join categoria c on p.genero = c.id
group by c.id
order by c.id;

select s.id as sucursal, (
	select count(a2.pelicula) 
	from alquiler a2
) as alquileres
from sucursal s
join disponibilidad d on s.id = d.sucursal
join pelicula p on d.pelicula = p.id
join alquiler a on p.id = a.pelicula
order by alquileres desc;


select p.titulo, p.genero, p.precio
from pelicula p
left join alquiler a on p.id = a.pelicula
where a.pelicula is null;

select c.nombre, p.titulo, a.fecha_inicio, a.fecha_fin
from cliente c
join alquiler a on c.id = a.cliente
join pelicula p on a.pelicula = p.id
where c.id = 8;

select p.*
from pelicula p 
join alquiler a on p.id = a.pelicula
where p.precio > 10
order by p.id;

select p.*
from pelicula p
left join alquiler a on p.id = a.pelicula
where p."year" in ('2025', '2024', '2023', '2022', '2021') and a.pelicula is null;
