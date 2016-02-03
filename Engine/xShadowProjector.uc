class xShadowProjector extends xDynamicProjector;

function Tick(float dt)
{
	local Rotator	rot;

	rot = Rotation;
	rot.roll = 0;

	SetRotation(rot);
	Super.Tick(dt);
}

defaultproperties
{
     MaxTraceDistance=500
     bProjectActor=False
     bClipBSP=True
     bProjectOnUnlit=True
     bGradient=True
     bProjectOnAlpha=True
     bProjectOnParallelBSP=True
     Physics=PHYS_Rotating
     bStatic=False
}
