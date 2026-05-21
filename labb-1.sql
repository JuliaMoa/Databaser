USE everyloop_restored

SELECT Spacecraft, [Launch date], [Carrier rocket], Operator, [Mission type]
INTO SuccessfulMissions
FROM MoonMissions
WHERE [Outcome] IN ('Sucess', 'Successful');

GO

UPDATE SuccessfulMissions
SET [Operator] = LTRIM([Operator]);

GO

UPDATE SuccessfulMissions
SET Spacecraft = LTRIM(RTRIM(LEFT(Spacecraft, CHARINDEX('(', Spacecraft + '(') -1)));

GO

SELECT Operator, [Mission type], COUNT(*) AS [Mission count]
FROM SuccessfulMissions
GROUP BY Operator, [Mission type] 
HAVING COUNT(*) > 1 
ORDER BY Operator, [Mission type], [Mission count]

GO 

SELECT *
FROM Users;

SELECT *,
FirstName + ' ' + LastName AS Name,
CASE  
    WHEN CAST(SUBSTRING(ID, LEN(ID) -1, 1) AS INT) % 2 = 0 
    THEN 'Female'
    ELSE 'Male'
END AS Gender
INTO NewUsers
FROM Users;

GO

SELECT UserName, COUNT(*) AS RepeatCount
FROM NewUsers
GROUP BY UserName 
Having COUNT(*) > 1;

GO

WITH x AS (
    SELECT
        ID,
        UserName,
        ROW_NUMBER() OVER (PARTITION BY UserName ORDER BY ID) AS rn
    FROM NewUsers
    WHERE UserName IN (
        SELECT UserName
        FROM NewUsers 
        GROUP BY UserName
        HAVING COUNT(*) > 1
    )
)
SELECT  
    ID,
    UserName,
    UserName + '_' + CAST(rn AS NVARCHAR(10)) AS NewUserName
FROM x;

SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'NewUsers' AND COLUMN_NAME = 'UserName';

ALTER TABLE NewUsers
ALTER COLUMN UserName NVARCHAR(50);

WITH x AS (
    SELECT
        ID,
        UserName,
        ROW_NUMBER() OVER (PARTITION BY UserName ORDER BY ID) AS rn
    FROM NewUsers
    WHERE UserName IN (
        SELECT UserName
        FROM NewUsers 
        GROUP BY UserName
        HAVING COUNT(*) > 1
    )
)
UPDATE x
SET UserName = UserName + '_' + CAST(rn AS NVARCHAR(10));

SELECT UserName, COUNT(*)
FROM NewUsers
GROUP BY UserName
HAVING COUNT(*) > 1;

GO

DELETE FROM NewUsers
WHERE Gender = 'Female'
    AND CAST(LEFT(ID, 2) AS INT) < 70;

GO

INSERT INTO NewUsers (ID, UserName, Gender)
VALUES ('7504295542', 'newuser', 'Female');

GO

SELECT 
    Gender,
    AVG(
        DATEDIFF(
            YEAR,
            CONVERT(date, 
                CAST(LEFT(ID, 2) AS int) + 1900
                || '-' ||
                SUBSTRING(ID, 3, 2)
                || '-' ||
                SUBSTRING(ID, 5, 2)
            ),
            GETDATE()
        )
    ) AS AverageAge
FROM NewUsers
GROUP BY Gender;

GO

SELECT company.products.Id, ProductName AS Product, CompanyName as Supplier, CategoryName as Category
FROM company.products 
JOIN company.suppliers ON company.products.SupplierId = company.suppliers.Id
JOIN company.categories ON company.products.CategoryId = company.categories.Id

GO

SELECT r.RegionDescription AS REGION, 
COUNT(DISTINCT(EmployeeId)) AS EmployeeCount
FROM company.regions r
JOIN company.territories t ON r.Id = t.RegionId
JOIN company.employee_territory et ON et.TerritoryId = t.Id
GROUP BY r.RegionDescription;

GO

SELECT 
    e.Id as Id, 
    e.Title + ' ' + e.FirstName + ' ' + e.LastName AS Name, 
    COALESCE(
    m.Title + ' ' + m.FirstName + ' ' + m.LastName, 'Nobody!') AS [Reports to]

FROM company.employees e 
LEFT JOIN company.employees m 
    ON e.ReportsTo = m.Id
ORDER BY e.Id;