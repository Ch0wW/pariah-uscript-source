class WeaponAttachment extends InventoryAttachment
	native
	nativereplication;

var		byte	FlashCount;			// when incremented, draw muzzle flash for current frame
var		bool	bAutoFire;			// When set to true.. begin auto fire sequence (used to play looping anims)
var		byte	FiringMode;			// replicated to identify what type of firing/reload animations to play
var		float	FiringSpeed;		// used by human animations to determine the appropriate speed to play firing animations

var	  bool bHasWeaponBone;	// for those weapons that have a special weapon bone that get rotated rather than thier base

var() enum EWeaponType
{
	EWT_Other,
	EWT_HealingTool,
	EWT_FragRifle,
	EWT_GrenadeLauncher,
	EWT_PlasmaGun,
	EWT_TitansFist,
	EWT_RocketLauncher,
	EWT_Bulldog,
	EWT_BoneSaw,
	EWT_FlameThrower,
	EWT_GrenadeDetonator,
	EWT_SniperRifle,
	EWT_None
}WeaponType;


replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && !bNetOwner && (Role==ROLE_Authority) )
		FlashCount, FiringMode, bAutoFire;
}

simulated function HitEffectNotify(Effects e);

/* 
ThirdPersonEffects called by Pawn's C++ tick if FlashCount incremented
becomes true
OR called locally for local player
*/
simulated event ThirdPersonEffects()
{
	// spawn 3rd person effects

	// have pawn play firing anim
	if ( Instigator != None )
		Instigator.PlayFiring(1.0,FiringMode);
}

defaultproperties
{
     FiringSpeed=1.000000
     bActorShadows=True
     bReplicateInstigator=True
}
