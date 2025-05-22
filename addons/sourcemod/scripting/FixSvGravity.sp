#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#pragma newdecls required

public Plugin myinfo =
{
	name = "FixSvGravity",
	author = "Botox, xen",
	description = "Fixes gravity prediction, server crashes and resets gravity on map end",
	version = "2.0.0",
	url = ""
};

ConVar g_ConVar_SvGravity;

float g_flSvGravity;
float g_flClientGravity[MAXPLAYERS + 1];
float g_flClientActualGravity[MAXPLAYERS + 1];

bool g_bLadder[MAXPLAYERS + 1];

public void OnPluginStart()
{
	g_ConVar_SvGravity = FindConVar("sv_gravity");
	g_flSvGravity = GetConVarFloat(g_ConVar_SvGravity);
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
	if(convar.IntValue < 1)
	{
		convar.IntValue = 800;
		return;
	}

	g_flSvGravity = GetConVarFloat(g_ConVar_SvGravity);
}

// If a player is on a ladder with modified gravity and the round restarts,
// their gravity would be restored to what it was last round since they'd be no longer on a ladder
public void OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	ResetGravityAll();
}

public void OnGameFrame()
{
	for (int client = 1; client < MaxClients; client++)
	{
		if (!IsClientInGame(client) || !IsPlayerAlive(client) || IsFakeClient(client))
		{
			g_flClientGravity[client] = 1.0;
			g_bLadder[client] = false;
			continue;
		}

		if (GetEntityMoveType(client) == MOVETYPE_LADDER)
		{
			// They're on a ladder, ignore current gravity modifier
			if (!g_bLadder[client])
				g_bLadder[client] = true;

			continue;
		}

		// Now that they're off, restore it
		if (g_bLadder[client])
		{
			RequestFrame(RestoreGravity, client);
			continue;
		}

		float flClientGravity = GetEntityGravity(client);

		// Gamemovement treats 0.0 gravity as 1.0
		if (flClientGravity != 0.0)
			g_flClientGravity[client] = flClientGravity;
		else
			flClientGravity = 1.0;

		// Some maps change sv_gravity while clients already have modified gravity
		// So we store the actual calculated gravity to catch such cases
		float flClientActualGravity = flClientGravity * g_flSvGravity;

		if (flClientActualGravity != g_flClientActualGravity[client])
		{
			char szGravity[8];
			FloatToString(flClientActualGravity, szGravity, sizeof(szGravity));
			g_ConVar_SvGravity.ReplicateToClient(client, szGravity);

			g_flClientActualGravity[client] = flClientActualGravity;
		}
	}
}

public void RestoreGravity(int client)
{
	g_bLadder[client] = false;
	SetEntityGravity(client, g_flClientGravity[client]);
}

public void ResetGravityAll()
{
	char szGravity[8];
	g_ConVar_SvGravity.GetString(szGravity, sizeof(szGravity));

	for (int client = 1; client < MaxClients; client++)
	{
		g_flClientGravity[client] = 1.0;
		g_bLadder[client] = false;

		if (IsClientInGame(client) && !IsFakeClient(client))
			g_ConVar_SvGravity.ReplicateToClient(client, szGravity);
	}
}
