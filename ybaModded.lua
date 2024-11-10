local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local function createNotify(text, timee, title)
    Fluent:Notify({
        Title = title,
        Content = text,
        SubContent = "",
        Duration = timee
    })

end
--// SERVICES \\--
local HttpService = game:GetService('HttpService')
local TeleportService = game:GetService('TeleportService')

local player = game.Players.LocalPlayer
repeat task.wait(1) until player.Character

makefolder("YbaModded")
--------------------------------------------
local DefaultFiles = {

	['YbaModded\\Settings_' .. player.Name] = {

		['AutoTp'] = false;
		['AutoSell'] = false;
        ['ServerHopItems'] = false;

	};




}

function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

for name, value in pairs(DefaultFiles) do -- SET DEFAULT VALUES
	if not pcall(function() readfile(name) end) then writefile(name, HttpService:JSONEncode(value)) end 
end

local Settings = HttpService:JSONDecode(readfile('YbaModded\\Settings_' .. player.Name)) 

local function Save (valueName, newValue)
	Settings[valueName] = newValue
	writefile('YbaModded\\Settings_' .. player.Name, HttpService:JSONEncode(Settings))
    print('Saved ' .. valueName)
end

local function GetSave (valueName)
	local value = Settings[valueName]
	if value == nil then
		if DefaultFiles['YbaModded\\Settings_' .. player.Name][valueName] ~= nil then
			Save(valueName, DefaultFiles['YbaModded\\Settings_' .. player.Name][valueName])
		else
			Save(valueName, false)
		end

		value = Settings[valueName]
	end

	if type(value) == 'table' then value = deepcopy(value) end

	return value
end
-------------------------------------------------
local Window = Fluent:CreateWindow({
    Title = "Skele Hub - YBA",
    SubTitle = "by menshaha",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Items = Window:AddTab({ Title = "Items", Icon = "square-chevron-right" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

--// FUNCTIONS \\--
function sellItem(item)
    if not GetSave('AutoSell') then return end

    local plrName = game.Players.LocalPlayer.Name
    local itemName = game.Players.LocalPlayer.Backpack:FindFirstChild(item.Name)
    itemName.Parent = game.Workspace.Living:FindFirstChild(plrName)

    local args = {
        [1] = "EndDialogue",
        [2] = {
            ["NPC"] = "Merchant",
            ["Option"] = "Option2",
            ["Dialogue"] = "Dialogue5"
        }
    }

    game:GetService("Players").LocalPlayer.Character.RemoteEvent:FireServer(unpack(args))

    createNotify('Item Sold: ' .. item.Name, 5, 'Success!')
end

function maxItems()
	
    items = {
        ["Mysterious Arrow"] = 0,
        ["Rokakaka"] = 0,
        ["Gold Coin"] = 0,
        ["Diamond"] = 0,
        ["Pure Rokakaka"] = 0,
        ["Quinton's Glove"] = 0,
        ["Steel Ball"] = 0,
        ["Rib Cage of The Saint's Corpse"] = 0,
        ["Zepellin's Headband"] = 0,
        ["Zeppeli's Hat"] = 0,
        ["Caesar's Headband"] = 0,
        ["Clackers"] = 0,
        ["Stone Mask"] = 0,
        ["Ancient Scroll"] = 0,
        ["Dio's Diary"] = 0,
        ["Pure Rokakaka"] = 0,
        ["Lucky Stone Mask"] = 0,
        ["Gold Umbrella"] = 0
    }

    local maxLimits = {  -- Add to the list if I missed an item
        ["Mysterious Arrow"] = 25,
        ["Rokakaka"] = 25,
        ["Gold Coin"] = 45,
        ["Diamond"] = 25,
        ["Pure Rokakaka"] = 10,
        ["Quinton's Glove"] = 10,
        ["Steel Ball"] = 10,
        ["Rib Cage of The Saint's Corpse"] = 10,
        ["Zepellin's Headband"] = 10,
        ["Zeppeli's Hat"] = 10,
        ["Caesar's Headband"] = 10,
        ["Clackers"] = 10,
        ["Stone Mask"] = 10,
        ["Ancient Scroll"] = 10,
        ["Dio's Diary"] = 10,
        ["Pure Rokakaka"] = 999,
        ["Lucky Stone Mask"] = 999,
        ["Lucky Arrow"] = 999,
        ["Gold Umbrella"] = 999,
        ["Left Arm of The Saint's Corpse"] = 999,
        ["Heart of The Saint's Corpse"] = 999,
        ["Pelvis of The Saint's Corpse"] = 999
    }

    for _, item in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if items[item.Name] then
            items[item.Name] = items[item.Name] + 1
            if (items[item.Name] >= (maxLimits[item.Name] or 25)) and GetSave('AutoSell') then
                sellItem(item)
                
            end
        end
    end
end

local function serverHop()
    local PlaceID = game.PlaceId
    local AllIDs = {}
    local foundAnything = ""
    local actualHour = os.date("!*t").hour
    
    function TPReturner()
        local sortOrder = math.random(1, 2) == 1 and "Asc" or "Desc"
        local Site
        if foundAnything == "" then
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' ..
            PlaceID .. '/servers/Public?sortOrder=' .. sortOrder .. '&limit=100&excludeFullGames=true'))
        else
            Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' ..
            PlaceID .. '/servers/Public?sortOrder=' .. sortOrder .. '&limit=100&cursor=' .. foundAnything .. '&excludeFullGames=true'))
        end
        if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
            foundAnything = Site.nextPageCursor
        end
    
        local serverList = {}
        for _, v in pairs(Site.data) do
            if tonumber(v.maxPlayers) > tonumber(v.playing) then
                table.insert(serverList, tostring(v.id))
            end
        end
    
        if #serverList > 0 then
            local randomIndex = math.random(1, #serverList) 
            local randomServerID = serverList[randomIndex]
            table.insert(AllIDs, randomServerID)
    
            pcall(function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, randomServerID, game.Players.LocalPlayer)
            end)
        else
            if foundAnything ~= "" then
                TPReturner()
            end
        end
    end
    
    function Teleport()
        while wait() do
            pcall(function()
                TPReturner()
            end)
        end
    end
    Teleport()

    createNotify('Server Hopping', 5, 'Success!')
end

local function travelTo(place)
    local plr = game.Players.LocalPlayer.Character.HumanoidRootPart
    local vector = place.Position - plr.Position

    local length = vector.Magnitude

    local num_tp = math.ceil(length / 50)

    plr.CFrame = plr.CFrame + vector / num_tp
end

function AutoFarmItems()
    print('Current Items Amount On Map: ' .. #game.Workspace.Item_Spawns.Items:GetChildren())

    if GetSave('AutoTp') then
        while GetSave('AutoTp') do
            if #game.Workspace.Item_Spawns.Items:GetChildren() <= 0 then
                if GetSave('ServerHopItems') then
                    coroutine.wrap(serverHop)()
                end
            end
            maxItems()
            for _, v in pairs(game.Workspace.Item_Spawns.Items:GetChildren()) do
                local item = v:FindFirstChild("MeshPart")
                if item and item:FindFirstChild("PointLight") then
                    local proxPrompt = v.ProximityPrompt
                    while item:IsDescendantOf(game.Workspace) and GetSave('AutoTp') do
                        local plr = game.Players.LocalPlayer.Character.HumanoidRootPart
                        travelTo(item)
                        if (item.Position - plr.Position).Magnitude < 5 then
                            maxItems()
                            fireproximityprompt(proxPrompt, 4)
                        end
                        task.wait(0.05)
                    end
                    maxItems()
                end
            end
            task.wait(1)
        end
    end
end

do
    local autoFarmToggle = Tabs.Items:AddToggle("AutoFarmItems", {Title = "Auto Farm Items", Default = GetSave("AutoTp") })
    local autoSellToggle = Tabs.Items:AddToggle("AutoSellItems", {Title = "Auto Sell Items", Default = GetSave("AutoSell") })
    local serverHopItems = Tabs.Items:AddToggle("ServHopItems", {Title = "Server Hop if No Items", Default = GetSave("ServerHopItems") })

    autoFarmToggle:OnChanged(function()
        Save('AutoTp', Options.AutoFarmItems.Value)
        AutoFarmItems()
    end)

    autoSellToggle:OnChanged(function()
        Save('AutoSell', Options.AutoSellItems.Value)
        maxItems()
    end)

    serverHopItems:OnChanged(function()
        Save('ServerHopItems', Options.ServHopItems.Value)
    end)
end

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("FluentScriptHub")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)


Window:SelectTab(1)

createNotify('Script Loaded!', 5, 'Success!')
