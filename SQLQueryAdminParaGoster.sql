USE [StockMarketData]
GO
/****** Object:  StoredProcedure [dbo].[AdminParaGoster]    Script Date: 16.05.2021 15:33:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [dbo].[AdminParaGoster]
as
Select m.UserID,m.MoneyAmount,m.MoneyAccept from Tbl_Money m Where m.MoneyAccept=0
