class SPAIRoleFlameThrower extends SPAIRole;

function GOTO_Attack()
{
    GotoState('ApproachEnemy');
}


state ApproachEnemy
{
    function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }

    function BeginState() {}

    function OnLostSight() {
        if( curLabel != 'HUNT')
            GotoState('ApproachEnemy', 'SUPRESS');
    }

BEGIN:

STANDGROUND:
    curLabel = 'STANDGROUND';
    while (true) {
        bot.StartFireWeapon();
        bot.Perform_Engaged_StandGround(2.5+frand()); WaitForNotification();
        if( ! SPAIFlameThrower(bot).inFlameRange() ) {
            Goto('HUNT');
        }
    }

SUPRESS:
    bot.Perform_Engaged_SupressionFire(); WaitForNotification();
    if( bot.EnemyIsVisible() ) {
        Goto('StandGround');
    }
    else {
        Goto('HUNT');
    }
    
HUNT:
    curLabel = 'HUNT';

    bot.Perform_Engaged_HuntEnemy();  WaitForNotification();
    if( bot.EnemyIsVisible() ) {
        Goto('StandGround');
    }
    else
    {
        Goto('HUNT');
    }
}

defaultproperties
{
}
