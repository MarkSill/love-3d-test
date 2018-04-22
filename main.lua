local cpml = require "cpml"

function love.load()
	format = {
		{
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
	vertices = {
		{100, 50, 10},
		{110, 50, 10},
		{110, 60, 10}
	}
	mesh = love.graphics.newMesh(format, vertices, "triangles")
	shader = love.graphics.newShader("test.glsl")
	cameraPos = cpml.vec3(0, -5, -15)
	angle = cpml.vec2(0, 0)
end

function love.draw()
	shader:send("view", makeProper(matrix()))
	love.graphics.setShader(shader)
	love.graphics.setDepthMode("lequal", false)
	love.graphics.draw(mesh)
	love.graphics.setShader()
	for i = 1, mesh:getVertexCount() do
		local vertex = cpml.vec3(mesh:getVertex(i))
		vertex = makeProper(matrix()) * vertex
		love.graphics.points(vertex.x, vertex.y)
		love.graphics.print(vertex.x .. ", " .. vertex.y .. ", " .. vertex.z, 20, 20 * i)
	end
end

function matrix()
	local mat = cpml.mat4.from_perspective(60, love.graphics.getWidth()/love.graphics.getHeight(), 0.1, 1000)
	local v = cpml.mat4()
	v:translate(v, cameraPos)
	v:rotate(v, -math.pi/2, cpml.vec3.unit_x)
	v:rotate(v, angle.y, cpml.vec3.unit_x)
	v:rotate(v, angle.x, cpml.vec3.unit_z)
	return mat * v
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
	end
end

function love.mousepressed(x, y, button)
	if button == 1 then
		dragging = true
	end
end

function love.mousereleased(x, y, button)
	if button == 1 then
		dragging = false
	end
end

function love.mousemoved(x, y, dx, dy)
	if dragging then
		angle.x = angle.x + math.rad(dx * 0.5)
		angle.y = angle.y + math.rad(dy * 0.5)
	end
end
