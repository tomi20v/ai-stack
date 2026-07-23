# Model observations

These are not very scientific observations, I'd even call then subjective, of different models under copilot/claude

## Tooling

### Claude

Uses a lot of initial prompt. However, these get cached properly - unless it start some kind of loop. Because the huge inital loop, a warmup (just saying "hello", though this gives strange session names) is necessary, othervise it can timeout on the first prompt.

In general works fine, and is powerful, though it tends to go into some internal loop. Once it was repeating the same same failing tool call over and over.

claude-code was complaining about updates when run inside a docker

### Copilot

Copilet uses much less initial context, no need for warmups in general.

## The models

### gpt-oss:20b

Capable and very fast, for general chitchatting. It might write some simple code, but most of the time rather fails. Poor tool use, it can hang ollama

### gemma4-12b

Not very capable, sometimes usable. Not even soooo fast

### gemma4-26b

This one runs in a split GPU/CPU mode, 66-75% GPU depending on context (128k: 66, 64k: 75). Speed is quite ok still, up to 50tok/sec
- it could write most of the launchers, copilot claude similar - but sometimes got offtrack.

### gemma4-31b

Terribly slow, about 1.6tok/sec. It doesn't seem to grasp what to do most of the time

### qwen3-coder:30b

A bit sluggish, 15 tps, but it just keeps going. Even when making mistakes, it seems to find them and fix them. However, it totally disobeys working in just one vertical at once and other orders. 
- On the other hand, the only model which could actually implement the template.sh BUT it went down a loophole, I had to tell him how to do the loop.
- Funny bunny leaves test stuff around, then, when I already removed them, it suddenly wants to remove them in the middle of something totally different...
- Funny bunny runs a lot of seemingly even incorrect checks after completing the specs plan. In one occasion it actually broke the working implementation. This might work better with stored, automated tests?
- Refuses to archive spec and plan files, just does the beforementioned "final testing"
- Quite impossible to do spec/planning only, step by step - it launches itself, maps out the whole repo, and does everything at once



