class DestroyableObjective extends GameObjective;

var() int  DamageCapacity;	// amount of damage that can be taken before destroyed
var() name TakeDamageEvent;
var() int DamageEventThreshold;	// trigger damage event whenever this amount of damage is taken
var int AccumulatedDamage;
var int Health;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Reset();
}

/* TellBotHowToDisable()
tell bot what to do to disable me.
return true if valid/useable instructions were given
*/
function bool TellBotHowToDisable(Bot B)
{
	if ( B.CanAttack(self) )
	{
		// FIXME - decide whether to kill enemy first

		`B.GoalString = "Attack Objective";
		B.DoRangedAttackOn(self);
		return true;
	}

	return Super.TellBotHowToDisable(B);
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Health = DamageCapacity;
	AccumulatedDamage = 0;
	Super.Reset();
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	if ( bDisabled || (Damage <= 0) || InstigatedBy == None)
		return;

	if ( (InstigatedBy.PlayerReplicationInfo != None)
		&& (InstigatedBy.PlayerReplicationInfo.Team.TeamIndex == DefenderTeamIndex) )
		return;

	AccumulatedDamage += Damage;
	if ( (DamageEventThreshold > 0) && (AccumulatedDamage >= DamageEventThreshold) )
	{
		TriggerEvent(TakeDamageEvent,self, InstigatedBy);
		AccumulatedDamage = 0;
	}
	Health -= Damage;
	if ( Health <= 0 )
		DisableObjective(instigatedBy);
}

defaultproperties
{
     DamageCapacity=100
     bCollideActors=True
     bProjTarget=True
}
