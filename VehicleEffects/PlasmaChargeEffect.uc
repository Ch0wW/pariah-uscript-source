class PlasmaChargeEffect extends Effects;

simulated function SetChargeScale(float power)
{
    local Vector Scale3d;
    Scale3d.Z = 0.9;
	Scale3d.Y = 1.0;
	Scale3d.X = power * 0.8;
	SetDrawScale3D(Scale3d);
	bHidden = (power == 0.0);
}

defaultproperties
{
     StaticMesh=StaticMesh'PariahWeaponMeshes.Plasma.EnergyBox'
     DrawScale3D=(X=0.050000)
     DrawType=DT_StaticMesh
     bHidden=True
     bNetTemporary=False
     bAlwaysRelevant=True
}
