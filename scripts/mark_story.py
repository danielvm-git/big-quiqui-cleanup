#!/usr/bin/env python3
"""Mark a story done and advance active_story: python3 scripts/mark_story.py e01s01 e01s02"""
import re
import sys

done, nxt = sys.argv[1], sys.argv[2]
path = "specs/execution-status.yaml"
text = open(path).read()
open(path, "w").write(re.sub(rf"^  {done}: \w+", f"  {done}: done", text, flags=re.M))
path = "specs/state.yaml"
text = open(path).read()
open(path, "w").write(re.sub(r"^active_story: .*", f"active_story: {nxt}", text, flags=re.M))
