class AlarmButton extends UseButton
	hidecategories(UseButton)
	hidecategories(Events);


var() edfindable Alarm MyAlarm;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if(MyAlarm==None)
	{
		log("AlarmButton "$self$" is not associated with an alarm!",'Error');
		assert(false);
	}

	MyAlarm.RegisterButton(self);

}

function ButtonOn(Pawn P, optional bool bNoEvent)
{
	Super.ButtonOn(P, bNoEvent);
	MyAlarm.TurnAlarmOn();
}


function ButtonOff(Pawn P, optional bool bNoEvent)
{
	Super.ButtonOff(P, bNoEvent);
	MyAlarm.TurnAlarmOff();
}

defaultproperties
{
     OnMat=Combiner'PariahGameTypeTextures.alarm.alarm_on_combiner'
     OffMat=Shader'PariahGameTypeTextures.alarm.alarm_off_shader'
     DisabledMat=Shader'PariahGameTypeTextures.alarm.alarm_disabled_shader'
     UseButtonState=UBS_Off
     StaticMesh=StaticMesh'PariahGametypeMeshes.alarm.alarm_button'
}
