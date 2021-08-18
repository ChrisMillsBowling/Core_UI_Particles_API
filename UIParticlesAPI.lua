--[[
    ExtremeBarAPI by Chris Mills-Bowling - MetalGunTalk - 2021
    This API should allow for the creation of modular "progress bars" with easily applyable advanced effects.
    Users should be able to determine what and how effects should be playered as the progress bar updates.
    Users should find the example project modular enough to begin working with UI elements.

]]--

--[[challenge notes:
https://forums.coregames.com/t/challenge-gui-animations/1826
Description

The goal of this Challenge is to create an API and library of graphical user interface (GUI) animations that creators can use to animate GUI elements in their games. These animations can be used for animating text, images, or just about any other GUI element that needs movement.

The next time you play a PC or mobile game, take note of all the GUI elements that have some sort of animation. This could be a notification that slides on and then off the screen. Or a reward image that scales from small to big. Or an alert that fades in and then out. Or a button that wiggles to get your attention. Basically any GUI element that moves.
Features

API
This should be an API so that creators can easily call to add animation to any GUI element.

Library
Build a library of animations so that creators have different animations to choose from. The animations should be the type of animations that are commonly used and needed for GUI animations (slide in/out, scale up/down, etc).

Use Curves
The new Curves feature in Core is perfect for this task since it provides a simple way to create very powerful GUI animations. It is also much easier to understand and customize animations using the Curve editor.

Flexibility
Your system should be as flexible as possible so that creators can specify or override common animation parameters such as speed in, speed out, static duration, direction, positioning, easing, etc.

Events
Consider broadcasting a custom event for when the animation starts, pauses, and ends. This allows creators to listen to those events and add custom handlers. Allow creators to define the name of the events via custom properties.
]]
local UIParticlesAPI = {}

--This is the spawned particle template--
local UI_Default_Particle = script:GetCustomProperty("UI_Default_Particle")


UIParticlesAPI.Ease =
{
    Linear="Linear",
    Exponential="Exponential",
    Log="Log",
    Sine="Sine",
    Curve="Curve"
}

UIParticlesAPI.Shapes =
{
    Box=1,
    Circle=2,
    Point=3
}


--For more on what is going on here, please read about Lua privacy: https://www.lua.org/pil/16.4.html
UIParticlesAPI.Spawn = function(Particle_Settings)  
    local Particle_Emitter =
    {
        Particle_Image=nil,
        Particle_Size=nil,
        Location=Vector2.ONE/2,
        Color=Color.GREEN,
        Shape=UIParticlesAPI.Shapes.Point,
        Lifespan=1,
        Timescale=1, --This means a complete loop will be over 1 second!
        Parent=nil,
        --Curve Data--
        Particle_Size_Curve=nil,
        Particle_Position_Curve=nil,
        Particle_Spawn_Rate_Curve=nil,
        Particle_X_Offset_Curve=nil,
        Particle_Y_Offset_Curve=nil,
        --Shape Specific Data--
        Box_Width=1,
        Box_Height=1,
        Circle_Radius=1,

        --particle system controls--
        Particle_Emitter=nil
    }

    --creation methods start--
    --[[ Overview:
        The idea behind these private methods is that they are the asynchronous tasks
        That allow and manage the creation of the particle system elements.

        Particle Emitter:
            This object should create particle tasks as defined by it's properties.
            This object should be it's own managed task by a turnon turnoff method
            which is exposed to the end developer.
        
        Particle:
            This object should simply animate a single particle for by the rules given to it at creation.
            This object should be tracked by the emitter in order to shut down the task at will.
    ]]--

    local Create_Particle=
        function()
            local Particle_Table=
            {
                Task=nil,
                Image=nil
            }
            
            Particle_Table.Task = Task.Spawn(function()
                if not Particle_Emitter.Parent then error("No Parent Set!") return end
                Particle_Table.Image = World.SpawnAsset(UI_Default_Particle, {parent=Particle_Emitter.Parent})
                Particle_Table.Image:SetColor(Particle_Emitter.Color)
            end)
            

            return Particle_Table
        end

    local Create_Particle_Emitter=
        function()
            local particles = {}

            local TurnOn=
                function()
                    table.insert(particles, Create_Particle())
                end
            
            local TurnOff=
                function()
                    for _, particle in pairs(particles) do
                        if particle.Task then
                            particle.Task:Cancel()
                        end
                        if Object.IsValid(particle.Image) then
                            particle.Image:Destroy()
                        end
                        particle = nil
                    end
                    particles = {}
                end
            
            local Particle_Emitter =
            {
                TurnOn=TurnOn,
                TurnOff=TurnOff
            }
            return Particle_Emitter
        end



    --start accessor methods--
    local SetImage =
        function(Image)
            if not Image then return end
            if not Image.type == "UIImage" then return end
            Particle_Emitter.Particle_Image = Image
        end

    local SetLocation=
        function(Location)
            if not Location then return end
            if not Location.type == "Vector2" then return end
            Particle_Emitter.Location = Location
        end

    local GetLocation=
        function()
            return Particle_Emitter.Location
        end

    local SetLifespan=
        function(Value)
            if not Value then return end
            if not type(Value) == "number" then return end
            Particle_Emitter.Lifespan = Value
        end
   
    local GetLifespan=
        function()
            return Particle_Emitter.Lifespan
        end

    local GetColor=
        function()
            return Particle_Emitter.Color
        end
    
    local SetColor=
        function(Color)
            if not Color then return end
            if not Color.type == "Color3" then return end
            Particle_Emitter.Color = Color
        end

    local TurnOff=
        function()
            warn("Turn off not implimented")
        end

    local TurnOn=
        function()
            warn("Turn on not implimented")
        end
    --end accessor methods--    
    
    local Particle_System =
    {
        SetImage=SetImage,
        SetLocation=SetLocation,
        GetLocation=GetLocation,
        SetLifespan=SetLifespan,
        GetLifespan=GetLifespan,
        GetColor=GetColor,
        SetColor=SetColor,
        TurnOn=TurnOn,
        TurnOff=TurnOff
    }

    return Particle_System
end

return UIParticlesAPI

--[[
    Location Library
    This will help to dermine orientation about a progrSetParticleLifeSpanParticles_Per_Second=2,
--Partical potential features list:receive_connect
    --Shapes
        --Point
        --Circle
        --Box
        --N-sided shape.

    --Note, each of these shapes should be passed a table detailing their behavior!

--Example workshop for use cases 

--I want a sparkly outline for my UI box element. 

--[[
    Particle_Settings = 
    {
        "Shape"="Box",
        "Width"=Object.x,
        "Hieght"=Object.y,
        "Particle"=Image_ID,
        "Y_Movement"=Curve_Data -- OR -- UIParticleAPI.Movement.Linear(5),
        "Gravity"=UIParticleAPI.Gravity.Normal,
        "Color"=Color_Value,
        "Location"=location_value,
        "Size_Start"= Vector2.New(2,2)
        "Size_End" = Vector2.New(.5,.5)
        "Particle_Lifespan"=2
    }

    local ps = UIParticleAPI.Spawn(Particle_Settings)
    ps.location = Vector2.ZERO -- Alternatively make it an accessor for saftey!
    ps:SetLocation(Vector2.ZERO)

    ps:TrackObject(UI_Panel)

    ps:TurnOn()
    ps:TurnOff()

    ps:TrackUserMouse()

    ps:SetColor(x)

    ps:SetWidth(x)
    ps:SetHeight(x)

    ps:SetParticleLifeSpan(x)
]]

