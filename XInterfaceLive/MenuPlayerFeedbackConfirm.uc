class MenuPlayerFeedbackConfirm extends MenuQuestionYesNo
    DependsOn(MenuGamerList);

var() MenuGamerList.Gamer Gamer;
var() String FeedbackEnum;
var() String FeedbackText;

var() MenuText Info[3];

var() WidgetLayout InfoLayout;

simulated function Init( String Args )
{
    Super.Init( Args );

    Info[0].Text = Info[0].Text @ FeedbackText;
    Info[1].Text = Info[1].Text @ Gamer.Gamertag;
    
    // Smashed by defaults.
    Question.DrawPivot = DP_UpperLeft; 
    Question.TextAlign = TA_Left; 
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );
    
    LayoutArray( Info[0], 'InfoLayout' );
}

simulated function OnYes()
{
    if( "SUCCESS" != ConsoleCommand( "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "PLAYER FEEDBACK" @ FeedbackEnum @ "GAMERTAG=\"" $ Gamer.Gamertag $ "\"" ) )
        OverlayErrorMessageBox( "PLAYER_SEND_FEEDBACK_FAILED" );
    else
        GotoMenuClass("XInterfaceLive.MenuPlayerFeedbackDone");
}

simulated function OnNo()
{
    CloseMenu();
}

defaultproperties
{
     Info(0)=(Text="Complaint:",DrawPivot=DP_MiddleLeft,MaxSizeX=0.700000,Style="NormalLabel")
     Info(1)=(Text="Gamertag:")
     Info(2)=(Text="Game name: Pariah")
     InfoLayout=(PosX=0.100000,PosY=0.280500,SpacingY=0.050000,BorderScaleX=0.942000,Pivot=DP_MiddleLeft)
     Question=(Text="The Xbox Live community is managed by its users.\n\nMultiple reports from other users about this Gamer can lead to Voice Banning, Lockout, and Account Termination.\n\nDo you wish to proceed with your complaint?",PosX=0.100000,PosY=0.430000,MaxSizeX=0.800000)
     MenuTitle=(Text="Feedback Confirmation")
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
