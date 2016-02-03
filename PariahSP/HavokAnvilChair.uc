class HavokAnvilChair extends SimpleHavokDestroyableMesh
	placeable
	hidecategories(Havok,HavokProps);

// Created by DavidPayne

defaultproperties
{
     HMass=20.000000
     HFriction=1.400000
     HRestitution=0.100000
     HLinearDamping=0.500000
     HAngularDamping=0.600000
     HBuoyancy=1.000000
     MaxHealth=100
     ImpactSoundVolScale=1.000000
     DestroyedMesh=StaticMesh'HavokObjectsPrefabs.AnvilChair.AnvilChair'
     ImpactSound=SoundGroup'HavokObjectSounds.BarrelFalling.BarrelFallRandom'
     StaticMesh=StaticMesh'HavokObjectsPrefabs.AnvilChair.AnvilChair'
     Tag="HavokAnvilChair"
     Physics=PHYS_Havok
}
