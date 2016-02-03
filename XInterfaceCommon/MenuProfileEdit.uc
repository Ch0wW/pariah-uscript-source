class MenuProfileEdit extends MenuTemplateTitledB;

var() MenuButtonText    Options[2];
var() MenuText          Values[2];
var() localized String  StringNotSet;
var() config int        Position;
var ProfileData         mProfileData;


simulated function Init( String Args )
{
    Super.Init( Args );
 
    LayoutArray( Options[0], 'TitledOptionLayout' );
    LayoutArray( Values[0], 'TitledValueLayout' );
    UpdateOptions();
    mProfileData = GetProfileData();
    assert(mProfileData != None);      
}

simulated function UpdateOptions()
{
    local GameProfile gProfile;
    local int difficulty;
    
    // don't allow rename, it's a pain in the ass
    Options[0].bDisabled = 1;
    
    Values[0].Text = GetPlayerName();
    Values[1].Text = StringNotSet;
    
    gProfile = GetCurrentGameProfile();
    assert(gProfile != None);
    
    difficulty = gProfile.GetDifficultyIndex();
    if(difficulty >= 0)
    {
        Values[1].Text = class'GameInfo'.static.GetDifficultyName(difficulty);
    }
    
    Position = Clamp( Position, 0, ArrayCount(Options) - 1 );
    if( Options[Position].bHidden != 0 )
    {
        for( Position = 0; Options[Position].bHidden != 0; Position++ )
            continue;
    }
    
    FocusOnWidget( Options[1] );
}

simulated function SavePosition()
{
    for( Position = 0; Position < ArrayCount(Options); Position++ )
    {
        if( Options[Position].bHasFocus != 0 )
            break;
    }
    
    if( Position >= ArrayCount(Options) )
        Position = 0;

    SaveConfig();
}

simulated function OnName()
{
    SavePosition();
    mProfileData.SetRequirements(mProfileData.cNeedName);
    CallMenuClass(EditNameMenuClass());
}

simulated function OnDifficulty()
{
    SavePosition();
    mProfileData.SetRequirements(mProfileData.cNeedDifficulty);
    CallMenuClass( "XInterfaceCommon.MenuProfileEditDifficulty" );
}

simulated function bool MenuClosed(Menu closingMenu)
{
    log(self@" closingMenu="$closingMenu);
    
    if(closingMenu.IsA('MenuProfileSaving'))
    {
        UpdateOptions();
        return(true);
    }
    
    return(false);
}

defaultproperties
{
     Options(0)=(Blurred=(Text="Profile Name:"),OnSelect="OnName",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Game Difficulty:"),OnSelect="OnDifficulty")
     Values(0)=(Text="<Profile Name>",DrawColor=(B=255,G=255,R=255,A=255),DrawPivot=DP_MiddleLeft,Style="TitleText")
     Values(1)=(Text="<Difficulty>")
     StringNotSet="Not Set"
     MenuTitle=(Text="Edit Profile")
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
