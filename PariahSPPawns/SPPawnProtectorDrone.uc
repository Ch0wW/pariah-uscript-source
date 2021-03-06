class SPPawnProtectorDrone extends SPPawnDrone;


var DisruptorShell MyShell;

function PostBeginPlay()
{
	MyShell=spawn(class'DisruptorShell',self,,Location,Rotation);
	MyShell.SetBase(self);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{

	Super.TakeDamage(0, instigatedby,hitlocation,momentum,damagetype,projowner,bsplashdamage);
}


function EMPHit(bool bEnhanced)
{
	//oh jeez!

	Controller.GotoState('DisabledByEMP');
	Velocity = VSize(Velocity)*vect(0, 0, -1);
	Acceleration = vect(0, 0, 0);
	SetPhysics(PHYS_Falling);
	bShouldBounce = true;
}

simulated function Landed(vector HitNormal)
{
	Velocity = 0.35*( (Velocity dot HitNormal)*HitNormal*(-2.0)+Velocity);
	SetPhysics(PHYS_Falling);
	if(VSize(Velocity) < 20) {
		bShouldBounce = false;
		SetTimer(RandRange(1, 10), false);
	}
}

function Timer()
{
	// blow up
	Explode();
}

function StartEMP()
{
	MyShell.Disable('Tick');
}

function EndEMP()
{
	MyShell.Enable('Tick');
}

defaultproperties
{
     ExplodeSound=Sound'PariahGameSounds.Mines.MineExplosionA'
     ExplodeEmitter=Class'VehicleEffects.VGRocketExplosion'
     ExplosionDistortionClass=Class'VehicleEffects.VGRocketExplosionDistort'
     AirSpeed=1000.000000
     FlyingBrakeAmount=10.000000
     bDontReduceSpeed=True
     DrawScale=4.000000
     StaticMesh=StaticMesh'DronesStaticMeshes.ProtectorDroneCore'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem106
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem106'
     Skins(0)=Shader'DroneTex.Protector.ProtectorShader'
}
