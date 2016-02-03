class VehicleWeaponAttachment extends VGWeaponAttachment;

var		bool	bIsDefaultWeapon;
var		bool	bHadTarget;
var		rotator	AimRotation;
var	()	float	MaxRotationRate;
var		float	TargetTime;
var	()	float	MaxTargetTime;
var		bool	bIsTracking;
var		float	TimerFreq;
var     Rotator WeaponBoneRotation;

var float YawMax, YawMin;		// max and min rotation ranges for driver vehicle weapons
var float PitchMax, PitchMin;	// max and min pitch for driver vehicle weapons
var int WBRYaw, WBRPitch;
var bool RPCServer;
var Rotator RPCServerRotation;
var Rotator RPCServerAim;

replication
{
	// make sure vehicle weapon rotation gets sent to the server, ya?
	unreliable if(Role < ROLE_Authority)// && bIsTracking)
		ServerSetRotationAndAim;
	unreliable if(Role == ROLE_Authority)
		bIsTracking;
	unreliable if(Role == ROLE_Authority)
		WBRYaw, WBRPitch;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(Instigator != none && Role == Role_Authority)
	{
		AimRotation = Instigator.Rotation;
		SetRotation(AimRotation);
	}

    SetTimer(0.25, true);
}

simulated function QueueRotationAim(Rotator NewRotation, Rotator AimRotation)
{
    if(RPCServerRotation != NewRotation && RPCServerAim != AimRotation)
    {
        RPCServerRotation = NewRotation;
        RPCServerAim = AimRotation;
        RPCServer = true;
    }
}

simulated function Timer()
{
    if(RPCServer)
    {
        if(Role < ROLE_Authority && bNetOwner) 
		{
            ServerSetRotationAndAim(RPCServerRotation, RPCServerAim);
        }
        RPCServer = false;
    }
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	AddLightTag( 'VEHICLE' );
	if ( Level.bVehiclesExclusivelyLit )
	{
		bMatchLightTags=True;
	}

	if(Role < ROLE_Authority)
		return;

	if(Instigator != none && Role == Role_Authority)
	{
		AimRotation = Instigator.Rotation;
		SetRotation(AimRotation);
	}

	if(Owner != none && Owner.IsA('VGVehicle') && Role == Role_Authority)
	{
		if(bIsDefaultWeapon && VGVehicle(Owner).DefaultWeapon != none)
		{
			VGVehicle(Owner).DefaultWeapon.BringUp();
		}
		else if(VGVehicle(Owner).Weapon != none)
		{
			VGVehicle(Owner).Weapon.BringUp();
		}
	}
}

function SetTracking(bool bTracking)
{
	bIsTracking = bTracking;
}

//hack so the weapon controls the animation instead of the attachment
simulated function AnimEnd(int channel)
{
	if(Owner != none && Owner.IsA('VGVehicle') ) {
		if(bIsDefaultWeapon) {
			VGVehicle(Owner).DefaultWeapon.AnimEnd(channel);
		}
		else {
			VGVehicle(Owner).Weapon.AnimEnd(channel);
		}
	}
}

simulated function Tick(float dt)
{
	local rotator	NewRotation;
	local float		YawDiff, PitchDiff;
	local float		MaxYawDiff, MaxPitchDiff;

//	log("Owner.Owner = "$Owner.Owner$", Inst = "$Instigator$", Ctrl = "$Instigator.Controller);
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
		NewRotation.Yaw = AimRotation.Yaw-Base.Rotation.Yaw;
		SetRelativeRotation(NewRotation);

		if(Role == ROLE_Authority) {
			// this allows us to replicate the weapon rotation to the client, yay!
			WBRYaw = NewRotation.Yaw;
			WBRPitch = NewRotation.Pitch;
		}

		if(Role < ROLE_Authority) {//Instigator.Controller.Pawn.IsA('VGVehicle') ) {// && Owner != None) {
		    QueueRotationAim(NewRotation, AimRotation);
		}
	}
	else if(Instigator != none && Instigator.Controller != none 
		&& Instigator.Controller.IsA('VehiclePlayer') 
		&& Instigator.IsLocallyControlled())
	{
//		if(Instigator != Instigator.Controller.Pawn)
//			return;

//		Location + (vector(PawnOwner.Weapon.ThirdPersonActor.Rotation) * 2000);
//		if(VehiclePlayer(Instigator.Controller).Target != none)
//		{
//			NewRotation = rotator(VehiclePlayer(Instigator.Controller).Target.Location - Location);
//			NewRotation.Pitch = Instigator.Rotation.Pitch;
//			NewRotation.Roll = Instigator.Rotation.Roll;
//			NewRotation.Pitch = 0;//Instigator.Rotation.Pitch;	//don't pitch
//			NewRotation.Roll = 0;//Instigator.Rotation.Roll;	//don't Roll
//			TargetTime = 0.0;
//		}
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
		NewRotation.Roll = 0;
		NewRotation.Yaw = AimRotation.Yaw-Base.Rotation.Yaw;
//		bForceBaseRep = true;
		SetRelativeRotation(NewRotation);
//		log("Instigator = "$Instigator$", I.Controller = "$Instigator.Controller);
//		log("   I.Controller.Pawn = "$Instigator.Controller.Pawn);
		if(Role == ROLE_Authority) {
			// this allows us to replicate the weapon rotation to the client, yay!
			WBRYaw = NewRotation.Yaw;
			WBRPitch = NewRotation.Pitch;
		}

		if(Role < ROLE_Authority) {// && bIsTracking && bNetOwner) {//Instigator.Controller.Pawn.IsA('VGVehicle') ) {// && Owner != None) {
		    QueueRotationAim(NewRotation, AimRotation);
		}
	}
	else if(Role < ROLE_Authority) {
		NewRotation.Pitch = WBRPitch;
		NewRotation.Yaw = WBRYaw;
		NewRotation.Roll = 0;
		SetRelativeRotation(NewRotation);
	}
}

function ServerSetRotationAndAim(rotator rot, rotator aim)
{
	rot.roll = 0;
	SetRelativeRotation(rot);
	AimRotation = aim;
}

function rotator ServerGetRotation()
{
	return Rotation;
}

simulated function ClientSetRotation(rotator rot)
{
//	log("CSR: AimRot = "$rot$", Role = "$Role$", RemoteRole = "$RemoteRole);
	AimRotation = rot;
	SetRotation(rot);
}

simulated function Rotator GetAttachmentRotation()
{
	return AimRotation;
}

defaultproperties
{
     MaxRotationRate=32768.000000
     MaxTargetTime=0.500000
     TimerFreq=0.250000
     bFastAttachmentReplication=False
     AttachmentBone="None"
     bOnlyDrawIfAttached=False
     bHardAttach=True
     bForceBaseRep=True
}
