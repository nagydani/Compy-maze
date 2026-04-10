# Maze

A game for learning to program by guiding a turtle
through a maze!

## Goal

Push every yellow box onto a cyan square to win!
If there is a red circle, you can also win by
reaching it.

## Controls

Each level uses one of two control modes.

### Key Mode

Press keys to tell the turtle where to go. Each key
adds a command and you hear a short ping.

You can give directions on a compass:

  N — North
  S — South
  E — East
  W — West

Or tell the turtle to move and turn relative to where
it is facing:

  F — move forward
  B — move backward
  L — turn left
  R — turn right

Commands run one after another. You can press several
keys in a row and the turtle will follow them in order.

#### Recording Shortcuts

You can save a sequence of keys as a shortcut:

 1. Hold Shift and press a key — this names your
    shortcut. You hear a beep and see the key on
    screen with a blue background.
 2. While still holding Shift, press up to 7 keys —
    each one makes a click sound and appears on
    screen.
 3. Release Shift to save your shortcut.

Now just press your shortcut key to replay the whole
sequence!

To erase a shortcut, hold Shift, press the key, and
release Shift right away without adding any keys.

You cannot use N, E, S, W, F, B, L or R as shortcut
names — those are already commands.

While Shift is held, the screen dims to show you are
in recording mode.

### Editor Mode

Type commands in the text field at the bottom and
press Enter to run them. You hear a ping for each
valid command.

The same compass and relative commands are available.
Both uppercase and lowercase letters work. Any other
characters are ignored.

You can type several commands at once, for example
SSEEF, and they will run in order when you press
Enter.

#### Repeating Commands

Put a number before a command to repeat it:

    3R

This turns right three times.

#### Defining Shortcuts

Give a name to a sequence of commands by typing a
letter, an equal sign, and the commands:

    X=3R

Now typing X anywhere runs three right turns.

Shortcuts can build on each other:

    X=3R
    X=2X
    X

This runs six right turns.

You cannot use N, E, S, W, F, B, L or R as shortcut
names — those are already commands.

#### Multiple Lines

Press Shift+Enter to type several lines at once. All
lines run in order when you press Enter. If any line
has a mistake, nothing runs and you hear a warning
sound so you can fix it.

## What Happens

The turtle turns and moves with a short animation.

When moving forward, it leaves a bright trail behind.
Moving backward leaves no trail.

If the turtle hits a wall, it flashes red, you hear
a sound, and the maze resets so you can try again.

When you reach the red circle, you hear a victory
sound and the circle disappears.

## Pushing Boxes

Some levels have yellow boxes. You can push a box by
walking into it. The box moves one square in the
direction you are pushing.

A box can only be pushed if the square behind it is
empty. If it cannot move, the turtle bumps against it
like a wall.

## Box Goals

Some levels have cyan squares on the floor. Push
every yellow box onto a cyan square to win! You hear
a victory sound when all boxes are in place.

## Level Progression

The game has multiple levels. Complete a level to
advance to the next one. The last level completed
quits the game.

Defined shortcuts carry over between levels.
Commands entered before a level ends will continue
in the next level.

## The Screen

The maze is shown in the center. Walls are blue,
open paths are white. The bottom right corner shows
all available commands.

Press Escape to quit.
