class BoneSawPickup extends VehicleWeaponPickupPlaceable;

defaultproperties
{
     bVehiclePickup=False
     bCharacterPickup=True
     MaxDesireability=0.400000
     InventoryType=Class'VehicleWeapons.BoneSaw'
     PickupMessage="You got the Bonesaw."
     CantPickupMessage="You already have the Bonesaw."
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.BoneSaw_3rd'
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
