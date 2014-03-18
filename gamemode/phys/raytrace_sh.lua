/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */

local GAMEMODE = GAMEMODE;

local function checkSolid( x, y, z )
	local block = GAMEMODE:GetBlock( x, y, z );
	if( block == 0 )then
		return false
	else
		return true, blockid
	end
end

local function traceBetweenPoints( pStart, pFinish, tRes )
	// NOTES:
	// * This code assumes that the ray's position and direction are in 'cell coordinates', which means
	//   that one unit equals one cell in all directions.
	// * When the ray doesn't start within the voxel grid, calculate the first position at which the
	//   ray could enter the grid. If it never enters the grid, there is nothing more to do here.
	// * Also, it is important to test when the ray exits the voxel grid when the grid isn't infinite.
	// * The Point3D structure is a simple structure having three integer fields (X, Y and Z).

	local dir = pFinish - pStart;

	// The cell in which the ray starts
	local x, y, z = math.floor( pStart.x ), math.floor( pStart.y ), math.floor( pStart.z )
	local sx, sy, sz = x, y, z;

	// The cell in which the ray finishes.
	local fx, fy, fz = math.floor( pFinish.x ), math.floor( pFinish.y ), math.floor( pFinish.z );

	// Determine which way we go.
	local stepX = dir.x == 0 and 0 or dir.x / math.abs( dir.x );
	local stepY = dir.y == 0 and 0 or dir.y / math.abs( dir.y );
	local stepZ = dir.z == 0 and 0 or dir.z / math.abs( dir.z );

	// Calculate cell boundaries. When the step (i.e. direction sign) is positive,
	// the next boundary is AFTER our current position, meaning that we have to add 1.
	// Otherwise, it is BEFORE our current position, in which case we add nothing.

	local cellBoundary = Vector( 
			x + ( stepX > 0 and 1 or 0),
			y + ( stepY > 0 and 1 or 0),
			z + ( stepZ > 0 and 1 or 0)
		)
	tRes.cellBoundary = cellBoundary;

	// NOTE: For the following calculations, the result will be Single.PositiveInfinity
	// when ray.Direction.X, Y or Z equals zero, which is OK. However, when the left-hand
	// value of the division also equals zero, the result is Single.NaN, which is not OK.

	// Determine how far we can travel along the ray before we hit a voxel boundary.
	local tMax = Vector( 
			dir.x == 0 and math.huge or (( cellBoundary.x - pStart.x ) / dir.x), -- boundary is a plane on the XY axis
			dir.y == 0 and math.huge or (( cellBoundary.y - pStart.y ) / dir.y), -- boundary is a plane on the YZ axis
			dir.z == 0 and math.huge or (( cellBoundary.z - pStart.z ) / dir.z)  -- boundary is a plane on the YZ axis;
		)
	tRes.stMax = Vector( tMax.x, tMax.y, tMax.z );

	local tDelta = Vector( 
			math.abs( stepX / dir.x ),
			math.abs( stepY / dir.y ),
			math.abs( stepZ / dir.z )
		)
	if( tDelta.x ~= tDelta.x )then tDelta.x = math.huge end
	if( tDelta.y ~= tDelta.y )then tDelta.y = math.huge end
	if( tDelta.z ~= tDelta.z )then tDelta.z = math.huge end

	local GAMEMODE = GAMEMODE;

	local function checkBlock( x, y, z)
		local isSolid, blockid = checkSolid( x, y, z )
		if( isSolid )then
			tRes.hit = true;
			tRes.hitBlock = blockid;
			tRes.stepRaw = Vector( stepX, stepY, stepZ );
			-- determine our T value.
			local t = nil;
			if( tMax.x < tMax.y and tMax.x < tMax.z )then
				if( stepX < 0 )then
					t = ( x - sx + 1 ) / dir.x
				else
					t = ( x - sx ) / dir.x
				end
				tRes.step = Vector( stepX, 0, 0 );
			elseif( tMax.y < tMax.z )then
				if( stepY < 0 )then
					t = ( y - sy + 1 ) / dir.y
				else
					t = ( y - sy ) / dir.y
				end
				tRes.step = Vector( 0, stepY, 0 );
			else
				if( stepZ < 0 )then
					t = ( z - sz + 1 ) / dir.z
				else
					t = ( z - sz ) / dir.z
				end
				tRes.step = Vector( 0, 0, stepZ );
			end
			tRes.fraction = t;
			tRes.HitPos = pStart + t*dir;
			tRes.x = x;
			tRes.y = y;
			tRes.z = z;
			tRes.tMax = tMax;
			tRes.tDelta = tDelta;
			tRes.dir = dir;
			tRes.pStart = pStart;
			tRes.pFinish = pFinish;
			return tRes;
		end
	end

	local limit = 200
	local isSolid, block = checkSolid( x, y, z );
	if( isSolid )then
		
		tRes.hit = true;
		tRes.fraction = 0;
		tRes.hitBlock = block;

		if( tMax.x < tMax.y and tMax.x < tMax.z )then
			tRes.step = Vector( stepX, 0, 0 );
		elseif( tMax.y < tMax.z )then
			tRes.step = Vector( 0, stepY, 0 );
		else
			tRes.step = Vector( 0, 0, stepZ );
		end

	else
		
		while( ( x ~= fx or y ~= fy or z ~= fz ) and limit > 0 )do
			limit = limit - 1;

			if( tMax.x < tMax.y and tMax.x < tMax.z )then
				x = x + stepX;
				
				-- CHECK FOR COLLISION.
				local isSolid, block = checkSolid( x, y, z );
				if( isSolid )then
					tRes.hitBlock = block;
					tRes.hit = true;
					if( stepX < 0 )then
						tRes.fraction = ( x - sx + 1 ) / dir.x
					else
						tRes.fraction = ( x - sx - 1) / dir.x
					end
					tRes.step = Vector( stepX, 0, 0 );
					break ;
				end

				-- UPDATE tMax.
				tMax.x = tMax.x + tDelta.x;
			elseif( tMax.y < tMax.z )then
				y = y + stepY;

				-- CHECK FOR COLLISION.
				local isSolid, block = checkSolid( x, y, z );
				if( isSolid )then
					tRes.block = block;
					tRes.hit = true;
					if( stepY < 0 )then
						tRes.offsetted = true;
						tRes.fraction = ( y - sy + 1 ) / dir.y
					else
						tRes.fraction = ( y - sy - 1 ) / dir.y
					end
					tRes.step = Vector( 0, stepY, 0 );
					break ;
				end

				-- UPDATE tMax.
				tMax.y = tMax.y + tDelta.y;
			else
				z = z + stepZ;

				-- CHECK FOR COLLISION.
				local isSolid, block = checkSolid( x, y, z );
				if( isSolid )then
					tRes.block = block;
					tRes.hit = true;
					if( stepZ < 0 )then
						tRes.offsetted = true;
						tRes.fraction = ( z - sz + 1 ) / dir.z
					else
						tRes.fraction = ( z - sz - 1) / dir.z
					end
					tRes.step = Vector( 0, 0, stepZ );
					break ;
				end

				-- UPDATE tMax.
				tMax.z = tMax.z + tDelta.z;
			end
		end

	end
	tRes.start = pStart;
	tRes.finish = pFinish;
	tRes.hx = x;
	tRes.hy = y;
	tRes.hz = z;
	tRes.dir = dir;
	tRes.rStep = Vector( stepX, stepY, stepZ );
	tRes.tMax = tMax;
	tRes.tDelta = tDelta;

	if( not tRes.hit )then
		tRes.hit = false;
		tRes.fraction = 1;	
	end

	tRes.HitPos = pStart + tRes.fraction*dir;
	
	if( tRes.step )then
		local step = tRes.step;
		if( step.x ~= 0 )then
			tRes.HitPos.x = math.Round( tRes.HitPos.x );
		elseif( step.y ~= 0 )then
			tRes.HitPos.y = math.Round( tRes.HitPos.y );
		elseif( step.z ~= 0 )then
			tRes.HitPos.z = math.Round( tRes.HitPos.z );
		end
	end

	return tRes;
end




function GAMEMODE:TraceLine( start, finish )
	return traceBetweenPoints( start, finish, {});
end
