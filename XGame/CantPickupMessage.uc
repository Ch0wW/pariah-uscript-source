// mjm - This file is the class which outputs the "you already got the bleh" weapon message if you run over it

class CantPickupMessage extends LocalMessage;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
	return Pickup(OptionalObject).CantPickupMessage;
}

defaultproperties
{
     FontSize=1
     Lifetime=3.000000
     PosX=0.980000
     PosY=0.120000
     DrawColor=(B=255,G=255,R=255)
     DrawPivot=DP_UpperRight
     StackMode=SM_Down
     bFadeMessage=True
}
