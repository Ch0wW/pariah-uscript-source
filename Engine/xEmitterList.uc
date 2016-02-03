//=============================================================================
class xEmitterList extends Effects;

#exec Texture Import File=Textures\S_Emitter.pcx  Name=S_Emitter Mips=Off MASKED=1

const	MaxxEmitters = 10;
const	LowDetailDistance = 8000;

var		array<xEmitter>	xEmitters;
var	()	class<xEmitter>	xEmitterClasses[MaxxEmitters];
var ()	class<xEmitter> xEmitterClassesLow[MaxxEmitters];
var	()	Sound			SoundEffect;
/*
simulated function PostBeginPlay()
{
	local int i;

	i = 0;
	while(xEmitterClasses[i] != none)
	{
		AddxEmitter(xEmitterClasses[i]);
		i++;
	}
	log("XJ: xEmitterList PostBeginPlay");
*/
	/*
	local int i;
	local controller C;
	local float	dist;
	local vector dir;

	i = 0;
	dist = 0;
	//check distance to camera, if far use low emitters
	for(C=Level.ControllerList;C!=None;C=C.NextController )
	{
		if(C.bIsPlayer && (C.Role == ROLE_Authority))
		{
			dir = C.Location - Location;
			dist = VSize(dir);
		}
	}
	if(dist < LowDetailDistance) // near
	{
		while(xEmitterClasses[i] != none)
		{
			AddxEmitter(xEmitterClasses[i]);
			i++;
		}
	}
	else // far
	{
		while(xEmitterClassesLow[i] != none)
		{
			AddxEmitter(xEmitterClassesLow[i]);
			i++;
		}
	}
	*/
//}

simulated function AddxEmitter(class<xEmitter> emitter)
{
	xEmitters[xEmitters.Length] = spawn(emitter,owner,,Location,Rotation);
	SetBase(self);
}

simulated function StopRegen()
{
	local int i;
	for(i=0;i<xEmitters.Length;i++)
	{
		if(xEmitters[i] != none)
			xEmitters[i].mRegen = false;
	}
}

simulated function PauseRegen()
{
	local int i;
	for(i=0;i<xEmitters.Length;i++)
	{
		if(xEmitters[i] != none)
			xEmitters[i].mRegenPause = true;
	}
}

simulated function ResumeRegen()
{
	local int i;
	for(i=0;i<xEmitters.Length;i++)
	{
		if(xEmitters[i] != none)
			xEmitters[i].mRegenPause = false;
	}
}

simulated function tick(float deltaTime)
{
	local int i, count;
	count = 0;
	for(i=0;i<xEmitters.Length;i++)
	{
		if(	xEmitters[i] != none
			&&	xEmitters[i].bDeleteMe == 0)
			//&&	!xEmitters[i].mRegen 
			//&&	xEmitters[i].mNumActivePcl == 0
			//&&	xEmitters[i].mStartParticles == 0 )
			count++;
	}
	if(count == 0)
		Destroy();
}

function Trigger( Actor Other, Pawn EventInstigator )
{
	local int i;
	for( i=0; i<xEmitters.Length; i++ )
	{
		if( xEmitters[i] != None && xEmitters[i].bDeleteMe == 0)
			xEmitters[i].mRegenPause = !xEmitters[i].mRegenPause;
	}
}

simulated function Destroyed()
{
	local int i;

	for(i=0;i<xEmitters.Length;i++)
		if(	xEmitters[i] != None && xEmitters[i].bDeleteMe == 0)
			xEmitters[i].Destroy();
	Super.Destroyed();
}

simulated function PlaySoundEffect()
{
	if(SoundEffect != none)
		PlaySound(SoundEffect);
}

// This is messed, the PostBeginPlay function doesn't simulate if
// Level.NetMode... is in the function or a function called from it.
Auto State StartUp
{
	simulated function Tick(float DeltaTime)
	{
		local int i;
		
		i = 0;
		if ( Level.NetMode != NM_DedicatedServer )
        {
			while(xEmitterClasses[i] != none)
			{
				AddxEmitter(xEmitterClasses[i]);
				i++;
			}
			PlaySoundEffect();
		}
		GotoState('');
	}
}

/*
	Texture=S_Emitter
	bHiddenEd=false
	bDirectional=true

	// inherited vars
    DrawType=DT_Sprite
    Style=STY_Normal
	Physics=PHYS_None
	bUnlit=true
	bNetTemporary=true
	bGameRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	//RemoteRole=ROLE_None
	CollisionRadius=+0.00000
	CollisionHeight=+0.00000
    bCollideActors=false
    bAcceptsProjectors=true
	bActorShadows=false
	LifeSpan=5.0
	//bUseLightingFromBase=true
*/

defaultproperties
{
     DrawType=DT_None
     RemoteRole=ROLE_SimulatedProxy
     AmbientGlow=255
}
