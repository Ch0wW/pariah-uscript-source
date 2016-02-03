class MenuAddVoiceAttachment extends MenuTemplateTitledBA;

// mjm - for recording voicemail attachments

var() int AttachmentState;
var() MenuButtonText Options[6];

var() localized String StringRecording;
var() localized String StringPlaying;
var() localized String StringInfo;

var() MenuText StateText;
var() MenuText TimeText;
var() MenuText InfoText;

var() WidgetLayout InfoLayout;
var() String XBLiveRequest;

var() transient int StateMsgPulse;
var() int StateMsgPulseSpeed;
var() int VmailDuration;

/*
    Voicemail state commands:
    1 - setup (called outside of this class)
    2 - play
    3 - record
    4 - stop
    5 - erase
    6 - return current state
    7 - reset back to rgular voice chat mode (on exit)
*/

// Our custom enum for menu states

var() enum EVoicemailMenu
{
    VM_NoneStopped,     // nothing recorded and we're stopped
    VM_Recording,
    VM_SomeStopped,     // something recorded and we're stopped
    VM_Playing
} VMEnum;
var() EVoicemailMenu OldVMEnum;

simulated function Init( String Args )
{
    // The actual init for the voicemail is done in the previous menu, which will completely
    // skip over this page if the user is not allowed to send voice commands    
    
    XBLiveRequest = Args;

    Super.Init( Args );
    SetTimer(0.25,true);    // For our state change

    InfoText.Text = StringInfo;

    SetVisible('OnRecord', true);
    SetVisible('OnStop', false);
    SetVisible('OnPlay', false);
    SetVisible('OnErase', false);
    SetVisible('OnSubmit', false);
    SetVisible('OnContinue', true);
    FocusOnWidget(Options[0]);
}

simulated function DoDynamicLayout( Canvas C )
{
    Super.DoDynamicLayout( C );
    LayoutArray( Options[0], 'TitledOptionLayout' );
    LayoutWidgets( StateText, TimeText, 'InfoLayout' );
}

// Only used for our throbbing state message
simulated function Tick( float DT )
{
    StateMsgPulse += StateMsgPulseSpeed;
    
    if (StateMsgPulse >= 255)
    {
        StateMsgPulse = 255;
        StateMsgPulseSpeed *= -1;
    }
    else if (StateMsgPulse < 127)
    {
        StateMsgPulse = 127;
        StateMsgPulseSpeed *= -1;
    }
    
    StateText.DrawColor.A = StateMsgPulse;    
}

// Based on the state, show whether or not we are recording anything or have recorded something.
simulated function Timer()
{
    local int VoicemailState;
    VoicemailState = int(ConsoleCommand("VOICEMAIL Cmd=6"));

    if (VoicemailState == 2)
    {
        StateText.Text = StringRecording;
        TimeText.Text = "";
    }    
    else if (VoicemailState == 1)
    {
        StateText.Text = StringPlaying;
        TimeText.Text = "";
    }
    else
    {
        StateText.Text = "";

        // Best to do this in the timer when we know we're stopped since there's a delay for processing of the voicemail
        VmailDuration = int(ConsoleCommand("VOICEMAIL Cmd=8"));

        if (VmailDuration > 0)
        {
            VMEnum = VM_SomeStopped;
            TimeText.Text = (float(VMailDuration) / 1000.0) @ "sec";
        }
        else
        {
            VMEnum = VM_NoneStopped;
            TimeText.Text = "";
        }
    }

    // Hot damn! State changes!!

    if (OldVMEnum != VMEnum)
    {
        if (VMEnum == VM_NoneStopped)
        {
            SetVisible('OnRecord', true);
            SetVisible('OnStop', false);
            SetVisible('OnPlay', false);
            SetVisible('OnErase', false);
            SetVisible('OnSubmit', false);
            SetVisible('OnContinue', true);
            FocusOnWidget(Options[0]);
        }
        else if (VMEnum == VM_SomeStopped)
        {
            SetVisible('OnRecord', false);
            SetVisible('OnStop', false);
            SetVisible('OnPlay', true);
            SetVisible('OnErase', true);
            SetVisible('OnSubmit', true);
            SetVisible('OnContinue', false);        
            FocusOnWidget(Options[2]);
        }
        else if (VMEnum == VM_Recording)
        {
            SetVisible('OnRecord', false);
            SetVisible('OnStop', true);
            SetVisible('OnPlay', false);
            SetVisible('OnErase', false);
            SetVisible('OnSubmit', false);
            SetVisible('OnContinue', false);
            FocusOnWidget(Options[1]);
        }
        else if (VMEnum == VM_Playing)
        {
            SetVisible('OnRecord', false);
            SetVisible('OnStop', true);
            SetVisible('OnPlay', false);
            SetVisible('OnErase', false);
            SetVisible('OnSubmit', false);
            SetVisible('OnContinue', false);   
            FocusOnWidget(Options[1]);
        }
        OldVMEnum = VMEnum;
    }
}

// Stop our voicemail
simulated function OnStop()
{  
    ConsoleCommand("VOICEMAIL Cmd=4");    
}

// Erase our voicemail
simulated function OnErase()
{
    ConsoleCommand("VOICEMAIL Cmd=5");
    VMEnum = VM_NoneStopped;
}

// Play our voicemail
simulated function OnPlay()
{
    ConsoleCommand("VOICEMAIL Cmd=2");
    VMEnum = VM_Playing;
}

// Record our voicemail
simulated function OnRecord()
{
    ConsoleCommand("VOICEMAIL Cmd=3");
    VMEnum = VM_Recording;
}

// Just go forward without recording anything
simulated function OnContinue()
{
    ConsoleCommand("VOICEMAIL Cmd=5");  // erase data
    ConsoleCommand("VOICEMAIL Cmd=7");  // change back to other state
    SubmitRequest();
}

// Continue to XBLive message - succesfull exit forward
simulated function OnSubmit()
{
    ConsoleCommand("VOICEMAIL Cmd=7");  // change back to other state
    SubmitRequest();
}

// This is where we actually send our request (game invite or friend request)
simulated function SubmitRequest()
{
    if("SUCCESS" != ConsoleCommand(XBLiveRequest))
    {
        if (InStr(XBLiveRequest, "INVITE SEND GAMERTAG") == 0)
            OverlayErrorMessageBox( "FRIEND_INVITE_SEND_FAILED" );
        else if (InStr(XBLiveRequest, "PLAYER ADDFRIEND GAMERTAG") == 0)
            OverlayErrorMessageBox( "FRIEND_REQUEST_FAILED" );
    }
    else
    {
        CloseMenu();
    }
}

// On the way out (via cancel), put the state back to the way it was, and delete any data
simulated function HandleInputBack()
{    
    ConsoleCommand("VOICEMAIL Cmd=5");  // erase data
    ConsoleCommand("VOICEMAIL Cmd=7");  // change back to other state
    Super.HandleInputBack();
}

defaultproperties
{
     Options(0)=(Blurred=(Text="Record"),HelpText="Record your voice attachment.",OnSelect="OnRecord",Style="TitledTextOption")
     Options(1)=(Blurred=(Text="Stop"),HelpText="Stop recording or playing.",OnSelect="OnStop")
     Options(2)=(Blurred=(Text="Play"),HelpText="Listen to your voice attachment.",OnSelect="OnPlay")
     Options(3)=(Blurred=(Text="Erase"),HelpText="Erase your voice attachment.",OnSelect="OnErase")
     Options(4)=(Blurred=(Text="Send message"),HelpText="Submit your voice attachment.",OnSelect="OnSubmit")
     Options(5)=(Blurred=(Text="Skip message"),HelpText="Continue with no voice attachment.",OnSelect="OnContinue")
     StringRecording="Recording Attachment..."
     StringPlaying="Playing Attachment..."
     StringInfo="You may record an optional voice attachment to go along with your Xbox Live request."
     StateText=(DrawPivot=DP_MiddleRight,Style="NormalLabel")
     TimeText=(DrawPivot=DP_MiddleRight,Style="NormalLabel")
     InfoText=(DrawPivot=DP_MiddleLeft,PosX=0.100000,PosY=0.750000,MaxSizeX=0.800000,bWordWrap=1,Style="NormalLabel")
     InfoLayout=(PosX=0.900000,PosY=0.300000,SpacingY=0.050000,BorderScaleX=0.400000,Pivot=DP_UpperRight)
     StateMsgPulseSpeed=5
     MenuTitle=(Text="Add a Voice Attachment")
     ReservedNames(1)="Default"
     ReservedNames(2)="New"
     ReservedNames(3)="Player"
     ReservedNames(4)="Pariah"
     ReservedNames(5)="Build"
     ReservedNames(6)="Default"
     ReservedNames(7)="DefPariahEd"
     ReservedNames(8)="DefUser"
     ReservedNames(9)="Manifest"
     ReservedNames(10)="MiniEdLaunch"
     ReservedNames(11)="MiniEdUser"
     ReservedNames(12)="PariahEd"
     ReservedNames(13)="PariahEdTips"
     ReservedNames(14)="Running"
     ReservedNames(15)="TEMP"
     ReservedNames(16)="User"
}
