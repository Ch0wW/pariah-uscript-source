class SimpleHavokDestroyableMesh extends SimpleDestroyableMesh
	placeable
	hidecategories(Havok);

// these are the variables that should be adjusted to control Havok properties of actor
// - don't create a HavokParams!
//
var(HavokProps) float		HMass;
var(HavokProps) float		HFriction;
var(HavokProps) float		HRestitution;
var(HavokProps) float		HLinearDamping;
var(HavokProps) float		HAngularDamping;
var(HavokProps) vector		HStartLinVel;
var(HavokProps) vector		HStartAngVel;
var(HavokProps) float		HGravScale;
var(HavokProps) float		HBuoyancy;
var(HavokProps) float       HImpactThreshold;

function PostBeginPlay()
{
    Super.PostBeginPlay();
    if ( Physics == PHYS_Havok && HMass > 0 )
    {
		HSetMass( HMass );
		HSetFriction( HFriction );
		HSetRestitution( HRestitution );
		HSetDampingProps( HLinearDamping, HAngularDamping );
		HavokParams(HParams).GravScale = HGravScale;
		HavokParams(HParams).Buoyancy = HBuoyancy;
        if ( HImpactThreshold > 0 )
        {
            HavokParams(HParams).ImpactThreshold = HImpactThreshold;
        }
    }
}

function GetBent(Pawn instigator,optional Controller ProjOwner)
{
	if ( HMass > 0 )
	{
		SetPhysics(PHYS_Havok);
		HWake();
		HSetMass( HMass );
		HSetFriction( HFriction );
		HSetRestitution( HRestitution );
		HSetDampingProps( HLinearDamping, HAngularDamping );
		HSetRBVel( HStartLinVel >> Rotation, HStartAngVel >> Rotation );
		HavokParams(HParams).GravScale = HGravScale;
		HavokParams(HParams).Buoyancy = HBuoyancy;
        if ( HImpactThreshold > 0 )
        {
            HavokParams(HParams).ImpactThreshold = HImpactThreshold;
        }
	}
	Super.GetBent(instigator,ProjOwner);
}


function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum,
					 class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	local vector impulse;

	if(Physics==PHYS_Havok)
	{

		if( damageType.static.GetHavokHitImpulse( momentum, impulse ) )
		{
			HAddImpulse(impulse, hitlocation);
		}
	}

	Super.TakeDamage(Damage,eventinstigator,hitlocation,momentum,damagetype,projowner,bsplashdamage);
}

defaultproperties
{
     HMass=100.000000
     HFriction=0.300000
     HRestitution=0.500000
     HLinearDamping=0.200000
     HAngularDamping=0.200000
     HGravScale=1.500000
     HBuoyancy=0.500000
     HImpactThreshold=256.000000
}
