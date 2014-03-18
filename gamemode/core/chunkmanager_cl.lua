/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */
 
local openStreams = 0;
local maxStreams = GM.cfg.parallelDownloads;

--
-- ACTUALLY FETCH THE CHUNKS.
--
local function FetchChunk( cx, cy, cz, cback )
	--print( '[PMC] Issuing fetch request for chunk: ', cx, cy, cz );
	openStreams = openStreams + 1;

	local newChunk = GAMEMODE.NewChunk( ):InitBase( );
	newChunk:SetPos( cx, cy, cz );
	if( cback )then
		newChunk.cback = cback;
	end
	GAMEMODE:SetChunk( cx, cy, cz, newChunk );

	newChunk:SetStatus( STATUS_PENDING );
	hook.Call( 'mc_ChunkPending', GAMEMODE, cc, cx, cy, cz );
	net.Start( 'mc_chunkRequest')
		net.WriteInt( cx, 32 );
		net.WriteInt( cy, 32 );
		net.WriteInt( cz, 32 );
	net.SendToServer( );
end

net.Receive( 'mc_chunkReady', function( )
	openStreams = openStreams - 1;

	local cx, cy, cz = net.ReadInt( 32 ), net.ReadInt( 32 ), net.ReadInt( 32 );
	local data = net.ReadData( net.ReadInt( 16 ) );

	local cc = GAMEMODE:GetChunk( cx, cy, cz );
	if( ValidChunk( cc ) and cc:StatusPending( ) )then
		cc:InitFromString( data );
		cc:SetStatus( STATUS_READY );
		if( cc.cback )then
			cc.cback( cc )
			cc.cback = nil
		end
	end

	hook.Call( 'mc_ChunkReady', GAMEMODE, cc, cx, cy, cz );
	hook.Call( 'mc_ChunkUpdate', GAMEMODE, cc, cx, cy, cz );
end);

--
-- MANAGE GETTING CHUNKS ETC
--
local rr = GM.cfg.loadRadius;


local function render_Identify_CheckChunk( lcx, lcy, lcz, cx, cy, cz )
	if( openStreams >= maxStreams )then return end

	local c = GAMEMODE:GetChunk( lcx + cx, lcy + cy, lcz + cz );
	if( not ValidChunk( c ) )then
		FetchChunk( lcx + cx, lcy + cy, lcz + cz );
	end

	return issuedFetch;
end

local function render_Identify_CheckRadius( cx, cy, cz, r )
	for a = -r, r do
		for b = -r, r do
			render_Identify_CheckChunk( cx, cy, cz, a, b,  r )
			if( r ~= 0 )then
			render_Identify_CheckChunk( cx, cy, cz, a, r,  b )
			render_Identify_CheckChunk( cx, cy, cz, r, a,  b )
		
			render_Identify_CheckChunk( cx, cy, cz, a, b, -r )
			render_Identify_CheckChunk( cx, cy, cz, a, -r, b )
			render_Identify_CheckChunk( cx, cy, cz, -r, a, b )
			end
			if( openStreams >= maxStreams )then return end
		end
	end
end

function GM:ChunkManager_HandleDownloads( )
	local lPos = GAMEMODE:LocalPlayer():GetPos();
	local lcx, lcy, lcz = self.pos_blockToChunk( self.pos_worldToBlock( lPos.x, lPos.y, lPos.z ));

	maxStreams = 1000 / math.Clamp( LocalPlayer():Ping(), 50, 1000 )*2;

	for i = 0, rr do
		render_Identify_CheckRadius( lcx, lcy, lcz, i );
		if( openStreams >= maxStreams )then return end
	end
end

--
-- GARBAGE COLLECTION
--
local gcr = GM.cfg.gcRadius;
function GM:ChunkManager_GarbageCollect( )
	local count = 0;
	local lPos = GAMEMODE:LocalPlayer():GetPos();
	local lcx, lcy, lcz = self.pos_blockToChunk( self.pos_worldToBlock( lPos.x, lPos.y, lPos.z ));

	local chunks = self.chunks;

	for x,ytbl in pairs( chunks )do
		for y,ztbl in pairs( ytbl )do
			for z, cc in pairs( ztbl )do
				if( math.abs( x - lcx ) > gcr or math.abs( y - lcy ) > gcr or math.abs( z - lcz ) > gcr )then
					ztbl[ z ] = nil;
					count = count + 1;
				end
			end
			if( table.Count( ztbl ) == 0 )then
				ytbl[ y ] = nil;
			end
		end
		if( table.Count( ytbl ) == 0 )then
			chunks[ x ] = nil
		end
	end
	if( count > 0 )then
		MsgC( Color( 255, 0, 0 ), '[PMC] Garbage collected '..count..' chunks!\n');
	end
end