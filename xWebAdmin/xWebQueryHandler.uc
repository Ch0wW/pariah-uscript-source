// ====================================================================
//  Class:  XWebAdmin.xWebQueryHandler
//  Parent: Engine.xAdminBase
//
//  <Enter a description here>
// ====================================================================

class xWebQueryHandler extends xAdminBase
		Within PariahServerAdmin;

var string DefaultPage;
var string Title;
var string NeededPrivs;

//TODO: Implement natively
static final operator(44) string += (out coerce string A, coerce string B) { A = A $ B; return A; }
static final operator(44) string @= (out coerce string A, coerce string B) { A = A @ B; return A; }
static final operator(44) string -= (out coerce string A, coerce string B) { A = ReplaceTag(A, B, ""); return A; }

function bool Init() {return true;}
function bool PreQuery(WebRequest Request, WebResponse Response) { return true; }
function bool Query(WebRequest Request, WebResponse Response)    { return false; }
function bool PostQuery(WebRequest Request, WebResponse Response) { return true; }

// Called at end of match
function Cleanup();

defaultproperties
{
}
