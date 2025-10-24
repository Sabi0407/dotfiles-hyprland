#!/usr/bin/env python3
import json
import re
import subprocess
import sys


def wpctl_status() -> str:
    try:
        return subprocess.check_output(["wpctl", "status"], text=True, stderr=subprocess.DEVNULL)
    except (subprocess.CalledProcessError, FileNotFoundError):
        return ""


SINK_LINE_RE = re.compile(r"[^\d]*([0-9]+)\.\s+(.+)")
DEFAULT_RE = re.compile(r"Default Sink:\s*([0-9]+)\s*\((.+)\)")


def normalise_name(name: str) -> str:
    # Retire les informations de volume ou commentaires entre crochets
    return re.sub(r"\s*\[.*?\]\s*$", "", name).strip()


def classify_sink(name: str) -> str:
    lower = name.lower()
    if any(keyword in lower for keyword in ("headphone", "headset", "earbud", "earbuds", "buds")):
        return "headphones"
    if any(keyword in lower for keyword in ("bluetooth", "bt ", "wh-", "buds", "airpods")):
        return "headphones"
    if any(keyword in lower for keyword in ("speaker", "analog", "built-in", "hdmi", "monitor", "line out", "display audio", "dac")):
        return "speaker"
    return "other"


def icon_for_class(class_name: str) -> str:
    return {
        "headphones": "󰋋",
        "speaker": "󰓃",
    }.get(class_name, "󰕾")


def parse_sinks(status: str):
    sinks = []
    in_section = False
    for raw_line in status.splitlines():
        line = raw_line.rstrip()
        stripped = line.strip()
        if stripped.startswith("Sinks:"):
            in_section = True
            continue
        if in_section and stripped.startswith("Sources:"):
            break
        if not in_section:
            continue
        match = SINK_LINE_RE.search(stripped)
        if match:
            sink_id = int(match.group(1))
            name = normalise_name(match.group(2))
            sinks.append({"id": sink_id, "name": name, "class": classify_sink(name)})
    return sinks


def default_sink(status: str):
    match = DEFAULT_RE.search(status)
    if not match:
        return None
    sink_id = int(match.group(1))
    name = normalise_name(match.group(2))
    sink_class = classify_sink(name)
    return {"id": sink_id, "name": name, "class": sink_class}


def set_default(sink_id: int) -> None:
    subprocess.run(["wpctl", "set-default", str(sink_id)], check=False)


def toggle_sink(status: str) -> None:
    sinks = parse_sinks(status)
    default = default_sink(status)
    if not sinks or default is None:
        return

    target = None
    if default["class"] == "headphones":
        target = next((s for s in sinks if s["class"] == "speaker"), None)
    elif default["class"] == "speaker":
        target = next((s for s in sinks if s["class"] == "headphones"), None)

    if target is None:
        target = next((s for s in sinks if s["id"] != default["id"]), None)

    if target is not None:
        set_default(target["id"])


def cycle_sink(status: str) -> None:
    sinks = parse_sinks(status)
    default = default_sink(status)
    if not sinks or default is None:
        return

    sink_ids = [s["id"] for s in sinks]
    if default["id"] not in sink_ids:
        set_default(sink_ids[0])
        return

    current_index = sink_ids.index(default["id"])
    next_index = (current_index + 1) % len(sink_ids)
    set_default(sink_ids[next_index])


def output_status(status: str) -> None:
    default = default_sink(status)
    if default is None:
        print(json.dumps({
            "icon": "󰝟",
            "tooltip": "Audio PipeWire indisponible",
            "class": "unavailable"
        }))
        return

    icon = icon_for_class(default["class"])
    tooltip = f"Sortie par défaut : {default['name']} (ID {default['id']})"
    print(json.dumps({
        "icon": icon,
        "tooltip": tooltip,
        "class": default["class"]
    }))


def main() -> None:
    action = sys.argv[1] if len(sys.argv) > 1 else "status"
    status = wpctl_status()

    if action == "toggle":
        toggle_sink(status)
        return
    if action == "cycle":
        cycle_sink(status)
        return

    output_status(status)


if __name__ == "__main__":
    main()
