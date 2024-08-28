pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

function _init()
    poke(0x5f2d, 1)
    debug = {}
    p1 = player:new({
        x = 64,
        y = 64,
        size = 5,
        trace = false
    })
end

function _update60()
    p1:update()
end

function _draw()
    cls(1)

    p1:draw()

    for i,d in ipairs(debug) do
        print(d, 4, i * 6, 8)
    end
end
-->8
-- common

sprite_half_size = 4

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
    y = 0,
})

function entity:boxed()
    self.x = max(0, min(128, self.x))
    self.y = max(0, min(128, self.y))
end

wasd = {}

function wasd:btn(key)
    if (key == ⬆️ and stat(28, 26)) return true
    if (key == ⬇️ and stat(28, 22)) return true
    if (key == ⬅️ and stat(28, 4)) return true
    if (key == ➡️ and stat(28, 7)) return true
    return false
end

mouse = {}

function mouse:btn(n)
    return stat(34) == n
end
-->8
-- objects

scope = entity:extend()

bullet = entity:extend({
    sx = 0,
    sy = 0,
    tx = 0,
    ty = 0,
    speed = 6
})

player = entity:extend({
    size = 1,
    scope = scope:new(),
    bullets = {},
    trace = false,
    gun = {
        cooldown = 0
    }
})

-->8
-- player

function player:update()
    if (btn(⬆️) or wasd:btn(⬆️)) self.y -= 1
    if (btn(⬇️) or wasd:btn(⬇️)) self.y += 1
    if (btn(⬅️) or wasd:btn(⬅️)) self.x -= 1
    if (btn(➡️) or wasd:btn(➡️)) self.x += 1

    self:boxed()
    self.scope:update()

    if (mouse:btn(1) and self.gun.cooldown <= 0) then
        add(self.bullets, bullet:new({
            x = self.x,
            y = self.y,
            sx = self.x,
            sy = self.y,
            tx = self.scope.x + sprite_half_size,
            ty = self.scope.y + sprite_half_size,
        }))
        self.gun.cooldown = 15
    end

    for b in all(self.bullets) do
        b:update()
        if (b:is_offscreen()) del(self.bullets, b)
    end

    self.gun.cooldown -= 1
end

function player:draw()
    self.scope:draw()

    if (self.trace) self.scope:trace(self)

    circfill(self.x, self.y, self.size, 7)

    for b in all(self.bullets) do
        b:draw()
    end
end
-->8
-- scope

function scope:update()
    self.x = stat(32)
    self.y = stat(33)
end

function scope:draw()
    spr(0, self.x, self.y)
end

function scope:trace(player)
    line(
        player.x,
        player.y,
        self.x + sprite_half_size,
        self.y + sprite_half_size,
        6
    )
end
-->8
-- bullet

function bullet:update()
    local angle = atan2(self.tx - self.sx, self.ty - self.sy)
    local dx = cos(angle)
    local dy = sin(angle)
    self.x += dx * self.speed
    self.y += dy * self.speed
end

function bullet:draw()
    circfill(self.x, self.y, 2, 8)
end

function bullet:is_offscreen()
    return self.x <= 0 or self.x >= 128 or self.y <= 0 or self.y >= 128
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
