class MenuMiniEdSaveOffline extends MenuTemplateTitledBA;

var() MenuText WasLiveMessage;
var() MenuText WasNewMessage;

var() WidgetLayout OptionLayout;
var() MenuButtonText Options[2];

simulated function Init(String Args)
{
    if( Args == "" )
    {
        WasNewMessage.bHidden = 0;
    }
    else
    {
        WasLiveMessage.bHidden = 0;
    }
    
    Super.Init("");
}

simulated function HandleInputBack()
{
    CloseMenu();
    PreviousMenu.HandleInputBack();
}

simulated function OnSignInFirst()
{
    GotoMenuClass( "XInterfaceLive.MenuLiveSignIn", "MINIED_PROMPT" );
}

simulated function OnSaveForOfflinePlay()
{
    CloseMenu();
}

simulated function DoDynamicLayout( Canvas C )
{
    local float DY;
    
    Super.DoDynamicLayout( C );

    if( WasLiveMessage.bHidden == 0 )
    {
        DY = GetWrappedTextHeight( C, WasLiveMessage );
        OptionLayout.PosY = WasLiveMessage.PosY + DY + (OptionLayout.SpacingY * 0.5);
    }
    else
    {
        DY = GetWrappedTextHeight( C, WasNewMessage );
        OptionLayout.PosY = WasNewMessage.PosY + DY + (OptionLayout.SpacingY * 0.5);
    }

    LayoutArray( Options[0], 'OptionLayout' );
}

defaultproperties
{
     WasLiveMessage=(Text="You are about to save an Xbox Live map but you are not currently signed-in.\n\nIf you don't sign in first, the copy you save will be classified as Offline and can only be used for Practice Mode and System Link games.\n",PosX=0.100000,PosY=0.175000,MaxSizeX=0.800000,bHidden=1,Style="LongMessageText")
     WasNewMessage=(Text="Do you want to save an Xbox Live map?\n\nIf you sign in first, you will be able to publish your map on Xbox Live and share it with your friends.\n\nIf you don't sign in first, it will be classified as Offline and can only be used for Practice Mode and System Link games.\n",PosX=0.100000,PosY=0.175000,MaxSizeX=0.800000,bHidden=1,Style="LongMessageText")
     OptionLayout=(PosX=0.100000,SpacingY=0.050000,BorderScaleX=0.400000)
     Options(0)=(Blurred=(Text="Sign in to Xbox Live first"),OnSelect="OnSignInFirst",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Save for Offline play"),OnSelect="OnSaveForOfflinePlay")
     MenuTitle=(Text="Warning")
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
