--*************************************************************************--
-- Title: Assignment06
-- Author: Laura Truong
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-05-15,Laura Truong,Created File
-- 2021-05-17, Laura Truong, Added code to complete tasks #1-10 in assignment
-- 2021-05-18, Laura Truong, Reviewed code to check if queries are consistent and run
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_TruongLaura')
	 Begin 
	  Alter Database [Assignment06DB_TruongLaura] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_TruongLaura;
	 End
	Create Database Assignment06DB_TruongLaura;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_TruongLaura;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
/**'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'**/

-- Question 1 (5% pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

-- Create View for Categories Table.
go
Create View vCategories
With SchemaBinding
As
	Select CategoryID, CategoryName
	From dbo.Categories;
go

-- Create View for Products Table.
go
Create View vProducts
With SchemaBinding
As
	Select ProductID, ProductName, CategoryID, UnitPrice
	From dbo.Products;

go

-- Create View for Employees Table.
go
Create View vEmployees
With SchemaBinding
As
	Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	From dbo.Employees;
go

-- Create View for Inventories Table.
go
Create View vInventories
With SchemaBinding
As
	Select InventoryID,InventoryDate,EmployeeID, ProductID, [Count]
	From dbo.Inventories;
go


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--Set permissions for Categories
Deny Select On Categories To Public;
Grant Select On vCategories To Public;

--Set permissions for Products
Deny Select On Products To Public;
Grant Select On vProducts To Public;

--Set permissions for Employees
Grant Select On vEmployees To Public;
Deny Select On Employees To Public;

--Set permissions for Inventories
Grant Select On vInventories To Public;
Deny Select On Inventories To Public;


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

go
Create View vProductsByCategories
As
	Select Top 10000 CategoryName, ProductName, UnitPrice
	From vCategories 
	Inner Join vProducts
	On vCategories.CategoryID = vProducts.CategoryID
	Order By CategoryName, ProductName;
go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

go
Create View vInventoriesByProductsByDates
As
	Select Top 10000 ProductName, InventoryDate, [Count]
	From vProducts 
	Inner Join vInventories
	On vProducts.ProductID = vInventories.ProductID
	Order By ProductName, InventoryDate, [Count];
go


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

go
Create View vInventoriesByEmployeesByDates
As
	Select Distinct Top 10000 InventoryDate, EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName
	From vInventories 
	Inner Join vEmployees
	On vInventories.EmployeeID = vEmployees.EmployeeID
	Order By InventoryDate;
go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

go
Create View vInventoriesByProductsByCategories
As
	Select Top 10000 CategoryName,ProductName, InventoryDate, [Count]
	From vCategories 
	Inner Join vProducts
	On vCategories.CategoryID = vProducts.CategoryID
	Inner Join vInventories
	On vProducts.ProductID = vInventories.ProductID
	Order By CategoryName, ProductName, InventoryDate, [Count];
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

go
Create View vInventoriesByProductsByEmployees
As
	Select Top 10000 CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName
	From vCategories 
	Inner Join vProducts
	On vCategories.CategoryID = vProducts.CategoryID
	Inner Join vInventories
	On vProducts.ProductID = vInventories.ProductID
	Inner Join vEmployees
	On vInventories.EmployeeID = vEmployees.EmployeeID
	Order By InventoryDate, CategoryName, ProductName, EmployeeName;
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

go
Create View vInventoriesForChaiAndChangByEmployees
As
	Select Top 10000 CategoryName, ProductName, InventoryDate, [Count], EmployeeFirstName + ' ' + EmployeeLastName As EmployeeName
	From vCategories 
	Inner Join vProducts
	On vCategories.CategoryID = vProducts.CategoryID
	Inner Join vInventories
	On vProducts.ProductID = vInventories.ProductID
	Inner Join vEmployees
	On vInventories.EmployeeID = vEmployees.EmployeeID
	Where ProductName IN ('Chai', 'Chang')
	Order By InventoryDate, CategoryName, ProductName;

go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

go
Create View vEmployeesByManager
As
	Select Top 10000 Manager.EmployeeFirstName + ' ' + Manager.EmployeeLastName As Manager, Employee.EmployeeFirstName + ' ' + Employee.EmployeeLastName As Employee
	From vEmployees As Employee 
	Inner Join vEmployees As Manager
	On Manager.EmployeeID = Employee.ManagerID
	Order By Manager, Employee;
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan


Go
Create View vInventoriesByProductsByCategoriesByEmployees
As 
  Select vCategories.CategoryID, vCategories.CategoryName , vProducts.ProductID, vProducts.ProductName, vProducts.UnitPrice, vInventories.InventoryID, vInventories.InventoryDate, vInventories.[Count], emp.EmployeeID, Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName As Employee, Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName As Manager
  From Employees As Emp
  Join Employees As Mgr
  On Emp.ManagerID = Mgr.EmployeeID 
  Join vInventories
  On Emp.EmployeeID = vInventories.EmployeeID
  Join vProducts
  On vInventories.ProductID = vProducts.ProductID
  Join vCategories
  On vProducts.CategoryID = vCategories.CategoryID;
Go

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/