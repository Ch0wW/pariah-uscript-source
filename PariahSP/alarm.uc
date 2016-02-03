class Alarm extends GameplayDevices
	placeable;

var(Events) editconst const Name hTurnAlarmOn;
var(Events) editconst const Name hTurnAlarmOff;
var(Events) editconst const Name hDisableAlarm;


var() name AlarmOnEvent;
var() float AlarmOnEventRepeat;
var() name AlarmOffEvent;
var() float AlarmOffEventRepeat;

var Sound AlarmSound;

var Material AlarmOnMat, AlarmOffMat;

var array<AlarmButton> MyButtons;


var() Name AlarmGroupTag;
var() bool bDummyAlarm;

var array<Alarm> DummyAlarms;

function PostBeginPlay()
{
	local Alarm a;

	if(AlarmGroupTag!='')
	{
		ForEach AllActors(class'Alarm', a, AlarmGroupTag)
		{
			if(a.bDummyAlarm)
				DummyAlarms[DummyAlarms.Length] = a;
			else
				log("error, alarm matching alarmgrouptag "$AlarmGroupTag$" Was not set bDummyAlarm=true");
		}
	}
}

function RegisterButton(AlarmButton btn)
{
	MyButtons[MyButtons.Length] = btn;
}

function SetAllButtonsOn()
{
	local int i;

	for(i=0;i<MyButtons.Length;i++)
	{
		MyButtons[i].ButtonOn(None);
	}
}

function SetAllButtonsOff()
{
	local int i;

	for(i=0;i<MyButtons.Length;i++)
	{
		MyButtons[i].ButtonOff(None);
	}
}

function SetAllButtonsDisabled()
{
	local int i;

	for(i=0;i<MyButtons.Length;i++)
	{
		MyButtons[i].ButtonDisable(None);
	}
}

Auto State AlarmOff
{
	function BeginState()
	{
		//set anim/texture
		AlarmOffEffects();
		if(AlarmOffEventRepeat != 0.0)
		{
			SetTimer(AlarmOffEventRepeat, true);
		}
	}

	function Timer()
	{
		if(AlarmOffEvent != '')
			TriggerEvent(AlarmOffEvent, self, none);
	}

	function EndState()
	{
		SetTimer(0,false);
	}

}

function AlarmOnEffects()
{
	SetSkin(0, AlarmOnMat);
	AmbientSound = AlarmSound;
}

function AlarmOffEffects()
{
	SetSkin(0, AlarmOffMat);
	AmbientSound = None;
}

State AlarmOn
{
	function BeginState()
	{
		AlarmOnEffects();
		//set anim/texture here
		if(AlarmOnEventRepeat != 0.0)
		{
			SetTimer(AlarmOnEventRepeat, true);
		}
	}

	function Timer()
	{
		if(AlarmOnEvent != '')
			TriggerEvent(AlarmOnEvent, self, none);
	}

	function EndState()
	{
		SetTimer(0,false);
	}
}

State AlarmDisabled
{
	function BeginState()
	{
		AlarmOffEffects();
	}

	function TurnAlarmOn()
	{
		
	}

	function TurnAlarmOff()
	{
		
	}

	function DisableAlarm()
	{
		
	}

}

function TurnAlarmOn()
{
	local int i;
	if(GetStateName()=='AlarmOn')
		return;

	if(AlarmOnEvent != '')
		TriggerEvent(AlarmOnEvent, self, none);

	GotoState('AlarmOn');
	SetAllButtonsOn();


	for(i=0;i<DummyAlarms.Length;i++)
	{
		DummyAlarms[i].AlarmOnEffects();
	}

}


function TurnAlarmOff()
{
	local int i;
	if(GetStateName()=='AlarmOff')
		return;

	if(AlarmOffEvent != '')
		TriggerEvent(AlarmOffEvent, self, none);

	GotoState('AlarmOff');
	SetAllButtonsOff();

	for(i=0;i<DummyAlarms.Length;i++)
	{
		DummyAlarms[i].AlarmOffEffects();
	}

}

function DisableAlarm()
{
	local int i;
	if(GetStateName()=='AlarmDisabled')
		return;

	GotoState('AlarmDisabled');
	SetAllButtonsDisabled();
	for(i=0;i<DummyAlarms.Length;i++)
	{
		DummyAlarms[i].AlarmOffEffects();
	}

}

event TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	if(bDummyAlarm) return;

	switch(handler)
	{
	case hTurnAlarmOn:
		TurnAlarmOn();
		break;
	case hTurnAlarmOff:
		TurnAlarmOff();
		break;
	case hDisableAlarm:
		DisableAlarm();
		break;

	}


}

defaultproperties
{
     AlarmSound=Sound'PariahGameSounds.alarm.AlarmB'
     AlarmOnMat=Shader'PariahGameTypeTextures.alarm.alarm_on_shader'
     AlarmOffMat=Shader'PariahGameTypeTextures.alarm.alarm_bell_off'
     hTurnAlarmOn="TurnAlarmOn"
     hTurnAlarmOff="TurnAlarmOff"
     hDisableAlarm="DisableAlarm"
     StaticMesh=StaticMesh'PariahGametypeMeshes.alarm.alarm_bell'
     DrawType=DT_StaticMesh
     bHasHandlers=True
}
