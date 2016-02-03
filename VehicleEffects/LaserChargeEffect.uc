class LaserChargeEffect extends Effects;

const	MaxTime = 2.0;

var bool	Charging;
var float	ChargingTime, ChargingCount;

simulated function Tick(float DeltaTime)
{
	if(Charging)
	{
		if(ChargingCount < ChargingTime)
		{
			ChargingCount += DeltaTime;
			SetDrawScale(ChargingCount/ChargingTime);
		}
		SetRotation(RotRand(true));
	}
}

simulated function Charge()
{
	ChargingTime = MaxTime;
	Charging = true;
	ChargingCount = 0.0;
	//RotationRate = RotRand(true);
}

simulated function DisCharge()
{
	Charging = false;
	SetDrawScale(0);
}

defaultproperties
{
     DrawScale=0.000000
     StaticMesh=StaticMesh'BlowoutGeneralMeshes.Effects.Sphere_Misc'
     Skins(0)=Shader'NoonTextures.VehicleFX.Vehicle_Shield'
     DrawType=DT_StaticMesh
}
