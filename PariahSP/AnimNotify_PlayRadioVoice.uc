class AnimNotify_PlayRadioVoice extends AnimNotify_Scripted;

var() Sound	RadioIntro;
var() sound RadioEnd;
var() sound Voice;


event Notify( Actor Owner )
{
    SPPawn(Owner).PlayOrderedSound(RadioIntro,Voice, None, RadioEnd);
}

defaultproperties
{
     RadioIntro=Sound'DialogueRadioSounds.DialogueRadioIn'
     RadioEnd=Sound'DialogueRadioSounds.DialogueRadioOut'
}
