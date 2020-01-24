-- TODO: Installation Script
--  -> Script will install onto floppy disk drive

-- Modules
local component  = require("component")
local event      = require("event")
local filesystem = require("filesystem")
local gpu        = require("term").gpu()
local internet   = computer.getPrimary("internet")

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
local state = "" -- What Screen looks like

----  Graphics Processing  ----
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
-- process
local function drawContent()

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

-- Selections
local maxSelect = 1
local select = 1

-- keyEnterDown: Do stuff
local function keyEnterDown()
	if state == "" then
		state = "menu"
		maxSelect = 2
		select = 1
	elseif state == "menu" then
		if select == 1 then
			-- OS Selection
			state = "select-version"
			maxSelect = 2
			select = 1
		elseif select == maxSelect then
			-- Exit
			run = false
		end
	elseif state == "select-version" then
		if select == 1 then

		elseif select == maxSelect then
			-- Exit
			state = "menu"
			maxSelect = 2
			select = 1
		end
	end
end
keyEnterDown = ""

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
