/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */



function GM:Think( )
	if( not GAMEMODE:LocalPlayer() )then return end

	self:ChunkManager_HandleDownloads( );
	self:ChunkManager_GarbageCollect( );
	self:phys_Tick( );

end

function GM:Tick( )
	if( not GAMEMODE:LocalPlayer() )then return end

	self:phys_Tick( );
end

function GM:PostDrawOpaqueRenderables( )
	
end

local renderChunkSize = GM.cfg.renderScale * GM.cfg.chunk_size
local fogDistance = GM.cfg.loadRadius * renderChunkSize;
local renderScale = GM.cfg.renderScale;

function GM:RenderScene( )
	if( not GAMEMODE:LocalPlayer() )then return end

	render.Clear( 200, 230, 255 , 255 )

	render.FogMode( MATERIAL_FOG_LINEAR );
	render.FogStart( fogDistance - renderChunkSize )
	render.FogEnd( fogDistance );
	render.FogColor( 200, 230, 255 );

	cam.Start3D( GAMEMODE:LocalPlayer():EyePos()*renderScale, GAMEMODE:LocalPlayer():EyeAngles(), 90 )
	self:render_DrawChunks( );
	self:render_ProcessQueue( );
	self:render_DrawPlayers( );
	cam.End3D();

	hook.Call( 'PreDrawHUD', GAMEMODE );
	hook.Call( 'HUDPaintBackground', GAMEMODE );
	hook.Call( 'HUDPaint', GAMEMODE );
	hook.Call( 'PostDrawHUD', GAMEMODE );
	hook.Call( 'PostRender', GAMEMODE );
	return true;
end


timer.Simple( 1, function() 
	net.Start( 'mc_dataReady' );
	net.SendToServer( );
end);