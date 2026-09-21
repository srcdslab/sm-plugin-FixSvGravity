#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

public Plugin myinfo =
{
	name = "FixSvGravity",
	author = "Botox, xen",
	description = "Fixes server crashes and resets gravity on map end",
	version = "3.0.1",
	url = ""
};

ConVar g_ConVar_SvGravity;

public void OnPluginStart()
{
	g_ConVar_SvGravity = FindConVar("sv_gravity");
	g_ConVar_SvGravity.AddChangeHook(OnConVarChanged);

	HookEvent("round_start", OnRoundStart);
}

public void OnPluginEnd()
{
	ResetGravityAll();
}

public void OnMapEnd()
{
	g_ConVar_SvGravity.IntValue = 800;
}

public void OnConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (convar.IntValue < 1)
	{
		convar.IntValue = 800;
		return;
	}
}

public void OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	ResetGravityAll();
}

public void ResetGravityAll()
{
	char szGravity[8];
	g_ConVar_SvGravity.GetString(szGravity, sizeof(szGravity));

	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
			SetEntityGravity(client, 1.0);
	}
}
