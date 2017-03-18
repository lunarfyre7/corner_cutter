local Class = require 'lib.class' 
local Layer = require 'layer' 
local Player = require 'player' 
local Bump = require 'lib.bump'

local Core = Class()

--##General notes##
-- This is the the game part, the ui/level-manager should/might be handled by a higher up file.
-- *Coord units are in tile lengths
-- *layer types: Background (parallax), Normal (collisions), Item, Decoration


function Core:init(arg)
    --required args: layers (table), player (player object)
    --layer structure
--     self.layers = {
--         backgound = Layer.Background(),
--         map = Layer.Normal()
--     }
    self.layers = arg.layers
    self.player = arg.player
end

function Core:update(dt)
    --TODO update camera
    --TODO update parallax
    --TODO update player and do collision test
end
function Core:draw()
    for i, layer in ipairs(self.layers) do
        layer:draw()
    end
end
function Core:keypressed(key,screencode,isrepeat)
    
end
function Core:mousemoved(x, y, dx, dy, istouch)

end
return Core
