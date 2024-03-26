local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local MarketService = Knit.CreateService({
	Name = "MarketService",
	Client = {},
	_DeveloperProducts = {
		GamePasses = {
			690608475, --allow seed
			690931056, --more lobby size
		},
		Items = {
			1731658102,
		},
	},
})

function MarketService.Client:GetOwnedProducts()
	local OwnedGamePasses = {}
	local PurchasedItems = {}
end

function MarketService:GetProductIds()
	return self._DeveloperProducts
end

function MarketService.Client:GetProductIds()
	return self.Server._DeveloperProducts
end

function MarketService.Client:PurchaseProduct(Player, ProductId: number, InfoType: Enum.InfoType)
	if InfoType == Enum.InfoType.GamePass and self.Server._DeveloperProducts.Gamepas then
		MarketplaceService:PromptGamePassPurchase(Player, ProductId)
	end
end

function MarketService:GetInfoTypeFromProductId(ProductId: number)
	if table.find(self._DeveloperProducts.GamePasses, ProductId) then
		return Enum.InfoType.GamePass
	elseif table.find(self._DeveloperProducts.Items, ProductId) then
		return Enum.InfoType.Product
	else
		print("cannot find info type for given product id")
	end
end

function MarketService:KnitStart()
	local DataService = Knit.GetService("DataService")
	local IgnoreCurrencySpent = true
	DataService.UserPurchasedProductSignal:Connect(function(PlayerId: number, ProductId: number, CurrencySpent: number)
		if
			MarketplaceService:GetProductInfo(ProductId, Enum.InfoType.Product)
			and table.find(self._DeveloperProducts.Items, ProductId)
		then
			print("returned ")
			return Enum.InfoType.Product
		end
	end)
end

function MarketService.Client:PurchaseProduct(Player, ProductId, InfoType)
	local PrintService = ServerStorage.Source.Services.PrintService
	if InfoType == Enum.InfoType.Product then
		MarketplaceService:PromptProductPurchase(Player, ProductId)
	elseif InfoType == Enum.InfoType.GamePass then
		MarketplaceService:PromptGamePassPurchase(Player, ProductId)
	else
		PrintService:PrintClient(Player, "MarketService", "cannot prompt purchase for " .. ProductId)
	end
end

return MarketService
