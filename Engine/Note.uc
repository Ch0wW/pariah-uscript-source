//=============================================================================
// A sticky note.  Level designers can place these in the level and then
// view them as a batch in the error/warnings window.
//=============================================================================
class Note extends Actor
	placeable
	native;

#exec Texture Import File=Textures\Note.pcx  Name=S_Note Mips=Off MASKED=1

var() editinline string Text;

// these flags determine whether the note's text is actually displayed in the editor and/or the game
// - if the text is displayed the TextFont and TextColor are used when drawing the text
//
var() bool bDisplayNoteInEditor;
var() bool bDisplayNoteInGame;
var() font TextFont;
var() color TextColor;

var const transient int				RenderTarget;
var const transient NoteTexture		NoteTexture;
var const transient Material		SavedTexture;

defaultproperties
{
     TextFont=Font'Engine.FontSmall'
     TextColor=(G=255,R=255,A=255)
     bDisplayNoteInEditor=True
     bDisplayNoteInGame=True
     Texture=Texture'Engine.S_Note'
     Style=STY_Alpha
     bStatic=True
     bHidden=True
     bNoDelete=True
     bMovable=False
}
