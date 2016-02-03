//=============================================================================
//=============================================================================
class VGRocketLauncherPickup extends VehicleWeaponPickupPlaceable;

defaultproperties
{
     bVehiclePickup=False
     bCharacterPickup=True
     MaxDesireability=0.400000
     InventoryType=Class'VehicleWeapons.VGRocketLauncher'
     PickupMessage="You got the Rocket Launcher."
     CantPickupMessage="You already have the Rocket Launcher."
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.RocketLauncher_3rd'
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
