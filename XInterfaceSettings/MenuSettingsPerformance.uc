class MenuSettingsPerformance extends MenuTemplateTitledBA;

var() String TextureDetailFields;
var() Array<String> TextureDetailSettings;

var() String VisualEffectsFields;
var() Array<String> VisualEffectsSettings;

var() String RenderQualityFields;
var() Array<String> RenderQualitySettings;

var() String VerticalSyncFields;
var() Array<String> VerticalSyncSettings;

var() String PostFXFields;
var() Array<String> PostFXSettings;

var() MenuButtonEnum TextureDetailEnum;
var() MenuButtonEnum VisualEffectsEnum;
var() MenuButtonEnum RenderQualityEnum;
var() MenuButtonEnum VerticalSyncEnum;
var() MenuButtonEnum PostFXEnum;

var() MenuSliderArrow TextureDetailDown;
var() MenuSliderArrow VisualEffectsDown;
var() MenuSliderArrow RenderQualityDown;
var() MenuSliderArrow VerticalSyncDown;
var() MenuSliderArrow PostFXDown;

var() MenuSliderArrow TextureDetailUp;
var() MenuSliderArrow VisualEffectsUp;
var() MenuSliderArrow RenderQualityUp;
var() MenuSliderArrow VerticalSyncUp;
var() MenuSliderArrow PostFXUp;

var() bool NeedToApplySettings;

simulated function String GetSetting( String Field )
{
    local PlayerController PC;
    local String Command;
    local String Setting;
    
	// added '-nolocalized' so localized version of 'True/False' aren't returned thus breaking the string array presets.
	// would have fix this with a bool cast but its not symetrical and changing it globally was risky.
    Command = "get" @ Field @ "-notlocalized";
    
    PC = PlayerController( Owner );
    Setting = PC.ConsoleCommand( Command );
    
    Log( "Field" @ Field @ "is set to" @ Setting );
    
    return( Setting );
}

simulated function String GetSettings( String Fields )
{
    local int FieldEnd;
    local String Field;
    
    FieldEnd = InStr( Fields, ";" );
    if( FieldEnd >= 0 )
    {
        Field = Left( Fields, FieldEnd );
        Fields = Right( Fields, Len( Fields ) - ( FieldEnd + 1 ) );
        return(GetSetting(Field) $ ";" $ GetSettings(Fields));
    }
}

simulated function int GetSettingsIndex( String Fields, out Array<String> Settings )
{
    local int i;
    local String CurrentSettings;
    
    CurrentSettings = GetSettings( Fields );
    
    log( "Current settings are" @ CurrentSettings );
    
    for( i = 0; i != Settings.Length; ++i )
    {
        if( Settings[i] == CurrentSettings )
        {
            log( "Matching settings index is" @ i );
            
            return( i );
        }
    }
    
    return( Settings.Length / 2 );
}

simulated function FlagDeferredApplication()
{
    if( NeedToApplySettings )
    {
        return;
    }
    
    NeedToApplySettings = true;
    
    HideAButton(0);
    ALabel.Text = StringApply;
    BLabel.Text = StringCancel;
    bDynamicLayoutDirty = true;
}

simulated function bool ApplyChanges()
{
    local PlayerController PC;
    local String Res;
    local String ColorDepth;
    local String Cmd;
    
    UpdateTextureDetail();
    UpdateVisualEffects();
    UpdateRenderQuality();
    UpdateVerticalSync();
	UpdatePostFX();
        
    // To actually apply the bulk of these settings we need to kick the D3D driver!
    PC = PlayerController(Owner);

    Res = PC.ConsoleCommand( "GETCURRENTRES" ); // Note: does not include color depth.
    ColorDepth = PC.ConsoleCommand( "GETCURRENTCOLORDEPTH" );
    
    Cmd = "SETRES" @ Res $ "x" $ ColorDepth;
    
    PC.ConsoleCommand( Cmd );

    // TODO: would be nice to detect if this failed!

    return( true );
}

simulated function OnBButton()
{
    CloseMenu();
}

simulated function OnAButton()
{
    NeedToApplySettings = false;

    if( !ApplyChanges() )
    {
        CallMenuClass( "XInterfaceCommon.MenuWarning", MakeQuotedString(class'MenuSettingsVideo'.default.StringCouldNotApply) );
    }

    LoadValues();

    BLabel.Text = default.BLabel.Text;
    HideAButton(1);
}

simulated function ApplySetting( String Field, String Setting )
{
    local PlayerController PC;
    local String Command;
    
    Log( "Setting " $ Field $ " to " $ Setting ); 
    
    Command = "set" @ Field @ Setting;
    
    PC = PlayerController( Owner );
    PC.ConsoleCommand( Command );
}

simulated function ApplySettings( String Fields, String Settings )
{
    local int FieldEnd;
    local int SettingEnd;
    local String Field;
    local String Setting;
    
    FieldEnd = InStr( Fields, ";" );
    SettingEnd = InStr( Settings, ";" );
    
    if( ( FieldEnd >= 0 ) && ( SettingEnd >= 0 ) )
    {
        Field = Left( Fields, FieldEnd );
        Setting = Left( Settings, SettingEnd );
        
        ApplySetting( Field, Setting );
        
        Fields = Right( Fields, Len( Fields ) - ( FieldEnd + 1 ) );
        Settings = Right( Settings, Len( Settings ) - ( SettingEnd + 1 ) );
        
        ApplySettings( Fields, Settings );
    }
}

simulated function GetTextureDetail()
{    
    TextureDetailEnum.Current = GetSettingsIndex( TextureDetailFields, TextureDetailSettings );
}

simulated function UpdateTextureDetail()
{        
    ApplySettings( TextureDetailFields, TextureDetailSettings[ TextureDetailEnum.Current ] );
}

simulated function GetVisualEffects()
{
    VisualEffectsEnum.Current = GetSettingsIndex( VisualEffectsFields, VisualEffectsSettings );
}

simulated function UpdateVisualEffects()
{            
    ApplySettings( VisualEffectsFields, VisualEffectsSettings[ VisualEffectsEnum.Current ] );
}

simulated function GetRenderQuality()
{
    RenderQualityEnum.Current = GetSettingsIndex( RenderQualityFields, RenderQualitySettings );
}

simulated function UpdateRenderQuality()
{            
    ApplySettings( RenderQualityFields, RenderQualitySettings[ RenderQualityEnum.Current ] );
}

simulated function GetVerticalSync()
{    
    VerticalSyncEnum.Current = GetSettingsIndex( VerticalSyncFields, VerticalSyncSettings );
}

simulated function UpdateVerticalSync()
{
    ApplySettings( VerticalSyncFields, VerticalSyncSettings[ VerticalSyncEnum.Current ] );
}

simulated function GetPostFX()
{    
    PostFXEnum.Current = GetSettingsIndex( PostFXFields, PostFXSettings );
}

simulated function UpdatePostFX()
{
    ApplySettings( PostFXFields, PostFXSettings[ PostFXEnum.Current ] );
}

simulated function LoadValues()
{
    GetTextureDetail();
    GetVisualEffects();
    GetRenderQuality();
    GetVerticalSync();
	GetPostFX();
}

simulated function Init( String Args )
{
    Super.Init(Args);

    LoadValues();    
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout(C);   
        
    LayoutWidgets( TextureDetailEnum, PostFXEnum, 'SettingsItemLayout' );
    LayoutWidgets( TextureDetailDown, PostFXDown, 'SettingsLeftArrowLayout' );
    LayoutWidgets( TextureDetailUp, PostFXUp, 'SettingsRightArrowLayout' );    
}

defaultproperties
{
     TextureDetailFields="ini:Engine.Engine.ViewportManager TextureDetailInterface;ini:Engine.Engine.ViewportManager TextureDetailTerrain;ini:Engine.Engine.ViewportManager  TextureDetailWeaponSkin;ini:Engine.Engine.ViewportManager TextureDetailPlayerSkin;ini:Engine.Engine.ViewportManager TextureDetailWorld;ini:Engine.Engine.ViewportManager TextureDetailRenderMap;ini:Engine.Engine.ViewportManager TextureDetailLightmap;"
     TextureDetailSettings(0)="Normal;Lower;Lower;Low;Low;Lower;Lower;"
     TextureDetailSettings(1)="Normal;Normal;Normal;Lower;Normal;Lower;Normal;"
     TextureDetailSettings(2)="Normal;Normal;Normal;Normal;Normal;Normal;Normal;"
     TextureDetailSettings(3)="UltraHigh;UltraHigh;UltraHigh;UltraHigh;UltraHigh;UltraHigh;UltraHigh;"
     VisualEffectsFields="ini:Engine.Engine.ViewportManager Decals;ini:Engine.Engine.ViewportManager DecoLayers;ini:Engine.Engine.ViewportManager Coronas;ini:Engine.Engine.ViewportManager Projectors;ini:Engine.Engine.ViewportManager NoDynamicLights;ini:Engine.Engine.ViewportManager EnablePostFX;"
     VisualEffectsSettings(0)="False;False;False;False;False;False;"
     VisualEffectsSettings(1)="True;False;False;False;False;True;"
     VisualEffectsSettings(2)="True;True;True;False;False;True;"
     VisualEffectsSettings(3)="True;True;True;True;False;True;"
     RenderQualityFields="ini:Engine.Engine.RenderDevice UseTrilinear;ini:Engine.Engine.RenderDevice UseBumpmaps;ini:Engine.Engine.RenderDevice HighDetailActors;ini:Engine.Engine.RenderDevice UseHighDetailShadows;ini:Engine.Engine.RenderDevice UseCompressedLightmaps;"
     RenderQualitySettings(0)="False;False;False;False;True;"
     RenderQualitySettings(1)="True;False;True;False;True;"
     RenderQualitySettings(2)="True;True;True;False;True;"
     RenderQualitySettings(3)="True;True;True;True;False;"
     VerticalSyncFields="ini:Engine.Engine.RenderDevice UseVSync;"
     VerticalSyncSettings(0)="False;"
     VerticalSyncSettings(1)="True;"
     PostFXFields="ini:Engine.Engine.RenderDevice DisablePostFX;"
     PostFXSettings(0)="False;"
     PostFXSettings(1)="True;"
     TextureDetailEnum=(Items=("Texture Detail: Low","Texture Detail: Medium","Texture Detail: High","Texture Detail: Very High"),OnChange="FlagDeferredApplication",Style="SettingsEnum")
     VisualEffectsEnum=(Items=("Visual Effects: Low","Visual Effects: Medium","Visual Effects: High","Visual Effects: Very High"),OnChange="FlagDeferredApplication",Style="SettingsEnum")
     RenderQualityEnum=(Items=("Render Quality: Low","Render Quality: Medium","Render Quality: High","Render Quality: Very High"),OnChange="FlagDeferredApplication",Style="SettingsEnum")
     VerticalSyncEnum=(Items=("Vertical Sync: No","Vertical Sync: Yes"),OnChange="FlagDeferredApplication",Style="SettingsEnum")
     PostFXEnum=(Items=("Disable Post Render FX: No","Disable Post Render FX: Yes"),OnChange="FlagDeferredApplication",Style="SettingsEnum")
     TextureDetailDown=(WidgetName="TextureDetailEnum",Style="SettingsSliderLeft")
     VisualEffectsDown=(WidgetName="VisualEffectsEnum",Style="SettingsSliderLeft")
     RenderQualityDown=(WidgetName="RenderQualityEnum",Style="SettingsSliderLeft")
     VerticalSyncDown=(WidgetName="VerticalSyncEnum",Style="SettingsSliderLeft")
     PostFXDown=(WidgetName="PostFXEnum",Style="SettingsSliderLeft")
     TextureDetailUp=(WidgetName="TextureDetailEnum",Style="SettingsSliderRight")
     VisualEffectsUp=(WidgetName="VisualEffectsEnum",Style="SettingsSliderRight")
     RenderQualityUp=(WidgetName="RenderQualityEnum",Style="SettingsSliderRight")
     VerticalSyncUp=(WidgetName="VerticalSyncEnum",Style="SettingsSliderRight")
     PostFXUp=(WidgetName="PostFXEnum",Style="SettingsSliderRight")
     APlatform=MWP_All
     AButtonHidden=1
     MenuTitle=(Text="Performance Settings")
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
