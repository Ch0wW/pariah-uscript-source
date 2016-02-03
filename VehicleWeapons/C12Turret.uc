class C12Turret extends effects placeable;

var	()	vector				TraceOffset;
var	()	class<DamageType>	DamageType;
var	()	float				TimerUpdate;
var	()	class<MuzzleFlash>	MuzFlashClass;
var ()  int					HitPoints;
var		MuzzleFlash			MuzFlash;
var		bool				bFire;
var	()	sound				LaunchSound;
var ()	int					RocketCount;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(14, true);
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	SetTimer(TimerUpdate, true);
}

simulated function Timer()
{
	SetTimer(TimerUpdate, true);

	If (RocketCount<=0)
		Destroy();
	Fire();
}	


simulated function Fire()
{
	local vector start,Adjust;
	local rotator SecRot;

	RocketCount--;
	bFire = False;
	start = Location + (TraceOffset >> Rotation);

	Adjust = (TraceOffset >> Rotation) + VRand()*700;
	SecRot = Rotator(Adjust);

	DoFireEffect();

	PlaySound(LaunchSound, SLOT_Misc, 1.0,,8000,,true);
	Spawn(class'C12Rocket',self,,Start);

	if (RocketCount <15 )
	{
		Spawn(class'C12Rocket',self,,Start,SecRot);

	}

	Adjust = (TraceOffset >> Rotation) + VRand()*700;
	SecRot = Rotator(Adjust);

	if (RocketCount <6 )
	{
		Spawn(class'C12Rocket',self,,Start,SecRot);

	}

}

simulated function DoFireEffect()
{
	if(MuzFlash == none)
	{
		MuzFlash = Spawn(MuzFlashClass,self,,Location + (TraceOffset >> Rotation));
		MuzFlash.SetDrawScale(68.0);
		MuzFlash.SetBase(self);
	}
	MuzFlash.Flash(0);
}

defaultproperties
{
     HitPoints=50
     RocketCount=18
     TimerUpdate=7.000000
     LaunchSound=Sound'Sounds_Library_manny.Weapon_Sounds.73-long_dynamite_blast4'
     DamageType=Class'Engine.DamageType'
     MuzFlashClass=Class'VehicleEffects.AssaultRifleMuzzleFlash'
     TraceOffset=(X=1330.000000)
     TransientSoundVolume=2.500000
     CollisionRadius=60.000000
     CollisionHeight=30.000000
     StaticMesh=StaticMesh'JS_ForestPrefabs.CannonTop'
     Tag="'"
     DrawType=DT_StaticMesh
     RemoteRole=ROLE_SimulatedProxy
}
