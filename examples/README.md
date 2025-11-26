# Data – (X, y) Examples

This folder contains example pairs **(X, y)** used in the thesis.

- **X** = input model of the system
  In this project, X is:
  - a DSML diagram created with the Draw.io library (file: `model.drawio`), and optionally
  - a parsed or “normalized” representation of that model (e.g. `model.json` in later stages).

- **y** = generated Ruby / Ruby on Rails artefacts
  In this project, y is:
  - Ruby / Rails code produced from the model (e.g. models, services, events),
  - stored under a `generated/` subdirectory for each example.
