Object = class()

function Object:init(points,x,y)
    -- you can accept and set parameters here
    self.points = points
    self.x,self.y = x,y
    self.edges = {}
    self.normals = {}
    self:calculateEdges()
    self:calculateNormals()
    self.border = color(255)
end

function Object:draw()
    -- Codea does not automatically call this method
    stroke(self.border)
    pushMatrix()
    translate(self.x,self.y)
    for i=1,#self.points do
        local next = i%#self.points+1
        line(self.points[i].x,self.points[i].y,self.points[next].x,self.points[next].y)
    end
    popMatrix()
end

function Object:move(vec)
    self.x = self.x + vec.x
    self.y = self.y + vec.y
end

function Object:getPoints()
    local tab = {}
    for i,v in pairs(self.points) do
        table.insert(tab,v+vec2(self.x,self.y))
    end
    return tab
end

function Object:calculateEdges()
    for i=1,#self.points do
        local next = (i)%#self.points+1
        local dx = self.points[next].x - self.points[i].x
        local dy = self.points[next].y - self.points[i].y
        table.insert(self.edges,{x=dx,y=dy})
    end
end

function Object:calculateNormals()
    for i,v in pairs(self.edges) do
        local norm = findNormal(v.x,v.y)
        if not contains(self.normals,norm) then
            table.insert(self.normals,norm)
        end
    end
end