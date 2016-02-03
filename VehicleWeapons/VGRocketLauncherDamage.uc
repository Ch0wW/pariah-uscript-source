class VGRocketLauncherDamage extends DamageType;

/*
static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
		HitEffects[0] = class'HitSmoke';

		if( VictemHealth <= 0 && FRand() < 0.2 )
				HitEffects[1] = class'HitFlameBig';
		else if ( FRand() < 0.8 )
				HitEffects[1] = class'HitFlame';
}
*/

defaultproperties
{
     DamageDesc=16
     GibModifier=4.000000
     HavokHitImpulseScale=7.000000
     HavokVehicleHitImpulseScale=15.000000
     WeaponClass=Class'VehicleWeapons.VGRocketLauncher'
     DeathString="%o rode %k's rocket into oblivion."
     FemaleSuicide="%o fired her rocket prematurely."
     MaleSuicide="%o fired his rocket prematurely."
     bDetonatesGoop=True
}
