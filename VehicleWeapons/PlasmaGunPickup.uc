//=============================================================================
// AssaultRiflePickup.
//=============================================================================
class PlasmaGunPickup extends VehicleWeaponPickup;

defaultproperties
{
     MaxDesireability=0.400000
     InventoryType=Class'VehicleWeapons.PlasmaGun'
     PickupMessage="You got the Plasma Gun."
     CantPickupMessage="You already have the Plasma Gun."
     DrawScale=0.500000
     StaticMesh=StaticMesh'PariahWeaponMeshes.Weapons.WeaponPlasma'
     MessageClass=Class'UnrealGame.PickupMessagePlus'
}
