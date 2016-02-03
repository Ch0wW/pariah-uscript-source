class VGRocketSwitchMessage extends PlayerInfoMessage;

var localized string RocketModeZero;	// normal/napalm rocket
var localized string RocketModeOne;		// seeking rocket
var localized string RocketModeTwo;		// MERV rocket
var localized string RocketModeUnknown;

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.YellowColor;
}


static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	switch(Switch)
	{
	case 0: return Default.RocketModeZero;
	case 1:	return Default.RocketModeOne;
	case 2:	return Default.RocketModeTwo;
	default: return Default.RocketModeUnknown;
	}
}

defaultproperties
{
     RocketModeZero="Napalm Selected"
     RocketModeOne="Seeking Rockets Selected"
     RocketModeTwo="MERV Rockets Selected"
     RocketModeUnknown="Unknown Rocket Type"
}
