class SPAIRoleShield extends SPAIRole;

var SPAIShield myBot;
var float LastSupressedTime;

function GOTO_Attack()
{
    GotoState('ApproachEnemy');
}

function OnSupressed();

state ApproachEnemy
{
    function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }

    function BeginState() {}

	function OnSupressed() {
        GotoState('Suppressed'); 
	}
BEGIN:
    
APPROACH:
    curLabel = 'APPROACH';
    while (true) 
	{
		if( myBot.IsInMeleeRange() )
		{
			if( TimeElapsed(myBot.LastMeleeTime, 3.0) )
			{
				myBot.Perform_Engaged_MeleeRush(); WaitForNotification();		
			}
			else
			{
				myBot.Perform_Engaged_StandGround(2); WaitForNotification();
			}
		}
		else 
		{
			myBot.Perform_Engaged_SlowAdvance(); WaitForNotification();
		}
    }
}

///////

state Suppressed
{ 
	function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }

    function BeginState() {}
BEGIN:
	while(true)
	{ 
		myBot.Perform_Engaged_CrouchBehindShield(); WaitForNotification();
		if( TimeElapsed(LastSupressedTime, 2.0) )
			GotoState('ApproachEnemy');
	}
}

defaultproperties
{
}
