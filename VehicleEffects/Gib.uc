class Gib extends Actor
	abstract;

//stole this from UT2, edited to appease my will!!

var() float DampenFactor;
var() class<xEmitter> TrailClass;
var() xEmitter Trail;



simulated function Destroyed()
{
    if( Trail != None )
        Trail.mRegen = false;

	Super.Destroyed();
}

simulated final function RandSpin(float spinRate)
{
	DesiredRotation = RotRand();
	RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
	RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
	RotationRate.Roll = spinRate * 2 *FRand() - spinRate;	
}

simulated function Landed( Vector HitNormal )
{
    HitWall( HitNormal, None );
}
  
simulated function HitWall( Vector HitNormal, Actor Wall )
{
    local float Speed;

    Velocity = DampenFactor * ((Velocity dot HitNormal) * HitNormal*(-2.0) + Velocity);
    RandSpin(100000);
    Speed = VSize(Velocity);

/* TODO
    if ( Level.NetMode != NM_DedicatedServer )
        PlaySound(ImpactSound, SLOT_Misc, 1.5 );
*/
    if( Speed < 20 ) 
    {
        bBounce = False;
        SetPhysics(PHYS_None);
    }
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation, Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage )
{
	SetPhysics(PHYS_Falling);
	Velocity += momentum/Mass;
	If ( Damage > 15 )
		Destroy();
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();

    Trail = Spawn(TrailClass, self,, Location, Rotation);
    Trail.SetPhysics( PHYS_Trailer );

    Trail.LifeSpan = 1.5;

    RandSpin( 64000 );

	SetTimer( 5.0, false );
}

simulated function Timer()
{
    if( !PlayerCanSeeMe() )
        Destroy();
    else
		SetTimer( 2.0, false );
}

defaultproperties
{
     DampenFactor=0.500000
     TrailClass=Class'VehicleEffects.BloodJet'
     Mass=30.000000
     Physics=PHYS_Falling
     RemoteRole=ROLE_None
     bCollideWorld=True
     bUseCylinderCollision=True
     bBounce=True
     bFixedRotationDir=True
}
