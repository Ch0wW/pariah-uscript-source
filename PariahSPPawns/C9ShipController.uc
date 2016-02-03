class C9ShipController extends effects placeable;

var() SceneManager Scene1;
var() SceneManager Scene2;
var() SceneManager Scene3;
var() SceneManager Scene4;

var() SceneManager SceneNoZipB;
var() SceneManager SceneNoZipA;

var int SceneNum;
var() int TotalDropShips;
var() name EndGameEvent;
var C8ZipDropShip Ship;
var int NumDropDudes;
var bool bShipSent;
var float DelayTime;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SceneNum = 0;
	NumDropDudes=2;
}


simulated function Tick(float DeltaTime)  //Wait 5 seconds before allowing the sending of another ship.
{
	if (bShipSent==True)
	{
		Disable('Trigger');
		DelayTime+=DeltaTime;
		if (DelayTime>=5.0)
		{
			Enable('Trigger');
			bShipSent=False;
		}
	}
}

event Trigger( actor Other, pawn EventInstigator )
{
	// Player Ran over trigger to start this or we get a death event or a scene end event. 
	// (all should be the same)   Event = DropShipDead

	DelayTime=0.0;
	bShipSent=True;
	TotalDropShips--;

	if (TotalDropShips<=0 && Scene4!=None)
	{
		MaxLights=0;
		Ship = spawn(class'C8ZipDropShip',Self);
		Scene4.AffectedActor = Ship;
		Scene4.Trigger(Other, EventInstigator);
		SetTimer(8,False);

	}
	else if (SceneNum==4 && Scene1!=None)
	{
		MaxLights=NumDropDudes;
		Ship = spawn(class'C8ZipDropShip',Self);
		Scene1.AffectedActor = Ship;
		Scene1.Trigger(Other, EventInstigator);
		NumDropDudes++;
	}
	else if (SceneNum==1 && Scene2!=None)
	{
		MaxLights=NumDropDudes;
		Ship = spawn(class'C8ZipDropShip',Self);
		Scene2.AffectedActor = Ship;
		Scene2.Trigger(Other, EventInstigator);
	}
	else if (SceneNum==0 && SceneNoZipA!=None)
	{
		MaxLights=0;
		Ship = spawn(class'C8ZipDropShip',Self);
		SceneNoZipA.AffectedActor = Ship;
		SceneNoZipA.Trigger(Other, EventInstigator);
	}
	else if (SceneNum==2 && SceneNoZipB!=None)
	{
		MaxLights=0;
		Ship = spawn(class'C8ZipDropShip',Self);
		SceneNoZipB.AffectedActor = Ship;
		SceneNoZipB.Trigger(Other, EventInstigator);
	}
	else if (Scene3!=None && Ship!=None)
	{
		MaxLights=NumDropDudes;
		Ship = spawn(class'C8ZipDropShip',Self);
		Scene3.AffectedActor = Ship;
		Scene3.Trigger(Other, EventInstigator);
		NumDropDudes++;
	}

	if (NumDropDudes>=4) NumDropDudes=4;
	SceneNum++;
	if (SceneNum>=5) SceneNum=0;
}

simulated function Timer()
{
		if( EndGameEvent != '' )
			TriggerEvent( EndGameEvent, self, None );
}

defaultproperties
{
     TotalDropShips=10
     EndGameEvent="EndCinematic"
     StaticMesh=StaticMesh'JamesPrefabs.Chapter12.DropTurBarrel'
     Tag="DropShipDead"
     DrawType=DT_StaticMesh
     MaxLights=0
}
