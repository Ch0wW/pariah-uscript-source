class HealingToolRaise extends VGInstantFire;

const MAX_HEALING_DIST = 150;

var		bool	bHitEnemy;
var		Pawn	HitPawn;
var		vector	HitPawnLocation;
var		float	HealTime;
var ()	float	MaxHealth;
var		bool	bFlapsAreMovingBack;
var		bool	bReadyToHeal, bAllowHeal;
var		float	TimeToRevive;
var		int		ReviveHP;

var bool bDisabled;
var float DisableTimer;

var bool bEnabled;			// reviving enabled or not
var bool bJustFired;

simulated function bool AllowFire() 
{ 
	// test for ammo
	if(Instigator.Health > 0 && Weapon.Ammo[ThisModeNum] != None && Weapon.Ammo[ThisModeNum].AmmoAmount < AmmoPerFire) {
		HitPawn = none;
		return false;
	}

	// check to see if the raise upgrade has been enabled
	if(!bEnabled)
		return false;

	// check for a pawn to revive
	CheckHit();

	// if we just fired, don't do it now (test to prevent an extra fire animation after releasing the fire button)
	if(bJustFired) {
		bJustFired = false;
		HitPawn = none;
		return false;
	}

	// check to see if we're disabled (as a result from being hit by the EMP)
	if(bDisabled)
		return false;

	// check to see if the hitpawn is targetable and, if so, check if it's a "mostly dead" pawn
	if(HitPawn != none) {
		if(CanTarget(HitPawn) )
			// only raise those who are actually dead
			return HitPawn.Health <= 0;

//		return HitPawn.Health > 0;
	}

	return false;
}

simulated function Tick(float dt)
{
	// if the defibrillator is disabled (because of an EMP hit) then advance the disable timer, reenabling if the timer expires
	if(bDisabled) {
		DisableTimer += dt;
		if(DisableTimer > 10.0) {
			bDisabled = false;
			DisableTimer = 0;
		}
	}

	Super.Tick(dt);
}

function ModeHoldFire()
{
	if(AllowFire() ) {
		GotoState('Charge');
		Super.ModeHoldFire();
	}
}

function ModeDoFire()
{
	Super.ModeDoFire();
	HoldTime = 0;
	HitPawn = none;
}

// check to see if there is a pawn (other than a vehicle) within range to be healed
function CheckHit()
{
	local Actor Other;
    local Vector HitNormal, StartTrace, EndTrace;
    local Rotator Aim;

	StartTrace = Instigator.Location;  
	Aim = AdjustAim(StartTrace, AimError);
	EndTrace = StartTrace+MAX_HEALING_DIST*Vector(Aim); 

	Other = Trace(HitPawnLocation, HitNormal, EndTrace, StartTrace, true);
	if(Other != None && Other != Instigator && Other.IsA('Pawn') && !Other.IsA('VGVehicle') )
	{
		HitPawn = Pawn(Other);
		bHitEnemy = true;
		Owner.AmbientSound = None;
	}
}

function DoTrace(Vector Start, Rotator Dir)
{
	// ... do nothing...
}

simulated function WECLevelUp(int level)
{
	switch(Level) {
		case 1:	// defibrillator
			bEnabled = true;
			break;
		case 2:	// improved heal
			TimeToRevive = 2.5;
			ReviveHP = 80;
			break;
		case 3:	// stealth kill
			break;
	}
}

function PlayFiring() {}

// test to see if a pawn can be targetted by the healing tool's raise functionality (team members only)
simulated function bool CanTarget(Pawn P)
{
	if(P == none || P == Instigator)
		return false;

	if(P.IsA('MostlyDeadPawn') )
		return true;

    return (P.PlayerReplicationInfo != None && P.PlayerReplicationInfo.Team == Instigator.PlayerReplicationInfo.Team);
}

// "charge" the healing tool... this is where revival happens
simulated state Charge
{
	simulated function BeginState()
	{
        NextFireTime = Level.TimeSeconds - 1.0; //fire now!
		HealTime = 0;
		Weapon.IncrementFlashCount(ThisModeNum);
	}
	simulated function EndState()
	{
		Weapon.PlayAnim( FireEndAnim, FireEndAnimRate, TweenTime );
		bReadyToHeal = false;
		bHitEnemy = false;
		HitPawn = none;
		Weapon.ZeroFlashCount(ThisModeNum);
	}

    function ModeTick( float dt )
    {
		local float dist;

		HealTime += dt;
        NextFireTime = Level.TimeSeconds - 1.0; //fire now!

		if(HealTime >= TimeToRevive && HitPawn != none) {
			// we've been "charging" long enough to revive the target
			if(Level.NetMode != NM_Client) {
				HitPawn.GiveHealth(ReviveHP, MaxHealth);
				HitPawn.Revive(Instigator);
			}
			Global.ModeDoFire();
			bJustFired = true;
			GotoState('');
			HitPawn = none;
		}

		// check to make sure we're still close enough to our target
		if(HitPawn != none && HitPawn != Instigator) {
			dist = VSize(HitPawn.Location-Instigator.Location);
			if(dist > MAX_HEALING_DIST) {
				// connection with target broken...
				if(!bJustFired)
					Global.ModeDoFire();
				bJustFired = true;
				GotoState('');
			}
		}
	}

	simulated function bool AllowFire() { return HitPawn != none; }

	event ModeDoFire()
	{
		HitPawn = none;
		Global.ModeDoFire();
		GotoState('');
	}
}

defaultproperties
{
     ReviveHP=35
     MaxHealth=100.000000
     TimeToRevive=5.000000
     bAllowHeal=True
     TraceRange=200.000000
     Momentum=100.000000
     DamageType=Class'VehicleWeapons.HealingToolDamage'
     bAnimateThird=False
     AmmoPerFire=1
     PreFireTime=1.000000
     FireRate=0.150000
     BotRefireRate=0.990000
     PreFireAnim="FirePreB"
     FireAnim="FireLoopB"
     FireLoopAnim="FireLoopB"
     FireEndAnim="FireEndB"
     AmmoClass=Class'VehicleWeapons.HealingToolAmmo'
     FireForce="HealingToolFire"
     bFireOnRelease=True
}
