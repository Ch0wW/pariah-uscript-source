class MenuProfileWarning extends MenuTemplateTitledA;

var() MenuText  mMessage;
var bool        mGotoProfileSelect;

simulated function Init(string Args)
{
    mMessage.Text = ParseToken(Args);
    mGotoProfileSelect = (ParseToken(Args) ~= "SELECT");
    Super.Init(Args);
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
    if(mGotoProfileSelect)
    {
        GotoMenuClass("XInterfaceCommon.MenuProfileSelect");
    }
    else
    {
        CloseMenu();
    }
}

defaultproperties
{
     mMessage=(Style="MessageText")
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
