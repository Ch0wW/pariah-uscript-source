class MenuProfileSaving extends MenuWarningTransition;

var ProfileData mProfileData;
var localized string mCreatingText;
var localized string mUpdatingText;


simulated function Init(string Args)
{
    mProfileData = GetProfileData();
    assert(mProfileData != None);
    mCallbackName = ToName(mProfileData.DoneSaveCallback());
    mCallbackObject = mProfileData.DoneSaveCallbackObject();

    Super.Init(Args);

    if(!IsOnConsole() || mProfileData.ContinueWithoutSaving())
    {
        mHoldTime = 1.f;
        if(mProfileData.NewProfile())
        {
            UpdateTextField(mMessage.Text, "<ACTION>", mCreatingText);
        }
        else
        {
            UpdateTextField(mMessage.Text, "<ACTION>", mUpdatingText);
        }
    }
    else
    {
        mMessage.Text = class'XboxMsg'.default.XBOX_SAVING_CONTENT;
    }
    UpdateTextField(mMessage.Text, "<CONTENT>", mProfileData.Name());
}

simulated function DoWork()
{
    mProfileData.Save(self);
    Super.DoWork();
}

defaultproperties
{
     mCreatingText="Creating"
     mUpdatingText="Updating"
     mMessage=(Text="<ACTION> profile: <CONTENT>")
     mHoldTime=3.000000
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
