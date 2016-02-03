class GeneratorPanelGlass extends SimpleHavokDestroyableMesh
	placeable
	hidecategories(Havok,HavokProps);

defaultproperties
{
     MaxHealth=50
     DestroySound=Sound'Sounds_Library.Building_and_Object_Crashes.50-object_crash_through_wall2'
     DestroyedMesh=StaticMesh'HavokObjectsPrefabs.StocktonGenerator.GeneratorGlass_Dmg'
     DestroyEmitters(0)=(EmitterClass=Class'VehicleEffects.GlassShatterC')
     CollisionRadius=150.000000
     CollisionHeight=60.000000
     StaticMesh=StaticMesh'HavokObjectsPrefabs.StocktonGenerator.GeneratorGlass'
     Tag="GeneratorPanelGlass"
}
