import json, datetime

from os import path

now = datetime.datetime.now()

if now.isoweekday() > 5:
    ret = ""
else:
    with open(path.abspath(path.join(path.dirname(__file__), "settings.json")), "r") as fh:
        settings = json.loads("".join(fh.readlines()))

    work_hours = [sum([int(n) * (60 ** (2 - idx)) for idx, n in enumerate(i.split(":"))]) for i in settings["work_hours"].split("-")]
    lunch_breaks = [sum([int(n) * (60 ** (2 - idx)) for idx, n in enumerate(i.split(":"))]) for i in settings["lunch_breaks"].split("-")]
    now_timestamp = int(now.strftime("%H")) * 3600 + int(now.strftime("%M")) * 60 + int(now.strftime("%S"))

    if now_timestamp not in range(work_hours[0], work_hours[1] + 1800):
        ret = ""
    else:
        total = work_hours[1] - work_hours[0] - lunch_breaks[1] + lunch_breaks[0]
        elapsed = (lunch_breaks[0] if now_timestamp in range(lunch_breaks[0], lunch_breaks[1] + 1) else now_timestamp) - work_hours[0]

        elapsed -= (lunch_breaks[1] - lunch_breaks[0]) if now_timestamp > lunch_breaks[1] else 0
        elapsed = total if elapsed > total else elapsed

        ret = f"{(100 * elapsed / total):.2f}".rstrip("0")
        ret = ret[:-1] if ret[-1] == "." else ret
        ret += "%"

print(ret, end="")
