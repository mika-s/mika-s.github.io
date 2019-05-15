---
layout: post
title:  "Creating a Wireshark dissector in Lua - part 4 (separate subtrees)"
date:   2018-12-16 12:00:00 +0100
categories: wireshark lua dissector
---

This post continues where [the third post]({% post_url 2017-11-08-creating-a-wireshark-dissector-in-lua-3 %}) left off.
A reader told me it would be nice to have the header and the payload separated into two different sub trees, so in this
post I'll explain how we can do that.

### Sub trees

I am using the dissector from part three. I will only look at the `OP_QUERY` and `OP_REPLY` messages, otherwise the
dissector gets too big for a blog post.

I should explain what a sub tree is first. Sub trees are the dropdown menus you see in the packet details pane in Wireshark:

![Sub trees]({{ "/assets/creating-wireshark-dissectors-4/what-are-subtrees.png" | absolute_url }}){: style="margin-top: 15px; margin-bottom: 30px;" }

At the moment the dissector has one main sub tree for the entire MongoDB protocol. We want to add two new sub trees as
children of the MongoDB sub tree: one for the header and one for the payload. Lets just call them *Header* and *Payload*.

The two new sub trees are basically sub-sub trees, but I'll call them child sub trees.

### Add new child sub trees

A new sub tree under another sub tree called `subtree` is created with `subtree:add(proto_obj_name, buffer(), "Title")`.
The two new child sub trees are therefore made like this:

```lua
local subtree = tree:add(mongodb_protocol, buffer(), "MongoDB Protocol Data")
local headerSubtree = subtree:add(mongodb_protocol, buffer(), "Header")
local payloadSubtree = subtree:add(mongodb_protocol, buffer(), "Payload")
```

The first line was there before. That's the main sub tree. It is added to the main `tree` object that is a parameter of the
dissector function. We add two new sub trees as children of the main sub tree, and have two variables, `headerSubtree` and
`payloadSubtree` that we can use to refer to those sub trees. It should look like this now:

![Sub trees without children]({{ "/assets/creating-wireshark-dissectors-4/subtrees-without-children.png" | absolute_url }}){: style="margin-top: 15px; margin-bottom: 30px;" }

The child sub trees are empty because the fields are still pointing to the main sub tree.

### Make the fields point to the child sub trees

We have to change the sub tree that the various fields are added to. For example, for some of the header variables:

Change from:

```lua
-- Header
subtree:add_le(message_length, buffer(0,4))
subtree:add_le(request_id,     buffer(4,4))
subtree:add_le(response_to,    buffer(8,4))
```

To:

```lua
-- Header
headerSubtree:add_le(message_length, buffer(0,4))
headerSubtree:add_le(request_id,     buffer(4,4))
headerSubtree:add_le(response_to,    buffer(8,4))
```

And the payload variables:

Change from:

```lua
subtree:add_le(full_coll_name, buffer(20,string_length))
```

To:

```lua
payloadSubtree:add_le(full_coll_name, buffer(20,string_length))
```

It has to be done for all the fields. It will look like this in the end:

![Sub trees with children]({{ "/assets/creating-wireshark-dissectors-4/subtrees-with-children.png" | absolute_url }}){: style="margin-top: 15px; margin-bottom: 30px;" }

You can also find the final code [here][mikas-github-mongodb].

If you want to find out how you can split the dissector into several files you can take a look at [the fifth post]({% post_url 2018-12-18-creating-a-wireshark-dissector-in-lua-5 %}) in this series.

[mikas-github-mongodb]: https://github.com/mika-s/mika-s.github.io/blob/master/assets/creating-wireshark-dissectors-4/mongodb.lua
