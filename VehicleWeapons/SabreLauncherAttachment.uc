class SabreLauncherAttachment extends VehicleWeaponAttachment;//WeaponAttachment;

#exec OBJ LOAD FILE=..\Animations\PariahVehicleWeaponAnimations.ukx

//var Rotator WeaponBoneRotation;

//replication 
//{
//	reliable if(Role == ROLE_Authority)
//		WeaponBoneRotation;
//}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
//	LinkSkelAnim(MeshAnimation'SwarmRL');
//	log("BLA created");
}

simulated function Tick(float dt)
{
	local rotator	NewRotation, tempRotation;
	local float		YawDiff;
	local float		MaxYawDiff;

	if(Instigator != none && Instigator.Controller != none 
		&& Instigator.Controller.IsA('VehiclePlayer') 
		&& Instigator.IsLocallyControlled())
	{
		if(Instigator.IsA('VGVehicle') ) {
			NewRotation.Yaw = Instigator.Rotation.Yaw;
//			NewRotation.Pitch = Instigator.Rotation.Pitch;
//			NewRotation.Roll = Instigator.Rotation.Roll;
			NewRotation.Pitch = 0;
			NewRotation.Roll = 0;
		}
		else if(VehiclePlayer(Instigator.Controller).Target != none)
		{
			NewRotation = rotator(VehiclePlayer(Instigator.Controller).Target.Location - Location);
//			NewRotation.Pitch = Instigator.Rotation.Pitch;
//			NewRotation.Roll = Instigator.Rotation.Roll;
			NewRotation.Pitch = 0;//Instigator.Rotation.Pitch;	//don't pitch
			NewRotation.Roll = 0;//Instigator.Rotation.Roll;	//don't Roll
			TargetTime = 0.0;
		}
		else if(TargetTime < MaxTargetTime)
		{
			NewRotation.Yaw = Instigator.Controller.Rotation.Yaw;
//			NewRotation.Pitch = Instigator.Rotation.Pitch;
//			NewRotation.Roll = Instigator.Rotation.Roll;
			NewRotation.Pitch = 0;//Instigator.Rotation.Pitch;	//don't pitch
			NewRotation.Roll = 0;//Instigator.Rotation.Roll;	//don't Roll
			TargetTime += dt;
		}
		else
		{
			NewRotation.Yaw = Instigator.Controller.Rotation.Yaw;
//			NewRotation.Pitch = Instigator.Rotation.Pitch;
//			NewRotation.Roll = Instigator.Rotation.Roll;
			NewRotation.Pitch = 0;//Instigator.Rotation.Pitch;	//don't pitch
			NewRotation.Roll = 0;//Instigator.Rotation.Roll;	//don't Roll
//			SetRotation(AimRotation);
//			return;
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

		AimRotation.Roll = 0;//NewRotation.Roll;
		AimRotation.Yaw += YawDiff;
		AimRotation.Pitch = 0;//NewRotation.Pitch;
		NewRotation.Roll = 0;
		NewRotation.Pitch = 0;
		NewRotation.Yaw = Base.Rotation.Yaw-AimRotation.Yaw;
//		SetRelativeRotation(NewRotation);
		tempRotation.Roll = 0;
		tempRotation.Pitch = 0;
		tempRotation.Yaw = 0;
		SetRelativeRotation(tempRotation);

		SetBoneRotation('Weapon', NewRotation);

		if(Role == ROLE_Authority) {
			// this allows us to replicate the weapon rotation to the client, yay!
			WeaponBoneRotation = NewRotation;
			WeaponBoneRotation.Roll = 0;
		}
//		log("AimRot = "$AimRotation);
		if(Role < ROLE_Authority) {// && Instigator.Controller.Pawn.IsA('VGVehicle') ) {
			ServerSetRotation(NewRotation);
		}
//		log("Rotation = "$Rotation);
//		log("I = "$Instigator$", I.C = "$Instigator.Controller$", Owner = "$Owner);
	}
	else if(Role < ROLE_Authority) {
		// make sure the base remains unrotated
		NewRotation.Roll = 0;
		NewRotation.Pitch = 0;
		NewRotation.Yaw = 0;
		SetRelativeRotation(NewRotation);

		// set the bone rotation using the value set on the server side
		WeaponBoneRotation.Roll = 0;
		SetBoneRotation('Weapon', WeaponBoneRotation);
	}
/*	else if(Role < ROLE_Authority && Instigator != none) {// && Instigator.IsA('VGPawn') ) {
//		log("Inst = "$Instigator$", Rotation = "$Rotation);
//		log("Ctrl = "$Instigator.Controller$", Local = "$Instigator.IsLocallyControlled() );
//		log("SRot = "$ServerGetRotation() );
		AimRotation.Roll = 0;
		AimRotation.Pitch = 0;
		AimRotation.Yaw = Rotation.Yaw;
		NewRotation.Roll = 0;
		NewRotation.Pitch = 0;
		NewRotation.Yaw = 0;//AimRotation.Yaw;//-Base.Rotation.Yaw;
//		SetRelativeRotation(NewRotation);
		SetBoneRotation('Weapon', NewRotation);
//		ServerSetRotation(AimRotation);
	}*/
}

function ServerSetRotation(rotator rot)
{
	local Rotator tempRotation;

	tempRotation.roll = 0;
	tempRotation.pitch = 0;
	tempRotation.yaw = 0;
	SetRelativeRotation(tempRotation);

	//	log("SSR: rot = "$rot$", Role = "$Role$", RemoteRole = "$RemoteRole);
	rot.roll = 0;
//	rot.pitch = 0;
//	SetRelativeRotation(rot);
	SetBoneRotation('Weapon', rot);
}

defaultproperties
{
     MuzzleOffset=(X=100.000000,Z=20.000000)
     bHeavy=True
     bFlashForPrimary=True
     bFlashLight=True
     Mesh=SkeletalMesh'PariahVehicleWeaponAnimations.SabreLauncher'
     DrawType=DT_Mesh
}
