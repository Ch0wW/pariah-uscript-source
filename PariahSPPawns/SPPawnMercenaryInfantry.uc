class SPPawnMercenaryInfantry extends SPPawnMerc;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

var staticmesh Helmet1;
var staticmesh Helmet2;

simulated function PostBeginPlay()
{
   	local float chance;
    // jim: Randomize helmet selection.
	chance = RandRange( 0, 100 );

    if ( chance > 50 )
    {
        Helmet=Helmet1;
	    SetHelmet();
        HelmetActor.HelmetType = 1;
    }
    else
    {
        Helmet=Helmet2;
	    SetHelmet();
        HelmetActor.HelmetType = 2;
    }

	Super.PostBeginPlay();
}

event PreLoadData()
{
	Super.PreLoadData();
	PreLoad( Helmet1 );
	PreLoad( Helmet2 );
}

defaultproperties
{
     Helmet1=StaticMesh'PariahCharacterMeshes.Helmets.MercInfantry_Helmet'
     Helmet2=StaticMesh'PariahCharacterMeshes.Helmets.merchelmet2'
     AIRoleClass=Class'PariahSPPawns.SPAIRoleAggressive'
     ExclamationClass=Class'PariahSPPawns.SPMercExclaim'
     ControllerClass=Class'PariahSPPawns.SPAIAssaultRifle'
     race=R_Clan
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.MercInfantryClanA01_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem120
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem120'
     bNeedPreLoad=True
}
