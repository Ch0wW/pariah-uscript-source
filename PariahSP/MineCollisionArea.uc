class MineCollisionArea extends Actor;

//collision size set by Mine.uc

var Mine MyMine;

event Touch(Actor Other)
{
	if(Other == None || !( Other.IsA('Pawn') || Other.Physics == PHYS_Havok ) )
		return;

	//log(self@Location$" has been touched by "$Other@Other.Location);
	MyMine.AreaViolated(Other, self);
}


event UnTouch(Actor Other)
{
	if(Other == None || !( Other.IsA('Pawn') || Other.Physics == PHYS_Havok ) )
		return;

	//log(self@Location$" has been UNtouched by "$Other@Other.Location);
	MyMine.AreaUnviolated(Other, self);
}

defaultproperties
{
     bHidden=True
     bCollideActors=True
     bUseCylinderCollision=True
}
