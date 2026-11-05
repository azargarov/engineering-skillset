## Prototype verification

1. Run the executable in its intended environment and exercise the primary
   scenario.
2. Inspect the actual result and confirm its essential behavior. A manual or
   automated smoke check is acceptable.
3. Do not add automated tests by default. Add them when a concrete risk,
   project contract, or explicit user requirement justifies them.
4. When you omit automated tests for a behavioral change, state why the smoke
   check is sufficient for this prototype and name important guarantees it
   does not establish.
5. Record significant limitations and assumptions that remain unverified.

Keep verification focused on validating the hypothesis. Do not imply that
untested edge cases or failure behavior have been established.
