function GM:Think( )
	self:ChunkManager_ProcessQueue( );
end

function GM:Tick( )
	self:phys_Tick( );
end

function GM:PlayerInitialSpawn( pl )
	self:phys_PlayerInitialSpawn( pl );
end

function GM:PlayerDisconnected( pl )
	self:phys_PlayerDisconnected( pl );
end

function GM:PlayerSpawn( pl )
	pl:SetMoveType( MOVETYPE_NOCLIP );
end

function GM:PlayerNWReady( pl )
	self:phys_NWReady( pl );
end



util.AddNetworkString( 'mc_dataReady' );
net.Receive( 'mc_dataReady', function( len, pl )
	hook.Call( 'PlayerNWReady', GAMEMODE, pl );
end);