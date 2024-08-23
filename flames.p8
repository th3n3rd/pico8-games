pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
screen_min = 0
screen_max = 128
screen_center = screen_max / 2

function _init()
    flame = make_flame(
        screen_center,
        screen_center + 20
    )
end

function _update60()
    flame:update()
end

function _draw()
    cls(0)
    flame:draw()
end
-->8

function make_fire_particle(x, y)
    local life = 30 + rnd(20)
    local dsize = 0.05
    local dlife = 1
    local colours = {7, 10, 9}

    local particle = {}

    particle.x = x + rnd(10) - 10
    particle.y = y
    particle.dy = rnd(1) + 0.2
    particle.size = rnd(2) + 1
    particle.life = life
    particle.colour = colours[1]

    particle.is_dead = function(self)
        return self.life <= 0
    end

    particle.update = function(self)
        self.y -= self.dy
        self.x += rnd(1) - 0.5 -- horizontal flickering
        self.life -= dlife
        self.size -= dsize

        if (self.life < life / 1.10) self.colour = colours[2]
        if (self.life < life / 1.5) self.colour = colours[3]
    end

    particle.draw = function(self)
        circfill(self.x, self.y, self.size, flr(self.colour))
    end

    return particle
end

function make_flame(x, y)
    local flame = {}

    flame.x = x
    flame.y = y

    flame.particles = {}
    flame.spawn_rate = 5

    flame.update = function(self)
        for i = 1,self.spawn_rate do
            add(self.particles, make_fire_particle(self.x, self.y))
        end

        for p in all(self.particles) do
            p:update()
            if (p:is_dead()) del(self.particles, p)
        end
    end

    flame.draw = function(self)
        for p in all(self.particles) do
            p:draw()
        end
    end

    return flame
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
