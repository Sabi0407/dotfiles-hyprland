const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#121e2c", /* black   */
  [1] = "#3F6683", /* red     */
  [2] = "#565D81", /* green   */
  [3] = "#665B82", /* yellow  */
  [4] = "#4B6584", /* blue    */
  [5] = "#6E6188", /* magenta */
  [6] = "#A46786", /* cyan    */
  [7] = "#c3c6ca", /* white   */

  /* 8 bright colors */
  [8]  = "#616b77",  /* black   */
  [9]  = "#3F6683",  /* red     */
  [10] = "#565D81", /* green   */
  [11] = "#665B82", /* yellow  */
  [12] = "#4B6584", /* blue    */
  [13] = "#6E6188", /* magenta */
  [14] = "#A46786", /* cyan    */
  [15] = "#c3c6ca", /* white   */

  /* special colors */
  [256] = "#121e2c", /* background */
  [257] = "#c3c6ca", /* foreground */
  [258] = "#c3c6ca",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
