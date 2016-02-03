class Outpost extends MultiPieceHavokDestroyableMesh
	placeable
	hidecategories(Havok,HavokProps);

defaultproperties
{
     PieceLifeSpan=60.000000
     Pieces(0)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostArch01',AttachPoint="Point_OutpostArch01",Mass=8000.000000)
     Pieces(1)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostArch02',AttachPoint="Point_OutpostArch02",Mass=8000.000000)
     Pieces(2)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostBalCony01',AttachPoint="Point_OutpostBalCony01",Mass=8000.000000)
     Pieces(3)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostBalCony02',AttachPoint="Point_OutpostBalCony02",Mass=8000.000000)
     Pieces(4)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostBalCony03',AttachPoint="Point_OutpostBalCony03",Mass=8000.000000)
     Pieces(5)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostRamp01',AttachPoint="Point_OutpostRamp01",Mass=8000.000000)
     Pieces(6)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostRamp02',AttachPoint="PointOutpostRamp02",Mass=8000.000000)
     Pieces(7)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostRoof01',AttachPoint="Point_OutpostRoof01",Mass=8000.000000)
     Pieces(8)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostRoof02',AttachPoint="Point_OutpostRoof02",Mass=8000.000000)
     Pieces(9)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostSupport01',AttachPoint="Point_OutpostSupport01",Mass=8000.000000)
     Pieces(10)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostSupport04',AttachPoint="PointOutpostSupport04",Mass=8000.000000)
     Pieces(11)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostSupport05',AttachPoint="Point_OutpostSupport05",Mass=8000.000000)
     Pieces(12)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostSupport06',AttachPoint="Point_OutpostSupport06",Mass=8000.000000)
     Pieces(13)=(Mesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostSupport08',AttachPoint="Point_OutpostSupport08",Mass=8000.000000)
     HMass=0.000000
     HFriction=0.900000
     HLinearDamping=1.000000
     HAngularDamping=0.700000
     MaxHealth=415
     DamageEventThresshold=100
     DestroySound=Sound'HavokObjectSounds.Outpost.TowerCollapseA'
     DestroyedMesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostBase'
     DestroyEmitters(0)=(AttachPoint="Point_OutpostRoof01",EmitterClass=Class'VehicleEffects.OutpostDestroyDust')
     DamageEmitters(0)=(AttachPoint="FX01",EmitterClass=Class'VehicleEffects.OutpostDamageDustNarrow')
     DamageEmitters(1)=(AttachPoint="FX02",EmitterClass=Class'VehicleEffects.OutpostDamageDustNarrow')
     DamageEmitters(2)=(AttachPoint="FX03",EmitterClass=Class'VehicleEffects.OutpostDamageDustNarrow')
     DamageEmitters(3)=(AttachPoint="FX04",EmitterClass=Class'VehicleEffects.OutpostDamageDustNarrow')
     DamageEmitters(4)=(AttachPoint="FX05",EmitterClass=Class'VehicleEffects.OutpostDamageDustNarrow')
     DamageEmitters(5)=(AttachPoint="FX06",EmitterClass=Class'VehicleEffects.OutpostDamageDustNarrow')
     DamageEmitters(6)=(AttachPoint="FX07",EmitterClass=Class'VehicleEffects.OutpostDamageDustNarrow')
     DamageEmitters(7)=(AttachPoint="FX08",EmitterClass=Class'VehicleEffects.OutpostDamageDustNarrow')
     DamageEmitters(8)=(AttachPoint="FX09",EmitterClass=Class'VehicleEffects.OutpostDamageDustNarrow')
     StaticMesh=StaticMesh'HavokObjectsPrefabs.HavokOutpost.OutpostAll'
     Tag="Outpost"
}
