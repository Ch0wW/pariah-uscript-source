// this will hang off of hud and have input redirected to it while active
class HudXboxVoiceChannelOverlay extends MenuTemplate;

var PlayerController    player;

var() MenuSprite        ButtonBorder;

var() MenuSprite        XboxIcons[6];
var() MenuText          VoiceChannels[6];

var() int				MAX_CHATTERS;
var() localized string  DeathmatchChannels[6];
var() localized string  TeamChannels[9];
var() int               ChannelMembers[9];

var() Color             CurrentChannelHiLite;
var() Color             NormalChannelHiLite;
var() Color             FullChannelHiLite;

var() int               CurrentChannel;

var() float             LastChannelTime;
var() float             RefreshTime;

var() GameReplicationInfo           GRI;
var() array<PlayerReplicationInfo>  PRIArray;

simulated function SetPlayer(PlayerController inPlayer)
{
    player = inPlayer;
}

simulated function ReopenInit()
{
    player.PlayBeepSound();

    // set the border color based on the player's current team
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
    
    // set the player's current channel
    CurrentChannel = player.VoiceChannel;
    
    // get all PRI's so we know who's in what channels
    GRI = player.GameReplicationInfo;
    if (GRI != None)
    {
        GRI.AddPRIArrayUser(self);
        GRI.GetPRIArray(PRIArray);
    }    

    RefreshChannels();    
    SetTimer(0.5, true);
    RefreshTime = Level.TimeSeconds;
    LastChannelTime = RefreshTime;
}

simulated function PRIArrayUpdated()
{
    GRI.GetPRIArray(PRIArray);
    RefreshChannels();
}

simulated function RefreshChannels()
{
    local int i;

    if (CurrentChannel != player.VoiceChannel)
        CurrentChannel = player.VoiceChannel;

    // determine which channels are full
    for(i = 0; i < 9; i++)
        ChannelMembers[i] = 0;
    for(i = 0; i < PRIArray.Length; i++)
    {
        if ((PRIArray[i].VoiceChannel < 0) || (PRIArray[i].bBot) || (!PRIArray[i].bHasVoice))
            continue;
        
        ChannelMembers[PRIArray[i].VoiceChannel]++;
    }
    
    // set the text accordingly (deathmatch OR any team game)
    if (player.GameReplicationInfo.bTeamGame)
    {
        // initialize all channel colors
        for(i = 0; i < 6; i++)
            VoiceChannels[i].DrawColor = NormalChannelHiLite;

        if (ChannelMembers[6] >= MAX_CHATTERS)
            VoiceChannels[3].DrawColor = FullChannelHiLite;
        if (ChannelMembers[7] >= MAX_CHATTERS)
            VoiceChannels[4].DrawColor = FullChannelHiLite;
        if (ChannelMembers[8] >= MAX_CHATTERS)
            VoiceChannels[5].DrawColor = FullChannelHiLite;
        
        if (player.PlayerReplicationInfo.Team.TeamIndex == 0)
        {
            // initialize all channel colors
            if (ChannelMembers[0] >= MAX_CHATTERS)
                VoiceChannels[0].DrawColor = FullChannelHiLite;
            if (ChannelMembers[2] >= MAX_CHATTERS)
                VoiceChannels[1].DrawColor = FullChannelHiLite;
            if (ChannelMembers[4] >= MAX_CHATTERS)
                VoiceChannels[2].DrawColor = FullChannelHiLite;
            
            VoiceChannels[0].Text = TeamChannels[0] $ " (" $ ChannelMembers[0] $ ")";
            VoiceChannels[1].Text = TeamChannels[2] $ " (" $ ChannelMembers[2] $ ")";;
            VoiceChannels[2].Text = TeamChannels[4] $ " (" $ ChannelMembers[4] $ ")";;
        }
        else
        {
            // initialize all channel colors
            if (ChannelMembers[1] >= MAX_CHATTERS)
                VoiceChannels[0].DrawColor = FullChannelHiLite;
            if (ChannelMembers[3] >= MAX_CHATTERS)
                VoiceChannels[1].DrawColor = FullChannelHiLite;
            if (ChannelMembers[5] >= MAX_CHATTERS)
                VoiceChannels[2].DrawColor = FullChannelHiLite;

            VoiceChannels[0].Text = TeamChannels[1] $ " (" $ ChannelMembers[1] $ ")";
            VoiceChannels[1].Text = TeamChannels[3] $ " (" $ ChannelMembers[3] $ ")";
            VoiceChannels[2].Text = TeamChannels[5] $ " (" $ ChannelMembers[5] $ ")";
        }

        VoiceChannels[3].Text = TeamChannels[6] $ " (" $ ChannelMembers[6] $ ")";
        VoiceChannels[4].Text = TeamChannels[7] $ " (" $ ChannelMembers[7] $ ")";
        VoiceChannels[5].Text = TeamChannels[8] $ " (" $ ChannelMembers[8] $ ")";

        if (CurrentChannel >= 0)
        {            
            if (CurrentChannel <= 5)
                VoiceChannels[CurrentChannel/2].DrawColor = CurrentChannelHiLite;
            else
                VoiceChannels[CurrentChannel-3].DrawColor = CurrentChannelHiLite;
        }
    }
    else
    {
        // initialize all channel colors
        for(i = 0; i < 6; i++)
        {
            if (ChannelMembers[i] >= MAX_CHATTERS)
                VoiceChannels[i].DrawColor = FullChannelHiLite;
            else
                VoiceChannels[i].DrawColor = NormalChannelHiLite;
        }
        
        for(i = 0; i < 6; i++)
            VoiceChannels[i].Text = DeathmatchChannels[i] $ " (" $ ChannelMembers[i] $ ")";
    
        if (CurrentChannel >= 0)
        {
            // highlight the player's current channel    
            VoiceChannels[CurrentChannel].DrawColor = CurrentChannelHiLite;
        }
    }
}

simulated function Timer()
{
    local bool Refresh;
    
    if (Level.TimeSeconds > LastChannelTime+4.0)
    {
        Exit();
        return;
    }
    
    if (Level.TimeSeconds < RefreshTime+0.5)
    {
        Refresh = false;
    }
    else
    {
        RefreshTime = Level.TimeSeconds;
        Refresh = true;
    }

    if (CurrentChannel != player.VoiceChannel || Refresh)
        RefreshChannels();
}

simulated function Exit()
{
    SetTimer(0, false);
    player.PlayBeepSound();
    player.MyHud.bShowVoiceChannelMenu = false;
    player.Player.Console.KeyMenuClose();
}

simulated function DrawMenu(Canvas C, bool HasFocus)
{
    if (C.ClipY < 480 && C.ClipX == 640)
        ButtonBorder.ScaleY = 4.0;
    else
        ButtonBorder.ScaleY = 6.0;

    Super.DrawMenu(C,HasFocus);
}

simulated event JoinChannel(int Channel)
{
    local XBoxAddr EmptyAddr;    
    
    if (player.GameReplicationInfo.bTeamGame)
    {
        if (Channel >= 3)
        {
            Channel += 3;
        }
        else if (player.PlayerReplicationInfo.Team.TeamIndex == 0)
        {
            if (Channel != 0)
                Channel *= 2;
        }
        else
        {
            if (Channel == 0)
                Channel++;
            else
                Channel = (Channel * 2)+1;
        }
        
        // don't even try to join a channel we think is full (may be lagged by the server (ie actually have room) by a little bit, but that's fine)
        if (ChannelMembers[Channel] >= MAX_CHATTERS)
            return;

        player.ServerChangeChannel(player, EmptyAddr, 0, -4-Channel );    
    }
    else
    {
        // don't even try to join a channel we think is full (may be lagged by the server (ie actually have room) by a little bit, but that's fine)
        if (ChannelMembers[Channel] >= MAX_CHATTERS)
            return;
        
        player.ServerChangeChannel(player, EmptyAddr, 0, -4-Channel );    
    }
}

simulated event bool HandleInputKeyRaw(Interactions.EInputKey Key, Interactions.EInputAction Action)
{
    if(Action != IST_Press)
    {
        return(false);
    }
    if (IsOnConsole())
    {
        // prevent RPC storms...(eat A,B,X,Y)        
        //if ((Level.TimeSeconds < LastChannelTime+0.6) && (Key == IK_Joy1 || Key == IK_Joy2 || Key == IK_Joy3 || Key == IK_Joy4))
        //    return true;
        
        //LastChannelTime = Level.TimeSeconds;        
        
        switch ( Key )
        {
            case IK_Joy3: // A
                JoinChannel(0);
                break;
            case IK_Joy2: // B
                JoinChannel(1);
                break;
            case IK_Joy4: // X
                JoinChannel(2);
                break;
            case IK_Joy1: // Y
                JoinChannel(3);
                break;
            case IK_JoyPovLeft:
                JoinChannel(4);
                break;
            case IK_JoyPovRight:
                JoinChannel(5);
                break;
            case IK_Joy9: // Start
                //Exit();
                break;
            case IK_Joy10: // Back
                //Exit();
                break;
            default:
                return false;
                break;
        }
    }
    else
    {
        switch ( Key )
        {
            case IK_3:
                JoinChannel(0);
                break;
            case IK_2:
                JoinChannel(1);
                break;
            case IK_4:
                JoinChannel(2);
                break;
            case IK_1:
                JoinChannel(3);
                break;
            case IK_5:
                JoinChannel(4);
                break;
            case IK_6:
                JoinChannel(5);
                break;
            case IK_Escape:
                break;
            default:
                return false;
                break;
        }
    }

    Exit(); // allows multiple channel selection if we comment this out and refresh periodically...
    return true;
}

simulated function Destroyed()
{
    if (GRI != None)
    {
        GRI.RemovePRIArrayUser(self);
    }
    Super.Destroyed();
}

defaultproperties
{
     ButtonBorder=(WidgetTexture=Texture'InterfaceContent.Menu.BorderBoxC',DrawColor=(R=80,A=255),PosX=0.070000,PosY=0.250000,ScaleX=7.000000,ScaleY=6.000000,ScaleMode=MSM_Stretch,Pass=1)
     XboxIcons(0)=(DrawPivot=DP_MiddleRight,PosX=0.130000,PosY=0.300000,Style="XboxButtonA")
     XboxIcons(1)=(DrawPivot=DP_MiddleRight,PosX=0.130000,PosY=0.360000,Style="XboxButtonB")
     XboxIcons(2)=(DrawPivot=DP_MiddleRight,PosX=0.130000,PosY=0.420000,Style="XboxButtonX")
     XboxIcons(3)=(DrawPivot=DP_MiddleRight,PosX=0.130000,PosY=0.480000,Style="XboxButtonY")
     XboxIcons(4)=(WidgetTexture=FinalBlend'InterfaceContent.Menu.fbArrowLeft',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleRight,PosX=0.130000,PosY=0.540000,ScaleX=0.850000,ScaleY=0.850000,Pass=2)
     XboxIcons(5)=(WidgetTexture=FinalBlend'InterfaceContent.Menu.fbArrowRight',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleRight,PosX=0.130000,PosY=0.600000,ScaleX=0.850000,ScaleY=0.850000,Pass=2)
     VoiceChannels(0)=(Text=": EMPTY",DrawPivot=DP_MiddleLeft,PosX=0.130000,PosY=0.300000,ScaleX=1.000000,ScaleY=1.000000,Style="LabelText")
     VoiceChannels(1)=(DrawPivot=DP_MiddleLeft,PosX=0.130000,PosY=0.360000,ScaleX=1.000000,ScaleY=1.000000,Style="LabelText")
     VoiceChannels(2)=(DrawPivot=DP_MiddleLeft,PosX=0.130000,PosY=0.420000,ScaleX=1.000000,ScaleY=1.000000,Style="LabelText")
     VoiceChannels(3)=(DrawPivot=DP_MiddleLeft,PosX=0.130000,PosY=0.480000,ScaleX=1.000000,ScaleY=1.000000,Style="LabelText")
     VoiceChannels(4)=(DrawPivot=DP_MiddleLeft,PosX=0.130000,PosY=0.540000,ScaleX=1.000000,ScaleY=1.000000,Style="LabelText")
     VoiceChannels(5)=(DrawPivot=DP_MiddleLeft,PosX=0.130000,PosY=0.600000,ScaleX=1.000000,ScaleY=1.000000,Style="LabelText")
     MAX_CHATTERS=8
     DeathmatchChannels(0)=": CH 1"
     DeathmatchChannels(1)=": CH 2"
     DeathmatchChannels(2)=": CH 3"
     DeathmatchChannels(3)=": CH 4"
     DeathmatchChannels(4)=": CH 5"
     DeathmatchChannels(5)=": CH 6"
     TeamChannels(0)=": RED 1"
     TeamChannels(1)=": BLUE 1"
     TeamChannels(2)=": RED 2"
     TeamChannels(3)=": BLUE 2"
     TeamChannels(4)=": RED 3"
     TeamChannels(5)=": BLUE 3"
     TeamChannels(6)=": NEUTRAL 1"
     TeamChannels(7)=": NEUTRAL 2"
     TeamChannels(8)=": NEUTRAL 3"
     CurrentChannelHiLite=(B=80,G=220,R=80,A=255)
     NormalChannelHiLite=(B=180,G=180,R=180,A=255)
     FullChannelHiLite=(B=64,G=64,R=64,A=255)
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
