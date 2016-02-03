// this will hang off of hud and have input redirected to it while active
class HudXboxSpeechOverlay extends MenuTemplate;

var PlayerController player;
var bool bTDM;

var() MenuSprite ButtonBorder;

var() MenuSprite XboxIconA;
var() MenuText   ALabel;

var() MenuSprite XboxIconB;
var() MenuText   BLabel;

var() MenuSprite XboxIconX;
var() MenuText   XLabel;

var() MenuSprite XboxIconY;
var() MenuText   YLabel;

var() localized string FollowText;

simulated function SetPlayer(PlayerController inPlayer)
{
    player = inPlayer;
}

simulated function ReopenInit()
{
    player.PlayBeepSound();
    if (player.GameReplicationInfo.bTeamGame && player.PlayerReplicationInfo.Team.TeamIndex == 0)
    {
        ButtonBorder.DrawColor.R = 80;
        ButtonBorder.DrawColor.B = 0;
    }
    else
    {
        ButtonBorder.DrawColor.R = 0;
        ButtonBorder.DrawColor.B = 80;
    }

    bTDM = (player.GameReplicationInfo.GameClass == "XGame.xTeamGame");

    if (bTDM)
    {
        XBoxIconX.bHidden = 1;
        XLabel.bHidden = 1;
        BLabel.Text = FollowText;
    }

	if(player.bHasVoice)
	{
		// mh
		//Again, the SRVocabulary value MUST match the enum value in the Speech Bank
		if(bTDM)
		{
			player.SRVocabulary = 0;
		}
		else
		{
			player.SRVocabulary = 1;
		}
		ConsoleCommand("SPEECHREC ON");
	}

    SetTimer(4.0, false);
}

simulated function Timer()
{
    if (player.MyHud.bShowVoiceMenu)
        Exit();
}

simulated function Exit()
{
    SetTimer(0, false);
    player.PlayBeepSound();

	if(player.bHasVoice)
	{
		ConsoleCommand("SPEECHREC OFF");
	}

    player.MyHud.bShowVoiceMenu = false;
    player.Player.Console.KeyMenuClose();
}

simulated function Taunt()
{
    xPlayer(player).LastVoiceTime = Level.TimeSeconds;
    player.Speech('AUTOTAUNT', player.PlayerReplicationInfo.VoiceType.static.PickRandomTauntFor(player, false, false), "");
    xPlayer(player).Taunt('');
}

simulated function OrderRoam()
{
    xPlayer(player).Order(4);
}

simulated function OrderAttack()
{
    if (!bTDM)
        xPlayer(player).Order(2);
}

simulated function OrderDefend()
{
    if (bTDM)
        xPlayer(player).Order(3);
    else
        xPlayer(player).Order(0);
}

simulated event bool HandleInputKeyRaw(Interactions.EInputKey Key, Interactions.EInputAction Action)
{
    if(Action != IST_Press)
    {
        return(false);
    }
    //log("HandleInputKey!"@Key);

    if (IsOnConsole())
    {
        switch ( Key )
        {
            case IK_Joy3: // A
                OrderRoam();
                break;
            case IK_Joy2: // B
                OrderDefend();
                break;
            case IK_Joy4: // X
                OrderAttack();
                break;
            case IK_Joy1: // Y
                Taunt();
                break;
            case IK_Joy9:// Start
                Exit();
            default:
                return false;
                break;
        }
    }
    else
    {
        switch ( Key )
        {
            case IK_1:
                OrderRoam();
                break;
            case IK_2:
                OrderDefend();
                break;
            case IK_3:
                OrderAttack();
                break;
            case IK_4:
                Taunt();
                break;
            case IK_Escape:
                break;
            default:
                return false;
                break;
        }
    }

    Exit();
    return true;
}

defaultproperties
{
     ButtonBorder=(WidgetTexture=Texture'InterfaceContent.Menu.BorderBoxC',DrawColor=(R=80,A=255),PosX=0.070000,PosY=0.460000,ScaleX=0.400000,ScaleY=0.310000,ScaleMode=MSM_FitStretch,Pass=1)
     XboxIconA=(DrawPivot=DP_MiddleRight,PosX=0.130000,PosY=0.510000,Style="XboxButtonA")
     ALabel=(Text=": FREELANCE",DrawPivot=DP_MiddleLeft,PosX=0.130000,PosY=0.510000,ScaleX=1.000000,ScaleY=1.000000,Style="LabelText")
     XboxIconB=(DrawPivot=DP_MiddleRight,PosX=0.130000,PosY=0.580000,Style="XboxButtonB")
     BLabel=(Text=": DEFEND",DrawPivot=DP_MiddleLeft,PosX=0.130000,PosY=0.580000,ScaleX=1.000000,ScaleY=1.000000,Style="LabelText")
     XboxIconX=(DrawPivot=DP_MiddleRight,PosX=0.130000,PosY=0.650000,Style="XboxButtonX")
     XLabel=(Text=": ATTACK",DrawPivot=DP_MiddleLeft,PosX=0.130000,PosY=0.650000,ScaleX=1.000000,ScaleY=1.000000,Style="LabelText")
     XboxIconY=(DrawPivot=DP_MiddleRight,PosX=0.130000,PosY=0.720000,Style="XboxButtonY")
     YLabel=(Text=": TAUNT",DrawPivot=DP_MiddleLeft,PosX=0.130000,PosY=0.720000,ScaleX=1.000000,ScaleY=1.000000,Style="LabelText")
     FollowText=": FOLLOW"
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
