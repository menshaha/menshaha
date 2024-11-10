if GetSave('AutoTp') then
        while GetSave('AutoTp') do
            if #game.Workspace.Item_Spawns.Items:GetChildren() <= 0 then
                if GetSave('ServerHopItems') then
                    serverHop()
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
