#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>

#pragma newdecls required

/* Global cvars */
int gCountT, gCountCT;

public Plugin myinfo = {
	name = "MoveMe",
	author = "Luckiris",
	description = "Move the player to a team if the in game menu dosen't work and/or by command",
	version = "1.2",
	url = "https://github.com/Luckiris"
};

public void OnPluginStart(){
	HookEvent("round_start", EventRoundStart);
	HookUserMessage(GetUserMessageId("VGUIMenu"), TeamMenuHook, true);
	RegConsoleCmd("sm_moveme", CommandMoveMe, "Move the player to a team");	
}

public Action EventRoundStart(Event event, const char[] name, bool dontBroadcast){
	gCountT = GetTeamClientCount(CS_TEAM_T);
	gCountCT = GetTeamClientCount(CS_TEAM_CT);
	return Plugin_Continue;
}

public Action TeamMenuHook(UserMsg msg_id, Protobuf msg, const int[] players, int playersNum, bool reliable, bool init){
	/*	Moving the player joining to a team
	*/
    char buffermsg[64];
    PbReadString(msg, "name", buffermsg, sizeof(buffermsg));
    if (StrEqual(buffermsg, "team", true)){
        int client = players[0];
        CreateTimer(0.1, SwapMe, client);
    }
    return Plugin_Continue;
}  

public Action CommandMoveMe(int client, int args)
{
	/*	Command will move the player to a team
	*/

	/* Just checking if the client is already in a team */
	if (GetClientTeam(client) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_T) return Plugin_Handled;

	/* Getting the team */
	ChangeClientTeam(client, GetTeamForChange());
	return Plugin_Handled;	
}

public Action SwapMe(Handle timer, any client){
	/* Getting the team */
	int count = GetTeamClientCount(CS_TEAM_T) + GetTeamClientCount(CS_TEAM_CT);
	if (count > 2) ChangeClientTeam(client, GetTeamForChange());
	return Plugin_Handled;
}

int GetTeamForChange(){
	/*	This function check the numbers of players in each team
		If a team has no players, then we move to the other team (COURSE MAP BEHAVIOUR)
		For normal map, move the player to the first team which is unbalance
	*/

	/* Update the counter just in case */
	gCountT = GetTeamClientCount(CS_TEAM_T);
	gCountCT = GetTeamClientCount(CS_TEAM_CT);

	/* First case : course maps */
	if (gCountT == 0 && gCountCT > 0) return CS_TEAM_CT;
	else if (gCountCT == 0 && gCountT > 0) return CS_TEAM_T;

	return GetRandomInt(CS_TEAM_T, CS_TEAM_CT);
}