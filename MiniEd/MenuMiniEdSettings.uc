class MenuMiniEdSettings extends MenuTemplateTitledB;

var() MenuSlider CameraSpeedSlider;
var() MenuToggle SnapToGridToggle;
var() MenuSlider HillToolStrengthSlider;
var() MenuSlider PaintFlowSlider;
var() MenuSlider SmoothingStrengthSlider;

var() MenuSliderArrow CameraSpeedDown;
var() MenuSliderArrow SnapToGridDown;
var() MenuSliderArrow HillToolStrengthDown;
var() MenuSliderArrow PaintFlowDown;
var() MenuSliderArrow SmoothingStrengthDown;

var() MenuSliderArrow CameraSpeedUp;
var() MenuSliderArrow SnapToGridUp;
var() MenuSliderArrow HillToolStrengthUp;
var() MenuSliderArrow PaintFlowUp;
var() MenuSliderArrow SmoothingStrengthUp;

var() MiniEdInfo Info;
var() MiniEdController C;

simulated function Init( String Args )
{
	Info = MiniEdInfo(Level.Game);
	Assert( Info != None );
	
	C = MiniEdController(Owner);
	Assert( C != None );

    CameraSpeedSlider.Value = C.GetCameraSpeed();
    SnapToGridToggle.bValue = int(Info.bSnapping);
    HillToolStrengthSlider.Value = float( ConsoleCommand( "TERRAIN HILLSTOOLSENSITIVIY" ) );
    PaintFlowSlider.Value = float( ConsoleCommand( "TERRAIN PAINT_FLOW" ) );
    SmoothingStrengthSlider.Value = float( ConsoleCommand( "TERRAIN SMOOTHING_STRENGTH" ) );
}

simulated function HandleInputBack()
{
    // TODO: Save config.
    CloseMenu();
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout(C);
    
    LayoutWidgets( CameraSpeedSlider, SmoothingStrengthSlider, 'SettingsItemLayout' );
    LayoutWidgets( CameraSpeedDown, SmoothingStrengthDown, 'SettingsLeftArrowLayout' );
    LayoutWidgets( CameraSpeedUp, SmoothingStrengthUp, 'SettingsRightArrowLayout' );    
}

simulated function UpdateCameraSpeed()
{
    C.SetCameraSpeed( CameraSpeedSlider.Value );
}

simulated function UpdateSnapToGrid()
{
    Info.bSnapping = bool(SnapToGridToggle.bValue);
}

simulated function UpdateHillToolStrength()
{
    ConsoleCommand( "TERRAIN HILLSTOOLSENSITIVIY VALUE=" $ int(HillToolStrengthSlider.Value) );
}

simulated function UpdatePaintFlow()
{
    ConsoleCommand( "TERRAIN PAINT_FLOW VALUE=" $ int(PaintFlowSlider.Value) );
}

simulated function UpdateSmoothingStrength()
{
    ConsoleCommand( "TERRAIN SMOOTHING_STRENGTH VALUE=" $ int(SmoothingStrengthSlider.Value) );
}

defaultproperties
{
     CameraSpeedSlider=(MaxValue=1.000000,Delta=0.100000,MinScaleX=0.010000,OnSlide="UpdateCameraSpeed",Blurred=(Text="Camera Speed"),Style="SettingsSlider")
     SnapToGridToggle=(TextOff="Snap to Grid: Off",TextOn="Snap to Grid: On",OnToggle="UpdateSnapToGrid",Style="SettingsToggle")
     HillToolStrengthSlider=(MinValue=10.000000,MaxValue=80.000000,Delta=10.000000,MinScaleX=0.010000,OnSlide="UpdateHillToolStrength",Blurred=(Text="Hill Tool Strength"),Style="SettingsSlider")
     PaintFlowSlider=(MinValue=80.000000,MaxValue=300.000000,Delta=20.000000,MinScaleX=0.010000,OnSlide="UpdatePaintFlow",Blurred=(Text="Terrain Paint Flow"),Style="SettingsSlider")
     SmoothingStrengthSlider=(MinValue=5.000000,MaxValue=125.000000,Delta=10.000000,MinScaleX=0.010000,OnSlide="UpdateSmoothingStrength",Blurred=(Text="Smoothing Strength"),Style="SettingsSlider")
     CameraSpeedDown=(WidgetName="CameraSpeedSlider",Style="SettingsSliderLeft")
     SnapToGridDown=(WidgetName="SnapToGridToggle",Style="SettingsSliderLeft")
     HillToolStrengthDown=(WidgetName="HillToolStrengthSlider",Style="SettingsSliderLeft")
     PaintFlowDown=(WidgetName="PaintFlowSlider",Style="SettingsSliderLeft")
     SmoothingStrengthDown=(WidgetName="SmoothingStrengthSlider",Style="SettingsSliderLeft")
     CameraSpeedUp=(WidgetName="CameraSpeedSlider",Style="SettingsSliderRight")
     SnapToGridUp=(WidgetName="SnapToGridToggle",Style="SettingsSliderRight")
     HillToolStrengthUp=(WidgetName="HillToolStrengthSlider",Style="SettingsSliderRight")
     PaintFlowUp=(WidgetName="PaintFlowSlider",Style="SettingsSliderRight")
     SmoothingStrengthUp=(WidgetName="SmoothingStrengthSlider",Style="SettingsSliderRight")
     MenuTitle=(Text="Editor Settings")
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
