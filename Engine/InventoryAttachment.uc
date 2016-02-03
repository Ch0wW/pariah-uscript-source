class InventoryAttachment extends Actor
	native
	nativereplication;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var bool bFastAttachmentReplication; // only replicates the subset of actor properties needed by basic attachments whose 
									 // common properties don't vary from their defaults

function InitFor(Inventory I)
{
	Instigator = I.Instigator;
}
		

defaultproperties
{
     bFastAttachmentReplication=True
     NetUpdateFrequency=10.000000
     AttachmentBone="righthand"
     DrawType=DT_Mesh
     RemoteRole=ROLE_SimulatedProxy
     bOnlyDrawIfAttached=True
     bUseLightingFromBase=True
     bIgnoresPauseTime=True
}
