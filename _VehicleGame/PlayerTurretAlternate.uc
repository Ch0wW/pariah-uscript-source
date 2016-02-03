class PlayerTurretAlternate extends PlayerTurret
	placeable;

simulated function SpawnMuzFlash()
{
	FlashEffect1 = Spawn(class'VehicleEffects.turret_flashManned', self);
	if(FlashEffect1 != none)
    {
	    AttachToBone(FlashEffect1, 'FX1');
		FlashEffect1.SetDrawScale(4.0);
		FlashEffect1.SetRelativeLocation(vect(710, 0, 25) );
	}

	FlashEffect2 = Spawn(class'VehicleEffects.turret_flashManned', self);
	if(FlashEffect2 != none)
    {
	    AttachToBone(FlashEffect2, 'FX2');
		FlashEffect2.SetDrawScale(4.0);
		FlashEffect2.SetRelativeLocation(vect(710, 0, 25) );
	}
}

defaultproperties
{
     ViewMaxPitch=6500
     ViewMinPitch=59000
     PitchMax=7000.000000
     PitchMin=-7500.000000
     SwivelBone="SwingArm"
     ExitPoint=(Y=-340.000000)
     TurretCameraOffset=(X=400.000000,Z=400.000000)
     WeaponClass="VehicleWeapons.PlayerTurretDualCannon"
     Health=100000
     CollisionRadius=330.000000
     CollisionHeight=100.000000
     Mesh=SkeletalMesh'PariahTurrets.Turret03'
     AmbientGlow=120
}
