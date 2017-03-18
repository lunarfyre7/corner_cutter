local Core = require 'core' 
local Layer = require 'layer'
local Autotile = require 'autotile'
local lg = love.graphics
--gamestates
local game = {}
local menu = {}

--most of this is example/testing code.

--conf
local levels = {}
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
	local cobble = Autotile('img/minitiles-basic.png', 'minitile') -- create an autotile instance
	local map = { --PoC test map
			{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
			{0,0,1,1,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0},
			{0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0},
			{0,0,0,1,0,0,1,1,1,1,1,0,0,1,0,0,0,0,0,0,0},
			{0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,0,0,0,0,0,0},
			{1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0},
			{0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		}
    local map2 = {
            {0,0,1,0,0},
            {0,0,1,0,0},
            {1,1,1,0,1},
            {0,0,1,1,0},
            {0,0,1,0,0},
        }
    local map3 = {
            {0,0,0,0},
            {0,1,1,0},
            {0,1,0,0}
        }
	--[[local]] layer = Layer.Base{map=rotate(map), ts=cobble, tilescale=1.5}
end

--function game:enter()
    --Construct game core here, from selected level and other settings from menu state.
    --self.core = Core(self.coreconf) --Coreconf is just settings to shove into the core init. Passed from another gamestate. i.e., for lvl selction and player select.
--end
function love.load(arg)
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    --TESTING/HACK
    make_levels()
    print('init')
end
function love.update(dt)
    
end
function love.keypressed()
    
end
function love.draw()
    layer:draw()
end