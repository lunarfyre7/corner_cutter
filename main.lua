local Layer = require 'layer'
local Autotile = require 'autotile'
local lg = love.graphics
--gamestates
-- local game = {}
-- local menu = {}

--most of this is example/testing code.

--conf
local size = 32
local function rotate(inp)
    local out = {}
    for x, row in ipairs(inp) do
        for y, cell in ipairs(row) do
            out[y]=out[y] or {}
            out[y][x] = cell
        end
    end
    return out
end
local function make_levels() --done like this to be able to rebuild level objects
    --test for a "level 1"
	local cobble = Autotile('img/minitiles.png', 'minitile') -- create an autotile instance
    local red = Autotile('img/minitiles-basic-clean.png', 'minitile')
    T = {cobble=1,red=2}
	local map = {}
	local mapsize = {20,15}
    local chance = 1/3
	for x=1,mapsize[1],1 do map[x]={} for y=1,mapsize[2],1 do map[x][y]= math.random()<chance and 2 or 0 end end --mapgen
	local map1 = rotate({ --PoC test map
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,1,1,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0},
			{0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0},
			{0,0,0,1,0,0,1,1,1,1,1,0,0,1,0,0,0,0,0,0,0},
			{0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,0,0,0,0,0,0},
			{1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0},
			{0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		})
    local map2 = rotate({
            {0,0,1,0,0},
            {0,0,1,0,0},
            {1,1,1,0,1},
            {0,0,1,1,0},
            {0,0,1,0,0},
        })
    local map3 = rotate({
            {0,0,0,0},
            {0,1,1,0},
            {0,1,0,0}
        })
	--[[local]] layer = Layer.Base{map=map, ts={cobble, red}, tilesize = size}
end

--function game:enter()
    --Construct game core here, from selected level and other settings from menu state.
    --self.core = Core(self.coreconf) --Coreconf is just settings to shove into the core init. Passed from another gamestate. i.e., for lvl selction and player select.
--end
function love.load(arg)
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    --TESTING/HACK - Actually this applies to this whole file...
    make_levels()
    print('init')
end
function love.update(dt)
    --stupid simple editor
	local px_pos = {love.mouse.getPosition()}
	local tile_pos = {math.ceil(px_pos[1]/size),math.ceil(px_pos[2]/size)}
	if love.mouse.isDown(1) then 
		layer:tile(tile_pos[1],tile_pos[2],1)
	elseif love.mouse.isDown(2) then 
		layer:tile(tile_pos[1],tile_pos[2],2)
	elseif love.mouse.isDown(3) then 
		layer:tile(tile_pos[1],tile_pos[2],0)
	end
end
function love.keypressed()
    
end
function love.draw()
    layer:draw()
    lg.print(string.format("use rmb/lmb/mmb to 'edit' \nFPS: %d", love.timer.getFPS()))
end