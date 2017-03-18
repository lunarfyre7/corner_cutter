local Class = require 'lib.class'
local Layer = {}
local lg = love.graphics
--[[----(About)-------    
    
   
------------------]]--
Layer.Base = Class()
function Layer.Base:init(arg) --[[
Args: 
    size(optional): {xtiles, ytiles}
	tilesize: pixel size of tiles
    tileset, ts: an array of tilesets, indexes corrisponding to the map numbers
    maxSprites, ms (optional): max tile sprites
    map: the tile map, consisting of Tile objects(quads)
]]
	local autosize = {}
	if arg.map then --get map size
		autosize = {#arg.map[1], #arg.map[2]}
	end
    self.size = arg.size or autosize
    self.tileset = arg.tileset or arg.ts --TODO switch to MULTIPLE tilesets. ALSO need to use deepcopy on tilesets.
	self.tilesize = arg.tilesize or 32
    self.tilescale = arg.tilescale
    
    self.map = {} --the actual tile map
    --populate tile map to make a 2d array,
    for x=1, self.size[1], 1 do
        self.map[x] = {}
        for y=1, self.size[2], 1 do 
            self.map[x][y] = {}
        end
    end
    --setup spritebatch
    local auto_sprite_num = self.size[1]*self.size[2]
	local sprite_num = arg.maxSprites or arg.ms or auto_sprite_num
    --self.spritebatch = lg.newSpriteBatch(self.tileset.texture, arg.maxSprites or arg.ms or auto_sprite_num)
	for i, v in ipairs(self.tileset) do
		v:buildSprites(sprite_num)
	end
	
	--bind tilesets to layer
	self.tileset:layerInit(arg.map, sprite_num, self.tilescale) --ARG.MAP is a HACK
end
function Layer.Base:update(dt)
    
end
function Layer.Base:draw()
	self.tileset:draw()
end
Layer.Normal = Class(Layer.Base)
function Layer.Normal:init(arg) --[[
Args: 
    
]]
    Base.init(self, arg)
    
end
Layer.Background = Class(Layer.Base)
function Layer.Background:init(arg) --[[
Args: 
   speed: parallax speed modifier
]]
    Base.init(self, arg)
    self.speed = arg.apeed
end

return Layer