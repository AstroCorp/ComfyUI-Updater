# ComfyUI Updater

Script to update ComfyUI portable on Windows and migrate desired directories from previous version.

> [!WARNING]
> This is a personal script. If you need to modify it, feel free to create a fork and adapt it to your needs.

## Requirements

- A terminal compatible with Bash (e.g., Git Bash, WSL, or similar).
- The `7z` command available in your terminal. You can get it by installing [Nanazip](https://github.com/M2Team/NanaZip) or [7-Zip](https://www.7-zip.org/).

## Usage

1. Open your terminal in the project folder.
2. Run the script:
   ```bash
   bash updater.sh
   ```
3. Enter the target version and your current ComfyUI path when prompted.

The script will validate your input, download the specified version, and automatically move models and output files. Additionally, it will create hard links to the `output` and `models` directories, ensuring that your data remains accessible. The script also installs `ComfyUI-Manager` to enhance your workflow.

---

If you have issues with the `7z` command, make sure it is in your PATH and you can run it from the terminal.
