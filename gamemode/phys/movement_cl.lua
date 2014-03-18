/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */

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