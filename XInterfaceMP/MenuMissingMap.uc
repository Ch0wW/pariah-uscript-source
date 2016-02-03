class MenuMissingMap extends MenuTemplateTitledA;

var() MenuText Message;
var() string MissingMapName;

simulated function Init( String Args )
{
    MissingMapName = Args;
    Message.Text = ReplaceSubstring( default.Message.Text, "<MAPNAME>", MissingMapName);
}

simulated function LanguageChange()
{
    Message.Text = ReplaceSubstring( default.Message.Text, "<MAPNAME>", MissingMapName);
}

simulated function OnAButton()
{
    if (PreviousMenu == None)
        GotoMenuClass("XInterfaceMP.MenuMultiplayerMain");
    else
        CloseMenu();
}

simulated function HandleInputBack();

simulated function HandleInputStart()
{
    OnAButton();
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName ~= "A" )
    {
        OnAButton();
        return( true );
    }

    return( Super.HandleInputGamePad( ButtonName ) );
}

defaultproperties
{
     Message=(Text="You do not have <MAPNAME>. It is available as a free download from Xbox Live.\n\nYou must select another server to play on.",DrawPivot=DP_MiddleLeft,PosY=0.500000,Style="LongMessageText")
     ALabel=(Text="Continue")
     APlatform=MWP_All
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
