ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "PMC-Phys"
ENT.Author = "TheLastPenguin"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 1, "player")
end

function ENT:SetupPhysicsProperties( )
	self:EnableCustomCollisions( )
	self:GetPhysicsObject():EnableMotion( false )
	self:GetPhysicsObject():SetMass(500)
	self:SetMoveType(MOVETYPE_PUSH)
	self:SetSolid(SOLID_VPHYSICS)
	
	self:SetCustomCollisionCheck(true)
end

local radius = 5;
local blockScale = GAMEMODE.cfg.blockScale;
local function MeshGenerate( px, py, pz )
	local GAMEMODE = GAMEMODE;
	local GetBlock = GAMEMODE.GetBlock;
	local worldOffset = Vector( GAMEMODE.pos_blockToWorld( px, py, pz ) ) / blockScale;

	for ox = -radius, radius do
		local x = px + ox;
		for oy = -radius, radius do
			local y = py + oy;
			for oz = -radius, radius do
				local z = pz + oz;
				local block = GetBlock( GAMEMODE, x, y, z );
				if( block )then
					physmesh_builder.AddBlock( worldOffset + Vector( x, y, z ), x, y, z );
				end
			end
		end
	end
end

function ENT:BuildMesh( )
	local pl = self.dt.player;
	local pPos = pl:GetPos();
	local bx, by, bz = GAMEMODE.pos_worldToBlock( pPos.x, pPos.y, pPos.z );


	physmesh_builder.Start()
	physmesh_builder.SetScale( GAMEMODE.blockScale )

	-- add the blocks into it.

	local mesh_tbl = physmesh_builder.End()

	-- gen mesh.
	MeshGenerate( bx, by, bz );

	-- validate the mesh.
	if( not mesh_tbl or #mesh_tbl == 0 or #mesh_tbl % 3 ~= 0 )then
		print("MESH TBL COUNT NOT MULTIPLE OF 3 OR = 0 COUNT IS: "..#mesh_tbl )
		print("     POS: ", self:GetPos() );
		return
	end
	MsgC(Color(0,255,0),"SUCCESSFUL PHYSGEN!");

	-- physics properties. This needs work.
	self:PhysicsFromMesh( mesh_tbl, true ) //THIS MOTHERFUCKER
end