class MenuFileLimit extends MenuTemplateTitledA;

var() MenuText  Message;

simulated function Init(string Args)
{
    local string type;

    Super.Init(Args);

    type = ParseToken(Args);
    
    if (type ~= "PROFILE")
        Message.Text = class'XboxStandardMsgs'.default.ErrorMsg[12];
    else if (type ~= "SAVEGAME")
        Message.Text = class'XboxStandardMsgs'.default.ErrorMsg[13];

    UpdateTextField(Message.Text, "%d", LoadSaveCommand("MAX_SAVED_GAMES"));
}

simulated function HandleInputStart()
{
    CloseMenu();
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
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName == "A" )
    {
        CloseMenu();
        return( true );
    }

    if( ButtonName == "B" )
    {
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

defaultproperties
{
     Message=(Style="MessageText")
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
