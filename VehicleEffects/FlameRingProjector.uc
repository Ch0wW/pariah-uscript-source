class FlameRingProjector extends Projector;

var		float		DeltaSum;
var		float		LifeTime;

simulated function Tick(float dt)
{
	DeltaSum += dt;
	DetachProjector();
	SetDrawScale((DeltaSum/LifeTime) * 15.0);
	AttachProjector();
}

defaultproperties
{
     Lifetime=0.500000
     MaxTraceDistance=100
     ProjTexture=Texture'PariahVehicleEffectsTextures.Vehicle_Explosion.flame_ring'
     FrameBufferBlendingOp=PB_Add
     bProjectParticles=False
     bProjectActor=False
     LifeSpan=0.500000
     bStatic=False
}
