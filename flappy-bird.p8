pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
best_score = 0
screen_min = 0
screen_max = 128
screen_center = screen_max / 2
sprite_size = 8
text_size = 8
sprites = {
    bird_body = 1,
    bird_rest = 17,
    bird_flap = 18,
    pipe_up = 3,
    pipe_body = 4,
    pipe_down = 5
}
colours = {
    black = 0,
    dark_blue = 1,
    dark_purple = 2,
    dark_green = 3,
    brown = 4,
    dark_grey = 5,
    light_grey = 6,
    white = 7,
    red = 8,
    orange = 9,
    yellow = 10,
    light_green = 11,
    light_blue = 12,
    lavender = 13,
    pink = 14,
    light_peach = 15
}

function _init()
    game_over = false
    frame = 0
    score = track_score()
    logs = logging()
    pipes = {}
    bird = make_bird(screen_center, screen_center)
end

function _update60()
    logs:clear()

    if (game_over) then
        if (btn(❎)) _init()
        return
    end

    if (should_add_pipe()) add(pipes, make_random_pipe())

    if (too_many_pipes()) deli(pipes, 1)

    foreach(pipes, function(p)
        p:move()
    end)

    if (btn(⬆️)) then
        bird:flap()
    else
        bird:drop()
    end

    foreach(pipes, function(p)
        if (p:collides(bird)) game_over = true
    end)

    if (bird:is_offscreen()) game_over = true

    frame += 1
    score:increment()
    best_score = max(score.value, best_score)
end

function _draw()
    cls(colours.light_blue)

    map_overlay()

    foreach(pipes, function(p)
        p:draw()
    end)

    bird:draw()

    score:draw()

    logs:draw()

    if (game_over) game_over_overlay()
end

function should_add_pipe()
    return (frame % 100) == 0
end

function too_many_pipes()
    return #pipes > 2
end

function hcenter(text)
    return screen_center - (#text * 2)
end

function vcenter(text)
    return screen_center
end

function bracket(value)
    return max(screen_min, min(screen_max - sprite_size, value))
end

function collide(a, b)
    horizontal = abs(a.x - b.x)
    vertical = abs(a.y - b.y)
    tolerance = 2
    threshold = sprite_size - tolerance
    return horizontal <= threshold  and vertical <= threshold
end

function make_random_pipe()
    return make_pipe(screen_max, 10 + rnd(80))
end

function make_pipe(x, height)
    hitboxes = {}

    gap = sprite_size * 2.5

    for i = 0, height, sprite_size do
        add(hitboxes, {sprite = sprites.pipe_body, x = x, y = i})
    end

    pipe_down = {sprite = sprites.pipe_down, x = x, y = height}
    add(hitboxes, pipe_down)

    pipe_up = {sprite = sprites.pipe_up, x = x, y = pipe_down.y + sprite_size + gap}
    add(hitboxes, pipe_up)

    for i = pipe_up.y, screen_max, sprite_size do
        add(hitboxes, {sprite = sprites.pipe_body, x = x, y = i})
    end

    return {
        hitboxes = hitboxes,
        move = function(self)
            foreach(self.hitboxes, function(h)
                h.x = h.x - 1
            end)
        end,
        collides = function(self, other)
            hit = false
            foreach(self.hitboxes, function(h)
                if (collide(h, other)) hit = true
            end)
            return hit
        end,
        draw = function(self)
            foreach(self.hitboxes, function(h)
                spr(h.sprite, h.x, h.y)
            end)
        end
    }
end

function make_bird(x, y)
    gravity = 0.1
    jump = -1.2
    return {
        x = x,
        y = y,
        vy = 0,
        body_sprite = sprites.bird_body,
        wing_sprite = sprites.bird_rest,
        drop = function(self, frame)
            self.vy += gravity
            self.y += self.vy
            self.wing_sprite = sprites.bird_rest
        end,
        flap = function(self)
            self.vy = jump
            self.y = bracket(self.y + self.vy)
            self.wing_sprite = sprites.bird_flap
        end,
        is_offscreen = function(self)
            return (self.y >= screen_max) or (self.y <= screen_min - sprite_size / 2)
        end,
        draw = function(self)
            spr(self.body_sprite, self.x, self.y)
            spr(self.wing_sprite, self.x, self.y)
        end
    }
end

function game_over_overlay()
    text = {
        game_over = "g a m e   o v e r",
        best_score = "best score: "..best_score,
        press_key = "press ❎ to restart"
    }
    rectfill(16, 48, 112, 88, colours.dark_grey)
    rect(17, 49, 111, 87, colours.white)
    print(text.game_over, hcenter(text.game_over), 57, colours.black)
    print(text.game_over, hcenter(text.game_over), 56, colours.white)
    print(text.best_score, hcenter(text.best_score), 69, colours.black)
    print(text.best_score, hcenter(text.best_score), 68, colours.white)
    print(text.press_key, hcenter(text.press_key), 77, colours.black)
    print(text.press_key, hcenter(text.press_key), 76, colours.white)
end

function track_score()
    return {
        value = 0,
        x = 4,
        y = 4,
        increment = function(self)
            self.value += 1
        end,
        draw = function(self)
           print("score: "..self.value, self.x, self.y, colours.white)
        end
    }
end

function logging()
    return {
        lines = {},
        clear = function(self)
            self.lines = {}
        end
        debug = function(self, text)
            add(self.lines, text)
        end,
        draw = function(self)
            for i,l in ipairs(self.lines) do
                print("-- "..l, score.x, score.y + (text_size * i), colours.white)
            end
        end
    }
end

function map_overlay()
    map(0, 0, 0, screen_center - sprite_size)
end
__gfx__
0000000000000000cccccccc7abbbbbb07abbbb007abbbb000000000000000000000000077777777000000000000000000000000000000000000000000000000
0000000000aa7700cccccccc7abbbbbb07abbbb007abbbb000000000000000000000000077777777000000000000000000000000000000000000000000000000
0070070077a77070cccccccc7aaaaaaa07abbbb007abbbb000000000000000000000000077777777000000000000000000000000000000000000000000000000
00077000aaaa7888cccccccc07abbbb007abbbb007abbbb000000770000000000000000077777777000000000000000000000000000000000000000000000000
00077000aaaa8888cccccccc07abbbb007abbbb007abbbb000007777077000070000000077777777000000000000000000000000000000000000000000000000
0070070099999888cccccccc07abbbb007abbbb07aaaaaaa07707777777700777700000777777777000000000000000000000000000000000000000000000000
0000000000999900cccccccc07abbbb007abbbb07bbbbbbb77777777777777777777077777777777000000000000000000000000000000000000000000000000
0000000000000000cccccccc07abbbb007abbbb07bbbbbbb77777777777777777777777777777777000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077700000077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007700000777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f0a0a0a0a0a0a0a0a3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f0a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0a0a0a0a0a0a0a0a0a3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0606060706080807070808080708080700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0909090909090909090909090909090900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
