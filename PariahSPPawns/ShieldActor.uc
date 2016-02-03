class ShieldActor extends Actor;

var SPShieldedPawn myPawn;
var class<Emitter> HitEffectClass;

function Init(SPShieldedPawn p)
{
    myPawn = p;
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
    if(EventInstigator != myPawn)
        myPawn.NotifyShieldHit();

    if(HitEffectClass != None)
    {
        spawn( HitEffectClass, self, , HitLocation, Rotation);
    }
}


event TornOff()
{
	//Velocity = vect(0,0,150) + 150 * VRand();
	//if ( Base != None )
	//{
	//	Velocity = 1.2 * Base.Velocity + Velocity;
	//	if( bUseLightingFromBase )
	//	{
	//		bUnlit = Base.bUnlit;
	//		AmbientGlow = Base.AmbientGlow;
	//	}
	//}
	//LifeSpan = 10;
	//// FIXME - set location to bone location to be safe?
	//SetPhysics(PHYS_Havok); //FIXME Karma?
	
    local RuntimeHavokActor	piece;
    
    piece = Spawn( class'RuntimeHavokActor', self, , Location, Rotation );
	`log( "JM: spawning RuntimeHavokActor"@piece@"at l="@Location@",r="@rotation);
	
	if(piece != None)
	{
		//piece.bFuckPaths = bFuckPaths;
	    if(myPawn != None)
	    {
	        piece.LifeSpan = myPawn.LifeSpan;
	        piece.SetStaticMesh( myPawn.ShieldMesh );
        }
        else
        {
	        piece.SetStaticMesh( StaticMesh );
        }
	    piece.bCanCrushPawns = false;
		piece.bDisableKarmaEncroacher=true;
	    piece.CrushSpeed = 2000.0f;
	    piece.HSetMass( 50.0f );

	    // currently all these piece properties are the same as this actor
	    //
	    piece.HSetFriction( 0.3f );
	    piece.HSetRestitution( 0.5f );
	    piece.HSetDampingProps( 0.2f, 0.2f );
	    //HSetRBVel( HStartLinVel >> Rotation, HStartAngVel >> Rotation );
	    HavokParams(piece.HParams).GravScale = 1.5f;
	    HavokParams(piece.HParams).Buoyancy = 0.5f;
	    HavokParams(piece.HParams).Mass = 151;
        HavokParams(piece.HParams).ImpactThreshold = 512;
        piece.ImpactSound = Sound'HavokObjectSounds.BarrelFalling.BarrelFallRandom';
        piece.ImpactSoundVolScale = 2048.0f;
	    piece.HWake(); 	    
	}

    // Hide the old piece
	SetBase(None);
	bCollideWorld = false;
	SetCollision(false,false,false);
	bProjTarget = false;
	bHidden = true;
	bTearOff = true;
}

defaultproperties
{
     DrawType=DT_StaticMesh
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
}
