/*=============================================================================
	Copyright 2001 Digital Extremes. All Rights Reserved.

    There's a whole 'lotta magic ass in here.

    The following code is not yet supported:
        var() Array<SomeMenuWidget> MyWidgets;
        var() Array<int[30]> SomeIntArrays;
        FocusOnWidget for MenuStringList elements
        Default propagation down arrays of MenuButtonEnum.List members.

    The following code will probably crash:
        Emptying an array of widgets while one has focus (MenuStringList)

=============================================================================*/

class MenuBase extends Menu
    NoPropertySort
    exportstructs
    native;

#exec OBJ LOAD FILE=MenuSounds.uax
#exec OBJ LOAD FILE=InterfaceContent.utx

enum EMenuWidgetPlatform
{
    MWP_All,
    MWP_PC,
    MWP_Console, // Xbox + PS/2
    MWP_Xbox,
    MWP_PS2
};

enum EMoveDirection //used for layout mode (xmatt)
{
	MD_Left,
	MD_Right,
	MD_Up,
	MD_Down
};

struct long RenderBounds extends FloatBox
{
    var() float PosX, PosY;
};

struct long MenuWidgetBase // Abstract
{
    var() int Pass;
    var() int bHidden;
    var() EMenuWidgetPlatform Platform; // Defaults to MWP_All; can mask widgets from different platforms.
    var() int bLocked; // If bLocked only show this widget if !PlayerController(Owner).GetEntryLevel().game.bLocked 
    var() Name Style;
	var() RenderBounds Area; //In layout mode, the area that the widget takes (xmatt)
};

enum EMenuScaleMode
{
    MSM_Scale,      // Scale with respect to original texture size (1.0 leaves it the way it is)
    MSM_Stretch,    // Like MSM_Scale but splits texture and fill in gaps with a stretched area made of the middle texels
    MSM_Fit,        // Scale with respect to screen size: ScaleX is a percent of screen->sizeX, similar for ScaleY
    MSM_FitStretch, // Like MSM_Fit but splits texture and fill in gaps with a stretched area made of the middle texels
};

struct MenuSprite extends MenuWidgetBase
{
    var() Material WidgetTexture;
    var() IntBox TextureCoords;     // If 0,0,0,0 the whole texture is used

    var() ERenderStyle RenderStyle; // STY_Alpha is the default
    var() Color DrawColor;          // If 0,0,0,0 fully-opaque white is used

    var() EDrawPivot DrawPivot;     // Default is DP_UpperLeft
    var() float PosX, PosY;         // 0.0, 0.0 is upper-left 1.0, 1.0 is lower-right of the screen
    var() float ScaleX, ScaleY;     // Default is 1.0, 1.0

    var() float RotAngle;               // Degrees, Clockwise from 12-o'clock position.
    var() float RotPivotX, RotPivotY;

    var() EMenuScaleMode ScaleMode; // Default is MSM_Scale
    
    //xmatt: Allow corner dimensions to be specified
    //Reason: Brian and I want to make the UI look different. The first thing
    //		  we want to try is to allow the borders to be tiled and the middle
    //		  to be filled  

	var() Material	FillTexture;
	var() Material	BottomBorderTexture;
	var() Material	TopBorderTexture;
	var() Material	LeftBorderTexture;
	var() Material	RightBorderTexture;
	var() bool		TileFill;		// Should the fill texture be tiled
};

struct MenuText extends MenuWidgetBase
{
    var() Font MenuFont;
    var() localized String Text;

    var() ERenderStyle RenderStyle; // STY_Alpha is the default
    var() Color DrawColor;          // If 0,0,0,0 fully-opaque white is used

    var() EDrawPivot DrawPivot;     // Default is DP_UpperLeft
    var() float PosX, PosY;         // 0.0, 0.0 is upper-left 1.0, 1.0 is lower-right of the screen
    var() float ScaleX, ScaleY;     // Default is 1.0, 1.0
    
    var() int Kerning;              // Can be negative
    
    var() float MaxSizeX;           // 0 implies none.
    var() int bEllipsisOnLeft;
    var() int bNoFontRemapping;

    var() int bWordWrap;
	var() ETextAlign TextAlign;     // Only applied when MaxSizeX is specified; otherwise the DrawPivot is the anchor.
};

struct MenuDecoText extends MenuWidgetBase
{
    var() Font MenuFont;

    var() String TextName;

    var() ERenderStyle RenderStyle; // STY_Alpha is the default
    var() Color DrawColor;          // If 0,0,0,0 fully-opaque white is used

    // Draw pivot is always DP_UpperLeft
    var() float PosX, PosY;         // 0.0, 0.0 is upper-left 1.0, 1.0 is lower-right of the screen
    var() float ScaleX, ScaleY;     // Default is 1.0, 1.0

    var() int ColumnCount;
    var() int RowCount;

    var() float TimePerCharacter;
    var() float TimePerLineFeed;
    var() float TimePerLoopEnd;
    var() float TimePerCursorBlink;

    var() float CursorScale;
    var() float CursorOffset;

    var() int bCapitalizeText;
    var() int bPaused;

    var() transient DecoText Text;  // This is loaded from the INT entry specified by TextName

    var() transient float TickAccumulator;
    var() transient float BlinkAccumulator;

    var() transient int CurrentRow;
    var() transient int CurrentColumn;
    var() transient int bShowCursor;
};


struct MenuActiveWidget extends MenuWidgetBase
{
    var() RenderBounds ActiveArea;

    var() const int bHasFocus;
    var() const int bDrawFocused; // Will draw focused anyway; eg slider arrows will highlite the slider 
    var() int bDisabled;
    var() int bIgnoreController;
    var() int ContextID;

    var() localized String HelpText;

    var() Name OnFocus; // function [WidgetName]OnFocus( int ContextID );
    var() Name OnBlur; // function [WidgetName]OnBlur( int ContextID );

    var() Name OnSelect; // function [WidgetName]OnSelect( int ContextID );
    var() Name OnDoubleClick; // function [WidgetName]OnDoubleClick( int ContextID );

    // The following events can turn regular buttons into spinners. If they
    // are left as None the basic tab-order maneuvring code will kick in.

    var() Name OnLeft; // function [WidgetName]OnLeft( int ContextID );
    var() Name OnRight; // function [WidgetName]OnRight( int ContextID );
    var() Name OnUp; // function [WidgetName]OnUp( int ContextID );
    var() Name OnDown; // function [WidgetName]OnDown( int ContextID );
};

// In all cases, the Blurred widget will provided defaults for the focused version.
// That is, fill in the defaults for the Blurred version and override any you need
// to in the focused version.
//
// Copy order:
//
// Blurred -> Focused
// Blurred -> SelectedBlurred
// SelectedBlurred -> SelectedFocused
// BackgroundBlurred -> BackgroundFocused
// BackgroundFocused -> BackgroundSelected

struct MenuButton extends MenuActiveWidget // Abstract
{
    var() MenuSprite BackgroundBlurred, BackgroundFocused;
    var() int bRelativeBackgroundCoords;    // If set, Background PosX is Blurred.PosX + Background.PosX
};

struct MenuButtonSprite extends MenuButton
{
    var() MenuSprite Blurred, Focused;
};

struct MenuButtonText extends MenuButton
{
    var() MenuText Blurred;
    var() nonlocalized MenuText Focused;
};

struct MenuButtonEnum extends MenuButtonText
{
    var() localized Array<String> Items;
    var() int Current;
    var() int bNoWrap;
	var() int bNoSpin;
	
    var() Name OnChange; // function [WidgetName]OnChange( int ContextID );
};

struct MenuCheckBox extends MenuButton
{
    // To get RadioButton behaviour, set the Group variable.
    var() Name Group;
    var() const int bSelected;

    var() Name OnToggle; // function [WidgetName]OnToggle( int ContextID );
};

struct MenuCheckBoxSprite extends MenuCheckBox
{
    var() MenuSprite Blurred, Focused, SelectedBlurred, SelectedFocused;
};

struct MenuCheckBoxText extends MenuCheckBox
{
    var() MenuText Blurred;
    var() nonlocalized MenuText Focused, SelectedBlurred, SelectedFocused;
};

struct MenuSlider extends MenuButtonText
{
	// The part that moves (Do layout for "full", ScaleX will be adjusted at draw time):
	var() MenuSprite SliderBlurred, SliderFocused;
    var() int bRelativeSliderCoords; // If set, SliderBlurred.PosX is Blurred.PosX + SliderBlurred.PosX, etc

    // The first/last value (eg: Players: 1, 16):
	var() float MinValue; 
	var() float MaxValue; 

    // The sliding incremental change (right will add delta, left will subtract delta, eg 1 player at a time):
	var() float Delta;

    // The current value of the slider (eg: 4 players):
	var() float Value; 

    // If you don't want the slider to get scaled away to nothing, set this (ie: never make the bar less than 0.02 of the screen wide):
    var() float MinScaleX;

	var() Name OnSlide;
};

// This is basically a special-case slider/enum
struct MenuToggle extends MenuButtonText
{
    // This is drawn when the widget is toggled on:
	var() MenuSprite ToggledBlurred, ToggledFocused;
    var() int bRelativeToggleCoords; // If set, ToggleBlurred.PosX is Blurred.PosX + ToggledBlurred.PosX, etc

    var() localized String TextOff;
    var() localized String TextOn;
    
    var() int bValue;

	var() Name OnToggle;
};

enum EArrowDir
{
    AD_Left,
    AD_Right
};

struct MenuSliderArrow extends MenuButtonSprite
{
	var() Name WidgetName;
	var() EArrowDir ArrowDir;
};

enum MenuBoxFilterMode
{
    FM_Default,
    FM_None,
    FM_Alpha, // Allows only alphas
    FM_Numeric, // Allows only numerics
    FM_AlphaNumeric // Allows only numerics
};

// EditBoxes are really only useful on PC! They can be used on console but it SUCKS.
// OnSelect on PC gets called when they hit enter in an active EditBox;
//          on Console it gets called when they hit A on the focused EditBox.
struct MenuEditBox extends MenuButtonText
{
    var() int bNoSpaces; // Defaults to allow spaces
    var() MenuBoxFilterMode FilterMode;

    var() int MaxLength; // Defaults to 0 (no limit)
    var() int MinLength; // Defaults to 0

    var String TextBackup;

    var() float TimePerCursorBlink;
    var() float CursorScale;

    var() Name OnActivate;
    var() Name OnDeactivate;

    var() transient float BlinkAccumulator;
    var() transient int bShowCursor;
};

struct MenuBindingBox extends MenuButtonText
{
    var() MenuSprite BackgroundSelected;
    var() String Alias;
    var() Interactions.EInputKey Binding;
    var() int Priority; // 0 => Primary binding, 1 => Secondary, etc
};

struct MenuStringList extends MenuWidgetBase
{
    var() MenuButtonText Template;

    var() nonlocalized array<MenuButtonText> Items; // Must call LayoutMenuStringList when this changes

    var() float PosX1, PosY1;       // 0.0, 0.0 is upper-left 1.0, 1.0 is lower-right of the screen
    var() float PosX2, PosY2;       // 0.0, 0.0 is upper-left 1.0, 1.0 is lower-right of the screen
    var() int DisplayCount;
    var() int Position;
    
    var() Name OnScroll; // function [WidgetName]OnScroll( int ContextID );
};

struct MenuLayer extends MenuWidgetBase
{
    var() editinline MenuBase Layer;    // A MenuClassName will be spawned and assigned on first render if None.
    var() String MenuClassName;     // Done as a string to avoid loading classes we won't need.
};

struct MenuScrollBar extends MenuCheckBoxSprite
{
    var() int Position;
    var() int Length;
    var() int DisplayCount;
    
    var() float PosX1, PosY1, PosX2, PosY2;
    var() float MinScaleX, MinScaleY;
    var() Name OnScroll; // function [WidgetName]OnScroll( int ContextID );
    
    var() transient float ClickX, ClickY;
    
    // Natively cast to MenuActiveWidget*, assigned with LayoutMenuScrollBarEx.
    var() transient int PageUpArea, PageDownArea; 
};

struct MenuActorLight
{
    var() Vector Position;
    var() Color Color;
    var() float Radius;
};

struct MenuActor extends MenuWidgetBase
{
    var() editinline Actor Actor;
    var() float FOV;
    var() Array<MenuActorLight> Lights;
    var() byte AmbientGlow;
};

struct long MenuScrollArea extends MenuWidgetBase
{
    var() float X1, Y1, X2, Y2;    

    var() Name OnScrollTop;         // function [WidgetName]OnScrollTop();
    var() Name OnScrollPageUp;      // function [WidgetName]OnScrollPageUp();
    var() Name OnScrollLinesUp;     // function [WidgetName]OnScrollLineUp(int Lines);
    var() Name OnScrollLinesDown;   // function [WidgetName]OnScrollLineDown(int Lines);
    var() Name OnScrollPageDown;    // function [WidgetName]OnScrollPageDown();
    var() Name OnScrollBottom;      // function [WidgetName]OnScrollBottom();
    var() Name OnScrollKey;         // function [WidgetName]OnScrollKey( String Key );
};

enum ETransitionDir
{
    TD_None,
    TD_Out,
    TD_In,
};

struct FontMapping
{
    var int ResX, ResY;
    var Font OrigFont, DestFont;
    var float ScaleAdjustment;  
};

// To use these sexy bitchez you gotta make one in your MenuDefaults class and call it the style name;
// you can also put this structure in your local menu class but that is sloppy and ill-advised.
// Pass this name to the LayoutArray or LayoutWidgets and you're rockin. I would have made it pass the
// struct ref but UnrealScript sucks my ass and you can't pass structs from other objects to native funcs.

struct WidgetLayout
{
    var() float PosX;
    var() float PosY;
    var() float SpacingY;
    var() float BorderScaleX; // In Fit/FitStretch scale.
    var() EDrawPivot Pivot;
};

var private const int WidgetInFocus; // Natively cast to FMenuActiveWidget*
var private const int StructInFocus; // Natively cast to UStructProperty*

// Used to deferr focus until post-layout when we have proper mouse coords:
var private const int WidgetInAutoFocus; // Natively cast to FMenuActiveWidget*
var private const int StructInAutoFocus; // Natively cast to UStructProperty*

// Used to make edit boxes "lazily blur":
var private const int ActiveLazyBlurWidget; // Natively cast to FMenuActiveWidget*
var private const int ActiveLazyBlurStruct; // Natively cast to UStructProperty*

var() const transient float ResScaleX, ResScaleY;
var() const transient float NormalToScreenScaleX, NormalToScreenScaleY;
var() const transient float ScreenToNormalScaleX, ScreenToNormalScaleY;

var bool bDeferAutoFocus;
var bool bDeferAutoFocusMouseMove;

var() bool bAcceptInput;
var() float MouseRepeatDelayInitial;
var() float MouseRepeatDelaySubsequent;
var() transient float MouseRepeatDelayCurrent;

var() transient String KeyQueue;
var() float KeyQueueTimeout; // For using keys to jump down string lists

var() ETransitionDir CrossFadeDir;
var() float CrossFadeRate;
var() float CrossFadeLevel;
var() float CrossFadeMax; //Maximum brightness (xmatt)
var() float CrossFadeMin; //Minimum brightness (xmatt)

var() ETransitionDir ModulateDir;
var() float ModulateRate;
var() float ModulateLevel;
var() float ModulateMin;

var() Sound SoundTweenIn;
var() Sound SoundTweenOut;
var() Sound SoundOnFocus;
var() Sound SoundOnSelect;
var() Sound SoundOnError;

var() String ForceFeedbackOnFocus;

var() localized String StringYes;
var() localized String StringNo;
var() localized String StringOn;
var() localized String StringOff;
var() localized String StringOk;
var() localized String StringCancel;
var() localized String StringPercent;
var() localized String StringUnknown;
var() localized String StringContinue;
var() localized String StringNone;
var() localized String StringApply;

var() localized String StringOfficialCustomMap;

var() float DoubleClickTime;

var() bool bDynamicLayoutDirty;

var transient float ClickTime;
var transient int ClickWidget; // Natively cast to FMenuActiveWidget*

var transient float CanvasSizeX, CanvasSizeY;

var transient bool bHasFocus;

// More default stuff: here's the big picture:
//
// 1) Positions interpolated down arrays.
// 2) Other properties are copied down arrays.
// 3) Sub-widgets like Blurred & Focused are copied as described above.
// 3) Properties from the MenuDefaults blocks are copied.
// 4) Widgets are filled in with default values described above.
//
// Non-zero properties aren't overwritten; this is why you'll see some
// double-negative booleans, Vlad forgive me.

enum EHelpTextState
{
    HTS_InitialHidden,
    HTS_FadeUp,
    HTS_Show,
    HTS_FadeDown,
    HTS_Hidden,
};

var() MenuText HelpText;
var() EHelpTextState HelpTextState;
var() float HelpTextStateDelays[5]; // 0 - hidden, 1 - fade up, 2 - show, 3 - fade, 4 - end
var() float HelpTextOpacity;

var() bool DrawRenderBounds;
var() bool DrawScrollAreas;

// To simulate TV overscan region
var() MenuSprite OverscanWidgets[4];

var() String Args;

const SECONDS_PER_HOUR = 3600;
const SECONDS_PER_MINUTE = 60;

var() Array<string> ReservedNames;

enum EProfileState
{
    EPS_None,       // not initialized
    EPS_Default,    // profile is default, select existing or create new or use default if out of space
    EPS_Valid,      // profile is valid, but not loaded
    EPS_Loaded,     // profile is valid and loaded
    EPS_InUse,      // profile is valid and in use by another PlayerController (split-screen buddy)
    EPS_Corrupt,    // profile is corrupt
    EPS_Missing,    // profile is missing (last used user.ini is cached to util region/system dir)
};


//xmatt--
var bool bPositioning; //widgets can be cliked and moved
var bool bScaling; //widgets can be cliked and scaled
var private const int WidgetWeMove;
var array<Animator> Animators;

simulated function INT GetWidgetInFocus()
{
    return WidgetInFocus;
}

exec function uiposition()
{
	bPositioning = !bPositioning;
	if( bPositioning )
		log( "Toggling to gui positioning mode" );
}
exec function uiscale()
{
	bScaling = !bScaling;
	if( bScaling )
		log( "Toggling to gui scaling mode" );
}

exec function uisave()
{
	if( bPositioning || bScaling )
	{
		SaveUpdatedMenuBase();
	}
}
//--xmatt

exec function MenuEdit()
{
	ConsoleCommand("editactor class=menu");
}

exec function MenuDefaultsEdit()
{
	ConsoleCommand("editactor defaults class=menudefaults");
}

static simulated function String FormatTime( int Seconds )
{
    local int Minutes, Hours;
    local String Time;

    if( Seconds > SECONDS_PER_HOUR )
    {
        Hours = Seconds / SECONDS_PER_HOUR;
        Seconds -= Hours * SECONDS_PER_HOUR;

        Time = Time $ Hours $ ":";

        Minutes = Seconds / SECONDS_PER_MINUTE;
        Seconds -= Minutes * SECONDS_PER_MINUTE;

        if( Minutes >= 10 )
            Time = Time $ Minutes $ ":";
        else
            Time = Time $ "0" $ Minutes $ ":";
    
        if( Seconds >= 10 )
            Time = Time $ Seconds;
        else
            Time = Time $ "0" $ Seconds;
    
        return( Time );
    }
    else if( Seconds > SECONDS_PER_MINUTE )
    {
        Minutes = Seconds / SECONDS_PER_MINUTE;
        Seconds -= Minutes * SECONDS_PER_MINUTE;

        Time = Time $ Minutes $ ":";

        if( Seconds >= 10 )
            Time = Time $ Seconds;
        else
            Time = Time $ "0" $ Seconds;
    
        return( Time );
    }
    else
    {
        if( Seconds >= 10 )
            Time = "0:" $ Seconds;
        else
            Time = "0:0" $ Seconds;
    
        return( Time );
    }
}

static simulated function String FormatFloat( float f )
{
    local int Truncated;
    local int Whole;
    local int Fractional;
    local String Text;

    if( f < 0 )
    {
        Text = "-";
        f = -f;
    }

    Truncated = f * 100.0f;

    Whole = Truncated / 100;

    Fractional = Truncated - (Whole * 100);

    if( Fractional >= 10 )
        return( Text $ Whole $"."$Fractional );
    else
        return( Text $ Whole $"."$Fractional$"0" );
}


/*
	GrabDelimited
	Desc:
		In a string of the form "[delimiter]key1=value1[delimiter]key2=value2...",
		get the first key/value pair by providing the delimiter
	Params:
		- Input:	Input string
		- Result:	The key/value pair
		- Delim:	Delimiter
	Return:
		False if there is no more key / value pair
	xmatt
*/
static simulated function bool GrabDelimited( out string Input, out string Result, String Delim )
{
    if( Left(Input,1) == Delim )
    {
        // Get result.
        Result = Mid(Input,1);
        if( InStr(Result,Delim) >= 0 )
            Result = Left( Result, InStr(Result,Delim) );

        // Update options.
        Input = Mid(Input,1);
        if( InStr(Input,Delim)>=0 )
            Input = Mid( Input, InStr(Input,Delim) );
        else
            Input = "";

        return true;
    }
    else return false;
}


static function GetKeyValue( string Pair, out string Key, out string Value )
{
    if( InStr(Pair,"=")>=0 )
    {
        Key   = Left(Pair,InStr(Pair,"="));
        Value = Mid(Pair,InStr(Pair,"=")+1);
    }
    else
    {
        Key   = Pair;
        Value = "";
    }
}


/*
	GetValue
	Desc:
		In a string of the form "key1=value1[delimiter]key2=value2[delimiter]...",
		Get valueX by passing keyX.

	Params:
		- Input:	Input string
		- InKey:	Key linked to the value you want
		- Delim:	The delimiter used in the input string

	Return:
		The value attached to the key
	xmatt
*/
static simulated function String GetValue( string Input, string InKey, string Delim )
{
    local string Pair, Key, Value;
    while( GrabDelimited( Input, Pair, Delim ) )
    {
        GetKeyValue( Pair, Key, Value );
        if( Key ~= InKey )
            return Value;
    }
    return "";
}


static simulated function int CountOccurances( String Text, String SubText )
{
    local int i;
    local int Count;
    
	i = InStr( Text, SubText );
	
	while( i >= 0 )
	{
		Text = Left( Text, i ) $ Mid( Text, i+Len(SubText) );
	    i = InStr( Text, SubText );
	    ++Count;
	}
	
	return Count;
}

static simulated function String ParseToken(out String Str)
{
    local String Ret;
    local int len;

    Ret = "";
    len = 0;

	// Skip spaces and tabs.
	while( Left(Str,1)==" " || Asc(Left(Str,1))==9 )
		Str = Mid(Str, 1);

	if( Asc(Left(Str,1)) == 34 )
	{
		// Get quoted String.
		Str = Mid(Str, 1);
		while( Str!="" && Asc(Left(Str,1))!=34 )
		{
			Ret = Ret $ Mid(Str,0,1);
            Str = Mid(Str, 1);
		}
		if( Asc(Left(Str,1))==34 )
			Str = Mid(Str, 1);
	}
	else
	{
		// Get unquoted String.
		for( len=0; (Str!="" && Left(Str,1)!=" " && Asc(Left(Str,1))!=9); Str = Mid(Str, 1) )
            Ret = Ret $ Mid(Str,0,1);
	}

	return Ret;
}

simulated function Init( String A )
{
    Args = A;
}

native simulated event DrawMenu( Canvas C, bool HasFocus );

simulated event PostEditChange()
{
    bDynamicLayoutDirty = true;
}

simulated event DoDynamicLayout( Canvas C ); // called if bDynamicLayoutDirty before draw.

simulated function Plane GetModulationColor()
{
    local Plane C;

    C.X = ModulateLevel;
    C.Y = ModulateLevel;
    C.Z = ModulateLevel;
    C.W = CrossFadeLevel;

    return( C );
}

simulated function bool IsVisible()
{
    return( (CrossFadeDir != TD_None) || (CrossFadeLevel != 0.0) );
}

native simulated function HandleInputLeft();
native simulated function HandleInputRight();
native simulated function HandleInputUp();
native simulated function HandleInputDown();
native simulated function UpdateLayingOut( EMoveDirection Dir, bool bPositioning, bool bScaling );

simulated function InputLeft()
{
	// log( "InputLeft" );

	if( !bAcceptInput )
		return;

	//If in layout mode
	if( (bPositioning || bScaling) && WidgetWeMove != 0 )
		UpdateLayingOut( MD_Left, bPositioning, bScaling );

	//Otherwise handle as usual
	else
		HandleInputLeft();
}


simulated function InputRight()
{
	// log( "InputRight" );

	if( !bAcceptInput )
		return;

	//If in layout mode
	if( (bPositioning || bScaling) && WidgetWeMove != 0 )
		UpdateLayingOut( MD_Right, bPositioning, bScaling );

	//Otherwise handle as usual
	else
		HandleInputRight();
}


simulated function InputUp()
{
	// log( "InputUp" );

	if( !bAcceptInput )
		return;

	//If in layout mode
	if( (bPositioning || bScaling) && WidgetWeMove != 0 )
		UpdateLayingOut( MD_Up, bPositioning, bScaling );

	//Otherwise handle as usual
	else
		HandleInputUp();
}


simulated function InputDown()
{
	// log( "InputDown" );

	if( !bAcceptInput )
		return;

	//If in layout mode
	if( (bPositioning || bScaling) && WidgetWeMove != 0 )
		UpdateLayingOut( MD_Down, bPositioning, bScaling );

	//Otherwise handle as usual
	else
		HandleInputDown();
}


native simulated function HandleInputSelect();
native simulated function HandleInputStart();
native simulated function HandleInputBack();
native simulated function bool HandleInputKey( Interactions.EInputKey Key );
native simulated function bool HandleInputKeyRaw(Interactions.EInputKey Key, Interactions.EInputAction Action);
native simulated function FindDoubleClickedWidget();

native simulated function SetMousePos( float X, float Y );

simulated function InputMouseDown()
{
	if( !bAcceptInput )
		return;

	//If in layout mode
	if( bPositioning || bScaling )
		FindDoubleClickedWidget();

	//Otherwise handle as usual
	else
		HandleInputMouseDown();
}


simulated function InputMouseUp()
{
	// log( "InputMouseUp" );

	if( !bAcceptInput )
		return;

	//If in layout mode
	if( bPositioning || bScaling )
		return;

	HandleInputMouseUp();
}


native simulated function HandleInputMouseDown();
native simulated function HandleInputMouseUp();


native simulated function HandleInputMouseMove();
native simulated function bool HandleInputWheelUp( int Clicks );
native simulated function bool HandleInputWheelDown( int Clicks );

native simulated function FocusOnNothing();
native simulated function ResetFocus();	//xmatt: use if there is no item left in the array of text buttons,
										//		 it gets around the lack of support of deleting all widgets
										//		 while one has focus (see note in header of this class)
native simulated function FocusOnWidget( MenuActiveWidget Widget );
native simulated function SelectWidget( MenuActiveWidget Widget );
native simulated function DeSelectCheckbox( MenuCheckBox Checkbox );

native simulated function LayoutMenuStringList( MenuStringList StringList );
native simulated function LayoutMenuDecoText( MenuDecoText DecoText );
native simulated function LayoutMenuScrollBar( MenuScrollBar MenuScrollBar );
native simulated function LayoutMenuScrollBarEx( MenuScrollBar MenuScrollBar, MenuActiveWidget PageUpArea, MenuActiveWidget PageDownArea );

native simulated function float GetDecoTextTime( MenuDecoText mdt );

native simulated function float GetWrappedTextHeight( Canvas C, MenuText MenuText );

native simulated function GetMenuTextSize( Canvas C, MenuText TextWidget, out float DX, out float DY );
native simulated function GetMenuSpriteSize( Canvas C, MenuSprite SpriteWidget, out float DX, out float DY );

native simulated event GotoMenu( Menu InTravelMenu, optional String Args );
native simulated event CallMenu( Menu InTravelMenu, optional String Args );
native simulated event CloseMenu();

simulated event DecoTextComplete();

native simulated function LayoutArray( out MenuWidgetBase ArrayOfWidgets, Name LayoutStyle );
native simulated function LayoutWidgets( out MenuWidgetBase First, out MenuWidgetBase Last, Name LayoutStyle );
native simulated function FitBorderBoxToArray( out MenuSprite BorderBox, out MenuWidgetBase ArrayOfWidgets, Name LayoutStyle );
native simulated function FitBorderBoxToWidgets( out MenuSprite BorderBox, out MenuWidgetBase First, out MenuWidgetBase Last, Name LayoutStyle );

native simulated function SetVisible( Name OnSelect, bool visible );

function ClientPlayForceFeedback( String EffectName )
{
    local PlayerController PC;
    PC = GetPlayerOwner();
    if( (PC != None) && PC.bEnableGUIForceFeedback )
        PC.ClientPlayForceFeedback( EffectName );
}

simulated event OnFocusChange()
{
    if( LastInputSource != IS_Mouse )
    {
        PlayMenuSound( SoundOnFocus );
    }
}

simulated event OnSelectionChange()
{
    local PlayerController PC;

    if( SoundOnSelect == None )
        return;

    PC = PlayerController( Owner );
    assert( PC != None );
    PC.PlayBeepSound(SoundOnSelect);
}

simulated function ChildAnimEnd( Actor A, int i );

static simulated function String ParseOption( String Options, String InKey )
{
    return( class'GameInfo'.static.ParseOption( Options, InKey ) );
}

// workers
function PlayerController GetPlayerOwner()
{
    return PlayerController(Owner);
}

function Actor GetPersistSpawner() // todo: entry's levelinfo used to serve this purpose
{
    return self;//PlayerController(Owner);
}

simulated function AddListItem( out MenuStringList msl, String s, int context )
{
    local int i;

    i = msl.Items.Length;
    msl.Items[i].Focused.Text = s;
    msl.Items[i].Blurred.Text = s;
    msl.Items[i].ContextID = context;
}

simulated function String GetSelectedListItem( out MenuStringList msl )
{
    local int i;
    for( i=0; i<msl.Items.Length; i++ )
    {
        if( msl.Items[i].bHasFocus == 1 )
            return msl.Items[i].Focused.Text;
    }
    return "";
}

simulated function DoNothing();

simulated function SetupActor(out Actor playerActor, out Actor weaponActor, String charName, String weapName, vector actorPos, rotator actorRot, optional float size)
{
    local xUtil.PlayerRecord PlayerRecord;
    local Mesh m;
    local StaticMesh sm;
    local xUtil.WeaponRecord wRec;
    local class<Actor> menuSkelMeshActor;
    local class<Actor> menuStatMeshActor;

    assert( charName != "" );
    PlayerRecord = class'xUtil'.static.FindPlayerRecord( charName );
    assert( PlayerRecord.MeshName != "" );

    m = Mesh( DynamicLoadObject( PlayerRecord.MeshName, class'Mesh' ) );
    if( m == None )
    {
        log("Could not load mesh " $ PlayerRecord.MeshName, 'Error');
        return;
    }
    
    menuSkelMeshActor = class<Actor>(DynamicLoadObject("XInterface.MenuActorSkeletalMesh", class'Class'));
    playerActor = Spawn( menuSkelMeshActor, self,, actorPos, actorRot );
    assert( playerActor != None );


    playerActor.LinkMesh( m );
    playerActor.SetSkin(0, Material(DynamicLoadObject(PlayerRecord.BodySkinName, class'Material')));
    playerActor.SetSkin(1, Material(DynamicLoadObject(PlayerRecord.FaceSkinName, class'Material')));
    playerActor.Style = STY_AlphaZ;

    if (size > 0.0 )
        playerActor.SetDrawScale( size );

    menuStatMeshActor = class<Actor>(DynamicLoadObject("XInterface.MenuActorStaticMesh", class'Class'));
    weaponActor = Spawn( menuStatMeshActor, playerActor );
    assert( weaponActor != None );

    if( weapName == "" )
        weapName = PlayerRecord.WepAffinity.WepString;

    wRec = class'xUtil'.static.FindWeaponRecord(weapName);
    sm = StaticMesh(DynamicLoadObject(wRec.AttachmentMeshName, class'StaticMesh'));

    weaponActor.SetStaticMesh(sm);
    
    if (size > 0.0 )
        weaponActor.SetDrawScale( wRec.AttachmentDrawScale*size );
    else
        weaponActor.SetDrawScale( wRec.AttachmentDrawScale );

    weaponActor.bHidden = false;

    if( !playerActor.AttachToBone( weaponActor, 'righthand' ) )
        log( "Couldn't attach weapon!", 'Error' );

    playerActor.LoopAnim( 'idle_rest' );
}

simulated function UpdateActor(out Actor playerActor, out Actor weaponActor, String charName, String weapName )
{
    local xUtil.PlayerRecord PlayerRecord;
    local xUtil.WeaponRecord wRec;
    local Mesh m;
    local StaticMesh sm;

    if( charName == "" )
        return;

    PlayerRecord = class'xUtil'.static.FindPlayerRecord( charName );
    assert( PlayerRecord.MeshName != "" );

    m = Mesh( DynamicLoadObject( PlayerRecord.MeshName, class'Mesh' ) );
    assert( m != None );
    
    playerActor.LinkMesh( m );
    playerActor.SetSkin(0, Material(DynamicLoadObject(PlayerRecord.BodySkinName, class'Material')));
    playerActor.SetSkin(1, Material(DynamicLoadObject(PlayerRecord.FaceSkinName, class'Material')));

    if( weapName == "" )
        weapName = PlayerRecord.WepAffinity.WepString;

    wRec = class'xUtil'.static.FindWeaponRecord(weapName);
    sm = StaticMesh(DynamicLoadObject(wRec.AttachmentMeshName, class'StaticMesh'));

    weaponActor.SetStaticMesh(sm);

    if( !playerActor.AttachToBone( weaponActor, 'righthand' ) )
        log( "Couldn't attach weapon!", 'Error' );

    playerActor.LoopAnim( 'idle_rest' );
}

simulated exec function Menu( String Command )
{
	local int i;
	local string s;

    if( Command ~= "renderbounds" )
        DrawRenderBounds = !DrawRenderBounds;
    else if( Command ~= "scrollarea" )
        DrawScrollAreas = !DrawScrollAreas;
    else if( Command ~= "overscan" )
    {
		if( OverscanWidgets[i].bHidden == 0 )
		{
			for( i = 0; i < ArrayCount(OverscanWidgets); i++ )
				OverscanWidgets[i].bHidden = 1;
		}
		else
		{
			for( i = 0; i < ArrayCount(OverscanWidgets); i++ )
				OverscanWidgets[i].bHidden = 0;
				
			// Left bar    
			OverscanWidgets[0].ScaleX = (1.f - 0.93f) * 0.5f;

			// Right bar    
			OverscanWidgets[1].ScaleX = (1.f - 0.93f) * 0.5f;

			// Top bar    
			OverscanWidgets[2].ScaleY = (1.f - 0.85f) * 0.5f;

			// Bottom bar    
			OverscanWidgets[3].ScaleY = (1.f - 0.85f) * 0.5f;
		}
    }
    else if( Command ~= "test" )
    {
        Assert( ReplaceSubstring("<Gamertag> is fat", "<GAMERTAG>", "Glen") == "Glen is fat" );
        Assert( ReplaceSubstring("<GAMERTAG> is fat", "<gamertag>", "Glen") == "Glen is fat" );
     
        s = "<Gamertag> is fat";
        Assert( UpdateTextField(s, "<GAMERTAG>", "Glen") );
        Assert( s == "Glen is fat" );
     
        s = "<GAMERTAG> is fat";
        Assert( UpdateTextField(s, "<gamertag>", "Glen") );
        Assert( s == "Glen is fat" );
     
        log("All tests passed.", 'Log');
    }
}

// TODO: combine with normal version post big smash
simulated function MenuBase CallMenuClassEx( String MenuClassName, optional String Args )
{
    local MenuBase m;
	assert(MenuClassName!="");
	m = Spawn( class<MenuBase>( DynamicLoadObject( MenuClassName, class'Class' ) ), Owner );
    CallMenu( m, Args );
    return( m );
}

simulated function CallMenuClass( String MenuClassName, optional String Args )
{
	assert(MenuClassName!="");
    CallMenu( Spawn( class<Menu>( DynamicLoadObject( MenuClassName, class'Class' ) ), Owner ), Args );
}

simulated function GotoMenuClass( String MenuClassName, optional String Args )
{
	assert(MenuClassName!="");
    GotoMenu( Spawn( class<Menu>( DynamicLoadObject( MenuClassName, class'Class' ) ), Owner ), Args );
}

static simulated function string MakeQuotedString( string in )
{
    return "\""$in$"\"";
}

native final function EMenuWidgetPlatform GetPlatform();

simulated function SetPositionSprite( out MenuSprite w, float x, float y )
{
    w.PosX = x;
    w.PosY = y;
}

simulated function SetPositionEditBox( out MenuEditBox w, float x, float y )
{
    w.Blurred.PosX = x;
    w.Focused.PosX = x;
    w.BackgroundBlurred.PosX = x;
    w.BackgroundFocused.PosX = x;

    w.Blurred.PosY = y;
    w.Focused.PosY = y;
    w.BackgroundBlurred.PosY = y;
    w.BackgroundFocused.PosY = y;
}

simulated function SetPositionButtonText( out MenuButtonText w, float x, float y )
{
    w.Blurred.PosX = x;
    w.Focused.PosX = x;
    w.BackgroundBlurred.PosX = x;
    w.BackgroundFocused.PosX = x;

    w.Blurred.PosY = y;
    w.Focused.PosY = y;
    w.BackgroundBlurred.PosY = y;
    w.BackgroundFocused.PosY = y;
}

native simulated function SetPositionButtonSprite( out MenuButtonSprite w, float x, float y );

simulated function SetPositionButtonEnum( out MenuButtonEnum w, float x, float y )
{
    w.Blurred.PosX = x;
    w.Focused.PosX = x;
    w.BackgroundBlurred.PosX = x;
    w.BackgroundFocused.PosX = x;

    w.Blurred.PosY = y;
    w.Focused.PosY = y;
    w.BackgroundBlurred.PosY = y;
    w.BackgroundFocused.PosY = y;
}

native simulated function SetPositionCheckbox( out MenuCheckboxSprite W, float PosX, float PosY );

simulated function SetVisibilityCheckbox( out MenuCheckboxSprite W, bool bVisible )
{
	local int Hidden;
	
	if( !bVisible )
		Hidden = 1;
		
	W.BackgroundBlurred.bHidden = Hidden;
	W.BackgroundFocused.bHidden = Hidden;
	W.Blurred.bHidden = Hidden;
	W.Focused.bHidden = Hidden;
	W.SelectedBlurred.bHidden = Hidden;
	W.SelectedFocused.bHidden = Hidden;
}

native simulated function SetVisibilityButtonSprite( out MenuButtonSprite W, bool bVisible );

simulated function string AppendGamePadIndexIfSplit()
{
    local PlayerController pc;
    pc = PlayerController(Owner);
    if(pc.IsSharingScreen())
    {
        return("GAMEPADINDEX=" $ pc.Player.GamePadIndex);
    }
    return("");
}

simulated function string LoadSaveCommand(string cmd, optional string opts)
{
    return ConsoleCommand("LOADSAVE" @ cmd @ opts @ AppendGamePadIndexIfSplit());
}

simulated function UpdatePlayerProfile()
{
    //StopWatch();
    if(!bool(LoadSaveCommand("UPDATE_PLAYER_PROFILE")))
    {
        warn("Cannot update player profile");
    }
    //StopWatch("UPDATE_PLAYER_PROFILE", true);
}

simulated function UpdateDecoField(out MenuDecoText decoText, string marker, string info)
{
    local int Row;
    for (Row=0; Row<decoText.Text.Rows.Length; Row++)
        if (UpdateTextField(decoText.Text.Rows[Row], marker, info))
            return;
}

simulated function OverlayErrorMessageBox( String OperationName )
{
    CallMenuClass( "XInterfaceLive.MenuLiveErrorMessage", OperationName );
}

simulated function string GetPlayerName()
{
    return LoadSaveCommand("PROFILE GET_CURRENT_PLAYER");
}

simulated function PlayDefaultCharacterName(string charName)
{
    local Sound s;
    s = Sound(DynamicLoadObject("PlayerNames."$charName, class'Sound'));
    PlaySound(s, SLOT_Talk, 1.0);
}

simulated function string CheckName(string inName, bool continueWithoutSaving)
{
    return
    (
        LoadSaveCommand
        (
            "CHECK_NAME NAME=" $ inName @ 
            "CONTINUE_WITHOUT_SAVING=" $ int(continueWithoutSaving)
        )
    );
}

simulated function GetProfileList( out Array<string> Profiles )
{
    local string profileNames;
    local int cnt;
    local int index;
    local int isSharing;

    Profiles.Length = 0;
    
    if (PlayerController(Owner).IsSharingScreen())
        isSharing = 1;

    profileNames = LoadSaveCommand("LIST_SAVES", "UNIQUE="$isSharing);

    if (profileNames == "")
        return;

    do
    {
        index = InStr(profileNames, ",");
        if (index < 0)
        {
            Profiles[cnt] = profileNames;
            break;
        }
        
        Profiles[cnt++] = Left(profileNames, index);
        ProfileNames = Right(profileNames, Len(ProfileNames) - index - 1);
    }
    until (false);
}

static function bool NameIsReserved( string Name )
{
    local int i;
    
    for(i = 0; i < default.ReservedNames.Length; ++i)
    {
        if( Name ~= default.ReservedNames[i] )
        {
            return(true);
        }
    }

    return(false);
}

simulated function EProfileState GetProfileState(string profileName)
{
    local EProfileState profileState;
    
    if(NameIsReserved(profileName))
    {
        return(EPS_Default);
    }

    switch(ConsoleCommand("LOADSAVE GET_STATE NAME="$profileName))
    {
        case "LOADED":
            profileState = EPS_Loaded;
            break;
            
        case "INUSE":
            profileState = EPS_InUse;
            break;
            
        case "VALID":
            profileState = EPS_Valid;
            break;
            
        case "CORRUPT":
            profileState = EPS_Corrupt;
            break;
            
        case "MISSING":
            profileState = EPS_Missing;
            break;
            
        default:
            assert(false);            
    }
    
    return(profileState);
}

simulated function bool LowStorage()
{
    return(int(LoadSaveCommand("SPACE_FREE")) < int(LoadSaveCommand("SPACE_NEEDED")));
}

simulated function string EditNameMenuClass()
{
    if(IsOnConsole())
    {
        return("XInterfaceCommon.MenuProfileEditNameConsole");
    }
    else
    {
        return("XInterfaceCommon.MenuProfileEditNamePC");
    }
}

native simulated function PlayMenuSound( Sound S, optional float Volume, optional float Pitch );

/*
	PlayLoopingSound
	Desc: This plays a sound that loops. There is condition on whether or its audibility.
	Note: I will use it in the minied to make a sound as long as the user levels the terrain (xmatt)
*/
native simulated function PlayLoopingSound( Sound s, optional ESoundSlot Slot, optional float Volume );

//  Plays the ambient sound on the ambient sound actors
native simulated function PlayAmbientSound( Sound s, optional int Volume );

//  Sets ambient sound on ambient sound actors to NULL
native simulated function StopAmbientSound( );

/*
	StopSound (xmatt)
	Desc: This stops a sound without condition.
	Note: I will use it in the minied to stop a sound the terrain leveling sound when the user stops using the tool
*/
native simulated function StopSound( Sound s );


/*
	SaveUpdatedMenuBase (xmatt)
	Desc: This saves the changes made to the layout
	Note: only position data for 3 types of widget for now
*/
native simulated function SaveUpdatedMenuBase();


native simulated function GetVideoValues(out float Brightness, out float Contrast, out float Gamma);


/*
	InitSlider (xmatt)
	Desc: To setup a slider
*/
simulated function InitSlider( out MenuSlider S, float X, float Y, float ScaleX, float ScaleY, float MinValue, float MaxValue, float Value )
{
    S.Value     = Value;
    S.MinScaleX = 0.015;
	S.MinValue  = MinValue;
	S.MaxValue  = MaxValue;
    S.Delta     = 10;

	S.Blurred.PosX=X;
	S.Blurred.PosY=Y;
	S.Focused.PosX=X;
	S.Focused.PosY=Y;
	
	S.SliderBlurred.ScaleX = ScaleX;
	S.SliderBlurred.ScaleY = ScaleY;
	S.SliderBlurred.ScaleX = ScaleX;
	S.SliderBlurred.ScaleY = ScaleY;

	S.BackgroundBlurred.ScaleX = ScaleX;
	S.BackgroundBlurred.ScaleY = ScaleY;

	S.bRelativeBackgroundCoords=1;
	S.bRelativeSliderCoords=1;
}


/*
	InitCheckboxButtonSprite (xmatt)
	Desc: To setup a checkbox button sprite
*/
native simulated function InitCheckboxButtonSprite( out MenuCheckBoxSprite S, float PosX, float PosY, float ScaleX, float ScaleY, Material M, Name Group );


/*
	InitMenuButtonText
	Desc: To setup a menu button text
	xmatt
*/
simulated function InitMenuButtonText(  out MenuButtonText S, string Text,
										float PosX, float PosY,
										float ScaleX, float ScaleY, float TextScaleX, float TextScaleY )
{
	S.BackgroundBlurred.bHidden = 0;
	S.BackgroundFocused.bHidden = 0;
	S.Blurred.bHidden = 0;
	S.Focused.bHidden = 0;
	
	S.BackgroundBlurred.PosX = PosX;
	S.BackgroundBlurred.PosY = PosY;
	S.BackgroundBlurred.ScaleX = ScaleX;
	S.BackgroundBlurred.ScaleY = ScaleY;
	S.BackgroundBlurred.WidgetTexture = Material'InterfaceContent.Menu.BorderBoxD';
	S.BackgroundBlurred.ScaleMode = MSM_FitStretch;
	S.BackgroundBlurred.DrawPivot = DP_MiddleMiddle;

	S.BackgroundFocused.PosX = PosX;
	S.BackgroundFocused.PosY = PosY;
	S.BackgroundFocused.ScaleX = ScaleX;
	S.BackgroundFocused.ScaleY = ScaleY;
	S.BackgroundFocused.WidgetTexture = Material'InterfaceContent.Menu.ButtonBigPulse2';
	S.BackgroundFocused.ScaleMode = MSM_FitStretch;
	S.BackgroundFocused.DrawPivot = DP_MiddleMiddle;

	S.Blurred.PosX = PosX;
	S.Blurred.PosY = PosY;
	S.Blurred.ScaleX = TextScaleX;
	S.Blurred.ScaleY = TextScaleY;
	S.Blurred.DrawPivot = DP_MiddleMiddle;
	S.Blurred.Style = 'LabelText';

	S.Focused.PosX = PosX;
	S.Focused.PosY = PosY;
	S.Focused.ScaleX = TextScaleX;
	S.Focused.ScaleY = TextScaleY;
	S.Focused.DrawPivot = DP_MiddleMiddle;
	S.Focused.Style = 'LabelText';
	
	S.Blurred.Text = Text;
}


/*
	InitMenuButtonSprite (ksue)
	Desc: To setup a menu button sprite
*/
native simulated function InitMenuButtonSprite( out MenuButtonSprite S, float PosX, float PosY, float ScaleX, float ScaleY, Material M );

/*
	MakeDropDown
	Desc: Makes a menu animator that can move widgets in a direction
	xmatt
*/
native simulated function MakeDropDown( int Id, bool bExpand, float TimeBetweenUnveils );

/*
	MakeTranslator
	Desc: Makes a menu animator that can move widgets in a direction
	xmatt
*/
native simulated function MakeTranslator( int Id, EMoveDirection Dir, float AnimTime, float Delta );

/*
	MakeDrawer
	Desc: Makes a menu animator that can move widgets in a direction and back
	xmatt
*/
native simulated function MakeDrawer( int Id, EMoveDirection Dir, float AnimTime, float Delta );

/*
	MakePulsator
	Desc: Makes a menu animator that can pulsate widgets
	xmatt
*/
native simulated function MakePulsator( int Id, float Speed, float Scale );

/*
	AddToAnimator
	Desc: Adds a widget to the last created animator
	xmatt
*/
native simulated function AddToAnimator( out MenuWidgetBase WidgetToAnimate );

/*
	AddToPulsator
	Desc: Adds a widget to the last created animator which must me a pulsator
	xmatt
*/
native simulated function AddToPulsator( out MenuWidgetBase WidgetToAnimate );

/*
	MoveAnimatedTo
	Desc: Moves the widgets inside the last created animator to a position
	xmatt
*/
native simulated function MoveAnimatedTo( float X, float Y );

/*
	MoveAnimatedDir
	Desc: Moves the widgets inside the last created animator by an amount
	xmatt
*/
native simulated function MoveAnimatedDir( EMoveDirection Dir, float Delta );

/*
	KillAnimator
	Desc: Kill an animator
	Params:
			Id	-	Id of the animator you want to kill
	xmatt
*/
native simulated function KillAnimator( int Id );

/*
	KillPulsator
	Desc: Kill a pulsator
	Params:
			Id	-	Id of the pulsator you want to kill
	xmatt
*/
native simulated function KillPulsator( int Id );

/*
	AnimatorDone
	Desc: Event called when an animator is done with his job
	xmatt
*/
event AnimatorDone( int Id );

native simulated function ProfileData   GetProfileData();
native simulated function Manifest      GetManifest();
native simulated function name          ToName(string s);
native simulated function bool          Callback(name callbackFunc, Object callbackObject);


simulated function bool MiniEdMapIsLoaded()
{
    return( ConsoleCommand("MINIED MAP_IS_LOADED") == "TRUE" );
}

simulated function bool MiniEdMapIsDirty()
{
    return( ConsoleCommand("MINIED MAP_IS_DIRTY") == "TRUE" );
}

// A map is "Live" if it was Live and user was signed-in when it was loaded (so its Live signature
// could be verified). The user can load an Live map while offline but would not be considered Live
// in this case, EVEN IF THEY PROCEDED TO SIGN INTO LIVE.

simulated function bool MiniEdMapIsLive()
{
    return( ConsoleCommand("MINIED MAP_IS_LIVE") == "TRUE" );
}

simulated function bool MiniEdMapWasLive()
{
    return( ConsoleCommand("MINIED MAP_WAS_LIVE") == "TRUE" );
}

simulated function String MiniEdGetCustomMapShort()
{
    return( ConsoleCommand("MINIED GET_CUSTOM_MAP_SHORT") );
}

simulated function String MiniEdGetCustomMapGamerTag()
{
    return( ConsoleCommand("MINIED GET_GAMER_TAG") );
}

simulated function String MiniEdGetCustomMapGameType()
{
    return( ConsoleCommand("MINIED GET_GAME_TYPE") );
}

// XDM-ShitBag?custommap=DM-WangPull@shaggie76 -> DM-WangPull@shaggie76
static native simulated function String GetCustomMapName( String MapName );

// XDM-ShitBag?custommap=DM-WangPull@shaggie76 -> XDM-ShitBag
static native simulated function String BaseMapName( String MapName );

// DM-ShitBag@shaggie76 -> DM-ShitBag, shaggie76
static native simulated function CrackLiveMapName( String MapName, out String LongName, out String Author );

// XDM-ShitBag?custommap=DM-WangPull@shaggie76 -> WangPull
static native simulated function String GetMapDisplayName( String MapName );

// XDM-Autumn-UnholyPrison-- -> UnholyPrison
static native simulated function String GetMapDisplayNameFromCustomMapPassport( String MapName );

simulated exec function CloseDownToMenuEditor( Console C )
{
    local Menu M, D;
    
    if( C == None )
        return;

    log("Closing down to MenuEditor");

    M = Self;

    while(M != None)
    {
        D = M;
        M = M.PreviousMenu;
        
        if( ( InStr( String(D.Class), "MenuEditor" ) >= 0 ) )
        {
            C.CurMenu = D;
            break;
        }

        D.DestroyMenu();
   }
   
   if( (C.CurMenu == None) || (C.CurMenu.bDeleteMe != 0) )
   {
        C.GotoState('');
   }
}

simulated function bool InMenuLevel()
{
    return( (Level.Game != None) && Level.Game.bMenuLevel );
}

simulated function bool InLiveGame()
{
    if( Level.NetMode == NM_Standalone )
    {
        return(false);
    }
    
    return( Level.GetAuthMode() == AM_Live );
}

simulated function bool HaveSpaceToSaveMap()
{
    local int freeSpace;
    local int neededSpace;

    freeSpace = int(LoadSaveCommand("SPACE_FREE"));
    neededSpace = int(LoadSaveCommand("CUSTOM_MAP_SPACE_NEEDED"));

    return( freeSpace >= neededSpace );
}

defaultproperties
{
     bDeferAutoFocus=True
     bDeferAutoFocusMouseMove=True
     bAcceptInput=True
     MouseRepeatDelayInitial=0.500000
     MouseRepeatDelaySubsequent=0.050000
     KeyQueueTimeout=0.500000
     CrossFadeRate=2.000000
     CrossFadeLevel=1.000000
     CrossFadeMax=1.000000
     ModulateRate=2.000000
     ModulateLevel=1.000000
     ModulateMin=0.200000
     SoundTweenOut=Sound'VehicleGameSounds.GUI.GUI_Select_B'
     SoundOnFocus=Sound'InterfaceSounds.Buttons.MenuOnFocus'
     SoundOnSelect=Sound'InterfaceSounds.Buttons.MenuOnSelect'
     ForceFeedbackOnFocus="GUIFocus"
     StringYes="Yes"
     StringNo="No"
     StringOn="On"
     StringOff="Off"
     StringOk="Ok"
     StringCancel="Cancel"
     StringPercent="%"
     StringUnknown="Unknown"
     StringContinue="Continue"
     StringNone="None"
     StringApply="Apply"
     StringOfficialCustomMap="Official Custom Map"
     DoubleClickTime=0.500000
     bDynamicLayoutDirty=True
     HelpText=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=200,G=200,R=200,A=255),DrawPivot=DP_LowerLeft,PosX=0.100000,PosY=0.923000,ScaleX=0.650000,ScaleY=0.650000,MaxSizeX=0.800000,bWordWrap=1,Pass=4)
     HelpTextStateDelays(0)=1.500000
     HelpTextStateDelays(1)=0.500000
     HelpTextStateDelays(2)=3.000000
     HelpTextStateDelays(3)=0.500000
     HelpTextStateDelays(4)=4.000000
     OverscanWidgets(0)=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(B=128,G=128,R=128,A=255),ScaleY=1.000000,ScaleMode=MSM_Fit,Pass=15,bHidden=1)
     OverscanWidgets(1)=(DrawPivot=DP_UpperRight,PosX=1.000000,ScaleY=1.000000,bHidden=1)
     OverscanWidgets(2)=(ScaleX=1.000000,bHidden=1)
     OverscanWidgets(3)=(DrawPivot=DP_LowerLeft,PosY=1.000000,ScaleX=1.000000,bHidden=1)
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
     bAlwaysTick=True
}
