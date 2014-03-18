/*
 * This file is subject to the terms and conditions defined in
 * file 'LICENSE.txt', which is part of this source code package.
 * removing or modifying this header is a violation of the terms 
 * and conditions defined in 'LICENSE.txt'
 */
 
local mt = {};
mt.__index = mt;

function GM.NewDataBlob( )
	local n = {};
	setmetatable( n, mt );
	return n;
end

local lshift = bit.lshift;
local rshift = bit.rshift;
local bor = bit.bor;
local bnot = bit.bnot;
local band = bit.band;
local table = table;

local char = string.char;
local charToByte = string.byte;
local insert = table.insert;

local byteMask = 0xff;

--
-- WRITE
--

function mt:StartWrite( )
	self.res = {};
end

function mt:FinishWrite( )
	local final = table.concat( self.res );
	table.Empty( self.res );
	return final;
end

function mt:WriteInt( val, bytes )
	local res = self.res;
	for i = 1, bytes do
		insert( res, char( band( val, byteMask )) );
		val = rshift( val, 8 );
	end
end

--
-- READ
--
function mt:StartRead( data )
	self.data = data;
	self.index = 1;
end

function mt:ReadInt( bytes )
	local val = 0;
	local index = self.index;
	local data = self.data;
	for i = 0, bytes - 1 do
		local cChar = charToByte( data[ index + i ] );
		val = bor( val, lshift( cChar, i * 8 ))
	end
	self.index = self.index + bytes;
	return val;
end

function mt:StepBack( step )
	self.index = self.index - step
end

function mt:FinishRead( )
	return self.res;
end