class MenuSettingsInput extends MenuTemplateTitledB;

var() MenuToggle InvertLookToggle;
var() MenuToggle AutoAimToggle;
var() MenuToggle ControllerVibrationToggle;
var() MenuSlider XSensitivitySlider;
var() MenuSlider YSensitivitySlider;
var() MenuToggle UseJoystickToggle;

var() MenuSliderArrow InvertLookDown;
var() MenuSliderArrow AutoAimDown;
var() MenuSliderArrow ControllerVibrationDown;
var() MenuSliderArrow XSensitivityDown;
var() MenuSliderArrow YSensitivityDown;
var() MenuSliderArrow UseJoystickDown;

var() MenuSliderArrow InvertLookUp;
var() MenuSliderArrow AutoAimUp;
var() MenuSliderArrow ControllerVibrationUp;
var() MenuSliderArrow XSensitivityUp;
var() MenuSliderArrow YSensitivityUp;
var() MenuSliderArrow UseJoystickUp;

simulated function Init( String Args )
{
    local PlayerController PC;
    
    Super.Init( Args );

    PC = PlayerController(Owner);

    InvertLookToggle.bValue = int(PC.GetInvertLook());
    AutoAimToggle.bValue = int(PC.bAutoAim);
    ControllerVibrationToggle.bValue = int(PC.bEnableDamageForceFeedback);
    XSensitivitySlider.Value = PC.GetSensitivityX();
    YSensitivitySlider.Value = PC.GetSensitivityY();
	UseJoystickToggle.bValue = int(bool(ConsoleCommand("get ini:Engine.Engine.ViewportManager UseJoystick")));    
    
    UpdateXSensitivitySlider();
    UpdateYSensitivitySlider();
}

simulated function Commit()
{
    local PlayerController PC;
    PC = PlayerController(Owner);

    PC.SetInvertLook( bool(InvertLookToggle.bValue) );
    PC.bAutoAim = bool(AutoAimToggle.bValue);
    PC.UpdateForceFeedbackProperties( ForceFeedbackSupported(), bool(ControllerVibrationToggle.bValue), bool(ControllerVibrationToggle.bValue), bool(ControllerVibrationToggle.bValue), bool(ControllerVibrationToggle.bValue) );
    PC.SetSensitivityX( XSensitivitySlider.Value );
    PC.SetSensitivityY( YSensitivitySlider.Value );
	ConsoleCommand("set ini:Engine.Engine.ViewportManager UseJoystick" @ bool(UseJoystickToggle.bValue));

    PC.SaveConfig();
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout(C);
    
    LayoutWidgets( InvertLookToggle, UseJoystickToggle, 'SettingsItemLayout' );
    LayoutWidgets( InvertLookDown, UseJoystickDown, 'SettingsLeftArrowLayout' );
    LayoutWidgets( InvertLookUp, UseJoystickUp, 'SettingsRightArrowLayout' );
}

simulated function HandleInputBack()
{
    Commit();
    Super.HandleInputBack();
}

simulated function UpdateXSensitivitySlider()
{
    XSensitivitySlider.Blurred.Text = default.XSensitivitySlider.Blurred.Text $ ":" @ XSensitivitySlider.Value;
    XSensitivitySlider.Focused.Text = XSensitivitySlider.Blurred.Text;
}

simulated function UpdateYSensitivitySlider()
{
    YSensitivitySlider.Blurred.Text = default.YSensitivitySlider.Blurred.Text $ ":" @ YSensitivitySlider.Value;
    YSensitivitySlider.Focused.Text = YSensitivitySlider.Blurred.Text;
}

defaultproperties
{
     InvertLookToggle=(TextOff="Invert Look Up/Down: Off",TextOn="Invert Look Up/Down: On",Style="SettingsToggle")
     AutoAimToggle=(TextOff="Auto-Aim: Off",TextOn="Auto-Aim: On",Style="SettingsToggle")
     ControllerVibrationToggle=(TextOff="Controller Vibration: Off",TextOn="Controller Vibration: On",Platform=MWP_Xbox,Style="SettingsToggle")
     XSensitivitySlider=(MinValue=0.250000,MaxValue=10.000000,Delta=0.250000,MinScaleX=0.010000,OnSlide="UpdateXSensitivitySlider",Blurred=(Text="Left/Right Look Sensitivity"),Style="SettingsSlider")
     YSensitivitySlider=(MinValue=0.250000,MaxValue=10.000000,Delta=0.250000,MinScaleX=0.010000,OnSlide="UpdateYSensitivitySlider",Blurred=(Text="Up/Down Look Sensitivity"),Style="SettingsSlider")
     UseJoystickToggle=(TextOff="Joystick: Off",TextOn="Joystick: On",bHidden=1,Style="SettingsToggle")
     InvertLookDown=(WidgetName="InvertLookToggle",Style="SettingsSliderLeft")
     AutoAimDown=(WidgetName="AutoAimToggle",Style="SettingsSliderLeft")
     ControllerVibrationDown=(WidgetName="ControllerVibrationToggle",Platform=MWP_Xbox,Style="SettingsSliderLeft")
     XSensitivityDown=(WidgetName="XSensitivitySlider",Style="SettingsSliderLeft")
     YSensitivityDown=(WidgetName="YSensitivitySlider",Style="SettingsSliderLeft")
     UseJoystickDown=(WidgetName="UseJoystickToggle",bHidden=1,Style="SettingsSliderLeft")
     InvertLookUp=(WidgetName="InvertLookToggle",Style="SettingsSliderRight")
     AutoAimUp=(WidgetName="AutoAimToggle",Style="SettingsSliderRight")
     ControllerVibrationUp=(WidgetName="ControllerVibrationToggle",Platform=MWP_Xbox,Style="SettingsSliderRight")
     XSensitivityUp=(WidgetName="XSensitivitySlider",Style="SettingsSliderRight")
     YSensitivityUp=(WidgetName="YSensitivitySlider",Style="SettingsSliderRight")
     UseJoystickUp=(WidgetName="UseJoystickToggle",bHidden=1,Style="SettingsSliderRight")
     MenuTitle=(Text="Input Settings")
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
