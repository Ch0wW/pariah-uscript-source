class GrenadeSticky extends GrenadeMag;

var() bool Stuck;

simulated function HookTo(Pawn Other, Vector HitLocation)
{
    local Coords BoneCoords;
    local Name ClosestBone;
    local Vector Offset;
    local float DistToBone;
    
    ClosestBone = Other.GetClosestBone(HitLocation, Normal(Velocity), DistToBone);
    SetOwner(Other);
    if(ClosestBone != 'None' && !Other.IsLocallyControlled())
    {
        SetPhysics(PHYS_None);
        BoneCoords = Other.GetBoneCoords( ClosestBone );
        Offset = Normal(BoneCoords.Origin - Location) * (DistToBone * 0.5);
        Other.AttachToBone(self, ClosestBone);
        SetRelativeLocation(Offset);
        bReplicateMovement = false;
    }
    else
    {
        SetPhysics(PHYS_Trailer);
    }
    Stuck = true;
    Velocity = vect(0,0,0);
    Speed = 0;
    RotationRate.Yaw = 0;
    RotationRate.Pitch = 0;
    RotationRate.Roll = 0;
    DesiredRotation = Rotation;

	if (DebrisTrail != None) 
		DebrisTrail.Kill();
}

simulated function HitWall (vector HitNormal, actor Wall)
{
    if(Stuck)
    {
        return;
    }
    if(Wall.IsA('Pawn'))
    {
        HookTo(Pawn(Wall), Location);
	    bArmed = true;
        if(GLight != None)
            GLight.ArmTimer(explodeTime);
    }
    else
    {
        Super.HitWall(HitNormal, Wall);
    }
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
    if(Stuck)
    {
        return;
    }
    if(Other.IsA('Pawn') && Other != Instigator)
    {
        HookTo(Pawn(Other), HitLocation);
	    bArmed = true;
        if(GLight != None)
            GLight.ArmTimer(explodeTime);
    }
    else
    {
        Super.ProcessTouch(Other, HitLocation);
    }
}

defaultproperties
{
     GrenadeLightType=Class'VehicleEffects.StickyGrenadeLight'
}
