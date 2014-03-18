/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */


GAMEMODE = GM;

GM.Version = "1.0.0"
GM.Name = "EARTH³"
GM.Author = "By thelastpenguin™"

--
-- _main.lua
--
print( [[
=========================================
= Loading pMinecraft by thelastpenguin™ =
=========================================
]]);

local function include( path, force )
	if( string.find( path, '_sh.lua' ) or force == 'sh' )then
		if(SERVER)then
			AddCSLuaFile( path );
		end
		_G.include( path );
	elseif( string.find( path, '_cl.lua' ) or force == 'cl' )then
		( SERVER and AddCSLuaFile or _G.include )( path );
	elseif( SERVER and string.find( path, '_sv.lua' ) or force == 'sv' )then
		_G.include( path );
	end
end

GM.include = include;

include( '_include_sh.lua' );