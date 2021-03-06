USE [StockManagement]
GO
/****** Object:  Table [dbo].[Brands]    Script Date: 2.1.2019 14:35:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Brands](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BrandName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Brands] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PhoneCases]    Script Date: 2.1.2019 14:35:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PhoneCases](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [nvarchar](150) NULL,
	[Price] [decimal](18, 2) NULL,
	[CaseColor] [int] NULL,
	[StockQTY] [int] NULL,
 CONSTRAINT [PK_PhoneCases] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Phones]    Script Date: 2.1.2019 14:35:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Phones](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Price] [decimal](18, 2) NULL,
	[ProductName] [nvarchar](150) NULL,
	[IMEI1] [nvarchar](50) NULL,
	[IMEI2] [nvarchar](50) NULL,
	[BrandID] [int] NULL,
	[ModelCode] [nvarchar](50) NULL,
	[StockQTY] [int] NULL,
 CONSTRAINT [PK_Phones] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Phones] ADD  CONSTRAINT [DF_Phones_StockQTY]  DEFAULT ((0)) FOR [StockQTY]
GO
/****** Object:  StoredProcedure [dbo].[DeleteBrand]    Script Date: 2.1.2019 14:35:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[DeleteBrand] 
@ID int 
AS
BEGIN
	DELETE FROM Brands WHERE ID = @ID
END
GO
/****** Object:  StoredProcedure [dbo].[DeletePhone]    Script Date: 2.1.2019 14:35:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeletePhone]
@ID int
AS
BEGIN
	DELETE FROM Phones WHERE ID = @ID
END
GO
/****** Object:  StoredProcedure [dbo].[GetAvailableProducts]    Script Date: 2.1.2019 14:35:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetAvailableProducts]
@q as nvarchar(50) = NULL
AS
BEGIN

DECLARE @sql AS nvarchar(MAX)
SET @sql = 'SELECT ID, ProductName, Price, IMEI1, IMEI2 FROM Phones '

IF (@q IS NOT NULL)
BEGIN
	SET @sql += 'WHERE StockQTY != 0 AND (ProductName LIKE ''%'+@q+'%'''
	SET @sql += 'OR IMEI1 LIKE ''%'+@q+'%'''
	SET @sql += 'OR IMEI2 LIKE ''%'+@q+'%'''
	SET @sql += 'OR ModelCode LIKE ''%'+@q+'%'')'
END
	ELSE
		SET @sql += 'WHERE StockQTY != 0'

SET @sql += ' UNION ALL '
SET @sql += 'SELECT ID, ProductName, Price, '''', '''' FROM PhoneCases '

IF (@q IS NOT NULL)
	SET @sql += 'WHERE StockQTY != 0 AND ProductName LIKE ''%'+@q+'%'''
ELSE
	SET @sql += 'WHERE StockQTY != 0'

--SELECT @sql
exec (@sql)
END

GO
/****** Object:  StoredProcedure [dbo].[GetPhones]    Script Date: 2.1.2019 14:35:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GetPhones]
AS
BEGIN
	SELECT p.*, b.ID AS BID, b.BrandName 
	FROM Phones p
	INNER JOIN Brands b
	ON p.BrandID = b.ID
	ORDER BY BrandID,ProductName
END
GO
/****** Object:  StoredProcedure [dbo].[InsertPhone]    Script Date: 2.1.2019 14:35:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[InsertPhone]
@productName nvarchar(150), @price decimal,
@IMEI1 nvarchar(50), @IMEI2 nvarchar(50),
@modelCode nvarchar(50), @brandId int
AS
BEGIN
	INSERT INTO Phones (ProductName, Price, IMEI1, IMEI2, ModelCode, BrandID)
	VALUES (@productName, @price, @IMEI1, @IMEI2, @modelCode, @brandId)
END
GO
/****** Object:  StoredProcedure [dbo].[sp_addStock]    Script Date: 2.1.2019 14:35:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_addStock]
@id int, @qty int
AS
BEGIN
	UPDATE PhoneCases SET StockQTY = StockQTY + @qty
	WHERE ID = @id
END
GO
/****** Object:  StoredProcedure [dbo].[sp_CreatePhoneCase]    Script Date: 2.1.2019 14:35:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_CreatePhoneCase]
@name nvarchar(150),
@price decimal,
@color int,
@qty int
AS
BEGIN
	INSERT INTO PhoneCases (ProductName, Price, CaseColor, StockQTY)
	SELECT @name, @price, @color, @qty
END
GO
/****** Object:  StoredProcedure [dbo].[sp_searchPhone]    Script Date: 2.1.2019 14:35:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[sp_searchPhone]
@BID int, @modelCode nvarchar(50)
AS
BEGIN
	SELECT * FROM Phones p
	INNER JOIN Brands b
	ON p.BrandID = b.ID
	WHERE 
	(p.BrandID = @BID OR @BID =0) 
	AND
	(ModelCode LIKE '%'+@modelCode+'%' OR 
	@modelCode = '')
END
GO
