
# ttyd (ttyd)

Installs ttyd - Share your terminal over the web. https://tsl0922.github.io/ttyd The ttyd options (port, cols, fontSize, readOnly) control the auto-generated .devcontainer/ttyd.sh script, but are ignored if a .devcontainer/ttyd.sh file already exists.

## Example Usage

```json
"features": {
    "ghcr.io/stu-bell/devcontainer-features/ttyd:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Version of ttyd to install (e.g., '1.7.4' or 'latest') | string | latest |
| port | Port to run ttyd on. | string | 7681 |
| cols | Number of columns for the terminal. | string | 80 |
| fontSize | Font size for the terminal. | string | 20 |
| readOnly | If true, ttyd will be read-only (removes -W flag). | boolean | false |

ttyd: [tsl0922.github.io/ttyd)](https://tsl0922.github.io/ttyd)



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/stu-bell/devcontainer-features/blob/main/src/ttyd/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
