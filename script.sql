USE [flutterApplicationBackend]
GO
/****** Object:  Table [dbo].[AuthenticationMaster]    Script Date: 22-03-2025 13:24:00 ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BookedMarkMaster]    Script Date: 22-03-2025 13:24:00 ******/
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
/****** Object:  Table [dbo].[CommentMaster]    Script Date: 22-03-2025 13:24:00 ******/
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
/****** Object:  Table [dbo].[deviceInformation]    Script Date: 22-03-2025 13:24:00 ******/
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
/****** Object:  Table [dbo].[LikeMaster]    Script Date: 22-03-2025 13:24:00 ******/
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
/****** Object:  Table [dbo].[Postmaster]    Script Date: 22-03-2025 13:24:00 ******/
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
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[simInformation]    Script Date: 22-03-2025 13:24:00 ******/
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
/****** Object:  Table [dbo].[TextPost]    Script Date: 22-03-2025 13:24:00 ******/
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
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[AuthenticationMaster] ON 

INSERT [dbo].[AuthenticationMaster] ([id], [userName], [phone], [otp], [deviceId], [pass], [createdAt], [updatedAt], [countryCode], [dialCode], [email], [role]) VALUES (1, N'', N'7887941005', NULL, N'PSR1.180720.117', N'$2y$10$.l5aKiPx11RORaNUxzjRKOkbsHDSynQyAvd2/QjjiAW6JNYilKH6e', CAST(N'2025-03-13T00:35:34.243' AS DateTime), CAST(N'2025-03-13T00:35:34.243' AS DateTime), N'us', N'+1', N'om.p.shahane@gmail.com', N'user')
INSERT [dbo].[AuthenticationMaster] ([id], [userName], [phone], [otp], [deviceId], [pass], [createdAt], [updatedAt], [countryCode], [dialCode], [email], [role]) VALUES (2, N'', N'1111111111', NULL, N'PSR1.180720.117', N'$2y$10$JCK0LcTXgpQA7NQlAPmJpOXnQAUnsUSXqE7AAdKJnmpjgTxpHP4e.', CAST(N'2025-03-16T10:02:45.113' AS DateTime), CAST(N'2025-03-16T10:02:45.113' AS DateTime), N'us', N'+1', N'user@gmail.com', N'user')
SET IDENTITY_INSERT [dbo].[AuthenticationMaster] OFF
GO
SET IDENTITY_INSERT [dbo].[LikeMaster] ON 

INSERT [dbo].[LikeMaster] ([id], [postId], [postType], [postPath], [phone], [likedAt]) VALUES (11, 9, N'image', N'uploads/images/7887941005/IMG_20240705_171807.jpg', N'7887941005', CAST(N'2025-03-19T17:33:54.280' AS DateTime))
INSERT [dbo].[LikeMaster] ([id], [postId], [postType], [postPath], [phone], [likedAt]) VALUES (14, 1, N'video', N'uploads/videos/7887941005/VID_20250309_124323.mp4', N'7887941005', CAST(N'2025-03-19T17:40:24.450' AS DateTime))
SET IDENTITY_INSERT [dbo].[LikeMaster] OFF
GO
SET IDENTITY_INSERT [dbo].[Postmaster] ON 

INSERT [dbo].[Postmaster] ([id], [postType], [postPath], [phone], [createdAt], [updatedAt]) VALUES (1, N'video', N'uploads/videos/7887941005/VID_20250309_124323.mp4', N'7887941005', CAST(N'2025-03-13T00:47:04.673' AS DateTime), CAST(N'2025-03-13T00:47:04.673' AS DateTime))
INSERT [dbo].[Postmaster] ([id], [postType], [postPath], [phone], [createdAt], [updatedAt]) VALUES (2, N'video', N'uploads/videos/7887941005/1_VID_20250309_124323.mp4', N'7887941005', CAST(N'2025-03-13T01:10:24.403' AS DateTime), CAST(N'2025-03-13T01:10:24.403' AS DateTime))
INSERT [dbo].[Postmaster] ([id], [postType], [postPath], [phone], [createdAt], [updatedAt]) VALUES (3, N'image', N'uploads/images/7887941005/IMG_20250313_004558.jpg', N'7887941005', CAST(N'2025-03-13T23:19:41.517' AS DateTime), CAST(N'2025-03-13T23:19:41.517' AS DateTime))
INSERT [dbo].[Postmaster] ([id], [postType], [postPath], [phone], [createdAt], [updatedAt]) VALUES (4, N'video', N'uploads/videos/7887941005/2_VID_20250309_124323.mp4', N'7887941005', CAST(N'2025-03-13T23:19:57.880' AS DateTime), CAST(N'2025-03-13T23:19:57.880' AS DateTime))
INSERT [dbo].[Postmaster] ([id], [postType], [postPath], [phone], [createdAt], [updatedAt]) VALUES (5, N'video', N'uploads/videos/7887941005/3_VID_20250309_124323.mp4', N'7887941005', CAST(N'2025-03-13T23:20:12.040' AS DateTime), CAST(N'2025-03-13T23:20:12.040' AS DateTime))
INSERT [dbo].[Postmaster] ([id], [postType], [postPath], [phone], [createdAt], [updatedAt]) VALUES (6, N'video', N'uploads/videos/1111111111/VID_20250309_124323.mp4', N'1111111111', CAST(N'2025-03-16T11:06:20.643' AS DateTime), CAST(N'2025-03-16T11:06:20.643' AS DateTime))
INSERT [dbo].[Postmaster] ([id], [postType], [postPath], [phone], [createdAt], [updatedAt]) VALUES (7, N'image', N'uploads/images/1111111111/IMG_20250309_124253.jpg', N'1111111111', CAST(N'2025-03-16T21:49:07.747' AS DateTime), CAST(N'2025-03-16T21:49:07.747' AS DateTime))
INSERT [dbo].[Postmaster] ([id], [postType], [postPath], [phone], [createdAt], [updatedAt]) VALUES (8, N'video', N'uploads/videos/1111111111/VID_20250317_092049.mp4', N'1111111111', CAST(N'2025-03-17T09:21:33.620' AS DateTime), CAST(N'2025-03-17T09:21:33.620' AS DateTime))
INSERT [dbo].[Postmaster] ([id], [postType], [postPath], [phone], [createdAt], [updatedAt]) VALUES (9, N'image', N'uploads/images/7887941005/IMG_20240705_171807.jpg', N'7887941005', CAST(N'2025-03-17T16:38:43.853' AS DateTime), CAST(N'2025-03-17T16:38:43.853' AS DateTime))
SET IDENTITY_INSERT [dbo].[Postmaster] OFF
GO
SET IDENTITY_INSERT [dbo].[TextPost] ON 

INSERT [dbo].[TextPost] ([id], [postType], [phone], [title], [message], [createdAt], [updatedAt]) VALUES (1, N'textPost', N'7887941005', N'this', N'this', CAST(N'2025-03-14T00:06:15.860' AS DateTime), CAST(N'2025-03-14T00:06:15.860' AS DateTime))
INSERT [dbo].[TextPost] ([id], [postType], [phone], [title], [message], [createdAt], [updatedAt]) VALUES (2, N'textPost', N'7887941005', N'hello', N'mobile', CAST(N'2025-03-14T21:50:10.570' AS DateTime), CAST(N'2025-03-14T21:50:10.570' AS DateTime))
INSERT [dbo].[TextPost] ([id], [postType], [phone], [title], [message], [createdAt], [updatedAt]) VALUES (3, N'textPost', N'7887941005', N'th', N'th', CAST(N'2025-03-14T21:53:38.973' AS DateTime), CAST(N'2025-03-14T21:53:38.973' AS DateTime))
SET IDENTITY_INSERT [dbo].[TextPost] OFF
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Authenti__B43B145F53365CD7]    Script Date: 22-03-2025 13:24:01 ******/
ALTER TABLE [dbo].[AuthenticationMaster] ADD UNIQUE NONCLUSTERED 
(
	[phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
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
ALTER TABLE [dbo].[TextPost] ADD  DEFAULT (getdate()) FOR [createdAt]
GO
ALTER TABLE [dbo].[TextPost] ADD  DEFAULT (getdate()) FOR [updatedAt]
GO
