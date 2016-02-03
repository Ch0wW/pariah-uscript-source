class DropShipCargo extends Actor;


var Name DoorAAttachPointName;
var Vector DoorAAttachPoint;

var Name DoorBAttachPointName;
var Vector DoorBAttachPoint;

var Vector ShipVelocity;
var bool bReceiveStateNew;

var bool TouchedDown;

var DropShipCargoDoor DoorA, DoorB;

var Name SpawnEvent;

function PostBeginPlay()
{
	local Rotator r;

	if(GetAttachPoint(DoorAAttachPointName, DoorAAttachPoint, r))
	{
		DoorA = Spawn(class'DropShipCargoDoor',self,,Location + ((DoorAAttachPoint + Vect(0,-15,0))>>Rotation), Rotation);
		DoorA.SetBase(self);
	}
	else
	{
		log("CHARLES: DropShipCargo couldn't find DoorAAttachPoint!");
	}

	if(GetAttachPoint(DoorBAttachPointName, DoorBAttachPoint, r))
	{
		DoorB = Spawn(class'DropShipCargoDoorB',self,,Location + ((DoorBAttachPoint + Vect(0,15,0))>>Rotation), Rotation);
		DoorB.SetBase(self);
	}
	else
	{
		log("CHARLES: DropShipCargo couldn't find DoorBAttachPoint!");
	}

}

function SetUnlit(bool unlit)
{
	bUnlit = unlit;

	if(DoorA != None)
		DoorA.bUnlit = unlit;

	if(DoorB != None)
		DoorB.bUnlit = unlit;
}

simulated event bool HHandleContact(
	actor				other,
	vector				pos,	
	vector				vel,
	vector				norm,
	out KContactParams	params
)
{
	if(other != DoorA && other != DoorB)
	{
		if(TouchedDown) return False;
		TouchedDown=True;
		SetTimer(3, false);
		return False;
	}
	else //if(other == DoorA || other == DoorB)
	{
		//params.bAcceptContact = 0;
		return False;
	}

	return False;
}

simulated event Destroyed()
{
	if(DoorA != None)
		DoorA.Destroy();

	if(DoorB != None) 
		DoorB.Destroy();
}

simulated event bool HUpdateState(out KRigidBodyState newState)
{
	local KRigidBodyState	 CurrentState;

	if(!bReceiveStateNew)
		return False;

	HGetRigidBodyState( CurrentState );

	newState.Position = CurrentState.Position;
	newState.Quaternion = CurrentState.Quaternion;


	newState.LinVel.X = ShipVelocity.X;
	newState.LinVel.Y = ShipVelocity.Y;
	newState.LinVel.Z = ShipVelocity.Z;
	newState.AngVel = CurrentState.AngVel;
	
	bReceiveStateNew = False;

	return True;
}

function GoGoGadgetDoor(out DropShipCargoDoor Door)
{
	local vector v;

	Door.SetBase(none);

	Door.SetCollision(True,True,True);
	//Door.KSetBlockKarma(true);
	//Cargo.bCollideWorld=True;

	Door.SetPhysics(PHYS_Havok);
	Door.HWake();
	
	//KDisableCollision(Door);
	//Door.KSetComOffset(Vect(0,10,-200));
	//Door.KSetVelocity(Velocity);
	

	v = Door.Location - Location;
	v.z = 0;

	Door.HAddImpulse(1000*Normal(v), Door.Location + Vect(0,0,80) + Normal(-v)*20);

	
	Door = None;
}


event Timer()
{
	SetPhysics(PHYS_None);
	//HFreeze();
	bWorldGeometry=true;

	GoGoGadgetDoor(DoorA);

	GoGoGadgetDoor(DoorB);


	TriggerEvent(SpawnEvent, self, none);
}

defaultproperties
{
     DoorAAttachPointName="PCargoHoldDoorCentreA"
     DoorBAttachPointName="PCargoHoldDoorCentreB"
     KarmaEncroachSpeed=20.000000
     StaticMesh=StaticMesh'PariahDropShipMeshes.SmallDropShip.DropShipCargoHold'
     Begin Object Class=HavokParams Name=CargoHParams
         Mass=10000.000000
         bWantContactEvent=True
     End Object
     HParams=HavokParams'PariahSP.CargoHParams'
     DrawType=DT_StaticMesh
     SurfaceType=EST_Metal
     bHardAttach=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bBlockKarma=True
}
