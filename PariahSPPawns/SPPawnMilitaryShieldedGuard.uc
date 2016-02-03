class SPPawnMilitaryShieldedGuard extends SPShieldedPawn;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

var array<Material> FaceSkins; // jim: Multiple face skins

simulated function PostBeginPlay()
{
    local float chance;

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
     FaceSkins(0)=Texture'PariahCharacterTextures.HeavyGuard.guard_face2a'
     FaceSkins(1)=Texture'PariahCharacterTextures.HeavyGuard.guard_face2bs'
     PawnSkill=3
     AIRoleClass=Class'PariahSPPawns.SPAIRoleShield'
     ExclamationClass=Class'PariahSPPawns.SPMilitaryExclaim'
     disposition=D_Brave
     bMayDive=False
     Helmet=StaticMesh'PariahCharacterMeshes.Helmets.HeavyGuard_Helmet'
     Health=150
     ControllerClass=Class'PariahSPPawns.SPAIShield'
     race=R_Guard
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.HeavyGuard_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem129
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem129'
     Skins(0)=Texture'PariahCharacterTextures.HeavyGuard.guard_body2'
     bAffectedByEnhancedVision=27
}
