class DozerLauncherAttachment extends VehicleWeaponAttachment;

#exec OBJ LOAD FILE=..\Animations\PariahVehicleWeaponAnimations.ukx

var bool bAnimStart;
var bool bIdling;
var int PitchOffset;

replication
{
	reliable if(Role == ROLE_Authority)
		bIdling;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(Instigator != none && Role == Role_Authority)
	{
		AimRotation = Instigator.Rotation;
		AimRotation.Yaw += 32768;
		SetRotation(AimRotation);
	}
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if(Instigator != none && Role == Role_Authority)
	{
		AimRotation = Instigator.Rotation;
		AimRotation.Yaw += 32768;
		SetRotation(AimRotation);
	}
}

simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();

	if(FlashCount > 0)
		// play the freaking fire animation
		PlayAnim('Fire');
}

simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

	if(anim == 'Fire') {
		PlayAnim('Reload');
	}

	if(anim == 'Reload') {
//		if(Owner != none && Owner.Owner != none && Owner.Owner.IsA('VGVehicle') && VGVehicle(Owner.Owner).Controller != none)
			LoopAnim('Idle');
	}
}

simulated function Tick(float dt)
{
	local rotator	NewRotation;
	local float		YawDiff, PitchDiff;
	local float		MaxYawDiff, MaxPitchDiff;

	if(Role == ROLE_Authority) {
		if(Instigator == none || Instigator.Controller == none || Instigator.Controller.Pawn != Instigator) {
			StopAnimating();
			bAnimStart = true;
			bIdling = false;
		}
		else if(bAnimStart) {
			LoopAnim('Idle');
			bAnimStart = false;
			bIdling = true;
		}
	}
	else {
		if(bIdling && !IsAnimating() ) {
			LoopAnim('Idle');
		}
		else if(!bIdling) {
			StopAnimating();
		}
	}

	if(Owner != none && Owner.Owner != none && Instigator != none && ( (Instigator.Controller == none && ROLE == Role_Authority) ||
		(Instigator.Controller != none && Instigator.Controller.Pawn != Instigator) ) ) {

		NewRotation.Yaw = Owner.Owner.Rotation.Yaw+32768;
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
		NewRotation.Yaw = AimRotation.Yaw;//-Base.Rotation.Yaw;
		NewRotation.Pitch = -NewRotation.Pitch;
//		SetRelativeRotation(NewRotation);
		SetBoneDirection('Weapon', NewRotation, vect(0, 0, 0), 1.0, 1);

		if(Role == ROLE_Authority) {
			// this allows us to replicate the weapon rotation to the client, yay!
			WBRYaw = NewRotation.Yaw;
			WBRPitch = NewRotation.Pitch;
		}

		if(Role < ROLE_Authority && bIsTracking && bNetOwner) {
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
			NewRotation.Pitch += PitchOffset;
			NewRotation.Roll = 0;//Instigator.Rotation.Roll;
			TargetTime += dt;
		}
		else
		{
			NewRotation = Instigator.Controller.Rotation;
			NewRotation.Pitch += PitchOffset;
			NewRotation.Roll = 0;//Instigator.Rotation.Roll;
		}

		NewRotation.Yaw += 32768;

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
		NewRotation.Roll = 0;
		NewRotation.Yaw = AimRotation.Yaw;//-Base.Rotation.Yaw;
		NewRotation.Pitch = -NewRotation.Pitch;
		SetBoneDirection('Weapon', NewRotation, vect(0, 0, 0), 1.0, 1);
//		SetRelativeRotation(NewRotation);
		if(Role == ROLE_Authority) {
			// this allows us to replicate the weapon rotation to the client, yay!
			WBRYaw = NewRotation.Yaw;
			WBRPitch = NewRotation.Pitch;
		}

		if(Role < ROLE_Authority) 
		{
			QueueRotationAim(NewRotation, AimRotation);
		}
	}
	else if(Role < ROLE_Authority) {
		NewRotation.Pitch = WBRPitch;
		NewRotation.Yaw = WBRYaw;
		NewRotation.Roll = 0;
		SetBoneDirection('Weapon', NewRotation, vect(0, 0, 0), 1.0, 1);
//		SetRelativeRotation(NewRotation);
	}
}

function ServerSetRotationAndAim(rotator rot, rotator aim)
{
	rot.roll = 0;
	SetBoneDirection('Weapon', rot, vect(0, 0, 0), 1.0, 1);
	AimRotation = aim;
}

defaultproperties
{
     PitchOffset=4250
     MaxRotationRate=24384.000000
     PitchMax=4250.000000
     PitchMin=-500.000000
     MuzzleOffset=(X=100.000000,Z=20.000000)
     bHeavy=True
     bFlashForPrimary=True
     bFlashLight=True
     bHasWeaponBone=True
     Mesh=SkeletalMesh'PariahVehicleWeaponAnimations.DozerLauncher'
     DrawType=DT_Mesh
}
