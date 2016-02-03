class GroupMover extends Actor
	native
	placeable;


// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)


var() array<SpecialStaticMeshActor> Objects;

var() name GroupTag;

struct native ObjectCollision
{
	var bool bCollideActors;
	var bool bBlockActors;
	var bool bBlockPlayers;
};


var array<Vector> ObjectStartLocations;
var array<ObjectCollision> ObjectStartCollisions;

var() vector ObjectsVelocity;
var() float LoopTime;
var() float RepeatDelay;
var() int LoopCount;
var() bool bStartEnabled;

var bool bDelaying;
var int LoopsRemaining;
var bool bRunning;
var float TimePassed;
var vector CurrentOffset;

//function PostBeginPlay()
//{
//	
//}

simulated event DoInit()
{
	local int i;
	local SpecialStaticMeshActor sm;

//log("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");

	if(GroupTag != '')
	{
		Objects.Length=0;
		foreach AllActors(class'SpecialStaticMeshActor',sm,GroupTag)
		{
			//log("found object "$sm);
			Objects[Objects.Length] = sm;
		}
	}


	for(i=0;i<Objects.Length;i++)
	{
		if ( Objects[i] != None )
		{
			ObjectStartLocations[i] = Objects[i].Location;
			//log(Objects[i]@ObjectStartLocations[i]);
			ObjectStartCollisions[i].bCollideActors = Objects[i].bCollideActors;
			ObjectStartCollisions[i].bBlockActors = Objects[i].bBlockActors;
			ObjectStartCollisions[i].bBlockPlayers = Objects[i].bBlockPlayers;
		}
	}



	if(bStartEnabled)
		StartUp();
	else
		SetHidden(true);

}

simulated function StartUp()
{
	//log("SDFSDFSDFSDFSDFSDFSDFSDFSDF");
	SetHidden(false);
	bRunning = true;
	LoopsRemaining = LoopCount;
	if(RepeatDelay==0.0)
	{
		//log("SETTING TIMAAAAAAAAR");
		SetTimer(LoopTime, True);
	}
	else
	{
		//log("SETTING TIMAAAAAAAAR2");
		
		SetTimer(LoopTime, False);
	}
}

simulated function Finish()
{
	SetHidden(true);
	bRunning=False;
	SetTimer(0.0, False);
}

simulated function SetHidden(bool b)
{
	local int i;
	for(i=0;i<Objects.Length;i++)
	{
		if ( Objects[i] != None )
		{
			Objects[i].bHidden = b;
			if(b)
				Objects[i].SetCollision(false,false,false);
			else
				Objects[i].SetCollision(ObjectStartCollisions[i].bCollideActors, ObjectStartCollisions[i].bBlockActors, ObjectStartCollisions[i].bBlockPlayers);
		}
	}
}

//function Tick(float dt)
//{
//	log("TOOOOOOOOOOOOOOOOOOOOOOCK");
//	if(!bRunning || bDelaying) return;
//	
//
//	log("ticking");
//	TimePassed+=dt;
//
//	CurrentOffset = TimePassed*ObjectsVelocity;
//
//	UpdatePositions();
//}

simulated event UpdatePositions()
{
	local int i;

	//log("RAAAAAAAAAAAAAARGH");

	for(i = 0; i < Objects.Length; i++)
	{
		if(Objects[i] != None)
			Objects[i].SetLocation(ObjectStartLocations[i] + CurrentOffset);
	}

}

simulated event Timer()
{
	local int i;

	//log("TIMAAAAAAAARRRRRR");

	if(bDelaying) //then start up and reset timer
	{
		bDelaying = false;
		SetHidden(false);
		SetTimer(LoopTime, False);
		return;
	}

	for(i = 0; i < Objects.Length; i++)
	{
	    if( Objects[i] != None )
	    {
		    Objects[i].SetLocation(ObjectStartLocations[i]);
		}
	}

	TimePassed = 0;

	CurrentOffset = Vect(0,0,0);

	if(LoopsRemaining != 0) //count down and disable
	{
		LoopsRemaining--;

		if(LoopsRemaining == 0)
		{
			Finish();
		}
		else if(RepeatDelay > 0.0)
		{
			SetHidden(True);
			bDelaying=True;
			SetTimer(RepeatDelay, False);
		}
	}
}


function Trigger(Actor Other, Pawn EventInstigator)
{
	if(!bRunning)
		StartUp();
}

defaultproperties
{
     bStartEnabled=True
     RemoteRole=ROLE_None
     bNoDelete=True
}
