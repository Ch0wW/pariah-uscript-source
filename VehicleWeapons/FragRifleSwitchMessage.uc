class FragRifleSwitchMessage extends PlayerInfoMessage;

var localized string FRModeZero;	// normal
var localized string FRModeOne;		// bean bag
var localized string FRModeTwo;		// ember shards
var localized string FRModeThree;	// ice shards
var localized string FRModeUnknown;

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
	case 0: return Default.FRModeZero;
	case 1:	return Default.FRModeOne;
	case 2:	return Default.FRModeTwo;
	case 3:	return Default.FRModeThree;
	default: return Default.FRModeUnknown;
	}
}

defaultproperties
{
     FRModeZero="Frag Bullets Selected"
     FRModeOne="Bean Bag Shot Selected"
     FRModeTwo="Ember Shards Selected"
     FRModeThree="Ice Shards Selected"
     FRModeUnknown="Unknown Rifle Shot Type"
}
