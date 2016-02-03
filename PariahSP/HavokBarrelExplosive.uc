class HavokBarrelExplosive extends MultiPieceHavokDestroyableMesh
	placeable
	hidecategories(Havok,HavokProps);

defaultproperties
{
     PieceLifeSpan=3.000000
     Pieces(0)=(Mesh=StaticMesh'HavokObjectsPrefabs.Barrels.BarrelExplTop',AttachPoint="PointTop",Mass=10.000000)
     Pieces(1)=(Mesh=StaticMesh'HavokObjectsPrefabs.Barrels.BarrelExplBottom',AttachPoint="PointBottom",Mass=10.000000)
     HMass=110.000000
     HFriction=0.700000
     HStartLinVel=(Z=1300.000000)
     HStartAngVel=(X=1024.000000,Y=8190.000000,Z=1.000000)
     MaxHealth=100
     DestructionHurtMomentum=1300.000000
     ImpactSoundVolScale=1024.000000
     DestroySound=Sound'SM-chapter03sounds.ExplosionWithMetal'
     ImpactSound=SoundGroup'HavokObjectSounds.BarrelFalling.BarrelFallRandom'
     DestroyEmitters(1)=(AttachPoint="PointBottom",EmitterClass=Class'VehicleEffects.BarrelShardBurst')
     bRemoveMeshOnDestroy=True
     bCauseHurtOnDestruction=True
     CollisionRadius=42.000000
     StaticMesh=StaticMesh'HavokObjectsPrefabs.Barrels.ExplosiveBarrel'
     Tag="HavokBarrelExplosive"
     Physics=PHYS_Havok
}
