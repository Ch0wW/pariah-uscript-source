class MenuPlayerFeedback extends MenuTemplateTitledBA
    DependsOn(MenuGamerList);

var() MenuGamerList.Gamer Gamer;

var() MenuSprite Borders[2];

var() MenuText Info[2];

var() MenuButtonText Options[8];

var() WidgetLayout InfoLayout;
var() WidgetLayout OptionsLayout;

simulated function Init( String Args )
{
    Super.Init( Args );

    Info[0].Text = Info[0].Text @ Gamer.Gamertag;
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );
    
    LayoutArray( Info[0], 'InfoLayout' );
    FitBorderBoxToArray( Borders[0], Info[0], 'InfoLayout' );

    LayoutArray( Options[0], 'OptionsLayout' );
    FitBorderBoxToArray( Borders[1], Options[0], 'OptionsLayout' );
}


simulated function OnFeedback()
{
    local int i;
    
    for( i = 0; i < ArrayCount(Options); i++ )
    {
        if( Options[i].bHasFocus != 0 )
            AssembleFeedback(i);
    }
}

simulated function AssembleFeedback( int i )
{
    local String FeedbackEnum;
    local String FeedbackText;
    local bool bConfirm;
    local MenuPlayerFeedbackConfirm M;
    
    FeedbackText = Options[i].Blurred.Text;
    
    switch( i )
    {
        case 0:
            FeedbackEnum = "XONLINE_FEEDBACK_POS_ATTITUDE";
            bConfirm = false;
            break;

        case 1:
            FeedbackEnum = "XONLINE_FEEDBACK_POS_SESSION";
            bConfirm = false;
            break;

        case 2:
            FeedbackEnum = "XONLINE_FEEDBACK_NEG_NICKNAME";
            bConfirm = true;
            break;

        case 3:
            FeedbackEnum = "XONLINE_FEEDBACK_NEG_LEWDNESS";
            bConfirm = true;
            break;

        case 4:
            FeedbackEnum = "XONLINE_FEEDBACK_NEG_SCREAMING";
            bConfirm = true;
            break;

        case 5:
            FeedbackEnum = "XONLINE_FEEDBACK_NEG_GAMEPLAY";
            bConfirm = true;
            break;

        case 6:
            FeedbackEnum = "XONLINE_FEEDBACK_NEG_HARASSMENT";
            bConfirm = true;
            break;

        case 7:
            FeedbackEnum = "XONLINE_FEEDBACK_NEG_MESSAGE_INAPPROPRIATE";
            bConfirm = true;
            break;

        default:
            return;
    }

    if( bConfirm )
    {
        M = Spawn( class'MenuPlayerFeedbackConfirm', Owner );
        M.Gamer = Gamer;
        M.FeedbackEnum = FeedbackEnum;
        M.FeedbackText = FeedbackText;
        GotoMenu( M );
    }
    else
    {
        if( "SUCCESS" != ConsoleCommand( "XLIVE FRIENDS GAMEPAD=" $ PlayerController(Owner).Player.GamePadIndex @ "PLAYER FEEDBACK" @ FeedbackEnum @ "GAMERTAG=\"" $ Gamer.Gamertag $ "\"" ) )
            OverlayErrorMessageBox( "PLAYER_SEND_FEEDBACK_FAILED" );
        else
            GotoMenuClass("XInterfaceLive.MenuPlayerFeedbackDone");
    }
}

defaultproperties
{
     Borders(0)=(Style="DarkBorder")
     Borders(1)=(Style="DarkBorder")
     Info(0)=(Text="Gamertag:",DrawPivot=DP_MiddleMiddle,MaxSizeX=0.700000,Style="NormalLabel")
     Info(1)=(Text="Game name: Pariah")
     Options(0)=(Blurred=(Text="Great session"),OnSelect="OnFeedback",Style="CenteredTextOption")
     Options(1)=(Blurred=(Text="Good attitude"))
     Options(2)=(Blurred=(Text="Bad name"))
     Options(3)=(Blurred=(Text="Cursing or lewdness"))
     Options(4)=(Blurred=(Text="Screaming"))
     Options(5)=(Blurred=(Text="Cheating"))
     Options(6)=(Blurred=(Text="Threats or harassment"))
     Options(7)=(Blurred=(Text="Offensive message"))
     InfoLayout=(PosX=0.500000,PosY=0.250000,SpacingY=0.050000,BorderScaleX=0.700000,Pivot=DP_MiddleMiddle)
     OptionsLayout=(PosX=0.500000,PosY=0.590000,SpacingY=0.050000,BorderScaleX=0.700000,Pivot=DP_MiddleMiddle)
     MenuTitle=(Text="Player Feedback")
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
