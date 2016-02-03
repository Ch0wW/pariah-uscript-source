class SPPawnShroudBlocker extends SPShieldedPawn;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

var ShieldActor ShieldB;
var() staticmesh ShieldMeshB;

function SetupShield()
{
    Super.SetupShield();
    Shield.HitEffectClass = class'ShroudShieldHitEffect';
    
    SetupShieldB();
    //If ShieldB has collision on, it bumps the player around since they're not attached.
    ShieldB.SetCollision(false, false, false);
}
function SetupShieldB()
{
    if ( ShieldB == None )
	{
		ShieldB = Spawn(ShieldClass,self);
	}

	// can't attach ShieldB to the skeleton because it uses a distortion affect
	// and that doesn't work when the actor is attached to a skeletal mesh
	//
	ShieldB.SetStaticMesh(ShieldMeshB);
    ShieldB.Init(self);
}

event Tick( float dt )
{
	// since the distortion shield isn't attached, update position/rotation manually
	//
	if(ShieldB != None && Shield != None)
	{
	    ShieldB.SetLocation( Shield.Location );
	    ShieldB.SetRotation( Shield.Rotation );
    }
    Super.Tick(dt);
}

function KnockOffShield()
{
	if ( Shield != None )
	{
		Shield.Destroy();
		Shield = None;
	}
    if ( ShieldB != None )
	{
		ShieldB.Destroy();
		ShieldB = None;
	}
}

function bool MaySmoke()
{
    return false;
}

defaultproperties
{
     ShieldMeshB=StaticMesh'PariahGametypeMeshes.ShieldS.shroud_shield'
     ShieldMesh=StaticMesh'PariahGametypeMeshes.ShieldS.shroud_shield_frame'
     ShieldRelativeLocation=(Y=10.000000)
     PawnSkill=5
     AIRoleClass=Class'PariahSPPawns.SPAIRoleShield'
     disposition=D_Cautious
     bDropNothingOnDeath=True
     Health=75
     ControllerClass=Class'PariahSPPawns.SPAIShield'
     race=R_Shroud
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.ShroudBlocker_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem130
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem130'
}
