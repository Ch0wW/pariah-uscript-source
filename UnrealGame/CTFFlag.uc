class CTFFlag extends GameObject;

#exec OBJ LOAD File="PariahAnnouncer.uax"

var byte 			TeamNum;
var UnrealTeamInfo 	Team;
var Pawn	 		OldHolder;

var bool bNoGotFlagVoice;

replication
{
	reliable if ( Role == ROLE_Authority )
		Team;
}

// State transitions
function SetHolder(Controller C)
{
	local CTFSquadAI S;
    local PlayerController PC;

	// AI Related
	if ( Bot(C) != None )
		S = CTFSquadAI(Bot(C).Squad);
	else if ( PlayerController(C) != None )
		S = CTFSquadAI(UnrealTeamInfo(C.PlayerReplicationInfo.Team).AI.FindHumanSquad());
	if ( S != None )
		S.EnemyFlagTakenBy(C);

	Super.SetHolder(C);

    if(!bNoGotFlagVoice)
		C.SendMessage(None, 'OTHER', C.GetMessageIndex('GOTENEMYFLAG'), 10, 'TEAM');

    PC = Level.GetLocalPlayerController();
    if (PC != None)
    {
        if (C == PC)
            Level.Game.EvaluateHint('PickedUpFlag', None);
        else if (PC.SameTeamAs(C))
            Level.Game.EvaluateHint('TeammateHasFlag', C.Pawn);
        else
            Level.Game.EvaluateHint('EnemyHasFlag', C.Pawn);
    }
}

function Drop(vector newVel)
{
    OldHolder = Holder;

	RotationRate.Yaw = Rand(200000) - 100000;
	RotationRate.Pitch = Rand(200000 - Abs(RotationRate.Yaw)) - 0.5 * (200000 - Abs(RotationRate.Yaw));

    Velocity = (0.2 + FRand()) * (newVel + 400 * FRand() * VRand());
	if ( PhysicsVolume.bWaterVolume )
		Velocity *= 0.5;

    Super.Drop(Velocity);
}


// Helper funcs
//CMR - I swapped the logic on this one, shouldn't hurt anything though.
function bool SameTeam(Controller c)
{
	if (c.PlayerReplicationInfo.Team == Team)
    {
		//log("CHARLES:  SAMETEAM player:"$c.PlayerReplicationInfo.Team@c.PlayerReplicationInfo.Team.TeamIndex$" Flag: "$Team@Team.TeamIndex);
		return true;
	}

    return false;
}

protected function SetReplicatedState( GameReplicationInfo.GameObjectState gos )
{
    if(TeamNum < 2)
		Level.Game.GameReplicationInfo.GameObjStates[TeamNum] = gos;
}

function bool ValidHolder(Actor Other)
{
    local Controller c;

    if (!Super.ValidHolder(Other))
        return false;

    c = Pawn(Other).Controller;
	if (SameTeam(c))
	{
        SameTeamTouch(c);
        return false;
	}
	else
		DiffTeamTouch(c);


    return true;
}

function SameTeamTouch(Controller c)
{
}

function DiffTeamTouch(Controller c)
{
}


// Events
function Landed(vector HitNormal)
{
	local rotator NewRot;

	NewRot = Rot(16384,0,0);
	NewRot.Yaw = Rotation.Yaw;
	SetRotation(NewRot);
	Super.Landed(HitNormal);
}

// Logging
function LogReturned()
{
	BroadcastLocalizedMessage( MessageClass, 3, None, None, Team );
}

function LogDropped()
{
	BroadcastLocalizedMessage( MessageClass, 2, Holder.PlayerReplicationInfo, None, Team );
	if (Level.Game.GameStats != None )
		Level.Game.GameStats.GameEvent("flag_dropped",""$Team.TeamIndex, Holder.PlayerReplicationInfo);
}

function CheckPain(); // stub


// States
auto state Home
{
    function SameTeamTouch(Controller c)
    {
        local CTFFlag flag;

        if (C.PlayerReplicationInfo.HasFlag == None)
            return;

        // Score!
        flag = CTFFlag(C.PlayerReplicationInfo.HasFlag);
        CTFGame(Level.Game).ScoreFlag(C, flag);
        flag.Score();

        if (Bot(C) != None)
            Bot(C).Squad.SetAlternatePath(true);
    }

    function LogTaken(Controller c)
    {
        BroadcastLocalizedMessage( MessageClass, 6, C.PlayerReplicationInfo, None, Team );
        if (Level.Game.GameStats!=None)
            Level.Game.GameStats.GameEvent("flag_taken",""$Team.TeamIndex,C.PlayerReplicationInfo);
    }

	function Timer()
	{
		if ( VSize(Location - HomeBase.Location) > 10 )
		{

			if (Level.Game.GameStats != None)
				Level.Game.GameStats.GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);

            log(self$" Home.Timer: had to sendhome", 'Error');
			SendHome();
		}
	}

	function BeginState()
	{
        Super.BeginState();
		bHidden = true;
		HomeBase.bHidden = false;
		HomeBase.StopBaseSound();
		SetTimer(1.0, true);
	}

	function EndState()
	{
        Super.EndState();
		bHidden = false;
		HomeBase.bHidden = true;
		HomeBase.PlayAlarm();
		SetTimer(0.0, false);
	}
}

state Held
{
	function Timer()
	{
		if (Holder == None)
        {
            log(self$" Held.Timer: had to sendhome", 'Error');

			if (Level.Game.GameStats != None)
				Level.Game.GameStats.GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);

			SendHome();
        }
	}

	function BeginState()
	{
        Super.BeginState();
		SetTimer(10.0, true);
	}
}


state Dropped
{
    function SameTeamTouch(Controller c)
	{
		// returned flag
		if(Level.Game.IsA('CTFGame'))
			CTFGame(Level.Game).ScoreFlag(C, self);
		SendHome();
	}


    function bool ValidHolder(Actor Other)
    {
        if( Other == OldHolder )
            return false;

        return global.ValidHolder(Other);
    }

    function LogTaken(Controller c)
    {
        if (Level.Game.GameStats!=None)
            Level.Game.GameStats.GameEvent("flag_pickup",""$Team.TeamIndex,C.PlayerReplicationInfo);
        BroadcastLocalizedMessage( MessageClass, 4, C.PlayerReplicationInfo, None, Team );
    }

    function CheckFit()
    {
	    local vector X,Y,Z;

	    GetAxes(OldHolder.Rotation, X,Y,Z);
	    SetRotation(rotator(-1 * X));
	    if ( !SetLocation(OldHolder.Location - 2 * OldHolder.CollisionRadius * X + OldHolder.CollisionHeight * vect(0,0,0.5))
		    && !SetLocation(OldHolder.Location) )
	    {
		    SetCollisionSize(0.8 * OldHolder.CollisionRadius, FMin(CollisionHeight, 0.8 * OldHolder.CollisionHeight));
		    if ( !SetLocation(OldHolder.Location) )
		    {
                log(self$" Drop sent flag home", 'Error');

				if (Level.Game.GameStats != None)
					Level.Game.GameStats.GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);

			    SendHome();
			    return;
		    }
	    }
    }

    function CheckPain()
    {
        if (IsInPain())
            timer();
    }

	function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
        CheckPain();
	}

	singular function PhysicsVolumeChange( PhysicsVolume NewVolume )
	{
		Super.PhysicsVolumeChange(NewVolume);
        CheckPain();
	}

	function BeginState()
	{
        Super.BeginState();
	    bCollideWorld = true;
	    SetCollisionSize(0.5 * default.CollisionRadius, CollisionHeight);
        CheckFit();
        CheckPain();
		SetTimer(MaxDropTime, false);
		OldHolder = None;
	}

    function EndState()
    {
        Super.EndState();
		bCollideWorld = false;
		SetCollisionSize(default.CollisionRadius, default.CollisionHeight);
    }

	function Timer()
	{
		if (Level.Game.GameStats != None)
			Level.Game.GameStats.GameEvent("flag_returned_timeout",""$Team.TeamIndex,None);

		Super.Timer();
	}


}

defaultproperties
{
     TakenSounds(0)=Sound'PariahAnnouncer.blue_flag_taken'
     TakenSounds(1)=Sound'PariahAnnouncer.red_flag_taken'
     bHome=True
     DrawScale=0.600000
     CollisionRadius=48.000000
     CollisionHeight=30.000000
     Mass=30.000000
     Buoyancy=20.000000
     NetPriority=3.000000
     MessageClass=Class'UnrealGame.CTFMessage'
     PrePivot=(X=2.000000,Z=0.500000)
     RotationRate=(Pitch=30000,Roll=30000)
     Style=STY_Masked
     bStatic=False
     bHidden=True
     bStasis=False
     bAlwaysRelevant=True
     bCollideActors=True
     bCollideWorld=True
     bFixedRotationDir=True
}
