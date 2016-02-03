class LoadOutMenu extends MenuTemplateTitledBA;

var() MenuButtonText LoadOuts[8];
var VehiclePlayer MyPlayer;
var() config int Position;

simulated function Init( String Args )
{
    Super.Init( Args );
    LayoutArray( LoadOuts[0], 'TitledOptionLayout' );
    Position = Clamp( Position, 0, ArrayCount(LoadOuts) - 1 );
    FocusOnWidget( LoadOuts[Position] );
    MyPlayer = VehiclePlayer(Owner);
}

simulated function AddWeapons(string Wep1ClassName, string Wep2ClassName)
{
    local class<Weapon> WepClass;
    WepClass = class<Weapon>(DynamicLoadObject(Wep1ClassName, class'Class'));
    if(WepClass == None)
    {
        log("*** Weapon class not found: "@Wep1ClassName);
    }
    MyPlayer.LoadPlayerWeapon(WepClass, 0);
    MyPlayer.ClientLoadPlayerWeapon(WepClass, 0);
    WepClass = class<Weapon>(DynamicLoadObject(Wep2ClassName, class'Class'));
    if(WepClass == None)
    {
        log("*** Weapon class not found: "@Wep2ClassName);
    }
	MyPlayer.LoadPlayerWeapon(WepClass, 1);
    MyPlayer.ClientLoadPlayerWeapon(WepClass, 1);
}

simulated function SavePosition()
{
    for( Position = 0; Position < ArrayCount(LoadOuts); Position++ )
    {
        if( LoadOuts[Position].bHasFocus != 0 )
            break;
    }
    
    if( Position >= ArrayCount(LoadOuts) )
        Position = 0;

    SaveConfig();
}

simulated function OnFocusChange()
{
    Super.OnFocusChange();
    
    for( Position = 0; Position < ArrayCount(LoadOuts); Position++ )
    {
        if( LoadOuts[Position].bHasFocus != 0 )
            break;
    }
    
    if( Position >= ArrayCount(LoadOuts) )
        Position = 0;
        
    HelpTextState = HTS_Show;
    HelpTextStateDelays[HelpTextState] = default.HelpTextStateDelays[HelpTextState];
    HelpText.Text = LoadOuts[Position].HelpText;
}

simulated function DoLoadout()
{
    local PlayerController PC;
    
    SavePosition();
    
    //BullDog/Heal 	- Lightweight 
    //Plasma/Frag	- Shredder
    //Plasma/Heal	- Medic
    //Rocket/Grenade - Demolisher
    //Rocket/Sniper	- Lancer 
    //Grenade/Frag	-  Gutbuster
    //Sniper/Heal	- Rifleman
    //Bulldog/frag	- Assault
    
    switch(Position)
    {
        case 0:
            AddWeapons("VehicleWeapons.VGAssaultRifle", "VehicleWeapons.GrenadeLauncher");
            break;
        case 1:
            AddWeapons("VehicleWeapons.PlayerPlasmaGun", "VehicleWeapons.FragRifle");
            break;
        case 2:
            AddWeapons("VehicleWeapons.PlayerPlasmaGun", "VehicleWeapons.SniperRifle");
            break;
        case 3:
            AddWeapons("VehicleWeapons.VGRocketLauncher", "VehicleWeapons.GrenadeLauncher");
            break;
        case 4:
            AddWeapons("VehicleWeapons.VGRocketLauncher", "VehicleWeapons.SniperRifle");
            break;
        case 5:
            AddWeapons("VehicleWeapons.GrenadeLauncher", "VehicleWeapons.FragRifle");
            break;
        case 6:
            AddWeapons("VehicleWeapons.SniperRifle", "VehicleWeapons.FragRifle");
            break;
        case 7:
            AddWeapons("VehicleWeapons.VGAssaultRifle", "VehicleWeapons.PlayerPlasmaGun");
            break;
    }

    CloseMenu();

    CrossFadeLevel = 0.f;
    CrossFadeDir = TD_None;

    PC = PlayerController(Owner);

    PC.Player.bDominateSplit = false;
    PC.SetPause( false );
    PC.MenuMessage("DONELOADOUT");
    VehiclePlayer(PC).bLoadedOut = true;
}

simulated function bool HandleInputGamePad( String ButtonName )
{
    if( ButtonName ~= "RT" ) // allow trigger to do it also
    {
        DoLoadout();
        return( true );
    }
    return( Super.HandleInputGamePad( ButtonName ) );
}

simulated function HandleInputBack()
{
    CloseMenu();
    
    CrossFadeLevel = 0.f;
    CrossFadeDir = TD_None;
}

defaultproperties
{
     LoadOuts(0)=(Blurred=(Text="Lightweight",PosX=0.145000),HelpText="Bulldog / Grenade Launcher",OnSelect="DoLoadout",Style="TitledTextOption")
     LoadOuts(1)=(Blurred=(Text="Shredder"),HelpText="Plasma Rifle / Frag Rifle",OnSelect="DoLoadout")
     LoadOuts(2)=(Blurred=(Text="Griever"),HelpText="Plasma Rifle / Sniper Rifle",OnSelect="DoLoadout")
     LoadOuts(3)=(Blurred=(Text="Demolisher"),HelpText="Rocket Launcher / Grenade Launcher",OnSelect="DoLoadout")
     LoadOuts(4)=(Blurred=(Text="Lancer"),HelpText="Sniper Rifle / Rocket Launcher",OnSelect="DoLoadout")
     LoadOuts(5)=(Blurred=(Text="Gutbuster"),HelpText="Grenade Launcher / Frag Rifle",OnSelect="DoLoadout")
     LoadOuts(6)=(Blurred=(Text="Rifleman"),HelpText="Sniper Rifle / Frag Rifle",OnSelect="DoLoadout")
     LoadOuts(7)=(Blurred=(Text="Trooper"),HelpText="Bulldog / Plasma Rifle",OnSelect="DoLoadout")
     BLabel=(Text="Cancel")
     MenuTitle=(Text="Choose weapon load-out")
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
