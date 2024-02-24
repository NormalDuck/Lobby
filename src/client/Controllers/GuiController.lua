local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Mouse = Players.LocalPlayer:GetMouse()
local GuiService = game:GetService("GuiService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local GuiController = Knit.CreateController{Name = "GuiController"}

--[[References]]--
local Player = Players.LocalPlayer
local MainMenu = Player.PlayerGui:WaitForChild("MainMenu")
local ViewportSize = workspace.CurrentCamera.ViewportSize
------------------
type Configurations = {
    LobbyOwner: Player,
    PlayersInLobby: table,
    Seed: number,
    MazeSize: number,
    LobbySize: number,
    Visibility: "Private" | "Public" | "Friends",
}
function GuiController:KnitInit()
    --Path configuration--

end
function NumberInRange(number: number, smallest: number, greatest: number): boolean
    if number >= smallest and number <= greatest then
      return true
    else
      return false
    end
end
function GuiController:KnitStart()
    local MarketService = Knit.GetService("MarketService")
    local LobbyService = Knit.GetService("LobbyService")
    local Screens = {
        Starting = MainMenu:FindFirstChild("StartingScreen"), -- done
        Shop = MainMenu:FindFirstChild("ShopScreen"), --done
        Credit = MainMenu:FindFirstChild("CreditScreen"),
        Play = MainMenu:FindFirstChild("PlayScreen"),
    }
    --[[Helper Functions]]--
    local function GetUserPlatform(): string
        if (GuiService:IsTenFootInterface()) then
            return "Console"
        elseif (UserInputService.TouchEnabled and not UserInputService.MouseEnabled) then
            local DeviceSize = workspace.CurrentCamera.ViewportSize;
            if ( DeviceSize.Y > 600 ) then
                return "Mobile"
            else
                return "Mobile"
            end
        else
            return "Desktop"
        end
    end
    local function SwitchScreen(ScreenName)
        for ScreenFolderName, Screen: Frame in pairs(Screens) do
            if ScreenFolderName ~= ScreenName then
                Screen.Visible = false
            else
                Screen.Visible = true
            end
        end
    end
    local function HasProperty(Object: Instance, PropertyName: string): boolean
        local success, _ = pcall(function()
            Object[PropertyName] = Object[PropertyName]
        end)
        return success
    end
    ------------------------
    --[[Starting Screen]]--
    do
        Screens.Starting.Play.MouseButton1Click:Connect(function()
            SwitchScreen("Play")
        end)
        Screens.Starting.Shop.MouseButton1Click:Connect(function()
            SwitchScreen("Shop")
        end)
        Screens.Starting.Credit.MouseButton1Click:Connect(function()
            SwitchScreen("Credit")
        end)
    end
    -----------------------

    --[[Shop Screen]]--
    do

        local DescriptionSection = Screens.Shop.DescriptionSection
        local Header = Screens.Shop.ShopSection.Header
        local ProductsScrollFrame = Screens.Shop.ShopSection.ScrollingFrame
        MarketService:GetProductIds():andThen(function(ProductIds)
            local GamePasses = ProductIds.GamePasses
            local Items = ProductIds.Items
            for i = 1, #GamePasses do
                local Gamepass = MarketplaceService:GetProductInfo(GamePasses[i],Enum.InfoType.GamePass)
                if not ProductsScrollFrame:FindFirstChild(Gamepass.Name) then
                    local ImageButton = Instance.new("ImageButton")
                    ImageButton.Image = "rbxassetid://" .. Gamepass.IconImageAssetId
                    ImageButton.Name = Gamepass.Name
                    ImageButton.MouseButton1Click:Connect(function()
                        DescriptionSection:FindFirstChild("Name").Text = Gamepass.Name
                        DescriptionSection:FindFirstChild("Description").Text = Gamepass.Description or "No description, please report in #Bug-Report"
                        if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamePasses[i]) then
                            DescriptionSection:FindFirstChild("Purchase").Text = "Purchased"
                        else
                            DescriptionSection:FindFirstChild("Purchase").Text = Gamepass.PriceInRobux .. " Robux"
                        end
                        DescriptionSection.Image.Image = "rbxassetid://" .. Gamepass.IconImageAssetId
                        DescriptionSection:SetAttribute("InfoType", Enum.InfoType.GamePass)
                        DescriptionSection:SetAttribute("AssetId", GamePasses[i])
                    end)
                    ImageButton.Parent = ProductsScrollFrame
                    ProductsScrollFrame:GetAttributeChangedSignal("Type"):Connect(function()
                        if ProductsScrollFrame:GetAttribute("Type") == "Gamepass" then
                            ImageButton.Visible = true
                        else
                            ImageButton.Visible = false
                        end
                    end)
                end
            end
            for i = 1, #Items do
                local Item = MarketplaceService:GetProductInfo(Items[i], Enum.InfoType.Product)
                if not ProductsScrollFrame:FindFirstChild(Item.Name) then
                    local ImageButton = Instance.new("ImageButton")
                    ImageButton.Image = "rbxassetid://" .. Item.IconImageAssetId
                    ImageButton.Name = Item.Name
                    ImageButton.MouseButton1Click:Connect(function()
                        DescriptionSection:FindFirstChild("Name").Text = Item.Name
                        DescriptionSection:FindFirstChild("Description").Text = Item.Description or "No description, please report in #Bug-Report"
                        if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Items[i]) then
                            DescriptionSection:FindFirstChild("Purchase").Text = "Purchased"
                        else
                            DescriptionSection:FindFirstChild("Purchase").Text = Item.PriceInRobux .. " Robux"
                        end
                        DescriptionSection.Image.Image = "rbxassetid://" .. Item.IconImageAssetId
                        DescriptionSection:SetAttribute("InfoType", Enum.InfoType.Product)
                        DescriptionSection:SetAttribute("AssetId", Items[i])
                    end)
                    ImageButton.Parent = ProductsScrollFrame
                    ProductsScrollFrame:GetAttributeChangedSignal("Type"):Connect(function()
                        if ProductsScrollFrame:GetAttribute("Type") == "Gamepass" then
                            ImageButton.Visible = true
                        else
                            ImageButton.Visible = false
                        end
                    end)
                end
            end
        end)

        --[[topbar]]--
        do
            Header.Gamepass.MouseButton1Click:Connect(function()
                ProductsScrollFrame:SetAttribute("Type", "Gamepass")
            end)
            Header.Avatar.MouseButton1Click:Connect(function()
                ProductsScrollFrame:SetAttribute("Type", "Avatar")
            end)
            Header.Donation.MouseButton1Click:Connect(function()
                ProductsScrollFrame:SetAttribute("Type", "Donation")
            end)
            Header.Items.MouseButton1Click:Connect(function()
                ProductsScrollFrame:SetAttribute("Type", "Items")
            end)
        end

        DescriptionSection.Purchase.MouseButton1Click:Connect(function()
            if string.match(DescriptionSection.Purchase.Text, "Robux") then
                MarketService:PurchaseProduct(DescriptionSection:GetAttribute("AssetId"), DescriptionSection:GetAttribute("InfoType"))
            end
        end)

        
    end

    -------------------

    --[[Play Screen]]--
    do
        -------------------[[References]]-------------------
        local CreateLobbyFolder = Screens.Play.Base.CreateLobby

        local JoinLobbyFolder = Screens.Play.Base.JoinLobby
            local JoinLobbyScroll = JoinLobbyFolder.Scroll
            local SampleJoinLobby = JoinLobbyScroll.Example

        local LobbyFolder = Screens.Play.Base.Lobby
            local LobbyScroll = LobbyFolder.PlayerBase.Scroll
            local SampleInLobbyPlayerGui = LobbyScroll.LobbyPlayerExample
            local SampleOwnerPlayerGui = LobbyScroll.LobbyOwnerExample

        local Header = Screens.Play.Base.Header

        local Preview = CreateLobbyFolder.Preview
        Preview.Username.Text = Player.Name
        Preview.PlayerIcon.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        --[[Essential Variables]]--
        local LobbyInfo = {
            LobbyOwner = Player,
            PlayersInLobby = {Player},
            Seed = 0,
            MazeSize = 10,
            LobbySize = 1,
            Visibility = "Private",
            IsCreated = false,
        }
        type LobbyData = {
            LobbyOwner: Player,
            PlayersInLobby: table,
            Seed: number,
            MazeSize: number,
            LobbySize: number,
            Visibility: "Private" | "Public" | "Friends",
            IsCreated: boolean,
        }
        --[[Helper Functions]]--
        local function SwitchFolders(FolderName: "CreateLobby" | "JoinLobby" | "Lobby")
            for _, GuiObject: GuiObject in ipairs(CreateLobbyFolder:GetChildren()) do
                if HasProperty(GuiObject, "Visible") then
                    GuiObject.Visible = FolderName == "CreateLobby"
                end
            end
            for _, GuiObject: GuiObject in ipairs(JoinLobbyFolder:GetChildren()) do
                if HasProperty(GuiObject, "Visible") then
                    GuiObject.Visible = FolderName == "JoinLobby"
                end
            end
            for _, GuiObject: GuiObject in ipairs(LobbyFolder:GetChildren()) do
                if HasProperty(GuiObject, "Visible") then
                    GuiObject.Visible = FolderName == "Lobby"
                end
            end
        end
        local function SwitchHeader(HeaderType: "Default" | "InLobby" | "LobbyOwner")
            if HeaderType == "Default" then
				for _, Object: Instance in ipairs(Header:GetChildren()) do
                    if Object:IsA("TextButton") and Object.Name ~= "Create" and Object.Name ~= "Join" then
                        Object.Visible = false
                    else
                        Object.Visible = true
                    end
				end
            end
            if HeaderType == "InLobby" then
				for _, Object: Instance in ipairs(Header:GetChildren()) do
                    if Object:IsA("TextButton") and Object.Name ~= "Leave" then
                        Object.Visible = false
                    else
                        Object.Visible = true
                    end
				end
            end
            if HeaderType == "LobbyOwner" then
				for _, Object: Instance in ipairs(Header:GetChildren()) do
                    if Object:IsA("TextButton") and Object.Name ~= "Start" and Object.Name ~= "Delete" then
                        Object.Visible = false
                    else
                        Object.Visible = true
                    end
				end
            end
        end

        ------------------------
        SwitchFolders("JoinLobby") ; SwitchHeader("Default")

        Header.Join.MouseButton1Click:Connect(function()
            SwitchFolders("JoinLobby")
        end)

        Header.Create.MouseButton1Click:Connect(function()
            SwitchFolders("CreateLobby")
        end)

        CreateLobbyFolder.Create.MouseButton1Click:Connect(function()
            LobbyFolder.LobbySize.Text = "LobbySize: " .. LobbyInfo.LobbySize
            LobbyFolder.MazeSize.Text = "MazeSize: " .. LobbyInfo.MazeSize
            LobbyFolder.Seed.Text = "Seed: " .. LobbyInfo.Seed
            LobbyFolder.Players.Text = "Players: " ..#LobbyInfo.PlayersInLobby
            LobbyService:CreateLobby()
            SwitchFolders("Lobby") ; SwitchHeader("LobbyOwner")
            Header.Delete.MouseButton1Click:Once(function()
                LobbyService:DestroyLobby()
                SwitchFolders("CreateLobby") ; SwitchHeader("Default")
            end)
            Header.Start.MouseButton1Click:Once(function()
                LobbyService:StartGame()
            end)
        end)

        --[[Create Lobby Folder Inputs]]--
        do
            CreateLobbyFolder.LobbySize.Input.FocusLost:Connect(function()
                if type(tonumber(CreateLobbyFolder.LobbySize.Input.Text)) == "number" then
                    local Input = tonumber(CreateLobbyFolder.LobbySize.Input.Text)
                    if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 690931056) then
                        if not NumberInRange(Input, 1, 8) then
                            if Input <= 8 then
                                if Input <= 1 then
                                    LobbyInfo.LobbySize = 1
                                end
                            else
                                LobbyInfo.LobbySize = 8
                            end
                        else
                            LobbyInfo.LobbySize = Input
                        end
                        
                        CreateLobbyFolder.LobbySize.Input.Text = LobbyInfo.LobbySize
                        LobbyService:EditLobby(LobbyInfo)
                    else
                        if not NumberInRange(Input, 1, 4) then
                            if Input <= 4 then
                                if Input <= 1 then
                                    LobbyInfo.LobbySize = 1
                                end
                            else
                                LobbyInfo.LobbySize = 4
                            end
                        else
                            LobbyInfo.LobbySize = Input
                        end
                        CreateLobbyFolder.LobbySize.Input.Text = LobbyInfo.LobbySize
                        print(LobbyInfo.LobbySize)
                        LobbyService:EditLobby(LobbyInfo)
                    end
                else
                    CreateLobbyFolder.LobbySize.Input.Text = "Invaild Format"
                    task.wait(0.2)
                    CreateLobbyFolder.LobbySize.Input.Text = LobbyInfo.LobbySize
                end
            end)

            CreateLobbyFolder.MazeSize.Input.FocusLost:Connect(function()
                if type(tonumber(CreateLobbyFolder.MazeSize.Input.Text)) == "number" then
                    local Input = tonumber(CreateLobbyFolder.MazeSize.Input.Text)
                    if not NumberInRange(Input, 10, 150) then
                        if Input <= 150 then
                            if Input <= 10 then
                                LobbyInfo.MazeSize = 10
                            end
                        else
                            LobbyInfo.MazeSize = 150
                        end
                    else
                        LobbyInfo.MazeSize = Input
                    end
                    CreateLobbyFolder.MazeSize.Input.Text = LobbyInfo.MazeSize
                    LobbyService:EditLobby(LobbyInfo)
                else
                    CreateLobbyFolder.MazeSize.Input.Text = "Invaild Format"
                    task.wait(0.2)
                    CreateLobbyFolder.MazeSize.Input.Text = LobbyInfo.MazeSize
                end
            end)

            if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 690608475) then
                CreateLobbyFolder.Seed.Input.FocusLost:Connect(function()
                    if type(tonumber(CreateLobbyFolder.Seed.Input.Text)) == "number" then
                        local Input = tonumber(CreateLobbyFolder.Seed.Input.Text)
                        LobbyInfo.Seed = Input
                        CreateLobbyFolder.Seed.Input.Text = LobbyInfo.Seed or ""
                        LobbyService:EditLobby(LobbyInfo)
                    else
                        CreateLobbyFolder.Seed.Input.Text = "Invaild Format"
                        task.wait(0.2)
                        CreateLobbyFolder.Seed.Input.Text = ""
                    end
                end)
            end

            CreateLobbyFolder.Visibility.Friends.MouseButton1Click:Connect(function()
                CreateLobbyFolder.Visibility.Friends.BackgroundColor3 = Color3.fromHex("#2b4056")
                CreateLobbyFolder.Visibility.Public.BackgroundColor3 = Color3.fromHex("#141e28")
                CreateLobbyFolder.Visibility.Private.BackgroundColor3 = Color3.fromHex("#141e28")
                LobbyInfo.Visibility = "Friends"
                LobbyService:EditLobby(LobbyInfo)
            end)

            CreateLobbyFolder.Visibility.Public.MouseButton1Click:Connect(function()
                CreateLobbyFolder.Visibility.Friends.BackgroundColor3 = Color3.fromHex("#141e28")
                CreateLobbyFolder.Visibility.Public.BackgroundColor3 = Color3.fromHex("#2b4056")
                CreateLobbyFolder.Visibility.Private.BackgroundColor3 = Color3.fromHex("#141e28")
                LobbyInfo.Visibility = "Public"
                LobbyService:EditLobby(LobbyInfo)
            end)

            CreateLobbyFolder.Visibility.Private.MouseButton1Click:Connect(function()
                CreateLobbyFolder.Visibility.Friends.BackgroundColor3 = Color3.fromHex("#141e28")
                CreateLobbyFolder.Visibility.Public.BackgroundColor3 = Color3.fromHex("#141e28")
                CreateLobbyFolder.Visibility.Private.BackgroundColor3 = Color3.fromHex("#2b4056")
                LobbyInfo.Visibility = "Private"
                LobbyService:EditLobby(LobbyInfo)
            end)
        end
        --[[Create Lobby Folder Inputs]]--

        LobbyService.UserKickedSignal:Connect(function()
            print("i got kicked")
            SwitchFolders("JoinLobby") ; SwitchHeader("Default")
        end)

        LobbyService.CurrentLobbies:Observe(function(CurrentLobbies)

            --[[Garbadge Collection]]--
            coroutine.wrap(function()
                for i, GuiObject: GuiObject in JoinLobbyScroll:GetChildren() do
                    if not table.find(CurrentLobbies, Players:GetUserIdFromNameAsync(GuiObject.Name)) and GuiObject ~= SampleJoinLobby and GuiObject:IsA("Frame") then
                        GuiObject:Destroy()
                    end
                end
            end)()

            for LobbyUserId, LobbyData: LobbyData in pairs(CurrentLobbies) do
                if not JoinLobbyScroll:FindFirstChild(LobbyData.LobbyOwner.Name) then
                    local Clone: Instance = SampleJoinLobby:Clone()
                    Clone.Visible = false
                    Clone.PlayerIcon.Image = Players:GetUserThumbnailAsync(LobbyUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                    Clone.Username.Text = LobbyData.LobbyOwner.Name
                    Clone.Name = LobbyData.LobbyOwner.Name
                    Clone.Parent = JoinLobbyScroll
                    Clone.Join.MouseButton1Click:Connect(function()
                        local Response = LobbyService:JoinLobby(LobbyData.LobbyOwner)
                        if not Response then return end
                        SwitchFolders("Lobby") ; SwitchHeader("InLobby")
                        --gets the current data, overrides the lobby data
                        local NewLobbyData = LobbyService.CurrentLobbies:Get()[LobbyUserId]
                            LobbyFolder.LobbySize.Text = "LobbySize: " .. NewLobbyData.LobbySize
                            LobbyFolder.MazeSize.Text = "MazeSize: " .. NewLobbyData.MazeSize
                            LobbyFolder.Seed.Text = "Seed: " .. NewLobbyData.Seed
                            LobbyFolder.Players.Text = "Players: " ..#NewLobbyData.PlayersInLobby
                        Header.Leave.MouseButton1Click:Once(function()
                            LobbyService:LeaveLobby(NewLobbyData.LobbyOwner)
                            SwitchFolders("JoinLobby") ; SwitchHeader("Default")
                        end)
                    end)
                end
                
                local LobbyGui: GuiObject = JoinLobbyScroll:WaitForChild(LobbyData.LobbyOwner.Name)
                if LobbyData.Visibility == "Public" and LobbyData.LobbyOwner ~= Player and LobbyData.IsCreated then
                    LobbyGui.Visible = true
                end
                if LobbyData.Visibility == "Friends" and LobbyData.LobbyOwner:IsFriendsWith(Player.UserId) and LobbyData.IsCreated then
                    LobbyGui.Visible = true
                elseif LobbyData.Visibility == "Friends" and not LobbyData.LobbyOwner:IsFriendsWith(Player.UserId) and LobbyData.Visibility ~= "Public" then
                    LobbyGui.Visible = false
                end
                if LobbyData.Visibility == "Private" then
                    LobbyGui.Visible = false
                end
                if not LobbyData.IsCreated then
                    LobbyGui.Visible = false
                end

                LobbyGui.LobbySize.Text = #LobbyData.PlayersInLobby .. "/" .. LobbyData.LobbySize
                Preview.LobbySize.Text = #LobbyData.PlayersInLobby .. "/" .. LobbyInfo.LobbySize
                --checks if player is in lobby
                if table.find(LobbyData.PlayersInLobby, Player) and LobbyData.IsCreated then
                    local _IsOwner = LobbyData.LobbyOwner == Player and LobbyData.IsCreated
                    for _, OtherPlayerLobbyGui: Instance in ipairs(LobbyScroll:GetChildren()) do
                        if not table.find(CurrentLobbies, LobbyUserId) and OtherPlayerLobbyGui ~= SampleOwnerPlayerGui and OtherPlayerLobbyGui ~= SampleInLobbyPlayerGui and not OtherPlayerLobbyGui:IsA("UIListLayout") then
                            OtherPlayerLobbyGui:Destroy()
                        end
                    end

                    for _, OtherPlayer: Player in ipairs(LobbyData.PlayersInLobby) do
                        if not LobbyScroll:FindFirstChild(OtherPlayer.Name) then
                            if _IsOwner then
                                if OtherPlayer == Player then
                                    local OwnerGui = SampleInLobbyPlayerGui:Clone()
                                    OwnerGui.Parent = LobbyScroll
                                    OwnerGui.Username.Text = Player.Name
                                    OwnerGui.PlayerIcon.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                                    OwnerGui.Visible = true
                                    OwnerGui.Name = OtherPlayer.Name
                                else
                                    local OtherPlayerGui = SampleOwnerPlayerGui:Clone()
                                    OtherPlayerGui.PlayerIcon.Image = Players:GetUserThumbnailAsync(OtherPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                                    OtherPlayerGui.Username.Text = OtherPlayer.Name
                                    OtherPlayerGui.Parent = LobbyScroll
                                    OtherPlayerGui.Visible = true
                                    OtherPlayerGui.Name = OtherPlayer.Name
                                    OtherPlayerGui.Parent = LobbyScroll
                                    OtherPlayerGui.Delete.MouseButton1Click:Connect(function()
                                        LobbyService:KickPlayer(OtherPlayer)
                                    end)
                                end
                            else
                                local OtherPlayerGui: GuiObject = SampleInLobbyPlayerGui:Clone()
                                OtherPlayerGui.Username.Text = OtherPlayer.Name
                                OtherPlayerGui.PlayerIcon.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
                                OtherPlayerGui.Visible = true
                                OtherPlayerGui.Name = OtherPlayer.Name
                                OtherPlayerGui.Parent = LobbyScroll
                            end
                        end
                    end
                end
            end
        end)
    end
    -------------------

    --[[Swipe Detector]]--
    do
        local SwipeFolder: Folder = MainMenu:WaitForChild("Swipe")
        local SwipeDetector: Frame = SwipeFolder:WaitForChild("SwipeDetector")
        local EndDetector: Frame = SwipeFolder:WaitForChild("EndDetector")
        local BlackSwipe: Frame = SwipeFolder:WaitForChild("BlackSwipe")
        if GetUserPlatform() == "Mobile" then
            EndDetector.Size = UDim2.new(0.7,0,1,0)
        end
        SwipeDetector.MouseEnter:Connect(function()
            Mouse.Button1Down:Once(function()
                SwipeDetector.MouseLeave:Wait()
                local BreakSignal = false
                local ActivateSignal = false
                UserInputService.InputEnded:Once(function()
                    BreakSignal = true
                end)
                EndDetector.MouseEnter:Once(function()
                    ActivateSignal = true
                end)
                BlackSwipe.Transparency = 0
                while task.wait() do
                    BlackSwipe.Size = UDim2.new(0, Mouse.X, 1, 0)
                    if BreakSignal then
                        if ActivateSignal then
                            local tweenInfo = TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut)
                            TweenService:Create(BlackSwipe,tweenInfo,{Transparency = 1}):Play()
                            SwitchScreen("Starting")
                            BlackSwipe.Size = UDim2.new(1,0,1,0)
                            task.wait(tweenInfo.Time)
                            BlackSwipe.Size = UDim2.new(0,0,1,0)
                        else
                            local tweenInfo = TweenInfo.new(BlackSwipe.Size.X.Offset / ViewportSize.X / 6, Enum.EasingStyle.Linear,Enum.EasingDirection.InOut)
                            TweenService:Create(BlackSwipe,tweenInfo,{Size = UDim2.new(0,0,1,0)}):Play()
                        end
                        break
                    end
                end
            end)
        end)
    end

end
return GuiController