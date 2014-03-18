/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */

local players = {};


-- GET PLAYER AT THE GIVEN INDEX.
function GM:phys_GetPlayer( pl )
	if( type( pl ) == 'number' )then
		return players[ pl ]
	else
		return players[ pl:EntIndex() ];
	end
end

-- GET ALL PLAYERS
function GM:phys_GetPlayers( )
	return players;
end

-- GET THE LOCAL PLAYER OBJECT.
function GM:LocalPlayer( )
	return players[ LocalPlayer():EntIndex() ];
end

-- RECEIVE PHYS UPDATE DATA FROM SERVER FOR A GIVEN PLAYER.
net.Receive( 'mc_physSync', function( len )
	local id = net.ReadInt( 32 );
	if( not players[ id ] )then
		players[ id ] = GAMEMODE:phys_NewPlayer( player.GetByID( id ) );
	end

	local ply = players[ id ];
	ply:SetPos( Vector( net.ReadDouble(), net.ReadDouble(), net.ReadDouble() ) );
	ply:SetVelocity( Vector( net.ReadDouble(), net.ReadDouble(), net.ReadDouble() ) );

	print( '[MC] Received physics data packet.');
	PrintTable( ply );
end);




--
-- PHYSICS SYSTEM TICK.
--
do -- bottle up those local variables...
	local lastTick = CurTime( );
	local syncTime = CurTime( );
	function GM:phys_Tick( )
		-- garbage collect garbage.
		for k,v in pairs( players )do
			if( not IsValid( v.pl ) )then
				players[ k ] = nil;
			end
		end

		if( CurTime() > syncTime )then
			self:phys_Sync( );
			syncTime = CurTime() + 0.5
		end

		local t = CurTime() - lastTick;
		lastTick = CurTime();

		for k,v in pairs( players )do
			if( v.pl:IsValid() )then
				self:phys_PlayerTick( v, t );
			end
		end

	end
end

function GM:phys_Sync( )
	local LocalPlayer = self:LocalPlayer();
	if( not LocalPlayer )then return end

	net.Start( 'mc_physSubmit' );
		local pos = LocalPlayer:GetPos();
		net.WriteDouble( pos.x );
		net.WriteDouble( pos.y );
		net.WriteDouble( pos.z );
		local vel = LocalPlayer:GetVelocity( );
		net.WriteDouble( vel.x );
		net.WriteDouble( vel.y );
		net.WriteDouble( vel.z );
	net.SendToServer( );
end