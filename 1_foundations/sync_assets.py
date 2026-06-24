"""Copy course images into this folder so notebook markdown can load them locally."""

from pathlib import Path
import shutil

REPO_ASSETS = Path(__file__).resolve().parent.parent / "assets"
LOCAL_ASSETS = Path(__file__).resolve().parent / "assets"

ASSET_NAMES = (
    "stop.png",
    "tools.png",
    "exercise.png",
    "business.png",
    "autonomy.png",
    "thanks.png",
    "aaa.png",
    "business.jpg",
    "voyage.jpg",
)


def main() -> None:
    LOCAL_ASSETS.mkdir(exist_ok=True)
    copied = 0
    for name in ASSET_NAMES:
        src = REPO_ASSETS / name
        dst = LOCAL_ASSETS / name
        if not src.is_file():
            print(f"skip (missing upstream): {src}")
            continue
        shutil.copy2(src, dst)
        copied += 1
        print(f"copied: {name}")
    print(f"done — {copied} file(s) in {LOCAL_ASSETS}")


if __name__ == "__main__":
    main()
