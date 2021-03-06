local physics  = require("physics")
local composer = require("composer")
local vibrator = require('plugin.vibrator')

local function update(self, dt)
    local dx = (self.initialX - self.x) * self.returnForce * dt
    local dy = (self.initialY - self.y) * self.returnForce * dt
    self:applyForce(dx, dy, self.x, self.y)
end

local function collision(self, event)
    if event.phase == "began" and event.other.isPuck then
        local scene = composer.getScene(composer.getSceneName("current"))
        if scene then
            if event.selfElement == 4 then
                timer.performWithDelay(1, function ()
                    scene:endRound(self.colorName)
                    audio.play(self.goalSound, { channel = 15})
                end)
            elseif event.selfElement == 5 or event.selfElement == 6 then
                scene:showGameText("close", event.other.x, event.other.y, self.colorName)
                local haptic = vibrator.newHaptic('impact', 'medium')
                if haptic then
                    haptic:invoke()
                end
            end
        end
    end
end

local function constructor(colorName, x, y, isMLG)
    local self = display.newImage("assets/gate_".. colorName ..".png")
    self.colorName = colorName
    local path = "assets/sounds/goal.wav"
    if isMLG then
        path = "assets/sounds/explosion.wav"
    end
    self.goalSound = audio.loadSound(path)

    self.initialX = x
    self.initialY = y

    self.isGate = true

    self.x = x
    self.y = y

    self.returnForce = 0.05
    local filter = { groupIndex = -1 }
    -- Physics setup
    physics.addBody(self,
    -- Stick body
    {
        density = 0.05,
        bounce = 0,
        filter = filter,
        box = {
            halfWidth  = self.width * 0.4,
            halfHeight = 0.5,
            x          = 0,
            y          = self.height / 2,
            angle      = 0,
        }
    },
    {
        density = 0.05,
        bounce = 0,
        filter = filter,
        box = {
            halfWidth  = self.height / 2,
            halfHeight = 0.5,
            x          = -self.width / 2,
            y          = 0,
            angle      = 80,
        }
    },
    {
        density = 0.05,
        bounce = 0,
        filter = filter,
        box = {
            halfWidth  = self.height / 2,
            halfHeight = 0.5,
            x          = self.width / 2,
            y          = 0,
            angle      = -80,
        }
    },
    {
        density = 0.05,
        bounce = 0,
        filter = filter,
        isSensor = true,
        box = {
            halfWidth  = self.width * 0.4,
            halfHeight = 0.5,
            x          = 0,
            y          = self.height * -0.1,
            angle      = 0,
        }
    },
    {
        density = 0.05,
        bounce = 0,
        filter = filter,
        isSensor = false,
        box = {
            halfWidth  = 1,
            halfHeight = 0.7,
            x          = -self.width / 2 - 1,
            y          = self.height * -0.45,
            angle      = 80,
        }
    },
    {
        density = 0.05,
        bounce = 0,
        filter = filter,
        isSensor = false,
        box = {
            halfWidth  = 1,
            halfHeight = 0.7,
            x          = self.width / 2 + 1,
            y          = self.height * -0.45,
            angle      = -80,
        }
    })

    self.linearDamping = 100
    self.isFixedRotation = true

    self.update = update
    self.collision = collision

    self:addEventListener("collision")
    return self
end

return constructor