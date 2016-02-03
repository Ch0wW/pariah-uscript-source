class OverlayVoiceChannelMenu extends MenuTemplate;

struct RealChannel
{
    var array<String>   PlayerNames;  // The names of the gamers in this channel    
    var array<int>      TeamIndex;  // 0 for red, 1 for blue and 2 for neutral (same size as PlayerNames array)
    var int             FakeIndex;  // What is the fake channel index
};

const CHANNELS = 6;
const MAX_CHANNELS = 9; // 1.5 x channels
const MAX_CHATTERS = 8; // 6 x 8 is alot of talkers, but we'll only have 16 players at one time anywho!

var() MenuText          MenuTitle;
var() MenuSprite        TopBar;
var() MenuSprite        BottomBar;
var() MenuSprite        Background;

var() MenuButtonText	Options[CHANNELS];
var() MenuText			TextCurrentChannel;
var() MenuText			TextChannelFull;
var() MenuText			TextGamerChannel;
var() MenuText			PlayerNames[MAX_CHATTERS];
var() WidgetLayout 		ChannelOptionLayout;
var() WidgetLayout      PlayerNamesLayout;

var() localized string	StringCurrentChannel,VoiceChannelTitle;
var() localized string  StringTeam[3];

var() RealChannel       RealChannels[MAX_CHANNELS];
var() int               FakeChannels[CHANNELS];  // translation from our fake channel to the real index
var() Color	            ClrTeam[3];
var() int               TeamIndex;
var() int               FocusChannelIndex;

var() GameReplicationInfo           GRI;
var() array<PlayerReplicationInfo>  PRIArray;
var() Interactions.EInputKey        HoldKey;

/*******************************************************************************
	Function:   Init
	Created by: Mark Mikulec on 2004-12-30 17:24:15
	Notes:      Called when the menu is instanced, everytime the user hits the
                back button.
*******************************************************************************/
simulated function Init(String Args)
{	
    local int c;
    local Interactions.EInputAction Action;
    local float Delta;
    local int whichstring;
	
	Super.Init(Args);

    MenuTitle.Text = VoiceChannelTitle;
    VehiclePlayer(Owner).GetInputAction(Action, HoldKey, Delta);

    // Assert( Action == IST_Press );
    // Assert( HoldKey != IK_None );

    TextChannelFull.bHidden = 1;
    TextGamerChannel.bHidden = 0;

	for(c = 0; c < CHANNELS; c++)
	{
		Options[c].ContextID = c;
	}

    // get all PRI's so we know who's in what channels
    GRI = PlayerController(Owner).GameReplicationInfo;
    if (GRI != None)
    {
        GRI.AddPRIArrayUser(self);
        GRI.GetPRIArray(PRIArray);
    }

    // Is this a team or a ffa game?

    if (PlayerController(Owner).GameReplicationInfo.bTeamGame)
    {
        TeamIndex = PlayerController(Owner).PlayerReplicationInfo.Team.TeamIndex;

        for (c = 0; c < CHANNELS / 2; c++)                  // botton half either even or odd based on team
        {
            FakeChannels[c] = (c * 2) + TeamIndex;
            RealChannels[FakeChannels[c]].FakeIndex = c;    // And it the other way as well
        }
        for (c = CHANNELS / 2; c < CHANNELS; c++)           // top half same binding
        {
            FakeChannels[c] = c + CHANNELS / 2;
            RealChannels[FakeChannels[c]].FakeIndex = c;    // And it the other way as well
        }
    }
    else
    {
        TeamIndex = 2;
        for (c = 0; c < CHANNELS; c++)                      // If we're not in a team game, fake channel = real channel
        {
            FakeChannels[c] = c;
            RealChannels[c].FakeIndex = c;
        }
    }

    if (FocusChannelIndex < 3)
        whichstring = TeamIndex;
    else
        whichstring = 2;

    FocusChannelIndex = RealChannels[PlayerController(Owner).VoiceChannel].FakeIndex;
    TextCurrentChannel.Text = StringCurrentChannel @ StringTeam[whichstring] $ (FocusChannelIndex + 1); 

    RefreshChannelInfo();    
    RefreshChannelGUI();    
    SetTimer(1.5, true);
}

/*******************************************************************************
	Function:   PRIArrayUpdated
	Created by: Mark Mikulec on 2004-12-30 21:58:06
	Notes:      Called somewhere way up top when the player replication info is
                changed?
*******************************************************************************/
simulated function PRIArrayUpdated()
{
    log("PRI changed - updating our channels");
    GRI.GetPRIArray(PRIArray);
    RefreshChannelInfo();
    RefreshChannelGUI();
}

/*******************************************************************************
	Function:   Timer
	Created by: Mark Mikulec on 2005-01-02 02:47:47
	Notes:      Refresh the list every 1.5 seconds.
*******************************************************************************/
simulated function Timer()
{
    
    RefreshChannelInfo();    
    RefreshChannelGUI();
}

/*******************************************************************************
	Function:   CloseMenu
	Created by: Mark Mikulec on 2005-01-02 02:48:21
	Notes:      Shutdown timer on exit.
*******************************************************************************/
simulated function CloseMenu()
{
    SetTimer(0, false);
    Super.CloseMenu();
}

/*******************************************************************************
	Function:   RefreshChannelInfo
	Created by: Mark Mikulec on 2004-12-30 22:33:52
	Notes:      Call this first to get the data from the engine on who's who and
                what's what.
*******************************************************************************/
simulated function RefreshChannelInfo()
{
    local int i;
    local String PlayerName;

    // Reset our gamer tag list and fill it again
    for(i = 0; i < MAX_CHANNELS; i++)
    {
        RealChannels[i].PlayerNames.Length = 0;
        RealChannels[i].TeamIndex.Length = 0;
    }

    for(i = 0; i < PRIArray.Length; i++)
    {
        if ((PRIArray[i].VoiceChannel < 0) || (PRIArray[i].bBot) || (!PRIArray[i].bHasVoice))
            continue;        
        
        PlayerName = PRIArray[i].RetrivePlayerName();
        
        if( PlayerName == "" )
        {
            continue;
        }
        
        RealChannels[PRIArray[i].VoiceChannel].PlayerNames.Insert(0, 1); // wow, what a ghey way of doing arrays
        RealChannels[PRIArray[i].VoiceChannel].TeamIndex.Insert(0, 1);
        RealChannels[PRIArray[i].VoiceChannel].PlayerNames[0] = PlayerName;

        if (TeamIndex < 2)                                             // Then it's a team game, so get the player's team index
            RealChannels[PRIArray[i].VoiceChannel].TeamIndex[0] = PRIArray[i].Team.TeamIndex;
        else
            RealChannels[PRIArray[i].VoiceChannel].TeamIndex[0] = 2;
    }
}


/*******************************************************************************
	Function:   RefreshChannelGUI
	Created by: Mark Mikulec on 2004-12-30 22:02:48
	Notes:      Then change the gui layout of the main menu as appropriate.
*******************************************************************************/
simulated function RefreshChannelGUI()
{
    local int c, option; 

    // Note that the (fake) channel # displayed on the screen does not correlate with
    // the channel number in script (real). Neutral channels are: 0-5 in deathmatch
    // and 0,2,4 blue 1,3,5 red and 6,7,8 all in a team game

    for (c = 0; c < CHANNELS; c++)
    {
        if (c < 3)
            option = TeamIndex;
        else
            option = 2;

        // Print Channel: # (everyone/team blue) [8/8]
        
        Options[c].Blurred.Text = StringTeam[option]$(c + 1) @ "[" $ RealChannels[FakeChannels[c]].PlayerNames.Length $ "/" $ MAX_CHATTERS $ "]";
        Options[c].Blurred.DrawColor = ClrTeam[option];      
        Options[c].Focused.DrawColor = ClrTeam[option];
    }
    FocusOnWidget(Options[FocusChannelIndex]);
    FocusChannel(FocusChannelIndex);
}

/*******************************************************************************
	Function:   function Pork
	Created by: Mark Mikulec on 2004-12-30 22:32:10
	Notes:      Pork! Pork! Pork! To see a test case.
*******************************************************************************/
simulated exec function Pork()
{
    RealChannels[0].PlayerNames.Length = 2;
    RealChannels[0].PlayerNames[0] = "Hoju";
    RealChannels[0].TeamIndex[0] = 2;
    RealChannels[0].PlayerNames[1] = "Pookie";
    RealChannels[0].TeamIndex[1] = 2;
    RealChannels[1].PlayerNames.Length = 8;
    RealChannels[1].PlayerNames[0] = "Omfg";
    RealChannels[1].TeamIndex[0] = 2;
    RealChannels[1].PlayerNames[1] = "Hot";
    RealChannels[1].TeamIndex[1] = 2;
    RealChannels[1].PlayerNames[2] = "Yeeehaw!";
    RealChannels[1].TeamIndex[2] = 2;
    RealChannels[1].PlayerNames[3] = "Spunk";
    RealChannels[1].TeamIndex[3] = 2;
    RealChannels[1].PlayerNames[4] = "Pants";
    RealChannels[1].TeamIndex[4] = 2;    
    RealChannels[1].PlayerNames[5] = "Omfg";
    RealChannels[1].TeamIndex[5] = 2;
    RealChannels[1].PlayerNames[6] = "Hot";
    RealChannels[1].TeamIndex[6] = 2;
    RealChannels[1].PlayerNames[7] = "Yeeehaw!";
    RealChannels[1].TeamIndex[7] = 2;    
    RefreshChannelGUI();
}

/*******************************************************************************
	Function:   DoDynamicLayout
	Created by: Mark Mikulec on 2004-12-30 17:24:52
	Notes:      
*******************************************************************************/
simulated event DoDynamicLayout(Canvas C)
{
	Super.DoDynamicLayout(C);
	
	// todo: draw some nice background square around them
	
	LayoutArray(Options[0], 'ChannelOptionLayout');
    LayoutArray(PlayerNames[0], 'PlayerNamesLayout' );
}

/*******************************************************************************
	Function:   JoinChannel
	Created by: Mark Mikulec on 2004-12-30 21:58:48
	Notes:      Called a channel is selected, as in the user releases the button
                and the channel is submitted for selection.
*******************************************************************************/
simulated function JoinChannel(int ContextID)
{
    local XBoxAddr EmptyAddr;

    if (RealChannels[FakeChannels[ContextID]].PlayerNames.Length >= MAX_CHATTERS)
    {
        log("Channel is full, cannot join.");
        return;
    }

    log("Joining channel " @ FakeChannels[ContextID]);

    PlayerController(Owner).ServerChangeChannel(PlayerController(Owner), EmptyAddr, 0, -4 -FakeChannels[ContextID]);  // wow. -4 -Channel. Top secret jij code.   

    CloseMenu();
}

/*******************************************************************************
	Function:   FocusChannel
	Created by: Mark Mikulec on 2004-12-30 21:59:56
	Notes:      Called when the channel gets the focus, so we need to repopulate
                the other window with the gamer tags.
*******************************************************************************/
simulated function FocusChannel(int ContextID)
{
    local int g;
    local RealChannel ref;  // I sincerely hope this is a reference..

    FocusChannelIndex = ContextID;
    TextChannelFull.bHidden = 0;
    TextGamerChannel.bHidden = 1;
    ref = RealChannels[FakeChannels[ContextID]];
    for (g = 0; g < MAX_CHATTERS; g++)
    {        
        if (g < ref.PlayerNames.Length)
        {
            PlayerNames[g].Text = ref.PlayerNames[g];
            PlayerNames[g].DrawColor = ClrTeam[ref.TeamIndex[g]];
        }
        else
        {
            PlayerNames[g].Text = "";
            TextChannelFull.bHidden = 1;
            TextGamerChannel.bHidden = 0;
        }
    }   
}

/*******************************************************************************
	Function:   bool HandleInputKeyRaw
	Created by: Mark Mikulec on 2004-12-31 15:40:09
	Notes:      Override this so that if the back button is released the menu 
                disappears.
*******************************************************************************/
simulated function bool HandleInputKeyRaw(Interactions.EInputKey Key, Interactions.EInputAction Action)
{
    if( (Action == IST_Release) && (Key == HoldKey ))
    {
        JoinChannel(FocusChannelIndex);
        return true;
    }
    return Super.HandleInputKeyRaw(Key, Action);
}

defaultproperties
{
     MenuTitle=(PosX=0.080000,PosY=0.130000,ScaleX=0.650000,ScaleY=0.650000,Pass=2,Style="NormalLabel")
     TopBar=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(A=255),ScaleX=1.000000,ScaleY=0.155000,ScaleMode=MSM_Fit,Pass=1)
     BottomBar=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(A=255),DrawPivot=DP_LowerLeft,PosY=1.000000,ScaleX=1.000000,ScaleY=0.155000,ScaleMode=MSM_Fit,Pass=1)
     Background=(WidgetTexture=Texture'Engine.PariahWhiteTexture',RenderStyle=STY_Alpha,DrawColor=(A=100),PosY=0.155000,ScaleX=1.000000,ScaleY=0.690000,ScaleMode=MSM_Fit)
     Options(0)=(Blurred=(Text="Channel"),OnFocus="FocusChannel",OnSelect="JoinChannel",Style="TitledTextOption")
     TextCurrentChannel=(PosX=0.100000,PosY=0.300000,Style="NormalLabel")
     TextChannelFull=(Text="Channel is Full",DrawColor=(G=150,R=255,A=255),PosX=0.550000,PosY=0.300000,Style="NormalLabel")
     TextGamerChannel=(Text="Users in Channel",PosX=0.550000,PosY=0.300000,Style="NormalLabel")
     PlayerNames(0)=(Style="NormalLabel")
     ChannelOptionLayout=(PosX=0.100000,PosY=0.380000,SpacingY=0.050000,BorderScaleX=0.400000)
     PlayerNamesLayout=(PosX=0.550000,PosY=0.380000,SpacingY=0.050000,BorderScaleX=0.400000)
     StringCurrentChannel="Talking in channel:"
     VoiceChannelTitle="Voice Channels"
     StringTeam(0)="R"
     StringTeam(1)="B"
     StringTeam(2)="N"
     ClrTeam(0)=(R=200,A=255)
     ClrTeam(1)=(B=200,A=255)
     ClrTeam(2)=(B=200,G=200,R=200,A=255)
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
     bRenderLevel=True
}
