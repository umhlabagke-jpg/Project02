# Logging contract

Applications must emit one JSON object per line to stdout/stderr. Required fields are `severity`, `message`, `timestamp`, `service`, `version`, and `trace`. Do not log credentials, tokens, request bodies, or personal data. GKE workload logs are collected by Cloud Logging through the managed collection agent.
