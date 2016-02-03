class MenuSettingsVideo extends MenuTemplateTitledBXYA;

var() MenuButtonEnum ResolutionEnum;
var() MenuToggle FullScreenToggle;
var() MenuSlider BrightnessSlider;
var() MenuSlider ContrastSlider;
var() MenuSlider GammaSlider;
var() MenuToggle ReducedGoreToggle;

var() MenuSliderArrow ResolutionDown;
var() MenuSliderArrow FullScreenDown;
var() MenuSliderArrow BrightnessDown;
var() MenuSliderArrow ContrastDown;
var() MenuSliderArrow GammaDown;
var() MenuSliderArrow ReducedGoreDown;

var() MenuSliderArrow ResolutionUp;
var() MenuSliderArrow FullScreenUp;
var() MenuSliderArrow BrightnessUp;
var() MenuSliderArrow ContrastUp;
var() MenuSliderArrow GammaUp;
var() MenuSliderArrow ReducedGoreUp;

var() MenuSprite CalibrationSquares[32];
var() MenuSprite CalibrationArrow;
var() MenuSprite CalibrationBackground;
var() MenuText CalibrationText;

var() localized String StringBasic;
var() localized String StringAdvanced;
var() localized String StringResolution;
var() localized String StringCouldNotApply;

var() config bool ShowAdvanced;
var() bool NeedToApplySettings;

struct ResolutionSetting
{
    var() int Width;
    var() int Height;
};

var() Array<ResolutionSetting> ResolutionSettings;

simulated function Init( String Args )
{
    Super.Init(Args);
    LoadValues();
}

simulated function LoadValues()
{
    local PlayerController PC;
    local int i;
    local String CurrentRes, Res;
    local String ColorDepth;

    PC = PlayerController(Owner);

    GetVideoValues( BrightnessSlider.Value, ContrastSlider.Value, GammaSlider.Value );
    ReducedGoreToggle.bValue = class'GameInfo'.Default.GoreLevel; // Yay! A bNoNotReducedGore variable.
    
    FullScreenToggle.bValue = int(bool(PC.ConsoleCommand("ISFULLSCREEN")));
    
    ColorDepth = PC.ConsoleCommand( "GETCURRENTCOLORDEPTH" );

    CurrentRes = PC.ConsoleCommand( "GETCURRENTRES" ); // Note: does not include color depth.

    ResolutionSettings = default.ResolutionSettings;
    ResolutionEnum.Items.Remove( 0, ResolutionEnum.Items.Length );

    for( i = 0; i < ResolutionSettings.Length; ++i )
    {
		if( !bool( PC.ConsoleCommand( "SUPPORTEDRESOLUTION WIDTH="$ ResolutionSettings[i].Width @ "HEIGHT=" $ ResolutionSettings[i].Height @ "BITDEPTH=" $ ColorDepth ) ) )
		{
		    log("Not showing unsupported res:" @ ResolutionSettings[i].Width $ "x" $ ResolutionSettings[i].Height);

            ResolutionSettings.Remove( i, 1 );
            --i;
		    continue;
		}
		
		Res = ResolutionSettings[i].Width $ "x" $ ResolutionSettings[i].Height;
		
		if( Res == CurrentRes )
		{
		    ResolutionEnum.Current = ResolutionEnum.Items.Length;
		}
		
		ResolutionEnum.Items[ResolutionEnum.Items.Length] = StringResolution $ ":" @ Res;
    }
}

simulated function DoDynamicLayout( Canvas C )
{
    local int i;
    local float f;

    if( ShowAdvanced )
    {
        YLabel.Text = StringBasic;
        
        GammaSlider.bHidden = 0;
        GammaDown.bHidden = 0;
        GammaUp.bHidden = 0;
        ContrastSlider.bHidden = 0;
        ContrastDown.bHidden = 0;
        ContrastUp.bHidden = 0;
        
        for( i = 0; i < ArrayCount(CalibrationSquares); ++i )
        {
            CalibrationSquares[i].bHidden = 1;
        }

        CalibrationArrow.bHidden = 1;
        CalibrationBackground.bHidden = 1;
        CalibrationText.bHidden = 1;
    }
    else
    {
        YLabel.Text = StringAdvanced;

        GammaSlider.bHidden = 1;
        GammaDown.bHidden = 1;
        GammaUp.bHidden = 1;
        ContrastSlider.bHidden = 1;
        ContrastDown.bHidden = 1;
        ContrastUp.bHidden = 1;

        for( i = 0; i < ArrayCount(CalibrationSquares); ++i )
        {
            CalibrationSquares[i].bHidden = 0;
        }

        CalibrationArrow.bHidden = 0;
        CalibrationBackground.bHidden = 0;
        CalibrationText.bHidden = 0;

        for( i = 0; i < ArrayCount(CalibrationSquares); ++i )
        {
            f = float(i + 1) / float(ArrayCount(CalibrationSquares));
            // My kingdom for pow(x,y)!
            f = (f * f);
            f = (f * f * f);
        
            CalibrationSquares[i].DrawColor.R = int(f * 255.0);
            CalibrationSquares[i].DrawColor.G = CalibrationSquares[i].DrawColor.R;
            CalibrationSquares[i].DrawColor.B = CalibrationSquares[i].DrawColor.R;
        }
    }
    
    LayoutWidgets( ResolutionEnum, ReducedGoreToggle, 'SettingsItemLayout' );
    LayoutWidgets( ResolutionDown, ReducedGoreDown, 'SettingsLeftArrowLayout' );
    LayoutWidgets( ResolutionUp, ReducedGoreUp, 'SettingsRightArrowLayout' );

    Super.DoDynamicLayout(C);
}

simulated function UpdateBrightness()
{
    ConsoleCommand( "Brightness" @ BrightnessSlider.Value );
}

simulated function UpdateContrast()
{
    ConsoleCommand( "Contrast" @ ContrastSlider.Value );
}

simulated function UpdateGamma()
{
    ConsoleCommand( "Gamma" @ GammaSlider.Value);
}

simulated function UpdateReducedGore()
{
    class'GameInfo'.Default.GoreLevel = ReducedGoreToggle.bValue;
    class'GameInfo'.static.StaticSaveConfig();
}

simulated function OnXButton()
{
    // Cancel!
    CloseMenu();
}

simulated function OnYButton()
{
    ShowAdvanced = !ShowAdvanced;
    bDynamicLayoutDirty = true;
}

simulated function bool ApplyChanges()
{
    local PlayerController PC;
    local String Res;
    local String ColorDepth;
    local String Cmd;

    PC = PlayerController(Owner);
    
    if( FullScreenToggle.bValue != int(bool(PC.ConsoleCommand("ISFULLSCREEN"))) )
    {
        PC.ConsoleCommand( "TOGGLEFULLSCREEN" );
    
        if( (FullScreenToggle.bValue != int(bool(PC.ConsoleCommand("ISFULLSCREEN")))) )
        {
            return(false);
        }
    }
    
    Res = ResolutionSettings[ResolutionEnum.Current].Width $ "x" $ ResolutionSettings[ResolutionEnum.Current].Height;
    ColorDepth = PC.ConsoleCommand( "GETCURRENTCOLORDEPTH" );
    
    Cmd = "SETRES" @ Res $ "x" $ ColorDepth;
    
    PC.ConsoleCommand( Cmd );

    return( (FullScreenToggle.bValue == int(bool(PC.ConsoleCommand("ISFULLSCREEN")))) && (PC.ConsoleCommand( "GETCURRENTRES" ) == Res) );
}

simulated function DirtyScreenSettings()
{
    if( NeedToApplySettings )
    {
        return;
    }
    
    NeedToApplySettings = true;
    
    BLabel.Text = StringApply;
    HideXButton(0);
}

simulated function OnBButton()
{
    if( NeedToApplySettings )
    {
        NeedToApplySettings = false;
    
        if( !ApplyChanges() )
        {
            CallMenuClass( "XInterfaceCommon.MenuWarning", MakeQuotedString(StringCouldNotApply) );
        }
        
        LoadValues();

        BLabel.Text = default.BLabel.Text;
        HideXButton(1);
        
        return;
    }

    CloseMenu();
}

defaultproperties
{
     ResolutionEnum=(OnChange="DirtyScreenSettings",Platform=MWP_PC,Style="SettingsEnum")
     FullScreenToggle=(TextOff="Screen: Windowed",TextOn="Screen: Full-Screen",OnToggle="DirtyScreenSettings",Platform=MWP_PC,Style="SettingsToggle")
     BrightnessSlider=(MaxValue=1.000000,Delta=0.050000,MinScaleX=0.010000,OnSlide="UpdateBrightness",Blurred=(Text="Brightness"),Style="SettingsSlider")
     ContrastSlider=(MaxValue=1.000000,Delta=0.050000,MinScaleX=0.010000,OnSlide="UpdateContrast",Blurred=(Text="Contrast"),bHidden=1,Style="SettingsSlider")
     GammaSlider=(MaxValue=1.000000,Delta=0.050000,MinScaleX=0.010000,OnSlide="UpdateGamma",Blurred=(Text="Gamma"),bHidden=1,Style="SettingsSlider")
     ReducedGoreToggle=(TextOff="Reduced Gore: Off",TextOn="Reduced Gore: On",OnToggle="UpdateReducedGore",Style="SettingsToggle")
     ResolutionDown=(WidgetName="ResolutionEnum",Platform=MWP_PC,Style="SettingsSliderLeft")
     FullScreenDown=(WidgetName="FullScreenToggle",Platform=MWP_PC,Style="SettingsSliderLeft")
     BrightnessDown=(WidgetName="BrightnessSlider",Style="SettingsSliderLeft")
     ContrastDown=(WidgetName="ContrastSlider",Style="SettingsSliderLeft")
     GammaDown=(WidgetName="GammaSlider",Style="SettingsSliderLeft")
     ReducedGoreDown=(WidgetName="ReducedGoreToggle",Style="SettingsSliderLeft")
     ResolutionUp=(WidgetName="ResolutionEnum",Platform=MWP_PC,Style="SettingsSliderRight")
     FullScreenUp=(WidgetName="FullScreenToggle",Platform=MWP_PC,Style="SettingsSliderRight")
     BrightnessUp=(WidgetName="BrightnessSlider",Style="SettingsSliderRight")
     ContrastUp=(WidgetName="ContrastSlider",Style="SettingsSliderRight")
     GammaUp=(WidgetName="GammaSlider",Style="SettingsSliderRight")
     ReducedGoreUp=(WidgetName="ReducedGoreToggle",Style="SettingsSliderRight")
     CalibrationSquares(0)=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawPivot=DP_MiddleMiddle,PosX=0.200000,PosY=0.750000,ScaleX=3.300000,ScaleY=3.300000,Pass=3)
     CalibrationSquares(31)=(PosX=0.800000)
     CalibrationArrow=(WidgetTexture=TexRotator'PariahInterface.InterfaceTextures.ArrowDown',DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.700000,Pass=3)
     CalibrationBackground=(WidgetTexture=Texture'Engine.PariahWhiteTexture',DrawColor=(A=255),DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.750000,ScaleX=1.000000,ScaleY=0.100000,ScaleMode=MSM_Fit,Pass=2)
     CalibrationText=(Text="Pariah is best played when the brightness is adjusted so that the bar is black at the marker.",DrawPivot=DP_LowerLeft,PosX=0.100000,PosY=0.695000,ScaleX=0.750000,ScaleY=0.750000,MaxSizeX=0.800000,Style="MessageText")
     StringBasic="Basic"
     StringAdvanced="Advanced"
     StringResolution="Resolution"
     StringCouldNotApply="Your computer does not support the settings you selected."
     ResolutionSettings(0)=(Width=512,Height=384)
     ResolutionSettings(1)=(Width=640,Height=480)
     ResolutionSettings(2)=(Width=800,Height=500)
     ResolutionSettings(3)=(Width=800,Height=600)
     ResolutionSettings(4)=(Width=1024,Height=640)
     ResolutionSettings(5)=(Width=1024,Height=768)
     ResolutionSettings(6)=(Width=1152,Height=768)
     ResolutionSettings(7)=(Width=1152,Height=864)
     ResolutionSettings(8)=(Width=1280,Height=800)
     ResolutionSettings(9)=(Width=1280,Height=854)
     ResolutionSettings(10)=(Width=1280,Height=960)
     ResolutionSettings(11)=(Width=1280,Height=1024)
     ResolutionSettings(12)=(Width=1600,Height=1024)
     ResolutionSettings(13)=(Width=1600,Height=1200)
     ResolutionSettings(14)=(Width=1680,Height=1050)
     ResolutionSettings(15)=(Width=1920,Height=1200)
     YPlatform=MWP_PC
     XLabel=(Text="Cancel")
     XPlatform=MWP_PC
     XButtonHidden=1
     MenuTitle=(Text="Video Settings")
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
