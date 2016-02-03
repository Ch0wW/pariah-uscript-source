class PuncherFire extends VGInstantFire;

var	float					MaxRollSpeed;
var	float					RollSpeed;
var	float					SpinTime;		//how long has it been spinning up/down
var	PuncherAttachment		Attachment;
var Emitter					BulletShells;
var	xEmitter				OverheatSmoke;

var	()	Sound				FiringSound;
var	()	Sound				WindingSound;
var	()	float				MaxSpinTime;	//time after spining up or down to fire or stop spinning
var	()	float				NumBarrels;		//how many barrels the gun has

function PostBeginPlay()
{
	Super.PostBeginPlay();
	MaxRollSpeed = 65536.f/NumBarrels/FireRate;	//make barrel roll speed dependant on fire rate
}

simulated function Destroyed()
{
	Attachment = none;
	if(BulletShells != none)
	{
		BulletShells.Destroy();
	}
	if(OverheatSmoke != none)
	{
		OverheatSmoke.Destroy();
	}
	Super.Destroyed();
}

function StopRoll()
{
	RollSpeed = 0.0;
	SpinTime = 0.0;
	if(Attachment != none)
	{
		Attachment.StopBarrel();
	}
}

function PutDown()
{
	LastHeatTime = Level.TimeSeconds + HeatTime;
	GotoState('Idle');
}

function BringUp()
{
	HeatTime = LastHeatTime - Level.TimeSeconds;
	if(HeatTime < 0.0)
		HeatTime = 0.0;
    // jjs disabled
	//if(bOverheated)
	//	GotoState('Overheat');
}

function StopFiring()
{
	if(Attachment != none)
		Attachment.StopAnimating();
	//log("PUNCHER:  StopFiring");
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
		StopRoll();
		if(Weapon != none && Weapon.Ammo[0] != none)
			Weapon.Ammo[0].bRegen=true;
		//Attachment.AmbientSound = none;

//		if(BulletShells != none)
//			BulletShells.Kill();
	}
    function StartFiring()
    {
		if(Attachment == none)
		{
			Attachment = PuncherAttachment(Weapon(Owner).ThirdPersonActor);
		}
		RollSpeed = Attachment.CurrentRoll;
		//Attachment.AmbientSound = WindingSound;
		GotoState('SpinUp');
		Weapon.Ammo[0].bRegen=false;
	}
}

state Firing
{
    function BeginState()
    {
        NextFireTime = Level.TimeSeconds - 0.1; //fire now!
        if(Level.NetMode != NM_DedicatedServer)
        {
		    if(BulletShells == none)
			    BulletShells = spawn(class'DavidBulletCasings');
		    //log("!! Bullets = "$BulletShells);
		    Attachment.AttachToBone(BulletShells, Attachment.SFXRef1);
		    BulletShells.Start();
        }
		//Attachment.AmbientSound=FiringSound;
	}
	function EndState()
	{
	    if(BulletShells != none)
		    BulletShells.Stop();
		//BulletShells = none;
	}
    function ModeTick(float dt)
    {
        Super.ModeTick(dt);
        Attachment.RollBarrel(dt, RollSpeed);
 		// jjs disabled
        //HeatTime+=dt;
		//HudBarValue = HeatTime/MaxHeatTime;
		//if(HeatTime >= MaxHeatTime)
		//{
		//	GotoState('Overheat');
		//}
		if(!Weapon.HasAmmo())
		{
			StopFiring();
			Weapon(Owner).PlayIdle();
			//log("PUNCHER: Firing.ModeTick - StopFiring (no ammo)");
		}
   }
    function StopFiring()
    {
		//Attachment.AmbientSound=WindingSound;
		if(Attachment != none)
			Attachment.StopAnimating();
		GotoState('SpinDown');
    }
}

state SpinUp
{
	event ModeDoFire(){}
    function ModeTick(float dt)
    {
		HeatTime-=dt * CoolFactor;
		if(HeatTime < 0.0)
			HeatTime = 0.0;
		HudBarValue = HeatTime/MaxHeatTime;
        SpinTime += dt;
        RollSpeed = (SpinTime/MaxSpinTime) * MaxRollSpeed;

        if (RollSpeed >= MaxRollSpeed)
        {
            RollSpeed = MaxRollSpeed;
            Attachment.RollBarrel(dt, RollSpeed);
            GotoState('Firing');
            return;
        }
        Attachment.RollBarrel(dt, RollSpeed);
    }

    function StopFiring()
    {
		if(Attachment != none)
			Attachment.StopAnimating();
        GotoState('SpinDown');
		log("PUNCHER: SpinUp.StopFiring");
    }
}

state SpinDown
{
	event ModeDoFire(){}
    function ModeTick(float dt)
    {
		HeatTime-=dt * CoolFactor;
		if(HeatTime < 0.0)
			HeatTime = 0.0;
		HudBarValue = HeatTime/MaxHeatTime;
        SpinTime -= dt;
        RollSpeed = (SpinTime/MaxSpinTime) * MaxRollSpeed;

        if (RollSpeed <= 0.0)
        {
            RollSpeed = 0.0;
            Attachment.RollBarrel(dt, RollSpeed);
            StopRoll();
			GotoState('Idle');
            return;
        }
        Attachment.RollBarrel(dt, RollSpeed);
	}
    function StartFiring()
    {
		GotoState('SpinUp');
	}
}

state Overheat
{
	function BeginState()
	{
		if(OverheatSmoke == none)
		{
			OverheatSmoke = Spawn(class'DavidPuncherOverheat');
		}
		Attachment.AttachToBone(OverheatSmoke, Attachment.SFXRef1);
		OverheatSmoke.mRegenPause=false;
		FireRate = 0.35;
        NextFireTime = Level.TimeSeconds - 0.1; //fire now!
//		BulletShells = spawn(class'DavidBulletCasings');
//		Attachment.AttachToBone(BulletShells, Attachment.SFXRef1);
	}
	function EndState()
	{
		OverheatSmoke.mRegenPause=true;
		FireRate = 0.1;
	}
//	event ModeDoFire(){}
//	function StartFiring(){}
    function ModeTick(float dt)
    {
        Super.ModeTick(dt);
        Attachment.RollBarrel(dt, RollSpeed*0.1);
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

/*		if(SpinTime == 0.0)
			return;

        SpinTime -= dt;
		if(SpinTime < 0.0)
			SpinTime = 0.0;
        RollSpeed = (SpinTime/MaxSpinTime) * MaxRollSpeed;
        if (RollSpeed <= 0.0)
        {
            RollSpeed = 0.0;
            Attachment.RollBarrel(dt, RollSpeed);
            StopRoll();
			return;
		}
		Attachment.RollBarrel(dt, RollSpeed);*/
	}
}

function DoFireEffect()
{
    Super.DoFireEffect();
    Attachment.PlayOwnedSound(Sound'NewVehicleSounds.Weapons.WaspFireA', SLOT_None, TransientSoundVolume,false,,,false);
}

defaultproperties
{
     MaxSpinTime=0.300000
     NumBarrels=3.000000
     FiringSound=Sound'SM-chapter03sounds.TurretOneSecondLoopB'
     WindingSound=Sound'SM-chapter03sounds.TurretSpinA'
     Momentum=1024.000000
     TracerFreq=0.500000
     DamageType=Class'VehicleWeapons.PuncherDamage'
     HitEffectClass=Class'VehicleWeapons.VGHitEffect'
     TracerClass=Class'VehicleGame.Tracer'
     VehicleDamage=20
     PersonDamage=20
     MaxHeatTime=6.000000
     MaxCoolTime=3.500000
     AmmoPerFire=1
     FireAnimRate=0.250000
     FireRate=0.150000
     BotRefireRate=0.990000
     aimerror=800.000000
     Spread=0.060000
     FireAnim="None"
     FireLoopAnim="Fire"
     FireEndAnim="None"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     FireForce="PuncherFire"
     SpreadStyle=SS_Random
     bPawnRapidFireAnim=True
     SoundRadius=200.000000
     SoundVolume=200
}
