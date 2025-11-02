static const char norm_fg[] = "#c5c1c5";
static const char norm_bg[] = "#190a19";
static const char norm_border[] = "#6e596e";

static const char sel_fg[] = "#c5c1c5";
static const char sel_bg[] = "#B04E74";
static const char sel_border[] = "#c5c1c5";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
};
