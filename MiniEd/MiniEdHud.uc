class MiniEdHud extends HudFunctional
    exportstructs;

const COUNTER_ANIM_TIME = 1.0;
var bool bCounterAnimOn;
var float CounterAnimTimer;
var float CounterFontScaleX, CounterFontScaleY;

//var SpriteWidget HealthIcon;
var SpriteWidget PressStartIcon;

var() localized String StringPressStart;


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

var() bool DoCropping;
var() float CroppingAmount;
var() Material CroppingMaterial;

var() float TargetPlayerNameX;
var() float TargetPlayerNameY;
var() string TargetPlayerName;
var() float TargetPlayerShowStartTime;
var() color TargetPlayerColor;

// Derived HUDs override UpdateHud to update variables before rendering;
// NO draw code should be in derived DrawHud's; they should instead override 
// DrawHudPass[A-D] and call their base class' DrawHudPass[A-D] (This cuts
// down on render state changes).

simulated function UpdateHud(); 

//simulated function DrawHudPassA (Canvas C); // Alpha Pass
simulated function DrawHudPassB (Canvas C); // Alternate Texture Pass

simulated function DrawHud (Canvas C)
{
    Super.DrawHud (C);

    UpdateHud();

    PassStyle = STY_Alpha;
    DrawHudPassA (C);
    PassStyle = STY_None;
    DrawHudPassB (C);

    DisplayLocalMessages (C);
}


simulated function DrawHudPassA (Canvas C)
{
	local MiniEdController Controller;
	local Font SavedFont;
	
	Controller = MiniEdController(PlayerOwner);

	// If not editing
	if( Controller == None )
	{
		//The press start icon (when you are trying the map) that lets the user know how to get back to editing
		//Draw press start button
        if( IsOnConsole() )
        {
            DrawSpriteWidget( C, PressStartIcon );
        }

		//Draw press start text
		SavedFont = C.Font;
		C.Font = Font'Engine.FontSmall';
        if( IsOnConsole() )
        {
		    C.DrawScreenText( StringPressStart, 0.18, 0.82, DP_MiddleLeft );
        }
        else
        {
            C.DrawScreenText( StringPressStart, 0.08, 0.95, DP_MiddleLeft );
        }

		C.Font = SavedFont;
	}
}


simulated function Tick( float dt )
{
	if( bCounterAnimOn )
		UpdateCounterAnim( dt );
}


simulated function UpdateCounterAnim( float dt )
{
	CounterAnimTimer += dt;

	if( CounterAnimTimer > COUNTER_ANIM_TIME )
	{
		//Reset timer
		CounterAnimTimer = 0;
		bCounterAnimOn = false;
		CounterFontScaleX = 1.0;
		CounterFontScaleY = 1.0;
		return;
	}

	CounterFontScaleX = FakePIDResponse( 0.2, 0.2, 4.0*PI, 2.0, CounterAnimTimer );
	CounterFontScaleY = FakePIDResponse( 0.2, 0.2, 4.0*PI, 2.0, CounterAnimTimer );
}


simulated function DrawSpectatingHud(Canvas C)
{
    if (PlayerOwner.GetStateName() == 'PlayerWaiting' && PlayerOwner.Player.SplitIndex==0 )
    {
        if (PreGameOverlay != None)
            PreGameOverlay.DrawMenu (C, false);
        DisplayLocalMessages (C);
    }
    else
    {
        if (SpectatingOverlay != None)
            SpectatingOverlay.DrawMenu (C, false);
        DisplayLocalMessages (C);
    }
}

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
			Msg = PRI.RetrivePlayerName()@ "(" $ PRI.GetLocationName() $ "):"@ Msg;
			MessageClass = class'TeamSayMessagePlus';
			break;
		case 'CriticalEvent':
			MessageClass = class'CriticalEventPlus';
			LocalizedMessage( MessageClass, 0, None, None, None, Msg );
			return;
		case 'DeathMessage':
			MessageClass = class'xDeathMessage';
			break;
		default:
			MessageClass = class'StringMessagePlus';
			break;
	}

	AddTextMessage(Msg,MessageClass);
}
simulated function PulseCrosshair()
{
}
simulated function PulseAmmoIcon()
{
}
simulated function LocalizedMessage( class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject, optional String CriticalString)
{
	local int i;

    if( Message == None )
        return;

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

	if(ArrayCount(LocalMessages) > 0)
	{
		LocalMessages[i].Message = Message;
		LocalMessages[i].Switch = Switch;
		LocalMessages[i].RelatedPRI = RelatedPRI_1;
		LocalMessages[i].OptionalObject = OptionalObject;
		LocalMessages[i].EndOfLife = Message.static.GetLifetime(Switch) + Level.TimeSeconds;
		LocalMessages[i].StringMessage = CriticalString;
		LocalMessages[i].LifeTime = Message.static.GetLifetime(Switch);
	}
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
    Message.StringFont = MessageFonts[Clamp( FontSize, 0, ArrayCount(MessageFonts) - 1 )];

	Message.DrawColor = Message.Message.static.GetColor( Message.Switch );

    Message.Message.static.GetPos( Message.Switch, Message.DrawPivot, Message.StackMode, Message.PosX, Message.PosY );

    C.Font = Message.StringFont;

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

    if( !LocalMessages[i].Message.default.bFadeMessage )
		C.DrawColor = LocalMessages[i].DrawColor;
    else
	{
		FadeValue = (LocalMessages[i].EndOfLife - Level.TimeSeconds);
		C.DrawColor = LocalMessages[i].DrawColor;
		C.DrawColor.A = LocalMessages[i].DrawColor.A * (FadeValue/LocalMessages[i].LifeTime);
    }

	C.Font = LocalMessages[i].StringFont;

    GetScreenCoords( PosX, PosY, ScreenX, ScreenY, LocalMessages[i], C );
	C.SetPos( ScreenX, ScreenY );
	C.DrawTextClipped( LocalMessages[i].StringMessage );

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

	if((C.ClipX < 640) || (C.ClipY < 480))
		return;

	C.Reset();

/* Uncomment if you want to make sure messages are getting cleared properly
	for( i = 0; i < ArrayCount(LocalMessages); i++ )
	{
		if( LocalMessages[i].Message == None )
			break;
	}
	for( j = i; j < ArrayCount(LocalMessages); j++ )
	{
		assert( LocalMessages[j].Message == None );
	}
*/

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

function Draw2DLocationDot(Canvas C, vector Loc, float PosX, float PosY , int TeamIndex)
{
}

simulated function SetTargeting( bool bShow, optional Vector TargetLocation, optional float Size )
{
}

simulated function SetHintTarget( bool bShow, optional Vector TargetLocation, optional float Size )
{
}

simulated function SetCropping( bool Active )
{
    DoCropping = active;
}

simulated function DrawInstructionGfx(Canvas C)
{
}

simulated function DrawInstructionText(Canvas C)
{
}

simulated function DrawInstructionKeyText(Canvas C)
{
}

simulated function SetInstructionText( string text )
{
}

simulated function SetInstructionKeyText( string text )
{
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


simulated function DisplayMemStats(Canvas C)
{
    local string S;
    
    C.DrawColor.R = 0;
    C.DrawColor.G = 255;
    C.DrawColor.B = 0;
    C.DrawColor.A = 255;    
    C.Font = Font'Engine.FontMedium';   

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
     CroppingAmount=0.250000
     TargetPlayerNameX=0.500000
     TargetPlayerNameY=0.610000
     MessageFonts(0)=Font'Engine.FontMedium'
     MessageFonts(1)=Font'Engine.FontSmall'
     MessageFonts(2)=Font'Engine.FontMono'
     PressStartIcon=(WidgetTexture=Texture'MiniEdTextures.Buttons.Buttonstart',RenderStyle=STY_Alpha,TextureCoords=(X2=32,Y2=32),TextureScale=1.000000,DrawPivot=DP_MiddleMiddle,PosX=0.110000,PosY=0.850000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     StringPressStart="Press ESC to return to Editor"
}
