class StocktonGenerator extends MultiPieceHavokDestroyableMesh
	placeable;
	//hidecategories(Havok,HavokProps);

defaultproperties
{
     PieceLifeSpan=3.000000
     Pieces(0)=(Mesh=StaticMesh'HavokObjectsPrefabs.StocktonGenerator.CoreMain_Dmg',AttachPoint="Point_CoreMain_Dmg",Mass=400.000000)
     Pieces(1)=(Mesh=StaticMesh'HavokObjectsPrefabs.StocktonGenerator.GeneratorTop_Dmg',AttachPoint="Point_GeneratorTop_Dmg",Mass=400.000000)
     Pieces(2)=(Mesh=StaticMesh'HavokObjectsPrefabs.StocktonGenerator.GeneratorTopPanel_Dmg',AttachPoint="Point_GeneratorTopPanel_Dmg",Mass=1000.000000)
     Pieces(3)=(Mesh=StaticMesh'HavokObjectsPrefabs.StocktonGenerator.Piston01_Dmg',AttachPoint="Point_Piston01_Dmg",Mass=2000.000000)
     HMass=0.000000
     HStartLinVel=(Y=2048.000000,Z=2048.000000)
     MaxHealth=25
     DestroyedMesh=StaticMesh'HavokObjectsPrefabs.StocktonGenerator.GeneratorBottom_Dmg'
     DestroyEmitters(0)=(AttachPoint="Point_GeneratorBottom_Dmg",EmitterClass=Class'VehicleEffects.TitansFistExplosion')
     DestroyEmitters(1)=(AttachPoint="Point_GeneratorBottom_Dmg",EmitterClass=Class'VehicleEffects.DavidEngineSmoke')
     StaticMesh=StaticMesh'HavokObjectsPrefabs.StocktonGenerator.StocktonGenerator'
     Tag="StocktonGenerator"
     SoundVolume=200
}
