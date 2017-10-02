#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Move me to a team",
	author = "Luckiris",
	description = "Move the player to a team if the in game menu dosen't work",
	version = "1.1",
	url = "https://www.dream-community.de"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_moveme", CommandMoveMe, "Move the player to a team");
	HookUserMessage(GetUserMessageId("VGUIMenu"), TeamMenuHook, true);
}

public Action TeamMenuHook(UserMsg msg_id, Protobuf msg, const int[] players, int playersNum, bool reliable, bool init)
{
	/*	Moving the player joining to T team
	
	*/
    char buffermsg[64];
    
    PbReadString(msg, "name", buffermsg, sizeof(buffermsg));
    
    if (StrEqual(buffermsg, "team", true))
    {
        int client = players[0];
        CreateTimer(0.1, SwapMe, client);
    }
    
    return Plugin_Continue;
}  

public Action CommandMoveMe(int client, int args)
{
	/*	We check if the client is valid then we check his team number
	
		IF team number > 1, the client is in CT or T
		THEN we do nothing
		ELSE we move him to T then CT (if needed)
	
	*/
	Action result = Plugin_Handled;
	
	if (IsValidClient(client))
	{
		int team = GetClientTeam(client);
		
		if (team > 1)
		{
			/* Already in a team */
			PrintToChat(client, " \x01[\x04DREAM\x01] You are already in a team !");
		}
		else
		{
			ChangeClientTeam(client, 2);
			/* Checking if the team change was succesful ... */
			team = GetClientTeam(client);		
			if (team != 2)
			{
				/* The first change failed so we trying to move to the other team ... */
				ChangeClientTeam(client, 3);
			}
			if (team > 1)
			{
				/* Success */
				PrintToChat(client, " \x01[\x04DREAM\x01] You are now in a team !");
			}
			else
			{
				/* Fail */
				PrintToChat(client, " \x01[\x04DREAM\x01] Failed to move you ! Please reconnect to the server !");
			}
		}
	}
	
	return result;
}

public Action SwapMe(Handle timer, any client)
{
	ChangeClientTeam(client, 2);
	return Plugin_Handled;
}

bool IsValidClient(int client)
{
	/*	Check if the client is in game, connected
	
	*/
	bool valid = false;
	if (client > 0 && client <= MAXPLAYERS && IsClientConnected(client) && IsClientInGame(client))
	{
		valid = true;
	}
	return valid;
}