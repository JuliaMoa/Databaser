
--- 4 gjorda, 4 tabeller kvar
--- demodata - be chatten utefter mina tabeller

--- 2 vyer
--- Saved Procedure "moving book"

--- author/book relationshiop = manytomany GJORT
--- extra view

--- ge rättigheter med lösen, ge 

--- ER-diagram, när db är klar, i SSMS

CREATE DATABASE BookStoreDB;
GO -- kommandoavgränsare

USE BookStoreDB;
GO 

CREATE TABLE Authors (
    ID INT IDENTITY(1,1) PRIMARY KEY, -- auto unique och not null
    FirstName NVARCHAR(50) NOT NULL CHECK (LEN(LTRIM(RTRIM(FirstName))) > 0),
    LastName NVARCHAR(50) NOT NULL CHECK (LEN(LTRIM(RTRIM(LastName))) > 0),
    DateOfBirth DATE CHECK (DateOfBirth <= GETDATE()),

    CONSTRAINT unique_authors UNIQUE (FirstName, LastName, DateOfBirth)
);

CREATE TABLE Books (
    ISBN13 CHAR(13) PRIMARY KEY,    -- alltid 13 tecken, inte ett tal som ska räknas med
    Title NVARCHAR(50) NOT NULL CHECK (LEN(LTRIM(RTRIM(Title))) > 0),
    [Language] NVARCHAR(50) NOT NULL,
    ReleaseDate DATE CHECK (ReleaseDate <= GETDATE()),
    AuthorID INT,
    -- följande endast rätt för one-to-many, för many-to-many behövs junction table
    CONSTRAINT fk_books_authors1
        FOREIGN KEY (AuthorID) REFERENCES Authors(ID) 
);

CREATE TABLE Stores (
    StoreID INT IDENTITY(1,1) PRIMARY KEY,
    StoreName NVARCHAR(50) NOT NULL, 
    [Address] NVARCHAR(50)
);


--junction
CREATE TABLE StockQuantity (
    StoreID INT NOT NULL,
    ISBN13 CHAR(13) NOT NULL,
    QuantityInStock INT NOT NULL CHECK (QuantityInStock >= 0),

    CONSTRAINT pk_stock_quantity
        PRIMARY KEY (StoreID, ISBN13),
    
    CONSTRAINT fk_stock_store
        FOREIGN KEY(StoreID) REFERENCES Stores(StoreID),

    CONSTRAINT fk_stock_book
        FOREIGN KEY(ISBN13) REFERENCES Books(ISBN13)
);

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(50) NOT NULL,
    Phone NVARCHAR(50) NOT NULL
);
 --- Orders ska ha fk till customers, inte tvärtom

CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    StoreID INT,

    CONSTRAINT fk_customerID_orders
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT fk_orders_store
        FOREIGN KEY (StoreID) REFERENCES Stores(StoreID)  
);

-- junction table, ingen IDENTITY
CREATE TABLE OrderItems (
    OrderID INT NOT NULL,
    ISBN13 CHAR(13) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    PriceAtPurchase INT NOT NULL,

    CONSTRAINT pk_orderitems
        PRIMARY KEY (OrderID, ISBN13),

    CONSTRAINT fk_order_books
        FOREIGN KEY (ISBN13) REFERENCES Books(ISBN13),
    
    CONSTRAINT fk_orderitems_orders
        FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

ALTER TABLE Books
ADD PublisherID INT; 

CREATE TABLE Publisher (
    PublisherID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Country NVARCHAR(500),
    FoundedYear INT
);

ALTER TABLE Books
ADD CONSTRAINT fk_books_publisher 
    FOREIGN KEY (PublisherID) REFERENCES Publisher(PublisherID);

---- update many-to-many relationship books/authors
ALTER TABLE Books
DROP CONSTRAINT fk_books_authors1;

ALTER TABLE Books
DROP COLUMN AuthorID;


-- junction table for many-to-many relationship
CREATE TABLE Books_Authors (
    ISBN13 CHAR(13) NOT NULL,
    AuthorID INT NOT NULL,

    CONSTRAINT pk_books_authors
        PRIMARY KEY (ISBN13, AuthorID),
    
    CONSTRAINT fk_books_authors_book
        FOREIGN KEY (ISBN13) REFERENCES Books(ISBN13),
    
    CONSTRAINT fk_books_authors_author
        FOREIGN KEY (AuthorID) REFERENCES Authors(ID)
);  

CREATE TABLE Prices (
    ISBN13 CHAR(13) NOT NULL,
    Price INT NOT NULL CHECK (Price >= 0),
    ValidFrom DATE NOT NULL DEFAULT GETDATE(),

    CONSTRAINT pk_prices PRIMARY KEY (ISBN13, ValidFrom),
    CONSTRAINT fk_prices_books FOREIGN KEY (ISBN13) REFERENCES Books(ISBN13)
)

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL UNIQUE
);

ALTER TABLE Books
ADD CategoryID INT;

ALTER TABLE Books
ADD CONSTRAINT fk_books_category
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID);


---- ovan executed
INSERT INTO Categories (CategoryName)
VALUES
('Children'),
('Fantasy'),
('Classic'),
('Dystopian'),
('Literary Fiction');

INSERT INTO Publisher (Name, Country, FoundedYear)
VALUES
('Norstedts', 'Sweden', 1823),
('Bonnier Books', 'Sweden', 1804),
('Penguin Random House', 'USA', 1927),
('HarperCollins', 'USA', 1817);

INSERT INTO Authors (FirstName, LastName, DateOfBirth)
VALUES
('Astrid', 'Lindgren', '1907-11-14'),
('J.K.', 'Rowling', '1965-07-31'),
('George', 'Orwell', '1903-06-25'),
('Haruki', 'Murakami', '1949-01-12');

INSERT INTO Books (ISBN13, Title, [Language], ReleaseDate, PublisherID, CategoryID)
VALUES
('9789129700001', 'Pippi Långstrump', 'Swedish', '1945-01-01', 1, 1),
('9789129700002', 'Bröderna Lejonhjärta', 'Swedish', '1973-01-01', 1, 1),
('9789129700003', 'Ronja Rövardotter', 'Swedish', '1981-01-01', 1, 1),
('9789129700004', 'Mio min Mio', 'Swedish', '1954-01-01', 1, 1),

('9780747532743', 'Harry Potter and the Philosopher''s Stone', 'English', '1997-06-26', 3, 2),
('9780747538493', 'Harry Potter and the Chamber of Secrets', 'English', '1998-07-02', 3, 2),

('9780451524935', '1984', 'English', '1949-06-08', 3, 4),
('9780141036144', 'Animal Farm', 'English', '1945-08-17', 3, 4),

('9780307277671', 'Kafka on the Shore', 'English', '2002-09-12', 4, 5),
('9780099448761', 'Norwegian Wood', 'English', '1987-09-04', 4, 5);

INSERT INTO Books_Authors (ISBN13, AuthorID)
VALUES
('9789129700001', 1),
('9789129700002', 1),
('9789129700003', 1),
('9789129700004', 1),

('9780747532743', 2),
('9780747538493', 2),

('9780451524935', 3),
('9780141036144', 3),

('9780307277671', 4),
('9780099448761', 4);

INSERT INTO Prices (ISBN13, Price, ValidFrom)
VALUES
('9789129700001', 129, '2024-01-01'),
('9789129700002', 149, '2024-01-01'),
('9789129700003', 129, '2024-01-01'),
('9789129700004', 119, '2024-01-01'),

('9780747532743', 199, '2024-01-01'),
('9780747538493', 199, '2024-01-01'),

('9780451524935', 99,  '2024-01-01'),
('9780141036144', 89,  '2024-01-01'),

('9780307277671', 159, '2024-01-01'),
('9780099448761', 139, '2024-01-01');

INSERT INTO Stores (StoreName, [Address])
VALUES
('Göteborg City Books', 'Avenyn 12'),
('Stockholm Central Books', 'Drottninggatan 5'),
('Malmö BookPoint', 'Stortorget 3');

INSERT INTO StockQuantity (StoreID, ISBN13, QuantityInStock)
VALUES
-- Store 1
(1, '9789129700001', 12),
(1, '9789129700002', 8),
(1, '9789129700003', 9),
(1, '9789129700004', 11),
(1, '9780747532743', 15),
(1, '9780747538493', 10),
(1, '9780451524935', 20),
(1, '9780141036144', 18),
(1, '9780307277671', 6),
(1, '9780099448761', 7),

-- Store 2
(2, '9789129700001', 5),
(2, '9789129700002', 4),
(2, '9789129700003', 7),
(2, '9789129700004', 6),
(2, '9780747532743', 12),
(2, '9780747538493', 9),
(2, '9780451524935', 14),
(2, '9780141036144', 10),
(2, '9780307277671', 3),
(2, '9780099448761', 5),

-- Store 3
(3, '9789129700001', 3),
(3, '9789129700002', 2),
(3, '9789129700003', 5),
(3, '9789129700004', 4),
(3, '9780747532743', 8),
(3, '9780747538493', 6),
(3, '9780451524935', 10),
(3, '9780141036144', 9),
(3, '9780307277671', 4),
(3, '9780099448761', 3);

INSERT INTO Customers (FirstName, LastName, Email, Phone)
VALUES
('Anna', 'Svensson', 'anna@example.com', '0701234567'),
('Johan', 'Karlsson', 'johan@example.com', '0709876543'),
('Maria', 'Lindberg', 'maria@example.com', '0735551234');

INSERT INTO Orders (CustomerID, OrderDate, StoreID)
VALUES
(1, '2024-01-10', 1),
(2, '2024-02-15', 2),
(3, '2024-03-01', 3);

INSERT INTO OrderItems (OrderID, ISBN13, Quantity, PriceAtPurchase)
VALUES
(1, '9789129700001', 1, 129),
(1, '9780451524935', 1, 99),

(2, '9780747532743', 1, 199),
(2, '9780747538493', 1, 199),

(3, '9780307277671', 1, 159),
(3, '9780099448761', 1, 139);

--- ovan executed

ALTER TABLE Authors
ADD DateOfDeath DATE NULL;

-- ovan executed

UPDATE Authors
SET DateOfDeath = '2002-01-28'
WHERE FirstName = 'Astrid' AND LastName = 'Lindgren';

UPDATE Authors
SET DateOfDeath = '1950-01-21'
WHERE LastName = 'Orwell';


-- ovan executed

-- vy 1

CREATE OR ALTER VIEW TitlarPerFörfattare AS
SELECT
    A.FirstName + ' ' + A.LastName AS Namn,
    CASE 
        WHEN A.DateOfDeath IS NULL 
            THEN CAST(DATEDIFF(YEAR, A.DateOfBirth, GETDATE()) AS VARCHAR(4)) + ' år'
        ELSE 'död'
    END AS Ålder,
    CAST(COUNT(DISTINCT B.ISBN13) AS VARCHAR(10)) + ' st' AS Titlar,
    CAST(SUM(SQ.QuantityInStock * P.Price) AS VARCHAR(20)) + ' kr' AS Lagervärde
FROM Authors A
JOIN Books_Authors BA ON BA.AuthorID = A.ID
JOIN Books B ON B.ISBN13 = BA.ISBN13
JOIN StockQuantity SQ ON SQ.ISBN13 = B.ISBN13
JOIN (
    SELECT p1.ISBN13, p1.Price
    FROM Prices p1
    JOIN (
        SELECT ISBN13, MAX(ValidFrom) AS LatestDate
        FROM Prices
        GROUP BY ISBN13
    ) p2 ON p1.ISBN13 = p2.ISBN13 AND p1.ValidFrom = p2.LatestDate
) P ON P.ISBN13 = B.ISBN13
GROUP BY 
    A.FirstName, 
    A.LastName,
    A.DateOfBirth,
    A.DateOfDeath;


SELECT * FROM TitlarPerFörfattare

-- stored procedure

CREATE OR ALTER PROCEDURE FlyttaBok
    @ISBN13 CHAR(13),
    @FromStoreID INT,
    @ToStoreID INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        DECLARE @CurrentStock INT;

        -- Kontrollera att boken finns i från-butiken
        SELECT @CurrentStock = QuantityInStock
        FROM StockQuantity
        WHERE StoreID = @FromStoreID AND ISBN13 = @ISBN13;

        IF @CurrentStock IS NULL
        BEGIN
            THROW 50001, 'Boken finns inte i från-butiken.', 1;
        END

        -- Kontrollera att det finns tillräckligt antal
        IF @CurrentStock < @Quantity
        BEGIN
            THROW 50002, 'Det finns inte tillräckligt många exemplar i från-butiken.', 1;
        END

        -- Minska lagret i från-butiken
        UPDATE StockQuantity
        SET QuantityInStock = QuantityInStock - @Quantity
        WHERE StoreID = @FromStoreID AND ISBN13 = @ISBN13;

        -- Om boken inte finns i till-butiken → skapa rad
        IF NOT EXISTS (
            SELECT 1 
            FROM StockQuantity 
            WHERE StoreID = @ToStoreID AND ISBN13 = @ISBN13
        )
        BEGIN
            INSERT INTO StockQuantity (StoreID, ISBN13, QuantityInStock)
            VALUES (@ToStoreID, @ISBN13, 0);
        END

        -- Öka lagret i till-butiken
        UPDATE StockQuantity
        SET QuantityInStock = QuantityInStock + @Quantity
        WHERE StoreID = @ToStoreID AND ISBN13 = @ISBN13;

        COMMIT TRANSACTION;

        PRINT 'Flytt genomförd.';

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrNum INT = ERROR_NUMBER();

        THROW @ErrNum, @ErrMsg, 1;

    END CATCH
END;

EXEC FlyttaBok 
    @ISBN13 = '9789129700001',
    @FromStoreID = 1,
    @ToStoreID = 2,
    @Quantity = 3;

--- ovan executed och funkar trots att VS Code römarkerar

-- vy 2
CREATE OR ALTER VIEW FörsäljningPerKategori AS
SELECT
    C.CategoryName AS Kategori,
    COUNT(DISTINCT B.ISBN13) AS AntalTitlar,
    SUM(OI.Quantity) AS AntalSålda,
    SUM(OI.Quantity * P.Price) AS TotalFörsäljning,
    AVG(P.Price) AS SnittPris
FROM Categories C
JOIN Books B ON B.CategoryID = C.CategoryID
JOIN OrderItems OI ON OI.ISBN13 = B.ISBN13
JOIN (
    SELECT p1.ISBN13, p1.Price
    FROM Prices p1
    JOIN (
        SELECT ISBN13, MAX(ValidFrom) AS LatestDate
        FROM Prices
        GROUP BY ISBN13
    ) p2 ON p1.ISBN13 = p2.ISBN13 AND p1.ValidFrom = p2.LatestDate
) P ON P.ISBN13 = B.ISBN13
GROUP BY C.CategoryName;

SELECT * FROM FörsäljningPerKategori;

--- ovan executed och funkar


-- skapa användare 
--- som programmet ska använda
CREATE USER BookStoreUser FOR LOGIN BookStoreUser;

--- ovan executed 

GRANT SELECT ON dbo.Books TO BookStoreUser;
GRANT SELECT ON dbo.StockQuantity TO BookStoreUser;
GRANT SELECT ON dbo.Stores TO BookStoreUser;

-- ovan executed