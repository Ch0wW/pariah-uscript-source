class HavokAnvilCrateA extends MultiPieceHavokDestroyableMesh
	placeable
	hidecategories(Havok,HavokProps,Health);

// Created by DavidPayne

defaultproperties
{
     PieceLifeSpan=5.000000
     Pieces(0)=(Mesh=StaticMesh'HavokObjectsPrefabs.AnvilCrateA.CrateA_Piece01',AttachPoint="Point01",Mass=25.000000)
     Pieces(1)=(Mesh=StaticMesh'HavokObjectsPrefabs.AnvilCrateA.CrateA_Piece02',AttachPoint="Point02",Mass=50.000000)
     Pieces(2)=(Mesh=StaticMesh'HavokObjectsPrefabs.AnvilCrateA.CrateA_Piece03',AttachPoint="Point03",Mass=50.000000)
     Pieces(3)=(Mesh=StaticMesh'HavokObjectsPrefabs.AnvilCrateA.CrateA_Piece04',AttachPoint="Point04",Mass=75.000000)
     HMass=0.000000
     HStartLinVel=(X=-768.000000,Z=256.000000)
     HStartAngVel=(X=256.000000,Y=256.000000,Z=1024.000000)
     ImpactSoundVolScale=1024.000000
     DestroySound=Sound'HavokObjectSounds.AnvilCrate.AnvilCrateExplode'
     DestroyedMesh=StaticMesh'HavokObjectsPrefabs.AnvilCrateA.CrateA_Destroyed'
     ImpactSound=SoundGroup'HavokObjectSounds.BarrelFalling.BarrelFallRandom'
     DestroyEmitters(0)=(AttachPoint="Point01",EmitterClass=Class'VehicleEffects.VehicleHitSparks')
     DestroyEmitters(1)=(AttachPoint="Point02",EmitterClass=Class'VehicleEffects.VehicleHitSparks')
     DestroyEmitters(2)=(AttachPoint="Point03",EmitterClass=Class'VehicleEffects.VehicleHitSparks')
     DestroyEmitters(3)=(AttachPoint="Point04",EmitterClass=Class'VehicleEffects.VehicleHitSparks')
     bCanCrushPawns=False
     StaticMesh=StaticMesh'HavokObjectsPrefabs.AnvilCrateA.CrateA_Clean'
     Tag="HavokAnvilCrateA"
     bAcceptsProjectors=True
     bShadowCast=True
}
