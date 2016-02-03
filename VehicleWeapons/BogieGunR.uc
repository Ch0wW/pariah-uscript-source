//=============================================================================
// Bogie driver controlled weapon
//=============================================================================
class BogieGunR extends BogieGun;

defaultproperties
{
     fireSeq=1
     WeaponMountName(0)="WP2"
     FireModeClass(0)=Class'VehicleWeapons.BogieGunFireR'
     AttachmentClass=Class'VehicleWeapons.BogieGunAttachmentR'
     ItemName="BogieGunR"
}
