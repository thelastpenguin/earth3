include( 'shared.lua' );
include( 'mesh_physics.lua' );

ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube1x1x1.mdl");
	self:PhysicsInit(SOLID_CUSTOM);
	self:SetMoveType(MOVETYPE_PUSH);

	self:SetupPhysicsProperties( );
end