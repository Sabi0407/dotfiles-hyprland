const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#190a19", /* black   */
  [1] = "#B04E74", /* red     */
  [2] = "#DB576E", /* green   */
  [3] = "#3C6D8A", /* yellow  */
  [4] = "#6E4787", /* blue    */
  [5] = "#614883", /* magenta */
  [6] = "#955089", /* cyan    */
  [7] = "#c5c1c5", /* white   */

  /* 8 bright colors */
  [8]  = "#6e596e",  /* black   */
  [9]  = "#B04E74",  /* red     */
  [10] = "#DB576E", /* green   */
  [11] = "#3C6D8A", /* yellow  */
  [12] = "#6E4787", /* blue    */
  [13] = "#614883", /* magenta */
  [14] = "#955089", /* cyan    */
  [15] = "#c5c1c5", /* white   */

  /* special colors */
  [256] = "#190a19", /* background */
  [257] = "#c5c1c5", /* foreground */
  [258] = "#c5c1c5",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
