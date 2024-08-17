pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
best_score = 0
screen_min = 0
screen_max = 128
sprite_size = 8
text_size = 8
bg = 12
score_y = 4
debug = true

function _init()
    frame = 0
    score = 0
    game_over = false
    pipes = {}
    bird = make_bird(screen_max / 2, screen_max / 2)
end

function _update60()
	if (game_over) then
		if ((btn(❎))) _init()
		return
	end

    if ((frame % 100) == 0) then
        add(pipes, make_random_pipe())
    end

    if ((#pipes > 2)) then
        deli(pipes, 1)
    end

	foreach(pipes, function(p)
		p:move()
	end)

	if (btn(⬆️)) then
		bird:flap()
	else
		bird:drop()
	end

	foreach(pipes, function(p)
		if ((p:collides(bird))) game_over = true
	end)

	if ((bird.y >= screen_max)) game_over = true
	if ((bird.y <= screen_min - sprite_size / 2)) game_over = true

	frame += 1
	score += 1
    best_score = max(score, best_score)
end

function _draw()
    cls(bg)

    map_overlay()

    foreach(pipes, function(p)
        p:draw()
    end)

    bird:draw()

 	score_overlay()

 	if ((debug)) debug_overlay()

 	if (game_over) then
		game_over_overlay()
		return
	end
end

function hcenter(text)
	return (screen_max / 2) - (#text * 2)
end

function vcenter(text)
    return (screen_max) / 2 - 1
end

function bracket(value)
	return max(0, min(screen_max - sprite_size, value))
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
 	pipe_down = 5
	pipe_up = 3
	pipe_body = 4

 	hitboxes = {}

	gap = sprite_size * 2.5

	for i=0,height,sprite_size do
		add(hitboxes, {sprite = pipe_body, x = x, y = i})
	end

	add(hitboxes, {sprite = pipe_down, x = x, y = height})

	add(hitboxes, {sprite = pipe_up, x = x, y = height + gap + sprite_size})

    for i=height+gap+sprite_size,screen_max,sprite_size do
		add(hitboxes, {sprite = pipe_body, x = x, y =i})
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
                if((collide(h, other))) hit = true
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
	rest = 17
	flap = 18
 	return {
		x = x,
		y = y,
		vy = 0,
		body_sprite = 1,
		wing_sprite = rest,
		drop = function(self, frame)
			self.vy += gravity
			self.y += self.vy
			self.wing_sprite = rest
		end,
		flap = function(self)
	 		self.vy = jump
			self.y = bracket(self.y + self.vy)
			self.wing_sprite = flap
		end,
		draw = function(self)
			spr(self.body_sprite, self.x, self.y)
			spr(self.wing_sprite, self.x, self.y)
		end
 	}
end

function game_over_overlay()
	text ={
		game_over = "g a m e   o v e r",
		best_score = "best score: "..best_score,
		press_key = "press ❎ to restart"
	}
	rectfill(16, 48, 112, 88,5)
	rect(17, 49, 111,87, 7)
	print(text.game_over,hcenter(text.game_over), 57, 0)
	print(text.game_over, hcenter(text.game_over), 56, 7)
	print(text.best_score, hcenter(text.best_score), 69, 0)
	print(text.best_score, hcenter(text.best_score), 68, 7)
	print(text.press_key, hcenter(text.press_key), 77, 0)
	print(text.press_key, hcenter(text.press_key), 76, 7)
end

function score_overlay()
	print("score: "..score, 4, score_y, 7)
end

function debug_overlay()
	lines = {
		-- put strings here
	}
	for i,l in ipairs(lines) do
		print("--"..l, 4, score_y + (text_size * i), 7)
	end
end

function map_overlay()
	map(0,0,0,screen_max / 2 - 8)
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
