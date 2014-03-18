local root = function( num, deg ) return math.pow( num, 1/deg ) end
local pow = math.pow
local rshift = bit.rshift
local band = bit.band
local floor = math.floor 
local random = math.random
local fmod = math.fmod

local F2 = 0.5 * (pow(3.0,0.5) - 1.0)
local G2 = (3.0 - pow(3.0,0.5)) / 6.0
local F3 = 1.0 / 3.0
local G3 = 1.0 / 6.0
local F4 = (pow(5.0,0.5) - 1.0) / 4.0
local G4 = (5.0 - pow(5.0,0.5)) / 20.0

/*=========================
SIMPLEX META OBJECT
=========================*/
local simplex_mt = {} -- The metatable
local simplex_methods = {} -- Methods for our objects
simplex_mt.__index = simplex_methods

function GM.NewSimplexNoise( rand )
	local new = {}
	setmetatable( new, simplex_mt )
	new:Init( rand ) -- init it and all dem shizzles :)
	return new
end

-- hell of math... you really don't want to EVER try to understand this... trust me... you don't... just don't...
function simplex_methods:Init(random)
    -- variable defaults.
    self.a = 0.4; -- attenuity or roughness.
    self.p = math.pow( 2, 1 ) -- generation depth.

    -- algorithm.
    if (not random )then random = math.random( ) end
    math.randomseed( random );

    self.p = {};
    self.perm = {}
    self.permMod12 = {};
    for i = 0, 256  do
        self.p[i] = math.random(0,256);
    end
    for i = 0, 512 do
        self.perm[i] = self.p[band( i, 255)]
        self.permMod12[i] = fmod( self.perm[i], 12 )
	end
end

function simplex_methods:SetAttenuity( a )
    self.a = a;
    return self;
end
function simplex_methods:SetPermutations( p )
    self.p = math.pow( 2, p );
    return self;
end
function simplex_methods:SetScale( sx, sy, sz )
    self.sx = sx;
    self.sy = sy;
    self.sz = sz;
end

simplex_methods.grad3 = {1, 0,- 1, 1, 0,1, - 1, 0, - 1, - 1, 0,1, 0, 1,- 1, 0, 1,1, 0, - 1,- 1, 0, - 1,0, 1, 1,0, - 1, 1,0, 1, - 1,0, - 1, - 1};
simplex_methods.grad3[ 0 ] = 1
simplex_methods.grad4 = { 1, 1, 1, 0, 1, 1, -1, 0, 1, -1, 1, 0, 1, -1, -1, 0, -1, 1, 1, 0, -1, 1, -1, 0, -1, -1, 1, 0, -1, -1, -1,1, 0, 1, 1, 1, 0, 1, -1, 1, 0, -1, 1, 1, 0, -1, -1,-1, 0, 1, 1, -1, 0, 1, -1, -1, 0, -1, 1, -1, 0, -1, -1,1, 1, 0, 1, 1, 1, 0, -1, 1, -1, 0, 1, 1, -1, 0, -1,-1, 1, 0, 1, -1, 1, 0, -1, -1, -1, 0, 1, -1, -1, 0, -1,1, 1, 1, 0, 1, 1, -1, 0, 1, -1, 1, 0, 1, -1, -1, 0,-1, 1, 1, 0, -1, 1, -1, 0, -1, - 1, 1, 0, -1, -1, -1, 0}
simplex_methods.grad4[ 0 ] = 0

function simplex_methods:noise2D(xin, yin)
        local permMod12 = self.permMod12
        local perm = self.perm
        local grad3 = self.grad3
        local n0,n1,n2 = 0,0,0; // Noise contributions from the three corners
        // Skew the input space to determine which simplex cell we're in
        local s = (xin + yin) * F2; // Hairy factor for 2D
        local i = floor(xin + s);
        local j = floor(yin + s);
        local t = (i + j) * G2;
        local X0 = i - t; // Unskew the cell origin back to (x,y) space
        local Y0 = j - t;
        local x0 = xin - X0; // The x,y distances from the cell origin
        local y0 = yin - Y0;
        // For the 2D case, the simplex shape is an equilateral triangle.
        // Determine which simplex we are in.
        local i1, j1; // Offsets for second (middle) corner of simplex in (i,j) coords
        if (x0 > y0)then
            i1 = 1;
            j1 = 0;
			// lower triangle, XY order: (0,0)->(1,0)->(1,1)
        else
            i1 = 0;
            j1 = 1;
        end // upper triangle, YX order: (0,0)->(0,1)->(1,1)
        // A step of (1,0) in (i,j) means a step of (1-c,-c) in (x,y), and
        // a step of (0,1) in (i,j) means a step of (-c,1-c) in (x,y), where
        // c = (3-sqrt(3))/6
        local x1 = x0 - i1 + G2; // Offsets for middle corner in (x,y) unskewed coords
        local y1 = y0 - j1 + G2;
        local x2 = x0 - 1.0 + 2.0 * G2; // Offsets for last corner in (x,y) unskewed coords
        local y2 = y0 - 1.0 + 2.0 * G2;
        // Work out the hashed gradient indices of the three simplex corners
        local ii = band( i , 255 );
        local jj = band( j , 255 );
        // Calculate the contribution from the three corners
        local t0 = 0.5 - x0 * x0 - y0 * y0;
        if (t0 >= 0) then
            local gi0 = permMod12[ii + perm[jj]] * 3;
            t0 = t0 * t0;
            n0 = t0 * t0 * (grad3[gi0] * x0 + grad3[gi0 + 1] * y0); // (x,y) of grad3 used for 2D gradient
        end
        local t1 = 0.5 - x1 * x1 - y1 * y1;
        if (t1 >= 0) then
            local gi1 = permMod12[ii + i1 + perm[jj + j1]] * 3;
            t1 = t1 * t1;
            n1 = t1 * t1 * (grad3[gi1] * x1 + grad3[gi1 + 1] * y1);
        end
        local t2 = 0.5 - x2 * x2 - y2 * y2;
        if (t2 >= 0) then
            local gi2 = permMod12[ii + 1 + perm[jj + 1]] * 3;
            t2 = t2 * t2;
            n2 = t2 * t2 * (grad3[gi2] * x2 + grad3[gi2 + 1] * y2);
        end
        // Add contributions from each corner to get the final noise value.
        // The result is scaled to return values in the interval [-1,1].
        return 70.0 * (n0 + n1 + n2);
    end
    // 3D simplex noise
function simplex_methods:noise3D(xin, yin, zin)
        local permMod12 = self.permMod12
        local perm = self.perm
		local grad3 = self.grad3
        local n0, n1, n2, n3 = 0, 0, 0, 0 ; // Noise contributions from the four corners
        // Skew the input space to determine which simplex cell we're in
        local s = (xin + yin + zin) * F3; // Very nice and simple skew factor for 3D
        local i = floor(xin + s);
        local j = floor(yin + s);
        local k = floor(zin + s);
        local t = (i + j + k) * G3;
        local X0 = i - t; // Unskew the cell origin back to (x,y,z) space
        local Y0 = j - t;
        local Z0 = k - t;
        local x0 = xin - X0; // The x,y,z distances from the cell origin
        local y0 = yin - Y0;
        local z0 = zin - Z0;
        // For the 3D case, the simplex shape is a slightly irregular tetrahedron.
        // Determine which simplex we are in.
        local i1, j1, k1; // Offsets for second corner of simplex in (i,j,k) coords
        local i2, j2, k2; // Offsets for third corner of simplex in (i,j,k) coords
        if (x0 >= y0) then
            if (y0 >= z0) then
                i1 = 1;
                j1 = 0;
                k1 = 0;
                i2 = 1;
                j2 = 1;
                k2 = 0;
            // X Y Z order
            elseif (x0 >= z0)then
                i1 = 1;
                j1 = 0;
                k1 = 0;
                i2 = 1;
                j2 = 0;
                k2 = 1;
             // X Z Y order
            else
                i1 = 0;
                j1 = 0;
                k1 = 1;
                i2 = 1;
                j2 = 0;
                k2 = 1;
            end // Z X Y order
        else // x0<y0
            if (y0 < z0)then
                i1 = 0;
                j1 = 0;
                k1 = 1;
                i2 = 0;
                j2 = 1;
                k2 = 1;
				// Z Y X order
            elseif (x0 < z0)then
                i1 = 0;
                j1 = 1;
                k1 = 0;
                i2 = 0;
                j2 = 1;
                k2 = 1;
				// Y Z X order
            else
                i1 = 0;
                j1 = 1;
                k1 = 0;
                i2 = 1;
                j2 = 1;
                k2 = 0;
            end // Y X Z order
        end
        // A step of (1,0,0) in (i,j,k) means a step of (1-c,-c,-c) in (x,y,z),
        // a step of (0,1,0) in (i,j,k) means a step of (-c,1-c,-c) in (x,y,z), and
        // a step of (0,0,1) in (i,j,k) means a step of (-c,-c,1-c) in (x,y,z), where
        // c = 1/6.
        local x1 = x0 - i1 + G3; // Offsets for second corner in (x,y,z) coords
        local y1 = y0 - j1 + G3;
        local z1 = z0 - k1 + G3;
        local x2 = x0 - i2 + 2.0 * G3; // Offsets for third corner in (x,y,z) coords
        local y2 = y0 - j2 + 2.0 * G3;
        local z2 = z0 - k2 + 2.0 * G3;
        local x3 = x0 - 1.0 + 3.0 * G3; // Offsets for last corner in (x,y,z) coords
        local y3 = y0 - 1.0 + 3.0 * G3;
        local z3 = z0 - 1.0 + 3.0 * G3;
        // Work out the hashed gradient indices of the four simplex corners
        local ii = band( i, 255 );
        local jj = band( j, 255 );
        local kk = band( k, 255 );
        // Calculate the contribution from the four corners
        local t0 = 0.6 - x0 * x0 - y0 * y0 - z0 * z0;
        if (t0 < 0)then
			n0 = 0.0
        else
            local gi0 = permMod12[ii + perm[jj + perm[kk]]] * 3;
            t0 = t0 * t0;
            n0 = t0 * t0 * (grad3[gi0] * x0 + grad3[gi0 + 1] * y0 + grad3[gi0 + 2] * z0);
        end
		
        local t1 = 0.6 - x1 * x1 - y1 * y1 - z1 * z1;
        if (t1 < 0)then
			n1 = 0.0
        else
            local gi1 = permMod12[ii + i1 + perm[jj + j1 + perm[kk + k1]]] * 3;
            t1 = t1 * t1;
            n1 = t1 * t1 * (grad3[gi1] * x1 + grad3[gi1 + 1] * y1 + grad3[gi1 + 2] * z1);
        end
        local t2 = 0.6 - x2 * x2 - y2 * y2 - z2 * z2;
        if (t2 < 0)then
			n2 = 0.0
        else
            local gi2 = permMod12[ii + i2 + perm[jj + j2 + perm[kk + k2]]] * 3;
            t2 = t2 * t2;
            n2 = t2 * t2 * (grad3[gi2] * x2 + grad3[gi2 + 1] * y2 + grad3[gi2 + 2] * z2);
        end
        local t3 = 0.6 - x3 * x3 - y3 * y3 - z3 * z3;
        if (t3 < 0)then
			n3 = 0.0
        else
            local gi3 = permMod12[ii + 1 + perm[jj + 1 + perm[kk + 1]]] * 3;
            t3 = t3 * t3;
            n3 = t3 * t3 * (grad3[gi3] * x3 + grad3[gi3 + 1] * y3 + grad3[gi3 + 2] * z3);
        end
        // Add contributions from each corner to get the final noise value.
        // The result is scaled to stay just inside [-1,1]
        return 32.0 * (n0 + n1 + n2 + n3);
    end

function simplex_methods:noise3D_adv( x, y, z )
    local p, a = self.p, self.a;

    x, y, z = x*self.sx, y*self.sy, z*self.sz;

	local v, d = 0, 0
	while( p >= 1 )do
		v = v * a + self:noise3D( x*p, y*p, z*p )
		d = d * a + 1
		p = p / 2
	end
	return v/d
end

function simplex_methods:noise2D_adv( x, y )
    local p, a = self.p, self.a;
    x, y = x*self.sx, y*self.sy;

	local v, d = 0, 0
	while( p >= 1 )do
		v = v * a + self:noise2D( x*p, y*p )
		d = d * a + 1
		p = p / 2
	end
	return v/d
end

--
-- NOISE FIELD UTILITIES - pre generate a square or cubic field at a given coordinate.
-- 

-- will need some work.
local function TriLerp( x, y, z, V000, V001, V010, V011, V100, V101, V110, V111 )
    local _x = 1 - x
    local _y = 1 - y
    local _z = 1 - z
    return (((V000*x+V001*_x)*y+(V010*x+_x*V011)*_y)*z + ((V100*x+V101*_x)*y+(V110*x+_x*V111)*_y)*_z )
end

-- will need some work.
local function BiLerp( x, y, V000, V001, V010, V011 )
    local _x = 1 - x
    local _y = 1 - y
    return ((V000*x+V001*_x)*y+(V010*x+_x*V011)*_y)
end
local write3D1D, read3D1D = GAMEMODE.write3D1D, GAMEMODE.read3D1D;
local read2D1D, write2D1D = GAMEMODE.read2D1D, GAMEMODE.write2D1D;

function simplex_methods:noisefield_2Dadv( x, y, size, samples )

    local read2D1D, write2D1D, BiLerp = GAMEMODE.read2D1D, GAMEMODE.write2D1D, BiLerp;

    self.cache = self.cache or {}; 
    local _cache = self._cache or {};
    self._cache = _cache;
    local cache = self.cache;

    local sampFreq = size / samples;

    for sx = 0, samples do
        for sy = 0, samples do
            write2D1D( _cache, samples + 1, sx, sy, self:noise2D_adv( (x + sx * sampFreq), (y + sy * sampFreq)));
        end
    end

    local sizeexcl = size - 1;

    for ox = 0, sizeexcl do
        local XFRAC = 1 - ox / sampFreq % 1;
        local sampX = floor( ox / sampFreq );
        for oy = 0, sizeexcl do
            local sampY = floor( oy / sampFreq );
            local YFRAC = 1 - oy / sampFreq % 1;
            write2D1D( cache, size, ox, oy, BiLerp( XFRAC, YFRAC, read2D1D( _cache, samples + 1, sampX, sampY ),
                                                                  read2D1D( _cache, samples + 1, sampX + 1, sampY ),
                                                                  read2D1D( _cache, samples + 1, sampX, sampY + 1 ),
                                                                  read2D1D( _cache, samples + 1, sampX + 1, sampY + 1 ) ));
        end
    end
    return cache;
end

function simplex_methods:noisefield_3Dadv( x, y, z, size, samples, cache )
    local write3D1D, read3D1D, TriLerp = GAMEMODE.write3D1D, GAMEMODE.read3D1D, TriLerp;

    
    local _cache = self._cache or {};
    self._cache = _cache;

    self.cache = self.cache or {};
    local cache = cache or self.cache;

    local sampFreq = size / samples;

    for sx = 0, samples do
        for sy = 0, samples do
            for sz = 0, samples do
                write3D1D( _cache, samples + 1, sx, sy, sz, self:noise3D_adv( (x + sx * sampFreq), (y + sy * sampFreq), (z + sz * sampFreq)));
            end
        end
    end

    samples = samples + 1;
    local sizeexcl = size - 1;

    for ox = 0, sizeexcl do
        local XFRAC = 1 - ox / sampFreq % 1;
        local X0 = floor( ox / sampFreq );
        local X1 = X0 + 1; 

        for oy = 0, sizeexcl do
            local Y0 = floor( oy / sampFreq );
            local Y1 = Y0 + 1; 
            local YFRAC = 1 - oy / sampFreq % 1;

            for oz = 0, sizeexcl do
                local Z0 = floor( oz / sampFreq );
                local Z1 = Z0 + 1;
                local ZFRAC = 1 - oz / sampFreq % 1;
                write3D1D( cache, size, ox, oy, oz, TriLerp( XFRAC, YFRAC, ZFRAC, read3D1D( _cache, samples, X0,Y0,Z0 ), 
                                                                          read3D1D( _cache, samples, X1,Y0,Z0 ),
                                                                          read3D1D( _cache, samples, X0,Y1,Z0 ),
                                                                          read3D1D( _cache, samples, X1,Y1,Z0 ),
                                                                          read3D1D( _cache, samples, X0,Y0,Z1 ),
                                                                          read3D1D( _cache, samples, X1,Y0,Z1 ),
                                                                          read3D1D( _cache, samples, X0,Y1,Z1 ),
                                                                          read3D1D( _cache, samples, X1,Y1,Z1 ) ) ); 
            end
        end
    end

    return cache;
end

function simplex_methods:noisefield_get3D( size, x, y, z, cache )
    return read3D1D( cache or self.cache, size, x, y, z ); 
end
function simplex_methods:noisefield_get2D( size, x, y, cache )
    return read2D1D( cache or self.cache, size, x, y );
end


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