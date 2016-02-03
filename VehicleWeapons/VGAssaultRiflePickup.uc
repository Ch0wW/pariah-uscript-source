//=============================================================================
// AssaultRiflePickup.
//=============================================================================
class VGAssaultRiflePickup extends VehicleWeaponPickupPlaceable;

//#exec OBJ LOAD FILE=PickupSounds.uax

defaultproperties
{
     bVehiclePickup=False
     bCharacterPickup=True
     MaxDesireability=0.400000
     InventoryType=Class'VehicleWeapons.VGAssaultRifle'
     PickupMessage="You got the Bulldog."
     CantPickupMessage="You already have the Bulldog."
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.Bulldog_3rd'
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
