//=============================================================================
// Our default projectile type
//=============================================================================
class VGProjectile extends Projectile
	abstract;

//movement
var		float				AccelRate;			//Acceleration rate

//damage info
var		int					VehicleDamage;		//amount of damage to vehicles
var		int					PersonDamage;		//damage to people
var		float				SplashDamage;		//amount of splash damage, set to 0 for none
var	()	Sound				ExplosionSound;		//the sound when projectile explodes, if any
var		Material.ESurfaceTypes		HitSurfaceType;	//type of surface hit

var class<VGHitEffectBase> HitEffectClass;

simulated function PostBeginPlay()
{
	local vector Dir;

	Super.PostBeginPlay();

	Dir = vector(Rotation);
	Velocity = Speed * Dir;
	Acceleration = Dir * AccelRate;
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	//spawn the various special effects
	if ( Level.NetMode != NM_DedicatedServer )
	{
		SpawnTrail();
	}
}


//override these functions for the various special effects
simulated function SpawnTrail() {}
simulated function SpawnExplosion(vector HitLocation, vector HitNormal) {}


//do the splash damage
simulated function BlowUp(vector HitLocation)
{
	if(Instigator != none)
		HurtRadius(SplashDamage*Instigator.DamageScaling, DamageRadius, MyDamageType, MomentumTransfer, HitLocation, ProjOwner );
	else
		HurtRadius(SplashDamage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation, ProjOwner );
	MakeNoise(1.0);
}

//do the special effects for the impact
simulated function Explode(vector HitLocation, vector HitNormal)
{
	if ( Level.NetMode != NM_DedicatedServer )
	{
		SpawnExplosion(HitLocation, HitNormal);
	}
	if(ExplosionSound != none)
		PlaySound(ExplosionSound,,0.8);
		
    Destroy();
}

//validate touch and do all the neccessary damage calculations
simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	local vector dir;

//	log("ProcessTouch!!!!!  Other = "$Other$", Inst = "$Instigator);

	if ( Other!=Instigator && Other != none && Instigator != none/*&& !Other.IsA('Projectile') */)
	{
		dir = Vector(Rotation);
		if (Other.IsA('VGVehicle'))
		{
			//don't apply momentum if the weapon does splash damage, the splash effect will do it for us
			if(SplashDamage > 0)
			{
				Other.TakeDamage(VehicleDamage*instigator.DamageScaling,instigator,HitLocation,vect(0,0,0),MyDamageType, ProjOwner);
			}
			else
			{
				Other.TakeDamage(VehicleDamage*instigator.DamageScaling,instigator,HitLocation,MomentumTransfer*dir,MyDamageType, ProjOwner);
			}
		}
		else if(Other.IsA('Projectile'))
		{
			return;
		}
		else
		{
			//don't apply momentum if the weapon does splash damage, the splash effect will do it for us
			if(SplashDamage > 0)
				Other.TakeDamage(PersonDamage*Instigator.DamageScaling,instigator,HitLocation,0*dir,MyDamageType, ProjOwner);
			else
				Other.TakeDamage(PersonDamage*Instigator.DamageScaling,instigator,HitLocation,MomentumTransfer*dir,MyDamageType, ProjOwner);
		}
		if(SplashDamage > 0)
			BlowUp(HitLocation);
		Explode(HitLocation, dir);
	}
}

event TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	if(!bProjTarget)
		return;
}

// these are the specific combo functions/explosions should be communatative
// ie. plasma getting hit by rocket should have the same effect as a rocket getting hit by plasma

simulated function PlasmaRocketExplode(Vector HitLocation, Vector Rotation){}
simulated function PlasmaGrenadeExplode(Vector HitLocation, Vector Rotation){}
simulated function PlasmaMinigunExplode(Vector HitLocation, Vector Rotation){}
simulated function PlasmaRailExplode(Vector HitLocation, Vector Rotation){}
simulated function PlasmaSSWIGExplode(Vector HitLocation, Vector Rotation){}
simulated function PlasmaPlasmaExplode(Vector HitLocation, Vector Rotation){}

simulated function SSWIGRocketExplode(Vector HitLocation, Vector Rotation){}
simulated function SSWIGGrenadeExplode(Vector HitLocation, Vector Rotation){}
simulated function SSWIGMinigunExplode(Vector HitLocation, Vector Rotation){}
simulated function SSWIGRailExplode(Vector HitLocation, Vector Rotation){}
simulated function SSWIGSSWIGExplode(Vector HitLocation, Vector Rotation){}

simulated function RocketGrenadeExplode(Vector HitLocation, Vector Rotation){}
simulated function RocketRocketExplode(Vector HitLocation, Vector Rotation){}
simulated function RocketMinigunExplode(Vector HitLocation, Vector Rotation){}
simulated function RocketRailExplode(Vector HitLocation, Vector Rotation){}

simulated function GrenadeGrenadeExplode(Vector HitLocation, Vector Rotation){}
simulated function GrenadeMinigunExplode(Vector HitLocation, Vector Rotation){}
simulated function GrenadeRailExplode(Vector HitLocation, Vector Rotation){}

//what to do when we hit a wall
//NOTE: right now hitting a vehicle causes a the hitwall event
//this can be changed by making bBlockPlayer and bBlockActor true
//but that causes other issues at the moment.
//hack solution is to check if it's a valid touch when we hit a wall
simulated function HitWall (vector HitNormal, actor Wall)
{
	local vector HitLoc, HitNorm, TraceEnd, TraceStart;
	local Material	HitMat;
	local Actor HitActor;

	if(Wall.bStatic)
	{
		if(Wall.Texture != none)
			HitSurfaceType = Wall.Texture.SurfaceType;
		else
			HitSurfaceType = EST_Default;
		if(SplashDamage > 0)
			BlowUp(Location);
		TraceStart = Location + ExploWallOut * HitNormal;
		TraceEnd = Location + -ExploWallOut * HitNormal;
		HitActor = Trace(HitLoc, HitNorm, TraceEnd, TraceStart,,,HitMat);
//		log("HitMat = "$HitMat);
		if ( HitActor != none )
		{
			if(HitMat != none)
				HitSurfaceType = HitMat.SurfaceType;
			else
				HitSurfaceType = EST_Default;
			Explode(Location + ExploWallOut * HitNormal, HitNormal);
			//if we really hit a wall, create a decal
			if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			{
				// 6 is rocket launcher
				Level.QuickDecal( Location, HitNormal, HitActor, 50.0f, 100.0f, ExplosionDecal.default.ProjTexture, int(HitSurfaceType), 6 );
			}

			if(HitEffectClass != none && Level.NetMode != NM_DedicatedServer)
				HitEffectClass.static.SpawnHitEffect(HitActor, Location, HitNormal, self, HitMat);

				// jim: Use a QuickDecal instead...
				//Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
		}
		else
			// in some cases we seem to be getting this case...
			ProcessTouch(Wall, Location);
	}
	else
		ProcessTouch(Wall, Location);
}

defaultproperties
{
     MaxSpeed=0.000000
     ExploWallOut=20.000000
     LifeSpan=10.000000
     SoundRadius=10.000000
     TransientSoundVolume=0.000000
     TransientSoundRadius=0.000000
     SoundVolume=128
     bFixedRotationDir=True
}
