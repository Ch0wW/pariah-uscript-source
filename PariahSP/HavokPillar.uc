class HavokPillar extends MultiPieceHavokDestroyableMesh
	placeable
	hidecategories(Havok,HavokProps);

// Created by DavidPayne

defaultproperties
{
     PieceLifeSpan=5.000000
     Pieces(0)=(Mesh=StaticMesh'HavokObjectsPrefabs.StormSetPillar.HavokConcretePiece01',AttachPoint="Point01",Mass=50.000000)
     Pieces(1)=(Mesh=StaticMesh'HavokObjectsPrefabs.StormSetPillar.HavokConcretePiece02',AttachPoint="Point02",Mass=50.000000)
     Pieces(2)=(Mesh=StaticMesh'HavokObjectsPrefabs.StormSetPillar.HavokConcretePiece03',AttachPoint="Point03",Mass=50.000000)
     Pieces(3)=(Mesh=StaticMesh'HavokObjectsPrefabs.StormSetPillar.HavokConcretePiece04',AttachPoint="Point04",Mass=50.000000)
     Pieces(4)=(Mesh=StaticMesh'HavokObjectsPrefabs.StormSetPillar.HavokConcretePiece05',AttachPoint="Point05",Mass=50.000000)
     HMass=0.000000
     MaxHealth=100
     DestroySound=SoundGroup'HavokObjectSounds.PillarCollapse.PillarCollapsing'
     DestroyedMesh=StaticMesh'HavokObjectsPrefabs.StormSetPillar.PillarDmg'
     DestroyEmitters(0)=(SpawnLocation=(Z=256.000000),EmitterClass=Class'VehicleEffects.HavokPillarFiller')
     StaticMesh=StaticMesh'HavokObjectsPrefabs.StormSetPillar.PillarClean'
     Tag="HavokPillar"
     bShadowCast=True
}
