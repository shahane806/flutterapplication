USE [flutterApplicationBackend]
GO

/****** Object:  Table [dbo].[userProfile]    Script Date: 25-03-2025 13:42:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[userProfile](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[profilePicturePath] [varchar](max) NOT NULL,
	[profilePictureSize] [int] NULL,
	[bio] [varchar](255) NOT NULL,
	[phone] [varchar](15) NULL,
	[createdAt] [datetime] NULL,
	[updatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[userProfile] ADD  DEFAULT (getdate()) FOR [createdAt]
GO

ALTER TABLE [dbo].[userProfile] ADD  DEFAULT (getdate()) FOR [updatedAt]
GO


