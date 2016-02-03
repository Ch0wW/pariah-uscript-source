class MenuProfileLoading extends MenuWarningTransition;

var localized string mLoadingText;
var localized string mDeletingText;
var bool mDeleteMode;


simulated function Init(string Args)
{
    local string profileName;

    mDeleteMode = (ParseToken(Args) ~= "DELETE");
    profileName = ParseToken(Args);
    assert(profileName != "");

    Super.Init(Args);

    if(mDeleteMode)
    {
        UpdateTextField(mMessage.Text, "<Action>", mDeletingText);
    }
    else
    {
        UpdateTextField(mMessage.Text, "<Action>", mLoadingText);
    }
    UpdateTextField(mMessage.Text, "<ProfileName>", profileName);
}

simulated function bool MenuClosed(Menu ClosingMenu)
{
    local PlayerController pc;
    log(self$" closing="$closingmenu);
    pc = PlayerController(Owner);
    if(pc.IsSharingScreen() && ClosingMenu == self)
    {
        pc.myHud.UtilityOverlay.GotoState('');
    }
    return(true);
}

defaultproperties
{
     mLoadingText="Loading"
     mDeletingText="Deleting"
     mMessage=(Text="<Action> profile: <ProfileName>")
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
