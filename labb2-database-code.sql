
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

--- ovan är executed, vänta med tabellerna tills de är klara

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

