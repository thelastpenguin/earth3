/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */



local read3D1D = GM.read3D1D;
local write3D1D = GM.write3D1D;

do
	local function initFromRaw( raw, X0, Y0, Z0, size, fullsize )
		if( size == 1 )then
			return read3D1D( raw, fullsize, X0, Y0, Z0 );
		end

		local hs = size * 0.5 -- hs... our favorite.
		local X1, Y1, Z1 = X0 + hs, Y0 + hs, Z0 + hs;


		local H000 = initFromRaw( raw, X0, Y0, Z0, hs, fullsize );
		local H001 = initFromRaw( raw, X1, Y0, Z0, hs, fullsize );
		local H010 = initFromRaw( raw, X0, Y1, Z0, hs, fullsize );
		local H011 = initFromRaw( raw, X1, Y1, Z0, hs, fullsize );

		local H100 = initFromRaw( raw, X0, Y0, Z1, hs, fullsize );
		local H101 = initFromRaw( raw, X1, Y0, Z1, hs, fullsize );
		local H110 = initFromRaw( raw, X0, Y1, Z1, hs, fullsize );
		local H111 = initFromRaw( raw, X1, Y1, Z1, hs, fullsize );

		if( H000 == H001 and H000 == H010 and H000 == H011 and H000 == H100 and H000 == H101 and H000 == H110 and H000 == H111 )then
			return H000;
		else
			return { H000, H001, H010, H011, H100, H101, H110, H111 };
		end
	end

	local function expandToRaw( raw, oct, topSize, curSize, X0, Y0, Z0 )
		if( curSize == 1 )then
			write3D1D( raw, topSize, X0, Y0, Z0, oct );
			return ;
		end
		local hs = curSize * 0.5;
		local X1, Y1, Z1 = X0 + hs, Y0 + hs, Z0 + hs;

		if( type( oct ) == 'number' )then
			--print("NUMBER!",X0,X1,Y0,Y1,Z0,Z1);
			local write3D1D = write3D1D;
			local X1, Y1, Z1 = X0+curSize-1,Y0+curSize-1, Z0+curSize-1;
			for x = X0, X1 do
				for y = Y0, Y1 do
					for z = Z0, Z1 do
						write3D1D( raw, topSize, x, y, z, oct );
					end
				end
			end
		else
			expandToRaw( raw, oct[1], topSize, hs, X0, Y0, Z0, hs );
			expandToRaw( raw, oct[2], topSize, hs, X1, Y0, Z0, hs );
			expandToRaw( raw, oct[3], topSize, hs, X0, Y1, Z0, hs );
			expandToRaw( raw, oct[4], topSize, hs, X1, Y1, Z0, hs );

			expandToRaw( raw, oct[5], topSize, hs, X0, Y0, Z1, hs );
			expandToRaw( raw, oct[6], topSize, hs, X1, Y0, Z1, hs );
			expandToRaw( raw, oct[7], topSize, hs, X0, Y1, Z1, hs );
			expandToRaw( raw, oct[8], topSize, hs, X1, Y1, Z1, hs );
		end
	end





	function GM.OctExpandToRaw( size, oct, raw )
		expandToRaw( raw, oct, size, size, 0, 0, 0 );
		return raw;
	end

	function GM.NewOctFromRaw( raw, size )
		local hs = size * 0.5 -- hs... our favorite.
		
		local X0, Y0, Z0 = 0, 0, 0;
		local X1, Y1, Z1 = X0 + hs, Y0 + hs, Z0 + hs;


		local H000 = initFromRaw( raw, X0, Y0, Z0, hs, size );
		local H001 = initFromRaw( raw, X1, Y0, Z0, hs, size );
		local H010 = initFromRaw( raw, X0, Y1, Z0, hs, size );
		local H011 = initFromRaw( raw, X1, Y1, Z0, hs, size );

		local H100 = initFromRaw( raw, X0, Y0, Z1, hs, size );
		local H101 = initFromRaw( raw, X1, Y0, Z1, hs, size );
		local H110 = initFromRaw( raw, X0, Y1, Z1, hs, size );
		local H111 = initFromRaw( raw, X1, Y1, Z1, hs, size );

		return { H000, H001, H010, H011, H100, H101, H110, H111 };
	end
end

do
	local blob = GAMEMODE.NewDataBlob( );
	local lshift = bit.lshift;
	local rshift = bit.rshift;
	local band = bit.band;
	local bor = bit.bor;

	local function OctToString( value )
		if( type( value ) == 'number' )then
			blob:WriteInt( bor( lshift( value, 1 ), 1 ), 2 );
		else
			blob:WriteInt( 0, 1 );
			OctToString( value[1] );
			OctToString( value[2] );
			OctToString( value[3] );
			OctToString( value[4] );
			OctToString( value[5] );
			OctToString( value[6] );
			OctToString( value[7] );
			OctToString( value[8] );
		end
	end

	function GM.OctToString( oct )
		blob:StartWrite( );
		OctToString( oct );
		return blob:FinishWrite( );
	end

	local function StringToOct( )
		if( band( blob:ReadInt( 1 ), 1 ) == 1 )then
			blob:StepBack( 1 );
			return rshift( blob:ReadInt( 2 ), 1 );
		else
			return {
				StringToOct( ),
				StringToOct( ),
				StringToOct( ),
				StringToOct( ),
				StringToOct( ),
				StringToOct( ),
				StringToOct( ),
				StringToOct( )
			}
		end
	end

	function GM.OctFromString( str )
		blob:StartRead( str );
		return StringToOct( );
	end
end