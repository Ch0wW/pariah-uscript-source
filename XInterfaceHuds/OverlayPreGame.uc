class OverlayPreGame extends VignetteLoading;

var() MenuText WaitingForPlayers;
var() MenuText PressFire;
var() MenuText MOTDTitle;
var() MenuText MOTDText;

var() float FadeEndTime;

const PRE_FADE_TIME = 3.0;
const TIME_TO_FADE = 1.0;

var() float FadeTime;
var() float Fade;

simulated function Init( String Args )
{
    Super.Init( Args );
    RollBink();
    
    if( class'VignetteConnecting'.default.ServerName == "" )
    {
        MenuTitle.Text = class'VignetteConnecting'.default.StringConnecting;
    }
    else
    {
        MenuTitle.Text = ReplaceSubstring( class'VignetteConnecting'.default.StringConnectingTo, "<SERVERNAME>", class'VignetteConnecting'.default.ServerName );
    }
}

auto state WaitingForPostLevelChange
{
    ignores Tick;
        
    simulated function PostLevelChange()
    {
        Super.PostLevelChange();
        GotoState('WaitingForReplication');
    }
}

auto state WaitingForReplication
{
    ignores Tick;

    simulated function BeginState()
    {
        SetTimer( 1.0, true );
    }
    
    simulated function EndState()
    {
        SetTimer( 0, true );
    }
    
    simulated function Timer()
    {
        if( FullyReplicated() )
        {
            GotoState('FadingAway');
        }
    }
    
    simulated function bool FullyReplicated()
    {
        local PlayerController PC;
        
        PC = PlayerController(Owner);
         
        if( PC.Player == None )
        {
            return(false);
        }
        
        if( PC.PlayerReplicationInfo == None )
        {
            return(false);
        }        

        if( PC.GameReplicationInfo == None )
        {
            return(false);
        }
        
        return(true);
    }
}

state FadingAway
{
    simulated function BeginState()
    {
        PlayerController(Owner).PlayLoadOutFlyBy();
        bRenderLevel = true;

        WaitingForPlayers.bHidden = 1;
        PressFire.bHidden = 0;
        
        Fade = Background.DrawColor.A;
        ShowMOTD(); 
    }
    
    simulated function ShowMOTD()
	{
		if( Level.Netmode==NM_Standalone )
			return;
		
		if ( PlayerController(Owner)==None || PlayerController(Owner).GameReplicationInfo==None)
    		return;
		
		if(PlayerController(Owner).GameReplicationInfo.MessageOfTheDay != "")
			MOTDTitle.bHidden = 0;
				
		MOTDText.Text = PlayerController(Owner).GameReplicationInfo.MessageOfTheDay;
	}
	
    simulated function Tick( float Delta )
    {
        local bool Done;

        Super.Tick( Delta );
        
        Fade -= 255.f * (Delta / FadeTime);
        
        if( Fade <= 0.f )
        {
            Fade = 0.f;
            Done = true;
        }
    
        Background.DrawColor.A = Fade;
        MenuTitle.DrawColor.A = Fade;
        LoadingMapName.DrawColor.A = Fade;
        
        MOTDTitle.DrawColor.A = 255.f - Fade;
		MOTDText.DrawColor.A = 255.f - Fade; 

        if( Done )
        {
            GotoState( 'Done' );
        }
    }
}

state Done
{
    ignores Tick;
    
    simulated function BeginState()
    {
        Timer();
        SetTimer( 1.0, true );
    }
    
    simulated function EndState()
    {
        SetTimer( 0, true );
    }

    simulated function Timer()
    {
        local PlayerController PC;
        
        PC = PlayerController(Owner);

        if( PC.PlayerReplicationInfo.bWaitingPlayer && PC.PlayerReplicationInfo.bReadyToPlay )
        {
            WaitingForPlayers.bHidden = 0;
            PressFire.bHidden = 1;
        }
        else
        {
            WaitingForPlayers.bHidden = 1;
            PressFire.bHidden = 0;
        }
    }
}

defaultproperties
{
     WaitingForPlayers=(Text="Waiting for other players...",DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.896000,bHidden=1,Style="LabelText")
     PressFire=(Text="Press fire to begin",DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.896000,bHidden=1,Style="LabelText")
     MOTDTitle=(Text="Message of the Day",PosX=0.080000,PosY=0.130000,ScaleX=0.650000,ScaleY=0.650000,Pass=2,bHidden=1,Style="NormalLabel")
     MOTDText=(DrawColor=(B=255,G=255,R=255,A=255),PosX=0.100000,PosY=0.300000,ScaleX=0.500000,ScaleY=0.500000,MaxSizeX=0.500000,bWordWrap=1,Style="SmallLabel")
     FadeTime=1.000000
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
