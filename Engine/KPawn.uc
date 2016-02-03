class KPawn extends Pawn
	abstract
	native;

defaultproperties
{
     LandMovementState="PlayerDriving"
     WaterMovementState="PlayerDriving"
     ControllerClass=None
     bCanJump=False
     bCanWalk=False
     Physics=PHYS_Karma
     DrawType=DT_StaticMesh
     bOwnerNoSee=False
     bBlockKarma=True
     bEdShouldSnap=True
}
