class DartGunFire extends VGProjectileFire;

var	DartGunAttachment		Attachment;
var	xEmitter				OverheatSmoke, OverheatSmoke2;
var int						BarrelNum;

var	()	Sound				FiringSound;
var	()	float				YOffset;

function PostBeginPlay()
{
	Super.PostBeginPlay();
}

simulated function Destroyed()
{
	if(OverheatSmoke != none) {
		OverheatSmoke.Destroy();
		OverheatSmoke = none;
	}

	if(OverheatSmoke2 != none) {
		OverheatSmoke2.Destroy();
		OverheatSmoke2 = none;
	}

	Super.Destroyed();
}

simulated function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local Projectile pp;

	if(Level.NetMode == NM_Client)
		return none;

	if(ProjectileClass != None) {
		pp = Spawn(ProjectileClass,,, Start, Dir);
	}

    if(pp == None)
        return None;

	pp.ProjOwner = Weapon.Instigator.Controller;
	pp.Instigator = Weapon.Instigator;
    pp.Damage = Ceil(pp.Damage*DamageAtten);

	return pp;
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
		if(Weapon != none && Weapon.Ammo[0] != none)
			Weapon.Ammo[0].bRegen=true;
	}
    function StartFiring()
    {
		if(Attachment == none)
		{
			Attachment = DartGunAttachment(Weapon(Owner).ThirdPersonActor);
		}
		GotoState('Firing');
		Weapon.Ammo[0].bRegen=false;
	}
}

/*function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal;//, HitLoc, HitNorm;
    local Actor Other;
	local Material HitMat;
	local float damageAmount;
	local Material.ESurfaceTypes HitSurfaceType;

	X = Vector(Dir);
    End = Start + TraceRange * X;
    Other = Trace(HitLocation, HitNormal, End, Start, true,,HitMat);

    if ( Other != None && Other != Instigator )
    {
		if(Other.IsA('GrenadeProjectile') ) {
			GrenadeProjectile(Other).BlowUp(HitLocation);
			GrenadeProjectile(Other).Explode(HitLocation, HitNormal);
			GrenadeProjectile(Other).bDestroy = true;
			return;
		}

		if(Other.bProjTarget || !Other.bWorldGeometry)
        {
			if(Other.IsA('VGVehicle'))
				Other.TakeDamage(VehicleDamage, Instigator, HitLocation, Momentum*X, DamageType);
			else {
				damageAmount = PersonDamage;
				Other.TakeDamage(damageAmount, Instigator, HitLocation, Momentum*X, DamageType);
			}

			if(!Other.IsA('Pawn') && HitEffectClass != None && HitEffectProb >= FRand() ) {
				HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal, Weapon.GetHitEffectOwner(),HitMat);

				if(HitMat != none)
					HitSurfaceType = HitMat.SurfaceType;
				else
					HitSurfaceType = EST_Default;

				if(Other.bStatic)
					Level.QuickDecal(HitLocation, HitNormal, Other, 8.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 7 );
			}
		}
        else
        {
			//XJ can use HitMaterial from trace to determine effect since bsp doesn't work right.
            if (HitEffectClass != None && HitEffectProb >= FRand() )
            {
                HitEffectClass.static.SpawnHitEffect(Other, HitLocation, HitNormal, Weapon.GetHitEffectOwner(),HitMat);

				if(HitMat != none)
					HitSurfaceType = HitMat.SurfaceType;
				else
					HitSurfaceType = EST_Default;

				if(Other.bStatic)
					Level.QuickDecal(HitLocation, HitNormal, Other, 8.0f, 100.0f, class'ExplosionMark'.default.ProjTexture, int(HitSurfaceType), 7 );
            }
			else
        }
	}
	else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }

	//Trace following the bullets
	if(TracerFreq > FRand() && TracerClass != none) {
		Spawn(TracerClass,,, Start, Dir);
	}
}*/

function DoFireEffect()
{
    local Vector StartTrace;//, Delta;
    local Rotator R, Aim;
    local int t;//, i, k;
    local int TraceCount;
	local vector X, Y, Z;
//	local int nRad1, nRad2; //Frag rifle spread area delimiters (xmatt)
	local vector	localOffset;

	// Instigator.MakeNoise(1.0);
	MakeFireNoise();

    // the to-hit trace always starts right in front of the eye
	//StartTrace = Instigator.Location + Instigator.EyePosition();
	GetAxes( Weapon.ThirdPersonActor.Rotation, X, Y, Z );
	StartTrace = Weapon.GetFireStart( X, Y, Z );

	// adjust for which barrel we want
	if(BarrelNum == 0) {
		BarrelNum = 1;
		localOffset.y = YOffset;
		Weapon.ThirdPersonActor.PlayAnim('Fire01', 1);
	}
	else {
		BarrelNum = 0;
		localOffset.y = -YOffset;
		Weapon.ThirdPersonActor.PlayAnim('Fire02', 1);
	}
	localOffset = localOffset >> Weapon.ThirdPersonActor.Rotation;

	StartTrace += localOffset;

    Aim = AdjustAim(StartTrace, AimError);

    TraceCount = ProjPerFire;

	switch (SpreadStyle)
	{
	case SS_Random:
		for (t = 0; t < TraceCount; t++)
		{
			R = Aim;
			R = rotator(vector(R) + VRand()*FRand()*Spread);
			SpawnProjectile(StartTrace, R);
		}

		break;
	}
	Super(VGWeaponFire).DoFireEffect();
}

state Firing
{
    function BeginState()
    {
        NextFireTime = Level.TimeSeconds - 0.1; //fire now!
	}
	function EndState()
	{
	}
    function ModeTick(float dt)
    {
        Super.ModeTick(dt);
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
		}
   }
    function StopFiring()
    {
		if(Attachment != none)
			Attachment.StopAnimating();
		GotoState('Idle');
    }
}

state Overheat
{
	function BeginState()
	{
		if(OverheatSmoke == none)
			OverheatSmoke = Spawn(class'DavidPuncherOverheat');
		Attachment.AttachToBone(OverheatSmoke, Attachment.MuzzleRef);
		OverheatSmoke.SetRelativeLocation(vect(0, 30, 0) );
		OverheatSmoke.mRegenPause=false;

		if(OverheatSmoke2 == none)
			OverheatSmoke2 = Spawn(class'DavidPuncherOverheat');
		Attachment.AttachToBone(OverheatSmoke2, Attachment.MuzzleRef);
		OverheatSmoke2.SetRelativeLocation(vect(0, -30, 0) );
		OverheatSmoke2.mRegenPause=false;

		FireRate = 0.4;
        NextFireTime = Level.TimeSeconds - 0.1; //fire now!
	}
	function EndState()
	{
		OverheatSmoke.mRegenPause=true;
		OverheatSmoke2.mRegenPause=true;
		FireRate = 0.2;
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
     YOffset=22.000000
     FiringSound=Sound'SM-chapter03sounds.TurretOneSecondLoopB'
     ProjSpawnOffset=(X=50.000000,Y=10.000000)
     VehicleDamage=15
     PersonDamage=25
     MaxHeatTime=6.000000
     MaxCoolTime=3.500000
     AmmoPerFire=1
     FireRate=0.200000
     BotRefireRate=0.990000
     aimerror=800.000000
     Spread=0.030000
     FireSound=Sound'PariahWeaponSounds.DartGun_Fire'
     FireAnim="None"
     FireLoopAnim="None"
     FireEndAnim="None"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     ProjectileClass=Class'VehicleWeapons.DartPlasma'
     FireForce="PuncherFire"
     SpreadStyle=SS_Random
     bPawnRapidFireAnim=True
     SoundRadius=200.000000
     SoundVolume=200
}
