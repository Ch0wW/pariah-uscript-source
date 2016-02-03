class BogieGunFireR extends VGInstantFire;

var	BogieGunAttachmentR		Attachment;
var	xEmitter				OverheatSmoke;

var	()	Sound				FiringSound;
var int lastGunFired;	// which of the two guns fired last (0 or 1)
var int fireSeq;

function PostBeginPlay()
{
	Super.PostBeginPlay();
//	if(Weapon != none && Weapon.IsA('BogieGunR') )
//		fireSeq = 1;
}

simulated function bool AllowFire()
{
    local VehiclePlayer VP;
	
	if(Instigator == none)
	{
		Instigator = Pawn(Weapon.Owner);
	}
	
	VP = VehiclePlayer(Instigator.Controller);

    if( (VP != None) && VP.bExitingByAnimation )
    {
        return false;
    }
    
	return (Weapon.Ammo[ThisModeNum] != None && Weapon.Ammo[ThisModeNum].AmmoAmount >= AmmoPerFire);
}

simulated function Destroyed()
{
	Attachment = none;

	if(OverheatSmoke != none)
		OverheatSmoke.Destroy();

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

		if(Attachment == none && BogieGun(Owner) != none && BogieGun(Owner).slaveGun != none)
			Attachment = BogieGunAttachmentR(BogieGun(Owner).slaveGun.ThirdPersonActor);

//		log("-- slave Gun = "$BogieGun(Owner).slaveGun);
//		if(BogieGun(Owner).slaveGun != none)
//			log("-- slave Gun TPA = "$BogieGun(Owner).slaveGun.ThirdPersonActor);

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

		if(Attachment != none)
			Attachment.AttachToBone(OverheatSmoke, Attachment.SFXRef1);

		FireRate = 0.35;
        NextFireTime = Level.TimeSeconds - 0.1; //fire now!
//		BulletShells = spawn(class'DavidBulletCasings');
//		Attachment.AttachToBone(BulletShells, Attachment.SFXRef1);
	}
	function EndState()
	{
		if(OverheatSmoke != none)
			OverheatSmoke.mRegenPause = true;
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
     fireSeq=1
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
     Spread=0.060000
     FireLoopAnim="Fire"
     FireEndAnim="Idle"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     SpreadStyle=SS_Random
     bPawnRapidFireAnim=True
     SoundRadius=200.000000
     SoundVolume=200
}
