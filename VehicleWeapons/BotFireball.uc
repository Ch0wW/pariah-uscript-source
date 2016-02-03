class BotFireball extends VGProjectile;

var	() class<Emitter>	TrailClass;
var	() class<Actor>		ExplosionClass;
var	() class<Actor>		ExplosionDistortionClass;

var FlameThrowerFire fireTrail;

simulated function Destroyed()
{
	Super.Destroyed();
	if(fireTrail != none)
		fireTrail.Kill();
	fireTrail = none;
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	if(Other.IsA('VGPawn') && Other != Instigator) {
		VGPawn(Other).SetOnFire();
		VGPawn(Other).FireInstigator = Instigator;
	}

	Super.ProcessTouch(Other, HitLocation);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	Super.Explode(HitLocation, HitNormal);

	if(fireTrail != none)
		fireTrail.Kill();
	fireTrail = none;
}

simulated function Landed( vector HitNormal )
{
	local vector HitLoc, HitNorm, TraceEnd, TraceStart;
	local Material	HitMat;
	local Actor HitActor;

    Explode(HitNormal, vect(0, 0, 1) );

	TraceStart = Location + ExploWallOut * HitNormal;
	TraceEnd = Location + -ExploWallOut * HitNormal;
	HitActor = Trace(HitLoc, HitNorm, TraceEnd, TraceStart,,,HitMat);

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
	}
}

simulated function SpawnTrail()
{
	if(TrailClass != none) {
		fireTrail = FlameThrowerFire(Spawn(TrailClass, self) );
		if(fireTrail != none)
			fireTrail.SetBase(self);
	}
}

defaultproperties
{
     TrailClass=Class'VehicleEffects.FlameThrowerFire'
     VehicleDamage=20
     PersonDamage=20
     SplashDamage=40.000000
     Speed=1800.000000
     MaxSpeed=3000.000000
     DamageRadius=350.000000
     MyDamageType=Class'VehicleWeapons.GrenadeLauncherDamage'
     ExplosionDecal=Class'VehicleEffects.ExplosionMark'
     CollisionRadius=8.000000
     CollisionHeight=12.000000
     StaticMesh=StaticMesh'PariahWeaponEffectsMeshes.PulseRifle.plasma_projectile'
     Physics=PHYS_Falling
     DrawType=DT_StaticMesh
}
