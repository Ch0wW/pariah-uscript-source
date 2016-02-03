class AnimNotify_FireWeapon extends AnimNotify_Scripted;

event Notify( Actor Owner )
{
	// fake fire - play weapon effect, but no real shot
	Pawn(Owner).bIgnorePlayFiring = true;
	WeaponAttachment(Pawn(Owner).Weapon.ThirdPersonActor).ThirdPersonEffects();
	if ( Pawn(Owner).Weapon.FireMode[0].FireSound != None ) // sjs
		Pawn(Owner).Weapon.PlaySound(Pawn(Owner).Weapon.FireMode[0].FireSound, SLOT_None, 1.0); // sjs
}

defaultproperties
{
}
