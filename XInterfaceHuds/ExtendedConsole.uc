// ====================================================================
//  Class:  XInterface.ExtendedConsole
//  Parent: Engine.Console
//
//  <Enter a description here>
// ====================================================================

class ExtendedConsole extends Console;

#exec OBJ LOAD FILE=MenuSounds.uax
#exec OBJ LOAD FILE=InterfaceContent.utx

// Visible Console stuff

var globalconfig int MaxScrollbackSize;

var array<string> Scrollback;
var int SBHead, SBPos;	// Where in the scrollback buffer are we
var Font ConsoleFont;
var bool bCtrl;
var bool bFadeIn, bFadeOut, bWaiting;
var float FadeValue, FadeRatio;

exec function CLS()
{
	SBHead = 0;
	ScrollBack.Remove(0,ScrollBack.Length);
}

function PostRender( canvas Canvas );	// Subclassed in state

event Message( coerce string Msg, float MsgLife)
{
	if (ScrollBack.Length==MaxScrollBackSize)	// if full, Remove Entry 0
	{
		ScrollBack.Remove(0,1);
		SBHead = MaxScrollBackSize-1;
	}
	else
		SBHead++;		
	
	ScrollBack.Length = ScrollBack.Length + 1;
	
	Scrollback[SBHead] = Msg;
	Super.Message(Msg,MsgLife);
}

//-----------------------------------------------------------------------------
// State used while typing a command on the console.

exec function ConsoleOpen()
{
    PrevState = GetStateName();
	TypedStr = "";
	GotoState('ConsoleVisible');
}

exec function ConsoleClose()
{
 	TypedStr="";
    if( GetStateName() == 'ConsoleVisible' )
        GotoState( PrevState ); 
}

exec function ConsoleToggle()
{
    if( GetStateName() == 'ConsoleVisible' )
        bFadeOut=true;
    else
        ConsoleOpen();
}

state ConsoleVisible
{
	function bool KeyType( EInputKey Key, optional string Unicode )
	{
		if (bIgnoreKeys)		
			return true;

		if( Key>=0x20 )
		{
			if( Unicode != "" )
				TypedStr = TypedStr $ Unicode;
			else
				TypedStr = TypedStr $ Chr(Key);
            return( true );
		}
		
		return( false );
	}

    function bool IgnoreKeyEvent( EInputKey Key, EInputAction Action )
    {
        if( KeyIsBoundTo( Key, "ConsoleToggle" ) )
        	return( true );
		
        return( global.IgnoreKeyEvent( Key, Action ) );
    }

	function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta )
	{
		local string Temp;
    
        if( IgnoreKeyEvent( Key, Action ) )
            return( false );

		if( Key==IK_Ctrl )
		{
			if (Action == IST_Press)
				bCtrl = true;
			else if (Action == IST_Release)
				bCtrl = false;
		}

		if (Action== IST_PRess)
		{
			bIgnoreKeys=false;
		}
	
		if( Key==IK_Escape)
		{
			if( TypedStr!="" )
			{
				TypedStr="";
				HistoryCur = HistoryTop;
                return( true );
			}
			else
			{
				bFadeOut=true;
                //ConsoleClose();
                //return( true );
        	}
		}
		else if( Action != IST_Press )
            return( false );

		else if( Key==IK_Enter )
		{
			if( TypedStr!="" )
			{
				// Print to console.
//				Message( TypedStr, 6.0 );

				History[HistoryTop] = TypedStr;
                HistoryTop = (HistoryTop+1) % ArrayCount(History);
				
				if ( ( HistoryBot == -1) || ( HistoryBot == HistoryTop ) )
                    HistoryBot = (HistoryBot+1) % ArrayCount(History);

				HistoryCur = HistoryTop;

				// Make a local copy of the string.
				Temp=TypedStr;
				TypedStr="";
				
				if( !ConsoleCommand( Temp ) )
					Message( Localize("Errors","Exec","Core") $ ":" @ Temp, 6.0 );
			}
			else
                bFadeOut=true;//ConsoleClose();
            
            return( true );
		}
		else if( Key==IK_Up )
		{
			if ( HistoryBot >= 0 )
			{
				if (HistoryCur == HistoryBot)
					HistoryCur = HistoryTop;
				else
				{
					HistoryCur--;
					if (HistoryCur<0)
                        HistoryCur = ArrayCount(History)-1;
				}
				
				TypedStr = History[HistoryCur];
			}
            return( true );
		}
		else if( Key==IK_Down )
		{
			if ( HistoryBot >= 0 )
			{
				if (HistoryCur == HistoryTop)
					HistoryCur = HistoryBot;
				else
                    HistoryCur = (HistoryCur+1) % ArrayCount(History);
					
				TypedStr = History[HistoryCur];
			}			

		}
		else if( Key==IK_Backspace || Key==IK_Left )
		{
			if( Len(TypedStr)>0 )
				TypedStr = Left(TypedStr,Len(TypedStr)-1);
            return( true );
		}
		
		else if ( Key==IK_PageUp || key==IK_MouseWheelUp )
		{
			if (SBPos<ScrollBack.Length-1)
			{
				if (bCtrl)
					SBPos+=5;
				else
					SBPos++;
				
				if (SBPos>=ScrollBack.Length)
				  SBPos = ScrollBack.Length-1;
			}
				
			return true;
		}			
		else if ( Key==IK_PageDown || key==IK_MouseWheelDown)
		{
			if (SBPos>0)
			{
				if (bCtrl)
					SBPos-=5;
				else
					SBPos--;
				
				if (SBPos<0)
					SBPos = 0;
			}
		}		
		
        return( true );
	}
	
    function BeginState()
	{
		SBPos = 0;
        bVisible= true;
		bIgnoreKeys = true;
        HistoryCur = HistoryTop;
		bCtrl = false;
        bFadeIn=true;
        FadeValue = 0;
    }
    function EndState()
    {
        FadeValue = 0;
        bFadeIn = false;
        bVisible = false;
		bCtrl = false;
    }

    function Tick( float deltaTime)
    {
        if(bFadeIn)
        {
            if(FadeValue < 1.0)
                FadeValue += deltaTime*FadeRatio;
            else
            {
                FadeValue = 1.0;
                bFadeIn = false;
            }
        }
        
        if(bFadeOut)
        {
			bFadeIn = false;
            if(FadeValue >= 0.1)
                FadeValue -= deltaTime*FadeRatio;
            else
            {
				ConsoleClose();
                FadeValue = 0.0;
                bFadeOut = false;
            }
        }
        
        FadeValue = FClamp(FadeValue, 0.0, 1.0);
    }

	function PostRender( canvas C )
	{
		local float fw,fh;
		local float yclip,y;
		local int idx;
		
        C.Font = ConsoleFont;
		yclip = C.ClipY*0.35;

        if(TypedStr!= "")
            C.StrLen( TypedStr,fw, fh );
        else
            C.StrLen("X",fw,fh); 

		C.SetPos(0,0);
        C.Style = 5; //DrawStyle is Alpha
        C.SetDrawColor(0,0,0,FadeValue*200);
		C.DrawTile(texture 'Engine.PariahWhiteTexture',C.ClipX,C.ClipY*0.35,16,32,32,28);

		C.SetPos(0,yclip);
		C.SetDrawColor(30,30,30,FadeValue*200);
		C.DrawTile(texture 'Engine.PariahWhiteTexture',C.ClipX, -(fh+5),0,0,2,2);
    	
		C.SetPos(0,yclip);
		C.SetDrawColor(0,0,0,FadeValue*255);
		C.DrawTile(texture 'Engine.PariahWhiteTexture',C.ClipX,1,0,0,2,2);

        C.SetPos(0,yclip-(fh+5));
		C.SetDrawColor(0,0,0,FadeValue*255);
		C.DrawTile(texture 'Engine.PariahWhiteTexture',C.ClipX,1,0,0,2,2);

        C.SetDrawColor(186,206,217,FadeValue*255);
        C.SetPos(0,yclip-2-fh);
      	C.DrawText("(>"@TypedStr$"_");
    	
		idx = SBHead - SBPos;
		y = yClip-y-5-(fh*2);

		if (ScrollBack.Length==0)
			return;
    
        C.SetDrawColor(127,127,127,FadeValue*255);

        while (y>fh && idx>=0)
		{   
            C.StrLen( Scrollback[idx], fw, fh ); // Wrapped!
            y-=fh;

            C.SetPos(0,y);
			C.DrawText(Scrollback[idx]);
            
            idx--;
		}
    
	}
}

defaultproperties
{
     MaxScrollbackSize=128
     FadeRatio=7.000000
     ConsoleFont=Font'Engine.FontMono'
}
