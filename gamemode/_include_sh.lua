/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */

jit.on( );

local include = GM.include;

--
-- CONFIGURATION FILES FIRST
-- 
include( '_config_sh.lua' )

include( '_enums_sh.lua' );

--
-- LIBRARY
--

include( 'lib/util_sh.lua' );

include( 'lib/von_sh.lua' );
include( 'lib/datablobs_sh.lua' );

include( 'lib/octtree_sh.lua' ) -- oct tree libraries.
include( 'lib/octtree_util_sh.lua' );


include( 'lib/metablock_sh.lua' );


include( 'lib/metachunk_sh.lua' ); -- shared chunk meta table.
include( 'lib/metachunk_cl.lua' ); -- client side chunk metatable.

include( 'lib/perlin_sh.lua' ); -- perlin noise field generation.





--
-- CORE
--
include( 'core/hooks_sv.lua' );
include( 'core/hooks_cl.lua' );

include( 'core/blocks_sh.lua' );

include( 'core/chunkmanager_sh.lua' );
include( 'core/chunkmanager_cl.lua' );
include( 'core/chunkmanager_sv.lua' );

include( 'core/terraingen_sh.lua' );

include( 'core/render_cl.lua' );


--
-- PHYSICS
-- 
include( 'phys/raytrace_sh.lua' );

include( 'phys/movement_cl.lua' );

include( 'phys/player_cl.lua' );
include( 'phys/player_sv.lua' );

include( 'phys/playermanager_sh.lua' );
include( 'phys/playermanager_cl.lua' );
include( 'phys/playermanager_sv.lua' );