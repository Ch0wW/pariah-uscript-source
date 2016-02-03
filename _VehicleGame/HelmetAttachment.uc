class HelmetAttachment extends InventoryAttachment;

// jim: HelmetType - 0 is default.  1 is shatter.  2 is no fall off.
var int HelmetType;

event TornOff()
{
	Velocity = vect(0,0,150) + 150 * VRand();
	if ( Base != None )
	{
		Velocity = 1.2 * Base.Velocity + Velocity;
		if( bUseLightingFromBase )
		{
			bUnlit = Base.bUnlit;
			AmbientGlow = Base.AmbientGlow;
		}
	}
	LifeSpan = 10;
	bTearOff = true;

    // jim: If it is the merc helmet we want it to shatter.
    if ( HelmetType == 1 )
    {
        spawn( class 'MercHelmetShatter', Owner );
	    bCollideWorld = false;
        SetCollision(false,false,false);
        bHidden = true;
    }
    else
    {
	    // FIXME - set location to bone location to be safe?
	    SetBase(None);
	    SetPhysics(PHYS_Falling); //FIXME Karma?
	    bCollideWorld = true;
	    SetCollision(true,false,false);
	    bProjTarget = true;
	    RotationRate = rot(65535,65535,65535) * (0.3 + 0.7 * FRand());
	    DesiredRotation = RotRand(true);
	    bHidden = false;
    }

}

simulated function HitWall(vector HitNormal, actor Wall)
{
	local float speed;
	
	Velocity = 0.8 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	Velocity.Z = FMin(Velocity.Z * 0.8, 700);
	speed = VSize(Velocity);
	if ( speed < 120 )
	{
		bBounce = false;
		Disable('HitWall');
	}
	// PlaySound(HitSounds[Rand(2)]); //FIXME need sound
	RotationRate = rot(65535,65535,65535) * (0.3 + 0.7 * FRand());
	DesiredRotation = RotRand(true);
}

simulated event Landed(vector HitNormal)
{
	// PlaySound(HitSounds[Rand(2)]); //FIXME need sound
	RotationRate = rot(65535,65535,65535);
	SetPhysics(PHYS_Rotating);
	bFixedRotationDir = false;
	DesiredRotation = rot(0,0,0);
	DesiredRotation.Yaw = Rotation.Yaw;
}

simulated event EndedRotation()
{
	if ( Physics == PHYS_Rotating )
		SetPhysics(PHYS_None);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner,
						optional bool bSplashDamage )
{
	if ( Base != None )
		return;
	SetPhysics(PHYS_Falling);
	bFixedRotationDir = true;
	RotationRate = rot(65535,65535,65535) * (0.3 + 0.7 * FRand());
	DesiredRotation = RotRand(true);
	Velocity = momentum + vect(0,0,100);
	LifeSpan = FMax(LifeSpan,6);
}

defaultproperties
{
     CollisionRadius=11.000000
     CollisionHeight=11.000000
     RelativeRotation=(Pitch=49152)
     DrawType=DT_StaticMesh
     bOnlyDrawIfAttached=False
     bOrientOnSlope=True
     bBounce=True
     bFixedRotationDir=True
     bRotateToDesired=True
}
