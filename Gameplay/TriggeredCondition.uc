class TriggeredCondition extends Triggers;


#exec Texture Import File=Textures\ifcondition.pcx Name=IfIcon Mips=Off MASKED=1

var()	bool	bToggled;
var()	bool	bEnabled;
var()	bool	bTriggerControlled;	// false if untriggered
var		bool	bInitialValue;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bInitialValue = bEnabled;
}

function Trigger( actor Other, pawn EventInstigator )
{
	if ( bToggled )
		bEnabled = !bEnabled;
	else
		bEnabled = !bInitialValue;
}

function Untrigger( actor Other, pawn EventInstigator )
{
	if ( bTriggerControlled )
		bEnabled = bInitialValue;
}

defaultproperties
{
     Texture=Texture'Gameplay.IfIcon'
}
