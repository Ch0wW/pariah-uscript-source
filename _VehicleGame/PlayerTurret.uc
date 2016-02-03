class PlayerTurret extends Pawn
	placeable;

var() float MaxEnterDistance;
var   VGPawn PawnGunner;
var   Weapon SavedWeapon;	// save the gunner's weapon
var   Vector PassengerPoint;
var   Vector ExitPoint;

var   Name UpAnim;
var   Name DownAnim;
var() Name RiderAnimName;
var   Name SwivelBone;

// rotation ranges for the turret
var float YawMax, YawMin;	
var float PitchMax, PitchMin;

var () int ViewMaxPitch;
var () int ViewMinPitch;

var rotator AimRotation;
var float MaxRotationRate;

var string WeaponClass;

var float clientYaw, clientPitch;

var Controller DelayedKiller;
var class<DamageType> DelayedDamageType;
var bool bDelayingDeath;	// for networking
var Pawn SavedKiller;

var Emitter					DeathEmitter;
var(VGVehicle) vector		DeathEmitterOffset;
var (VGSounds) byte		MasterVehicleSoundVolume;
var (VGSounds) sound	DeathSound;
var (VGSounds) byte		DeathSoundVolume;
var (VGSounds) sound	StartUpSound;
var (VGSounds) byte		StartUpSoundVolume;
var (VGSounds) sound	PowerDownSound;
var (VGSounds) byte		PowerDownSoundVolume;
var (VGSounds) sound	MovingSound;
var (VGSounds) sound    SpinningSound;

var (TurretCam) vector TurretCameraOffset;

var float fEMPTime;
var float fEMPTimer;
var bool bDisabled;

var MuzzleFlash FlashEffect1;
var MuzzleFlash FlashEffect2;

var bool bFlash; // replicated for toggling muzzle flash

var() sound FiringSound;

replication
{
	reliable if(Role == ROLE_Authority)
		bDelayingDeath, bDisabled, PawnGunner, bFlash;
	unreliable if(Role == ROLE_Authority)
		clientYaw, clientPitch;
}

simulated function PostNetBeginPlay()
{
    Super.PostNetBeginPlay();

	if(Role == ROLE_Authority)
    {
		GiveWeapon(WeaponClass);
    	CheckCurrentWeapon();
        VGWeapon(Weapon).SetTurret(self);
	}

    if(Level.NetMode != NM_DedicatedServer)
    {
        SpawnMuzFlash();
	    SetBoneDirection(SwivelBone, Rotation, vect(0,0,0), 1.0, 1);
	    AimRotation = Rotation;
	    PlayAnim(DownAnim, 0.7, 0.1);
    }
}

simulated function SpawnMuzFlash()
{
	FlashEffect1 = Spawn(class'VehicleEffects.turret_flashManned', self);
	if(FlashEffect1 != none)
    {
	    AttachToBone(FlashEffect1, 'FX1');
	    FlashEffect1.SetDrawScale(5.0);
	}

	FlashEffect2 = Spawn(class'VehicleEffects.turret_flashManned', self);
	if(FlashEffect2 != none)
    {
	    AttachToBone(FlashEffect2, 'FX2');
	    FlashEffect2.SetDrawScale(5.0);
	}
}

simulated function bool CanEnter(Pawn somePawn)
{
	return (VSize(somePawn.Location-Location) <= MaxEnterDistance && !bDisabled);
}

function TryToEnter(Pawn somePawn)
{
	local int n;

	PawnGunner = VGPawn(somePawn);
	PawnGunner.RiddenTurret = self;

	PawnGunner.EndDash();

	PawnGunner.SetHavokCharacterCollisions(false);	// turn off any havok-character collisions while in turret
	PawnGunner.SetCollision(false, false, false);
	PawnGunner.RiderAnim = RiderAnimName;
//	PawnGunner.Controller.bIsRidingVehicle = True;
//	PawnGunner.Controller.bUseRiderCamera = true;
	if(PawnGunner.Controller.IsA('VehiclePlayer') )
	{
		VehiclePlayer(PawnGunner.Controller).SetViewTarget(self);
		VehiclePlayer(PawnGunner.Controller).SetRiderCamStuff(self, true);
		VehiclePlayer(PawnGunner.Controller).PitchUpLimit = ViewMaxPitch;
		VehiclePlayer(PawnGunner.Controller).PitchDownLimit = ViewMinPitch;//54660;//PitchMin+65536;
//		VehiclePlayer(PawnGunner.Controller).myHUD.bVehicleCrosshairShow = true;

		VehiclePlayer(PawnGunner.Controller).ClientEndZoom();    //Ensure Zoom is off.
	}
	
//	PawnGunner.SetLocation(Location);
	PawnGunner.SetPhysics(PHYS_RidingBase);
	PawnGunner.bDontRotateWithBase=True;

	GetBoneCoords('Gunner');
//	log("GUNNER pos = "$attachPt.Origin);

	PawnGunner.SetBase(self);
	AttachToBone(PawnGunner, 'Gunner');//'RootDummy');
	PawnGunner.SetRelativeLocation(PassengerPoint>>Rotation);

	// save the gunner's weapon
	SavedWeapon = PawnGunner.Weapon;
	PawnGunner.SavedWeapon = PawnGunner.Weapon;
	if(PawnGunner.Weapon.ThirdPersonActor != none) {
		PawnGunner.Weapon.HolderDied();
		PawnGunner.Weapon.DetachFromPawn(PawnGunner);
	}

	if(Role == ROLE_Authority && Weapon == none)
    {
		GiveWeapon(WeaponClass);
    	CheckCurrentWeapon();
        VGWeapon(Weapon).SetTurret(self);
	}

	if(Weapon != none)
    {
        VGWeapon(Weapon).SetTurret(self);

		Weapon.Instigator = PawnGunner;
//		Weapon.ThirdPersonActor.Instigator = PawnGunner;
		Weapon.SetOwner(PawnGunner);

		PawnGunner.Weapon = Weapon;

		// make sure the rider weapon has ammo
		for(n = 0; n < Weapon.NUM_FIRE_MODES; n++) 
		{
			if(Weapon.FireMode[n] != none) 
			{
				Weapon.FireMode[n].Instigator = PawnGunner;
				Weapon.GiveAmmo(n);
			}
		}

		Weapon.ClientState = WS_ReadyToFire;
		Weapon.GotoState('');
		PawnGunner.ClientVehicleWeaponStuff(Weapon);
	}

//	if(RiderEnterEvent != '' && Level.Game != None && Level.Game.bSingleplayer)
//	{
//		log("firing off event "$RiderEnterEvent);
//		TriggerEvent(RiderEnterEvent, self, aPawn);
//	}

	PlayVehicleSoundEffect(StartUpSound, StartUpSoundVolume, 64);
    SetAnimAction(UpAnim);
}

simulated function ClientSetRide(VGPawn aPawn)
{
	local int n;

	if(aPawn.Controller.IsA('VehiclePlayer') )
	{
		VehiclePlayer(aPawn.Controller).PitchUpLimit = ViewMaxPitch;
		VehiclePlayer(aPawn.Controller).PitchDownLimit = ViewMinPitch;
		VehiclePlayer(aPawn.Controller).ClientEndZoom();
	}

	if(Weapon != none)
    {
		// this vehicle has a rider controlled weapon so place it under the control of the rider
		Weapon.Instigator = aPawn;
		if(aPawn.Weapon != Weapon)
			SavedWeapon = aPawn.Weapon;
		aPawn.Weapon = Weapon;

		// make sure the rider weapon has ammo
		for(n = 0; n < Weapon.NUM_FIRE_MODES; n++) {
			if(Weapon.FireMode[n] != none) {
				Weapon.FireMode[n].Instigator = aPawn;
				Weapon.GiveAmmo(n);
			}
		}

		Weapon.ClientState = WS_ReadyToFire;
		Weapon.GotoState('');
		Weapon.SetOwner(aPawn);
	}
}

function bool CheckExtentsTo(Pawn test, Vector startchk, Vector endchk)
{
	local vector hitloc, hitnorm, extent;
	local actor a;


	extent.X = test.default.CollisionRadius;
	extent.Y = test.default.CollisionRadius;
	extent.Z = test.default.CollisionHeight;

	startchk = test.Location;

	a = Trace(hitloc, hitnorm, endchk, startchk, true, extent);

	if(a != None) //oh snap, hit something in between driver and outpos.
	{
		log("hit "$a);
		return false;
	}


	return true;
}

function EndRide( VGPawn p )
{
	local int i;
	local vector v;
	local Rotator fudge;
	local bool bSpotFound;


	if(PawnGunner != none)
		PawnGunner.SetCollision(True, True, True);

	if(p == none)
		return;

//	log("*** End Ride for "$p);
	if(p.Controller.IsA('VehiclePlayer') )
    {
//		VehiclePlayer(p.Controller).Toggle3rd();
		VehiclePlayer(p.Controller).bUse3rdPersonCam = false;
		VehiclePlayer(p.Controller).bBehindView = false;
		VehiclePlayer(PawnGunner.Controller).myHUD.bVehicleCrosshairShow = false;
		VehiclePlayer(PawnGunner.Controller).PitchUpLimit = VehiclePlayer(PawnGunner.Controller).Default.PitchUpLimit;
		VehiclePlayer(PawnGunner.Controller).PitchDownLimit = VehiclePlayer(PawnGunner.Controller).Default.PitchDownLimit;
	}

	//set an exit position relative to the center of vehicle
	v = (PassengerPoint >> Rotation);
	v.z = 0;

//	p.SetLocation(Location + (PassengerPoint >> Rotation) + Normal(v)*250.0);


	//cmr - determine exit spot.

	for(i=0;i<4;i++)
	{

		if(CheckExtentsTo(p, Location, Location + (ExitPoint >> (Rotation + fudge)) ) )
		{
			p.SetLocation(Location + (ExitPoint >> (Rotation + fudge)) );
			bSpotFound = true;
			break;
		}
	
	
		fudge.yaw += 16384;
	}

	if(!bSpotFound) //player couldn't get out normal, spawn on top
	{
		p.SetLocation(Location + Vect(0,0,300));
	}

	p.bDontRotateWithBase=False;

	// restore any havok-character collision
	p.SetHavokCharacterCollisions(p.UseHavokCharacterCollision() );

	//reset camera
	if(p.Controller.IsA('VehiclePlayer') ) {
		VehiclePlayer(p.Controller).SetRiderCamStuff(p, false);
	}
    StopFiringSound();
	p.RiddenTurret = none;
	PawnGunner = none;

	if(Weapon != none) {
		Weapon.Instigator = self;
		Weapon.SetOwner(self);
		Weapon.HolderDied();
	}

	if(SavedWeapon != none) {
		p.Weapon = SavedWeapon;
		p.ClientEndRideVehicle(SavedWeapon);
		SavedWeapon.SetOwner(p);
		p.Weapon.AttachToPawn(p);
		p.Controller.Restart();
		p.PotentialTurret = none;
	}

	SavedWeapon = none;

	PlayVehicleSoundEffect(PowerDownSound, PowerDownSoundVolume, 64);
    SetAnimAction(DownAnim);        
    return;
}

simulated function ClientEndRide(VGPawn p)
{
	if(Weapon != none) {
		Weapon.Instigator = self;
	}

	if(SavedWeapon != none)
		Pawn(SavedWeapon.Owner).Weapon = SavedWeapon;

	if(p.Controller.IsA('VehiclePlayer') && VGPawn(SavedWeapon.Owner) == p) {
		VehiclePlayer(p.Controller).bUse3rdPersonCam = false;
		VehiclePlayer(p.Controller).bBehindView = false;
	}

	SavedWeapon = none;
}

// tick function handles movement of turret, similar to how things happen for vehicle weapons (in the weapon attachment classes)
simulated function Tick(float dt)
{
	local rotator NewRotation, GunnerRot;
	local float	YawDiff, PitchDiff;
	local float	MaxYawDiff, MaxPitchDiff;

	local vector Start, HitLocation, HitNormal;
	local Actor Other;
	local VehiclePlayer vp;

    local float Dist;
    local vector View;
    
    if(Role == ROLE_Authority)
    {
        AmbientSound = None;
    }

//	Super.Tick(dt);

	if(bDisabled) {
		fEMPTimer += dt;
		if(fEMPTimer > fEMPTime) {
			fEMPTimer = 0;
			bDisabled = false;
			log("PT:  EMP ends");
		}
	}

    // controlled by a remote player - use the replicated rotation
	if(Role < ROLE_Authority && (PawnGunner == None || !PawnGunner.IsLocallyControlled()))
    {
		NewRotation.Roll = 0;
		NewRotation.Pitch = clientPitch;
		NewRotation.Yaw = clientYaw;
		SetBoneDirection(SwivelBone, NewRotation, vect(0,0,0), 1.0, 1);
		return;
	}

    if(PawnGunner == none || PawnGunner.Controller == None || PawnGunner.Health <= 0)
		return;

	// if the turret has a controller then use the controller's rotation to aim the turret
	if(PawnGunner.Controller.IsA('VehiclePlayer') )
    {
		vp = VehiclePlayer(PawnGunner.Controller);

        // jjs - the server doesn't know the player's viewpoint so approximate it
        NewRotation = vp.Rotation;
        Dist = vp.CameraDist * PawnGunner.Default.CollisionRadius;
        View = vect(1,0,0) >> NewRotation;
        Start = Location + TurretCameraOffset - (Dist * View);

		Other = Trace(HitLocation, HitNormal, Start+20000*vector(NewRotation), Start+1000*vector(NewRotation), true);
		if(Other != none)
        {
			NewRotation = Rotator(HitLocation-(Location+vect(0,0,100)));
        }
	}
	else
		NewRotation = PawnGunner.Controller.Rotation;

    NewRotation = PawnGunner.Controller.Rotation; // aw fuck it

	NewRotation.Roll = 0;

	if(PawnGunner != none)
    {
		GunnerRot.Yaw = 16000;
		PawnGunner.SetRelativeRotation(GunnerRot);
	}

	// calculate the change in yaw and pitch for this tick
	YawDiff = (NewRotation.Yaw & 65535)-(AimRotation.Yaw & 65535);

	if (YawDiff < -32768) yawDiff += 65536;
	else if (YawDiff > 32768) YawDiff -= 65536;

	MaxYawDiff = dt*MaxRotationRate;		//Maximum number of units to rotate this update
	if(Abs(YawDiff) > MaxYawDiff)
	{
		if(YawDiff > 0)
			YawDiff = MaxYawDiff;
		else
			YawDiff = -MaxYawDiff;
	}

	// now same thing for pitch
	PitchDiff = (NewRotation.Pitch & 65535)-(AimRotation.Pitch & 65535);

	if (PitchDiff < -32768) PitchDiff += 65536;
	else if (PitchDiff > 32768) PitchDiff -= 65536;

	MaxPitchDiff = dt*MaxRotationRate;		//Maximum number of units to rotate this update
	if(Abs(PitchDiff) > MaxPitchDiff)
	{
		if(PitchDiff > 0)
			PitchDiff = MaxPitchDiff;
		else
			PitchDiff = -MaxPitchDiff;
	}

	AimRotation.Roll = 0;
	AimRotation.Yaw += YawDiff;
	AimRotation.Pitch += PitchDiff;

//		log("Ctrl = "$Controller$", AimRot = "$AimRotation$", YawDiff = "$YawDiff$", PitchDiff = "$PitchDiff);
	clientYaw = AimRotation.Yaw;
	clientPitch = AimRotation.Pitch;

	NewRotation.Roll = 0;
	NewRotation.Pitch = clientPitch;
	NewRotation.Yaw = 0;
	SetBoneDirection(SwivelBone, AimRotation, vect(0,0,0), 1.0, 1);
	if(Abs(YawDiff) > 15 || Abs(PitchDiff) > 15 && Role == ROLE_Authority)
		AmbientSound = MovingSound;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
//	log("PlayerTurret::Died() called - Killer = "$Killer );

	if(Killer != None)
		SavedKiller = Killer.Pawn;
	else
		SavedKiller = None;
	Super.Died(Killer, damageType, HitLocation);
}

function DelayDied(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
//	log("PlayerTurret::DelayDied() called - Killer = "$Killer );

	DelayedKiller = Killer;
	DelayedDamageType = damageType;

	GotoState('DelayingDeath');
}

state DelayingDeath
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, byte FiringMode) {}
	function PlayWeaponSwitch(Weapon NewWeapon) {}
	function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
	simulated function PlayNextAnimation() {}
	function Landed(vector HitNormal)
	{
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
	}

	simulated function BeginState()
	{
//		log(GetStateName()$"::BeginState() called" );
		bDelayingDeath = True;
		SetTimer(3.0, false);
		if ( Level.NetMode != NM_DedicatedServer )
		{
			DeathEmitter=Spawn(class'VehicleEffects.VehicleDeathFire',self);
			DeathEmitter.SetBase(self);
			DeathEmitter.SetRelativeLocation(DeathEmitterOffset);
		}
	}

	simulated function Timer()
	{
		if ( Role == ROLE_Authority )
		{
			Died(DelayedKiller, DelayedDamageType, Vect(0,0,0));
			DelayedKiller = None;
			DelayedDamageType = None;
		}
	}
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
//	log("PlayerTurret:PlayDying("$DamageType$") enter bTearOff="$bTearOff );

	EndRide(PawnGunner);

	fEMPTimer = 0;
	bPlayedDeath = True;
	bTearOff = True;
	bCanTeleport = False;
	bReplicateMovement = False;
	GotoState('TurretDying');

    StopFiringSound();

	if(Level.NetMode == NM_Client)
		return;
}

state TurretDying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, byte FiringMode) {}
	function PlayWeaponSwitch(Weapon NewWeapon) {}
	function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
	simulated function PlayNextAnimation() {}

	function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
	{
	}

	function Landed(vector HitNormal)
	{
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
	}

	simulated function KillDriver()
	{
		//log("XXXX - KillDriver() Called for "$self$" with driver "$Driver);

		if ( PawnGunner != None )
		{

			//this is fucked, it only happens on the client, need to fix this shit sometime.
			PawnGunner.SetPhysics(PHYS_Falling);
			PawnGunner.bPhysicsAnimUpdate = PawnGunner.Default.bPhysicsAnimUpdate;
			PawnGunner.bCollideWorld = True;
			PawnGunner.SetCollision(True, True, True);

			PawnGunner.TakeDamage(1200, SavedKiller, PawnGunner.Location, ((Velocity*0.8) + Vect(0,0,1000))*PawnGunner.mass/*vect(0,0,0)*/, class'DriverDamage');
			SavedKiller = None;
		}
	}

	simulated function FinalDeath()
	{
//		local int i;
//		local VGPawn passenger;

//		log(GetStateName()$"::FinalDeath() called" );

		//caution!! bTearOff has been set Authority is now the client!!!!!
		EndRide(PawnGunner);
		if ( Level.NetMode != NM_DedicatedServer && PlayerCanSeeMe() )
		{
			DoTurretDeathEffects();
		}

		LifeSpan = 0.5;
	}

	simulated function Timer()
	{
//		log("timer calling finaldeath");
		FinalDeath();
	}

	simulated function BeginState()
	{ 
		local Emitter	ExplRay;
//		log(GetStateName()$"::BeginState() called bTearOff="$bTearOff );

  //      if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
		//{
		//	LifeSpan = 1.0;
		//	glog( RJ2, GetStateName()$"::BeginState() setting LifeSpan to "$LifeSpan );
		//}
		//else 
		//{
			
			if ( Level.NetMode != NM_DedicatedServer && PlayerCanSeeMe() )
			{
				ExplRay = spawn(class'VehicleEffects.DavidVehicleExplosionRays',,,Location);
				ExplRay.SetBase(self);
			}

			if(Level.NetMode != NM_Client)
			{
				KillDriver();
			}
//			EndRideAll();
			SetTimer(0.5,false);
			//FinalDeath();
//		}
	}	
}

function DoTurretDeathEffects()
{
	// set EMP hit count back to zero and make sure it's reenabled
	SetTimer(0, false);

	PlayVehicleSoundEffect( DeathSound, DeathSoundVolume, 64 );

	spawn(class'VehicleEffects.FlameRingProjector',,,Location, Rotation + rot(-16384,0,0));
	spawn(class'VehicleEffects.VehicleExplosionMark',,,Location, Rotation + rot(-16384,0,0));
	

	spawn(class'VehicleEffects.DavidVehicleExplosionSmoke',,,Location + vect(0,0,-25),Rotation + rot(16384,0,0));
	//spawn(class'VehicleEffects.DavidVehicleExplosionDirt',,,Location);
	spawn(class'VehicleEffects.DavidExplosionBall',,,Location);
	spawn(class'VehicleEffects.DavidVehicleExplosionEmbers',,,Location);
	spawn(class'VehicleEffects.DavidVehicleExplosionShrapnel',,,Location);
//	spawn(class'VehicleEffects.DavidVehicleExplosionTires',,,Location);
}

event GotoDelayingDeath()
{
	GotoState('DelayingDeath');
}

simulated event PlayVehicleSoundEffect(sound TheSound, byte Volume, byte Pitch)
{
	local float	 v, p;

	v = Volume * MasterVehicleSoundVolume / 65025.0;	// 65025=255*255
	p = Pitch / 64.0;
	PlaySound( TheSound, , v, , , p );
}

simulated event Destroyed()
{
	if(DeathEmitter != None)
	{
		DeathEmitter.Destroy();
		DeathEmitter = None;
	}

	if(FlashEffect1 != none)
    {
		FlashEffect1.Destroy();
        FlashEffect1 = None;
	}

	if(FlashEffect2 != none)
    {
		FlashEffect2.Destroy();
        FlashEffect2 = None;
	}

	Super.Destroyed();
}

simulated function EMPHit(bool bEnhanced)
{
	if(!bPlayedDeath) {
		EndRide(PawnGunner);

		if(!bEnhanced)
			fEMPTime = 2;	// disable for 2 seconds
		else
			fEMPTime = 5;

		fEMPTimer = 0;
		bDisabled = true;
//		log("PT:  EMPHit; EMPTime = "$fEMPTime$"; Role = "$Role$", RemoteRole = "$RemoteRole);
	}
}


event bool EncroachingOn(Actor Other) //if this turret is moving and has a base, assume that it should never refuse to move.
{
	if(Base!=None && Base.IsA('Mover'))
		return false;
	else
		return Super.EncroachingOn(Other);
}

simulated function PlayFiringSound()
{
/*
    if (PawnGunner != None)
    {
        PawnGunner.PlayOwnedSound( FiringSound, SLOT_Misc, TransientSoundVolume, , 3000 );
        PawnGunner.PlayOwnedSound( SpinningSound, SLOT_None, TransientSoundVolume / 2.0f, , 3000 ); // bleh, hard coded yuck!
    }
    else
    {
        PlayOwnedSound( FiringSound, SLOT_Misc, TransientSoundVolume, , 3000 );
        PlayOwnedSound( SpinningSound, SLOT_None, TransientSoundVolume / 2.0f, , 3000 );
    }    
*/
}

simulated function StopFiringSound()
{
    if(Weapon != None)
    {
        Weapon.FireMode[0].StopFiring();
    }
}

function StartFlash()
{
    bFlash = true;
    UpdateFlash();
}

function StopFlash()
{
    bFlash = false;
    UpdateFlash();
}

simulated event PostNetReceive()
{
    UpdateFlash();

    if(PawnGunner == None)
    {
        StopFiringSound();
    }
}

simulated function UpdateFlash()
{
    if(Level.NetMode == NM_DedicatedServer)
        return;

    // turn on/off muzzle flash
    if(bFlash)
    {
		if(FlashEffect1 != none)
			turret_flashManned(FlashEffect1).StartFlash();
		if(FlashEffect2 != none)
			turret_flashManned(FlashEffect2).StartFlash();
    }
    else
    {
		if(FlashEffect1 != none)
			turret_flashManned(FlashEffect1).StopFlash();
		if(FlashEffect2 != none)
			turret_flashManned(FlashEffect2).StopFlash();
    }
}

simulated event SetAnimAction(name NewAction)
{
	AnimAction = NewAction;
    if(Level.NetMode != NM_DedicatedServer)
    {
        if(AnimAction == 'Fire')
        {
	        LoopAnim(AnimAction);
        }
        else if(AnimAction != 'None')
        {
	        PlayAnim(AnimAction, 0.7, 0.1);
        }
    }
}

defaultproperties
{
     ViewMaxPitch=10000
     ViewMinPitch=54660
     MaxEnterDistance=450.000000
     PitchMax=10000.000000
     PitchMin=-8500.000000
     MaxRotationRate=16384.000000
     DeathSound=Sound'PariahVehicleSounds.Vehicle_and_Bomb_Explosions.95-car_explosion'
     MovingSound=Sound'PlayerTurretSounds.Turning.TurningSoundA'
     SpinningSound=Sound'PlayerTurretSounds.Spinning.TrainTurretSpin'
     FiringSound=Sound'SM-chapter03sounds.TurretOneSecondLoopB'
     UpAnim="SitUp"
     DownAnim="SitDown"
     RiderAnimName="Turret_Sit"
     SwivelBone="UpperMainDummy"
     PassengerPoint=(Z=90.000000)
     ExitPoint=(Y=-200.000000,Z=90.000000)
     TurretCameraOffset=(Z=450.000000)
     WeaponClass="VehicleWeapons.PlayerTurretDummyWeapon"
     MasterVehicleSoundVolume=255
     DeathSoundVolume=255
     Health=1000
     LandMovementState="PlayerInTurret"
     WaterMovementState="PlayerInTurret"
     bCanBeBaseForPawns=True
     bDelayDied=True
     TransientSoundVolume=1.000000
     Style=STY_Additive
     bDontFailAttachedMove=True
     bUnlit=True
     bMovable=False
     bBlockKarma=True
     bNetNotify=True
     bRotateToDesired=False
}
