class MenuProfileEditNameConsole extends MenuVirtualKeyboard;

var() localized string  InUseText;
var() localized string  MinLenText;
var() localized string  IsReserved;
var() localized string  DefaultName;
var ProfileData         mProfileData;


simulated function Init( String Args )
{
    local string n;
    
    Super.Init( Args );

    mProfileData = GetProfileData();
    assert(mProfileData != None);

    if(mProfileData.ValidName())
    {
        n = mProfileData.Name();
        InputText.Text = n;
    }
    else
    {
        // correct wrt existing names
        n = CheckName(DefaultName, mProfileData.ContinueWithoutSaving());
        InputText.Text = n;
    }
}

simulated function OnDone()
{
    local string n;
    
    n = InputText.Text;

    if( !NameIsValid(n) )
    {
        HandleInvalidName(n);
        return;
    }

    mProfileData.Name(n);
    
    if( mProfileData.DefineDifficulty() )
    {
        CallMenuClass("XInterfaceCommon.MenuProfileEditDifficulty");
    }
    else
    {
        CallMenuClass("XInterfaceCommon.MenuProfileSaving");    
    }    
}

simulated function bool NameInUse( string Name )
{
    return( Name != CheckName(Name, mProfileData.ContinueWithoutSaving()) );
}

simulated function bool NameIsValid( string Name )
{
    return
    (
        Len( Name ) >= default.MinLength &&
        !NameInUse( Name ) &&
        !class'XInterface.MenuBase'.static.NameIsReserved( Name )
    );
}

simulated function HandleInvalidName( string Name )
{
    local string warningMessage;

    if( Len( Name ) < default.MinLength )
    {
        warningMessage = default.MinLenText;
        CallMenuClass("XInterfaceCommon.MenuWarning", MakeQuotedString(warningMessage));
    }
    else if( NameInUse( Name ) )
    {
        warningMessage = default.InUseText;
        UpdateTextField(warningMessage, "%s", Name);
        CallMenuClass("XInterfaceCommon.MenuWarning", MakeQuotedString(warningMessage));
    }
    else if( class'XInterface.MenuBase'.static.NameIsReserved( Name ) )
    {
        warningMessage = default.IsReserved;
        UpdateTextField(warningMessage, "%s", Name);
        CallMenuClass("XInterfaceCommon.MenuWarning", MakeQuotedString(warningMessage));
    }
}

defaultproperties
{
     InUseText="There is already a profile or saved game named %s."
     MinLenText="A profile name must be at least one letter or number in length."
     IsReserved="%s is a reserved name."
     DefaultName="Mason"
     APlatform=MWP_All
     MenuTitle=(Text="Profile Name")
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
