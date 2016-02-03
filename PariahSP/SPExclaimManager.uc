class SPExclaimManager extends ExclaimManager;

var bool bUseRadio;
var bool bCanUseRadio;
var string RadioIntro;
var string RadioEnd;

var sound RadioIntroSound;
var sound RadioEndSound;

/**
 */
function PlayScheduledExclamation()
{
    local int i;
    local Sound snd;

    GlobalLastExclaimTime = c.Level.TimeSeconds;

    if(c.currentStage != None) {
        c.currentStage.LastExclaimTime[nextExclamation.type]
            = c.Level.TimeSeconds;
    }
    else {
        LastExclaimTime[nextExclamation.type] = c.Level.TimeSeconds;
    }

    bScheduled = false;
    snd = sndGroups[nextExclamation.type];
    
    // you can hack around max-volume by playing the same sound
    // multiple times.  This shouldn't really be neccessary if your
    // sounds are balanced right in the first place.
    for ( i = 0; i < LoudExclaimHack; ++i ) {
        if (bUseRadio == false){
            c.Pawn.PlaySound( snd, SLOT_Talk, 2.5*c.Pawn.TransientSoundVolume,
                   false, exclaimRadiusUU / 100, exclaimPitch );
        } else {

            if (RadioIntroSound == none && RadioIntro != ""){
               RadioIntroSound = Sound( DynamicLoadObject(RadioIntro, class'Sound') );
            }

            if (RadioEndSound == none && RadioEnd != ""){
               RadioEndSound = Sound( DynamicLoadObject(RadioEnd, class'Sound') );
            }

            SPPawn(c.Pawn).PlayOrderedSound( RadioIntroSound, snd, none, RadioEndSound,
                2.5*c.Pawn.TransientSoundVolume,exclaimRadiusUU / 100);
        }

    }
}

defaultproperties
{
     RadioIntro="DialogueRadioSounds.DialogueRadioIn"
     RadioEnd="DialogueRadioSounds.DialogueRadioIn"
     TimeBetween(11)=1.000000
}
