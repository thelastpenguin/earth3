--
-- SETTINGS
--
local hMax = 80;
local hMin = 0;
local hSea = 0;
local hRange = hMax-hMin;

--
-- LOAD AND CACHE CONFIGURATION VARIABLES
--
local chunkSize = GM.cfg.chunk_size;
local read3D1D = GM.read3D1D;
local write3D1D = GM.write3D1D;
local read2D1D = GM.read2D1D;
local write2D1D = GM.write2D1D;
--
-- GENERATE SIMPLEX NOISE GENERATORS
-- 
local ng_density = GM.NewSimplexNoise( );
ng_density:SetAttenuity( 0.4 );
ng_density:SetPermutations( 4 );
ng_density:SetScale( 1/100, 1/100, 1/100 );

local ng_height = GM.NewSimplexNoise( );
ng_height:SetScale( 1/1000, 1/1000, 1/1000 );
ng_height:SetAttenuity( 0.2 );
ng_height:SetPermutations( 4 );

local ng_height2 = GM.NewSimplexNoise( );
ng_height2:SetScale( 1/100, 1/100, 1/100 );
ng_height2:SetAttenuity( 0.5 );
ng_height2:SetPermutations( 5 );

local math_bias = GM.math_bias;
local math_gain = GM.math_gain;



-- terrain generator.
function GM:TG_GenerateChunk( cx, cy, cz, res )
	-- PRE PROCESSING CALCULATIONS
	local bx, by, bz = self.pos_chunkToBlock( cx, cy, cz );
	local size = chunkSize;
	local eSize = chunkSize - 1;

	-- CACHE FUNCTIONS.
	local read3D1D, write3D1D = read3D1D, write3D1D;
	local read2D1D, write3D1D = read2D1D, write3D1D;

	-- CALCULATE DENSITY.
	local heightMap = ng_height:noisefield_2Dadv( bx, by, chunkSize, 4 );
	local heightMap2 = ng_height2:noisefield_2Dadv( bx, by, chunkSize, 2 );
	local densityMap = ng_density:noisefield_3Dadv( bx, by, bz, chunkSize, 4 );

	for x = 0, eSize do
		local rx = x + bx;
		for y = 0, eSize do
			local ry = y + by;
			local hMult = (read2D1D( heightMap2, size, x, y )*read2D1D( heightMap, size, x, y )*0.5+0.5)*2;
			local height = hMin + hMult * hRange;
			for z = 0, eSize do
				local rz = z + bz;

				local thresh = math_gain( 0.6, rz/height*0.5 ) * 2;
				local density = read3D1D( densityMap, size, x, y, z )*0.5+0.5;

				local hDif = rz - height;
				if( density >= thresh )then
					write3D1D( res, size, x, y, z, 3 );
				else
					write3D1D( res, size, x, y, z, 0 );
				end
			end
		end
	end

	return res;
end

-- COOL SNIPPITS
--[[
	PILERS: 
	local hMult = read2D1D( heightMap, size, x, y )*math_gain( 0.7, read2D1D( heightMap2, size, x, y ))*0.5+0.5;
	
	HILLS:
	for x = 0, eSize do
		local rx = x + bx;
		for y = 0, eSize do
			local ry = y + by;
			local hMult = (read2D1D( heightMap2, size, x, y )*read2D1D( heightMap, size, x, y )*0.5+0.5)*2;
			local height = hMin + hMult * hRange;
			for z = 0, eSize do
				local rz = z + bz;

				local thresh = rz/height*0.5
				local density = read3D1D( densityMap, size, x, y, z )*0.5+0.5;

				local hDif = rz - height;
				if( density >= thresh )then
					write3D1D( res, size, x, y, z, 3 );
				else
					write3D1D( res, size, x, y, z, 0 );
				end
			end
		end
	end
]]