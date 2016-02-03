class OverlayPlayerStats extends MenuTemplateTitled;

var() MenuSprite        BackgroundTrim;
// Buttons
var() MenuButtonSprite  NextPlayerButton, PrevPlayerButton;
var() MenuText          MorePlayersButtonText;
var() MenuSprite        BButtonIcon;
var() MenuText          BLabel;

// team flags
var() MenuSprite        FlagWidgets[2];

// Player name at Top of the Screen
var() MenuText PlayerName[2]; // 0 is title and 1 dynamic content
var() MenuText TeamKillsTop[2];
var() MenuText Efficiency[2];

// Players Character
var() MenuActor         PlayerActor;
var() Vector            PlayerActorPos;
var() Rotator           PlayerActorRot;
var() Actor             WeaponActor;
var transient String    LastCharName;

// Weapon Stats
const MAXWEAPONS = 12;
var() MenuText WeaponName	[MAXWEAPONS]; // 0 is title and 1 dynamic content
var() MenuText Frags		[MAXWEAPONS];
var() MenuText Deaths		[MAXWEAPONS];
var() MenuText WepAcc		[MAXWEAPONS];
var() MenuText TeamKills	[MAXWEAPONS];

// Legend
var() MenuText LegendFrags[2];
var() MenuText LegendDeaths[2];
var() MenuText LegendAccuracy[2];
var() MenuText LegendTeamKills[2];

// Additional Information
var() MenuText PlayTime[2];
var() MenuText PlayerLifeSpan[2];
var() MenuText FragsPerMin[2];
var() MenuText Suicides[2];
var() MenuText TotalScore[2];
var() MenuText Specials[2];
var() MenuText Refresh;

// Footer Info
var() MenuText AmountOfPlayers;
// var() MenuButtonSprite PrevPlayer, NextPlayer;


// Button Pulsing
const BUTTON_FADE_TIME = 0.15;
var() float fButtonLeft;
var() float fButtonRight;

var() int bButtonLeft;
var() int bButtonRight;


// Color Scheme
var() color WhiteColor, TitleColor, GoldColor, CyanColor;
var() Color	BGColorRed;
var() Color	BGColorBlue;


// Localized Text
var localized string	StatsTitle;
var localized string	lsPlayerName, lsAccuracy, lsEfficiency, lsBotName;
var localized string	lsWeapons, lsFrags, lsDeaths, lsAccuracyA, lsTeamKills; 
var localized string	lsLegendFrags, lsLegendDeaths, lsLegendSuicides, lsLegendTeamKills;
var localized string	lsPlayTime, lsLifeSpan, lsFragsPerMin, lsSpecials;

var() xPlayer       xPlayerOwner;
var() int           PRIIndex;
var() Array<PlayerReplicationInfo>  PRIs;
var() bool          Subscribed;

var String defaultCName;

//---------------------------------------------------------------------------

simulated function Init( String Args )
{
    local String CName;

	Super.Init( Args );
    xPlayerOwner = xPlayer(Owner);
    PRIIndex = 0;
    
    if( xPlayerOwner.PlayerReplicationInfo != None )
        CName = xPlayerOwner.PlayerReplicationInfo.CharacterName;
    
    if( CName == "" )
        CName = defaultCName;
    // jim: Do not load all weapons by default in MenuLevel.
    //SetupActor(PlayerActor.Actor, WeaponActor, CName, "VehicleWeapons.VGAssaultRifle"/*"XWeapons.AssaultRifle"*/, PlayerActorPos, PlayerActorRot, 0.63);
    LastCharName = CName;
}

simulated function Destroyed()
{
    PlayerActor.Actor.Destroy();
    WeaponActor.Destroy();
    PlayerActor.Actor = None;
    WeaponActor = None;
    Super.Destroyed();
}

simulated function ReopenInit()
{
    local PlayerController PC;

    PC = PlayerController( Owner );
    assert( PC != None );

    PC.PlayBeepSound();

    CrossFadeDir = TD_In;
    CrossFadeLevel = 0;
    TravelMenu = self;

    Subscribe();
}

simulated function bool IgnoreKeyEvent( Interactions.EInputKey Key, Interactions.EInputAction Action )
{
    if( KeyIsBoundTo( Key, "ShowPersonalStats" ) )
        return( true );

    if( KeyIsBoundTo( Key, "ShowPersonalStats | OnRelease ShowPersonalStats" ) )
        return( true );

    if( KeyIsBoundTo( Key, "ShowScores" ) )
        return( true );

    if( KeyIsBoundTo( Key, "ShowScores | OnRelease ShowScores" ) )
        return( true );

    return( Super.IgnoreKeyEvent( Key, Action ) );
}

simulated function CloseMenu()
{
    Super.CloseMenu();
    UnSubscribe();
}

simulated function Timer()
{
    if (xPlayerOwner.LastRequestPRI != PRIs[PRIIndex])
        xPlayerOwner.GetStats(PRIs[PRIIndex]);
}

simulated function NextPlayer()
{
    local PlayerController PC;

    FlashButtonRight();

    PC = PlayerController( Owner );
    assert( PC != None );

    PC.PlayBeepSound();

    PRIIndex++;
    if (PRIIndex >= PRIs.Length )
        PRIIndex = 0;

    xPlayerOwner.NextStatRequestTime = FMax(Level.TimeSeconds, xPlayerOwner.NextStatRequestTime-xPlayerOwner.MinStatRequestCount+1.0) + 0.5;
    xPlayerOwner.GetStats(PRIs[PRIIndex]);
}

simulated function PrevPlayer()
{
    local PlayerController PC;

    FlashButtonLeft();

    PC = PlayerController( Owner );
    assert( PC != None );

    PC.PlayBeepSound();

    PRIIndex--;
    if( PRIIndex < 0 )
        PRIIndex = PRIs.Length - 1;

    xPlayerOwner.NextStatRequestTime = FMax(Level.TimeSeconds, xPlayerOwner.NextStatRequestTime-xPlayerOwner.MinStatRequestCount+1.0) + 0.5;
    xPlayerOwner.GetStats(PRIs[PRIIndex]);
}

simulated function FlashArrows(bool Left, out float GlobalFloat,out int GlobalBool,optional out MenuButtonSprite Button )
{
    local float  Ratio;
 

    if( GlobalBool != 0 )
    {
        Ratio= FClamp(((GlobalFloat) - Level.TimeSeconds),0.0,1.0);
        if (Left)
        {
            Button.blurred.WidgetTexture = Material'InterfaceContent.Menu.fbQuickFlashLeft';
            Button.focused.WidgetTexture = Material'InterfaceContent.Menu.fbQuickFlashLeft';
        }
        else
        {
            Button.blurred.WidgetTexture = Material'InterfaceContent.Menu.fbQuickFlashRight';
            Button.focused.WidgetTexture = Material'InterfaceContent.Menu.fbQuickFlashRight';

        }
        if (Ratio == 0.0)
        {        
            if (Left)
            {
                Button.blurred.WidgetTexture = Material'InterfaceContent.Menu.fbArrowLeft';
                Button.focused.WidgetTexture = Material'InterfaceContent.Menu.fbArrowLeft';
            }
            else
            {
                Button.blurred.WidgetTexture = Material'InterfaceContent.Menu.fbArrowRight';
                Button.focused.WidgetTexture = Material'InterfaceContent.Menu.fbArrowRight';

            }
            GlobalBool = 0;
        }
    }

    
}
simulated function FlashButtonLeft()
{
    bButtonLeft = 1;
    fButtonLeft = Level.TimeSeconds + BUTTON_FADE_TIME;
}
simulated function FlashButtonRight()
{
    bButtonRight = 1;
    fButtonRight = Level.TimeSeconds + BUTTON_FADE_TIME;
}

simulated function Subscribe()
{
    local PlayerReplicationInfo PRI;

    Subscribed = true;
    SetTimer(0.5, true);
    // find all stats (in pri's) - todo, use priarray stuff
    PRIs.Length = 0;
    PRIs[PRIs.Length] = xPlayerOwner.PlayerReplicationInfo;
    foreach AllActors(class'PlayerReplicationInfo', PRI)
    {
        if( PRI != xPlayerOwner.PlayerReplicationInfo )
            PRIs[PRIs.Length] = PRI;
    }

    PRIIndex = 0;
    xPlayerOwner.GetStats(PRIs[PRIIndex]);

	DrawTitles(); // just sets text and colors actually. stranger things have happened.
}

simulated function UnSubscribe()
{
    SetTimer(0.0, false);
    Subscribed = false;
    xPlayerOwner.GetStats(None);
}

simulated function DrawMenu( Canvas C, bool HasFocus )
{
    if( !Subscribed )
        return;

	FillBlanks();
    FlashArrows(true, fButtonLeft, bButtonLeft, NextPlayerButton );
    FlashArrows(false, fButtonRight, bButtonRight, PrevPlayerButton );
   
    Super.DrawMenu( C, HasFocus );
    
}

simulated function DrawTitles()
{
	ColorFormatTitles();

	MenuTitle.Text = StatsTitle;

	// Player at Top of the Screen
	TeamKillsTop[0].Text = lsLegendTeamKills;
	Efficiency[0].Text = lsEfficiency;

	// Weapon Stats
	WeaponName[0].Text = lsWeapons;
	Frags[0].Text = lsFrags;
	Deaths[0].Text = lsDeaths;
	WepAcc[0].Text = lsAccuracyA;
    
	// Legend
	LegendFrags[0].Text = lsFrags;
	LegendFrags[1].Text = lsLegendFrags;
	LegendDeaths[0].Text = lsDeaths;
	LegendDeaths[1].Text = lsLegendDeaths;
	LegendAccuracy[0].Text = lsAccuracyA;
	LegendAccuracy[1].Text = lsAccuracy;
	
	LegendTeamKills[0].Text = lsTeamKills;
	LegendTeamKills[1].Text = lsLegendTeamKills;
}


simulated function FillBlanks()
{
	local int i, w, s;
    local PlayerReplicationInfo PRI;
    local PlayerStats PS;
    local PlayerStats.StatData WS;
    local String WName;
    local xUtil.WeaponRecord wr;
    local xUtil.PlayerRecord pr;

    PRI = PRIs[PRIIndex];

    if( PRI == None )
    {
        PRIIndex = 0;
        return;
    }

    if( PRI.Stats == None )
        PRI.Stats = Spawn(class'PlayerStats');

    PS = PRI.Stats;

    if( PRI.PlayTime > 0 )
        PS.PlayTime = PRI.PlayTime;

    if( LastCharName != PRI.CharacterName )
    {
        LastCharName = PRI.CharacterName;

        if( InStr( Level.GetLocalURL(), "MutSpeciesStats" ) >= 0 )
        {
            pr = class'xUtil'.static.FindPlayerRecord(PRI.CharacterName);
            WName = pr.WepAffinity.WepString;
        }
        // jim: Do not load all weapons by default in MenuLevel.
        //else
            //WName = "VehicleWeapons.VGAssaultRifle";//"XWeapons.AssaultRifle";

        UpdateActor( PlayerActor.Actor, WeaponActor,  PRI.CharacterName, WName );
    }

    if( PRI.Team == None || PRI.Team.TeamIndex == 1 )
    {
        FlagWidgets[0].bHidden = 1;
        
    }else   
    {
        FlagWidgets[0].bHidden = 0;
        BackGround.DrawColor = BGColorRed;
    }
    if( PRI.Team == None || PRI.Team.TeamIndex == 0 )
    {
        FlagWidgets[1].bHidden = 1;
    }else
    {
        BackGround.DrawColor = BGColorBlue;
        FlagWidgets[1].bHidden = 0;
    }
	PlayerName[1].Text = PRI.RetrivePlayerName();
	TotalScore[1].Text = string( int(PRI.Score) );
    Efficiency[1].Text = string(PS.Efficiency);

    PlayTime[1].Text = FormatTime( PS.PlayTime );
    //PlayerLifeSpan[1].Text = FormatTime( PS.AverageLifeTime() );
    FragsPerMin[1].Text = FormatFloat( PS.FragsPerMinute() );
    Suicides[1].Text = string(PS.Overall.Suicides);
    Specials[1].Text = string(PS.Overall.Specials);

    if( PS.Overall.TeamKills > 0 )
    {
    	TeamKillsTop[1].Text = string(PS.Overall.TeamKills);
        TeamKillsTop[0].bHidden = 0;
        TeamKillsTop[1].bHidden = 0;
    }
	else
    {
        TeamKillsTop[0].bHidden = 1;
        TeamKillsTop[1].bHidden = 1;
    }

    /*if( xPlayerOwner.LastRequestPRI == None )
        Refresh.bHidden = 1;
    else
        Refresh.bHidden = 0;*/

    if( PRI.bBot )
        PlayerName[0].Text = lsBotName;
    else
        PlayerName[0].Text = lsPlayerName;

    i = 1;
    for ( w=0; w < 16; w++ )
    {
        for ( s=0; s < MAXWEAPONS; s++ )
        {
            WS = PS.GetWeaponStats(s);
            if (WS.WeaponClass == None || WS.WeaponClass.default.BarIndex == w)
                break;
        }

        if( s < MAXWEAPONS && WS.WeaponClass != None /*&& WS.WeaponClass != class'BallLauncher'*/)
        {
            ClearOldStats(i);
            ColorFormatWeaponStats(i);
			/*
            if (WS.WeaponClass == class'SuperShockRifle')
                wr = class'xUtil'.static.FindWeaponRecord(String(class'ShockRifle'));
            else
			*/
                wr = class'xUtil'.static.FindWeaponRecord(String(WS.WeaponClass));
            WeaponName[i].Text = wr.FriendlyName;
		    Frags[i].Text = string(WS.Kills);
		    Deaths[i].Text = string(WS.Deaths);
		    WepAcc[i].Text = string(Min(100,WS.Accuracy))$"%";
            i++;
	    }
    }
    while (i < MAXWEAPONS)
    {
        ClearOldStats(i);
        i++;
    }
}

simulated function ClearOldStats(int i)
{
    WeaponName[i].Text = "";
	Frags[i].Text = "";
	Deaths[i].Text = "";
	WepAcc[i].Text = "";
	TeamKills[i].Text = "";
}

simulated function ColorFormatTitles()
{
	PlayerName[0].DrawColor = TitleColor;
	TeamKillsTop[0].DrawColor = TitleColor;
	Efficiency[0].DrawColor = TitleColor;

	// Weapon Stats
	WeaponName[0].DrawColor = TitleColor;
	Frags[0].DrawColor = GoldColor;
	Deaths[0].DrawColor = GoldColor;
	WepAcc[0].DrawColor = GoldColor;
	TeamKills[0].DrawColor = GoldColor;	
}

simulated function ColorFormatPlayerStats()
{	
	PlayerName[1].DrawColor = CyanColor;
	TeamKillsTop[1].DrawColor = CyanColor;
	Efficiency[1].DrawColor = CyanColor;	
}

simulated function ColorFormatWeaponStats(int i)
{
	WeaponName[i].DrawColor = WhiteColor;
	Frags[i].DrawColor = CyanColor;
	Deaths[i].DrawColor = CyanColor;
	WepAcc[i].DrawColor = CyanColor;
	TeamKills[i].DrawColor = CyanColor;
}

//---------------------------------------------------------------------------

simulated function HandleInputSelect();

simulated function HandleInputRight()
{
    //if (xPlayerOwner.LastRequestPRI == None)
        NextPlayer();
}

simulated function HandleInputLeft()
{
    //if (xPlayerOwner.LastRequestPRI == None)
        PrevPlayer();
}

simulated function HandleInputBack()
{
    local PlayerController PC;

    PC = PlayerController( Owner );
    assert( PC != None );

    xPlayerOwner.myHud.bShowPersonalStats = false;
    PC.PlayBeepSound();
    CloseMenu();
}

simulated function HandleInputStart();

defaultproperties
{
     BackgroundTrim=(WidgetTexture=Texture'InterfaceContent.Backgrounds.MainBackgroundTrim',DrawColor=(B=255,G=255,R=255,A=255),Style="FullScreen")
     NextPlayerButton=(Blurred=(WidgetTexture=FinalBlend'InterfaceContent.Menu.fbArrowLeft',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.100000,PosY=0.895000,ScaleX=0.800000,ScaleY=0.800000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),OnSelect="PrevPlayer",Pass=1)
     PrevPlayerButton=(Blurred=(WidgetTexture=FinalBlend'InterfaceContent.Menu.fbArrowRight',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.420000,PosY=0.895000,ScaleX=0.800000,ScaleY=0.800000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),OnSelect="NextPlayer",Pass=1)
     MorePlayersButtonText=(Text="PREV / NEXT",DrawColor=(B=180,G=180,R=180,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.260000,PosY=0.896000,Pass=1,Style="LabelText")
     BButtonIcon=(DrawPivot=DP_MiddleLeft,PosX=0.895000,PosY=0.896000,Style="XboxButtonB")
     BLabel=(Text="BACK TO GAME:",DrawPivot=DP_MiddleRight,PosX=0.900000,PosY=0.896000,Style="LabelText")
     FlagWidgets(0)=(WidgetTexture=Texture'InterfaceContent.HUD.newHudTMP',TextureCoords=(X1=78,Y1=67,X2=107,Y2=100),RenderStyle=STY_Alpha,DrawColor=(R=100,A=255),PosX=0.070000,PosY=0.240000)
     FlagWidgets(1)=(WidgetTexture=Texture'InterfaceContent.HUD.newHudTMP',TextureCoords=(X1=78,Y1=67,X2=107,Y2=100),RenderStyle=STY_Alpha,DrawColor=(B=102,G=66,R=37,A=255),PosX=0.070000,PosY=0.240000)
     PlayerName(0)=(PosX=0.080000,PosY=0.160000,Pass=3,Style="StatsText")
     PlayerName(1)=(DrawColor=(B=255,G=255,R=255,A=255),PosY=0.210000)
     TeamKillsTop(0)=(DrawColor=(B=180,G=180,R=180,A=255),PosX=0.400000,PosY=0.710000,Style="StatsText")
     TeamKillsTop(1)=(DrawColor=(B=150,G=150,R=100,A=255),PosY=0.740000)
     Efficiency(0)=(DrawColor=(B=180,G=180,R=180,A=255),PosX=0.720000,PosY=0.790000,Style="StatsText")
     Efficiency(1)=(DrawColor=(B=150,G=150,R=100,A=255),PosY=0.820000)
     playerActor=(FOV=90.000000,Lights=((Position=(Z=80.000000),Color=(B=200,G=200,R=200,A=255),Radius=350.000000)),AmbientGlow=40)
     PlayerActorPos=(X=120.000000,Y=-75.000000,Z=13.000000)
     PlayerActorRot=(Yaw=20000)
     WeaponName(0)=(PosX=0.310000,PosY=0.275000,Style="StatsText")
     WeaponName(1)=(PosY=0.310000)
     Frags(0)=(PosX=0.580000,PosY=0.275000,Style="StatsText")
     Frags(1)=(PosY=0.310000)
     Deaths(0)=(PosX=0.680000,PosY=0.275000,Style="StatsText")
     Deaths(1)=(PosY=0.310000)
     WepAcc(0)=(PosX=0.780000,PosY=0.275000,Style="StatsText")
     WepAcc(1)=(PosY=0.310000)
     TeamKills(0)=(PosX=0.880000,PosY=0.275000,Style="StatsText")
     TeamKills(1)=(PosY=0.310000)
     LegendFrags(0)=(DrawColor=(G=255,R=255,A=255),PosX=0.080000,PosY=0.640000,Style="StatsText")
     LegendFrags(1)=(DrawColor=(B=180,G=180,R=180,A=255),PosX=0.120000)
     LegendDeaths(0)=(DrawColor=(G=255,R=255,A=255),PosX=0.080000,PosY=0.675000,Style="StatsText")
     LegendDeaths(1)=(DrawColor=(B=180,G=180,R=180,A=255),PosX=0.120000)
     LegendAccuracy(0)=(DrawColor=(G=255,R=255,A=255),PosX=0.080000,PosY=0.710000,Style="StatsText")
     LegendAccuracy(1)=(DrawColor=(B=180,G=180,R=180,A=255),PosX=0.120000)
     LegendTeamKills(0)=(DrawColor=(G=255,R=255,A=255),PosX=0.080000,PosY=0.745000,bHidden=1,Style="StatsText")
     LegendTeamKills(1)=(DrawColor=(B=180,G=180,R=180,A=255),PosX=0.120000,bHidden=1)
     PlayTime(0)=(Text="PLAYTIME",DrawColor=(B=180,G=180,R=180,A=255),PosX=0.080000,PosY=0.790000,Style="StatsText")
     PlayTime(1)=(DrawColor=(B=150,G=150,R=100,A=255),PosY=0.820000)
     PlayerLifeSpan(0)=(Text="LIFESPAN",DrawColor=(B=180,G=180,R=180,A=255),PosX=0.240000,PosY=0.790000,bHidden=1,Style="StatsText")
     PlayerLifeSpan(1)=(DrawColor=(B=150,G=150,R=100,A=255),PosY=0.820000,bHidden=1)
     FragsPerMin(0)=(Text="FRAGS / MIN",DrawColor=(B=180,G=180,R=180,A=255),PosX=0.400000,PosY=0.790000,Style="StatsText")
     FragsPerMin(1)=(DrawColor=(B=150,G=150,R=100,A=255),PosY=0.820000)
     Suicides(0)=(Text="SUICIDES",DrawColor=(B=180,G=180,R=180,A=255),PosX=0.720000,PosY=0.160000,Style="StatsText")
     Suicides(1)=(DrawColor=(B=150,G=150,R=100,A=255),PosY=0.210000)
     TotalScore(0)=(Text="POINTS",DrawColor=(B=180,G=180,R=180,A=255),PosX=0.450000,PosY=0.160000,Style="StatsText")
     TotalScore(1)=(DrawColor=(B=150,G=150,R=100,A=255),PosY=0.210000)
     Specials(0)=(Text="SPECIALS",DrawColor=(B=180,G=180,R=180,A=255),PosX=0.720000,PosY=0.710000,Style="StatsText")
     Specials(1)=(DrawColor=(B=150,G=150,R=100,A=255),PosY=0.740000)
     Refresh=(Text="Refreshing...",DrawColor=(B=200,G=200,R=200,A=255),DrawPivot=DP_MiddleRight,PosX=0.850000,PosY=0.108787,bHidden=1,Style="StatsText")
     WhiteColor=(B=255,G=255,R=255,A=255)
     TitleColor=(B=180,G=180,R=180,A=255)
     GoldColor=(G=255,R=255,A=255)
     CyanColor=(B=150,G=150,R=100,A=255)
     BGColorRed=(R=80,A=80)
     BGColorBlue=(B=105,G=66,R=30,A=80)
     StatsTitle="STATISTICS"
     lsPlayerName="PLAYER"
     lsAccuracy="ACCURACY"
     lsEfficiency="EFFICIENCY"
     lsBotName="BOT"
     lsWeapons="WEAPONS"
     lsFrags="F"
     lsDeaths="D"
     lsAccuracyA="A"
     lsTeamKills="TK"
     lsLegendFrags="FRAGS"
     lsLegendDeaths="DEATHS"
     lsLegendSuicides="SUICIDES"
     lsLegendTeamKills="TEAM KILLS"
     lsPlayTime="PLAYTIME"
     lsLifeSpan="LIFESPAN"
     lsFragsPerMin="FRAGS / MIN"
     lsSpecials="SPECIALS"
     defaultCName="Mason"
     Background=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(B=0,G=0,R=0,A=130),DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleX=0.900000,ScaleY=0.850000)
     ControllerIcon=(bHidden=1)
     ControllerNumText=(bHidden=1)
     CrossFadeRate=100.000000
     ModulateRate=100.000000
     SoundTweenOut=None
     SoundOnFocus=None
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
     bPersistent=True
     bFullscreenOnly=True
}
