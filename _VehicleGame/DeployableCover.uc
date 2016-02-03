class DeployableCover extends GameplayDevices
	placeable;

var StaticMesh PartMeshes[3];

var DeployableCoverPart Parts[3];

var int StartPitch;

var Name PartPointNames[3];
var Vector PartPoints[3];

var float RotateTime, RotateStartTime, ExtendTime, ExtendStartTime;

var int DamageLevelHealth;
var int AccumulatedDamage;

var int PartCount;
 
function PostBeginPlay()
{
	local int i;
	local Rotator r,garbage;

	for(i=0;i<3;i++)
	{
		assert(GetAttachPoint(PartPointNames[i], PartPoints[i], garbage));
	}

	r.roll=StartPitch;

	for(i = 0; i < 3; i++)
	{
		Parts[i] = spawn(class'DeployableCoverPart', self,, Location + (PartPoints[0]>>Rotation), Rotation+r);
		Parts[i].InitCover(self, i);
	}


}

event Trigger( Actor Other, Pawn EventInstigator )
{
	GotoState('OpenRotate');
}


state OpenRotate
{
	ignores Trigger;
	function BeginState()
	{
		SetTimer(RotateTime, false);
		RotateStartTime = Level.TimeSeconds;
	}

	function Tick(float dt)
	{
		local float alpha;
		local Rotator r;

		alpha = 1.0 - ((Level.TimeSeconds - RotateStartTime) / RotateTime);

		r.roll = alpha * StartPitch;

		Parts[0].SetRotation(Rotation + r);
		Parts[1].SetRotation(Rotation + r);
		Parts[2].SetRotation(Rotation + r);
	}

	function Timer()
	{
		GotoState('OpenExtend');
	}

	function EndState()
	{
		Parts[0].SetRotation(Rotation);
		Parts[1].SetRotation(Rotation);
		Parts[2].SetRotation(Rotation);
	}


}

state OpenExtend
{
	ignores Trigger;
	function BeginState()
	{
		SetTimer(ExtendTime, false);
		ExtendStartTime = Level.TimeSeconds;
	}

	function Tick(float dt)
	{
		local float alpha;
		local Vector v;
		local int i;

		alpha = ((Level.TimeSeconds - ExtendStartTime) / ExtendTime);

		for(i=1;i<3;i++)
		{
			v = alpha * ((PartPoints[i] - PartPoints[0]));
			Parts[i].SetLocation(Location + ((PartPoints[0] + v)>>Rotation));
		}

	}

	function Timer()
	{
		GotoState('Deployed');
	}

	function EndState()
	{
		local int i;

		for(i=1;i<3;i++)
		{
			Parts[i].SetLocation(Location + ((PartPoints[i])>>Rotation));
		}
		for(i=0;i<3;i++)
		{
			Parts[i].bMovable=false;
			Parts[i].GotoState('Deployed');
		}
	}

}

state Deployed
{
	function Trigger( Actor Other, Pawn EventInstigator )
	{
		if(PartCount == 3) //untouched, allow close
		{
			GotoState('CloseExtend');
		}
	}

	function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
		AccumulatedDamage+=Damage;

		while (AccumulatedDamage >= DamageLevelHealth && PartCount > 0)
		{
			Parts[PartCount-1].SetDetachParams(HitLocation, Momentum, DamageType);
			Parts[PartCount-1].GotoState('Detached');
			AccumulatedDamage -= DamageLevelHealth;
			PartCount--;
		}

		if(PartCount==0)
			GotoState('Crapcakes');			
		
	}
}


state Crapcakes
{
	ignores Trigger;
}


state CloseRotate
{
	ignores Trigger;
	function BeginState()
	{
		SetTimer(RotateTime, false);
		RotateStartTime = Level.TimeSeconds;
	}

	function Tick(float dt)
	{
		local float alpha;
		local Rotator r;

		alpha = ((Level.TimeSeconds - RotateStartTime) / RotateTime);

		r.roll = alpha * StartPitch;

		Parts[0].SetRotation(Rotation + r);
		Parts[1].SetRotation(Rotation + r);
		Parts[2].SetRotation(Rotation + r);
	}

	function Timer()
	{
		GotoState('');
	}

	function EndState()
	{
		local Rotator r;

		r.Roll = startpitch;
		Parts[0].SetRotation(Rotation + r);
		Parts[1].SetRotation(Rotation + r);
		Parts[2].SetRotation(Rotation + r);
	}


}

state CloseExtend
{
	ignores Trigger;
	function BeginState()
	{
		local int i;

		SetTimer(ExtendTime, false);
		ExtendStartTime = Level.TimeSeconds;

		for(i=0;i<3;i++)
		{
			Parts[i].bMovable=true;
			Parts[i].GotoState('');
		}
	}

	function Tick(float dt)
	{
		local float alpha;
		local Vector v;
		local int i;

		alpha = 1.0 - ((Level.TimeSeconds - ExtendStartTime) / ExtendTime);

		for(i=1;i<3;i++)
		{
			v = alpha * ((PartPoints[i] - PartPoints[0]));
			Parts[i].SetLocation(Location + ((PartPoints[0] + v)>>Rotation));
		}

	}

	function Timer()
	{
		GotoState('CloseRotate');
	}

	function EndState()
	{
		local int i;

		for(i=1;i<3;i++)
		{
			Parts[i].SetLocation(Location + ((PartPoints[0])>>Rotation));
		}
	}

}

defaultproperties
{
     StartPitch=16384
     DamageLevelHealth=140
     PartCount=3
     RotateTime=0.500000
     ExtendTime=0.500000
     PartMeshes(0)=StaticMesh'NoonMeshes.DestroyCover.DestroyCover_piece1'
     PartMeshes(1)=StaticMesh'NoonMeshes.DestroyCover.DestroyCover_piece2'
     PartMeshes(2)=StaticMesh'NoonMeshes.DestroyCover.DestroyCover_piece3'
     PartPointNames(0)="Piece1_base"
     PartPointNames(1)="Piece2_base"
     PartPointNames(2)="Piece3_base"
     StaticMesh=StaticMesh'NoonMeshes.DestroyCover.DestroyCover_base'
     DrawType=DT_StaticMesh
     SurfaceType=EST_Metal
     bMovable=False
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bBlockKarma=True
}
