//=============================================================================
// SniperRiflePickup.
//=============================================================================
class SniperRiflePickup extends VehicleWeaponPickupPlaceable;

//#exec OBJ LOAD FILE=PickupSounds.uax

defaultproperties
{
     bVehiclePickup=False
     bCharacterPickup=True
     MaxDesireability=0.400000
     InventoryType=Class'VehicleWeapons.SniperRifle'
     PickupMessage="You got the Sniper Rifle."
     CantPickupMessage="You already have the Sniper Rifle."
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.SniperRifle_3rd'
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
