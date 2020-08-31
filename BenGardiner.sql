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

-- END PROVIDED DDL ----- BEGIN TSQL WORK ---------------------

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

select * from customer;

GO
-- addding some data back in to test further queries
EXEC ADD_CUSTOMER @pcustid = 1, @pcustname = 'testdude2';
EXEC ADD_CUSTOMER @pcustid = 2, @pcustname = 'testdude3';
EXEC ADD_CUSTOMER @pcustid = 3, @pcustname = 'testdude5';

GO

-- BEGIN "ADD PRODUCT" STORED PROCEDURE

IF OBJECT_ID('ADD_PRODUCT') IS NOT NULL
DROP PROCEDURE ADD_PRODUCT;
GO

CREATE PROCEDURE ADD_PRODUCT @pprodid INT, @pprodname NVARCHAR(100), @pprice MONEY AS

BEGIN
    BEGIN TRY

        IF @pprodid < 1000 OR @pprodid > 2500
            THROW 50040, 'Product ID out of range', 1
        ELSE if @pprice < 0 OR @pprice > 999.99
             THROW 50050, 'Product price out of range', 1
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



-- begin get customer string work here --- - - - - - - -

IF OBJECT_ID('GET_CUSTOMER_STRING') IS NOT NULL
DROP PROCEDURE GET_CUSTOMER_STRING;
GO

CREATE PROCEDURE GET_CUSTOMER_STRING @pcustid INT, @pReturnString NVARCHAR(100) OUTPUT AS

BEGIN
    BEGIN TRY
        DECLARE @cName NVARCHAR(100), @ytd money, @status NVARCHAR(7);
        SELECT @cName = Custname, @ytd = SALES_YTD , @status  = [status] from CUSTOMER where CUSTID = @pcustid;
    END TRY
    BEGIN CATCH
        IF @@ROWCOUNT = 0
        -- custom error below
        THROW 50060, 'CustomerID not found', 1 
    END CATCH
    set @pReturnString = CONCAT('Custid: ', @pcustid, 'Name: ', @cName, 'Status: ', @status,  'SalesYTD: ',@ytd)
END;

GO

BEGIN

DECLARE @externalParam NVARCHAR(100)

EXEC GET_CUSTOMER_STRING @pcustid = 3, @pReturnString = @externalParam OUTPUT


print @externalParam

END


-- begin UPD_CUST_SALESYTD work here - - -- - - -
-- Update one customer's sales_ytd value in the customer table


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

-- test with positive num
BEGIN

EXEC UPD_CUST_SALESYTD @pcustid = 2, @pamt = 344;

END

-- test with out of range
BEGIN

EXEC UPD_CUST_SALESYTD @pcustid = 2, @pamt = 9000;

END

-- test with custID not found
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

        set @pReturnString = CONCAT('Prodid: ', @pprodid, 'Name: ', @pprodname, 'Price: ' , @sellprice ,'SalesYTD: ',@ytd);

    END TRY

    BEGIN CATCH

    IF ERROR_NUMBER() IN (50060)
        THROW
    ELSE
    
        BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX) = ERROR_MESSAGE();
                THROW 50000, @ERRORMESSAGE, 1
        END;
        
    END CATCH
    
END

GO

BEGIN

DECLARE @externalParam NVARCHAR(100)

EXEC GET_PROD_STRING @pprodid = 1001, @pReturnString = @externalParam OUTPUT


print @externalParam

END 

-- error handling not working here - it should be givingn me an error but instead prints out the line still
-- https://www.techonthenet.com/sql_server/procedures.php --- this website is good