USE [RestAPIDapper]
GO
/****** Object:  UserDefinedTableType [dbo].[Permission]    Script Date: 3/17/2019 10:00:02 PM ******/
CREATE TYPE [dbo].[Permission] AS TABLE(
	[RoleId] [uniqueidentifier] NULL,
	[FunctionId] [varchar](50) NOT NULL,
	[ActionId] [varchar](50) NOT NULL
)
GO
/****** Object:  StoredProcedure [dbo].[Create_Function]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	
-- Create date: 18/12/2018
-- Description:	Select one recorrd by id 
-- =============================================
CREATE PROCEDURE [dbo].[Create_Function]
	@id varchar(50),
	@name nvarchar(50),
	@url nvarchar(50),
	@parentId varchar(50),
	@sortOrder int,
	@cssClass nvarchar(50),
	@isActive bit
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [dbo].[Functions]
           ([Id]
           ,[Name]
           ,[Url]
           ,[ParentId]
           ,[SortOrder]
           ,[CssClass]
           ,[IsActive])
     VALUES
           (@id
           ,@name
           ,@url
           ,@parentId
           ,@sortOrder
           ,@cssClass
           ,@isActive)

END
GO
/****** Object:  StoredProcedure [dbo].[Create_Permission]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	
-- Create date: 11/1/2018
-- Description:	Save permissions for role id
-- =============================================
--create TYPE [dbo].[Permission] AS TABLE(
--    [RoleId] uniqueidentifier,
--    [FunctionId] [varchar](50) NOT NULL,
--    [ActionId] [varchar](50) NOT NULL
--)
--GO

create PROCEDURE [dbo].[Create_Permission]
	@roleId uniqueidentifier,
	@permissions dbo.Permission readonly
AS
BEGIN
	SET NOCOUNT ON;
	set xact_abort on;
	begin tran
	begin try
	   delete from Permissions where RoleId = @roleId

	   insert into Permissions (RoleId,FunctionId,ActionId)
	   select RoleId,FunctionId,ActionId from @permissions

	commit
	end try
	begin catch
		rollback
		  DECLARE @ErrorMessage VARCHAR(2000)
		  SELECT @ErrorMessage = 'Lỗi: ' + ERROR_MESSAGE()
		  RAISERROR(@ErrorMessage, 16, 1)
	end catch



  
END
GO
/****** Object:  StoredProcedure [dbo].[Create_Product]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Thanh Nghia
-- Create date: 12/01/2019
-- Description: cretae
-- =============================================
CREATE PROCEDURE [dbo].[Create_Product]
@name nvarchar(255),
@description nvarchar(255),
@content ntext,
@seoDescription nvarchar(255),
@seoAlias nvarchar(255),
@seoTitle nvarchar(255),
@seoKeyword nvarchar(255),
@sku varchar(50),
@price float,
@isActive bit,
@imageUrl nvarchar(255),
@language varchar(5),
@categoryIds varchar(50),
@id int output
AS
BEGIN
	SET NOCOUNT ON;
	SET NOCOUNT ON;
	set xact_abort on;
	begin tran
	begin try
		insert into Products(Sku,Price,IsActive,ImageUrl,CreatedAt,ViewCount,RateTotal,RateCount)
		values(@sku,@price,@isActive,@imageUrl,getdate(),0,0,0)
		set @id = SCOPE_IDENTITY()

		insert into ProductTranslations(ProductId,LanguageId,Content,Name,Description,SeoDescription,SeoAlias,SeoTitle,SeoKeyword)
		values(@id,@language,@content,@name,@description,@seoDescription,@seoAlias,@seoTitle,@seoKeyword)
		--set @id=SCOPE_IDENTITY()

		---delete from ProductInCategories where ProductId = @id
	   	insert into ProductInCategories
	    select @id as ProductId,cast(String as int) as CategoryId from ufn_CSVToTable(@categoryIds,',')

	commit
	end try
	begin catch
		rollback
		  DECLARE @ErrorMessage VARCHAR(2000)
		  SELECT @ErrorMessage = 'Lỗi: ' + ERROR_MESSAGE()
		  RAISERROR(@ErrorMessage, 16, 1)
	end catch
END

select * from ProductInCategories
GO
/****** Object:  StoredProcedure [dbo].[Delete_Function_ById]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 28/12/2018
-- Description:	Delete function
-- =============================================
CREATE proc [dbo].[Delete_Function_ById]
	@id int
AS
BEGIN
	SET NOCOUNT ON;
	delete from Functions where Id = @id
END
GO
/****** Object:  StoredProcedure [dbo].[Delete_Product_ById]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Thanh Nghia
-- Create date: 12/01/2019
-- Description: cretae
-- =============================================
CREATE PROCEDURE [dbo].[Delete_Product_ById]
@id int

AS
BEGIN
	SET NOCOUNT ON;
	Begin tran;
		begin try
			delete from Products where Id=@id
			delete from ProductTranslations where ProductId=@id
		commit
	end try
		begin catch
			rollback
			DECLARE @ErrorMessage varchar(2000)
			SELECT @ErrorMessage='Lổi:'+ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1)
		end catch
	
END

GO
/****** Object:  StoredProcedure [dbo].[Get_Function_All]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[Get_Function_All]
as
begin
	set nocount on;

	SELECT [Id]
      ,[Name]
      ,[Url]
      ,[ParentId]
      ,[SortOrder]
      ,[CssClass]
      ,[IsActive]
  FROM [dbo].[Functions]
end
GO
/****** Object:  StoredProcedure [dbo].[Get_Function_AllPaging]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[Get_Function_AllPaging]
	@keyword nvarchar(50),
	@pageIndex int,
	@pageSize int,
	@totalRow int output
as
begin
	set nocount on;
	select @totalRow = count(*) from Functions r
	where (@keyword is null or r.Name like @keyword +'%')

	SELECT [Id]
      ,[Name]
      ,[Url]
      ,[ParentId]
      ,[SortOrder]
      ,[CssClass]
      ,[IsActive]
  FROM [dbo].[Functions] f
	where (@keyword is null or f.Name like @keyword +'%')
	order by f.Name
	offset (@pageIndex - 1) * @pageSize rows
	fetch next @pageSize row only
end
GO
/****** Object:  StoredProcedure [dbo].[Get_Function_ById]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[Get_Function_ById]
@id varchar(50)
as
begin
	set nocount on;

	SELECT [Id]
      ,[Name]
      ,[Url]
      ,[ParentId]
      ,[SortOrder]
      ,[CssClass]
      ,[IsActive]
  FROM [dbo].[Functions] where Id = @id
end
GO
/****** Object:  StoredProcedure [dbo].[Get_Function_ByPermission]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	
-- Create date: 11/1/2019
-- Description:	Get function by permission
-- =============================================
create PROCEDURE [dbo].[Get_Function_ByPermission]
	@userId varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	select 
		f.Id,
		f.Name,
		f.Url,
		f.ParentId,
		f.IsActive,
		f.SortOrder,
		f.CssClass
	 from Functions f
	join Permissions p on f.Id = p.FunctionId
	join AspNetRoles r on p.RoleId = r.Id
	join Actions a on p.ActionId = a.Id
	join AspNetUserRoles ur on r.Id = ur.RoleId
	where ur.UserId = @userId and a.Id ='VIEW'
END
GO
/****** Object:  StoredProcedure [dbo].[Get_Function_WithActions]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 8/1/2019
-- Description:	Get function with action
-- =============================================
create PROCEDURE [dbo].[Get_Function_WithActions]
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
			f.Id,
			f.Name,
			f.ParentId,
			case when sum(case when a.Id='CREATE' then 1 else 0 end)>0 then 1 else 0 end as HasCreated,
			case when sum(case when a.Id='UPDATE' then 1 else 0 end)>0 then 1 else 0 end as HasUpdate,
			case when sum(case when a.Id='DELETE' then 1 else 0 end)>0 then 1 else 0 end as HasDelete,
			case when sum(case when a.Id='VIEW' then 1 else 0 end)>0 then 1 else 0 end as HasView,
			case when sum(case when a.Id='IMPORT' then 1 else 0 end)>0 then 1 else 0 end as HasImport,
			case when sum(case when a.Id='EXPORT' then 1 else 0 end)>0 then 1 else 0 end as HasExport,
			case when sum(case when a.Id='APPROVE' then 1 else 0 end)>0 then 1 else 0 end as HasApprove
		from Functions f
			left join ActionInFunctions aif on f.Id = aif.FunctionId
			left join Actions a on aif.ActionId = a.Id
	    group by f.Id,f.Name,f.ParentId
END
GO
/****** Object:  StoredProcedure [dbo].[Get_Permission_ByRoleId]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 11/1/2019
-- Description:	Get permission by role id
-- =============================================
create PROCEDURE [dbo].[Get_Permission_ByRoleId]
	@roleId uniqueidentifier 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	select 
		p.FunctionId,
		p.ActionId,
		p.RoleId
	from Permissions p inner join Actions a
		on p.ActionId = a.Id 
	where p.RoleId = @roleId
END
GO
/****** Object:  StoredProcedure [dbo].[Get_Permission_ByUserId]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 11/1/2019
-- Description:	Get permission by userId
-- =============================================
create PROCEDURE [dbo].[Get_Permission_ByUserId]
	@userId varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	select distinct 
		f.Id + '_' + a.Id
	from Permissions p 
	join Functions f on f.Id = p.FunctionId
	join AspNetRoles r on p.RoleId = r.Id
	join Actions a on p.ActionId = a.Id
	join AspNetUserRoles ur on r.Id = ur.RoleId
	where ur.UserId = @userId 
END
GO
/****** Object:  StoredProcedure [dbo].[Get_Product_All]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Get_Product_All]
@language varchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	select 
	p.Id,
	p.Sku,
	p.Price,
	p.DiscountPrice,
	p.ImageUrl,
	p.CreatedAt,
	p.IsActive,
	p.ViewCount,
	pt.Name,
	pt.Description,
	pt.SeoAlias,
	pt.SeoTitle,
	pt.Content,
	pt.LanguageId
	from Products p
	inner join ProductTranslations pt on p.Id=pt.ProductId
	where pt.LanguageId=@language
END

GO
/****** Object:  StoredProcedure [dbo].[Get_Product_AllPaging]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Thanh Nghia	
-- Create date: 13/01
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Get_Product_AllPaging]
	@keyWord nvarchar(50),
	@categoryId int,
	@pageIndex int,
	@pageSize int,
	@language varchar(5),
	@totalRow int output
	 
AS
BEGIN
	SET NOCOUNT ON;
		select @totalRow=COUNT(*) 
		from Products p inner join ProductTranslations pt on p.Id=pt.ProductId
		left join ProductInCategories pic on p.Id=pic.ProductId
		left join Categories c on pic.CategoryId=c.Id
		where (@keyWord is null or p.Sku like @keyWord + '%' )and p.IsActive=1
	and pic.CategoryId=@categoryId
	select 
	p.Id,
	p.Sku,
	p.Price,
	p.ImageUrl,
	p.ImageList,
	p.DiscountPrice,
	p.ImageUrl,
	p.CreatedAt,
	p.IsActive,
	p.ViewCount,
	pt.Name,
	pt.Description,
	pt.SeoAlias,
	pt.SeoTitle,
	pt.Content,
	pt.LanguageId,
	c.Name as CategoryName
	from Products p inner join ProductTranslations pt on p.Id=pt.ProductId
	left join ProductInCategories pic on p.Id=pic.ProductId
	left join Categories c on pic.CategoryId=c.Id
	where (@keyWord is null or p.Sku like @keyWord + '%' )and p.IsActive=1
	and  pt.LanguageId=@language
	and pic.CategoryId=@categoryId
	order By	p.CreatedAt desc
	offset (@pageIndex-1)*@pageSize rows
	fetch next @pageIndex row only


END

GO
/****** Object:  StoredProcedure [dbo].[Get_Product_ById]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Thanh Nghia
-- Create date: 12/01/2019
-- Description:	select GetById
-- =============================================
CREATE PROCEDURE [dbo].[Get_Product_ById]
@id int,
@language varchar(5)
AS
BEGIN
	SET NOCOUNT ON;
	
	select p.Id,
	p.Sku,
	p.Price,
	p.DiscountPrice,
	p.ImageUrl,
	p.CreatedAt,
	p.IsActive,
	p.ViewCount,
	pt.Name,
	pt.Description,
	pt.SeoAlias,
	pt.SeoTitle,
	pt.Content,
	pt.LanguageId
	from Products p
	inner join ProductTranslations pt on p.Id=pt.ProductId
	where pt.LanguageId=@language and @id=id
END

GO
/****** Object:  StoredProcedure [dbo].[Get_Role_All]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[Get_Role_All]
as
begin
set nocount on;
select Id,Name
from AspNetRoles
end

GO
/****** Object:  StoredProcedure [dbo].[Get_Role_AllPaging]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[Get_Role_AllPaging]
	@keyWord nvarchar(50),
	@pageIndex int,
	@pageSize int,
	@totalRow int output
as
begin
	set nocount on;
	select @totalRow = count(*)from AspNetRoles r
	where (@keyWord is null or r.Name like @keyWord+'%')

	select Id,Name	
	from AspNetRoles r
	where (@keyWord is null or r.Name like @keyWord+'%')
	order By r.Name 
	offset (@pageIndex-1)*@pageSize rows
	fetch next @pageIndex row only
end

GO
/****** Object:  StoredProcedure [dbo].[Get_User_All]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [dbo].[Get_User_All]
as
begin
set nocount on;
select Id,UserName,FullName,Email,Address
from AspNetUsers
end


GO
/****** Object:  StoredProcedure [dbo].[Get_User_AllPaging]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Get_User_AllPaging]
	@keyWord nvarchar(50),
	@pageIndex int,
	@pageSize int,
	@totalRow int output
as
begin
	set nocount on;
	select @totalRow = count(*)from AspNetUsers u
	where (@keyWord is null or u.UserName like @keyWord+'%' or u.FullName like @keyWord+'%')

	select Id,UserName,FullName,Email,Address
	from AspNetUsers u
	where (@keyWord is null or u.UserName like @keyWord+'%' or u.FullName like @keyWord+'%')
	order By u.UserName 
	offset (@pageIndex-1)*@pageSize rows
	fetch next @pageIndex row only
end

GO
/****** Object:  StoredProcedure [dbo].[Update_Function]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 18/12/2018
-- Description:	Select one recorrd by id 
-- =============================================
CREATE PROCEDURE [dbo].[Update_Function]
	@id varchar(50),
	@name nvarchar(50),
	@url nvarchar(50),
	@parentId varchar(50),
	@sortOrder int,
	@cssClass nvarchar(50),
	@isActive bit
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE [dbo].[Functions]
   SET [Name] = @name
      ,[Url] = @url
      ,[ParentId] = @parentId
      ,[SortOrder] = @sortOrder
      ,[CssClass] = @cssClass
      ,[IsActive] = @isActive
 WHERE [Id] = @id


END
GO
/****** Object:  StoredProcedure [dbo].[Update_Product]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Thanh Nghia
-- Create date: 12/01/2019
-- Description: cretae
-- =============================================
CREATE PROCEDURE [dbo].[Update_Product]
@id int,
@name nvarchar(255),
@description nvarchar(255),
@content ntext,
@seoDescription nvarchar(255),
@seoAlias nvarchar(255),
@seoTitle nvarchar(255),
@seoKeyword nvarchar(255),
@sku varchar(50),
@price float,
@isActive bit,
@imageUrl nvarchar(255),
@language varchar(5),
@categoryIds varchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	set xact_abort on;
	begin tran
	begin try
	    update Products set Sku = @sku,Price = @price, IsActive = @isActive,ImageUrl=@imageUrl
			where Id = @id

		update ProductTranslations 
		   set Content = @content,
		   Name = @name,
		   Description = @description,
		   SeoDescription= @seoDescription,
		   SeoAlias = @seoAlias,
		   SeoTitle = @seoTitle,
		   SeoKeyword = @seoKeyword
	   where ProductId = @id and LanguageId = @language
	   	delete from ProductInCategories where ProductId = @id
	   insert into ProductInCategories
	    select @id as ProductId,cast(String as int) as CategoryId from ufn_CSVToTable(@categoryIds,',')
	commit
	end try
	begin catch
		rollback
		  DECLARE @ErrorMessage VARCHAR(2000)
		  SELECT @ErrorMessage = 'Lỗi: ' + ERROR_MESSAGE()
		  RAISERROR(@ErrorMessage, 16, 1)
	end catch
END

GO
/****** Object:  UserDefinedFunction [dbo].[ufn_CSVToTable]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ufn_CSVToTable] ( @StringInput VARCHAR(8000), @Delimiter nvarchar(1))
RETURNS @OutputTable TABLE ( [String] VARCHAR(10) )
AS
BEGIN

    DECLARE @String    VARCHAR(10)

    WHILE LEN(@StringInput) > 0
    BEGIN
        SET @String      = LEFT(@StringInput, 
                                ISNULL(NULLIF(CHARINDEX(@Delimiter, @StringInput) - 1, -1),
                                LEN(@StringInput)))
        SET @StringInput = SUBSTRING(@StringInput,
                                     ISNULL(NULLIF(CHARINDEX(@Delimiter, @StringInput), 0),
                                     LEN(@StringInput)) + 1, LEN(@StringInput))

        INSERT INTO @OutputTable ( [String] )
        VALUES ( @String )
    END

    RETURN
END

GO
/****** Object:  Table [dbo].[ActionInFunctions]    Script Date: 3/17/2019 10:00:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActionInFunctions](
	[FunctionId] [nvarchar](50) NOT NULL,
	[ActionId] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ActionInFunction] PRIMARY KEY CLUSTERED 
(
	[FunctionId] ASC,
	[ActionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Actions]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Actions](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[SortOrder] [int] NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_Actions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetRoleClaims]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoleClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetRoles]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoles](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](256) NULL,
	[NormalizedName] [nvarchar](256) NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserClaims]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserLogins]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserLogins](
	[LoginProvider] [nvarchar](128) NOT NULL,
	[ProviderKey] [nvarchar](128) NOT NULL,
	[ProviderDisplayName] [nvarchar](max) NULL,
	[UserId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY CLUSTERED 
(
	[LoginProvider] ASC,
	[ProviderKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserRoles]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserRoles](
	[UserId] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUsers]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUsers](
	[Id] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](256) NULL,
	[NormalizedUserName] [nvarchar](256) NULL,
	[Email] [nvarchar](256) NULL,
	[NormalizedEmail] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEnd] [datetimeoffset](7) NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
	[FullName] [nvarchar](250) NULL,
	[Address] [nvarchar](250) NULL,
 CONSTRAINT [PK_AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AspNetUserTokens]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserTokens](
	[UserId] [uniqueidentifier] NOT NULL,
	[LoginProvider] [nvarchar](128) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[LoginProvider] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AttributeOptions]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AttributeOptions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AttributeId] [int] NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_AttributeOptions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AttributeOptionValues]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AttributeOptionValues](
	[Id] [int] NOT NULL,
	[OptionId] [int] NULL,
	[Value] [nvarchar](255) NULL,
 CONSTRAINT [PK_AttributeOptionValues] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Attributes]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Attributes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Code] [varchar](255) NULL,
	[Name] [nvarchar](255) NULL,
	[SortOrder] [int] NULL,
	[BackendType] [varchar](50) NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_Attributes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AttributeValueDateTimes]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AttributeValueDateTimes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Value] [ntext] NULL,
	[AttributeId] [int] NULL,
	[ProductId] [int] NULL,
	[LanguageId] [varchar](50) NULL,
 CONSTRAINT [PK_AttributeValueDateTimes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AttributeValueDecimals]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AttributeValueDecimals](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Value] [varchar](250) NULL,
	[AttributeId] [int] NULL,
	[ProductId] [int] NULL,
	[LanguageId] [varchar](50) NULL,
 CONSTRAINT [PK_AttributeValueDecimals] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AttributeValueInts]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AttributeValueInts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AttributeId] [int] NULL,
	[Value] [int] NULL,
	[ProductId] [int] NULL,
	[LanguageId] [varchar](50) NULL,
 CONSTRAINT [PK_AttributeValueInts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AttributeValueText]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AttributeValueText](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[AttributeId] [int] NULL,
	[Value] [ntext] NULL,
	[ProductId] [int] NULL,
	[LanguageId] [varchar](50) NULL,
 CONSTRAINT [PK_AttributeValueText] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AttributeValueVarchars]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AttributeValueVarchars](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Value] [varchar](250) NULL,
	[AttributeId] [int] NULL,
	[ProductId] [int] NULL,
	[LanguageId] [varchar](50) NULL,
 CONSTRAINT [PK_AttributeValueVarchars] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Categories]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Categories](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[SeoAlias] [varchar](255) NULL,
	[SeoTitle] [nvarchar](255) NULL,
	[SeoKeyword] [nvarchar](255) NULL,
	[SeoDescription] [nvarchar](255) NULL,
	[ParentId] [int] NULL,
	[SortOrder] [int] NOT NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Functions]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Functions](
	[Id] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[Url] [nvarchar](50) NULL,
	[ParentId] [varchar](50) NULL,
	[SortOrder] [int] NULL,
	[CssClass] [nvarchar](50) NULL,
	[IsActive] [bit] NULL,
 CONSTRAINT [PK_Functions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Languages]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Languages](
	[Id] [varchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[IsActive] [bit] NULL,
	[IsDefault] [bit] NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_Languages] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OrderDetails]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetails](
	[ProductId] [int] NOT NULL,
	[OrderId] [int] NOT NULL,
	[Price] [float] NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK_OrderDetails] PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC,
	[OrderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Orders]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Orders](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CustomerId] [int] NULL,
	[CustomerName] [nvarchar](50) NOT NULL,
	[CustomerAddress] [nvarchar](255) NOT NULL,
	[CustomerEmail] [nvarchar](255) NOT NULL,
	[CustomerPhone] [varchar](20) NOT NULL,
	[CustomerNote] [nvarchar](255) NOT NULL,
	[CreatedAt] [datetime] NULL,
	[UpdatedAt] [datetime] NULL,
	[Status] [int] NOT NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Permissions]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Permissions](
	[FunctionId] [nvarchar](50) NOT NULL,
	[ActionId] [nvarchar](50) NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_Permissions] PRIMARY KEY CLUSTERED 
(
	[FunctionId] ASC,
	[ActionId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductInCategories]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductInCategories](
	[ProductId] [int] NOT NULL,
	[CategoryId] [int] NOT NULL,
 CONSTRAINT [PK_ProductInCategories] PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC,
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Products]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Products](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Sku] [varchar](50) NOT NULL,
	[Price] [float] NOT NULL,
	[DiscountPrice] [float] NULL,
	[ImageUrl] [nvarchar](255) NOT NULL,
	[ImageList] [nvarchar](max) NULL,
	[ViewCount] [int] NULL,
	[CreatedAt] [datetime] NULL,
	[UpdatedAt] [datetime] NULL,
	[IsActive] [bit] NOT NULL,
	[RateTotal] [int] NULL,
	[RateCount] [int] NULL,
 CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ProductTranslations]    Script Date: 3/17/2019 10:00:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ProductTranslations](
	[ProductId] [int] NOT NULL,
	[LanguageId] [varchar](50) NOT NULL,
	[Content] [ntext] NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](255) NULL,
	[SeoDescription] [nvarchar](255) NULL,
	[SeoAlias] [varchar](255) NULL,
	[SeoTitle] [nvarchar](255) NULL,
	[SeoKeyword] [nvarchar](255) NULL,
 CONSTRAINT [PK_ProductTranslations] PRIMARY KEY CLUSTERED 
(
	[ProductId] ASC,
	[LanguageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[ActionInFunctions] ([FunctionId], [ActionId]) VALUES (N'SYSTEM.USER', N'CREATE')
INSERT [dbo].[ActionInFunctions] ([FunctionId], [ActionId]) VALUES (N'SYSTEM.USER', N'DELETE')
INSERT [dbo].[ActionInFunctions] ([FunctionId], [ActionId]) VALUES (N'SYSTEM.USER', N'IMPORT')
INSERT [dbo].[ActionInFunctions] ([FunctionId], [ActionId]) VALUES (N'SYSTEM.USER', N'UPDATE')
INSERT [dbo].[ActionInFunctions] ([FunctionId], [ActionId]) VALUES (N'SYSTEM.USER', N'VIEW')
INSERT [dbo].[Actions] ([Id], [Name], [SortOrder], [IsActive]) VALUES (N'APPROVE', N'Duyệt', 7, 1)
INSERT [dbo].[Actions] ([Id], [Name], [SortOrder], [IsActive]) VALUES (N'CREATE', N'Tạo mới', 1, 1)
INSERT [dbo].[Actions] ([Id], [Name], [SortOrder], [IsActive]) VALUES (N'DELETE', N'Xóa', 3, 1)
INSERT [dbo].[Actions] ([Id], [Name], [SortOrder], [IsActive]) VALUES (N'EXPORT', N'Xuất', 6, 1)
INSERT [dbo].[Actions] ([Id], [Name], [SortOrder], [IsActive]) VALUES (N'IMPORT', N'Nhập', 5, 1)
INSERT [dbo].[Actions] ([Id], [Name], [SortOrder], [IsActive]) VALUES (N'UPDATE', N'Cập nhật', 2, 1)
INSERT [dbo].[Actions] ([Id], [Name], [SortOrder], [IsActive]) VALUES (N'VIEW', N'Truy cập', 4, 1)
INSERT [dbo].[AspNetRoles] ([Id], [Name], [NormalizedName], [ConcurrencyStamp]) VALUES (N'19f1d7d1-2e87-4482-82fe-e2ba22536a64', N'Admin', N'ADMIN', NULL)
INSERT [dbo].[AspNetUserRoles] ([UserId], [RoleId]) VALUES (N'9d323b82-af17-4727-8285-497a69bde9ae', N'19f1d7d1-2e87-4482-82fe-e2ba22536a64')
INSERT [dbo].[AspNetUsers] ([Id], [UserName], [NormalizedUserName], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [ConcurrencyStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled], [LockoutEnd], [LockoutEnabled], [AccessFailedCount], [FullName], [Address]) VALUES (N'9d323b82-af17-4727-8285-497a69bde9ae', N'hangnghia11089@gmail.com', N'HANGNGHIA11089@GMAIL.COM', N'hangnghia11089@gmail.com', N'HANGNGHIA11089@GMAIL.COM', 0, N'AQAAAAEAACcQAAAAEOMvHY7Aw0iQccbiaaYYbDLziyXrcNhg3+TY1/tVBipBTANGukGSZVPLuIKgq+2x/Q==', NULL, NULL, NULL, 0, 0, NULL, 0, 0, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Attributes] ON 

INSERT [dbo].[Attributes] ([Id], [Code], [Name], [SortOrder], [BackendType], [IsActive]) VALUES (1, N'chat-lieu', N'Chất liệu', 1, NULL, 1)
SET IDENTITY_INSERT [dbo].[Attributes] OFF
SET IDENTITY_INSERT [dbo].[Categories] ON 

INSERT [dbo].[Categories] ([Id], [Name], [SeoAlias], [SeoTitle], [SeoKeyword], [SeoDescription], [ParentId], [SortOrder], [IsActive]) VALUES (1, N'Áo phông nam', N'ao-phong-nam', N'Áo phông nam 2018', N'ao phong nam', N'Các sản phẩm áo phông nam', NULL, 1, 1)
SET IDENTITY_INSERT [dbo].[Categories] OFF
INSERT [dbo].[Functions] ([Id], [Name], [Url], [ParentId], [SortOrder], [CssClass], [IsActive]) VALUES (N'REPORT', N'Báo cáo', N'/admin/report', NULL, 3, N'icon-system', 1)
INSERT [dbo].[Functions] ([Id], [Name], [Url], [ParentId], [SortOrder], [CssClass], [IsActive]) VALUES (N'REPORT.INVENTORY', N'Tồn kho', N'/admin/report/inventory', N'REPORT', 2, N'icon-inventory', 1)
INSERT [dbo].[Functions] ([Id], [Name], [Url], [ParentId], [SortOrder], [CssClass], [IsActive]) VALUES (N'REPORT.REVENUE', N'Doanh thu', N'/admin/report/revenue', N'REPORT', 1, N'icon-revenue', 1)
INSERT [dbo].[Functions] ([Id], [Name], [Url], [ParentId], [SortOrder], [CssClass], [IsActive]) VALUES (N'REPORT.VISITOR', N'Truy cập', N'/admin/report/visitor', N'REPORT', 3, N'icon-visitor', 1)
INSERT [dbo].[Functions] ([Id], [Name], [Url], [ParentId], [SortOrder], [CssClass], [IsActive]) VALUES (N'SALES', N'Kinh doanh', N'/admin/sales', NULL, 2, N'icon-sales', 1)
INSERT [dbo].[Functions] ([Id], [Name], [Url], [ParentId], [SortOrder], [CssClass], [IsActive]) VALUES (N'SALES.ATTRIBUTE', N'Thuộc tính', N'/admin/sales/attribute', N'SALES', 4, N'icon-attribute', 1)
INSERT [dbo].[Functions] ([Id], [Name], [Url], [ParentId], [SortOrder], [CssClass], [IsActive]) VALUES (N'SALES.CATALOG', N'Nhóm sản phẩm', N'/admin/sales/catalog', N'SALES', 1, N'icon-catalog', 1)
INSERT [dbo].[Functions] ([Id], [Name], [Url], [ParentId], [SortOrder], [CssClass], [IsActive]) VALUES (N'SALES.ORDER', N'Hóa đơn', N'/admin/sales/order', N'SALES', 3, N'icon-order', 1)
INSERT [dbo].[Functions] ([Id], [Name], [Url], [ParentId], [SortOrder], [CssClass], [IsActive]) VALUES (N'SALES.PRODUCT', N'Sản phẩm', N'/admin/sales/product', N'SALES', 2, N'icon-product', 1)
INSERT [dbo].[Functions] ([Id], [Name], [Url], [ParentId], [SortOrder], [CssClass], [IsActive]) VALUES (N'SYSTEM', N'Hệ thống', N'/admin/system', NULL, 1, N'icon-system', 1)
INSERT [dbo].[Functions] ([Id], [Name], [Url], [ParentId], [SortOrder], [CssClass], [IsActive]) VALUES (N'SYSTEM.ROLE', N'Nhóm người dùng', N'/admin/system/role', N'SYSTEM', 1, N'icon-role', 1)
INSERT [dbo].[Functions] ([Id], [Name], [Url], [ParentId], [SortOrder], [CssClass], [IsActive]) VALUES (N'SYSTEM.SETTING', N'Cấu hình', N'/admin/system/setting', N'SYSTEM', 3, N'icon-setting', 1)
INSERT [dbo].[Functions] ([Id], [Name], [Url], [ParentId], [SortOrder], [CssClass], [IsActive]) VALUES (N'SYSTEM.USER', N'Người dùng', N'/admin/system/user', N'SYSTEM', 2, N'icon-user', 1)
INSERT [dbo].[Languages] ([Id], [Name], [IsActive], [IsDefault], [SortOrder]) VALUES (N'en-US', N'Tiếng anh', 1, 0, 2)
INSERT [dbo].[Languages] ([Id], [Name], [IsActive], [IsDefault], [SortOrder]) VALUES (N'vi-VN', N'Tiếng việt', 1, 1, 1)
INSERT [dbo].[Permissions] ([FunctionId], [ActionId], [RoleId]) VALUES (N'SYSTEM.USER', N'CREATE', N'19f1d7d1-2e87-4482-82fe-e2ba22536a64')
INSERT [dbo].[Permissions] ([FunctionId], [ActionId], [RoleId]) VALUES (N'SYSTEM.USER', N'UPDATE', N'19f1d7d1-2e87-4482-82fe-e2ba22536a64')
INSERT [dbo].[Permissions] ([FunctionId], [ActionId], [RoleId]) VALUES (N'SYSTEM.USER', N'VIEW', N'19f1d7d1-2e87-4482-82fe-e2ba22536a64')
INSERT [dbo].[ProductInCategories] ([ProductId], [CategoryId]) VALUES (3, 1)
INSERT [dbo].[ProductInCategories] ([ProductId], [CategoryId]) VALUES (14, 1)
INSERT [dbo].[ProductInCategories] ([ProductId], [CategoryId]) VALUES (22, 1)
INSERT [dbo].[ProductInCategories] ([ProductId], [CategoryId]) VALUES (24, 1)
SET IDENTITY_INSERT [dbo].[Products] ON 

INSERT [dbo].[Products] ([Id], [Sku], [Price], [DiscountPrice], [ImageUrl], [ImageList], [ViewCount], [CreatedAt], [UpdatedAt], [IsActive], [RateTotal], [RateCount]) VALUES (3, N'sku123', 3, NULL, N'string', NULL, 0, CAST(0x0000A9B400000000 AS DateTime), NULL, 1, 0, 0)
INSERT [dbo].[Products] ([Id], [Sku], [Price], [DiscountPrice], [ImageUrl], [ImageList], [ViewCount], [CreatedAt], [UpdatedAt], [IsActive], [RateTotal], [RateCount]) VALUES (14, N'12', 12, NULL, N'string', NULL, 0, CAST(0x0000A9D4013E9763 AS DateTime), NULL, 1, 0, 0)
INSERT [dbo].[Products] ([Id], [Sku], [Price], [DiscountPrice], [ImageUrl], [ImageList], [ViewCount], [CreatedAt], [UpdatedAt], [IsActive], [RateTotal], [RateCount]) VALUES (15, N'sku001', 45, NULL, N'string', NULL, 0, CAST(0x0000AA05013F3F02 AS DateTime), NULL, 1, 0, 0)
INSERT [dbo].[Products] ([Id], [Sku], [Price], [DiscountPrice], [ImageUrl], [ImageList], [ViewCount], [CreatedAt], [UpdatedAt], [IsActive], [RateTotal], [RateCount]) VALUES (16, N'sku001', 23, NULL, N'string', NULL, 0, CAST(0x0000AA050141B974 AS DateTime), NULL, 1, 0, 0)
INSERT [dbo].[Products] ([Id], [Sku], [Price], [DiscountPrice], [ImageUrl], [ImageList], [ViewCount], [CreatedAt], [UpdatedAt], [IsActive], [RateTotal], [RateCount]) VALUES (17, N'skusdsu', 10, NULL, N'string', NULL, 0, CAST(0x0000AA05015C6E17 AS DateTime), NULL, 1, 0, 0)
INSERT [dbo].[Products] ([Id], [Sku], [Price], [DiscountPrice], [ImageUrl], [ImageList], [ViewCount], [CreatedAt], [UpdatedAt], [IsActive], [RateTotal], [RateCount]) VALUES (22, N'123sku', 45, NULL, N'string', NULL, 0, CAST(0x0000AA1301647ECB AS DateTime), NULL, 1, 0, 0)
INSERT [dbo].[Products] ([Id], [Sku], [Price], [DiscountPrice], [ImageUrl], [ImageList], [ViewCount], [CreatedAt], [UpdatedAt], [IsActive], [RateTotal], [RateCount]) VALUES (24, N'sku 89', 89, NULL, N'string', NULL, 0, CAST(0x0000AA130168A9A2 AS DateTime), NULL, 1, 0, 0)
SET IDENTITY_INSERT [dbo].[Products] OFF
INSERT [dbo].[ProductTranslations] ([ProductId], [LanguageId], [Content], [Name], [Description], [SeoDescription], [SeoAlias], [SeoTitle], [SeoKeyword]) VALUES (3, N'en-US', N'English content', N't-shirt', N'description', N'description for t-shirt', N't-shirt', N't-shirt', N't-shirt')
INSERT [dbo].[ProductTranslations] ([ProductId], [LanguageId], [Content], [Name], [Description], [SeoDescription], [SeoAlias], [SeoTitle], [SeoKeyword]) VALUES (3, N'vi-VN', N'string', N'string', N'string', N'string', N'string', N'string', N'string')
INSERT [dbo].[ProductTranslations] ([ProductId], [LanguageId], [Content], [Name], [Description], [SeoDescription], [SeoAlias], [SeoTitle], [SeoKeyword]) VALUES (15, N'vi-VN', N'quần đùi', N'quần đùi', N'quần đùi', N'quần đùi', N'string', N'quần đùi', N'quần đùi')
INSERT [dbo].[ProductTranslations] ([ProductId], [LanguageId], [Content], [Name], [Description], [SeoDescription], [SeoAlias], [SeoTitle], [SeoKeyword]) VALUES (16, N'en-US', N'23', N'23', N'23', N'string', N'string', N'string', N'string')
INSERT [dbo].[ProductTranslations] ([ProductId], [LanguageId], [Content], [Name], [Description], [SeoDescription], [SeoAlias], [SeoTitle], [SeoKeyword]) VALUES (17, N'vi-VN', N'string', N'string', N'string', N'string', N'string', N'string', N'string')
INSERT [dbo].[ProductTranslations] ([ProductId], [LanguageId], [Content], [Name], [Description], [SeoDescription], [SeoAlias], [SeoTitle], [SeoKeyword]) VALUES (22, N'vi-VN', N'string', N'string', N'string', N'string', N'string', N'string', N'string')
INSERT [dbo].[ProductTranslations] ([ProductId], [LanguageId], [Content], [Name], [Description], [SeoDescription], [SeoAlias], [SeoTitle], [SeoKeyword]) VALUES (24, N'en-US', N'string', N'string', N'string', N'string', N'string', N'string', N'string')
ALTER TABLE [dbo].[ActionInFunctions]  WITH CHECK ADD  CONSTRAINT [FK_ActionInFunction_Actions] FOREIGN KEY([ActionId])
REFERENCES [dbo].[Actions] ([Id])
GO
ALTER TABLE [dbo].[ActionInFunctions] CHECK CONSTRAINT [FK_ActionInFunction_Actions]
GO
ALTER TABLE [dbo].[ActionInFunctions]  WITH CHECK ADD  CONSTRAINT [FK_ActionInFunction_Functions] FOREIGN KEY([FunctionId])
REFERENCES [dbo].[Functions] ([Id])
GO
ALTER TABLE [dbo].[ActionInFunctions] CHECK CONSTRAINT [FK_ActionInFunction_Functions]
GO
ALTER TABLE [dbo].[AspNetRoleClaims]  WITH CHECK ADD  CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetRoleClaims] CHECK CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserClaims]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserClaims] CHECK CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserLogins]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserLogins] CHECK CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserTokens]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserTokens] CHECK CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AttributeOptions]  WITH CHECK ADD  CONSTRAINT [FK_AttributeOptions_Attributes] FOREIGN KEY([AttributeId])
REFERENCES [dbo].[Attributes] ([Id])
GO
ALTER TABLE [dbo].[AttributeOptions] CHECK CONSTRAINT [FK_AttributeOptions_Attributes]
GO
ALTER TABLE [dbo].[AttributeOptionValues]  WITH CHECK ADD  CONSTRAINT [FK_AttributeOptionValues_AttributeOptions] FOREIGN KEY([OptionId])
REFERENCES [dbo].[AttributeOptions] ([Id])
GO
ALTER TABLE [dbo].[AttributeOptionValues] CHECK CONSTRAINT [FK_AttributeOptionValues_AttributeOptions]
GO
ALTER TABLE [dbo].[AttributeValueDateTimes]  WITH CHECK ADD  CONSTRAINT [FK_AttributeValueDateTimes_Attributes] FOREIGN KEY([AttributeId])
REFERENCES [dbo].[Attributes] ([Id])
GO
ALTER TABLE [dbo].[AttributeValueDateTimes] CHECK CONSTRAINT [FK_AttributeValueDateTimes_Attributes]
GO
ALTER TABLE [dbo].[AttributeValueDateTimes]  WITH CHECK ADD  CONSTRAINT [FK_AttributeValueDateTimes_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[AttributeValueDateTimes] CHECK CONSTRAINT [FK_AttributeValueDateTimes_Products]
GO
ALTER TABLE [dbo].[AttributeValueDecimals]  WITH CHECK ADD  CONSTRAINT [FK_AttributeValueDecimals_Attributes] FOREIGN KEY([AttributeId])
REFERENCES [dbo].[Attributes] ([Id])
GO
ALTER TABLE [dbo].[AttributeValueDecimals] CHECK CONSTRAINT [FK_AttributeValueDecimals_Attributes]
GO
ALTER TABLE [dbo].[AttributeValueDecimals]  WITH CHECK ADD  CONSTRAINT [FK_AttributeValueDecimals_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[AttributeValueDecimals] CHECK CONSTRAINT [FK_AttributeValueDecimals_Products]
GO
ALTER TABLE [dbo].[AttributeValueInts]  WITH CHECK ADD  CONSTRAINT [FK_AttributeValueInts_Attributes] FOREIGN KEY([AttributeId])
REFERENCES [dbo].[Attributes] ([Id])
GO
ALTER TABLE [dbo].[AttributeValueInts] CHECK CONSTRAINT [FK_AttributeValueInts_Attributes]
GO
ALTER TABLE [dbo].[AttributeValueInts]  WITH CHECK ADD  CONSTRAINT [FK_AttributeValueInts_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[AttributeValueInts] CHECK CONSTRAINT [FK_AttributeValueInts_Products]
GO
ALTER TABLE [dbo].[AttributeValueText]  WITH CHECK ADD  CONSTRAINT [FK_AttributeValueText_Attributes] FOREIGN KEY([AttributeId])
REFERENCES [dbo].[Attributes] ([Id])
GO
ALTER TABLE [dbo].[AttributeValueText] CHECK CONSTRAINT [FK_AttributeValueText_Attributes]
GO
ALTER TABLE [dbo].[AttributeValueText]  WITH CHECK ADD  CONSTRAINT [FK_AttributeValueText_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[AttributeValueText] CHECK CONSTRAINT [FK_AttributeValueText_Products]
GO
ALTER TABLE [dbo].[AttributeValueVarchars]  WITH CHECK ADD  CONSTRAINT [FK_AttributeValueVarchars_Attributes] FOREIGN KEY([AttributeId])
REFERENCES [dbo].[Attributes] ([Id])
GO
ALTER TABLE [dbo].[AttributeValueVarchars] CHECK CONSTRAINT [FK_AttributeValueVarchars_Attributes]
GO
ALTER TABLE [dbo].[AttributeValueVarchars]  WITH CHECK ADD  CONSTRAINT [FK_AttributeValueVarchars_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[AttributeValueVarchars] CHECK CONSTRAINT [FK_AttributeValueVarchars_Products]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Orders] FOREIGN KEY([OrderId])
REFERENCES [dbo].[Orders] ([Id])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_Orders]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [FK_OrderDetails_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_Products]
GO
ALTER TABLE [dbo].[Permissions]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_Actions] FOREIGN KEY([ActionId])
REFERENCES [dbo].[Actions] ([Id])
GO
ALTER TABLE [dbo].[Permissions] CHECK CONSTRAINT [FK_Permissions_Actions]
GO
ALTER TABLE [dbo].[Permissions]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_AspNetRoles] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
GO
ALTER TABLE [dbo].[Permissions] CHECK CONSTRAINT [FK_Permissions_AspNetRoles]
GO
ALTER TABLE [dbo].[Permissions]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_Functions] FOREIGN KEY([FunctionId])
REFERENCES [dbo].[Functions] ([Id])
GO
ALTER TABLE [dbo].[Permissions] CHECK CONSTRAINT [FK_Permissions_Functions]
GO
ALTER TABLE [dbo].[ProductInCategories]  WITH CHECK ADD  CONSTRAINT [FK_ProductInCategories_Categories] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Categories] ([Id])
GO
ALTER TABLE [dbo].[ProductInCategories] CHECK CONSTRAINT [FK_ProductInCategories_Categories]
GO
ALTER TABLE [dbo].[ProductInCategories]  WITH CHECK ADD  CONSTRAINT [FK_ProductInCategories_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[ProductInCategories] CHECK CONSTRAINT [FK_ProductInCategories_Products]
GO
ALTER TABLE [dbo].[ProductTranslations]  WITH CHECK ADD  CONSTRAINT [FK_ProductTranslations_Languages] FOREIGN KEY([LanguageId])
REFERENCES [dbo].[Languages] ([Id])
GO
ALTER TABLE [dbo].[ProductTranslations] CHECK CONSTRAINT [FK_ProductTranslations_Languages]
GO
ALTER TABLE [dbo].[ProductTranslations]  WITH CHECK ADD  CONSTRAINT [FK_ProductTranslations_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[ProductTranslations] CHECK CONSTRAINT [FK_ProductTranslations_Products]
GO
