# Systemd Timer Setup

Run codeREM automatically at 3 AM every night.

## Install

```bash
# Copy unit files
mkdir -p ~/.config/systemd/user/
cp nightly-dream.service ~/.config/systemd/user/
cp nightly-dream.timer ~/.config/systemd/user/

# Enable and start
systemctl --user daemon-reload
systemctl --user enable nightly-dream.timer
systemctl --user start nightly-dream.timer

# Verify
systemctl --user status nightly-dream.timer
systemctl --user list-timers
```

## Check logs

```bash
# Last run
journalctl --user -u nightly-dream.service --since today

# Trigger manually
systemctl --user start nightly-dream.service
```

## Customize schedule

Edit `nightly-dream.timer` and change the `OnCalendar` line:

```ini
# Every night at 3 AM (default)
OnCalendar=*-*-* 03:00:00

# Every 6 hours
OnCalendar=*-*-* 00/6:00:00

# Weekdays only at midnight
OnCalendar=Mon..Fri *-*-* 00:00:00
```

Then reload: `systemctl --user daemon-reload`
