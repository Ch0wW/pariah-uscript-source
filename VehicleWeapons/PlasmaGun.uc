//=============================================================================
// Plasma Gun
//=============================================================================
class PlasmaGun extends VehicleWeapon;

function float GetAIRating()
{
	return AIRating;
}

defaultproperties
{
     AIRating=0.400000
     CurrentRating=0.400000
     AutoAimFactor=0.500000
     FireModeClass(0)=Class'VehicleWeapons.PlasmaGunFire'
     bCanThrow=False
     PickupClass=Class'VehicleWeapons.PlasmaGunPickup'
     AttachmentClass=Class'VehicleWeapons.PlasmaGunAttachment'
     ItemName="Plasma Gun"
     InventoryGroup=2
     BarIndex=2
}
