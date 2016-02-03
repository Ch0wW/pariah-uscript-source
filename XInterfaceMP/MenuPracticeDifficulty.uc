class MenuPracticeDifficulty extends MenuTemplateTitledBA;

// Args: <MAP>

var() MenuButtonText    Options[10];
var() config int        Position;

var localized String    StringNoBots;

var() xUtil.GameTypeRecord GameType;
var() String MapName;

simulated function Init( String Args )
{
    Super.Init( Args );

    MapName = ParseToken( Args );

    UpdateOptions();

    Position = Clamp( Position, 0, ArrayCount(Options) - 1 );

    if( Options[Position].bHidden != 0 )
    {
        for( Position = 0; Options[Position].bHidden != 0; Position++ )
            continue;
    }
    
    FocusOnWidget( Options[Position] );
}

simulated function SavePosition()
{
    for( Position = 0; Position < ArrayCount(Options); Position++ )
    {
        if( Options[Position].bHasFocus != 0 )
            break;
    }
    
    if( Position >= ArrayCount(Options) )
        Position = 0;

    SaveConfig();
}

simulated function UpdateOptions()
{
    local int i;
    local int Index;

    Options[0].ContextID = 0;
    Options[0].Blurred.Text = StringNoBots;
    Options[0].Focused.Text = StringNoBots;
    Options[0].bHidden = 0;
    
    Index = 1;
    
    for( i = 0; i < class'GameInfo'.static.GetNumDifficultyLevels() + 1; ++i )
    {
        Assert( Index < ArrayCount(Options) );

        Options[Index].ContextID = Index;
        Options[Index].Blurred.Text = class'GameInfo'.static.GetDifficultyName(i);
        Options[Index].Focused.Text = Options[i].Blurred.Text;
        Options[Index].bHidden = 0;
        ++Index;
    }

    while( i < ArrayCount( Options ) )
    {
        Options[i].bHidden = 1;
        ++i;
    }

    LayoutArray( Options[0], 'TitledOptionLayout' );
}

simulated event PostEditChange()
{
    UpdateOptions();
}

simulated function OnSelect( int contextId )
{
    local String URL;
    
    SavePosition();

    URL = MapName $ "?Game=" $ GameType.ClassName $ "?PracticeMode=true";

    if( contextId == 0 )
    {
        URL = URL $ "?bAutoNumBots=false";
    }
    else
    {
        URL = URL $ "?bAutoNumBots=true?Difficulty=" $ class'GameInfo'.static.GetDifficultyLevel(contextId - 1);
    }

    class'VignetteConnecting'.default.ServerName = "";
    class'VignetteConnecting'.static.StaticSaveConfig();
    
    class'GameEngine'.default.DisconnectMenuClass = "XInterfaceCommon.MenuMain";
    class'GameEngine'.default.DisconnectMenuArgs = "";
    class'GameEngine'.static.StaticSaveConfig();

    RestoreVideo();

    PlayerController(Owner).ClientTravel( URL, TRAVEL_Absolute, false );
}

simulated function HandleInputBack()
{
    local MenuPracticeMap M;

    SavePosition();

    M = Spawn(class'MenuPracticeMap', Owner);
    M.GameType = GameType;

    GotoMenu(M, Args);
}

defaultproperties
{
     Options(0)=(OnSelect="OnSelect",Style="TitledTextOption")
     StringNoBots="No Bots"
     MenuTitle=(Text="Bot Difficulty")
     ReservedNames(1)="Default"
     ReservedNames(2)="New"
     ReservedNames(3)="Player"
     ReservedNames(4)="Pariah"
     ReservedNames(5)="Build"
     ReservedNames(6)="Default"
     ReservedNames(7)="DefPariahEd"
     ReservedNames(8)="DefUser"
     ReservedNames(9)="Manifest"
     ReservedNames(10)="MiniEdLaunch"
     ReservedNames(11)="MiniEdUser"
     ReservedNames(12)="PariahEd"
     ReservedNames(13)="PariahEdTips"
     ReservedNames(14)="Running"
     ReservedNames(15)="TEMP"
     ReservedNames(16)="User"
}
