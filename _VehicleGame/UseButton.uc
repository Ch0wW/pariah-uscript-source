class UseButton extends GameplayDevices
	placeable;


var() enum EUseButtonType
{
	UBT_Toggle,
	UBT_TimedRevert,
	UBT_OneUse,
	UBT_ToggleOnOnly,
	UBT_ToggleOffOnly
} UseButtonType;


var() enum EUseButtonState
{
	UBS_On,
	UBS_Off,
	UBS_Disabled
} UseButtonState;

var EUseButtonState OriginalState;

var() float RevertTime;

var() Name OnEvent;
var() Name OffEvent;
var() Name DisableEvent;

var Sound OnSound, OffSound, DisableSound, NotUsableSound;

var() Sound	BlackBoxSound;

var Material OnMat, OffMat, DisabledMat;

var bool bReverting;

var(Events) const editconst Name hTurnOn;
var(Events) const editconst Name hTurnOff;
var(Events) const editconst Name hDisable;
var(Events) const editconst Name hTurnOnWithoutEvent;
var(Events) const editconst Name hTurnOffWithoutEvent;
var(Events) const editconst Name hDisableWithoutEvent;

var int SwapMatIndex;

function PostBeginPlay()
{
	OriginalState = UseButtonState;
	switch(UseButtonState)
	{
	case UBS_On:
		InitialState='On';
		break;
	case UBS_Off:
		InitialState='Off';
		break;
	case UBS_Disabled:
		InitialState='Disabled';
		break;
	}
	
}

auto state On
{
	function BeginState()
	{
		UseButtonState = UBS_On;
		SetSkin(SwapMatIndex,OnMat);
	}


	function UsedBy(Pawn P)
	{
		if(bReverting) return;


		switch(UseButtonType)
		{
		case UBT_TimedRevert:
			SetTimer(RevertTime,false);
			bReverting=true;
		case UBT_Toggle:
			ButtonOff(P);
			break;
		case UBT_OneUse:
			ButtonDisable(P);
			break;
		case UBT_ToggleOnOnly:
			break;
		case UBT_ToggleOffOnly:
			ButtonOff(P);
			break;		
		}
	}

	event Timer()
	{
		//if timer, revert to off
		bReverting=false;
		ButtonOff(None);
	}
}

function ButtonDisable(Pawn P, optional bool bNoEvent)
{
	if(UseButtonState == UBS_Disabled)
		return;

	if(!bNoEvent)
		TriggerEvent(DisableEvent, self, P);
	if(DisableSound!= None)
		PlaySound(DisableSound);
	GotoState('Disabled');

}

function ButtonOff(Pawn P, optional bool bNoEvent)
{
	if(UseButtonState == UBS_Off)
		return;
		
	if(BlackBoxSound != None)
	{
		P.PlayOwnedSound(BlackBoxSound, SLOT_Interface);
	}

	if(!bNoEvent)
		TriggerEvent(OffEvent, self, P);
	if(OffSound!=None)
		PlaySound(OffSound);
	GotoState('Off');
}


function ButtonOn(Pawn P, optional bool bNoEvent)
{
	if(UseButtonState == UBS_On)
		return;

	if(!bNoEvent)
		TriggerEvent(OnEvent, self, P);
	if(OnSound!=None)
		PlaySound(OnSound);
	GotoState('On');
}

state Off
{
	function BeginState()
	{
		UseButtonState = UBS_Off;
		SetSkin(SwapMatIndex,OffMat);
	}


	function UsedBy(Pawn P)
	{
		if(bReverting) return;
		switch(UseButtonType)
		{
		case UBT_TimedRevert:
			SetTimer(RevertTime,false);
			bReverting=true;
		case UBT_Toggle:
			ButtonOn(P);
			break;
		case UBT_OneUse:
			ButtonDisable(P);
			break;
		case UBT_ToggleOnOnly:
			ButtonOn(P);
			break;
		case UBT_ToggleOffOnly:
			break;		
		}
	}

	event Timer()
	{
		//if timer, revert to On
		bReverting=false;
		ButtonOn(None);
	}
}

state Disabled
{
	function BeginState()
	{
		UseButtonState = UBS_Disabled;
		SetSkin(SwapMatIndex,DisabledMat);
	
	}


	function UsedBy(Pawn P)
	{
		if(NotUsableSound != None)
			PlaySound(NotUsableSound);
	}

}

function TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	switch(handler)
	{
	case hTurnOn:
		ButtonOn(instigator);
		break;
	case hTurnOff:
		ButtonOff(instigator);
		break;
	case hDisable:
		ButtonDisable(instigator);
		break;
	case hTurnOnWithoutEvent:
		ButtonOn(instigator,true);
		break;
	case hTurnOffWithoutEvent:
		ButtonOff(instigator,true);
		break;
	case hDisableWithoutEvent:
		ButtonDisable(instigator,true);
		break;
	}
}

defaultproperties
{
     SwapMatIndex=1
     OnSound=Sound'PariahGameSounds.Buttons.ButtonPressH'
     OffSound=Sound'PariahGameSounds.Buttons.ButtonPressG'
     DisableSound=Sound'PariahGameSounds.Buttons.ButtonPressF'
     NotUsableSound=Sound'PariahGameSounds.Buttons.ButtonDisabled'
     OnMat=Shader'PariahGameTypeTextures.neutral.button_green_shader'
     OffMat=Shader'PariahGameTypeTextures.neutral.button_red_shader'
     DisabledMat=Shader'PariahGameTypeTextures.neutral.button_disabled_shader'
     hTurnOn="TURNON"
     hTurnOff="TURNOFF"
     hDisable="Disable"
     hTurnOnWithoutEvent="TURNONWITHOUTEVENT"
     hTurnOffWithoutEvent="TURNOFFWITHOUTEVENT"
     hDisableWithoutEvent="DISABLEWITHOUTEVENT"
     StaticMesh=StaticMesh'PariahGametypeMeshes.neutral.Button'
     DrawType=DT_StaticMesh
     bWorldGeometry=True
     bHasHandlers=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bBlockKarma=True
     bUsable=True
}
