class MenuSettingsMain extends MenuTemplateTitledBA;

var() MenuButtonText Options[10];

simulated function Init( String Args )
{
    Super.Init( Args );
    
    SetVisible('OnXboxLive', (PlayerController(Owner).LiveStatus == LS_SignedIn));
    
    LayoutArray( Options[0], 'TitledOptionLayout' );
}

simulated exec function Pork()
{
    local int i;
    
    for( i = 0; i < 3; ++i )
    {
        Options[i].bHidden = 0;
        Options[i].Blurred.Text = default.Options[i].Blurred.Text @ default.Options[i].OnSelect;
    }
    
    SetVisible('OnXboxLive', true);
    LayoutArray( Options[0], 'TitledOptionLayout' );
}

simulated function OnXboxControls()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsControlsXbox" );
}

simulated function OnPS2Controls()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsControlsPSX" );
}

simulated function OnPCControls()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsControlsPC" );
}

simulated function OnInput()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsInput" );
}

simulated function OnAudio()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsAudio" );
}

simulated function OnVideo()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsVideo" );
}

simulated function OnInternet()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsInternet" );
}

simulated function OnPerformance()
{
    CallMenuClass( "XInterfaceSettings.MenuSettingsPerformance" );
}

simulated function OnXboxLive()
{
    CallMenuClass( "XInterfaceLive.MenuLiveSettings" );
}

simulated function OnCheatCodes()
{
    CallMenuClass( "XInterfaceSettings.MenuEnterCheatCodes" );
}

simulated function HandleInputBack()
{
    local bool cWoS;
    
    // continue without saving?
    cWoS = ("" != LoadSaveCommand("CONTINUE_WITHOUT_SAVING"));

    // don't show "saving" if continue w/o saving!
    if(!IsOnConsole() || cWoS)
    {
        UpdatePlayerProfile();
        GoBack();
    }
    else
    {
        GotoMenuClass("XInterfaceSettings.MenuSettingsSaving");
    }
}

simulated function GoBack()
{
    if( PreviousMenu != None )
    {
        CloseMenu();
    }
    else
    {
        GotoMenuClass( "XInterfaceCommon.MenuMain" );
    }
}

defaultproperties
{
     Options(0)=(Blurred=(Text="Controls"),HelpText="Change the control scheme.",OnSelect="OnXboxControls",Platform=MWP_Xbox,Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Controls"),HelpText="Change the control scheme.",OnSelect="OnPS2Controls",Platform=MWP_PS2)
     Options(2)=(Blurred=(Text="Controls"),HelpText="Change the control scheme.",OnSelect="OnPCControls",Platform=MWP_PC)
     Options(3)=(Blurred=(Text="Input"),HelpText="Adjust other input settings.",OnSelect="OnInput")
     Options(4)=(Blurred=(Text="Audio"),HelpText="Adjust the sound settings.",OnSelect="OnAudio")
     Options(5)=(Blurred=(Text="Video"),HelpText="Adjust the video settings.",OnSelect="OnVideo")
     Options(6)=(Blurred=(Text="Internet"),HelpText="Adjust your network settings.",OnSelect="OnInternet",Platform=MWP_PC)
     Options(7)=(Blurred=(Text="Performance"),HelpText="Adjust the performance settings.",OnSelect="OnPerformance",Platform=MWP_PC)
     Options(8)=(Blurred=(Text="Xbox Live"),HelpText="Change Xbox Live Settings.",OnSelect="OnXboxLive",Platform=MWP_Xbox)
     Options(9)=(Blurred=(Text="Cheat Codes"),HelpText="Enter secret cheat codes!",OnSelect="OnCheatCodes")
     MenuTitle=(Text="Settings")
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
