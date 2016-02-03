class VGAssaultSwitchMessage extends PlayerInfoMessage;

var localized string VGAssaultModeZero;	// normal mode
var localized string VGAssaultModeOne;	// uranium mode
var localized string VGAssaultModeTwo;	// explosive mode
var localized string VGAssaultModeUnknown;

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
	case 0: return Default.VGAssaultModeZero;
	case 1:	return Default.VGAssaultModeOne;
	case 2:	return Default.VGAssaultModeTwo;
	default: return Default.VGAssaultModeUnknown;
	}
}

defaultproperties
{
     VGAssaultModeZero="Normal Bullets"
     VGAssaultModeOne="Uranium Laced Bullets"
     VGAssaultModeTwo="Explosive Bullets"
     VGAssaultModeUnknown="Unknown Bullet Type"
}
