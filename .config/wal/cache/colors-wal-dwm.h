static const char norm_fg[] = "#c3c6ca";
static const char norm_bg[] = "#121e2c";
static const char norm_border[] = "#616b77";

static const char sel_fg[] = "#c3c6ca";
static const char sel_bg[] = "#3F6683";
static const char sel_border[] = "#c3c6ca";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
};
