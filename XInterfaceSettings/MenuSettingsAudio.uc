class MenuSettingsAudio extends MenuTemplateTitledBA;

var() MenuSlider MusicVolumeSlider;
var() MenuSlider EffectsVolumeSlider;
var() MenuSlider VoiceVolumeSlider;
var() MenuButtonEnum VoiceMaskingEnum;
var() MenuToggle XBLSpkrToggle;
var() MenuToggle PCNativeOpenALToggle;
var() MenuButtonEnum PC3DSoundEnum;
var() MenuButtonEnum AudioChannelsEnum;

var() MenuSliderArrow MusicVolumeDown;
var() MenuSliderArrow EffectsVolumeDown;
var() MenuSliderArrow VoiceVolumeDown;
var() MenuSliderArrow VoiceMaskingDown;
var() MenuSliderArrow XBLSpkrDown;
var() MenuSliderArrow PCOpenALDown;
var() MenuSliderArrow PC3DSoundDown;
var() MenuSliderArrow AudioChannelsDown;

var() MenuSliderArrow MusicVolumeUp;
var() MenuSliderArrow EffectsVolumeUp;
var() MenuSliderArrow VoiceVolumeUp;
var() MenuSliderArrow VoiceMaskingUp;
var() MenuSliderArrow XBLSpkrUp;
var() MenuSliderArrow PCOpenALUp;
var() MenuSliderArrow PC3DSoundUp;
var() MenuSliderArrow AudioChannelsUp;

var() Sound EffectsSound;
var() Sound VoiceSound;

var() bool NeedToApplySettings;

simulated function Init( String Args )
{    
    local PlayerController PC;
    PC = PlayerController(Owner);

    Super.Init( Args );

    // it's possible to come in here before the user has joined a game, meaning their voice mask wouldn't be set yet
    ConsoleCommand("UPDATEVOICEMASK");    

    SetTimer(0.5,true);

    MusicVolumeSlider.Value = float( ConsoleCommand("get ini:Engine.Engine.AudioDevice MusicVolume") );
    EffectsVolumeSlider.Value = float( ConsoleCommand("get ini:Engine.Engine.AudioDevice SoundVolume") );
    VoiceVolumeSlider.Value = float( ConsoleCommand("get ini:Engine.Engine.AudioDevice VoiceVolume") );
    VoiceMaskingEnum.Current = PC.VoiceMask;    
    
    LoadValues();
}

simulated function OnBButton()
{
    CloseMenu();
}

simulated function LoadValues()
{
    local int Channels;

    // PCNativeOpenALToggle = !UseDefaultDriver conceptually
    PCNativeOpenALToggle.bValue = int(bool(ConsoleCommand("get ini:Engine.Engine.AudioDevice UseDefaultDriver")));    

    // PC3DSoundEnum =
    //  0 : Use3DSound = False, UseEAX = False
    //  1 : Use3DSound = True, UseEAX = False
    //  2 : Use3DSound = True, UseEAX = True

    // Internally we set Use3DSound to true if UseEAX is on so it's implicitly excplicit :)
    if (bool(ConsoleCommand("get ini:Engine.Engine.AudioDevice UseEAX")))
    {
        PC3DSoundEnum.Current = 2;
    }
    else if (bool(ConsoleCommand("get ini:Engine.Engine.AudioDevice Use3DSound")))
    {
        PC3DSoundEnum.Current = 1;
    }
    else
    {
        PC3DSoundEnum.Current = 0;
    }

    // Channels:
    //  0 = 4
    //  1 = 8
    //  2 = 16
    //  3 = 32
    Channels = int(ConsoleCommand("get ini:Engine.Engine.AudioDevice Channels"));
    AudioChannelsEnum.Current = Loge(Channels) / Loge(2) - 2;
}

simulated function Timer()
{
    local PlayerController PC;
    PC = PlayerController(Owner);

    XBLSpkrToggle.bValue = int(PC.ConsoleCommand("XBLiveChatThruSpeaker"));    
}

simulated exec function Pork()
{
    VoiceMaskingEnum.bHidden = 0;
    VoiceMaskingDown.bHidden = 0;
    VoiceMaskingUp.bHidden = 0;

    XBLSpkrToggle.bHidden = 0;
    XBLSpkrDown.bHidden = 0;
    XBLSpkrUp.bHidden = 0;

    bDynamicLayoutDirty = true;
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout(C);
    
    LayoutWidgets( MusicVolumeSlider, AudioChannelsEnum, 'SettingsItemLayout' );
    LayoutWidgets( MusicVolumeDown, AudioChannelsDown, 'SettingsLeftArrowLayout' );
    LayoutWidgets( MusicVolumeUp, AudioChannelsUp, 'SettingsRightArrowLayout' );    
}

simulated function HandleInputBack()
{
    local PlayerController PC;
    PC = PlayerController(Owner);

    // always disable voice loopback on the way out    
    ConsoleCommand("VOICELOOPBACK OFF");    
    Super.HandleInputBack();
}

simulated function UpdateSettings()
{
    local PlayerController PC;
    PC = PlayerController(Owner);

    PC.ConsoleCommand("SetXBLiveChatThruSpeaker Val=" $ XBLSpkrToggle.bValue);
    
    if( PC.VoiceMask != VoiceMaskingEnum.Current )
    {
        PC.VoiceMask = VoiceMaskingEnum.Current;
        log("Voice mask set to " $ VoiceMaskingEnum.Items[VoiceMaskingEnum.Current]);
        ConsoleCommand("UPDATEVOICEMASK");
    }
}

simulated function UpdateMusicVolume()
{
    ConsoleCommand( "set ini:Engine.Engine.AudioDevice MusicVolume" @ MusicVolumeSlider.Value );
}

simulated function UpdateEffectsVolume()
{
    ConsoleCommand( "set ini:Engine.Engine.AudioDevice SoundVolume" @ EffectsVolumeSlider.Value );
    PlayMenuSound( EffectsSound, EffectsVolumeSlider.Value );
}

simulated function UpdateVoiceVolume()
{
    ConsoleCommand( "set ini:Engine.Engine.AudioDevice VoiceVolume" @ VoiceVolumeSlider.Value );
    PlayMenuSound( VoiceSound, VoiceVolumeSlider.Value );
}

simulated function EnableLoopback()
{
    // when the voice mask widget gets the focus, enable voice loopback so the user can what they will sound like
    ConsoleCommand("VOICELOOPBACK ON");
}

simulated function DisableLoopback()
{
    // disable voice loopback when the focus leaves this widget
    ConsoleCommand("VOICELOOPBACK OFF");
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

simulated function bool ApplyChanges()
{
    local bool UseEAX;
    local bool Use3DSound;
    local int  Channels;

    ConsoleCommand("set ini:Engine.Engine.AudioDevice UseDefaultDriver" @ bool(PCNativeOpenALToggle.bValue));

    if (PC3DSoundEnum.Current == 2)
    {
        UseEAX = true;
        Use3DSound = true;
    }
    else if (PC3DSoundEnum.Current == 1)
    {
        Use3DSound = true;
    }

    Channels = int(2.0 ** (AudioChannelsEnum.Current + 2));
    ConsoleCommand("set ini:Engine.Engine.AudioDevice Channels" @ Channels);
    ConsoleCommand("set ini:Engine.Engine.AudioDevice UseEAX" @ UseEAX);
    ConsoleCommand("set ini:Engine.Engine.AudioDevice Use3DSound" @ Use3DSound);
        
    if (int(ConsoleCommand("SOUND_REBOOT")) == 1)
    {
        PlayMusic(Level.LastPlayedSong, 1.0);
        return true;
    }       
    return false;
}

#exec OBJ LOAD FILE=NewWeaponSounds.uax
#exec OBJ LOAD FILE=AIStateDialogue.uax

defaultproperties
{
     MusicVolumeSlider=(MaxValue=1.000000,Delta=0.050000,MinScaleX=0.010000,OnSlide="UpdateMusicVolume",Blurred=(Text="Music Volume"),Style="SettingsSlider")
     EffectsVolumeSlider=(MaxValue=1.000000,Delta=0.050000,MinScaleX=0.010000,OnSlide="UpdateEffectsVolume",Blurred=(Text="Effects Volume"),Style="SettingsSlider")
     VoiceVolumeSlider=(MaxValue=1.000000,Delta=0.050000,MinScaleX=0.010000,OnSlide="UpdateVoiceVolume",Blurred=(Text="Voice Volume"),Style="SettingsSlider")
     VoiceMaskingEnum=(Items=("Voice Masking: Disabled","Voice Masking: Anonymous","Voice Masking: Cartoon","Voice Masking: Big guy","Voice Masking: Child","Voice Masking: Robot","Voice Masking: Darkmaster","Voice Masking: Whisper"),OnChange="UpdateSettings",OnFocus="EnableLoopback",OnBlur="DisableLoopback",Platform=MWP_Xbox,Style="SettingsEnum")
     XBLSpkrToggle=(TextOff="Voice through TV: Off",TextOn="Voice through TV: On",OnToggle="UpdateSettings",Platform=MWP_Xbox,Style="SettingsToggle")
     PCNativeOpenALToggle=(TextOff="Use Native OpenAL: Yes",TextOn="Use Native OpenAL: No",OnToggle="FlagDeferredApplication",Platform=MWP_PC,Style="SettingsToggle")
     PC3DSoundEnum=(Items=("3D Sound: Off","3D Sound: On","3D Sound: On + EAX AdvancedHD"),OnChange="FlagDeferredApplication",Platform=MWP_PC,Style="SettingsEnum")
     AudioChannelsEnum=(Items=("Maximum Simultaneous Sounds: 4","Maximum Simultaneous Sounds: 8","Maximum Simultaneous Sounds: 16","Maximum Simultaneous Sounds: 32"),OnChange="FlagDeferredApplication",Style="SettingsEnum")
     MusicVolumeDown=(WidgetName="MusicVolumeSlider",Style="SettingsSliderLeft")
     EffectsVolumeDown=(WidgetName="EffectsVolumeSlider",Style="SettingsSliderLeft")
     VoiceVolumeDown=(WidgetName="VoiceVolumeSlider",Style="SettingsSliderLeft")
     VoiceMaskingDown=(WidgetName="VoiceMaskingEnum",Platform=MWP_Xbox,Style="SettingsSliderLeft")
     XBLSpkrDown=(WidgetName="XBLSpkrToggle",Platform=MWP_Xbox,Style="SettingsSliderLeft")
     PCOpenALDown=(WidgetName="PCNativeOpenALToggle",Platform=MWP_PC,Style="SettingsSliderLeft")
     PC3DSoundDown=(WidgetName="PC3DSoundEnum",Platform=MWP_PC,Style="SettingsSliderLeft")
     AudioChannelsDown=(WidgetName="AudioChannelsEnum",Platform=MWP_PC,Style="SettingsSliderLeft")
     MusicVolumeUp=(WidgetName="MusicVolumeSlider",Style="SettingsSliderRight")
     EffectsVolumeUp=(WidgetName="EffectsVolumeSlider",Style="SettingsSliderRight")
     VoiceVolumeUp=(WidgetName="VoiceVolumeSlider",Style="SettingsSliderRight")
     VoiceMaskingUp=(WidgetName="VoiceMaskingEnum",Platform=MWP_Xbox,Style="SettingsSliderRight")
     XBLSpkrUp=(WidgetName="XBLSpkrToggle",Platform=MWP_Xbox,Style="SettingsSliderRight")
     PCOpenALUp=(WidgetName="PCNativeOpenALToggle",Platform=MWP_PC,Style="SettingsSliderRight")
     PC3DSoundUp=(WidgetName="PC3DSoundEnum",Platform=MWP_PC,Style="SettingsSliderRight")
     AudioChannelsUp=(WidgetName="AudioChannelsEnum",Platform=MWP_PC,Style="SettingsSliderRight")
     EffectsSound=Sound'NewWeaponSounds.AssaultRifle.AssaultRifleSingleShot'
     VoiceSound=Sound'AIStateDialogue.AIStateKarina.MAIStateKarinaChapter406'
     APlatform=MWP_All
     AButtonHidden=1
     MenuTitle=(Text="Audio Settings")
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
