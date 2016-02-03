class MenuSettingsControlsXbox extends MenuTemplateTitledB;

// God, I just need a sweet bitch.
//
// IK_Joy1 => Y
// IK_Joy2 => B
// IK_Joy3 => A
// IK_Joy4 => X
// IK_Joy5 => Black
// IK_Joy6 => White
// IK_Joy7 => Left Trigger
// IK_Joy8 => Right Trigger
// IK_Joy9 => Start
// IK_Joy10 => Back
// IK_Joy11 => LeftStick (L3)
// IK_Joy12 => RightStick (R3)
//
// IK_JoyPovDown
// IK_JoyPovLeft
// IK_JoyPovRight
// IK_JoyPovUp 

enum AxisBind
{
    AB_None,
    AB_MoveX,
    AB_MoveY,
    AB_LookX,
    AB_LookY
};

const AXIS_BIND_COUNT = 5;

struct AxesConfig
{
    var() localized String Name;
    
    var() AxisBind JoyX;
    var() AxisBind JoyY;
    var() AxisBind JoyU;
    var() AxisBind JoyV;
};

enum ButtonBind
{
    BB_None,
    BB_ShowWeaponMenu,
    BB_Jump,
    BB_UseAndReload,
    BB_HealingTool,
    BB_MeleeAttack,
    BB_Fire,
    BB_ShowMenu,
    BB_Duck,
    BB_Zoom,
    BB_Dash,
    BB_ShowObjectives,
    BB_NextWeapon,
    BB_PreviousWeapon,
    BB_ShowVoiceMenu
};

const BUTTON_BIND_COUNT = 15;

struct ButtonConfig
{
    var() localized String Name;
    var() ButtonBind Buttons[12];
    var() ButtonBind PovUp;
    var() ButtonBind PovDown;
    var() ButtonBind PovLeft;
    var() ButtonBind PovRight;
};

var() MenuSprite        Controller;

var() MenuLayer         AxesLayer;
var() MenuLayer         ButtonsLayer;

var() MenuButtonEnum    AxesConfigEnum;
var() MenuButtonEnum    ButtonConfigEnum;

var() MenuSliderArrow   AxesConfigDown;
var() MenuSliderArrow   ButtonConfigDown;

var() MenuSliderArrow   AxesConfigUp;
var() MenuSliderArrow   ButtonConfigUp;

var() WidgetLayout      SliderLayout;
var() WidgetLayout      SliderLeftArrowLayout;
var() WidgetLayout      SliderRightArrowLayout;

var() localized String  AxesLabel;
var() localized String  ButtonLabel;

var() localized String  AxesBindLabels[AXIS_BIND_COUNT];
var() String            AxesBindCommands[AXIS_BIND_COUNT];

var() localized String  ButtonBindLabels[BUTTON_BIND_COUNT];
var() String            ButtonBindCommands[BUTTON_BIND_COUNT];

var() AxesConfig        AxesConfigs[4];
var() ButtonConfig      ButtonConfigs[6];

simulated function Init( String Args )
{
    local int i;
    
    for( i = 0; i < ArrayCount(AxesConfigs); ++i )
    {
        AxesConfigEnum.Items[i] = AxesLabel @ AxesConfigs[i].Name;
    }
    
    for( i = 0; i < ArrayCount(ButtonConfigs); ++i )
    {
        ButtonConfigEnum.Items[i] = ButtonLabel @ ButtonConfigs[i].Name;
    }
    
    AxesLayer.Layer = MenuBase( Spawn( class<Menu>( DynamicLoadObject(AxesLayer.MenuClassName, class'Class') ), Owner ) );
    ButtonsLayer.Layer = MenuBase( Spawn( class<Menu>( DynamicLoadObject(ButtonsLayer.MenuClassName, class'Class') ), Owner ) );
    
    AxesConfigEnum.Current = LoadAxisConfig();
    ButtonConfigEnum.Current = LoadButtonConfig();
    
    OnAxesChange();
    OnButtonChange();
    
    OnAxesFocus();
}

simulated function HandleInputBack()
{
    SaveAxisConfig( AxesConfigs[AxesConfigEnum.Current] );
    SaveButtonConfig( ButtonConfigs[ButtonConfigEnum.Current] );

    CloseMenu();
}

simulated function AxisBind LoadAxesBinding( String KeyName )
{
    local String BindingString;
    local int i;
    
    BindingString = PlayerController(Owner).ConsoleCommand("KEYBINDING" @ KeyName);
    
    for( i = 0; i < ArrayCount(AxesBindCommands); ++i )
    {
        if( BindingString == AxesBindCommands[i] )
        {
            return(AxisBind(i));
        }
    }
    
    log("Ignoring custom axis binding of" @ KeyName @ "to" @ BindingString, 'Warning');
    return(AB_None);
}

simulated function bool AxisConfigsEqual( AxesConfig A, AxesConfig B )
{
    return
    (
        ( A.JoyX == B.JoyX ) &&
        ( A.JoyY == B.JoyY ) &&
        ( A.JoyU == B.JoyU ) &&
        ( A.JoyV == B.JoyV )
    );
}

simulated function int LoadAxisConfig()
{
    local AxesConfig Config;
    local int ConfigIndex;
    
    Config.JoyX = LoadAxesBinding( "JoyX" );
    Config.JoyY = LoadAxesBinding( "JoyY" );
    Config.JoyU = LoadAxesBinding( "JoyU" );
    Config.JoyV = LoadAxesBinding( "JoyV" );
    
    for( ConfigIndex = 0; ConfigIndex < ArrayCount(AxesConfigs); ++ConfigIndex )
    {
        if( AxisConfigsEqual( Config, AxesConfigs[ConfigIndex] ) )
        {
            return(ConfigIndex);
        }
    }
    
    log("Ignoring custom config of controller axes!", 'Warning');
    return(0);
}

simulated function ButtonBind LoadButtonBinding( String KeyName )
{
    local String BindingString;
    local int i;
    
    BindingString = PlayerController(Owner).ConsoleCommand("KEYBINDING" @ KeyName);
    
    for( i = 0; i < ArrayCount(ButtonBindCommands); ++i )
    {
        if( BindingString == ButtonBindCommands[i] )
        {
            return(ButtonBind(i));
        }
    }
    
    log("Ignoring custom button binding of" @ KeyName @ "to" @ BindingString, 'Warning');
    return(BB_None);
}

simulated function bool ButtonConfigsEqual( ButtonConfig A, ButtonConfig B )
{
    local int ButtonIndex;

    for( ButtonIndex = 0; ButtonIndex < ArrayCount( A.Buttons ); ++ButtonIndex )
    {
        if( A.Buttons[ButtonIndex] != B.Buttons[ButtonIndex] )
        {
            return(false);
        }
    }

    return
    (
        ( A.PovUp == B.PovUp ) &&
        ( A.PovDown == B.PovDown ) &&
        ( A.PovLeft == B.PovLeft ) &&
        ( A.PovRight == B.PovRight )
    );
}

simulated function int LoadButtonConfig()
{
    local ButtonConfig Config;
    local int ButtonIndex;
    local int ConfigIndex;

    for( ButtonIndex = 0; ButtonIndex < ArrayCount( ButtonConfigs[ConfigIndex].Buttons ); ++ButtonIndex )
    {
        Config.Buttons[ButtonIndex] = LoadButtonBinding( "Joy" $ (ButtonIndex + 1) );
    }
    
    Config.PovUp = LoadButtonBinding( "JoyPovUp" );
    Config.PovDown = LoadButtonBinding( "JoyPovDown" );
    Config.PovLeft = LoadButtonBinding( "JoyPovLeft" );
    Config.PovRight = LoadButtonBinding( "JoyPovRight" );
    
    for( ConfigIndex = 0; ConfigIndex < ArrayCount(ButtonConfigs); ++ConfigIndex )
    {
        if( ButtonConfigsEqual( Config, ButtonConfigs[ConfigIndex] ) )
        {
            return(ConfigIndex);
        }
    }
    
    log("Ignoring custom button config!", 'Warning');
    return(0);
}

simulated function SaveBinding( String KeyName, String Binding )
{
    local PlayerController PC;
    local String Prefix;

    PC = PlayerController(Owner);
    Prefix = "SETINPUT GAMEPAD_INDEX=" $ PC.Player.GamePadIndex; 
    log( Prefix @ "KEY=" $ KeyName @ "BINDING=" $ MakeQuotedString(Binding) );
    PC.ConsoleCommand( Prefix @ "KEY=" $ KeyName @ "BINDING=" $ MakeQuotedString(Binding) );
}

simulated function SaveAxisConfig( AxesConfig Config )
{
    SaveBinding( "JoyX", AxesBindCommands[Config.JoyX] );
    SaveBinding( "JoyY", AxesBindCommands[Config.JoyY] );
    SaveBinding( "JoyU", AxesBindCommands[Config.JoyU] );
    SaveBinding( "JoyV", AxesBindCommands[Config.JoyV] );
}

simulated function SaveButtonConfig( ButtonConfig Config )
{
    local int i;
    
    for( i = 0; i < ArrayCount(Config.Buttons); ++i )
    {
        SaveBinding( "Joy" $ (i + 1), ButtonBindCommands[Config.Buttons[i]] );
    }
    
    while( i < 16 )
    {
        ++i;
        SaveBinding( "Joy" $ i, "" );
    }
    
    SaveBinding( "JoyPovUp", ButtonBindCommands[Config.PovUp] );
    SaveBinding( "JoyPovDown", ButtonBindCommands[Config.PovDown] );
    SaveBinding( "JoyPovLeft", ButtonBindCommands[Config.PovLeft] );
    SaveBinding( "JoyPovRight", ButtonBindCommands[Config.PovRight] );
}

static simulated function String GetAxisBind( AxisBind Bind )
{
    Assert( Bind < ArrayCount( default.AxesBindLabels ) );
    return( default.AxesBindLabels[ Bind ] );
}

static simulated function String GetButtonBind( ButtonBind Bind )
{
    Assert( Bind < ArrayCount( default.ButtonBindLabels ) );
    return( default.ButtonBindLabels[ Bind ] );
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );
    
    LayoutWidgets( AxesConfigEnum, ButtonConfigEnum, 'SliderLayout' );
    LayoutWidgets( AxesConfigDown, ButtonConfigDown, 'SliderLeftArrowLayout' );
    LayoutWidgets( AxesConfigUp, ButtonConfigUp, 'SliderRightArrowLayout' );

    if( AxesLayer.Layer != None )
    {
        OverlayXboxAxes(AxesLayer.Layer).SetConfig( AxesConfigs[AxesConfigEnum.Current] );
    }

    if( ButtonsLayer.Layer != None )
    {
        OverlayXboxButtons(ButtonsLayer.Layer).SetConfig( ButtonConfigs[ButtonConfigEnum.Current] );
    }
}

simulated function OnAxesFocus()
{
    if( AxesLayer.Layer != None )
    {
        AxesLayer.Layer.CrossFadeDir = TD_In;
    }

    if( ButtonsLayer.Layer != None )
    {
        ButtonsLayer.Layer.CrossFadeDir = TD_Out;
    }
}

simulated function OnAxesChange()
{
    if( AxesLayer.Layer != None )
    {
        OverlayXboxAxes(AxesLayer.Layer).SetConfig( AxesConfigs[AxesConfigEnum.Current] );
    }
}

simulated function OnButtonFocus()
{
    if( ButtonsLayer.Layer != None )
    {
        ButtonsLayer.Layer.CrossFadeDir = TD_In;
    }
    
    if( AxesLayer.Layer != None )
    {
        AxesLayer.Layer.CrossFadeDir = TD_Out;
    }
}

simulated function OnButtonChange()
{
    if( ButtonsLayer.Layer != None )
    {
        OverlayXboxButtons(ButtonsLayer.Layer).SetConfig( ButtonConfigs[ButtonConfigEnum.Current] );
    }
}

defaultproperties
{
     Controller=(WidgetTexture=Texture'PariahInterface.XboxController.LargeController',DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.650000,Pass=3)
     AxesLayer=(MenuClassName="XInterfaceSettings.OverlayXboxAxes",Pass=4)
     ButtonsLayer=(MenuClassName="XInterfaceSettings.OverlayXboxButtons",Pass=4)
     AxesConfigEnum=(OnChange="OnAxesChange",OnFocus="OnAxesFocus",Style="SettingsEnum")
     ButtonConfigEnum=(OnChange="OnButtonChange",OnFocus="OnButtonFocus",Style="SettingsEnum")
     AxesConfigDown=(WidgetName="AxesConfigEnum",OnFocus="OnAxesFocus",OnBlur="OnAxesBlur",Style="SettingsSliderLeft")
     ButtonConfigDown=(WidgetName="ButtonConfigEnum",OnFocus="OnButtonFocus",OnBlur="OnButtonBlur",Style="SettingsSliderLeft")
     AxesConfigUp=(WidgetName="AxesConfigEnum",OnFocus="OnAxesFocus",OnBlur="OnAxesBlur",Style="SettingsSliderRight")
     ButtonConfigUp=(WidgetName="ButtonConfigEnum",OnFocus="OnButtonFocus",OnBlur="OnButtonBlur",Style="SettingsSliderRight")
     SliderLayout=(PosX=0.145000,PosY=0.250000,SpacingY=0.065000,BorderScaleX=0.400000)
     SliderLeftArrowLayout=(PosX=0.100000,PosY=0.250000,SpacingY=0.065000,BorderScaleX=0.400000)
     SliderRightArrowLayout=(PosX=0.610000,PosY=0.250000,SpacingY=0.065000,BorderScaleX=0.400000)
     AxesLabel="Thumbsticks:"
     ButtonLabel="Buttons:"
     AxesBindLabels(0)="Unused"
     AxesBindLabels(1)="Strafe Left / Right"
     AxesBindLabels(2)="Move Forward / Back"
     AxesBindLabels(3)="Turn Left / Right"
     AxesBindLabels(4)="Look Up / Down"
     AxesBindCommands(1)="Axis aStrafe SpeedBase=32768.0 DeadZone=0.4"
     AxesBindCommands(2)="Axis aBaseY SpeedBase=32768.0 DeadZone=0.4 | Axis aThrottle SpeedBase=24000.0 DeadZone=0.4"
     AxesBindCommands(3)="Axis aBaseX SpeedBase=32768.0 DeadZone=0.24 | Axis aSteer SpeedBase=24000.0 DeadZone=0.24"
     AxesBindCommands(4)="Axis aBaseZ SpeedBase=32768.0 DeadZone=0.24"
     ButtonBindLabels(0)="Unused"
     ButtonBindLabels(1)="Weapon Menu"
     ButtonBindLabels(2)="Jump"
     ButtonBindLabels(3)="Use / Reload"
     ButtonBindLabels(4)="Healing Tool"
     ButtonBindLabels(5)="Bonesaw"
     ButtonBindLabels(6)="Fire"
     ButtonBindLabels(7)="Pause"
     ButtonBindLabels(8)="Duck"
     ButtonBindLabels(9)="Zoom"
     ButtonBindLabels(10)="Dash"
     ButtonBindLabels(11)="Objectives"
     ButtonBindLabels(12)="Next Weapon"
     ButtonBindLabels(13)="Prev. Weapon"
     ButtonBindLabels(14)="Voice Menu"
     ButtonBindCommands(1)="ShowWeaponMenu"
     ButtonBindCommands(2)="IfInVehicle Nop ; Jump | DriveForward"
     ButtonBindCommands(3)="ExitVehicleOr EnterVehicleOr UseOr ReloadWeapon"
     ButtonBindCommands(4)="IfInVehicle Nop ; ToggleHealingTool | DriveBackward"
     ButtonBindCommands(5)="IfInVehicle AltFire ; Melee | OnRelease AltFire"
     ButtonBindCommands(6)="Fire"
     ButtonBindCommands(7)="ShowMenu"
     ButtonBindCommands(8)="Duck | OnRelease Duck"
     ButtonBindCommands(9)="AltFire"
     ButtonBindCommands(10)="IfInVehicle HandBrake ; Dash | OnRelease HandBrake"
     ButtonBindCommands(11)="ShowObjectivesOr ShowScores | OnRelease ShowObjectivesOr HideScores"
     ButtonBindCommands(12)="NextWeapon"
     ButtonBindCommands(13)="PrevWeapon"
     ButtonBindCommands(14)="ShowVoiceMenu"
     AxesConfigs(0)=(Name="Default",JoyX=AB_MoveX,JoyY=AB_MoveY,JoyU=AB_LookX,JoyV=AB_LookY)
     AxesConfigs(1)=(Name="SouthPaw",JoyX=AB_LookX,JoyY=AB_LookY,JoyU=AB_MoveX,JoyV=AB_MoveY)
     AxesConfigs(2)=(Name="Legacy",JoyX=AB_LookX,JoyY=AB_MoveY,JoyU=AB_MoveX,JoyV=AB_LookY)
     AxesConfigs(3)=(Name="Legacy SouthPaw",JoyX=AB_MoveX,JoyY=AB_LookY,JoyU=AB_LookX,JoyV=AB_MoveY)
     ButtonConfigs(0)=(Name="Default",Buttons[0]=BB_ShowWeaponMenu,Buttons[1]=BB_Dash,Buttons[2]=BB_Jump,Buttons[3]=BB_UseAndReload,Buttons[4]=BB_ShowObjectives,Buttons[5]=BB_HealingTool,Buttons[6]=BB_MeleeAttack,Buttons[7]=BB_Fire,Buttons[8]=BB_ShowMenu,Buttons[9]=BB_ShowVoiceMenu,Buttons[10]=BB_Duck,Buttons[11]=BB_Zoom,PovUp=BB_NextWeapon,PovDown=BB_PreviousWeapon)
     ButtonConfigs(1)=(Name="RabbitFinger",Buttons[0]=BB_ShowWeaponMenu,Buttons[1]=BB_MeleeAttack,Buttons[2]=BB_Dash,Buttons[3]=BB_UseAndReload,Buttons[4]=BB_ShowObjectives,Buttons[5]=BB_HealingTool,Buttons[6]=BB_Jump,Buttons[7]=BB_Fire,Buttons[8]=BB_ShowMenu,Buttons[9]=BB_ShowVoiceMenu,Buttons[10]=BB_Duck,Buttons[11]=BB_Zoom,PovUp=BB_NextWeapon,PovDown=BB_PreviousWeapon)
     ButtonConfigs(2)=(Name="Clicker",Buttons[0]=BB_ShowWeaponMenu,Buttons[1]=BB_Duck,Buttons[2]=BB_Dash,Buttons[3]=BB_UseAndReload,Buttons[4]=BB_ShowObjectives,Buttons[5]=BB_HealingTool,Buttons[6]=BB_MeleeAttack,Buttons[7]=BB_Fire,Buttons[8]=BB_ShowMenu,Buttons[9]=BB_ShowVoiceMenu,Buttons[10]=BB_Jump,Buttons[11]=BB_Zoom,PovUp=BB_NextWeapon,PovDown=BB_PreviousWeapon)
     ButtonConfigs(3)=(Name="SouthPaw",Buttons[0]=BB_ShowWeaponMenu,Buttons[1]=BB_NextWeapon,Buttons[2]=BB_Jump,Buttons[3]=BB_PreviousWeapon,Buttons[4]=BB_ShowObjectives,Buttons[5]=BB_HealingTool,Buttons[6]=BB_MeleeAttack,Buttons[7]=BB_Fire,Buttons[8]=BB_ShowMenu,Buttons[9]=BB_ShowVoiceMenu,Buttons[10]=BB_Zoom,Buttons[11]=BB_Dash,PovUp=BB_Jump,PovDown=BB_Duck,PovLeft=BB_UseAndReload,PovRight=BB_ShowWeaponMenu)
     ButtonConfigs(4)=(Name="SouthPaw RabbitFinger",Buttons[0]=BB_ShowWeaponMenu,Buttons[1]=BB_NextWeapon,Buttons[2]=BB_Jump,Buttons[3]=BB_PreviousWeapon,Buttons[4]=BB_ShowObjectives,Buttons[5]=BB_HealingTool,Buttons[6]=BB_Jump,Buttons[7]=BB_Fire,Buttons[8]=BB_ShowMenu,Buttons[9]=BB_ShowVoiceMenu,Buttons[10]=BB_Zoom,Buttons[11]=BB_Dash,PovUp=BB_MeleeAttack,PovDown=BB_Duck,PovLeft=BB_UseAndReload,PovRight=BB_ShowWeaponMenu)
     ButtonConfigs(5)=(Name="SouthPaw Clicker",Buttons[0]=BB_ShowWeaponMenu,Buttons[1]=BB_NextWeapon,Buttons[2]=BB_Dash,Buttons[3]=BB_PreviousWeapon,Buttons[4]=BB_ShowObjectives,Buttons[5]=BB_HealingTool,Buttons[6]=BB_MeleeAttack,Buttons[7]=BB_Fire,Buttons[8]=BB_ShowMenu,Buttons[9]=BB_ShowVoiceMenu,Buttons[10]=BB_Zoom,Buttons[11]=BB_Jump,PovUp=BB_Dash,PovDown=BB_Duck,PovLeft=BB_UseAndReload,PovRight=BB_ShowWeaponMenu)
     MenuTitle=(Text="Controls")
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
