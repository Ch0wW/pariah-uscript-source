class BogieGunFire extends VGInstantFire;

var	BogieGunAttachmentL		Attachment;
var	BogieGunAttachmentR		Attachment2;
var	xEmitter				OverheatSmoke;
var xEmitter				OverheatSmoke2;

var	()	Sound				FiringSound;
var int lastGunFired;	// which of the two guns fired last (0 or 1)
var int fireSeq;

function PostBeginPlay()
{
	Super.PostBeginPlay();
//	if(Weapon != none && Weapon.IsA('BogieGunR') )
//		fireSeq = 1;
}

function bool AllowFire()
{
    local VehiclePlayer VP;
    
    VP = VehiclePlayer(Instigator.Controller);

    if( (VP != None) && VP.bExitingByAnimation )
        return false;
    return Super.AllowFire();
}

/*simulated function bool AllowFire()
{
	if(fireSeq == 1) {
		fireSeq = 0;
		return false;
	}

	fireSeq = 1;
    return true;
}*/

function DoTrace(Vector Start, Rotator Dir)
{
	if(Level.NetMode != NM_Client)
		Super.DoTrace(Start, Dir);
}

simulated function Destroyed()
{
	Attachment = none;
	Attachment2 = none;

	if(OverheatSmoke != none)
		OverheatSmoke.Destroy();

	if(OverheatSmoke2 != none)
		OverheatSmoke2.Destroy();

	Super.Destroyed();
}

function PutDown()
{
	LastHeatTime = Level.TimeSeconds + HeatTime;
	GotoState('Idle');
}

function BringUp()
{
}

function StopFiring()
{
	if(Attachment != none)
		Attachment.StopAnimating();
	if(Attachment2 != none)
		Attachment2.StopAnimating();
}

function DoFireEffect()
{
	if(fireSeq == 0)
		Super.DoFireEffect();
}

function DrawMuzzleFlash(Canvas Canvas)
{
	if(fireSeq == 0) 
		Super.DrawMuzzleFlash(Canvas);
}

function FlashMuzzleFlash()
{
	if(fireSeq == 0)
		Super.FlashMuzzleFlash();
}

function StartMuzzleSmoke()
{
	if(fireSeq == 0)
		Super.StartMuzzleSmoke();
}

event ModeDoFire()
{
	if(fireSeq == 0 && BogieGun(Weapon).slaveGun != none) {
		Super.ModeDoFire();
		fireSeq = 1;
	}
	else {
		if(BogieGun(Weapon).slaveGun != none)
			BogieGun(Weapon).slaveGun.FireMode[0].ModeDoFire();
		fireSeq = 0;
		NextFireTime = Level.TimeSeconds+FireRate;
	}
}

function PlayFiring()
{
	if(fireSeq == 0)
		Super.PlayFiring();
}

auto state Idle
{
	event ModeDoFire(){}
    function ModeTick(float dt)
    {
		HeatTime-=dt * CoolFactor;
		if(HeatTime < 0.0)
			HeatTime = 0.0;
		HudBarValue = HeatTime/MaxHeatTime;
	}
	function BeginState()
	{
		if(Weapon != none && Weapon.Ammo[0] != none)
			Weapon.Ammo[0].bRegen=true;
		//Attachment.AmbientSound = none;
	}
    function StartFiring()
    {
		if(Instigator == none)
			// the instigator has not been set somehow
			Instigator = Pawn(Weapon.Owner);

		if(Attachment == none && Weapon(Owner) != none)
			Attachment = BogieGunAttachmentL(Weapon(Owner).ThirdPersonActor);

//		log("-- slave Gun = "$BogieGun(Owner).slaveGun);
//		if(BogieGun(Owner).slaveGun != none)
//			log("-- slave Gun TPA = "$BogieGun(Owner).slaveGun.ThirdPersonActor);

		if(Attachment2 == none && BogieGun(Owner) != none && BogieGun(Owner).slaveGun != none)
			Attachment2 = BogieGunAttachmentR(BogieGun(Owner).slaveGun.ThirdPersonActor);

		GotoState('Firing');
		Weapon.Ammo[0].bRegen=false;
	}
}

state Firing
{
    function BeginState()
    {
        NextFireTime = Level.TimeSeconds - 0.1; //fire now!
		//Attachment.AmbientSound=FiringSound;
	}
	function EndState()
	{
	}
    function ModeTick(float dt)
    {
        Super.ModeTick(dt);

        if(!Weapon.HasAmmo())
		{
			StopFiring();
			Weapon(Owner).PlayIdle();
		}
   }
    function StopFiring()
    {
		//Attachment.AmbientSound=WindingSound;
		if(Attachment != none)
			Attachment.StopAnimating();
		if(Attachment2 != none)
			Attachment2.StopAnimating();
		GotoState('Idle');
    }
}

state Overheat
{
	function BeginState()
	{
		if(OverheatSmoke == none) {
			OverheatSmoke = Spawn(class'DavidPuncherOverheat');
			OverheatSmoke.mRegenPause = false;
		}
		else
			OverheatSmoke.mRegenPause = false;

		if(OverheatSmoke2 == none) {
			OverheatSmoke2 = Spawn(class'DavidPuncherOverheat');
			OverheatSmoke2.mRegenPause = false;
		}
		else
			OverheatSmoke2.mRegenPause = false;

		if(Attachment != none)
			Attachment.AttachToBone(OverheatSmoke, Attachment.SFXRef1);

		if(Attachment2 != none)
			Attachment2.AttachToBone(OverheatSmoke2, Attachment.SFXRef1);

		FireRate = 0.35;
        NextFireTime = Level.TimeSeconds - 0.1; //fire now!
//		BulletShells = spawn(class'DavidBulletCasings');
//		Attachment.AttachToBone(BulletShells, Attachment.SFXRef1);
	}
	function EndState()
	{
		if(OverheatSmoke != none)
			OverheatSmoke.mRegenPause = true;
		if(OverheatSmoke2 != none)
			OverheatSmoke2.mRegenPause = true;
		FireRate = 0.25;
	}
//	event ModeDoFire(){}
//	function StartFiring(){}
    function Tick(float dt)
    {
        Super.Tick(dt);
 		bOverheated=true;
		HeatTime-=CoolFactor * dt;
		if(HeatTime < 0.0)
			HeatTime = 0.0;
		if(HeatTime <= 0.0)
		{
			HeatTime = 0.0;
			bOverheated=false;
			FireRate = 0.1;
			if(bIsFiring)
				GotoState('Firing');
			else
				GotoState('Idle');
		}
		HudBarValue = HeatTime/MaxHeatTime;
	}
}

defaultproperties
{
     FiringSound=Sound'SM-chapter03sounds.TurretOneSecondLoopB'
     Momentum=768.000000
     DamageType=Class'VehicleWeapons.PuncherDamage'
     HitEffectClass=Class'VehicleWeapons.VGHitEffect'
     TracerClass=Class'VehicleGame.Tracer'
     VehicleDamage=20
     PersonDamage=15
     MaxHeatTime=5.500000
     MaxCoolTime=4.000000
     AmmoPerFire=1
     FireAnimRate=4.000000
     FireRate=0.100000
     BotRefireRate=0.990000
     aimerror=800.000000
     Spread=0.050000
     FireLoopAnim="Fire"
     FireEndAnim="Idle"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     SpreadStyle=SS_Random
     bPawnRapidFireAnim=True
     SoundRadius=200.000000
     SoundVolume=200
}
