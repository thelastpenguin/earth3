local origin = GM.cfg.origin;
local blockScale = GM.cfg.blockScale;
local renderScale = GM.cfg.renderScale;
local chunkSize = GM.cfg.chunk_size;
local floor = math.floor;

function GM.pos_worldToBlock( x, y, z )
	return floor( x ), floor( y ), floor( z );
end

function GM.pos_blockToWorld( x, y, z )
	return x, y, z;
end

function GM.pos_blockToChunk( bx, by, bz )
	return floor( bx / chunkSize ), floor( by / chunkSize ), floor( bz / chunkSize );
end

function GM.pos_chunkToBlock( cx, cy, cz )
	return cx * chunkSize, cy * chunkSize, cz * chunkSize;
end

function GM.pos_blockToRender( x, y, z )
	return x * renderScale, y * renderScale, z * renderScale;
end




function GM.read2D1D( tbl, size, x, y )
    return tbl[ x * size + y ];
end

function GM.write2D1D( tbl, size, x, y, val )
    tbl[ x * size + y ] = val
end

function GM.read3D1D( tbl, size, x, y, z )
    return tbl[ (( x * size ) + y) * size + z ];
end
function GM.write3D1D( tbl, size, x, y, z, val )
    tbl[ (( x * size ) + y) * size + z ] = val;
end

local bench = 0;
function GM.benchmark( )
	local delta = SysTime() - bench;
	bench = SysTime( );
	return delta;
end



--
-- VECTOR CACHE
-- 
do
	local vectorCache = {};
	local vCacheInd = 0;
	function GM.recycledVec( x, y, z )
		vCacheInd = vCacheInd + 1;
		local vec = vectorCache[ vCacheInd ];
		if( not vec )then
			vec = Vector( x, y, z );
			vectorCache[ vCacheInd ] = vec;
		else
			vec.x, vec.y, vec.z = x, y, z;	
		end
		return vec;
	end

	function GM.vecRecyclerRestart( purge )
		vCacheInd = 0;
		if( purge )then
			table.Empty( vectorCache );
		end
	end
end

--
-- TERRAIN GEN MATH.
--
function GM.math_bias( a, b ) -- bias 0-1 and value 0-1
	return b/((1/a-2)*(1-b)+1);
end
function GM.math_gain( g, v )
    local p = (1/g-2)*(1-2*v);
    if (v < 0.5)then
		return v/(p+1)
    else
		return (p-v)/(p-1)
	end
end

function GM.perlin3Dnormalize( val )
	return val / 1.036;
end
function GM.perlin2Dnormalize( val )
	return val / 0.695648;
end