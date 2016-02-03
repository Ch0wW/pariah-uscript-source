class BogieGunAttachmentL extends VehicleWeaponAttachment;//WeaponAttachment;

#exec OBJ LOAD FILE=..\Animations\PariahVehicleWeaponAnimations.ukx

var	float		CurrentRoll;
var	MuzzleFlash	MuzParticles;

function SetTracking(bool bTracking)
{
	bIsTracking = bTracking;
//	log("Owner = "$Owner);
//	if(Owner != none && VGVehicle(Owner).Weapon != none && VGVehicle(Owner).Weapon.IsA('BogieGun') )
//		VehicleWeaponAttachment(BogieGun(VGVehicle(Owner).Weapon).slaveGun.ThirdPersonActor).bIsTracking = bTracking;
}

simulated event ThirdPersonEffects()
{
    if (Level.NetMode == NM_DedicatedServer || Instigator == None)
        return;

//	if(BogieGun(Pawn(Owner).Weapon).whichFiredLast == 0) {
//		BogieGunAttachmentR(BogieGun(Pawn(Owner).Weapon).slaveGun.ThirdPersonActor).ThirdPersonEffects();
//		return;
//	}

    if (FlashCount == 0)
    {
        bDynamicLight = false;
    }
    if (FlashCount > 0 && MuzFlashClass != None)
    {
        if (FiringMode == 0 && bFlashForPrimary || FiringMode == 1 && bFlashForAlt)
        {
            if (MuzFlash == None)
            {
                MuzFlash = Spawn(MuzFlashClass);
				AttachToWeaponAttachment(MuzFlash, MuzzleRef);
            }
			if(MuzParticles == None)
			{
				MuzParticles = Spawn(class'DavidPuncherMuzzle');
				AttachToWeaponAttachment(MuzParticles, MuzzleRef);
			}
            FlashFlash(FiringMode);
			/*
			if ( Instigator.Role < ROLE_AutonomousProxy )
			{
				AmbientSound = Sound'SM-chapter03sounds.TurretOneSecondLoopB';
				SetTimer(0.2, false);
			}
			*/
        }
    }
}

simulated function FlashFlash(byte mode)
{
    MuzFlash.Flash(mode);
	MuzParticles.Flash(mode);
    //if (bFlashLight && !Level.bDropDetail && Level.bHighDetailMode)
    //    bDynamicLight = true;
	PlayAnim('Fire', 1.0, 0.0);
}

simulated function Tick(float dt)
{
	local rotator	NewRotation;
	local float		YawDiff, PitchDiff;
	local float		MaxYawDiff, MaxPitchDiff;

    if(Base == None)
    {
        Destroy();
        return;
    }

	if(Owner != none && Owner.Owner != none && Instigator != none && Instigator.Controller == none && ROLE == Role_Authority)
	{
		NewRotation.Yaw = Owner.Owner.Rotation.Yaw;
		NewRotation.Pitch = Owner.Owner.Rotation.Pitch;
		NewRotation.Roll = 0;

		YawDiff = (NewRotation.Yaw & 65535) - (AimRotation.Yaw & 65535);

		if (YawDiff < -32768) yawDiff += 65536;
		else if (YawDiff > 32768) YawDiff -= 65536;

		if(YawMax != 0 && YawDiff >= YawMax) {
			NewRotation.Yaw = Owner.Owner.Rotation.Yaw+YawMax;
		}

		if(YawMin != 0 && YawDiff <= YawMin) {
			NewRotation.Yaw = Owner.Owner.Rotation.Yaw+YawMin;
		}

		YawDiff = (NewRotation.Yaw & 65535) - (AimRotation.Yaw & 65535);

		if (YawDiff < -32768) yawDiff += 65536;
		else if (YawDiff > 32768) YawDiff -= 65536;

		MaxYawDiff = dt * MaxRotationRate;		//Maximum number of units to rotate this update
		if(Abs(YawDiff) > MaxYawDiff)
		{
			if(YawDiff > 0)
				YawDiff = MaxYawDiff;
			else
				YawDiff = -MaxYawDiff;
		}

		// now same thing for pitch
		PitchDiff = (NewRotation.Pitch & 65535) - (AimRotation.Pitch & 65535);

		if (PitchDiff < -32768) PitchDiff += 65536;
		else if (PitchDiff > 32768) PitchDiff -= 65536;

		if(PitchMax != 0 && PitchDiff >= PitchMax) {
			NewRotation.Pitch = Owner.Owner.Rotation.Pitch+PitchMax;
		}

		if(PitchMin != 0 && PitchDiff <= PitchMin) {
			NewRotation.Pitch = Owner.Owner.Rotation.Pitch+PitchMin;
		}

		PitchDiff = (NewRotation.Pitch & 65535) - (AimRotation.Pitch & 65535);

		if (PitchDiff < -32768) PitchDiff += 65536;
		else if (PitchDiff > 32768) PitchDiff -= 65536;

		MaxPitchDiff = dt * MaxRotationRate;		//Maximum number of units to rotate this update
		if(Abs(PitchDiff) > MaxPitchDiff)
		{
			if(PitchDiff > 0)
				PitchDiff = MaxPitchDiff;
			else
				PitchDiff = -MaxPitchDiff;
		}

		AimRotation.Pitch += PitchDiff;
		AimRotation.Roll = NewRotation.Roll;
		AimRotation.Yaw += YawDiff;

		if(AimRotation.Pitch < PitchMin)
			AimRotation.Pitch = PitchMin;
		if(AimRotation.Pitch > PitchMax)
			AimRotation.Pitch = PitchMax;

		NewRotation.Pitch = AimRotation.Pitch-Base.Rotation.Pitch;
		NewRotation.Roll = 0;
		Weapon(Owner).RealPitch = NewRotation.Pitch;
		NewRotation.Pitch = 0;
		NewRotation.Yaw = AimRotation.Yaw-Base.Rotation.Yaw;
		SetRelativeRotation(NewRotation);

		if(Role == ROLE_Authority) 
		{
			// this allows us to replicate the weapon rotation to the client, yay!
			WBRYaw = NewRotation.Yaw;
			WBRPitch = NewRotation.Pitch;
		}

		if(Role < ROLE_Authority && bNetOwner) 
		{
		    //Instigator.Controller.Pawn.IsA('VGVehicle') ) {// && Owner != None) {
		    QueueRotationAim(NewRotation, AimRotation);
		}
	}
	else if(Instigator != none && Instigator.Controller != none 
		&& Instigator.Controller.IsA('VehiclePlayer') 
		&& Instigator.IsLocallyControlled())
	{
		if(TargetTime < MaxTargetTime)
		{
			NewRotation = Instigator.Controller.Rotation;
			NewRotation.Pitch += 1250;
			NewRotation.Roll = Instigator.Rotation.Roll;
			TargetTime += dt;
		}
		else
		{
			NewRotation = Instigator.Controller.Rotation;
			NewRotation.Pitch += 1250;
			NewRotation.Roll = Instigator.Rotation.Roll;
		}

		// make sure the weapon doesn't turn more than is allowed
		YawDiff = (NewRotation.Yaw & 65535) - (Instigator.Rotation.Yaw & 65535);

		if (YawDiff < -32768) yawDiff += 65536;
		else if (YawDiff > 32768) YawDiff -= 65536;

		if(YawMax != 0 && YawDiff >= YawMax) {
			NewRotation.Yaw = Instigator.Rotation.Yaw+YawMax;
		}

		if(YawMin != 0 && YawDiff <= YawMin) {
			NewRotation.Yaw = Instigator.Rotation.Yaw+YawMin;
		}

		YawDiff = (NewRotation.Yaw & 65535) - (AimRotation.Yaw & 65535);

		if (YawDiff < -32768) yawDiff += 65536;
		else if (YawDiff > 32768) YawDiff -= 65536;

		MaxYawDiff = dt * MaxRotationRate;		//Maximum number of units to rotate this update
		if(Abs(YawDiff) > MaxYawDiff)
		{
			if(YawDiff > 0)
				YawDiff = MaxYawDiff;
			else
				YawDiff = -MaxYawDiff;
		}

		// now same thing for pitch
		PitchDiff = (NewRotation.Pitch & 65535) - (Instigator.Rotation.Pitch & 65535);

		if (PitchDiff < -32768) PitchDiff += 65536;
		else if (PitchDiff > 32768) PitchDiff -= 65536;

		if(PitchMax != 0 && PitchDiff >= PitchMax) {
			NewRotation.Pitch = Instigator.Rotation.Pitch+PitchMax;
		}

		if(PitchMin != 0 && PitchDiff <= PitchMin) {
			NewRotation.Pitch = Instigator.Rotation.Pitch+PitchMin;
		}

		PitchDiff = (NewRotation.Pitch & 65535) - (AimRotation.Pitch & 65535);

		if (PitchDiff < -32768) PitchDiff += 65536;
		else if (PitchDiff > 32768) PitchDiff -= 65536;

		MaxPitchDiff = dt * MaxRotationRate;		//Maximum number of units to rotate this update
		if(Abs(PitchDiff) > MaxPitchDiff)
		{
			if(PitchDiff > 0)
				PitchDiff = MaxPitchDiff;
			else
				PitchDiff = -MaxPitchDiff;
		}

		AimRotation.Pitch += PitchDiff;
		AimRotation.Roll = NewRotation.Roll;
		AimRotation.Yaw += YawDiff;
		NewRotation.Pitch = AimRotation.Pitch-Base.Rotation.Pitch;
		if(Owner != none && Owner.IsA('Weapon') )
			Weapon(Owner).RealPitch = NewRotation.Pitch;
		NewRotation.Pitch = 0;
		NewRotation.Roll = 0;
		NewRotation.Yaw = AimRotation.Yaw-Base.Rotation.Yaw;
		SetRelativeRotation(NewRotation);
		if(Role == ROLE_Authority) 
		{
			// this allows us to replicate the weapon rotation to the client, yay!
			WBRYaw = NewRotation.Yaw;
			WBRPitch = NewRotation.Pitch;
		}
		if(Role < ROLE_Authority) 
		{
		    // && bIsTracking && bNetOwner) {//Instigator.Controller.Pawn.IsA('VGVehicle') ) {// && Owner != None) {
		    QueueRotationAim(NewRotation, AimRotation);
		}
	}
	else if(Role < ROLE_Authority) 
	{
		NewRotation.Pitch = WBRPitch;
		if(Owner != none && Owner.IsA('Weapon') )
			Weapon(Owner).RealPitch = AimRotation.Pitch-Base.Rotation.Pitch;
		NewRotation.Yaw = WBRYaw;
		NewRotation.Roll = 0;
		SetRelativeRotation(NewRotation);
	}
}

function ServerSetAim(rotator aim)
{
	AimRotation = aim;
	if(Owner != none && Owner.IsA('Weapon') )
		Weapon(Owner).RealPitch = AimRotation.Pitch-Base.Rotation.Pitch;
}

defaultproperties
{
     YawMax=3000.000000
     YawMin=-3000.000000
     PitchMax=2000.000000
     PitchMin=-2000.000000
     MuzFlashClass=Class'VehicleEffects.MachinegunMuzzleFlash'
     MuzzleOffset=(X=100.000000,Z=12.000000)
     bHeavy=True
     bFlashForPrimary=True
     bFlashLight=True
     Mesh=SkeletalMesh'PariahVehicleWeaponAnimations.BogieGun01'
     DrawType=DT_Mesh
}
