local Class = require 'lib.class'
local AutoTile = Class()
local lg = love.graphics
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
function AutoTile:layerInit(map,num,scale) --important
	--call from host layer to perform 2nd init to setup things in relation to the layer.
	self.scale = scale
    
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
	local function minitile_index(above, below, left, right) --I wish lua(in default LOVE) had binary operators
		--type: 1[outside corners],2[vertical],3[horizontal],4[inner corner],5[inner fill] 
		--layout: right-to-left
        local function falsy(thing) if thing and thing ~= 0 then return true else return false end end
        local above, below, left, right = falsy(above), falsy(below), falsy(left), falsy(right)
		local minitile = {  1, 1, --start as a detatched tile
							1, 1}
		--catch fill tiles 
		if above and below and left and right then return {5,5,5,5} end
		
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
		return minitile
	end
    local function minitile_index_tab(up,down,left,right) --to test without worrying about errors in the above
        local function eq (t1,t2)
          if #t1 == #t2 then
            for k, v in ipairs(t1) do
              if t2[k] ~= v then return false end
            end
          else return false end
          return true
        end
        local function falsy(thing) if thing and thing ~= 0 then return 1 else return 0 end end
        local key = {falsy(up),falsy(down),falsy(left),falsy(right)} --format input
        local minitile_tab = {
    --up,down,left,right --type: 1[outside corners],2[vertical],3[horizontal],4[inner corner],5[inner fill] 
            {{0,0,0,0}, {1,1,1,1}},
            {{0,0,0,1}, {1,3,1,3}},
            {{0,0,1,0}, {3,1,3,1}},
            {{0,0,1,1}, {3,3,3,3}},
            {{0,1,0,0}, {1,1,2,2}},
            {{0,1,0,1}, {1,3,2,4}},
            {{0,1,1,0}, {3,1,4,2}},
            {{0,1,1,1}, {2,2,4,4}},
            {{1,0,0,0}, {2,2,1,1}},
            {{1,0,0,1}, {2,4,1,3}},
            {{1,0,1,0}, {4,2,2,1}},
            {{1,0,1,1}, {4,5,3,3}},
            {{1,1,0,0}, {2,2,2,2}},
            {{1,1,0,1}, {2,4,2,4}},
            {{1,1,1,0}, {4,2,4,2}},--note: need to check for inner corners
            {{1,1,1,1}, {4,4,4,4}},
        }
        for i, v in ipairs(minitile_tab) do --find matching table entry and return
            if eq(v[1], key) then return v[2] end
        end
        return {5,5,5,5} --in case of error
    end
	local calc --For chosen tile calc algo
	if self.type == "minitile" then
		calc = minitile_index
	elseif self.type then
		calc = aware_index
	end
	--generate a map of all the calculated tile connection types
    local function sx (int) return math.min(math.max(int, 1),#map) end --wrapper to keep index in bounds
    local function sy (int) return math.min(math.max(int, 1),#map[1]) end --wrapper to keep index in bounds
	for x, row in ipairs(map) do
		self.map[x]={}
		for y, cell in ipairs(row) do 
			self.map[x][y] = cell ~= 0 and calc(map[x][sy(y-1)],map[x][sy(y+1)],map[sx(x-1)][y],map[sx(x+1)][y]) or 0
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