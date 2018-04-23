local cpml = require "cpml"

function love.load()
	love.window.setTitle("3D Test")
	format = {
		{
			-- Add Z coordinate to VertexPosition
			"VertexPosition",
			"float",
			3
		},
		{
			"VertexTexCoord",
			"float",
			2
		},
		{
			"VertexColor",
			"byte",
			4
		}
	}
	width = 2
	height = 2
	vertices = {
		{-width/2, -height/2, 0},
		{width/2, -height/2, 0},
		{width/2, height/2, 0}
	}
	mesh = love.graphics.newMesh(format, vertices, "triangles")
	shader = love.graphics.newShader("test.glsl")
	cameraPos = cpml.vec3(0, 0, -15)
	angle = cpml.vec2(0, 0)
	drawMode = "lines"
end

function love.draw()
	love.graphics.push("all")
	local w, h = love.graphics.getDimensions()
	love.graphics.translate(w/2, h/2)
	local view = matrix()
	shader:send("view", view)
	love.graphics.setShader(shader)
	love.graphics.setDepthMode("lequal", false)
	love.graphics.draw(mesh)
	love.graphics.setShader()
	love.graphics.pop()
	local vertices = {}
	for i = 1, mesh:getVertexCount() do
		local vertex = cpml.vec3(mesh:getVertex(i))
		vertex = view * vertex
		table.insert(vertices, vertex.x * 10)
		table.insert(vertices, vertex.y * 10)
		love.graphics.print(vertex.x .. ", " .. vertex.y .. ", " .. vertex.z, 20, 20 * i)
	end
	love.graphics.push("all")
	love.graphics.translate(w/2, h/2)
	if drawMode == "points" then
		for i = 1, #vertices, 2 do
			love.graphics.points(vertices[i], vertices[i+1])
		end
	elseif drawMode == "lines" then
		love.graphics.polygon("line", vertices)
	elseif drawMode == "fill" then
		love.graphics.polygon("fill", vertices)
	end
	love.graphics.pop()
	love.graphics.print("Angle: " .. angle.x .. ", " .. angle.y, 20, 20*4)
	love.graphics.print("Draw mode: " .. drawMode, 20, 20*5)
	love.graphics.print("Press space to change draw mode; backspace to reset angle", 20, 20*6)
	love.graphics.print("WASD, arrow keys, or click and drag to rotate", 20, 20*7)
	love.graphics.print("There should be a triangle drawn with a mesh/shader where the triangle drawn on screen is, but there's not.", 20, 20*8)
end

function love.update(dt)
	local speed = 5 * dt
	if love.keyboard.isDown("w", "up") then
		angle.y = angle.y - speed
	elseif love.keyboard.isDown("s", "down") then
		angle.y = angle.y + speed
	end
	if love.keyboard.isDown("a", "left") then
		angle.x = angle.x - speed
	elseif love.keyboard.isDown("d", "right") then
		angle.x = angle.x + speed
	end
end

function matrix()
	local mat = cpml.mat4.from_perspective(60, love.graphics.getWidth()/love.graphics.getHeight(), 0.1, 1000)
	local v = cpml.mat4()
	v:translate(v, cameraPos)
	v:rotate(v, -math.pi/2, cpml.vec3.unit_x)
	v:rotate(v, angle.y, cpml.vec3.unit_x)
	v:rotate(v, angle.x, cpml.vec3.unit_y)
	return makeProper(mat) * makeProper(v)
end

function makeProper(mat)
	local m = {}
	for x = 1, 4 do
		local t = {}
		for y = 1, 4 do
			table.insert(t, mat[(y - 1) * 4 + x])
		end
		table.insert(m, t)
	end
	return cpml.mat4(m)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "space" then
		if drawMode == "points" then
			drawMode = "lines"
		elseif drawMode == "lines" then
			drawMode = "fill"
		elseif drawMode == "fill" then
			drawMode = "points"
		end
	elseif key == "backspace" then
		angle = cpml.vec2(0, 0)
	end
end

function love.mousepressed(x, y, button)
	if button == 1 then
		dragging = true
		love.mouse.setRelativeMode(true)
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		dragging = false
		love.mouse.setRelativeMode(false)
	end
end

function love.mousemoved(x, y, dx, dy)
	if dragging then
		angle.x = angle.x + math.rad(dx * 0.5)
		angle.y = angle.y + math.rad(dy * 0.5)
	end
end
