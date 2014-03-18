AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile('mesh_physics.lua');

include("shared.lua")
include( 'mesh_physics.lua' );

include('shared.lua')
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include("mesh_physics.lua")

function ENT:Initialize()
	self:SetPos( 0, 0 );
	self:SetModel("models/hunter/blocks/cube1x1x1.mdl")

	self:PhysicsInit(SOLID_CUSTOM)

	self:SetAngles( Angle( 0, 0, 0 ) )
	self:SetNoDraw( true )
	self:SetNotSolid( true )

	self:SetupPhysicsProperties( );
end