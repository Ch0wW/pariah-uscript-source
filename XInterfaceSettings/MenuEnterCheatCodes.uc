class MenuEnterCheatCodes extends MenuTemplateTitledBA;

var() localized string  EnterCheatCodeText;
var() localized string  FalseCheatCode;

const MAX_PASSCODE_LENGTH = 4;

var() MenuText      Instructions;
var() MenuText      Checking;
var() MenuText      Input[4];
var() MenuSprite    InputBorder[4];

var() String        PassCode;
var() int           PassCodeLength;
var() int           SelectedCheat;

var() transient float T;
var() float StartTime;
var() float CheckingTime;

// PC version editbox
var() MenuEditBox   PCInput;

struct CheatCodes
{
    var string PCCheatCode;
    var string CheatCode;
    var localized string Name;
    var string Command;
};

var CheatCodes Cheats[15];

simulated function Init( String Args )
{
    Super.Init( Args );

    ClearPasscode();
    HandleInputStart();
}

simulated function ClearPasscode()
{
    local int i;
    
    if( IsOnConsole() )
    {
        for( i = 0; i < ArrayCount(Input); i++ )
            Input[i].bHidden = 1;
    }
    else
        ClearPCInputText();

    if(PassCodeLength > 0 )
        StartTime = Level.TimeSeconds + CheckingTime;
    
    SelectedCheat = -1;
    PassCodeLength = 0;
    PassCode = "";
}

simulated function ClearPCInputText()
{
    PCInput.Blurred.Text = "";
    PCInput.Focused.Text = "";
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    local PlayerController PC;

    if( ButtonName == "B" )
    {
        HandleInputBack();
        return( true );
    }

    PC = PlayerController( Owner );
    assert( PC != None );

    PC.PlayBeepSound( SoundOnFocus );
        
    if( PassCodeLength >= MAX_PASSCODE_LENGTH )
        return( true );

    Input[PassCodeLength++].bHidden = 0;
    
    PassCode = PassCode $ ButtonName $ " ";

    if( PassCodeLength == MAX_PASSCODE_LENGTH )
    {
        GotoState('CheckingCode');
    }

    return( true );
}

auto state GettingInput
{
    simulated function BeginState()
    {
        local int i;
        
        Checking.bHidden = 1;
        MenuTitle.Text = default.MenuTitle.Text;
        
        ClearPasscode();

		SetTimer( 0, false );

        for( i = 0; i < 4; ++i )
        {
            InputBorder[i].DrawColor.A = 255;
            Input[i].DrawColor.A = 255;
        }

        Instructions.bHidden = 0;
        Checking.bHidden = 1;
    }
}

simulated exec function UnlockChapters()
{
    local GameProfile gProfile;
    gProfile = GetCurrentGameProfile();
    if(gProfile != None)
    {
        gProfile.UnlockChapters();
    }
}

simulated exec function UnlockCinematics()
{
    // One can skip everything up to and including this video. See SkipVideo() for details - mjm
    PlayerController(Owner).sLastSkippableVideo = "Chapter17Scene1.bik";
}

simulated exec function UnlockOfficial(String Prefix)
{   
    local PlayerController PC;
    local int i;
    
    if( !HaveSpaceToSaveMap() )
    {
        GotoMenuClass("XInterfaceSettings.MenuUnlockMapsLowStorage", "");
        return;
    }
    
    class'xUtil'.static.UnlockCustomMaps( Prefix );
    
    PC = PlayerController(Owner);
    
    for( i = 0; i < PC.OfficialMapVendorPrefixes.Length; ++i )
    {
        if( PC.OfficialMapVendorPrefixes[i] ~= Prefix )
        {
            return;
        }
    }   

    log("UnlockOfficial"@Prefix);
    PC.OfficialMapVendorPrefixes[PC.OfficialMapVendorPrefixes.Length] = Prefix;
}

state CheckingCode
{
    simulated function BeginState()
    {
        Instructions.bHidden = 1;
        Checking.bHidden = 0;
        
        MenuTitle.Text = Checking.Text;
        SetTimer( CheckingTime, false );
    }
    
    simulated function EndState()
    {
        SetTimer( 0, false );
    }

    simulated function Timer()
    {
       local int i;

        for( i = 0; i < ArrayCount(Cheats); ++i )
        {
            if( (IsOnConsole() && PassCode == Cheats[i].CheatCode)  || PCInput.Blurred.Text == Cheats[i].PCCheatCode && PCInput.Blurred.Text != "" )
            {
                SelectedCheat = i;
                log("Cheat Activated");
                PlayerController(Owner).ConsoleCommand(Cheats[i].Command);
                GotoState('CheatActivated'); 
                return;
            }
        }

        log("Cheat Failed");
        GotoState('GettingInput');
    }

    simulated function Tick( float DT )
    {
        local float f;
        local byte DeltaA;
        local int i;
        
        Super.Tick(DT);
        
        T += DT;
        
        if( T > CheckingTime )
            T -= CheckingTime;

        f = 0.5 * (Cos( 2 * PI  * T / CheckingTime ) + 1.0);

        Checking.DrawColor.A = 128.f + (127.f * f);
        
        DeltaA = byte( 255.f * (CrossFadeRate * DT) );
        DeltaA = Min( DeltaA, Input[0].DrawColor.A );
        
        for( i = 0; i < 4; ++i )
        {
            InputBorder[i].DrawColor.A -= DeltaA;
            Input[i].DrawColor.A -= DeltaA;
        }
    }    
}

state CheatActivated
{
    simulated function HandleInputStart();

    simulated function BeginState()
    {
        Instructions.bHidden = 1;
        Checking.bHidden = 0;
        HideBButton(1);
        HideAButton(1);
        
        MenuTitle.Text = default.MenuTitle.Text;
        Checking.Text = Cheats[SelectedCheat].Name;
        
        SetTimer(3, false);
    }
    
    simulated function Timer()
    {
        CloseMenu();
    }

    simulated function HandleInputBack()
    {
    }
}

simulated function HandleInputBack()
{
    CloseMenu();
}

simulated exec function TrySaveHere()
{
    local GameProfile gp;
    local string saveMsg;
    
    if(Level.Game != None && Level.Game.bSinglePlayer)
    {
        gp = GetCurrentGameProfile();
        if(gp != None && gp.ShouldSave())
        {
            // UNPAUSE
            saveMsg = class'XboxMsg'.default.XBOX_SAVING_CONTENT;
            UpdateTextField(saveMsg, "<CONTENT>", gp.GetName());
            Checking.Text = saveMsg;
            // NEED TO SET TIMER, TICK TO SHOW MSG
            Level.Game.SaveProgress();
            // REPAUSE
            return;        
        }
    }
    GotoState('GettingInput');
}

simulated function OnAButton()
{
    GotoState('CheckingCode');  
}

defaultproperties
{
     Instructions=(Text="Please enter the Cheat Code.",DrawPivot=DP_LowerLeft,Style="MessageText")
     Checking=(Text="Checking Cheat Code...",DrawPivot=DP_LowerLeft,Style="MessageText")
     Input(0)=(Text="?",DrawPivot=DP_MiddleMiddle,PosX=0.350000,PosY=0.579000,Platform=MWP_Console,Style="LabelText")
     Input(1)=(Platform=MWP_Console)
     Input(2)=(Platform=MWP_Console)
     Input(3)=(PosX=0.650000,Platform=MWP_Console)
     InputBorder(0)=(DrawPivot=DP_MiddleMiddle,PosX=0.350000,PosY=0.575000,ScaleX=0.062500,ScaleY=0.075314,Pass=1,Platform=MWP_Console,Style="DarkBorder")
     InputBorder(1)=(Platform=MWP_Console)
     InputBorder(2)=(Platform=MWP_Console)
     InputBorder(3)=(PosX=0.650000,Platform=MWP_Console)
     CheckingTime=2.000000
     PCInput=(bNoSpaces=1,MaxLength=15,MinLength=1,Blurred=(PosX=0.305000,PosY=0.650000),Platform=MWP_PC,Style="NormalEditBox")
     Cheats(0)=(PCCheatCode="IMALAZYBEEOTCH",CheatCode="Y D RT D ",Name="Unlocked Single Player",Command="UnlockChapters")
     Cheats(1)=(PCCheatCode="F3ARM3",CheatCode="U LT X LT ",Name="God Mode Toggled",Command="GOD")
     Cheats(2)=(PCCheatCode="ALLAMO",CheatCode="D U D Y ",Name="All Ammo Given",Command="ALLAMMO")
     Cheats(3)=(PCCheatCode="MYLOCATION",CheatCode="X R LT L ",Name="Location Stat Toggled",Command="STAT LOCATION")
     Cheats(4)=(PCCheatCode="P33kaB00",CheatCode="X L Y U ",Name="Cinematics can now be skipped",Command="UnlockCinematics")
     Cheats(5)=(PCCheatCode="EBpwnz",CheatCode="W Y X K ",Name="Electronics Boutique content unlocked",Command="UnlockOfficial EB")
     Cheats(6)=(PCCheatCode="BESTBUYpwnsYou",CheatCode="LT K W RT ",Name="Best Buy content unlocked",Command="UnlockOfficial BB")
     Cheats(7)=(PCCheatCode="GameStopPwnage",CheatCode="L LT X L ",Name="GameStop content unlocked",Command="UnlockOfficial GS")
     Cheats(8)=(PCCheatCode="TRUPwned",CheatCode="L U W K ",Name="Toys R Us content unlocked",Command="UnlockOfficial TRU")
     Cheats(9)=(PCCheatCode="FuturePwnage",CheatCode="R D RT X ",Name="Future Shop content unlocked",Command="UnlockOfficial FS")
     Cheats(10)=(PCCheatCode="PwnageMart",CheatCode="U LT K W ",Name="Walmart content unlocked",Command="UnlockOfficial WM")
     Cheats(11)=(PCCheatCode="YouGotGroove",CheatCode="RT X D L ",Name="Groove content unlocked",Command="UnlockOfficial GR")
     Cheats(12)=(PCCheatCode="TargetingYou",CheatCode="D LT LT D ",Name="Target content unlocked",Command="UnlockOfficial TG")
     Cheats(13)=(PCCheatCode="ShhItsaSecret",CheatCode="Y LT D L ",Name="Secret content unlocked",Command="UnlockOfficial SE")
     Cheats(14)=(CheatCode="Q Q Q Q Q ",Command="TrySaveHere")
     ALabel=(Text="OK")
     APlatform=MWP_PC
     MenuTitle=(Text="Enter Cheat Code")
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
