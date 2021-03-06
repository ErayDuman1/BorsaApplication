USE [StockMarketData]
GO
/****** Object:  StoredProcedure [dbo].[Satis]    Script Date: 20.06.2021 23:45:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Proc [dbo].[Satis] @ItemID int, @UserID varchar(50) ,@ItemPrice decimal(18,4),@ItemAmount int
as
declare @TopAmount int
declare @TopPrice decimal
declare @SellerID varchar(50)

Set @SellerID=(Select Top 1 UserID From Tbl_UserItems Where ItemID=@ItemID order by ItemPrice)
Set @TopPrice=(Select Top 1 ItemPrice From Tbl_UserItems Where ItemID=@ItemID and UserID= @SellerID order by ItemPrice)
Set @TopAmount=(Select Top 1 ItemAmount From Tbl_UserItems Where ItemID=@ItemID and UserID=@SellerID order by ItemPrice )

if (@TopAmount>@ItemAmount)
begin	
    if(@ItemPrice=@TopPrice)
	begin
 	update Tbl_UserItems set ItemAmount-=@ItemAmount  Where UserID=@SellerID and ItemID=@ItemID and ItemAccept=1 and ItemPrice=@TopPrice
	update Tbl_Money set MoneyAmount-=((@ItemAmount*@TopPrice)+(@ItemAmount*@TopPrice*0.01)) Where UserID=@UserID and MoneyAccept=1
	update Tbl_Money set MoneyAmount+=(@ItemAmount*@TopPrice*0.01) Where UserID='Muhasebeci' and MoneyAccept=1
	insert into Tbl_PurchasedItems(UserID,ItemID,ItemAmount,DateOfPurchase) values(@UserID,@ItemID,@ItemAmount,GETDATE())
	end
	else
	begin
	insert into Tbl_BuyOrder(UserID,ItemID,ItemAmount,ItemPrice)values(@UserID,@ItemID,@ItemAmount,@ItemPrice)
	end

	if exists(Select * From Tbl_Money Where @SellerID=UserID)
	begin
    update Tbl_Money set MoneyAmount+=@TopPrice*@ItemAmount Where UserID=@SellerID and MoneyAccept=1
	end
	else
	begin
	insert into Tbl_Money(UserID,MoneyAmount,MoneyAccept) values (@SellerID,@TopPrice*@TopAmount,1)	
	end
end
else if(@TopAmount=@ItemAmount)
begin
    if(@ItemPrice=@TopPrice)
	begin
	Delete Tbl_UserItems Where ItemPrice=@TopPrice and UserID=@SellerID and ItemID=@ItemID and ItemAccept=1
	update Tbl_Money set MoneyAmount-=(@ItemAmount*@TopPrice)+(@ItemAmount*@TopPrice*0.01) Where UserID=@UserID and MoneyAccept=1
	update Tbl_Money set MoneyAmount+=(@ItemAmount*@TopPrice*0.01) Where UserID='Muhasebeci' and MoneyAccept=1
	insert into Tbl_PurchasedItems(UserID,ItemID,ItemAmount,DateOfPurchase) values(@UserID,@ItemID,@ItemAmount,GETDATE())
	end
	else
	begin
	insert into Tbl_BuyOrder(UserID,ItemID,ItemAmount,ItemPrice)values(@UserID,@ItemID,@ItemAmount,@ItemPrice)
	end

	if exists(Select * From Tbl_Money Where @SellerID=UserID)
	begin
    update Tbl_Money set MoneyAmount+=@TopPrice*@ItemAmount Where UserID=@SellerID and MoneyAccept=1
	end
	else
	begin
	insert into Tbl_Money(UserID,MoneyAmount,MoneyAccept) values (@SellerID,@TopPrice*@TopAmount,1)	
	end
end