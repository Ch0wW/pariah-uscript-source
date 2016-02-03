class MenuDedicatedServer extends MenuTemplateTitledB;

var() MenuText	    SessionInfo;
var() MenuSprite	LogBackground;

var() float ScreenSaverTime;
var() float ScreenSaverActivate;
var() String CircBuffer[16];
var() int CircCursor;

var() localized String InitMsg;
var() localized String PlayersString;
var() localized String PlayerString;

var() float SingleLineHeight;

simulated function Init(String Args)
{
    Super.Init(Args);
    ScreenSaverActivate = Level.TimeSeconds + ScreenSaverTime;
    SetTimer(0.1, true);
    //TestData();
    
    LanguageChange();
}

simulated function LanguageChange()
{
    for( CircCursor = 0; CircCursor < ArrayCount(CircBuffer); ++CircCursor )
    {
        CircBuffer[CircCursor] = "";
    } 
    
    CircCursor = 0;
    HandleGameLog(InitMsg);
}

simulated exec function Pork()
{
    local int i;
    for( i=0; i<ArrayCount(CircBuffer); i++ )
    {
        CircBuffer[i] = "Dedicated Server started.  This is some test data!  It happens to be a really long line, which is totally cool" @ String(i);
    }
}

simulated function HandleGameLog(String Msg)
{
    if( Msg=="" )
        return;

    CircBuffer[CircCursor] = Msg;
    CircCursor = (CircCursor + 1) % ArrayCount(CircBuffer);
}

simulated function ShutdownDialog()
{
    local MenuEndDedicatedServer Question;

    bAcceptInput = false;
    Question = Spawn(class'MenuEndDedicatedServer', Owner);
    CallMenu( Question );
}

simulated function bool MenuClosed( Menu ClosingMenu )
{
    bAcceptInput = true;
    return false;
}

simulated function HandleInputBack()
{
    ShutdownDialog();
}

simulated function HandleInputStart();

simulated function ResetScreenSaver()
{
    ScreenSaverActivate = Level.TimeSeconds + ScreenSaverTime;
}

// !! Need to handle analog movement too!
simulated event bool HandleInputKeyRaw(Interactions.EInputKey Key, Interactions.EInputAction Action)
{
    if(Action != IST_Press)
    {
        return(false);
    }
    ResetScreenSaver();
    return false;
}

simulated function DrawMenu(Canvas C, bool HasFocus )
{
    local int i;
    local float x, y;
    local float outX, outY;
    local float bottomX, bottomY;
    local float tmpX;

    Super.DrawMenu(C, HasFocus);

    x = (LogBackground.PosX * C.SizeX) + 8;
    y = (LogBackground.PosY * C.SizeY) + 1;
    
    C.Reset();

    C.bCenter = false;
    bottomX = (x+(LogBackground.ScaleX * C.SizeX))-4;
    bottomY = (y+(LogBackground.ScaleY * C.SizeY))-2;

    C.SetClip( bottomX, bottomY );
    C.Font = class'MenuDefaults'.default.SmallLabel.MenuFont;
    C.FontScaleX = class'MenuDefaults'.default.SmallLabel.ScaleX;
    C.FontScaleY = class'MenuDefaults'.default.SmallLabel.ScaleY;
    C.DrawColor = class'MenuDefaults'.default.SmallLabel.DrawColor;

    if( SingleLineHeight== 0.0 )
    {
        C.SetPos( 0, 0);
        C.TextSize("T", tmpX, SingleLineHeight);
    }

    for( i=ArrayCount(CircBuffer)-1; i>-1; i-- )
    {
        C.SetPos( x, 0);
        C.StrLen(CircBuffer[(CircCursor+i)%ArrayCount(CircBuffer)], outX, outY);
        if( (bottomY-outY) < y )
            break;
        C.SetPos( x, bottomY-outY );
        C.DrawText(CircBuffer[(CircCursor+i)%ArrayCount(CircBuffer)]);
        bottomY -= outY;
    }

    C.Reset();
    C.SetPos( 0, 0 );
    C.SetClip( C.SizeX, C.SizeY );

    if( Level.TimeSeconds > ScreenSaverActivate )
    {
        C.Style = ERenderStyle.STY_Alpha;

        C.DrawColor.R = 0;
        C.DrawColor.G = 0;
        C.DrawColor.B = 0;
        C.DrawColor.A = 180;

        C.DrawTile( Texture'Engine.PariahWhiteTexture', C.SizeX, C.SizeY, 0.0, 0.0, 64, 64 );

        C.DrawColor.R = 255;
        C.DrawColor.G = 255;
        C.DrawColor.B = 255;
        C.DrawColor.A = 255;
    }
}

simulated function Timer()
{
    local int Count;
    local String Details;

    Count = int(ConsoleCommand("GET_HOST_PLAYER_COUNT"));
    Details = ConsoleCommand("GET_HOST_DETAILS");
    
    if( Details != "" )
    {
        Details = Details $ " - ";
    }
    
    if( Count == 1 )
        SessionInfo.Text = Details $ Count @ PlayerString;
    else
        SessionInfo.Text = Details $ Count @ PlayersString;
}

defaultproperties
{
     SessionInfo=(Text="Gametype - Map",DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.180000,Style="SmallLabel")
     LogBackground=(PosX=0.075000,PosY=0.200837,ScaleX=0.850000,ScaleY=0.644351,Pass=1,Style="Border")
     ScreenSaverTime=60.000000
     InitMsg="Dedicated server started."
     PlayersString="Players"
     PlayerString="Player"
     MenuTitle=(Text="Dedicated Server")
     Background=(WidgetTexture=Texture'LoadingScreens.Vignette_00',DrawColor=(B=64,G=64,R=64,A=255))
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
     bAllowStats=True
}
