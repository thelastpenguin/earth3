AddCSLuaFile()

module( "physmesh_builder", package.seeall )

local Vertices = {}
scale = 10

local up    = Vector( 0, 0, 1 )
local front = Vector( 0, 1, 0 )
local right = Vector( 1, 0, 0 )

function Start( )
	Vertices = {}
end
function SetScale( _scale )
	scale = _scale
end

function InsertQuad( top_left, top_right, bottom_right, bottom_left )
	table.insert( Vertices, { pos = bottom_right } )
	table.insert( Vertices, { pos = top_right } )
	table.insert( Vertices, { pos = bottom_left } )
	
	table.insert( Vertices, { pos = top_right } )
	table.insert( Vertices, { pos = top_left } )
	table.insert( Vertices, { pos = bottom_left } )
end

local GAMEMODE = _G.GAMEMODE;
function AddBlock( pos, x, y, z )
	local GAMEMODE = _G.GAMEMODE;
	if( GAMEMODE:GetBlock( x, y, z + 1, 0 ) == 0 )then
		InsertQuad( pos + up, pos + up + right, pos + up + right + front, pos + up + front ) -- top.
	end
	if( GAMEMODE:GetBlock( x, y, z - 1, 0 ) == 0 )then
		InsertQuad( pos + right, pos, pos + front, pos + right + front ) -- bottom quad.
	end
	if( GAMEMODE:GetBlock( x + 1, y, z, 0 ) == 0 )then
		InsertQuad( pos + up + right, pos + up + front + right, pos + front + right, pos ) -- left quad.
	end
	if( GAMEMODE:GetBlock( x - 1, y, z, 0 ) == 0 )then
		InsertQuad( pos + up, pos + up + front, pos + front, pos ) -- left quad.
	end
	if( GAMEMODE:GetBlock( x, y + 1, z, 0 ) == 0 )then
		InsertQuad( pos + front + up, pos + front + up + right, pos + front + right, pos + front ) -- front quad.
	end
	if( GAMEMODE:GetBlock( x, y - 1, z, 0 ) == 0 )then
		InsertQuad( pos + up + right, pos + up, pos, pos + right ) -- back quad.
	end
end	

function End()
	for k,v in pairs( Vertices )do
		if( v.pos )then
			v.pos = v.pos * scale
		else
			PrintTable( Vertices )
			print("VERTEX:" )
			PrintTable( v )
			return nil
		end
	end
	print("Built Mesh size: ".. #Vertices )
	return Vertices
end