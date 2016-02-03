class xTimerMessage extends CriticalEventPlus;

var() Sound CountDownSounds[10];
var() localized string CountDownTrailer;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject 
    )
{
    return Switch$default.CountDownTrailer;
}

static function ClientReceive( 
    PlayerController P,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
    if (Switch > 0 && Switch < 11)
        P.PlayAnnouncement(default.CountDownSounds[Switch-1],1,true);
}

defaultproperties
{
     CountDownTrailer="..."
     Lifetime=1.000000
     PosX=0.980000
     PosY=0.120000
     DrawColor=(B=0,G=255,R=255)
     DrawPivot=DP_UpperRight
     StackMode=SM_Down
     bBeep=False
}
