//=============================================================================
//=============================================================================
class DistortionShieldMilShip extends Effects
	placeable;

//
// This is the shield actor for chapter 9
//

var() FinalBlend DisTex;
var float MyCount;

Simulated function PostBeginPlay()
{
	SetSkin(0,DisTex);
}

simulated function OnShield()
{
	bHidden=False;
	SetSkin(0,DisTex);
		ConstantColor(Shader(DisTex.Material).Opacity).Color.A = 255;
	MyCount=1.0;
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	OnShield();
}

function Trigger( actor Other, pawn EventInstigator )
{
	Spawn( class'ShieldBurst');
	Destroy();
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
	}
}

defaultproperties
{
     DisTex=FinalBlend'JS_TrainTextures.Energy.PFinal'
     StaticMesh=StaticMesh'JamesPrefabs.Chapter12.MilShield'
     Tag="DestroyShield"
     DrawType=DT_StaticMesh
     bWorldGeometry=True
     bCollideActors=True
     bProjTarget=True
}
