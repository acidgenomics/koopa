# Run Emacs in terminal with 24-bit color support

Updated 2019-09-19.

See also:
https://www.gnu.org/software/emacs/manual/html_node/efaq/Colors-on-a-TTY.html

- iTerm2 works well with colon separators.
- This doesn't work in PuTTY on Windows.

```sh
tic -x -o ~/.terminfo terminfo-24bit-colon.src
TERM=xterm-24bit emacs --no-window-system
```
