pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

function _init()
    pal(0, 129, 1)
    debug={}
    stars={}
    for i=1,70 do
        local star_type = rnd({
            star,
            near_star,
            far_star
        })
        add(stars, star_type:new({
            x = rnd(128),
            y = rnd(128)
        }))
    end
end

function _update60()
    for s in all(stars) do
        s:update()
    end
end

function _draw()
    cls()

    for s in all(stars) do
        debug[2] = s.x
        s:draw()
    end

    for i,d in ipairs(debug) do
        print(d, 4, i * 4, 8)
    end
end
-->8
-- common

class = {}

function class:new(props)
    local instance = props or {}
    setmetatable(instance, {
        __index = self
    })
    return instance
end

function class:extend(props)
    return self:new(props)
end

entity = class:extend({
    x = 0,
    y = 0
})

-->8
-- star

star = entity:extend({
    colour = 13,
    speed = 0.5,
    radius = 0,
})

function star:update()
    self.y += self.speed
    if (self.y - self.radius >= 128) then
        self.y = -self.radius
        self.x = rnd(128)
    end
end

function star:draw()
    circfill(
        self.x,
        self.y,
        self.radius,
        self.colour
    )
end

near_star = star:extend({
    colour = 7,
    speed = 0.75,
    radius = 1,
})

far_star = star:extend({
    colour = 1,
    speed = 0.25,
    radius = 0,
})
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
