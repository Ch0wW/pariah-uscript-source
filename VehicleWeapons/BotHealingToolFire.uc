class BotHealingToolFire extends VGInstantFire;

var		bool	bHitEnemy;
var		Pawn	HitPawn;
var		vector	HitPawnLocation;
var		float	HealTime;
var	()	float	HealTimeFreq;
var	()	float	HealTimeFactor;
var		float	AutoFireCheckTime;
var	()	float	AutoFireCheckFreq;
var ()	float	MaxHealth;
var	()	int		HealingDamage;

function ModeTick(float dt)
{

	if(bIsFiring)
	{
		HealTime += dt;
		AutoFireCheckTime += dt;
		if(HealTime * HealTimeFactor >= HealTimeFreq)
		{
			Instigator.GiveHealth(1,MaxHealth);
			HealTime = 0.0;
		}
		if(AutoFireCheckTime >= AutoFireCheckFreq)
		{
			CheckHit();
			AutoFireCheckTime = 0.0;
		}
	}
}

function CheckHit()
{
	local Actor Other;
    local Vector HitNormal, StartTrace, EndTrace;
    local Rotator Aim;

	StartTrace = Instigator.Location;  
	Aim = AdjustAim(StartTrace, AimError);
	EndTrace = StartTrace + TraceRange * Vector(Aim); 

	Other = Trace(HitPawnLocation, HitNormal, EndTrace, StartTrace, true);
	if ( Other != None && Other != Instigator && Other.IsA('Pawn') && !Other.IsA('VGVehicle'))
	{
		HitPawn = Pawn(Other);
		bHitEnemy = true;
		bIsFiring = false;
		Owner.AmbientSound = None;
	}
}

function DoFireEffect()
{
	if(bHitEnemy)
	{
		if(Instigator.Controller.SameTeamAs(HitPawn.Controller))
		{
			//HitPawn.TakeDamage(HealingDamage, Instigator, HitPawnLocation, Momentum*vector(Instigator.Rotation), DamageType,,true);
			HitPawn.GiveHealth(HealingDamage, HitPawn.default.Health);
		}
		bHitEnemy = false;
		HitPawn = none;
	}
}

function DoTrace(Vector Start, Rotator Dir)
{
}

simulated function WECLevelUp(int level)
{
	switch(Level)
	{
	case 1:	HealTimeFactor *= 1.5; break;
	case 2:	HealingDamage = 80; break;
	case 3:	MaxHealth = 150; break;
	case 4:	HealingDamage = 110; break;
	}
}

defaultproperties
{
     HealingDamage=50
     HealTimeFreq=1.000000
     HealTimeFactor=10.000000
     AutoFireCheckFreq=0.150000
     MaxHealth=100.000000
     TraceRange=200.000000
     Momentum=100.000000
     DamageType=Class'VehicleWeapons.BotHealingToolDamage'
     bAnimateThird=False
     AmmoPerFire=1
     FireRate=1.000000
     BotRefireRate=0.990000
     FireSound=Sound'PariahWeaponSounds.hit.HT_FireEnd'
     FireLoopAnim="None"
     FireEndAnim="None"
     AmmoClass=Class'VehicleWeapons.VGUnlimitedAmmo'
     FireForce="BotHealingToolFire"
     bFireOnRelease=True
}
