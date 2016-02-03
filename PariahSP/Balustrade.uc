class Balustrade extends SimpleHavokDestroyableMesh
	placeable
	hidecategories(Havok,HavokProps);

// Created by DavidPayne

defaultproperties
{
     HMass=151.000000
     HStartLinVel=(X=10.000000,Z=100.000000)
     MaxHealth=50
     ImpactSoundVolScale=1024.000000
     DestroySound=Sound'Sounds_Library.Building_and_Object_Crashes.42-elevator_crash_short'
     DestroyedMesh=StaticMesh'HavokObjectsPrefabs.HavokBalustrade.HavokBalustrade02'
     ImpactSound=SoundGroup'HavokObjectSounds.BarrelFalling.BarrelFallRandom'
     DestroyEmitters(0)=(AttachPoint="FX1",EmitterClass=Class'VehicleEffects.VehicleHitSparks')
     DestroyEmitters(1)=(AttachPoint="FX2",EmitterClass=Class'VehicleEffects.VehicleHitSparks')
     StaticMesh=StaticMesh'HavokObjectsPrefabs.HavokBalustrade.HavokBalustrade01'
     Tag="Balustrade"
     bDirectional=True
}
