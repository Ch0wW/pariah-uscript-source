class C12FiringController extends Effects
	placeable;


//  look for scene manager.  When trigger is called, speed up action[12] so ship will
// close in on other ship
//
//
var SceneManager MyScene;
var() float SlowTimeAt;
var() int NumTrigger;
var RockingSkyZoneInfo RockingZone;
var Actor SkyMesh[2];
var StaticMesh CasketMesh;
var StaticMesh WindowMesh, DoorMesh;

var array<Emitter> LiveEmitters;

struct ShipEmitterDesc
{
	var() name AttachPoint;
	var() class<Emitter> EmitterClass;
};

var() editinline Array<ShipEmitterDesc> Emitters;

simulated function PostBeginPlay()
{
	local SceneManager MActor;
	local RockingSkyZoneInfo Ractor;
	local Actor Act;
	local vector CPos;
	local rotator CRot;
	local Actor A;

	foreach AllActors(class'SceneManager',MActor)
		if (Mactor.EventEnd == 'Boor') MyScene=Mactor;

	foreach AllActors(class'RockingSkyZoneInfo',RActor)
		 RockingZone=Ractor;

	foreach AllActors(class'Actor',Act)
	{
		if (Act.Tag=='SkyHemi')
		{
			Act.SetBase(RockingZone);    //Attach sky hemispheres to RockingSkyZoneInfo
		}
	};

	foreach AllActors(class'Actor',Act, 'DropShip')
	{
		Act.GetAttachPoint( 'CryoPoint', CPos, CRot );
		A=Spawn(Class'LobTurBase',self);
		A.SetStaticMesh(CasketMesh);
		A.SetCollision(True, True, True);
		AttachThis(Act, A, Cpos, CRot);

		Act.GetAttachPoint( 'WindowCover', CPos, CRot );
		A=Spawn(Class'LobTurBase',self);
		A.SetStaticMesh(WindowMesh);
		AttachThis(Act, A, Cpos, CRot);

		Act.GetAttachPoint( 'BackCover', CPos, CRot );
		A=Spawn(Class'LobTurBase',self);
		A.SetStaticMesh(DoorMesh);
		A.SetCollision(True, True, True);
		AttachThis(Act, A, Cpos, CRot);

		SetAttachments(Act);
	}


    Super.PostBeginPlay();


	// Slow down ship at specified time.
	//
	SetTimer(SlowTimeAt,False);
}


function SetAttachments(Actor Act)
{
	local Rotator r;
	local vector v;
	local int i;
	local Emitter e;
	local rotator zero;

	for(i=0;i<6;i++)
	{
		if(Act.GetAttachPoint(Emitters[i].Attachpoint, v, r))
		{
			if(Emitters[i].EmitterClass != None)
			{
				e = spawn(Emitters[i].EmitterClass,self,,(Location+v)>>Rotation,Rotation );
				e.SetBase(Act);
				e.SetRelativeLocation(v);
				e.SetRelativeRotation(zero);
				LiveEmitters[LiveEmitters.Length] = e;
			}
		}
	}


}


function AttachThis(Actor AttachTo, Actor A, vector offset, rotator rotation)
{
	A.SetBase(AttachTo);
	A.SetRelativeLocation(offset);
	A.SetRelativeRotation(rotation);
}


//
// Gets triggered when you want ship to close in.
//
function Trigger(actor Other, pawn EventInstigator)
{
	If (MyScene!=None)
	{
			NumTrigger--;
			if (NumTrigger<=0)
			{
				MyScene.SceneSpeed=1.0;
				SetTimer(120,False);		//Slow time again after 2 minutes when you are close enough to other ship.
			}

	}
}

simulated function Timer()
{
	if (NumTrigger<=0 && MyScene !=None)
	{	
			MyScene.SceneSpeed=0.001;	
	}
	else if (MyScene!=None)
	{
			MyScene.SceneSpeed=0.05;
	}

}

defaultproperties
{
     NumTrigger=4
     SlowTimeAt=160.000000
     CasketMesh=StaticMesh'MynkiMeshes.CryoCasket.CryoCasketIntact'
     WindowMesh=StaticMesh'JamesPrefabs.Chapter12.WindowBox'
     DoorMesh=StaticMesh'JamesPrefabs.Chapter12.MilBlockDoor'
     Emitters(0)=(AttachPoint="ThrustVertA",EmitterClass=Class'VehicleEffects.MilShipBottomThrust')
     Emitters(1)=(AttachPoint="ThrustVertB",EmitterClass=Class'VehicleEffects.MilShipBottomThrust')
     Emitters(2)=(AttachPoint="ThrustVertC",EmitterClass=Class'VehicleEffects.MilShipBottomThrust')
     Emitters(3)=(AttachPoint="ThrustVertD",EmitterClass=Class'VehicleEffects.MilShipBottomThrust')
     Emitters(4)=(AttachPoint="ThrustBackA",EmitterClass=Class'VehicleEffects.MilShipBackThrust')
     Emitters(5)=(AttachPoint="ThrustBackB",EmitterClass=Class'VehicleEffects.MilShipBackThrust')
     bHidden=True
     bNoDelete=True
}
