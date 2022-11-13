---
layout: post
title:  "Verifying emulator correctness - part 2 (one instruction at a time)"
date:   2022-11-10 12:00:00 +0100
categories: emulators Z80 8080
---

In [the previous part]({% post_url 2022-11-06-verifying-emulator-correctness-1 %}) I explained how I compared my own
emulator to a reference emulator using `diff`. This was done as a debugging technique to find out what's wrong with my
implementation of specific instructions. In this post I'll show how I deal with very long running tests that creates too
much log data to diff in an ordinary way. By too much log data I'm talking about tens, hundreds or even thousands of
gigabytes.

### The goal

Instead of running the tests to completion, one can do the following instead:

- Set up the emulators to print their state to stdout as usual. This should be done for every instruction.
- A new instruction should only run after receiving a command via stdin. E.g. after receiving an 'n' character and
  then line shift.
- The emulator under test and reference emulator should run in parallel and execute the same instruction at any given
  time.
- A program should automatically send 'n' to each emulator to run a new instruction. It should listen to their stdouts
  and then compare the output after each instruction. If the log output is equal between both emulators, send 'n' again
  to run a new instruction. If not, a diff has been found.

The program that's used for testing only has to store one instruction. We don't have to store the log data of previously
run instructions. Only the currently run instruction has to be stored in memory at any given time. Or perhaps the last
10-20 instructions to make it easier to locate where the error is.

### Setting up our own emulator and the reference emulator

For this to work, we have to set up our own emulator and the reference emulator. The emulators should first be set up as
in [the first post]({% post_url 2022-11-06-verifying-emulator-correctness-1 %}). The emulators should then be modified
to only run a new instruction after receiving an 'n' character.

In my emulator, I'll change:

```cpp
void CpmApplicationSession::run() {
    std::cout << "--------------- Starting " << m_loaded_file << " ---------------\n\n";
    m_cpu->start();

    while (m_cpu->can_run_next_instruction() && !m_is_finished) {
        m_cpu->next_instruction();
    }

    m_cpu->stop();
    std::cout << "\n\n--------------- Finished " << m_loaded_file << " ---------------\n\n";
}
```

to:

```cpp
void CpmApplicationSession::run() {
    std::cout << "--------------- Starting " << m_loaded_file << " ---------------\n\n";
    m_cpu->start();
    std::string next;

    while (m_cpu->can_run_next_instruction() && !m_is_finished) {
        m_cpu->next_instruction();
        std::cin >> next;
        if (next == "q") {
            break;
        }
    }

    m_cpu->stop();
    std::cout << "\n\n--------------- Finished " << m_loaded_file << " ---------------\n\n";
}
```

In my case, it responds to any character, not only 'n', but that's fine. 'q' is an exception. When the emulator receives
that it quits. When zexdoc is run with the emulator it will look like this:

```
$ ./emulator run zexdoc
--------------- Starting roms/z80/zexdoc.cim ---------------

pc=0x0101,sp=0xffff,op=0xc3,a=0xff,b=0x00,c=0x00,d=0x00,e=0x00,h=0x00,l=0x00,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x0000,iy=0x0000,i=0x00,r=0x00,c=1,po=1,hc=1,n=1,z=1,s=1,y=1,x=1
n
pc=0x0114,sp=0xffff,op=0x2a,a=0xff,b=0x00,c=0x00,d=0x00,e=0x00,h=0x00,l=0x00,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x0000,iy=0x0000,i=0x00,r=0x01,c=1,po=1,hc=1,n=1,z=1,s=1,y=1,x=1
n
pc=0x0117,sp=0xffff,op=0xf9,a=0xff,b=0x00,c=0x00,d=0x00,e=0x00,h=0xc9,l=0x00,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x0000,iy=0x0000,i=0x00,r=0x02,c=1,po=1,hc=1,n=1,z=1,s=1,y=1,x=1
n
pc=0x0118,sp=0xc900,op=0x11,a=0xff,b=0x00,c=0x00,d=0x00,e=0x00,h=0xc9,l=0x00,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x0000,iy=0x0000,i=0x00,r=0x03,c=1,po=1,hc=1,n=1,z=1,s=1,y=1,x=1
n
pc=0x011b,sp=0xc900,op=0x0e,a=0xff,b=0x00,c=0x00,d=0x1d,e=0x56,h=0xc9,l=0x00,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x0000,iy=0x0000,i=0x00,r=0x04,c=1,po=1,hc=1,n=1,z=1,s=1,y=1,x=1
n
pc=0x011d,sp=0xc900,op=0xcd,a=0xff,b=0x00,c=0x09,d=0x1d,e=0x56,h=0xc9,l=0x00,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x0000,iy=0x0000,i=0x00,r=0x05,c=1,po=1,hc=1,n=1,z=1,s=1,y=1,x=1
n
pc=0x1d4b,sp=0xc8fe,op=0xf5,a=0xff,b=0x00,c=0x09,d=0x1d,e=0x56,h=0xc9,l=0x00,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x0000,iy=0x0000,i=0x00,r=0x06,c=1,po=1,hc=1,n=1,z=1,s=1,y=1,x=1
n
pc=0x1d4c,sp=0xc8fc,op=0xc5,a=0xff,b=0x00,c=0x09,d=0x1d,e=0x56,h=0xc9,l=0x00,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x0000,iy=0x0000,i=0x00,r=0x07,c=1,po=1,hc=1,n=1,z=1,s=1,y=1,x=1
q


--------------- Finished roms/z80/zexdoc.cim ---------------
```

'n' for new instruction and 'q' for quitting.

Setting up the reference emulator is done by changing ([here][z80_tests_change_place] in the code):

```c
while (!test_finished) {
    nb_instructions += 1;

    // warning: the following line will output dozens of GB of data.
    // z80_debug_output(z);

    z80_step(z);
}
```

to:

```c
setbuf(stdout, NULL);
char inp[20];
while (!test_finished) {
    nb_instructions += 1;

    // warning: the following line will output dozens of GB of data.
    // z80_debug_output(z);

    z80_step(z);
    scanf("%19s", inp);
    if (strcmp(inp, "q") == 0) {
        return 0;
    }
}
```

It will also continue when receving any character other than 'q'. `setbuf(stdout, NULL);` is added to make the output
stream unbuffered. It will print to stdout immediately.

### Using the emulator exerciser

I have made a [Python program][compare_emulators_interactively.py] that runs the emulators in parallel. It will compare
the outputs of each emulator and then send a 'n' character (and line shift) after each instruction without diff. If it
finds a diff it will print out the 20 previously run instructions. There are a few parameters that can be adjusted after
the `Emulator` class definition. The most important parameters are the arguments that are used to start the two
emulators: `emulator_under_test` and `reference_emulator`. `log_line_token` should be changed to contain a string that
each log line contains. This is used to differentiate between instruction log lines and other types of output to stdout.


```python
import asyncio


class Emulator:
    def __init__(self, name: str, args: []):
        self.name = name
        self.args = args

    def __str__(self):
        name = self.name
        maybe_space = ' ' if len(self.args) > 0 else ''
        args = ' '.join(self.args)

        return './' + name + maybe_space + args


# Must be adapted to each emulator:
emulator_under_test = Emulator('emulator', ['run', 'zexdoc'])
reference_emulator = Emulator('z80_tests', [])
log_line_token = 'pc=0x'

# Can be changed if you really want to:
queue_length = 20
log_string_encoding = 'utf-8'
new_instruction_character = b"n\n"


async def setup(sut_config: Emulator, ref_config: Emulator):
    sut = await asyncio.subprocess.create_subprocess_exec(
        f'./{sut_config.name}', *sut_config.args,
        stdin=asyncio.subprocess.PIPE,
        stdout=asyncio.subprocess.PIPE
    )
    ref = await asyncio.subprocess.create_subprocess_exec(
        f'./{ref_config.name}', *ref_config.args,
        stdin=asyncio.subprocess.PIPE,
        stdout=asyncio.subprocess.PIPE
    )

    return sut, ref


async def get_to_first_line(emu_process: asyncio.subprocess.Process):
    binary_line = await emu_process.stdout.readuntil(b"\n")

    while binary_line:
        str_line = binary_line.decode(log_string_encoding).strip("\n")
        if log_line_token in str_line:
            return str_line
        else:
            emu_process.stdin.write(new_instruction_character)

        binary_line = await emu_process.stdout.readuntil(b"\n")


def print_arrow_at_first_diff(sut_line, ref_line, offset):
    diff_pos = 0
    for pos in range(0, len(sut_line)):
        if sut_line[pos] == ref_line[pos]:
            diff_pos += 1
        else:
            break

    print(' ' * (diff_pos + offset) + '^')


async def compare_emulator_outputs(sut, sut_line, ref, ref_line):
    sut.stdin.write(new_instruction_character)
    ref.stdin.write(new_instruction_character)
    queue = []
    line_number = 0

    while sut_line == ref_line:
        if len(queue) < queue_length:
            queue.append(sut_line)
        else:
            queue.append(sut_line)
            queue.pop(0)

        if "pc=0x" not in sut_line:
            print(sut_line)

        sut_binary_line = await sut.stdout.readuntil(b"\n")
        sut_line = sut_binary_line.decode(log_string_encoding).strip("\n")
        sut.stdin.write(new_instruction_character)

        ref_binary_line = await ref.stdout.readuntil(b"\n")
        ref_line = ref_binary_line.decode(log_string_encoding).strip("\n")
        ref.stdin.write(new_instruction_character)

        line_number += 1

        if line_number % 1000000 == 0:
            print(f"At line number: {line_number:,}")

    print("********** FOUND DIFFERENCE IN THE EMULATORS **********")
    print(f"Line number: {line_number}\n\n")
    print(f"Last {queue_length} instructions before the diff:\n")
    for line in queue:
        print(line)

    print()
    print(f"SUT: {sut_line}")
    print(f"REF: {ref_line}")
    print_arrow_at_first_diff(sut_line, ref_line, 5)


async def main():
    sut, ref = await setup(emulator_under_test, reference_emulator)

    print(f"\nStarting comparison between '{emulator_under_test}' and '{reference_emulator}'")

    sut_line = await get_to_first_line(sut)
    ref_line = await get_to_first_line(ref)

    print("Found the first log lines of each emulator. Starting on comparison...\n\n")

    await compare_emulator_outputs(sut, sut_line, ref, ref_line)


asyncio.run(main())
```

The program will first ignore the initial lines that don't contain `log_line_token`. We don't want to compare the
metadata (e.g. "Emulator started" stuff that's often printed at the beginning of an execution), hence the
`get_to_first_line` function.

I've not put any effort into making it quit gracefully. If it doesn't find any errors it will raise exceptions of type
BrokenPipe. These errors can be ignored.

Here's how it works in action. I'm running zexdoc with an error in `add ix,<bc,de,ix,sp>`. This time I'm running the
entire zexdoc test program with all its tests:

```
$ ./emulator run zexdoc
--------------- Starting roms/z80/zexdoc.cim ---------------

Z80doc instruction exerciser
<adc,sbc> hl,<bc,de,hl,sp>....  OK
add hl,<bc,de,hl,sp>..........  OK
add ix,<bc,de,ix,sp>..........  ERROR **** crc expected:c133790b found:a79b9a0d
add iy,<bc,de,iy,sp>..........  ERROR **** crc expected:e8817b9e found:8e299898
aluop a,nn....................  OK
aluop a,<b,c,d,e,h,l,(hl),a>..  OK
aluop a,<ixh,ixl,iyh,iyl>.....  OK
aluop a,(<ix,iy>+1)...........  OK
bit n,(<ix,iy>+1).............  OK
bit n,<b,c,d,e,h,l,(hl),a>....  OK
cpd<r>........................  OK
cpi<r>........................  OK
<daa,cpl,scf,ccf>.............  OK
<inc,dec> a...................  OK
<inc,dec> b...................  OK
<inc,dec> bc..................  OK
<inc,dec> c...................  OK
<inc,dec> d...................  OK
<inc,dec> de..................  OK
<inc,dec> e...................  OK
<inc,dec> h...................  OK
<inc,dec> hl..................  OK
<inc,dec> ix..................  OK
<inc,dec> iy..................  OK
<inc,dec> l...................  OK
<inc,dec> (hl)................  OK
<inc,dec> sp..................  OK
<inc,dec> (<ix,iy>+1).........  OK
<inc,dec> ixh.................  OK
<inc,dec> ixl.................  OK
<inc,dec> iyh.................  OK
<inc,dec> iyl.................  OK
ld <bc,de>,(nnnn).............  OK
ld hl,(nnnn)..................  OK
ld sp,(nnnn)..................  OK
ld <ix,iy>,(nnnn).............  OK
ld (nnnn),<bc,de>.............  OK
ld (nnnn),hl..................  OK
ld (nnnn),sp..................  OK
ld (nnnn),<ix,iy>.............  OK
ld <bc,de,hl,sp>,nnnn.........  OK
ld <ix,iy>,nnnn...............  OK
ld a,<(bc),(de)>..............  OK
ld <b,c,d,e,h,l,(hl),a>,nn....  OK
ld (<ix,iy>+1),nn.............  OK
ld <b,c,d,e>,(<ix,iy>+1)......  OK
ld <h,l>,(<ix,iy>+1)..........  OK
ld a,(<ix,iy>+1)..............  OK
ld <ixh,ixl,iyh,iyl>,nn.......  OK
ld <bcdehla>,<bcdehla>........  OK
ld <bcdexya>,<bcdexya>........  OK
ld a,(nnnn) / ld (nnnn),a.....  OK
ldd<r> (1)....................  OK
ldd<r> (2)....................  OK
ldi<r> (1)....................  OK
ldi<r> (2)....................  OK
neg...........................  OK
<rrd,rld>.....................  OK
<rlca,rrca,rla,rra>...........  OK
shf/rot (<ix,iy>+1)...........  OK
shf/rot <b,c,d,e,h,l,(hl),a>..  OK
<set,res> n,<bcdehl(hl)a>.....  OK
<set,res> n,(<ix,iy>+1).......  OK
ld (<ix,iy>+1),<b,c,d,e>......  OK
ld (<ix,iy>+1),<h,l>..........  OK
ld (<ix,iy>+1),a..............  OK
ld (<bc,de>),a................  OK
Tests complete

--------------- Finished roms/z80/zexdoc.cim ---------------
```

Running the comparison program gives us the following:

```
$ time ../../helpers/compare_emulators_interactively.py

Starting comparison between './emulator run zexdoc' and './z80_tests'
Found the first log lines of each emulator. Starting on comparison...


Z80doc instruction exerciser
At line number: 1,000,000
At line number: 2,000,000
At line number: 3,000,000
At line number: 4,000,000
At line number: 5,000,000
...
At line number: 416,000,000
At line number: 417,000,000
At line number: 418,000,000
At line number: 419,000,000
OK
********** FOUND DIFFERENCE IN THE EMULATORS **********
Line number: 419694962


Last 20 instructions before the diff:

pc=0x1d2b,sp=0xc8f8,op=0xf5,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x00,l=0x2c,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0xd226,iy=0xc4c7,i=0x00,r=0x5b,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d2c,sp=0xc8f6,op=0xc5,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x00,l=0x2c,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0xd226,iy=0xc4c7,i=0x00,r=0x5c,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d2d,sp=0xc8f4,op=0xd5,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x00,l=0x2c,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0xd226,iy=0xc4c7,i=0x00,r=0x5d,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d2e,sp=0xc8f2,op=0xe5,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x00,l=0x2c,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0xd226,iy=0xc4c7,i=0x00,r=0x5e,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d2f,sp=0xc8f0,op=0xf3,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x00,l=0x2c,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0xd226,iy=0xc4c7,i=0x00,r=0x5f,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d30,sp=0xc8f0,op=0xed,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x00,l=0x2c,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0xd226,iy=0xc4c7,i=0x00,r=0x60,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d31,sp=0xc8f0,op=0x73,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x00,l=0x2c,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0xd226,iy=0xc4c7,i=0x00,r=0x61,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d34,sp=0xc8f0,op=0x31,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x00,l=0x2c,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0xd226,iy=0xc4c7,i=0x00,r=0x62,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d37,sp=0x0105,op=0xfd,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x00,l=0x2c,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0xd226,iy=0xc4c7,i=0x00,r=0x63,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d38,sp=0x0105,op=0xe1,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x00,l=0x2c,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0xd226,iy=0xc4c7,i=0x00,r=0x64,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d39,sp=0x0107,op=0xdd,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x00,l=0x2c,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0xd226,iy=0xc294,i=0x00,r=0x65,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d3a,sp=0x0107,op=0xe1,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x00,l=0x2c,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0xd226,iy=0xc294,i=0x00,r=0x66,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d3b,sp=0x0109,op=0xe1,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x00,l=0x2c,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x635b,iy=0xc294,i=0x00,r=0x67,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d3c,sp=0x010b,op=0xd1,a=0x09,b=0x00,c=0x09,d=0x02,e=0xc3,h=0x33,l=0xd3,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x635b,iy=0xc294,i=0x00,r=0x68,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d3d,sp=0x010d,op=0xc1,a=0x09,b=0x00,c=0x09,d=0x6a,e=0x76,h=0x33,l=0xd3,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x635b,iy=0xc294,i=0x00,r=0x69,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d3e,sp=0x010f,op=0xf1,a=0x09,b=0xfa,c=0x20,d=0x6a,e=0x76,h=0x33,l=0xd3,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x635b,iy=0xc294,i=0x00,r=0x6a,c=1,po=0,hc=0,n=1,z=0,s=1,y=1,x=0
pc=0x1d3f,sp=0x0111,op=0xed,a=0x68,b=0xfa,c=0x20,d=0x6a,e=0x76,h=0x33,l=0xd3,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x635b,iy=0xc294,i=0x00,r=0x6b,c=0,po=1,hc=1,n=0,z=0,s=1,y=0,x=0
pc=0x1d40,sp=0x0111,op=0x7b,a=0x68,b=0xfa,c=0x20,d=0x6a,e=0x76,h=0x33,l=0xd3,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x635b,iy=0xc294,i=0x00,r=0x6c,c=0,po=1,hc=1,n=0,z=0,s=1,y=0,x=0
pc=0x1d43,sp=0x36f5,op=0xdd,a=0x68,b=0xfa,c=0x20,d=0x6a,e=0x76,h=0x33,l=0xd3,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x635b,iy=0xc294,i=0x00,r=0x6d,c=0,po=1,hc=1,n=0,z=0,s=1,y=0,x=0
pc=0x1d44,sp=0x36f5,op=0x09,a=0x68,b=0xfa,c=0x20,d=0x6a,e=0x76,h=0x33,l=0xd3,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x635b,iy=0xc294,i=0x00,r=0x6e,c=0,po=1,hc=1,n=0,z=0,s=1,y=0,x=0

SUT: pc=0x1d45,sp=0x36f5,op=0x00,a=0x68,b=0xfa,c=0x20,d=0x6a,e=0x76,h=0x33,l=0xd3,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x5d7b,iy=0xc294,i=0x00,r=0x6f,c=1,po=1,hc=0,n=0,z=1,s=1,y=0,x=1
REF: pc=0x1d45,sp=0x36f5,op=0x00,a=0x68,b=0xfa,c=0x20,d=0x6a,e=0x76,h=0x33,l=0xd3,a'=0x00,b'=0x00,c'=0x00,d'=0x00,e'=0x00,h'=0x00,l'=0x00,ix=0x5d7b,iy=0xc294,i=0x00,r=0x6f,c=1,po=1,hc=0,n=0,z=0,s=1,y=0,x=1
                                                                                                                                                                                                ^

real    102m29,349s
user    94m30,720s
sys     5m45,139s
```

As we can see, it finds an error after running 419,694,962 instructions. SUT is my emulator's instruction, while REF is
the reference emulator's instruction. The error is related to the zero flag in instruction 0xdd 0x09 (`ADD IX, BC`).

If each line is 201 characters, each character is one byte and we require two log files, we would need
2 * 419,694,962 * 201 * 1 = 168,717,374,724 bytes ≈ 168 GB of disk space if we used the normal diffing approach. The
failing test is quite early in the zexdoc suite. If the error was in one of the final tests, we would have to log 5.6
billion instructions, which would require 2 * 5,600,000,000 * 201 * 1 ≈ 2.25 TB of disk space.

After fixing it the zexdoc suite runs without any problems:

```
$ ./emulator run zexdoc
--------------- Starting roms/z80/zexdoc.cim ---------------

Z80doc instruction exerciser
<adc,sbc> hl,<bc,de,hl,sp>....  OK
add hl,<bc,de,hl,sp>..........  OK
add ix,<bc,de,ix,sp>..........  OK
add iy,<bc,de,iy,sp>..........  OK
aluop a,nn....................  OK
aluop a,<b,c,d,e,h,l,(hl),a>..  OK
aluop a,<ixh,ixl,iyh,iyl>.....  OK
aluop a,(<ix,iy>+1)...........  OK
bit n,(<ix,iy>+1).............  OK
bit n,<b,c,d,e,h,l,(hl),a>....  OK
cpd<r>........................  OK
cpi<r>........................  OK
<daa,cpl,scf,ccf>.............  OK
<inc,dec> a...................  OK
<inc,dec> b...................  OK
<inc,dec> bc..................  OK
<inc,dec> c...................  OK
<inc,dec> d...................  OK
<inc,dec> de..................  OK
<inc,dec> e...................  OK
<inc,dec> h...................  OK
<inc,dec> hl..................  OK
<inc,dec> ix..................  OK
<inc,dec> iy..................  OK
<inc,dec> l...................  OK
<inc,dec> (hl)................  OK
<inc,dec> sp..................  OK
<inc,dec> (<ix,iy>+1).........  OK
<inc,dec> ixh.................  OK
<inc,dec> ixl.................  OK
<inc,dec> iyh.................  OK
<inc,dec> iyl.................  OK
ld <bc,de>,(nnnn).............  OK
ld hl,(nnnn)..................  OK
ld sp,(nnnn)..................  OK
ld <ix,iy>,(nnnn).............  OK
ld (nnnn),<bc,de>.............  OK
ld (nnnn),hl..................  OK
ld (nnnn),sp..................  OK
ld (nnnn),<ix,iy>.............  OK
ld <bc,de,hl,sp>,nnnn.........  OK
ld <ix,iy>,nnnn...............  OK
ld a,<(bc),(de)>..............  OK
ld <b,c,d,e,h,l,(hl),a>,nn....  OK
ld (<ix,iy>+1),nn.............  OK
ld <b,c,d,e>,(<ix,iy>+1)......  OK
ld <h,l>,(<ix,iy>+1)..........  OK
ld a,(<ix,iy>+1)..............  OK
ld <ixh,ixl,iyh,iyl>,nn.......  OK
ld <bcdehla>,<bcdehla>........  OK
ld <bcdexya>,<bcdexya>........  OK
ld a,(nnnn) / ld (nnnn),a.....  OK
ldd<r> (1)....................  OK
ldd<r> (2)....................  OK
ldi<r> (1)....................  OK
ldi<r> (2)....................  OK
neg...........................  OK
<rrd,rld>.....................  OK
<rlca,rrca,rla,rra>...........  OK
shf/rot (<ix,iy>+1)...........  OK
shf/rot <b,c,d,e,h,l,(hl),a>..  OK
<set,res> n,<bcdehl(hl)a>.....  OK
<set,res> n,(<ix,iy>+1).......  OK
ld (<ix,iy>+1),<b,c,d,e>......  OK
ld (<ix,iy>+1),<h,l>..........  OK
ld (<ix,iy>+1),a..............  OK
ld (<bc,de>),a................  OK
Tests complete

--------------- Finished roms/z80/zexdoc.cim ---------------
```

And that's how I find errors when the amount of log data is too much to be saved.

[z80_tests_change_place]: https://github.com/superzazu/z80/blob/d64fe10a2274e5e40019b1086bf7d8990cbc5f23/z80_tests.c#L98
[compare_emulators_interactively.py]: https://github.com/mika-s/MikasEmulators/blob/master/helpers/compare_emulators_interactively.py
