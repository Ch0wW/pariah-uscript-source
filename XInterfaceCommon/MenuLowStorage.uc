class MenuLowStorage extends MenuTemplateTitledBA;

var() MenuText  mMessage;
var() int       mNeededSpace;

simulated function Init(string Args)
{
    Super.Init(Args);
    InitText();
}

simulated function InitText()
{
    local int freeSpace;

    freeSpace = int(LoadSaveCommand("SPACE_FREE"));
    mNeededSpace = int(LoadSaveCommand("SPACE_NEEDED"));
    
    assert(freeSpace < mNeededSpace);

    // always ask for the maximum number of blocks needed
    mMessage.Text = class'XboxMsg'.default.XBOX_NOT_ENOUGH_FREE_BLOCKS;
    UpdateTextField(mMessage.Text, "<BLOCKS>", string(mNeededSpace));
}

simulated function HandleInputStart()
{
    ContinueWithoutSaving();
}

simulated function OnAButton()
{
    ContinueWithoutSaving();
}

simulated function HandleInputBack()
{
    Dashboard();
}

simulated function OnBButton()
{
    Dashboard();
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName == "A" )
    {
        ContinueWithoutSaving();
        return( true );
    }

    if( ButtonName == "B" )
    {
        Dashboard();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

simulated function ContinueWithoutSaving()
{
    local ProfileData pd;
    pd = GetProfileData();
    pd.ContinueWithoutSaving("true");
    GotoMenuClass(EditNameMenuClass());
}

simulated function Dashboard()
{
    if(IsOnConsole())
    {
        CallMenuClass
        ( 
            "XInterfaceLive.MenuDashboardConfirm", 
            "XLD_LAUNCH_DASHBOARD_MEMORY" @ 
            "DRIVE=" $ LoadSaveCommand("DRIVE_LETTER") @
            "BLOCKS=" $ (1 + mNeededSpace)
        );
    }
    else
    {
        CloseMenu();
    }
}

defaultproperties
{
     mMessage=(Style="MedMessageText")
     ALabel=(Text="Continue without saving")
     APlatform=MWP_All
     BLabel=(Text="Free Blocks")
     MenuTitle=(Text="Warning: Low storage")
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
