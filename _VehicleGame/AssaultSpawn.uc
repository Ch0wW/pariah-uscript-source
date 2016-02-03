class AssaultSpawn extends xDomPoint
	placeable;

var Array<PlayerStart> PlayerStarts;
var Array<DumbTurret> Turrets;

var Array<VehicleStart> VehicleStarts;



var() int OrderIndex;
var int BaseTeamIndex;
var bool bIsBase;
var bool bIsNeutral;
//var float CaptureTime;
var() float RevertTime;

var float CaptureMeter;
var() float CaptureScale; 

var() Name RedCapturedEvent, BlueCapturedEvent, NeutralEvent, RedTaggedEvent, BlueTaggedEvent, ResetEvent;

enum EASEvent
{
	AS_RedCaptured,
	AS_RedTagged,
	AS_Neutral,
	AS_Reset,
	AS_BlueTagged,
	AS_BlueCaptured
	
};



var PlayerReplicationInfo CapturePRI;
var TeamInfo CaptureTeam;
var Pawn CapturePawn;


function ResetAssaultPoint(optional bool bDoVehicleStarts)
{
	CaptureMeter = 0.5;
	EnableSpawn(false, 255);
	GotoState('');
	if(bDoVehicleStarts)
		EnableVehicleStarts(false);

}

function EnableVehicleStarts(bool bEnable)
{
	local int i;

	for(i=0;i<VehicleStarts.Length;i++)
	{
		if(bEnable)
		{
			VehicleStarts[i].EnableSpawn(None,True);
		}
		else
		{
			VehicleStarts[i].DisableSpawn();
		}
	}
}

function InheretVehicleSpawns(AssaultSpawn other)
{
	local int i,j;
	local VGVehicle save;

	if(other.VehicleStarts.Length != VehicleStarts.Length)
	{
		log("VehicleStarts mismatch between:"@self@"->"@other);
	}

	for(i=0;i<VehicleStarts.Length;i++)
	{
		for(j=0;j<other.VehicleStarts.Length;j++)
		{
			if(other.VehicleStarts[j].bSpawnEnabled && VehicleStarts[i].IsSameAs(other.VehicleStarts[j]))
			{
				save = other.VehicleStarts[j].DisableSpawn();

				VehicleStarts[i].EnableSpawn(save);

				break;
			}
		}
	}

	for(i=0;i<VehicleStarts.Length;i++)
	{
		assert(VehicleStarts[i].bSpawnEnabled);
	}

	for(i=0;i<other.VehicleStarts.Length;i++)
	{
		assert(!other.VehicleStarts[i].bSpawnEnabled);
	}

}



function CallEvent(EASEvent theEvent)
{
	local Actor A;
	local Name EventName;
	
	//log("Self got event "$theEvent);

	switch(theEvent)
	{
	case AS_RedCaptured:
		EventName = RedCapturedEvent;
		break;
	case AS_BlueCaptured:
		EventName = BlueCapturedEvent;
		break;
	case AS_Neutral:
		EventName = NeutralEvent;
		break;
	case AS_Reset:
		EventName = ResetEvent;
		break;
	case AS_RedTagged:
		EventName = RedTaggedEvent;
		break;
	case AS_BlueTagged:
		EventName = BlueTaggedEvent;
		break;
	}
	
	// send the event to trigger related actors
    if(EventName != '')
		foreach AllActors(class'Actor', A, EventName)
			A.Trigger(self, CapturePawn);
}


function PlayAlarm()
{

}

function listspawninfo()
{
	local int i;
	for(i=0;i<PlayerStarts.length;i++)
	{
		log(PlayerStarts[i].Name$" Enabled:"$PlayerStarts[i].bEnabled$" Team:"$PlayerStarts[i].TeamNumber);
	}
	for(i=0;i<VehicleStarts.length;i++)
	{
		VehicleStarts[i].PrintInfo();
	
	}
}

function EnableSpawn(bool enable, byte team)
{
	local int i;

	for(i=0;i<PlayerStarts.Length;i++)
	{
		PlayerStarts[i].bEnabled=enable;
		PlayerStarts[i].TeamNumber=team;

	}

}

function SetTurrets(byte team)
{
	local int attackteam,i;

	if(team==0)
		attackteam=1;
	else if(team==1)
		attackteam=0;
	else
		attackteam=-1;
	for(i=0;i<Turrets.Length;i++)
	{
		//log(Turrets[i].Name@"set to attack team"@attackteam);
		Turrets[i].TargetTeam=attackteam;
		Turrets[i].Target=None;
	}

}

function Touch(Actor Other)
{
	
	if ( Pawn(Other) == None || Pawn(Other).Health <= 0)
		return;	

	if((DefenderTeamIndex==255 && !bIsBase) || (bIsBase && bIsNeutral && BaseTeamIndex==Pawn(Other).PlayerReplicationInfo.Team.TeamIndex))
	{
		Tag(Pawn(Other).PlayerReplicationInfo, Pawn(Other).PlayerReplicationInfo.Team.TeamIndex, Pawn(Other));

		//SetTimer(CaptureTime, false);
		
	}


}

state TaggedBlue
{
	function BeginState()
	{
		Flash(1);
		Level.Game.GameReplicationInfo.GameObjStates[0] = GOS_HeldBlue;
	}

	function Tick(float dt)
	{
		CaptureMeter += dt/CaptureScale;
		if(CaptureMeter >= 1.0)
		{
			Capture(CapturePRI, CaptureTeam);
			CapturePRI=None;
			CaptureTeam=None;
			GotoState('');
			return;
		}
		AssaultReplicationInfo(Level.Game.GameReplicationInfo).AssaultBar = CaptureMeter*255.0;

	}	

}

state TaggedRed
{
	function BeginState()
	{
		Flash(0);
		Level.Game.GameReplicationInfo.GameObjStates[0] = GOS_HeldRed;
		
	}

	function Tick(float dt)
	{
		CaptureMeter -= dt/CaptureScale;
		if(CaptureMeter <= 0.0)
		{
			Capture(CapturePRI, CaptureTeam);
			CapturePRI=None;
			CaptureTeam=None;
			GotoState('');
			return;
		}
		AssaultReplicationInfo(Level.Game.GameReplicationInfo).AssaultBar = CaptureMeter*255.0;

	}	

}


function Tag(PlayerReplicationInfo PRI, int team, Pawn tagger)
{
	CapturePRI=PRI;
	CaptureTeam = PRI.Team;
	CapturePawn=tagger;
	if(team == 1)
	{
		GotoState('TaggedBlue');
		
	}
	else
	{
		GotoState('TaggedRed');	
	}
	TeamGame(Level.Game).FindNewObjectives(self);
}

function Flash(int team)
{
	//log("flash "$team);

	if(team == 1)
	{
		CallEvent(AS_BlueTagged);
		if (DomLetter != None)
		{
			DomLetter.SetSkin(0, class'xDomLetter'.Default.BlueTouchedShader);
			DomLetter.NewShader = class'xDomLetter'.Default.BlueTouchedShader;
		}
		if (DomRing != None)
		{
			DomRing.SetSkin(0, class'xDomRing'.Default.BlueTouchedShader);
			DomRing.NewShader = class'xDomRing'.Default.BlueTouchedShader;
		}
	}
	else
	{
		CallEvent(AS_RedTagged);
		if (DomLetter != None)
		{
			DomLetter.SetSkin(0, class'xDomLetter'.Default.RedTouchedShader);
			DomLetter.NewShader = class'xDomLetter'.Default.RedTouchedShader;
		}
		if (DomRing != None)
		{
			DomRing.SetSkin(0, class'xDomRing'.Default.RedTouchedShader);
			DomRing.NewShader = class'xDomRing'.Default.RedTouchedShader;
		}
	}

}



state AutoCapture //state for making a point automatically revert after a certain time
{
	function BeginState()
	{
		Flash(int(OrderIndex!=0));
		
		CaptureMeter=0.5;
		BroadcastLocalizedMessage( class'AssaultMessage',5,None,None,self);
		SetTimer(RevertTime,False);
	}
	function Touch(Actor Other)
	{}

	function Tick(float dt)
	{
		if(OrderIndex != 0)
		{
			CaptureMeter+= dt/(RevertTime*2.0);
		}
		else
		{
			CaptureMeter-= dt/(RevertTime*2.0);
		}
		AssaultReplicationInfo(Level.Game.GameReplicationInfo).AssaultBar = CaptureMeter*255.0;
	}

	function EndState()
	{
		SetTimer(0,False);
	
	}
	function Timer()
	{
		if(OrderIndex == 0)
			Capture(None, Level.Game.GameReplicationInfo.Teams[0]);
		else
			Capture(None, Level.Game.GameReplicationInfo.Teams[1]);
		GotoState('');
	}

}



function UnTouch(Actor Other)
{

}

//function UpdateStatus()
//{
//
//}

 function UpdateAIStatus(TeamInfo NewTeam)
 {
 	local int OldIndex;
     
 	// for AI, update DefenderTeamIndex
     OldIndex = DefenderTeamIndex;
 	if ( NewTeam == None )
 	    DefenderTeamIndex = 255; // ie. "no team" since 0 is a valid team
 	else
 		DefenderTeamIndex = NewTeam.TeamIndex;
     
 	//We'll do this stuff in the Assault Game after a new Frontline is defined.
     //if ( bControllable && (OldIndex != DefenderTeamIndex) )
 	//	TeamGame(Level.Game).FindNewObjectives(self);
 
 }
 

simulated function SetShaderStatus( Material mat1, Material mat2, Material mat3 )
{}

function Capture(PlayerReplicationInfo Capturer, TeamInfo CaptureTeam)
{
	Assault(Level.Game).ScoreFrontline(Capturer, CaptureTeam, self);
	
	if(CaptureTeam.TeamIndex==0)
		CallEvent(AS_RedCaptured);
	else
		CallEvent(AS_BlueCaptured);
//	CapturePRI=None;

}

function Timer()
{}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

    if (Level.NetMode != NM_Client)
    {
        DomLetter = Spawn(class'XGame.xDomA',self,,Location+EffectOffset,Rotation);
        DomRing = Spawn(class'XGame.xDomRing',self,,Location+EffectOffset,Rotation);
    }

    SetShaderStatus(CNeutralState[0],SNeutralState,CNeutralState[1]);
}

defaultproperties
{
     BaseTeamIndex=255
     RevertTime=30.000000
     CaptureScale=90.000000
     PointName="A"
     bSkipTouching=True
     OrderObjectiveName="DEFEND"
}
