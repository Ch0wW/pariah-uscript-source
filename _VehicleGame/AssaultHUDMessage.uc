class AssaultHUDMessage extends LocalMessage;

// Assault Messages
//
// Switch 0: The frontline is at your base!
//
// Switch 1: The frontline is at the enemy's base! 


var localized string FrontlineAtBase;
var localized string FrontlineAtEnemyBase;


var(Message) color RedColor, YellowColor;

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	if(Switch==0)
		return Default.RedColor;
	else
		return Default.YellowColor;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if(Switch == 0)
	    return Default.FrontlineAtBase;
	else if(Switch == 1)
		return Default.FrontlineAtEnemyBase;
    else if(Switch == 2)
    {
        return class'SquadAI'.Default.DefendString;
    }
    else if(Switch == 3)
    {
        return class'SquadAI'.Default.AttackString;
    }    
}

defaultproperties
{
     RedColor=(B=23,G=23,R=166,A=255)
     YellowColor=(G=255,R=255,A=255)
     FrontlineAtBase="The front line has reached your base! Defend your base!"
     FrontlineAtEnemyBase="The front line is at your enemy's base! Press the attack!"
     Lifetime=2.000000
     PosY=0.800000
     DrawColor=(B=255,G=128,R=0)
     DrawPivot=DP_UpperMiddle
     StackMode=SM_Up
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
}
