/*****************************************************************
 * Author : Jesse LaChapelle
 * Date : Sept 20, 2004
 * Description : An action that allows LD's to specify a cutscene
 * video from a script
 *****************************************************************
 */
class ACTION_PlayLocalizedVideo extends LatentScriptedAction;

var(Action)		string			English;
var(Action)		string			French;
var(Action)		string			German;
var(Action)		string			Italian;
var(Action)		string			Spanish;

var(Action)     bool            bPauseDuringPlay;
var(Action)     bool            bInterruptible;
var(Action)		float			FadeToTime;
var(Action)		float			FadeFromTime;
var(Action)		Color			FadeToColor;
var(Action)		Color			FadeFromColor;
var(Action)		array<string>	ExtraVideoNames;

function bool InitActionFor(ScriptedController C)
{
    C.CurrentAction = self;
    if(FadeToTime > 0.0)
    {
		C.SetTimer(FadeToTime, false);
		SetFadesOuts(C, FadeToTime, FadeToColor);
    }
    else
    {
        C.SetTimer(0.1, false);
    }
	return true;
}

function bool CompleteWhenTriggered()
{
	return false;
}

function bool CompleteWhenTimer()
{
	return true;
}

function ProceedToNextAction(ScriptedController C)
{
	if(FadeFromTime > 0.0)
    {
		SetFadesOuts(C, -FadeFromTime, FadeFromColor);
    }
    C.Level.PlayLocalizedCinematic(English, French, German, Italian, Spanish, ExtraVideoNames, bPauseDuringPlay, bInterruptible);
    Super.ProceedToNextAction(C);
}

function SetFadesOuts(Controller ActionTarget, float time, Color TransitionColor)
{
	local Controller C;
	local PlayerController PC;

	for ( C=ActionTarget.Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.IsA('PlayerController') )
		{
			PC = PlayerController(C);
			if(PC.myHud != None)
			{
				PC.myHud.QueueCinematicFade(time, transitionColor);
			}
		}
	}
}

function string GetActionString()
{
	return ActionString;
}

defaultproperties
{
     FadeToTime=1.000000
     FadeFromTime=1.000000
     FadeToColor=(B=255,G=255,R=255,A=255)
     FadeFromColor=(B=255,G=255,R=255,A=255)
     English="SomeVideo.bik"
     French="SomeVideoFrt.bik"
     German="SomeVideoDet.bik"
     Italian="SomeVideoItt.bik"
     Spanish="SomeVideoEst.bik"
     bPauseDuringPlay=True
     bInterruptible=True
     ActionString="Play Video"
}
