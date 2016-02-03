class MenuCorruptContent extends MenuTemplateTitledA;

var() MenuText          mMessage;
var() bool              mGotoProfileSelection;
var() bool              mCloseMenu;
var string              mCorruptContentName;


simulated function Init(string Args)
{
    local string mode;
    
    mCorruptContentName = ParseToken(Args);
    mode = ParseToken(Args);
    
    mGotoProfileSelection = (mode ~= "SELECT_VALID");
    mCloseMenu = (mode ~= "CLOSE");

    Super.Init(Args);
    LanguageChange();
}

simulated function LanguageChange()
{
    mMessage.Text = class'XboxMsg'.default.XBOX_CONTENT_DAMAGE;
    UpdateTextField(mMessage.Text, "<CONTENT>", mCorruptContentName);
}

simulated function HandleInputStart()
{
    Done();
}

simulated function OnAButton()
{
    Done();
}

simulated function HandleInputBack()
{
}

simulated function OnBButton()
{
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName == "A" )
    {
        Done();
        return( true );
    }

    if( ButtonName == "B" )
    {
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

simulated function Done()
{
    if (mGotoProfileSelection)
    {
        GotoMenuClass("XInterfaceCommon.MenuProfileSelect");
    }
    else if(mCloseMenu)
    {
        CloseMenu();
    }
    else
    {
        if(LowStorage())
        {
            GotoMenuClass("XInterfaceCommon.MenuLowStorage");
        }
        else
        {    
            GotoMenuClass(EditNameMenuClass());
        }
    }
}

defaultproperties
{
     mMessage=(Style="MedMessageText")
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
