class xRealCTFBase extends CTFBase
	abstract;

var Texture MyTeamSymbol;

replication
{
    reliable if (Role == ROLE_Authority)
        MyTeamSymbol;
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    Tag = 'TeamSymbolUpdate';
}

simulated function PostLinearize()
{
	Super.PostLinearize();	
    
    if ( Level.NetMode != NM_DedicatedServer )
        LoopAnim('flag');

    if (Level.NetMode != NM_Client)
    {
        // set proper team symbol
        //MyTeamSymbol = Level.Game.GameReplicationInfo.GetTeamSymbol(DefenderTeamIndex);
        //TexScaler(Combiner(Shader(Skins[0]).SelfIllumination).Material2).Material = MyTeamSymbol;        
    }
}

function Trigger( actor Other, pawn EventInstigator )
{
    if (Other.IsA('GameReplicationInfo'))
    {
        //MyTeamSymbol = Level.Game.GameReplicationInfo.GetTeamSymbol(DefenderTeamIndex);
        //TexScaler(Combiner(Shader(Skins[0]).SelfIllumination).Material2).Material = Level.Game.GameReplicationInfo.GetTeamSymbol(DefenderTeamIndex);
    }
}

simulated event PostNetReceive()
{
    if (MyTeamSymbol != None)
       TexScaler(Combiner(Shader(Skins[0]).SelfIllumination).Material2).Material = MyTeamSymbol;
}

defaultproperties
{
     bHidden=False
     bNetNotify=True
}
