class C12Rocket extends VGProjectile;

var		Emitter			Trail;
var		Emitter			TrailDistortion;
var		Actor			Corona;
var	()	class<Emitter>	TrailClass;
var	()	class<Emitter>	TrailMClass;
var	()	class<Emitter>	TrailClassDistortion;
var	()	class<Actor>	CoronaClass;
var	()	class<Actor>	ExplosionClass;
var () Float ExplosionImpulse;
var float CS,SN;

var Actor Seeking;
var Sound FlySound;
var bool bMyRocket;


//do the special effects for the impact
simulated function Explode(vector HitLocation, vector HitNormal)
{

	SpawnExplosion(HitLocation, HitNormal);

	if(ExplosionSound != none)
		PlaySound(ExplosionSound,,1.0,,10000);

 	Destroy();
}

simulated function PostBeginPlay()
{
	Seeking = none;

	Super.PostBeginPlay();

	AmbientSound = FlySound;

	CS=FRand()*3;

	SetTimer(12,False);
}

simulated function Timer()
{
	BlowUp(Location);
	Explode(Location, Vect(0,0,1));

}


simulated function Destroyed()
{
	if(Trail != None)
		Trail.Kill();

	if(TrailDistortion != None)
		TrailDistortion.Kill();

	if(Corona != none)
		Corona.Destroy();

	Super.Destroyed();
}

simulated function SpawnRocketTrail()
{

	if(TrailClass != none && Trail == none)
		{
			if (bMyRocket)
				Trail = Spawn(TrailMClass,self);
			else
				Trail = Spawn(TrailClass,self);
		}

	if(TrailClassDistortion != none && TrailDistortion == none) 
		TrailDistortion = Spawn(TrailClassDistortion,self);

	if(CoronaClass != none)
		Corona = Spawn(CoronaClass,self);
}

simulated function SpawnExplosion(vector HitLocation, vector HitNormal)
{
	local vector v;
	local rotator r;

	v = HitLocation+HitNormal*100;
	r = rotator(HitNormal);
	if(ExplosionClass != none)
		spawn(ExplosionClass,,,v,r);
}


simulated function FindSeekingTarget()
{
	local Controller C;
	local actor Act;

	if (bMyRocket)
	{
		foreach AllActors(class'Actor',Act)
		{
			if (Act.IsA('C12ShieldGenerator'))  Seeking = Act;
		}

//		if (Seeking!=None) 
//		{
//			SetRotation(rotator(Normal(Seeking.Location - Location)));
//			Velocity = VSize(Velocity) * Normal(Seeking.Location - Location + Vect(0,8000,0));
//		}
	}
	else
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController ) 
			if(PlayerController(C) != None)
				Seeking = PlayerController(C).ViewTarget;
	}

	if (Seeking!=None) SpawnRocketTrail();
}


simulated function Tick(float DeltaTime)
{
	local vector SeekingDir;

	if(Seeking == None ) FindSeekingTarget();

	if (Seeking != None)
	{
		CS+=DeltaTime*4.0;
		SeekingDir = Normal(Seeking.Location - Location); 
		SeekingDir.X += Cos(CS);
		SeekingDir.Z += Sin(CS);
		
		Velocity =  Speed * Normal(Velocity+Speed*SeekingDir*DeltaTime*2.0); 
		SetRotation(rotator(Velocity) );
	}
	else
	{
		SeekingDir = Vect(0,0,-1);
		Velocity =  Velocity*0.97+Speed*SeekingDir*0.03; 
		SetRotation(rotator(Velocity) );
	}
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{

	BlowUp(Location);
	Explode(Location, Vect(0,0,1));
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	local vector dir;
	local float ExplosionToEnemyDist;
	local Vector ExplosionToEnemyDistVector;
	local Vector ImpulseDirection;
	local Pawn PawnAffected;

	if (Other.IsA('C12Rocket') ) Return;

	//don't apply momentum if the weapon does splash damage, the splash effect will do it for us

	Other.TakeDamage(PersonDamage*Instigator.DamageScaling,instigator,HitLocation,0*dir,MyDamageType);



	foreach radiusactors(class'Pawn', PawnAffected, 4000)
	{
		ExplosionToEnemyDistVector = PawnAffected.Location - Location;
		ImpulseDirection = Normal(ExplosionToEnemyDistVector);
		ExplosionToEnemyDist = VSize(ExplosionToEnemyDistVector);
		ExplosionToEnemyDist = FMax( 1.0, ExplosionToEnemyDist );

		If (ImpulseDirection.Z<=0.1) ImpulseDirection.Z = 0.2;

		PawnAffected.TakeDamage(SplashDamage, Instigator, Location, (ExplosionImpulse * ImpulseDirection), MyDamageType,, true);
	}

	BlowUp(HitLocation);
	Explode(HitLocation, dir);

}

defaultproperties
{
     FlySound=Sound'PariahWeaponSounds.rocket_fly_lp'
     TrailClass=Class'VehicleEffects.C12Exhaust'
     TrailMClass=Class'VehicleEffects.C12Exhaust'
     ExplosionClass=Class'VehicleEffects.C12BigExpl'
     VehicleDamage=18
     PersonDamage=18
     SplashDamage=18.000000
     ExplosionSound=Sound'PariahDropShipSounds.Millitary.DropshipExplosionA'
     Speed=3300.000000
     MaxSpeed=3300.000000
     DamageRadius=500.000000
     MyDamageType=Class'VehicleWeapons.VGRocketLauncherDamage'
     ExplosionDecal=Class'VehicleEffects.ExplosionMark'
     LifeSpan=15.000000
     DrawScale=2.000000
     SoundRadius=8000.000000
     CollisionRadius=350.000000
     CollisionHeight=700.000000
     StaticMesh=StaticMesh'JamesPrefabs.Chapter12.C12Rocket'
     Event="RocketHitShield"
     DrawType=DT_StaticMesh
     SoundVolume=255
     bNetTemporary=False
     bAlwaysRelevant=True
     bUpdateSimulatedPosition=True
     bProjTarget=True
     bReplicateNotify=True
}
