class SavedPlayerData extends Object
    native;
    
simulated function Update(GameInfo game, int numPlayers);
simulated function bool SetupInventory(PlayerController PC, GameInfo game, int numPlayers);
simulated function LogSavedData(int numPlayers);

defaultproperties
{
}
