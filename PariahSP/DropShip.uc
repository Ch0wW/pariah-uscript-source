class DropShip extends Actor
	placeable;



var Name CargoAttachPointName;
var Vector CargoAttachPoint;


struct ShipEmitterDesc
{
	var() name AttachPoint;
	var() class<Emitter> EmitterClass;
	var() class<xEmitter> xEmitterClass;
};

var() editinline Array<ShipEmitterDesc> Emitters;

var() bool bDoGroundEffects;

var array<Emitter> LiveEmitters;
var array<xEmitter> LivexEmitters;


var DropShipCargo Cargo;

var Emitter Dirt;
var int DirtPPS;
var Vector DirtStart;
var() Sound DropCargoSound;

function PostBeginPlay()
{
	local Rotator r;

	AddLightTag( 'VEHICLE' );
	if ( Level.bVehiclesExclusivelyLit )
	{
		bMatchLightTags=True;
	}

	GetAttachPoint('PEmitter01', DirtStart, r);



}

event tick(float dt)
{
	local vector l,n;

	if(bHidden || !bDoGroundEffects) return;

	if (Trace(l,n, (DirtStart>>Rotation)+Location + (Vect(0,0,-1000)>>Rotation), (DirtStart>>Rotation)+Location, False) != None)
	{
		if(Dirt != None)
		{
			SetTimer(0,false);
			Dirt.Emitters[0].ParticlesPerSecond = DirtPPS;

			Dirt.SetLocation(l);
		}
		else
		{
			Dirt = Spawn(class'shipthruster_dirteffect',self,,l);
			DirtPPS = Dirt.Emitters[0].ParticlesPerSecond;
		}

	}
	else if (Dirt != None && Dirt.Emitters[0].ParticlesPerSecond != 0)
	{
		Dirt.Emitters[0].ParticlesPerSecond = 0;
		SetTimer(2.5, false);
	}



}

event Timer()
{
	if(Dirt != None)
		Dirt.Destroy();
}

function CreateCargoHold()
{
	local Rotator r;
	local vector v;
	local int i;
	local Emitter e;
	local xEmitter x;
	local rotator zero;
	if(GetAttachPoint(CargoAttachPointName, CargoAttachPoint, r))
	{
		Cargo = Spawn(class'DropShipCargo',self,,Location + (CargoAttachPoint>>Rotation), Rotation);
		Cargo.SetBase(self);

		Cargo.SetUnlit( bUnlit );

		Cargo.LightTags = LightTags;
	}
	else
	{
		log("CHARLES: DropShip couldn't find CargoAttachPoint!");
	}

	//spawn and attach emitters

	for(i=0;i<Emitters.Length;i++)
	{
		if(GetAttachPoint(Emitters[i].Attachpoint, v, r))
		{
			if(Emitters[i].EmitterClass != None)
			{
				//log("ship at "@Location@Rotation$" spawnign eimitter for "$v@r);			
				e = spawn(Emitters[i].EmitterClass,self,,(Location+v)>>Rotation,Rotation );
				e.SetBase(self);
				e.SetRelativeLocation(v);
				e.SetRelativeRotation(zero);
				LiveEmitters[LiveEmitters.Length] = e;
			}

			if(Emitters[i].xEmitterClass != None)
			{
				x = spawn(Emitters[i].xEmitterClass,self,,(Location+v)>>Rotation,Rotation );
				x.SetBase(self);
				x.SetRelativeLocation(v);
				x.SetRelativeRotation(zero);
				LivexEmitters[LivexEmitters.Length] = x;
   			}

		}
	}


}

function DropCargo(name spawnevent)
{
	Cargo.SetBase(none);

	Cargo.SetCollision(True,True,True);
	//Cargo.KSetBlockKarma(true);
	//Cargo.bCollideWorld=True;

	Cargo.SetPhysics(PHYS_Havok);
	Cargo.HWake();
	//Cargo.HSetVelocity(Velocity);

	Cargo.ShipVelocity = Velocity;
	Cargo.bReceiveStateNew = True;

	Cargo.SpawnEvent = spawnevent;

	Cargo = None;
	
	PlaySound(DropCargoSound);
}

simulated function StartInterpolation()
{
	//GotoState('');
	//SetCollision(True,false,false);
	bCollideWorld = False;
	bInterpolating = true;
	SetPhysics(PHYS_None);
}


event SceneManagerEvent( name theevent, name secondaryevent )
{
	local int i;

	log("Got SceneManagerEvent with "$theevent$" secondary: "$secondaryevent);
	if(theevent=='StartPath')
	{
		bHidden=False;
		CreateCargoHold();
	}
	if(theevent=='DropCargo')
	{
		DropCargo(secondaryevent);
	}
	if(theevent=='EndPath')
	{
		for(i=0;i<LiveEmitters.Length;i++)
		{
			LiveEmitters[i].Destroy();
		}

		for(i=0;i<LivexEmitters.Length;i++)
		{
			LivexEmitters[i].Destroy();
		}

		if(Cargo != None)
		{
			Cargo.Destroy();
			Cargo=None;
		}

		LiveEmitters.Length=0;
		LivexEmitters.Length=0;
		bHidden=True;
		if(Dirt != None)
			Dirt.Destroy();
	}

}

defaultproperties
{
     DropCargoSound=Sound'PariahDropShipSounds.Millitary.Cargo_Detach01'
     CargoAttachPointName="PCargoHoldDetach"
     Emitters(0)=(AttachPoint="PEmitter01",EmitterClass=Class'VehicleEffects.shipthruster_distortion')
     Emitters(1)=(AttachPoint="PEmitter01",EmitterClass=Class'VehicleEffects.shipthruster_flame')
     Emitters(2)=(AttachPoint="PEmitter02",EmitterClass=Class'VehicleEffects.shipthrusterback_distortion')
     Emitters(3)=(AttachPoint="PEmitter02",EmitterClass=Class'VehicleEffects.shipthrusterback_flame')
     StaticMesh=StaticMesh'PariahDropShipMeshes.DropShipBody'
     AmbientSound=Sound'PariahDropShipSounds.Millitary.ThrusterMediumA'
     DrawType=DT_StaticMesh
     SurfaceType=EST_Metal
     bHidden=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
}
