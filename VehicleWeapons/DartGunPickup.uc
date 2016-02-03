//=============================================================================
//=============================================================================
class DartGunPickup extends VehicleWeaponPickup;

defaultproperties
{
     MaxDesireability=0.400000
     InventoryType=Class'VehicleWeapons.DartGun'
     PickupMessage="You got the Dart Gun."
     CantPickupMessage="You already have the Dart Gun."
     DrawScale=0.500000
     StaticMesh=StaticMesh'PariahWeaponMeshes.Weapons.WeaponBullets'
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
