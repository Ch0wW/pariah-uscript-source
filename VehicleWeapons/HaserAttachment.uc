class HaserAttachment extends VehicleWeaponAttachment;//WeaponAttachment;

#exec OBJ LOAD FILE=..\Animations\PariahVehicleWeaponAnimations.ukx

//replication 
//{
//	reliable if(Role == ROLE_Authority)
//		WeaponBoneRotation;
//	reliable if(Role < ROLE_Authority && bNetOwner)
//		ServerSetAim;
//}

simulated function Tick(float dt)
{
	local rotator	NewRotation, tempRotation;
	local float		YawDiff, PitchDiff;
	local float		MaxYawDiff, MaxPitchDiff;

	if(Instigator != none && Instigator.Controller == none && Role == ROLE_Authority) {
		NewRotation.Yaw = Owner.Owner.Rotation.Yaw;
		NewRotation.Pitch = Owner.Owner.Rotation.Pitch;
		NewRotation.Roll = 0;

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

		AimRotation.Roll = 0;//NewRotation.Roll;
		AimRotation.Yaw += YawDiff;
		AimRotation.Pitch += PitchDiff;//NewRotation.Pitch;

		if(AimRotation.Pitch < PitchMin)
			AimRotation.Pitch = PitchMin;
		if(AimRotation.Pitch > PitchMax)
			AimRotation.Pitch = PitchMax;

		NewRotation.Roll = 0;
		NewRotation.Pitch = Base.Rotation.Pitch-AimRotation.Pitch;
		NewRotation.Yaw = Base.Rotation.Yaw-AimRotation.Yaw;
//		SetRelativeRotation(NewRotation);
		tempRotation.Roll = 0;
		tempRotation.Pitch = 0;
		tempRotation.Yaw = -NewRotation.Yaw;
		SetRelativeRotation(tempRotation);

		NewRotation.Yaw = 0;
		SetBoneRotation('Weapon', NewRotation);
		NewRotation.Yaw = -tempRotation.Yaw;

		if(Role == ROLE_Authority) {
			// this allows us to replicate the weapon rotation to the client, yay!
			WeaponBoneRotation = NewRotation;
			WeaponBoneRotation.Yaw = tempRotation.Yaw;
			WeaponBoneRotation.Roll = dt;
		}
//		log("AimRot = "$AimRotation);
		if(Role < ROLE_Authority) {// && Instigator.Controller.Pawn.IsA('VGVehicle') ) {
			ServerSetRotation(NewRotation);
			ServerSetAim(AimRotation);
		}
	}
	else if(Instigator != none && Instigator.Controller != none 
		&& Instigator.Controller.IsA('VehiclePlayer') 
		&& Instigator.IsLocallyControlled())
	{
//		if(Instigator.IsA('VGVehicle') ) {
//			NewRotation.Yaw = Instigator.Rotation.Yaw;
//			NewRotation.Pitch = 0;
//			NewRotation.Roll = 0;
//		}
		if(VehiclePlayer(Instigator.Controller).Target != none)
		{
			NewRotation = rotator(VehiclePlayer(Instigator.Controller).Target.Location - Location);
//			NewRotation.Pitch += 1250;//Instigator.Rotation.Pitch;	//don't pitch
			NewRotation.Roll = Instigator.Rotation.Roll;	//don't Roll
			TargetTime = 0.0;
		}
		else if(TargetTime < MaxTargetTime)
		{
			NewRotation = Instigator.Controller.Rotation;
			NewRotation.Pitch += 1250;//Instigator.Rotation.Pitch;	//don't pitch
			NewRotation.Roll = Instigator.Rotation.Roll;	//don't Roll
			TargetTime += dt;
		}
		else
		{
			NewRotation = Instigator.Controller.Rotation;
			NewRotation.Pitch += 1250;//Instigator.Rotation.Pitch;	//don't pitch
			NewRotation.Roll = Instigator.Rotation.Roll;	//don't Roll
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

		AimRotation.Roll = NewRotation.Roll;
		AimRotation.Yaw += YawDiff;
		AimRotation.Pitch += PitchDiff;//NewRotation.Pitch;
		NewRotation.Roll = 0;
		NewRotation.Pitch = Base.Rotation.Pitch-AimRotation.Pitch;
		NewRotation.Yaw = Base.Rotation.Yaw-AimRotation.Yaw;

		tempRotation.Roll = 0;
		tempRotation.Pitch = 0;
		tempRotation.Yaw = -NewRotation.Yaw;
		SetRelativeRotation(tempRotation);

		NewRotation.Yaw = 0;
		SetBoneRotation('Weapon', NewRotation);
		NewRotation.Yaw = -tempRotation.Yaw;

		if(Role == ROLE_Authority) {
			// this allows us to replicate the weapon rotation to the client, yay!
			WeaponBoneRotation = NewRotation;
			WeaponBoneRotation.Yaw = tempRotation.Yaw;
			WeaponBoneRotation.Roll = dt;
		}
		if(Role < ROLE_Authority) {// && Instigator.Controller.Pawn.IsA('VGVehicle') ) {
			ServerSetRotation(NewRotation);
			ServerSetAim(AimRotation);
		}
	}
	else if(Role < ROLE_Authority) {
		// make sure the base remains unrotated
		NewRotation.Roll = 0;
		NewRotation.Pitch = 0;
		NewRotation.Yaw = WeaponBoneRotation.Yaw;
		SetRelativeRotation(NewRotation);

		// set the bone rotation using the value set on the server side
		WeaponBoneRotation.Roll = 0;
		WeaponBoneRotation.Yaw = 0;
		SetBoneRotation('Weapon', WeaponBoneRotation);
		WeaponBoneRotation.Yaw = NewRotation.Yaw;
	}
}

function ServerSetRotation(rotator rot)
{
	local Rotator tempRotation;

	tempRotation.roll = 0;
	tempRotation.pitch = 0;
	tempRotation.yaw = -rot.yaw;
	SetRelativeRotation(tempRotation);

	rot.roll = 0;
	rot.yaw = 0;
	SetBoneRotation('Weapon', rot);
}

function ServerSetAim(rotator aim)
{
	AimRotation = aim;
}

defaultproperties
{
     PitchMax=2500.000000
     PitchMin=-2500.000000
     MuzzleOffset=(X=117.291000,Z=19.489000)
     bHeavy=True
     Mesh=SkeletalMesh'PariahVehicleWeaponAnimations.DozerGun'
     DrawType=DT_Mesh
}
