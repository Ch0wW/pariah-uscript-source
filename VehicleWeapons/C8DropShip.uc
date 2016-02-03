//=============================================================================
//=============================================================================
class C8DropShip extends HavokDropShip
	placeable;

var(Turret) LobTurret Turret;
var(Turret) vector TurretRelativePosition;

var bool bFiringDone;

var StaticMesh AltMesh;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	//Place the turret
	Turret = Spawn(class'LobTurret');
	Turret.LobBase = Spawn(class'LobTurBase');
	Turret.SeekDistance = 15000;

	Turret.SetDrawScale(0.5);
	Turret.LobBase.SetDrawScale(0.5);

	//The location must take is in world space
	Turret.SetLocation( Location + (TurretRelativePosition >> Rotation) );
	Turret.LobBase.SetLocation(Location + (TurretRelativePosition >> Rotation) );
	
	//The base of the turret must be the ship
	Turret.SetBase( Self );
	Turret.LobBase.SetBase( Self);
}


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(50,False);
	bFiringDone=False;
}


//  Note: Don't delete self completely as it causes crash in
//  SceneManager if his has no affectedactor.
//
//
simulated function BlowUpShip()
{

	local int i;
	local DropShipChunks SM;
	
	if (Turret!=None)
		Turret.Explode();


	//Send a death event out
	if( OnDeathEvent != '' )
		TriggerEvent( OnDeathEvent, self, None );

	if( Level != None && Level.GetLocalPlayerController() != None )
		Level.GetLocalPlayerController().PlaySound( ShipBlowupSound,, TransientSoundVolume );
	
	if( ExplosionBurst2Class != None )
		spawn( ExplosionBurst2Class, , , Location );

	if ( Smoke1 != None )
		Smoke1.Kill();
	
	if ( Smoke2 != None )
		Smoke2.Kill();
		
	for( i=0; i<10; i++ )
	{
		SM = Spawn( SMeshClass[i],Self );

		if ( SM!=None )
			SM.SetLocation( Location + SM.ELoc );
	}

	for( i=0; i<LiveEmitters.Length; i++ )
		if ( LiveEmitters[i]!=None )
			LiveEmitters[i].Destroy();

	GotoState('Death');
}



simulated function Timer()
{

	if (bFiringDone)
		DeleteShip();

	if (Turret!=None)
		Turret.bStopFiring=True;
	bFiringDone=True;
	SetTimer(15,True);
}


simulated function DeleteShip()
{
	local int i;

	//Send a death event out
	if( OnDeathEvent != '' )
		TriggerEvent( OnDeathEvent, self, None );


	if (Turret!=None)
		Turret.Explode();

	if ( Smoke1 != None )
		Smoke1.Kill();
	
	if ( Smoke2 != None )
		Smoke2.Kill();
		
	for( i=0; i<LiveEmitters.Length; i++ )
		if ( LiveEmitters[i]!=None )
			LiveEmitters[i].Destroy();


	GotoState('Death');
				
}


state Death
{

simulated function Tick(Float DeltaTime)
{

}

simulated function Timer()
{
	Destroy();
}

Begin:
	SetStaticMesh(AltMesh);
	bHidden=True;
	SetCollision(False,False,False);
	bDying=False;
	SetTimer(120,False);
}

defaultproperties
{
     AltMesh=StaticMesh'JamesPrefabs.Chapter12.DropTurBase'
     TurretRelativePosition=(X=630.000000,Z=-350.000000)
     OnDeathEvent="DropShipDead"
     Emitters(0)=(AttachPoint="PEmitter01",EmitterClass=Class'VehicleEffects.shipthruster_flame')
     Emitters(1)=(AttachPoint="PEmitter02",EmitterClass=Class'VehicleEffects.shipthruster_flame')
     Emitters(2)=(AttachPoint="ThrusterFrontLeft",EmitterClass=Class'VehicleEffects.shipthruster_Side')
     Emitters(3)=(AttachPoint="ThrusterFrontRight",EmitterClass=Class'VehicleEffects.shipthruster_Side')
     CullDistance=20000.000000
     Begin Object Class=HavokParams Name=HavokParams8
         Mass=40.000000
         LinearDamping=0.300000
         AngularDamping=0.300000
         StartEnabled=True
         Restitution=1.000000
         ImpactThreshold=100000.000000
     End Object
     HParams=HavokParams'VehicleWeapons.HavokParams8'
}
