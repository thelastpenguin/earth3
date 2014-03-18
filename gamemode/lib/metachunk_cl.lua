--
-- CLIENT CHUNK RENDERING UTILITES
-- 
local mt = GM.GetChunkMT( );

local rVector = GM.recycledVec; -- no wasting vectors here! nope nope nope!
local read3D1D = GM.read3D1D;
local blockScale = GM.cfg.blockScale;
local renderScale = GM.cfg.renderScale;

--
-- MESH OPTIMIZATIONS FOR INSERTING VERTEX STRUCTURES.
--
local mesh_GetTable;
local mesh_ResetAll;
local mesh_GetSize;
local mesh_UpdateSize;
local mesh_GetAll;
do
	local meshes = {};
	local meshSizes = {};
	function mesh_GetTable( key )
		local m = meshes[ key ];
		if( not m )then
			m = {};
			meshes[ key ] = m;
			meshSizes[ m ] = 0;
		end
		return m, meshSizes[ m ];
	end

	function mesh_GetAll( )
		return meshes;
	end

	function mesh_GetTrueSize( tbl )
		return meshSizes[ tbl ];
	end
	function mesh_UpdateSize( tbl, s )
		if( s )then
			meshSizes[ tbl ] = s;
		else
			meshSizes[ tbl ] = #tbl;
		end
	end

	function mesh_ResetAll( )
		for _,m in pairs( meshes )do
			for k,v in pairs( m )do
				m[ k ] = nil;
			end
			meshSizes[ m ] = 0;
		end
	end
end

--
-- WORKING WITH BLOCKS
--
local chunk_Load;
local block_Get;
local block_GetEx;
do
	local read3D1D = read3D1D;

	local bCache = {};
	

	local cTop, cBottom, cFront, cBack, cRight, cLeft;
	local cx, cy, cz;
	local size, eSize;

	function chunk_Load( chunk )
		cx, cy, cz = chunk:GetPos( );
		size = chunk:GetSize();
		eSize = size - 1;

		chunk:UnpackToRawTable( bCache );

		cTop = GAMEMODE:GetChunk( cx, cy, cz+1 );
		cBottom = GAMEMODE:GetChunk( cx, cy, cz-1 );
		cFront = GAMEMODE:GetChunk( cx, cy+1, cz );
		cBack = GAMEMODE:GetChunk( cx, cy-1, cz );
		cRight = GAMEMODE:GetChunk( cx+1, cy, cz );
		cLeft = GAMEMODE:GetChunk( cx-1, cy, cz );
	end

	function block_Get( x, y, z )
		return read3D1D( bCache, size, x, y, z );
	end

	function block_GetEx( x, y, z )
		if( x < 0 )then -- left chunk.
			return ValidChunk( cLeft ) and cLeft:StatusReady() and cLeft:GetBlock( size + x, y, z );
		elseif( x > eSize )then -- right chunk.
			return ValidChunk( cRight ) and cRight:StatusReady() and cRight:GetBlock( x - size, y, z );
		elseif( y < 0 )then -- back chunk.
			return ValidChunk( cBack ) and cBack:StatusReady() and cBack:GetBlock( x, size + y, z );
		elseif( y > eSize )then -- front chunk.
			return ValidChunk( cFront ) and cFront:StatusReady() and cFront:GetBlock( x, y - size, z );
		elseif( z < 0 )then -- bottom chunk.
			return ValidChunk( cBottom ) and cBottom:StatusReady() and cBottom:GetBlock( x, y, size + z );
		elseif( z > eSize )then -- top chunk.
			return ValidChunk( cTop ) and cTop:StatusReady() and cTop:GetBlock( x, y, z - size );
		end

		return read3D1D( bCache, size, x, y, z );
	end
end


--
-- ACTUALLY BUILD IT INTO THE MESH.
--
local block_Add;
do
	local bTypes = GAMEMODE.blocks;
	local mesh_GetTable = mesh_GetTable;
	local mesh_UpdateSize = mesh_UpdateSize;

	local block_GetEx = block_GetEx;

	function block_Add( blockid, x, y, z )
		if( not blockid or blockid == 0 )then return end
		local bMeta = bTypes[ blockid ];
		if( not bMeta )then return end
		local tex = bMeta:GetTexture( );

		local cmesh, size = mesh_GetTable( tex );

		-- insert vertices where visible. If structure handles occlusion.
		if( block_GetEx( x, y, z + 1 ) == 0 )then -- air above us?
			size = bMeta:Mesh_InsertTop( cmesh, size, x, y, z )
		end
		if( block_GetEx( x, y, z - 1 ) == 0 )then -- air below us?
			size = bMeta:Mesh_InsertBottom( cmesh, size, x, y, z )
		end
		if( block_GetEx( x, y + 1, z ) == 0 )then -- air infront of us?
			size = bMeta:Mesh_InsertFront( cmesh, size, x, y, z )
		end
		if( block_GetEx( x, y - 1, z) == 0 )then -- air behind us?
			size = bMeta:Mesh_InsertBack( cmesh, size, x, y, z )
		end
		if( block_GetEx( x + 1, y, z ) == 0 )then -- air to our right?
			size = bMeta:Mesh_InsertRight( cmesh, size, x, y, z )
		end
		if( block_GetEx( x - 1, y, z ) == 0 )then -- air to our left?
			size = bMeta:Mesh_InsertLeft( cmesh, size, x, y, z )
		end

		mesh_UpdateSize( cmesh, size );
	end
end

function mt:BuildRenderMesh( )
	
	-- prepare commonly used values.
	local size = self:GetSize();
	local eSize = size - 1;

	-- clear data from last render.
	mesh_ResetAll( );

	-- setup working chunk data.
	chunk_Load( self );

	-- since parts of the algorithm use it...
	GAMEMODE.vecRecyclerRestart( ) -- restart the vector recycler.

	--
	-- BUILD BLOCK TRIANGLE TABLES.
	--
	local tStart = SysTime();
	do
		local block_Add, size = block_Add, size;
		local block_Get, block_GetEx = block_Get, block_GetEx;

		-- core blocks.
		for x = 0, eSize do
			for y = 0, eSize do
				for z = 0, eSize do
					block_Add( block_Get( x, y, z ), x, y, z );
				end
			end
		end

		-- top / bottom.
		for x = 0, eSize do
			for y = 0, eSize do
				block_Add( block_GetEx( x, y, -1 ), x, y, -1 );
				block_Add( block_GetEx( x, y, size ), x, y, size );
			end
		end

		-- left / right.
		for y = 0, eSize do
			for z = 0, eSize do
				block_Add( block_GetEx( -1, y, z ), -1, y, z );
				block_Add( block_GetEx( size, y, z ), size, y, z );
			end
		end

		-- front / back.
		for x = 0, eSize do
			for z = 0, eSize do
				block_Add( block_GetEx( x, -1, z ), x, -1, z );
				block_Add( block_GetEx( x, size, z ), x, size, z );
			end
		end


	end
	local tTriangles = SysTime();

	--
	-- CONVERT MESH TABLES INTO RENDERABLE MESHES.
	--
	local rMesh = {};
	for tex, verts in pairs( mesh_GetAll( ))do
		if( #verts == 0 or #verts % 3 ~= 0 )then continue end
		local obj = Mesh();
		obj:BuildFromTriangles( verts );
		rMesh[ tex ] = obj;
	end

	local tMeshes = SysTime();

	self.rMesh = rMesh;

	-- CLEANUP TIME.
	GAMEMODE.vecRecyclerRestart( ) -- restart the vector recycler.

	--print('[PMC] RENDER MESH '..( SysTime() - tStart )..' SECS. ( '..( size*size*size / ( SysTime() - tStart ) )..' bps)');
end

function mt:SetDrawTransform( pos )
	local mat = Matrix();
	mat:Translate( pos*renderScale );
	mat:Rotate(Angle(0,0,0));
	mat:Scale( Vector( 1, 1, 1 ) * renderScale );

	self.rMatrix = mat
end

local MAT_DEBUG = Material( 'phoenix_storms/wire/pcb_red' )
function mt:Draw( )
	cam.PushModelMatrix( self.rMatrix );
	--render.SetMaterial( MAT_DEBUG );
	--render.DrawSphere( Vector(0,0,0), 1, 5, 5, Color( 255, 0, 0 ) );

	render.SuppressEngineLighting( true );
	render.SetLightingOrigin( Vector( 0, 0, 100 ) )
	render.SetModelLighting( BOX_FRONT, 0.5, 0.5, 0.5 );
	render.SetModelLighting( BOX_TOP, 0.5, 0.5, 0.5 );

	for mat,mesh in pairs( self.rMesh )do
		render.SetMaterial( mat )
		mesh:Draw();
	end

	render.SuppressEngineLighting( false );

	cam.PopModelMatrix();
end







--[[
local MAT_DEBUG = Material( 'phoenix_storms/wire/pcb_red' )
local function DrawDatMesh( offset, meshtbl ) -- MC.GridOrigin
	local scale = 20;
	mat = Matrix();
	mat:Translate( offset );
	mat:Rotate(Angle(0,0,0));
	mat:Scale( Vector( 1, 1, 1 ) * MC.BlockSize );
	
	
	cam.PushModelMatrix ( mat ); -- apply transformation matrix.
	/*render.SetMaterial( MAT_DEBUG ) -- draw spheres for testing.
	render.DrawSphere( Vector(0,0,0), 1, 20, 20, Color( 255, 0, 0 ) )*/
	for mat,mesh in pairs( meshtbl )do
		render.SetMaterial( mat )
		mesh:Draw();
	end
	cam.PopModelMatrix();
end
]]