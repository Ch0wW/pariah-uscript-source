//=============================================================================
// UnrealPlayer.
//=============================================================================
class UnrealPlayer extends debug //amb
	native
	config(User);

var bool		bRising;
var class<CriticalEventPlus> TimeMessageClass;
var string TimeMessageClassName;
var int LastTaunt;
var float LastPlayTakeHitTime;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		TimeMessage, ClientPlayTakeHit, PlayStartupMessage;
	reliable if ( Role == ROLE_Authority )
		PlayWinMessage; 

	reliable if ( Role < ROLE_Authority )
		ServerTaunt, ServerChangeLoadout, ServerSpectate, ServerOrder;
}

exec function ShowAI()
{
	myHUD.ShowDebug();
	if ( UnrealPawn(ViewTarget) != None )
		UnrealPawn(ViewTarget).bSoakDebug = myHUD.bShowDebugInfo;
}

function Possess(Pawn aPawn)
{
	if ( UnrealPawn(aPawn) != None )
	{
		if ( UnrealPawn(aPawn).Default.VoiceType != "" )
			VoiceType = UnrealPawn(aPawn).Default.VoiceType;
		if ( VoiceType != "" )
        {
			PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject(VoiceType,class'Class'));
        }
	}
	Super.Possess(aPawn);
}

function bool DontReuseTaunt(int T)
{
	if ( T == LastTaunt )
		return true;
	LastTaunt = T;
	return false;
}

exec function SoakBots()
{
	local Bot B;

	log("Start Soaking");
	UnrealMPGameInfo(Level.Game).bSoaking = true;
	ForEach DynamicActors(class'Bot',B)
		B.bSoaking = true;
}

function SoakPause(Pawn P)
{
	log("Soak pause by "$P);
	SetViewTarget(P);
	SetPause(true);
	bBehindView = true;
	myHud.bShowDebugInfo = true;
	if ( UnrealPawn(P) != None )
		UnrealPawn(P).bSoakDebug = true;
}

function SpeechRecognized(int wordID)
{
	switch(wordID)
	{
		case 100:// freelance
			Order(4);
			break;
		case 101://  follow
			Order(3);
			break;
		case 200://  freelance
			Order(4);
			break;
		case 201://  attack
			Order(2);
			break;
		case 202://  defend
			Order(0);
			break;
		default:
			return;
	}

	PlayBeepSound();
	myHud.bShowVoiceMenu = false;
}

function ServerOrder(int NewOrders)
{
    local Controller C;
	local Bot B, Best;
	local float BestDist, NewDist, NewFOV;
    local bool bFreelance, bBestFreelance;
    local bool bLooking, bBestLooking;
    local name CurrentOrdersName, NewOrdersName;
    
    // 0 defend
    // 1 hold
    // 2 attack
    // 3 follow
    // 4 freelance

	if ( !Level.Game.bTeamGame || Pawn == None )
		return;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
    {
		if ( C.Pawn != None && C.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team )
        {
		    if ( Bot(C) != None )
            {
    		    B = Bot(C);
                if (B.Squad != None && B.Squad.bFreelance)
                    CurrentOrdersName = 'Freelance';
                else
                    CurrentOrdersName = B.GetOrders();

                NewOrdersName = B.OrderNames[NewOrders];

                if (CurrentOrdersName != NewOrdersName)
                {
			        NewDist = VSize(B.Pawn.Location - Pawn.Location);
			        NewFOV = Normal(B.Pawn.Location - Pawn.Location) Dot vector(Rotation);
                    bFreelance = (CurrentOrdersName == 'Freelance');
                    bLooking = (NewFOV > 0.9 || NewDist < 2000);

			        if (Best == None ||
                        (bLooking && (NewDist < BestDist || !bBestLooking)) ||
                        (!bBestFreelance && bFreelance && !bBestLooking) )
			        {
				        BestDist = NewDist;
				        Best = B;
                        bBestFreelance = bFreelance;
                        bBestLooking = bLooking;
			        }
                }
            }
        }
    }

	if ( Best != None )
    {
        SendVoiceMessage(PlayerReplicationInfo, Best.PlayerReplicationInfo, 'Order', NewOrders, 'TEAM');
    }

    SendVoiceMessage(PlayerReplicationInfo, None, 'Order', NewOrders, 'TEAM');
}

exec function bool Order(int NewOrders)
{
    ServerOrder(NewOrders);
    return true;
}

/*
function ServerOrder(Bot B, name NewOrders)
{
	if ( SameTeamAs(B) )
		B.SetOrders(NewOrders, self);
}

exec function bool Order(int NewOrders)
{
    local Pawn P;
	//local Bot B, Best;
	local float BestDist, NewDist, NewFOV;
    local TeamPlayerReplicationInfo TRI, Best;

	if ( !GameReplicationInfo.bTeamGame || (Pawn == None) )
		return false;

	foreach DynamicActors(class'Pawn', P)
	{
        TRI = TeamPlayerReplicationInfo(P.PlayerReplicationInfo);
        if (TRI != None && TRI.bBot && TRI != None
            && TRI.Team == PlayerReplicationInfo.Team
            && TRI.Squad.CurrentOrders != class'Bot'.default.OrderNames[NewOrders])
        {
            //log("CurrentOrders"@TRI.Squad.CurrentOrders);
			NewDist = VSize(P.Location - Pawn.Location);
			NewFOV = Normal(P.Location - Pawn.Location) Dot vector(Rotation);
			if ( Best == None || (NewFOV > 0.9 && NewDist < BestDist) )
			{
				BestDist = NewDist;
				Best = TRI; 
			}
        }
    }

	if ( Best != None )
    {
		//ServerOrder(Best, NewOrders);
        Speech('ORDER', NewOrders, Best.TeamId);
        return true;
    }
    return false;
}
*/
function byte GetMessageIndex(name PhraseName)
{
	if ( PlayerReplicationInfo.VoiceType == None )
		return 0;
	return PlayerReplicationInfo.Voicetype.Static.GetMessageIndex(PhraseName);
}

exec function Taunt( name Sequence )
{
	if ( (Pawn != None) && (Pawn.Health > 0) )
		ServerTaunt(Sequence);
}

exec function WeaponZoom()
{
	// MERGE_HACK if ( (Pawn != None) && (Pawn.Weapon != None) )
	// MERGE_HACK 	Pawn.Weapon.Zoom();
}

function ServerTaunt(name AnimName )
{
	Pawn.SetAnimAction(AnimName);
}

function PlayStartupMessage(byte StartupStage)
{
	// MERGE_HACK myHUD.PlayStartupMessage(StartupStage);
}

exec function CycleLoadout()
{
	if ( UnrealTeamInfo(PlayerReplicationInfo.Team) != None )
		ServerChangeLoadout(string(UnrealTeamInfo(PlayerReplicationInfo.Team).NextLoadOut(PawnClass)));
}

exec function ChangeLoadout(string LoadoutName)
{
	ServerChangeLoadout(LoadoutName);
}

function ServerChangeLoadout(string LoadoutName)
{
	UnrealMPGameInfo(Level.Game).ChangeLoadout(self, LoadoutName);
}

function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	local int iDam;

	Super.NotifyTakeHit(InstigatedBy,HitLocation,Damage,DamageType,Momentum);

	iDam = Clamp(Damage,0,250);
	
    if (Level.TimeSeconds > LastPlayTakeHitTime + 0.5)
    {
        LastPlayTakeHitTime = Level.TimeSeconds;
	    ClientPlayTakeHit(hitLocation - Pawn.Location, iDam, damageType); 
    }
}

function ClientPlayTakeHit(vector HitLoc, byte Damage, class<DamageType> damageType)
{
	local float rnd;
	
	Pawn.PlayTakeHit(HitLoc, Damage, damageType);

	if ( Damage > 0 )
	{
		rnd = FClamp(Damage, 20, 60);
		ClientFlash(DamageType.Default.FlashScale*rnd,DamageType.Default.FlashFog*rnd);
	}
}
	
function PlayWinMessage(bool bWinner);

function TimeMessage(int Num)
{
	if ( (TimeMessageClass == None) && (TimeMessageClassName != "") )
		TimeMessageClass = class<CriticalEventPlus>(DynamicLoadObject(TimeMessageClassName, class'Class'));

	if ( TimeMessageClass != None )
		ReceiveLocalizedMessage( TimeMessageClass, Num );
}


function SendMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait, name BroadcastType, optional float freq)
{
	if ( Level.TimeSeconds - OldMessageTime < 10 )
		return;

	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, BroadcastType);
}


// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
ignores SeePlayer, HearNoise;

	function bool NotifyLanded(vector HitNormal)
	{
		if (DoubleClickDir == DCLICK_Active)
		{
			DoubleClickDir = DCLICK_Done;
			ClearDoubleClick();
			Pawn.Velocity *= Vect(0.1,0.1,1.0);
		}
		else
			DoubleClickDir = DCLICK_None;

		if ( Global.NotifyLanded(HitNormal) ) // jjs - moved this down here to fix dodge freezing bug
			return true;

		return false;
	}

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		if ( (DoubleClickMove == DCLICK_Active) && (Pawn.Physics == PHYS_Falling) )
			DoubleClickDir = DCLICK_Active;
		else if ( (DoubleClickMove != DCLICK_None) && (DoubleClickMove < DCLICK_Active) )
		{
			if ( UnrealPawn(Pawn).Dodge(DoubleClickMove) )
				DoubleClickDir = DCLICK_Active;
		}

		Super.ProcessMove(DeltaTime,NewAccel,DoubleClickMove,DeltaRot);
	}
}

function ServerSpectate()
{
	GotoState('Spectating');
}

state Dead
{
ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon;

	exec function Fire( optional float F )
	{
		if ( bFrozen )
			return;
		if ( PlayerReplicationInfo.bOutOfLives )
			ServerSpectate();
		else 
			Super.Fire(F);
	}
}

defaultproperties
{
     PlayerReplicationInfoClass=Class'UnrealGame.TeamPlayerReplicationInfo'
}
