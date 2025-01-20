-- NIVEL 1 

/* Utilitzant JOIN realitzaràs les següents consultes */

-- 1. Llistat dels països que estan fent compres.

select distinct company.country as Países_Que_Compran
from transaction
inner join company on transaction.company_id = company.id;

-- (Decidí incluir todas las transacciones, así hayan sido declinadas o no) 

 -- 2. Des de quants països es realitzen les compres.

select count(distinct company.country) as Número_de_Países_Donde_Compran
from company 
inner join transaction on company.id = transaction.company_id;

-- 3. Identifica la companyia amb la mitjana més gran de vendes.
 
select company.company_name, AVG(transaction.amount) 
from company 
join transaction on company.id = transaction.company_id
where declined = 0 
group by company.company_name
order by 2 desc
limit 1;

/* Utilitzant només subconsultes (sense utilitzar JOIN): */

-- 1. Mostra totes les transaccions realitzades per empreses d'Alemanya.

select transaction.id
from transaction 
where transaction.company_id in (
	select company.id
    from company
    where company.country = "Germany");
    
-- 2. Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
 
select distinct company.company_name
from company
where company.id in (
	select transaction.company_id
    from transaction
	where transaction.declined = 0 and transaction.amount > (
		select avg(transaction.amount)
		from transaction
        where transaction.declined = 0
	)    
);

-- (Decidí quitar todas las transacciones declinadas)

-- 3. Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.

/* 
select company.company_name
from company
where company.id not in (
	select distinct transaction.company_id
    from transaction);
    
NO HAY NINGUNA EMPRESA SIN TRANSACIONES.*/

SET SQL_SAFE_UPDATES = 0;   

/* I want to update every row in the table, so I'm disabling safe mode.
I would have to run it every time I log in. */

delete from company
where company.id not in (
	select distinct transaction.company_id
    from transaction);
 
-- Otra opción:

delete from company
where not exists 
	(select transaction.company_id
	from transaction);


-- NIVEL 2 

-- Exercici 1

/* Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
Mostra la data de cada transacció juntament amb el total de les vendes. */

select date(transaction.timestamp), SUM(transaction.amount)
from transaction
where declined = 0
group by 1
order by 2 desc
limit 5;

    
-- Exercici 2 

-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

select company.country, avg(transaction.amount)  
from company 
inner join transaction on company.id = transaction.company_id
where declined = 0
group by 1
order by 2 desc;


-- Exercici 3 

/*
En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". 
Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
*/

-- Usando join y subqueries.

-- A. No inlucyo las transacciones declinadas. 

select *
from transaction
inner join company on company.id = transaction.company_id
where company.company_name <> "Non Institute" and transaction.declined = "0" and company.country = 
	(select country
	from company
	where company_name = "Non Institute");
        
-- B. Incluyo las transacciones declinadas.

select *
from transaction
inner join company on company.id = transaction.company_id
where company.company_name <> "Non Institute" and company.country = 
	(select country
	from company
	where company_name = "Non Institute");
    
-- Solo usando subqueries

-- A. No incluyo las transacciones declinadas. 

select *
from transaction
where transaction.declined = "0" and transaction.company_id in (
	select company.id
	from company 
	where company.company_name <> "Non Institute" and company.country = (
		select company.country
		from company
		where company_name = "Non Institute"
        )
);

-- B. Incluyo las transacciones declinadas.
 
select *
from transaction
where transaction.company_id in (
	select company.id
	from company 
	where company.company_name <> "Non Institute" and company.country = (
		select company.country
		from company
		where company_name = "Non Institute"
        )
);

-- Exercici 1

/* 
Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que 
van realitzar transaccions amb un valor comprès entre 100 i 200 euros 
i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. 
Ordena els resultats de major a menor quantitat.
*/

select company.company_name, company.phone, company.country, date(transaction.timestamp), transaction.amount
from company
inner join transaction on company.id = transaction.company_id 
where date(transaction.timestamp) in ("2021-04-29", "2021-07-20", "2022-03-13") and transaction.amount between 100 and 200
order by 5 desc;  

-- Exercici 2
/* 
Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
però el departament de recursos humans és exigent 
i vol un llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.
*/

-- A. Incluyo las transacciones declinadas. 

select company.company_name, count(transaction.id),
case 
	when count(transaction.id) > 4 then "Más de cuatro transacciones"
	else "Cuatro o menos transacciones"
end as "Número de transacciones"
from transaction
inner join company on company.id = transaction.company_id
group by company.company_name
order by 3 desc;

-- B. No incluyo las transacciones declinadas. 

select company.company_name, count(transaction.id),
case 
	when count(transaction.id) > 4 then "Más de cuatro transacciones"
	else "Cuatro o menos transacciones"
end as "Número de transacciones"
from transaction
inner join company on company.id = transaction.company_id
where transaction.declined = 0
group by company.company_name
order by 3 desc;