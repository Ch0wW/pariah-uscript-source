class SpecialStaticMesh extends StaticMeshActor
	native
    NotPlaceable;

//I tried to set bBlockActors and bBlockPlayers to true but on foot I still go
//through added objects. If I set the other two the pawns can't spawn...Is it
//a wrong collision model for the arrow? I don't know.

defaultproperties
{
     RemoteRole=ROLE_None
     bStatic=False
     bHidden=True
     bWorldGeometry=False
     bShadowCast=False
     bStaticLighting=False
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
}
