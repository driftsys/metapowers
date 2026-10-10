# Capture: retry backoff under a 30-second upstream outage

Measurements taken while testing the retry backoff change. They are input to a
follow-up change to the retry budget, which is not scheduled yet.

| `max_attempts` | Calls that failed | Mean added latency |
| -------------- | ----------------- | ------------------ |
| 3              | 41 %              | 0.7 s              |
| 5              | 12 %              | 2.9 s              |
