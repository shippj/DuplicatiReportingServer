USE [master]
GO

/****** Object:  Database [Duplicati]    Script Date: 8/1/2020 7:46:42 PM ******/
CREATE DATABASE [Duplicati]
GO

USE [Duplicati]
GO

/****** Object:  Table [dbo].[Reports]    Script Date: 8/1/2020 7:48:24 PM ******/
CREATE TABLE [dbo].[Reports](
	[pk] [int] IDENTITY(1,1) NOT NULL,
	[Date] [date] NOT NULL,
	[Time] [time](7) NULL,
	[Job] [nvarchar](100) NULL,
	[Report] [nvarchar](max) NULL,
	[Success] [char](1) NOT NULL,
	[IP] [nvarchar](45) NULL,
	[Hide] [bit] NULL,
 CONSTRAINT [PK_Reports] PRIMARY KEY CLUSTERED 
(
	[pk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

/****** Object:  Table [dbo].[hide]    Script Date: 8/1/2020 7:49:15 PM ******/
CREATE TABLE [dbo].[hide](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[date] [date] NOT NULL,
	[job] [varchar](100) NOT NULL,
 CONSTRAINT [PK_hide] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
