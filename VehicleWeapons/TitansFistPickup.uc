class TitansFistPickup extends VehicleWeaponPickupPlaceable;

defaultproperties
{
     bVehiclePickup=False
     bCharacterPickup=True
     MaxDesireability=0.700000
     InventoryType=Class'VehicleWeapons.TitansFist'
     PickupMessage="You got Titan's Fist."
     CantPickupMessage="You already have Titan's Fist."
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.TitansFist_3rd'
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
