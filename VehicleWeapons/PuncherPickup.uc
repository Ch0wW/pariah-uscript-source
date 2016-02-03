//=============================================================================
//=============================================================================
class PuncherPickup extends VehicleWeaponPickup;

defaultproperties
{
     MaxDesireability=0.400000
     InventoryType=Class'VehicleWeapons.Puncher'
     PickupMessage="You got the Puncher."
     CantPickupMessage="You already have the Puncher."
     DrawScale=0.500000
     StaticMesh=StaticMesh'PariahWeaponMeshes.Weapons.WeaponBullets'
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
