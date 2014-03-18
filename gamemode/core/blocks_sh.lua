/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */

--
local BLOCKTBL_STONE = GM.NewBlockType( 1, 'stone' )
if( CLIENT )then
	BLOCKTBL_STONE:SetTexture( Material('mc/texture_packs/default/stone') )
end

local DIRT = GM.NewBlockType( 2, 'dirt' )
if( CLIENT )then
	DIRT:SetTexture( Material('mc/texture_packs/default/dirt') )
end

local GRASS = GM.NewBlockType( 3, 'grass' )
if( CLIENT )then
	GRASS:SetTexture( Material('mc/texture_packs/default/grass') )
end