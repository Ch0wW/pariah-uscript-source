class MenuMatchMakingNoMatches extends MenuQuestionYesNo;

// Args: < QUICK_MATCH | OPTI_MATCH >

simulated function Init( String Args )
{
    Super.Init( Args );
    
    SetText( default.MenuTitle.Text $ "." $ "\\n" $ default.Question.Text, default.MenuTitle.Text );
}

simulated function OnNo()
{    
    if( Args ~= "QUICK_MATCH" )
        GotoMenuClass("XInterfaceLive.MenuLiveMain");
    else
        GotoMenuClass("XInterfaceLive.MenuMatchMakingOptiMatchOptions");
}

simulated function OnYes()
{
    GotoMenuClass( "XInterfaceMP.MenuHostMain", "XBOX_LIVE" );
}

defaultproperties
{
     Question=(Text="Create new match?")
     ALabel=(Text="Yes")
     BLabel=(Text="No")
     MenuTitle=(Text="No matches found")
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
