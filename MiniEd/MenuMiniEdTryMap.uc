class MenuMiniEdTryMap extends MenuTemplateTitledBA;

var() MenuButtonText Options[4];

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );
    LayoutArray( Options[0], 'TitledOptionLayout' );
}

simulated function CloseAllMenus()
{
    local PlayerController PC;
    
    PC = PlayerController(Owner);
    
    if( PC == None )
    {
        return;
    }
    
    PC.Player.Console.MenuClose();
}

simulated function OnFoot()
{
    CloseAllMenus();
    ConsoleCommand( "TRYMAP IN TRANSPORTATION=0");
}

simulated function OnWasp()
{
    CloseAllMenus();
    ConsoleCommand( "TRYMAP IN TRANSPORTATION=1");
}

simulated function OnDart()
{
    CloseAllMenus();
    ConsoleCommand( "TRYMAP IN TRANSPORTATION=2");
}

simulated function OnBogie()
{
    CloseAllMenus();
    ConsoleCommand( "TRYMAP IN TRANSPORTATION=3");
}

simulated function HandleInputBack()
{
    GotoMenuClass("MiniEd.MenuMiniEdMain");
}

defaultproperties
{
     Options(0)=(Blurred=(Text="On Foot"),OnSelect="OnFoot",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="In Wasp"),OnSelect="OnWasp")
     Options(2)=(Blurred=(Text="In Dart"),OnSelect="OnDart")
     Options(3)=(Blurred=(Text="In Bogie"),OnSelect="OnBogie")
     MenuTitle=(Text="Try Map")
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
