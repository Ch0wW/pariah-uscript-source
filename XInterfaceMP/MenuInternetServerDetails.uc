class MenuInternetServerDetails extends MenuTemplateTitledBXA;

var() ServerList Servers;
var() ServerList.ServerResponseLineEx Server;
var() bool bLANGame;

var() MenuButtonText    ServerInfoHeadings[5];
var() MenuText          ServerInfoRow[5];

var() MenuText          LongInfoLabels[3];
var() MenuText          LongInfoValues[3];

var() WidgetLayout      LongInfoLabelLayout;  
var() WidgetLayout      LongInfoValueLayout;  

var() MenuText          ColumnTitles[5];

var() MenuScrollArea    InfoScrollArea;
var() MenuScrollBar     InfoScrollBar;
var() MenuButtonSprite  InfoScrollArrowUp, InfoScrollArrowDown;
var() MenuActiveWidget  InfoPageUpArea, InfoPageDownArea;

var() MenuScrollArea    PlayerScrollArea;
var() MenuScrollBar     PlayerScrollBar;
var() MenuButtonSprite  PlayerScrollArrowUp, PlayerScrollArrowDown;
var() MenuActiveWidget  PlayerPageUpArea, PlayerPageDownArea;

var() MenuStringList    InfoColumns[2];
var() MenuStringList    PlayerColumns[3];

var() MenuText          ErrorMessage;

var() localized String  StringAdministrator;
var() localized String  StringIPAddress;
var() localized String  StringGame;
var() localized String  StringDedicated;
var() localized String  StringPrivate;
var() localized String  StringCustom;
var() localized String  StringFriendlyFire;
var() localized String  StringBots;
var() localized String  StringTimeLimit;
var() localized String  StringScoreLimit;
var() localized String  StringInitialWECs;

var() Array<xUtil.GameTypeRecord> GameTypeRecords;

var() bool Porked;

simulated function Init( String Args )
{
    Super.Init( Args );

    class'xUtil'.static.GetGameTypeList( GameTypeRecords );
    
    InfoColumns[0].Template.Blurred.DrawColor = ServerInfoRow[0].DrawColor;
    InfoColumns[1].Template.Blurred.DrawColor = ServerInfoRow[0].DrawColor;
    
    InfoColumns[0].Template.Blurred.bEllipsisOnLeft = 1; 

    PlayerColumns[0].Template.Blurred.DrawColor = ServerInfoRow[0].DrawColor;
    PlayerColumns[1].Template.Blurred.DrawColor = ServerInfoRow[0].DrawColor;
    PlayerColumns[2].Template.Blurred.DrawColor = ServerInfoRow[0].DrawColor;
    
    if( bLANGame )
    {
        HideXButton(1);
    }
    else
    {
        HideXButton(0);
        UpdateFavouritesButton();
    }
    
    Refresh();
    SetTimer(0.5, true);
}

simulated function UpdateFavouritesButton()
{
    if( bool(Server.bFavourite) )
    {
        XLabel.Text = class'MenuInternetServerList'.default.StringRemoveFromFavourites;
    }
    else
    {
        XLabel.Text = class'MenuInternetServerList'.default.StringAddToFavourites;
    }
    
    bDynamicLayoutDirty = true;
}

simulated function OnAButton()
{
    local MenuInternetServerJoin Join;

    Join = Spawn( class'MenuInternetServerJoin', Owner );

    Join.Server = Server;
    Join.Servers = Servers;
    Join.bLANGame = bLANGame;
    
    CallMenu( Join );        
}

simulated function OnXButton()
{
    local int i;
    
    if( bool(Server.bFavourite) )
    {
        Servers.DelFavourite( Server );
    }
    else
    {
        Servers.AddFavourite( Server );
    }

    // Since we're updating a copy out of the pinged list we need to update it manually :(
    for( i = 0; i < Servers.Pinged.Length; ++i )
    {
        if( (Servers.Pinged[i].IP == Server.IP) && (Servers.Pinged[i].Port == Server.Port) )
        {
            Servers.Pinged[i].bFavourite = Server.bFavourite;
            break;
        }
    }    
    
    if( MenuBase(PreviousMenu) != None )
    {
        MenuBase(PreviousMenu).bDynamicLayoutDirty = true;
    }

    UpdateFavouritesButton();
}

simulated function Timer()
{
    Refresh();
}

simulated function AddInfoRow( String Label, String Value )
{
    local int row;
    
    row = InfoColumns[0].Items.Length;
    
    InfoColumns[0].Items[row].Blurred.Text = Label $ ":";
    InfoColumns[0].Items[row].bDisabled = 1;
    
    InfoColumns[1].Items[row].Blurred.Text = Value;
    InfoColumns[1].Items[row].bDisabled = 1;
}

simulated function String GetField( String Key )
{
    local String Value;
    local int i;
    
    for( i = 0; i < Server.ServerInfo.Length; ++i )
    {
        if( Server.ServerInfo[i].Key ~= Key )
        {
            Value = Server.ServerInfo[i].Value;
            Server.ServerInfo.Remove( i, 1 );
            return(Value);
        }
    }
    
    return("");
}

simulated function String GetLongGameType( String GameType )
{
    local int i;
    
    for( i = 0; i < GameTypeRecords.Length; ++i )
    {
        if( GameTypeRecords[i].ClassName == GameType )
        {
            return(GameTypeRecords[i].GameName);
        }
    }
    
    return( GameType );
}

simulated function String BoolInt( coerce bool b )
{
    if(b)
    {
        return(StringYes);
    }
    else
    {
        return(StringNo);
    }
}

simulated function String BoolKey( String Key )
{
    return( BoolInt(GetField(Key)) );
}

simulated function String IntKey( String Key )
{
    local int value;
    
    value = int(GetField(Key));
    
    if( value == 0 )
    {
        return( StringNone );
    }
    else
    {
        return( String(value) );
    }
}

simulated function RefreshServerInfo()
{
    ServerInfoRow[0].Text = Server.ServerName;
    ServerInfoRow[1].Text = Server.LongMapName;
    ServerInfoRow[2].Text = class'MenuInternetServerList'.static.HumpFrenchie(ConsoleCommand("GET_LANGUAGE"), Caps(Server.GameTypeAcronym));
    ServerInfoRow[3].Text = String( Server.CurrentPlayers ) $ "/" $ String( Server.MaxPlayers );
    ServerInfoRow[4].Text = String( Server.Ping );
}

simulated function RefreshLongInfo()
{
    local String Name;
    local String Mail;

    LongInfoLabelLayout.PosX = InfoColumns[0].PosX1;
    LongInfoValueLayout.PosX = InfoColumns[1].PosX1;

    LongInfoLabels[0].Text = StringAdministrator $ ":";

    Name = GetField( "adminname" );
    Mail = GetField( "adminemail" );
    
    if( Porked )
    {
        Mail = "reallyfuckinglongassholeemail" $ Mail;
    }
    
    if( (Name == "") && (Mail == "") )
    {
        LongInfoValues[0].Text = StringUnknown;
    }
    else if( Name == "" )
    {
        LongInfoValues[0].Text = Mail;
    }
    else if ( Mail == "" )
    {
        LongInfoValues[0].Text = Name;
    }
    else
    {
        LongInfoValues[0].Text = Name @ "<" $ Mail $ ">";
    }
    
    LongInfoValues[0].MaxSizeX = 0.9 - LongInfoLabelLayout.PosX;

    LongInfoLabels[1].Text = StringIPAddress $ ":";
    LongInfoValues[1].Text = Server.IP $ ":" $ Server.Port;

    LongInfoLabels[2].Text = StringGame $ ":";
    LongInfoValues[2].Text = GetLongGameType(Server.GameType);

    LayoutArray( LongInfoLabels[0], 'LongInfoLabelLayout' );
    LayoutArray( LongInfoValues[0], 'LongInfoValueLayout' );
}

simulated function RefreshInfoColumns()
{
    local int i;

    InfoColumns[0].Items.Remove( 0, InfoColumns[0].Items.Length );
    InfoColumns[1].Items.Remove( 0, InfoColumns[1].Items.Length );
    
    InfoColumns[1].Template.Blurred.MaxSizeX = (ServerInfoHeadings[1].Blurred.PosX - InfoColumns[1].PosX1);

    AddInfoRow( StringDedicated, BoolInt(Server.bDedicated) );
    AddInfoRow( StringPrivate, BoolInt(Server.bPrivate) );
    AddInfoRow( StringCustom, BoolInt(Server.bCustom) );
    
    if( bool(Server.bTeamGame) )
    {
        AddInfoRow( StringFriendlyFire, BoolKey("friendlyfire") );
    }
    else
    {
        GetField("friendlyfire"); // gobble the field
    }
    
    AddInfoRow( StringBots, BoolKey("initialbots") );
    AddInfoRow( StringTimeLimit, IntKey("timelimit") );
    AddInfoRow( StringScoreLimit, IntKey("goalscore") );
    AddInfoRow( StringInitialWECs, IntKey("initialwecs") );
    
    if( Porked )
    {
	    i = Server.ServerInfo.Length;
	    Server.ServerInfo[i].Key = "bullshit";
	    Server.ServerInfo[i].Value = "true";

	    i = Server.ServerInfo.Length;
	    Server.ServerInfo[i].Key = "crapdung";
	    Server.ServerInfo[i].Value = "false";

	    i = Server.ServerInfo.Length;
	    Server.ServerInfo[i].Key = "cockdick";
	    Server.ServerInfo[i].Value = "false";

	    i = Server.ServerInfo.Length;
	    Server.ServerInfo[i].Key = "cockdickcockdickballbag";
	    Server.ServerInfo[i].Value = "100242";
	    
	    if( Server.PlayerInfo.Length > 0 )
	    {
	        Server.PlayerInfo[0].PlayerName = Server.PlayerInfo[0].PlayerName @ "Asshole Long Name, Fuck";
	    }
    }
    
    for( i = 0; i < Server.ServerInfo.Length; ++i )
    {
        AddInfoRow( Server.ServerInfo[i].Key, Server.ServerInfo[i].Value );
    }

    LayoutMenuStringList( InfoColumns[0] );
    LayoutMenuStringList( InfoColumns[1] );

	UpdateInfoScrollBar();
        
    if( !bool(InfoScrollBar.bHidden) )
    {
        InfoColumns[1].Template.Blurred.MaxSizeX = (InfoScrollBar.PosX1 - InfoColumns[1].PosX1) - (InfoScrollBar.MinScaleX * 0.5);
    
        for( i = 0; i < InfoColumns[1].Items.Length; ++i )
        {
            InfoColumns[1].Items[i].Blurred.MaxSizeX = InfoColumns[1].Template.Blurred.MaxSizeX;
        }
    }
}

simulated function RefreshPlayerColumns()
{
    local int i;

    PlayerColumns[0].Items.Remove( 0, PlayerColumns[0].Items.Length );
    PlayerColumns[1].Items.Remove( 0, PlayerColumns[1].Items.Length );
    PlayerColumns[2].Items.Remove( 0, PlayerColumns[2].Items.Length );

    PlayerColumns[0].PosX1 = ServerInfoHeadings[1].Blurred.PosX;
    PlayerColumns[0].PosX2 = PlayerColumns[0].PosX1;

    PlayerColumns[1].PosX1 = ServerInfoHeadings[3].Blurred.PosX;
    PlayerColumns[1].PosX2 = PlayerColumns[1].PosX1;

    PlayerColumns[2].PosX1 = ServerInfoHeadings[4].Blurred.PosX;
    PlayerColumns[2].PosX2 = PlayerColumns[2].PosX1;
    
    PlayerColumns[0].Template.Blurred.MaxSizeX = ServerInfoHeadings[2].Blurred.PosX - ServerInfoHeadings[1].Blurred.PosX;
    
    for( i = 0; i < Server.PlayerInfo.Length; ++i )
    {
        PlayerColumns[0].Items[i].Blurred.Text = Server.PlayerInfo[i].PlayerName;
        PlayerColumns[0].Items[i].bDisabled = 1;
        
        PlayerColumns[1].Items[i].Blurred.Text = String(Server.PlayerInfo[i].Score);
        PlayerColumns[1].Items[i].bDisabled = 1;
        
        PlayerColumns[2].Items[i].Blurred.Text = String(Server.PlayerInfo[i].Ping);
        PlayerColumns[2].Items[i].bDisabled = 1;
    }    

    LayoutMenuStringList( PlayerColumns[0] );
    LayoutMenuStringList( PlayerColumns[1] );
    LayoutMenuStringList( PlayerColumns[2] );

	UpdatePlayerScrollBar();
}

simulated function Refresh()
{
    local int i;
    
    Servers.RefreshServer( Server );

    RefreshServerInfo();

    if( Server.Ping <= 0 )
    {
        if( !bool(AButtonHidden) )
        {
            HideAButton(1);
        }
        
        InfoScrollBar.bHidden = 1;
        InfoScrollArrowUp.bHidden = 1;
        InfoScrollArrowDown.bHidden = 1;

        PlayerScrollBar.bHidden = 1;
        PlayerScrollArrowUp.bHidden = 1;
        PlayerScrollArrowDown.bHidden = 1;

        for( i = 0; i < ArrayCount(InfoColumns); ++i )
        {
            InfoColumns[i].bHidden = 1;
        }

        for( i = 0; i < ArrayCount(PlayerColumns); ++i )
        {
            PlayerColumns[i].bHidden = 1;
        }
        
        for( i = 0; i < ArrayCount(ColumnTitles); ++i )
        {
            ColumnTitles[i].bHidden = 1;
        }
        
        ErrorMessage.bHidden = 0;
    }
    else
    {
        if( bool(AButtonHidden) )
        {
            HideAButton(1);
        }
        
        InfoScrollBar.bHidden = 0;
        InfoScrollArrowUp.bHidden = 0;
        InfoScrollArrowDown.bHidden = 0;

        PlayerScrollBar.bHidden = 0;
        PlayerScrollArrowUp.bHidden = 0;
        PlayerScrollArrowDown.bHidden = 0;

        for( i = 0; i < ArrayCount(InfoColumns); ++i )
        {
            InfoColumns[i].bHidden = 0;
        }

        for( i = 0; i < ArrayCount(PlayerColumns); ++i )
        {
            PlayerColumns[i].bHidden = 0;
        }

        for( i = 0; i < ArrayCount(ColumnTitles); ++i )
        {
            ColumnTitles[i].bHidden = 0;
        }        
        
        RefreshLongInfo();
        RefreshInfoColumns();
        RefreshPlayerColumns();
        
        ErrorMessage.bHidden = 1;
    }
}

simulated function DoDynamicLayout( Canvas C )
{
    local int m;

    local float DX, DY;
    local float ScaleX;

    Super.DoDynamicLayout(C);

    for( m = 0; m < ArrayCount(ServerInfoHeadings); ++m )
    {
        ServerInfoRow[m].PosX = ServerInfoHeadings[m].Blurred.PosX;
    }

    for( m = 0; m < ArrayCount(ServerInfoHeadings); ++m )
    {
        ServerInfoHeadings[m].ContextID = m;

        GetMenuTextSize( C, ServerInfoHeadings[m].Blurred, DX, DY );

        ScaleX = DX + ButtonBackgroundPaddingDX + (2.f * ButtonIconDX);

        ServerInfoHeadings[m].BackgroundBlurred.ScaleX = ScaleX;
        ServerInfoHeadings[m].BackgroundBlurred.DrawPivot = DP_MiddleLeft;

        if( ServerInfoHeadings[m].Blurred.DrawPivot == DP_MiddleLeft )
        {
            ServerInfoHeadings[m].BackgroundBlurred.PosX = 0.f;
        }
        else if( ServerInfoHeadings[m].Blurred.DrawPivot == DP_MiddleRight )
        {
            ServerInfoHeadings[m].BackgroundBlurred.PosX = -DX;
        }
    }

    ServerInfoRow[0].MaxSizeX = ServerInfoHeadings[1].Blurred.PosX - ServerInfoHeadings[0].Blurred.PosX;

    ColumnTitles[0].PosX = InfoColumns[0].PosX1;
    ColumnTitles[1].PosX = InfoColumns[1].PosX1;
    ColumnTitles[2].PosX = PlayerColumns[0].PosX1;
    ColumnTitles[3].PosX = PlayerColumns[1].PosX1;
    ColumnTitles[4].PosX = PlayerColumns[2].PosX1;
}

simulated exec function Pork()
{
    Porked = !Porked;
}

simulated function UpdateInfoScrollBar()
{
    if( InfoColumns[0].Items.Length <= InfoColumns[0].DisplayCount )
    {
        InfoScrollBar.bHidden = 1;
        InfoScrollArrowUp.bHidden = 1;
        InfoScrollArrowDown.bHidden = 1;
        InfoPageUpArea.bHidden = 1;
        InfoPageDownArea.bHidden = 1;
    }
    else
    {
        InfoScrollBar.bHidden = 0;
        InfoScrollArrowUp.bHidden = 0;
        InfoScrollArrowDown.bHidden = 0;
        InfoPageUpArea.bHidden = 0;
        InfoPageDownArea.bHidden = 0;

        InfoScrollBar.Position = InfoColumns[0].Position;
        InfoScrollBar.Length = InfoColumns[0].Items.Length;
        InfoScrollBar.DisplayCount = InfoColumns[0].DisplayCount;
        LayoutMenuScrollBarEx( InfoScrollBar, InfoPageUpArea, InfoPageDownArea );
    }
}

simulated function OnInfoScroll()
{
    InfoColumns[0].Position = InfoScrollBar.Position;
    InfoColumns[1].Position = InfoScrollBar.Position;
    
    LayoutMenuStringList( InfoColumns[0] );
    LayoutMenuStringList( InfoColumns[1] );
}

simulated function ScrollInfoTo( int NewPosition )
{
    if( InfoScrollBar.Length == 0 )
        return;

    NewPosition = Clamp( NewPosition, 0, Max( 0, InfoScrollBar.Length - InfoScrollBar.DisplayCount ) );

    if( InfoScrollBar.Position == NewPosition )
        return;

    InfoScrollBar.Position = NewPosition;

    LayoutMenuScrollBar( InfoScrollBar );
}

simulated function OnInfoScrollUp()
{
    ScrollInfoTo( InfoScrollBar.Position - 1 );
}

simulated function OnInfoScrollDown()
{
    ScrollInfoTo( InfoScrollBar.Position + 1 );
}

simulated function OnInfoPageUp()
{
    ScrollInfoTo( InfoScrollBar.Position - InfoScrollBar.DisplayCount );
}

simulated function OnInfoPageDown()
{
    ScrollInfoTo( InfoScrollBar.Position + InfoScrollBar.DisplayCount );
}

simulated function OnInfoScrollLinesUp( int Lines )
{
    ScrollInfoTo( InfoScrollBar.Position - Lines );
}

simulated function OnInfoScrollLinesDown( int Lines )
{
    ScrollInfoTo( InfoScrollBar.Position + Lines );
}

simulated function UpdatePlayerScrollBar()
{
    if( PlayerColumns[0].Items.Length <= PlayerColumns[0].DisplayCount )
    {
        PlayerScrollBar.bHidden = 1;
        PlayerScrollArrowUp.bHidden = 1;
        PlayerScrollArrowDown.bHidden = 1;
        PlayerPageUpArea.bHidden = 1;
        PlayerPageDownArea.bHidden = 1;
    }
    else
    {
        PlayerScrollBar.bHidden = 0;
        PlayerScrollArrowUp.bHidden = 0;
        PlayerScrollArrowDown.bHidden = 0;
        PlayerPageUpArea.bHidden = 0;
        PlayerPageDownArea.bHidden = 0;

        PlayerScrollBar.Position = PlayerColumns[0].Position;
        PlayerScrollBar.Length = PlayerColumns[0].Items.Length;
        PlayerScrollBar.DisplayCount = PlayerColumns[0].DisplayCount;
        LayoutMenuScrollBarEx( PlayerScrollBar, PlayerPageUpArea, PlayerPageDownArea );
    }
}

simulated function OnPlayerScroll()
{
    PlayerColumns[0].Position = PlayerScrollBar.Position;
    PlayerColumns[1].Position = PlayerScrollBar.Position;
    PlayerColumns[2].Position = PlayerScrollBar.Position;

    LayoutMenuStringList( PlayerColumns[0] );
    LayoutMenuStringList( PlayerColumns[1] );
    LayoutMenuStringList( PlayerColumns[2] );
}

simulated function ScrollPlayerTo( int NewPosition )
{
    if( PlayerScrollBar.Length == 0 )
        return;

    NewPosition = Clamp( NewPosition, 0, Max( 0, PlayerScrollBar.Length - PlayerScrollBar.DisplayCount ) );

    if( PlayerScrollBar.Position == NewPosition )
        return;

    PlayerScrollBar.Position = NewPosition;

    LayoutMenuScrollBar( PlayerScrollBar );
}

simulated function OnPlayerScrollUp()
{
    ScrollPlayerTo( PlayerScrollBar.Position - 1 );
}

simulated function OnPlayerScrollDown()
{
    ScrollPlayerTo( PlayerScrollBar.Position + 1 );
}

simulated function OnPlayerPageUp()
{
    ScrollPlayerTo( PlayerScrollBar.Position - PlayerScrollBar.DisplayCount );
}

simulated function OnPlayerPageDown()
{
    ScrollPlayerTo( PlayerScrollBar.Position + PlayerScrollBar.DisplayCount );
}

simulated function OnPlayerScrollLinesUp( int Lines )
{
    ScrollPlayerTo( PlayerScrollBar.Position - Lines );
}

simulated function OnPlayerScrollLinesDown( int Lines )
{
    ScrollPlayerTo( PlayerScrollBar.Position + Lines );
}

defaultproperties
{
     ServerInfoHeadings(0)=(Blurred=(Text="Server",DrawPivot=DP_MiddleLeft,PosX=0.064000,PosY=0.120000),bDisabled=1,OnSelect="OnSortChange",Pass=3,Style="SmallPushButtonRounded")
     ServerInfoHeadings(1)=(Blurred=(Text="Map",DrawPivot=DP_MiddleLeft,PosX=0.500000))
     ServerInfoHeadings(2)=(Blurred=(Text="Game",DrawPivot=DP_MiddleRight,PosX=0.764000))
     ServerInfoHeadings(3)=(Blurred=(Text="Size",DrawPivot=DP_MiddleRight,PosX=0.850000))
     ServerInfoHeadings(4)=(Blurred=(Text="Ping",DrawPivot=DP_MiddleRight,PosX=0.936000))
     ServerInfoRow(0)=(DrawPivot=DP_MiddleLeft,PosY=0.185000,Style="SmallLabel")
     ServerInfoRow(1)=(DrawPivot=DP_MiddleLeft,MaxSizeX=0.190000)
     ServerInfoRow(2)=(DrawPivot=DP_MiddleRight)
     ServerInfoRow(3)=(DrawPivot=DP_MiddleRight)
     ServerInfoRow(4)=(DrawPivot=DP_MiddleRight)
     LongInfoLabels(0)=(DrawPivot=DP_MiddleRight,PosX=0.250000,Style="SmallLabel")
     LongInfoValues(0)=(DrawPivot=DP_MiddleLeft,PosX=0.260000,Style="SmallLabel")
     LongInfoLabelLayout=(PosY=0.260000,SpacingY=0.045000)
     LongInfoValueLayout=(PosY=0.260000,SpacingY=0.045000)
     ColumnTitles(0)=(Text="Property:",DrawPivot=DP_MiddleRight,PosY=0.425000,Style="SmallLabel")
     ColumnTitles(1)=(Text="Value",DrawPivot=DP_MiddleLeft)
     ColumnTitles(2)=(Text="Player",DrawPivot=DP_MiddleLeft)
     ColumnTitles(3)=(Text="Score",DrawPivot=DP_MiddleRight)
     ColumnTitles(4)=(Text="Ping",DrawPivot=DP_MiddleRight)
     InfoScrollArea=(X1=0.020000,Y1=0.450000,X2=0.455000,Y2=0.830000,OnScrollPageUp="OnInfoPageUp",OnScrollLinesUp="OnInfoScrollLinesUp",OnScrollLinesDown="OnInfoScrollLinesDown",OnScrollPageDown="OnInfoPageDown",Style="TitledStringListScrollArea")
     InfoScrollBar=(PosX1=0.475000,PosY1=0.491000,PosX2=0.475000,PosY2=0.800000,OnScroll="OnInfoScroll",Style="VerticalScrollBar")
     InfoScrollArrowUp=(Blurred=(PosX=0.475000,PosY=0.475000),OnSelect="OnInfoScrollUp",Style="TitledStringListArrowUp")
     InfoScrollArrowDown=(Blurred=(PosX=0.475000,PosY=0.815000),OnSelect="OnInfoScrollDown",Style="TitledStringListArrowDown")
     InfoPageUpArea=(OnSelect="OnInfoPageUp",Style="TitledStringListPageScrollArea")
     InfoPageDownArea=(OnSelect="OnInfoPageDown",Style="TitledStringListPageScrollArea")
     PlayerScrollArea=(X1=0.500000,Y1=0.450000,X2=0.950000,Y2=0.830000,OnScrollPageUp="OnPlayerPageUp",OnScrollLinesUp="OnPlayerScrollLinesUp",OnScrollLinesDown="OnPlayerScrollLinesDown",OnScrollPageDown="OnPlayerPageDown",Style="TitledStringListScrollArea")
     PlayerScrollBar=(PosX1=0.970000,PosY1=0.491000,PosX2=0.970000,PosY2=0.800000,OnScroll="OnPlayerScroll",Style="VerticalScrollBar")
     PlayerScrollArrowUp=(Blurred=(PosX=0.970000,PosY=0.475000),OnSelect="OnPlayerScrollUp",Style="TitledStringListArrowUp")
     PlayerScrollArrowDown=(Blurred=(PosX=0.970000,PosY=0.815000),OnSelect="OnPlayerScrollDown",Style="TitledStringListArrowDown")
     PlayerPageUpArea=(OnSelect="OnPlayerPageUp",Style="TitledStringListPageScrollArea")
     PlayerPageDownArea=(OnSelect="OnPlayerPageDown",Style="TitledStringListPageScrollArea")
     InfoColumns(0)=(Template=(Blurred=(DrawPivot=DP_MiddleRight,MaxSizeX=0.220000)),PosX1=0.250000,PosY1=0.475000,PosX2=0.250000,PosY2=0.790000,DisplayCount=8,Style="ServerInfoColumn")
     InfoColumns(1)=(Template=(Blurred=(DrawPivot=DP_MiddleLeft,MaxSizeX=0.680000)),PosX1=0.260000,PosX2=0.260000)
     PlayerColumns(0)=(Template=(Blurred=(DrawPivot=DP_MiddleLeft)),PosX1=0.065000,PosY1=0.475000,PosX2=0.065000,PosY2=0.790000,DisplayCount=8,Style="ServerInfoColumn")
     PlayerColumns(1)=(Template=(Blurred=(DrawPivot=DP_MiddleRight)),PosX1=0.260000,PosX2=0.260000)
     PlayerColumns(2)=(Template=(Blurred=(DrawPivot=DP_MiddleRight)),PosX1=0.260000,PosX2=0.260000)
     ErrorMessage=(Text="This server is not responding. It might be offline at the moment or there could be a problem with your internet connection.\n\nPlease try again later.",Style="MedMessageText")
     StringAdministrator="Administrator"
     StringIPAddress="IP-Address"
     StringGame="Game"
     StringDedicated="Dedicated"
     StringPrivate="Private"
     StringCustom="Custom"
     StringFriendlyFire="Friendly Fire"
     StringBots="Bots"
     StringTimeLimit="Time Limit"
     StringScoreLimit="Score Limit"
     StringInitialWECs="Initial WECs"
     ALabel=(Text="Join")
     APlatform=MWP_All
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
