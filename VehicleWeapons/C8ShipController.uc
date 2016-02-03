class C8ShipController extends effects placeable;

var() SceneManager Scene1;
var() SceneManager Scene2;
var() SceneManager Scene3;
var() SceneManager Scene4;
var int SceneNum;
var() int TotalDropShips;
var() name EndGameEvent;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SceneNum = 0;

}

event Trigger( actor Other, pawn EventInstigator )
{
	local C8DropShip Ship;

	// Player Ran over trigger to start this or we get a death event or a scene end event. 
	// (all should be the same)   Event = DropShipDead

	// Spawn a ship.
	Ship = spawn(class'C8DropShip');

	TotalDropShips--;

	if (TotalDropShips<=0 && Scene4!=None && Ship!=None)
	{
		Scene4.AffectedActor = Ship;
		Scene4.Trigger(Other, EventInstigator);
		SetTimer(8,False);
	}
	else if (SceneNum==0 && Scene1!=None && Ship!=None)
	{
		Scene1.AffectedActor = Ship;
		Scene1.Trigger(Other, EventInstigator);
	}
	else if (SceneNum==1 && Scene2!=None && Ship!=None)
	{
		Scene2.AffectedActor = Ship;
		Scene2.Trigger(Other, EventInstigator);
	}
	else if (Scene3!=None && Ship!=None)
	{
		Scene3.AffectedActor = Ship;
		Scene3.Trigger(Other, EventInstigator);
	}


	SceneNum++;
	if (SceneNum>=2) SceneNum=0;
}

simulated function Timer()
{
		if( EndGameEvent != '' )
			TriggerEvent( EndGameEvent, self, None );
}

defaultproperties
{
     TotalDropShips=8
     EndGameEvent="'"
     StaticMesh=StaticMesh'JamesPrefabs.Chapter12.DropTurBarrel'
     Tag="'"
     DrawType=DT_StaticMesh
}
