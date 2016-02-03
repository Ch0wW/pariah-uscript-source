// Havok actor that imparts forces on the underlying body (s) when shot etc
// It also initializes the Actor fields to reasonable defaults for a 
// rigid body constructed from a StaticMesh.

class HavokActor extends Actor
	native
	placeable;

var (Havok)		bool		bAcceptsShotImpulse;

var (Havok)		bool		bCanCrushPawns;
var (Havok)		float		CrushSpeed;

var (Sound)     Sound       ImpactSound;
var (Sound)     float       ImpactSoundVolScale;

// this will only be called if the impact is greater than it's HParam's ImpactThresold 
//
simulated event HImpact(actor other, vector pos, vector ImpactVel, vector ImpactNorm, Material HitMaterial)
{
	local float Vol;

    if ( ImpactSound != None )
    {
	    Vol = VSize(ImpactVel);
        if ( ImpactSoundVolScale > 0 )
        {
            Vol /= ImpactSoundVolScale;
        }
	    PlaySound(ImpactSound,,Vol);
    }
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, 
					Vector momentum, class<DamageType> damageType,
					optional Controller ProjOwner, optional bool bSplashDamage)
{
	local vector impulse;
	
	if( bAcceptsShotImpulse && damageType.static.GetHavokHitImpulse( momentum, impulse ) )
	{
		HAddImpulse(impulse, hitlocation);
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	HWake();
}

defaultproperties
{
     CrushSpeed=300.000000
     bAcceptsShotImpulse=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     Physics=PHYS_Havok
     DrawType=DT_StaticMesh
     RemoteRole=ROLE_None
     bNoDelete=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
     bBlockKarma=True
     bEdShouldSnap=True
}
