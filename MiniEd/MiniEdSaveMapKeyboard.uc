/*
    Desc: The menu that lets you choose a name for a custom map
*/

class MiniEdSaveMapKeyboard extends MenuVirtualKeyboard
    DependsOn(MenuMiniEdMain);

var() MenuText              TextNameOfMap;

var() localized String      EditNameText;
var() localized String      InUseText;
var() localized String      MinLenText;

var() localized Array<String>       Adjectives;
var() localized Array<String>       Nouns;

var() MiniEdInfo            Info;

var() MenuMiniEdMain.ESaveAction SaveAction;

simulated function Init( String Args )
{
    local String GamerTag;
    local bool WasLiveMap;
    
    Super.Init( Args );
    Info = MiniEdInfo(Level.Game);
    
    InputText.Text = ParseToken( Args );
    
    if( InputText.Text == "" )
    {
        InputText.Text = MiniEdGetCustomMapShort();
    }
    
    GamerTag = MiniEdGetCustomMapGamerTag();
    WasLiveMap = false;
    if( Len( GamerTag ) > 0 )
    {
        WasLiveMap = true;
    }
    
    if( (GetPlatform() == MWP_Xbox) && (PlayerController(Owner).LiveStatus != LS_SignedIn) && (WasLiveMap || (InputText.Text == "")) )
    {
        CallMenuClass("MiniEd.MenuMiniEdSaveOffline", InputText.Text);
    }

    CalcMaxLength();
    
    if( InputText.Text == "" )
    {
        OnGenerate();
    }
    else if( UpperCase )
    {
        OnYButton();
    }
}

simulated function CalcMaxLength()
{
    local String Gamertag;
    local PlayerController PC;
    
    PC = PlayerController(Owner);
    
    if( MiniEdMapIsLive() && (PC.LiveStatus == LS_SignedIn) )
    {
        Gamertag = PC.Gamertag;
        Gamertag = ReplaceSubstring( Gamertag, " ", "_" );
    }
    
    SetMaxLength( Min( class'xUtil'.static.GetMaxCustomMapNameLen( GetURLMap(), Gamertag ), default.MaxLength ) );
}

simulated function bool MenuClosed( Menu ClosingMenu )
{
    CalcMaxLength();
    return(true);
}

simulated function SetMaxLength( int i )
{
    log( i @ "chars for file name." );

    if( i < Len( InputText.Text ) )
    {
        Super.SetMaxLength(i);
        OnGenerate();
    }
    else
    {
        Super.SetMaxLength(i);
    }
}

simulated function bool MapExists( String MapName )
{
    local PlayerController PC;

    Assert( InStr( MapName, "-" ) < 0 );
    Assert( InStr( MapName, "@" ) < 0 );

    MapName = MiniEdGetCustomMapGameType() $ "-" $ MapName;
    
    PC = PlayerController(Owner);
    if( MiniEdMapIsLive() && (PC.LiveStatus == LS_SignedIn) )
    {
        MapName = MapName $ "@" $ ReplaceSubstring( PC.Gamertag, " ", "_" );
    }
    
    return( class'xUtil'.static.CustomMapExists( MapName ) );
}

simulated function OnGenerate()
{
    local int attempts;
    local int i;
    
    attempts = 25;
    
    // Try to generate a compound name:
    
    for( i = 0; i < attempts; ++i )
    {
        InputText.Text = Adjectives[Rand(Adjectives.Length)] $ Nouns[Rand(Nouns.Length)];
        
        if( Len( InputText.Text ) > MaxLength  )
        {
            continue;
        }

        if( !MapExists( InputText.Text ) )
        {
            if( UpperCase )
            {
                OnYButton();
            }

            return;
        }
    }
    
    // Try to generate a shorter name:
    
    for( i = 0; i < attempts; ++i )
    {
        InputText.Text = Nouns[Rand(Nouns.Length)];
        
        if( Len( InputText.Text ) > MaxLength  )
        {
            continue;
        }

        if( !MapExists( InputText.Text ) )
        {
            if( UpperCase )
            {
                OnYButton();
            }

            return;
        }
    }
    
    // Generate a truncated shorter name:

    for( i = 0; i < attempts; ++i )
    {
        InputText.Text = Left( Nouns[Rand(Nouns.Length)], MaxLength );

        if( !MapExists( InputText.Text ) )
        {
            if( UpperCase )
            {
                OnYButton();
            }

            return;
        }
    }
    
    InputText.Text = "";
}

simulated function OnDone()
{   
    local MenuMiniEdConfirmOverwrite ConfirmOverwrite;
    local MenuMiniEdNameVerify       NameVerify;

    if( Len( InputText.Text ) < MinLength )
    {
        CallMenuClass("XInterfaceCommon.MenuWarning", MakeQuotedString(MinLenText));
        return;
    }

    TrimTrailingSpace();
    
    if( MapExists( InputText.Text ) )
    {
        ConfirmOverwrite = Spawn( class'MenuMiniEdConfirmOverwrite', Owner );
        ConfirmOverwrite.SaveAction = SaveAction;
        GotoMenu( ConfirmOverwrite, MakeQuotedString(InputText.Text) );
        return;
    }
    
    if( MiniEdMapIsLive() && (PlayerController(Owner).LiveStatus == LS_SignedIn) )
    {
        NameVerify = Spawn( class'MenuMiniEdNameVerify', Owner );
        NameVerify.SaveAction = SaveAction;
        GotoMenu( NameVerify, MakeQuotedString(InputText.Text));
        return;
    }

    SaveMap(self, InputText.Text, SaveAction );
}

static simulated function SaveMap(MenuBase Menu, String NewName, MenuMiniEdMain.ESaveAction SaveAction)
{
    local MenuMiniEdSaved Saved;

    Menu.ConsoleCommand( "SAVEIT MAPNAME=" $ MakeQuotedString(NewName) );

    Saved = Menu.Spawn( class'MenuMiniEdSaved', Menu.Owner );
    Saved.SaveAction = SaveAction;
    Menu.GotoMenu( Saved, MakeQuotedString(NewName) );
}

simulated function HandleInputBack()
{
    GotoMenuClass("MiniEd.MenuMiniEdMain");
}

defaultproperties
{
     TextNameOfMap=(Text="Map name:",DrawPivot=DP_MiddleLeft,PosX=0.167500,PosY=0.250000,ScaleX=0.650000,ScaleY=0.650000,Pass=3,Style="LabelText")
     EditNameText="You must give your map a name!"
     InUseText="There's already a map with that name"
     MinLenText="Name must be at least one letter/number"
     Adjectives(0)="Super"
     Adjectives(1)="Mega"
     Adjectives(2)="Wicked"
     Adjectives(3)="Poison"
     Adjectives(4)="Rusty"
     Adjectives(5)="Smashing"
     Adjectives(6)="Fiery"
     Adjectives(7)="Liquid"
     Adjectives(8)="Raging"
     Adjectives(9)="Unholy"
     Adjectives(10)="Reeking"
     Adjectives(11)="Dirty"
     Adjectives(12)="Dusty"
     Adjectives(13)="Dry"
     Adjectives(14)="Burning"
     Adjectives(15)="Silent"
     Adjectives(16)="Screaming"
     Adjectives(17)="Eyeless"
     Adjectives(18)="Dark"
     Nouns(0)="Fields"
     Nouns(1)="Death"
     Nouns(2)="Carnage"
     Nouns(3)="Blunder"
     Nouns(4)="Trap"
     Nouns(5)="Pit"
     Nouns(6)="Prison"
     Nouns(7)="Wreckage"
     Nouns(8)="Pools"
     Nouns(9)="Arena"
     Nouns(10)="Prosthetics"
     Nouns(11)="Scissors"
     Nouns(12)="Boom"
     Nouns(13)="Oblivion"
     Nouns(14)="Soil"
     Nouns(15)="Alpha"
     Nouns(16)="Blade"
     KeyboardLayout(38)=(Span=6,bIsLastInRow=0)
     KeyboardLayout(39)=(Label="Generate",Span=4)
     InputText=(DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleLeft,PosX=0.420000)
     Buttons(39)=(OnSelect="OnGenerate")
     MaxLength=18
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
