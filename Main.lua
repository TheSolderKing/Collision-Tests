-- Collisions

-- Use this function to perform your initial setup
function setup()
    print("Hello World!")
    p=Physics()
    parameter.watch("1/DeltaTime")
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color 
    background(69, 69, 195, 255)

    -- This sets the line thickness
    strokeWidth(5)

    -- Do your drawing here
    p:draw()
end

function touched(touch)
    p:touched(touch)
end

