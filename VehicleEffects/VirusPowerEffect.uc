class VirusPowerEffect extends Effects;

//const	MaxTime = 2.0;

var bool	Charging;
var float	ChargingTime, ChargingCount;

var float   fMaxChargeTime;	// maximum effective charge time
var float   fChargePower;	// current charge power in the range [0,1]
var float	chargeScale;
var bool    bSelfDestruct;	// destroy self after fully charged

replication
{
	reliable if(Role == ROLE_Authority)
		Charging, bSelfDestruct;
}

simulated function Tick(float DeltaTime)
{
	if(Charging)
	{
		ChargingCount += DeltaTime;
		if(ChargingCount >= fMaxChargeTime && bSelfDestruct) {

			Destroy();
			return;
		}

		if(ChargingCount > ChargingTime)
			ChargingCount = ChargingTime;

		fChargePower = ChargingCount/ChargingTime;
		SetDrawScale(fChargePower*chargeScale);
		SetRotation(RotRand(true));
	}
}

simulated function Charge()
{
	ChargingTime = fMaxChargeTime;
	Charging = true;
	ChargingCount = 0.0;
	bHidden = false;
}

simulated function DisCharge()
{
	Charging = false;
	SetDrawScale(0);
	bHidden = true;
}

defaultproperties
{
     chargeScale=0.250000
     DrawScale=0.000000
     StaticMesh=StaticMesh'StocktonBossPrefabs.AssassinShockwave.ShockwaveSphere'
     AmbientSound=Sound'BossFightSounds.Stockton.StocktonShieldCharge'
     DrawType=DT_StaticMesh
     RemoteRole=ROLE_SimulatedProxy
     bHidden=True
     bNetTemporary=False
     bAlwaysRelevant=True
     bUpdateSimulatedPosition=True
     bCollideActors=True
     bCollideWorld=True
}
