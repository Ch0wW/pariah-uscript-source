class ScoreBoardDeathMatch extends ScoreBoardBase;

const MaxScores = 32;

// gamestats
var() MenuText      Players  [MaxScores];
var() MenuText      Points   [MaxScores];
var() MenuText      Pings    [MaxScores];

var() MenuText      PingLabel;

var() MenuSprite    HighLight       [MaxScores];
var() MenuSprite    CommunicatorOn	[MaxScores];

var() localized String  CommChannelNames[6];

simulated function Init( String Args )
{
    CommunicatorOn[0].bHidden = 1;
    
    LanguageChange();
}

simulated function LanguageChange()
{
    PlayerNameLabel.Text = PlayerText;
	ScoreLabel.Text = ScoresTitle;
    PingLabel.Text = PingsTitle;
}

simulated event UpdateScoreBoard()
{
    local int RowIndex, PriIndex;

	// -- ADD THIS LATER FragLimitTitle.Text = ( FragLimit$GRI.GoalScore@Spacer@TimeLimit$GRI.TimeLimit );

    MenuTitle.Text = InitTitle();

    PriIndex = 0;
    PlayerIndex = -1;

    for( RowIndex = 0; RowIndex < ArrayCount(Players); RowIndex++ ) 
    {
        if( PriIndex >= PRIArray.Length )
            break;
    
        ShowIndex(RowIndex);
        // record owner player index and swap swap out for Player Highlight
        if (PRIArray[PriIndex] == Controller(Owner).PlayerReplicationInfo)
		{
            HighLight[RowIndex].bHidden = 0;
			HighLight[RowIndex].DrawColor = ScoreboardNumberList;
			HighLight[RowIndex].DrawColor.A = 20;
			PlayerIndex = RowIndex;
		}
		else
		{
			HighLight[RowIndex].bHidden = 1;
		}
			
        if( !IsOnlySpectator( PRIArray[PriIndex] ) )
        {
			Points[RowIndex].DrawColor = ScoreboardNumberList;
            Pings[RowIndex].DrawColor = ScoreboardNumberList;
            Points[RowIndex].Text = String( int( PRIArray[PriIndex].Score ) );
        }
        else
        {
            Points[RowIndex].Text = "-";
        }
   
		if ( PRIArray[PriIndex].bBot )
		{
            
            CommunicatorOn[RowIndex].bHidden = 1;
			Players[RowIndex].DrawColor = ScoreboardBotList;
			Players[RowIndex].Text = "bot -"@PRIArray[PriIndex].RetrivePlayerName();
            Pings[RowIndex].Text = "-";
		}
		else
		{
			Players[RowIndex].DrawColor = ScoreboardList;
			Players[RowIndex].Text = PRIArray[PriIndex].RetrivePlayerName();
            Pings[RowIndex].Text = string( PRIArray[PriIndex].Ping );
		}

        if(PRIArray[PriIndex].bHasVoice )
        {
            CommunicatorOn[RowIndex].bHidden = 0;

            if(PRIArray[PriIndex].bIsTalking)
                CommunicatorOn[RowIndex].WidgetTexture = AnimatedCommunicator;
            else
                CommunicatorOn[RowIndex].WidgetTexture = default.CommunicatorOn[0].WidgetTexture;
        }else
        {
            CommunicatorOn[RowIndex].bHidden = 1;
        }
        PriIndex++;
    }

    // hide unfilled rows
    while( RowIndex < ArrayCount(Players) )
		ShowIndex( RowIndex++, 1 );
}

function ShowIndex(int i, optional int bHide)
{
	HighLight[i].bHidden = 1;
    
    CommunicatorOn[i].bHidden = bHide; 
    Players[i].bHidden   = bHide;
    Points[i].bHidden    = bHide;
    Pings[i].bHidden    = bHide;
}

defaultproperties
{
     Players(0)=(PosX=0.250000,PosY=0.155000,ScaleX=0.500000,ScaleY=0.500000,MaxSizeX=0.250000,Pass=2,Style="TitleText")
     Players(1)=(PosY=0.180000)
     Points(0)=(PosX=0.100000,PosY=0.155000,ScaleX=0.500000,ScaleY=0.500000,Pass=2,Style="TitleText")
     Points(1)=(PosY=0.180000)
     Pings(0)=(PosX=0.500000,PosY=0.155000,ScaleX=0.500000,ScaleY=0.500000,Pass=2,Style="TitleText")
     Pings(1)=(PosY=0.180000)
     PingLabel=(DrawColor=(B=127,G=127,R=127,A=255),PosX=0.500000,PosY=0.115000,ScaleX=0.650000,ScaleY=0.650000,Pass=2,Style="TitleText")
     HighLight(0)=(WidgetTexture=Texture'Engine.PariahWhiteTexture',RenderStyle=STY_Alpha,DrawColor=(G=150,R=255,A=255),DrawPivot=DP_LowerLeft,PosX=0.050000,PosY=0.150000,ScaleX=46.000000,ScaleY=1.500000,ScaleMode=MSM_Stretch)
     HighLight(1)=(PosY=0.175000)
     CommunicatorOn(0)=(WidgetTexture=Texture'InterfaceContent.LiveIcons.CommunicatorOn',RenderStyle=STY_Alpha,DrawPivot=DP_LowerLeft,PosX=0.175000,PosY=0.168000,ScaleX=0.450000,ScaleY=0.450000)
     CommunicatorOn(1)=(PosY=0.193000)
     CommChannelNames(0)="CH1"
     CommChannelNames(1)="CH2"
     CommChannelNames(2)="CH3"
     CommChannelNames(3)="CH4"
     CommChannelNames(4)="CH5"
     CommChannelNames(5)="CH6"
     ScoreLabel=(DrawColor=(B=127,G=127,R=127,A=255),PosX=0.100000,PosY=0.115000,ScaleX=0.650000,ScaleY=0.650000,Pass=2,Style="TitleText")
     PlayerNameLabel=(DrawColor=(B=127,G=127,R=127,A=255),PosX=0.250000,PosY=0.115000,ScaleX=0.650000,ScaleY=0.650000,Pass=2,Style="TitleText")
     BottomBar=(ScaleY=0.070000)
     Background=(ScaleX=0.900000)
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
