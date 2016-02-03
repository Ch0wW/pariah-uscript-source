class MenuMessageBox extends MenuTemplateTitledB;

var() MenuText Message;

simulated function Init( String Args )
{
    local MenuTemplateTitled SubMenu;
    
    SubMenu = MenuTemplateTitled( PreviousMenu );
    
    if( SubMenu != None )
        Background = SubMenu.Background;
}

simulated function SetText( String MessageText, optional String TitleText )
{
    if( TitleText != "" )
        MenuTitle.Text = TitleText;
        
    Message.Text = MessageText;
}

simulated function String GetText()
{
    return( Message.Text );
}

simulated function OnBButton()
{
    CloseMenu();
}

simulated function HandleInputBack()
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

    return( false );
}

defaultproperties
{
     Message=(DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,Pass=2,Style="LabelText")
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
