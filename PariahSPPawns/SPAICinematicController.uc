class SPAICinematicController extends ScriptedController;


/*****************************************************************
 * SetLootAtActor
 * Defines the current object of interest for this bot
 *****************************************************************
 */
function SetLookAtActor(Name NewLookAtActorTag, bool eyes, bool head, bool torso){
    local Actor newActor;

    //hack it so that no tag mean generally look forward
    if (NewLookAtActorTag == ''){
        SPPawn(Pawn).SetLookAtTarget( None, Pawn.Location + vect(1000,0,0) + (vect(0,0,1) * Pawn.BaseEyeHeight) , eyes, head, torso);
        return;
    }

    //yup we break when we find the first one, better only be one thing
    //with that tag
    foreach AllActors(class'Actor', newActor, NewLookAtActorTag){
        SPPawn(Pawn).SetLookAtTarget( None, newActor.Location, eyes, head, torso);
        break;
    }
}


/*****************************************************************
 * SetLookAtRates
 * The rate a which the LookAtActor function changes to look at the
 * target
 *****************************************************************
 */
function SetLookAtRates(float eyes, float head, float torso){
   SPPawn(Pawn).EyesTurnRate = eyes;
   SPPawn(Pawn).HeadTurnRate = head;
   SPPawn(Pawn).TorsoTurnRate = torso;
}

/*****************************************************************
 * SetHeadNoise
 * Adjusts the value of the rotator that is used in the calculation
 * of the perlin noise that is applied to this pawn
 *****************************************************************
 */
 function SetHeadNoise(Rotator HeadNoise){
    SPPawn(Pawn).HeadNoiseAmp = HeadNoise;
 }

defaultproperties
{
}
