class SPAIRoleDefensive extends SPAIRole;

var float LastEnemyDist;

function GOTO_Attack()
{
    GotoState('DefensiveAttack');
}

state DefensiveAttack 
{
    function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }
    
    function BeginState(){}

	function TakeCoverFailed()
	{
		GotoState('NOCOVER');
	}

    function AttackFromCoverFailed()
    {
        GotoState('NoCover', 'WaitForPlayer');
    }

BEGIN:
    while(true) {
        if( !bot.IsInValidCover() ) {
            bot.Perform_Engaged_TakeCover(); WaitForNotification();
        }
        else {
            bot.Perform_AttackFromCover( 1.0f + 1.0f*frand() ); WaitForNotification();
            if( bot.ShouldReload() ) {
                bot.StartReload();
				if( !bot.IsInValidCover() ) {
					bot.Perform_Engaged_TakeCover(); WaitForNotification();
				}
            }
        }
    }
}

state NoCover
{
    function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }
    
    function OnLostSight()
    {
        if(curLabel != 'WAITFORPLAYER')
            GotoState('NoCover', 'WaitForPlayer');
    }
	
	function OnMustReload(){
		bot.StartReload();
	}

    function float curDist()
    {
        return Approx2DLength( (bot.Enemy.Location - bot.pawn.Location) );
    }

BEGIN:    
    while(true) {
        curLabel = 'NOCOVER';
	    if(true)
        {
            LastEnemyDist = curDist();
			bot.Perform_Engaged_StandGround(1.0+Frand()); WaitForNotification();

            if( abs(LastEnemyDist - curDist()) < 100 )
            {
                bot.Perform_Engaged_StandGround(0.5+Frand()); WaitForNotification();
            }
			else if(  curDist() < LastEnemyDist || curDist() < 1000)
			{
				bot.Perform_Engaged_Backoff();  WaitForNotification();
			}
        }
        //Try finding cover
        GotoState('DefensiveAttack');
    }

WAITFORPLAYER:
    curLabel = 'WAITFORPLAYER';
    bot.Perform_Engaged_StandGround(3.0); WaitForNotification();
    GotoState('DefensiveAttack');

}

defaultproperties
{
}
