#!/usr/bin/env python3

import jinja2
import os
import sys

if __name__ == "__main__":
  template = jinja2.Template(sys.stdin.read(), lstrip_blocks=True, trim_blocks=True)
  random = os.urandom(3).hex()
  output = template.render(random=random)
  print(output)
