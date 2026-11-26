---
name: init
description: Install the rules of the delegation-policies bundle into this repository
disable-model-invocation: true
---

Run this command in the root directory of the repository. Then report its
output to the user.

```text
upskill add https://github.com/driftsys/metapowers delegation-policies --kind rule --project --claude
```

If the command fails, report the error text. Do not run another command in its
place.
