/*******************************************************
 MeshBrowserMenu
 Desc: Opens when the user presses A while in the MenuEditor
	   MeshAdd mode. A set of thumbnails are shown. The center
	   thumbnail is focused on and its corresponding 3d mesh
	   is shown rotating on the right side. When the user
	   presses A the menu layer will close and the mesh will
	   appear where the user is looking. The mesh will be
	   semi-transparent. If it cannot be placed where the user
	   is currently looking at, it will glow red to indicate
	   to the user he has to find a different location.
 ******************************************************/
class MeshBrowserMenu extends ToolMenuBase
	native;


const NUM_THUMBS_PER_ROW	= 3;
const NUM_THUMBS_PER_PAGE	= 9;
const MESH_DIM				= 40.0;

var MenuButtonSprite	ArrowLeft, ArrowRight;
var Material            ArrowRightMat, ArrowleftMat;
var float				MeshScale[NUM_THUMBS_PER_PAGE];
var MenuButtonSprite	Buttons[NUM_THUMBS_PER_PAGE];
var MenuActor			MeshPreview;
var MenuText			MeshText;
var Vector				MeshPreviewPosition;
var Rotator				MeshPreviewRotSpeed;
var Rotator				MeshPreviewRotation;
var StaticMesh			PreviewMeshes[NUM_THUMBS_PER_PAGE];
var int					ActivePage; //the page index displaying meshes
var int					SelectedMeshIndex;
var int					PageSelectedMesh;
var String				SelectedMeshName;
var array<String>		CategoryNames;		//List of the mesh categories
var int					NumPages;
var localized String	L_GUIHelpText;
var localized String	L_PressLTText;

//Help menu
var localized string	HelpText_SelectObject;
var localized string	HelpText_CloseMenu;

event AnimatorDone( int Id )
{
	switch( Id )
	{
	case 1:
		CloseMenu();
		break;
	}
}


simulated function MakePanelPanIn()
{
	local int i;

	MakeTranslator( 0, MD_Left, 0.5, 0.4 );
	
	//Add the widgets to the animator
	AddToAnimator( DrawerBackground );
	for( i=0; i < ArrayCount(Buttons); i++ )
		AddToAnimator( Buttons[i] );

	MoveAnimatedDir( MD_Right, 0.4 );
}


simulated function MakePanelPanOut()
{
	local int i;

	MakeTranslator( 1, MD_Right, 0.5, 0.4 );

	//Add the widgets to the animator
	AddToAnimator( DrawerBackground );
	for( i=0; i < ArrayCount(Buttons); i++ )
		AddToAnimator( Buttons[i] );
}


simulated function Init( String Args )
{
	//After laying out gui
	Super.Init( Args );

	NumPages = Info.MeshNames.Length / NUM_THUMBS_PER_PAGE;
	if( (Info.MeshNames.Length % NUM_THUMBS_PER_PAGE) != 0 )
		NumPages++;
	
	UpdateButtonVisibility();
	InitThumbnails();
	InitMeshPreview();

	ActivePage = 0;
	SelectedMeshIndex = 0;
	UpdatePage();

	MakePanelPanIn();
	UpdateArrows();

	FocusOnWidget( Buttons[0] );
	SelectWidget( Buttons[0] );
    SetPreview(0);

	SetHelpText_A( HelpText_SelectObject );
	SetHelpText_B( HelpText_CloseMenu );

    InitMenuButtonSprite( ArrowRight, 0.97, 0.65, 0.06, 0.08, ArrowRightMat );
    ArrowRight.BackgroundBlurred.bHidden=1;
    ArrowRight.BackgroundFocused.bHidden=1;
    InitMenuButtonSprite( ArrowLeft, 0.585, 0.65, 0.06, 0.08, ArrowLeftMat );
    ArrowLeft.BackgroundBlurred.bHidden=1;
    ArrowLeft.BackgroundFocused.bHidden=1;

    ArrowRight.OnSelect='OnRightArrow';
}


simulated function OnLeftArrow()
{
    log("left");
	if( ActivePage != 0 )
	{
		ShowLeftPage();
        UpdatePage();
	}
}


simulated function OnRightArrow()
{
    log("right");
	if( ActivePage != (NumPages-1) )
	{
		ShowRightPage();
		UpdatePage();
	}
}


// Goes through each button and checks if it has a sprite, if not, the button is hidden
simulated function UpdateButtonVisibility()
{
	local int i;
	local int NumInLast;

	for( i = 0; i < NUM_THUMBS_PER_PAGE; i++ )	
		Buttons[i].bHidden = 0;

	if( ActivePage == NumPages-1 )
	{
		NumInLast = Info.MeshNames.Length % NUM_THUMBS_PER_PAGE;
		if ( NumInLast != 0 )
		{
			for( i = NumInLast; i < NUM_THUMBS_PER_PAGE; i++ )	
				Buttons[i].bHidden = 1;
		}
	}
}


simulated function InitThumbnails()
{
	local float spacingX, spacingY, OffsetY, PosX, PosY, ScaleX, ScaleY;
	local int i;
	local Material DefaultMat;
    
	spacingX = 0.115;
	spacingY = 0.115;
	OffsetY = 0.535;
	ScaleX = 0.11;
	ScaleY = 0.12;
	DefaultMat = Material'PariahPlayerMugShotsTextures.cDefault';

	for( i = 0; i < NUM_THUMBS_PER_PAGE; i++ )
	{
		PosX = 0.55 + ((i%NUM_THUMBS_PER_ROW)+1) * spacingX;
		PosY = OffsetY + (i/NUM_THUMBS_PER_ROW) * spacingY;
        
        InitMenuButtonSprite( Buttons[i], PosX, PosY, ScaleX, ScaleY, DefaultMat );

        if( !IsOnConsole() )
            Buttons[i].OnFocus='ChangePreview';
	}
}


simulated function ChangePreview()
{
    UpdateSelection();
}


simulated function InitMeshPreview()
{
	local class<actor>	MeshPreviewClass;
	MeshPreviewClass = class<Actor>(DynamicLoadObject("XInterface.MenuActorStaticMesh",class'Class'));
	MeshPreview.Actor = Spawn( MeshPreviewClass, self, , MeshPreviewPosition );
}


simulated function Tick( float DeltaTime )
{
	MeshPreviewRotation = MeshPreviewRotation + MeshPreviewRotSpeed*DeltaTime;
	MeshPreview.Actor.SetRotation( MeshPreviewRotation );
}


//When the user presses A the selected mesh is spawned in the level at the 
//terrain lookat position, but a bit off the ground
simulated function HandleInputSelect()
{
	Super.HandleInputSelect(); //So that a focused widget can be selected
}


simulated function OnMesh()
{
	UpdateSelection();
}


simulated function UpdateSelection()
{
    local int SelectionIndex;
    SelectionIndex = GetSelectionOnFocus();
    if( SelectionIndex != -1 && (ActivePage*NUM_THUMBS_PER_PAGE + SelectionIndex) != SelectedMeshIndex )
        SetPreview(SelectionIndex);
}


simulated function SetPreview( int i )
{
    local vector PreviewHalfHeight;

	UpdateArrows();
	PageSelectedMesh = i;
	SelectedMeshIndex = ActivePage*NUM_THUMBS_PER_PAGE + i;
	MeshText.text = Info.MeshDesc[SelectedMeshIndex];
	if( PreviewMeshes[i] == None )
	{
		log( "preview mesh no good" );
		return;
	}
	MeshPreview.Actor.SetStaticMesh( PreviewMeshes[i] );
	MeshPreview.Actor.SetDrawScale( MeshScale[i] );
	PreviewHalfHeight.Z = 0.5f * MeshScale[i] * GetHeight( PreviewMeshes[i] );
	MeshPreview.Actor.SetLocation( MeshPreviewPosition - PreviewHalfHeight );
}


simulated function bool OnLeftSide()
{
	if( (PageSelectedMesh % NUM_THUMBS_PER_ROW) == 0 )	
	{
		return true;
	}
	return false;
}


simulated function bool OnRightSide()
{
	if( (PageSelectedMesh % NUM_THUMBS_PER_ROW) == (NUM_THUMBS_PER_ROW-1) )	
	{
		return true;
	}
	return false;
}


simulated function ShowRightPage()
{
	ActivePage++;
    if( IsOnConsole() )
    {
	    FocusOnWidget( Buttons[0] );
	    SelectWidget( Buttons[0] );
    }
	UpdatePage();
}


simulated function ShowLeftPage()
{
	ActivePage--;
    if( IsOnConsole() )
    {
	    FocusOnWidget( Buttons[NUM_THUMBS_PER_PAGE-1] );
	    SelectWidget( Buttons[NUM_THUMBS_PER_PAGE-1] );	
    }
    UpdatePage();
}


//To select the thumbnail button on the left
simulated function HandleInputLeft()
{
	//If the focus was on a button on the left side of the set of thumbnails
	if( OnLeftSide() )
	{
		if( ActivePage != 0 )
            ShowLeftPage();
	}
	else
	{
		Super.HandleInputLeft();
	}
	UpdateSelection();
}

simulated function UpdateArrows()
{
	// make sure that there's more than one page
	if( (NumPages - 1) != 0 )
	{
		//at right 
		if ( ActivePage == NumPages-1 )
		{
			ArrowRight.bHidden = 1;
			ArrowLeft.bHidden = 0;
		}
		//at left 
		if ( ActivePage == 0 )
		{
			ArrowRight.bHidden = 0;
			ArrowLeft.bHidden = 1;
		}
		//not on right side or left side
		if ( ActivePage != NumPages-1 && ActivePage != 0 )
		{
			ArrowRight.bHidden = 0;
			ArrowLeft.bHidden = 0;
		}
	}
}


//To select the thumbnail button on the right
simulated function HandleInputRight()
{
	//If the focus was on a button on the right side of the set of thumbnails
	if( OnRightSide() )
	{
		if( ActivePage != (NumPages-1) )
            ShowRightPage();
	}
	else
	{
		Super.HandleInputRight();
	}
	UpdateSelection();
}


simulated function HandleInputUp()
{
	Super.HandleInputUp();
	UpdateSelection();
}


simulated function HandleInputDown()
{
	Super.HandleInputDown();
	UpdateSelection();
}


// When the active page is changed this is called to swap the sprites and the static meshes
// I do this swap to have more memory available
simulated function UpdatePage()
{
	local Material M;
	local float LargestDim;
	local int i, Index;

	for( i = 0; i < NUM_THUMBS_PER_PAGE; i++ )	
	{
		// Change the thumbnails
		Index = ActivePage*NUM_THUMBS_PER_PAGE + i;

		if( index >= Info.MeshThumbs.Length )
			M = Material'PariahPlayerMugShotsTextures.cDefault';
        else
			M = Material(DynamicLoadObject( Info.MeshThumbs[index], class'Material'));

		Buttons[i].Blurred.WidgetTexture = M;
		Buttons[i].Focused.WidgetTexture = M;

		// Change loaded meshes
		if( Index < Info.MeshNames.Length )
			PreviewMeshes[i]=StaticMesh(DynamicLoadObject(Info.MeshNames[Index], class'StaticMesh'));

		if( PreviewMeshes[i] == None )
			log( "MESH DOES NOT EXIST: " $ Info.MeshNames[Index] );
		else
		{
			LargestDim = GetLargestDim( PreviewMeshes[i] );
			MeshScale[ i ] = MESH_DIM/LargestDim;		
		}
	}
	UpdateArrows();
	UpdateButtonVisibility();
}


simulated function int GetSelectionOnFocus()
{
    local int i;
    for( i = 0; i < NUM_THUMBS_PER_PAGE; i++ )
    {
        if( Buttons[i].bHasFocus != 0 )
            return i;
    }
    return -1;
}


simulated function OnARelease()
{
    if( GetSelectionOnFocus() == -1 )
        return;

    SelectedMeshName = Info.MeshNames[ SelectedMeshIndex ];		// needed for PC development
	MeshPreview.Actor.SetStaticMesh( None );
	MakePanelPanOut();
	CloseMenu();
}


simulated function OnBRelease()
{
	Super.OnBRelease();
	MeshPreview.bHidden = 1;
}


simulated function CloseMenu()
{
	Super.CloseMenu();
	SelectedMeshIndex = 0;
	ActivePage = 0;	
}


simulated function Destroyed()
{
    if( MeshPreview.Actor != None )
    {
        MeshPreview.Actor.Destroy();
        MeshPreview.Actor = None;
    }
    
    Super.Destroyed();
}

defaultproperties
{
     ArrowLeft=(OnSelect="OnLeftArrow")
     ArrowRight=(OnSelect="OnRightArrow")
     ArrowRightMat=Shader'PariahInterface.InterfaceTextures.arrowright_pulse_shader'
     ArrowleftMat=TexRotator'PariahInterface.InterfaceTextures.ArrowLeft'
     Buttons(0)=(Blurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),BackgroundBlurred=(RenderStyle=STY_Alpha,DrawColor=(B=255,G=255,R=255,A=200),DrawPivot=DP_MiddleMiddle,ScaleMode=MSM_Fit),OnSelect="OnMesh",Pass=1)
     MeshPreview=(FOV=90.000000,Lights=((Position=(Y=-50.000000),Color=(B=255,G=255,R=255,A=255),Radius=360.000000)),AmbientGlow=30,Pass=2)
     MeshText=(MenuFont=Font'Engine.FontSmall',Text="This is a test",DrawPivot=DP_MiddleLeft,PosX=0.568000,PosY=0.250000,ScaleX=0.900000,ScaleY=0.900000,Pass=3,Style="LabelText")
     MeshPreviewPosition=(X=100.000000,Y=55.000000,Z=28.000000)
     MeshPreviewRotSpeed=(Yaw=6000)
     HelpText_SelectObject="Select this object"
     HelpText_CloseMenu="Close Menu"
     DrawerBackground=(ScaleX=0.450000,ScaleY=0.650000)
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
