class SPObjectiveList extends SinglePlayerTriggers
	native
	exportstructs;

#exec Texture Import File=Textures\objectives.pcx Name=ObjectivesIcon Mips=Off MASKED=1

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

struct SubObjectiveInfo
{
    var() name				ObjectiveCompleteEvent;
    var() name				EnableEvent;
    var() localized string	ObjectiveMessage;
    var bool				Enabled;
    var bool				bObjectiveComplete;
};

const MaxObjectives = 10;
const MaxSubObjectives = 10;

struct ObjectiveInfo
{
    var() name						ObjectiveCompleteEvent;                  
    var() localized string			ObjectiveMessage;
    var bool						bObjectiveComplete;
    var array<SubObjectiveInfo>		SubObjectives;							// obsolete
    var() SubObjectiveInfo			SubObjectiveArray[MaxSubObjectives];	// need fixed arrays for localization
};

var() Name					StartEvent;
var array<ObjectiveInfo>	Objectives;										// obsolete
var() ObjectiveInfo			ObjectiveArray[MaxObjectives];					// need fixed array for localization

var const Name              ObjectiveComplete;
var bool                    bStarted;

var localized string        Thumbsticks;
var string                  MoveControlsPC;
var string                  VehicleControlsPC;

var transient DecoText      WrappedText;

const WaitForSPCTimer = 0;

simulated function bool TextButtonReplace(out string Text)
{
    local int open, close;
    local string tmp;
    local String Command, CommaKeys, InsertText;
    local int jesus;
    local PlayerController PC;
    local String LocalizedMouse;
    
    PC = GetPlayerController();  

    for(jesus = 0; jesus < 10; jesus++) // keep replacing till none left, or the second coming
    {
        // parse out command
        open = InStr(Text, "<");
        if(open < 0)
            return false;

        close = InStr(Text, ">");
        if(close < 0)
            return false;

        Command = Mid(Text, open + 1, close - open - 1);

        // translate command to key
        if(Command == "LOOK AND MOVE")
        {
            if( IsOnConsole() )
            {
				InsertText = default.Thumbsticks;
            }
            else
            {
                InsertText = default.MoveControlsPC;
                InsertText = ReplaceSubstring( InsertText, "MoveForward", class'Fonts_rc'.static.LocalizedDescribeBinding( GetPlayerController().ConsoleCommand("BINDINGTOKEY MoveForward"), PC ) );
                InsertText = ReplaceSubstring( InsertText, "StrafeLeft", class'Fonts_rc'.static.LocalizedDescribeBinding( GetPlayerController().ConsoleCommand("BINDINGTOKEY StrafeLeft"), PC ) );
                InsertText = ReplaceSubstring( InsertText, "StrafeRight", class'Fonts_rc'.static.LocalizedDescribeBinding( GetPlayerController().ConsoleCommand("BINDINGTOKEY StrafeRight"), PC ) );
                InsertText = ReplaceSubstring( InsertText, "MoveBackward", class'Fonts_rc'.static.LocalizedDescribeBinding( GetPlayerController().ConsoleCommand("BINDINGTOKEY MoveBackward"), PC ) );
            }
        }
        else if(Command == "DRIVE VEHICLE")
        {
            if( IsOnConsole() )
            {
				InsertText = default.Thumbsticks;
            }
            else
            {
                InsertText = default.VehicleControlsPC;
                
                // horrible hack to get localized name for mouse
                LocalizedMouse = class'LocalizedKeys'.static.LocalizeKeyIndex( 228 );
				LocalizedMouse = Left( LocalizedMouse, Len(LocalizedMouse) - 1 );
                
                InsertText = ReplaceSubstring( InsertText, "SteerM", LocalizedMouse );
                InsertText = ReplaceSubstring( InsertText, "MoveForward", class'Fonts_rc'.static.LocalizedDescribeBinding( GetPlayerController().ConsoleCommand("BINDINGTOKEY MoveForward"), PC ) );
                InsertText = ReplaceSubstring( InsertText, "MoveBackward", class'Fonts_rc'.static.LocalizedDescribeBinding( GetPlayerController().ConsoleCommand("BINDINGTOKEY MoveBackward"), PC ) );
            }
        }
        else
        {
            CommaKeys = GetPlayerController().ConsoleCommand("BINDINGTOKEY "$Command);
                       
            if(CommaKeys == "")
            {
                CommaKeys = Command;
            }

            // translate key to button character
            InsertText = class'Fonts_rc'.static.DescribeBinding( CommaKeys, PC );
            
            if( InsertText == "" )
            {
                InsertText = "(" $ CommaKeys $ ")";
            }            
        }
        
        log( "Substituting" @ InsertText @ "for" @ Command, 'Log' );

        // paste it back
        tmp = Text;
        Text = Left(tmp, open) $ InsertText $ Right(tmp, Len(tmp) - close - 1);
    }
}

function HookSubObjectives(out ObjectiveInfo info) // sjs
{
    local int sub;
    
    for( sub=0; sub < MaxSubObjectives; sub++ )
    {
        if( info.SubObjectiveArray[sub].ObjectiveCompleteEvent == 'None' )
        {
            continue;
        }
        
        if(info.SubObjectiveArray[sub].EnableEvent == 'None')
        {
            info.SubObjectiveArray[sub].Enabled = true;
        }
        else
        {
            info.SubObjectiveArray[sub].Enabled = false;
            AppendEventBinding(info.SubObjectiveArray[sub].EnableEvent, ObjectiveComplete);
        }

        AppendEventBinding(info.SubObjectiveArray[sub].ObjectiveCompleteEvent, ObjectiveComplete);
    }
}

event PostBeginPlay()
{
    local int o;

    Super.PostBeginPlay();

    // setup handler for start event
    if( StartEvent != 'None' )
    {
        AppendEventBinding(StartEvent, StartEvent);
    }

    // setup handlers for objective complete events
    for( o=0; o < MaxObjectives; o++ )
    {
        HookSubObjectives(ObjectiveArray[o]);
        if( ObjectiveArray[o].ObjectiveCompleteEvent == 'None' )
        {
            continue;
        }
        AppendEventBinding(ObjectiveArray[o].ObjectiveCompleteEvent, ObjectiveComplete);
    }
}

function PlayerController GetPlayerController()
{
    return Level.GetLocalPlayerController();
}

function Timer()
{
    // If we haven't got a PC, wait for a little bit:
    if( GetPlayerController() == None )
    {
        SetTimer( 0.2, false );
        return;
    }

    // If we've got a PC but havn't started yet, startup but delay display of objectives:
    if( !bStarted )
    {
        bStarted = true;
        SetTimer( 2, false );
        return;
    }

    DisplayCurrentObjective( true );
}

function TidyText( out String Text )
{
    local String E;

    if( Text == "" )
    {
        return;
    }

    // Chop trailing whitespace.
    while(true)
    {
        E = Right( Text, 1 );
        
        if( E == " " )
        {
            Text = Left( Text, Len( Text ) - 1 );
        }
        else
        {
            break;
        }
    }

    E = Right( Text, 1 );
    
    if( (E != ".") && (E != "!") && (E != "?") )
    {
        Text = Text $ ".";
    }
}

function DisplayCurrentObjective( bool AutoHide )
{
    local int Obj;
    local int SubObj;
    local PlayerController PC;
    local MenuObjectives Overlay;
    local String PrimaryObjText;
    local String SubObjText;

    if( !bStarted )
    {
        log( "Can't display current objective; not started!", 'Log' );
        return;
    }
    
    PC = GetPlayerController();
    
    if( PC == None )
    {
        log( "Can't display current objective; no player controller!", 'Log' );
        return;
    }
    if( PC.MyHUD == None )
    {
        log( "Can't display current objective; no HUD!", 'Log' );
        return;
    }

    for( Obj = 0; Obj < MaxObjectives; ++Obj )
    {
        if
        (
            (ObjectiveArray[Obj].ObjectiveCompleteEvent != 'None') &&
            (!ObjectiveArray[Obj].bObjectiveComplete) 
        )
        {
            PrimaryObjText = ObjectiveArray[Obj].ObjectiveMessage;
            break;
        }
    }
    
    if( Obj >= MaxObjectives )
    {
        log( "Can't display current objective; no more objectives.", 'Log' );
        return;
    }

    for( SubObj = 0; SubObj < MaxSubObjectives; ++SubObj )
    {
        if
        (
            ObjectiveArray[Obj].SubObjectiveArray[SubObj].Enabled &&
            !ObjectiveArray[Obj].SubObjectiveArray[SubObj].bObjectiveComplete
        )
        {
            SubObjText = ObjectiveArray[Obj].SubObjectiveArray[SubObj].ObjectiveMessage;
            break;
        }
    }

    if( PC.MyHud.ObjectivesMenu == None )
    {
        PC.MyHud.ObjectivesMenu = Spawn( class'XInterfaceCommon.MenuObjectives', PC );
    }

    Overlay = MenuObjectives( PC.MyHud.ObjectivesMenu );
    Assert( Overlay != None );

    TidyText( PrimaryObjText );
    TidyText( SubObjText );
    
    log( "Primary Objective:" @ PrimaryObjText, 'Log' );
    
    if( Len(SubObjText) > 0 )
    {
        log( "Sub-objective:" @ SubObjText, 'Log' );
    }
    
    TextButtonReplace( PrimaryObjText );
    TextButtonReplace( SubObjText );
    
    Overlay.ShowObjectives( PrimaryObjText, SubObjText, AutoHide );
}

function TriggerEx(Actor Other, Pawn EventInstigator, Name Handler, Name RealEvent)
{
    local int Obj;

    if( Handler == StartEvent)
    {
        if( !bStarted )
        {
            // We can't start until we get a SinglePlayerController;
            // the timer callback will check for one and defer startup if needed.
            Timer();
        }

        return;
    }
    
    if( !bStarted )
    {
        return;
    }
    
    if( Handler == ObjectiveComplete )
    {
        for( Obj = 0; Obj < MaxObjectives; Obj++ )
        {
            if( ObjectiveArray[Obj].ObjectiveCompleteEvent != 'None' && !ObjectiveArray[Obj].bObjectiveComplete )
            {
                break;
            }
        }

		if( Obj < MaxObjectives )
		{
			if( RealEvent == ObjectiveArray[Obj].ObjectiveCompleteEvent )
			{
				ObjectiveArray[Obj].bObjectiveComplete = true;
				DisplayCurrentObjective( true );
			}
			else
			{
				if(CheckSubObjective(ObjectiveArray[Obj], RealEvent)) // sjs
				{
					DisplayCurrentObjective( true );
				}
			}
		}
    }
}

function bool CheckSubObjective(out ObjectiveInfo info, Name inEvent) // sjs
{
    local int sub;
    local bool showMsg;
    
    showMsg = false;
    // we allow fall-through to enable and complete multiple subobjectives
    for(sub = 0; sub < MaxSubObjectives; ++sub)
    {
        if(!info.SubObjectiveArray[sub].Enabled && info.SubObjectiveArray[sub].EnableEvent == inEvent)
        {
            // enable it!
            info.SubObjectiveArray[sub].Enabled = true;
            showMsg = true;
        }
        else if(info.SubObjectiveArray[sub].Enabled && info.SubObjectiveArray[sub].ObjectiveCompleteEvent == inEvent)
        {
            info.SubObjectiveArray[sub].bObjectiveComplete = true;
        }
    }
    return(showMsg);
}

defaultproperties
{
     ObjectiveComplete="ObjectiveComplete"
     Thumbsticks="the thumbsticks"
     MoveControlsPC="MoveForward, StrafeLeft, StrafeRight, MoveBackward"
     VehicleControlsPC="MoveForward, MoveBackward, SteerM"
     Texture=Texture'PariahSP.ObjectivesIcon'
     bHasHandlers=True
}
