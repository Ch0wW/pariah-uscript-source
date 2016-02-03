class GrenadeProjectile extends VGProjectile;

const SPIN_SPEED = 60000;

var () float        explodeTime;	// length of grenade's fuse
var () float		minExplodeTime;	// minimum fuse time
var () float		maxExplodeTime;	// maximum chargeable time
var    float		blowUpTimer;	// 'cause the Timer method doesn't seem to want to talk to the client...

var () float		spinDelay;		// delay after firing before starting to spin grenade
var    float		delayTime;
var	   bool			bStartSpin;
var    bool			bPowerUp;
var	   bool			bForceExplode;	// force the grenade to explode

var bool            bHitWater;

var Emitter		    Trail;
var AvoidMarker         FearMarker;
var	() class<Emitter>	TrailClass;
var	() class<Actor>		ExplosionClass;
var	() class<Actor>		ExplosionDistortionClass;

var ()	float			EffectRadius;

var	int					HitWallCount;

var rotator				angularRotVel;	//speed at which it spins in each axis (xmatt)

var bool                bArmed;

var() GrenadeLight      GLight;
var   float             LastHitEffectTime;
var() class<GrenadeLight>   GrenadeLightType; 

replication
{
    reliable if (Role==ROLE_Authority)
        bForceExplode, bArmed;
}

simulated function PostBeginPlay()
{
	local vector X;

	Super.PostBeginPlay();

	if ( Role == ROLE_Authority )
	{
		X = Vector(Rotation);
		Velocity = Speed * X + vect(0,0,1) * Speed * 0.05;

		bHitWater = false;
		if ( Instigator.HeadVolume.bWaterVolume )
		{
			bHitWater = true;
			Velocity = 0.6*Velocity;			
		}
	}

	if ( Level.NetMode != NM_DedicatedServer )
    {
        if(TrailClass != none) 
        {
		    Trail = Spawn(TrailClass,self);
        }
        GLight = Spawn(GrenadeLightType, self);
    }
}


simulated function BlowUp(vector HitLocation)
{
	local GamePlayDevices MPHD;
	local vector Momen;

	foreach RadiusActors(class'GameplayDevices',MPHD, 900)
	{
		if (MPHD.IsA('MultiPieceHavokDestroyableMesh'))
		{
			Momen = Normal(MPHD.Location - Location) * 2000;
			MPHD.TakeDamage(PersonDamage*2, Instigator, Location, Momen, class'RunOver' );
		}
	}

	Super.BlowUp(HitLocation);
}

simulated function Destroyed()
{
    Super.Destroyed();

	if(Trail != none)
	{
		Trail.Kill();
	    if(Role < ROLE_Authority)
        {
            SpawnExplosion(Location, vect(0,0,1));
	        if(ExplosionSound != none)
		        PlaySound(ExplosionSound,,0.8);
        }
    }

	if(GLight != None)
	{
	    GLight.Destroy();
	}

    if(FearMarker != None)
    {
        FearMarker.Destroy();
    }
}

simulated function SpawnExplosion(vector HitLocation, vector HitNormal)
{
	local vector v;
	local rotator r;

	v = HitLocation+HitNormal*ExploWallOut;
	r = Rotator(HitNormal);

	if(ExplosionClass != none)
		spawn(ExplosionClass,,,v,r);

	if( ExplosionDistortionClass != None )
		spawn(ExplosionDistortionClass,,,v,r);

	if(Trail != none)
		Trail.Kill();

	if(GLight != none)
		GLight.Destroy();
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	local rotator R;
	
//	if (Trail!=None)
//	{
//		Trail.Emitters[0].ParticlesPerSecond = 0;
//		Trail.Emitters[0].InitialParticlesPerSecond = 0;
//	}


	//Note: The object should have a constant restitution coefficient but we do that to have a different behavior
	//		when it hits a wall and a flat surface
	if( HitNormal.Z > 0.7 )
	{
		Velocity = 0.25*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);
    }
	else
	{
		Velocity = 0.2*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);
	}

	HitWallCount++;
	
	if ( Level.NetMode != NM_DedicatedServer && Level.TimeSeconds > LastHitEffectTime + 0.2)
	{
	    class'VGAssaultHitEffects'.static.SpawnHitEffect(Wall, Location, HitNormal, Instigator, Wall.Texture);
	    LastHitEffectTime = Level.TimeSeconds;
    }

	if ( VSize(Velocity) < 80 && Physics == PHYS_Falling ) 
	{
		bBounce = false;
		//Stop it from rotating
		SetRotation( R );
		bRotateToDesired = false;
        SetPhysics(PHYS_None);
	}
	
	if(Role == ROLE_Authority && HitWallCount == 1)
	{
	    bArmed = true;
        if(GLight != None)
            GLight.ArmTimer(explodeTime);
    }
}

simulated function PhysicsVolumeChange( PhysicsVolume NewVolume )
{
	if ( !NewVolume.bWaterVolume || bHitWater ) 
		return;

	bHitWater = True;
	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (Trail!=None) Trail.Kill();
	}
	Velocity = 0.6*Velocity;
}


function SpawnFearMarker()
{
	if(FearMarker == none)
		FearMarker = spawn( Level.Game.FearMarkerClass );
	else
		FearMarker.SetLocation(Location);
    FearMarker.SetCollisionSize(500,200); 
    FearMarker.StartleBots();
    FearMarker.StartleOtherThings();
    
}

simulated function Landed( vector HitNormal )
{
    SpawnFearMarker();
    HitWall( HitNormal, None );
}


simulated function ProcessTouch( actor Other, vector HitLocation )
{
	if(Role == ROLE_Authority && Other != instigator)
	{
        if(false && Other.IsA('ShieldActor'))
        {
            HitWall(Vector(Other.Rotation), None); // bounce of personal shields
        }
        else
        {
	        if(Other.bProjTarget || Other.bWorldGeometry && !bArmed)
	        {
	            bArmed = true;
            }
		    Super.ProcessTouch(Other, HitLocation);
        }
	}
}

simulated event PostNetReplicate()
{
	if( bForceExplode )
	{
		BlowUp(Location);
		Explode(Location, Vect(0, 0, 1) );
	}
}

simulated function Timer()
{
    if(Role == ROLE_Authority)
    {
	    BlowUp(Location);
	    Explode(Location,Vect(0,0,1) );
    }
}


// proximity grenades do stuff in tick
simulated function Tick(float dt)
{
	Super.Tick(dt);
    
	if(!bStartSpin && delayTime >= spinDelay) 
	{
		RandSpin(50000);
		bStartSpin = true;
	}
	else
	{
		delayTime += dt;
	}

	if(bForceExplode) 
	{
		BlowUp(Location);
		Explode(Location, Vect(0, 0, 1) );
		return;
	}

	if(bArmed) 
	{
	    if(GLight != None && GLight.LifeSpan == 0.0)
	    {
	        GLight.ArmTimer(explodeTime);
	    }
		blowUpTimer += dt;
		if(blowUpTimer >= explodeTime)
		{
			Timer();
        }
		return;
	}
}

function SetParams(int VehicleDmg, int PersonDmg, float SplashDmg, float DmgRadius, float Momentum)
{
	VehicleDamage = VehicleDmg;
	PersonDamage = PersonDmg;
	SplashDamage = SplashDmg;
	DamageRadius = DmgRadius;
	MomentumTransfer = Momentum;
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);
	if(Role == ROLE_Authority && Damage > 10) 
	{
		// the grenade has stopped bouncing...  allow it to explode
		Blowup(HitLocation);
		Explode(HitLocation, vect(0, 0, 1) );
		
	}
	else if(Role == ROLE_Authority && !bArmed)
	{
	    bArmed = true;
	}
}

defaultproperties
{
     explodeTime=3.000000
     minExplodeTime=5.000000
     maxExplodeTime=8.000000
     spinDelay=0.080000
     EffectRadius=1000.000000
     TrailClass=Class'VehicleEffects.GrenadeMagTrail'
     ExplosionClass=Class'VehicleEffects.GrenadeExplosion'
     ExplosionDistortionClass=Class'VehicleEffects.ParticleRocketExplosionSmallDistort'
     GrenadeLightType=Class'VehicleEffects.GrenadeLight'
     VehicleDamage=50
     PersonDamage=20
     SplashDamage=100.000000
     ExplosionSound=Sound'PariahWeaponSounds.expl_grenade'
     Speed=1800.000000
     MaxSpeed=3000.000000
     DamageRadius=550.000000
     MomentumTransfer=5000.000000
     MyDamageType=Class'VehicleWeapons.GrenadeLauncherDamage'
     bSwitchToZeroCollision=True
     LifeSpan=30.000000
     DrawScale=0.800000
     CollisionRadius=6.000000
     CollisionHeight=6.000000
     NetPriority=1.000000
     NetUpdateFrequency=20.000000
     StaticMesh=StaticMesh'PariahWeaponMeshes.Projectiles.w_granade_mesh'
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
     bOrientOnSlope=True
     bNetTemporary=False
     bProjTarget=True
     bBounce=True
}
