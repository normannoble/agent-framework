import re, sys, datetime

path = sys.argv[1]
try:
    text = open(path, encoding="utf-8").read()
except FileNotFoundError:
    sys.exit(2)

now = datetime.datetime.now().astimezone()
tasks = re.split(r"^### ", text, flags=re.M)[1:]

def field(block, name):
    m = re.search(r"^- \*\*" + re.escape(name) + r":\*\*\s*(.+?)\s*$", block, re.M)
    return m.group(1).strip() if m else ""

def match(expr, value, lo, hi):
    if expr == "*":
        return True
    for part in expr.split(","):
        step = 1
        if "/" in part:
            part, step = part.split("/", 1); step = int(step)
        if part == "*":
            rng = range(lo, hi + 1)
        elif "-" in part:
            a, b = part.split("-", 1); rng = range(int(a), int(b) + 1)
        else:
            rng = range(int(part), int(part) + 1)
        if value in rng and (value - rng.start) % step == 0:
            return True
    return False

def parse_last(s):
    s = s.strip()
    if not s or s.lower() in ("never", "-", "—"):
        return None
    s = s.replace("Z", "+00:00")
    for fmt in ("%Y-%m-%dT%H:%M%z", "%Y-%m-%dT%H:%M:%S%z", "%Y-%m-%d %H:%M%z", "%Y-%m-%d"):
        try:
            d = datetime.datetime.strptime(s, fmt)
            return d if d.tzinfo else d.replace(tzinfo=now.tzinfo)
        except ValueError:
            pass
    return None

due = []
for block in tasks:
    tid = block.split("\n", 1)[0].strip()
    if field(block, "Enabled").lower() != "true":
        continue
    sched = field(block, "Schedule")
    m = re.search(r"`([^`]+)`", sched)
    if not m:
        continue
    parts = m.group(1).split()
    if len(parts) != 5:
        continue
    M, H, dom, mon, dow = parts
    cron_dow = (now.weekday() + 1) % 7  # cron: 0=Sun
    if not (match(dom, now.day, 1, 31) and match(mon, now.month, 1, 12) and match(dow, cron_dow, 0, 6)):
        continue
    # earliest scheduled time today
    h = int(H.split(",")[0].split("-")[0].split("/")[0]) if H != "*" else 0
    mi = int(M.split(",")[0].split("-")[0].split("/")[0]) if M != "*" else 0
    if (now.hour, now.minute) < (h, mi):
        continue
    last = parse_last(field(block, "Last run"))
    if last is not None:
        last = last.astimezone(now.tzinfo)
        if dow != "*":      # weekly-ish: same Mon-anchored week
            same = last.isocalendar()[:2] == now.isocalendar()[:2]
        elif dom != "*":    # monthly-ish
            same = (last.year, last.month) == (now.year, now.month)
        else:               # daily
            same = last.date() == now.date()
        if same:
            continue
    due.append(tid)

print(" ".join(due))
