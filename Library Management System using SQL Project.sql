

create database xyz;
use xyz;

create table books ( ISBN	varchar(100) primary key ,
                    BOOK_TITLE	varchar(100),
                    CATEGORY	varchar(100),
                    RENTAL_PRICE	float,
                    STATUS	varchar(100),
                    AUTHOR	varchar(100),
                    PUBLISHER varchar(100)
                    );


select * from books;

create table branch ( BRANCH_ID	varchar (100) primary key,
					  MANAGER_ID varchar (100),	
                      BRANCH_ADDRESS	varchar(100),
                      CONTACT_NO varchar(100)
                      );
                      
select * from branch;

create table employees( EMP_ID	varchar(100) primary key,
                        EMP_NAME varchar(100),	
                        POSITION varchar (100),	
                        SALARY	bigint,
                        BRANCH_ID varchar(100), 
                        foreign key (BRANCH_ID) references branch(BRANCH_ID)
                        );
select * from employees;

create table members( MEMBER_ID	varchar(100) primary key,
                      MEMBER_NAME	varchar(100),
                      MEMBER_ADDRESS varchar(100),	
                      REG_DATE date
                      );
select * from members;

create table issued_status ( ISSUED_ID	varchar(100) primary key,
               ISSUED_MEMBER_ID	varchar(100), foreign key ( ISSUED_MEMBER_ID) references members(MEMBER_ID),
               ISSUED_BOOK_NAME	varchar(100),
               ISSUED_DATE	date,
               ISSUED_BOOK_ISBN	varchar(100), foreign key (ISSUED_BOOK_ISBN) references books(ISBN),
               ISSUED_EMP_ID varchar(100), foreign key (ISSUED_EMP_ID) references employees(EMP_ID)
               );

select * from issued_status;

create table return_status( RETURN_ID	varchar(100) primary key,
						    ISSUED_ID	varchar(100), foreign key(ISSUED_ID) references issued_status( ISSUED_ID),
                            RETURN_BOOK_NAME	varchar(100),
                            RETURN_DATE	varchar(100),
                            RETURN_BOOK_ISBN varchar(100), foreign key (RETURN_BOOK_ISBN) references books(ISBN)
                            );
                            
select * from return_status;
# Data Cleaning 
  # check  Duplicate ,Blank and Null values in ISBN because 'ISBN' in our Primary Key

select ISBN, count(*)
from books
Where ISBN is not null And ISBN <> ' '
group by ISBN
having count(*) >1;

 # check  Duplicate ,Blank and Null values in  because 'ISBN' in our Primary Key

select ISBN, count(*)
from books
Where ISBN is not null And ISBN <> ' '
group by ISBN
having count(*) >1;

 #this type your try for evry table IN my case my all table full clean and well structure we move to our finding and Analysis
 
 #Task 1. Create a New Book Record 
 #"978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books( ISBN,	BOOK_TITLE,	CATEGORY,	RENTAL_PRICE,	STATUS,	AUTHOR,	PUBLISHER)
value
( '978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books;

#Task 2: Update an Existing Member's Address " '125 Oak St' for member_ID C103

update members
set MEMBER_ADDRESS = '125 Oak St'
where MEMBER_ID = 'C103';
    #Lets check 
select * from members
where MEMBER_ID = 'C103';

#Delete a Record from the Issued Status Table -- 
#Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

delete from issued_status
where ISSUED_ID = 'IS121';

  #Lets check 
select * from issued_status
where ISSUED_ID = 'IS121';

#Task 4: Retrieve All Books Issued by a Specific Employee -- 
   #Objective: Select all books issued by the employee with emp_id = 'E101'.

select * from issued_status
where ISSUED_EMP_ID = 'E101';

#Task 5: List Members Who Have Issued More Than One Book -- 
 #Objective: Use GROUP BY to find members who have issued more than FIVE book.

select ISSUED_MEMBER_ID, count(*)
FROM issued_status
group by 1
having count(*) > 5;

#(select count(distinct(ISSUED_MEMBER_ID)), ISSUED_MEMBER_ID from issued_status group by ISSUED_MEMBER_ID;)

#Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

create table Summary_Tables as  
                              select b.ISBN as ISBN,
                              b.BOOK_TITLE as Book_Title,
                              count(I.ISSUED_ID) as Book_Issued_count
                              from books b
                              join issued_status I
                              on I.ISSUED_BOOK_ISBN = b.ISBN
                              group by b.ISBN, b.BOOK_TITLE;
 #lets check table
 select * from Summary_Tables;

#Task 7. Retrieve All Books in a 'Classic' Category

select * from books
where CATEGORY = 'Classic' ;

#Task 8: Find Total Rental Income by Category

select b.CATEGORY, sum(b.RENTAL_PRICE) as Rental_Income, count(*)
from books b
join issued_status I 
on I.ISSUED_BOOK_ISBN =  b.ISBN
group by b.CATEGORY;

#Task 9: List Members Who Registered in the last 180 Days:

select * from members
where REG_DATE >= date_sub(curdate(), interval 180 Day);

#task 10: branch List Employees with Their Branch Manager's Name and their branch details:

select e.EMP_ID, e.EMP_NAME, e2.EMP_NAME as manager_name, b.* 
from employees e
join branch b on b.BRANCH_ID = e.BRANCH_ID
join employees e2 on b.MANAGER_ID = e2.EMP_ID;

#Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:

create table Threshold_Above_7USD as 
                                    select * from books
                                    where RENTAL_PRICE > 7;
  #lets check
select * from  Threshold_Above_7USD;

#Task 12: Retrieve the List of Books Not Yet Returned

select  I.*
from issued_status I 
left join return_status R on R.ISSUED_ID = I.ISSUED_ID
where R.ISSUED_ID is null;

#Task 13: Identify Members with Overdue Books
     #Write a query to identify members who have overdue books (assume a 30-day return period). 
     #Display the member's_id, member's name, book title, issue date, and days overdue.
     
select m.MEMBER_ID, m.MEMBER_NAME, b.BOOK_TITLE, i.ISSUED_DATE,
       current_date-i.ISSUED_DATE as OVERDUE_DAYS
from members m 
join issued_status i on i.ISSUED_MEMBER_ID = m.MEMBER_ID
join books b on b.ISBN = i.ISSUED_BOOK_ISBN
left join return_status r on r.ISSUED_ID = i.ISSUED_ID
where r.RETURN_DATE is null and (current_date - i.ISSUED_DATE) > 30
order by 1;



#Task 14: Branch Performance Report
#Create a query that generates a performance report for each branch,
# showing the number of books issued, 
#the number of books returned, 
#and the total revenue generated from book rentals.


create table branch_repport
AS (
    select B.BRANCH_ID, B.MANAGER_ID, 
           count(I.ISSUED_BOOK_ISBN) as total_book_Issued, 
		   count(R.RETURN_BOOK_ISBN) as total_book_return, 
           sum(Bk.RENTAL_PRICE) as total_revenue
	from books BK
	join issued_status I on BK.ISBN = I.ISSUED_BOOK_ISBN
	join employees E on E.EMP_ID = I.ISSUED_EMP_ID
	left join return_status R on R.ISSUED_ID = I.ISSUED_ID
	join branch B on B.BRANCH_ID = E.BRANCH_ID
	group by B.BRANCH_ID
);

select * from branch_reports;


#Task 15: CTAS: Create a Table of Active Members
#Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
#who have issued at least one book in the last 2 months.

create table Active_Members as 
( 
  select * from members
  where MEMBER_ID in (select distinct(ISSUED_MEMBER_ID)
					  from issued_status
					  where ISSUED_DATE >= current_date - interval  1 year)
);

select * from Active_Members;

#Task 16: Find #Employees with the Most Book Issues Processed
  #Write a query #to find the top 3 employees who have processed the most book issues.
   # Display the employee name, number of books ISSUED, and their branch.



select e.EMP_NAME, count(I.ISSUED_ID) as number_of_books_ISSUED, b.BRANCH_ID
from employees e
join branch b on b.BRANCH_ID = e.BRANCH_ID
join issued_status I on I.ISSUED_EMP_ID = e.EMP_ID
group by 1, 3
order by 2 desc
limit 3;

#ask 17: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
#Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
#The table should include: The number of overdue books. 
#The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. 
#The resulting table should show: Member ID Number of overdue books Total fines

CREATE TABLE calculate_fines AS
SELECT 
    m.MEMBER_ID,
    COUNT(I.ISSUED_ID) AS Total_book_Issued,
    COUNT(CASE 
              WHEN r.RETURN_DATE IS NULL AND DATEDIFF(CURDATE(), I.ISSUED_DATE) > 30 
              THEN 1 
          END) AS overdue_books,
    ROUND(SUM(
        CASE 
            WHEN r.RETURN_DATE IS NULL AND DATEDIFF(CURDATE(), I.ISSUED_DATE) > 30  
            THEN (DATEDIFF(CURDATE(), I.ISSUED_DATE) - 30) * 0.50
            ELSE 0 
        END
    ), 2) AS total_fine
FROM members m
JOIN issued_status I ON I.ISSUED_MEMBER_ID = m.MEMBER_ID
LEFT JOIN return_status r ON r.ISSUED_ID = I.ISSUED_ID
GROUP BY m.MEMBER_ID;

select * from calculate_fines;