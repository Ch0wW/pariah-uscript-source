class MenuDefaults extends MenuBase // This needs to extend MenuBase so we can take advantage of the magic default interpolation
    native;

var() nonlocalized MenuText             DefaultMenuText;
var() nonlocalized MenuDecoText         DefaultMenuDecoText;
var() nonlocalized MenuButtonSprite     DefaultMenuButtonSprite;
var() nonlocalized MenuButtonText       DefaultMenuButtonText;
var() nonlocalized MenuButtonEnum       DefaultMenuButtonEnum;
var() nonlocalized MenuCheckBoxSprite   DefaultMenuCheckBoxSprite;
var() nonlocalized MenuCheckBoxText     DefaultMenuCheckBoxText;
var() nonlocalized MenuEditBox          DefaultMenuEditBox;
var() nonlocalized MenuBindingBox       DefaultMenuBindingBox;
var() nonlocalized MenuStringList       DefaultMenuStringList;
var() nonlocalized MenuScrollBar        DefaultMenuScrollBar;
var() nonlocalized MenuSlider           DefaultMenuSlider;
var() nonlocalized MenuToggle           DefaultMenuToggle;

var() nonlocalized MenuText             TitleText;             // In the title-bar of most menus
var() nonlocalized MenuText             MessageText;           // For text to be displayed in the middle of the menu (warnings, messages, etc)
var() nonlocalized MenuText             MedMessageText;        // Not super fat message text.
var() nonlocalized MenuText             LongMessageText;       // For paragraphs of message text
var() nonlocalized MenuText             NormalLabel;           // Same size and such as MessageText but without the wrapping magic.
var() nonlocalized MenuText             SmallLabel;            // Like NormalLabel, just smaller.

var() nonlocalized MenuText             DetailLabel;           // Like NormalLabel but right-justified
var() nonlocalized MenuText             DetailValue;            // Matches DetailLabel; to be used with DetailLabelsLayout & DetailValuesLayout

var() nonlocalized MenuButtonText       TitledTextOption;      // For titled menus containing lists of text option buttons (main menu etc)
var() nonlocalized MenuButtonText       CenteredTextOption;    // Same as TitledTextOption except centered on the screen

var() nonlocalized MenuSlider           SettingsSlider;        // All sliders in the settings heirarchy
var() nonlocalized MenuButtonEnum       SettingsEnum;          // All enums in the settings heirarchy
var() nonlocalized MenuToggle           SettingsToggle;        // All toggles in the settings heirarchy

var() nonlocalized MenuSliderArrow      SettingsSliderLeft;    // These wrap all Sliders, Enums and Toggles in the settings heirarchy
var() nonlocalized MenuSliderArrow      SettingsSliderRight;

var() nonlocalized MenuStringList       TitledStringList;      // MenuStringList + TitledText Style + TitledOptionLayout! EG: Sign in account list, profile lists, map lists, etc.
var() nonlocalized MenuStringList       TitledStringListBar;   
var() nonlocalized MenuStringList       TitledCheckboxList;    // For a left-hand column of checkboxes TitledStringList
var() nonlocalized MenuScrollArea       TitledStringListScrollArea;
var() nonlocalized MenuScrollBar        TitledStringListScrollBar;
var() nonlocalized MenuButtonSprite     TitledStringListArrowUp;
var() nonlocalized MenuButtonSprite     TitledStringListArrowDown;
var() nonlocalized MenuActiveWidget     TitledStringListPageScrollArea;

var() nonlocalized MenuButtonSprite     ButtonChecked;         // For hackalicious checkboxes beside string lists
var() nonlocalized MenuButtonSprite     ButtonUnchecked;

var() nonlocalized MenuSlider           ProgressBarSlider;

var() nonlocalized MenuText             MiniEdLabel;

var() nonlocalized MenuSlider           MiniEdSlider;          // All sliders in the MiniEd

var() nonlocalized MenuSliderArrow      MiniEdSliderLeft;      // These wrap all Sliders, Enums and Toggles in the MiniEd
var() nonlocalized MenuSliderArrow      MiniEdSliderRight;

var() nonlocalized MenuStringList       ServerInfoColumn;
var() nonlocalized MenuEditBox          NormalEditBox;
var() nonlocalized MenuEditBox          EditListBox;

var() nonlocalized MenuStringList       CyanButtonList;         // A StringList of ListButtons
var() nonlocalized MenuStringList       CheveronButtonList;
var() nonlocalized MenuStringList       CyanButtonListWide;

var() nonlocalized Array<FontMapping>   FontMappings;

var() nonlocalized MenuSprite           FullScreen;     // For background pics fit to the whole screen
var() nonlocalized MenuSprite           Darken;         // For a black tint fit the whole screen
var() nonlocalized MenuSprite           Border;         // A stretched background border; only slightly darkens background
var() nonlocalized MenuSprite           DarkBorder;     // Same as Border but darker.
var() nonlocalized MenuSprite           BlackBorder;    // A stretched background border for the Scroll bar area

var() nonlocalized MenuText             ImpactLabelText;     
var() nonlocalized MenuText             LabelText;      // Default text for labels etc
var() nonlocalized MenuText             StatsText;
var() nonlocalized MenuText             HugeText;

var() nonlocalized MenuButtonText       PushButtonRounded;     // For "OKAY" / "BACK" buttons, etc
var() nonlocalized MenuButtonText       SmallPushButtonRounded;

var() nonlocalized MenuText             MiniedDrawerText; //text on the drawers
var() nonlocalized MenuText             MiniedButtonsText; //text under the buttons

var() nonlocalized MenuStringList       ButtonList;     // A StringList of ListButtons
var() nonlocalized MenuStringList       SmallButtonList;

var() nonlocalized MenuSprite           XboxButtonA;
var() nonlocalized MenuSprite           XboxButtonB;
var() nonlocalized MenuSprite           XboxButtonX;
var() nonlocalized MenuSprite           XboxButtonY;
var() nonlocalized MenuSprite           XboxButtonWhite;
var() nonlocalized MenuSprite           XboxButtonBlack;

var() nonlocalized MenuButtonSprite     VerticalScrollBarArrowUp;
var() nonlocalized MenuButtonSprite     VerticalScrollBarArrowDown;
var() nonlocalized MenuScrollBar        VerticalScrollBar;
var() nonlocalized MenuScrollBar        NewVerticalScrollBar;

var() nonlocalized MenuButtonText       URLButton;

var() nonlocalized Color                RedColor;
var() nonlocalized Color                BlueColor;
var() nonlocalized Color                WhiteColor;

var() nonlocalized MenuButtonText       ServerBrowserActiveCell;
var() nonlocalized MenuButtonText       ServerBrowserPassiveCell;

var() const class<MenuVirtualKeyboard> VirtualKeyboardClass;

var() Material MouseCursorTexture;
var() float MouseCursorScale;

var() Material WhiteTexture; // For text cursors.

var() WidgetLayout CenteredTextLayout;

var() WidgetLayout TitledOptionLayout;
var() WidgetLayout TitledValueLayout;

var() WidgetLayout SettingsItemLayout;
var() WidgetLayout SettingsLeftArrowLayout;
var() WidgetLayout SettingsRightArrowLayout;

var() WidgetLayout EnumLabelLayout;
var() WidgetLayout EnumLeftArrowLayout;
var() WidgetLayout EnumOptionLayout;
var() WidgetLayout EnumRightArrowLayout;

var() WidgetLayout DetailLabelsLayout;  // For menus with two columns of text values, centered on the screen
var() WidgetLayout DetailValuesLayout;

var() WidgetLayout BindingLabelLayout;
var() WidgetLayout BindingBoxLayoutA;
var() WidgetLayout BindingBoxLayoutB;

defaultproperties
{
     DefaultMenuText=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=200,G=200,R=200,A=255),ScaleX=0.800000,ScaleY=0.800000,Pass=3)
     DefaultMenuDecoText=(MenuFont=Font'Engine.FontMono',DrawColor=(B=200,G=200,R=200,A=222),TimePerCharacter=0.055000,TimePerLineFeed=0.750000,TimePerLoopEnd=2.000000,TimePerCursorBlink=0.080000,CursorScale=0.750000,CursorOffset=0.250000,bCapitalizeText=1)
     DefaultMenuButtonText=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=180,G=180,R=180,A=255),DrawPivot=DP_MiddleMiddle,ScaleX=0.500000,ScaleY=0.500000))
     DefaultMenuCheckBoxText=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=180,G=180,R=180,A=255),DrawPivot=DP_MiddleMiddle,ScaleX=0.500000,ScaleY=0.500000))
     DefaultMenuEditBox=(TimePerCursorBlink=0.200000,CursorScale=0.600000,Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=180,G=180,R=180,A=255),DrawPivot=DP_MiddleMiddle,ScaleX=0.700000,ScaleY=0.700000))
     DefaultMenuBindingBox=(BackgroundSelected=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.BindingBoxFocused',DrawColor=(G=150,R=255,A=255)),Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=180,G=180,R=180,A=255),DrawPivot=DP_MiddleMiddle,ScaleX=0.500000,ScaleY=0.500000),BackgroundBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.BindingBoxBlurred',DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,ScaleX=0.205000,ScaleY=0.050000,ScaleMode=MSM_FitStretch),BackgroundFocused=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.BindingBoxFocused',DrawColor=(B=255,G=255,R=255,A=255)),Pass=1)
     DefaultMenuSlider=(SliderBlurred=(DrawColor=(B=45,G=35,R=15,A=255),DrawPivot=DP_MiddleLeft,ScaleX=0.285000,ScaleY=0.056000,ScaleMode=MSM_FitStretch),SliderFocused=(DrawColor=(B=80,G=65,R=19,A=255)),bRelativeSliderCoords=1,MaxValue=10.000000,Delta=1.000000,Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=90,G=80,R=60,A=255),DrawPivot=DP_MiddleLeft,PosX=0.025000,ScaleX=0.600000,ScaleY=0.700000),Focused=(DrawColor=(B=180,G=180,R=180,A=255)),BackgroundBlurred=(DrawColor=(A=128),DrawPivot=DP_MiddleLeft,ScaleX=0.285000,ScaleY=0.056000,ScaleMode=MSM_FitStretch),BackgroundFocused=(DrawColor=(A=255)),bRelativeBackgroundCoords=1,Pass=2)
     TitleText=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=143,G=150,R=105,A=255),DrawPivot=DP_LowerLeft,ScaleX=0.800000,ScaleY=0.800000,Pass=4)
     MessageText=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=200,G=200,R=200,A=255),DrawPivot=DP_MiddleLeft,PosX=0.150000,PosY=0.500000,ScaleX=0.800000,ScaleY=0.800000,MaxSizeX=0.700000,bWordWrap=1,TextAlign=TA_Center,Pass=4)
     MedMessageText=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=200,G=200,R=200,A=255),DrawPivot=DP_MiddleLeft,PosX=0.150000,PosY=0.500000,ScaleX=0.800000,ScaleY=0.800000,MaxSizeX=0.700000,bWordWrap=1,Pass=4)
     LongMessageText=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=200,G=200,R=200,A=255),PosX=0.150000,PosY=0.200000,ScaleX=0.730000,ScaleY=0.730000,MaxSizeX=0.700000,bWordWrap=1,Pass=4)
     NormalLabel=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=200,G=200,R=200,A=255),DrawPivot=DP_MiddleLeft,ScaleX=0.800000,ScaleY=0.800000,Pass=4)
     SmallLabel=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=200,G=200,R=200,A=255),DrawPivot=DP_MiddleLeft,ScaleX=0.600000,ScaleY=0.600000,Pass=4)
     DetailLabel=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=200,G=200,R=200,A=255),DrawPivot=DP_MiddleRight,ScaleX=0.800000,ScaleY=0.800000,MaxSizeX=0.450000,Pass=4)
     DetailValue=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=200,G=200,R=200,A=255),DrawPivot=DP_MiddleLeft,ScaleX=0.800000,ScaleY=0.800000,MaxSizeX=0.450000,Pass=4)
     TitledTextOption=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=127,G=127,R=127,A=255),DrawPivot=DP_MiddleLeft,PosX=0.500000,ScaleX=0.800000,ScaleY=0.800000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),BackgroundBlurred=(WidgetTexture=Texture'Engine.DefaultTexture',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255),DrawPivot=DP_MiddleLeft,PosX=-0.050000,ScaleX=0.340000,ScaleY=0.060000,ScaleMode=MSM_Fit),BackgroundFocused=(WidgetTexture=FinalBlend'PariahInterface.InterfaceShaders.fbBtnHighlight',DrawColor=(B=255,G=255,R=255,A=255),ScaleX=0.345000,ScaleY=0.035000),bRelativeBackgroundCoords=1,Pass=4)
     CenteredTextOption=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=127,G=127,R=127,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.500000,ScaleX=0.800000,ScaleY=0.800000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),BackgroundBlurred=(WidgetTexture=Texture'Engine.DefaultTexture',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255),DrawPivot=DP_MiddleMiddle,ScaleX=0.450000,ScaleY=0.060000,ScaleMode=MSM_Fit),BackgroundFocused=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.HighlightSelected',DrawColor=(B=177,G=166,R=127,A=255),ScaleX=0.695000,ScaleMode=MSM_FitStretch),bRelativeBackgroundCoords=1,Pass=4)
     SettingsSlider=(SliderBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.SliderFill',DrawColor=(B=45,G=35,R=15,A=255),DrawPivot=DP_MiddleLeft,PosX=-0.025000,ScaleX=0.470000,ScaleY=0.056000,ScaleMode=MSM_FitStretch),SliderFocused=(DrawColor=(B=80,G=65,R=19,A=255)),bRelativeSliderCoords=1,Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=90,G=80,R=60,A=255),DrawPivot=DP_MiddleLeft,ScaleX=0.600000,ScaleY=0.700000),Focused=(DrawColor=(B=180,G=180,R=180,A=255)),BackgroundBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.SliderBackground',DrawColor=(A=128),DrawPivot=DP_MiddleLeft,PosX=-0.025000,ScaleX=0.470000,ScaleY=0.056000,ScaleMode=MSM_FitStretch),BackgroundFocused=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.SliderBackground',DrawColor=(A=255)),bRelativeBackgroundCoords=1,Pass=4)
     SettingsEnum=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=90,G=80,R=60,A=255),DrawPivot=DP_MiddleLeft,ScaleX=0.600000,ScaleY=0.700000),Focused=(DrawColor=(B=180,G=180,R=180,A=255)),BackgroundBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.SliderBackground',DrawColor=(A=128),DrawPivot=DP_MiddleLeft,PosX=-0.025000,ScaleX=0.470000,ScaleY=0.056000,ScaleMode=MSM_FitStretch),BackgroundFocused=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.SliderBackground',DrawColor=(A=255)),bRelativeBackgroundCoords=1,Pass=4)
     SettingsToggle=(ToggledBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.SliderFill',DrawColor=(B=45,G=35,R=15,A=255),DrawPivot=DP_MiddleLeft,PosX=-0.025000,ScaleX=0.470000,ScaleY=0.056000,ScaleMode=MSM_FitStretch),ToggledFocused=(DrawColor=(B=80,G=65,R=19,A=255)),bRelativeToggleCoords=1,Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=90,G=80,R=60,A=255),DrawPivot=DP_MiddleLeft,ScaleX=0.600000,ScaleY=0.700000),Focused=(DrawColor=(B=180,G=180,R=180,A=255)),BackgroundBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.SliderBackground',DrawColor=(A=128),DrawPivot=DP_MiddleLeft,PosX=-0.025000,ScaleX=0.470000,ScaleY=0.056000,ScaleMode=MSM_FitStretch),BackgroundFocused=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.SliderBackground',DrawColor=(A=255)),bRelativeBackgroundCoords=1,Pass=4)
     SettingsSliderLeft=(Blurred=(WidgetTexture=TexRotator'PariahInterface.InterfaceTextures.ArrowLeft',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleX=1.000000,ScaleY=1.000000),bRelativeBackgroundCoords=1,bIgnoreController=1,Pass=4)
     SettingsSliderRight=(ArrowDir=AD_Right,Blurred=(WidgetTexture=TexOscillator'PariahInterface.InterfaceTextures.arrowright_pulse',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleX=1.000000,ScaleY=1.000000),bRelativeBackgroundCoords=1,bIgnoreController=1,Pass=4)
     TitledStringList=(Template=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=127,G=127,R=127,A=255),DrawPivot=DP_MiddleLeft,PosX=0.500000,ScaleX=0.800000,ScaleY=0.800000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),BackgroundBlurred=(WidgetTexture=Texture'Engine.DefaultTexture',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255),DrawPivot=DP_MiddleLeft,PosX=-0.080000,ScaleX=0.340000,ScaleY=0.060000,ScaleMode=MSM_Fit),BackgroundFocused=(WidgetTexture=FinalBlend'PariahInterface.InterfaceShaders.fbBtnHighlight',DrawColor=(B=255,G=255,R=255,A=255),ScaleX=0.345000,ScaleY=0.035000),bRelativeBackgroundCoords=1),PosX1=0.150000,PosY1=0.300000,PosX2=0.150000,PosY2=0.700000,DisplayCount=8,Pass=4)
     TitledStringListBar=(Template=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=127,G=127,R=127,A=255),DrawPivot=DP_MiddleLeft,PosX=0.500000,ScaleX=0.800000,ScaleY=0.800000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),BackgroundBlurred=(WidgetTexture=Texture'Engine.DefaultTexture',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255),DrawPivot=DP_MiddleLeft,PosX=-0.050000,ScaleX=0.340000,ScaleY=0.060000,ScaleMode=MSM_Fit),BackgroundFocused=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.HighlightSelected',DrawColor=(B=177,G=166,R=127,A=255),ScaleX=0.345000,ScaleY=0.035000),bRelativeBackgroundCoords=1),PosX1=0.100000,PosY1=0.300000,PosX2=0.100000,PosY2=0.700000,DisplayCount=8,Pass=4)
     TitledCheckboxList=(Template=(BackgroundBlurred=(WidgetTexture=Texture'InterfaceContent.Menu.CheckBoxChecked',RenderStyle=STY_Alpha,DrawColor=(B=180,G=180,R=180,A=255),DrawPivot=DP_MiddleLeft,PosY=-0.002000,ScaleX=1.000000,ScaleY=1.000000),BackgroundFocused=(DrawColor=(B=255,G=255,R=255,A=255)),bRelativeBackgroundCoords=1,bIgnoreController=1),PosX1=0.115000,PosY1=0.300000,PosX2=0.115000,PosY2=0.700000,DisplayCount=8,Pass=5)
     TitledStringListScrollArea=(X1=0.080000,Y1=0.250000,X2=0.880000,Y2=0.750000)
     TitledStringListScrollBar=(PosX1=0.900000,PosY1=0.320000,PosX2=0.900000,PosY2=0.680000,MinScaleX=0.015000,MinScaleY=0.010000,Blurred=(WidgetTexture=Texture'Engine.PariahWhiteTexture',RenderStyle=STY_Alpha,DrawColor=(G=150,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_FitStretch),Focused=(DrawColor=(G=150,R=255,A=255)),SelectedBlurred=(WidgetTexture=Texture'Engine.PariahWhiteTexture',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_FitStretch),SelectedFocused=(DrawColor=(B=255,G=255,R=255,A=255)),bIgnoreController=1,Pass=5)
     TitledStringListArrowUp=(Blurred=(WidgetTexture=TexRotator'PariahInterface.InterfaceTextures.Arrowup',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,PosX=0.900000,PosY=0.300000,ScaleX=0.700000,ScaleY=0.700000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),bRelativeBackgroundCoords=1,bIgnoreController=1,Pass=4)
     TitledStringListArrowDown=(Blurred=(WidgetTexture=TexRotator'PariahInterface.InterfaceTextures.ArrowDown',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,PosX=0.900000,PosY=0.700000,ScaleX=0.700000,ScaleY=0.700000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),bRelativeBackgroundCoords=1,bIgnoreController=1,Pass=4)
     TitledStringListPageScrollArea=(bIgnoreController=1,Pass=3)
     ButtonChecked=(Blurred=(WidgetTexture=Texture'InterfaceContent.Menu.CheckBoxChecked',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleX=1.000000,ScaleY=1.000000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),bRelativeBackgroundCoords=1,bIgnoreController=1,Pass=5)
     ButtonUnchecked=(Blurred=(WidgetTexture=Texture'InterfaceContent.Menu.CheckBoxUnchecked',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,PosX=0.900000,PosY=0.300000,ScaleX=0.700000,ScaleY=0.700000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),bRelativeBackgroundCoords=1,bIgnoreController=1,Pass=5)
     ProgressBarSlider=(SliderBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.SliderFill',DrawColor=(B=45,G=35,R=15,A=255),DrawPivot=DP_MiddleLeft,PosX=0.290000,PosY=0.600000,ScaleX=0.420000,ScaleY=0.056000,ScaleMode=MSM_FitStretch),MaxValue=1.000000,BackgroundBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.SliderBackground',DrawColor=(B=45,G=35,R=15,A=255),DrawPivot=DP_MiddleLeft,PosX=0.290000,PosY=0.600000,ScaleX=0.420000,ScaleY=0.056000,ScaleMode=MSM_FitStretch),bDisabled=1,Pass=4)
     MiniEdLabel=(MenuFont=Font'Engine.FontSmall',DrawColor=(B=180,G=180,R=180,A=255),DrawPivot=DP_MiddleLeft,PosX=0.700000,ScaleX=0.800000,ScaleY=0.800000)
     MiniEdSlider=(SliderBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.SliderFill',DrawColor=(B=45,G=35,R=15,A=255),DrawPivot=DP_MiddleLeft,PosX=0.040000,PosY=0.048000,ScaleX=0.200000,ScaleY=0.040000,ScaleMode=MSM_FitStretch),SliderFocused=(DrawColor=(B=80,G=65,R=19,A=255)),bRelativeSliderCoords=1,MaxValue=100.000000,Delta=10.000000,Value=50.000000,Blurred=(MenuFont=Font'Engine.FontSmall',DrawColor=(B=180,G=180,R=180,A=255),DrawPivot=DP_MiddleLeft,PosX=0.700000,PosY=0.500000,ScaleX=0.800000,ScaleY=0.800000),Focused=(DrawColor=(B=180,G=180,R=180,A=255)),BackgroundBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.SliderBackground',DrawColor=(A=128),DrawPivot=DP_MiddleLeft,PosX=0.040000,PosY=0.048000,ScaleX=0.200000,ScaleY=0.040000,ScaleMode=MSM_FitStretch),BackgroundFocused=(DrawColor=(A=255)),bRelativeBackgroundCoords=1,Pass=2)
     MiniEdSliderLeft=(Blurred=(WidgetTexture=TexRotator'PariahInterface.InterfaceTextures.ArrowLeft',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,PosX=0.725000,PosY=0.559000,ScaleX=0.700000,ScaleY=0.700000),bRelativeBackgroundCoords=1,bIgnoreController=1,Pass=2)
     MiniEdSliderRight=(ArrowDir=AD_Right,Blurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.ArrowRight',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,PosX=0.958000,PosY=0.559000,ScaleX=0.700000,ScaleY=0.700000),bRelativeBackgroundCoords=1,bIgnoreController=1,Pass=2)
     ServerInfoColumn=(Template=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=127,G=127,R=127,A=255),DrawPivot=DP_MiddleLeft,ScaleX=0.600000,ScaleY=0.600000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),BackgroundBlurred=(WidgetTexture=Texture'Engine.DefaultTexture',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255),DrawPivot=DP_MiddleLeft,PosX=-0.020000,ScaleX=0.870000,ScaleY=0.052000,ScaleMode=MSM_Fit),BackgroundFocused=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.HighlightSelected',DrawColor=(B=177,G=166,R=127,A=255),ScaleX=0.695000,ScaleMode=MSM_FitStretch),bRelativeBackgroundCoords=1),Pass=4)
     NormalEditBox=(FilterMode=FM_AlphaNumeric,Blurred=(MenuFont=Font'Engine.FontMedium',DrawPivot=DP_MiddleLeft,ScaleX=0.700000,ScaleY=0.700000,MaxSizeX=0.430000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),BackgroundBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.EditBoxBlurred',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleLeft,PosX=-0.020000,ScaleX=0.460000,ScaleY=0.060000,ScaleMode=MSM_FitStretch),BackgroundFocused=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.EditBoxFocused',DrawColor=(B=255,G=255,R=255,A=255)),bRelativeBackgroundCoords=1)
     EditListBox=(FilterMode=FM_None,Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=127,G=127,R=127,A=255),DrawPivot=DP_MiddleLeft,PosX=0.500000,ScaleX=0.800000,ScaleY=0.800000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),BackgroundBlurred=(WidgetTexture=Texture'Engine.DefaultTexture',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255),DrawPivot=DP_MiddleLeft,PosX=-0.050000,ScaleX=0.340000,ScaleY=0.060000,ScaleMode=MSM_Fit),BackgroundFocused=(WidgetTexture=FinalBlend'PariahInterface.InterfaceShaders.fbBtnHighlight',DrawColor=(B=255,G=255,R=255,A=255),ScaleX=0.345000,ScaleY=0.035000),bRelativeBackgroundCoords=1,Pass=4)
     CyanButtonList=(Template=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=90,G=80,R=60,A=255),DrawPivot=DP_MiddleLeft,PosX=0.145000,ScaleX=0.700000,ScaleY=0.800000),Focused=(DrawColor=(B=150,G=150,R=150,A=255)),BackgroundBlurred=(WidgetTexture=Texture'Engine.DefaultTexture',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255),DrawPivot=DP_MiddleLeft,PosX=-0.050000,ScaleX=0.280000,ScaleY=0.060000,ScaleMode=MSM_Fit),BackgroundFocused=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.MenuTitleLine',DrawColor=(B=200,G=172,R=115,A=150),ScaleX=0.390000),bRelativeBackgroundCoords=1))
     CheveronButtonList=(Template=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=127,G=127,R=127,A=255),DrawPivot=DP_MiddleLeft,PosX=0.145000,ScaleX=0.700000,ScaleY=0.800000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),BackgroundBlurred=(WidgetTexture=Texture'Engine.DefaultTexture',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255),DrawPivot=DP_MiddleLeft,PosX=-0.050000,ScaleX=0.280000,ScaleY=0.060000,ScaleMode=MSM_Fit),BackgroundFocused=(WidgetTexture=FinalBlend'PariahInterface.InterfaceShaders.fbBtnHighlight',DrawColor=(B=255,G=255,R=255,A=255),ScaleX=0.345000,ScaleY=0.035000),bRelativeBackgroundCoords=1))
     CyanButtonListWide=(Template=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=127,G=127,R=127,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.500000,ScaleX=0.700000,ScaleY=0.700000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),BackgroundFocused=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.HighlightSelected',RenderStyle=STY_Alpha,DrawColor=(B=177,G=166,R=127,A=255),DrawPivot=DP_MiddleMiddle,PosY=-0.004000,ScaleX=0.400000,ScaleY=0.045000,ScaleMode=MSM_FitStretch),bRelativeBackgroundCoords=1))
     FullScreen=(ScaleX=0.625000,ScaleY=0.936000)
     Darken=(WidgetTexture=Texture'Engine.PariahWhiteTexture',RenderStyle=STY_Alpha,DrawColor=(A=180),DrawPivot=DP_MiddleMiddle,PosX=0.500000,PosY=0.500000,ScaleX=1.000000,ScaleY=1.000000,ScaleMode=MSM_Fit)
     Border=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.HighlightSelected',RenderStyle=STY_Alpha,DrawColor=(A=64),ScaleMode=MSM_FitStretch,Pass=1)
     DarkBorder=(WidgetTexture=Texture'InterfaceContent.Menu.BackFill',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),ScaleMode=MSM_FitStretch,Pass=1)
     BlackBorder=(WidgetTexture=Texture'InterfaceContent.Menu.BorderBoxD',RenderStyle=STY_Alpha,DrawColor=(A=175),ScaleMode=MSM_FitStretch,Pass=1)
     ImpactLabelText=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleLeft,ScaleX=0.700000,ScaleY=0.700000,Pass=1)
     LabelText=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=180,G=180,R=180,A=255),DrawPivot=DP_MiddleRight,ScaleX=0.700000,ScaleY=0.700000,Pass=1)
     StatsText=(MenuFont=Font'Engine.FontSmall',DrawColor=(B=180,G=180,R=180,A=255),ScaleX=1.000000,ScaleY=1.000000,Pass=1)
     HugeText=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=180,G=180,R=180,A=255),PosX=0.500000,ScaleX=0.500000,ScaleY=0.600000,Pass=1)
     PushButtonRounded=(Blurred=(MenuFont=Font'Engine.FontMedium',ScaleX=0.700000,ScaleY=0.700000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),BackgroundBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.BottomBlurred',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,ScaleX=0.360000,ScaleY=0.060000,ScaleMode=MSM_FitStretch),BackgroundFocused=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.BottomFocused',DrawColor=(B=255,G=255,R=255,A=255)),bRelativeBackgroundCoords=1)
     SmallPushButtonRounded=(Blurred=(MenuFont=Font'Engine.FontMedium',ScaleX=0.600000,ScaleY=0.600000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),BackgroundBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.BTNBlurred',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.008500,ScaleX=0.340000,ScaleY=0.051400,ScaleMode=MSM_FitStretch),BackgroundFocused=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.BTNFocused',DrawColor=(B=255,G=255,R=255,A=255)),bRelativeBackgroundCoords=1)
     MiniedDrawerText=(MenuFont=Font'Engine.FontSmall',DrawColor=(B=160,G=160,R=160,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.500000,ScaleX=0.700000,ScaleY=0.700000)
     MiniedButtonsText=(MenuFont=Font'Engine.FontSmall',DrawColor=(B=160,G=160,R=160,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.500000,ScaleX=0.600000,ScaleY=0.600000)
     ButtonList=(Template=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=160,G=160,R=160,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.500000,ScaleX=0.500000,ScaleY=0.600000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),BackgroundFocused=(WidgetTexture=FinalBlend'InterfaceContent.Menu.fbListButtonHighLight',RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosY=-0.004000,ScaleX=0.400000,ScaleY=0.045000,ScaleMode=MSM_FitStretch),bRelativeBackgroundCoords=1))
     SmallButtonList=(Template=(Blurred=(MenuFont=Font'Engine.FontSmall',DrawColor=(B=160,G=160,R=160,A=255),DrawPivot=DP_MiddleMiddle,PosX=0.500000,ScaleX=1.000000,ScaleY=1.000000),Focused=(DrawColor=(B=255,G=255,R=255,A=255)),BackgroundFocused=(WidgetTexture=FinalBlend'InterfaceContent.Menu.fbListButtonHighLight',RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,PosY=-0.004000,ScaleX=0.400000,ScaleY=0.040000,ScaleMode=MSM_FitStretch),bRelativeBackgroundCoords=1))
     XboxButtonA=(WidgetTexture=Texture'InterfaceContent.Controller.ControllerIcons',TextureCoords=(X1=3,X2=32,Y2=31),RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),ScaleX=0.850000,ScaleY=0.850000,Pass=2)
     XboxButtonB=(WidgetTexture=Texture'InterfaceContent.Controller.ControllerIcons',TextureCoords=(X1=33,X2=64,Y2=31),RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),ScaleX=0.850000,ScaleY=0.850000,Pass=2)
     XboxButtonX=(WidgetTexture=Texture'InterfaceContent.Controller.ControllerIcons',TextureCoords=(X1=65,X2=95,Y2=31),RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),ScaleX=0.850000,ScaleY=0.850000,Pass=2)
     XboxButtonY=(WidgetTexture=Texture'InterfaceContent.Controller.ControllerIcons',TextureCoords=(X1=96,X2=126,Y2=31),RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),ScaleX=0.850000,ScaleY=0.850000,Pass=2)
     XboxButtonWhite=(WidgetTexture=Texture'InterfaceContent.Controller.ControllerIcons',TextureCoords=(X1=3,X2=-32,Y2=31),RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),ScaleX=0.850000,ScaleY=0.850000,Pass=2)
     XboxButtonBlack=(WidgetTexture=Texture'InterfaceContent.Controller.ControllerIcons',TextureCoords=(X1=96,X2=-126,Y2=31),RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),ScaleX=0.850000,ScaleY=0.850000,Pass=2)
     VerticalScrollBarArrowUp=(Blurred=(WidgetTexture=TexRotator'PariahInterface.InterfaceTextures.ScrollArrowUp',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleX=0.700000,ScaleY=0.700000),bRelativeBackgroundCoords=1,bIgnoreController=1)
     VerticalScrollBarArrowDown=(Blurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.ScrollArrowDown',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleX=0.700000,ScaleY=0.700000),bRelativeBackgroundCoords=1,bIgnoreController=1)
     VerticalScrollBar=(MinScaleX=0.030000,MinScaleY=0.075000,Blurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.BottomBlurred',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_FitStretch),Focused=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.BottomFocused'),SelectedBlurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.BottomFocused',DrawColor=(B=255,G=255,R=255,A=255)),bIgnoreController=1)
     NewVerticalScrollBar=(MinScaleX=0.020000,MinScaleY=0.060000,Blurred=(WidgetTexture=Texture'PariahInterface.InterfaceTextures.SliderBackground',RenderStyle=STY_Alpha,DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_FitStretch),Focused=(WidgetTexture=FinalBlend'InterfaceContent.Menu.fbNewHightlight'),SelectedBlurred=(WidgetTexture=FinalBlend'InterfaceContent.Menu.fbNewHightlight'),bIgnoreController=1)
     URLButton=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=220,A=255),DrawPivot=DP_MiddleLeft,PosX=0.500000,ScaleX=0.800000,ScaleY=0.800000),Focused=(DrawColor=(B=255,A=255)),bRelativeBackgroundCoords=1,bIgnoreController=1,Pass=4)
     RedColor=(B=23,G=23,R=166,A=255)
     BlueColor=(B=186,G=29,R=25,A=255)
     WhiteColor=(B=200,G=200,R=200,A=255)
     ServerBrowserActiveCell=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=127,G=127,R=127,A=255),DrawPivot=DP_MiddleLeft,PosX=0.500000,ScaleX=0.600000,ScaleY=0.600000),Focused=(DrawColor=(B=200,G=200,R=200,A=255)),BackgroundBlurred=(WidgetTexture=Texture'Engine.DefaultTexture',RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255),DrawPivot=DP_MiddleLeft,PosX=-0.050000,ScaleX=0.930000,ScaleY=0.035000,ScaleMode=MSM_Fit),BackgroundFocused=(WidgetTexture=FinalBlend'PariahInterface.InterfaceShaders.fbBtnHighlight',TextureCoords=(X2=768,Y2=16),DrawColor=(B=255,G=255,R=255,A=255),ScaleX=0.930000,ScaleY=0.035000,ScaleMode=MSM_Fit),bRelativeBackgroundCoords=1,Pass=4)
     ServerBrowserPassiveCell=(Blurred=(MenuFont=Font'Engine.FontMedium',DrawColor=(B=127,G=127,R=127,A=255),DrawPivot=DP_MiddleLeft,PosX=0.500000,ScaleX=0.600000,ScaleY=0.600000),bRelativeBackgroundCoords=1,bDisabled=1,Pass=4)
     VirtualKeyboardClass=Class'XInterface.MenuVirtualKeyboard'
     MouseCursorTexture=Texture'InterfaceContent.Menu.MouseCursor'
     MouseCursorScale=1.000000
     WhiteTexture=Texture'Engine.PariahWhiteTexture'
     CenteredTextLayout=(PosX=0.500000,PosY=0.500000,SpacingY=0.045000,BorderScaleX=0.400000,Pivot=DP_MiddleMiddle)
     TitledOptionLayout=(PosX=0.100000,PosY=0.300000,SpacingY=0.050000,BorderScaleX=0.400000)
     TitledValueLayout=(PosX=0.440000,PosY=0.300000,SpacingY=0.050000,BorderScaleX=0.400000)
     SettingsItemLayout=(PosX=0.145000,PosY=0.300000,SpacingY=0.065000,BorderScaleX=0.400000)
     SettingsLeftArrowLayout=(PosX=0.100000,PosY=0.300000,SpacingY=0.065000,BorderScaleX=0.400000)
     SettingsRightArrowLayout=(PosX=0.608000,PosY=0.300000,SpacingY=0.065000,BorderScaleX=0.400000)
     EnumLabelLayout=(PosX=0.500000,PosY=0.500000,SpacingY=0.060000,BorderScaleX=0.400000,Pivot=DP_MiddleMiddle)
     EnumLeftArrowLayout=(PosX=0.540000,PosY=0.500000,SpacingY=0.060000,BorderScaleX=0.400000,Pivot=DP_MiddleMiddle)
     EnumOptionLayout=(PosX=0.700000,PosY=0.500000,SpacingY=0.060000,BorderScaleX=0.400000,Pivot=DP_MiddleMiddle)
     EnumRightArrowLayout=(PosX=0.855000,PosY=0.500000,SpacingY=0.060000,BorderScaleX=0.400000,Pivot=DP_MiddleMiddle)
     DetailLabelsLayout=(PosX=0.495000,PosY=0.500000,SpacingY=0.060000,Pivot=DP_MiddleMiddle)
     DetailValuesLayout=(PosX=0.505000,PosY=0.500000,SpacingY=0.060000,Pivot=DP_MiddleMiddle)
     BindingLabelLayout=(PosX=0.100000,PosY=0.300000,SpacingY=0.050000,BorderScaleX=0.400000)
     BindingBoxLayoutA=(PosX=0.595000,PosY=0.300000,SpacingY=0.050000,BorderScaleX=0.400000)
     BindingBoxLayoutB=(PosX=0.800000,PosY=0.300000,SpacingY=0.050000,BorderScaleX=0.400000)
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
