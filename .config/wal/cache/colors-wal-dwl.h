/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

static const float rootcolor[]             = COLOR(0x190a19ff);
static uint32_t colors[][3]                = {
	/*               fg          bg          border    */
	[SchemeNorm] = { 0xc5c1c5ff, 0x190a19ff, 0x6e596eff },
	[SchemeSel]  = { 0xc5c1c5ff, 0xDB576Eff, 0xB04E74ff },
	[SchemeUrg]  = { 0xc5c1c5ff, 0xB04E74ff, 0xDB576Eff },
};
