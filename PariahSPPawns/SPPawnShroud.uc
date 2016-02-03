class SPPawnShroud extends SPPawn
    abstract;

function bool MaySmoke()
{
    return false;
}

defaultproperties
{
     PawnSkill=5
     bMayFallDown=True
     bDropNothingOnDeath=True
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem136
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem136'
}
