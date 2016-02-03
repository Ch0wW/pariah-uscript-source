class PlayerTitansFistFire extends TitansFistFire;

var	   TitansFistMuzzleFlash	FlashEffect;


function Destroyed()
{
	Super.Destroyed();

	if(FlashEffect != none)
		FlashEffect.Destroy();
}

state Charge
{

	event ModeDoFire()
	{
		local playercontroller PC;
		
		PC = PlayerController(Instigator.Controller);
		if( PC != None )		
			PC.AddImpulse( spring_force_applied ); //new cam shake (xmatt)
		Super.ModeDoFire();

		if( FlashEffect != none )
			FlashEffect.StartFlash();

        GotoState('');
	}

}

function InitEffects()
{
    Super.InitEffects();


	if(FlashEffect == none)
		FlashEffect = Spawn(class'VehicleEffects.TitansFistMuzzleFlash', self);
		
	if(FlashEffect != none) 
	{
		Weapon.AttachToBone(FlashEffect, 'FX1');
		FlashEffect.SetRelativeLocation(vect(-2, 0, 4) );
	}

}

defaultproperties
{
     AmmoDrainMin=5
     AmmoDrainMax=25
     FullChargeTime=3.000000
     BeamEffectClass=None
     HealthDrainDamageType=Class'VehicleWeapons.TitanDrainDamage'
}
