local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local FileName = "SulfateLoaded"

-- Function to check if the loader has already been executed
local function checkLoader()
    -- PC/Exploit File Support
    if isfile and readfile then
        return isfile("Sulfate.cnfg")
    end

    -- Mobile Support: Check attribute on the player
    if LocalPlayer:GetAttribute(FileName) then
        return true
    end

    return false
end

-- Function to mark the loader as executed
local function markLoader()
    -- PC/Exploit File Support
    if writefile then
        writefile("Sulfate.cnfg", "Loaded")
        return
    end

    -- Mobile Support: Set attribute on the player
    LocalPlayer:SetAttribute(FileName, true)
end

-- Main Execution
if checkLoader() then
    LocalPlayer:Kick("Sulfate.lol Already Loaded")
else
    markLoader()
    warn("Sulfate Loader successfully executed. Run the main script now.")
end
