class MenuWarningTransition extends MenuTemplateTitled
    abstract;

enum ETimerType
{
    ETT_None,
    ETT_Start,
    ETT_Work,
    ETT_Hold,
    ETT_WaitToClose,
};

var ETimerType  mTimerType;
var MenuText    mMessage;
var float       mHoldTime;
var float       mStartTime;
var float       mActualTransitionTime;
var Name        mCallbackName;
var Object      mCallbackObject;


simulated function DrawMenu(Canvas C, bool HasFocus)
{
    Super.DrawMenu(C, HasFocus);

    if (CrossFadeLevel >= 1.f && mTimerType == ETT_None)
    {
        mTimerType = ETT_Start;
        SetTimer(mStartTime, false); // don't want to do real work during render loop
    }
}

simulated function DoWork()
{
    DoCallback();
}

simulated function DoCallback()
{
    if(mCallbackName == '' || mCallbackObject == None)
    {
        return;
    }
    
    if(!Callback(mCallbackName, mCallbackObject))
    {
        log(self@" Could not process callback "$mCallbackObject$"."$mCallbackName, 'WARNING');
    }
}

simulated function Timer()
{
    local float timeRemaining;
    
    switch(mTimerType)
    {
        case ETT_Start:
            SetTimer(0.01, false);
            mTimerType = ETT_Work;
            StopWatch();
            DoWork();
            break;
        
        case ETT_Work:
            mActualTransitionTime = StopWatch("MenuWarningTransition", true);
            timeRemaining = mHoldTime - mActualTransitionTime;
            log(self$" mActualTransitionTime="$mActualTransitionTime);
            log(self$" Time Left="$timeRemaining);
            if(timeRemaining > 0.f)
            {
                SetTimer(timeRemaining, false);
                mTimerType = ETT_Hold;
                break;
            }
            // else fall-through
        
        case ETT_Hold:
            Done();
            break;
        
        case ETT_WaitToClose:
            DoClose();
            break;
        
        default:
            assert(false);
    }
}

simulated function Done()
{
    DoClose();
}

simulated function DoClose()
{
    local Menu top;
    top = PlayerController(Owner).Player.Console.CurMenu;
    if(top == self)
    {
        CloseMenu();
    }
    else
    {
        SetTimer(0.01, false);
        mTimerType = ETT_WaitToClose;
    }
}

simulated function HandleInputStart()
{
}

simulated function HandleInputBack()
{
}

defaultproperties
{
     mMessage=(Text="Doing stuff",Style="MessageText")
     mHoldTime=1.000000
     mStartTime=0.000010
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
