class SPPawnMilitaryHeavyGuard extends SPPawnMilitary;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

var array<Material> FaceSkins; // jim: Multiple face skins
var staticmesh HelmetCached; // jim: Randomized helmet on or off

simulated function PostBeginPlay()
{
    local float chance;

    // Randomize helmet
    chance = RandRange( 0, 100 );

    if ( chance < 85 )
    {
        Helmet = HelmetCached;
    }

	SetHelmet();

    // jim: Randomize face skin.
	chance = RandRange( 0, 100 );

    if ( chance < 50 )
    {
        SetSkin( 1, FaceSkins[0] );
    }
    else
    {
        if ( IsOnConsole() )
            SetSkin( 1, FaceSkins[1] );
        else
            SetSkin( 1, Texture'PariahCharacterTextures.guard_face2b' );

    }

	Super.PostBeginPlay();
}

defaultproperties
{
     HelmetCached=StaticMesh'PariahCharacterMeshes.Helmets.HeavyGuard_Helmet'
     FaceSkins(0)=Texture'PariahCharacterTextures.HeavyGuard.guard_face2a'
     FaceSkins(1)=Texture'PariahCharacterTextures.HeavyGuard.guard_face2bs'
     AIRoleClass=Class'PariahSPPawns.SPAIRoleDefensive'
     ExclamationClass=Class'PariahSPPawns.SPMilitaryExclaim'
     disposition=D_Brave
     bMayDive=False
     Health=150
     ControllerClass=Class'PariahSPPawns.SPAIRocketLauncher'
     race=R_Guard
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.HeavyGuard_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem125
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem125'
     Skins(0)=Texture'PariahCharacterTextures.HeavyGuard.guard_body2'
     bAffectedByEnhancedVision=27
}
