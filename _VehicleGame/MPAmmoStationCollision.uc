class MPAmmoStationCollision extends StaticMeshActor;



var MPAmmoStation Station;


event Bump(actor Other)
{
	Station.Bump(Other);
	Super.Bump(Other);
}

defaultproperties
{
     StaticMesh=StaticMesh'CSmart_prefabs.Gameplay.ammostationboxC'
     bStatic=False
     bHidden=True
     bWorldGeometry=False
     bAcceptsProjectors=False
     bMovable=False
}
