/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)    { ((hex >> 24) & 0xFF) / 255.0f, \
                        ((hex >> 16) & 0xFF) / 255.0f, \
                        ((hex >> 8) & 0xFF) / 255.0f, \
                        (hex & 0xFF) / 255.0f }

static const float rootcolor[]             = COLOR(0x121e2cff);
static uint32_t colors[][3]                = {
	/*               fg          bg          border    */
	[SchemeNorm] = { 0xc3c6caff, 0x121e2cff, 0x616b77ff },
	[SchemeSel]  = { 0xc3c6caff, 0x565D81ff, 0x3F6683ff },
	[SchemeUrg]  = { 0xc3c6caff, 0x3F6683ff, 0x565D81ff },
};
