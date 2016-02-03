//=============================================================================
//=============================================================================
class DistortionShieldDecay extends Effects
	placeable;

//
// This is the shield actor for chapter 9
//

var() FinalBlend DisTex;
var float MyCount,BSize;
var bool bBlowShield;
var Sound ImpASound, ImpBSound, ImpCSound, ShieldSound;
var Pawn Inst;

Simulated function PostBeginPlay()
{
	bBlowShield=False;
	SetSkin(0,DisTex);
}

simulated function OnShield(Pawn EventInstigator)
{

	if (!bBlowShield)
	{
		bHidden=False;
		MyCount=1.0;
		ConstantColor(Shader(DisTex.Material).Opacity).Color.A = 255;
	}
}

simulated function Blow(Pawn EventInstigator)
{
	if (!bBlowShield)
	{
		EventInstigator.PlayOwnedSound(ShieldSound, SLOT_Interact, 1.0,,,, false);
		Spawn( class'ShieldBurst');
		bBlowShield=True;
		MyCount=0.6;
		BSize=1.0;
	}
}

simulated function Tick(float DeltaTime)
{
	if(!bHidden)
	{
		MyCount-=DeltaTime;
		if (MyCount>0.0)
			ConstantColor(Shader(DisTex.Material).Opacity).Color.A = MyCount*255.0;
		else
			bHidden=True;

		if (bBlowShield)
		{
			BSize+=DeltaTime*DeltaTime*10.0;
			SetDrawScale(BSize);
			if (MyCount<=0.0) Destroy();
		}

	}
}

defaultproperties
{
     DisTex=FinalBlend'JS_TrainTextures.Energy.PFinal'
     ImpASound=Sound'PariahDropShipSounds.Millitary.DropshipShieldShortA'
     ImpBSound=Sound'PariahDropShipSounds.Millitary.DropshipShieldShortB'
     ImpCSound=Sound'PariahDropShipSounds.Millitary.DropshipShieldShortC'
     ShieldSound=Sound'PariahDropShipSounds.Millitary.DropshipShieldImpactA'
     StaticMesh=StaticMesh'JS_TrainPrefabs.DropShipShield'
     DrawType=DT_StaticMesh
}
