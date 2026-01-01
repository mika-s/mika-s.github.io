---
layout: post
title:  "Creating a Wireshark USB dissector in Lua - part 1 (mouse)"
date:   2019-07-23 15:00:00 +0100
categories: wireshark lua dissector usb
---

I have [previously]({% post_url 2017-11-04-creating-a-wireshark-dissector-in-lua-1 %}) experimented
with creating Wireshark dissectors in Lua. The dissector I made back then was for a network
protocol. Wireshark can also sniff USB traffic, so I thought it would be interesting to take a look
at that too.

In this post I'll try to create a dissector for my Logitech MX518 mouse. It has two ordinary buttons,
a scroll wheel that also doubles as the third button, backward/forward buttons, a "switch button" and
two buttons for adjusting mouse sensitivity.

If you are trying to use this blog post as a tutorial, you should first take a look at the blog post
series I linked to above. It has an introduction to Lua and creating Lua dissectors in general.

### First experiment

We have to install USBPCap on Windows, or use usbmon on Linux, in order to sniff USB traffic in
Wireshark. If it's installed correctly it should look like this when capturing on the USB
interface:

![Wireshark without dissector]({{ "/assets/creating-wireshark-usb-dissectors-1/wireshark-without-dissector.png" | absolute_url }})

This shows all USB traffic, including the keyboard and anything else that is using USB. The
"Leftover Capture Data" is the application layer and what I consider interesting. Wireshark doesn't
dissect it, so that's what I want to write a dissector for. I use the following filter to show only
the packets that go from the mouse to the computer:

![Filter for usb.src]({{ "/assets/creating-wireshark-usb-dissectors-1/wireshark-filter-for-src.png" | absolute_url }})

The packets are called *reports* when using HID (described below). My PC is the *host* and the mouse
is *1.7.1*. The source name seems to vary between captures. I had *1.2.1* in the first screenshot
and *1.7.1* in the second. The host will send an ack report for each report it receives from the
device, back to the device. The filter I use in the screenshot will filter out the ack reports, as
they are just noise. USB is usually little endian, by the way.

At this stage I'll try to reverse engineer the mouse data without looking at the specification. I am
mainly interested in two things: capturing button presses and mouse movements.

Starting off, all the bytes are 0. Pressing only one button, one by one, yields:

- Left button:

  Hexadecimal: 0x01<br/>
  Binary: 0000 0001

  ![Left click bytes]({{ "/assets/creating-wireshark-usb-dissectors-1/left-click-bytes.png" | absolute_url }})

- Right button:

  Hexadecimal: 0x02<br/>
  Binary: 0000 0010

  ![Right click bytes]({{ "/assets/creating-wireshark-usb-dissectors-1/right-click-bytes.png" | absolute_url }})

- Middle button:

  Hexadecimal: 0x04<br/>
  Binary: 0000 0100

  ![Middle click bytes]({{ "/assets/creating-wireshark-usb-dissectors-1/middle-click-bytes.png" | absolute_url }})

- Back button:

  Hexadecimal: 0x08<br/>
  Binary: 0000 1000

  ![Back click bytes]({{ "/assets/creating-wireshark-usb-dissectors-1/back-click-bytes.png" | absolute_url }})

- Forward button:

  Hexadecimal: 0x10<br/>
  Binary: 0001 0000

  ![Forward click bytes]({{ "/assets/creating-wireshark-usb-dissectors-1/forward-click-bytes.png" | absolute_url }})

- Switch button:

  Hexadecimal: 0x20<br/>
  Binary: 0010 0000

  ![Switch click bytes]({{ "/assets/creating-wireshark-usb-dissectors-1/switch-click-bytes.png" | absolute_url }})


Nothing is sent when the mouse sensitivity buttons are clicked. I think the mouse changes the
reporting frequency internally when using these buttons. They don't seem to change anything related to
software.

Holding down two buttons at the same time yields:

- Left + right buttons:

  Hexadecimal: 0x03<br/>
  Binary: 0000 0011

  ![Left+right click bytes]({{ "/assets/creating-wireshark-usb-dissectors-1/left-right-click-bytes.png" | absolute_url }})

- Back + left buttons:

  Hexadecimal: 0x09<br/>
  Binary: 0000 1001

  ![Back+left click bytes]({{ "/assets/creating-wireshark-usb-dissectors-1/back-left-click-bytes.png" | absolute_url }})

So it's easy to see what's going on here: a button is represented as one bit. The first byte
therefore contains the state of 8 buttons.

When I scroll the mouse, without doing anything else, I see:

- Up: 0x01

  ![Scroll up bytes]({{ "/assets/creating-wireshark-usb-dissectors-1/scroll-up-bytes.png" | absolute_url }})

- Down: 0xff

  ![Scroll down bytes]({{ "/assets/creating-wireshark-usb-dissectors-1/scroll-down-bytes.png" | absolute_url }})

Here it's also easy to see what's going on: the fourth byte is 1 (in decimal) when scrolling up
and -1 when scrolling down. Down could also be 255 when scrolling down, if the field was unsigned,
but that is unlikely.

I can see that the rest of the bytes change to something non-zero when moving the pointer around,
so I assume they represent X and Y position in some way, but I'll look at that later.

### Creating the first dissector

Now that we know how the buttons and scroll wheel work, we can create the first dissector. We can
pretty much copy/paste the boilerplate code from the previous network dissector series. The
dissector will then look like this:

```lua
usb_mouse_protocol = Proto("USB_mouse",  "USB mouse protocol")

local buttons   = ProtoField.uint8("usb_mouse.buttons",   "Buttons",   base.DEC)
local scrolling = ProtoField.int8 ("usb_mouse.scrolling", "Scrolling", base.DEC)

usb_mouse_protocol.fields = { buttons, scrolling }

function usb_mouse_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = usb_mouse_protocol.name

  local subtree = tree:add(usb_mouse_protocol, buffer(), "USB Mouse Data")
  
  subtree:add_le(buttons,   buffer(0,1))
  subtree:add_le(scrolling, buffer(3,1))
end

DissectorTable.get("usb.interrupt"):add(0xffff, usb_mouse_protocol)
```

It doesn't do much. It parses two fields, but we need something to see that the dissection works
as it should. And it does:

![First dissector bytes]({{ "/assets/creating-wireshark-usb-dissectors-1/first-dissector-bytes.png" | absolute_url }})

A USB dissector works just like a network packet dissector. The only difference is that we don't
connect our new dissector to the *tcp.port* table. Instead, we use the *usb.interrupt* table,
and use the USB interface class as value (*0xffff*). Other tables that can be used are *usb.control*
and *usb.bulk*. I'm not sure where they are used, but I think *usb.bulk* is used for USB HDD traffic.

The dissector only shows a number for button and scrolling status. I would like to show text as well,
so I expand the dissector:

```lua
usb_mouse_protocol = Proto("USB_mouse",  "USB mouse protocol")

local buttons   = ProtoField.uint8("usb_mouse.buttons",   "Buttons",   base.DEC)
local scrolling = ProtoField.int8 ("usb_mouse.scrolling", "Scrolling", base.DEC)

usb_mouse_protocol.fields = { buttons, scrolling }

local scrolling_lookup = {
  [-1] = " (down)",
  [ 0] = " (not scrolling)",
  [ 1] = " (up)"
}

local function parse_buttons(buffer)
  -- byte & (1 << n) > 0
  local function is_bit_set(byte, n)
    return bit.band(byte, bit.lshift(1, n)) > 0
  end

  local LEFT_BUTTON_BIT    = 0
  local RIGHT_BUTTON_BIT   = 1
  local MIDDLE_BUTTON_BIT  = 2
  local BACK_BUTTON_BIT    = 3
  local FORWARD_BUTTON_BIT = 4
  local SWITCH_BUTTON_BIT  = 5

  local buttons_number = buffer(0,1):le_uint()
  local buttons_array = {}

  if is_bit_set(buttons_number, LEFT_BUTTON_BIT)    then table.insert(buttons_array, "left")    end
  if is_bit_set(buttons_number, RIGHT_BUTTON_BIT)   then table.insert(buttons_array, "right")   end
  if is_bit_set(buttons_number, MIDDLE_BUTTON_BIT)  then table.insert(buttons_array, "middle")  end
  if is_bit_set(buttons_number, BACK_BUTTON_BIT)    then table.insert(buttons_array, "back")    end
  if is_bit_set(buttons_number, FORWARD_BUTTON_BIT) then table.insert(buttons_array, "forward") end
  if is_bit_set(buttons_number, SWITCH_BUTTON_BIT)  then table.insert(buttons_array, "switch")  end

  local buttons_text = " (none)"
  
  if #buttons_array ~= 0 then
    buttons_text = " (" .. table.concat(buttons_array, ", ") .. ")"
  end

  return buttons_text
end

function usb_mouse_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = usb_mouse_protocol.name

  local subtree = tree:add(usb_mouse_protocol, buffer(), "USB Mouse Data")
  
  local buttons_text   = parse_buttons(buffer)
  local scrolling_text = scrolling_lookup[buffer(3,1):le_int()]

  subtree:add_le(buttons,   buffer(0,1)):append_text(buttons_text)
  subtree:add_le(scrolling, buffer(3,1)):append_text(scrolling_text)
end

DissectorTable.get("usb.interrupt"):add(0xffff, usb_mouse_protocol)
```

I've created a new function: `parse_buttons()`. `parse_buttons()` returns a string with
information on what buttons that are clicked. I have also made a value string called `scrolling_lookup`,
which converts the number found in the scroll byte (in decimal) to either "(up)", "(down)" or
"(not scrolling)". The strings are shown next to the button and scroll status numbers.

The code is pretty self-explanatory. To find out whether a button is clicked or not I use bit
manipulation on the first byte.

This is what the tree looks like after reloading the dissector, and then capturing while clicking
the left and right button at the same time, while scrolling up:

![Second dissector bytes]({{ "/assets/creating-wireshark-usb-dissectors-1/second-dissector-bytes.png" | absolute_url }})

### HID

It was fairly easy to figure out how the mouse buttons and scroll wheel work without looking at any formal
specifications. The mouse movement seems to be related to either the second and third byte, or
the fifth to eight bytes. So in order to figure out how to get the mouse position we have to look
up how the USB protocol actually works.

USB devices such as keyboards and mice use something called HID (Human Interface Devices). HID is kind of
a protocol on top of USB that provides a standardized way for keyboards and mice to communicate with
the host. My mouse uses HID rather than a proprietary Logitech driver when communicating with my PC.

If you are interested in reading more about HID, you can do that [here][who-t-understanding-hid-report-descriptors]
or [here][eleccelerator-tutorial-about-hid-report-descriptors]. In summary, when the mouse gets
connected to the PC it will send a report descriptor to it that tells the PC how the mouse will
send data. For instance, what does the first byte represent, what does the second represent, and so
on. How to find the report descriptors can be read about [here][how-to-dump-report-descriptor]. The
report descriptor for my mouse looks like this:

```
Usage Page (Desktop),                   ; Generic desktop controls (01h)
Usage (Mouse),                          ; Mouse (02h, application collection)
Collection (Application),
    Usage (Pointer),                    ; Pointer (01h, physical collection)
    Collection (Physical),
        Usage Page (Button),            ; Button (09h)
        Usage Minimum (01h),
        Usage Maximum (08h),
        Logical Minimum (0),
        Logical Maximum (1),
        Report Count (8),
        Report Size (1),
        Input (Variable),
        Report Count (0),
        Input (Constant, Variable),
        Usage Page (FF00h),             ; FF00h, vendor-defined
        Usage (40h),
        Report Count (2),
        Report Size (8),
        Logical Minimum (-127),
        Logical Maximum (127),
        Input (Variable),
        Usage Page (Desktop),           ; Generic desktop controls (01h)
        Usage (Wheel),                  ; Wheel (38h, dynamic value)
        Logical Minimum (-127),
        Logical Maximum (127),
        Report Size (8),
        Report Count (1),
        Input (Variable, Relative),
        Usage (X),                      ; X (30h, dynamic value)
        Usage (Y),                      ; Y (31h, dynamic value)
        Logical Minimum (-32767),
        Logical Maximum (32767),
        Report Size (16),
        Report Count (2),
        Input (Variable, Relative),
    End Collection,
End Collection
```

Every `Usage Page` represents a field I am interested in. The report descriptor for my mouse is divided into
the following pages (fields):

```
Usage Page (Button),            ; Button (09h)
Usage Minimum (01h),
Usage Maximum (08h),
Logical Minimum (0),
Logical Maximum (1),
Report Count (8),
Report Size (1),
Input (Variable),
Report Count (0),
Input (Constant, Variable),
```

The unit of *Report Size* is bit. This usage page says that the button state is
*8 (Report Count) * 1 (Report Size) = 8 bits*, which is one byte. One bit
represents button state for one button. The next section looks like this:

```
Usage Page (FF00h),             ; FF00h, vendor-defined
Usage (40h),
Report Count (2),
Report Size (8),
Logical Minimum (-127),
Logical Maximum (127),
Input (Variable),
```

This says that the next two bytes are vendor defined. The fields are signed, because the logical minimum is
negative. The next section is for the wheel:

```
Usage Page (Desktop),           ; Generic desktop controls (01h)
Usage (Wheel),                  ; Wheel (38h, dynamic value)
Logical Minimum (-127),
Logical Maximum (127),
Report Size (8),
Report Count (1),
Input (Variable, Relative),
```

It says that the wheel (up-down-status) is represented with one byte. The field is signed, because the logical
minimum is negative. The final section looks like this:

```
Usage (X),                      ; X (30h, dynamic value)
Usage (Y),                      ; Y (31h, dynamic value)
Logical Minimum (-32767),
Logical Maximum (32767),
Report Size (16),
Report Count (2),
Input (Variable, Relative),
```

There is an int16 for the X axis and an int16 for the Y axis. The values are relative. The fields are signed
because the logical minimum is negative.

### Creating the final dissector

With the things we learned from the report descriptor we can create the final dissector:

```lua
usb_mouse_protocol = Proto("USB_mouse",  "USB mouse protocol")

local buttons   = ProtoField.uint8("usb_mouse.buttons",   "Buttons",   base.DEC)
local vendor1   = ProtoField.int8 ("usb_mouse.vendor1",   "Vendor 1",  base.DEC)
local vendor2   = ProtoField.int8 ("usb_mouse.vendor2",   "Vendor 2",  base.DEC)
local scrolling = ProtoField.int8 ("usb_mouse.scrolling", "Scrolling", base.DEC)
local x_offset  = ProtoField.int16("usb_mouse.x_offset",  "X offset",  base.DEC)
local y_offset  = ProtoField.int16("usb_mouse.y_offset",  "Y offset",  base.DEC)

usb_mouse_protocol.fields = {
  buttons, vendor1, vendor2,
  scrolling, x_offset, y_offset,
}

local scrolling_lookup = {
  [-1] = " (down)",
  [ 0] = " (not scrolling)",
  [ 1] = " (up)"
}

local function parse_buttons(buffer)
  -- byte & (1 << n) > 0
  local function is_bit_set(byte, n)
    return bit.band(byte, bit.lshift(1, n)) > 0
  end

  local LEFT_BUTTON_BIT    = 0
  local RIGHT_BUTTON_BIT   = 1
  local MIDDLE_BUTTON_BIT  = 2
  local BACK_BUTTON_BIT    = 3
  local FORWARD_BUTTON_BIT = 4
  local SWITCH_BUTTON_BIT  = 5

  local buttons_number = buffer(0,1):le_uint()
  local buttons_array = {}

  if is_bit_set(buttons_number, LEFT_BUTTON_BIT)    then table.insert(buttons_array, "left")    end
  if is_bit_set(buttons_number, RIGHT_BUTTON_BIT)   then table.insert(buttons_array, "right")   end
  if is_bit_set(buttons_number, MIDDLE_BUTTON_BIT)  then table.insert(buttons_array, "middle")  end
  if is_bit_set(buttons_number, BACK_BUTTON_BIT)    then table.insert(buttons_array, "back")    end
  if is_bit_set(buttons_number, FORWARD_BUTTON_BIT) then table.insert(buttons_array, "forward") end
  if is_bit_set(buttons_number, SWITCH_BUTTON_BIT)  then table.insert(buttons_array, "switch")  end

  local buttons_text = " (none)"
  
  if #buttons_array ~= 0 then
    buttons_text = " (" .. table.concat(buttons_array, ", ") .. ")"
  end

  return buttons_text
end

function usb_mouse_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = usb_mouse_protocol.name

  local subtree = tree:add(usb_mouse_protocol, buffer(), "USB Mouse Data")
  
  local buttons_text   = parse_buttons(buffer)
  local scrolling_text = scrolling_lookup[buffer(3,1):le_int()]

  subtree:add_le(buttons,   buffer(0,1)):append_text(buttons_text)
  subtree:add_le(vendor1,   buffer(1,1))
  subtree:add_le(vendor2,   buffer(2,1))
  subtree:add_le(scrolling, buffer(3,1)):append_text(scrolling_text)
  subtree:add_le(x_offset,  buffer(4,2))
  subtree:add_le(y_offset,  buffer(6,2))
end

DissectorTable.get("usb.interrupt"):add(0xffff, usb_mouse_protocol)
```

I parse four new fields: `vendor1`, `vendor2`, `x_offset` and `y_offset`. `vendor1` and `vendor2` are
not very interesting. I think they are X and Y offset with 8-bit resolution. They might be there for
backwards compatibility. `x_offset` is the movement of the mouse in X direction compared to previous
update. `y_offset` is the same, but in Y direction. I know they are offsets because the report descriptor
said the positions were relative. There are also devices that can output absolute positions (touch screens
for instance), but my mouse gives relative position.

The final dissector looks like this in Wireshark:

![Final dissector bytes]({{ "/assets/creating-wireshark-usb-dissectors-1/final-dissector-bytes.png" | absolute_url }})

### Exporting and analyzing the result in Python

Now that the dissector is complete, I want to plot the X and Y position to check that the dissector works
correctly. The packets can be exported to JSON by going to **File --> Export Packet Dissections --> As JSON...**.
Here is a snippet of the JSON file (which I saved as Circle.json):

```json
[
  {
    "_index": "packets-2019-07-20",
    "_type": "pcap_file",
    "_score": null,
    "_source": {
      "layers": {
        "frame": {...},
        "usb": {...},
        "_ws.lua.fake": "",
        "usb_mouse": {
          "usb_mouse.buttons": "0",
          "usb_mouse.vendor1": "0",
          "usb_mouse.vendor2": "-1",
          "usb_mouse.scrolling": "0",
          "usb_mouse.x_offset": "0",
          "usb_mouse.y_offset": "-1"
        }
      }
    }
  },
  {
    "_index": "packets-2019-07-20",
    "_type": "pcap_file",
    "_score": null,
    "_source": {
      "layers": {...}
    }
    ...
  }
```

It contains an array of packet objects, meaning each packet/report is an object. There is a sub
object called `_source`, that contains a sub object called `layers`, that contains the `usb_mouse`
object that I am interested in. Here is a Python script that parses the JSON file and plots the X
and Y positions:

```python
import itertools
import json
import matplotlib.pyplot as plt


def main():
  packets_export_file = open('Circle.json')
  packets = json.load(packets_export_file)

  x_offsets = [int(p["_source"]["layers"]["usb_mouse"]["usb_mouse.x_offset"])
    for p in packets]

  y_offsets = [-int(p["_source"]["layers"]["usb_mouse"]["usb_mouse.y_offset"])
    for p in packets]

  x_positions = list(itertools.accumulate(x_offsets))
  y_positions = list(itertools.accumulate(y_offsets))

  plt.plot(x_positions, y_positions)
  plt.title("Mouse position")
  plt.xlabel("X")
  plt.ylabel("Y")
  plt.show()
  
main()
```

The JSON file is open and deserialized into a list (`packets`). I use list comprehension to store
all the offsets in `x_offsets` and `y_offsets`. As mentioned before, the offsets are distances away
from the previous position. In order to get the actual position, we have to sum up the offsets with
`itertools.accumulate()`.

Pyplot is used for plotting. Here is the plot:

![Plot of mouse position - circle]({{ "/assets/creating-wireshark-usb-dissectors-1/circle.png" | absolute_url }})

I was moving my mouse in a circular manner when capturing packets, which means the plot looks
correct, and that the dissector parses the positions correctly. You can find the final code
[here][mikas-github-usb-mouse-dissector].

[how-to-dump-report-descriptor]: https://github.com/tmk/tmk_keyboard/wiki/HID-Report-Descriptor
[who-t-understanding-hid-report-descriptors]: http://who-t.blogspot.com/2018/12/understanding-hid-report-descriptors.html
[eleccelerator-tutorial-about-hid-report-descriptors]: https://eleccelerator.com/tutorial-about-usb-hid-report-descriptors/
[mikas-github-usb-mouse-dissector]: https://github.com/mika-s/mika-s.github.io/blob/master/assets/creating-wireshark-usb-dissectors-1/usb_mouse.lua
