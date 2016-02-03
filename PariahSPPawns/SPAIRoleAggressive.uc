class SPAIRoleAggressive extends SPAIRole;

var float LastEnemyDist;

function GOTO_Attack()
{
    GotoState('AggressiveAttack');
}


function bool CoverIsStale()
{
    if( bot.LastTakeCoverTime != 0 
        && TimeElapsed(bot.LastTakeCoverTime, 5.0) )
    {
        return true;
    }
    return false;
}

//=================
// Combat Strategy
// Try to use cover
//=================

state AggressiveAttack 
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
        GotoState('LOSTTARGET');
    }

    function OnCoverNotValid()
    {
        GotoState('AggressiveAttack', 'NOTVALID');
    }

BEGIN:
    curLabel = '';
	while(true) 
    {
        if( !bot.IsInValidCover() ) 
        {
NOTVALID:
            //log("Not In Valid Cover?");
            bot.Perform_Engaged_TakeCover(); WaitForNotification();
        }
        else if( CoverIsStale() )
        {
            bot.Perform_Engaged_FindNewCover(); WaitForNotification();
            MarkTime(bot.LastTakeCoverTime);
        }
        else
        {
            bot.Perform_AttackFromCover( 1.0f + 1.0f*frand() ); WaitForNotification();
        }   
        
        if( bot.ShouldReload() ){
            bot.StartReload();
			if( !bot.IsInValidCover() ) {
				bot.Perform_Engaged_TakeCover(1.0+Frand()); WaitForNotification();
			}
        }
    }
}


state LostTarget
{
    function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }
    

    function RecoverEnemyFailed()
    {
        GotoState('LostTarget', 'HUNT');
    }

    function HuntFailed()
    {
        GotoState('LostTarget', 'LOST');
    }

BEGIN:
    curLabel = 'RECOVER';
    bot.Perform_Engaged_RecoverEnemy(); WaitForNotification();
    if( bot.EnemyIsVisible() )
        Goto('FOUND');

HUNT:
    curLabel = 'HUNT';
    //Say something like "I'll find him" or "Where could he have gone?"
    bot.Perform_Engaged_HuntEnemy(); WaitForNotification();
    Goto('FOUND');

LOST:
    //TODO wait a bit, then hunt again
    // if multiple attempts fail, What to do? Go back to Idle?
    bot.Perform_Engaged_StandGround(2.0); WaitForNotification();
    //Say Something like "Must have retreated!" and go back to idle
    GotoState('AggressiveAttack');

FOUND:
    bot.Perform_Engaged_StandGround(2.0); WaitForNotification();
    GotoState('AggressiveAttack');
}

//===============
// General CombatStrategy 
// when there's no cover
//===============

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
			bot.Perform_Engaged_StandGround(0.5+Frand()); WaitForNotification();

            if( abs(LastEnemyDist - curDist()) < 100 )
            {
                bot.Perform_Engaged_StrafeMove();  WaitForNotification();
                bot.Perform_Engaged_StandGround(0.5+Frand()); WaitForNotification();
            }
            
            
            if(  curDist() > LastEnemyDist || curDist() > 2500)
            {
                bot.Perform_Engaged_ShortRush();  WaitForNotification();
            }
            else
            {
                bot.Perform_Engaged_Backoff();  WaitForNotification();
            }
            
//            bot.UpdatePawnViewPitch();
        }

        //Try finding cover
        GotoState('AggressiveAttack');
    }

WAITFORPLAYER:
    curLabel = 'WAITFORPLAYER';
    //bot.Perform_Engaged_StandGround(3.0); WaitForNotification();
    
    GotoState('LostTarget');
	
}

defaultproperties
{
}
