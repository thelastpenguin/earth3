/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */

local playermt = {};
playermt.__index = playermt;

function playermt:SetPos( pos )
	self.pos = pos;
end

function playermt:SetVelocity( vel )
	self.vel = vel;
end

function playermt:GetVelocity( )
	return self.vel;
end

function playermt:GetPos( )
	return self.pos;
end

function playermt:EyeAngles( )
	return self.pl:EyeAngles( )
end

function playermt:EyePos( )
	return self.pos + Vector( 0, 0, 1.5 );
end

function playermt:Index( )
	return self.id;
end

local syncDistance = GM.cfg.loadRadius * GM.cfg.chunk_size;

util.AddNetworkString( 'mc_physSync' );
function playermt:PhysSync( shareWith )
	print("[MC] Syncing phys data for player "..self.pl:Name());
	local myPos = self:GetPos();

	net.Start( 'mc_physSync' );
		net.WriteInt( self:Index(), 32 );
		local pos = self:GetPos();
		net.WriteDouble( pos.x );
		net.WriteDouble( pos.y );
		net.WriteDouble( pos.z );
		local vel = self:GetVelocity();
		net.WriteDouble( vel.x );
		net.WriteDouble( vel.y );
		net.WriteDouble( vel.z );

	if( shareWith )then
		net.Send( shareWith );
	else
		local shareWith = {};
		local players = GAMEMODE:phys_GetPlayers( );
		for k,v in pairs( players )do
			if( v ~= self )then
				local oPos = v:GetPos();
				if( math.abs( oPos.x - myPos.x ) > syncDistance or math.abs( oPos.y - myPos.y ) > syncDistance or math.abs( oPos.z - myPos.z ) > syncDistance )then
					table.insert( shareWith, v.pl );
				end
			end
		end
		net.Send( shareWith );
	end

end

function GM:phys_NewPlayer( pl )
	local n = setmetatable( {}, playermt );
	n.id = pl:EntIndex();
	n.pl = pl;
	n:SetPos( Vector( 0, 0, 200 ) );
	n:SetVelocity( Vector( 0, 0, 0 ) );

	return n;
end