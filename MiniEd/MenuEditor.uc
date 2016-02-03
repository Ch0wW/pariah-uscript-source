//-------------------------------------------------
// MenuEditor
// Author: Matthieu St-Pierre
// Desc: The menu that allows the placement of meshes
//		 and the modification of the terrain
//       On the PC, the controls are:
//		 M,K,I,J that simulate A,B,Y,X
//		 Seems weird but they have similar relative
//		 positions.
//		 Q,E to strafe
//		 W,S to move forwards and backwards
//		 A,D to rotate
//		 The PC app is only meant to test features
//		 more quickly.
//		 T,Y are left and right triggers respectively
//-------------------------------------------------
class MenuEditor extends MenuTemplate
	exportstructs
    native;

//Meshes
#exec OBJ LOAD FILE=..\StaticMeshes\MiniEdMeshes.usx

//Textures
#exec OBJ LOAD FILE=..\Textures\MiniEdTextures.utx
#exec OBJ LOAD FILE=..\Textures\PariahPlayerMugShotsTextures.utx

//Sounds
#exec OBJ LOAD FILE=..\Sounds\MenuSounds.uax
#exec OBJ LOAD FILE=..\Sounds\MiniEdSounds.uax
#exec OBJ LOAD FILE=..\Sounds\Sounds_Library.uax
#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax
#exec OBJ LOAD FILE=..\Sounds\OutdoorAmbience.uax

const NUM_MODES = 12;

var	MenuSprite			BannerBehindButtons;

// Mode buttons
var	MenuCheckBoxSprite	Buttons[NUM_MODES];
var MenuText			ModeButtonsLabels[NUM_MODES];

// Arrows
var MenuButtonSprite	ArrowLeft;
var MenuButtonSprite	ArrowRight;

// PC screen scroll

var MenuSprite			ScrollBarTop;
var MenuSprite			ScrollBarLeft;
var MenuSprite			ScrollBarBottom;
var MenuSprite			ScrollBarRight;

//Usage
var MenuText			UsageDesc;
var MenuSprite			UsageOverlay;
var MenuSprite			UsageSlider;
var MenuText			UsageWarningText;

//Painting
var MenuSprite			OtherLayerVersionsIcons[3];
var MenuButtonSprite	LayersSprites[3];		//Shows the texture of each layer
var MenuSprite			TerrainLayerSelectedOutline;

//Help
var MenuSprite			HelpIcons[7];
var MenuText			HelpTexts[7];

var localized String	Help_Hills_Raise;
var localized String	Help_Hills_Lower;
var localized String	Help_Hills_Size;
	
var localized String	Help_Flatten;
var localized String	Help_Flatten_Size;

var localized String	Help_Jump_Up;
var localized String	Help_Jump_Down;
var localized String	Help_Jump_Size;
var localized String	Help_Jump_Rotate;
	
var localized String	Help_Paint_Execute;
var localized String	Help_Paint_Size;
var localized String	Help_Paint_Nextlayer;
var localized String	Help_Paint_Cycle;
	
var localized String	Help_Smooth_Execute;
var localized String	Help_Smooth_Size;

var localized String	Help_Object_Place;
var localized String	Help_Object_Delete;
var localized String	Help_Object_RotateLeft;
var localized String	Help_Object_RotateRight;
var localized String	Help_Object_AutoFlattenOn;
var localized String	Help_Object_AutoFlattenOff;
var localized String	Help_Object_Pickup;
var localized String	Help_Object_Browser;
var localized String	Help_Object_Change;

var localized String	Help_DeleteAll;

var localized String	Help_Fog_Menu;
var localized String	Help_Sky_Menu;
var localized String	Help_Weather_Menu;
var localized String	Help_Sounds_Menu;
var localized String	Help_Lighting_Menu;

var localized String	Help_CloseMenu;

var localized String	Warning_NotEnoughMem;
var localized String	Warning_ActorCount;
//var localized String	Warning_OutsideAllowedArea; //can we localize this?
var localized String	Warning_CamTooClose;
var localized String	Warning_NoDeletePlayerStart;
var localized String	Warning_NoDeleteAssaultObjective;
var localized String	Warning_VehicleCount;
var localized String	Warning_GameObjCount;
var localized String	Warning_FlatForRamp;
var localized String	Warning_JumpTooHigh;
var localized String	Warning_JumpTooLow;
var localized String	Warning_FlatForObj;
var localized String	Warning_IntersectWithObj;
var localized String	Warning_Loading;

//Sounds
var Sound				MESound[22];

//GUI
var bool				bAnimatingGUI;
var bool				bDPadDeactivated;
var bool				bStartDeactivated;

native function CloseMenuGlue();

native function DPADLeft();
native function DPADRight();

native function OnAReleaseGlue();
native function OnBReleaseGlue();
native function OnXReleaseGlue();
native function OnYReleaseGlue();
native function OnLTReleaseGlue();
native function OnRTReleaseGlue();
native function OnLeftClick();
native function OnAutoFlattening();
native function OnDeleteRelease();
native function OnLeftArrow();
native function OnRightArrow();

native function AnFXMenuClosed( Menu M );
native function AnOptionsMenuClosed( Menu M, int ButtonIndex );
native function PawnMenuClosed( Menu M );
native function MeshMenuClosed( Menu M );
native function VehicleMenuClosed( Menu M );
native function MiniEdOptionsMenuClosed( Menu M );
native function TickNative( float dt );
native function SetActive( bool bActive );

native function ChangePaintLayer( int layer );

function Init( String Args )
{
	Super.Init( Args );
	
	CrossFadeDir=TD_In;

	//End of clear
	CrossFadeMax=1.0;

	//Start from final darkness value set when fading out
	CrossFadeLevel=CrossFadeMin;
	TransientSoundVolume = 1.0;
}

function SetPaintLayer0()
{
	ChangePaintLayer(0);
}

function SetPaintLayer1()
{
	ChangePaintLayer(1);
}

function SetPaintLayer2()
{
	ChangePaintLayer(2);
}


function Tick( float dt )
{
	TickNative( dt );
}

//todo: use this to clean up input mess
simulated event bool HandleInputKeyRaw(Interactions.EInputKey Key, Interactions.EInputAction Action)
{
    //log("HandleInputKey!"@Key);

    if (IsOnConsole())
    {
        switch ( Key )
        {
            default:
                return false;
                break;
        }
    }
    else
    {
        switch ( Key )
        {
            case IK_P:
                if( Action == IST_Release )
                {
                    OnAutoFlattening();
                }
                break;
            case IK_LeftMouse:
                if( Action == IST_Release )
                {
                    if( GetWidgetInFocus() != 0 )
                        Super.HandleInputMouseDown();
                    else
                        OnLeftClick();
                }
                break;
            
            case IK_Shift:
                if( Action == IST_Press )
                {
                    MiniEdController(Owner).bMouseControlledCamRot = true;
					MiniEdController(Owner).PlayerInput.FilterMouseInput = 1.0;
                }
                else if( Action == IST_Release )
                {
                    MiniEdController(Owner).bMouseControlledCamRot = false;
					MiniEdController(Owner).PlayerInput.FilterMouseInput = 0.0;
                }
                break;

            case IK_MiddleMouse:
                if( Action == IST_Release )
                    OnYReleaseGlue();
                break;

            default:
                return false;
                break;
        }
    }

    return true;
}


//function HandleInputMouseDown()
//{
//    log( "1" );
//    if( GetWidgetInFocus() != 0 )
//        Super.HandleInputMouseDown();
//}


function bool HandleInputWheelUp( int Clicks )
{
    (MiniEdController(Owner)).MouseWheel = Clicks;
    return true;
}


function bool HandleInputWheelDown( int Clicks )
{
    (MiniEdController(Owner)).MouseWheel = -Clicks;
    return true;
}


simulated event HandleInputSelectOfSuper()
{
	Super.HandleInputSelect();
}

//---------------------------------
//Handle button releases for the PC
//---------------------------------

exec function Delete( String cmd )
{
	OnDeleteRelease();
}

exec function ReleasedA( String cmd )
{
	OnAReleaseGlue();
}

exec function ReleasedB( String cmd )
{
	OnBReleaseGlue();
}

exec function ReleasedX( String cmd )
{
	OnXReleaseGlue();
}

exec function ReleasedY( String cmd )
{
	OnYReleaseGlue();
}
/*
exec function ReleasedWhite( String cmd )
{
	OnWhiteReleaseGlue();
}
*/
exec function ReleasedLT( String cmd )
{
	OnLTReleaseGlue();
}


exec function ReleasedRT( String cmd )
{
	OnRTReleaseGlue();
}

exec function Released( String cmd )
{
	OnAReleaseGlue();
}


exec function PressedStart( String cmd )
{
	CallMenuClass("MiniEd.MiniEdStartMenu" );	
}


//Handle button releases for the gamepad
function bool HandleInputGamePad( String ButtonName )
{	
	// B
	if( ButtonName == "B" )
	{
		OnBReleaseGlue();
		return true; // gam -- ???
	}
	// X
	else if( ButtonName == "X" )
	{
		OnXReleaseGlue();
		return true;
	}
	// Y
	else if( ButtonName == "Y" )
	{
		OnYReleaseGlue();
		return true;
	}
	// Left trigger
	else if( ButtonName == "LT" )
	{
		OnLTReleaseGlue();
		return true; // gam -- ???
	}
	// Right trigger
	else if( ButtonName == "RT" )
	{
		OnRTReleaseGlue();
		return true; // gam -- ???
	}
	return Super.HandleInputGamePad(ButtonName);
}

function HandleInputBack()
{
    local MenuMiniEdMain M;
    
    SetActive(false);

    M = Spawn( class'MenuMiniEdMain', Owner );
	CallMenu(M);
    M.CrossFadeLevel = 1.f;
}


// The "A" Button that will select a static mesh or a mode button
function HandleInputSelect()  
{
	OnAReleaseGlue();
}


event AnimatorDone( int Id )
{
	switch( Id )
	{
	case 0:
		bAnimatingGUI = false;
		break;
	}
}


function HandleInputLeft()
{
	if( bAnimatingGUI || bDPadDeactivated )
		return;
	
	Super.HandleInputLeft();
	DPADLeft();
}


function HandleInputRight()
{
	if( bAnimatingGUI || bDPadDeactivated )
		return;
		
	Super.HandleInputRight();
	DPADRight();
}


function CloseMenu()
{
	CloseMenuGlue();
	Super.CloseMenu();
}


function HandleInputStart()
{
	if ( bStartDeactivated )
		return;
    HandleInputBack();
}


function bool MenuClosed( Menu ClosingMenu )
{
	local MiniEdController C;
	
	//Reset A and B
	C = MiniEdController(Owner);
	C.bPressedA = 0;
	C.bPressedB = 0;

	// Handle closing of the Fx dropdown:
	//	- fog drawer
	//	- sky drawer
	//	- Weather drawer
	//	- Sound drawer
	if( ClosingMenu.IsA('MiniedDrawer_FogSelect') ||
		ClosingMenu.IsA('MiniedDrawer_SkySelect') ||
		ClosingMenu.IsA('MiniedDrawer_WeatherSelect') ||
		ClosingMenu.IsA('MiniedDrawer_SoundSelect') ||
		ClosingMenu.IsA('LightingMenu') )
	{
		AnFXMenuClosed( ClosingMenu );
		return true;
	}

	if ( ClosingMenu.IsA('DeleteAllMenu') )
	{
		AnOptionsMenuClosed( ClosingMenu, 3 );
		return true;
	}

	// Handle pawn selection menu
	else if( ClosingMenu.IsA('PawnBrowserMenu') )
	{
		PawnMenuClosed( ClosingMenu );
		return true;
	}
	
	//Handle mesh browser menu
	else if( ClosingMenu.IsA('MeshBrowserMenu') )
	{
		MeshMenuClosed( ClosingMenu );
		return true;
	}

	else if(ClosingMenu.IsA('VehicleBrowserMenu') )
	{	
		VehicleMenuClosed( ClosingMenu );
		return true;
	}
	
	// Handle closing of the physic setup browser menu
	else if( ClosingMenu.IsA('MiniEdOptionsMenu') )
	{
		MiniEdOptionsMenuClosed( ClosingMenu );
		return true;
	}
    else if( ClosingMenu.IsA('MenuMiniEdMain') )
    {
        SetActive(true);
    }

    return true;
}

defaultproperties
{
     BannerBehindButtons=(WidgetTexture=Texture'InterfaceContent.Menu.BackFill',RenderStyle=STY_Alpha,DrawColor=(A=80),DrawPivot=DP_MiddleLeft,PosY=0.220000,ScaleX=1.000000,ScaleY=0.030000,ScaleMode=MSM_FitStretch)
     Buttons(0)=(OnSelect="OnLeftClick",Pass=1)
     Buttons(1)=(OnSelect="OnLeftClick",Pass=1)
     Buttons(2)=(OnSelect="OnLeftClick",Pass=1)
     Buttons(3)=(OnSelect="OnLeftClick",Pass=1)
     Buttons(4)=(OnSelect="OnLeftClick",Pass=1)
     Buttons(5)=(OnSelect="OnLeftClick",Pass=1)
     Buttons(6)=(OnSelect="OnLeftClick",Pass=1)
     Buttons(7)=(OnSelect="OnLeftClick",Pass=1)
     Buttons(8)=(OnSelect="OnLeftClick",Pass=1)
     Buttons(9)=(OnSelect="OnLeftClick",Pass=1)
     Buttons(10)=(OnSelect="OnLeftClick",Pass=1)
     Buttons(11)=(OnSelect="OnLeftClick",Pass=1)
     ModeButtonsLabels(0)=(Text="Objects",DrawPivot=DP_MiddleMiddle,PosY=0.220000,ScaleX=0.700000,ScaleY=0.700000,Style="MiniedButtonsText")
     ModeButtonsLabels(1)=(Text="Game objects",DrawPivot=DP_MiddleMiddle,PosY=0.220000,ScaleX=0.700000,ScaleY=0.700000,Style="MiniedButtonsText")
     ModeButtonsLabels(2)=(Text="Vehicles",DrawPivot=DP_MiddleMiddle,PosY=0.220000,ScaleX=0.700000,ScaleY=0.700000,Style="MiniedButtonsText")
     ModeButtonsLabels(3)=(Text="Raising",DrawPivot=DP_MiddleMiddle,PosY=0.220000,ScaleX=0.700000,ScaleY=0.700000,Style="MiniedButtonsText")
     ModeButtonsLabels(4)=(Text="Flatten",DrawPivot=DP_MiddleMiddle,PosY=0.220000,ScaleX=0.700000,ScaleY=0.700000,Style="MiniedButtonsText")
     ModeButtonsLabels(5)=(Text="Ramp",DrawPivot=DP_MiddleMiddle,PosY=0.220000,ScaleX=0.700000,ScaleY=0.700000,Style="MiniedButtonsText")
     ModeButtonsLabels(6)=(Text="Paint",DrawPivot=DP_MiddleMiddle,PosY=0.220000,ScaleX=0.700000,ScaleY=0.700000,Style="MiniedButtonsText")
     ModeButtonsLabels(7)=(Text="Smooth",DrawPivot=DP_MiddleMiddle,PosY=0.220000,ScaleX=0.700000,ScaleY=0.700000,Style="MiniedButtonsText")
     ModeButtonsLabels(8)=(Text="Fog",DrawPivot=DP_MiddleMiddle,PosY=0.220000,ScaleX=0.700000,ScaleY=0.700000,Style="MiniedButtonsText")
     ModeButtonsLabels(9)=(Text="Sky",DrawPivot=DP_MiddleMiddle,PosY=0.220000,ScaleX=0.700000,ScaleY=0.700000,Style="MiniedButtonsText")
     ModeButtonsLabels(10)=(Text="Weather",DrawPivot=DP_MiddleMiddle,PosY=0.220000,ScaleX=0.700000,ScaleY=0.700000,Style="MiniedButtonsText")
     ModeButtonsLabels(11)=(Text="Lighting",DrawPivot=DP_MiddleMiddle,PosY=0.220000,ScaleX=0.700000,ScaleY=0.700000,Style="MiniedButtonsText")
     ScrollBarTop=(WidgetTexture=Texture'MiniEdTextures.GUI.PureWhite',DrawColor=(G=92,R=196,A=128),ScaleX=40.000000,bHidden=1)
     ScrollBarLeft=(WidgetTexture=Texture'MiniEdTextures.GUI.PureWhite',DrawColor=(G=92,R=196,A=128),ScaleY=30.000000,bHidden=1)
     ScrollBarBottom=(WidgetTexture=Texture'MiniEdTextures.GUI.PureWhite',DrawColor=(G=92,R=196,A=128),DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,ScaleX=40.000000,bHidden=1)
     ScrollBarRight=(WidgetTexture=Texture'MiniEdTextures.GUI.PureWhite',DrawColor=(G=92,R=196,A=128),DrawPivot=DP_LowerRight,PosX=1.000000,PosY=1.000000,ScaleY=30.000000,bHidden=1)
     UsageDesc=(MenuFont=Font'Engine.FontSmall',Text="Usage",DrawPivot=DP_MiddleRight,PosX=0.740000,PosY=0.900000,ScaleX=0.800000,ScaleY=0.800000,Style="LabelText")
     UsageOverlay=(WidgetTexture=Texture'MiniEdTextures.HUD.Bar',TextureCoords=(X2=256,Y2=64),RenderStyle=STY_Alpha,DrawColor=(B=235,G=206,R=44,A=220),DrawPivot=DP_MiddleLeft,PosX=0.735000,PosY=0.900000,ScaleX=0.500000,ScaleY=0.500000)
     UsageSlider=(WidgetTexture=Texture'MiniEdTextures.HUD.Bar',TextureCoords=(Y1=64,X2=23,Y2=128),RenderStyle=STY_Alpha,DrawPivot=DP_MiddleLeft,PosX=0.735000,PosY=0.900000,ScaleX=0.500000,ScaleY=0.500000)
     UsageWarningText=(Style="MessageText")
     OtherLayerVersionsIcons(0)=(WidgetTexture=Texture'MiniEdTextures.GUI.sheet_01',RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000)
     OtherLayerVersionsIcons(1)=(WidgetTexture=Texture'MiniEdTextures.GUI.sheet_01',RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000)
     OtherLayerVersionsIcons(2)=(WidgetTexture=Texture'MiniEdTextures.GUI.sheet_01',RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000)
     LayersSprites(0)=(OnSelect="SetPaintLayer0")
     LayersSprites(1)=(OnSelect="SetPaintLayer1")
     LayersSprites(2)=(OnSelect="SetPaintLayer2")
     TerrainLayerSelectedOutline=(WidgetTexture=Texture'MiniEdTextures.GUI.paint_layer',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,ScaleX=1.100000,ScaleY=1.100000)
     HelpIcons(0)=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.093000,ScaleX=0.600000,ScaleY=0.600000,Pass=1)
     HelpIcons(1)=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.093000,ScaleX=0.600000,ScaleY=0.600000,Pass=1)
     HelpIcons(2)=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.093000,ScaleX=0.600000,ScaleY=0.600000,Pass=1)
     HelpIcons(3)=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.093000,ScaleX=0.600000,ScaleY=0.600000,Pass=1)
     HelpIcons(4)=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.093000,ScaleX=0.600000,ScaleY=0.600000,Pass=1)
     HelpIcons(5)=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.093000,ScaleX=0.600000,ScaleY=0.600000,Pass=1)
     HelpIcons(6)=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.093000,ScaleX=0.400000,ScaleY=0.400000,Pass=1)
     HelpTexts(0)=(MenuFont=Font'Engine.FontSmall',DrawPivot=DP_MiddleLeft,PosX=0.120000,ScaleX=0.800000,ScaleY=0.800000,Style="LabelText")
     HelpTexts(1)=(MenuFont=Font'Engine.FontSmall',DrawPivot=DP_MiddleLeft,PosX=0.120000,ScaleX=0.800000,ScaleY=0.800000,Style="LabelText")
     HelpTexts(2)=(MenuFont=Font'Engine.FontSmall',DrawPivot=DP_MiddleLeft,PosX=0.120000,ScaleX=0.800000,ScaleY=0.800000,Style="LabelText")
     HelpTexts(3)=(MenuFont=Font'Engine.FontSmall',DrawPivot=DP_MiddleLeft,PosX=0.120000,ScaleX=0.800000,ScaleY=0.800000,Style="LabelText")
     HelpTexts(4)=(MenuFont=Font'Engine.FontSmall',DrawPivot=DP_MiddleLeft,PosX=0.120000,ScaleX=0.800000,ScaleY=0.800000,Style="LabelText")
     HelpTexts(5)=(MenuFont=Font'Engine.FontSmall',DrawPivot=DP_MiddleLeft,PosX=0.120000,ScaleX=0.800000,ScaleY=0.800000,Style="LabelText")
     HelpTexts(6)=(MenuFont=Font'Engine.FontSmall',DrawPivot=DP_MiddleLeft,PosX=0.120000,ScaleX=0.800000,ScaleY=0.800000,Style="LabelText")
     Help_Hills_Raise="Raise terrain"
     Help_Hills_Lower="Lower terrain"
     Help_Hills_Size="Change radius of effect"
     Help_Flatten="Flatten"
     Help_Flatten_Size="Change radius of effect"
     Help_Jump_Up="Increase steepness"
     Help_Jump_Down="Decrease steepness"
     Help_Jump_Size="Change shape"
     Help_Jump_Rotate="Rotate"
     Help_Paint_Execute="Paint"
     Help_Paint_Size="Change radius of effect"
     Help_Paint_Nextlayer="Go to next texture"
     Help_Paint_Cycle="Cycle textures"
     Help_Smooth_Execute="Smooth terrain"
     Help_Smooth_Size="Change radius of effect"
     Help_Object_Place="Place object"
     Help_Object_Delete="Delete object"
     Help_Object_RotateLeft="Rotate Left"
     Help_Object_RotateRight="Rotate right"
     Help_Object_AutoFlattenOn="Turn on auto flattenning"
     Help_Object_AutoFlattenOff="Turn off auto flattenning"
     Help_Object_Pickup="Select object"
     Help_Object_Browser="Object browser"
     Help_Object_Change="Change object"
     Help_DeleteAll="Delete all placed objects"
     Help_Fog_Menu="Fog menu"
     Help_Sky_Menu="Sky menu"
     Help_Weather_Menu="Weather menu"
     Help_Sounds_Menu="Sounds menu"
     Help_Lighting_Menu="Open lighting tool"
     Help_CloseMenu="Close Menu"
     Warning_NotEnoughMem="Not Enough Memory For Object"
     Warning_ActorCount="Maximum number of objects reached"
     Warning_CamTooClose="Camera Too Close To Ground To Raise Terrain"
     Warning_NoDeletePlayerStart="You Can Not Delete Player Starts"
     Warning_NoDeleteAssaultObjective="You Can Not Delete The Assault Objective"
     Warning_VehicleCount="Too Many Vehicles"
     Warning_GameObjCount="Too Many Game Objects"
     Warning_FlatForRamp="Need a Flat Surface to Create Ramp"
     Warning_JumpTooHigh="Maximum Ramp Height Reached"
     Warning_JumpTooLow="Can't Go Any Lower"
     Warning_FlatForObj="Terrain Not Flat Enough"
     Warning_IntersectWithObj="Object Intersects"
     Warning_Loading="Loading..."
     MESound(0)=Sound'MiniEdSounds.MiniEdAmbientRain'
     MESound(1)=Sound'MiniEdSounds.MiniEdAmbientSnow'
     MESound(2)=Sound'MiniEdSounds.MiniEdAmbientWind'
     MESound(3)=Sound'MiniEdSounds.MiniEdChangeBrush'
     MESound(4)=Sound'MiniEdSounds.MiniEdDrawerClose'
     MESound(5)=Sound'MiniEdSounds.MiniEdDrawerOpen'
     MESound(6)=Sound'MiniEdSounds.MiniEdMenuSlideClose'
     MESound(7)=Sound'MiniEdSounds.MiniEdMenuSlideOpen'
     MESound(8)=Sound'MiniEdSounds.MiniEdObjectClone'
     MESound(9)=Sound'MiniEdSounds.MiniEdObjectPlace'
     MESound(10)=Sound'MiniEdSounds.MiniEdPhysicsObjectClone'
     MESound(11)=Sound'MiniEdSounds.MiniEdPhysicsObjectPlace'
     MESound(12)=Sound'MiniEdSounds.MiniEdTerrainEditLoopA'
     MESound(13)=Sound'MiniEdSounds.MiniEdTerrainEditLoopAEnd'
     MESound(14)=Sound'MiniEdSounds.MiniEdTerrainEditLoopB'
     MESound(15)=Sound'MiniEdSounds.MiniEdTerrainEditLoopBEnd'
     MESound(16)=Sound'MiniEdSounds.MiniEdTerrainEditStart'
     MESound(17)=Sound'MiniEdSounds.MiniEdTerrainPaintEnd'
     MESound(18)=Sound'MiniEdSounds.MiniEdTerrainPaintLoop'
     MESound(19)=Sound'MiniEdSounds.MiniEdTerrainPaintStart'
     MESound(20)=Sound'MiniEdSounds.Terrain_Flatten'
     MESound(21)=Sound'WeaponSounds.Misc.imp03'
     CrossFadeRate=0.500000
     CrossFadeMin=1.000000
     ModulateMin=1.000000
     SoundTweenOut=None
     SoundOnFocus=None
     SoundOnSelect=None
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
}
