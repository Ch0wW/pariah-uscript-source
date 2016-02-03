class MenuStorageError extends MenuTemplateTitledBA;

var() MenuText Message;

var() localized String StringOutOfClientSpace;
var() localized String StringOutOfServerSpace;

var() String LastErrorDash;
var() int AdditionalBlocksRequired;

simulated function Init( String Args )
{
    local String Token;
    
    Token = ParseToken(Args);
    
    if( Token == "OUT_OF_SERVER_SPACE" )
    {
        AdditionalBlocksRequired = int(ParseToken(Args));
        
        if(AdditionalBlocksRequired == 0)
        {
            AdditionalBlocksRequired = 4; // Since this is server-side, graceful over estimate if absent.
        }
        
        Message.Text = ReplaceSubstring( StringOutOfServerSpace, "<BLOCKS>", AdditionalBlocksRequired );
        HideBButton(1);
    }
    else if( Token == "OUT_OF_CLIENT_SPACE" )
    {
        AdditionalBlocksRequired = int(ParseToken(Args));
        
        if(AdditionalBlocksRequired == 0)
        {
            AdditionalBlocksRequired = int(LoadSaveCommand("CUSTOM_MAP_SPACE_NEEDED"));
        }
        
        Message.Text = ReplaceSubstring( StringOutOfClientSpace, "<BLOCKS>", AdditionalBlocksRequired );
        ALabel.Text = StringContinue;
        BLabel.Text = class'MenuLowStorage'.default.BLabel.Text;
        LastErrorDash = "XLD_LAUNCH_DASHBOARD_MEMORY";
    }
    else
    {
        Log("Unknown token passed to MenuStorageError:" @ Token);
        GotoMenuClass("XInterfaceLive.MenuLiveErrorMessage");
    }
}

simulated function HandleInputStart()
{
    OnAButton();
}

simulated function OnAButton()
{
    CloseMenu();
}

simulated function HandleInputBack()
{
}

simulated function OnBButton()
{
    if( LastErrorDash == "XLD_LAUNCH_DASHBOARD_MEMORY" )
    {
        CallMenuClass( "XInterfaceLive.MenuDashboardConfirm", LastErrorDash @ "DRIVE=U: BLOCKS="$ AdditionalBlocksRequired );
    }
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName == "A" )
    {
        OnAButton();
        return( true );
    }

    if( ButtonName == "B" )
    {
        OnBButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

defaultproperties
{
     Message=(Style="MedMessageText")
     StringOutOfClientSpace="Your Xbox doesn't have enough free blocks to download this custom map.\n\nYou need <BLOCKS> more free blocks."
     StringOutOfServerSpace="Your published custom map area doesn't have enough free blocks for this custom map.\n\nYou can unpublish maps to free blocks.\n\nYou need <BLOCKS> more free blocks."
     ALabel=(Text="Ok")
     MenuTitle=(Text="Xbox Live")
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
