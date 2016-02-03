class SPAIRoleKeeperFly extends SPAIRole;

var int tmpCount;

state Relax
{
BEGIN:
    while(true)
    {
        bot.Perform_Engaged_StandGround();
        WaitForNotification();
    }	
}

function GOTO_Attack()
{
    GotoState('KeeperCombat');
}

function bool NoOneIsSwooping()
{
    local int i;

    if( bot.currentStage != None ) {
        for(i=0; i<bot.currentStage.StageAgents.Length; i++)
        {
            if( SPAIKeeperFlyPast(bot) != None && 
                SPAIKeeperFlyPast(bot).isSwooping() )
            {
                return false;
            }
        }
    }
    return true;
}

state KeeperCombat
{
    function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }

    function HuntFailed()
    {
        GotoState('KeeperCombat', 'STAND');
    }
BEGIN:
    while(true)
    {
        if( bot.EnemyIsVisible() )
	    {
            
            for(tmpCount=0; tmpCount<3; tmpCount++)
            {
                if( !bot.EnemyIsVisible() )
                    break;
                SPAIKeeperFlyPast(bot).Perform_Engaged_KeeperMove(); 
                WaitForNotification();
            }
            /*
            if( NoOneIsSwooping() )
            {
                SPAIKeeperFlyPast(bot).Perform_Engaged_Swoop();
                WaitForNotification();
            }
            */
        }
        else
        {
	        bot.Perform_Engaged_HuntEnemy(); 
            WaitForNotification();
        }
    }
STAND:
	bot.Perform_Engaged_StandGround(); 
    WaitForNotification();
    Goto('BEGIN');
}

defaultproperties
{
}
