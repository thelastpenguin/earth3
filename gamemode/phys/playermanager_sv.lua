/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */

local players = {};


function GM:phys_PlayerInitialSpawn( pl )
	
end

function GM:phys_PlayerDisconnected( pl )
	print( '[MC] Physics cleaned up invalid player!' );
	players[ pl:EntIndex() ] = nil;
end


-- ACTUALLY CREATE THE PLAYER ONCE A NETWORK CONNECTION IS ESTABLISHED.
function GM:phys_NWReady( pl )
	print( '[MC] Physics created new player!' );
	local phys = self:phys_NewPlayer( pl );
	players[ pl:EntIndex() ] = phys;

	phys:SetPos( Vector( 0, 0, 200 ) );
	phys:SetVelocity( Vector( 0, 0, -10 ) );

	phys:PhysSync( player.GetAll() );
end


function GM:phys_GetPlayer( pl )
	if( type( pl ) == 'number' )then
		return players[ pl ]
	else
		return players[ pl:EntIndex() ];
	end
end

function GM:phys_GetPlayers( )
	return players;
end


local lastTick = CurTime( );
local syncTime = CurTime( );
function GM:phys_Tick( )
	-- garbage collect garbage.
	for k,v in pairs( players )do
		if( not IsValid( v.pl ) )then
			print( '[MC] Garbage collected player!' );
			players[ k ] = nil;
		end
	end

	if( CurTime() > syncTime )then
		self:phys_Sync( );
		syncTime = CurTime() + 0.5
	end

	local t = CurTime() - lastTick;
	for k,v in pairs( players )do
		self:phys_PlayerTick( v, t );
	end

end


function GM:phys_Sync( )
	print( '[MC] Syncing physics data.');
	for k,v in pairs( players )do
		v:PhysSync( );
	end
end


-- RECEIVE PHYSICS DATA FROM CLIENT.
util.AddNetworkString( 'mc_physSubmit' );
net.Receive( 'mc_physSubmit', function( len, pl )
	local phys = players[ pl:EntIndex() ];
	if( not phys )then return end
	phys:SetPos( Vector( net.ReadDouble(), net.ReadDouble(), net.ReadDouble() ) );
	phys:SetVelocity( Vector( net.ReadDouble(), net.ReadDouble(), net.ReadDouble() ) );
	print('[MC] Physics got data from client. ' );
	PrintTable( phys );
end);