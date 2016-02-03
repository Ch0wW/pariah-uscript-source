//=============================================================================
// xRedFlagBase.
//=============================================================================
class xRedFlagBase extends xRealCTFBase
	placeable;

#exec OBJ LOAD FILE=EmitterTextures2.utx

simulated function PostBeginPlay()
{
    local xCTFBase xbase;

    Super.PostBeginPlay();

    if ( Level.NetMode != NM_DedicatedServer )
    {
        xbase = Spawn(class'XGame.xCTFBase',self,,Location-vect(0,-4,75),Rotation);
        xbase.SetSkin(0,Texture'EmitterTextures2.FlagBase_Red');
    }
}

function string RetrivePlayerName()
{
//	if ( ObjectiveName != "" )
//		return ObjectiveName;

	return "Red Flag Base";
}

defaultproperties
{
     FlagType=Class'XGame.xRedFlag'
     DefenseScriptTags="DefendRedFlag"
     ObjectiveName="Red Flag Base"
     DrawScale=1.000000
     CollisionHeight=75.000000
     StaticMesh=StaticMesh'PariahGametypeMeshes.CTF_Flag.CTF_Flag'
     Skins(0)=TexScaler'PariahGameTypeTextures.CTFFlag.CTF_FlagPoleScale'
     Skins(1)=NoiseVertexModifier'PariahGameTypeTextures.CTFFlag.CTFflagRedFlapping'
     Location=(Z=-50.000000)
     DrawType=DT_StaticMesh
}
