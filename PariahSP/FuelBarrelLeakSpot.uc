class FuelBarrelLeakSpot extends Actor;


var bool bFirstSpot, bHitSpot;

var FuelBarrelLeakSpot Next, Prev;

var FuelBarrel MyFuelBarrel;

var HavokBarrelLeaks MyLeakyBarrel;     // newer version of fuel barrel derived from multipiecehavokdestroyablemesh

var FlameTrail MyFlameTrail; 

var float InitialBurnTime;

var vector TrailEnd; 

var Pawn Igniter;

var Sound IgniteSound, BurnSound;

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage )
{
//	if(bFirstSpot)
//	{
		bHitSpot=True;
		LightUp(Igniter);
//	}
}



function LightUp(Pawn p)
{
	local Vector dir;
	local float dist;

	Igniter = p;
	if(Next != None)
	{
		dist = VSize(Next.Location - Location);
		dir = Normal(Next.Location - Location);
		TrailEnd = Next.Location;
	}
	else
	{
        if ( MyFuelBarrel != None )
        {
			dist= 70;
		    dir = MyFuelBarrel.location - Location;
			dir.Z=0;
			dir = Normal(Dir);
		    TrailEnd = MyFuelBarrel.Location;
        }
        else if ( MyLeakyBarrel != None )
        {
			dist= 70;
		    dir = MyLeakyBarrel.location - Location;
			dir.Z=0;
			dir = Normal(Dir);
		    TrailEnd = MyLeakyBarrel.Location;
        }
	}
	
	MyFlameTrail = spawn(class'FlameTrail',,,Location, Rotator(dir));

	//set up trail props  250units/s
	InitialBurnTime = dist / 500.0;

	MyFlameTrail.Emitters[0].StartLocationRange.X.Max = dist;
	MyFlameTrail.Emitters[0].ParticlesPerSecond = dist / 750.0 * 200.0;
	MyFlameTrail.Emitters[0].StartLocationScaleUpTime = InitialBurnTime;
	MyFlameTrail.Emitters[0].StartLocationScaleTimeLeft = InitialBurnTime;
	
	//SetTimer(dist/300.0, false);
	GotoState('Burning');

}

function DoDamage()
{
	local Actor LastHitActor;
	local vector hitloc, lasthitloc, normal;

	LastHitActor = self;
	lasthitloc = Location;

	ForEach TraceActors(class'Actor', LastHitActor, hitloc, normal, TrailEnd)
	{
		LastHitActor.TakeDamage(10, Igniter, hitloc, Vect(0,0,0),class'VGBurningDamage');
	}
}


state Burning
{
	function BeginState()
	{
		SetMultiTimer(0, InitialBurnTime, false);
		SetMultiTimer(1, 0.4, true);
		if(bHitSpot)
			SetMultiTimer(2, 15, false);

		AmbientSound=BurnSound;
		PlaySound(IgniteSound);
	}

	function MultiTimer(int slot)
	{
		switch(slot)
		{
		case 0:
			if(Next != None)
				Next.LightUp(Igniter);
			else if ( MyFuelBarrel != None )
            {
				MyFuelBarrel.Explode(None, None);
            }
            else if ( MyLeakyBarrel != None )
            {
				MyLeakyBarrel.GetBent(None);
            }
			break;
		case 1:
			DoDamage();
			break;
		case 2:
			PutOut();
			break;
		case 3:
			MyFlameTrail.Emitters[0].InitialParticlesPerSecond=0;
			MyFlameTrail.Emitters[0].ParticlesPerSecond=0;
			MyFlameTrail.Emitters[0].RespawnDeadParticles=false;
			MyFlameTrail.LifeSpan=1;
			if(Next != None)
				Next.PutOut();

			AmbientSound=None;
			Destroy();
			break;

		}
	}

	function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage )
	{
	
	}
}

function PutOut()
{
	MyFlameTrail.Emitters[0].StartLocationScaleUpTime = 0.0;
	MyFlameTrail.Emitters[0].StartLocationScaleDownTime = 2.0;
	MyFlameTrail.Emitters[0].StartLocationScaleTimeLeft = 2.0;

	SetMultiTimer(3, 2, false);

}

defaultproperties
{
     IgniteSound=Sound'PariahGameSounds.FuelBarrel.GasIgniteWhooshA'
     BurnSound=Sound'PariahGameSounds.FuelBarrel.GasBurnLoopA'
     CollisionRadius=100.000000
     CollisionHeight=10.000000
     Physics=PHYS_Falling
     SoundVolume=20
     bHidden=True
     bCollideActors=True
     bCollideWorld=True
     bProjTarget=True
     bUseCylinderCollision=True
}
