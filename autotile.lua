local Class = require 'class'
local AutoTile = Class()
local lg = love.graphics
--[[NOTE this should be split into different subclasses (stupid type conditionals)
    Should be:
    Tile  - basic drawing and api base
    Aware(Tile) - aware style tiles
    Minitile(Tile or Aware) -minitiles
    AutoFactory() - function to detect the type type and return an instance of the proper class. For syntax sugar.
]]
function AutoTile:init(sprite, type_) --important
	self.texture = lg.newImage(sprite)
    self.texture:setFilter('nearest','nearest')
	self.type = type_ or 'auto' --Planned types: minitile (4 small tiles per tile), aware tiles, dumb/named/indexed tiles. Type could be guessed from image shape.
	
	--variables inited/set by other functions
	self.spritebatch = nil --:buildSprites
	self.map = {} --:settleTiles
		--:initSpriteBatch
	self.quads = {} -- holds the quads from the tileset
    self.size = 0 -- size of the tiles
		--:layerInit
	self.scale = 1 -- sets the draw scale
end
function AutoTile:layerInit(map,num,arg) --important
	--call from host layer to perform 2nd init to setup things in relation to the layer.
	self.scale = arg.scale -- gets overridden is sie is provided
	self.targetSize = arg.size
    
	self:initSpriteBatch(num)
	self:settleTiles(map)
end
function AutoTile:initSpriteBatch(num) --init spritebatch and cut the quads
	local num = num
	if self.type == 'minitile' then num = num*4 end --minitiles need 4 per normal tile
	self.spritebatch = lg.newSpriteBatch(self.texture, num)
	--cut quads
	local texSize = {self.texture:getDimensions()}
	if self.type == 'minitile' then
		--Format v1
		--Width: 5 blocks (10 micro). 
		--Height: 1 block (2 micro).
		--[outside corners][vertical (basically 1 micro tile split)][horizontal(ditto)][inner corner][inner fill(same tile x4)] 
		--Outside corners are easy to make from the vertical and horizontal set, the inner corners are the most complecated to draw when creating the texture.
		local miniSize = {texSize[1]/10, texSize[2]/2}
        self.size = texSize[2] -- width of a full tile
		self.scale = self.targetSize/self.size -- auto scale calc
		for x=0,9,1 do 
			self.quads[x+1]={}
			for y=0,1,1 do 
				--self.quads[x+1][y+1] = lg.newQuad(x*miniSize[1],y*miniSize[2],unpack(miniSize), unpack(texSize)) --why unpack isn't working here, idk...
				self.quads[x+1][y+1] = lg.newQuad(x*miniSize[1],y*miniSize[2],miniSize[1],miniSize[2],texSize[1],texSize[2])
			end
		end
	end
end
function AutoTile:settleTiles(map) --calculate the tile connection types based on the provided map.
	local function aware_index(above,below,left,right) --find the tile connection type based on http://www.saltgames.com/article/awareTiles/
		local val = 0
		if above ~= 0 then
			val = 1
		end if left ~= 0 then
			val = val+1
		end if below ~= 0 then
			val = val+4
		end if right ~= 0 then
			val = val+8
		end
		return val
	end
	self.map = {}
	--determine the method based on the spritesheet type
	local function minitile_index(map, x, y) --map: tilemap, x,y: index
		--type: 1[outside corners],2[vertical],3[horizontal],4[inner corner],5[inner fill] 
		--layout: right-to-left
        if map[x][y] ==0 then return 0 end--catch empty tile
        local function sx (int) return math.min(math.max(int, 1),#map) end --wrapper to keep index in bounds
        local function sy (int) return math.min(math.max(int, 1),#map[1]) end --wrapper to keep index in bounds
        local function falsy(thing) if thing and thing ~= 0 then return true else return false end end
        local above, below, left, right = falsy(map[x][sy(y-1)]), falsy(map[x][sy(y+1)]), falsy(map[sx(x-1)][y]), falsy(map[sx(x+1)][y]) --get neighbors
        local uleft, uright, dleft, dright = falsy(map[sx(x-1)][sy(y-1)]), falsy(map[sx(x+1)][sy(y-1)]), falsy(map[sx(x-1)][sy(y+1)]), falsy(map[sx(x+1)][sy(y+1)]) --get corners
		local minitile = {  1, 1, --start as a detatched tile
							1, 1}
		--catch fill tiles 
		--if above and below and left and right and uleft and uright and dright and dleft then return {5,5,5,5} end
		
		if above then 
			minitile[1]=2 --top connection
			minitile[2]=2 
		end if below then
			minitile[3]=2
			minitile[4]=2
		end
		
		if left then --auto sides (if 1 then horz, if 2 then inner corner!)
			minitile[1] = minitile[1] + 2
			minitile[3] = minitile[3] + 2
		end if right then 
			minitile[2] = minitile[2] + 2
			minitile[4] = minitile[4] + 2
		end
        --find fill areas
        if uleft and above and left then minitile[1]=5 end
        if uright and above and right then minitile[2]=5 end
        if dleft and below and left then minitile[3]=5 end
        if dright and below and right then minitile[4]=5 end
        
		return minitile
	end
	--generate a map of all the calculated tile connection types
	for x, row in ipairs(map) do --map and self.map, don't mix 'em up...
		self.map[x]={}
		for y, cell in ipairs(row) do 
			--self.map[x][y] = cell ~= 0 and calc(map[x][sy(y-1)],map[x][sy(y+1)],map[sx(x-1)][y],map[sx(x+1)][y]) or 0
            self.map[x][y] = minitile_index(map, x,y)
		end
	end
    --build the spritebatch
    self:buildSprites()
end
function AutoTile:buildSprites() --assign sprites corrisponding to the connection type to the internal spritebatch
    self.spritebatch:clear()
    local scale = 1
	if self.type == 'minitile' then
    local ms = self.size/2 --minitile size
		for x, row in ipairs(self.map) do
			for y, cell in ipairs(row) do
                if cell ~= 0 then
                    --add 4 mini cells to build a tile
                    self.spritebatch:add(self.quads[2*cell[1]-1][1], self.size*(x-1), self.size*(y-1)) --<^
                    self.spritebatch:add(self.quads[2*cell[2]][1], self.size*(x-1)+ms, self.size*(y-1)) -->^
                    self.spritebatch:add(self.quads[2*cell[3]-1][2], self.size*(x-1), self.size*(y-1)+ms) --<v
                    self.spritebatch:add(self.quads[2*cell[4]][2], self.size*(x-1)+ms, self.size*(y-1)+ms) -->v
                end
			end
		end
	end
    self.spritebatch:flush()
end
function AutoTile:draw()
    local scale = self.scale
	lg.draw(self.spritebatch, 0,0,0,scale,scale)
end

return AutoTile