class SPPawnMilitaryLightGuard extends SPPawnMilitary;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

var array<Material> FaceSkins; // jim: Multiple face skins
var staticmesh HelmetCached; // jim: Randomized helmet on or off

simulated function PostBeginPlay()
{
   	local float chance;

    // Randomize helmet
    chance = RandRange( 0, 100 );

    if ( chance < 75 )
    {
        Helmet = HelmetCached;
    }

    SetHelmet();

    // jim: Randomize face skin.
	chance = RandRange( 0, 100 );

    if ( chance < 33 )
    {
        if ( IsOnConsole() )
            SetSkin( 1, FaceSkins[2] );
        else
            SetSkin( 1, Texture'PariahCharacterTextures.Stubbs.Steve_Head3' );
    }
    else if ( chance < 66 )
    {
        if ( IsOnConsole() )
            SetSkin( 1, FaceSkins[1] );
        else
            SetSkin( 1, Texture'PariahCharacterTextures.Stubbs.Steve_Head4' );
    }
    else
    {
        if ( IsOnConsole() )
            SetSkin( 1, FaceSkins[0] );
        else
            SetSkin( 1, Texture'PariahCharacterTextures.Stubbs.Stubbs_Head2' );
    }

	Super.PostBeginPlay();
}

defaultproperties
{
     HelmetCached=StaticMesh'PariahCharacterMeshes.Helmets.Stubbs_Helmet'
     FaceSkins(0)=Texture'PariahCharacterTextures.Stubbs.stubbs_head2s'
     FaceSkins(1)=Texture'PariahCharacterTextures.Stubbs.steve_head3s'
     FaceSkins(2)=Texture'PariahCharacterTextures.Stubbs.steve_head4s'
     AIRoleClass=Class'PariahSPPawns.SPAIRoleAggressive'
     ExclamationClass=Class'PariahSPPawns.SPMilitaryExclaim'
     disposition=D_Cautious
     Health=75
     ControllerClass=Class'PariahSPPawns.SPAIPlasmaGun'
     race=R_Guard
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.Stubbs_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem126
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem126'
     Skins(0)=Texture'PariahCharacterTextures.Stubbs.Stubbs_Body'
}
