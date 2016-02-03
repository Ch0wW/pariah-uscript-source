class SPAIRoleScavenger extends SPAIRoleDefensive;

state Relax
{
    function GOTO_Relax() {} //Only ask for "Idle" order once.

    function BeginState() {
        
        bot.Pawn.WalkAnims[0] = 'Walk_Search';
        
    }

    function EndState()
    {
        bot.Pawn.WalkAnims[0] = bot.Pawn.default.WalkAnims[0];
    }

    function SelectBehaviour()
    {
        if( bot.Enemy != None )
            GOTO_Attack();
    }

    function PerformBehaviour()
    {
        Notify();
    }

	function OnEnemyAcquired()
	{
       GOTO_Attack();
	}

BEGIN: 
    curLabel = '';
    bot.Perform_NotEngaged_Wander();    WaitForNotification();
    while(true) {
RELAX:

        bot.Perform_NotEngaged_AtRest(5.0);    WaitForNotification();
WANDER:
        bot.Perform_NotEngaged_Wander();    WaitForNotification();
    
        SPAIController(bot).Perform_NotEngaged_FindTossAway();    WaitForNotification();
    }
}

defaultproperties
{
}
