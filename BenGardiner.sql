IF OBJECT_ID('Sale') IS NOT NULL
DROP TABLE SALE;

IF OBJECT_ID('Product') IS NOT NULL
DROP TABLE PRODUCT;

IF OBJECT_ID('Customer') IS NOT NULL
DROP TABLE CUSTOMER;

IF OBJECT_ID('Location') IS NOT NULL
DROP TABLE LOCATION;

GO

CREATE TABLE CUSTOMER (
CUSTID	INT
, CUSTNAME	NVARCHAR(100)
, SALES_YTD	MONEY
, STATUS	NVARCHAR(7)
, PRIMARY KEY	(CUSTID) 
);


CREATE TABLE PRODUCT (
PRODID	INT
, PRODNAME	NVARCHAR(100)
, SELLING_PRICE	MONEY
, SALES_YTD	MONEY
, PRIMARY KEY	(PRODID)
);

CREATE TABLE SALE (
SALEID	BIGINT
, CUSTID	INT
, PRODID	INT
, QTY	INT
, PRICE	MONEY
, SALEDATE	DATE
, PRIMARY KEY 	(SALEID)
, FOREIGN KEY 	(CUSTID) REFERENCES CUSTOMER
, FOREIGN KEY 	(PRODID) REFERENCES PRODUCT
);

CREATE TABLE LOCATION (
  LOCID	NVARCHAR(5)
, MINQTY	INTEGER
, MAXQTY	INTEGER
, PRIMARY KEY 	(LOCID)
, CONSTRAINT CHECK_LOCID_LENGTH CHECK (LEN(LOCID) = 5)
, CONSTRAINT CHECK_MINQTY_RANGE CHECK (MINQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_RANGE CHECK (MAXQTY BETWEEN 0 AND 999)
, CONSTRAINT CHECK_MAXQTY_GREATER_MIXQTY CHECK (MAXQTY >= MINQTY)
);

IF OBJECT_ID('SALE_SEQ') IS NOT NULL
DROP SEQUENCE SALE_SEQ;
CREATE SEQUENCE SALE_SEQ;

GO

-- END PROVIDED DDL ----- BEGIN ADD_CUSTOMER ---------------------------------------------------------

IF OBJECT_ID('ADD_CUSTOMER') IS NOT NULL
DROP PROCEDURE ADD_CUSTOMER;
GO

CREATE PROCEDURE ADD_CUSTOMER @PCUSTID INT, @PCUSTNAME NVARCHAR(100) AS

BEGIN
    BEGIN TRY

        IF @PCUSTID < 1 OR @PCUSTID > 499
            THROW 50020, 'Customer ID out of range', 1

        INSERT INTO CUSTOMER (CUSTID, CUSTNAME, SALES_YTD, STATUS) 
        VALUES (@PCUSTID, @PCUSTNAME, 0, 'OK');

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 2627
            THROW 50010, 'Duplicate customer ID', 1
        ELSE IF ERROR_NUMBER() = 50020
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;

END;

GO

-- execute and test here - - - - -- - - - -

EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude2';
EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'testdude3';
EXEC ADD_CUSTOMER @pcustid = 3, @pcustname = 'testdude5';

-- EXEC ADD_CUSTOMER @pcustid = 500, @pcustname = 'testdude3';

--EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude3'; 

select * from customer;

GO

-------------------------------- BEGIN DELETE_ALL_CUSTOMERS -------------------------------------------

IF OBJECT_ID('DELETE_ALL_CUSTOMER') IS NOT NULL
DROP PROCEDURE DELETE_ALL_CUSTOMER;

GO

CREATE PROCEDURE DELETE_ALL_CUSTOMER AS

BEGIN
    
    BEGIN TRY
            DELETE FROM Customer
            PRINT(CONCAT('NUM OF ROWS DELETED: ', @@ROWCOUNT));
    END TRY

    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END;
        
    END CATCH;

END;

GO

EXEC DELETE_ALL_CUSTOMER;

GO
-- PROVES SP WORKS----
select * from customer;

GO
-- addding some data back in to test further queries
EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude2';
EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'testdude3';
EXEC ADD_CUSTOMER @pcustid = 3, @pcustname = 'testdude5';

GO
----PROVES ADD_CUSTOMER WORKS----
select * from customer;

GO


-- BEGIN "ADD PRODUCT" STORED PROCEDURE ----------------------------------------------------------

IF OBJECT_ID('ADD_PRODUCT') IS NOT NULL
DROP PROCEDURE ADD_PRODUCT;
GO

CREATE PROCEDURE ADD_PRODUCT @pprodid INT, @pprodname NVARCHAR(100), @pprice MONEY AS

BEGIN
    BEGIN TRY

        IF @pprodid < 1000 OR @pprodid > 2500
            THROW 50040, 'Product ID out of range', 1
        ELSE if @pprice < 0 OR @pprice > 999.99
             THROW 50050, 'Price out of range', 1
        INSERT INTO PRODUCT ( PRODID, PRODNAME, SELLING_PRICE, SALES_YTD) 
        VALUES (@pprodid, @pprodname, @pprice, 0);

    END TRY
    BEGIN CATCH
        if ERROR_NUMBER() = 2627
            THROW 50030, 'Duplicate Product ID', 1
        ELSE IF ERROR_NUMBER() = 50040
            THROW
        ELSE IF ERROR_NUMBER() = 50050
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
    END CATCH;

END;

GO

-- test id range
-- EXEC ADD_PRODUCT @pprodid = 9, @pprodname = 'Shoes', @pprice = 50.00; 
-- test price range
-- EXEC ADD_PRODUCT @pprodid = 1001, @pprodname = 'Shoes', @pprice = 10000.00; 
-- test duplicate key
/* EXEC ADD_PRODUCT @pprodid = 1001, @pprodname = 'Shoes', @pprice = 100.00; 
EXEC ADD_PRODUCT @pprodid = 1001, @pprodname = 'Toxic Waste', @pprice = 50.00; */

EXEC ADD_PRODUCT @pprodid = 1001, @pprodname = 'Shoes', @pprice = 50.00; 
EXEC ADD_PRODUCT @pprodid = 1009, @pprodname = 'Arsenal Top', @pprice = 10.00; 
EXEC ADD_PRODUCT @pprodid = 1074, @pprodname = 'Golf Buggy', @pprice = 890.00; 

GO

select * from customer;

GO
select * from product;

GO
-- begin delete all products work herer --- - - - - - - -
IF OBJECT_ID('DELETE_ALL_PRODUCTS') IS NOT NULL
DROP PROCEDURE DELETE_ALL_PRODUCTS;
GO

CREATE PROCEDURE DELETE_ALL_PRODUCTS AS

BEGIN
    
    BEGIN TRY
            DELETE FROM PRODUCT
            PRINT(CONCAT('NUM OF ROWS DELETED: ', @@ROWCOUNT));
    END TRY

    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END;
        
    END CATCH;

END;

GO

EXEC DELETE_ALL_PRODUCTS;

GO

select * from PRODUCT;

GO

EXEC ADD_PRODUCT @pprodid = 1001, @pprodname = 'Shoes', @pprice = 50.00; 
EXEC ADD_PRODUCT @pprodid = 1009, @pprodname = 'Arsenal Top', @pprice = 10.00; 
EXEC ADD_PRODUCT @pprodid = 1074, @pprodname = 'Golf Buggy', @pprice = 890.00;  

select * from PRODUCT;

GO



-- BEGIN GET_CUSTOMER_STRING ------------------------------------------------------------------------

IF OBJECT_ID('GET_CUSTOMER_STRING') IS NOT NULL
DROP PROCEDURE GET_CUSTOMER_STRING;
GO

CREATE PROCEDURE GET_CUSTOMER_STRING @pcustid INT, @pReturnString NVARCHAR(100) OUTPUT AS

BEGIN
    BEGIN TRY
        DECLARE @cName NVARCHAR(100), @ytd money, @status NVARCHAR(7);
        SELECT @cName = Custname, @ytd = SALES_YTD , @status  = [status] from CUSTOMER where CUSTID = @pcustid;
        IF @@ROWCOUNT = 0
        -- custom error below
        THROW 50060, 'CustomerID not found', 1 
        SET @pReturnString = CONCAT('Custid: ', @pcustid, ' Name: ', @cName, ' Status: ', @status,  ' SalesYTD: ',@ytd)
       
    END TRY
    BEGIN CATCH
       BEGIN
            IF ERROR_NUMBER() IN (50060)
            THROW
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END;
    END CATCH
    
END;

GO

BEGIN

DECLARE @externalParam NVARCHAR(100)
-- TESTING THE CUSTOMER NOT FOUND ERROR SHOULD RETURN FROM THIS------------------
EXEC GET_CUSTOMER_STRING @pcustid = 7, @pReturnString = @externalParam OUTPUT

print @externalParam

END

GO
BEGIN

DECLARE @returnCustomerString NVARCHAR(100)
-- THIS SHOULD RETURN THE CUSTOMER STRING ------------------------
EXEC GET_CUSTOMER_STRING @pcustid = 3, @pReturnString = @returnCustomerString OUTPUT

print @returnCustomerString

END

GO
------------------- BEGIN UPD_CUST_SALESYTD work here --------------------------------------------------

IF OBJECT_ID('UPD_CUST_SALESYTD') IS NOT NULL
DROP PROCEDURE UPD_CUST_SALESYTD;
GO

CREATE PROCEDURE UPD_CUST_SALESYTD @pcustid INTEGER, @pamt INTEGER AS

BEGIN
    BEGIN TRY

        IF @pamt < -999.99 OR @pamt > 999.99
            THROW 50080, '$ Amount out of range', 1

        update CUSTOMER 
        set sales_ytd = sales_ytd + @pamt
        where CUSTID = @pcustid;
        
        IF @@ROWCOUNT = 0
            THROW 50070, 'CustomerID not found', 1 
        
    END TRY

    BEGIN CATCH
       
        IF ERROR_NUMBER() IN (50080, 50070)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
        
    END CATCH;

    
END;

GO

-- test with negative num
BEGIN

EXEC UPD_CUST_SALESYTD @pcustid = 1, @pamt = -344;

END

GO
-- test with positive num
BEGIN

EXEC UPD_CUST_SALESYTD @pcustid = 2, @pamt = 344;

END

GO
-- test with out of range this should error out w/50080
BEGIN

EXEC UPD_CUST_SALESYTD @pcustid = 2, @pamt = 9000;

END

GO
-- test with custID not found -- this should error out w/50070
BEGIN

EXEC UPD_CUST_SALESYTD @pcustid = 5, @pamt = 344;

END

GO

select * from CUSTOMER;

GO



-- -- begin get pruduct string work here --- - - - - - - -

IF OBJECT_ID('GET_PROD_STRING') IS NOT NULL
DROP PROCEDURE GET_PROD_STRING;
GO

CREATE PROCEDURE GET_PROD_STRING @pprodid INT, @pReturnString NVARCHAR(1000) OUTPUT AS

BEGIN
    BEGIN TRY

        DECLARE @pprodname NVARCHAR(100), @ytd money, @sellprice MONEY;

        SELECT @pprodname = PRODNAME, @ytd = SALES_YTD, @sellprice = SELLING_PRICE 
        from PRODUCT 
        where PRODID = @pprodid;
        IF @@ROWCOUNT = 0
        THROW 50090, 'Product ID not found', 1 
        set @pReturnString = CONCAT('Prodid: ', @pprodid, ' ','Name: ', @pprodname, ' ',  'Price: ' , @sellprice ,' ','SalesYTD: ',@ytd);

        
    END TRY

    BEGIN CATCH

    IF ERROR_NUMBER() IN (50090)
        THROW
    ELSE
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END;
    END CATCH
    
END
GO

DELETE FROM PRODUCT;

GO

SELECT *
FROM PRODUCT;

GO

INSERT INTO PRODUCT(PRODID, PRODNAME, SELLING_PRICE, sales_ytd)
VALUES(1,'Hammer', 500, 1000);

GO

SELECT *
FROM PRODUCT;


GO
BEGIN
    DECLARE @externalParam NVARCHAR(100)
    EXEC GET_PROD_STRING @pprodid = 1, @pReturnString = @externalParam OUTPUT
    print @externalParam
END 
GO
-- THIS SHOULD ERROR OUT W/ 50090
BEGIN
    DECLARE @externalParam NVARCHAR(100)
    EXEC GET_PROD_STRING @pprodid = 2, @pReturnString = @externalParam OUTPUT
    print @externalParam
END 
GO

-- https://www.techonthenet.com/sql_server/procedures.php --- this website is good



---------------------- BEGIN UPD_PROD_SALESYTD work here -------------------------------------------------------------------------------------------


IF OBJECT_ID('UPD_PROD_SALESYTD ') IS NOT NULL
DROP PROCEDURE UPD_PROD_SALESYTD;
GO

CREATE PROCEDURE UPD_PROD_SALESYTD  @pprodid INTEGER, @pamt INTEGER AS

BEGIN
    BEGIN TRY

        IF @pamt < -999.99 OR @pamt > 999.99
            THROW 50110, '$ Amount out of range', 1

        update PRODUCT 
        set sales_ytd = sales_ytd + @pamt
        where PRODID = @pprodid;
        
        IF @@ROWCOUNT = 0
            THROW 50100, 'ProductID not found', 1 
        
    END TRY

    BEGIN CATCH
       
        IF ERROR_NUMBER() IN (50100, 50110)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
        
    END CATCH;

    
END;

GO
DELETE FROM PRODUCT;
INSERT INTO PRODUCT(PRODID, PRODNAME, SELLING_PRICE, sales_ytd)
VALUES (2, 'Hammer', 500, 0),
(3, 'Shovel', 20, 0)

GO

-- test with negative num
BEGIN

EXEC UPD_PROD_SALESYTD  @pprodid = 2, @pamt = -344;

END
GO

-- test with positive num
BEGIN

EXEC UPD_PROD_SALESYTD  @pprodid = 3, @pamt = 344;

END
GO

-- test with out of range
BEGIN

EXEC UPD_PROD_SALESYTD  @pprodid = 2, @pamt = 9000;

END
GO

-- test with custID not found
BEGIN

EXEC UPD_PROD_SALESYTD  @pprodid = 5, @pamt = 344;

END
GO

select * from PRODUCT;

GO

-- begin work for UPD_CUSTOMER_STATUS HERE..... - - - - -- - 

IF OBJECT_ID('UPD_CUSTOMER_STATUS ') IS NOT NULL
DROP PROCEDURE UPD_CUSTOMER_STATUS;
GO

CREATE PROCEDURE UPD_CUSTOMER_STATUS  @pcustid INTEGER, @pstatus NVARCHAR(100) AS

BEGIN
    BEGIN TRY

        IF @pstatus != 'ok' AND  @pstatus != 'suspend'
            THROW 50130, 'Invalid Status Value', 1

        update CUSTOMER          
        set [status] = @pstatus
        where custid = @pcustid;
        
        
        IF @@ROWCOUNT = 0
            THROW 50120, 'CustomerID not found', 1 
        
    END TRY

    BEGIN CATCH
       
        IF ERROR_NUMBER() IN (50130, 50120)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
        
    END CATCH;

    
END;

GO

DELETE FROM CUSTOMER;

GO

INSERT INTO customer(custid, Custname, sales_ytd, [status])
VALUES 
(1, 'BallyWho', 500, 'ok'),
(3, 'Loady', 20, 'suspend');

GO

SELECT *

from Customer

GO
-- test suspend
BEGIN
EXEC UPD_CUSTOMER_STATUS  @pcustid = 1, @pstatus = 'suspend';
END

GO
SELECT *
from Customer

GO
-- test ok
BEGIN
EXEC UPD_CUSTOMER_STATUS  @pcustid = 3, @pstatus = 'ok';
END

GO
SELECT *
from Customer

GO
-- test custid does not exist
BEGIN

EXEC UPD_CUSTOMER_STATUS  @pcustid = 5, @pstatus = 'ok';

END

GO

-- test incorrect data entry
BEGIN

EXEC UPD_CUSTOMER_STATUS  @pcustid = 1, @pstatus = 'big trouble';

END

GO

-- check that the values in status have been reversed
SELECT *
from Customer
GO

--  ADD SIMPLE SALE follows here - - - - - - - - - - - -

IF OBJECT_ID('ADD_SIMPLE_SALE') IS NOT NULL
DROP PROCEDURE ADD_SIMPLE_SALE;
GO

CREATE PROCEDURE ADD_SIMPLE_SALE  @pcustid INTEGER, @pprodid INTEGER, @pqty INTEGER AS

BEGIN
    BEGIN TRY
        DECLARE @TOTAL INT, @status NVARCHAR, @pstatus NVARCHAR(100), @pprice money, @userID int, @userProdid INT;
       
        SELECT  @pstatus = [status] from CUSTOMER where CUSTID = @pcustid; 
        SELECT @pprice = SELLING_PRICE from PRODUCT where PRODID = @pprodid; 
        SELECT @userID = CUSTID from CUSTOMER where CUSTID = @pcustid; 
        SELECT @userProdid = PRODID from PRODUCT where PRODID = @pprodid;

        IF @userID is NULL
            THROW 50160, 'Customer ID not found', 1
        IF @userProdid is NULL
            THROW 50170, 'Product ID not found', 1
        IF @pstatus != 'ok'
            THROW 50150, 'Customer Status is not OK', 1
        IF @pqty < 1 OR @pqty > 999
            THROW 50140, 'Sale Quantity outside valid range', 1

        SET @TOTAL = @pqty * @pprice

        EXEC UPD_CUST_SALESYTD @pcustid = @pcustid, @pamt = @TOTAL;
        
        EXEC UPD_PROD_SALESYTD @pprodid = @pprodid, @pamt = @TOTAL;
        IF @pprodid is NULL
            THROW 50170, 'Customer Status is not OK', 1
        
    END TRY

    BEGIN CATCH
       
        IF ERROR_NUMBER() IN (50170, 50160, 50150, 50140)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 
        
    END CATCH;

    
END;

GO

DELETE FROM CUSTOMER;
INSERT INTO customer(custid, Custname, sales_ytd, [status])
VALUES 
-- customer staus ok below here for test. Error Tested working as "suspend"
(1, 'BallyWho', 500, 'ok'),
(3, 'Loady', 20, 'suspend');

GO

DELETE FROM PRODUCT;

GO

INSERT INTO PRODUCT(PRODID, PRODNAME, SELLING_PRICE, sales_ytd)
VALUES (2, 'Hammer', 50, 0),
(3, 'Shovel', 20, 0)

GO
-- TEST 1 -- THIS IS CORRECT AND SHOULD INSERT
BEGIN
EXEC ADD_SIMPLE_SALE  @pcustid = 1 , @pprodid = 2, @pqty = 3  
END

GO
-- TEST 2 -- SUSPEND WILL CAUSE THIS TO FAIL
BEGIN
EXEC ADD_SIMPLE_SALE  @pcustid = 3, @pprodid = 3, @pqty = 3;
END


GO
-- TEST 3 --PRODUCT ID NOT FOUND TEST
BEGIN
EXEC ADD_SIMPLE_SALE  @pcustid = 1, @pprodid = 12, @pqty = 3;
END

GO

-- TEST 4 - Sale Quantity outside valid range
BEGIN
EXEC ADD_SIMPLE_SALE  @pcustid = 1, @pprodid = 2, @pqty = 1000;
END

GO

-- TEST 5 - Customer ID not found
BEGIN
EXEC ADD_SIMPLE_SALE  @pcustid = 12, @pprodid = 2, @pqty = 3;
END

GO

GO
SELECT *
from Customer
SELECT *
from PRODUCT
GO

-- SUM_CUSTOMER_SALESYTD work to begin below here .-.-.-.-.-.-.-.-.-.

IF OBJECT_ID('SUM_CUSTOMER_SALESYTD') IS NOT NULL
DROP PROCEDURE SUM_CUSTOMER_SALESYTD;
GO

CREATE PROCEDURE SUM_CUSTOMER_SALESYTD AS

BEGIN
    
    BEGIN TRY
            RETURN (SELECT SUM(SALES_YTD) FROM CUSTOMER) 
    END TRY

    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END;
        
    END CATCH;

END;

GO
DECLARE @CustSalesSum INT
EXEC @CustSalesSum = SUM_CUSTOMER_SALESYTD;
PRINT CONCAT('CUSTOMER SALES_YTD TOTAL: ', @CustSalesSum)
GO

-- SUM_PRODUCT_SALESYTD work to begin below here .-.-.-.-.-.-.-.-.-.

IF OBJECT_ID('SUM_PRODUCT_SALESYTD') IS NOT NULL
DROP PROCEDURE SUM_PRODUCT_SALESYTD;
GO

CREATE PROCEDURE SUM_PRODUCT_SALESYTD AS

BEGIN
    
    BEGIN TRY
            RETURN (SELECT SUM(SALES_YTD) FROM PRODUCT) 
    END TRY

    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END;
        
    END CATCH;

END;

GO
DECLARE @ProdSalesSum INT
EXEC @ProdSalesSum = SUM_PRODUCT_SALESYTD;
PRINT CONCAT('PRODUCT SALES_YTD TOTAL: ', @ProdSalesSum)
GO

--.-.-.-.-.-. GET_ALL_CUSTOMERS WORK TO FOLLOW HERE .-.-.-.-.-.-.-.-.-.-.-.-.
IF OBJECT_ID('GET_ALL_CUSTOMERS') IS NOT NULL
DROP PROCEDURE GET_ALL_CUSTOMERS;
GO

CREATE PROCEDURE GET_ALL_CUSTOMERS @POUTCUR CURSOR VARYING OUTPUT
AS
BEGIN
    SET @POUTCUR = CURSOR FOR
    SELECT *
    FROM CUSTOMER;
 
    OPEN @POUTCUR;
END
GO

BEGIN
DECLARE @outCust as CURSOR;
DECLARE @Name NVARCHAR(100), @ytd money, @status NVARCHAR(10), @ID INTEGER



EXEC GET_ALL_CUSTOMERS @POUTCUR = @outCust OUTPUT

-- this line tests whether something can be returned
FETCH NEXT FROM @outCust INTO @ID, @Name, @ytd, @status;
-- this 
WHILE @@FETCH_status = 0
BEGIN
    PRINT CONCAT('CustomerID', @ID, 'Customer Name: ', @Name,'Sales YTD: ', @ytd, 'Customer Status: ', @status)
    FETCH NEXT FROM @outCust INTO @ID, @Name, @ytd, @status;
END

CLOSE @outCust;
DEALLOCATE @outCust;
END

GO


--.-.-.-.-.-. GET_ALL_PRODUCTS WORK TO FOLLOW HERE .-.-.-.-.-.-.-.-.-.-.-.-.
IF OBJECT_ID('GET_ALL_PRODUCTS') IS NOT NULL
DROP PROCEDURE GET_ALL_PRODUCTS;
GO

CREATE PROCEDURE GET_ALL_PRODUCTS @POUTCUR CURSOR VARYING OUTPUT
AS
BEGIN
    SET @POUTCUR = CURSOR FOR
    SELECT *
    FROM PRODUCT;
 
    OPEN @POUTCUR;
END
GO

BEGIN
DECLARE @outPROD as CURSOR;
DECLARE @PRODID INT, @PRODNAME NVARCHAR(100), @SELLING_PRICE MONEY, @SALES_YTD MONEY

EXEC GET_ALL_PRODUCTS @POUTCUR = @outPROD OUTPUT

-- this line tests whether something can be returned
FETCH NEXT FROM @outPROD INTO @PRODID, @PRODNAME, @SELLING_PRICE, @SALES_YTD;

WHILE @@FETCH_status = 0
BEGIN
    PRINT CONCAT('ProductID: ', @PRODID,' Product Name: ' , @PRODNAME,' Selling Price: ', @SELLING_PRICE,' Sales YTD: ', @SALES_YTD)
    FETCH NEXT FROM @outPROD INTO @PRODID, @PRODNAME, @SELLING_PRICE, @SALES_YTD;
END

CLOSE @outPROD;
DEALLOCATE @outPROD;
END


-- ADD_LOCATION .-.-.-.-.-.-.-.-.-.-.-.-.- adds a new row to the lcoation table

IF OBJECT_ID('ADD_LOCATION') IS NOT NULL
DROP PROCEDURE ADD_LOCATION;
GO

CREATE PROCEDURE ADD_LOCATION @ploccode NVARCHAR(20), @pminqty INT, @pmaxqty INT AS

BEGIN
    BEGIN TRY

        INSERT INTO [LOCATION] (LOCID, MINQTY, MAXQTY) 
        VALUES (@ploccode, @pminqty, @pmaxqty);

    END TRY

    BEGIN CATCH
        IF ERROR_NUMBER() = 2627
            THROW 50180, 'Duplicate location ID', 1
        IF ERROR_NUMBER() = 2628
            THROW 50190, 'Location Code length invalid', 1    
       
        IF ERROR_NUMBER() = 547
            BEGIN
                IF ERROR_MESSAGE() LIKE '%CHECK_MINQTY_RANGE%'
                    THROW 50200, 'Minimum Qty out of range', 1
                IF ERROR_MESSAGE() LIKE '%CHECK_MAXQTY_RANGE%'
                    THROW 50210, 'Maximum Qty out of range', 1
                IF ERROR_MESSAGE() LIKE '%CHECK_MAXQTY_GREATER_MIXQTY%'
                THROW 50220, 'Minimum Qty larger than   
               Maximum Qty', 1

            END;  
        
    END CATCH;

END;

GO
DELETE FROM [LOCATION];
INSERT INTO [LOCATION] (LOCID, MINQTY, MAXQTY) 
VALUES ('loc12', 123, 555);

GO
/* -- this tests as working the duplicate location ID
EXEC ADD_LOCATION @ploccode = 'loc12', @pminqty = 664, @pmaxqty = 667; */
/* -- this tests as working the LOCID_LENGTH working
EXEC ADD_LOCATION @ploccode = 'loc112', @pminqty = 664, @pmaxqty = 667; */
/* -- this tests as working the minqty_range working
EXEC ADD_LOCATION @ploccode = 'loc19', @pminqty = 39999, @pmaxqty = 40000;  */
/* -- this tests as working the mmaxqty_range working
EXEC ADD_LOCATION @ploccode = 'loc20', @pminqty = 299, @pmaxqty = 40000;  */
-- this tests as working the min_max_greaterthan_error working
/* EXEC ADD_LOCATION @ploccode = 'loc21', @pminqty = 699, @pmaxqty = 211; */
GO

SELECT *
From LOCATION

GO
DELETE FROM [LOCATION];

GO


-- ADD_COMPLEX_SALE -.-.-.-.-.-.-.-.- works to follow here

IF OBJECT_ID('ADD_COMPLEX_SALE') IS NOT NULL
DROP PROCEDURE ADD_COMPLEX_SALE;
GO

CREATE PROCEDURE ADD_COMPLEX_SALE  @pcustid INTEGER, @pprodid INTEGER, @pqty INTEGER, @pdate NVARCHAR(10) AS

BEGIN
    BEGIN TRY
        IF @pqty < 1 OR @pqty > 999
            THROW 50230, 'Sale Quantity outside valid range', 1
        DECLARE @TOTAL INT, @status NVARCHAR(100), @pstatus NVARCHAR(100), @pprice money, @userID int, @userProdid INT, @convertedDate DATE;
       
        SELECT  @pstatus = [status], @userID = CUSTID from CUSTOMER where CUSTID = @pcustid; 
        if @@rowcount = 0
            THROW 50260, 'Customer ID not found', 1
        SELECT @pprice = SELLING_PRICE, @userProdid = PRODID from PRODUCT where PRODID = @pprodid; 
        if @@rowcount = 0
            THROW 50270, 'Product ID not found', 1
        SELECT @convertedDate = CONVERT(nvarchar, @pdate, 112);

        IF @pstatus != 'ok'
            THROW 50240, 'Customer Status is not OK', 1
       
        DECLARE @seq BIGINT
        set @seq = next VALUE FOR SALE_SEQ

        SET @TOTAL = @pqty * @pprice

        EXEC UPD_CUST_SALESYTD @pcustid = @pcustid, @pamt = @TOTAL;
        EXEC UPD_PROD_SALESYTD @pprodid = @pprodid, @pamt = @TOTAL;

        INSERT INTO SALE (SALEID, CUSTID, PRODID, QTY, PRICE, SALEDATE)
        VALUES (@seq, @pcustid, @pprodid, @pqty, @pprice, @convertedDate)
       
        
    END TRY

    BEGIN CATCH
       
        IF ERROR_NUMBER() IN (50270, 50260, 50240, 50230)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 
            END; 

    END CATCH;

    
END;

/* GO
-- inserts new row and seems to be working
 EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2, @pqty = 3, @pdate = 20200612;  */ 

/* GO
-- prod id not found
 EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 7, @pqty = 3, @pdate = 20200612;  */

-- GO 

-- cust id not found
 EXEC ADD_COMPLEX_SALE @pcustid = 6, @pprodid = 2, @pqty = 3, @pdate = 20200612;  

--  GO
/* -- date not valid test - complete
 EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2, @pqty = 3, @pdate = 20201781;  */

-- sale qty not valid test 
/* GO 
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2, @pqty = 1000, @pdate = 20200612; */

/* -- customer status not valid test 
GO
EXEC ADD_COMPLEX_SALE @pcustid = 3, @pprodid = 2, @pqty = 1, @pdate = 20200612; */

 -- real life working insert
GO
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2, @pqty = 5, @pdate = 20200612; 
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 3, @pqty = 5, @pdate = 20200712;
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2, @pqty = 5, @pdate = 20200812;
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2, @pqty = 5, @pdate = 20200908; 
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 3, @pqty = 5, @pdate = 20200909;
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2, @pqty = 5, @pdate = 20200910;
GO 

SELECT *
FROM [SALE];

GO

SELECT *
FROM CUSTOMER;

GO

SELECT *
FROM PRODUCT;

/* GO
DELETE from SALE; */

GO

-- GET_ALLSALES --- works begin here ---------------------------------------------------------

IF OBJECT_ID('GET_ALL_SALES') IS NOT NULL
DROP PROCEDURE GET_ALL_SALES;
GO
CREATE PROCEDURE GET_ALL_SALES @POUTCUR CURSOR VARYING OUTPUT
AS

BEGIN
    SET @POUTCUR = CURSOR FOR
    SELECT *
    FROM SALE;
 
    OPEN @POUTCUR;
END
GO

BEGIN
    BEGIN TRY
        DECLARE @outSALES as CURSOR;
        DECLARE @outSALEID BIGINT, @outCUSTID INT, @outPRODID INT, @outQTY INT, @outPRICE MONEY, @outSALEDATE DATE


        EXEC GET_ALL_SALES @POUTCUR = @outSALES OUTPUT

        -- this line tests whether something can be returned
        FETCH NEXT FROM @outSALES INTO @outSALEID, @outCUSTID, @outPRODID, @outQTY, @outPRICE, @outSALEDATE;
        -- this is the sentinel value for the while loop until there are no more rows to fetch
        WHILE @@FETCH_status = 0
        BEGIN
            PRINT CONCAT('Sale ID: ', @outSALEID, ' Customer ID: ', @outCUSTID, ' Product ID: ', @outPRODID,' Qty: ', @outQTY, ' Price: ', @outPRICE,' Sale Date: ', @outSALEDATE)
            FETCH NEXT FROM @outSALES INTO @outSALEID, @outCUSTID, @outPRODID, @outQTY, @outPRICE, @outSALEDATE;
        END

        CLOSE @outSALES;
        DEALLOCATE @outSALES;
        
    END TRY
    BEGIN CATCH
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 

    END CATCH

END

GO


-- COUNT_PRODUCT_SALES ------- works below here ------------------------------------------------------

IF OBJECT_ID('COUNT_PRODUCT_SALES') IS NOT NULL
DROP PROCEDURE COUNT_PRODUCT_SALES;
GO

CREATE PROCEDURE COUNT_PRODUCT_SALES @pdays INTEGER
AS
BEGIN
    BEGIN TRY
        DECLARE @DateAdd DATE
        SET @DateAdd = DATEADD(DD, @pdays, SYSDATETIME());

        RETURN(SELECT COUNT(*) 
        FROM SALE
        WHERE SALEDATE >= @DateAdd);

    END TRY

    BEGIN CATCH

        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
            THROW 50000, @ERRORMESSAGE, 1
        END; 

    END CATCH

END

GO


GO

DECLARE @Count_prod_sales INT
EXEC @Count_prod_sales = COUNT_PRODUCT_SALES @pdays = -10
PRINT CONCAT('Total sales in your selected range is ', @Count_prod_sales);
-- NOT SURE IF THIS IS WORKING EXACTLY CORRECT- NEED CHECK WITH TIM ****
GO


-- -------------------- DELETE_SALE ---- WORKS BELOW --------------------------------------------

IF OBJECT_ID('DELETE_SALE') IS NOT NULL
DROP PROCEDURE DELETE_SALE;
GO

CREATE PROCEDURE DELETE_SALE AS

BEGIN
    BEGIN TRY
        DECLARE @minsale bigint ,@productID INT, @customerID INT, @sale_PRICE MONEY
        
        SELECT @minsale = MIN(SALEID) FROM SALE;
         if @minsale is NULL
            THROW 50280, 'No Sale Rows Found', 1
        
        DECLARE @TOTAL MONEY, @sale_qty INT
        SELECT @sale_PRICE = PRICE, @customerID = CUSTID, @sale_qty = QTY, @productID = PRODID
        FROM SALE WHERE SALEID = @minsale;
        
        SET @TOTAL = @sale_qty * @sale_PRICE
        
    
        EXEC UPD_CUST_SALESYTD @pcustid = @customerID, @pamt = @TOTAL;
         
        EXEC UPD_PROD_SALESYTD @pprodid = @productID, @pamt = @TOTAL;

        DELETE from SALE
        WHERE SALEID = @minsale; 

        
       
 
    END TRY
    BEGIN CATCH
       
        IF ERROR_NUMBER() IN (50280)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 
            END; 

    END CATCH;
    
END

GO

DELETE FROM SALE

GO
-- THIS SHOULD ERROR OUT
EXEC DELETE_SALE

GO
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2, @pqty = 5, @pdate = 20200612; 
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 3, @pqty = 5, @pdate = 20200712;
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2, @pqty = 5, @pdate = 20200812;
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2, @pqty = 5, @pdate = 20200908; 
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 3, @pqty = 5, @pdate = 20200909;
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2, @pqty = 5, @pdate = 20200910;

GO

EXEC DELETE_SALE

GO
-- results table shows 5 rows - procedure works.
Select *
FROM SALE;

go

select * 
from CUSTOMER;

GO

SELECT *
from product;

GO

-- -------------------- DELETE_ALL_SALES ---- WORKS BELOW --------------------------------------------

IF OBJECT_ID('DELETE_ALL_SALES') IS NOT NULL
DROP PROCEDURE DELETE_ALL_SALES;
GO

CREATE PROCEDURE DELETE_ALL_SALES AS

BEGIN
    BEGIN TRY
      
        DELETE from SALE;
           
        UPDATE CUSTOMER
        SET SALES_YTD = 0;
        UPDATE PRODUCT
        SET SALES_YTD = 0;

    END TRY

    BEGIN CATCH
       
        IF ERROR_NUMBER() IN (50280)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
            END; 

    END CATCH;


END 

GO

EXEC DELETE_ALL_SALES;

Go

SELECT 'Check Sales' as 'Check sales are del', *
FROM SALE;

go

SELECT *
FROM PRODUCT;

GO

SELECT *
FROM CUSTOMER;

GO
-- -------------------- DELETE_CUSTOMER ---- WORKS BELOW --------------------------------------------

IF OBJECT_ID('DELETE_CUSTOMER') IS NOT NULL
DROP PROCEDURE DELETE_CUSTOMER;
GO

CREATE PROCEDURE DELETE_CUSTOMER @pCustid INT AS

BEGIN
    BEGIN TRY
        DELETE from CUSTOMER
        WHERE CUSTID = @pCustid
        IF @@ROWCOUNT = 0
            THROW 50290, 'Customer ID not found', 1
        

    END TRY

    BEGIN CATCH
       
        IF ERROR_NUMBER() IN (50290)
            THROW
        IF ERROR_NUMBER() = 547
            THROW 50300, 'Customer cannot be deleted as sales exist', 1
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 
            END; 

    END CATCH;


END

GO
-- SETUP TESTING HERE TO CHECK THE CHILD COMPLEX SALES ERROR - TESTED WORKING.

EXEC UPD_CUSTOMER_STATUS  @pcustid = 3, @pstatus = 'ok';

GO

EXEC ADD_CUSTOMER @pcustid = 10, @pcustname = 'Augusto C. Sandino';

GO
SELECT 'Check customer b4' as 'Check cust b4', *
from Customer

GO

EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2, @pqty = 5, @pdate = 20200612; 
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 3, @pqty = 5, @pdate = 20200712;
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 2, @pqty = 5, @pdate = 20200812;
EXEC ADD_COMPLEX_SALE @pcustid = 3, @pprodid = 2, @pqty = 5, @pdate = 20200908; 
EXEC ADD_COMPLEX_SALE @pcustid = 1, @pprodid = 3, @pqty = 5, @pdate = 20200909;
EXEC ADD_COMPLEX_SALE @pcustid = 3, @pprodid = 2, @pqty = 5, @pdate = 20200910;

GO 
/* -- this tests the error
 EXEC DELETE_CUSTOMER @pcustid = 2;  */

GO
-- THIS TESTS THE ERROR
EXEC DELETE_CUSTOMER @pcustid = 10;

GO

SELECT 'Check customer' as 'Check cust delete', *
from Customer

GO
---------------------DELETE_PRODUCT works to follow here --------------------------------------------------------

IF OBJECT_ID('DELETE_PRODUCT') IS NOT NULL
DROP PROCEDURE DELETE_PRODUCT;
GO

CREATE PROCEDURE DELETE_PRODUCT @pProdid INT AS
BEGIN
    BEGIN TRY
        DELETE from PRODUCT
        WHERE PRODID = @pProdid
        IF @@ROWCOUNT = 0
            THROW 50310, 'Product ID not found', 1
        

    END TRY

    BEGIN CATCH
       
        IF ERROR_NUMBER() IN (50310)
            THROW
        IF ERROR_NUMBER() = 547
            THROW 50320, 'Product cannot be deleted as sales exist', 1
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 
            END; 

    END CATCH;


END


GO 
-- this tests the product id error
 EXEC DELETE_PRODUCT @pProdid = 212;  

GO
-- this test the sales exist error
EXEC DELETE_PRODUCT @pProdid = 3;

GO

SELECT 'Check prod' as 'Check prod delete', *
from Product

GO