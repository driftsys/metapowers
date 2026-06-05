# tech-diagramming-drawio — shape-index eval

Verifies the bundled vendor shape-index (`skills/tech-diagramming-drawio/data/shape-index.jsonl.gz`)
resolves a known service name to its official `mxgraph.*` style string — the lookup the
SKILL teaches in place of an MCP `search_shapes`. No network, no vision.

## Deterministic check

```bash
IDX=skills/tech-diagramming-drawio/data/shape-index.jsonl.gz
gunzip -c "$IDX" | grep -i '"title":"ec2"' | grep -q 'resIcon=mxgraph.aws4.ec2' \
  && echo "PASS: EC2 → mxgraph.aws4.ec2"
```

PASS: an "EC2" lookup returns a line whose `style` carries `resIcon=mxgraph.aws4.ec2`
(the AWS-4 resource icon). Exit 0.
