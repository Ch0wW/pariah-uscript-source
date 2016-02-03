/*****************************************************************
 * Author : Jesse LaChapelle
 * Date : Nov 11, 2004
 * Description : A hack to try and algorithmically simulate the radio
 * effect on some of the characters
 *****************************************************************
 */
class ACTION_PlayRadioVoice extends ScriptedAction;

var(Action) Sound	RadioIntro;
var(Action) sound   StaticLoop;
var(Action) sound   RadioEnd;
var(Action) sound   Voice;


function bool InitActionFor(ScriptedController C){
    SPPawn(C.Pawn).PlayOrderedSound(RadioIntro,Voice, StaticLoop, RadioEnd);
    return false;
}

function string GetActionString(){
	return ActionString;
}

defaultproperties
{
     RadioIntro=Sound'DialogueRadioSounds.DialogueRadioIn'
     RadioEnd=Sound'DialogueRadioSounds.DialogueRadioOut'
     ActionString="Play Video"
}
