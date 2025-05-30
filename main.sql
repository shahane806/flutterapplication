USE [flutterApplicationBackend]
GO
/****** Object:  Table [dbo].[AuthenticationMaster]    Script Date: 09-04-2025 09:11:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuthenticationMaster](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[userName] [varchar](50) NOT NULL,
	[phone] [varchar](10) NOT NULL,
	[otp] [varchar](6) NULL,
	[deviceId] [varchar](50) NULL,
	[pass] [varchar](255) NOT NULL,
	[createdAt] [datetime] NULL,
	[updatedAt] [datetime] NULL,
	[countryCode] [varchar](50) NULL,
	[dialCode] [varchar](50) NULL,
	[email] [varchar](100) NULL,
	[role] [varchar](5) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BookedMarkMaster]    Script Date: 09-04-2025 09:11:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BookedMarkMaster](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[postId] [int] NULL,
	[postType] [varchar](50) NULL,
	[postPath] [varchar](255) NULL,
	[phone] [varchar](20) NULL,
	[bookedMarkAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CommentMaster]    Script Date: 09-04-2025 09:11:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommentMaster](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[postId] [int] NULL,
	[postType] [varchar](50) NULL,
	[postPath] [varchar](255) NULL,
	[phone] [varchar](20) NULL,
	[comment] [varchar](300) NULL,
	[commentAt] [datetime] NULL,
	[commentUpdateAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[deviceInformation]    Script Date: 09-04-2025 09:11:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[deviceInformation](
	[local_wifi_connection_ip] [varchar](50) NULL,
	[id] [int] NOT NULL,
	[wifiName] [varchar](100) NULL,
	[internetConnection] [varchar](1) NULL,
	[deviceId] [varchar](50) NULL,
	[deviceName] [varchar](50) NULL,
	[manufacturer] [varchar](50) NULL,
	[board] [varchar](50) NULL,
	[location] [varchar](50) NULL,
	[latitude] [varchar](50) NULL,
	[longitude] [varchar](50) NULL,
	[userId] [int] NULL,
 CONSTRAINT [PK_deviceInformation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LikeMaster]    Script Date: 09-04-2025 09:11:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LikeMaster](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[postId] [int] NULL,
	[postType] [varchar](50) NULL,
	[postPath] [varchar](255) NULL,
	[phone] [varchar](20) NULL,
	[likedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Postmaster]    Script Date: 09-04-2025 09:11:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postmaster](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[postType] [varchar](50) NULL,
	[postPath] [varchar](255) NULL,
	[phone] [varchar](20) NULL,
	[createdAt] [datetime] NULL,
	[updatedAt] [datetime] NULL,
	[userName] [varchar](50) NULL,
	[content] [varchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReportPostMaster]    Script Date: 09-04-2025 09:11:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportPostMaster](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[postId] [varchar](50) NOT NULL,
	[postPath] [varchar](255) NOT NULL,
	[reportedAt] [datetime] NULL,
	[phone] [varchar](50) NULL,
	[reportedUser] [varchar](50) NULL,
	[reportedMessage] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[simInformation]    Script Date: 09-04-2025 09:11:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[simInformation](
	[carrier] [varchar](50) NULL,
	[phonePrefix] [varchar](50) NULL,
	[slotIndex] [varchar](1) NULL,
	[id] [int] NOT NULL,
	[deviceId] [varchar](50) NULL,
 CONSTRAINT [PK_simInformation] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TextPost]    Script Date: 09-04-2025 09:11:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TextPost](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[postType] [varchar](50) NOT NULL,
	[phone] [varchar](10) NOT NULL,
	[title] [varchar](255) NOT NULL,
	[message] [text] NOT NULL,
	[createdAt] [datetime] NULL,
	[updatedAt] [datetime] NULL,
	[userName] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[userProfile]    Script Date: 09-04-2025 09:11:04 ******/
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
	[userName] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuthenticationMaster] ADD  DEFAULT (getdate()) FOR [createdAt]
GO
ALTER TABLE [dbo].[AuthenticationMaster] ADD  DEFAULT (getdate()) FOR [updatedAt]
GO
ALTER TABLE [dbo].[BookedMarkMaster] ADD  DEFAULT (getdate()) FOR [bookedMarkAt]
GO
ALTER TABLE [dbo].[CommentMaster] ADD  DEFAULT (getdate()) FOR [commentAt]
GO
ALTER TABLE [dbo].[CommentMaster] ADD  DEFAULT (getdate()) FOR [commentUpdateAt]
GO
ALTER TABLE [dbo].[LikeMaster] ADD  DEFAULT (getdate()) FOR [likedAt]
GO
ALTER TABLE [dbo].[Postmaster] ADD  DEFAULT (getdate()) FOR [createdAt]
GO
ALTER TABLE [dbo].[Postmaster] ADD  DEFAULT (getdate()) FOR [updatedAt]
GO
ALTER TABLE [dbo].[ReportPostMaster] ADD  DEFAULT (getdate()) FOR [reportedAt]
GO
ALTER TABLE [dbo].[TextPost] ADD  DEFAULT (getdate()) FOR [createdAt]
GO
ALTER TABLE [dbo].[TextPost] ADD  DEFAULT (getdate()) FOR [updatedAt]
GO
ALTER TABLE [dbo].[userProfile] ADD  DEFAULT (getdate()) FOR [createdAt]
GO
ALTER TABLE [dbo].[userProfile] ADD  DEFAULT (getdate()) FOR [updatedAt]
GO
