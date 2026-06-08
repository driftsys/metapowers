#!/usr/bin/env python3
"""Score a long-tail shape-index run against confirmed ground-truth tokens.

Usage: score-longtail.py <run.out> [<run.out> ...]
Prints per-icon hit/miss and a total /8 per file. Lenient on the GCP
compute_engine `_2` suffix (records exact-vs-base separately).
"""
import sys, re

# (label, canonical renderable token, lenient substring to credit "knew the token")
ICONS = [
    ("AWS Athena",                "mxgraph.aws4.athena",                "mxgraph.aws4.athena"),
    ("AWS Step Functions",        "mxgraph.aws4.step_functions",        "mxgraph.aws4.step_functions"),
    ("AWS Kinesis Data Firehose", "mxgraph.aws4.kinesis_data_firehose", "mxgraph.aws4.kinesis_data_firehose"),
    ("AWS Cognito",               "mxgraph.aws4.cognito",               "mxgraph.aws4.cognito"),
    ("GCP Compute Engine",        "mxgraph.gcp2.compute_engine_2",      "mxgraph.gcp2.compute_engine"),
    ("GCP Cloud Monitoring",      "mxgraph.gcp2.cloud_monitoring",      "mxgraph.gcp2.cloud_monitoring"),
    ("Azure Active Directory",    "mxgraph.azure.azure_active_directory","mxgraph.azure.azure_active_directory"),
    ("Alibaba ActionTrail",       "mxgraph.alibaba_cloud.actiontrail",  "mxgraph.alibaba_cloud.actiontrail"),
]

def score(path):
    txt = open(path, encoding="utf-8", errors="replace").read()
    exact = lenient = 0
    rows = []
    for label, canon, base in ICONS:
        e = canon in txt
        l = base in txt
        exact += e
        lenient += l
        mark = "OK" if e else ("~base" if l else "MISS")
        rows.append(f"    {label:28} {mark}")
        rows.append(f"      need: {canon}")
    return exact, lenient, rows

for path in sys.argv[1:]:
    e, l, rows = score(path)
    print(f"== {path}: exact {e}/8, lenient {l}/8 ==")
    print("\n".join(rows))
    print()
