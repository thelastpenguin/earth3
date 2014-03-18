/*===========================================
GENARIC META OBJECT FOR A BLOCK TYPE.
METHODS:
	MakeRenderMesh - generates the rendering mesh when passed a table to stick the result into.
	MakePhysMesh - generates a physics mesh.
===========================================*/

local rVector = GM.recycledVec; -- no wasting vectors here! nope nope nope!



local block_mt = {} -- The metatable
local block_methods = {} -- Methods for our objects
block_mt.__index = block_methods -- Redirect all key "requests" to the methods table

GM.blocks = {}


function GM.NewBlockType( id, name )
	local new = {}
	setmetatable( new, block_mt )
	new.id = id
	new.name = name
	GM.blocks[ id ] = new
	return new
end

function block_methods:SetTexture( tex )
	self.texture = tex;
end
function block_methods:GetTexture( )
	return self.texture;
end

local up    = Vector( 0, 0, 1 )
local front = Vector( 0, 1, 0 )
local right = Vector( 1, 0, 0 )
local function InsertQuad( tbl, start, top_left, top_right, bottom_right, bottom_left, normal, us, u, vs, v, col )
	tbl[ start + 1 ] = { pos = bottom_right,normal = normal * 2, u=-us, v=-vs+v, color=col }
	tbl[ start + 2 ] = { pos = top_right, normal = normal * 2, u=-us, v=-vs, color=col  }
	tbl[ start + 3 ] = { pos = bottom_left, normal = normal * 2, u=-us+u, v=-vs+v, color=col }
	
	tbl[ start + 4 ] = { pos = top_right, normal = normal * 2, u=us, v=vs, color=col }
	tbl[ start + 5 ] = { pos = top_left,normal = normal * 2, u=-us+u, v=vs, color=col }
	tbl[ start + 6 ] = { pos = bottom_left, normal = normal * 2, u=-us+u, v=vs+v, color=col }

	return start + 6;
end
local color_green = Color(255,0,0 )
function block_methods:Mesh_InsertTop( tbl, start, x, y, z)
	return InsertQuad( tbl, start, rVector(x,y,z+1), rVector(x+1,y,z+1), rVector(x+1,y+1,z+1), rVector(x,y+1,z+1), up, 0, 0.5, 0, 0.5 )
end
function block_methods:Mesh_InsertBottom( tbl, start, x, y, z)
	return InsertQuad( tbl, start, rVector(x+1,y,z), rVector(x,y,z), rVector(x,y+1,z), rVector(x+1,y+1,z), -up, 0.5, 0.5, 0, 0.5) -- bottom quad.
end
function block_methods:Mesh_InsertLeft( tbl, start, x, y, z)
	return InsertQuad( tbl, start, rVector(x,y,z+1), rVector(x,y+1,z+1), rVector(x,y+1,z), rVector(x,y,z), -right, 0, 0.5, 0.5, 0.5 ) -- left quad.
end
function block_methods:Mesh_InsertRight( tbl, start, x, y, z)
	return InsertQuad( tbl, start, rVector(x+1,y+1,z+1), rVector(x+1,y,z+1), rVector(x+1,y,z), rVector(x+1,y+1,z), right, 0, 0.5, 0.5, 0.5) -- right quad.
end
function block_methods:Mesh_InsertFront( tbl, start, x, y, z)
	return InsertQuad( tbl, start, rVector(x,y+1,z+1), rVector(x+1,y+1,z+1), rVector(x+1,y+1,z), rVector(x,y+1,z), front, 0, 0.5, 0.5, 0.5) -- front quad.
end
function block_methods:Mesh_InsertBack( tbl, start, x, y, z)
	return InsertQuad( tbl, start, rVector(x+1,y,z+1), rVector( x,y,z+1), rVector(x,y,z), rVector(x+1,y,z), -front, 0, 0.5, 0.5, 0.5) -- back quad.
end