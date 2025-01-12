USE [master]
GO
/****** Object:  Database [MaxMobility]    Script Date: 23-09-2024 22:44:41 ******/
CREATE DATABASE [MaxMobility]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'MaxMobility', FILENAME = N'C:\Users\Roop\MaxMobility.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'MaxMobility_log', FILENAME = N'C:\Users\Roop\MaxMobility_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [MaxMobility] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [MaxMobility].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [MaxMobility] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [MaxMobility] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [MaxMobility] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [MaxMobility] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [MaxMobility] SET ARITHABORT OFF 
GO
ALTER DATABASE [MaxMobility] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [MaxMobility] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [MaxMobility] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [MaxMobility] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [MaxMobility] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [MaxMobility] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [MaxMobility] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [MaxMobility] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [MaxMobility] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [MaxMobility] SET  DISABLE_BROKER 
GO
ALTER DATABASE [MaxMobility] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [MaxMobility] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [MaxMobility] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [MaxMobility] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [MaxMobility] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [MaxMobility] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [MaxMobility] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [MaxMobility] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [MaxMobility] SET  MULTI_USER 
GO
ALTER DATABASE [MaxMobility] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [MaxMobility] SET DB_CHAINING OFF 
GO
ALTER DATABASE [MaxMobility] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [MaxMobility] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [MaxMobility] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [MaxMobility] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [MaxMobility] SET QUERY_STORE = OFF
GO
USE [MaxMobility]
GO
/****** Object:  UserDefinedTableType [dbo].[EmailTableType]    Script Date: 23-09-2024 22:44:41 ******/
CREATE TYPE [dbo].[EmailTableType] AS TABLE(
	[EmailID] [nvarchar](max) NULL
)
GO
/****** Object:  Table [dbo].[EmailMaster]    Script Date: 23-09-2024 22:44:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmailMaster](
	[Email_Id] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_EmailMaster] PRIMARY KEY CLUSTERED 
(
	[Email_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[SP_SaveEmail]    Script Date: 23-09-2024 22:44:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SaveEmail] 
	-- Add the parameters for the stored procedure here
	@EmailList EmailTableType READONLY
AS
BEGIN
    DECLARE @InsertedCount INT = 0;
    DECLARE @DuplicateCount INT = 0;

    -- Process each email
    DECLARE @EmailID NVARCHAR(255);
    DECLARE EmailCursor CURSOR FOR SELECT EmailID FROM @EmailList;
    OPEN EmailCursor;
    FETCH NEXT FROM EmailCursor INTO @EmailID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM EmailMaster WHERE Email_Id = @EmailID)
        BEGIN
            SET @DuplicateCount = @DuplicateCount + 1;
        END
        ELSE
        BEGIN
            INSERT INTO EmailMaster (Email_Id) VALUES (@EmailID);
            SET @InsertedCount = @InsertedCount + 1;
        END

        FETCH NEXT FROM EmailCursor INTO @EmailID;
    END

    CLOSE EmailCursor;
    DEALLOCATE EmailCursor;

    -- Return the results
    SELECT @InsertedCount AS InsertedCount, @DuplicateCount AS DuplicateCount;
END;
GO
USE [master]
GO
ALTER DATABASE [MaxMobility] SET  READ_WRITE 
GO
