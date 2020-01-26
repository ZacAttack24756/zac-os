-- TODO: Installation Script
--  -> Script will install onto floppy disk drive

-- Modules
local component  = require("component")
local event      = require("event")
local filesystem = require("filesystem")
local gpu        = require("term").gpu()
local internet   = component.getPrimary("internet")

-- Static
local repos = {
	{
		name = "stable",
		desc = "Latest Stable Release",
		url = "https://raw.githubusercontent.com/ZacAttack24756/zac-os/stable"
	},{
		name = "dev",
		desc = "Development Branch (unstable)",
		url = "https://raw.githubusercontent.com/ZacAttack24756/zac-os/master"
	}
} -- Official Github Repo
local width, height = gpu.getResolution()

-- Variables
local run = true -- Whether the choose loop should continue running
local state = "menu" -- What Screen looks like
local select = 1
local maxSelect = 2
local prevState = ""
local selectedRepo = 0

----  Graphics Processing  ----
local preset = {
	white = function()
		gpu.setBackground(0x000000)
		gpu.setForeground(0xFFFFFF)
	end,
	black = function()
		gpu.setBackground(0xFFFFFF)
		gpu.setForeground(0x000000)
	end,
	sel = function(bool)
		if (bool == true) then
			preset.black()
		else
			preset.white()
		end
	end
}
-- Set Resolution
if width > 80 or height > 25 then
	gpu.setResolution(80, 25)
	width = 80
	height = 25
end

-- drawBorder (Taken from Fuchas)
local function drawBorder(x, y, w, h)
	 gpu.set(x, y, "") -- Top Left Corner
	 gpu.set(x + w, y, "") -- Top Right Corner
	gpu.fill(x + 1, y, w - 1, 1, "") -- Top Border
	gpu.fill(x + 1, y + h, w - 1, 1, "") -- Bottom Border
	 gpu.set(x, y + h, "") -- Bottom Left Corner
	 gpu.set(x + w, y + h, "") -- Bottom Right Corner
	gpu.fill(x, y + 1, 1, h - 1, "") -- Left Border
	gpu.fill(x + w, y + 1, 1, h - 1, "") -- Right Border
end
local function drawTextList(startX, startY, list)
	local num = 0
	for i, v in pairs(list) do
		gpu.set(startX, startY + num, v)
		num = num + 1
	end
end
-- Dynamic Functions
local function drawMenuOptions()
	preset.sel(select == 1)
	gpu.set(6, 11, "Install onto Floppy Disk")
	preset.sel(select == 2)
	gpu.set(6, 12, "Exit")
end
local function drawVersionOptions()
	for i, v in pairs(repos) do
		preset.sel(select == i)
		gpu.set(6, 10 + i, repos[i].desc)
	end
	preset.sel(select == (#repos + 1))
	gpu.set(6, 11 + #repos, "Cancel")
end
local function drawConfirm()
	preset.sel(select == 1)
	gpu.set(6, 11, "Confirm")
	preset.sel(select == 2)
	gpu.set(6, 12, "Cancel")
end
-- drawState
local function drawState()
	gpu.setBackground(0x000000)
	gpu.fill(1, 1, 80, 25, " ")
	gpu.set((width / 2) - 10, 1, "Zac-OS  Installation")
	if state == "menu" then
		drawTextList(5, 5, {
			"Choose an installation option below"
		})
		drawMenuOptions()
	elseif state == "select-version" then
		drawTextList(5, 5, {
			"Choose a version"
		})
		drawVersionOptions()
	elseif state == "confirm" then
		drawConfirm()
	end
end

----  Installation  ----
-- download: Pulls a text file from a source
local function textDownload(url)
	local connection = internet.request(url)
	local buffer = ""
	local data = ""
	while data ~= nil do
		data = con.read(math.huge)
		if data ~= nil then
			buffer = buffer .. data
		end
	end
	con.close()
	return buffer
end

-- process: Install Operating System
local function process()
end

-- keyEnterDown: Do stuff
local function keyEnterDown()
	if state == "menu" then
		if select == 1 then
			-- OS Selection
			prevState = state
			state = "select-version"
			maxSelect = #repos + 1
			select = 1
		elseif select == maxSelect then
			-- Exit
			run = false
		end
	elseif state == "select-version" then
		if repos[select] then
			-- Choose Repository
			prevState = state
			state = "confirm"
			selectedRepo = select
			maxSelect = 2
			select = 1
		elseif select == maxSelect then
			-- Exit
			prevState = state
			state = "menu"
			maxSelect = 2
			select = 1
		end
	elseif state == "confirm" then
		if select == 1 then
			-- Confirm
			process()
		elseif select == 2 then
			-- Cancel
			state = prevState
			prevState = "confirm"
		end
	end
	if run == true then
		drawState()
	end
end

-- loop: Loops through to allow user to choose
os.sleep(0.5)
while run do
	local id, _, _, charCode, _ = event.pull()
	if id == "interrupted" then
		-- If the process was interrupted (Ctrl + C)
		run = false
		break
	elseif id == "key_down" then
		-- keyboard was pressed down
		if charCode == 200 then
			-- Up arrow key
			if selected > 1 then
				selected = selected - 1
			end
		elseif charCode == 208 then
			-- Down arrow key
			if selected < maxSelect then
				selected = selected + 1
			end
		end
	elseif id == "key_up" then
		-- keybaord press finished
		if charCode == 28 then
			-- Enter key was pressed up
			keyEnterDown()
		end
	end
end
