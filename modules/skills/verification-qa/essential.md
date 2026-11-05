## Fast Development verification

1. For observable behavior changes, use focused automated tests for important
   changed behavior and common edge cases; add or update tests when existing
   coverage does not establish the guarantees.
2. Add integration checks when component tests cannot establish a required
   interaction.
3. Reuse existing checks and avoid repeating coverage that adds no distinct
   evidence.
4. If required behavior cannot be tested, report why, what remains
   unverified, and the residual risk.
5. Report what passed and any relevant gaps or assumptions.
