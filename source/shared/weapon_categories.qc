/*
	shared/weapon_categories.qc

	The weapon category table: one place that says what every weapon *is*.

	An arsenal weapon is one of three eras of post-Second-World-War kit (Cold War issue,
	contemporary service, near-future prototype); a wonder weapon is one of five elemental
	families. Everything that needs to know - the Mystery Box's "one wonder weapon per
	family" rule, the element behaviour in server/weapons/weapon_elements.qc, the name
	shown on the ammo counter - asks this table instead of keeping its own list of ids.

	The vocabulary itself (WCAT_*, WELEM_*) is in shared_defs.qc with the rest of the
	game's enums; this file owns the mapping from weapon id to category, and from category
	to element and to a readable name.

	Copyright (C) 2021-2024 NZ:P Team

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA  02111-1307, USA.

*/

float(float weapon) WepDef_GetCategory =
{
	switch (weapon)
	{
		// --- ray family: aetheric damage ---
		case W_RAY:
		case W_PORTER:
		case W_RAYMK2:
		case W_PORTERMK2:
			return WCAT_WONDER_AETHER;

		// --- tesla family: arcs between targets ---
		case W_TESLA:
		case W_DG3:
		case W_DG5:
		case W_DG5PAP:
			return WCAT_WONDER_SHOCK;

		// --- incendiary: leaves the target burning ---
		case W_M2:
		case W_AFTERBURNER:
			return WCAT_WONDER_FIRE;

		// --- cryo: slows and brittles ---
		case W_FIW:
		case W_F2W:
		case W_F2WPAP:
			return WCAT_WONDER_CRYO;

		// --- heavy: explosive payloads ---
		case W_PULVERIZER:
		case W_LONGINUS:
		case W_PENETRATOR:
			return WCAT_WONDER_HEAVY;

		// --- melee and equipment ---
		case W_BK:
		case W_KRAUS:
		case W_BOWIE:
			return WCAT_MELEE;
		case W_GRENADE:
		case W_BETTY:
			return WCAT_EQUIPMENT;

		// --- contemporary service weapons ---
		case W_MP5K:
		case W_KOLLIDER:
		case W_PPSH:
		case W_REAPER:
		case W_PTRS:
		case W_SPRING:
		case W_MP5KPDW:
		case W_MP5KPDWPAP:
		case W_M40A1:
		case W_M40A1PAP:
		case W_MOSSBERG:
		case W_MOSSBERGPAP:
		case W_MG4:
		case W_MG4PAP:
		case W_VITYAZ:
		case W_VITYAZPAP:
		case W_SMAW:
		case W_SMAWPAP:
			return WCAT_MODERN;

		// --- near-future / experimental ---
		case W_AW50:
		case W_AW50PAP:
			return WCAT_PROTOTYPE;

		// --- Cold War issue: the original 1960s-80s roster plus the variants built on it.
		// Naming them all out rather than leaning on the default keeps the table complete,
		// so the era of every shipped weapon is written down somewhere.
		case W_COLT:
		case W_KAR:
		case W_THOMPSON:
		case W_357:
		case W_BAR:
		case W_BROWNING:
		case W_DB:
		case W_FG:
		case W_GEWEHR:
		case W_KAR_SCOPE:
		case W_M1:
		case W_M1A1:
		case W_MP40:
		case W_MG:
		case W_PANZER:
		case W_SAWNOFF:
		case W_STG:
		case W_TRENCH:
		case W_TYPE:
		case W_BIATCH:
		case W_KILLU:
		case W_COMPRESSOR:
		case W_M1000:
		case W_WIDDER:
		case W_ARMAGEDDON:
		case W_GIBS:
		case W_SAMURAI:
		case W_SPATZ:
		case W_SNUFF:
		case W_BORE:
		case W_IMPELLER:
		case W_BARRACUDA:
		case W_ACCELERATOR:
		case W_GUT:
		case W_HEADCRACKER:
		case W_WIDOW:
		case W_HIPOWER:
		case W_HIPOWERPAP:
		case W_MODEL70:
		case W_MODEL70PAP:
		case W_MAGNUM44:
		case W_MAGNUM44PAP:
		case W_COACHGUN:
		case W_COACHGUNPAP:
		case W_SLR:
		case W_SLRPAP:
		case W_GALIL:
		case W_GALILPAP:
		case W_PKM:
		case W_PKMPAP:
		case W_VSS:
		case W_VSSPAP:
		case W_M2CARBINE:
		case W_M2CARBINEPAP:
		case W_MP5SD:
		case W_MP5SDPAP:
		case W_CGM45:
		case W_CGM45PAP:
		case W_PSG1:
		case W_PSG1PAP:
		case W_AKS74U:
		case W_AKS74UPAP:
			return WCAT_RETRO;

		// An id nobody has categorised yet: the original roster's era is the safe answer.
		default:
			return WCAT_RETRO;
	}

	return WCAT_RETRO;
}

// WepDef_IsWonderWeapon(weapon)
// True for every category that behaves like a wonder weapon, i.e. the elemental
// families - not "has a special model" or "came out of the box".
float(float weapon) WepDef_IsWonderWeapon =
{
	float category = WepDef_GetCategory(weapon);
	return (category >= WCAT_WONDER_AETHER) && (category <= WCAT_WONDER_HEAVY);
}

// WepDef_GetElement(weapon)
// The on-hit element implied by the weapon's category. WELEM_NONE for everything that
// is not a wonder weapon, so an ordinary gun can never set a zombie alight.
float(float weapon) WepDef_GetElement =
{
	switch (WepDef_GetCategory(weapon))
	{
		case WCAT_WONDER_AETHER: return WELEM_AETHER;
		case WCAT_WONDER_SHOCK:  return WELEM_SHOCK;
		case WCAT_WONDER_FIRE:   return WELEM_FIRE;
		case WCAT_WONDER_CRYO:   return WELEM_CRYO;
		case WCAT_WONDER_HEAVY:  return WELEM_HEAVY;
		default: return WELEM_NONE;
	}

	return WELEM_NONE;
}

// WepDef_GetCategoryName(category)
// Display label for menus and the HUD, so the categories are visible to the player.
// Categories are read by the client too: the HUD and the menus show them.
string(float category) WepDef_GetCategoryName =
{
	switch (category)
	{
		case WCAT_RETRO:         return "Cold War";
		case WCAT_MODERN:        return "Modern";
		case WCAT_PROTOTYPE:     return "Prototype";
		case WCAT_WONDER_AETHER: return "Aether";
		case WCAT_WONDER_SHOCK:  return "Shock";
		case WCAT_WONDER_FIRE:   return "Incendiary";
		case WCAT_WONDER_CRYO:   return "Cryo";
		case WCAT_WONDER_HEAVY:  return "Heavy";
		case WCAT_MELEE:         return "Melee";
		case WCAT_EQUIPMENT:     return "Equipment";
		default: return "Unknown";
	}

	return "Unknown";
}
