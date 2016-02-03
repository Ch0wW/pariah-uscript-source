class MenuMiniEdLoadLiveOffline extends MenuTemplateTitledBA;

var() MenuText LiveMessage;
var() WidgetLayout OptionLayout;
var() MenuButtonText Options[2];

var() String URL;

simulated function Init(String Args)
{
    URL = Args;
    
    Super.Init("");
}

simulated function HandleInputBack()
{
    CloseMenu();
}

simulated function OnSignInFirst()
{
    CallMenuClass( "XInterfaceLive.MenuLiveSignIn", "MINIED_PROMPT" );
}

simulated function OnLoadAnyway()
{
    PlayerController(Owner).ClientTravel( URL, TRAVEL_Absolute, false );	
}

simulated function DoDynamicLayout( Canvas C )
{
    local float DY;
    
    Super.DoDynamicLayout( C );

    DY = GetWrappedTextHeight( C, LiveMessage );

    OptionLayout.PosY = LiveMessage.PosY + DY + (OptionLayout.SpacingY * 0.5);

    LayoutArray( Options[0], 'OptionLayout' );
}

simulated function bool MenuClosed( Menu ClosingMenu )
{
    local String ClassName;
    
    ClassName = String(ClosingMenu.Class);
    
    if( ClassName == "XInterfaceLive.MenuLiveSignIn" )
    {
        // Cancelled!
    }
    else
    {
        PlayerController(Owner).ClientTravel( URL, TRAVEL_Absolute, false );	
    }

    return(true);
}

defaultproperties
{
     LiveMessage=(Text="You are about to load an Xbox Live map while offline.\n\nIf you don't sign in first, it will be classified as Offline and can only be saved for Practice Mode and System Link games.\n",PosX=0.100000,PosY=0.175000,MaxSizeX=0.800000,Style="LongMessageText")
     OptionLayout=(PosX=0.100000,SpacingY=0.050000,BorderScaleX=0.400000)
     Options(0)=(Blurred=(Text="Sign in to Xbox Live First"),OnSelect="OnSignInFirst",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Load it offline"),OnSelect="OnLoadAnyway")
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
