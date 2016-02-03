class PickupMessage extends PickupMessagePlus;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject 
	)
{
	return class<Pickup>(OptionalObject).static.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
}

defaultproperties
{
}
