class MenuMiniEdSaved extends MenuTemplateTitledA
    DependsOn(MenuMiniEdMain);

var() MenuText Message;
var() MenuMiniEdMain.ESaveAction SaveAction;

simulated function Init( String Args )
{
    local String MapName;

    MapName = ParseToken( Args );
    Message.Text = ReplaceSubstring( default.Message.Text, "<MAPNAME>", MapName );
    
    if( HaveSpaceToSaveMap() )
    {
        HideAButton(1);
        SetTimer(2, false);
    }
    else
    {
        HideAButton(0);
    }
}

simulated function Timer()
{
    class'MenuMiniEdMain'.static.FinishSaveAction( self, SaveAction );
}

simulated function HandleInputBack()
{
}

simulated function HandleInputStart()
{
    local MenuMiniEdLowStorage ML;

    if( bool(AButtonHidden) )
    {
        return;
    }

    Assert( !HaveSpaceToSaveMap() );

    ML = Spawn( class'MenuMiniEdLowStorage', Owner );
    ML.SaveAction = SaveAction;

    GotoMenu(ML);
    return;
}

simulated function OnAButton()
{
    HandleInputStart();
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName == "A" )
    {
        OnAButton();
        return( true );
    }

	return( Super.HandleInputGamePad( ButtonName ) );
}

defaultproperties
{
     Message=(Text="Saved <MAPNAME>.",Style="MessageText")
     MenuTitle=(Text="Saved")
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
