//=============================================================================
// TeamVoicePack.
//=============================================================================
class TeamVoicePack extends VoicePack
	abstract;

var() Sound NameSound[4]; // leader names

var() Sound AckSound[16]; // acknowledgement sounds
var() string AckString[16];
var() string AckAbbrev[16];
var() name AckAnim[16];
var() int numAcks;

var() Sound FFireSound[16];
var() string FFireString[16];
var() string FFireAbbrev[16];
var() name FFireAnim[16];
var() int numFFires;

var() Sound TauntSound[48];
var() string TauntString[48];
var() string TauntAbbrev[48];
var() name TauntAnim[48];
var() int numTaunts;
var() byte MatureTaunt[48];
var() byte HumanOnlyTaunt[48]; // Whether this taunt should not be used by bots
var   float Pitch;
var string MessageString;
var name MessageAnim;
var byte DisplayString;
var String LeaderSign[4];

/* Orders (in same order as in Orders Menu 
	0 = Defend, 
	1 = Hold, 
	2 = Attack, 
	3 = Follow, 
	4 = FreeLance
*/
var() Sound OrderSound[16];
var() string OrderString[16];
var() string OrderAbbrev[16];
var() name OrderAnim[16];

var string CommaText;

/* Other messages - use passed messageIndex
	0 = Base Undefended
	1 = Get Flag
	2 = Got Flag
	3 = Back up
	4 = Im Hit
	5 = Under Attack
	6 = Man Down
*/
var() Sound OtherSound[48];
var() string OtherString[48];
var() string OtherAbbrev[48];
var() name OtherAnim[48];
var() byte OtherDelayed[48];
var() byte DisplayOtherMessage[48];
var() name OtherMesgGroup[48]; // Used to only show relevant comments in menu

var Sound Phrase[8];
var string PhraseString[8];
var int PhraseNum;
var() byte DisplayMessage[8];
var PlayerReplicationInfo DelayedSender;

var Sound	DeathPhrases[8];				// only spoken as alternative to death scream, not available from menus
var byte	HumanOnlyDeathPhrase[8];
var int		NumDeathPhrases;

var array<Sound> HiddenPhrases;
var array<String> HiddenString;

var bool bDisplayPortrait;
var PlayerReplicationInfo PortraitPRI;

function string GetCallSign( PlayerReplicationInfo P )
{
	if ( P == None )
		return "";
	if ( (Level.NetMode == NM_Standalone) && (P.TeamID == 0) )
		return LeaderSign[P.Team.TeamIndex];
	else
		return P.RetrivePlayerName();
}

static function bool PlayDeathPhrase(Pawn P)
{
	local int pdNum, tryCount;
	local bool foundPhrase;

	if ( Default.NumDeathPhrases == 0 )
		return false;
	
	for(tryCount = 0; !foundPhrase && tryCount < 100; tryCount++)
	{
		pdNum = Rand(Default.NumDeathPhrases);
		
		if( !P.IsHumanControlled() &&  Default.HumanOnlyDeathPhrase[pdNum] == 1 )
			continue;

		foundPhrase = true;
	}

	if(!foundPhrase)
	{
		Log("PlayDeathPhrase: Could Not Find Suitable Phrase.");
		return false;
	}

	P.PlaySound(Default.DeathPhrases[pdNum], SLOT_Talk,2.5*P.TransientSoundVolume, true,500);
	return true;
}

static function int PickRandomTauntFor(controller C, bool bNoMature, bool bNoHumanOnly)
{
	local int result, tryCount;
	local bool foundTaunt;

	// Not a while - worried about inifite loops with small number of taunts!
	for(tryCount = 0; !foundTaunt && tryCount < 100; tryCount++)
	{
		result = rand(Default.NumTaunts);

		if(C.DontReuseTaunt(result))
			continue;

        if(Default.TauntSound[result] == None)
			continue;

		if(bNoMature && Default.MatureTaunt[result] == 1)
			continue;

		if(bNoHumanOnly && Default.HumanOnlyTaunt[result] == 1)
			continue;

		// Pick mature taunts less often...
		if(Default.MatureTaunt[result] == 1 && FRand() < 0.5)
			continue;

		foundTaunt = true;
	}

	if(!foundTaunt)
		Log("PickRandomTauntFor: Could Not Find Suitable Taunt.");

	return result;
}


function BotInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex)
{
	local Sound MessageSound;

	DelayedSender = Sender;
	DisplayString = 0;
	if ( messagetype == 'ACK' )
		SetAckMessage(Rand(NumAcks), Recipient, MessageSound);
	else
	{
		SetTimer(0.1, false);
		if ( messagetype == 'FRIENDLYFIRE' )
			SetFFireMessage(Rand(NumFFires), Recipient, MessageSound);
		else if ( (messagetype == 'AUTOTAUNT') || (messagetype == 'TAUNT') )
			SetTauntMessage(messageIndex, Recipient, MessageSound);
		else if ( messagetype == 'ORDER' )
			SetOrderMessage(messageIndex, Recipient, MessageSound);
		else // messagetype == Other
			SetOtherMessage(messageIndex, Recipient, MessageSound);

		Phrase[0] = MessageSound;
		PhraseString[0] = MessageString;
		DisplayMessage[0] = DisplayString;
	}
}

static function int OrderToIndex(int Order, class<GameInfo> GameClass)
{
	if( ClassIsChildOf(GameClass, class'UnrealGame.CTFGame') )
	{
		if(Order == 2)
			return 10;

		if(Order == 0)
			return 11;
	}

	return Order;
}

function ClientInitialize(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageIndex)
{
	local Sound MessageSound;

	DelayedSender = Sender;
	DisplayString = 0;
	bDisplayPortrait = false;
	if ( (PlayerController(Owner).PlayerReplicationInfo == Recipient) || (messagetype == 'OTHER') )
	{
		PortraitPRI = Sender;
		bDisplayPortrait = true;
	}
	else if ( (PlayerController(Owner).PlayerReplicationInfo != Sender) && ((messagetype == 'ORDER') || (messagetype == 'ACK'))
			&& (Recipient != None) )
	{
		Destroy();
		return;
	}

	if(PlayerController(Owner).bNoVoiceMessages
		|| (PlayerController(Owner).bNoVoiceTaunts && (MessageType == 'TAUNT' || MessageType == 'AUTOTAUNT') && PlayerController(Owner).PlayerReplicationInfo != Sender)
		|| (PlayerController(Owner).bNoAutoTaunts && MessageType == 'AUTOTAUNT')
		)
	{
		Destroy();
		return;
	}

	if ( Sender.bBot )
	{
		BotInitialize(Sender, Recipient, messagetype, messageIndex);
		return;
	}

	SetTimer(0.6, false);

	if ( messagetype == 'ACK' )
		SetClientAckMessage(messageIndex, Recipient, MessageSound);
	else
	{
		if ( messagetype == 'FRIENDLYFIRE' )
			SetClientFFireMessage(messageIndex, Recipient, MessageSound);
		else if ( messagetype == 'TAUNT' )
			SetClientTauntMessage(messageIndex, Recipient, MessageSound);
		else if ( messagetype == 'AUTOTAUNT' )
		{
			SetClientTauntMessage(messageIndex, Recipient, MessageSound);
			SetTimer(1, false);
		}
		else if ( messagetype == 'ORDER' )
			SetClientOrderMessage(messageIndex, Recipient, MessageSound);
		else if ( messagetype == 'HIDDEN' )
			SetClientHiddenMessage(messageIndex, Recipient, MessageSound);
		else // messagetype == Other
			SetClientOtherMessage(messageIndex, Recipient, MessageSound);
	}
	Phrase[0] = MessageSound;
	PhraseString[0] = MessageString;
	DisplayMessage[0] = DisplayString;
}

function SetClientAckMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = Clamp(messageIndex, 0, numAcks-1);
	MessageSound = AckSound[messageIndex];
	MessageString = AckString[messageIndex];
	/*if ( (Recipient != None) && (Level.NetMode == NM_Standalone) 
		&& (recipient.TeamID == 0) && PlayerController(Owner).GameReplicationInfo.bTeamGame )
	{
		Phrase[1] = NameSound[Recipient.Team.TeamIndex];
	}*/
    MessageAnim = AckAnim[messageIndex];
}

function SetAckMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	SetTimer(3 + FRand(), false); // wait for initial order to be spoken
	Phrase[0] = AckSound[messageIndex];
	/*if ( (Level.NetMode == NM_Standalone) && (recipient.TeamID == 0) && PlayerController(Owner).GameReplicationInfo.bTeamGame )
		Phrase[1] = NameSound[recipient.Team.TeamIndex];*/
    MessageAnim = AckAnim[messageIndex];
}

function SetClientFFireMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = Clamp(messageIndex, 0, numFFires-1);
	MessageSound = FFireSound[messageIndex];
	MessageString = FFireString[messageIndex];
    MessageAnim = FFireAnim[messageIndex];
}

function SetFFireMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = FFireSound[messageIndex];
	MessageString = FFireString[messageIndex];
    MessageAnim = FFireAnim[messageIndex];
}

// Taunts from Players
function SetClientTauntMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = Clamp(messageIndex, 0, numTaunts-1);

	// If we are trying to set a mature message but its turned off - pick a new random one.
	if(MatureTaunt[messageIndex] == 1 && PlayerController(Owner).bNoMatureLanguage)
		messageIndex = PickRandomTauntFor(PlayerController(Owner), true, false);

	MessageSound = TauntSound[messageIndex];
	MessageString = TauntString[messageIndex];
    MessageAnim = TauntAnim[messageIndex];
}

// Taunts from Bots
function SetTauntMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = Clamp(messageIndex, 0, numTaunts-1);

	if(MatureTaunt[messageIndex] == 1 && PlayerController(Owner).bNoMatureLanguage)
		messageIndex = PickRandomTauntFor(PlayerController(Owner), true, true);

	MessageSound = TauntSound[messageIndex];
	MessageString = TauntString[messageIndex];
    MessageAnim = TauntAnim[messageIndex];
	SetTimer(1.0, false);
}

function SetClientOrderMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = OrderSound[messageIndex];
	MessageString = OrderString[messageIndex];
    MessageAnim = OrderAnim[messageIndex];
}

// 'Hidden' Messages - only from players
function SetClientHiddenMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = Clamp(messageIndex, 0, HiddenPhrases.Length-1);
	MessageSound = HiddenPhrases[messageIndex];
	MessageString = HiddenString[messageIndex];
    MessageAnim = '';
}
//

function SetOrderMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	messageIndex = OrderToIndex(messageIndex, Level.Game.Class);

	MessageSound = OrderSound[messageIndex];
	MessageString = OrderString[messageIndex];
    MessageAnim = OrderAnim[messageIndex];
}

// for Voice message popup menu - since order names may be replaced for some game types
static function string GetOrderString(int i, class<GameInfo> GameClass)
{
	if ( i > 9 )
		return ""; //high index order strings are alternates to the base orders 

	i = OrderToIndex(i, GameClass);

	if ( Default.OrderAbbrev[i] != "" )
		return Default.OrderAbbrev[i];

	return Default.OrderString[i];
}

function SetClientOtherMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	MessageSound = OtherSound[messageIndex];
	MessageString = OtherString[messageIndex];
	DisplayString = DisplayOtherMessage[messageIndex];
    MessageAnim = OtherAnim[messageIndex];
}

function SetOtherMessage(int messageIndex, PlayerReplicationInfo Recipient, out Sound MessageSound)
{
	if ( OtherDelayed[messageIndex] != 0 )
		SetTimer(2.5 + 0.5*FRand(), false); // wait for initial request to be spoken
	MessageSound = OtherSound[messageIndex];
	MessageString = OtherString[messageIndex];
	DisplayString = DisplayOtherMessage[messageIndex];
    MessageAnim = OtherAnim[messageIndex];
}

// We can't use the normal ParseMessageString, because thats only really valid on the server. 
// So we use a special one just for the %l (location) token.
static function string ClientParseChatPercVar(PlayerReplicationInfo PRI, String Cmd)
{
	if (cmd~="%L")
		return "in"@PRI.GetLocationName();
}

static function string ClientParseMessageString(PlayerReplicationInfo PRI, String Message)
{
	local string OutMsg;
	local string cmd;
	local int pos,i;

	OutMsg = "";
	pos = InStr(Message,"%");
	while (pos>-1) 
	{
		if (pos>0)
		{
		  OutMsg = OutMsg$Left(Message,pos);
		  Message = Mid(Message,pos);
		  pos = 0;
	    }

		i = len(Message);
		cmd = mid(Message,pos,2);
		if (i-2 > 0)
			Message = right(Message,i-2);
		else
			Message = "";

		OutMsg = OutMsg$ClientParseChatPercVar(PRI, Cmd);
		pos = InStr(Message,"%");
	}

	if (Message!="")
		OutMsg=OutMsg$Message;
	
	return OutMsg;
}

simulated function Timer()
{
	local PlayerController PlayerOwner;
	local string Mesg;

	PlayerOwner = PlayerController(Owner);
	//if ( bDisplayPortrait && (PhraseNum == 0) )
	//	PlayerController(Owner).myHUD.DisplayPortrait(PortraitPRI);
	if ( (Phrase[PhraseNum] != None) && ((Level.TimeSeconds - PlayerOwner.LastPlaySpeech > 1.5) || (PhraseNum > 0))  )
	{
		PlayerOwner.LastPlaySpeech = Level.TimeSeconds;
		if ( (PlayerOwner.ViewTarget != None) )
		{
			PlayerOwner.ViewTarget.PlaySound(Phrase[PhraseNum], SLOT_Talk,1.5*TransientSoundVolume,,,Pitch,false);
		}
		else
		{
			PlayerOwner.PlaySound(Phrase[PhraseNum], SLOT_Talk,1.5*TransientSoundVolume,,,Pitch,false);
		}

        if (MessageAnim != '')
        {
            UnrealPlayer(PlayerOwner).Taunt(MessageAnim);
        }

		if ( DisplayMessage[PhraseNum] != 0 )
		{
			Mesg = ClientParseMessageString(DelayedSender, PhraseString[PhraseNum]);
			PlayerOwner.ClientMessage(Mesg);
		}
		if ( Phrase[PhraseNum+1] == None )
			Destroy();
		else
		{
			SetTimer(GetSoundDuration(Phrase[PhraseNum]), false);
			PhraseNum++;
		}
	}
	else 
		Destroy();
}


static function PlayerSpeech( name Type, int Index, string Callsign, Actor PackOwner )
{
	local name SendMode;
	local PlayerReplicationInfo Recipient;
	local int i;
	local GameReplicationInfo GRI;

	switch (Type)
	{
		case 'ACK':					// Acknowledgements
		case 'FRIENDLYFIRE':		// Friendly Fire
		case 'OTHER':				// Other
			SendMode = 'TEAM';		// Only send to team.
			Recipient = None;		// Send to everyone.
			break;
		case 'ORDER':				// Orders
			SendMode = 'TEAM';		// Only send to team.

			Index = OrderToIndex(Index, PackOwner.Level.Game.Class);

			GRI = PlayerController(PackOwner).GameReplicationInfo;
			if ( GRI.bTeamGame )
			{
				if ( Callsign == "" )
					Recipient = None;
				else 
				{
					for ( i=0; i<GRI.PRIArray.Length; i++ )
						if ( (GRI.PRIArray[i] != None) && (GRI.PRIArray[i].RetrivePlayerName() == Callsign)
							&& (GRI.PRIArray[i].Team == PlayerController(PackOwner).PlayerReplicationInfo.Team) )
						{
							Recipient = GRI.PRIArray[i];
							break;
						}
				}
			}
			break;
		case 'TAUNT':				// Taunts
		case 'HIDDEN':				// Hidden Taunts
			SendMode = 'GLOBAL';	// Send to all teams.
			Recipient = None;		// Send to everyone.
			break;
		default:
			SendMode = 'GLOBAL';
			Recipient = None;
	}
	if (!PlayerController(PackOwner).GameReplicationInfo.bTeamGame)
		SendMode = 'GLOBAL';  // Not a team game? Send to everyone.

	//Log("PlayerSpeech: "$Type$" Ix:"$Index$" Callsign:"$Callsign$" Recip:"$Recipient);
	Controller(PackOwner).SendVoiceMessage( Controller(PackOwner).PlayerReplicationInfo, Recipient, Type, Index, SendMode );
}

static function string GetAckString(int i)
{
	if ( Default.AckAbbrev[i] != "" )
		return Default.AckAbbrev[i];

	return default.AckString[i];
}

static function string GetFFireString(int i)
{
	if ( default.FFireAbbrev[i] != "" )
		return default.FFireAbbrev[i];

	return default.FFireString[i];
}

static function string GetTauntString(int i)
{
	if ( default.TauntAbbrev[i] != "" )
		return default.TauntAbbrev[i];
	
	return default.TauntString[i];
}

static function string GetOtherString(int i)
{
	if ( Default.OtherAbbrev[i] != "" )
		return default.OtherAbbrev[i];
	
	return default.OtherString[i];
}

defaultproperties
{
     Pitch=1.000000
     LeaderSign(0)="Red Leader"
     LeaderSign(1)="Blue Leader"
     LeaderSign(2)="Green Leader"
     LeaderSign(3)="Gold Leader"
     CommaText=", "
}
