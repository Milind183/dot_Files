#include <X11/XF86keysym.h>

/* Appearance settings */
static const int vertpad            = 10;       /* vertical padding of bar */
static const int sidepad            = 10;       /* horizontal padding of bar */
static const int barpadding         = 10;
static const unsigned int gappih    = 10;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 10;       /* vert inner gap between windows */
static const unsigned int gappoh    = 10;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 10;       /* vert outer gap between windows and screen edge */

/* appearance */
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int gappx     = 10;       /* gap size between windows */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "JetBrains Mono:size=10" };
static const char dmenufont[]       = "JetBrains Mono:size=10";
static       int smartgaps          = 0;


/* Enum for color schemes */
enum { SchemeStatus, SchemeIndicator, SchemeMsg, SchemeLast };
/* Enum for tag schemes */
enum {  SchemeTag ,SchemeTag1, SchemeTag2, SchemeTag3, SchemeTag4, SchemeTag5 }; // Define all schemes

/* Colors */
static const char col_gray1[]       = "#292c3c";  /* Background color (dark) */
static const char col_gray2[]       = "#8caaee";  /* Inactive window border */
static const char col_gray3[]       = "#f4b8e4";  /* Font color */
static const char col_gray4[]       = "#a6d189";  /* Selected window title text */
static const char col_cyan[]        = "#24273a";  /* Highlight or selected text */
static const char col_white[]       = "#c6a0f6";  /* Foreground color (light) */
static const char col_crust[]       = "#11111b";
static const char col_surface1[]    = "#313244";
static const char col_red[]         = "#ed8796";
static const char col_flaimango[]   = "#f0c6c6";
static const char black[]           = "#181825";
static const char *colors[][3] = {
	                /* fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray4 },  /* Normal */
	[SchemeSel]  = { col_white, col_cyan, col_gray3 },   /* Selected */
	[SchemeStatus]  = { col_flaimango, col_gray1, col_gray3 }, /* Status bar */
	[SchemeIndicator] = { col_white, col_cyan, col_cyan }, /* Indicators */
	[SchemeMsg]     = { col_white, col_gray1, col_gray3 },  /* Message box */
    [SchemeTag]        = { col_gray3,   black,  black },
    [SchemeTag1]       = { col_gray4,    black,  black },
    [SchemeTag2]       = { col_red,     black,  black },
    [SchemeTag3]       = { col_white,  black,  black },
    [SchemeTag4]       = { col_gray2,   black,  black },
    [SchemeTag5]       = { col_flaimango,    black,  black },

};

/* Tags (workspaces) */
static const char *tags[] = { "  ", " ", " ", " ", "" };
 /* Use Nerd Fonts for tags */

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

/* Added for Vanity Gaps */
#define FORCE_VSPLIT 1
#define VANITYGAPS 1
#include "vanitygaps.c"

static const Layout layouts[] = {
    /* symbol     arrange function */
    { "[]=",      tile },    /* first entry is default */
    { "><>",      NULL },    /* no layout function means floating behavior */
    { "[M]",      monocle },
    { "[@]",      spiral },
    { "[\\]",     dwindle },
    { "H[]",      deck },
    { "TTT",      bstack },
    { "===",      bstackhoriz },
    { "HHH",      grid },
    { "###",      nrowgrid },
    { "---",      horizgrid },
    { ":::",      gaplessgrid },
    { "|M|",      centeredmaster },
    { ">M>",      centeredfloatingmaster },
    { "><>",      NULL },    /* no layout function means floating behavior */
    { NULL,       NULL },
};

static const Rule rules[] = {
    /* class      instance    title       tags mask     isfloating   monitor */
    { "Gimp",     NULL,       NULL,       0,            1,           -1 },
    { "Firefox",  NULL,       NULL,       1 << 8,       0,           -1 },
};

/* key definitions */
#define MODKEY Mod1Mask
#define TAGKEYS(KEY,TAG) \
    { MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
    { MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };
static const char *termcmd[]  = { "kitty", NULL };

/* key bindings */
static const Key keys[] = {
    /* modifier                     key        function        argument */
    { MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
    { MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },
    { MODKEY,                       XK_b,      togglebar,      {0} },
    { MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
    { MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
    { MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
    { MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
    { MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
    { MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
    { MODKEY,                       XK_Return, zoom,           {0} },
    { MODKEY,                       XK_Tab,    view,           {0} },
    { MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
    { MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
    { MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
    { MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
    { MODKEY,                       XK_space,  setlayout,      {0} },
    { MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
    { MODKEY,                       XK_0,      view,           {.ui = ~0 } },
    { MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
    { MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
    { MODKEY,                       XK_period, focusmon,       {.i = +1 } },
    { MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
    { MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
    TAGKEYS(                        XK_1,                      0)
    TAGKEYS(                        XK_2,                      1)
    TAGKEYS(                        XK_3,                      2)
    TAGKEYS(                        XK_4,                      3)

    /* Volume control with pamixer */
    { 0,                            XF86XK_AudioRaiseVolume,   spawn, SHCMD("pamixer --increase 5") },
    { 0,                            XF86XK_AudioLowerVolume,   spawn, SHCMD("pamixer --decrease 5") },
    { 0,                            XF86XK_AudioMute,          spawn, SHCMD("pamixer --toggle-mute") },

    /* Brightness control */
    { 0, XF86XK_MonBrightnessUp,   spawn, SHCMD("xbacklight -inc 10") },
    { 0, XF86XK_MonBrightnessDown, spawn, SHCMD("xbacklight -dec 10") },
};

/* button definitions */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
