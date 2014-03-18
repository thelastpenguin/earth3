local chunk_size = GM.cfg.chunk_size;

local mt = {};
mt.__index = mt;

local function tblCreateWithVal( v )
	return { v, v, v, v, v, v, v, v };
end

local function tblGetValue( oct, size, x, y, z )
	-- 3D to 1D.
	local hs = size * 0.5;
	--local index = z < hs and ( y < hs and ( x < hs and ( 1 ) or ( 2 ) ) or ( x < hs and ( 3 ) or ( 4 ) ) ) or ( y < hs and ( x < hs and ( 5 ) or ( 6 )  ) or ( x < hs and ( 7 ) or ( 8 )  )  ) 

	--local index = ( z < hs and 0 or 4 ) + ( y < hs and 0 or 2 ) + ( x < hs and 1 or 2 );
	local index = z < hs and ( y < hs and ( x < hs and ( 1 ) or ( 2 ) ) or ( x < hs and ( 3 ) or ( 4 ) ) ) or ( y < hs and ( x < hs and ( 5 ) or ( 6 )  ) or ( x < hs and ( 7 ) or ( 8 )  )  ) 

	
	-- indexing.
	local val = oct[ index ];
	if( type( val ) == 'table' )then
		return tblGetValue( val, hs, x % hs, y % hs, z % hs ); 
	else
		return val; 
	end
end

local function tblInsertValue( oct, size, x, y, z, add )
	if( size == 1 )then
		return add;
	end

	-- 3D to 1D.
	local hs = size * 0.5;
	local index = z < hs and ( y < hs and ( x < hs and ( 1 ) or ( 2 ) ) or ( x < hs and ( 3 ) or ( 4 ) ) ) or ( y < hs and ( x < hs and ( 5 ) or ( 6 )  ) or ( x < hs and ( 7 ) or ( 8 )  )  ) 

	-- indexing.
	local val = oct[ index ];
	if( type( val ) == 'table' )then
		local ret = tblInsertValue( val, hs, x % hs, y % hs, z % hs, add );
		if( ret )then
			oct[ index ] = ret;
		end
	else
		if( val == add )then
			return ; -- we don't need to do a thing.
		else
			local newOct = tblCreateWithVal( val );
			oct[ index ] = newOct;
			local ret = tblInsertValue( newOct, hs, x % hs, y % hs, z % hs, add );
			if( ret )then
				oct[ index ] = ret;
			end
		end
	end

	if( oct[1]==add and oct[2]==add and oct[3]==add and oct[4]==add and oct[5]==add and oct[6]==add and oct[7]==add and oct[8]==add )then
		return add;
	end
end

function GM.NewOct( val )
	return tblCreateWithVal( val or 0 ) -- guess how many... ( 8 ) suprise suprise.
end

function GM.OctGetVal( oct, size, x, y, z )
	return tblGetValue( oct, size, x, y, z );
end

function GM.OctSetVal( oct, size, x, y, z, val )
	tblInsertValue( oct, size, x, y, z, val );
end