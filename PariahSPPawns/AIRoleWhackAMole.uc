class AIRoleWhackAMole extends SPAIRole;

var SPAIPopUp myBot;
var float LastSupressedTime;

function GOTO_Relax()
{
    SetTimer(0,false);
    GotoState('Relax');
}

/**
 * For now, rely on subclasses to choose attack state.
 **/
function GOTO_Attack()
{
    GotoState('WhackAMole'); 
}



state Relax
{
    function GOTO_Relax() {} //Only ask for "Idle" order once.

    function BeginState() {}

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
    while(true) {
        bot.Perform_NotEngaged_AtRest();    WaitForNotification();
    }
}

/////////////////////////////
function OnSupressed();

function Timer()
{
    CheckSupression();
}

function CheckSupression()
{
    local PlayerController p;
    local vector MissVector;
    local float dotPAbs, dotPCur;

    p = Level.GetLocalPlayerController();
    if(p.pawn == None)
        return;

    MissVector = (vect(0,0,1) cross (bot.pawn.Location - p.Pawn.Location) );
    MissVector = bot.Pawn.Location + Normal(MissVector) * bot.Pawn.CollisionRadius*2 ;
    
    dotPAbs = Normal(MissVector - p.Pawn.location )dot Normal(bot.pawn.location - p.Pawn.location);
    dotPCur = vector(p.Pawn.Rotation) dot Normal(bot.pawn.location - p.Pawn.location);

    if( (dotPCur >= dotPAbs) && p.bFire != 0 )
    {
        if( TimeElapsed(LastSupressedTime, 2.0) )
            OnSupressed();
        markTime(LastSupressedTime);
    }
}

////////////////////////

state WhackAMole
{
    function BeginState() {}

    function SelectBehaviour() {
    }

    function PerformBehaviour() {
        Notify();
    }

	function OnMustReload() {
	    if( bot.someOneProvidesCover() && FRand() < 0.5)
        {
            if( bot.currentStage.PositionProvidesCoverFromEnemy( bot.claimedPosition, bot.Enemy) > 1.0 )
                bot.pawn.bWantsToCrouch = true;
            bot.StartReload();
        } 
	}

    function OnSupressed() {
		 if( bot.currentStage.PositionProvidesCoverFromEnemy( bot.claimedPosition, bot.Enemy) > 1.0 )
             bot.GotoState('Engaged_AttackFromCover', 'TAKECOVER'); 
	}


BEGIN:
    SetTimer(0.01, true);
    while(true)
    {
        curLabel = 'StandGround';
		bot.StartFireWeapon();
        bot.Perform_AttackFromCover( 2 + Rand(4));   WaitForNotification();
    }
}

defaultproperties
{
}
