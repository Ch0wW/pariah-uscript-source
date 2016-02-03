class SPScavengerExclaim extends SPHumanExclaim;

#exec OBJ LOAD FILE=AIStateDialogueGroups.uax

defaultproperties
{
     sndIdle=SoundGroup'AIStateDialogueGroups.AIStateScavenger.AIStateScavIdles'
     sndNotice=SoundGroup'AIStateDialogueGroups.AIStateScavenger.AIStateScavAlert'
     sndLost=SoundGroup'AIStateDialogueGroups.AIStateScavenger.AIStateScavLost'
     sndAttacking=SoundGroup'AIStateDialogueGroups.AIStateScavenger.AIStateScavCombat'
     sndFriendlyFire=SoundGroup'AIStateDialogueGroups.AIStateScavenger.AIStateScavFriendly'
     sndKilledEnemy=SoundGroup'AIStateDialogueGroups.AIStateScavenger.AIStateScavGloat'
}
