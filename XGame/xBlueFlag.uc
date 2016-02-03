//=============================================================================
// xBlueFlag.
//=============================================================================
class xBlueFlag extends CTFFlag;


var Texture MyTeamSymbol;

replication
{
    reliable if (Role == ROLE_Authority)
        MyTeamSymbol;
}

simulated function PostBeginPlay()
{
    LoopAnim('flag');
    SimAnim.bAnimLoop = true;
    Super.PostBeginPlay();
}

simulated function PostLinearize()
{
    Super.PostLinearize();

    LoopAnim('flag');
    SimAnim.bAnimLoop = true;
}

defaultproperties
{
     TeamNum=1
     DrawScale=1.000000
     CollisionHeight=67.000000
     StaticMesh=StaticMesh'PariahGametypeMeshes.CTF_Flag.CTF_Flag'
     Skins(0)=ConstantColor'PariahGameTypeTextures.CTFFlag.CTF_FlagPole'
     Skins(1)=NoiseVertexModifier'PariahGameTypeTextures.CTFFlag.CTFflagBlueFlapping'
     DrawType=DT_StaticMesh
     bNetNotify=True
}
