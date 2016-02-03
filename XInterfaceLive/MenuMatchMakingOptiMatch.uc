class MenuMatchMakingOptiMatch extends MenuTemplateTitledBA;

var() MenuButtonText Options[3];

simulated function Init( String Args )
{
    local int i;
    
    Super.Init( Args );

    LayoutArray( Options[0], 'TitledOptionLayout' );

    i = int( class'MenuMatchMakingOptiMatchOptions'.default.MapClassFilter );

    SetVisible( 'OnCustom', !bool( ConsoleCommand("XLIVE DENY_CUSTOM_CONTENT") ) );

    i = Clamp( i, 0, ArrayCount(Options) - 1 );
    if( Options[i].bHidden != 0 )
    {
        for( i = 0; Options[i].bHidden != 0; i++ )
            ;
    }
    FocusOnWidget( Options[i] );
}

simulated function OnAll()
{
    class'MenuMatchMakingOptiMatchOptions'.default.MapClassFilter = MCF_All;
    class'MenuMatchMakingOptiMatchOptions'.default.GameTypeName = "All";
    class'MenuMatchMakingOptiMatchOptions'.static.StaticSaveConfig();

    GotoMenuClass("XInterfaceLive.MenuMatchMakingOptiMatchOptions", "");
}

simulated function OnNormal()
{
    class'MenuMatchMakingOptiMatchOptions'.default.MapClassFilter = MCF_NormalOnly;
    class'MenuMatchMakingOptiMatchOptions'.static.StaticSaveConfig();
    
    GotoMenuClass("XInterfaceLive.MenuMatchMakingOptiMatchGameType", "");
}

simulated function OnCustom()
{
    class'MenuMatchMakingOptiMatchOptions'.default.MapClassFilter = MCF_CustomOnly;
    class'MenuMatchMakingOptiMatchOptions'.static.StaticSaveConfig();

    GotoMenuClass("XInterfaceLive.MenuMatchMakingOptiMatchGameType", "");
}

simulated function HandleInputBack()
{
    GotoMenuClass("XInterfaceLive.MenuLiveMain", "");
}

defaultproperties
{
     Options(0)=(Blurred=(Text="All Maps"),OnSelect="OnAll",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Normal Maps"),OnSelect="OnNormal")
     Options(2)=(Blurred=(Text="Custom Maps"),OnSelect="OnCustom")
     MenuTitle=(Text="OptiMatch")
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
