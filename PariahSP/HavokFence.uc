class HavokFence extends MultiPieceHavokDestroyableMesh
	placeable
	hidecategories(Havok,HavokProps);

defaultproperties
{
     Pieces(0)=(Mesh=StaticMesh'HavokObjectsPrefabs.Chapter04Fence.FencePiece01',AttachPoint="Point01",Mass=30.000000)
     Pieces(1)=(Mesh=StaticMesh'HavokObjectsPrefabs.Chapter04Fence.FencePiece02',AttachPoint="Point02",Mass=50.000000)
     Pieces(2)=(Mesh=StaticMesh'HavokObjectsPrefabs.Chapter04Fence.FencePiece03',AttachPoint="Point03",Mass=140.000000)
     Pieces(3)=(Mesh=StaticMesh'HavokObjectsPrefabs.Chapter04Fence.FencePiece04',AttachPoint="Point04",Mass=140.000000)
     HFriction=1.400000
     HRestitution=0.700000
     HAngularDamping=0.500000
     DestroySound=Sound'SM-chapter03sounds.ExplosionWithMetal'
     DestroyEmitters(0)=(SpawnLocation=(Y=13.793000,Z=501.821014),EmitterClass=Class'VehicleEffects.HavokFenceSparks')
     DestroyEmitters(1)=(SpawnLocation=(X=-38.674000,Y=39.360001,Z=234.483002),EmitterClass=Class'VehicleEffects.HavokFenceSparks')
     DestroyEmitters(2)=(SpawnLocation=(Y=-547.716003,Z=190.360001),EmitterClass=Class'VehicleEffects.HavokFenceSparks')
     DestroyEmitters(3)=(EmitterClass=Class'VehicleEffects.HavokFenceDust')
     bRemoveMeshOnDestroy=True
     StaticMesh=StaticMesh'HavokObjectsPrefabs.Chapter04Fence.FenceClean'
     Tag="HavokFence"
}
