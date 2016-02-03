class C12Lock extends Effects
	placeable;

// This is the lock to open the dropship door in Chapter 12
//


//
// Unlock (destroy self) when triggered.
//
function Trigger(actor Other, pawn EventInstigator)
{
	Destroy();
}

defaultproperties
{
     StaticMesh=StaticMesh'JamesPrefabs.Chapter12.DropShipLockMesh'
     Tag="'"
     DrawType=DT_StaticMesh
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
     bBlockKarma=True
}
