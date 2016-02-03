//=============================================================================
//=============================================================================
class HaserPickup extends VehicleWeaponPickup;

defaultproperties
{
     MaxDesireability=0.400000
     InventoryType=Class'VehicleWeapons.Haser'
     PickupMessage="You got the Haser."
     CantPickupMessage="You already have the Haser."
     DrawScale=0.500000
     StaticMesh=StaticMesh'PariahWeaponMeshes.Weapons.WeaponBullets'
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
