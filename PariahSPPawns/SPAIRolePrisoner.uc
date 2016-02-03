class SPAIRolePrisoner extends SPAIRole;

var SPAIPrisoner myBot;

function GOTO_Attack()
{
    GotoState('UnarmedAttack');
}



function OnTakingDamage(Pawn Other, float Damage)
{
	if(myBot.Enemy != None)
		GotoState('FuckOff');
}



state FuckOff
{
    function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }
    
    function BeginState(){}


	function OnLostSight()
	{
		GOTO_Relax();
	}
BEGIN:
    while(true)
	{
		myBot.Perform_Engaged_BackOff(); WaitForNotification();
		GOTO_Relax();
    }
}




state UnarmedAttack 
{
    function SelectBehaviour() {}
    function PerformBehaviour() { Notify(); }
    
    function BeginState(){}


	function OnLostSight()
	{
		GOTO_Relax();
	}
BEGIN:
    while(true)
	{
		myBot.Perform_Engaged_Melee(); WaitForNotification();

    }

}

defaultproperties
{
}
