Player = class()

function Player:init(x,y)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.obj = Object({vec2(-WIDTH/40,-HEIGHT/30),vec2(-WIDTH/40,HEIGHT/30),vec2(WIDTH/40,HEIGHT/30),vec2(WIDTH/40,-HEIGHT/30)},x,y)
end

function Player:draw()
    -- Codea does not automatically call this method
    self.obj:draw()
end

function Player:getTilePos()
    return math.floor(self.x/(WIDTH/10)),math.floor(self.y/(HEIGHT/10))
end

function Player:touched(touch)
    -- Codea does not automatically call this method
end

function Player:move(x,y)
    self.x = self.x + x
    self.y = self.y + y
    self.obj:move(vec2(x,y))
end
