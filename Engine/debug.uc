class debug extends PlayerController
	native;

/*==========================================================================

The following /*exec*/ functions are defined to help debug:
  
GetN <package>.<class>
GetN <class>
    Gets the names of all the objects of the specified class. 
        Example: getn engine.pawn
    If you know the most derived class, you can leave out the package.
        Example: getn buzzkill

GetP <objname> <property>
    Gets the property of the object.
        Example: getp buzzkill0 location
    You can also specify the object through other objects.
        Example: getp buzzkill0.weapon name

GetS <objname>
    Gets the state of the object.
        Example: gets buzzkill0 
    You can also specify the object through other objects.
        Example: gets buzzkill0.weapon 

Watch <objname> <property>
    Watch the property of the object.
        Example: watch buzzkill0 location
    You can also specify the object through other objects.
        Example: watch buzzkill0.weapon name
    Note: The special property State (not actually a property) 
          will show the object state

UnWatch <index>
    Unwatch the object property with index <index> (shown on HUD).
        Example: unwatch 5
    You can also unwatch all.
        Example: unwatch -1

WatchOn
    Turn watching on. On by default when there is something to watch.

WatchOff
    Turn watching off. Off when there is nothing to watch.

TODO: -Remove this file before shipping!!!!!
==========================================================================*/


const           mObjMax = 32;
const           mServerUpdateFreq = 25;

var     Object  maObjList[mObjMax];
var     string  maPropList[mObjMax];
var     int     mabShowState[mObjMax];

var     int     maServerVar[mObjMax];
var     string  maServerText[mObjMax];
var     int     mServerIdx;
var     int     mUpdateCount;

var     int     mObjCnt;
var()   bool    mbWatchEnabled;
var()   color   mDrawColor;
var()   string  mInfoText;
var()   vector  mInfoPos;
var()   vector  mWatchPos;


var() vector    mShRotMag;
var() vector    mShRotRate;
var() float     mShRotTime;
var() vector    mShOffsetMag;
var() vector    mShOffsetRate;
var() float     mShOffsetTime;


// sjs ---
var(CubeMap) Rotator    CubeMapRotations[6];
var(CubeMap) float      CubeMapFOV; 
var(CubeMap) float      CubeMapDelay;
var(CubeMap) transient int        CubeMapStage;
var(CubeMap) transient Name       CubeMapPrevState;
var(CubeMap) transient Rotator    CubeMapPrevRotation;
// --- sjs


/*
replication
{
	// server->client
	reliable if (Role==ROLE_Authority)
		DrawText, WatchOn, WatchOff, maServerText;

	// client->server
	reliable if (Role<ROLE_Authority)
		SGetS, SGetN, SGetP, SSetP, SCount, SCommand, ServerWatch, ServerUnWatch, RequestUpdate;
}*/


// amb: debug fun
function DrawText( string text )
{
    if (mInfoText == "")
        mInfoText = text;
    else
        mInfoText = mInfoText $ " ... " $ text;
    log(mInfoText, 'DEBUG_OUTPUT');
}

function string StateText(int i)
{
    return (maObjList[i].name$".State="$maObjList[i].GetStateName());
}

function string VarText(int i)
{
    return (maObjList[i].name$"."$maPropList[i]$"="$maObjList[i].GetPropertyText(maPropList[i]));
}

// this should only be done every second or so...
function RequestUpdate(int i)
{
    if (mabShowState[i] == 1)
        maServerText[i] = StateText(i);
    else
        maServerText[i] = VarText(i);
}

function RenderOverlays( canvas Canvas )
{
    local int   i;
	local float OldOrgX;
	local float OldOrgY;
    local color OldColor;
    local font  OldFont;
    local bool  bRequestUpdate;

    Super.RenderOverlays(Canvas);

    // save old settings
    OldOrgX  = Canvas.OrgX;
    OldOrgY  = Canvas.OrgY;
    OldColor = Canvas.DrawColor;
    OldFont  = Canvas.Font;

    // setup canvas
    Canvas.DrawColor = mDrawColor;
	Canvas.Font = Canvas.SmallFont;
	Canvas.Style = ERenderStyle.STY_Normal;
    Canvas.SetOrigin(0.f, 0.f);
    Canvas.SetPos(mInfoPos.X, mInfoPos.Y);

    Canvas.Drawtext(mInfoText);

    if (mbWatchEnabled)
    {      
        Canvas.SetPos(mWatchPos.X, mWatchPos.Y);

        bRequestUpdate = (mUpdateCount++ % mServerUpdateFreq == 0);

        for (i=0; i<mObjMax; i++)
        {
            if (maObjList[i] != None)
            {
                Canvas.SetPos(mWatchPos.X, Canvas.CurY);

                if (mabShowState[i] == 1)
                {
                    if (maServerVar[i] == 1)
                    {
                        Canvas.Drawtext(i$") (Server) "$maServerText[i]);
                        if (bRequestUpdate)
                            RequestUpdate(i);
                    }
                    else
                    {
                        Canvas.Drawtext(i$") "$StateText(i));
                    }
                }
                else
                {
                    if (maServerVar[i] == 1)
                    {
                        Canvas.Drawtext(i$") (Server) "$maServerText[i]);
                        if (bRequestUpdate)
                            RequestUpdate(i);
                    }
                    else
                    {
                        Canvas.Drawtext(i$") "$VarText(i));
                    }
                }
            }
        }
    }

    // restore settings
    Canvas.SetOrigin(OldOrgX, OldOrgY);
    Canvas.DrawColor = OldColor;
    Canvas.Font = OldFont;
}

//=============================================================================


/*exec*/ function shakeit()
{
    ShakeView(mshRotMag,    mshRotRate,    mshRotTime, 
              mshOffsetMag, mshOffsetRate, mshOffsetTime);
}


//=============================================================================

/*exec*/ function CubeShot()
{
    CubeMapPrevState = GetStateName();
    CubeMapPrevRotation = Rotation;
    GotoState('CubeMapShots');
}

state CubeMapShots
{
    ignores SeePlayer, HearNoise, KilledBy, SwitchWeapon, PlayerMove;
    
    function Timer()
	{
        ConsoleCommand("SHOT");
        CubeMapStage++;
        if( CubeMapStage > 5 )
        {
            GotoState(CubeMapPrevState);
        }
        else
        {
            SetRotation(CubeMapRotations[CubeMapStage]);
        }
    }

    function BeginState()
	{
		local SavedMove Next;

        CubeMapStage = 0;
		Enemy = None;
		bBehindView = false;
		bFrozen = true;
		bPressedJump = false;
        bZeroRoll = false;
		SetTimer(CubeMapDelay, true);
		// clean out saved moves
		while ( SavedMoves != None )
		{
			Next = SavedMoves.NextMove;
			SavedMoves.Destroy();
			SavedMoves = Next;
		}
		if ( PendingMove != None )
		{
			PendingMove.Destroy();
			PendingMove = None;
		}

        DesiredFOV = CubeMapFOV;
        SetRotation(CubeMapRotations[0]);
        MyHud.bHideHud = true;
        ShowGun();
        ConsoleCommand("ENDFULLSCREEN");
        ConsoleCommand("SETRES 512x512x32");
	}
	
    function EndState()
	{
        DesiredFOV = DefaultFOV;
        bFrozen = false;
        MyHud.bHideHud = false;
        ShowGun();
        bZeroRoll = true;
        SetRotation(CubeMapPrevRotation);
        ConsoleCommand("SETRES 800x600x32");
    }
    
}

//=============================================================================

/*exec*/ function SCommand(string s)
{
    ConsoleCommand(s);
}

/*exec*/ function ResetInfo()
{
    mInfoText = "";
}

/*exec*/ function SetColor(color c)
{
    mDrawColor = c;
}

/*exec*/ function SGetS(string s)
{
	GetS(s);
}

/*exec*/ function GetS(string s)
{
    local Object o;

    if (s == "")
    {
        // Too few args
        DrawText("Usage: GetS <instance_name>");
        return;
    }

    // Get the object
    o = GetObjectByName(s);

    if (o == None)
    {
        // Object not found
        DrawText("Object "$s$" not found.");
        return;
    }

    // Success
    DrawText(s$" State="$o.GetStateName());
}

/*exec*/ function SCount(string s)
{
	Count(s);
}

/*exec*/ function Count(string s)
{
    local Object o;
    local int i;
    local string cName;
    local bool found;
    local class<Object> cType;
    local int count;
    local int objCount;
    local int actorCount;

    // Check input string 
    if (s == "")
    {
        // Too few args
        DrawText("Usage: CountN [<package>.]<class>");
        return;
    }

    cName = s;
    cType = class<Object>(DynamicLoadObject(cName, class'Class'));

    foreach AllObjects( cType, o )
    {
        // Strip off the package name
        s = string(o.class);
        i = InStr(s, ".");
        if (i != -1)
            s = Mid(s, i+1);

        if (Caps(s) == Caps(cName) || o.ClassIsChildOf( o.class, cType ))
        {
            //DrawText("Found:"@string(o.name));
            found = true;
            count++;
        }
        
        objCount++;
        
        if (o.ClassIsChildOf(o.class, class'Actor'))
            actorCount++;
    }

    DrawText("Found:"@count@"of"@cName);
    DrawText("objCount="$objCount);
    DrawText("actorCount="$actorCount);

    // Object not found
    if (!found)
        DrawText("Objects of class "$cName$" not found.");
}

/*exec*/ function SGetN(string s)
{
	GetN(s);
}

/*exec*/ function GetN(string s)
{
    local Object o;
    local int i;
    local string cName;
    local bool found;
    local class<Object> cType;

    // Check input string 
    if (s == "")
    {
        // Too few args
        DrawText("Usage: GetN [<package>.]<class>");
        return;
    }

    cName = s;
    cType = class<Object>(DynamicLoadObject(cName, class'Class'));

    foreach AllObjects( cType, o )
    {
        // Strip off the package name
        s = string(o.class);
        i = InStr(s, ".");
        if (i != -1)
            s = Mid(s, i+1);

        if (Caps(s) == Caps(cName) || o.ClassIsChildOf( o.class, cType ))
        {
            DrawText("Found:"@string(o.name));
            found = true;
        }
    }

    // Object not found
    if (!found)
        DrawText("Objects of class "$cName$" not found.");
}

/*exec*/ function SGetP(string s)
{
	GetP(s);
}

/*exec*/ function GetP(string s)
{
    local Object o;
    local int i;
    local string oName;
    local string pName;

    // The input string s is of the form:
    // object_name object_property
    i = InStr(s, " ");
    if (i != -1)
    {
        // Get the first arg (object)
        oName = Left(s, i);

        // Get the second arg (property)
        pName = Mid(s, i+1);
    }
    else
    {
        // Too few args
        DrawText("Usage: getp <instance_name> <property>");
        return;
    }

    // Get the object
    o = GetObjectByName(oName);

    if (o == None)
    {
        // Object not found
        DrawText("Object "$oName$" not found.");
        return;
    }

    s = "";
    s = o.GetPropertyText(pName);

    if (s == "")
    {
        // Property not found
        DrawText("Property "$pName$" not found.");
        return;
    }

    // Success
    DrawText(oName$"."$pName$"="$s);
}

/*exec*/ function SSetP(string s)
{
	SetP(s);
}

/*exec*/ function SetP(string s)
{
    local Object o;
    local int i;
    local string oName;
    local string pName;
    local string vName;

    // The input string s is of the form:
    // object_name object_property value
    i = InStr(s, " ");
    if (i != -1)
    {
        // Get the first arg (object)
        oName = Left(s, i);

        // Get the rest
        s = Mid(s, i+1);

        i = InStr(s, " ");
        if (i != -1)
        {
            // Get the second arg (property)
            pName = Left(s, i);

            // Get the third arg (value)
            vName = Mid(s, i+1);
        }
        else
        {
            // Too few args
            DrawText("Usage: setp <instance_name> <property> <value>");
            return;
        }
    }
    else
    {
        // Too few args
        DrawText("Usage: setp <instance_name> <property> <value>");
        return;
    }

    // Get the object
    o = GetObjectByName(oName);

    if (o == None)
    {
        // Object not found
        DrawText("Object "$oName$" not found.");
        return;
    }

    if (o.SetPropertyText(pName, vName) == false)
    {
        // Property not found
        DrawText("Property "$pName$" could not be set to "$vName);
        return;
    }

    // Success
    DrawText(oName$"."$pName$"="$vName);
}

function int FindSpace()
{
    local int i;

    for(i=0; i<mObjMax; i++)
    {
        if (maObjList[i] == None)
        {
            return i;
        }
    }

    return -1;
}

/*exec*/ function SWatch(string s)
{
    local int j;

    j = FindSpace();

    if (j < 0)
        return;

    maObjList[j] = self; // just so it's not available
    maServerVar[j] = 1;

    ServerWatch(s, j, ++mObjCnt);
}

function ServerWatch(string s, int j, int cnt)
{
    mObjCnt = cnt;
    mServerIdx = j;
	Watch(s);
    mServerIdx = -1;
}

/*exec*/ function Watch(string s)
{
    local Object o;
    local int i;
    local string oName;
    local string pName;

    // The input string s is of the form:
    // object_name object_property
    i = InStr(s, " ");
    if (i != -1)
    {
        // Get the first arg (object)
        oName = Left(s, i);

        // Get the second arg (property)
        pName = Mid(s, i+1);
    }
    else
    {
        // Too few args
        DrawText("Usage: watch <instance_name> <property>");
        return;
    }

    // Get the object
    o = GetObjectByName(oName);

    if (o == None)
    {
        // Object not found
        DrawText("Object "$oName$" not found.");
        return;
    }

    s = "";
    pName = Caps(pName);
    if (pName == "STATE")
    {
        WatchState(o, oName);
        return;
    }

    s = o.GetPropertyText(pName);

    if (s == "")
    {
        // Property not found
        DrawText("Property "$pName$" not found.");
        return;
    }

    // Success
    if (mObjCnt < mObjMax)
    {
        if (mServerIdx > 0)
            i = mServerIdx;
        else
            i = FindSpace();

        if (i >= 0)
        {
            maObjList[i] = o;
            maPropList[i] = pName;
            if (mServerIdx < 0)
                mObjCnt++;
            //DrawText(oName$"."$pName$" added to watch list.");
            if (mObjCnt == 1)
                WatchOn();
        }
        else
        {
            DrawText("Watch list is full.");
            return;
        }

        if (mServerIdx > 0)
            maServerText[i] = VarText(i);
    }
    else
        DrawText("Watch list is full.");
}

function WatchState(Object o, string oName)
{
    local int i;

    // Success
    if (mObjCnt < mObjMax)
    {
        if (mServerIdx > 0)
            i = mServerIdx;
        else
            i = FindSpace();

        if (i >= 0)
        {
            maObjList[i] = o;
            mabShowState[i] = 1;
            if (mServerIdx < 0)
                mObjCnt++;
            //DrawText(oName$".State added to watch list.");
            if (mObjCnt == 1)
                WatchOn();
        }
        else
        {
            DrawText("Watch list is full.");
            return;
        }

        if (mServerIdx > 0)
            maServerText[i] = StateText(i);
    }
    else
        DrawText("Watch list is full.");
}

function bool ValidEntry(int i)
{
    return (i>=0 && i<mObjMax && maObjList[i] != None);
}

/*exec*/ function SUnWatch(int j)
{
    local int i;

    if (j == -1)
    {
        for(i=0; i<mObjMax; i++)
        {
            if (maObjList[i] != None && maServerVar[i] == 1)
            {
                maObjList[i] = None;
                maServerVar[i] = 0;
                ServerUnWatch(i, --mObjCnt);
            }
        }
    }
    else if (ValidEntry(j) && maServerVar[j] == 1)
    {
        maObjList[j] = None;
        maServerVar[j] = 0;
	    ServerUnWatch(j, --mObjCnt);
    }
}

function ServerUnWatch(int j, int cnt)
{
    mObjCnt = cnt;
    mServerIdx = j;
	UnWatch(j);
    mServerIdx = -1;
}

/*exec*/ function UnWatch(int i)
{
    if (ValidEntry(i) && maServerVar[i] == 0)
    {
        DrawText(maObjList[i]$"."$maPropList[i]$" removed from watch list.");
        maObjList[i] = None;
        maPropList[i] = "";
        mabShowState[i] = 0;
        if (mServerIdx < 0)
            mObjCnt--;
        if (mObjCnt == 0)
            WatchOff();
    }
    else if (i == -1)
    {
        // UnWatch all
        for(i=0; i<mObjMax; i++)
        {
            if (maObjList[i] != None && maServerVar[i] == 0)
            {
                maObjList[i] = None;
                maPropList[i] = "";
                mabShowState[i] = 0;
                mObjCnt--;
                if (mObjCnt == 0)
                    WatchOff();
            }
        }
        DrawText("Watch list cleared.");
    }
    else
        DrawText(i$" not in range.");
}

/*exec*/ function WatchOn()
{
    if (mObjCnt > 0)
    {
        mbWatchEnabled = true;
        //DrawText("Watch On");
    }
    else
    {
        mbWatchEnabled = false;
        DrawText("No objects in watch list.");
    }
}

/*exec*/ function WatchOff()
{
    mbWatchEnabled = false;
    DrawText("Watch Off");
}

function Object GetObjectByName(string oName)
{    
    local Object o;
    local int i;
    local string s;
    local string pName;
    local string pName2;

    // Parse next object if any
    i = InStr(oName, ".");
    if (i != -1)
    {
        pName = Mid(oName, i+1);
        oName = Left(oName, i);

        i = InStr(pName, ".");
        if (i != -1)
        {
            pName2 = Mid(pName, i+1);
            pName = Left(pName, i);
        }
    }

    foreach AllObjects( class'Object', o )
    {
        s = string(o.name);

        if (Caps(s) == Caps(oName))
        {
            if (pName == "" && pName2 == "")
                return o;

            s = "";
            s = o.GetPropertyText(pName);

            if (s == "")
                return None;

            i = InStr(s, ".");
            if (i != -1)
            {
                s = Mid(s, i+1);

                i = InStr(s, "'");
                if (i != -1)
                    s = Left(s, i);
            }

            if (pName2 != "")
                s = s $ "." $ pName2;

            return GetObjectByName(s);
        }
    }

    // Object not found
    return None;
}

defaultproperties
{
     mServerIdx=-1
     CubeMapFOV=90.000000
     CubeMapDelay=1.000000
     mDrawColor=(B=255,G=255,R=255,A=255)
     mWatchPos=(X=5.000000,Y=50.000000)
     CubeMapRotations(0)=(Roll=16384)
     CubeMapRotations(1)=(Yaw=32768,Roll=-16384)
     CubeMapRotations(2)=(Yaw=16384,Roll=32768)
     CubeMapRotations(3)=(Yaw=-16384)
     CubeMapRotations(4)=(Pitch=16384,Roll=16384)
     CubeMapRotations(5)=(Pitch=-16384,Roll=16384)
}
