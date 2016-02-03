class MiniEdPCSaveMap extends MenuTemplateTitledBXA
    DependsOn(MenuMiniEdMain);

var() MenuText TextNameOfMap;

var() MenuEditBox   InputText;

var() localized String EditNameText;
var() localized String InUseText;
var() localized String MinLenText;

var() localized Array<String> Adjectives;
var() localized Array<String> Nouns;

var() MiniEdInfo Info;

var() MenuMiniEdMain.ESaveAction SaveAction;

var int MaxLength;
var const int MinLength;

simulated function Init( String Args )
{
    Super.Init( Args );
    Info = MiniEdInfo(Level.Game);

    SetButtonText( ParseToken( Args ) );

    if( InputText.Blurred.Text == "" )
        SetButtonText( MiniEdGetCustomMapShort());
    
    if( InputText.Blurred.Text == "" )
        OnGenerate();
}

simulated function SetButtonText( String Txt)
{
    InputText.Blurred.Text = Txt;
    InputText.Focused.Text = Txt;
}

simulated function bool MenuClosed( Menu ClosingMenu )
{
    return(true);
}

simulated function SetMaxLength( int i )
{
    log( i @ "chars for file name." );

    if( i < Len( InputText.Blurred.Text ) )
    {
        SetButtonText( Left( InputText.Blurred.Text, i ) );
        OnGenerate();
    }
    else
    {
        SetButtonText( Left( InputText.Blurred.Text, i ) );
    }
}

simulated function bool MapExists( String MapName )
{
    Assert( InStr( MapName, "-" ) < 0 );
    Assert( InStr( MapName, "@" ) < 0 );

    MapName = MiniEdGetCustomMapGameType() $ "-" $ MapName;
    
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
        SetButtonText( Adjectives[Rand(Adjectives.Length)] $ Nouns[Rand(Nouns.Length)] );
        
        if( Len( InputText.Blurred.Text ) > MaxLength  )
        {
            continue;
        }

        if( !MapExists( InputText.Blurred.Text ) )
        {
            return;
        }
    }
    
    // Try to generate a shorter name:
    
    for( i = 0; i < attempts; ++i )
    {
        SetButtonText( Nouns[Rand(Nouns.Length)] );
        
        if( Len( InputText.Blurred.Text ) > MaxLength  )
        {
            continue;
        }

        if( !MapExists( InputText.Blurred.Text ) )
        {
            return;
        }
    }
    
    // Generate a truncated shorter name:

    for( i = 0; i < attempts; ++i )
    {
        SetButtonText( Left( Nouns[Rand(Nouns.Length)], MaxLength ));

        if( !MapExists( InputText.Blurred.Text ) )
            return;
    }
    
    SetButtonText("");
}

simulated function OnDone()
{   
    local MenuMiniEdConfirmOverwrite ConfirmOverwrite;

    if( Len( InputText.Blurred.Text ) < MinLength )
    {
        CallMenuClass("XInterfaceCommon.MenuWarning", MakeQuotedString(MinLenText));
        return;
    }

    TrimTrailingSpace();
    
    if( MapExists( InputText.Blurred.Text ) )
    {
        ConfirmOverwrite = Spawn( class'MenuMiniEdConfirmOverwrite', Owner );
        ConfirmOverwrite.SaveAction = SaveAction;
        GotoMenu( ConfirmOverwrite, MakeQuotedString(InputText.Blurred.Text) );
        return;
    }
    
    SaveMap(self, InputText.Blurred.Text, SaveAction );
}

simulated function TrimTrailingSpace()
{
    // trim trailing space if any
    if (Right(InputText.Blurred.Text, 1) == class'MenuVirtualKeyboard'.default.SpaceChar)
        SetButtonText( Left(InputText.Blurred.Text, Len(InputText.Blurred.Text) - 1));
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

simulated function OnXButton()
{
    OnGenerate();
}

defaultproperties
{
     TextNameOfMap=(Text="Map name:",DrawPivot=DP_MiddleLeft,PosX=0.100000,PosY=0.300000,ScaleX=0.650000,ScaleY=0.650000,Pass=3,Style="LabelText")
     InputText=(MaxLength=15,MinLength=1,Blurred=(PosX=0.120000,PosY=0.360000),Platform=MWP_PC,Style="NormalEditBox")
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
     MaxLength=18
     MinLength=1
     AButtonIcon=(bHidden=1)
     ALabel=(Text="Done")
     AButton=(OnSelect="OnDone")
     APlatform=MWP_PC
     XButtonIcon=(bHidden=1)
     XLabel=(Text="Generate")
     XButton=(OnSelect="OnGenerate")
     XPlatform=MWP_PC
     MenuTitle=(Text="Save Map")
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
