class AssaultObjective extends DestroyableObjective;

var bool bDestroyed;
var AssaultBase myBase;

function Reset()
{
	bDestroyed = False;
	Super.Reset();
}

function PostBeginPlay()
{
	local AssaultBase ab;

	Super.PostBeginPlay();

	ForEach AllActors(class'AssaultBase', ab)
	{
		if(ab.TeamIndex == DefenderTeamIndex)
		{
			myBase = ab;
			break;
		}
	}
	if(myBase == None)
		log("WARNING: No Base for"@self);

	
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

	return B.SetRouteToGoal(myBase);
}

function DisableObjective(Pawn Instigator)
{
	bDestroyed=True;
	Super.DisableObjective(Instigator);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	local int h;
	local float damagerange;

	if(bDestroyed)
		return;


	h=Health;
	Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType, ProjOwner, bSplashDamage);

	if(Health!=h)
	{
		damagerange = (float(Max(health,0))/float(DamageCapacity));
		Level.Game.GameReplicationInfo.ObjectiveDamage[DefenderTeamIndex] = damagerange*255;
	}
}

defaultproperties
{
     DamageCapacity=10
     Score=3
     DrawScale=3.000000
     StaticMesh=StaticMesh'DavidPrefabs.Blocks.Cylinder'
     DrawType=DT_StaticMesh
     bHidden=False
     bBlockActors=True
     bBlockPlayers=True
     bBlockKarma=True
}
