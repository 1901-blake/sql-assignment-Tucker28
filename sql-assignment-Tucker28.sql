/****************************************************
 *  2.0 SQL Queries
 ****************************************************/
--|2.1 SELECT|---------------------------------------
--Task 1: Select all records from the Employee table.
-----------------------------------------------------
select * from employee;


--Task 2: Select all records from the Employee table where last name is King.
-----------------------------------------------------------------------------
select * from employee where lastname = 'King';


--Task 3: Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
------------------------------------------------------------------------------------------------------
select * from employee where firstname = 'Andrew' and reportsto is NULL;



--|2.2 Order By|----------------------------------------------------------------------------
--Task 1: Select all albums in Album table and sort result set in descending order by title.
--------------------------------------------------------------------------------------------
select * from album order by title desc;


--Task 2: Select first name from Customer and sort result set in ascending order by city.
-----------------------------------------------------------------------------------------
select firstname from customer order by city asc;


--2.3 insert into---------------------------------
--Task 1: Insert two new records into Genre table.
--------------------------------------------------
insert into genre values (26, 'Holiday');
insert into genre values (27, 'Christmas');


--Task 2: Insert two new records into Employee table.
-----------------------------------------------------
insert into employee
values (9, 'Tucker', 'Ethan', 'IT Staff', 6, to_timestamp('1969/10/31', 'yyyy/mm/dd'),
	to_timestamp('2019/01/23', 'yyyy/mm/dd'), '748 Smith Grove Rd', 'Oakboro', 'NC',
	'USA', '28129', '704-555-2357', '', 'etucker@gmail.com');

insert into employee
values (10, 'Tucker', 'Bryan', 'IT Staff', 6, to_timestamp('1968/07/04', 'yyyy/mm/dd'),
	to_timestamp('2019/01/23', 'yyyy/mm/dd'), '748 Smith Grove Rd', 'Oakboro', 'NC',
	'USA', '28129', '704-555-8361', '', 'btucker@gmail.com');


--Task 3: Insert two new records into Customer table.
-----------------------------------------------------
insert into customer
values (60, 'Amelia', 'Masters', 'Ford', '732 Main Street', 'Detroit', 'MI', 'USA', '48126',
	'800-555-1357', '800-555-2468', 'amasters@ford.com', 3);

insert into customer
values (61, 'Jordan', 'Smith', 'Chrysler', '8365 Main Street', 'Detroit', 'MI', 'USA', '48126',
	'800-555-9573', '800-555-5835', 'jsmith@chrysler.com', 3);



--2.4 update-------------------------------------------------------
--Task 1: Update Aaron Mitchell in Customer table to Robert Walter.
-------------------------------------------------------------------
update customer
set firstname = 'Robert', lastname = 'Walter'
where customerid in
(select customerid from customer where firstname = 'Aaron' and lastname = 'Mitchell'); -- 32


--Task 2: Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”.
--------------------------------------------------------------------------------------------
update artist
set name = 'CCR'
where name = 'Creedence Clearwater Revival';



--2.5 like----------------------------------------------------
--Task 1: Select all invoices with a billing address like “T%”
--------------------------------------------------------------
select * from invoice where billingaddress like 'T%';



--2.6 between----------------------------------------------------
--Task 1: Select all invoices that have a total between 15 and 50
-----------------------------------------------------------------
select * from invoice where total between 15 and 50;


--Task 2: Select all employees hired between 1st of June 2003 and 1st of March 2004.
------------------------------------------------------------------------------------
select * from employee where hiredate between '2003-06-01' and '2004-03-01';



--2.7 delete----------------------------------------------------------------
--Task 1: Delete a record in Customer table where the name is Robert Walter
--(There may be constraints that rely on this, find out how to resolve them)
----------------------------------------------------------------------------
delete from invoiceline where invoiceid in
	(select invoiceid from invoice where customerid in
		(select customerid from customer where firstname = 'Robert' and lastname = 'Walter')
	);

delete from invoice where customerid in
	(select customerid from customer where firstname = 'Robert' and lastname = 'Walter');

delete from customer where firstname = 'Robert' and lastname = 'Walter';

-- I realize I could have altered the tables (invoice and invoiceline) to "on delete cascade"
-- and then back afterwards.  I chose not do that to since it was set that way intentionally
-- and it seems to be begging for trouble with referential integrity to make that a common practice.





/********************************************************
 * 3.0 sql functions
 ********************************************************/
--3.1 system defined function
--Task 1: Create a function that returns the current time.
----------------------------------------------------------
CREATE or REPLACE FUNCTION getTime()
RETURNS Time as $$
begin
	return current_time;
end;
$$ language plpgsql;

select GetTime();


--Task 2: Create a function that returns the length of a mediatype from the mediatype table
-------------------------------------------------------------------------------------------
create or replace function getLength()
returns setof integer as $$
begin
	return query select length(name) from mediatype;
end;
$$ language plpgsql

select getLength();



--3.2 system defined function
--Task 1: Create a function that returns the average total of all invoices
--------------------------------------------------------------------------
create or replace function avgTotal()
returns numeric as $$
begin
	return avg(total) from invoice;
end;
$$ language plpgsql

select avgTotal();


--Task 2: Create a function that returns the most expensive track
-----------------------------------------------------------------
create or replace function mostExpensiveTrack()
returns text as $$
begin
	return name from track
	where unitprice in (select max(unitprice) from track);
end;
$$ language plpgsql

select mostExpensiveTrack();



--3.3 User Defined Scalar Functions
--Task – Create a function that returns the average price of invoiceline item in the invoiceline table
------------------------------------------------------------------------------------------------------
create or replace function avgPrice()
returns numeric as $$
begin
	return avg(unitprice) from invoiceline;
end;
$$ language plpgsql

select avgPrice();



--3.4 User Defined Table Valued Functions
--Task – Create a function that returns all employees who are born after 1968.
------------------------------------------------------------------------------
create or replace function empAfter68()
returns setof text as $$
begin
	return query select concat(firstname, ' ', lastname) from employee where birthdate > '12/31/1968';
end;
$$ language plpgsql;

select empAfter68();





/********************************************************************************************
 * 4.0 Stored Procedures
 ********************************************************************************************/
--4.1 Basic Stored Procedure
--Task: Create a stored procedure that selects the first and last names of all the employees.
----------------------------------------------------------------------------------------------
create or replace function empNameProc(out ref refcursor) as $$
begin
	open ref for select firstname, lastname from employee;
end;
$$ language plpgsql;

do $$
declare
curs refcursor;
fname text;
lname text;
begin 
	select empNameProc() into curs;
	loop
		fetch curs into fname, lname;
		exit when not found;
		insert into empNames (firstName, lastName) values (fname, lname);
	end loop;
end;
$$ language plpgsql;

create table empNames(eID serial primary key, firstName text, lastName text);



--4.2 Stored Procedure Input Parameters
--Task 1: Create a stored procedure that updates the personal information of an employee.
----------------------------------------------------------------------------------------
create or replace function addressChangeProc(fname text, lname text, addr text, cty text, st text, zip text)
returns void as $$
begin
	update employee
	set address = addr, city = cty, state = st, postalcode = zip
	where firstname = fname and lastname = lname;
end;
$$ language plpgsql;

select addressChangeProc('Bryan', 'Tucker', '2713 Smith Grove Road', 'Oakboro', 'NC', '28129');


--Task 2: Create a stored procedure that returns the managers of an employee.
-----------------------------------------------------------------------------
create or replace function returnMgrProc (fname text, lname text, out mgrname refcursor) as $$
begin
	select concat(firstname, ' ', lastname) into mgrname
	from employee where employeeid in 
	(select reportsto from employee where firstname = fname and lastname = lname);
end;
$$ language plpgsql;

select returnMgrProc('Bryan', 'Tucker');



--4.3 Stored Procedure Output Parameters
--Task – Create a stored procedure that returns the name and company of a customer.
-----------------------------------------------------------------------------------
create or replace function nameNCompanyProc (id int, out custname refcursor) as $$
begin
	select concat('customer: ', firstname, ' ', lastname, ', company: ', company) into custname
	from customer where customerid = id;
end;
$$ language plpgsql;

select nameNCompanyProc(10);





/****************************************************************************
 * 5.0 Transactions
 * In this section you will be working with transactions. Transactions are
 * usually nested within a stored procedure.
 ****************************************************************************/
--Task – Create a transaction that given a invoiceId will delete that invoice
--(There may be constraints that rely on this, find out how to resolve them).
------------------------------------------------------------------------------
begin;
select * from invoice;
delete from invoiceline where invoiceid = 1;
delete from invoice where invoiceid = 1;
select * from invoice;
rollback;
select * from invoice;


--Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
---------------------------------------------------------------------------------------------------------------
create or replace function insCustProc(cid int, fname text, lname text, comp text, addr text, ct text, st text,
	ctry text, zip text, ph text, fx text, em text, rep int)
returns void as $$
begin
	insert into customer (customerid, firstname, lastname, company, address, city, state, country, postalcode,
		phone, fax, email, supportrepid)
		values (cid, fname, lname, comp, addr, ct, st, ctry, zip, ph, fx, em, rep);
end;
$$ language plpgsql;

select insCustProc(62, 'Seamus', 'Tucker', 'Maersk', '8034 Smith Grove Road', 'Oakboro','NC','USA','28129',
	'704-555-1638','704-555-1172','seamus@maersk.com',5);





/****************************************************************************
 * 6.0 Triggers
 * In this section you will create various kinds of triggers that work when
 * 	certain DML statements are executed on a table.
 ****************************************************************************/
--6.1 AFTER/FOR
--Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
------------------------------------------------------------------------------------------------------------------
create trigger emp_Insert_Trigger
after insert on employee
for each row
execute procedure empInsTrigProc();
--NOTE: There is no procedure linked.  The Task didn't say what the trigger was supposed to do.


--Task – Create an after update trigger on the album table that fires after a row is inserted in the table.
-----------------------------------------------------------------------------------------------------------
create trigger alb_Update_Trigger
after update on album
for each row
execute procedure albUpdTrigProc();
--NOTE: There is no procedure linked.  The Task didn't say what the trigger was supposed to do.


--Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
---------------------------------------------------------------------------------------------------------------
create trigger cust_Delete_Trigger
after delete on customer
for each row
execute procedure custDelTrigProc();
--NOTE: There is no procedure linked.  The Task didn't say what the trigger was supposed to do.





/********************************************************************************************************************
 * 7.0 JOINS
 ********************************************************************************************************************/
--7.1 INNER
--Task: Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.
----------------------------------------------------------------------------------------------------------------------
select c.firstname, c.lastname, i.invoiceid
from customer c
inner join invoice i on c.customerid = i.customerid
order by c.customerid asc;



--7.1 OUTER
--Task: Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname,
--		lastname, invoiceId, and total.
-------------------------------------------------------------------------------------------------------------
select c.firstname as "First Name", c.lastname as "Last Name", i.invoiceid as "Invoice ID", i.total as "Total"
from customer c
full join invoice i on c.customerid = i.customerid
order by i.invoiceid asc;



--7.2 RIGHT
--Task: Create a right join that joins album and artist specifying artist name and title.
-----------------------------------------------------------------------------------------
select ar.name as "Band Name", al.title as "Album Title"
from artist ar
right join album al on ar.artistid = al.artistid
order by ar.artistid asc;



--7.2 CROSS
--Task: Create a cross join that joins album and artist and sorts by artist name in ascending order.
----------------------------------------------------------------------------------------------------
select *
from album al
cross join artist ar
order by ar.name asc;



--7.2 SELF
--Task: Perform a self-join on the employee table, joining on the reportsto column.
-----------------------------------------------------------------------------------
select
	e1.employeeid as "Employee ID",
	e1.firstname as "First Name",
	e1.lastname as "Last Name",
	e1.title as "Title",
	e1.reportsto as "Reports To",
	e2.firstname as "First Name",
	e2.lastname as "Last Name",
	e2.title as "Title",
	e2.employeeid as "Manager ID"
from employee e1
inner join employee e2
on e1.reportsto = e2.employeeid;