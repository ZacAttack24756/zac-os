-- Taken from Fuchas
local component = require("component")
if component.internet then
    -- If there is HTTP capability
    local internet = component.internet
    local connection = internet.request("https://raw.githubusercontent.com/ZacAttack24756/zac-os/master/install/OpenOS.lua")
    con.finishConnect()
    local buffer = ""
    local data = ""
    -- Read the Internet Data
    while data ~= nil do
        data = connection.read(math.huge)
        if data ~= nil then
            buffer = buffer .. data
        end
    end
    -- Close Connection and Load the Installation Script
    connection:close()
    load(buffer)()
else
    -- No Internet Access
    error("Internet Card is required for installation")
end
