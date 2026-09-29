#!/usr/bin/env python3
"""Ajustes y extensiones de VS Code de escritorio, desde .devcontainer/devcontainer.json:
la misma lista que usa Codespaces. Escribe settings.json y devuelve las extensiones."""
import json
import pathlib
import re
import sys

jsonc = pathlib.Path(sys.argv[1]).read_text()
vscode = json.loads(re.sub(r"^\s*//.*$", "", jsonc, flags=re.M))["customizations"]["vscode"]
ajustes = pathlib.Path(sys.argv[2])
ajustes.parent.mkdir(parents=True, exist_ok=True)
ajustes.write_text(json.dumps(vscode["settings"], indent=2, ensure_ascii=False) + "\n")
print(" ".join(vscode["extensions"]))
