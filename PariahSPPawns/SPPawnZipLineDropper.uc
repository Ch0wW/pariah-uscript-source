/*
	A pawn that comes down from the offensive dropship using a zip line
	xmatt
*/
class SPPawnZipLineDropper extends SPPawnMilitary;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

var bool	bDetached;
var	name	UnhookingAnim;

/*
	This is from the dropship zip line droppers Purpose is to handle hitting the terrain or a vehicle
	xmatt
*/

simulated function PreBeginPlay()
{
	// pawn won't spawn properly if collision is on
	SetCollision( false, false, false);
}

simulated function Landed( vector HitNormal )
{
	local vector hitLoc;
	local vector hitNorm;
	local vector TraceStart;
	local vector snappedLoc;
	
	//log("landed with normal " $ HitNormal );

    if( !bDetached )
	{
		//Snap it to the terrain
		TraceStart = Location;
		Trace( hitLoc, hitNorm, TraceStart - vect(0,0,1000), TraceStart, false );
   		snappedLoc = hitLoc + vect(0,0,25);
		snappedLoc.Z += CollisionHeight;
		SetLocation( snappedLoc );
		
		SetCollision( true, true, true );
		bCollideWorld = true;
		SetPhysics( PHYS_Walking );
		PlayAnim( UnhookingAnim, , 0.1, 1 );
		AnimBlendToAlpha( 1, 0, 0.4);
		bDetached = true;
	}    
   
}

simulated function PostBeginPlay()
{
	SetHelmet();
	Super.PostBeginPlay();
}

function bool MaySmoke()
{
    return false;
}

defaultproperties
{
     UnhookingAnim="LandOffLine"
     AIRoleClass=Class'PariahSPPawns.SPAIRoleAggressive'
     ExclamationClass=Class'PariahSPPawns.SPMilitaryExclaim'
     disposition=D_Cautious
     Helmet=StaticMesh'PariahCharacterMeshes.Helmets.Stubbs_Helmet'
     Health=75
     ControllerClass=Class'PariahSPPawns.SPAIPlasmaGun'
     race=R_Guard
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.Stubbs_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem127
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem127'
     Skins(0)=Texture'PariahCharacterTextures.Stubbs.Stubbs_Body'
     Skins(1)=Texture'PariahCharacterTextures.Stubbs.Stubbs_Head'
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
}
