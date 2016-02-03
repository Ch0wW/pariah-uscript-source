class LobTurret extends effects placeable;

var	() class<Actor>			ExplosionClass;
var	() class<Emitter>		FlashClass;
var	()	vector				TraceOffset;
var	()	class<DamageType>	DamageType;
var	()	class<MuzzleFlash>	MuzFlashClass;
var		MuzzleFlash			MuzFlash;
var		float					LastFireTime;
var		Controller				Target;
var		bool					bStartFire;
var ()  LobTurBase				LobBase;
var ()  int						Health;
var ()  float					FireDelay;
var		float					FireCount;
var	()	sound					FireSound;
var		sound					BlowUpSound;
var ()	texture					AltTexture;
var ()	texture					AltBaseTexture;
var		int						SkinCount;
var() name						TagB;
var()	float					SeekDistance;
var()	bool					bStopFiring, bVulnerable;
 
simulated function PostBeginPlay()
{
	local Controller c;

	Super.PostBeginPlay();
	SetTimer(3.0, true);

	
	for(c = Level.ControllerList; c != None; c = c.NextController)
	{
		if(c.IsA('PlayerController'))
			Target = c;
	}

	bStopFiring=False;
}


simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	SetTimer(3.0, true);
	bStopFiring=False;
}

simulated function Timer()
{
	local Controller c;

	SetTimer(3.0+Frand(),True);

	if(Target != none)
	{
		if (Vsize(Target.Pawn.Location-Location) < SeekDistance) bStartFire=True;
	}
	else
	{		
		for(c = Level.ControllerList; c != None; c = c.NextController)
		{
			if(c.IsA('PlayerController'))
				Target = c;
		}
	}
}	



simulated event Tick(float DeltaTime)
{
//	local float YawDiff;
	local rotator RotationB;

	if (bStopFiring) Return;

	FireCount += DeltaTime;

	SkinCount++;
	if (SkinCount>3) 
	{
		SetSkin(0,None);
		if (LobBase!=None) LobBase.SetSkin(0,None);
	}


	RotationB = Rotation;
	RotationB.Pitch = 0.0;
	if (LobBase!=None) LobBase.SetRotation(RotationB);

	if(bStartFire )
	{

		DesiredRotation = rotator(Target.Pawn.Location - Location );

//		YawDiff = (DesiredRotation.Yaw & 65535) - (Rotation.Yaw & 65535);

//		if (YawDiff < -32768) YawDiff += 65536;
//		else if (YawDiff > 32768) YawDiff -= 65536;
		if ( FireCount>=2.0) 
		{
			FireCount=Frand();
			Fire();
		}
	}
}


simulated function Fire()
{
	local vector start;
	local vector HitLocation, HitNormal;

	start = Location + (TraceOffset >> Rotation);

	Trace(HitLocation, HitNormal, Target.Location, Start, true);

	if(FlashClass != none)
		Spawn(FlashClass,self,,Start);

	if(Role != ROLE_Authority)
		return;

	PlaySound(FireSound, SLOT_Misc, TransientSoundVolume,,14000,,true);
	Spawn(class'LaserProjectile',self,,Start);

}



function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, 
					 class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage )
{

	if (bVulnerable)
	{

		Health -= Damage;

		SetSkin(0,AltTexture);
		if (LobBase!=None) LobBase.SetSkin(0,AltBaseTexture);
		SkinCount=0;

		if(Health < 0)
			Explode();

		Super.TakeDamage( Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage );
	}
	else
	{
		If (Owner!=None) Owner.TakeDamage(Damage, EventInstigator, Hitlocation, Momentum, DamageType);
	}
}


function Explode()
{
	local actor Act;

	foreach AllActors(class'Actor',Act)
	{
		if (Act.Tag == Tag) 
		{
			Act.Trigger(self, none);
		}
		else if (Act.Tag == TagB)
		{
			Act.Trigger(self, none);   //Wake up the Door
		}
	}

	if( Level != None && Level.GetLocalPlayerController() != None )
		Level.GetLocalPlayerController().PlayOwnedSound( BlowupSound,, TransientSoundVolume );

	Spawn(ExplosionClass);
	if (LobBase!=None) LobBase.Destroy();
	Destroy();
}

defaultproperties
{
     Health=300
     FireDelay=2.000000
     SeekDistance=9500.000000
     FireSound=Sound'PariahDropShipSounds.Millitary.DropshipTurretFireA'
     BlowUpSound=Sound'PariahWeaponSounds.expl_grenade'
     AltTexture=Texture'JamesTextures.Chapter12.DropShipTurBBartga'
     AltBaseTexture=Texture'JamesTextures.Chapter12.DropShipTurBright'
     TagB="HavokDoor"
     ExplosionClass=Class'VehicleEffects.C12GenExpl'
     FlashClass=Class'VehicleEffects.DropShipFireFlash'
     DamageType=Class'Engine.DamageType'
     MuzFlashClass=Class'VehicleEffects.AssaultRifleMuzzleFlash'
     TraceOffset=(X=630.000000)
     bVulnerable=True
     TransientSoundVolume=2.500000
     CollisionRadius=80.000000
     CollisionHeight=110.000000
     StaticMesh=StaticMesh'JamesPrefabs.Chapter12.DropTurBarrel'
     Tag="'"
     RotationRate=(Pitch=12084,Yaw=7384)
     Physics=PHYS_Rotating
     DrawType=DT_StaticMesh
     RemoteRole=ROLE_SimulatedProxy
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
     bUseCylinderCollision=True
     bRotateToDesired=True
}
