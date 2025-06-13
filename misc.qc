
/*QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for spotlights, etc.
*/
void() info_null =
{
	remove(self);
};

/*QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for lightning.
*/
void() info_notnull =
{
	self.classname = "info_notnull";
};

//============================================================================

float START_OFF = 1;

void() light_use =
{
	if (self.spawnflags & START_OFF)
	{
		lightstyle(self.style, "m");
		self.spawnflags = self.spawnflags - START_OFF;
	}
	else
	{
		lightstyle(self.style, "a");
		self.spawnflags = self.spawnflags + START_OFF;
	}
};

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
*/
void() light =
{
	if (!self.targetname)
	{	// inert light
		remove(self);
		return;
	}
	
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
};

/*QUAKED light_fluoro (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
Makes steady fluorescent humming sound
*/
void() light_fluoro =
{
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
	
	precache_sound ("ambience/fl_hum1.wav");
	ambientsound (self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_fluorospark (0 1 0) (-8 -8 -8) (8 8 8)
Non-displayed light.
Default light value is 300
Default style is 10
Makes sparking, broken fluorescent sound
*/
void() light_fluorospark =
{
	if (!self.style)
		self.style = 10;

	precache_sound ("ambience/buzz1.wav");
	ambientsound (self.origin, "ambience/buzz1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_globe (0 1 0) (-8 -8 -8) (8 8 8)
Sphere globe light.
Default light value is 300
Default style is 0
*/
void() light_globe =
{
	precache_model ("progs/s_light.spr");
	setmodel (self, "progs/s_light.spr");
	makestatic (self);
};

void() FireAmbient =
{
	precache_sound ("ambience/fire1.wav");
// attenuate fast
	ambientsound (self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20)
Short wall torch
Default light value is 200
Default style is 0
*/
void() light_torch_small_walltorch =
{
	precache_model ("progs/flame.mdl");
	setmodel (self, "progs/flame.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_large_yellow (0 1 0) (-10 -10 -12) (12 12 18)
Large yellow flame ball
*/
void() light_flame_large_yellow =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	self.frame = 1;
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_small_yellow (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Small yellow flame ball
*/
void() light_flame_small_yellow =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_small_white (0 1 0) (-10 -10 -40) (10 10 40) START_OFF
Small white flame ball
*/
void() light_flame_small_white =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	FireAmbient ();
	makestatic (self);
};

//============================================================================


/*QUAKED misc_fireball (0 .5 .8) (-8 -8 -8) (8 8 8)
Lava Balls
*/

void() fire_fly;
void() fire_touch;
void() misc_fireball =
{	
	precache_model ("progs/lavaball.mdl");
	self.classname = "fireball";
	self.nextthink = time + (random() * 5);
	self.think = fire_fly;
	self.netname = "lava_ball";

	if (!self.speed)
		self.speed = 1000;
};

void() fire_fly =
{
local entity	fireball;

	fireball = spawn();
	fireball.solid = SOLID_TRIGGER;
	fireball.movetype = MOVETYPE_TOSS;
	fireball.velocity = '0 0 1000';
	fireball.velocity_x = (random() * 100) - 50;
	fireball.velocity_y = (random() * 100) - 50;
	fireball.velocity_z = self.speed + (random() * 200);
	fireball.classname = "fireball";
	setmodel (fireball, "progs/lavaball.mdl");
	setsize (fireball, '0 0 0', '0 0 0');
	setorigin (fireball, self.origin);
	fireball.nextthink = time + 5;
	fireball.think = SUB_Remove;
	fireball.touch = fire_touch;
	
	self.nextthink = time + (random() * 5) + 3;
	self.think = fire_fly;
};


void() fire_touch =
{
	T_Damage (other, self, self, 20, 0);
	remove(self);
};

//============================================================================

void(string gibname, float vel, vector org) ThrowDebri;
vector(float dm) VelocityForDamage;

void() barrel_explode =
{
	self.takedamage = DAMAGE_NO;
		
	T_RadiusDamage (self, self, 160, world);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() barrel_die = 
{
	// check for gib
	if (self.health < -50)
	{
		barrel_explode();
		return;
	}

	self.takedamage = DAMAGE_NO;
	self.think = barrel_explode;
	self.nextthink = time + 0.2;
	self.th_die = SUB_Null;
};

float CLIMBABLE = 1;

void() barrel_touch =
{
	if(!(other.flags & FL_ONGROUND) && (other.classname != "player") && (other.health <= 0))
		return;

	if (!(other.flags & FL_ONGROUND) )
	{	
		other.flags = other.flags + FL_ONGROUND;
		return;
	}
	
	if(!(self.spawnflags & CLIMBABLE))
	{
		if((other.flags & FL_JUMPRELEASED) && (other.flags & FL_CLIENT)) // this works lmao
			other.flags = other.flags - (other.flags & FL_JUMPRELEASED);
	}

	if(!checkbottom(other)) return;
	
	local float ratio;
	local vector v;
	
	ratio = other.mass / 150; // 150 is the barrel's magic mass
	v = ((self.maxs - self.mins) * 0.5 + self.absmin) - ((other.maxs - other.mins) * 0.5 + other.absmin);
	
	walkmove (vectoyaw(v), 25 * ratio * frametime);
};


/*QUAKED misc_explobox (0 .5 .8) (0 0 0) (32 32 64)
TESTING THING
*/

void() misc_explobox =
{
	local float	oldz;
	
	if(!self.mdl) 
		self.mdl = "maps/b_explob.bsp";

	precache_model ("maps/debri2.bsp");
	
	self.classname = "explo_box";
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;
	precache_model (self.mdl);
	setmodel (self, self.mdl);

	setsize (self, self.mins, self.maxs);
   	setorigin (self, self.origin);

	self.health = 30;
//	self.mass = 150;
	self.touch = barrel_touch;
	self.th_die = barrel_die;

	self.dmg = 120;
	self.color = 233;
	self.takedamage = DAMAGE_YES;
	self.netname = "$qc_exploding_barrel";

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();

	if (oldz - self.origin_z > 250)
	{
		dprint ("explobox fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};




/*QUAKED misc_explobox2 (0 .5 .8) (0 0 0) (32 32 64)
Smaller exploding box, REGISTERED ONLY
*/

void() misc_explobox2 =
{
	self.mdl = "maps/b_exbox2.bsp";
	misc_explobox();

	self.spawnflags += CLIMBABLE;
};

//============================================================================

float SPAWNFLAG_SUPERSPIKE	= 1;
float SPAWNFLAG_LASER = 2;

void() spikeshooter_use =
{
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		sound (self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		LaunchLaser (self.origin, self.movedir);
	}
	else
	{
		sound (self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		launch_spike (self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
			newmis.touch = superspike_touch;
	}
};

void() shooter_think =
{
	spikeshooter_use ();
	self.nextthink = time + self.wait;
	newmis.velocity = self.movedir * 500;
};


/*QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
When triggered, fires a spike in the direction set in QuakeEd.
Laser is only for REGISTERED.
*/

void() trap_spikeshooter =
{
	SetMovedir ();
	self.use = spikeshooter_use;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model ("progs/laser.mdl");
		
		precache_sound ("enforcer/enfire.wav");
		precache_sound ("enforcer/enfstop.wav");
	}
	else
		precache_sound ("weapons/spike2.wav");
};


/*QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
void() trap_shooter =
{
	trap_spikeshooter ();
	
	if (self.wait == 0)
		self.wait = 1;
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
};


float SPAWNFLAG_YELLOW = 1;
float SPAWNFLAG_BLUE = 2;
float SPAWNFLAG_RED = 4;

void() traplaser_use =
{
	local vector end;
	local vector from;
	local entity ignore;
	local vector p1, p2;
	
	p1 = self.origin;

	self.enemy = find(world, targetname, self.target);
	
	if ( (self.enemy.flags & FL_MONSTER) )
		return;
	
	p2 = self.enemy.origin;
		
	from = p1;
	end = from + normalize(p2 - p1) * (vlen(self.origin - self.enemy.origin) - 16); // 16 is our magic number

	ignore = self;

	sound (self, CHAN_AUTO, "weapons/lhit.wav", 1, ATTN_STATIC);

	if (checkclient())
	{
		while(ignore)
		{
			traceline (from, end, 2, ignore);

			if (!trace_ent)
				break;
		
			if((trace_ent != self.owner) && (trace_ent.takedamage))
			{	
				local entity targ = trace_ent;
				T_Damage (targ, self, self, self.dmg, 0);
				particle (targ.origin, '0 0 100', 225, self.dmg* 8);
			}
			
			ignore = trace_ent;
			from = trace_endpos;
		}
			
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);

		if(self.spawnflags & SPAWNFLAG_BLUE)
			WriteByte(MSG_BROADCAST, 5);
		else if(self.spawnflags & SPAWNFLAG_RED)
			WriteByte(MSG_BROADCAST, 6);	
		else
			WriteByte(MSG_BROADCAST, 13);	
		
   		WriteEntity(MSG_BROADCAST, self);
   		WriteCoord(MSG_BROADCAST, p1_x);
   		WriteCoord(MSG_BROADCAST, p1_y);
   		WriteCoord(MSG_BROADCAST, p1_z);
   	 	WriteCoord (MSG_BROADCAST, trace_endpos_x);
		WriteCoord (MSG_BROADCAST, trace_endpos_y);
		WriteCoord (MSG_BROADCAST, trace_endpos_z);
	}
};

void() traplaser_think =
{
	traplaser_use ();
	self.nextthink = time + self.wait;
};

void() traplaser_stop =
{
	self.nextthink = -1;
};

void() trap_laser = 
{			
	self.use = traplaser_use;
	self.solid = SOLID_NOT;
};

void() trap_laser_cont = 
{		
	trap_laser ();
	self.use = traplaser_stop;
	
	sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	
	if (self.wait == 0)
		self.wait = 1;
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = traplaser_think;
};

/*
===============================================================================


===============================================================================
*/


void() make_bubbles;
void() bubble_remove;
void() bubble_bob;

/*QUAKED air_bubbles (0 .5 .8) (-8 -8 -8) (8 8 8)

testing air bubbles
*/

void() air_bubbles =

{
	if (deathmatch)
	{
		remove (self);
		return;
	}
	precache_model ("progs/s_bubble.spr");
	self.nextthink = time + 1;
	self.think = make_bubbles;
};

void() make_bubbles =
{
local entity	bubble;

	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + random() + 0.5;
	self.think = make_bubbles;
};

void() bubble_split =
{
local entity	bubble;
	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = self.velocity;
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 1;
	bubble.cnt = 10;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.frame = 1;
	self.cnt = 10;
	if (self.waterlevel != 3)
		remove (self);
};

void() bubble_remove =
{
	if (other.classname == self.classname)
	{
//		dprint ("bump");
		return;
	}
	remove(self);
};

void() bubble_bob =
{
local float		rnd1, rnd2, rnd3;

	self.cnt = self.cnt + 1;
	if (self.cnt == 4)
		bubble_split();
	if (self.cnt == 20)
		remove(self);

	rnd1 = self.velocity_x + (-10 + (random() * 20));
	rnd2 = self.velocity_y + (-10 + (random() * 20));
	rnd3 = self.velocity_z + 10 + random() * 10;

	if (rnd1 > 10)
		rnd1 = 5;
	if (rnd1 < -10)
		rnd1 = -5;
		
	if (rnd2 > 10)
		rnd2 = 5;
	if (rnd2 < -10)
		rnd2 = -5;
		
	if (rnd3 < 10)
		rnd3 = 15;
	if (rnd3 > 30)
		rnd3 = 25;
	
	self.velocity_x = rnd1;
	self.velocity_y = rnd2;
	self.velocity_z = rnd3;
		
	self.nextthink = time + 0.5;
	self.think = bubble_bob;
};

/*~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>
~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~*/

/*QUAKED viewthing (0 .5 .8) (-8 -8 -8) (8 8 8)

Just for the debugging level.  Don't use
*/

void() viewthing =

{
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	precache_model ("progs/player.mdl");
	setmodel (self, "progs/player.mdl");
};


/*
==============================================================================

SIMPLE BMODELS

==============================================================================
*/

void() func_wall_use =
{	// change to alternate textures
	self.frame = 1 - self.frame;
};

/*QUAKED func_wall (0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
void() func_wall =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

/*QUAKED func_breakable (0 .5 .8) ?
make bmodels kaboom
*/

float GLASS = 1;
float METAL = 2;

void(string gibname, float vel, vector org) ThrowDebri =
{
	local	entity new;
	new = spawn();
	new.origin = org;

	setmodel (new, gibname);
	setsize (new, '0 0 0', '0 0 0');
	
	new.velocity = self.velocity + VelocityForDamage(vel);
	new.velocity = ClipGibVelocity(new.velocity);
	
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	new.think = SUB_Remove;
	new.ltime = time;
	new.nextthink = time + 10 + random()*10;
	new.frame = 0;
	new.flags = 0;
};

void() breakable_explode =
{
	self.takedamage = DAMAGE_NO;
	self.classname = "explo_box";

	local vector size;
	local vector org;
	local vector chunkorigin;

	size = (self.maxs - self.mins) * 0.5;
	org = size + self.absmin;
	self.origin = org;
	
	SUB_UseTargets();

	if((self.spawnflags & GLASS))
		sound (self, CHAN_AUTO, "world/brkglas.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_AUTO, "weapons/r_exp3.wav", 1, ATTN_NORM);		
	
	if(self.mass <= 0 && (self.mdl == "maps/debri.bsp" || self.mdl == "maps/debri2.bsp"))
		self.mass = 8;
	
	if (self.mass > 0)
	{
		while(self.mass--)
		{
			chunkorigin_x = org_x + crandom() * size_x;
			chunkorigin_y = org_y + crandom() * size_y;
			chunkorigin_z = org_z + crandom() * size_z;
			ThrowDebri (self.mdl, 1, chunkorigin);
		}
	}
	
	if(self.dmg)
		T_RadiusDamage (self, self, self.dmg + 60, world);
	BecomeExplosion();

	if( (self.spawnflags & GLASS) && !self.dmg)
		remove(self);

	if( (self.spawnflags & METAL) && !self.dmg)
		remove(self);
};

void() func_breakable =
{	
	self.classname = "func_breakable";
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.max_health = self.health;
	self.dmg = self.dmg;
	self.cnt = self.cnt;
	self.color = 233;
	self.mass = self.mass;
	self.th_die = breakable_explode;
	
	if(self.spawnflags & GLASS)
	{
		precache_sound ("world/brkglas.wav");
		self.mdl = "maps/debri.bsp";
		precache_model ("maps/debri.bsp");
	}
	else if(self.spawnflags & METAL)
	{
		self.mdl = "maps/debri2.bsp";
		precache_model ("maps/debri2.bsp");
	}

	self.takedamage = DAMAGE_YES;
	setmodel (self, self.model);
	setorigin (self, self.origin);
};

//============================================================================

//============================================================================

/*QUAKED func_illusionary (0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
void() func_illusionary =

{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.model);
	makestatic (self);
};

/*QUAKED func_episodegate (0 .5 .8) ? E1 E2 E3 E4
This bmodel will appear if the episode has allready been completed, so players can't reenter it.
*/
void() func_episodegate =

{
	if (!(serverflags & self.spawnflags))
		return;			// can still enter episode

	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

/*QUAKED func_bossgate (0 .5 .8) ?
This bmodel appears unless players have all of the episode sigils.
*/
void() func_bossgate =

{
	if ( (serverflags & 15) == 15)
		return;		// all episodes completed
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

//============================================================================
/*QUAKED ambient_suck_wind (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_suck_wind =
{
	precache_sound ("ambience/suck1.wav");
	ambientsound (self.origin, "ambience/suck1.wav", 1, ATTN_STATIC);
};

/*QUAKED ambient_drone (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drone =
{
	precache_sound ("ambience/drone6.wav");
	ambientsound (self.origin, "ambience/drone6.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_flouro_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_flouro_buzz =
{
	precache_sound ("ambience/buzz1.wav");
	ambientsound (self.origin, "ambience/buzz1.wav", 1, ATTN_STATIC);
};
/*QUAKED ambient_drip (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drip =
{
	precache_sound ("ambience/drip1.wav");
	ambientsound (self.origin, "ambience/drip1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_comp_hum (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_comp_hum =
{
	precache_sound ("ambience/comp1.wav");
	ambientsound (self.origin, "ambience/comp1.wav", 1, ATTN_STATIC);
};
/*QUAKED ambient_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_thunder =
{
	precache_sound ("ambience/thunder1.wav");
	ambientsound (self.origin, "ambience/thunder1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_light_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_light_buzz =
{
	precache_sound ("ambience/fl_hum1.wav");
	ambientsound (self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_swamp1 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp1 =
{
	precache_sound ("ambience/swamp1.wav");
	ambientsound (self.origin, "ambience/swamp1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_swamp2 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp2 =
{
	precache_sound ("ambience/swamp2.wav");
	ambientsound (self.origin, "ambience/swamp2.wav", 0.5, ATTN_STATIC);
};

void() ambient_radio1 =
{
	precache_sound ("world/radio2.wav");
	ambientsound (self.origin, "ambience/radio2.wav", 1, ATTN_STATIC);
};

void() ambient_radio2 =
{
	precache_sound ("world/radio3.wav");
	ambientsound (self.origin, "ambience/radio3.wav", 1, ATTN_STATIC);
};

void() ambient_noisemaker =
{
	trigger_noisemaker ();
};

//============================================================================
// GIBS//

vector(float dm) VelocityForDamage =
{
	local  vector v;

	v_x = 100 * crandom();
	v_y = 100 * crandom();
	v_z = 200 + 100 * random();

	if (dm < 50)
	{
		v = v * 0.7;
	}
		v = v * 1.2;

	return v;
};

vector (vector vel) ClipGibVelocity =
{
	if (vel_x < -300)
		vel_x = -300;
	else if (vel_x > 300)
		vel_x = 300;
	if (vel_y < -300)
		vel_y = -300;
	else if (vel_y > 300)
		vel_y = 300;
	if (vel_z < 200)
        	vel_z = 200;    // always some upwards
    	else if (vel_z > 500)
        	vel_z = 500;

	return vel;
};

void(string gibname, float dm) ThrowGib =
{	
	local vector size = (self.maxs - self.mins) * 0.5;
	local	vector org = size + self.absmin;
	local vector chunkorg;
	
	chunkorg_x = org_x + crandom() * size_x;
	chunkorg_y = org_y + crandom() * size_y;
	chunkorg_z = org_z + crandom() * size_z;
	
	local	entity new;
	new = spawn();
	new.origin = chunkorg;
	
	setmodel (new, gibname);
	setsize (new, '0 0 0', '0 0 0');

	new.velocity = self.velocity + VelocityForDamage(dm)*0.5;
	new.velocity = ClipGibVelocity(new.velocity);
	
	new.movetype = MOVETYPE_TOSS;
	new.solid = SOLID_NOT;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	new.think = SUB_Remove;
	new.ltime = time;
	new.nextthink = time + 10 + random()*10;
	new.frame = 0;
	new.flags = 0;
};

void(string gibname, float dm) ThrowHead =
{
	local	entity new;
	new = spawn();
	new.origin = self.origin;
	setmodel (new, gibname);
	setsize (new, '-16 -16 0', '16 16 56');

	new.velocity = self.velocity + VelocityForDamage(dm);
	new.velocity = ClipGibVelocity(new.velocity);
	
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity = crandom() * '0 600 0';
	new.origin_z = new.origin_z + 4;
	new.think = SUB_Remove;
	new.ltime = time;
	new.nextthink = time + 10 + random()*10;
	new.frame = 0;
	new.flags = 0;
};

void(string gibname, float dm) ThrowGibBoss =
{
	local	entity new;
	new = spawn();
	new.origin = self.origin;
	new.origin_z = new.origin_z + 24;
	setmodel (new, gibname);
	setsize (new, '0 0 0', '0 0 0');

	new.velocity = VelocityForDamage(dm)*2;
	new.velocity = ClipGibVelocity(new.velocity);
	
	new.movetype = MOVETYPE_TOSS;
	new.solid = SOLID_NOT;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	new.think = SUB_Remove;
	new.ltime = time;
	new.nextthink = time + 10 + random()*10;
	new.frame = 0;
	new.flags = 0;
};

void(string gibname, float dm) ThrowHeadBoss =
{
	local	entity new;
	new = spawn();
	new.origin = self.origin;
	setmodel (new, gibname);
	setsize (new, '-16 -16 0', '16 16 56');

	new.velocity = VelocityForDamage(dm)*2;
	new.velocity = ClipGibVelocity(new.velocity);
	
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity = crandom() * '0 600 0';
	new.origin_z = new.origin_z + 64;

	new.nextthink = -1;
	new.frame = 0;
	new.flags = 0;
};

void() func_gib =
{	
	self.origin_z += 16;
	droptofloor();
	setsize (self, '0 0 0', VEC_ORIGIN);
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;	
	
	self.cnt = self.cnt;

	switch(self.cnt)
      {
   		case 1:
    			setmodel (self, "progs/gib1.mdl");
     			break;
   		case 2:
     			setmodel (self, "progs/gib2.mdl");	
			break;
   		default:
     			setmodel (self, "progs/gib3.mdl");
     			break;
   	} 
	
	self.frame = 0;
};

void() func_creator =
{
	precache_model ("progs/creator.mdl");

	setmodel (self, "progs/creator.mdl");

	setsize (self, '0 0 -24', VEC_HULL_MAX);
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.origin_z += 32;
	droptofloor();
};

void() func_corpse =
{
	precache_model ("progs/player.mdl");

	setmodel (self, "progs/player.mdl");

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	self.skin = 1;
	self.cnt = self.cnt;

	switch(self.cnt)
      {
   		case 1:
    			self.frame = 60;
     			break;
   		case 2:
     			self.frame = 69;	
			break;
		case 3:
     			self.frame = 84;	
			break;
		case 4:
     			self.frame = 93;	
			break;
		case 5:
     			self.frame = 102;
			break;
   		default:
     			self.frame = 49;
     			break;
   	} 
};
