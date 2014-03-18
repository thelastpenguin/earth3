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