Class PlasmaGodRays extends Effects;

simulated function PostBeginPlay()
{
    local float spinRate;
    spinRate = 9000;
    
    RotationRate.Yaw = spinRate * 2 * FRand() - spinRate;
	RotationRate.Pitch = spinRate * 2 * FRand() - spinRate;
	RotationRate.Roll = spinRate * 2 * FRand() - spinRate;	
	SetRotation(Rotator(VRand()));
}

defaultproperties
{
     StaticMesh=StaticMesh'PariahWeaponEffectsMeshes.Plasma.ParticleBeam_01'
     DrawScale3D=(X=0.300000,Y=0.300000,Z=0.300000)
     Physics=PHYS_Trailer
     DrawType=DT_StaticMesh
     bTrailerAllowRotation=True
     bFixedRotationDir=True
}
