class MenuProfileDeleteConfirm extends MenuQuestionYesNo;

var string mProfileName;


simulated function Init( String Args )
{
    mProfileName = ParseToken(Args);
    assert(mProfileName != "");
    
    Super.Init( Args );
    
    UpdateTextField(Question.Text, "<ProfileName>", mProfileName);    
}

simulated function OnYes()
{
    local MenuProfileLoading m;    
    m = MenuProfileLoading(CallMenuClassEx("XInterfaceCommon.MenuProfileLoading", "DELETE" @ mProfileName));
    assert(m != None);
    m.mCallbackName = 'DoDelete';
    m.mCallbackObject = PreviousMenu;
    assert(PreviousMenu.IsA('MenuProfileSelect'));
}

simulated function OnNo()
{
    CloseMenu();
}

defaultproperties
{
     Question=(Text="Delete profile <ProfileName> and associated save game?")
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
