class FragRiflePickup extends VehicleWeaponPickupPlaceable;

defaultproperties
{
     bVehiclePickup=False
     bCharacterPickup=True
     MaxDesireability=0.700000
     InventoryType=Class'VehicleWeapons.FragRifle'
     PickupMessage="You got the Frag Rifle."
     CantPickupMessage="You already have the Frag Rifle."
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.FragRifle_3rd'
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
