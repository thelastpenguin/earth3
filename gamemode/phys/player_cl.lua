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

function GM:phys_NewPlayer( pl )
	local n = setmetatable( {}, playermt );
	n.id = pl:EntIndex();
	n.pl = pl;
	n:SetPos( Vector( 0, 0, 200 ) );
	n:SetVelocity( Vector( 0, 0, 0 ) );

	return n;
end