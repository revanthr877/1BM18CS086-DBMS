CREATE DATABASE AIRLINE;
USE AIRLINE;

CREATE TABLE FLIGHTS(FL_ID INT,FROM_PLACE VARCHAR(20),TO_PLACE VARCHAR(20),DISTANCE INT,DEPARTS TIME,ARRIVES TIME,PRICE INT,PRIMARY KEY(FL_ID));

CREATE TABLE AIRCRAFT(A_ID INT,A_NAME VARCHAR(10),CRUISING_RANGE INT,PRIMARY KEY(A_ID));

CREATE TABLE EMPLOYEE(E_ID INT,E_NAME VARCHAR(10),SALARY INT,PRIMARY KEY(E_ID));

CREATE TABLE CERTIFIED(E_ID INT,A_ID INT,FOREIGN KEY(E_ID) REFERENCES EMPLOYEE(E_ID),FOREIGN KEY(A_ID) REFERENCES AIRCRAFT(A_ID));

INSERT INTO FLIGHTS VALUES(111,'BENGALURU','FRANKFURT',1000,'09:30','16:00',10000);
INSERT INTO FLIGHTS VALUES(222,'MANDISON','BENGALURU',1020,'01:30','7:00',9000);
INSERT INTO FLIGHTS VALUES(333,'BENGALURU','FRANKFURT',1000,'01:40','12:00',9500);
INSERT INTO FLIGHTS VALUES(444,'BENGALURU','NEW DELHI',550,'08:00','13:00',5000);
INSERT INTO FLIGHTS VALUES(555,'NEW DELHI','NEW YORK',5000,'13:30','17:00',15000);
INSERT INTO FLIGHTS VALUES(666,'MANDISION','NEW YORK',12000,'16:30','19:00',20000);
SELECT * FROM FLIGHTS;

INSERT INTO AIRCRAFT VALUES(10,'AIR ASIA',12000);
INSERT INTO AIRCRAFT VALUES(20,'GO AIR',2000);
INSERT INTO AIRCRAFT VALUES(30,'AIR ASIA',600);
INSERT INTO AIRCRAFT VALUES(40,'INDIGO',5000);
INSERT INTO AIRCRAFT VALUES(50,'SPICE JET',900);
INSERT INTO AIRCRAFT VALUES(60,'SPICE JET',12500);
SELECT * FROM AIRCRAFT;

INSERT INTO EMPLOYEE VALUES(1,'SAM',82000);
INSERT INTO EMPLOYEE VALUES(2,'TANYA',15000);
INSERT INTO EMPLOYEE VALUES(3,'SHAAN',60000);
INSERT INTO EMPLOYEE VALUES(4,'RAJATH',81000);
INSERT INTO EMPLOYEE VALUES(5,'SAAKSHI',9000);
INSERT INTO EMPLOYEE VALUES(6,'AYMAN',70000);
SELECT * FROM EMPLOYEE;

INSERT INTO CERTIFIED VALUES(1,10);
INSERT INTO CERTIFIED VALUES(4,10);
INSERT INTO CERTIFIED VALUES(3,40);
INSERT INTO CERTIFIED VALUES(5,30);
INSERT INTO CERTIFIED VALUES(5,50);
INSERT INTO CERTIFIED VALUES(4,50);
INSERT INTO CERTIFIED VALUES(4,20);
INSERT INTO CERTIFIED VALUES(4,30);
SELECT * FROM CERTIFIED;

SELECT DISTINCT A.A_NAME FROM AIRCRAFT A WHERE A.A_ID IN (SELECT C.A_ID FROM CERTIFIED C, EMPLOYEE E WHERE C.E_ID = E.E_ID AND NOT EXISTS ( SELECT * FROM EMPLOYEE E1 WHERE E1.E_ID = E.E_ID AND E1.SALARY <80000 ));

SELECT C.E_ID,MAX(A.CRUISING_RANGE) AS MAX_CRUSING_RANGE FROM CERTIFIED C,AIRCRAFT A WHERE C.A_ID=A.A_ID AND C.E_ID=(SELECT E_ID FROM CERTIFIED GROUP BY E_ID HAVING COUNT(*)>3);

SELECT E_NAME FROM EMPLOYEE WHERE E_ID IN (SELECT E_ID FROM CERTIFIED) AND SALARY<(SELECT MIN(PRICE) FROM FLIGHTS WHERE FROM_PLACE='BENGALURU' AND TO_PLACE='FRANKFURT');

SELECT C.A_ID,AVG(E.SALARY) AS AVERAGE_SALARY FROM EMPLOYEE E,CERTIFIED C WHERE E.E_ID=C.E_ID AND C.A_ID IN (SELECT A_ID FROM AIRCRAFT WHERE CRUISING_RANGE>1000) GROUP BY C.A_ID;

SELECT A_ID FROM AIRCRAFT WHERE CRUISING_RANGE>(SELECT DISTANCE FROM FLIGHTS WHERE FROM_PLACE='BENGALURU' AND TO_PLACE='NEW DELHI');

SELECT F.DEPARTS FROM FLIGHTS F WHERE F.FL_ID IN ( ( SELECT F0.FL_ID FROM FLIGHTS F0 WHERE F0.FROM_PLACE = 'MANDISION' AND F0.TO_PLACE = 'NEW YORK' 
    AND EXTRACT(HOUR FROM F0.ARRIVES) < 18 ) UNION ( SELECT F0.FL_ID FROM FLIGHTS F0, FLIGHTS F1 WHERE F0.FROM_PLACE = 'MANDISION' AND F0.TO_PLACE <> 'NEW YORK' 
      AND F0.TO_PLACE = F1.FROM_PLACE AND F1.TO_PLACE = 'NEW YORK' AND F1.DEPARTS > F0.ARRIVES AND EXTRACT(HOUR FROM F1.ARRIVES) < 18 )
	    UNION( SELECT F0.FL_ID FROM  FLIGHTS F0, FLIGHTS F1, FLIGHTS F2 WHERE F0.FROM_PLACE = 'MANDISION' AND F0.TO_PLACE = F1.FROM_PLACE AND F1.TO_PLACE = F2.FROM_PLACE
           AND F2.TO_PLACE = 'NEW YORK' AND F0.TO_PLACE <> 'NEW YORK' AND F1.TO_PLACE <> 'NEW YORK' AND F1.DEPARTS > F0.ARRIVES AND F2.DEPARTS > F1.ARRIVES 
              AND EXTRACT(HOUR FROM F2.ARRIVES) < 18 ));

SELECT E_NAME,SALARY FROM EMPLOYEE WHERE E_ID NOT IN(SELECT E_ID FROM CERTIFIED) AND SALARY>(SELECT AVG(SALARY) FROM EMPLOYEE WHERE E_ID IN (SELECT E_ID FROM CERTIFIED));