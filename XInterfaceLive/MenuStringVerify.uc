class MenuStringVerify extends MenuTemplateTitledB
    abstract;

/*	XBox Live String Verify Intermediate Menu

	Queries XBox Live with the given string (map name, profile name, etc) to see it
	contains any objectional content.
	
	Users should derive a menu from this one and implement OnValid() and OnClose()
*/

var() MenuText          Message;
var() MenuText          ErrorMessage;

var() String            NameToVerify;

// Pass in the name which we want to check

simulated function Init( String Args )
{
    NameToVerify = ParseToken( Args );
    
    Super.Init(Args);
    
    if (int(ConsoleCommand("XLIVE STRINGVERIFY START String=\"" $ NameToVerify $ "\"")) == 0)
    {
        log("ERROR: String Verify start trask failed.");
        OnCancel();
        return;
    }
    SetTimer(0.25,true);    // Pump, pump, pump that task!
}

simulated function Timer()
{
    local int ReturnCode;
    
    ReturnCode = int(ConsoleCommand("XLIVE STRINGVERIFY PROCESS"));

    if (ReturnCode == 0)    // We've finished, and the name is illegal
    {
        Message.bHidden = 1;
        ErrorMessage.bHidden = 0;
        SetTimer(0.0,false);
    }
    else if (ReturnCode == 1)
    {
        SetTimer(0.0,false);
        OnValid();      
    }
}

simulated function HandleInputBack()
{
    SetTimer(0.0,false);
    OnCancel();
}

simulated function OnValid();
simulated function OnCancel();

defaultproperties
{
     Message=(Text="Verifying Name...",Style="MessageText")
     ErrorMessage=(Text="The text entered appears to contain offensive language and is not allowed.\n\nSee the Xbox Live Code of Conduct for more information.",bHidden=1,Style="MedMessageText")
     MenuTitle=(Text="Verifying Name")
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
