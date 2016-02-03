class CTFHUDMessage extends LocalMessage;

// CTF Messages
//
// Switch 0: You have the flag message.
//
// Switch 1: Enemy has the flag message.

var(Message) localized string YouHaveFlagString;
var(Message) localized string EnemyHasFlagString;
var(Message) localized string FlagDroppedString;
var(Message) localized string OvertimeString;
var(Message) color RedColor, YellowColor;

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	if (Switch == 0)
		return Default.YellowColor;
	else
		return Default.RedColor;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (Switch == 0)
	    return Default.YouHaveFlagString;
    else if (Switch == 1)
	    return Default.EnemyHasFlagString;
    else if (Switch == 2)
	    return Default.FlagDroppedString;
    else if (Switch == 3)
	    return Default.OvertimeString;
}

defaultproperties
{
     RedColor=(B=23,G=23,R=166,A=255)
     YellowColor=(G=255,R=255,A=255)
     YouHaveFlagString="You have the flag, return to base!"
     EnemyHasFlagString="The enemy has your flag, recover it!"
     FlagDroppedString="Your flag is down, recover it!"
     OvertimeString="Sudden Death Overtime!!!"
     Lifetime=1.400000
     PosY=0.800000
     DrawColor=(B=255,G=200,R=0)
     DrawPivot=DP_UpperMiddle
     StackMode=SM_Up
     bIsUnique=True
     bIsPartiallyUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
}
