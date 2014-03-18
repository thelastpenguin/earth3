--[[
HANDLES LOADING AND MANAGING OF CHUNKS
	THESE ARE GLOBAL CHUNK OPERATIONS SPECIFIC TO THE GAME NOT LIBRARY UTILITIES
	NOTE: CLIENT AND SERVER GARBAGE COLLECTION ALGORITHMS ARE TO BE HANDLED SEPERATELY.
]]

local chunks = {};
GAMEMODE.chunks = chunks;

file.CreateDir( 'pminecraft' );
file.CreateDir( 'pminecraft/maps' );
file.CreateDir( 'pminecraft/maps/'..GM.cfg.map );


--
-- GET A CHUNK AT GIVEN COORDINATES.
--
function GM:GetChunkRaw( cx, cy, cz )
	local existing = chunks[cx] and chunks[cx][cy] and chunks[cx][cy][cz];
	if( existing )then
		existing:SetAccessStamp( );
		return existing;
	end
end

--
-- SET CHUNK AT GIVEN CORDINATES.
--
function GM:SetChunk( cx, cy, cz, chunk )
	if( not chunks[cx] )then
		chunks[ cx ] = {}
	end
	if( not chunks[cx][cy] )then
		chunks[ cx ][ cy ] = {}
	end
	chunks[ cx ][ cy ][ cz ] = chunk;
end

--
-- REMOVE CHUNK AT GIVEN CORDINATES.
--
function GM:DelChunk( cx, cy, cz )
	if( not chunks[ cx ] or not chunks[ cx ][ cy ] )then
		print("CHUNK DOESNT EXIST");
		return
	end
	chunks[ cx ][ cy ][ cz ] = nil;

	if( #chunks[ cx][ cy ] == 0 )then
		chunks[ cx ][ cy ] = nil;
	end
	if( #chunks[ cx ] == 0 )then
		chunks[ cx ] = nil;
	end
end

local cache = {};
function GM:GetChunk( cx, cy, cz )
	-- first check if the chunk is already loaded.
	local chunk = self:GetChunkRaw( cx, cy, cz );
	if( chunk )then
		chunk:SetAccessStamp( );
		return chunk;
	end
end

local blockToChunk = GM.pos_blockToChunk;
local size = GM.cfg.chunk_size;
local ValidChunk = ValidChunk;
function GM:GetBlock( bx, by, bz )
	local size = size;
	local cx, cy, cz = blockToChunk( bx, by, bz );
	local x, y, z = bx%size, by%size, bz%size;
	local cc = self:GetChunk( cx, cy, cz );
	if( ValidChunk( cc ) )then
		return cc:GetBlock( x, y, z );
	end
end