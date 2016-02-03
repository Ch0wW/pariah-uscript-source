class MilitaryCover extends MultiPieceHavokDestroyableMesh
	placeable
	hidecategories(Havok,HavokProps);

defaultproperties
{
     PieceLifeSpan=5.000000
     Pieces(0)=(Mesh=StaticMesh'HavokObjectsPrefabs.MilitaryCover.CoverTop01_Dmg',AttachPoint="Point_Top01",Mass=100.000000)
     Pieces(1)=(Mesh=StaticMesh'HavokObjectsPrefabs.MilitaryCover.CoverTop02_Dmg',AttachPoint="Point_Top02",Mass=100.000000)
     Pieces(2)=(Mesh=StaticMesh'HavokObjectsPrefabs.MilitaryCover.CoverTop03_Dmg',AttachPoint="Point_Top03",Mass=100.000000)
     HMass=0.000000
     HStartLinVel=(X=100.000000,Z=512.000000)
     HStartAngVel=(X=1024.000000,Y=16384.000000,Z=1024.000000)
     MaxHealth=50
     ImpactSoundVolScale=2048.000000
     DestroyedMesh=StaticMesh'HavokObjectsPrefabs.MilitaryCover.CoverBottom'
     ImpactSound=SoundGroup'HavokObjectSounds.BarrelFalling.BarrelFallRandom'
     HitBoxes(0)="Hitbox01"
     HitBoxes(1)="Hitbox02"
     DestroyEmitters(0)=(AttachPoint="Point_Top01",EmitterClass=Class'VehicleEffects.ChassisSparks')
     DestroyEmitters(1)=(AttachPoint="Point_Top02",EmitterClass=Class'VehicleEffects.ChassisSparks')
     DestroyEmitters(2)=(AttachPoint="Point_Top03",EmitterClass=Class'VehicleEffects.ChassisSparks')
     bCanCrushPawns=False
     StaticMesh=StaticMesh'HavokObjectsPrefabs.MilitaryCover.CoverAll'
     Tag="MilitaryCover"
     bShadowCast=True
}
