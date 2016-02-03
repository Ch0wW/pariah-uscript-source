//=============================================================================
// xBlueFlagBase.
//=============================================================================
class xBlueFlagBase extends xRealCTFBase
	placeable;

simulated function PostLinearize()
{
    local xCTFBase xbase;

    Super.PostLinearize();

    if ( Level.NetMode != NM_DedicatedServer )
    {
        xbase = Spawn(class'XGame.xCTFBase',self,,Location-vect(0,-4,75),Rotation);
        xbase.SetSkin(0,Texture'EmitterTextures2.FlagBase_Blue');
    }
}

function string RetrivePlayerName()
{
//	if ( ObjectiveName != "" )
//		return ObjectiveName;

	return "Blue Flag Base";
}

defaultproperties
{
     FlagType=Class'XGame.xBlueFlag'
     DefenseScriptTags="DefendBlueFlag"
     ObjectiveName="Blue Flag Base"
     DefenderTeamIndex=1
     DrawScale=1.000000
     CollisionHeight=75.000000
     StaticMesh=StaticMesh'PariahGametypeMeshes.CTF_Flag.CTF_Flag'
     Skins(0)=TexScaler'PariahGameTypeTextures.CTFFlag.CTF_FlagPoleScale'
     Skins(1)=NoiseVertexModifier'PariahGameTypeTextures.CTFFlag.CTFflagBlueFlapping'
     DrawType=DT_StaticMesh
}
