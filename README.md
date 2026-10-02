# Imajev Deployment

Lightweight deployment of [imajev](https://github.com/mohit67890/imajev), a Jev-like model for automated decision-making.

## Deployment

### Local

Run with Podman:

```sh
podman build -t imajev:latest -f Containerfile

podman run -d \
  --name imajev \
  --replace \
  -p 8765:8765 \
  -v ./.cache/huggingface:/app/imajev/.cache/huggingface \
  -v ./adapters:/app/imajev/adapters \
  imajev:latest
```

> [!NOTE]
> If running on Mac Silicon, you will not get fully supported GPU acceleration. 
> You will only be able to use the CPU version of the model instead.
> For full metal support, clone and set up the [imajev repository](https://github.com/mohit67890/imajev) locally.

### Openshift

Run on Openshift: 

```sh
oc login --server=<server> --token=<token>

oc apply -f imajev.yaml -n <namespace>
```

> [!NOTE]
> The deployment uses specific configuration for a ROSA cluster with scaling GPU nodes.
> If you have a different configuration, you will need to update or remove this from the file.
> ```yaml
> spec:
>   template:
>     spec:
>       nodeSelector:
>         gpu-pool-size: small
>       tolerations:
>         - key: "nvidia.com/gpu"
>           operator: "Equal"
>           value: "true"
>           effect: "NoSchedule"
> ```
> This selector & toleration places it on a 1x L40S node.

## Usage

Set the `SERVER_URL` in your environment, e.g.:

```sh
export SERVER_URL=http://localhost:8765
```

A user interface is available at `open $SERVER_URL`, and a SystemOne-compatible API is available at `$SERVER_URL/v1/systemone`.
The documentation for the SystemOne API is [available here](https://docs.typesafe.ai/api).

Example:

```sh
curl -sS $SERVER_URL/v1/systemone \
  -H 'content-type: application/json' \
  -d '{"state":{"ticket":{"id":"TKT-48812","from":"dana.okafor@northwind-labs.example","received":"2026-09-21T08:14:00Z","subject":"Charged twice for the September seats - third email","body":"We were billed 480 USD twice on 3 September for the same 12 seats. I have now written three times and the only reply was an automated one. Our finance close is on Wednesday and I need the duplicate reversed before then. Nothing is broken in the product itself.","plan":"Team (12 seats)","prior_tickets_90d":2}},"questions":{"department":{"type":"choice","instructions":"Which department should own this ticket?","criteria":{"billing":"payments, invoices, refunds and subscription charges","technical_support":"the product is broken, erroring or unavailable","sales":"new seats, upgrades, quotes and renewals","account_management":"ownership, access and contract administration"}},"urgent":{"type":"noul","instructions":"This ticket needs a reply today.","criteria":{"true":"money is at stake or the customer has a dated deadline within days","false":"it can wait for the normal queue"}},"frustration":{"type":"score","instructions":"How frustrated does the customer sound?","criteria":["calm and matter-of-fact","impatient: chasing a reply or repeating themselves","angry: threatening to escalate, churn or dispute the charge"]}}}'
```

Or try the Python script:

```sh
uv venv
uv pip install ruff requests

uv run sample_inference.py --base-url $SERVER_URL
```

## Development

### Publish Images

Build images for amd64 and publish:

```sh
podman build \                                 
  --platform linux/amd64 \
  --pull=always \
  -t quay.io/rh_ee_taagarwa/imajev:amd64 \
  -f Containerfile .
```
