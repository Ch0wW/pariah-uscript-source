class MiniAssaultObjective extends DestroyableObjective;

var bool bDestroyed;
var float Invulnerable;

function Reset()
{
	bDestroyed = False;
	Invulnerable = Level.TimeSeconds + 8;
	Super.Reset();
}

function DisableObjective(Pawn Instigator)
{
	bDestroyed=True;
	Super.DisableObjective(Instigator);
}

function bool TellBotHowToDisable(Bot B)
{
	if ( (Level.TimeSeconds - B.Pawn.LastPainTime < 7.0) || B.EnemyVisible() )
		return false;

	if ( B.CanAttack(self) )
	{
		// FIXME - decide whether to kill enemy first

		`B.`GoalString = "Attack Objective";
		B.DoRangedAttackOn(self);
		return true;
	}

	return B.SetRouteToGoal(self);
}


function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	local int h;
	local float damagerange;

	if(bDestroyed)
		return;
		
    if(Level.TimeSeconds < Invulnerable)
    {
        return;
    }

	h=Health;
	Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType, ProjOwner, bSplashDamage);

	if(Health!=h)
	{
		damagerange = (float(Max(health,0))/float(DamageCapacity));
		Level.Game.GameReplicationInfo.ObjectiveDamage[0] = damagerange * 255;
	}
}

defaultproperties
{
     DamageCapacity=800
     DrawScale=3.000000
     StaticMesh=StaticMesh'DavidPrefabs.Blocks.Cylinder'
     DrawType=DT_StaticMesh
     bHidden=False
     bBlockActors=True
     bBlockPlayers=True
     bBlockKarma=True
}
