class HudBase extends HudFunctional
    exportstructs
    native;


// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() transient int TeamIndex;

struct HudLocalizedMessage
{
    // The following block of variables are set when the message is entered;
    // (Message being set indicates that a message is in the list).

    var class<LocalMessage> Message;
    var String StringMessage;
    var int Switch;
    var PlayerReplicationInfo RelatedPRI;
    var Object OptionalObject;
    var float EndOfLife;
    var float LifeTime;

    // The following block of variables are cached on first render;
    // (StringFont being set indicates that they've been rendered).

    var Font StringFont;
    var Color DrawColor;
    var EDrawPivot DrawPivot;
    var LocalMessage.EStackMode StackMode;
    var float PosX, PosY;
    var float DX, DY;
    
    // Stinky I know.
    var bool Drawn;
};

var() transient HudLocalizedMessage LocalMessages[8];
var() Font MessageFonts[3];
var() class<Menu> VoteMenuClass;
var() class<Menu> VoiceMenuClass;
var() class<Menu> VoiceChannelMenuClass;

// targeting
var Material TargetMaterial[3];
var transient bool bShowTargeting;
var transient Vector TargetingLocation;
var transient float TargetingSize;

var Material HintTargetMaterial;
var transient bool bShowHintTarget;
var transient Vector HintTargetLocation;
var transient float HintTargetSize;

var Material RocketTargetMaterial;
var transient int bShowRocketTarget[4];
var transient Vector RocketTargetLocation[4];
var transient float RocketTargetSize;
var() float ReticleScaleX, ReticleScaleY;

var transient vector VehicleCrossHairLocation;

// --- Hud Animations
const DIGITS_FADE_TIME  = 0.2;
const CROSSHAIR_TIME  = 0.25;

var() int bAmmoIconPulse;
var() int bCrosshairPulse;

var() float AmmoIconScaleSize;
var() float CrossHairScaleSize;
// ---


// instruction
var() string InstructionText;
var() string InstructionKeyText;
var() float InstructTextBorderX;
var() float InstructTextBorderY;
var() float InstrDelta;
var() float InstrRate;

var() bool DoCropping;
var() float CroppingAmount;
var() Material CroppingMaterial;

var() float RedRadarPosX, RedRadarPosY, BlueRadarPosX, BlueRadarPosY;

var() float LocalMessageFontScale;
var() float TargetPlayerNameX;
var() float TargetPlayerNameY;
var() string TargetPlayerName;
var() float TargetPlayerShowStartTime;
var() color TargetPlayerColor;


//cmr moved up from HudATeamDeathMatch to facilitate some nativization hacks.
var bool bHighlightFlagpos;
var bool bManualHighlight;
var vector ManualFlagpos;
var Color HudHighlightColor;
var vector HighlightPos;


//cmr -- moved up from hudadeathmatch for nativization
struct GuiHideData
{
    var bool bHide;
    var float HideSpeed;
    var float ShowSpeed; 
    var vector HiddenPos; //fully hidden offset
    var vector Position; //current gui offset
    var float HideTimeout; // how long till gui hides
    var float HideCounter; // to find when to hide (check against timeout)
    var float LastUpdate; // to track dt
    var vector CurrentDelta; //where movement is stored to update a guigroup

};

var() SpriteWidget  DefaultCrosshair;
var() Color         DefaultTints[2];

var() SpriteWidget  ReticleCrosshair;

var() class<Menu> SoakModeOverlayClass;
var() Menu SoakModeOverlay;

var() SpriteWidget LHud[2];
var() SpriteWidget OverHeatingIcon[2];

var() Material HealthAlertMaterial, HealthNormalMaterial;

var() NumericWidget HealthCount;
var() NumericWidget ShieldCount;
var() SpriteWidget HealthIcon;

var() DigitSet DigitsBig;

//var transient float CurHealth, LastHealth, CurShield, LastShield, CurEnergy, CurAmmoPrimary, CurAmmoSecondary;

var transient float CurHealth;

//var transient float MaxHealth, MaxShield, LastEnergy, MaxEnergy, MaxAmmoPrimary, MaxAmmoSecondary, UdamageCount;

const DamageDirFront    = 0;
const DamageDirRight    = 1;
const DamageDirLeft     = 2;
const DamageDirBehind   = 3;

const DamageDirMax      = 4;

var() bool bHudShowsTargetInfo;

var Rotator WeaponBoneRotation; // A somewhat convenient way to get the vehicle weapon reticle drawn in the right spot for weapons using a separate rotation bone
var Vector WeaponMuzzleLocation; // another aid for the vehicle weapon reticle

simulated native function UpdateHideData(out GuiHideData ghd);
simulated native function ToggleHideData(out GuiHideData ghd, bool bHide);
simulated native function ApplyHideDataS(GuiHideData ghd, out SpriteWidget widget, optional bool bSkipAlpha);
simulated native function ApplyHideDataN(GuiHideData ghd, out NumericWidget widget, optional bool bSkipAlpha);


simulated native function DrawCrosshair (Canvas C);


simulated native function DrawVehicleCrosshair (Canvas C);

simulated native function DrawDeathmatchHudPassA( Canvas C );

// Derived HUDs override UpdateHud to update variables before rendering;
// NO draw code should be in derived DrawHud's; they should instead override 
// DrawHudPass[A-D] and call their base class' DrawHudPass[A-D] (This cuts
// down on render state changes).

simulated function UpdateHud(); 

simulated function DrawHudPassA (Canvas C); // Alpha Pass
simulated function DrawHudPassB (Canvas C); // Alternate Texture Pass

simulated function DrawHud (Canvas C)
{
    Super.DrawHud (C);

    UpdateHud();
    
    if( bShowTargeting )
        DrawTargeting(C);

    if( bShowHintTarget )
        DrawHintTarget(C);

    DrawRocketTargets(C);

    PassStyle = STY_Alpha;
    DrawHudPassA (C);
    PassStyle = STY_None;
    DrawHudPassB (C);

    DisplayLocalMessages (C);
    DrawTargetPlayerName(C); //amb

    if(XPlayer(PlayerOwner).bShowMemStats)
        DisplayMemStats(C);
}

simulated function DrawSpectatingHud (Canvas C)
{
    if (PlayerOwner.Player.Console.IsSoaking())
    {
        if (SoakModeOverlay != None)
            SoakModeOverlay.DrawMenu (C, false);
    }
    else if (PlayerOwner.GetStateName() == 'PlayerWaiting' && PlayerOwner.Player.SplitIndex==0 )
    {
        if (PreGameOverlay != None)
            PreGameOverlay.DrawMenu (C, false);
        DisplayLocalMessages (C);
    }
    else if ( PlayerOwner.GetStateName() == 'GameEnded' && PlayerOwner.Player.SplitIndex==0 )
    {
        if( Scoreboard != None )
            Scoreboard.DrawMenu( C, false );

        DisplayLocalMessages (C);
    }
    else
    {
        if (SpectatingOverlay != None)
            SpectatingOverlay.DrawMenu (C, false);
        DisplayLocalMessages (C);
    }
}

simulated function SpawnOverlays()
{
    if (SoakModeOverlayClass != None)
    {
        SoakModeOverlay = Spawn (SoakModeOverlayClass, Owner);
        SoakModeOverlay.Init(Level.GetLocalURL());
    }

    Super.SpawnOverlays();
}

simulated event Destroyed()
{
    if( SoakModeOverlay != None )
    {
        SoakModeOverlay.Destroy();
        SoakModeOverlay = None;
    }

    Super.Destroyed();
}

native simulated function DrawAssaultHud( Canvas C, Vector NextPointWorldPosition, byte Team, byte barsize, Material Bar, Material NextPoint );

simulated function ClearMessage( out HudLocalizedMessage M )
{
    M.Message = None;
    M.StringFont = None;
}

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
    local Class<LocalMessage> MessageClass;

    if( bMessageBeep )
        PlayerOwner.PlayBeepSound();

    switch( MsgType )
    {
        case 'Say':
            Msg = PRI.RetrivePlayerName()$": "$Msg;
            MessageClass = class'SayMessagePlus';
            break;
        case 'TeamSay':
            Msg = PRI.RetrivePlayerName()$": "$Msg;
            MessageClass = class'TeamSayMessagePlus';
            break;
        case 'CriticalEvent':
            MessageClass = class'CriticalEventPlus';
            LocalizedMessage( MessageClass, 0, None, None, None, Msg );
            return;
        case 'DeathMessage':
            MessageClass = class'xDeathMessage';
            LocalizedMessage( MessageClass, 0, None, None, None, Msg );
            return;
        default:
            MessageClass = class'StringMessagePlus';
            break;
    }

    AddTextMessage( Msg, MessageClass, PRI );
}

simulated function PulseCrosshair()
{
    bCrosshairPulse = 1;
    CrossHairScaleSize = Level.TimeSeconds + CROSSHAIR_TIME;
}

simulated function PulseAmmoIcon()
{
    bAmmoIconPulse=1;
    AmmoIconScaleSize = Level.TimeSeconds + DIGITS_FADE_TIME;
}

// Aite, some messages have periods at the end, some don't.
simulated function ConformWhackPunctuation( out String Message )
{
    local String Suffix;
    
    Suffix = Right( Message, 1 );
    
    if( (Suffix != ".") && (Suffix != "!") )
    {
        Message = Message $ ".";
    }
}

simulated function KillMessages()
{
    local int i;
    for( i = 0; i < ArrayCount(LocalMessages) - 1; i++ )
    {
        ClearMessage(LocalMessages[i]);
    }
}

simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString)
{
    local int i;

    if( Message == None )
        return;

    if( (OptionalObject != None) && ClassIsChildOf( Message, class'PickupMessagePlus' ) )
    {
        if( ClassIsChildOf( class<Pickup>(OptionalObject), class'Ammo' ) )
        {
            PulseCrosshair();
            PulseAmmoIcon();
        }
        else
        {
           PulseCrosshair();
        }
    }

    if( CriticalString == "" )
        CriticalString = Message.static.GetString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );

    if( CriticalString == "" )
        return;

    if( bMessageBeep && Message.default.bBeep )
        PlayerOwner.PlayBeepSound();

    if( !Message.default.bIsSpecial )
    {
        AddTextMessage( CriticalString, Message );
        return;
    }

    i = ArrayCount(LocalMessages);

    if( Message.default.bIsUnique )
    {
        for( i = 0; i < ArrayCount(LocalMessages); i++ )
        {
            if( LocalMessages[i].Message == None )
                continue;

            if( LocalMessages[i].Message == Message )
                break;
        }
    }
    else if ( Message.default.bIsPartiallyUnique )
    {
        for( i = 0; i < ArrayCount(LocalMessages); i++ )
        {
            if( LocalMessages[i].Message == None )
                continue;

            if( ( LocalMessages[i].Message == Message ) && ( LocalMessages[i].Switch == Switch ) )
                break;
        }
    }

    if( i == ArrayCount(LocalMessages) )
    {
        for( i = 0; i < ArrayCount(LocalMessages); i++ )
        {
            if( LocalMessages[i].Message == None )
                break;
        }
    }

    if( i == ArrayCount(LocalMessages) )
    {
        for( i = 0; i < ArrayCount(LocalMessages) - 1; i++ )
            LocalMessages[i] = LocalMessages[i+1];
    }

    ClearMessage( LocalMessages[i] );

    ConformWhackPunctuation( CriticalString );

    LocalMessages[i].Message = Message;
    LocalMessages[i].Switch = Switch;
    LocalMessages[i].RelatedPRI = RelatedPRI_1;
    LocalMessages[i].OptionalObject = OptionalObject;
    LocalMessages[i].EndOfLife = 0;     // initialized in DisplayLocalMessages
    LocalMessages[i].StringMessage = CriticalString;
    LocalMessages[i].LifeTime = Message.static.GetLifetime(Switch);
}

simulated function int LocalizedMessageSlotsAvailable()
{
    local int i, available;

    available = 0;
    for( i = 0; i < ArrayCount(LocalMessages); i++ )
    {
        if( LocalMessages[i].Message == None )
        {
            available = ArrayCount(LocalMessages) - i;
            break;
        }
    }
    return available;
}

simulated function LayoutMessage( out HudLocalizedMessage Message, Canvas C )
{
    local int FontSize;

    FontSize = Message.Message.static.GetFontSize( Message.Switch );

    if( FontSize < 1 && C.ClipX < 640.00 )
            FontSize = 1;
    
    Message.StringFont = MessageFonts[Clamp( FontSize, 0, ArrayCount(MessageFonts) - 1 )];

    Message.DrawColor = Message.Message.static.GetColor( Message.Switch );

    Message.Message.static.GetPos( Message.Switch, Message.DrawPivot, Message.StackMode, Message.PosX, Message.PosY );

    C.Font = Message.StringFont;
    C.FontScaleX = LocalMessageFontScale;
    C.FontScaleY = LocalMessageFontScale;
    C.TextSize( Message.StringMessage, Message.DX, Message.DY );
}

simulated function GetScreenCoords(float PosX, float PosY, out float ScreenX, out float ScreenY, out HudLocalizedMessage Message, Canvas C )
{
    ScreenX = (PosX * HudCanvasScale * C.ClipX) + (((1.0f - HudCanvasScale) * HudCanvasCenterX) * C.ClipX);
    ScreenY = (PosY * HudCanvasScale * C.ClipY) + (((1.0f - HudCanvasScale) * HudCanvasCenterY) * C.ClipY);
   
    switch( Message.DrawPivot )
    {
        case DP_UpperLeft:
            break;

        case DP_UpperMiddle:
            ScreenX -= Message.DX * 0.5;
            break;

        case DP_UpperRight:
            ScreenX -= Message.DX;
            break;

        case DP_MiddleRight:
            ScreenX -= Message.DX;
            ScreenY -= Message.DY * 0.5;
            break;

        case DP_LowerRight:
            ScreenX -= Message.DX;
            ScreenY -= Message.DY;
            break;

        case DP_LowerMiddle:
            ScreenX -= Message.DX * 0.5;
            ScreenY -= Message.DY;
            break;

        case DP_LowerLeft:
            ScreenY -= Message.DY;
            break;

        case DP_MiddleLeft:
            ScreenY -= Message.DY * 0.5;
            break;

        case DP_MiddleMiddle:
            ScreenX -= Message.DX * 0.5;
            ScreenY -= Message.DY * 0.5;
            break;

    }
}

simulated function DrawMessage( Canvas C, int i, float PosX, float PosY, out float DX, out float DY )
{
    local float FadeValue;
    local float ScreenX, ScreenY;

    GetScreenCoords( PosX, PosY, ScreenX, ScreenY, LocalMessages[i], C );
    
    C.Font = LocalMessages[i].StringFont;
    
    //AsP --- To scale the Local messages.. so i dont have to import another texture
    C.FontScaleX = LocalMessageFontScale;
    C.FontScaleY = LocalMessageFontScale;

    if( !LocalMessages[i].Message.default.bFadeMessage )
    {
        C.SetPos( ScreenX+1, ScreenY+1 );
        C.DrawColor.R = 0;
        C.DrawColor.B = 0;
        C.DrawColor.G = 0;
        C.DrawColor.A = 255;
        C.DrawTextClipped( LocalMessages[i].StringMessage );

        C.DrawColor = LocalMessages[i].DrawColor;
        C.SetPos( ScreenX, ScreenY );
        C.DrawTextClipped( LocalMessages[i].StringMessage );
    }else
    {
        C.SetPos( ScreenX+1, ScreenY+1 );
        C.DrawColor.R = 0;
        C.DrawColor.B = 0;
        C.DrawColor.G = 0;
        FadeValue = FClamp(LocalMessages[i].EndOfLife - Level.TimeSeconds, 0.0, 1.0);
        C.DrawColor.A = LocalMessages[i].DrawColor.A * FadeValue;
        C.DrawTextClipped( LocalMessages[i].StringMessage );

        C.SetPos( ScreenX, ScreenY );
        C.DrawColor = LocalMessages[i].DrawColor;
        FadeValue = FClamp(LocalMessages[i].EndOfLife - Level.TimeSeconds, 0.0, 1.0);
        C.DrawColor.A = LocalMessages[i].DrawColor.A * FadeValue;
        
        C.DrawTextClipped( LocalMessages[i].StringMessage );

    }

    DX = LocalMessages[i].DX / C.ClipX;
    DY = LocalMessages[i].DY / C.ClipY;
    
    LocalMessages[i].Drawn = true;
}


simulated function DisplayLocalMessages( Canvas C )
{
    local float PosX, PosY, DY, DX;
    local int i, j;
    local float LifeLeft;

    local class<LocalMessage> Message;
    local int SwitchV;
    local PlayerReplicationInfo RelatedPRI;
    local Object OptionalObject;

    if( ShowingMenu() )
        return;

    C.Reset();

    // Pass 1: Layout anything that needs it and cull dead stuff.
    
    for( i = 0; i < ArrayCount(LocalMessages); i++ )
    {
        if( LocalMessages[i].Message == None )
            break;

        Message = LocalMessages[i].Message;
        SwitchV = LocalMessages[i].Switch;
        RelatedPRI = LocalMessages[i].RelatedPRI;
        OptionalObject = LocalMessages[i].OptionalObject;

        LocalMessages[i].Drawn = false;
        
        if( !Message.static.IsValid( SwitchV, RelatedPRI, None, OptionalObject ) )
        {
            for( j = i; j < ArrayCount(LocalMessages) - 1; j++ )
                LocalMessages[j] = LocalMessages[j+1];
            ClearMessage( LocalMessages[j] );
            i--;
            continue;
        }

        if( LocalMessages[i].StringFont == None )
            LayoutMessage( LocalMessages[i], C );

        if( LocalMessages[i].StringFont == None )
        {
            log( "LayoutMessage("$LocalMessages[i].Message$") failed!", 'Error' );

            for( j = i; j < ArrayCount(LocalMessages) - 1; j++ )
                LocalMessages[j] = LocalMessages[j+1];
            ClearMessage( LocalMessages[j] );
            i--;
            continue;
        }

        if ( LocalMessages[i].EndOfLife == 0 )
        {
            LocalMessages[i].EndOfLife = LocalMessages[i].Lifetime + Level.TimeSeconds;
        }
        LifeLeft = (LocalMessages[i].EndOfLife - Level.TimeSeconds);

        if( LifeLeft <= 0.0 ) 
        {
            for( j = i; j < ArrayCount(LocalMessages) - 1; j++ )
                LocalMessages[j] = LocalMessages[j+1];
            ClearMessage( LocalMessages[j] );
            i--;
            continue;
        }
    }

    // Pass 2: Go through the list and draw each stack:

    for( i = 0; i < ArrayCount(LocalMessages); i++ )
    {
        if( LocalMessages[i].Message == None )
            break;

        if( LocalMessages[i].Drawn )
            continue;

        PosX = LocalMessages[i].PosX;
        PosY = LocalMessages[i].PosY;
        
        if( LocalMessages[i].StackMode == SM_None )
        {
            DrawMessage( C, i, PosX, PosY, DX, DY );
            continue;
        }
        
        for( j = i; j < ArrayCount(LocalMessages); j++ )
        {
            if( LocalMessages[j].Drawn )
                continue;

            if( LocalMessages[i].PosX != LocalMessages[j].PosX ) 
                continue;

            if( LocalMessages[i].PosY != LocalMessages[j].PosY ) 
                continue;

            if( LocalMessages[i].DrawPivot != LocalMessages[j].DrawPivot ) 
                continue;

            if( LocalMessages[i].StackMode != LocalMessages[j].StackMode ) 
                continue;
        
            DrawMessage( C, j, PosX, PosY, DX, DY );
            
            switch( LocalMessages[j].StackMode )
            {
                case SM_Up:
                    PosY -= DY;
                    break;
                    
                case SM_Down:
                    PosY += DY;
                    break;
            }
        }
    }
}

// --- For Drawing 2d indicators for TeamGame objectives
function Draw2DLocationDot(Canvas C, vector Loc, float PosX, float PosY , int TeamIndex)
{
    local rotator Dir;
    local float Angle;
    local float Radius;

    Dir = rotator(Loc - PawnOwner.Location);
    Angle = ((Dir.Yaw - PawnOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
    
    Radius = 0.037;
    
    if ( TeamIndex == 0)
    {
        RedRadarPosX = PosX + (sin(Angle) * Radius)*( 640.0 / C.SizeX );
        RedRadarPosY = PosY - (cos(Angle) * Radius)*( 480.0 / C.SizeY );
    }
    else
    {
        BlueRadarPosX = PosX + (sin(Angle) * Radius)*( 640.0 / C.SizeX );
        BlueRadarPosY = PosY - (cos(Angle) * Radius)*( 480.0 / C.SizeY );           
    }
}
// ---

simulated function SetTargeting( bool bShow, optional Vector TargetLocation, optional float Size )
{
    bShowTargeting = bShow;
    if( bShow )
    {   
        TargetingLocation = TargetLocation;
        if( Size != 0.0 )
            TargetingSize = Size;
    }
}

simulated function SetHintTarget( bool bShow, optional Vector TargetLocation, optional float Size )
{
    bShowHintTarget = bShow;
    if( bShow )
    {   
        HintTargetLocation = TargetLocation;
        if( Size != 0.0 )
            HintTargetSize = Size;
    }
}

// XJ --
/*
simulated function SetVehicleCrosshairLocation(Vector TargetLocation)
{
    //local rotation rot;
    rot = Owner.AutoAim(Owner.Pawn.Weapon.GetFireStart, Owner.Pawn.Weapon)
    VehicleCrossHairLocation = Owner.Target.Location;
}
*/
// -- XJ


simulated function DrawTargeting( Canvas C )
{
    local int XPos, YPos;
    local vector ScreenPos;
    local vector X,Y,Z,Dir;
    local float RatioX, RatioY;
    local float tileX, tileY;
    local float Dist;

    local float SizeX;
    local float SizeY;

    SizeX = TargetingSize * 96.0;
    SizeY = TargetingSize * 96.0;

    if( !bShowTargeting )
        return;

    ScreenPos = C.WorldToScreen( TargetingLocation );

    RatioX = C.SizeX / 640.0;
    RatioY = C.SizeY / 480.0;

    tileX = sizeX * RatioX;
    tileY = sizeY * RatioX;

    GetAxes(PlayerOwner.Rotation, X,Y,Z);
    Dir = TargetingLocation - PawnOwner.Location;
    Dist = VSize(Dir);
    Dir = Dir/Dist;

    if ( (Dir Dot X) > 0.0 ) // don't draw if it's behind the eye
    {

        SizeX = 0.5 * 96.0;
        SizeY = 0.5 * 96.0;
        RatioX = C.SizeX / 640.0;
        RatioY = C.SizeY / 480.0;
        
        tileX = sizeX * RatioX;
        tileY = sizeY * RatioX;

        XPos = ScreenPos.X;
        YPos = ScreenPos.Y;
        C.Style = ERenderStyle.STY_Additive;
        C.DrawColor.R = 255;
        C.DrawColor.G = 255;
        C.DrawColor.B = 255;
        C.DrawColor.A = 80;
        C.SetPos(XPos - tileX*0.5, YPos - tileY*0.5);
        C.DrawTile( TargetMaterial[1], tileX, tileY, 0.0, 0.0, 64, 64); //--- TODO : Fix HARDCODED USIZE
        
        
        SizeX = 1.1 * 96.0;
        SizeY = 1.1 * 96.0;
        RatioX = C.SizeX / 640.0;
        RatioY = C.SizeY / 480.0;
        tileX = sizeX * RatioX;
        tileY = sizeY * RatioX;

        XPos = ScreenPos.X;
        YPos = ScreenPos.Y;
        C.Style = ERenderStyle.STY_Additive;
        C.DrawColor.R = 255;
        C.DrawColor.G = 255;
        C.DrawColor.B = 255;
        C.DrawColor.A = 160;
        C.SetPos(XPos - tileX*0.5, YPos - tileY*0.5);
        C.DrawTile( TargetMaterial[0], tileX, tileY, 0.0, 0.0, 256, 256); //--- TODO : Fix HARDCODED USIZE
        //log("Drawing passtarget focus1");

        XPos = ScreenPos.X;
        YPos = ScreenPos.Y;
        C.Style = ERenderStyle.STY_Alpha;
        C.DrawColor.R = 255;
        C.DrawColor.G = 255;
        C.DrawColor.B = 255;
        C.DrawColor.A = 255;
        C.SetPos(XPos - tileX*0.5, YPos - tileY*0.5);
        C.DrawTile( TargetMaterial[2], tileX, tileY, 0.0, 0.0, 32, 32); //--- TODO : Fix HARDCODED USIZE    
    }
}

simulated function DrawHintTarget( Canvas C )
{
    local int XPos, YPos;
    local vector ScreenPos;
    local vector X,Dir;
    local float RatioX;
    local float tileX, tileY;
    local float Dist;
    local float SizeX;
    local float SizeY;

    SizeX = HintTargetSize * 96.0;
    SizeY = HintTargetSize * 96.0;

    ScreenPos = C.WorldToScreen( HintTargetLocation );

    RatioX = C.SizeX / 640.0;
    tileX = sizeX * RatioX;
    tileY = sizeY * RatioX;

    X = Vector(PlayerOwner.Rotation);
    Dir = HintTargetLocation - PawnOwner.Location;
    Dist = VSize(Dir);
    Dir = Dir/Dist;

    if ( (Dir Dot X) > 0.0 ) // don't draw if it's behind the eye
    {
        XPos = ScreenPos.X;
        YPos = ScreenPos.Y;
        C.Style = ERenderStyle.STY_Additive;
        C.DrawColor.R = 255;
        C.DrawColor.G = 255;
        C.DrawColor.B = 255;
        C.DrawColor.A = 160;
        C.SetPos(XPos - tileX*0.5, YPos - tileY*0.5);
        C.DrawTile( HintTargetMaterial, tileX, tileY, 0.0, 0.0, 256, 256); //--- TODO : Fix HARDCODED USIZE 
    }
}

simulated function DrawRocketTargets( Canvas C )
{
    local int XPos, YPos;
    local vector ScreenPos;
    local vector X,Dir;
    local float RatioX;
    local float tileX, tileY;
    local float Dist;
    local float SizeX;
    local float SizeY;
    local int InGamePlayerScale;
    local int i;

    InGamePlayerScale = 196;// in unreal units

    for(i = 0; i < ArrayCount(bShowRocketTarget); ++i)
    {
        if(bShowRocketTarget[i] == 1)
        {
            ScreenPos = C.WorldToScreen( RocketTargetLocation[i] );

            X = Vector(PlayerOwner.Rotation);
            Dir = RocketTargetLocation[i] - PawnOwner.Location; 
            Dist = VSize(Dir);
            Dir = Dir/Dist;

            // MaxLockOnRange = 6000.00;
            SizeX = ReticleScaleX*(InGamePlayerScale/Dist);
            SizeY = ReticleScaleY*(InGamePlayerScale/Dist);
            RatioX = C.SizeX / 640.0;
            tileX = sizeX * RatioX;
            tileY = sizeY * RatioX;

            if ( (Dir Dot X) > 0.0 ) // don't draw if it's behind the eye
            {
                XPos = ScreenPos.X;
                YPos = ScreenPos.Y;
           
                C.Style = ERenderStyle.STY_Modulated;
                C.DrawColor.R = Lerp(sin(Level.TimeSeconds*10),128.0, 255, true);
                C.DrawColor.G = Lerp(sin(Level.TimeSeconds*10),128.0, 238, true);
                C.DrawColor.B = Lerp(sin(Level.TimeSeconds*10),128.0, 147, true);;
                C.DrawColor.A = 255;

                C.SetPos(XPos - tileX*0.5, YPos - tileY*0.5);
                C.DrawTile( texture'Engine.PariahWhiteTexture', tileX, tileY, 0.0, 0.0, 4, 4);

                C.SetDrawColor(255,175,128,255);
                C.SetPos( XPos - (tileX*0.5 +10), YPos );// Line
                C.DrawTile( texture'Engine.PariahWhiteTexture', -XPos, 1, 0.0, 0.0, 4, 4);

                C.SetPos( XPos + ( tileX*0.5 +10), YPos );// Line
                C.DrawTile( texture'Engine.PariahWhiteTexture', C.SizeX-XPos, 1, 0.0, 0.0, 4, 4);

                C.SetPos( XPos , YPos - ( tileY*0.5 +10));// Line
                C.DrawTile( texture'Engine.PariahWhiteTexture', 1, -YPos, 0.0, 0.0, 4, 4);

                C.SetPos( XPos , YPos + ( tileY*0.5 +10) );// Line
                C.DrawTile( texture'Engine.PariahWhiteTexture', 1, C.SizeY-YPos, 0.0, 0.0, 4, 4);

                C.Style = ERenderStyle.STY_Alpha;
                C.SetDrawColor(255,150,0,Lerp(sin(Level.TimeSeconds*20),100, 200, true));
                C.SetPos( XPos - (tileX+4)*0.5 , YPos - ( tileY*0.5+1 ));// Dot
                C.DrawTile( texture'Engine.PariahWhiteTexture', (tileX+4), 1, 0.0, 0.0, 4, 4);

                C.SetPos( XPos - (tileX+4)*0.5 , YPos + ( tileY*0.5+1 ) );// Dot
                C.DrawTile( texture'Engine.PariahWhiteTexture', (tileX+4), 1, 0.0, 0.0, 4, 4);


                C.Font = MessageFonts[2];
                C.Style = ERenderStyle.STY_Alpha;
                C.DrawColor.R = 255;
                C.DrawColor.G = 175;
                C.DrawColor.B = 128;
                C.DrawColor.A = 255;
                C.SetPos( XPos , YPos + ( tileY*0.5 - 10) );
                C.DrawText(Dist/ 52.5);
            
            }
        }
    }
}

simulated function SetCropping( bool Active )
{
    DoCropping = active;
}

simulated function DrawInstructionGfx(Canvas C)
{
    local float CropHeight;

    //log("DrawInstructionGfx");

    DrawCrosshair(C);
    DrawTargeting(C);
    if( DoCropping )
    {
        // todo: lerp the crop height
        CropHeight = (C.SizeY * CroppingAmount) * 0.5;
        C.SetPos(0, 0);

        C.DrawColor.R = 0;
        C.DrawColor.G = 0;
        C.DrawColor.B = 0;
        C.DrawColor.A = 255;

        C.DrawTile( Texture'Engine.PariahWhiteTexture', C.SizeX, CropHeight, 0.0, 0.0, 64, 64 );
        C.SetPos( 0, C.SizeY-CropHeight );
        C.DrawTile( Texture'Engine.PariahWhiteTexture', C.SizeX, CropHeight, 0.0, 0.0, 64, 64 );

        C.DrawColor.R = 255;
        C.DrawColor.G = 255;
        C.DrawColor.B = 255;
    }
    DrawInstructionText(C);
    DrawInstructionKeyText(C);
}

simulated function DrawInstructionText(Canvas C)
{
    if( InstructionText == "" )
        return;

    C.Font = C.SmallFont;

    C.SetOrigin( InstructTextBorderX, InstructTextBorderY );
    C.SetClip( C.SizeX-InstructTextBorderX, C.SizeY );
    C.SetPos(0,0);

    C.DrawText( InstructionText );    

    C.SetOrigin(0.0, 0.0);
    C.SetClip( C.SizeX, C.SizeY );
}

simulated function DrawInstructionKeyText(Canvas C)
{
    local float strX;
    local float strY;

    if( InstructionKeyText == "" )
        return;

    C.Font = C.SmallFont;


    C.SetOrigin( InstructTextBorderX, InstructTextBorderY );
    C.SetClip( C.SizeX-InstructTextBorderX, C.SizeY );

    C.StrLen( InstructionKeyText, strX, strY );

    C.SetOrigin( InstructTextBorderX, C.SizeY-strY-InstructTextBorderY );
    C.SetClip( C.SizeX-InstructTextBorderX, C.SizeY );
    C.SetPos(0,0);

    C.DrawText( InstructionKeyText );

    C.SetOrigin(0.0, 0.0);
    C.SetClip( C.SizeX, C.SizeY );
}

simulated function SetInstructionText( string text )
{
    InstructionText = text;
}

simulated function SetInstructionKeyText( string text )
{
    InstructionKeyText = text;
}

// amb ---
simulated function bool SameName(string nameA, string nameB) 
{
    local int i, j;

    i = InStr(nameA, " ");
    j = InStr(nameB, " ");
    
    if (i >= 0 && j >= 0)
    {
        nameA = Left(nameA, i);
        nameB = Left(nameB, j);
    }

    return (nameA ~= nameB);
}

simulated function DrawTargetPlayerName(Canvas C)
{
    local float sx, sy;
    local float dx, dy;
    local string newTarget;
    local color newColor;

    if (PlayerOwner.IsSharingScreen())
        return;

    if (PlayerOwner.PlayerNameArray.Length > 0)
    {
        newTarget = PlayerOwner.PlayerNameArray[0].mInfo;
        newColor = PlayerOwner.PlayerNameArray[0].mColor;
        PlayerOwner.PlayerNameArray.Remove(0, PlayerOwner.PlayerNameArray.Length);
    }

    if (TargetPlayerName == "" || 
        SameName(TargetPlayerName, newTarget) || 
        Level.TimeSeconds - TargetPlayerShowStartTime > 0.25f)
    {
        TargetPlayerName = newTarget;
        TargetPlayerShowStartTime = Level.TimeSeconds;
        TargetPlayerColor = newColor;
    }

    if (TargetPlayerName == "")
        return;

    C.DrawColor = TargetPlayerColor;
    C.Font = MessageFonts[1];
    C.TextSize( TargetPlayerName, dx, dy );

    sx = (TargetPlayerNameX * HudCanvasScale * C.ClipX) + (((1.0f - HudCanvasScale) * HudCanvasCenterX) * C.ClipX);
    sy = (TargetPlayerNameY * HudCanvasScale * C.ClipY) + (((1.0f - HudCanvasScale) * HudCanvasCenterY) * C.ClipY);

    sx -= dx * 0.5;
    sy -= dy * 0.5;

    C.SetPos(sx, sy);
    C.DrawTextClipped( TargetPlayerName );
}
// --- amb

simulated function DisplayMemStats(Canvas C)
{
    local string S;
    
    C.DrawColor.R = 0;
    C.DrawColor.G = 255;
    C.DrawColor.B = 0;
    C.DrawColor.A = 255;    
    C.Font = Font'Engine.FontSmall';   

    // get and display total amount of free memory remaining (in MB)
    S = ConsoleCommand("MEMSTAT1");
    C.SetPos(190,50);
    C.DrawText( S );

    C.DrawColor.R = 255;
    C.DrawColor.G = 255;
    C.DrawColor.B = 0;
    C.DrawColor.A = 255;    

    // get and display total amount of memory allocated for textures
    S = ConsoleCommand("MEMSTAT2");
    C.SetPos(190,90);
    C.DrawText( S );

    // get and display total amount of memory allocated for static meshes
    S = ConsoleCommand("MEMSTAT3");
    C.SetPos(190,110);
    C.DrawText( S );
    
    // get and display total amount of memory allocated for sounds    
    S = ConsoleCommand("MEMSTAT4");
    C.SetPos(190,130);
    C.DrawText( S );

    // get and display total amount of memory allocated for BSP
    S = ConsoleCommand("MEMSTAT5");
    C.SetPos(190,150);
    C.DrawText( S );

    C.DrawColor.R = 255;
    C.DrawColor.G = 0;
    C.DrawColor.B = 0;
    C.DrawColor.A = 255;    
    
    // get and display total amount of memory allocated for the level
    S = ConsoleCommand("MEMSTAT6");
    C.SetPos(190,190);
    C.DrawText( S );
}

defaultproperties
{
     ReticleScaleX=250.000000
     ReticleScaleY=450.000000
     InstructTextBorderX=10.000000
     InstructTextBorderY=10.000000
     CroppingAmount=0.250000
     LocalMessageFontScale=0.800000
     TargetPlayerNameX=0.500000
     TargetPlayerNameY=0.610000
     MessageFonts(0)=Font'Engine.FontMedium'
     MessageFonts(1)=Font'Engine.FontSmall'
     MessageFonts(2)=Font'Engine.FontMono'
     TargetMaterial(0)=TexRotator'InterfaceContent.Reticles.rOuterCircle'
     TargetMaterial(1)=TexRotator'InterfaceContent.Reticles.rMiddleCircle'
     TargetMaterial(2)=FinalBlend'InterfaceContent.Reticles.fbInnerCircle'
     HintTargetMaterial=TexRotator'InterfaceContent.Reticles.rOuterCircle'
     RocketTargetMaterial=FinalBlend'InterfaceContent.RocketReticleCog1.fbRockReticle'
     HealthAlertMaterial=FinalBlend'InterfaceContent.HUD.fbAlertPulse'
     HealthNormalMaterial=Texture'InterfaceContent.HUD.newHudTMP'
     bHudShowsTargetInfo=True
}
