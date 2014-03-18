/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */
 

--
-- FUNCTION FOR ACTUALLY LOADING OR GENERATING CHUNK DATA
--
function GM:LoadChunkObject( )

end



--
-- STREAM CHUNKS TO CLIENTS WHEN READY.
--

local function StreamChunk( chunk, ply )
	local cx, cy, cz = chunk:GetPos();
	local data = chunk:ToString( );
	local dLen = string.len( data );
	net.Start( 'mc_chunkReady' );
		net.WriteInt( cx, 32 );
		net.WriteInt( cy, 32 );
		net.WriteInt( cz, 32 );
		net.WriteInt( dLen, 16 );
		net.WriteData( data, dLen );
	net.Send( ply or chunk.interested );
end


--
-- PROCESS CHUNKS IN GENERATION PIPELINE.
--
local thresh = 1/30;
local genQueue = {};

local cache = {};
local function GenerateChunk( chunk )
	local cx, cy, cz = chunk:GetPos( );

	GAMEMODE:TG_GenerateChunk( cx, cy, cz, cache );
	chunk:InitFromRawTable( cache );
	chunk:SetStatus( STATUS_READY );

	StreamChunk( chunk );
	chunk.interested = nil;
end

function GM.ChunkManager_ProcessQueue( )
	local start = SysTime( );
	local c = 0;
	while( #genQueue > 0 )do
		c = c + 1;
		
		local chunk = table.remove( genQueue, 1 );
		GenerateChunk( chunk );

		if( SysTime() - start > thresh )then
			break ;
		end
	end
	if( c > 0 )then
		--print("[PMC] Processed "..c.." chunks from gen queue.");
	end
end

util.AddNetworkString( 'mc_chunkRequest' );
util.AddNetworkString( 'mc_chunkReady' );
net.Receive( 'mc_chunkRequest', function( len, ply )
	-- firstly we read the doubles.
	local cx = net.ReadInt( 32 );
	local cy = net.ReadInt( 32 );
	local cz = net.ReadInt( 32 );

	local cc = GAMEMODE:GetChunk( cx, cy, cz );
	if( ValidChunk( cc ) )then
		if( cc:StatusPending() )then
			table.insert( cc.interested, ply );
			--print("[PZS] Chunk already pending generation.", cx, cy, cz );
		elseif( cc:StatusReady( ) )then
			StreamChunk( cc, ply );
		end
	else
		local newChunk = GAMEMODE.NewChunk( ):InitBase( );
		newChunk:SetPos( cx, cy, cz );
		newChunk.interested = { ply };
		newChunk:SetStatus( STATUS_PENDING );

		GAMEMODE:SetChunk( cx, cy, cz, newChunk );
		table.insert( genQueue, newChunk );
	end
end);