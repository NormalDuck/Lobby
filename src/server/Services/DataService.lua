local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local DataStoreModule = require(ReplicatedStorage.Packages.Suphi)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Templete = {
    DuckCoins = 0,
	SwipeToLeave = false,
	Avatars = {},
	Inventory = {},
    DeveloperProducts = {
        Items = {},
        Gamepasses = {},
        TotalRobuxSpent = 0,
    },
}

type DatastoreTemplete = {
    DuckCoins: number,
	SwipeToLeave: boolean,
	Avatars: table,
	Inventory: table,
    DeveloperProducts: {
        Items: table,
        GamePasses: table,
    },
}

local DataService = Knit.CreateService {
    Name = "DataService",
    UserPurchasedProductSignal = Signal.new(),
    Client = {
    },
}

function DataService:SetData(Player: Player, Information: DatastoreTemplete): boolean
    local DataStore = DataStoreModule.find("Player", Player.UserId)
    if Player:IsDescendantOf(Players) and DataStore.State == true then
        DataStore.Value = Information
        if DataStore:Save() ~= "Saved" then
            return warn("[DataService] " .. Player.Name .. " cannot save " .. Information)
        else
            return true
        end
    else
        warn("[DataService] " .. Player.Name .. " isn't in the game")
    end
end

function DataService:GetData(Player: Player): DatastoreTemplete
    local DataStore = DataStoreModule.find("Player", Player.UserId)
    if Player:IsDescendantOf(Players) and DataStore.State == true then
        return DataStore.Value
    else
        warn("[DataService] " .. Player.Name .. " isn't in the game")
    end
end

function DataService:KnitStart()
    local MarketService = Knit.GetService("MarketService")
    MarketplaceService.ProcessReceipt = function(ReceiptInfo)
        local DataStore = DataStoreModule.find("Player", ReceiptInfo.PlayerId)
        if DataStore.State ~= true then return Enum.ProductPurchaseDecision.NotProcessedYet end
        local InfoType = MarketService:GetInfoTypeFromProductId(ReceiptInfo.ProductId)
        if InfoType == Enum.InfoType.Product then
            local Success, Error = pcall(function()
                DataStore.Value.DeveloperProducts.Items[tostring(ReceiptInfo.ProductId)] += 1
            end)
            if Error and not Success then
                DataStore.Value.DeveloperProducts.Items[tostring(ReceiptInfo.ProductId)] = 1
            end
        elseif InfoType == Enum.InfoType.GamePass then
            DataStore.Value.DeveloperProducts.GamePasses[tostring(ReceiptInfo.ProductId)] = true
        else print(InfoType) ; warn("[DataService] " .. " invaild infotype for " .. ReceiptInfo.ProductId .. " ProductId") end
        
        if DataStore:Save() ~= true then
            if InfoType == Enum.InfoType.GamePass then
                table.remove(DataStore.Value.DeveloperProducts.GamePasses, ReceiptInfo.ProductId)
            elseif InfoType == Enum.InfoType.Product then
                DataStore.Value.DeveloperProducts.Items[ReceiptInfo.ProductId] -= 1
            end
            return Enum.ProductPurchaseDecision.NotProcessedYet
        else
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
    end
end

function DataService:KnitInit()
    Players.PlayerAdded:Connect(function(player)
        if RunService:IsStudio() then return warn("Cannot run DataService under studio - Currently paused") end
        local DataStore = DataStoreModule.new("Player", player.UserId)
		while DataStore.State == false do
			if DataStore:Open(Templete) ~= "Success" then task.wait(6) end
            if not player:IsDescendantOf(Players) then DataStore:Destroy() break end
		end
    end)

    Players.PlayerRemoving:Connect(function(player)
        local DataStore = DataStoreModule.find("Player", player.UserId)
        if DataStore ~= nil then DataStore:Destroy() end
    end)

end

function DataService.Client:GetData(player)
    return table.freeze(TableUtil.Copy(DataStoreModule.find("Player", player.UserId).Value, true))
end

return DataService