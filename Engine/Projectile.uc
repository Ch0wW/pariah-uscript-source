//=============================================================================
// Projectile.
//
// A delayed-hit projectile that moves around for some time after it is created.
//=============================================================================
class Projectile extends Actor
	abstract
	native;

//-----------------------------------------------------------------------------
// Projectile variables.

// Motion information.
var		float   Speed;               // Initial speed of projectile.
var		float   MaxSpeed;            // Limit on speed of projectile (0 means no limit)
var		float	TossZ;
var		bool	bSwitchToZeroCollision; // if collisionextent nonzero, and hit actor with bBlockNonZeroExtents=0, switch to zero extent collision

// Damage attributes.
var   float    Damage; 
var	  float	   DamageRadius;        
var   float	   MomentumTransfer; // Momentum magnitude imparted by impacting projectile.
var   class<DamageType>	   MyDamageType;

// Projectile sound effects
var   sound    SpawnSound;		// Sound made when projectile is spawned.
var   sound	   ImpactSound;		// Sound made when projectile hits something.

// explosion effects
var   class<Projector> ExplosionDecal;
var   float		ExploWallOut;	// distance to move explosions out from wall

var Controller ProjOwner;

//==============
// Encroachment
function bool EncroachingOn( actor Other )
{
	if ( (Other.Brush != None) || (Brush(Other) != None) )
		return true;
		
	return false;
}

//==============
// Touching
simulated singular function Touch(Actor Other)
{
	local actor HitActor;
	local vector HitLocation, HitNormal, VelDir;
	local bool bBeyondOther;
	local float BackDist, DirZ;

	if ( Other.bProjTarget || (Other.bBlockActors && Other.bBlockPlayers) )
	{
		if(Other.IsA('GrenadeProjectile') && !IsA('GrenadeProjectile') ) {
			Projectile(Other).BlowUp(Other.Location);
			Projectile(Other).Explode(Other.Location, vect(0, 0, 1) );
			return;
		}

		if ( Velocity == vect(0,0,0) || !Other.IsA('Pawn') ) // sjs - test!
		{
			ProcessTouch(Other,Location);
			return;
		}

        // sjs - this breaks on movers, fluids, etc.
		
		//get exact hitlocation - trace back along velocity vector
		bBeyondOther = ( (Velocity Dot (Location - Other.Location)) > 0 );
		VelDir = Normal(Velocity);
		DirZ = sqrt(VelDir.Z);
		BackDist = Other.CollisionRadius * (1 - DirZ) + Other.CollisionHeight * DirZ;
		if ( bBeyondOther )
			BackDist += VSize(Location - Other.Location);
		else
			BackDist -= VSize(Location - Other.Location);

	 	HitActor = Trace(HitLocation, HitNormal, Location, Location - 1.1 * BackDist * VelDir, true);
		if (HitActor == Other)
			ProcessTouch(Other, HitLocation); 
		else if ( bBeyondOther )
			ProcessTouch(Other, Other.Location - Other.CollisionRadius * VelDir);
		else
			ProcessTouch(Other, Location);
	}
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if ( Other != Instigator )
		Explode(HitLocation,Normal(HitLocation-Other.Location));
}

simulated function HitWall (vector HitNormal, actor Wall)
{
	if ( Role == ROLE_Authority )
	{
		if ( Mover(Wall) != None )
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);

		MakeNoise(1.0);
	}
	Explode(Location + ExploWallOut * HitNormal, HitNormal);
	if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
		Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
}

simulated function BlowUp(vector HitLocation)
{
	HurtRadius(Damage,DamageRadius, MyDamageType, MomentumTransfer, HitLocation, ProjOwner );
	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	Destroy();
}

simulated final function RandSpin(float spinRate)
{
	DesiredRotation = RotRand();
	RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
	RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
	RotationRate.Roll = spinRate * 2 *FRand() - spinRate;	
}

defaultproperties
{
     MaxSpeed=2000.000000
     TossZ=100.000000
     DamageRadius=220.000000
     MyDamageType=Class'Engine.DamageType'
     LifeSpan=140.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     NetPriority=2.500000
     Texture=Texture'Engine.S_Camera'
     Physics=PHYS_Projectile
     DrawType=DT_Mesh
     RemoteRole=ROLE_SimulatedProxy
     SoundVolume=0
     bAcceptsProjectors=False
     bNetTemporary=True
     bReplicateInstigator=True
     bNetInitialRotation=True
     bUnlit=True
     bGameRelevant=True
     bCollideActors=True
     bCollideWorld=True
     bUseCylinderCollision=True
}
