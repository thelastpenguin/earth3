local function offsetTrace( o, start, finish )
	local tRes = GAMEMODE:TraceLine( start + o, finish + o );
	tRes.HitPos = tRes.HitPos - o;
	return tRes;
end

local offsets = {
		Vector( -0.25, -0.25, 0 ),
		Vector( 0.25, -0.25, 0 ),
		Vector( -0.25, 0.25, 0 ),
		Vector( 0.25, 0.25, 0 ),
		Vector( -0.25, -0.25, 0.8 ),
		Vector( 0.25, -0.25, 0.8 ),
		Vector( -0.25, 0.25, 0.8 ),
		Vector( 0.25, 0.25, 0.8 ),
		Vector( -0.25, -0.25, 1.6 ),
		Vector( 0.25, -0.25, 1.6 ),
		Vector( -0.25, 0.25, 1.6 ),
		Vector( 0.25, 0.25, 1.6 )
	}

local function PlayerTraceHull( start, finish )
	local btRes;
	for _, o in pairs( offsets )do
		local tRes = offsetTrace( o, start, finish );
		if( not btRes or ( tRes.hit and tRes.fraction < btRes.fraction ) )then
			btRes = tRes;
		end
	end
	return btRes;
end


function GM:phys_PlayerTick( mcply, dt )
	mcply:SetVelocity( mcply:GetVelocity() + Vector( 0, 0, -dt*20 ) );

	if( mcply.forward )then

		local cVel = mcply:GetVelocity();
		mcply:SetVelocity( Vector( cVel.y, cVel.x, 1 ) );

		local vec = mcply:EyeAngles():Forward() * 10;
		vec.z = 0;
		mcply:SetVelocity( Vector( vec.x, vec.y, cVel.z ) );
	end
	if( mcply.jump and PlayerTraceHull( mcply:GetPos(), mcply:GetPos() - Vector( 0, 0, 0.2 ) ).hit)then
		local cVel = mcply:GetVelocity();
		mcply:SetVelocity( Vector( cVel.x, cVel.y, 7 ) );
	end
	
	local cPos = mcply:GetPos();
	local vel = mcply:GetVelocity( );
	vel = Vector( vel.x, vel.y, vel.z );
	cPos = Vector( cPos.x, cPos.y, cPos.z );

	for i = 1, 5 do
		if( vel:Length() <= 0 )then
			break ;
		end

		local tRes = PlayerTraceHull( cPos, cPos + vel*dt );

		cPos = tRes.HitPos;
		
		if( tRes.hit )then
			local step = tRes.step;
			if( step.x ~= 0 )then
				vel.x = 0;
			elseif( step.y ~= 0 )then
				vel.y = 0;
			elseif( step.z ~= 0 )then
				vel.z = 0;
			end

			cPos = cPos + tRes.step * ( -0.001 );

			local rFrac = 1 - tRes.fraction;
			
		else
			break ;
		end
	end
	vel.x, vel.y = vel.x*0.5, vel.y*0.5;

	if( CLIENT and mcply == GAMEMODE:LocalPlayer() )then
		mcply:SetVelocity( vel );
	end
	mcply:SetPos( cPos );
end