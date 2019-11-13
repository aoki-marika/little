# Little BASIC

A superset of the Tiny BASIC dialect, built with Swift.

Little BASIC was created to serve as a scripting language for other applications, and is largely born out of nostalgia for [TI-BASIC](https://en.wikipedia.org/wiki/TI-BASIC).

For information on Tiny BASIC, see the [user manual](http://users.telenet.be/kim1-6502/tinybasic/tbum.html).
For the grammar definition, see [Appendix B](http://users.telenet.be/kim1-6502/tinybasic/tbum.html#appb).

## Demo

There is a builtin iPad demo app with syntax highlighting and interpreting available that demonstrates usage of the library in an application.

To use it, run the "Demo" target. Note that this application requires iOS 12+, and is only tested on iOS 13.

## Differences

Little BASIC has some small variations from Tiny BASIC.
Generally these differences are to simplify and remove unnecessary space saving measures.

The differences are as follows:

* Line numbers, `GOTO`, and `GOSUB` cannot have whitespace between the digits/characters.
   * For example, `7 8 9`, `GO TO`, and `G O S U B` are all invalid.
* Keywords must have whitespace after themselves.
   * For example, `PRI` would be equivalent to `PRINT I` in Tiny, but in Little this produces an invalid keyword error.
* The `PRINT` statement uses different separators.
   * The `,` separator produces a single space, and the `;` separator produces nothing.
   * For example, `PRINT "A", "B", "C"; "."` produces `A B C.`
* Some statements are omitted.
   * The `INPUT`, `RUN`, and `LIST` statements are all removed as these only function in a command line environment, which Little BASIC is not intended for.
   * The `USR` function is removed as the program can not be allowed to call machine language.
