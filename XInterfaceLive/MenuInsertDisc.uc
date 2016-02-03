class MenuInsertDisc extends MenuTemplateTitledB
    DependsOn(MenuGamerList);

var() MenuGamerList.Gamer Gamer;

var() MenuText Text[2];

// Args: <JOIN> | <ACCEPT>

simulated function Init( String Args )
{
    Super.Init(Args);
    
    Text[0].Text = Text[0].Text $ "\\n" $ Gamer.GameTitle;
}

simulated function HandleInputBack()
{
    OnBButton();
}

simulated function OnBButton()
{
    CloseMenu();
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName == "B" )
    {
        OnBButton();
        return( true );
    }
    
	return( Super.HandleInputGamePad( ButtonName ) );
}

defaultproperties
{
     Text(0)=(Text="Insert game disc for",Style="MessageText")
     Text(1)=(bHidden=1)
     BLabel=(Text="Cancel")
     MenuTitle=(Text="Game Disc Required")
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
