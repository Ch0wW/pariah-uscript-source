/*****************************************************************
 * Dialogue
 * Author: Jim MacArthur (?)
 * Edited By: Prof. Jesse LaChapelle
 * The dialogue actor is intended to provide a centralized place to
 * manage a characters dialog, without the need to add these to an AIscript
 * which is busy managing other stuff.
 *
 * Initially this class was designed to support subtitles, however this functionality
 * has since been depricated as it will NOT be used in pre-rendered cinematics, and thus
 * should not be used in any point in the game for consistency.
 *****************************************************************
 */
class Dialogue extends Info
	placeable;

#exec Texture Import File=Textures\S_dialog.pcx Name=S_Dialog Mips=Off MASKED=1


//Dialog system notes:
//
// To operate, dialogue requires that the text be put in PariahSPDialog.int with a particular Name, and then a wave file with the SAME NAME gets put
// in the dialogue sound package.  Game will automatically create the references to text and audio based on the TEXTID.  So if you have a
// line in PariahSP.int under [DecoText] that is like:
//
// d00001="Holy fucking hell batman!  Did you see that shit?"
//
// then you make sure that you have a wave file labelled d00001 in the dialogue package that speaks that line. For the dialog entry, the TextID
// you give it would be "d00001".
//
// CharID will be the tag associated with the 'speaking' character, for playing animations, etc.

var() string DIALOGPACKAGE;

//might have to add an anim name to this entry, or emotion or something, depending on our facial anim system.
struct DialogEntry
{
	var() string TextID;
	var() float PostDelay;
	var() name CharID;
	var() name LIPSyncAnim;
	var() bool bPlaySoundOnCamera;
};

var() array<DialogEntry> TheDialogue;
var() bool bCinematicStyle;
var() bool bPlayAllOnCamera;

var int CurrentIndex;
var SinglePlayerController MainPlayer;

var bool bPlaying;

//event Trigger( Actor Other, Pawn EventInstigator );
//event UnTrigger( Actor Other, Pawn EventInstigator );
//event BeginEvent();
//event EndEvent();
//GetSoundDuration(sound)
//GetLocalPlayerController()
//FindPlayer()

/*****************************************************************
 * Reset
 *****************************************************************
 */
function Reset()
{
	CurrentIndex = 0;
	MainPlayer = None;
	bPlaying = true;
}


/*****************************************************************
 * PrintDialogEntry
 * For debugging this actor
 *****************************************************************
 */
function printdialogentry(DialogEntry d)
{
	log("    This dialog entry has:");
	log("        TextID = "$d.TextID);
	log("        PostDelay = "$d.PostDelay);
	log("        CharID = "$d.CharID);
	log("        LIPSyncAnim = "$d.LIPSyncAnim);
	log("        bPlaySoundOnCamera = "$d.bPlaySoundOnCamera);
}


/*****************************************************************
 * Trigger
 * Start the dialog actor playing all of its entries
 *****************************************************************
 */
event Trigger( Actor Other, Pawn EventInstigator )
{
	//setup
	if(bPlaying){
		log("WARNING:  Dialogue triggered while already running!");
		return;
	}

	MainPlayer = SinglePlayerController(Level.GetLocalPlayerController());
	if(MainPlayer==None){
		log("Couldn't find mainplayer or mainplayer wasn't a singleplayercontroller");
		return;
	}

	bPlaying = true;
	//if(IsOnConsole())
	//	SetVoiceBias(true, 0.3);
	//else
	//	SetVoiceBias(true, 0.55);
	GotoState('Playing');
}

/*****************************************************************
 * PlayDialogEntry
 * Plays a single entry, increments the index to prepare for the next entry
 *****************************************************************
 */
function float PlayDialogEntry()
{
	local Sound s;
	local Pawn npc;
	local float delay;
    //local float DialogTime;
	//local name SkelAnims,TalkAnim;
	//local float length;
	//SkelAnims='MaleSkeleton';
	//TalkAnim='TalkingIdle';

	log("Attempting to play new dialog entry");
	printdialogentry(TheDialogue[CurrentIndex]);

    //load the sound the associated dialog voice
	s = Sound(DynamicLoadObject(DIALOGPACKAGE $ " ." $ TheDialogue[CurrentIndex].TextID, class'Sound'));
	if ( s == none){
        log ("The sound file could not be loaded for this dialogue entry");
    }

	//show the dialogbox/text (make an option to disable later)
	// DISABLED FOR EGN - RJ
	//DialogTime = MainPlayer.PlayDialogue(TheDialogue[CurrentIndex].TextID, s==None, TheDialogue[CurrentIndex].CharID, bCinematicStyle);
    //Removed by Jesse LaChapelle, for consistency none of the prerendered cinematics will ever show subtitles, thus
    //it seems reasonable that none of the in game events should use them either, might seem confusing to a player.
    /*
	if(s==None)	{
		// FOR EGN ONLY SHOW SUBTITLES IF NO SOUND - RJ
		//
		DialogTime = MainPlayer.PlayDialogue(TheDialogue[CurrentIndex].TextID, s==None, TheDialogue[CurrentIndex].CharID, bCinematicStyle);
		log("Dialogue:  Failed to play sound (ID = "$TheDialogue[CurrentIndex].TextID);
		//increment index
		CurrentIndex++;
		return DialogTime + TheDialogue[CurrentIndex-1].PostDelay;
	}
    */

	//play the sound
	//MainPlayer.PlayVoice(s);
	//this is where you'd play any lip animations on character matching CharID (which I figure will be a tag or something on the pawn)

	npc = SinglePlayer(Level.Game).GetNPCPawn(TheDialogue[CurrentIndex].CharID);
	if (npc == none){
	   Log("The character " $ TheDialogue[CurrentIndex].CharID $ " could not be found");
	}

	//urk
	//npc.LinkSkelAnim(MeshAnimation'MaleSkeleton');
	//npc.PlayAnim(TalkAnim);
	if(TheDialogue[CurrentIndex].LIPSyncAnim != ''){
		log("playing lipsinc anim");
		npc.PlayLIPSincAnim(TheDialogue[CurrentIndex].LIPSyncAnim, , , , bPlayAllOnCamera || TheDialogue[CurrentIndex].bPlaySoundOnCamera);
	} else {
        log ("No lip synch animations found for the dialogue");
		MainPlayer.PlayVoice(s);
	}

	//increment index
	CurrentIndex++;
	delay = GetSoundDuration(s);
	log("Total Delay time "$(delay + TheDialogue[CurrentIndex-1].PostDelay)$" sound was "$delay$", postdelay was "$TheDialogue[CurrentIndex-1].PostDelay);
	return delay + TheDialogue[CurrentIndex-1].PostDelay;
}


/*****************************************************************
 * STATE PLAYING
 * The state that manages the output of dialog. While in this state
 * you cannot re-trigger this actor
 *****************************************************************
 */
state Playing
{
	ignores Trigger;

BEGIN:

	log("State playing Beginning with Index: "$CurrentIndex);
	Sleep(PlayDialogEntry());

	//close the given menu
	MainPlayer.MenuClose();

	if(CurrentIndex >= TheDialogue.Length){
		log("Dialogue "$self$" Tag: "$Tag$" completed with "$TheDialogue.Length$" entries");
		Reset();
		//SetVoiceBias(false, 0.0);
		GotoState('');
	} else {
		log("More dialogue remaining, restarting loop");
		GotoState('Playing', 'BEGIN');
	}

}

defaultproperties
{
     DIALOGPACKAGE="DialogueVoices"
     Texture=Texture'PariahSP.S_Dialog'
}
