//Adds the driving states.
//Adds disposition
class SPAIRole extends AIRole;

var String actionString;

/**
 */
function OnStartle(Actor Feared)
{
    if(SPAIController(bot).MayDive())
        SPAIController(bot).Perform_DiveFromGrenade(Feared);
}

function GOTO_Patrol()
{
    if( VGVehicle( bot.Pawn ) != None ) {
        GotoState('DrivingPatrol');
    }
    else {
        GotoState('Patrol');
    }
}

function RoleSelectAction()
{
	if( VGVehicle( bot.Pawn ) != None ) {
        SelectVehicleAction();
    }
    else if( bot.bIsRidingVehicle ) {
        GotoState('Riding');
    }
    else {
        if( IsInDrivingState() )
        {
            GotoState('');
        }

        Super.RoleSelectAction();   
    }
}

function SelectBehaviour()
{
	if( VGVehicle( bot.Pawn ) != None ) {
        SelectVehicleAction();
    }
    else if( bot.bIsRidingVehicle ) {
        GotoState('Riding');
    }
    else {
        Super.SelectBehaviour(); 
	}
}

function SelectVehicleAction()
{
	AnalyzeSituation();
    bot.StartFireWeapon();
    if( !IsInDrivingState() )
		GotoState('Driving');

	SelectBehaviour();
	PerformBehaviour();
}

function bool IsInDrivingState()
{
	return( IsInState('Driving')
        || IsInState('DrivingPatrol')
        || IsInState('DrivingAttack') );
}

function SelectVehicleCombatAction()
{
	GotoState('DrivingAttack');
}

function SelectVehicleNonCombatAction()
{
	GotoState('Driving');
}

//===============
// Driving states
//===============
state Driving
{
	function SelectBehaviour()
	{
		if(bot.Enemy != None)
			SelectVehicleCombatAction();
	}

    function PerformBehaviour()
    {
		Notify();
    }

BEGIN:
    while(true) {
        SPAIController(bot).Perform_vehRest(); WaitForNotification();
    }
}

state DrivingPatrol
{
    function SelectBehaviour()
	{
		if(bot.Enemy != None)
			SelectVehicleCombatAction();
	}

    function PerformBehaviour()
    {
		Notify();
    }

BEGIN:
    while(true) {
        if(patrolPos == None){
            SPAIController(bot).Perform_vehRest(); WaitForNotification();
        }
        else {
            bot.Perform_WalkToward(patrolPos); WaitForNotification();
            if(patrolPos.PauseTimeMin > 0) { 
                bot.Perform_NotEngaged_AtRest( RandRange(patrolPos.PauseTimeMin, patrolPos.PauseTimeMax)  );
                WaitForNotification();
            }
            patrolPos = patrolPos.nextPosition;
        }

    }
}


state DrivingAttack
{
	function String GetDebugText()
	{
		return actionString@bot.movetimer;
	}

	function SelectBehaviour()
	{		
		if(bot.Enemy == None)
		{
			SelectVehicleNonCombatAction();
			return;
		}
		FightEnemy();
	}

	function FightEnemy()
	{
		if( bot.ActorReachable(bot.Enemy) )
		{ 	
			DoAttackStyle();
			actionString = "1-"$actionString;
		}
		else if(bot.CanAttack(bot.Enemy) && (VGVehicle(bot.Enemy) != None) ) //line of sight regardless of sector
		{
			actionString = "2-STANDOFF";
			GotoState('DrivingAttack', 'STANDOFF');
		}
		else
		{
			actionString = "3-Hunting";
			GotoState('DrivingAttack', 'HUNT');
		}
	}

	function DoAttackStyle()
	{
		local Vector carDir, enemyDir;
		local bool bEnemyMovingAway, bEnemyFacingUs;
		local float enemyDist;
		
		enemyDir = (bot.Enemy.Location - bot.Pawn.Location);
		enemyDist = VSize(enemyDir);
		
		//enemy not in car
		if( VGVehicle(bot.Enemy) == None && !bot.Enemy.Controller.bIsRidingVehicle)
		{
			if(enemyDist < VGVehicle(bot.Pawn).minTurnRadius && (enemyDir dot bot.Pawn.Velocity) < 0.93f)
			{
				GotoState('DrivingAttack', 'REAPPROACH');
				actionString = "REAPPROACH for RUNOVER";
			}
			else
			{
				GotoState('DrivingAttack', 'CHARGERAM');
				actionString = "RUNOVER";
			}
		}
		else	//enemy in car
		{
			//FIXME: Should also account for type of weapon.
			carDir = vector(bot.Pawn.Rotation);
			bEnemyMovingAway = VSize(bot.Enemy.Velocity) > 100 &&
                                (bot.Enemy.Velocity dot enemyDir) > 0.0f;
			
			//bEnemyFacingUs = EnemyFacingTime > 2.0f + frand() * 2.0f; // enemy has faced us between 2 and 4 seconds
			bEnemyFacingUs = (Vector(bot.Enemy.Controller.Rotation) 
								dot Normal(bot.Pawn.Location - bot.Enemy.Location) > 0.707 /*0.95*/ ); 
			
			if( (carDir dot enemyDir) > 0.0f ) //enemy in front of us
			{
				if(enemyDist > 5000)	//far enough away from enemy
				{
					if(bEnemyFacingUs)
					{
						GotoState('DrivingAttack', 'AVOID');
				
						//FIXME We may want to ram here as well.
						//or find a spot to hide behind
						actionString = "AVOID 1";
						//GotoState('vehAvoidFire');
					}
					else if(bEnemyMovingAway)	//med away + distance opening => charge
					{
                        GotoState('DrivingAttack', 'CHARGEATTACK');
						actionString = "CHARGE";
					}
					else if(frand() < 0.25 )	//med away + distance closing  => RAM
					{
						GotoState('DrivingAttack', 'CHARGERAM');
						
						// FIXME increase chance of ramming if we have the power up.
						actionString = "RAM";
					}
					else//med away + distance closing + 50%, => standoff
					{
						GotoState('DrivingAttack', 'STANDOFF');
						
						actionString = "STANDOFF";
					}
					
				}
				else	//pretty close to enemy
				{
					if(enemyDist < 1200)
					{
						GotoState('DrivingAttack', 'REAPPROACH');
						
						actionString = "TOO CLOSE REAPPROACH";
					}

					if(bEnemyFacingUs && frand() < 0.5)
					{
						GotoState('DrivingAttack', 'AVOID');
				
						actionString = "AVOID 2";
					}
					else if(bEnemyMovingAway)	//close + distance opening	=>standoff
					{
						GotoState('DrivingAttack', 'STANDOFF');
						
						actionString = "STANDOFF";
					}
					else if(frand() < 0.8)	//close + distance closing + 80%, => standoff
					{
						GotoState('DrivingAttack', 'STANDOFF');
						
						actionString = "STANDOFF";
					}
					else	 //close + distance closing	=>reapproach
					{	
						GotoState('DrivingAttack', 'REAPPROACH');
						
						actionString = "REAPPROACH";
					}
				}
			}
			else	//enemy behind us
			{
				GotoState('DrivingAttack', 'STANDOFF');
						
				//FIXME perhaps put in stuff for when enemy is facing us
				actionString = "STANDOFF";
			}
		}
		actionString = actionString@Level.TimeSeconds;
		return;
	}


	function PerformBehaviour()
    {
		Notify();
    }

	
BEGIN:

STANDOFF:
	SPAIController(bot).Perform_vehStandoff(); WaitForNotification();
REAPPROACH:
	SPAIController(bot).Perform_vehReApproach(); WaitForNotification();
CHARGERAM:
	SPAIController(bot).Perform_vehChargeRam(); WaitForNotification();
CHARGEATTACK:
	SPAIController(bot).Perform_vehChargeAttack(); WaitForNotification();
AVOID:
	SPAIController(bot).Perform_vehAvoidFire(); WaitForNotification();
HUNT:
	SPAIController(bot).Perform_vehHunt(); WaitForNotification();

}




//==============
// Riding states
//==============

state Riding
{
    function PerformBehaviour()
    {
        Notify();
    }
BEGIN:
    while(true) {
        SPAIController(bot).Perform_RidingVehicle(); WaitForNotification();
    }
}

defaultproperties
{
}
