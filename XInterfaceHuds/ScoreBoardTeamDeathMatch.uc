class ScoreBoardTeamDeathMatch extends ScoreBoardBase;

const MaxTeammates = 16; // Max Visible on the screen

var() localized string TeamAText;
var() localized string TeamBText;

var() MenuText	TeamScore[2];
var() MenuText  GameInfo, gameStats;
var() MenuText  TeamAPlayers     [MaxTeammates];
var() MenuText  TeamBPlayers     [MaxTeammates];
var() MenuText  TeamAScores      [MaxTeammates];
var() MenuText  TeamBScores      [MaxTeammates];
var() MenuText  TeamAPings       [MaxTeammates]; //msp: to see the poor fuckers with low pings
var() MenuText  TeamBPings       [MaxTeammates];

var() MenuSprite RedBackground;
var() MenuSprite BlueBackground;
var() MenuSprite RedScoreLine;
var() MenuSprite BlueScoreLine;
var() MenuSprite RedPingLine;
var() MenuSprite BluePingLine;

var() MenuSprite RedHighLight		    [MaxTeammates];
var() MenuSprite BlueHighLight		    [MaxTeammates];
var() MenuSprite RedCommunicatorOn	    [MaxTeammates];
var() MenuSprite BlueCommunicatorOn	    [MaxTeammates];

var() int FirstTeamBIndex; // team.teamindex == 1
var() int LastTeamBIndex;  // (Spectators follow)
var() int PlayerTeamIndex;

// Communicator things
var() localized String  CommChannelNames[9];
var() byte AlphaHighlight;

var() MenuText Scores[2], PlayerNames[2], PingsLabels[2];

var() Color	BGColorRed;
var() Color	BGColorBlue;

simulated event UpdateScoreBoard()
{
    local int i, RedCount, BlueCount;

    RedCount=0;
    BlueCount=0;
	Scores[0].Text = ScoresTitle;
	PlayerNames[0].Text = PlayerNamesTitle;
    PingsLabels[0].Text = PingsTitle;

    Scores[1].Text = ScoresTitle;
	PlayerNames[1].Text = PlayerNamesTitle;
    PingsLabels[1].Text = PingsTitle;

    RedBackGround.DrawColor = BGColorRed;
    BlueBackGround.DrawColor = BGColorBlue;
    

    for (i=0; i<PRIArray.Length; ++i)
    {
        if (PRIArray[i]== None )
            break;

        if ( IsOnlySpectator( PRIArray[i] ) )
            break;

        if (PRIArray[i].Team.TeamIndex == 0)
        {
            if( RedCount>=MaxTeammates )
                continue;
            
            HideRedCommunictorIcon(RedCount, true);

            if( PRIArray[i].bBot )
                HideRedCommunictorIcon(RedCount, true );
           
            if( PRIArray[i].bHasVoice )
            {
                HideRedCommunictorIcon(RedCount, false);

                if(PRIArray[i].bIsTalking)
                    RedCommunicatorOn[RedCount].WidgetTexture = AnimatedCommunicator;
                else
                    RedCommunicatorOn[RedCount].WidgetTexture = default.RedCommunicatorOn[0].WidgetTexture;
            }
             

            TeamScore[0].Text = string( int( GRI.Teams[0].Score));
            RedHighLight[RedCount].bHidden = 1;
            TeamAPlayers[RedCount].Text = PRIArray[i].RetrivePlayerName();
            TeamAScores[RedCount].Text = string( int( PRIArray[i].Score ) );
            TeamAPings[RedCount].Text = string( PRIArray[i].Ping );

            if (PRIArray[i] == Controller(Owner).PlayerReplicationInfo)
                RedHighLight[RedCount].bHidden = 0;

            ++RedCount;
        }

        if (PRIArray[i].Team.TeamIndex == 1)
        {
            if( BlueCount>=MaxTeammates )
                continue;

            HideBlueCommunictorIcon(BlueCount, true);
            if( PRIArray[i].bBot )
                HideBlueCommunictorIcon(BlueCount, true );

            if( PRIArray[i].bHasVoice )
            {
                HideBlueCommunictorIcon(BlueCount, false);

                if(PRIArray[i].bIsTalking)
                    BlueCommunicatorOn[BlueCount].WidgetTexture = AnimatedCommunicator;
                else
                    BlueCommunicatorOn[BlueCount].WidgetTexture = default.BlueCommunicatorOn[0].WidgetTexture;
            }

            TeamScore[1].Text = string( int( GRI.Teams[1].Score));
            BlueHighLight[BlueCount].bHidden = 1;
            TeamBPlayers[BlueCount].Text = PRIArray[i].RetrivePlayerName();
            TeamBScores[BlueCount].Text = string( int( PRIArray[i].Score ) );
            TeamBPings[BlueCount].Text = string( PRIArray[i].Ping );
          
            if (PRIArray[i] == Controller(Owner).PlayerReplicationInfo)
                BlueHighLight[BlueCount].bHidden = 0;

            ++BlueCount;
        }
    }
 


    for (i=RedCount; i<MaxTeammates; i++)
    { 
        TeamAPlayers[i].Text	= "";
        TeamAScores[i].Text		= "";
        TeamAPings[i].Text		= "";
        RedHighLight[i].bHidden = 1;
        HideRedCommunictorIcon(i, true);
    }

    for (i=BlueCount; i<MaxTeammates; i++)
    {
        TeamBPlayers[i].Text	= "";
        TeamBScores[i].Text		= "";
        TeamBPings[i].Text		= "";
        BlueHighLight[i].bHidden = 1;
        HideBlueCommunictorIcon(i, true);
    }

}

simulated function HideRedCommunictorIcon(int i, bool bHide)
{
    if(!bHide)
    {
        RedCommunicatorOn[i].bHidden   = 0;
        
        return;
    }

    RedCommunicatorOn[i].bHidden   = 1;
}


simulated function HideBlueCommunictorIcon(int i, bool bHide)
{
    if(!bHide)
    {
        BlueCommunicatorOn[i].bHidden   = 0;
        
        return;
    }
    BlueCommunicatorOn[i].bHidden   = 1; 
}

defaultproperties
{
     TeamAText="Red Team"
     TeamBText="Blue Team"
     TeamScore(0)=(DrawColor=(B=255,G=255,R=255,A=255),PosX=0.260000,PosY=0.140000,ScaleX=1.000000,ScaleY=1.000000,Pass=1,Style="TitleText")
     TeamScore(1)=(DrawColor=(B=255,G=255,R=255,A=255),PosX=0.700000,PosY=0.140000,ScaleX=1.000000,ScaleY=1.000000,Pass=1,Style="TitleText")
     TeamAPlayers(0)=(DrawColor=(B=255,G=255,R=255,A=255),PosX=0.200000,PosY=0.220000,ScaleX=0.500000,ScaleY=0.500000,MaxSizeX=0.210000,Pass=1,Style="TitleText")
     TeamAPlayers(1)=(PosY=0.260000)
     TeamBPlayers(0)=(DrawColor=(B=255,G=255,R=255,A=255),PosX=0.640000,PosY=0.220000,ScaleX=0.500000,ScaleY=0.500000,MaxSizeX=0.210000,Pass=1,Style="TitleText")
     TeamBPlayers(1)=(PosY=0.260000)
     TeamAScores(0)=(DrawColor=(B=255,G=255,R=255,A=255),PosX=0.070000,PosY=0.220000,ScaleX=0.500000,ScaleY=0.500000,Pass=1,Style="TitleText")
     TeamAScores(1)=(PosY=0.260000)
     TeamBScores(0)=(DrawColor=(B=255,G=255,R=255,A=255),PosX=0.510000,PosY=0.220000,ScaleX=0.500000,ScaleY=0.500000,Pass=1,Style="TitleText")
     TeamBScores(1)=(PosY=0.260000)
     TeamAPings(0)=(DrawColor=(B=255,G=255,R=255,A=255),PosX=0.420000,PosY=0.220000,ScaleX=0.500000,ScaleY=0.500000,Pass=1,Style="TitleText")
     TeamAPings(1)=(PosY=0.260000)
     TeamBPings(0)=(DrawColor=(B=255,G=255,R=255,A=255),PosX=0.860000,PosY=0.220000,ScaleX=0.500000,ScaleY=0.500000,Pass=1,Style="TitleText")
     TeamBPings(1)=(PosY=0.260000)
     RedBackground=(WidgetTexture=Texture'Engine.PariahWhiteTexture',ScaleX=0.500000,ScaleY=0.900000,ScaleMode=MSM_Fit)
     BlueBackground=(WidgetTexture=Texture'Engine.PariahWhiteTexture',PosX=0.500000,ScaleX=0.500000,ScaleY=0.900000,ScaleMode=MSM_Fit)
     RedScoreLine=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(B=255,G=255,R=255,A=15),PosX=0.060000,ScaleX=0.122000,ScaleY=0.900000,ScaleMode=MSM_Fit)
     BlueScoreLine=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(B=255,G=255,R=255,A=15),PosX=0.500000,ScaleX=0.122000,ScaleY=0.900000,ScaleMode=MSM_Fit)
     RedPingLine=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(B=255,G=255,R=255,A=15),PosX=0.410000,ScaleX=0.090000,ScaleY=0.900000,ScaleMode=MSM_Fit)
     BluePingLine=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(B=255,G=255,R=255,A=15),PosX=0.850000,ScaleX=0.090000,ScaleY=0.900000,ScaleMode=MSM_Fit)
     RedHighLight(0)=(WidgetTexture=Texture'Engine.PariahWhiteTexture',RenderStyle=STY_Alpha,DrawColor=(B=150,G=150,R=150,A=50),DrawPivot=DP_LowerLeft,PosX=0.060000,PosY=0.215000,ScaleX=35.150002,ScaleY=1.770000,ScaleMode=MSM_Stretch)
     RedHighLight(1)=(PosY=0.255000)
     BlueHighLight(0)=(WidgetTexture=Texture'Engine.PariahWhiteTexture',RenderStyle=STY_Alpha,DrawColor=(B=150,G=150,R=150,A=50),DrawPivot=DP_LowerLeft,PosX=0.500000,PosY=0.215000,ScaleX=35.150002,ScaleY=1.770000,ScaleMode=MSM_Stretch)
     BlueHighLight(1)=(PosY=0.255000)
     RedCommunicatorOn(0)=(WidgetTexture=Texture'InterfaceContent.LiveIcons.CommunicatorOn',RenderStyle=STY_Alpha,DrawPivot=DP_LowerLeft,PosX=0.150000,PosY=0.325000,ScaleX=0.450000,ScaleY=0.450000)
     RedCommunicatorOn(1)=(PosY=0.365000)
     BlueCommunicatorOn(0)=(WidgetTexture=Texture'InterfaceContent.LiveIcons.CommunicatorOn',RenderStyle=STY_Alpha,DrawPivot=DP_LowerLeft,PosX=0.590000,PosY=0.325000,ScaleX=0.450000,ScaleY=0.450000)
     BlueCommunicatorOn(1)=(PosY=0.365000)
     CommChannelNames(0)="R1"
     CommChannelNames(1)="B1"
     CommChannelNames(2)="R2"
     CommChannelNames(3)="B2"
     CommChannelNames(4)="R3"
     CommChannelNames(5)="B3"
     CommChannelNames(6)="N1"
     CommChannelNames(7)="N2"
     CommChannelNames(8)="N3"
     Scores(0)=(DrawColor=(B=127,G=127,R=127,A=255),PosX=0.070000,PosY=0.175000,ScaleX=0.500000,ScaleY=0.500000,Pass=1,Style="TitleText")
     Scores(1)=(PosX=0.510000)
     PlayerNames(0)=(DrawColor=(B=127,G=127,R=127,A=255),PosX=0.200000,PosY=0.175000,ScaleX=0.500000,ScaleY=0.500000,Pass=1,Style="TitleText")
     PlayerNames(1)=(PosX=0.640000)
     PingsLabels(0)=(DrawColor=(B=127,G=127,R=127,A=255),PosX=0.420000,PosY=0.175000,ScaleX=0.500000,ScaleY=0.500000,Pass=1,Style="TitleText")
     PingsLabels(1)=(PosX=0.860000)
     BGColorRed=(R=80,A=120)
     BGColorBlue=(B=105,G=66,R=30,A=120)
     sbTimeLimit(0)=(PosX=0.180000,PosY=0.948000,ScaleX=0.500000,ScaleY=0.500000)
     sbTimeLimit(1)=(PosX=0.070000,PosY=0.948000,ScaleX=0.500000,ScaleY=0.500000)
     sbTimeRemaining(0)=(PosX=0.180000,PosY=0.978000,ScaleX=0.500000,ScaleY=0.500000)
     sbTimeRemaining(1)=(PosX=0.070000,PosY=0.978000,ScaleX=0.500000,ScaleY=0.500000)
     sbFragLimit(0)=(PosX=0.180000,PosY=0.918000,ScaleX=0.500000,ScaleY=0.500000)
     sbFragLimit(1)=(PosX=0.070000,PosY=0.918000,ScaleX=0.500000,ScaleY=0.500000)
     Background=(ScaleX=1.000000)
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
