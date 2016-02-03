class TestAIRole extends SPAIRole;

var SPAITestController.EAction testAction;
var int curState;


function init(VGSPAIController c)
{
    super.init(c);
    bot.Enemy = Level.GetLocalPlayerController().Pawn;
}


function FindNewCoverFailed()
{
   bot.Perform_Engaged_StandGround();
}


function RoleSelectAction()
{
	switch(testAction)
	{
	case A_Rest:
		bot.Perform_NotEngaged_AtRest();
		break;
	case A_Wander:
		switch(curState)
		{
		case 0:
			timeTracker = Level.TimeSeconds;
			timeDuration = RandRange(1.0, 3.0);
			curState = 1;
			bot.Perform_NotEngaged_Wander();
			break;
		
		case 1:
			curState = 0;
			if( TimeElapsed(bot.LastWanderTime, timeDuration) )
				curState = 0;
			bot.Perform_NotEngaged_AtRest();
			break;
		}
		break;
	case A_MoveToPosition:
		bot.MoveTarget = Level.GetLocalPlayerController().Pawn;
		bot.Perform_RunToward( StagePosition(bot.MoveTarget));
		break;
	case A_StandGround:
		bot.Perform_Engaged_StandGround();
		break;
	case A_PursueEnemy:
		if( bot.EnemyIsVisible() )
			curState = 0;
		else	
			curState = 1;
		switch(curState)
		{
		case 0:
			bot.Perform_Engaged_StandGround();
			break;
		case 1:
			bot.Perform_Engaged_RecoverEnemy();
			break;
		}
		break;
	case A_Hide:
		bot.Perform_Engaged_HideFromEnemy();
		break;
	case A_StrafeMove:
		bot.Perform_Engaged_StrafeMove();
		break;
	case A_Panic:
		bot.Perform_Engaged_Panic();
		break;
	case A_TakeCover:
		bot.Perform_Engaged_TakeCover();
		break;
	case A_SupressionFire:
		bot.Perform_Engaged_SupressionFire();
		break;
	case A_Charge:
		//bot.Perform_Engaged_Charge();
		break;

	case A_CloseIn:
		bot.Perform_Engaged_FindNewCover();
        break;

	case A_ChargeStrafe:
		switch(curState)
		{
		case 0:
			//bot.Perform_Engaged_Charge();
			curState = 1;
			break;
		case 1:
			bot.Perform_Engaged_StrafeMove();
			curState = 0;
			break;
		}
		break;

	case A_GetLOS:
		switch(curState)
		{
		case 0:
			bot.Perform_Engaged_GetLOS();
			curState = 1;
			break;
		case 1:
			if( !bot.EnemyIsVisible() /*|| NoLongerOnGoodNode()*/ )
				curState = 0;
			bot.Perform_Engaged_StandGround();
			break;
		
		}
		
		break;

    case A_Hunt:
        //if( !bot.EnemyIsVisible() )
            bot.Perform_Engaged_HuntEnemy();
        //else
        //   bot.Perform_Engaged_StandGround();
		break;

	case A_BackOff:

		if( VSize(bot.Pawn.Location - bot.Enemy.Location) < 500 )
		{
			log("Too Close");
			curState = 1;
		}
		if( VSize(bot.Pawn.Location - bot.Enemy.Location) > 2000 )
		{
			log("Too Far");
			curState = 2;
		}

		if( (VSize(bot.Pawn.Location - bot.Enemy.Location) < (timeTracker-20)) &&
			(VSize(bot.Pawn.Location - bot.Enemy.Location) < 750) )
		{
			log("Closer" @ VSize(bot.Pawn.Location - bot.Enemy.Location) @ timeTracker);
			curState = 1;
		}
		if ( (VSize(bot.Pawn.Location - bot.Enemy.Location) > (timeTracker+20)) &&
			(VSize(bot.Pawn.Location - bot.Enemy.Location) > 750) )
		{
			log("Farther" @ VSize(bot.Pawn.Location - bot.Enemy.Location) @VSize(bot.Pawn.Location - bot.Enemy.Location) @ timeTracker);
			curState = 2;
		}	

		switch(curState)
		{
		case 0:	//standing ground
			bot.Perform_Engaged_StandGround();
			if(timeTracker == 0)
				timeTracker = VSize(bot.Pawn.Location - bot.Enemy.Location);
			break;

		case 1:	//backing off
			bot.Perform_Engaged_BackOff();
			timeTracker = VSize(bot.claimedPosition.Location - bot.Enemy.Location);
			curState = 0;
			break;

		case 2:	//closing in
			bot.Perform_Engaged_FindNewCover();
			timeTracker = VSize(bot.claimedPosition.Location - bot.Enemy.Location);
			curState = 0;
			break;

		}

		break;
    case A_AttackFromCover:
        switch(curState)
		{
		    case 0:
                bot.Perform_Engaged_TakeCover(3);
                curState = 1;
                break;
            case 1:
                bot.Perform_AttackFromCover(3);
                break;
        }
        break;
    case A_Flank:
        bot.Perform_Engaged_FlankTo(Level.GetLocalPlayerController().Pawn);
        break;
    case A_Auto:
		Super.RoleSelectAction();
		break;
	}

}

defaultproperties
{
}
