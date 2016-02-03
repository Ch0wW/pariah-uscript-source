class HavokBarrelEmpty extends MultiPieceHavokDestroyableMesh
	placeable
	hidecategories(Havok,HavokProps);

// Created by DavidPayne

defaultproperties
{
     HMass=80.000000
     HFriction=0.500000
     HRestitution=0.300000
     ImpactSoundVolScale=1024.000000
     DestroyedMesh=StaticMesh'HavokObjectsPrefabs.Barrels.EmptyBarrel'
     ImpactSound=SoundGroup'HavokObjectSounds.BarrelFalling.BarrelFallRandom'
     CollisionRadius=42.000000
     StaticMesh=StaticMesh'HavokObjectsPrefabs.Barrels.EmptyBarrel'
     Tag="HavokBarrelEmpty"
     Physics=PHYS_Havok
}
