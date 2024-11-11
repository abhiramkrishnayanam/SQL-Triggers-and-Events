/*1. Create a table named teachers with fields id, name, subject, experience and salary and insert 8 rows. 
  2. Create a before insert trigger named before_insert_teacher that will raise an error “salary cannot be negative”
     if the salary inserted to the table is less than zero. 
  3. Create an after insert trigger named after_insert_teacher that inserts a row with teacher_id,action, timestamp to a table called teacher_log 
     when a new entry gets inserted to the teacher table. tecaher_id -> column of teacher table, action -> the trigger action,
     timestamp -> time at which the new row has got inserted.
  4. Create a before delete trigger that will raise an error when you try to delete a row that has experience greater than 10 years. 
  5. Create an after delete trigger that will insert a row to teacher_log table when that row is deleted from teacher table.*/
  use challenge;
  #1. Create a table named teachers with fields id, name, subject, experience and salary and insert 8 rows. 
  CREATE TABLE teachers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    subject VARCHAR(50),
    experience INT,    -- Experience in years
    salary DECIMAL(10, 2)   -- Salary as a decimal value
);
INSERT INTO teachers (name, subject, experience, salary)
VALUES
('John Doe', 'Mathematics', 10, 50000.00),
('Jane Smith', 'Physics', 8, 48000.00),
('Robert Brown', 'Chemistry', 12, 52000.00),
('Emily Davis', 'Biology', 6, 45000.00),
('Michael Wilson', 'History', 9, 47000.00),
('Linda Garcia', 'English', 11, 51000.00),
('James Martinez', 'Geography', 7, 46000.00),
('Barbara Hernandez', 'Computer Science', 5, 44000.00);

/*2.Create a before insert trigger named before_insert_teacher that will raise an error “salary cannot be negative”
     if the salary inserted to the table is less than zero.*/
delimiter $$
CREATE TRIGGER before_insert_teacher
BEFORE INSERT ON teachers
FOR EACH ROW
BEGIN 
IF new.salary < 0  THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary cannot be negative';
    END IF;
END $$
DELIMITER ;

INSERT INTO teachers (name, subject, experience, salary)
VALUES('Johny Alwy', 'Mathematics', 10, -50000.00);

/*3. Create an after insert trigger named after_insert_teacher that inserts a row with teacher_id,action, timestamp to a table called teacher_log 
     when a new entry gets inserted to the teacher table. teacher_id -> column of teacher table, action -> the trigger action,
     timestamp -> time at which the new row has got inserted.*/
CREATE table teacher_log(teacher_id int primary key AUTO_INCREMENT ,action VARCHAR(50),  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP );
delimiter $$
CREATE TRIGGER after_insert_teacher
AFTER INSERT ON teachers
FOR EACH ROW
BEGIN 
 INSERT INTO TEACHER_LOG (teacher_id, action, timestamp) VALUES (NEW.id, 'INSERT', CURRENT_TIMESTAMP);
END $$
DELIMITER ;
INSERT INTO teachers (name, subject, experience, salary)
VALUES
('Symon Karle', 'Mathematics', 9, 57000.00);
select * from teachers;
select * from teacher_log;

#4. Create a before delete trigger that will raise an error when you try to delete a row that has experience greater than 8 years.
DELIMITER $$
CREATE TRIGGER Experience_check
BEFORE DELETE ON teachers
FOR EACH ROW
BEGIN 
IF OLD.EXPERIENCE > 8  THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'RECORDS OF TEACHERS HAVING MORE THAN 8 YEARS EXPERIENCE CANT BE DELETED';
END IF;
END $$
DELIMITER ;
DELETE FROM TEACHERS WHERE EXPERIENCE=10;

#5. Create an after delete trigger that will insert a row to teacher_log table when that row is deleted from teacher table.
DELIMITER $$
CREATE TRIGGER AFTER_DELETE
AFTER DELETE ON teachers
FOR EACH ROW
BEGIN 
INSERT INTO TEACHER_LOG (teacher_id, action, timestamp) VALUES (OLD.ID, 'DELETE', CURRENT_TIMESTAMP);
END $$
DELIMITER ;
DELETE FROM TEACHERS WHERE ID= 2;
SELECT * FROM TEACHERS ;
select * from teacher_log;

#Create an event to increase each teacher's salary by a certain percentage. In this example, we'll use a 5% increase, and the event will 
#run annually on January 1.

SET GLOBAL event_scheduler = ON; #First, ensure that the MySQL event scheduler is enabled:
CREATE EVENT IF NOT EXISTS annual_salary_increase
ON SCHEDULE EVERY 1 YEAR
STARTS '2024-01-01 00:00:00'
DO
    UPDATE teachers
    SET salary = salary * 1.05;  -- Increase salary by 5%
    
    
#Create an event which run every year on December 31 at midnight and remove any teachers who have more than 40 years of experience.
CREATE EVENT IF NOT EXISTS remove_retired_teachers
ON SCHEDULE EVERY 1 YEAR
STARTS '2024-12-31 23:59:59'
DO
    DELETE FROM teachers
    WHERE experience > 40;

