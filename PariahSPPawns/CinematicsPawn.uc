//-----------------------------------------------------------
//
//-----------------------------------------------------------
class CinematicsPawn extends SPPawnNPC;

var(CinematicsPawn) string MeshName;
var(CinematicsPawn) class<Weapon> AssignedWeapon;
var(CinematicsPawn) float RunningSpeed;

struct AttachedActors{
   var() name BoneName;
   var() name ActorTag;
};

var(CinematicsPawn) array<AttachedActors> MyAttachedActors;



/*****************************************************************
 * AttachItems
 * Puts the items on the bones
 *****************************************************************
 */
function AttachItems(){
   local int i;
   local actor temp;
   local bool error;
   local bool found;

   //look through the list of attached actors
   for (i=0; i < MyAttachedActors.Length; i++){

      error = false;
      found = false;

      //find them in the level
      ForEach AllActors(class'Actor', temp, MyAttachedActors[i].ActorTag){

        found = true;
         //attach them to the listed bones
        temp.SetCollision(false,false,false);
        error = AttachToBone(temp, MyAttachedActors[i].BoneName);
        if (error == false){
            Log ("ERROR: Could not attach : " $ temp $ " to : " $ MyAttachedActors[i].BoneName $ " on actor : " $ self);
        }
      }

      if (found == false){
        Log ("ERROR: Could not find : " $ MyAttachedActors[i].ActorTag $ " to attach to : " $ self);
      }
   }
}

/*****************************************************************
 * PostBeginPlay
 *****************************************************************
 */
function PostBeginPlay(){
    local weapon temp;
    LinkMesh( Mesh(DynamicLoadObject( MeshName, class'Mesh')));
    if (AssignedWeapon != none){
        temp = spawn(AssignedWeapon);
        temp.GiveTo(self);
        PendingWeapon = temp;
        ChangedWeapon();
    }
    GroundSpeed = RunningSpeed;
    AttachItems();
    super.PostBeginPlay();
}


/*****************************************************************
 *
 *****************************************************************
 */

defaultproperties
{
     RunningSpeed=575.000000
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem109
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem109'
}
