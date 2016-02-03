//=============================================================================
//=============================================================================
class DistortionShieldB extends Effects
	placeable;

var float DSize;
var bool bDecSize;

//
// This is the shield actor for Chapter 12.
//

simulated function PostBeginPlay()
{

	Super.PostBeginPlay();
	DSize = 1.0;
	SetTimer(0.8,False);
	bDecSize=False;
}


simulated function Timer()
{
	bDecSize=True;
}


simulated function Tick(float DeltaTime)
{
	if(bDecSize)
	{
		DSize-=DeltaTime;
		if (DSize<0.1) Destroy();
	}
}

defaultproperties
{
     StaticMesh=StaticMesh'JamesPrefabs.Chapter12.DistortionShellBMesh'
     DrawType=DT_StaticMesh
}
