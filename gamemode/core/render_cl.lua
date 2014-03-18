/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */


--[[
PLANNING:
what is required by rendering system?
it must determine which chunks it wants to render and attempt to render them.
]]

local renderScale = GM.cfg.renderScale;
local rr = GM.cfg.viewRadius;
local ValidChunk = ValidChunk;

function GM:render_DrawChunks( )
	local lPos = GAMEMODE:LocalPlayer():GetPos();
	local lcx, lcy, lcz = self.pos_blockToChunk( self.pos_worldToBlock( lPos.x, lPos.y, lPos.z ));
	
	local indexTime = 0;
	local drawTime = 0;
	for x = lcx-rr, lcx+rr do
		for y = lcy-rr, lcy+rr do
			for z = lcz-rr, lcz+rr do
				GAMEMODE.benchmark( );
				local cc = self:GetChunk( x, y, z );
				indexTime = indexTime + GAMEMODE.benchmark( );
				if( ValidChunk( cc ) and cc:StatusReady() and cc.rMesh and cc.rMatrix )then
					GAMEMODE.benchmark( );
					cc:Draw( );
					drawTime = drawTime + GAMEMODE.benchmark( );
				end
			end
		end
	end
end

local queue = {};
function GM:render_ProcessQueue( )
	local start = SysTime()
	local thresh = FrameTime()*0.3;

	while( SysTime() - start < thresh and #queue > 0 )do
		local cc = table.remove( queue );
		cc:BuildRenderMesh( );
	end
end

hook.Add( 'mc_ChunkReady', 'mc.RenderUpdate', function( cc, cx, cy, cz )
	-- this we do instantly since it is extremely quick.
	cc:SetDrawTransform( Vector( GAMEMODE.pos_blockToWorld( GAMEMODE.pos_chunkToBlock( cx, cy, cz ) ) ) );
end);

hook.Add( 'mc_ChunkUpdate', 'mc.RenderUpdate', function( cc, cx, cy, cz )
	table.insert( queue, 1, cc );
end);




function GM:render_DrawPlayers( )
	local players = self:phys_GetPlayers( );
	for k,v in pairs( players )do
		local pos = v:GetPos( );
		render.DrawWireframeSphere( pos * renderScale, 15, 10, 5, Color( 255, 0, 0 ) )
	end
end