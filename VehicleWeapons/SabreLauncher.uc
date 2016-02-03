//=============================================================================
//=============================================================================
class SabreLauncher extends VehicleWeapon;

function float GetAIRating()
{
	return AIRating;
}

defaultproperties
{
     WeaponMountName(0)="WP3"
     AIRating=0.400000
     CurrentRating=0.400000
     IdleAnim="Breathe"
     FireModeClass(0)=Class'VehicleWeapons.SabreLauncherFire'
     bCanThrow=False
     bDontDrawVehicleReticle=True
     AttachmentClass=Class'VehicleWeapons.SabreLauncherAttachment'
     ItemName="Sabre Launcher"
     InventoryGroup=6
     BarIndex=6
     bDrawingFirstPerson=True
     bHidden=False
     bOnlyOwnerSee=False
     bOnlyRelevantToOwner=False
}
