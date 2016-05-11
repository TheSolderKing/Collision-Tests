Physics = class()
--A class for utilities and handling collisions
function Physics:init()
    -- you can accept and set parameters here
    --a = Object({vec2(-50,50),vec2(50,50),vec2(50,-50),vec2(-50,-50)},3*WIDTH/4,HEIGHT/2)
    --b = Object({vec2(-50,50),vec2(50,50),vec2(50,-50)},WIDTH/2,HEIGHT/2)
    shapes = {
    {vec2(-WIDTH/20,-HEIGHT/20),vec2(-WIDTH/20,HEIGHT/20),vec2(WIDTH/20,HEIGHT/20),vec2(WIDTH/20,-HEIGHT/20)},
    {vec2(-WIDTH/20,-HEIGHT/20),vec2(-WIDTH/20,HEIGHT/20),vec2(WIDTH/20,-HEIGHT/20)},
    {vec2(-WIDTH/20,-HEIGHT/20),vec2(WIDTH/20,HEIGHT/20),vec2(WIDTH/20,-HEIGHT/20)},
    {vec2(-WIDTH/20,-HEIGHT/20),vec2(-WIDTH/20,HEIGHT/20),vec2(WIDTH/40,-HEIGHT/20)},
    {vec2(-WIDTH/40,-HEIGHT/20),vec2(WIDTH/20,HEIGHT/20),vec2(WIDTH/20,-HEIGHT/20)}
    }
    self.map = 
    {
    {1,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,1},
    {1,2,0,0,0,0,0,0,3,1},
    {1,1,2,0,0,0,0,3,1,1},
    {1,1,1,4,0,0,5,1,1,1},
    {1,1,1,1,4,5,1,1,1,1},
    {1,1,1,1,1,1,1,1,1,1}
    }
    self.shapes = {}
    local mVerts = {}
    for i,v in pairs(self.map) do
        self.shapes[i] = {}
        for a,b in pairs(v) do
            if b~=0 then
                self.shapes[i][a] = Object(shapes[b],a*WIDTH/10-WIDTH/20,(#self.map-i+1)*HEIGHT/10-HEIGHT/20)
                local verts = triangulate(self.shapes[i][a]:getPoints())
                for i,v in pairs(verts) do 
                    table.insert(mVerts, v)
                end
            end
        end
    end
    self.mesh = mesh()
    self.mesh.vertices = mVerts
    self.mesh:setColors(color(50,200,50))
    self.player = Player(WIDTH/3,HEIGHT/2)
end

function Physics:draw()
    -- Codea does not automatically call this method
    --[[a:draw()
    b:draw()
    bool, moveBy = self:testCollision(a,b)
    if bool == true then
        a.border = color(255,0,0)
        a:move(moveBy.axis*moveBy.amount*0.9)
    else
        a.border = color(255)
        a:move(vec2(-1,0))
    end]]--
    self.player:draw()
    self.mesh:draw()
    local px,py = self.player:getTilePos()
    for x=-1,1 do
        for y=-1,1 do
            if x+px > 0 and x+px < 11 and y+(10-py)>0 and y+(10-py)< 11 and self.shapes[(10-py)+y][px+x] then
                local bool,val = self:testCollision(self.player.obj,self.shapes[(10-py)+y][px+x])
                if bool then
                    self.player.obj.border = color(255,0,0)
                    print(val.axis*val.amount)
                    local vec = val.axis*val.amount*1.1
                    self.player:move(vec.x,vec.y)
                end
            end
        end
    end
    self.player:move(0,-1)
end

function Physics:touched(touch)
    -- Codea does not automatically call this method
    --a.x,a.y = touch.x,touch.y
end

function overlaps(a1,a2,b1,b2)
    --Very simple overlap test, saves some work
    if a1<b2 and a2>b1 then
        if a1>b1 then
            return true, b2-a1
        else
            return true, a2-b1
        end
    end
    return false
end

function findNormal(vx,vy)
    --Using right hand coordinate system - therefore shapes must be defined in a clockise order
    return vec2(-vy,vx):normalize()
end

function project(a,b)
    --projects vector a onto vector b, allowing for easy overlap testing
    ax,ay = a.x,a.y
    bx,by = b.x,b.y
    --local projx = (dot(ax,ay,bx,by)/(bx^2+by^2)) * bx
    --local projy = (dot(ax,ay,bx,by)/(bx^2+by^2)) * by
    local projx = dot(ax,ay,bx,by) * bx
    local projy = dot(ax,ay,bx,by) * by
    return vec2(projx, projy)
end

function dot(ax,ay,bx,by)
    --utility function for doing math without having to use the vector library
    return ax*bx + ay*by
end

function contains(tab, element)
    for i,v in pairs(tab) do
        if v==element then return true end
    end
end

function Physics:testCollision(obj1,obj2)
    --Generate a table of unique axes to save valuable computation time
    --Also to save computation time, store math.min and math.max locally
    local min, max = math.min,math.max
    local minimumOverlap = {axis = nil, amount = nil}
    local axes = {}
    for i,v in pairs(obj1.normals) do
        table.insert(axes,v)
    end
    for i,v in pairs(obj2.normals) do
        if not contains(axes,v) then
            table.insert(axes,v)
        end
    end
    
    --Loop thru for each axis and determine collision
    local collides = true
    for i,v in pairs(axes) do
        --For self, generate min and max values
        local mi1,ma1 = 0,0
        local mi2,ma2 = 0,0
        for a,b in pairs(obj1.points) do
            --get the position of each point on screen
            local realpos = b + vec2(obj1.x,obj1.y)
            --project that onto the current axis
            local num = project(realpos,v)
            --translate that into a 1D number
            num = num:len()
            --set current min max values based on this number
            if mi1 == 0 then mi1 = num
            else mi1 = min(mi1,num)
            end
            
            if ma1 == 0 then ma1 = num
            else ma1 = max(ma1,num)
            end
        end
        --now do the same for the other polygon
        
        for a,b in pairs(obj2.points) do
            local realpos = b + vec2(obj2.x,obj2.y)
            local num = project(realpos,v)
            num = num:len()
            if mi2 == 0 then mi2 = num
            else mi2 = min(mi2,num)
            end
            
            if ma2 == 0 then ma2 = num
            else ma2 = max(ma2,num)
            end
        end
        --now test overlap
        bool, val = overlaps(mi1,ma1,mi2,ma2)
        if not bool then
            return false
        end
        
        if minimumOverlap.amount == nil or math.abs(val)<minimumOverlap.amount then
            minimumOverlap.amount = val
            minimumOverlap.axis = v
        end
        
    end
    return collides, minimumOverlap
end
