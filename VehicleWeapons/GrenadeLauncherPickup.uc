//=============================================================================
//=============================================================================
class GrenadeLauncherPickup extends VehicleWeaponPickupPlaceable;

defaultproperties
{
     bVehiclePickup=False
     bCharacterPickup=True
     MaxDesireability=0.400000
     InventoryType=Class'VehicleWeapons.GrenadeLauncher'
     PickupMessage="You got the Grenade Launcher."
     CantPickupMessage="You already have the Grenade Launcher."
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.GrenadeLauncher_3rd'
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
