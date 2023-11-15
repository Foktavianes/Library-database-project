CREATE PROCEDURE dbo.LibraryDatabaseManagement
AS
BEGIN 
  USE master;
  CREATE DATABASE db_LibraryDatabase;
  CREATE TABLE publisher (
          PublisherID INT PRIMARY KEY IDENTITY(1,1),
          Name VARCHAR(255) NOT NULL,
          Phone VARCHAR(25) NOT NULL,
          Email VARCHAR(100),
          Address VARCHAR(100),
  );

  CREATE TABLE book (
          BookID INT PRIMARY KEY IDENTITY(1,1),
          Title VARCHAR(255) NOT NULL,
          Year INT NOT NULL,
          PublisherID INT,
          CONSTRAINT FK_PublisherID FOREIGN KEY (PublisherID) REFERENCES Publisher(PublisherID)
  );

  CREATE TABLE borrower (
          BorrowerID INT PRIMARY KEY IDENTITY(1,1),
          Name VARCHAR(255) NOT NULL,
          Phone INT NOT NULL,
          MembershipStatus VARCHAR(20),
          MembershipExpiryDate DATE
  );

  CREATE TABLE LibraryData (
          LibraryID INT PRIMARY KEY IDENTITY(1,1),
          LibraryName VARCHAR(255) NOT NULL,
          Location VARCHAR(255),
          EstablishmentYear INT
);

  CREATE TABLE BookLoan (
          LoanID INT PRIMARY KEY IDENTITY(1,1),
          BorrowerID INT,
          BookID INT,
          LibraryID INT,
          LoanDate DATE,
          ReturnDate DATE,
          CONSTRAINT FK_BorrowerID FOREIGN KEY (BorrowerID) REFERENCES Borrower(BorrowerID),
          CONSTRAINT FK_BookID FOREIGN KEY (BookID) REFERENCES Book(BookID),
          CONSTRAINT FK_LibraryID FOREIGN KEY (LibraryID) REFERENCES LibraryData(LibraryID)
);

-- Insert data into the publisher table
INSERT INTO publisher (Name, Phone, Email, Address)
VALUES
    ('Scholastic', '123-456-7890', 'info@scholastic.com', '123 Main Street'),
    ('Suzanne Collins Books', '987-654-3210', 'info@suzannecollinsbooks.com', '456 Oak Avenue');

-- Insert data into the book table 
INSERT INTO book (Title, Year, PublisherID)
VALUES
    ('Harry Potter and the Philosopher''s Stone', 1997, 1),
    ('Harry Potter and the Chamber of Secrets', 1998, 1),
    ('Harry Potter and the Prisoner of Azkaban', 1999, 1),
    ('Harry Potter and the Goblet of Fire', 2000, 1),
    ('Harry Potter and the Order of the Phoenix', 2003, 1),
    ('Harry Potter and the Half-Blood Prince', 2005, 1),
    ('Harry Potter and the Deathly Hallows', 2007, 1),
    ('The Hunger Games', 2008, 2),
    ('Catching Fire', 2009, 2),
    ('Mockingjay', 2010, 2);

-- Insert data into the borrower table
INSERT INTO borrower (Name, Phone, MembershipStatus, MembershipExpiryDate)
VALUES
    ('Hermione Granger', 555-1234, 'Active', '2023-12-31'),
    ('Ron Weasley', 555-5678, 'Active', '2023-12-31'),
    ('Katniss Everdeen', 555-4321, 'Active', '2023-12-31'),
    ('Peeta Mellark', 555-8765, 'Active', '2023-12-31');

-- Insert data into the LibraryData table
INSERT INTO LibraryData (LibraryName, Location, EstablishmentYear)
VALUES
    ('City Library', 'Downtown', 1990),
    ('Suburb Library', 'Suburbia', 2005);

-- Insert data into the BookLoan table
INSERT INTO BookLoan (BorrowerID, BookID, LibraryID, LoanDate, ReturnDate)
VALUES
    (1, 1, 1, '2023-01-01', '2023-02-01'),
    (2, 2, 1, '2023-01-15', '2023-02-15'),
    (3, 8, 2, '2023-02-01', '2023-03-01'),
    (4, 9, 2, '2023-03-15', '2023-04-15');

---------------------------- QUERY QUESTIONS -------------------------
#1 Find available books and their locations

SELECT
    b.Title AS BookTitle,
    l.LibraryName AS LibraryName
FROM
    book b
JOIN
    LibraryData l ON b.PublisherID = l.LibraryID
WHERE
    b.BookID NOT IN (SELECT DISTINCT BookID FROM BookLoan WHERE ReturnDate IS NULL);

#2 Retrieve Borrower Information for a Specific Book

SELECT
    b.Title AS BookTitle,
    br.Name AS BorrowerName,
    bl.LoanDate,
    bl.ReturnDate
FROM
    BookLoan bl
JOIN
    book b ON bl.BookID = b.BookID
JOIN
    borrower br ON bl.BorrowerID = br.BorrowerID
WHERE
    b.Title = 'Harry Potter and the Philosopher''s Stone';

#3 List of Overdue Books

SELECT
    b.Title AS BookTitle,
    br.Name AS BorrowerName,
    bl.LoanDate,
    bl.ReturnDate
FROM
    BookLoan bl
JOIN
    book b ON bl.BookID = b.BookID
JOIN
    borrower br ON bl.BorrowerID = br.BorrowerID
WHERE
    bl.ReturnDate IS NULL AND GETDATE() > bl.LoanDate;

#4 Find Library with most book selections

SELECT
    l.LibraryName,
    COUNT(b.BookID) AS NumberOfBooks
FROM
    LibraryData l
LEFT JOIN
    book b ON l.LibraryID = b.PublisherID
GROUP BY
    l.LibraryName
ORDER BY
    NumberOfBooks DESC;

#5 Count Books by Publisher

SELECT
    p.Name AS PublisherName,
    COUNT(b.BookID) AS NumberOfBooks
FROM
    publisher p
LEFT JOIN
    book b ON p.PublisherID = b.PublisherID
GROUP BY
    p.Name;