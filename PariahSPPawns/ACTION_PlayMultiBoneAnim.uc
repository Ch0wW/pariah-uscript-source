/*****************************************************************
 * ACTION_MultiBoneAnim
 * Authon: Professor J. LaChapelle
 *****************************************************************
 */
class ACTION_PlayMultiBoneAnim extends CinematicActions;

var() int StartChannel;
var() float BlendAlpha;
var() float InTime;
var() float OutTime;
var() name AnimName;
var() float AnimRate;
var() array<name> Bones;

function bool InitActionFor(ScriptedController C){
    local int i;

    for ( i=0; i< Bones.Length; i++){
        C.Pawn.AnimBlendParams(StartChannel + i, BlendAlpha, InTime, OutTime, Bones[i]);
        C.Pawn.Playanim(AnimName, AnimRate,,StartChannel + i);
    }
	return false;
}

function String GetActionString(){
	return ActionString;
}

defaultproperties
{
     StartChannel=5
     BlendAlpha=1.000000
     AnimRate=1.000000
     Bones(0)="'"
     ActionString="multiboneanim"
}
