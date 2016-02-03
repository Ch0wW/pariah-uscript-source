class AnimMeshActor extends Actor
	placeable;


var() Name AnimToPlay;

var()  array<Name>  AnimsToPlay;
var int index;
var() float Rate;
var() bool bRandom;
var() bool bLoopAnim;

function PostNetBeginPlay()
{
	if(Rate==0.0) Rate=1.0;

	if(AnimsToPlay.Length > 0)
	{
		index=0;
		if(bRandom)
		{
			PlayAnim(AnimsToPlay[Rand(AnimsToPlay.Length)], Rate);
		}
		else
			PlayAnim(AnimsToPlay[0], Rate);
	}
	else
	{
		if(bLoopAnim)
			LoopAnim(AnimToPlay,Rate);
		else
			PlayAnim(AnimToPlay,Rate);
	}
}

event AnimEnd(int channel)
{
	local int next;
	if(AnimsToPlay.Length > 0)
	{
		if(bRandom)
			next = Rand(AnimsToPlay.Length);
		else
		{
			next = index + 1;
			if(next >= AnimsToPlay.Length)
				next = 0;
		}

		PlayAnim(AnimsToPlay[next], Rate);
		index = next;
	}
}

defaultproperties
{
     DrawType=DT_Mesh
}
