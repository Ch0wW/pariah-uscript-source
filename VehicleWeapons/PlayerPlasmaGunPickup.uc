//=============================================================================
//=============================================================================
class PlayerPlasmaGunPickup extends VehicleWeaponPickupPlaceable;

defaultproperties
{
     bVehiclePickup=False
     bCharacterPickup=True
     MaxDesireability=0.700000
     InventoryType=Class'VehicleWeapons.PlayerPlasmaGun'
     PickupMessage="You got a Plasma Gun."
     CantPickupMessage="You already have the Plasma Gun."
     StaticMesh=StaticMesh'PariahWeaponMeshes.3rd_Weapons.PlasmaGun_3rd'
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
