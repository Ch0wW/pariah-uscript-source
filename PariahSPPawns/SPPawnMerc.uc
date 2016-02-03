class SPPawnMerc extends SPPawn
    abstract;

function bool MaySmoke()
{
    return false;
}

defaultproperties
{
     PawnSkill=1
     bMayFallDown=True
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem117
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem117'
}
