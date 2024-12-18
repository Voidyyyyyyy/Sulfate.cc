local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local FileName = "Sulfate.mobile"

local function deleteLoader()
    if isfile and readfile then
        if isfile("Sulfate.cnfg") then
            delfile("Sulfate.cnfg")
        end
    end

    if LocalPlayer:GetAttribute(FileName) then
        LocalPlayer:SetAttribute(FileName, nil)
    end
end

deleteLoader()
