pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

function _init()
    poke(0x5f2d, 1)

    high_score = score:new({
        x = 4,
        y = 4
    })

    p1 = player:new({
        x = 64,
        y = 64,
        size = 5,
        trace = false
    })

    targets = spawn_group:new({
        spawn_fn = function()
            return target:new({
                x = rnd(128),
                y = rnd(128),
                size = 3,
                spawned_at = time(),
            })
        end
    })
end

function _update60()
    p1:update(targets, high_score)
    targets:update()
end

function _draw()
    cls(1)

    targets:draw()

    p1:draw()

    high_score:draw()

    debug:draw()
end
-->8
-- common

sprite_size = 8
sprite_half_size = 4
friction = 0.90

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

function entity:collides(other)
    horizontal = abs(self.x - other.x)
    vertical = abs(self.y - other.y)
    tolerance = 2
    threshold = sprite_size - tolerance
    return horizontal <= threshold  and vertical <= threshold
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

debug = {}

function debug:draw()
    for i,d in ipairs(debug) do
        print(d, 4, (i + 1) * 6, 8)
    end
end
-->8
-- types

crosshair = entity:extend()

bullet = entity:extend({
    sx = 0,
    sy = 0,
    tx = 0,
    ty = 0,
    speed = 6,
    visible = true
})

player = entity:extend({
    size = 1,
    dx = 0,
    dy = 0,
    accel = 0.3,
    crosshair = crosshair:new(),
    bullets = {},
    trace = false,
    gun = {
        cooldown = 0
    }
})

target = entity:extend({
    size = 1,
    spawned_at = time(),
})

spawn_group = class:extend({
    objects = {},
    spawn_rate = 100,
    spawn_cooldown = 0,
    spawn_fn = function() end
})

score = entity:extend({
    value = 0
})
-->8
-- player

function player:update(targets, score)
    self.dx *= friction
    self.dy *= friction

    if (btn(⬆️) or wasd:btn(⬆️)) self.dy -= self.accel
    if (btn(⬇️) or wasd:btn(⬇️)) self.dy += self.accel
    if (btn(⬅️) or wasd:btn(⬅️)) self.dx -= self.accel
    if (btn(➡️) or wasd:btn(➡️)) self.dx += self.accel

    self.x += self.dx
    self.y += self.dy

    self:boxed()
    self.crosshair:update()

    if (mouse:btn(1) and self.gun.cooldown <= 0) then
        add(self.bullets, bullet:new({
            x = self.x,
            y = self.y,
            sx = self.x,
            sy = self.y,
            tx = self.crosshair.x + sprite_half_size,
            ty = self.crosshair.y + sprite_half_size,
        }))
        self.gun.cooldown = 15
    end

    for b in all(self.bullets) do
        b:update()

        targets:foreach(function (t)
            if (b:collides(t)) then
                b:explode()
                local points = t:hit()
                score:update(points)
            end
        end)

        if (not b.visible) del(self.bullets, b)
    end

    self.gun.cooldown -= 1
end

function player:draw()
    self.crosshair:draw()

    if (self.trace) self.crosshair:trace(self)

    circfill(self.x, self.y, self.size, 7)

    for b in all(self.bullets) do
        b:draw()
    end
end
-->8
-- crosshair

function crosshair:update()
    self.x = stat(32)
    self.y = stat(33)
end

function crosshair:draw()
    spr(0, self.x, self.y)
end

function crosshair:trace(player)
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
    self.visible = self.visible and not self:is_offscreen()
end

function bullet:draw()
    circfill(self.x, self.y, 2, 8)
end

function bullet:is_offscreen()
    return self.x <= 0 or self.x >= 128 or self.y <= 0 or self.y >= 128
end

function bullet:explode()
    self.visible = false
end
-->8
-- target

function target:update()
end

function target:draw()
    circfill(self.x, self.y, self.size, 11)
end

function target:hit()
    self.state = "dead"
    return self:points()
end

function target:points()
    local delay = time() - self.spawned_at
    local scaled_penalty = 10 * delay
    return flr(max(0, 100 - scaled_penalty))
end

function target:is_dead()
    return self.state == "dead"
end

function spawn_group:update()
    if (self.spawn_cooldown <= 0) then
        add(self.objects, self.spawn_fn())
        self.spawn_cooldown = self.spawn_rate
    end

    for o in all(self.objects) do
        o:update()
        if (o:is_dead()) del(self.objects, o)
    end

    self.spawn_cooldown -= 1
end

function spawn_group:draw()
    for e in all(self.objects) do
        e:draw()
    end
end

function spawn_group:foreach(fn)
    for o in all(self.objects) do
        fn(o)
    end
end
-->8
-- score

function score:update(inc)
    self.value += inc
end

function score:draw()
    print("score: "..self.value, self.x, self.y, 7)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
