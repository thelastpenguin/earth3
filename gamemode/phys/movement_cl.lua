hook.Add("KeyPress", 'GM:KeyRelease', function( ply, key )
	local LocalPlayer = GAMEMODE:LocalPlayer();
	if( not LocalPlayer )then return end

	if( key == IN_FORWARD )then
		LocalPlayer.forward = true;
	elseif( key == IN_JUMP )then
		LocalPlayer.jump = true;
	end
end);

hook.Add("KeyRelease", 'GM:KeyRelease', function( ply, key )
	local LocalPlayer = GAMEMODE:LocalPlayer();
	if( not LocalPlayer )then return end

	if( key == IN_FORWARD )then
		LocalPlayer.forward = false;
	elseif( key == IN_JUMP )then
		LocalPlayer.jump = false;
	end
end);