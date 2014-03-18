-- cache vars we use alot.
local GM, cfg, math = GM, GM.cfg, math;

local oct_setVal = GM.OctSetVal;
local oct_getVal = GM.OctGetVal;
local oct_new = GM.NewOct


local mt = {}
mt.__index = mt;

--
-- INITALIZATION
--
function mt:InitBase( val )
	self:SetSize( cfg.chunk_size );

	self.o = oct_new( val or 0 ) -- init oct.

	return self;
end

function mt:InitFromString( str )
	-- set our size.
	self:SetSize( cfg.chunk_size );

	-- init our oct table.
	self.o = GM.OctFromString( str );
end

function mt:InitFromRawTable( tbl ) -- a raw table representing a 3D chunk.
	-- set our size.
	self:SetSize( cfg.chunk_size );

	-- init our oct table.
	self.o = GM.NewOctFromRaw( tbl, self:GetSize( ) );
end


--
-- SETTERS
--
local STATUS_PENDING = STATUS_PENDING;
local STATUS_READY = STATUS_READY;
local STATUS_INVALID = STATUS_INVALID;

function mt:SetStatus( status )
	self.status = status;
end

function mt:GetStatus( status )
	return self.status;
end

function mt:StatusPending(  )
	return self.status == STATUS_PENDING;
end

function mt:StatusReady( )
	return self.status == STATUS_READY
end

function mt:StatusInvalid( )
	return self.status == STATUS_INVALID;
end



--
-- UTILITIES
--
function mt:UnpackToRawTable( tbl )
	tbl = tbl or {};
	GM.OctExpandToRaw( self:GetSize(), self.o, tbl );
	return tbl;
end

--
-- USING THESE SHOULD BE AVOIDED. GENERALLY OPERATIONS SHOULD BE DONE EN-MASS BY LOADING CHUNKS WITH UNPACK TO RAW TABLE.
--
function mt:SetPos( x, y, z ) -- offset position accounting for chunk size etc.
	self.x = x;
	self.y = y;
	self.z = z;
	return self;
end
function mt:GetPos( )
	return self.x, self.y, self.z;
end


function mt:SetSize( size )
	self.s = size;
	return self;
end
function mt:GetSize( )
	return self.s;
end

function mt:SetBlock( x, y, z, val )
	oct_setVal( self.o, self.s, x, y, z, val );
end
function mt:GetBlock( x, y, z )
	return oct_getVal( self.o, self.s, x, y, z );
end

function mt:SetAccessStamp( )
	self.access = SysTime( );
end

function mt:GetAccessStamp( )
	return self.access;
end

function mt:GetTimeSinceAccess( )
	return SysTime() - self.access;
end

function mt:Destroy( )
	table.Empty( self );
	self.invalidChunk = true;
end

function mt:ToString( )
	return GAMEMODE.OctToString( self.o );
end

function ValidChunk( tbl )
	if( not tbl )then return false else return true end
end

--
-- LASTLY LETS MAKE ONE
--
function GM.NewChunk( )
	local new = {};
	setmetatable( new, mt );
	return new;
end

function GM.GetChunkMT( )
	return mt;
end