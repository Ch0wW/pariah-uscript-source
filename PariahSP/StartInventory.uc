class StartInventory extends Info
	placeable;

#exec Texture Import File=Textures\spinventorya.pcx Name=StartInvIcon Mips=Off MASKED=1


var() class<PersonalWeapon>					StartWeapons[16];
var() int									StartWeaponLevel[16];

var() bool									bForceInventory;
var() bool									bOnlyThisInventory;

function GiveTo(SinglePlayerController pc)
{
	local Pawn				p;
	local int				i;
	local PersonalWeapon	pw;
	local Inventory			inv;
	local bool				bRescanInventory, bDeleteWeapon;

	p = pc.Pawn;

	if(p==None) return;


	for(i=0;i<16;i++)
	{
		if(StartWeapons[i] == None)
			continue;

		inv = p.FindInventoryType(StartWeapons[i]);
		if ( inv == None )
		{
			`log( "RJ: giving weapon"@StartWeapons[i] );

			p.GiveWeaponByClass(StartWeapons[i]);
			pw = PersonalWeapon(p.FindInventoryType(StartWeapons[i]));
			pw.SetWECLevel(StartWeaponLevel[i]);
			if ( bOnlyThisInventory )
	        {
	            PlayerController(P.Controller).SwitchWeapon(pw.InventoryGroup);
	        }
		}
	}
	
	if ( bOnlyThisInventory )
	{
		bRescanInventory = true;
		while ( bRescanInventory )
		{
			bRescanInventory = false;
			for( inv = p.Inventory; inv != None; inv = inv.Inventory )
			{
				if ( ClassIsChildOf( inv.Class, class'PersonalWeapon' ) )
				{
					// delete this weapon if it isn't in the start inventory
					//
					bDeleteWeapon = true;
					for ( i = 0; i < 16; i++ )
					{
						if( StartWeapons[i] == None )
						{
							continue;
						}

						if ( inv.Class == StartWeapons[i] )
						{
							bDeleteWeapon = false;
							break;
						}
					}

					if ( bDeleteWeapon )
					{
						`log( "RJ: Deleting"@inv@"of"@p );
						p.DeleteInventory( inv );
						bRescanInventory = true;
						break;
					}
				}
			}
		}
	}

	// gam -- If we have a gun let's use it instead of the bone saw!
	if(P.Controller != None )
	{
	    P.Controller.SwitchToBestWeapon();
	}
}

event PreLoadData()
{
	local int i;

	Super.PreLoadData();
	for ( i=0; i<16; i++ )
	{
		if(StartWeapons[i] == None)
			continue;

		PreLoad( StartWeapons[i] );
	}
}

defaultproperties
{
     Texture=Texture'PariahSP.StartInvIcon'
     bNeedPreLoad=True
}
