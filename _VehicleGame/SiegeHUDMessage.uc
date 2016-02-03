class SiegeHUDMessage extends LocalMessage;

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
    {
        return class'SquadAI'.Default.DefendString;
    }
    else if(Switch == 1)
    {
        return class'SquadAI'.Default.AttackString;
    }    
}

defaultproperties
{
     RedColor=(B=23,G=23,R=166,A=255)
     YellowColor=(G=255,R=255,A=255)
     Lifetime=10.000000
     PosX=0.980000
     PosY=0.120000
     DrawColor=(B=255,G=128,R=0)
     DrawPivot=DP_UpperRight
     StackMode=SM_Down
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
}
