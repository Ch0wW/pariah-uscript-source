//=============================================================================
// MeshObject
//
// A base class for all Animating-Mesh-editing classes.  Just a convenient place to store
// common elements like enums.
//=============================================================================

class MeshObject extends Object
	abstract
	native;


// Impostor render switches
enum EImpSpaceMode
{
	ISM_Sprite,
	ISM_Fixed,
	ISM_PivotVertical,
	ISM_PivotHorizontal,
};
enum EImpDrawMode
{
	IDM_Normal, 
	IDM_Fading,  
};	
enum EImpLightMode
{
	ILM_Unlit,
	ILM_PseudoShaded,	// Lit by hardware, diverging normals.
	ILM_Uniform,	        // Lit by hardware, all normals pointing faceward.
};	

// Mesh static-section extraction methods
enum EMeshSectionMethod
{
	EMSM_SmoothOnly,    // Smooth (software transformed) sections only.
	EMSM_RigidOnly,     // Only draw rigid parts, throw away anything that's not rigid.
	EMSM_Mixed,         // Convert suitable mesh parts to rigid and draw remaining sections smoothly (software transformation).
	EMSM_SinglePiece,   // Freeze all as a single static piece just as in the refpose.
	EMSM_ForcedRigid,   // Convert all faces to rigid parts using relaxed criteria ( entire smooth sections forced rigid ).	
};

enum EMeshHardwareStreamDesired
{
	MHW_SoftwareOnly, // Don't add any auxiliary GPU streams (delete if present.)
	MHW_GPUSkinning, // Convert to streams suitable for GPU vertex shader skinning.
	MHW_GPUSingleInfluence, // Forces single-influence GPU vertex shader renderable streams.
};

defaultproperties
{
}
